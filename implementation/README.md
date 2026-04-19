# Implementation Layer Templates

Project-agnostic implementation templates for Claude Code methodology system. Replace `[PROJECT]` placeholders with your actual project name.

## Files Overview

### 1. API_ENDPOINTS.md (337 lines)
Complete endpoint inventory template with standardized documentation format.

**Includes:**
- Endpoint template with Method, Path, Auth Level, Description, Request/Response
- 3 fully documented CRUD endpoints (GET list, POST create, GET detail, PATCH update, DELETE)
- Pagination standards (cursor-based and offset-based)
- Standard error response format with error codes
- API versioning strategy (/api/v1)
- Rate limiting tiers (Public, Authenticated, Premium)
- [PROJECT] section for custom endpoints

**Use when:** Documenting API surface, onboarding new developers, generating OpenAPI specs

---

### 2. DOCKER_LOCAL.md (511 lines)
Local development environment setup and troubleshooting guide.

**Includes:**
- Services table (PostgreSQL, Redis, Application, optional services)
- First-time setup steps (Docker start, dependencies, env, migrations, seeding)
- Common commands (start/stop/reset/logs)
- Health check commands for each service
- Comprehensive troubleshooting section (port conflicts, volume issues, connection refused, memory issues)
- Database and Redis operations
- Development workflow shortcuts
- Performance optimization tips

**Use when:** Setting up development environment, onboarding new team members, debugging Docker issues

---

### 3. docker-compose.yml (329 lines)
Production-quality Docker Compose configuration.

**Includes:**
- PostgreSQL with health checks and persistence
- Redis with health checks and persistence
- Application service with dependency ordering
- Optional services (commented): RabbitMQ, Elasticsearch, MinIO, MailHog
- Named volumes and bridge network
- Resource limits and reservations
- Health check configurations
- Environment variable references and comprehensive comments
- .env.local configuration guide

**Use when:** Setting up local/staging/production environments, containerizing services

---

### 4. EVENT_SCHEMA.md (475 lines)
Async event contract definitions and lifecycle management.

**Includes:**
- Event naming convention: domain.entity.verb (auth.user.registered)
- Event envelope format (id, type, timestamp, source, data, metadata)
- Event documentation template with publisher, consumers, payload, side effects
- 3 fully documented example events (user registration, invoice payment, resource update)
- Dead letter queue strategy with schema and processing procedures
- Idempotency requirements and implementation examples
- Event ordering guarantees (none, per-entity, global)
- Schema evolution and versioning strategy
- [PROJECT] section for custom events
- Monitoring and observability guidance

**Use when:** Designing async architectures, documenting event flows, implementing event handlers

---

### 5. MIGRATION_ORDER.md (422 lines)
Database dependency graph and schema migration strategy.

**Includes:**
- Migration naming convention: YYYYMMDDHHMMSS_{kebab-case}
- Layer concept (Layer 0-N based on dependencies)
- Migration structure template with up/down SQL
- Detailed 3-layer example dependency graph (Foundation → Relationships → Refinement)
- Dependency visualization diagram
- Cross-service boundary rules (foreign keys, shared types)
- Rollback strategy with forward-compatible approach
- Atomic migration requirements
- Migration testing procedures
- [PROJECT] section for project-specific migrations
- Performance considerations for large tables

**Use when:** Planning schema changes, managing database versions, documenting dependency order

---

### 6. LOCAL_RUNBOOK.md (586 lines)
Clone to running in under 15 minutes - complete setup guide.

**Includes:**
- Prerequisites checklist (Node, npm, Docker, Git, disk space)
- 7-step setup process (clone, env, npm install, Docker, migrations, seed, run)
- Verification commands (health endpoint, database, Redis, test user login, API test)
- Development workflow shortcuts (hot reload, code changes, creating tests, linting)
- Troubleshooting FAQ with solutions for common issues
- Full reset instructions (clean slate database)
- Getting help resources
- System architecture summary

