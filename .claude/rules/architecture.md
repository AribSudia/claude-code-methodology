---
paths:
  - "architecture/**"
---

# Architecture Layer Rules

The architecture layer (Layer A) defines WHAT to build and WHY.
No code is written until Layer A files exist.

## Required Files

| File              | Purpose                                         |
|-------------------|-------------------------------------------------|
| CONSTRAINTS.md    | Hard rules that must NEVER be violated           |
| TECH_STACK.md     | Approved technologies - nothing else allowed     |
| CONTEXT_MAP.md    | Folder structure + data flows                    |
| ERROR_PATTERNS.md | Known pitfalls + prevention strategies           |
| DECISIONS.md      | Architecture Decision Records (ADRs)             |
| SECURITY.md       | Security specification + threat model            |

## Microservices Extension (only if applicable)

| File              | Purpose                                         |
|-------------------|-------------------------------------------------|
| SERVICE_MAP.md    | Service registry, boundaries, ownership          |
| INTER_SERVICE.md  | Communication patterns, sagas, circuit breakers  |

## Rules

- Before writing code, check CONSTRAINTS.md for relevant rules
- Every architectural decision gets an ADR in DECISIONS.md
- TECH_STACK.md is the whitelist - no unapproved libraries
- ERROR_PATTERNS.md is a living document - add patterns as you find them
- SECURITY.md must be reviewed before any auth/payment/data changes
