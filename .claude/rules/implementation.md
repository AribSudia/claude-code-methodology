---
paths:
  - "implementation/**"
---

# Implementation Layer Rules

The implementation layer (Layer B) defines HOW to start coding.
Layer B must exist before any code is written.

## Required Files

| File                | Purpose                                      |
|---------------------|----------------------------------------------|
| API_ENDPOINTS.md    | Complete route inventory with real paths      |
| docker-compose.yml  | Container orchestration for local dev         |
| DOCKER_LOCAL.md     | Ports, credentials, setup steps               |
| EVENT_SCHEMA.md     | Async event contracts (or "sync only" note)   |
| MIGRATION_ORDER.md  | Database table dependency graph               |
| LOCAL_RUNBOOK.md    | Clone-to-running steps                        |
| GATEWAY_ROUTES.md   | API gateway config (or "monolith" note)       |

## Microservices Extension (only if applicable)

| File                | Purpose                                      |
|---------------------|----------------------------------------------|
| CONTRACT_TESTING.md | Inter-service contract verification           |

## Rules

- API_ENDPOINTS.md is the source of truth for all routes
- docker-compose.yml must match TECH_STACK.md services
- MIGRATION_ORDER.md defines the safe order for DB migrations
- LOCAL_RUNBOOK.md must work for a new developer on day one
- EVENT_SCHEMA.md defines the contract - events are the API between services
