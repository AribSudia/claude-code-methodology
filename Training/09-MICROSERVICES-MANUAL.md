# Claude Code Methodology v2.6.0
## Training Manual 09: Microservices Extension

**Version:** 2.6.0  
**Last Updated:** April 2026  
**Audience:** Developers building distributed systems, DevOps engineers, architects

---

## Table of Contents

1. [Introduction](#introduction)
2. [When to Use the Microservices Extension](#when-to-use)
3. [The 5 Core Extension Files](#core-files)
4. [services-check.sh Script](#services-check-script)
5. [Dev Orchestration Protocol](#dev-protocol)
6. [Architecture-Aware Bootstrap](#architecture-bootstrap)
7. [When NOT to Use Microservices](#when-not-to-use)
8. [Real-World Example: 3-Service Architecture](#real-world-example)
9. [Troubleshooting & Best Practices](#troubleshooting)

---

## Introduction

The Microservices Extension transforms your Claude Code Methodology workflow into a comprehensive guide for designing, implementing, and operating distributed systems. Rather than monolithic systems, you'll structure your application as independently deployable services that communicate through well-defined boundaries.

**Key Benefits:**
- Clear service ownership and bounded contexts
- Independent scaling and deployment
- Technology heterogeneity (different services, different stacks)
- Fault isolation and resilience
- Team autonomy and parallel development

**Prerequisites:**
- Docker and Docker Compose installed
- Kubernetes cluster access (for production)
- Basic understanding of distributed systems
- Experience with at least one messaging system (RabbitMQ, Kafka, or similar)

---

## When to Use the Microservices Extension

### Ideal Scenarios

**1. Multi-Team Organizations**
- Your organization has multiple teams responsible for different business capabilities
- Teams need to deploy independently without coordinating releases
- Team velocity is blocked by shared monolith deployment cycles

**2. Scaling Requirements at Different Rates**
- Some services experience significantly higher load than others
- You need to scale payment processing independently from the recommendation engine
- Different services have different resource requirements (CPU vs. memory)

**3. Technology Heterogeneity Requirements**
- Your data layer needs graph databases (Neo4j), key-value stores (Redis), and PostgreSQL
- Your real-time systems benefit from different languages (Go for concurrency, Python for ML)
- Your search infrastructure uses Elasticsearch while your transactional data uses MySQL

**4. Complex Domain with Clear Bounded Contexts**
- Your business domain can be divided into distinct subdomains (Orders, Billing, Inventory, Shipping)
- Each bounded context has independent data ownership
- Communication patterns are well-understood

**5. Resilience as a Core Requirement**
- Your system must remain partially operational during failures
- Single component failure cannot cascade to the entire system
- You implement circuit breakers, bulkheads, and graceful degradation

### Red Flags: When Your Organization Isn't Ready

- Single team building the entire system
- Tightly coupled domain logic that doesn't map to services
- Team lacks operational maturity for distributed debugging
- Network bandwidth is extremely constrained (microservices = more network calls)
- You have <100 RPS and simple data model (monolith sufficient)
- Developers uncomfortable with eventual consistency

---

## Core Extension Files

### 1. SERVICE_MAP.md (architecture/)

**Purpose:** Central registry of all microservices and their relationships.

**Contents:**

#### Service Registry
```
| Service      | Owner Team | Language | DB            | Status   |
|--------------|-----------|----------|---------------|----------|
| auth-service | Platform  | Go       | PostgreSQL    | Stable   |
| order-api    | Ecommerce | Node.js  | PostgreSQL    | Stable   |
| notify-svc   | Growth    | Python   | MongoDB       | Stable   |
| inventory    | Fulfil.   | Java     | PostgreSQL    | Beta     |
```

#### Service Boundaries & Responsibilities
- **auth-service**: Authentication, authorization, token management
  - Owns: User credentials, sessions, permissions
  - Does NOT own: User profiles (shared data in orders-api)

#### Dependency Matrix
Shows which services call which (synchronous only):
```
          auth  order  notify  inventory
auth        -      -      -        -
order      *      -      -        *
notify     -      *      -        -
inventory  -      *      -        -
```

#### Data Ownership
- Declare explicit data ownership to avoid duplication and consistency issues
- Example: `inventory-service` owns `inventory_items` table; `order-api` reads via API
- Identify shared data that needs eventual consistency strategies

#### Health Check Standard
Every service exposes `/health` and `/ready` endpoints:

```json
GET /health HTTP/1.1
{
  "status": "healthy",
  "timestamp": "2026-04-18T14:23:00Z",
  "checks": {
    "database": "ok",
    "cache": "ok",
    "queue": "ok"
  }
}

GET /ready HTTP/1.1
{
  "ready": true,
  "dependencies": {
    "database": "connected",
    "auth_service": "responding"
  }
}
```

#### New Service Checklist
When adding a new microservice:
- [ ] Service added to registry with owner, language, database
- [ ] Bounded context documented (what data does it own?)
- [ ] External dependencies listed (which services does it call?)
- [ ] Health check endpoints implemented
- [ ] INTER_SERVICE.md updated with communication patterns
- [ ] Docker image building documented
- [ ] Database migration strategy documented
- [ ] Monitoring and alerting configured
- [ ] On-call runbooks created
- [ ] API versioning strategy decided
- [ ] Contract tests written for all external APIs consumed

---

### 2. INTER_SERVICE.md (architecture/)

**Purpose:** Define communication patterns, protocols, and standards for service-to-service interaction.

#### Communication Patterns

**Pattern 1: REST API (Synchronous Request-Response)**
```
Order Service → Inventory Service: GET /v1/inventory/SKU-123
```
- Use for: Real-time availability checks, immediate responses
- Latency: <500ms typical
- Example: Checking stock before confirming order

```yaml
Order Service calls:
  - inventory-service:
      method: GET
      endpoint: /v1/inventory/{sku}
      timeout: 2s
      retry: true
      circuit_breaker: threshold=5_failures_in_10s
```

**Pattern 2: gRPC (Binary RPC)**
```protobuf
service InventoryService {
  rpc CheckStock(StockRequest) returns (StockResponse) {}
}
```
- Use for: High-frequency internal communication, strict performance SLAs
- Latency: <50ms typical (binary protocol, multiplexing)
- Example: Real-time pricing service calling catalog multiple times per request

```yaml
Internal only (not exposed to external clients):
  - auth-service gRPC: 50000
  - order-service gRPC: 50001
```

**Pattern 3: Event Streaming (Async Message Bus)**
```
Order Service: {event: "OrderCreated", orderId: "123", timestamp: "..."}
→ Kafka topic: "orders.created"
→ Consumed by: Notify Service, Inventory Service, Analytics
```
- Use for: Asynchronous workflows, decoupling, audit trails
- Latency: 100-1000ms acceptable
- Example: When order is created, multiple systems need to react (send email, reserve inventory, log event)

```yaml
Event Topics:
  orders.created:
    schema: OrderCreated v2
    retention: 7d
    consumers: [notify-service, inventory-service, analytics]
  
  orders.completed:
    schema: OrderCompleted v1
    retention: 30d
    consumers: [billing-service, shipping-service]
```

**Pattern 4: Sagas (Distributed Transactions)**

For operations spanning multiple services without atomic transactions:

```
OrderSaga:
  1. Order Service: Create order in PENDING state
  2. Inventory Service: Reserve stock (idempotent)
  3. Billing Service: Charge payment (idempotent)
  4. Notify Service: Send confirmation (idempotent)
  
  If step 3 fails:
    - Rollback step 2: Release stock reservation
    - Mark order FAILED
    - Notify customer
```

Orchestration vs. Choreography:
- **Orchestration** (centralized): Order Service coordinates all steps
  - Easier to understand, better error handling
  - Single point of failure (order service)
  
- **Choreography** (event-driven): Each service reacts to events
  - More decoupled, harder to visualize flow
  - Distributed debugging complexity

```yaml
OrderSaga (Orchestration):
  steps:
    - service: orders
      action: create_order_reserved
      timeout: 2s
      compensate: release_order
    
    - service: inventory
      action: reserve_stock
      timeout: 5s
      compensate: return_stock
      idempotency_key: "order-{orderId}-inventory"
    
    - service: billing
      action: charge_payment
      timeout: 10s
      compensate: refund_payment
      idempotency_key: "order-{orderId}-billing"
```

**Pattern 5: Commands (Fire-and-Forget with ACK)**
```
Order Service → Queue: {command: "SendReceipt", orderId: "123"}
← ACK: Command accepted
Notify Service: Process receipt asynchronously
```
- Use for: One-way notifications, audit logs, eventually-consistent operations
- Latency: Immediate ACK, processing delayed
- Example: Email sending, log aggregation

#### Decision Matrix for Choosing Patterns

| Requirement | REST | gRPC | Events | Sagas | Commands |
|-----------|------|------|--------|-------|----------|
| **Real-time response needed** | ✓ | ✓✓ | ✗ | ✗ | ✗ |
| **High frequency (1000s/sec)** | ~ | ✓✓ | ✓ | ~ | ✓ |
| **Decoupling important** | ✗ | ✗ | ✓✓ | ✓ | ✓ |
| **Transactional guarantee** | ~ | ~ | ✗ | ✓ | ✗ |
| **Simple point-to-point** | ✓ | ~ | ✗ | ✗ | ✓ |
| **Complex multi-step flow** | ✗ | ✗ | ✓ | ✓✓ | ✗ |
| **Built-in audit trail** | ✗ | ✗ | ✓✓ | ~ | ✓ |
| **Easy to monitor/debug** | ✓ | ✓ | ~ | ✓ | ~ |

**Decision Algorithm:**
1. Does it need real-time response? → REST or gRPC
2. Is it high-frequency? → gRPC or Events
3. Does it span multiple services? → Sagas or Events
4. Is simplicity critical? → REST or Commands
5. Is decoupling critical? → Events

#### Resilience Patterns

**Circuit Breaker with State Diagram**

```
        CLOSED (healthy)
           ↓ failure
        OPEN (failing)
           ↓ timeout
        HALF_OPEN (testing)
           ↓ success
        CLOSED
           ↓ failure (in HALF_OPEN)
        OPEN
```

States:
- **CLOSED**: Requests pass through normally. Count failures.
  - Transition to OPEN: Failure rate > 50% or >5 failures in 10s window
  
- **OPEN**: Fail fast. Don't call downstream service.
  - Transition to HALF_OPEN: After 30 seconds (configurable backoff)
  
- **HALF_OPEN**: Allow limited requests to test if downstream recovered.
  - Success: Return to CLOSED (reset counters)
  - Failure: Return to OPEN (exponential backoff: 30s → 60s → 120s)

```go
// Example: Go with github.com/grpc-ecosystem/go-grpc-middleware
import "github.com/grpc-contrib/go-grpc-middleware/retry"

conn, _ := grpc.Dial(
  "inventory:50000",
  grpc.WithUnaryInterceptor(
    grpc_retry.UnaryClientInterceptor(
      grpc_retry.WithMax(3),
      grpc_retry.WithBackoff(grpc_retry.BackoffLinear(100*time.Millisecond)),
    ),
  ),
)
```

**Retry with Exponential Backoff + Jitter**

```
Attempt 1: Fail immediately
Attempt 2: Wait 100ms + random(0-10ms), retry
Attempt 3: Wait 200ms + random(0-20ms), retry
Attempt 4: Wait 400ms + random(0-40ms), retry
Max retries: 3 (total: 700ms before giving up)
```

Prevents thundering herd (all services retrying simultaneously):
```
backoff = min(base * (2 ^ attempt), max_backoff) + random(0, jitter)
```

**Idempotency**

Every cross-service call must be idempotent (safe to retry):
```
POST /v1/orders
Headers: Idempotency-Key: "user-123-20260418-order"

First attempt: Creates order, returns 201
Retry: Detects duplicate key, returns 200 with same order
```

Implementation:
- Store idempotency keys in cache (with expiration)
- Return cached response if key seen before
- Use Redis for centralized idempotency key store

Anti-Patterns:
```
✗ Calling service without timeout (hangs forever)
✗ Retry without circuit breaker (cascading failure)
✗ Exponential backoff without jitter (thundering herd)
✗ Non-idempotent payment transactions (double charges)
✗ Calling in request-response path instead of async (latency explosion)
✗ No logging of service-to-service calls (impossible to debug)
```

---

### 3. OBSERVABILITY.md (operations/)

**Purpose:** Structured logging, distributed tracing, and metrics for visibility into distributed systems.

#### Three Pillars of Observability

**Pillar 1: Structured JSON Logging**

Every log entry is valid JSON:
```json
{
  "timestamp": "2026-04-18T14:23:45.123Z",
  "level": "ERROR",
  "service": "order-api",
  "trace_id": "abc123def456",
  "span_id": "xyz789",
  "user_id": "user-456",
  "request_id": "req-789",
  "message": "Failed to charge payment",
  "error": "payment_service_timeout",
  "error_stack": "...",
  "context": {
    "order_id": "order-123",
    "amount": 99.99,
    "currency": "USD",
    "retry_count": 2
  },
  "duration_ms": 5000
}
```

Standards:
- All services log to stdout (Docker collects to centralized logging)
- Include trace_id and span_id for correlation
- Structured context in `context` object
- One log = one JSON line

**Pillar 2: Distributed Tracing (OpenTelemetry)**

Trace follows request through services:
```
User Request
  ├─ order-api: POST /orders (100ms)
  │  ├─ inventory-api: GET /inventory/SKU (50ms)
  │  └─ billing-api: POST /charge (40ms)
  └─ notify-api: POST /send-email (1ms, async)
```

Each span has:
- Operation name (e.g., "order-api.POST /orders")
- Duration (100ms)
- Status (OK, ERROR, TIMEOUT)
- Attributes (order_id, user_id, etc.)
- Events (e.g., "retrying", "circuit_breaker_open")
- Links to child spans

Export to: Jaeger, Datadog, New Relic, or Grafana Tempo

**Pillar 3: Metrics (Prometheus)**

```
# HELP http_request_duration_seconds HTTP request duration
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{service="order-api",method="POST",path="/orders",le="0.1"} 150
http_request_duration_seconds_bucket{service="order-api",method="POST",path="/orders",le="0.5"} 295
http_request_duration_seconds_bucket{service="order-api",method="POST",path="/orders",le="1"} 298
http_request_duration_seconds_sum{service="order-api",method="POST",path="/orders"} 50.234
http_request_duration_seconds_count{service="order-api",method="POST",path="/orders"} 300

# HELP business_orders_created_total Orders created
# TYPE business_orders_created_total counter
business_orders_created_total{currency="USD"} 1520
business_orders_created_total{currency="EUR"} 340
```

Key metric types:
- **Counter**: Only increases (requests, errors, transactions)
- **Gauge**: Can go up/down (queue depth, connections)
- **Histogram**: Distribution (latency, size)

#### Four Golden Signals

Monitor these four metrics per service:

1. **Latency (p50, p95, p99)**
   ```
   API latency p50: 45ms ✓
   API latency p99: 280ms ✓
   Database query p99: 85ms ✓
   ```

2. **Traffic (requests per second)**
   ```
   order-api: 500 RPS ✓
   inventory-api: 800 RPS (bottleneck?)
   ```

3. **Errors (rate and types)**
   ```
   4xx errors: 0.5% (acceptable)
   5xx errors: 0.01% ✓
   Timeout errors: <0.001%
   ```

4. **Saturation (resource utilization)**
   ```
   CPU: 45% (healthy)
   Memory: 62% (monitoring)
   Disk I/O: 20% (healthy)
   Database connections: 85/100 (warning)
   ```

Alert when:
- p99 latency > 500ms
- Error rate > 1%
- Any 5xx errors > 0.1%
- CPU/Memory > 80%
- Database connections > 90%

#### Health Checks

Four types of health checks:

**1. Liveness (/health)**
- Is the service alive?
- Fail if: process crashed, deadlocked, unresponsive
- Response: Return immediately (no dependencies)
- Use for: Kubernetes restart decisions

```json
GET /health
200 OK
{
  "status": "healthy"
}
```

**2. Readiness (/ready)**
- Is the service ready to accept requests?
- Fail if: dependencies down, startup incomplete, draining connections
- Response: Check critical dependencies
- Use for: Load balancer decisions, routing traffic

```json
GET /ready
503 Service Unavailable
{
  "ready": false,
  "dependencies": {
    "database": "connected",
    "auth_service": "timeout",
    "cache": "connected"
  }
}
```

**3. Startup (/startup)**
- Did the service start correctly?
- Fail if: required data not loaded, initialization failed
- Response: Check one-time startup conditions
- Use for: Kubernetes startup probes (delay container restart during slow startup)

```json
GET /startup
200 OK
{
  "started": true
}
```

**4. Deep (/health/deep)**
- Comprehensive check of all subsystems
- Check: Database, cache, all downstream services
- Response: Detailed component status
- Use for: Manual debugging, dashboard health

```json
GET /health/deep
200 OK
{
  "overall": "degraded",
  "components": {
    "database": {"status": "healthy", "latency_ms": 5},
    "cache": {"status": "healthy", "latency_ms": 2},
    "message_queue": {"status": "degraded", "error": "connection_refused"},
    "downstream_auth": {"status": "healthy", "latency_ms": 45}
  }
}
```

#### Alerting Rules

```yaml
# Alert when error rate spikes
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.01
  for: 5m
  annotations:
    summary: "{{ $labels.service }} error rate above 1%"

# Alert when p99 latency exceeds budget
- alert: HighLatency
  expr: histogram_quantile(0.99, http_request_duration_seconds) > 0.5
  for: 5m
  annotations:
    summary: "{{ $labels.service }} p99 latency above 500ms"

# Alert when service is down
- alert: ServiceDown
  expr: up{job="microservices"} == 0
  for: 1m
  annotations:
    summary: "{{ $labels.service }} is down"

# Alert when database connections exhausted
- alert: DatabaseConnectionPoolExhausted
  expr: pg_stat_activity_count > 95
  for: 2m
```

#### Dashboard Layout

Dashboard should show per-service:
1. **Service Status**: Green/yellow/red status box
2. **Key Metrics**: 
   - Request rate (RPS)
   - p50/p95/p99 latency
   - Error rate (%)
   - 5xx error count
3. **Dependencies**:
   - Which services am I calling?
   - Which services call me?
   - Dependency health status
4. **Resource Usage**:
   - CPU, memory, disk
   - Database connections
5. **Business Metrics**:
   - Orders created
   - Revenue
   - Conversion rate
6. **Recent Errors**:
   - Last 10 errors
   - Error types distribution

---

### 4. CONTRACT_TESTING.md (implementation/)

**Purpose:** Ensure service contracts (APIs, events, messages) remain compatible as services evolve independently.

#### Consumer-Driven Contracts (Pact)

Pact lets you define API contracts from consumer perspective:

```javascript
// orders-service (consumer) tests
describe('Order API Contracts', () => {
  const provider = new Pact({
    consumer: 'orders-service',
    provider: 'inventory-service'
  });

  it('returns stock for a SKU', () => {
    return provider
      .addInteraction({
        state: 'inventory exists for SKU-123',
        uponReceiving: 'a request for stock',
        withRequest: {
          method: 'GET',
          path: '/v1/inventory/SKU-123'
        },
        willRespondWith: {
          status: 200,
          body: {
            sku: 'SKU-123',
            available: 45,
            reserved: 12,
            total: 57
          }
        }
      })
      .then(() => {
        // Test with mock server
        return orderService.checkStock('SKU-123');
      });
  });
});
```

Workflow:
1. Consumer writes contract tests (what it expects)
2. Test runs against Pact mock server
3. Pact generates contract JSON
4. Provider verifies it can satisfy contract
5. Provider tests run against real API
6. CI blocks deployment if contracts violated

**Contract JSON:**
```json
{
  "consumer": {"name": "orders-service"},
  "provider": {"name": "inventory-service"},
  "interactions": [
    {
      "description": "returns stock for a SKU",
      "request": {"method": "GET", "path": "/v1/inventory/SKU-123"},
      "response": {
        "status": 200,
        "body": {"sku": "SKU-123", "available": 45}
      }
    }
  ]
}
```

#### Event Contract Testing (JSON Schema)

For event-driven communication, define schemas:

```yaml
# schemas/events/order-created.schema.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "OrderCreated",
  "type": "object",
  "properties": {
    "event_type": {"const": "order.created"},
    "version": {"const": "2"},
    "order_id": {"type": "string", "pattern": "^order-[0-9]+$"},
    "user_id": {"type": "string"},
    "items": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "sku": {"type": "string"},
          "quantity": {"type": "integer", "minimum": 1},
          "price": {"type": "number", "minimum": 0}
        },
        "required": ["sku", "quantity", "price"]
      }
    },
    "total": {"type": "number", "minimum": 0},
    "timestamp": {"type": "string", "format": "date-time"}
  },
  "required": ["event_type", "version", "order_id", "user_id", "items", "total", "timestamp"],
  "additionalProperties": false
}
```

Test events against schema:
```javascript
import Ajv from 'ajv';
const ajv = new Ajv();
const validate = ajv.compile(orderCreatedSchema);

const event = {
  event_type: 'order.created',
  version: '2',
  order_id: 'order-123',
  user_id: 'user-456',
  items: [{sku: 'SKU-123', quantity: 2, price: 49.99}],
  total: 99.98,
  timestamp: '2026-04-18T14:23:00Z'
};

const valid = validate(event);
if (!valid) {
  console.error(validate.errors); // Schema violations
}
```

#### API Versioning Strategy

Use semantic versioning in URL path:

```
GET /v1/orders/123        ← Current stable
GET /v2/orders/123        ← New version (opt-in)
GET /v3/orders/123        ← Future version (coming soon)
```

Support multiple versions simultaneously:
- v1: Deprecated after 12 months
- v2: Current stable
- v3: Beta (documented, not guaranteed)

Version lifecycle:
```
v1: Current Stable
    ↓ (6 months: announce v2)
v1: Deprecated, v2: Current Stable
    ↓ (6 months more)
v1: Unsupported, v2: Stable, v3: Beta
    ↓ (v1 removed from production)
v2: Deprecated, v3: Current Stable
```

#### Breaking Change Detection

In CI/CD, detect breaking changes:

```bash
#!/bin/bash
# detect-breaking-changes.sh

OLD_SPEC="v$(git describe --abbrev=0 --tags)/openapi.json"
NEW_SPEC="./openapi.json"

npm install -g openapi-diff

openapi-diff "$OLD_SPEC" "$NEW_SPEC" \
  --fail-on breaking \
  --output-format json > changes.json

if [ $? -ne 0 ]; then
  echo "Breaking changes detected:"
  cat changes.json | jq '.breaking[]'
  exit 1
fi
```

Breaking changes:
- Removing endpoint
- Removing required parameter
- Changing response type
- Removing response field (consumers expect it)
- Changing error codes

Non-breaking:
- Adding optional parameter
- Adding new endpoint
- Adding new response field (with default)
- Reordering fields (JSON object property order is semantic)

#### CI/CD Integration

```yaml
# .github/workflows/contract-tests.yml
name: Contract Tests

on: [pull_request]

jobs:
  consumer-contracts:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm install
      - run: npm run test:contracts:consumer
      - run: npm run contracts:publish  # Publish to Pact Broker

  provider-verification:
    runs-on: ubuntu-latest
    needs: consumer-contracts
    steps:
      - uses: actions/checkout@v2
      - run: npm install
      - run: npm run test:contracts:provider  # Verify against published contracts
      - run: npm run test:contracts:event  # Validate event schemas

  breaking-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm run detect:breaking-changes
```

---

### 5. ORCHESTRATION.md (operations/)

**Purpose:** Deploy, scale, and manage microservices in development, staging, and production.

#### Docker Multi-Stage Builds

Separate build stage from runtime:

```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

CMD ["node", "dist/index.js"]
```

Benefits:
- Production image contains only runtime dependencies
- Smaller image (400MB → 180MB)
- Faster deployments
- Reduced attack surface

#### Docker Compose for Multi-Service Dev

```yaml
# docker-compose.yml
version: '3.9'

services:
  auth-service:
    build: ./services/auth
    ports:
      - "3001:3000"
    environment:
      NODE_ENV: development
      DATABASE_URL: "postgresql://user:password@postgres:5432/auth_db"
      LOG_LEVEL: debug
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - microservices
    volumes:
      - ./services/auth/src:/app/src  # Hot reload
    command: npm run dev

  order-api:
    build: ./services/orders
    ports:
      - "3002:3000"
    environment:
      NODE_ENV: development
      DATABASE_URL: "postgresql://user:password@postgres:5432/orders_db"
      AUTH_SERVICE_URL: "http://auth-service:3000"
      INVENTORY_SERVICE_URL: "http://inventory:3000"
    depends_on:
      postgres:
        condition: service_healthy
      auth-service:
        condition: service_started
    networks:
      - microservices

  inventory:
    build: ./services/inventory
    ports:
      - "3003:3000"
    environment:
      DATABASE_URL: "postgresql://user:password@postgres:5432/inventory_db"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - microservices

  notify-service:
    build: ./services/notify
    ports:
      - "3004:3000"
    environment:
      QUEUE_URL: "amqp://rabbitmq"
      SENDGRID_API_KEY: "${SENDGRID_API_KEY}"
    depends_on:
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-databases.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - microservices

  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"  # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: user
      RABBITMQ_DEFAULT_PASS: password
    healthcheck:
      test: ["CMD-SHELL", "rabbitmq-diagnostics ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - microservices

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - microservices

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"  # UI
      - "4317:4317"    # OTLP receiver
    networks:
      - microservices

networks:
  microservices:
    driver: bridge

volumes:
  postgres_data:
  prometheus_data:
```

Start all services: `docker-compose up`

#### Kubernetes Manifests

```yaml
# k8s/orders-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-api
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: order-api
  template:
    metadata:
      labels:
        app: order-api
        version: v2.1.0
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: order-api
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
      
      containers:
      - name: order-api
        image: registry.example.com/order-api:v2.1.0
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 3000
        
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: order-api-secrets
              key: database-url
        - name: LOG_LEVEL
          value: "info"
        
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        startupProbe:
          httpGet:
            path: /startup
            port: http
          failureThreshold: 30
          periodSeconds: 1

---
apiVersion: v1
kind: Service
metadata:
  name: order-api
  namespace: production
spec:
  type: ClusterIP
  ports:
  - name: http
    port: 80
    targetPort: 3000
  selector:
    app: order-api

---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-api-pdb
  namespace: production
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: order-api
```

#### Helm Charts

Helm templates deployment for easy configuration:

```yaml
# helm/values.yaml
replicaCount: 3

image:
  repository: registry.example.com/order-api
  tag: "v2.1.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5
```

Deploy: `helm install order-api ./helm -f values.yaml`

#### HPA + PDB Scaling

Horizontal Pod Autoscaler scales replicas based on metrics:

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-api
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: http_request_duration_seconds
      target:
        type: AverageValue
        averageValue: "100m"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
      selectPolicy: Max
```

PodDisruptionBudget ensures availability during cluster updates:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-api-pdb
spec:
  maxUnavailable: 1  # Keep at least 2 pods running
  selector:
    matchLabels:
      app: order-api
```

#### Deployment Strategies

**Rolling Update (Default)**
```
V1: 3 pods
V1: 2 pods + V2: 1 pod
V1: 1 pod + V2: 2 pods
V1: 0 pods + V2: 3 pods

Zero downtime, traffic gradually shifts
Good for: Most deployments
Rollback: Fast (old version still running)
```

**Canary Deployment**
```
V1: 95% traffic (3 pods)
V1: 95% traffic (3 pods) + V2: 5% traffic (1 pod)

Monitor metrics, if good:
V1: 50% traffic + V2: 50% traffic
V1: 0 pods + V2: 3 pods

Good for: High-risk deployments, rapid rollback needed
Rollback: Fast if canary shows issues
```

**Blue-Green Deployment**
```
BLUE (v1): 3 pods, load balancer routes all traffic
GREEN (v2): 3 pods, no traffic initially

Test GREEN fully

Switch load balancer to GREEN instantly
DELETE BLUE (keep for quick rollback)

Good for: Database migrations, schema changes
Rollback: Instant (just switch load balancer back)
Resource cost: 2x during deployment
```

Implement with Istio:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-api
spec:
  hosts:
  - order-api
  http:
  - match:
    - headers:
        user-agent:
          regex: ".*canary.*"
    route:
    - destination:
        host: order-api
        subset: v2
      weight: 100
  - route:
    - destination:
        host: order-api
        subset: v1
      weight: 95
    - destination:
        host: order-api
        subset: v2
      weight: 5
```

#### CI/CD Per-Service Pipelines

Each service has own pipeline (triggered on changes to that service):

```yaml
# services/order-api/.github/workflows/ci.yml
name: Order API CI

on:
  push:
    branches: [main]
    paths:
      - 'services/order-api/**'
      - '.github/workflows/order-api-ci.yml'
  pull_request:
    branches: [main]
    paths:
      - 'services/order-api/**'

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-node@v2
      with:
        node-version: '18'
    - run: npm ci
    - run: npm run test:unit
    - run: npm run test:contract  # Pact verification
    - run: npm run lint
    - run: npm run build

  integration:
    runs-on: ubuntu-latest
    needs: test
    steps:
    - uses: actions/checkout@v2
    - run: npm ci
    - run: docker-compose -f docker-compose.test.yml up -d
    - run: npm run test:integration
    - run: docker-compose -f docker-compose.test.yml down

  build-image:
    runs-on: ubuntu-latest
    needs: [test, integration]
    steps:
    - uses: actions/checkout@v2
    - uses: docker/setup-buildx-action@v1
    - uses: docker/build-push-action@v2
      with:
        context: ./services/order-api
        push: true
        tags: registry.example.com/order-api:${{ github.sha }}
        cache-from: type=registry,ref=registry.example.com/order-api:buildcache
        cache-to: type=registry,ref=registry.example.com/order-api:buildcache,mode=max

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build-image
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v2
    - run: kubectl set image deployment/order-api order-api=registry.example.com/order-api:${{ github.sha }} -n staging
    - run: kubectl rollout status deployment/order-api -n staging

  smoke-tests:
    runs-on: ubuntu-latest
    needs: deploy-staging
    steps:
    - uses: actions/checkout@v2
    - run: npm run test:smoke -- --url=https://order-api-staging.example.com
```

---

## services-check.sh Script

This shell script verifies all microservices are running before development.

**Location:** Project root or `scripts/` directory

```bash
#!/bin/bash
# services-check.sh
# Verifies all microservices are running

set -e

SERVICES=(
  "auth-service:3001"
  "order-api:3002"
  "inventory:3003"
  "notify-service:3004"
)

RABBITMQ_URL="amqp://user:password@localhost:5672"
POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
  echo "Usage: ./services-check.sh [--start|--wait|--restart|--stop|--status]"
  echo ""
  echo "Options:"
  echo "  --start    Start all microservices (docker-compose up -d)"
  echo "  --wait     Wait for all services to be ready"
  echo "  --restart  Restart all services"
  echo "  --stop     Stop all services"
  echo "  --status   Check status of all services"
}

check_service_health() {
  local service=$1
  local port=$2
  
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health 2>/dev/null || echo "000")
  
  if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓${NC} $service is healthy"
    return 0
  else
    echo -e "${RED}✗${NC} $service returned HTTP $response"
    return 1
  fi
}

check_postgres() {
  if pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U user > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} PostgreSQL is healthy"
    return 0
  else
    echo -e "${RED}✗${NC} PostgreSQL is not responding"
    return 1
  fi
}

check_rabbitmq() {
  if rabbitmq-diagnostics ping -q > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} RabbitMQ is healthy"
    return 0
  else
    echo -e "${RED}✗${NC} RabbitMQ is not responding"
    return 1
  fi
}

wait_for_services() {
  echo "Waiting for services to be ready..."
  
  local timeout=300  # 5 minutes
  local elapsed=0
  local interval=5
  
  while [ $elapsed -lt $timeout ]; do
    all_ready=true
    
    # Check database
    if ! check_postgres; then
      all_ready=false
    fi
    
    # Check message queue
    if ! check_rabbitmq; then
      all_ready=false
    fi
    
    # Check services
    for service_info in "${SERVICES[@]}"; do
      IFS=':' read -r service port <<< "$service_info"
      if ! check_service_health "$service" "$port"; then
        all_ready=false
      fi
    done
    
    if [ "$all_ready" = true ]; then
      echo -e "${GREEN}All services are ready!${NC}"
      return 0
    fi
    
    echo -e "${YELLOW}Services not ready, checking again in ${interval}s...${NC}"
    sleep $interval
    elapsed=$((elapsed + interval))
  done
  
  echo -e "${RED}Timeout waiting for services${NC}"
  return 1
}

status() {
  echo "Checking microservices status..."
  echo ""
  
  all_healthy=true
  
  echo "Infrastructure:"
  check_postgres || all_healthy=false
  check_rabbitmq || all_healthy=false
  
  echo ""
  echo "Microservices:"
  for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    check_service_health "$service" "$port" || all_healthy=false
  done
  
  echo ""
  if [ "$all_healthy" = true ]; then
    echo -e "${GREEN}All systems operational${NC}"
    return 0
  else
    echo -e "${RED}Some services are unhealthy${NC}"
    return 1
  fi
}

case "${1:-}" in
  --start)
    echo "Starting microservices..."
    docker-compose up -d
    wait_for_services
    ;;
  --wait)
    wait_for_services
    ;;
  --restart)
    echo "Restarting microservices..."
    docker-compose restart
    wait_for_services
    ;;
  --stop)
    echo "Stopping microservices..."
    docker-compose down
    ;;
  --status)
    status
    ;;
  *)
    print_usage
    exit 1
    ;;
