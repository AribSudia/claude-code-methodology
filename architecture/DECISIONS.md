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

# ADR-020: Skill `name:` Conformance + Autonomous Protocol Execution (v3.8.1)

**Status:** Accepted   **Date:** 2026-06-03

**Context.** (1) The 26-skill audit found **0/26 skills had a `name:`
field** — the skills-analog of the v3.7 agent bug; conformance gap risking
silent non-discovery. (2) The user required the bootstrap protocols to run
**systematically with no needless intervention**, but REVERSE_BOOTSTRAP
still had mid-flight "wait for confirmation" gates contradicting ADR-014.

**Decision.**
- Add `name: arib-<dir>` to all 26 skills. Extend `validate-coherence.sh`
  with a HARD skill-lint (name==dir + description) — CI-enforced — plus an
  ADVISORY hygiene check surfacing duplicate section headings.
- Add **Rule 5 (Autonomous Execution)** to `PROTOCOL_PRINCIPLES.md`: an
  invoked protocol runs end-to-end without permission-gating; the
  greenfield questionnaire is input (asked once, only when a new project
  has no facts), not intervention; genuine blockers remain the only pauses.
- Soften REVERSE_BOOTSTRAP's two approval gates to "report inline, proceed."
- Canonicalize the 4 invocation prompts in `bootstrap/RUN.md`.

**Consequences.** Skills conformant + kept so by CI. Protocols are
systematic: "execute the full X protocol" runs to completion, not a
stop-and-ask dialogue — while data-safety gates are preserved.

**Deferred (tracked by the new advisory check):** 6 skills have duplicate
section headings; a few have broken step numbering — cosmetic, surfaced by
`validate-coherence.sh` §3b, to be swept in v3.8.2.

---

# ADR-019: Lean Core — Always-On Context Budget (v3.8.0)

**Status:** Accepted   **Date:** 2026-06-03

**Context.** The single defect keeping CCM at C+ (per two external reviews
and the v3.7 self-audit) was the always-on session-start token cost:
**~45.9K tokens** — ~23% of a 200K window consumed before the user types.
`token-audit.sh` measured it; the `<8K` target was missed ~5.7x. The
bloat was 13 files in `settings.json` `context.include` (and the
session-start protocol bulk-reading them), dominated by reference docs:
DECISIONS.md (11.7K), SECURITY.md (6.1K), ERROR_PATTERNS.md (5.1K),
CONTEXT_MAP.md (3.5K), the three implementation/ schemas (9K), WORKFLOW.md
(1.7K), TECH_STACK.md (1.4K).

**Decision.** Adopt a **Lean Core**: always-on context is the minimum
Claude must see *before acting*. Everything else is read **on demand** by
the skill/agent/hook that needs it.

Always-on (4 files, ~7.3K):
- `CLAUDE.md` — master brain (governance).
- `architecture/CONSTRAINTS.md` — hard rules (must precede any action).
- `memory/project_status.md` — current state (rewritten lean; history → CHANGELOG).
- `memory/session_notes.md` — last handoff.

On-demand (read when the task touches them; mapped in CLAUDE.md §6):
- TECH_STACK (new feature/lib), CONTEXT_MAP (placement; the hook already
  reads its allowed_write_paths block directly), ERROR_PATTERNS (debug),
  DECISIONS (rationale), SECURITY (auth/data), API_ENDPOINTS/EVENT_SCHEMA/
  MIGRATION_ORDER (those subsystems), WORKFLOW (process questions).

Enforced in `settings.json` `context.include` (4 entries) AND in the
session-start protocol/skill (read lean core only; lazy-load the rest).

**Result (measured):** always-on **45,855 → 7,315 tokens (84% cut)** —
UNDER the 8K target for the first time. `token-audit.sh` confirms.

**Why CONSTRAINTS stays always-on:** moving hard rules to lazy-load would
let Claude act before seeing them — the one thing Lean Core must not do.
Same for CLAUDE.md. Reference material (the "why" and the schemas) can be
pulled when relevant; rules and current state cannot.

