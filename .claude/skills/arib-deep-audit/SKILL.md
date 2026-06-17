---
name: arib-deep-audit
argument-hint: "[wave-name | --from-file <audit-report.md>]"
description: "Audit | Wave-end 21-section deep audit + IMPLEMENT-FROM-FILE mode"
---

# Deep Audit — /arib-deep-audit

## Overview

A wave-end gate. Existing `/arib-check-*` skills are spot-checks (300-500
lines each, run individually). This skill **dispatches all of them in a single
fan-out**, plus 9 additional sections that are too cross-cutting for any
individual check to own. The output is a structured `OPERATIONS_LOG.md` entry
plus an audit hash committed to git.

The wave overlay (`/arib-wave-end`) requires this skill to pass before merging
to main.

## Two modes

### Mode 1 — Audit (default)

Dispatches all 21 sections, merges findings, returns a verdict (PASS / WARN /
BLOCK) and a deterministic audit hash.

```bash
/arib-deep-audit                    # audit current branch vs. main
/arib-deep-audit wave-3             # audit named wave (reads waves/wave-3/PLAN.md)
```

### Mode 2 — IMPLEMENT-FROM-FILE

Reads a previous audit report and **dispatches parallel Tier-2 fix agents per
finding**. Each finding gets its own subagent with a scoped prompt and the
relevant file context. Used when re-auditing after a known set of issues.

```bash
/arib-deep-audit --from-file io/ledger/audit-2026-05-08.md
```

The skill body matches each finding to the right specialist agent
(`security-auditor`, `accessibility`, `performance`, `database-guardian`,
`refactor-specialist`, `language`, `api-docs`) and dispatches them in
parallel where it's safe (see `architecture/AGENT_ARCHITECTURE.md`).

## The 21 Sections

Each section maps to either an existing `arib-check-*` skill (preserved as a
deeper reference) or a new check that this skill owns directly.