esac
```

**Usage:**
```bash
# Start all services and wait
./services-check.sh --start

# Check status
./services-check.sh --status

# Restart
./services-check.sh --restart

# Stop
./services-check.sh --stop
```

---

## Dev Orchestration Protocol

**Critical Rule: ALL services must run during development.**

Developers cannot develop a single service in isolation. Here's why:

1. **Contract Verification**: Consumer tests need provider running
2. **End-to-End Testing**: Feature tests cross service boundaries
3. **Data Flow Validation**: Can't verify saga compensation without all participants
4. **Local Debugging**: Can't debug distributed tracing without all services emitting spans

### Protocol Steps

1. **On first checkout:**
   ```bash
   git clone <repo>
   cd project
   ./services-check.sh --start  # Starts all services, waits for ready
   npm run seed:dev             # Populate dev data
   ```

2. **Before starting work each day:**
   ```bash
   ./services-check.sh --status  # Verify all services running
   # If any failed:
   ./services-check.sh --restart
   ```

3. **When services become unhealthy:**
   ```bash
   ./services-check.sh --stop
   ./services-check.sh --start
   ```

4. **When changing service code:**
   - Docker detects changes and rebuilds
   - Service restarts automatically
   - Other services remain running

5. **When adding database migration:**
   - Migration runs on startup
   - `docker-compose up` applies to all services' databases
   - No manual migration steps needed

### Health Check Frequency

- **Liveness**: Kubernetes checks every 10 seconds
- **Readiness**: Load balancer checks every 5 seconds
- **Manual checks**: Developer runs `./services-check.sh --status` before big changes

---

## Architecture-Aware Bootstrap

When you initialize a new project with Question 13 (Q13), it triggers microservices-specific questions:

**Q13: Is this a distributed/microservices architecture?**
- YES → Ask follow-up questions:
  - How many services initially? (3-5 recommended to start)
  - Service names and primary responsibilities?
  - Which services are read-heavy vs. write-heavy?
  - Synchronous communication patterns (REST, gRPC)?
  - Asynchronous patterns (events, commands)?
  - Are there complex sagas (distributed transactions)?

**Based on answers, CCM generates:**
- SERVICE_MAP.md with your services
- INTER_SERVICE.md with your communication patterns
- docker-compose.yml with all services
- services-check.sh script
- Initial health check endpoints in each service

---

## When NOT to Use Microservices

### Use a Monolith First If:

1. **Single Small Team**
   - Microservices overhead > benefit
   - Monolith faster to deploy and understand
   - Easy to refactor into services later

2. **Simple Domain**
   - No clear bounded contexts
   - Tightly coupled business logic
   - <3 distinct data models

3. **Performance Sensitive**
   - Network latency unacceptable
   - No async processing needed
   - All data in single transaction

4. **Early Stage**
   - Business model unproven
   - Requirements changing rapidly
   - No predictable traffic patterns

5. **Resource Constrained**
   - <$50K/month infrastructure budget
   - Single/dual developer team
   - Can't manage multi-service complexity

### Monolith-First Approach

Start with monolith:
```
User Service → All Logic → Single Database
```

Migrate to services later when you hit scale:
```
User Service → API Gateway → Micros
  Order Service
  Inventory Service
  Billing Service
