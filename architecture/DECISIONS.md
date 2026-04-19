# DECISIONS — Architecture Decision Records (ADRs) for [PROJECT]

This document contains Architecture Decision Records (ADRs) for [PROJECT]. ADRs document important design decisions, their context, alternatives considered, and consequences.

Use this to:
- Understand why we made key architectural choices.
- Avoid re-litigating old decisions.
- Onboard new team members.
- Make consistent decisions going forward.

---

## ADR Template

```markdown
# ADR-NNN: [Decision Title]

**Date:** YYYY-MM-DD  
**Status:** [Proposed | Accepted | Superseded | Deprecated]  
**Owner:** [Team/Person]  

## Context
Describe the problem or need that prompted this decision.
Why do we need to make a choice? What's at stake?

## Decision
What did we decide to do? Be clear and specific.

## Alternatives Considered
1. [Option A]: Pros and cons
2. [Option B]: Pros and cons
3. [Option C]: Pros and cons

## Consequences
**Positive:**
- Consequence 1
- Consequence 2

**Negative:**
- Consequence 1
- Consequence 2

**Neutral:**
- Consequence 1

## Notes
Any additional context, links to related decisions, or follow-up items.

## Review Date
Next review: [DATE + 1 year]
```

---

# ADR-001: Project Architecture Pattern

**Date:** 2024-01-15  
**Status:** Accepted  
**Owner:** [PROJECT] Tech Lead  

## Context
[PROJECT] is a new system that will handle user-facing API requests, background jobs, and real-time updates. We need to decide between:
- Monolithic architecture (single codebase, deployed as one unit)
- Microservices architecture (multiple services, loosely coupled)
- Hybrid approach (monolith with some extracted services)

The team is small (< 10 engineers), and we want to move fast without over-engineering. However, we also need the system to be maintainable long-term and scalable.

## Decision
**Adopt a modular monolith pattern with planned migration path to microservices.**

- Single codebase and deployment pipeline (easier to manage).
- Modules separated by domain boundary (users, products, orders, etc.).
- Each module has its own database schema (allows future migration to separate DB).
- Clear API boundaries between modules (reduces coupling).
- Services can be extracted later if needed (performance/scale issues arise).

## Alternatives Considered

1. **Monolith (no modularity)**
   - Pros: Simplest to start, shared code, simple deployments.
   - Cons: Coupling grows over time, harder to scale individual features, testing becomes slow.
   - Rejected because lack of modularity will slow us down after 6-12 months.

2. **Microservices (separate services from day 1)**
   - Pros: Clear ownership, independent scaling, easier to understand each service.
   - Cons: Operational complexity, inter-service communication overhead, harder to develop locally, more infrastructure needed.
   - Rejected because team is too small for the complexity, and we don't know where scaling will be needed.

3. **Hybrid: Modular monolith with planned service extraction**
   - Pros: Modular structure now, simple operations, path to scale later, easy local development.
   - Cons: Need discipline to maintain module boundaries, some migration work later.
   - Chosen because it balances simplicity and long-term flexibility.

## Consequences

**Positive:**
- Single codebase is easy to develop and test locally.
- Simple deployment pipeline (one Docker image, one release process).
- Code sharing between modules is straightforward.
- We can refactor across modules without worrying about API contracts.
- We can observe where performance bottlenecks are before extracting services.

