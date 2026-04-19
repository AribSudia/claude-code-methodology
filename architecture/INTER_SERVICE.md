# Inter-Service Communication Patterns

> **When to use this file:** Only for microservices or multi-service architectures.
> Monolith projects use direct function calls — skip this file.

---

## Communication Decision Matrix

| Scenario                                        | Pattern        | Why                                           |
|-------------------------------------------------|----------------|-----------------------------------------------|
| Service A needs data from Service B right now    | **REST / gRPC** | Synchronous — caller waits for response       |
| Service A notifies others something happened     | **Event**       | Async — fire and forget, one-to-many          |
| Service A tells Service B to do something        | **Command**     | Async — one-to-one, guaranteed delivery       |
| Multi-step process across 3+ services            | **Saga**        | Orchestrated or choreographed transaction     |
| High-frequency internal calls (>1000 req/s)      | **gRPC**        | Binary protocol, streaming, lower latency     |
| Simple CRUD between services                     | **REST**        | HTTP, well understood, easy to debug          |

**Golden Rule:** Default to async events. Use sync (REST/gRPC) only when the
caller genuinely cannot proceed without the response.

---

## Pattern 1: Synchronous — REST

### When to Use
- Caller needs a response to proceed
- Simple request/response (CRUD)
- Low-to-medium frequency calls

### Implementation

```
┌──────────┐    HTTP/JSON     ┌──────────┐
│ Service A │ ───────────────▶│ Service B │
│           │ ◀─────────────── │           │
└──────────┘    Response       └──────────┘
```

### Rules
- Always set timeouts (3-5 seconds for internal calls)
- Always implement retry with exponential backoff
- Always use circuit breaker (see below)
- Never make sync calls in a loop (N+1 problem across services)
- Use bulk/batch endpoints instead: `POST /users/batch` with array of IDs

### Example: Service A calls Service B

```javascript
// ✅ CORRECT: with timeout, retry, circuit breaker
const user = await authClient.getUser(userId, {
  timeout: 3000,
  retries: 2,
  circuitBreaker: true
});

// ❌ WRONG: no timeout, no error handling
const user = await fetch(`http://auth-service/users/${userId}`);
```

---

## Pattern 2: Synchronous — gRPC

### When to Use
- High-frequency internal calls (>100 req/s between services)
- Streaming data (real-time feeds, file uploads)
- Strong typing needed across language boundaries
- Performance-critical paths

### Implementation

```protobuf
// user.proto — shared contract
syntax = "proto3";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (stream User);
  rpc UpdateUser(UpdateUserRequest) returns (User);
}

message User {
  string id = 1;
  string email = 2;
  string name = 3;
  string role = 4;
}
```

### Rules
- Share `.proto` files in a common package/repo
- Version proto definitions (never remove fields, only deprecate)
- Use deadlines (gRPC equivalent of timeouts)
- Implement health checking via gRPC Health Checking Protocol

---

## Pattern 3: Asynchronous — Events

### When to Use
- One-to-many: one service publishes, many can subscribe
- Fire-and-forget: publisher doesn't need a response
- Eventual consistency is acceptable
- Decoupling services (no direct dependency)

### Implementation

```
┌──────────┐                    ┌──────────┐
│ Service A │ ── publishes ──▶  │  Message  │ ──▶ ┌──────────┐
│           │    event          │  Broker   │     │ Service B │
└──────────┘                   │ (RabbitMQ │ ──▶ ┌──────────┐
                                │  / Kafka) │     │ Service C │
                                └──────────┘     └──────────┘
```

### Event Envelope Standard

Every event uses this envelope (defined in `EVENT_SCHEMA.md`):

```json
{
  "eventId": "evt_abc123",
  "eventType": "auth.user.registered",
  "timestamp": "2026-04-17T10:30:00Z",
  "source": "auth-service",
  "version": "1.0",
  "correlationId": "req_xyz789",
  "data": {
    "userId": "usr_456",
    "email": "user@example.com",
    "role": "customer"
  }
}
```

### Rules
- Events are IMMUTABLE — once published, never modify
- Events describe what HAPPENED (past tense: `user.registered`, not `register.user`)
- Include enough data so consumers don't need to call back
- Version events: add fields freely, never remove
- Implement idempotent consumers (same event processed twice = same result)
- Dead-letter queue for failed events (investigate, don't lose)

---

## Pattern 4: Asynchronous — Commands

### When to Use
- One-to-one: one sender, one receiver
- Guaranteed delivery needed
- Receiver must process (not optional like events)

### Implementation

```
┌──────────┐                    ┌──────────┐
│ Service A │ ── send ────────▶ │  Queue    │ ──▶ ┌──────────┐
│           │    command        │ (durable) │     │ Service B │
└──────────┘                   └──────────┘      └──────────┘
```

### Example

```json
{
  "commandId": "cmd_abc123",
  "commandType": "notification.send_email",
  "timestamp": "2026-04-17T10:30:00Z",
  "source": "core-service",
  "correlationId": "req_xyz789",
  "data": {
    "to": "user@example.com",
    "template": "welcome",
    "variables": { "name": "Abdullah" }
  }
}
```

### Difference from Events
- **Event:** "Something happened" → `user.registered` (many can listen)
- **Command:** "Do something" → `send_email` (one service must act)

---

## Pattern 5: Saga — Distributed Transactions

### When to Use
- A business operation spans multiple services
- All steps must succeed OR all must be compensated (rolled back)
- Example: Create Order → Charge Payment → Reserve Inventory

### Choreography Saga (Event-Based)

Each service listens for events and publishes the next step:

```
┌──────────┐    order.created     ┌──────────┐    payment.charged    ┌──────────┐
│  Order   │ ──────────────────▶  │ Payment  │ ──────────────────▶  │Inventory │
│ Service  │                      │ Service  │                      │ Service  │
└──────────┘                      └──────────┘                      └──────────┘
     ▲                                  │                                │
     │         payment.failed           │      inventory.reserved       │
     └──────────────────────────────────┘                                │
     │         inventory.failed                                         │
     └──────────────────────────────────────────────────────────────────┘