```

Benefits:
- Simpler initial development
- Easier to understand system
- Can refactor gradually
- Split services by business capability once proven

**Decision Point for Migration:**
- Team > 10 people (coordination overhead)
- Different services have 10x load difference
- Deployment bottleneck (waiting for unrelated tests)
- Different services need different tech stacks

---

## Real-World Example: 3-Service Architecture

E-commerce platform with three core services:

### Architecture Diagram
```
┌─────────────────┐
│   API Gateway   │ (Kong/nginx)
└────────┬────────┘
         │
    ┌────┼────┬──────────┐
    │    │    │          │
    ▼    ▼    ▼          ▼
┌─────┐ ┌──────┐ ┌────────────┐
│Auth │ │Order │ │Inventory   │
└─────┘ └──────┘ └────────────┘
    ▲    │      │         ▲
    │    │      ▼         │
    │    │  RabbitMQ  ────┘
    │    │    (Events)
    │    │
    │    ├─→ [PostgreSQL]
    │    │    - orders
    │    │    - users
    │
    ├─────► [PostgreSQL]
    │        - auth
    │
    └────────┐
             │
             ▼ [PostgreSQL]
               - inventory
```

### SERVICE_MAP.md

```
| Service   | Owner   | Language | DB         | Status |
|-----------|---------|----------|------------|--------|
| auth      | Dev1    | Go       | PostgreSQL | Stable |
| order     | Dev2/3  | Node.js  | PostgreSQL | Stable |
| inventory | Dev4    | Python   | PostgreSQL | Stable |