**Consequences.** ~38K tokens of headroom returned to every session;
latency and cost drop; the C+→A+ token gate is cleared. Trade-off: a
session that needs a reference doc must read it (one extra tool call) —
acceptable, and the on-demand map in CLAUDE.md §6 makes it obvious which
file to pull. KPI #3 (always-on token cost) now passes.

**Alternatives rejected.**
- "Move the target to 45K" — dishonest goalpost-moving (forbidden by
  ADR-016). Cut the cost instead.
- "Lazy-load CONSTRAINTS too, to hit <5K" — unsafe; Claude could act
  without seeing hard rules.
- "@-import the reference docs in CLAUDE.md" — that just re-inlines them
  into always-on; defeats the purpose.

---

# ADR-018: Close the Deferred Review Findings (v3.7.1)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** v3.7.0 fixed the three SEVERE findings from the 23-agent
review (exit-2, agent frontmatter, coherence validator). Several P2/P3
findings were explicitly deferred. This patch closes them.

**Decision.** Ship the deferred fixes:
1. **memory-export.sh honesty.** It wrote failure-sentinel strings
   ("claude-mem CLI failed…") straight into the git-committed audit
   trail and referenced a `semantic_export.md` that did not exist. Now:
   failure reasons go to STDERR only (never the ledger); the export is
   appended ONLY on a real, non-empty dump (last-known-good preserved
   on failure, as the docs always promised); `semantic_export.md` is
   seeded with an honest "no live export has run yet" header so the
   reference is never dangling. Fixed the "seven files" miscount
   (six data files) in MEMORY_PROTOCOL.md, VERSION.json, CLAUDE.md.
2. **Real drift classifier.** `UPGRADE_PROTOCOL` Phase 1.5 depended on
   `reference/template-hashes.json`, which did not exist — so
   classification degraded to a heuristic that could overwrite user
   edits (the exact data loss the protocol claims to prevent). Added
   `scripts/gen-template-hashes.sh` (generates a sha256 manifest of 151
   shipped framework files; excludes project-state), the committed
   `reference/template-hashes.json`, and `scripts/drift-detect.sh`
   (classifies a target tree IDENTICAL/DIFFERS/MISSING and NEVER
   auto-overwrites — DIFFERS is reported NEEDS-REVIEW because stale-
   template vs local-edit cannot be distinguished without history).
   Phase 1.5 now invokes the real script.
3. **Hook hardening.** Whitespace-normalize bash commands before
   matching (catches `rm -rf  /` double-space, tabs); added `git push
   -f`/`--force-with-lease` short forms, `git clean -fd`, `DROP TABLE`,
   `rm -fr`; added Stripe/GitLab/GitHub-fine-grained/npm/JWT secret
   patterns. New fixtures + regression tests.
4. **Ledger honesty.** `stop.sh` now records `transport` and
   `notifications_sent` (the fields IO_PROTOCOL promised but the ledger
   omitted) — populated only with what is actually configured/sent.
5. **PR template** no longer hard-codes "31/31 pass" (the suite prints
   its own count); adds the coherence check to the checklist.
6. **Manifest freshness** is CI-enforced: `validate-coherence.sh`
   fails if `template-hashes.json` is missing or its version != VERSION.
7. **Training-doc reconciliation (partial):** corrected unambiguous
   stale counts in SYSTEM.md and Training/01 (13→15 agents, 21→26
   skills, 8→15, 7→6 memory files) and the 4-vs-5-layer framing in
   Training/01 to match ADR-017.

**Consequences.** The audit trail can no longer be polluted by export
failures; the upgrade path no longer risks clobbering user edits; the
enforcement backstop catches more real-world dangerous forms; the
ledger keeps its promises. None of these overclaim — the drift
classifier is explicitly honest that it cannot auto-distinguish
stale-template from local-edit, so it defers to the human.

