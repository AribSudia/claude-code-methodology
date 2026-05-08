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

# ADR-004: Hook Enforcement Layer (v3.2)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.1 documented a hooks layer in `hooks/HOOKS_PROTOCOL.md`,
but `.claude/hooks/` was empty on disk. CONSTRAINTS.md was honor-system —
the model could violate it and nothing stopped the tool call. Reviewers
running `ls .claude/hooks/` after reading the README would see the gap
immediately, eroding credibility.

**Decision.** Ship real bash hook executables under `.claude/hooks/`.
Specifically: `lib/common.sh` (shared helpers), `pre-tool-use.sh` (path
scoping + secret detection + dangerous-bash blocklist), `pre-commit.sh`
(credential files, secrets, debug stmts, oversize), `session-start.sh`
(CLAUDE.md hash, branch warn, capture start SHA), `stop.sh` (per-session
ledger to `io/ledger/`), `notification.sh` (push transport fan-out).
Wired in `.claude/settings.json`. Installer: `scripts/install-hooks.sh`.

**Consequences.** Advisory rules become enforced rules. Bypasses require
either updating CONTEXT_MAP, running outside Claude Code, or `git commit
--no-verify` (audit-trail-leaving). Smoke tests pass. The whole release
ladder (waves, autonomy, deep-audit gates) depends on this layer.

**Alternatives rejected.** "Document only" — the v3.1 status quo. Loses
credibility every time a reviewer runs `ls`. "External hook framework"
(e.g., husky-style) — unnecessary dependency for what's essentially
six bash files.

---

# ADR-005: Hybrid Memory Architecture

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.1 stored project memory as seven markdown files. This works
fine at session 5 and breaks down past ~50 sessions because grep doesn't
scale on novel paraphrases ("we decided to drop kafka" vs "kafka removal").

**Decision.** Add an *optional* semantic layer (`claude-mem` MCP) that
provides vector retrieval, with the markdown files preserved as the
authoritative audit trail. `scripts/memory-export.sh` exports the
semantic store to `memory/semantic_export.md` nightly (or on Stop). The
`/arib-memory-search` skill queries the MCP first, falls back to grep if
the MCP is unavailable.

**Consequences.** Long-horizon recall improves; markdown stays the source
of truth (regulated-data projects can opt out of the MCP entirely without
losing function). Adds a vendor dependency (claude-mem) but it stays
opt-in via env var.

**Alternatives rejected.** "Replace markdown with vectors" — loses the
human-readable audit trail. "Build our own embedding store" — out of
scope for a methodology repo.

---

# ADR-006: Wave Delivery Overlay

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.1 operated at session granularity. Multi-week delivery
had no exit gate — sessions ended, features landed, but nothing forced
"did we ship what we said we'd ship" review.

**Decision.** Add a wave concept: `waves/<name>/` containing a PLAN.md
(scope, exit criteria, risk register) and REPORT.md (stakeholder-facing,
generated at end). Skills `/arib-wave-start` and `/arib-wave-end` manage
the lifecycle. The pre-tool-use hook blocks `git push|merge` to main
from `wave/*` branches without an audit hash from `/arib-deep-audit`.

**Consequences.** CCM becomes a delivery framework, not just a session
helper. Waves produce stakeholder artifacts. Single-session work and
hotfixes still bypass the overlay (no `wave/*` prefix = no gate).

**Alternatives rejected.** "Quarterly review without git enforcement" —
honor-system; same failure mode v3.2 Item A fixed for hooks. "Force every
branch to be a wave" — too heavy for routine work.

---

# ADR-007: Compliance Honesty Principle

**Status:** Accepted   **Date:** 2026-05-08

**Context.** The expanded Item #7 added ISO 27001, SOC 2, GDPR, OWASP,
and PDPL alignment. Tempting to claim CCM "ensures compliance" — but
ISO 27001 is an ISMS, SOC 2 is an attestation over a 6-12 month
observation period, and GDPR has many operational pieces no script can
enforce. Pretending otherwise re-creates the marketing/disk gap that
v3.2 "Honest" was specifically designed to close.

**Decision.** `compliance/README.md` states the honesty principle
explicitly: CCM cannot certify, attest, or replace a DPO. It produces
*alignment reports* with a level (NONE / PARTIAL / STRONG), and contributes
*evidence artifacts* (audit trails, deps audits, secrets-block logs).
Each framework doc lists code-checkable rules separately from operational
rules. The `/arib-check-compliance` skill never says "compliant."

**Consequences.** CCM is honest with users and auditors. The OWASP layer
ships real hooks (eval/Function/exec blocks, PII-in-logs detection)
because OWASP is genuinely code-checkable. The ISO/SOC2 layers ship as
alignment docs only.