Dependencies:
- order-service → auth-service (verify JWT)
- order-service → inventory-service (check stock)
- order-service → rabbitmq (emit OrderCreated event)
- inventory-service ← rabbitmq (subscribe to OrderCreated)

Data Ownership:
- auth: user credentials, sessions (NOT owned by others)
- order: orders, line items, payment info
- inventory: stock levels, warehouse locations
```

### INTER_SERVICE.md

```
Communication Patterns:

1. Order → Auth (REST):
   GET /v1/users/{userId}
   Headers: Authorization: Bearer {token}
   Timeout: 2s
   Retry: 3x with exponential backoff
   Circuit breaker: 5 failures in 10s

2. Order → Inventory (REST):
   POST /v1/inventory/reserve
   Body: {skus: [{sku, qty}], orderId, idempotencyKey}
   Timeout: 5s
   Retry: 3x with exponential backoff
   Idempotency: Required

3. Order → RabbitMQ (Events):
   Topic: orders.created
   Schema: OrderCreated v2
   Consumer: inventory-service

Saga (OrderCreation):
  1. Order Service: Create order (RESERVED state)
  2. Inventory Service: Reserve stock
  3. Auth Service: Verify user is not blocked
  
  If any fails:
    - Release inventory reservation
    - Cancel order
```

### services-check.sh Output

```bash
$ ./services-check.sh --start

