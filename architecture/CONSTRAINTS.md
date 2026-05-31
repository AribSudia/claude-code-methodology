# CONSTRAINTS — Hard Rules for [PROJECT]

This document defines the non-negotiable constraints that must be enforced throughout [PROJECT]. These are not guidelines—they are rules. Violations must be caught in code review, automated checks, or CI/CD gates.

---

## Universal Security Rules

### Secrets and Credentials
- **NEVER commit secrets to version control.** No API keys, database passwords, private keys, tokens, or credentials in code, config files, or env examples.
- **NEVER log secrets.** Sanitize authentication headers, tokens, passwords, and PII from all logs.
- **NEVER hardcode connection strings.** All sensitive config must come from environment variables or secure vaults.
- **NEVER expose secrets in error messages** or stack traces returned to clients.
- Use `.env.example` with placeholder values only; `.env` is always `.gitignore`d.

### Input Validation
- **ALL user input must be validated** before processing—no exceptions.
- Validate type, length, format, and range.
- Reject unexpected input; never attempt silent correction.
- Validate on both client and server; never trust client-side validation alone.
- Use allowlists where possible; deny lists are fragile.

### SQL and Database
- **NEVER use string interpolation or concatenation for SQL.** Always use parameterized queries or ORM.
- **NEVER generate raw SQL from user input.** Use query builders with parameterized placeholders.
- **NEVER trust user-supplied column names or table names.** Validate against a whitelist if dynamic queries are unavoidable.

### API Security
- Validate origin in CORS headers; never use `*` with credentials.
- Enforce HTTPS in production; redirect HTTP → HTTPS.
- Implement rate limiting on all public endpoints.
- Sanitize all outputs in error responses to avoid information leakage.
- Never expose internal stack traces or database errors to clients.

---

## Data Integrity Rules

### Deletions
- **NEVER implement hard deletes without a soft-delete option.**
- Soft delete: add `deleted_at` timestamp; exclude soft-deleted rows in queries unless explicitly included.
- Require explicit admin confirmation + audit log for any hard delete.
- Maintain a separate archive table or write deleted records to an audit log before deletion.

### Audit Trail
- **EVERY create, update, delete operation must log who, what, when, where.**
- Log format: `timestamp | user_id | action | resource_type | resource_id | old_values | new_values | ip_address`
- Audit logs must be immutable (append-only) and retained per compliance requirements.
- Sensitive fields (passwords, SSNs) should never appear in audit logs; log only hash or "[REDACTED]".

### Transactions
- Wrap multi-step operations in transactions to prevent partial updates.
- Rollback on any failure; never leave data in inconsistent state.
- Validate foreign key constraints before committing.

### Concurrency
- Use optimistic locking (version/revision numbers) or pessimistic locking (row locks) where concurrent updates are possible.
- Handle race conditions in critical sections (inventory, payments, balances).

---

## Code Quality Rules

### Function Length
- **No function may exceed 30 lines** (excluding comments).
- Measure: function header to final `}` or `return`.
- Large functions must be refactored into smaller, focused helpers.
- Exception: generated code or DSL interpreters with explicit approval.

### File Length
- **No file may exceed 300 lines** (excluding comments and blank lines).
- Large files must be split into modules.
- Exception: auto-generated files (migrations, protobuf) and test fixtures with explicit comment.

### Code Review
- **All code must pass review before merge.**
- Reviewer must understand the change and verify it follows all CONSTRAINTS.
- No self-review; minimum 1 reviewer.
- Amend after review; do not force-push.

### No TODOs Without Tickets
- **Every TODO, FIXME, HACK comment must reference a ticket ID** in parentheses.
  - Example: `// TODO (PROJ-123): Optimize this query`
- Linter or pre-commit hook must catch bare TODOs.
- Bare TODOs are grounds for PR rejection.

### Documentation
- **Every public function must have a docstring** (or equivalent) with:
  - One-line summary.
  - Parameter types and descriptions.
  - Return type and description.
  - Example usage (if non-obvious).
- Internal-only functions should be self-documenting via clear names.

---

## Git Rules

### Conventional Commits
- All commits must follow the format: `[type]: description`
- Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `snapshot`, `security`
- Description: lowercase, imperative mood, no period.
- Example: `feat: add pagination to user list endpoint`
- Enforce via commit-msg hook.