**Alternatives rejected.** "Claim compliance" — false advertising; legal
risk; loses credibility on first audit. "Skip the operational frameworks
entirely" — the user explicitly asked for them.

---

# ADR-008: Design System Token Discipline

**Status:** Accepted   **Date:** 2026-05-08

**Context.** Item #8 of the proposal asked for an enforceable design
system. The proposal's original sketch had a YAML-ish config block in
`architecture/DESIGN_SYSTEM.md` that the hook would parse. Bash-parsing
YAML is finicky; smoke tests showed pattern-extraction failures.

**Decision.** Hardcode the rules in `.claude/hooks/pre-tool-use.sh`
(forbidden patterns: hex/rgb/hsl literals; exempt paths: tokens/theme/
generated/test). `architecture/DESIGN_SYSTEM.md` documents the contract
for humans; the hook is the machine truth. Override by editing the hook
directly.

**Consequences.** Fewer moving parts; deterministic enforcement; clearer
override path. Loses runtime configurability — projects with materially
different design rules must edit the hook (acceptable for a methodology
repo where forking is encouraged).

**Alternatives rejected.** "Re-attempt YAML config block" — fragile per
smoke testing. "Move enforcement to a dedicated linter" — extra
dependency, separate run cycle, worse failure mode (hook is fail-closed
on tool call, linter fails-open until run).

---

# ADR-009: Autonomy Mode Protocol

**Status:** Accepted   **Date:** 2026-05-08

**Context.** Long autonomous Claude Code runs (`--dangerously-skip-
permissions` + `caffeinate`) trade human-in-loop approval for tighter
machine-enforced guardrails. Without explicit guardrails, autonomy is
unsafe; with them, it's productive.

**Decision.** Add `operations/AUTONOMY_MODE.md` (preconditions,
guardrails, post-conditions) and `.claude/hooks/autonomy-guard.sh`
(runtime enforcement). Hook is a fast-path no-op unless `CCM_AUTONOMY=1`
is set; safe to ship in the always-on PreToolUse chain. Guardrails:
wall-clock cap (4h default), calls-since-commit cap (50 default), BLOCK
rate cap (5/10min default), unsanctioned push to main refused.

**Consequences.** Long autonomous runs become safe and observable.
Wave-end self-audit required before main-branch commits land — wave
overlay and autonomy compose cleanly.

**Alternatives rejected.** "Ship autonomy without guardrails" — unsafe.
"Require manual setup before every run" — defeats autonomy purpose.

---

# ADR-010: MCP Placeholder Strategy

**Status:** Accepted   **Date:** 2026-05-08

**Context.** Items #3, #4, #9 reference three MCP servers (claude-mem,
cowork, testsprite). Verifying npm package names mid-implementation
revealed: claude-mem ships unscoped (not `@claude-mem/mcp-server`),
testsprite ships as `@testsprite/testsprite-mcp` (not `@testsprite/mcp`),
and `@anthropic/cowork-mcp` does not exist on npm at all.

**Decision.** Use the *real* names where they exist (claude-mem,
testsprite). For cowork: keep the placeholder name in `.mcp.json` but
mark `_package_status: PLACEHOLDER` in the entry; rely on
`CCM_NOTIFY_WEBHOOK`/`CCM_COWORK_WEBHOOK` for actual notification fan-out.
Mark each MCP entry with a `_package_status` field documenting verification
state.

**Consequences.** Activating an MCP requires the user to verify the
package still exists at install time. Documentation is honest about
what's verified vs. placeholder. Notifications work without the cowork
MCP via plain webhooks.

**Alternatives rejected.** "Drop cowork entirely" — Item #4 is real and
the proposal specifically asks for CoWork integration. "Ship a custom
cowork MCP" — out of scope; we don't own that surface.

---

# ADR-012: CI/PR Governance Model

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.3 shipped one hooks regression workflow. Otherwise the
repo had no PR template, no CODEOWNERS, no issue templates, no
vulnerability disclosure policy, no contributor guide. A repo that
pushes straight to main can't credibly recommend PR discipline to
projects bootstrapped from it. The post-shipment audit also flagged a
real BSD-vs-GNU bash drift risk in `autonomy-guard.sh` that local
macOS testing couldn't catch — Linux CI would.

**Decision.** Adopt GitHub's PR/CI governance best practices, integrated
into CCM methodology:

- PR template (`.github/PULL_REQUEST_TEMPLATE.md`) requiring summary,
  type, ADR/issue links, test plan, token-budget impact, wave audit
  hash, compliance impact.