| # | Section | Owner | Severity if FAIL |
|---|---------|-------|------------------|
| 1 | Security — OWASP Top 10 + supply chain | `arib-check-security` (delegates to security-auditor agent + arib-check-deps) | BLOCK |
| 2 | Security — supply chain (deps + CVEs) | `arib-check-deps` | BLOCK on critical |
| 3 | Performance — N+1, latency budgets, bundle | `arib-check-perf` | WARN |
| 4 | Accessibility — WCAG 2.1 AA | `arib-check-a11y` | WARN |
| 5 | Reality — mock detection, fake APIs | `arib-check-reality` | BLOCK |
| 6 | Database — migration safety | `arib-check-migrate` | BLOCK |
| 7 | i18n — RTL/LTR/CJK, Arabic typography | `arib-docs-language` + `arib-check-arabic` (#7) | WARN |
| 8 | Observability — logging, metrics, tracing | this skill | WARN |
| 9 | Documentation — completeness, drift | `arib-docs-api` + `arib-docs-generate` | WARN |
| 10 | Test coverage — unit, integration, E2E | this skill (delegates to test-engineer) | WARN |
| 11 | Dependency CVEs (separate from supply chain) | `arib-check-deps` | BLOCK on critical |
| 12 | License compliance | this skill | WARN |
| 13 | Race conditions — concurrency, locks | this skill (delegates to debugger) | BLOCK on found |
| 14 | Multi-tenancy isolation | this skill | BLOCK on tenant leak |
| 15 | Secrets hygiene | pre-commit hook + this skill | BLOCK |
| 16 | Error handling — graceful, structured | this skill | WARN |
| 17 | Logging — PII redaction, retention | this skill (links to GDPR in #7) | BLOCK on PII leak |
| 18 | Retry / backoff — idempotency, jitter | this skill | WARN |
| 19 | Cache invalidation — staleness, stampede | this skill | WARN |
| 20 | Schema drift — migrations vs. types | `arib-check-migrate` | BLOCK on drift |
| 21 | Contract tests — API ↔ client | this skill | WARN |

**Severity rules:**
- **BLOCK** — wave cannot end. Must fix or escalate via `io/signals/`.
- **WARN** — wave can end, but the warning is recorded and re-checked next wave.
- **PASS** — section clean.

## Protocol

### Step 1 — Pre-flight

```text
1. Confirm git working tree is clean (advisory; warn if dirty).
2. Determine baseline:
   - Default: branch HEAD vs. main
   - With wave-name: read waves/<name>/PLAN.md for scope
   - With --from-file: skip to Mode 2
3. Echo the 21-section plan to the user.
```

### Step 2 — Dispatch (Mode 1)

Fan out wherever parallel-safe. The 15-agent table in `AGENT_ARCHITECTURE.md`
governs which calls share a Task batch.

```text
Batch A (read-only, fully parallel):
  Task(security-auditor)        sections 1, 11, 15, 17
  Task(performance)             section 3
  Task(accessibility)           section 4
  Task(reality-auditor)         section 5
  Task(database-guardian)       sections 6, 20
  Task(language)                section 7
  Task(api-docs, mode=audit)    section 9
  Task(test-engineer, mode=report-only)  section 10

Batch B (this skill runs directly, sequential):
  Sections 8, 12, 13, 14, 16, 18, 19, 21
```

### Step 2.5 — Refute before you record (adversarial filter, ADR-026)

Batch A is multi-*perspective* concurrency (different lenses run at once) — it
is NOT adversarial refutation, so it produces false positives. Before a finding
enters Step 3, put it through `find → refute → confirm`:

1. **Refute.** For each candidate finding, run an independent skeptic that
   **defaults to "not a bug"** and tries to disprove it on a distinct lens —
   *is it real? is it reachable? is it intentional/by-design?* Keep the finding
   only if it survives. (Use diverse lenses, not N identical skeptics —
   same-model agreement is correlated, not independent corroboration.)
2. **Confirm by ground-truth read.** Re-read the cited code yourself and prove
   the finding before it becomes a BLOCK/WARN. A finding that can't be grounded
   is downgraded to INFO or dropped, with the reason recorded (per CONSTRAINTS
   #14: rejecting a false positive is a real result).
3. **Loop until dry.** If a section keeps surfacing new real findings, sweep it
   again; stop when consecutive rounds add nothing.

**Safety-critical exception.** For sections 1/11/15/17 (security, authz,
tenant-isolation) and any money/tax finding, do NOT let the reject-biased filter
suppress a plausible issue — a false negative there is catastrophic. A single
credible finding in these classes goes straight to the ground-truth read and, if
real, to escalation; it is never dropped by a skeptic vote.

### Step 3 — Merge findings

For each section, record:
- **status**: PASS | WARN | BLOCK
- **finding**: one-paragraph description
- **evidence**: file:line citations
- **fix-hint**: actionable next step
- **owner**: which agent or section number

### Step 4 — Compute audit hash

The hash is the sha256 of the serialized findings (sorted by section). It
becomes the proof that an audit ran against this exact codebase state. The
wave overlay (`/arib-wave-end`) checks for this hash before merging.

```bash
sha256sum -- "${REPORT_FILE}"
```

### Step 5 — Write report + log

Output file: `io/ledger/audit-<YYYY-MM-DD>-<short-hash>.md`.

The report **MUST** start with the following YAML-style header. The
`pre-tool-use.sh` wave-merge gate greps for `wave: <name>` and the
`arib-wave-end` skill greps for `audit-hash: <sha>` — both keys are part
of the contract.

```markdown
# Deep Audit Report

- audit-hash: <full sha256>
- short-hash: <first 8 of sha>
- timestamp: <YYYY-MM-DDTHH:MM:SSZ>
- branch: <git current branch>
- head-sha: <full git HEAD>
- wave: <wave-name | none>
- verdict: PASS | WARN | BLOCK
- mode: audit | implement-from-file
- findings-count: <int>
- block-count: <int>
- warn-count: <int>

## Findings

(... per-section findings — see Step 3 ...)
```

If the audit is not tied to a wave (default branch), write `wave: none`.
The wave-merge gate only fires on `wave/*` branches, so `none` is safe.

Then append a single line to `operations/OPERATIONS_LOG.md`:

```markdown
2026-05-08 | deep-audit | <wave-or-none> | <verdict> | <short-hash> | <one-line-summary>
```

### Step 6 — Verdict

```text
PASS:  all sections PASS or WARN, no BLOCK.
BLOCK: any section returned BLOCK; wave halted; escalate via io/signals/.
```

## IMPLEMENT-FROM-FILE mode (deep dive)

```text
1. Parse report file. Extract findings by section.
2. For each finding:
   a. Determine severity (BLOCK first, then WARN).
   b. Match to specialist agent.
   c. Build a scoped prompt: section, finding, evidence, fix-hint.
   d. Add to dispatch batch (parallel where AGENT_ARCHITECTURE permits).
3. Run dispatch in waves of 3-5 parallel agents.
4. After each wave, verify with the agent's own check (e.g., security-auditor
   re-runs section 1 to confirm fix).
5. Re-compute audit hash. If new hash != original, the audit was advanced.
```

## Failure modes

- **Subagent timeout:** record the section as INCONCLUSIVE; do not mark PASS.
- **Conflicting findings between agents:** resolve to the more conservative
  call (BLOCK > WARN > PASS).
- **Wave plan missing:** if `--wave-name` was passed but `waves/<name>/PLAN.md`
  doesn't exist, fall back to branch-vs-main scope and warn.

## Related

- `architecture/AGENT_ARCHITECTURE.md` — parallel-dispatch governance.
- `arib-check-*` skills — individual sections in higher detail.
- `arib-wave-end` skill — calls this skill as a gate.
- `operations/OPERATIONS_LOG.md` — append-only audit history.