Starting microservices...
[+] Running 5/5
 ✓ postgres    Started
 ✓ rabbitmq    Started
 ✓ auth-service   Started
 ✓ order-api   Started
 ✓ inventory   Started

Waiting for services to be ready...
✓ PostgreSQL is healthy
✓ RabbitMQ is healthy
✓ auth-service is healthy
✓ order-api is healthy
✓ inventory is healthy

All services are ready!

$ curl http://localhost:3002/health
{"status": "healthy", "timestamp": "2026-04-18T14:23:00Z"}
```

### Local Development Workflow

```bash
# Day 1: Clone and setup
git clone <repo>
cd ecommerce
./services-check.sh --start

# Implement feature: Add order cancellation
# Edit: services/order/src/routes/orders.js
# Docker detects changes, rebuilds order-service automatically
curl http://localhost:3002/orders/123/cancel -X POST
# Tests run against real inventory-service and auth-service

# Verify saga works:
# Order cancellation triggers event → inventory-service releases stock
# Check inventory stocks returned

# Before commit:
./services-check.sh --status
# All services ✓
npm run test:integration
npm run test:contract
git push
```

---

## Troubleshooting & Best Practices

### Common Issues

**Issue: "Port already in use"**
```bash
# Solution: Kill existing container
docker ps | grep 3002
docker kill <container_id>
./services-check.sh --start
```

**Issue: "Service unavailable" after deploy**
```bash
# Check logs
docker logs order-api
# Check readiness
curl http://localhost:3002/ready
# If dependencies failed, restart them first
./services-check.sh --restart
```

**Issue: "Distributed transaction saga failed"**
```bash
# Check compensation ran
curl http://localhost:3002/orders/123
# Verify inventory was released
curl http://localhost:3003/inventory/SKU-123
# Check event consumption logs
docker logs inventory
```

### Best Practices

1. **Always include timeouts**: Prevent hanging on network failure
2. **Always include circuit breakers**: Prevent cascading failure
3. **Always implement idempotency**: Retries are unavoidable
4. **Always use structured logging**: Debug distributed systems without logs
5. **Always implement health checks**: Required for orchestration (K8s, etc.)
6. **Always version your APIs**: Services evolve independently
7. **Always test contracts**: Catch breaking changes before production
8. **Always include saga compensation**: Distributed transactions can fail partway

### Performance Considerations

- **Network latency**: 1-10ms per service call (vs. 0.1ms in-process)
- **Throughput**: Reduce if chattiness high (combine requests)
- **Consistency**: Eventual consistency acceptable for most features
- **Caching**: Cache service responses (needs invalidation strategy)

---

## Summary

The Microservices Extension transforms your project into a scalable, resilient distributed system with clear ownership boundaries. Use it when:

- ✓ Multiple teams building different features
- ✓ Services scale at different rates
- ✓ Technology heterogeneity required
- ✓ Resilience is critical

Don't use it if:

- ✗ Single small team
- ✗ Simple, tightly-coupled domain
- ✗ Not yet proven business model
- ✗ Single box infrastructure budget

The 5 core files (SERVICE_MAP, INTER_SERVICE, OBSERVABILITY, CONTRACT_TESTING, ORCHESTRATION) provide complete guidance from design through production operation.