- Issue templates for bug, feature, security (with private-advisory
  routing for high-severity).
- CODEOWNERS auto-routing review for hooks, architecture records,
  compliance, gate skills, methodology brain, .github itself.
- Three CI workflows beyond hooks regression: JSON validation
  (every committed JSON file + VERSION.json semver shape +
  .mcp.json + settings.json), token-budget (base vs head, comments
  delta, fails at >10K regression), markdown lint (markdownlint-cli2
  + TODO/FIXME detection in shipped docs).
- Dependabot for github-actions and npm, weekly, security-patches
  grouped.
- CONTRIBUTING.md as the binding contract: branch naming, conventional
  commits, test discipline, branch protection settings to apply.
- Repo-root SECURITY.md (separate from architecture/SECURITY.md) with
  vulnerability disclosure policy and SLA per severity.
- CODE_OF_CONDUCT.md (Contributor Covenant 2.1).
- `.claude/rules/ci-pr.md` — path-scoped rules for `.github/**` work.
- `Training/11-CI-PR-MANUAL.md` — user-facing manual matching the
  existing 10-manual structure.

Branch protection settings (require PR, require approvals, require
status checks, linear history, no direct pushes except by maintainer
for emergencies) are documented in CONTRIBUTING.md §6 and applied
once in the GitHub web UI.

**Consequences.** PR governance becomes a first-class methodology
artifact alongside hooks, waves, and compliance. New projects
bootstrapped from CCM inherit the scaffolding by default. CI catches
regressions at PR time instead of post-shipment. The maintainer's
direct-to-main push pattern (used during the v3.2/v3.3 push) is now
a documented exception, not the norm.

**Alternatives rejected.** "Skip CI entirely" — re-creates the
documentation/disk gap v3.2 was specifically designed to close.
"Only hooks workflow, no governance docs" — leaves contributors
guessing about branch naming, commit conventions, review process,
and security disclosure. "Use a third-party governance service like
Renovate or Mergify" — unnecessary dependency for what GitHub
provides natively.

---

# ADR-011: Override of v3.2 "Honest" Counter-Proposal

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.2 "Honest" was an explicit counter-proposal to the
original Enforced proposal. It deferred 8 of 11 items on the grounds of
scope creep and vendor pull-in. The maintainer agreed and v3.2 shipped
with only Items A/B/C (hooks, token discipline, agent architecture).

After v3.2 landed, the maintainer reversed the deferral and asked for
the full 8 items with Item #7 expanded to include ISO 27001, SOC 2,
GDPR, and OWASP enforcement. The work shipped as commits c48d9ee through
709baa7.

**Decision.** Honor the override but preserve all counter-proposal
safeguards: every new MCP stays opt-in via env var; ISO 27001 and SOC 2
docs frame as alignment-only; OWASP enforcement ships as real hooks
(eval/Function/exec blocks); compliance/README.md states the honesty
principle explicitly; CCM never claims certification.

**Consequences.** v3.3 "Operating" ships as the union of the original
Enforced proposal scope and the Honest counter-proposal's safeguards.
The counter-proposal file remains on disk as a record of the original
deferral and its reasoning.

**Alternatives considered.** "Hold to the counter-proposal deferral" —
maintainer's call, not mine. "Ship without the safeguards" — would
re-create the docs/disk gap v3.2 was specifically designed to close.

---

## Quick Reference: All ADRs

| ID | Title | Status | Date |
|---|---|---|---|
| ADR-001 | Project Architecture Pattern (Modular Monolith) | Accepted | 2024-01-15 |
| ADR-002 | Authentication Strategy (JWT + HttpOnly Refresh) | Accepted | 2024-01-20 |
| ADR-003 | Database Selection (PostgreSQL + Redis) | Accepted | 2024-02-01 |
| ADR-004 | Hook Enforcement Layer (v3.2) | Accepted | 2026-05-08 |
| ADR-005 | Hybrid Memory Architecture (claude-mem MCP + markdown) | Accepted | 2026-05-08 |
| ADR-006 | Wave Delivery Overlay | Accepted | 2026-05-08 |
| ADR-007 | Compliance Honesty Principle | Accepted | 2026-05-08 |
| ADR-008 | Design System Token Discipline | Accepted | 2026-05-08 |
| ADR-009 | Autonomy Mode Protocol | Accepted | 2026-05-08 |
| ADR-010 | MCP Placeholder Strategy | Accepted | 2026-05-08 |
| ADR-011 | Override of v3.2 "Honest" Counter-Proposal | Accepted | 2026-05-08 |
| ADR-012 | CI/PR Governance Model | Accepted | 2026-05-08 |

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