```

**Compensation flow:** If payment fails → cancel order. If inventory fails → refund payment → cancel order.

### Orchestration Saga (Central Coordinator)

A saga orchestrator manages the steps:

```
                    ┌──────────────┐
                    │     Saga     │
                    │ Orchestrator │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
  ┌──────────┐      ┌──────────┐      ┌──────────┐
  │  Order   │      │ Payment  │      │Inventory │
  │ Service  │      │ Service  │      │ Service  │
  └──────────┘      └──────────┘      └──────────┘
```

**Orchestrator tracks:**
- Current step
- Completed steps
- Compensation actions for rollback

### When to Use Which

| Factor              | Choreography          | Orchestration          |
|---------------------|-----------------------|------------------------|
| Number of steps     | 2-3 steps             | 4+ steps               |
| Complexity          | Simple flows          | Complex with branching |
| Visibility          | Hard to trace         | Central dashboard      |
| Coupling            | Very loose            | Orchestrator is coupled|
| Team preference     | Event-driven teams    | Workflow-oriented teams|

---

## Circuit Breaker Pattern

Prevents cascading failures when a service is down.

### States

```
     ┌─────────┐     failures > threshold     ┌──────┐
     │ CLOSED  │ ────────────────────────────▶│ OPEN │
     │(normal) │                              │(fail)│
     └────┬────┘                              └──┬───┘
          ▲                                      │
          │        success                       │ timeout expires
          │                                      ▼
          │                               ┌───────────┐
          └───────────────────────────────│ HALF-OPEN │
                                          │  (probe)  │
                                          └───────────┘
```

### Configuration

```javascript
const circuitBreaker = {
  failureThreshold: 5,        // Open after 5 consecutive failures
  resetTimeout: 30000,        // Try again after 30 seconds
  halfOpenRequests: 3,        // Allow 3 probe requests in half-open
  monitorInterval: 10000      // Check circuit state every 10s
};
```

### Rules
- Every sync call to another service MUST have a circuit breaker
- Circuit breakers must be per-service, not global
- When circuit is OPEN, return cached data or graceful degradation
- Log circuit state changes (CLOSED→OPEN, OPEN→HALF-OPEN)
- Alert when a circuit opens (something is wrong)

---

## Retry Policy

### Exponential Backoff with Jitter

```
Attempt 1: wait 0ms
Attempt 2: wait 1000ms + random(0-500ms)
Attempt 3: wait 2000ms + random(0-1000ms)
Attempt 4: give up → circuit breaker
```

### Rules
- Max 3 retries for sync calls
- Max 5 retries for async (with longer backoff)
- Always add jitter (prevents thundering herd)
- Never retry non-idempotent operations (POST without idempotency key)
- Log every retry attempt

---

## Idempotency

Every operation that can be retried MUST be idempotent.

### How to Implement

```
Client sends:
  POST /api/orders
  Idempotency-Key: idem_abc123
  Body: { ... }

Server:
  1. Check if idem_abc123 was already processed
  2. If yes → return cached response (200, not error)
  3. If no → process, store result with key, return response
```

### Rules
- All POST/PUT endpoints that change state need idempotency keys
- Store idempotency keys for at least 24 hours
- Return the SAME response for duplicate requests (including status code)
- GET and DELETE are naturally idempotent (no key needed)

---

## Service-to-Service Authentication

### Options

| Method              | When                                    | Security Level |
|---------------------|-----------------------------------------|----------------|
| **mTLS**            | Production, all internal traffic        | Highest        |
| **Service Token**   | Internal API calls with JWT             | High           |
| **API Key**         | Simple internal auth                    | Medium         |
| **Network Policy**  | Kubernetes namespace isolation          | Infrastructure |

### Recommended Approach

```
External → API Gateway (validates user JWT)
  │
  └─▶ Internal services communicate via:
       - mTLS (transport security)
       - Service JWT (identity + authorization)
       - Network policies (defense in depth)
```

**Rule:** Never trust a request just because it came from inside the network.
Always verify the calling service's identity.

---

## Anti-Patterns to Avoid

### 1. Distributed Monolith
**Symptom:** Every service calls every other service synchronously.
**Fix:** Use events for notifications, reduce sync dependencies.

### 2. Shared Database
**Symptom:** Multiple services read/write the same database tables.
**Fix:** Each service owns its data. Use events to sync.

### 3. Chatty Services
**Symptom:** Service A makes 50 API calls to Service B per request.
**Fix:** Bulk/batch APIs, or Service A caches the data it needs.

### 4. Circular Dependencies
**Symptom:** A calls B, B calls A.
**Fix:** Extract shared logic into a third service, or use events.

### 5. Synchronous Event Handling
**Symptom:** Publishing an event blocks until all consumers finish.
**Fix:** Events must be async. Publisher publishes and moves on.

### 6. No Timeout
**Symptom:** Service hangs forever waiting for a response.
**Fix:** Always set timeouts. 3-5 seconds for internal, 10-30 for external.