**Negative:**
- Need discipline to maintain module boundaries (or they'll decay).
- Some operational overhead when a module needs different scaling than others.
- Team needs to be aware of coupling anti-patterns (circular dependencies, tight coupling).

**Neutral:**
- Database: Each module has its own schema, but single database instance (for now).
- Shared infrastructure (Redis, queue) is easier with monolith.

## Notes
**Implementation Details:**
- Use folder structure: `src/modules/users/`, `src/modules/products/`, etc.
- Each module has controllers, services, repositories, models.
- Shared code in `src/shared/`.
- Module-to-module communication via service injection (no HTTP calls).
- Enforce dependency rules: No circular imports, no sibling imports without going through shared.

**Future Migration:**
- If a module needs independent scaling, extract to separate service.
- Start with API gateway pattern (monolith + extracted service behind same API).
- Gradually migrate data and requests to new service.
- Keep feature parity during migration.

**Review Date:** 2025-01-15

---

# ADR-002: Authentication Strategy

**Date:** 2024-01-20  
**Status:** Accepted  
**Owner:** [PROJECT] Tech Lead + Security Lead  

## Context
[PROJECT] serves both web and mobile clients. We need an authentication strategy that:
- Works across web, iOS, Android.
- Supports multiple login methods (email/password, OAuth, MFA).
- Is secure against common attacks (XSS, CSRF, token theft).
- Allows for future integration with enterprise SSO.

We're considering:
- Session-based (cookies) vs. token-based (JWT) vs. hybrid.
- Where to store tokens on client (localStorage, sessionStorage, in-memory, HttpOnly cookie).
- How to refresh tokens safely.

## Decision
**Use JWT tokens with HttpOnly secure cookies for refresh tokens, hybrid approach for maximum security.**

**Details:**
- Access token (JWT, short-lived, 15 minutes) stored in-memory or returned in response.
- Refresh token (opaque, long-lived, 7 days) stored in HttpOnly secure cookie.
- Client sends access token in Authorization header for API requests.
- When access token expires, client calls refresh endpoint with refresh cookie.
- Server issues new access token, refresh token cookie is auto-updated.
- Support multiple login methods via OAuth2 server (Google, GitHub, etc.).
- MFA via TOTP (Google Authenticator) as optional step after password auth.

## Alternatives Considered

1. **Session-based (cookies + sessions)**
   - Pros: Simple, built-in browser security (HttpOnly, Secure, SameSite), no token management.
   - Cons: Doesn't work well for mobile apps, CSRF requires special handling, server-side session store needed.
   - Rejected because we need mobile support without session affinity.

2. **Pure JWT in localStorage**
   - Pros: Stateless, works on all clients, no session server needed.
   - Cons: Vulnerable to XSS (localStorage accessible to JS), tokens can't be revoked easily.
   - Rejected because we want to minimize XSS impact.

3. **Pure JWT in HttpOnly cookie**
   - Pros: HttpOnly prevents XSS from stealing token, secure transport.
   - Cons: CSRF requires special handling, token refresh is complex.
   - Rejected because it doesn't work well with mobile apps (cookies not sent automatically).

4. **Hybrid: JWT access token + refresh token in HttpOnly cookie** ✓
   - Pros: Access token can be revoked quickly, refresh token is protected, works on all clients.
   - Cons: More complex implementation, requires careful token management.
   - Chosen because it balances security with usability.

## Consequences

**Positive:**
- Refresh token theft is harder (HttpOnly cookie can't be stolen via XSS).
- Access token theft is mitigated (short-lived, can be revoked).
- Stateless design (no session server needed).
- Works on web and mobile without changes.
- Easy to add OAuth2 / OIDC providers.
- MFA can be added without architectural changes.

**Negative:**
- More complex implementation than session-based auth.
- Requires client to handle token refresh (need SDK or guidance).
- Need to handle token revocation (logout, password change, security breach).
- Requires careful CORS/CSRF configuration.

**Neutral:**
- Clock skew between client and server can cause JWT validation failures (mitigated with clock tolerance).
- Token size increases with claims (use minimal claims).

## Implementation Notes

**Backend:**
- JWT payload: `{ sub: userId, iat, exp, aud: 'mobile|web' }`
- Refresh token: Random 32-byte string, stored in DB with userId, expires_at.
- Token refresh endpoint: POST `/auth/refresh` → validates refresh cookie, returns new access token + new refresh cookie.
- Logout endpoint: DELETE `/auth/logout` → invalidates refresh token in DB, clears cookie.
- Password change: Invalidate all refresh tokens (logout all sessions).

**Frontend:**
- Store access token in-memory or derived from refresh response.
- Interceptor: Check if access token expired before each request.
- If expired, call refresh endpoint.
- If refresh fails (no valid refresh cookie), redirect to login.
- On logout, clear in-memory token.

**Security:**
- Refresh token: HttpOnly, Secure, SameSite=Strict.
- CORS: Whitelist allowed origins, credentials: true.
- Token validation: Check exp, aud, signature.
- CSRF: Standard CSRF token for form-based actions if needed.

**Review Date:** 2025-01-20

---

# ADR-003: Database Selection and Strategy

**Date:** 2024-02-01  
**Status:** Accepted  
**Owner:** [PROJECT] Tech Lead + Database Admin  

## Context
[PROJECT] needs a primary data store. We have relational data (users, orders, products, relationships) and some semi-structured data (metadata, configuration).

We're considering:
- Relational database (PostgreSQL, MySQL)
- Document database (MongoDB)
- Hybrid (relational + document store)

Requirements:
- ACID transactions (critical for payments, inventory).
- Complex queries (reports, analytics).
- Scalability (read-heavy, but need consistency).
- Operational simplicity.
- Cost.

## Decision
**Primary: PostgreSQL (relational). Secondary: Redis (cache) and S3 (file storage).**

**Details:**
- PostgreSQL 15+ as primary OLTP database.
- JSON/JSONB columns for semi-structured data (metadata, config).
- Read replicas for scaling read-heavy queries.
- Redis for session cache, job queue, real-time features.
- S3 for file uploads (documents, images).
- No document database (MongoDB) as primary store.

## Alternatives Considered

1. **PostgreSQL (relational only)**
   - Pros: ACID transactions, complex queries, mature, reliable, good at relational data.
   - Cons: Not ideal for semi-structured data, scaling writes is harder.
   - Chosen as primary because it fits our data model best.

2. **MongoDB (document)**
   - Pros: Flexible schema, horizontal scaling, good for semi-structured data.
   - Cons: Weak ACID support (until 4.0), complex transactions, harder to enforce data quality, no joins.
   - Rejected because we need strong consistency and transactions for payments/inventory.

3. **PostgreSQL + MongoDB (hybrid)**
   - Pros: Best of both worlds, flexibility for both data types.
   - Cons: Operational complexity, data duplication, harder to keep in sync, more infrastructure.
   - Rejected because JSONB in PostgreSQL handles semi-structured data well enough.

4. **Cloud database (RDS, Cloud SQL)**
   - Pros: Managed service, automatic backups, scaling.
   - Cons: Less control, potentially higher cost, vendor lock-in.
   - Deferred to deployment decision (but compatible with all options).

## Consequences

**Positive:**
- Strong ACID guarantees (prevents data corruption).
- Complex queries and joins work well.
- JSONB for schema flexibility where needed.
- Mature ecosystem (plenty of ORMs, tools).
- Easy to scale reads (read replicas).
- Full-text search built-in.
- PostGIS for geographic queries (if needed).

**Negative:**
- Horizontal write scaling is harder (sharding needed if we outgrow single instance).
- Schema migrations are more rigid than document databases.
- Storage overhead for relational data (normalization penalty).

**Neutral:**
- Backup and recovery complexity (standard for relational databases).
- Operational expertise needed (but team has PostgreSQL experience).

## Implementation Notes

**Schema Strategy:**
- Normalized design for relational data (users, orders, products).
- JSONB columns for flexible metadata (user preferences, order metadata, feature flags).
- Soft deletes for audit trail (add deleted_at column).
- Audit triggers for critical tables.

**Scaling:**
- Primary instance for writes.
- Read replicas for read-heavy queries (reporting, analytics).
- Connection pooling (PgBouncer, pgpool) to manage connections.
- Caching (Redis) for frequently-accessed data.

**Backup Strategy:**
- Daily full backup to S3.
- WAL (Write-Ahead Logging) archival to S3 for point-in-time recovery.
- Test restore quarterly.

**Migration Strategy:**
- If write scaling becomes bottleneck, consider sharding by tenant_id or user_id.
- Or migrate to cloud-managed PostgreSQL (AWS RDS, Google Cloud SQL) for auto-scaling.
- Or extract hot data to separate specialized database (time-series data to TimescaleDB or InfluxDB).

**Review Date:** 2025-02-01

---

## Creating New ADRs

**When to create an ADR:**
- Making a significant architectural decision (tech stack, design pattern).
- Deciding between multiple options with long-term consequences.
- Decisions that affect the whole team or multiple teams.
- Decisions that are expensive to reverse.

**When NOT to create an ADR:**
- Minor implementation details (variable naming, code organization).
- Temporary workarounds (use comments in code instead).
- Decisions that are easily reversible.

**How to create an ADR:**
1. Copy the template above.
2. Fill in Title, Date, Owner.
3. Write Context (problem, constraints, options).
4. Document Decision (what, why, how).
5. List Alternatives Considered (with pros/cons).
6. Note Consequences (positive, negative, neutral).
7. Add Implementation Notes if needed.
8. Set Review Date (usually 1 year, or sooner if status changes).
9. Submit as PR for team review.
10. Update Status to "Accepted" once approved.

**ADR Status Values:**
- **Proposed:** Submitted for discussion, not yet decided.
- **Accepted:** Decision has been made and approved by team.
- **Superseded:** This decision was reversed by a newer ADR.
- **Deprecated:** No longer applicable.

---

## Quick Reference: All ADRs

| ID | Title | Status | Date |
|---|---|---|---|
| ADR-001 | Project Architecture Pattern (Modular Monolith) | Accepted | 2024-01-15 |
| ADR-002 | Authentication Strategy (JWT + HttpOnly Refresh) | Accepted | 2024-01-20 |
| ADR-003 | Database Selection (PostgreSQL + Redis) | Accepted | 2024-02-01 |

---

## Review and Updates

**How to review ADRs:**
- Quarterly review: Are these decisions still valid?
- If assumptions change, update ADR or create new one.
- If a decision is reversed, update Status to "Superseded" and link new ADR.

**Review Schedule:**
Last updated: [DATE]  
Next review: [DATE + 3 months]  
Owner: [PROJECT] Tech Lead