**Use when:** Onboarding developers, documenting setup process, quick reference for development

---

### 7. GATEWAY_ROUTES.md (544 lines)
API gateway routing map and authentication configuration.

**Includes:**
- Route table template (Path, Service, Port, Auth, Rate Limit)
- Microservices routing examples (Auth, Health, User, Resource, Admin routes)
- WebSocket routing examples
- Authentication levels (Public, Authenticated, Role-Based, Admin-Only)
- CORS configuration for development and production
- Rate limiting tiers (Tier 1/2/3) with specific limits and headers
- Health check routes (Basic, Full System, Detailed Admin)
- WebSocket connection examples with message formats
- Request flow diagram
- [PROJECT] section for custom routes
- Monolith note: "No gateway required" configuration for monolith projects
- Troubleshooting section
- Example gateway.config.yaml

**Use when:** Configuring API gateway, defining service boundaries, documenting authentication, planning routing

---

## Quick Start

1. **Copy all files** to your project's implementation layer directory
2. **Replace [PROJECT] placeholders** with your actual project name
3. **Customize sections** marked with [PROJECT] with your specific endpoints/events/routes
4. **Use as reference** for architecture decisions and onboarding documentation

## File Relationships

```
LOCAL_RUNBOOK.md
├─ References: DOCKER_LOCAL.md, docker-compose.yml
├─ Uses: docker-compose.yml for service startup
└─ Links to: API_ENDPOINTS.md for API testing

DOCKER_LOCAL.md
├─ References: docker-compose.yml
├─ Uses: Commands from LOCAL_RUNBOOK.md
└─ Links to: MIGRATION_ORDER.md for database setup

docker-compose.yml
├─ Used by: DOCKER_LOCAL.md, LOCAL_RUNBOOK.md
└─ Configures: All services mentioned in GATEWAY_ROUTES.md

API_ENDPOINTS.md
├─ Tested with: LOCAL_RUNBOOK.md verification commands
└─ Routed by: GATEWAY_ROUTES.md

EVENT_SCHEMA.md
├─ Independent from other files
└─ Documented: One per event type across all services

MIGRATION_ORDER.md
├─ Executed during: DOCKER_LOCAL.md / LOCAL_RUNBOOK.md setup
└─ Creates: Database schema for API_ENDPOINTS.md

GATEWAY_ROUTES.md
├─ Routes to: Services defined in docker-compose.yml
├─ Authenticates: Using JWT patterns in API_ENDPOINTS.md
└─ Rate limits: Events from EVENT_SCHEMA.md
```

## Customization Tips

### For Monolith Projects
- Use LOCAL_RUNBOOK.md and DOCKER_LOCAL.md as-is
- Ignore "microservices" sections in GATEWAY_ROUTES.md
- Use the "Monolith Note" section in GATEWAY_ROUTES.md
- Combine all API_ENDPOINTS into single file per service tier

### For Microservices
- Use all files as-is, customize [PROJECT] sections
- Each service gets its own copy of API_ENDPOINTS.md
- EVENT_SCHEMA.md is shared across services
- GATEWAY_ROUTES.md maps to service boundaries
- MIGRATION_ORDER.md per service database

### For Serverless
- Skip docker-compose.yml
- Use GATEWAY_ROUTES.md for routing rules
- Event-driven architecture aligns with EVENT_SCHEMA.md
- Adapt DOCKER_LOCAL.md for local testing (SAM, Serverless Framework, etc.)

## Maintenance

- Review API_ENDPOINTS.md when adding endpoints
- Update EVENT_SCHEMA.md when creating new event types
- Modify MIGRATION_ORDER.md when creating schema changes
- Refresh GATEWAY_ROUTES.md when adding services or changing auth rules
- Update DOCKER_LOCAL.md when adding new services or changing setup steps

---

Created: 2024-01-15
Version: 1.0.0
Total Lines: 3,204
Total Templates/Examples: 20+ documented patterns
