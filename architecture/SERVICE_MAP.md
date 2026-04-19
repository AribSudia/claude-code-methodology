# Service Map — Microservices Architecture

> **When to use this file:** Only when the project uses microservices or modular
> monolith with service extraction. For monolith projects, skip this file entirely.
>
> **Filled by:** Bootstrap (question 13 = "microservices") or Reverse Bootstrap
> (discovery phase detects multiple services).

---

## Architecture Pattern

| Field                    | Value                                       |
|--------------------------|---------------------------------------------|
| Pattern                  | [Microservices / Modular Monolith / Hybrid] |
| Total Services           | [NUMBER]                                    |
| Communication Style      | [Sync-first / Async-first / Hybrid]         |
| Service Discovery        | [DNS / Consul / Kubernetes / Eureka / None] |
| API Gateway              | [Kong / Nginx / Traefik / AWS ALB / Custom] |
| Message Broker           | [RabbitMQ / Kafka / Redis Streams / SQS]    |
| Container Orchestrator   | [Kubernetes / Docker Swarm / ECS / None]    |
| Monorepo or Multi-repo   | [Monorepo / Multi-repo / Hybrid]            |

---

## Service Registry

Each service is documented with its boundary, ownership, data, and contracts.

### Template

```markdown
### [SERVICE-NAME]

| Field            | Value                                         |
|------------------|-----------------------------------------------|
| Name             | [service-name]                                |
| Owner            | [Team or person responsible]                  |
| Port             | [Internal port, e.g., 3001]                   |
| Language/Stack   | [e.g., Node.js + Express, .NET 9, Python]     |
| Database         | [Own DB? Shared? Schema name]                 |
| Status           | [Active / In Development / Deprecated]        |

**Responsibility:** [One sentence — what this service OWNS]

**Owns Data:**
- [Entity 1] (table: [table_name])
- [Entity 2] (table: [table_name])

**Exposes APIs:**
- `POST /api/v1/[resource]` — [description]
- `GET  /api/v1/[resource]/:id` — [description]

**Consumes From:**
- [other-service] via [REST / gRPC / Event]

**Publishes Events:**
- `domain.entity.created` → [who consumes it]
- `domain.entity.updated` → [who consumes it]

**Subscribes To Events:**
- `other-domain.entity.event` from [source-service]
```

---

## Service Inventory

> Replace the examples below with your actual services during Bootstrap.

### 1. auth-service

| Field            | Value                              |
|------------------|------------------------------------|
| Name             | auth-service                       |
| Owner            | [PROJECT] Core Team                |
| Port             | 3001                               |
| Language/Stack   | [PROJECT_STACK]                    |
| Database         | auth_db (own schema)               |
| Status           | Active                             |

**Responsibility:** Authentication, authorization, user identity, sessions, tokens.

**Owns Data:**
- Users (table: users)
- Roles (table: roles)
- Permissions (table: permissions)
- Sessions (table: sessions)
- Refresh Tokens (table: refresh_tokens)

**Exposes APIs:**
- `POST /auth/register` — Create new user account
- `POST /auth/login` — Authenticate and issue tokens
- `POST /auth/refresh` — Refresh access token
- `POST /auth/logout` — Invalidate session
- `GET  /auth/me` — Current user profile
- `POST /auth/forgot-password` — Initiate password reset
- `POST /auth/reset-password` — Complete password reset

**Publishes Events:**
- `auth.user.registered` → notification-service, analytics-service
- `auth.user.logged_in` → analytics-service
- `auth.user.password_reset` → notification-service

**Subscribes To Events:**
- None (auth is a source, not a consumer)

---

### 2. [core-service]

| Field            | Value                              |
|------------------|------------------------------------|
| Name             | [core-service]                     |
| Owner            | [PROJECT] Core Team                |
| Port             | 3002                               |
| Language/Stack   | [PROJECT_STACK]                    |
| Database         | core_db (own schema)               |
| Status           | Active                             |

**Responsibility:** [PRIMARY BUSINESS DOMAIN — e.g., order management, vehicle listings, content management]

**Owns Data:**
- [Entity1] (table: [table_name])
- [Entity2] (table: [table_name])
- [Entity3] (table: [table_name])