**Known remaining (honest):** SYSTEM.md and Training/01 still contain
illustrative prose/diagrams that may reference older specifics; the
GDPR consent/deletion checks remain advisory (documented in gdpr.md,
not yet a hook); the <8K token target remains ~5x off with a ratchet
plan in ADR-016. These are tracked, not hidden.

---

# ADR-017: Canonical "4-Layer" Architecture Framing (v3.7)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** A 23-agent review found CCM described its own architecture
inconsistently: CLAUDE.md said both "5-Layer Architecture" (identity
table) and "The 4-Layer Architecture" (§1 heading); SYSTEM.md said both
"4-Layer Architecture" and "The 5-Layer Stack". This is a flat
DOCS-MATCH-DISK violation on the system's most foundational concept.

**Decision.** The canonical framing is **4 layers**: L1 CLAUDE.md +
rules, L2 Skills, L3 Hooks, L4 Agents. The **I/O Channel** and
**Persistent Memory** are cross-cutting subsystems, not numbered
layers. (Historically v1.0 called it "5-Layer" by counting I/O as a
layer; that framing is retired.) All current-claim docs use "4-Layer
Architecture + I/O Channel + Memory". The `validate-coherence.sh`
guard forbids the "5-Layer Stack" / "5-Layer Architecture + Persistent
Memory" tokens in CLAUDE.md and SYSTEM.md so the framing can't drift
back. Version-history rows (e.g. "v1.0 — 5-Layer Architecture") are
historical and exempt.

**Consequences.** One consistent mental model. The §1 diagram in
CLAUDE.md (L1–L4 + I/O band) is authoritative.

**Alternatives rejected.** "Adopt 5-Layer (count I/O as L5)" — the §1
diagram and README already commit to 4 numbered layers with I/O as a
cross-cutting band; renumbering would churn more docs than it fixes.

---

# ADR-016: Self-Policing — Make CCM Enforce Its Own Rules (v3.7)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** A 23-agent review of CCM v3.6.0 graded the system C+ and
found that, despite best-in-class *design* and *honesty*, several
load-bearing mechanisms were advisory in practice rather than enforced
— a direct violation of CCM's own "ENFORCED not advisory" and
"DOCS-MATCH-DISK" principles. Three defects were severe:

1. **`block()` used `exit 1`.** Claude Code treats PreToolUse exit 1 as
   a *non-blocking* error; only **exit 2** blocks. So every write-time
   gate (secrets, dangerous-bash, OWASP-A03, design-token, wave-merge)
   was advisory — it logged and warned but let the tool call proceed.
   The hooks manual itself specified exit 2; the code never matched it.
   The test suite asserted exit 1, codifying the bug as green.
2. **All 15 agent files lacked YAML frontmatter.** Claude Code registers
   subagents from `.claude/agents/*.md` frontmatter (`name`,
   `description`). Without it, every `Task(<agent>)` dispatch failed to
   resolve — the agent fleet was prose, not functioning agents.
3. **Documentation coherence broke silently** — stale counts (13 agents
   / 16 skills vs 15 / 26), VERSION.json `rules:8` while disk had 9, a
   4-vs-5-layer contradiction, and a stale ~39.6K token figure (real
   always-on ~43.4K).

The unifying root cause: **no script validated the invariants the
methodology preaches.** Drift survived because nothing checked it.

**Decision.** Make CCM self-policing:
- Fix `block()` → `exit 2` (and `pre-commit.sh` final exit → 2); flip
  the test suite's blocking assertions to expect 2. Enforcement is now
  real.
- Add YAML frontmatter (`name` == filename, `description`, scoped
  `tools` derived from the AGENT_ARCHITECTURE Writes column) to all 15
  agents. Read-only agents get Read/Grep/Glob(/Bash); writers add
  Edit/Write.
- Ship `scripts/validate-coherence.sh` + `.github/workflows/coherence.yml`
  asserting: disk counts == VERSION.json; agent frontmatter valid with
  name==filename; skill frontmatter present; version string present in
  CLAUDE.md/SYSTEM.md/README; no known stale tokens; `Task(<agent>)`
  references resolve.