### Merge and Push Rules
- **NEVER force-push to `main`**, `develop`, or any shared branch.
- **NEVER merge into `main` without review.**
- **NEVER merge `develop` into feature branches;** rebase feature off develop.
- All merges to `main` must go through a PR with CI passing.
- Branch protection rules must be enabled in Git.

### Branch Strategy
- `main`: production-ready, tagged releases only.
- `develop`: integration branch, must have tests passing.
- `feature/xxx`: off develop, one feature per branch.
- `hotfix/xxx`: off main, for production bugs, merged back to main and develop.
- `release/x.y.z`: for release prep, merged to main and develop.

---

## Testing Rules

### No Deploy Without Tests
- **Every feature must have tests** before PR approval.
- Tests must cover: happy path, edge cases, error handling.
- Minimum coverage: 70% for new code.
- Failing tests must be fixed; skipped tests must have a ticket reference.

### Test Coverage
- Unit tests: each function/method with logic.
- Integration tests: API endpoints, database interactions.
- E2E tests: critical user flows.
- Linter must enforce minimum coverage; CI must fail if below threshold.

### Test Naming
- Test names must describe the scenario: `test_createUser_withValidEmail_succeeds`
- Use BDD format where applicable: `Given..When..Then`

### No Untested Code in PR
- If you skip or comment-out a test, PR is rejected.
- If a feature is untested, it will not ship.

---

## Performance Rules

### N+1 Queries
- **NEVER fetch a parent and then loop over children to fetch each child.**
- Use JOIN, batch fetch, or ORM eager loading.
- Linter should warn on query counts in loops.
- Example prevention: `.include(:comments)` in Rails, `.populate()` in Hibernate.

### Pagination
- **All list endpoints MUST support pagination** with limit and offset.
- Default limit: 20 items; maximum limit: 100 items.
- Return total count and has_next_page in response.
- Never return unpaginated lists, even for admin endpoints.

### Connection Pool
- Configure database connection pool for expected concurrency.
- Monitor pool exhaustion; alert if > 80% utilization.
- Never open unbounded connections.

### Caching
- Cache responses for read-heavy endpoints (TTL must be configurable).
- Invalidate cache on write; prefer write-through or write-behind patterns.
- Cache key must include all relevant filters (user_id, region, etc.).

### External Calls
- All HTTP calls to external services must have timeout (max 30s).
- Retry transient failures with exponential backoff; max 3 attempts.
- Circuit breaker for repeated failures.

---

## [PROJECT]-Specific Domain Rules

**TODO: Add domain-specific constraints here.**

Examples:
- Payment processing: Never store full credit card numbers; use tokenization.
- File uploads: Only allow whitelisted MIME types; scan for viruses.
- Email: Validate sender domain; implement SPF/DKIM/DMARC.
- Multi-tenancy: Every query must filter by tenant_id; never expose cross-tenant data.
- Compliance: GDPR/HIPAA/SOC2 requirements and how they map to technical rules.

---

## Needs Approval — Sensitive Areas

These operations require explicit human review and sign-off before deployment:

| Operation | Approval Level | Reason |
|-----------|---|---|
| Database schema changes | Tech Lead | Data integrity, migration risk |
| Third-party service integration | Lead + Security | Credential management, data exposure |
| Permission/RBAC changes | Product + Security | Authorization boundary |
| Hard delete of user data | Legal + Data Officer | Compliance, audit trail |
| Public API change | Tech Lead + Product | Contract, backward compatibility |
| Security configuration change | Security Lead | Attack surface |
| Payment system changes | Finance + Security | PCI-DSS compliance |
| Data retention policy change | Legal + Compliance | Legal hold, regulatory |
| Deployment to production | Ops + Lead | Release readiness |

---

## Violations and Enforcement

**How violations are caught:**
- Pre-commit hooks: no secrets, TODOs with tickets, conventional commits.
- Linter: function length, file length, test naming, coverage.
- CI/CD: tests must pass, coverage must meet threshold, no force-pushes.
- Code review: semantic validation (business logic, architecture).
- Automated scanning: dependency vulnerabilities, secret scanning, SAST tools.

**What happens on violation:**
1. First violation: PR rejected with clear explanation.
2. Repeated violation: escalate to tech lead.
3. Habitual violation: performance discussion with manager.

---

## v3.3 "Operating" — Methodology-level constraints