**Exposes APIs:**
- `GET  /api/v1/[resources]` — List with pagination + filters
- `POST /api/v1/[resources]` — Create new [resource]
- `GET  /api/v1/[resources]/:id` — Get by ID
- `PUT  /api/v1/[resources]/:id` — Update [resource]
- `DELETE /api/v1/[resources]/:id` — Soft delete

**Publishes Events:**
- `[domain].[entity].created` → [consumers]
- `[domain].[entity].updated` → [consumers]
- `[domain].[entity].deleted` → [consumers]

**Subscribes To Events:**
- `auth.user.registered` — create default [resource] for new user

---

### 3. notification-service

| Field            | Value                              |
|------------------|------------------------------------|
| Name             | notification-service               |
| Owner            | [PROJECT] Core Team                |
| Port             | 3003                               |
| Language/Stack   | [PROJECT_STACK]                    |
| Database         | notifications_db (own schema)      |
| Status           | Active                             |

**Responsibility:** All outbound communication — email, SMS, push notifications, in-app.

**Owns Data:**
- Notification Templates (table: templates)
- Notification Log (table: notification_log)
- User Preferences (table: notification_preferences)

**Exposes APIs:**
- `POST /notifications/send` — Internal only: send notification
- `GET  /notifications/history` — User notification history
- `PUT  /notifications/preferences` — Update user preferences

**Publishes Events:**
- `notification.email.sent`
- `notification.email.failed`
- `notification.sms.sent`

**Subscribes To Events:**
- `auth.user.registered` → send welcome email
- `auth.user.password_reset` → send reset email
- `[domain].[entity].created` → send confirmation
- `payment.invoice.paid` → send receipt

---

### 4. [additional-service] (copy template for each service)

_(Use the template above for each additional service in your system)_

---

## Service Dependency Matrix

Shows which services depend on which. Read as: **Row depends on Column**.

```
                  auth  core  notify  payment  analytics
auth-service       —     ✗      ✗       ✗        ✗
core-service       ✓     —      ✗       ✓        ✗
notification       ✗     ✗      —       ✗        ✗
payment-service    ✓     ✓      ✗       —        ✗
analytics          ✓     ✓      ✗       ✓        —
```

**Legend:**
- `✓` = Sync dependency (REST/gRPC call — service CANNOT function without it)
- `~` = Async dependency (event-based — service degrades gracefully without it)
- `✗` = No dependency
- `—` = Self

**Rules:**
- Minimize `✓` (sync dependencies) — they create coupling and cascading failures
- Prefer `~` (async) where possible — loose coupling, better resilience
- **NEVER create circular sync dependencies** (A→B→A is forbidden)
- If you see a cycle, extract a shared service or use events

---

## Data Ownership Rules

Each piece of data has exactly ONE owner service. Other services may cache or
reference it, but they do NOT write to it directly.

| Data Domain        | Owner Service    | Other Services May...              |
|--------------------|------------------|------------------------------------|
| Users & Auth       | auth-service     | Read user ID via token claims      |
| [Core Entities]    | core-service     | Subscribe to change events         |
| Notifications      | notification-svc | Request send via internal API      |
| Payments           | payment-service  | Read payment status via API        |
| Analytics/Metrics  | analytics-svc    | Publish events for collection      |

**Golden Rule:** If service A needs data owned by service B:
1. **Best:** Subscribe to service B's events (async, no coupling)
2. **OK:** Call service B's API (sync, adds dependency)
3. **NEVER:** Read service B's database directly (tight coupling, breaks encapsulation)

---

## Service Communication Patterns

| Pattern            | When to Use                                    | Example                           |
|--------------------|------------------------------------------------|-----------------------------------|
| **REST API**       | Simple request/response, CRUD operations       | GET /users/:id                    |
| **gRPC**           | High-performance, streaming, internal services  | User lookup from payment service  |
| **Event (async)**  | Fire-and-forget, one-to-many notifications     | user.registered → many consumers  |
| **Command (async)**| One-to-one, guaranteed delivery needed          | SendEmail command → notification  |
| **Saga**           | Multi-service transaction that must be atomic   | Order → Payment → Inventory       |