- Make the token audit honest: separate always-on context from
  path-scoped rules (which load on demand, not at session start);
  correct the headline to the real ~43.4K; keep the <8K target with an
  honest "over by ~5x" and a ratchet-down plan (move true reference
  docs — DECISIONS.md, SECURITY.md, ERROR_PATTERNS.md — to lazy loading
  later; keep CLAUDE.md and CONSTRAINTS.md always-on so hard rules are
  never invisible).
- Wire or honestly downgrade three "documented but unwired" claims:
  security-auditor now explicitly reads owasp.md (wired); IO_PROTOCOL no
  longer claims hooks "watch signals / pre-empt" (downgraded to the
  truth — hooks fire on events, not a filesystem watch); the wave-merge
  gate now also catches `gh pr merge` and the docs note web-UI merges
  are governed by branch protection, not the local hook.
- Add `permissions:` + `concurrency:` to all GitHub workflows (they
  would have failed ci-pr-engineer's own checklist).

**Consequences.** A large fraction of prior findings flip from
honor-system to enforced in a handful of small commits. CI now catches
count drift, missing frontmatter, version skew, and dangling references
automatically. Crucially, none of these fixes make CCM overclaim —
several trade an aspirational claim (the 8K target, "hooks watch
signals", exit-1 "blocking") for an honest one, which is exactly what
CCM's honesty principle demands.

**Alternatives rejected.**
- "Leave exit 1; document hooks as advisory" — abandons the flagship
  ENFORCED principle when a one-character fix delivers it.
- "Skip the validator; fix the drift once by hand" — the root cause is
  the absence of a check; hand-fixing guarantees re-drift.
- "Hide the token gap by changing the target to 45K" — dishonest;
  better to keep the <8K target and state the gap plainly with a plan.

---

# ADR-015: Wave Auto-Advance Execution (v3.6)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** The wave overlay (ADR-006) gave CCM a multi-session
delivery unit with a plan and an end gate. But execution between
`/arib-wave-start` and `/arib-wave-end` was unstructured — in practice
CCM would complete one step and then ask the user "should I continue to
the next step?", repeating the question after every step. For a wave
with many steps this is exactly the Rule 2 anti-pattern that ADR-014
forbade for bootstrap protocols (numbered continue/stop prompts when
the right action is determinable). The user reported it directly:
"in this wave more than one step, let CCM not ask me to start next
unless [there is an] issue."

**Decision.** Add a dedicated execution engine skill, `/arib-wave-run`,
that reads the wave's PLAN.md Steps section and **auto-advances** from
step to step without asking for approval. It pauses only on six genuine
conditions: step failure (per the step's `on_failure`), an explicit
`checkpoint: true` step, genuine ambiguity, a blocker, an autonomy-guard
trip, or a user interrupt.

The PLAN.md template gains a structured Steps contract: each step has
`goal`, `done_when` (a verifiable completion criterion), `checkpoint`
(default false), and `on_failure` (halt | retry-once | skip-and-flag).
`/arib-wave-start` now generates this structure and offers to hand off
to `/arib-wave-run`.

This is ADR-014's decisive discipline extended from protocols into wave
execution. The principle is uniform across CCM now: don't ask when the
answer is determinable; pause only for genuinely-human decisions.

**Consequences.**
- A multi-step wave runs end-to-end with one command, reporting per-step
  progress, pausing only when it must.
- One commit per step keeps the autonomy guard's calls-since-commit
  counter healthy and the wave history granular.
- `checkpoint: true` is the explicit escape hatch for irreversible /
  high-stakes steps (prod deploy, data migration, external send) —
  those still get a human gate.
- `/arib-wave-end` remains an explicit gate (it's the finish line and
  the merge-to-main control, not a between-steps prompt). Auto-advance
  flows *within* the build, not *through* the close.
- An unverifiable step (`done_when` vague, no way to confirm) is treated
  as an ambiguity and pauses — it is never falsely marked PASS. Honesty
  principle preserved.

**Alternatives rejected.**
- "Fold execution into `/arib-wave-start`" — conflates planning with
  doing; the lifecycle is cleaner as start → run → end (matches the
  three-verb shape the wave skills already use).
- "Auto-run `/arib-wave-end` too when steps finish" — rejected; closing
  the wave gates the merge to main and runs the 21-section audit. That
  is a deliberate end gate, not a step transition. Keep it explicit.
- "No checkpoint concept; auto-advance everything" — unsafe for
  irreversible actions. The `checkpoint: true` flag is the minimal,
  honest exception.
- "Ask the user to set a global auto/manual toggle" — that's itself a
  menu; the per-step `checkpoint` flag is more precise and lives in the
  plan where the decision belongs.

---

# ADR-014: Decisive Bootstrap Protocols (v3.5.1)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** A user reported that running `UPGRADE_PROTOCOL.md` on a
project with matching `VERSION.json` (3.1.0 == 3.1.0) hit the Phase 0
STOP rule:

> "If versions are the same, STOP and tell the user 'Already up to date.'"

The protocol then offered three opt-in alternatives:

> "If you want me to take action anyway, your options are:
> 1. Force-reapply Phase 3 (UPDATE)...
> 2. Diff drift check...
> 3. Drop a newer methodology release...
> Tell me which (if any) and I'll proceed."

This is wrong on two axes:
1. **Matching versions don't imply matching files.** Project extensions,
   prior partial merges, and local edits all produce drift even at the
   current version. Stopping forfeits the audit value.
2. **Numbered option menus delegate the protocol's own job.** The
   correct action is determinable; presenting 3 choices to the user
   is delegation, not collaboration.

The same anti-pattern risk applies (to varying degrees) across the
4 sibling protocols (BOOTSTRAP, REVERSE_BOOTSTRAP, MIGRATION_GUIDE,
REENGINEERING_GUIDE).

**Decision.** Codify decisive-protocol discipline in
`bootstrap/PROTOCOL_PRINCIPLES.md` (binding charter for all 5
protocols). Four rules:

1. **Same version is not a terminator.** Matching `VERSION.json` →
   proceed to drift detection.
2. **No multiple-choice menus when one answer is correct.** Specific
   forbidden phrases enumerated ("If you want me to take action
   anyway, your options are: 1. ... 2. ... 3. ...").
3. **Ask only what you cannot determine.** The Project Questionnaire
   in BOOTSTRAP is the only legitimate user-input phase.
4. **Drift detection is automatic and complete.** Classification
   rules: IDENTICAL / PROJECT-EXTENSION / STALE-TEMPLATE / LOCAL-EDIT
   / PROJECT-STATE.

7 legitimate STOP conditions enumerated (dirty tree, missing required
deps, conflict requiring user resolution, user-cancelled, template
older than project, etc.). Anything else: proceed with the safest
correct action and report.

`UPGRADE_PROTOCOL.md` updated:
- Phase 0 STOP rule removed.
- New Phase 1.5 (DRIFT DETECTION) inserted, mandatory, runs in
  same-version case too.
- Drift report goes to `io/ledger/drift-<date>-<short-hash>.md` with
  the same YAML-style header as `/arib-deep-audit`.

The 4 sibling protocols each gain a header note pointing to
PROTOCOL_PRINCIPLES.md with protocol-specific guidance (BOOTSTRAP:
Questionnaire is the only user-input phase; REVERSE_BOOTSTRAP: ask
only on ambiguous scan; MIGRATION_GUIDE: source-system identification
is determinable; REENGINEERING_GUIDE: overlay sequence is
deterministic).

**Consequences.** Same-version upgrade runs no longer terminate
prematurely — they run drift detection and report what was refreshed,
preserved, or flagged for review. Numbered options menus become
forbidden by the binding charter. New constraint (#11 in
CONSTRAINTS.md) makes the discipline binding methodology-wide, not
just within bootstrap protocols.

**Alternatives rejected.** "Document the same-version exit as
intentional" — the user reported it as a bug, and they're right;
matching versions don't imply matching files. "Add a `--force` flag
the user must pass" — re-introduces a numbered choice the protocol
should make on its own. "Keep the menu but reword it" — addresses
the symptom, not the principle.

---

# ADR-013: CI/PR as a Standalone Technique (v3.5)

**Status:** Accepted   **Date:** 2026-05-08

**Context.** ADR-012 (v3.4) made CI/PR a first-class methodology
artifact via templates, workflows, CODEOWNERS, and governance docs.
But the artifacts were *static*: no agent owned them, no skill made
them executable, no path-scoped rules guided edits. Quarterly review
of CI/PR posture had no methodology-side entry point. Bootstrapping
CI/PR into a new project meant copying files manually rather than
running `/arib-ci-audit init`. The plumbing existed; the active layer
did not.

**Decision.** Promote CI/PR to a full CCM capability with the standard
agent + skill pair, matching the pattern used for code review
(`code-reviewer` + `/arib-dev-review`), compliance (`security-auditor`
+ `/arib-check-compliance`), and waves (`architect`/`planner` +
`/arib-wave-start`/`/arib-wave-end`).

- New agent: `.claude/agents/ci-pr-engineer.md`. Read-only by default;
  conditional sequential in `init` mode while the parent applies
  writes. Reads `.github/**`, `CONTRIBUTING.md`, `SECURITY.md`,
  ADR-012, optional `gh api` for live branch-protection state.
- New skill: `.claude/skills/arib-ci-audit/SKILL.md`. Four modes:
  `audit` (default), `init`, `review <file>`, `branch-protection`.
  Output goes to `io/ledger/ci-pr-<mode>-<date>.md` using the same
  YAML-style header as `/arib-deep-audit` for shared audit-trail
  format.
- New parallel-dispatch recipe (Recipe 5 in AGENT_ARCHITECTURE.md).
- Training/11-CI-PR-MANUAL.md updated to document the agent + skill.
- AGENT_ARCHITECTURE.md inventory grows to 15 (added planner from
  earlier work + ci-pr-engineer now).

**Consequences.** CI/PR audits become routine and reproducible. Init
mode means new projects bootstrap CI/PR through `/arib-ci-audit init`
instead of manual file copying. Branch protection — the only
GitHub-web-UI-only setting — gains an on-demand verification path via
`gh api`. The agent is parallel-safe in audit mode, so it composes
into `/arib-deep-audit` as section 9 (documentation completeness).

**Alternatives rejected.**
- "Multiple skills (`arib-ci-init`, `arib-ci-review`, etc.)" — splits
  related operations across files; CCM's established pattern is
  modes-on-one-skill (see `arib-deep-audit` audit/IMPLEMENT-FROM-FILE,
  `arib-check-compliance` per-framework).
- "New hook for session-start CI health check" — duplicates
  `json-validate.yml` work and adds noise on every session start;
  on-demand `branch-protection` mode in the skill is sufficient.
- "Make ci-pr-engineer a write-by-default agent" — violates the
  parallel-safety principle (only read-only agents fan out cleanly);
  init-mode sequential is the right exception, not the default.

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
| ADR-013 | CI/PR as a Standalone Technique (v3.5) | Accepted | 2026-05-08 |
| ADR-014 | Decisive Bootstrap Protocols (v3.5.1) | Accepted | 2026-05-08 |
| ADR-015 | Wave Auto-Advance Execution (v3.6) | Accepted | 2026-05-08 |
| ADR-016 | Self-Policing — Make CCM Enforce Its Own Rules (v3.7) | Accepted | 2026-05-08 |
| ADR-017 | Canonical "4-Layer" Architecture Framing (v3.7) | Accepted | 2026-05-08 |
| ADR-018 | Close the Deferred Review Findings (v3.7.1) | Accepted | 2026-05-08 |
| ADR-019 | Lean Core — Always-On Context Budget (v3.8.0) | Accepted | 2026-06-03 |
| ADR-020 | Skill name conformance + autonomous protocol execution (v3.8.1) | Accepted | 2026-06-03 |

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