These constraints govern CCM itself (not the projects it overlays). Apply
when modifying the methodology repo or shipping a new release.

1. **Hooks fail closed on unknown patterns.** A hook that cannot decide
   whether to block must block, not allow. Bypass paths are documented
   in `Training/04-HOOKS-MANUAL.md`; silent fail-open is forbidden.

2. **MCP servers are opt-in via env var.** No MCP may be a hard
   dependency of any skill, hook, or script. Every MCP-using path must
   degrade gracefully (markdown grep, filesystem polling, local
   checklist) when the MCP is absent.

3. **`compliance/` claims alignment, never certification.** The skills
   `/arib-check-compliance` and `/arib-check-arabic` output "alignment
   level: <level>" reports. The strings "compliant", "certified",
   "attested" must not appear in any framework doc as a CCM claim.

4. **Wave merges to main require an audit hash.** The
   `pre-tool-use.sh` wave-merge gate enforces this. The only sanctioned
   way to produce the hash is `/arib-deep-audit` (called by
   `/arib-wave-end`). Disabling the gate requires editing the hook.

5. **Autonomy mode requires preconditions checklist.** Documented in
   `operations/AUTONOMY_MODE.md`. The `autonomy-guard.sh` hook is a
   no-op unless `CCM_AUTONOMY=1`; with the env var set, all guardrails
   are mandatory (wall-clock, call rate, BLOCK rate, push gate).

6. **Documentation matches disk.** If `hooks/HOOKS_PROTOCOL.md` claims
   a hook exists, the hook must exist as an executable in
   `.claude/hooks/`. Same for skills, agents, and any "enforced rule".
   This constraint is the v3.2 "Honest" principle made permanent.

7. **Token-cost transparency.** `scripts/token-audit.sh` measures
   session-start cost. The README must surface the current measurement.
   Lines-of-markdown is not a quality metric.

8. **MCP placeholder packages are flagged.** Each entry in `.mcp.json`
   has a `_package_status` field. Any entry not marked `verified` must
   carry a `PLACEHOLDER` note explaining why.

9. **No experimental Claude Code flags as defaults.** Flags like
   `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` may be documented but must
   never be required for CCM to function.

10. **PRs through CI green and CODEOWNERS-approved.** Direct pushes to
    `main` are reserved for emergencies (hotfixes, broken CI on main).
    Every emergency direct push is logged in
    `operations/OPERATIONS_LOG.md` with reason and rollback plan.
    Required CI checks: hooks regression, JSON validation, token
    budget, markdown lint. CODEOWNERS routes review by path. Branch
    protection settings live in `CONTRIBUTING.md` §6.

11. **Bootstrap protocols are decisive.** Per
    `bootstrap/PROTOCOL_PRINCIPLES.md`, the 5 bootstrap protocols
    (BOOTSTRAP, REVERSE_BOOTSTRAP, UPGRADE_PROTOCOL, MIGRATION_GUIDE,
    REENGINEERING_GUIDE) must:
    - Never STOP on matching versions — proceed to drift detection.
    - Never present numbered multiple-choice menus when one answer is
      correct — pick the safest correct action and report.
    - Never ask the user a question whose answer is determinable from
      the filesystem (`VERSION.json`, `ls`, `git log`, package files).
    - Run drift detection automatically and completely, classifying
      each file as IDENTICAL / PROJECT-EXTENSION / STALE-TEMPLATE /
      LOCAL-EDIT / PROJECT-STATE and acting per the table.
    Legitimate STOP conditions are enumerated in
    `bootstrap/PROTOCOL_PRINCIPLES.md` §"Genuine blockers"; nothing
    else is a legitimate STOP.

12. **Wave execution auto-advances.** Per ADR-015, `/arib-wave-run`
    executes wave steps in order without asking "continue?" between
    them. It pauses ONLY on: step failure (per the step's
    `on_failure`), a `checkpoint: true` step, genuine ambiguity, a
    blocker, an autonomy-guard trip, or a user interrupt. An
    unverifiable step is treated as ambiguity (pause), never falsely
    marked PASS. `/arib-wave-end` remains an explicit gate — it is the
    finish line, not a between-steps prompt.

---

## Review Schedule

Last reviewed: [DATE]  
Next review: [DATE + 6 months]  
Owner: [PROJECT] Tech Lead