See `architecture/INTER_SERVICE.md` for detailed patterns.

---

## Per-Service CLAUDE.md Pattern

For large microservices projects, each service can have its own CLAUDE.md
that inherits from the root:

```
project-root/
├── CLAUDE.md                          ← Root brain (methodology + shared rules)
├── services/
│   ├── auth-service/
│   │   ├── CLAUDE.md                  ← Service-specific context
│   │   ├── src/
│   │   ├── tests/
│   │   └── Dockerfile
│   ├── core-service/
│   │   ├── CLAUDE.md                  ← Service-specific context
│   │   ├── src/
│   │   ├── tests/
│   │   └── Dockerfile
│   └── notification-service/
│       ├── CLAUDE.md                  ← Service-specific context
│       └── ...
```

### Service-Level CLAUDE.md Template

```markdown
# CLAUDE.md — [service-name]

> This file extends the root CLAUDE.md. Read root first, then this.

## Service Identity
- **Name:** [service-name]
- **Port:** [port]
- **Responsibility:** [one sentence]
- **Database:** [db_name] (own schema)

## Service-Specific Constraints
- [Rule 1 specific to this service]
- [Rule 2 specific to this service]

## Key Files
- `src/controllers/` — HTTP handlers
- `src/services/` — Business logic
- `src/repositories/` — Data access
- `src/events/` — Event publishers and subscribers

## API Contract
See root `architecture/SERVICE_MAP.md` for this service's full API.

## Events Owned
- `[domain].[entity].created`
- `[domain].[entity].updated`
```

---

## Monorepo vs Multi-repo Strategy

### Monorepo (Recommended for < 5 services)

```
project/
├── CLAUDE.md                    ← Shared methodology
├── services/
│   ├── auth/
│   ├── core/
│   └── notifications/
├── packages/                    ← Shared libraries
│   ├── common/                  ← Shared types, utils
│   └── events/                  ← Event definitions
├── infrastructure/              ← Terraform, K8s manifests
└── docker-compose.yml           ← Local dev orchestration
```

**Pros:** Atomic commits across services, shared code easy, single CI pipeline
**Cons:** Larger repo, CI can be slower, ownership boundaries less clear

### Multi-repo (Recommended for > 5 services or multiple teams)

```
github.com/org/auth-service/
github.com/org/core-service/
github.com/org/notification-service/
github.com/org/shared-contracts/     ← Event schemas, API types
github.com/org/infrastructure/       ← K8s manifests, Terraform
```

**Pros:** Clear ownership, independent CI/CD, smaller repos
**Cons:** Cross-service changes harder, shared code via packages, version coordination

---

## Health Check Standard

Every service MUST expose a health endpoint:

```
GET /health

Response 200:
{
  "status": "healthy",
  "service": "auth-service",
  "version": "1.2.3",
  "uptime": "4h 23m",
  "dependencies": {
    "database": "healthy",
    "redis": "healthy",
    "message-broker": "healthy"
  }
}

Response 503:
{
  "status": "unhealthy",
  "service": "auth-service",
  "dependencies": {
    "database": "unhealthy",
    "redis": "healthy"
  }
}
```

---

## Adding a New Service Checklist

When adding a new microservice to the system:

1. [ ] Define service boundary and responsibility (one sentence)
2. [ ] Identify data ownership (which tables/entities does it own?)
3. [ ] Define API contract (endpoints, request/response schemas)
4. [ ] Define events published and subscribed
5. [ ] Update SERVICE_MAP.md with new service entry
6. [ ] Update dependency matrix
7. [ ] Create service-level CLAUDE.md
8. [ ] Create Dockerfile
9. [ ] Add to docker-compose.yml for local dev
10. [ ] Add to GATEWAY_ROUTES.md
11. [ ] Add health check endpoint
12. [ ] Add contract tests (see CONTRACT_TESTING.md)
13. [ ] Add to CI/CD pipeline
14. [ ] Add to monitoring/alerting (see OBSERVABILITY.md)
15. [ ] Update ORCHESTRATION.md if using Kubernetes
