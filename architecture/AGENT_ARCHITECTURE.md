# AGENT_ARCHITECTURE.md

> **Purpose** — Document each CCM agent's parallel-dispatch safety, what state it
> reads/writes, and which skills should fan out to multiple agents in a single
> Task call rather than running them sequentially.
>
> **Status** — Documentation only. No new infrastructure, no experimental flags,
> no MCP servers. Parallel dispatch happens via the standard `Task` tool with
> multiple invocations in a single message — a primitive that has worked since
> Claude Code shipped.

---

## Parallel-dispatch primer

Claude Code allows multiple `Task` tool calls in a single assistant message. When
the calls are independent, the runtime dispatches them concurrently. The pattern
is:

```text
[ASSISTANT]  Calling Task(reviewer), Task(security), Task(tester) — all in one message.
```

This shaves wall-clock time on review-style workflows where three agents read
the same diff and produce independent findings.

**Two rules govern when this is safe:**

1. **No write conflicts.** Two parallel agents must not write to the same file
   or memory record. Memory writes converge through the parent session, not
   inside the parallel tasks.
2. **No read-after-write within the fan-out.** If agent B needs the output of
   agent A, they cannot run in parallel. Sequence them.

The table below records, for each CCM agent, what it reads and writes, and
whether it is safe to dispatch alongside others.

---

## Agent inventory

| Agent | Reads | Writes | Parallel-safe | Notes |
|-------|-------|--------|---------------|-------|
| `architect` | `architecture/*.md`, current diff | proposes changes only (no direct writes) | Yes | Pairs well with `code-reviewer` during planning. |
| `code-reviewer` | diff, `architecture/CONSTRAINTS.md` | review report (returned to parent) | Yes | Core member of the parallel review fan-out. |
| `security-auditor` | diff, `architecture/SECURITY.md`, `.env.example` | security report (returned to parent) | Yes | Core member of the parallel review fan-out. |
| `test-engineer` | diff, `tests/`, `package.json` test scripts | optionally writes to `tests/` | Conditional | Parallel-safe when scoped to *report only*. If asked to write tests, run sequentially after reviewer/security so the test plan reflects their findings. |
| `debugger` | failing test output, source under suspicion | hypothesis log | Conditional | Parallel-safe with `reality-auditor` (both read-only). Sequence with anything that modifies the file under investigation. |
| `reality-auditor` | source code, schema, test fixtures | reality report | Yes | Read-only. Cheap to run alongside any other agent. |
| `database-guardian` | `migrations/`, `prisma/`, `architecture/DECISIONS.md` | migration safety report | Conditional | Sequence with `architect` if both touching schema decisions. |
| `performance` | source under audit, profiler output | perf report | Yes | Read-only by default. |
| `accessibility` | UI components, design tokens | a11y report | Yes | Read-only. |
| `api-docs` | route handlers, `implementation/API_ENDPOINTS.md` | docs (writes) | No | Writes to API docs — must run alone or sequentially with anything else editing `implementation/`. |
| `language` | i18n strings, locale configs | locale audit | Yes | Read-only. |
| `refactor-specialist` | source under refactor | rewritten files | No | Direct file writes. Always run alone for the duration of the refactor. |
| `deploy-guardian` | `operations/DEPLOYMENT.md`, CI config, env files | deploy gate verdict | Yes | Read-only review of deploy readiness. |
| `planner` | architect output, `architecture/DECISIONS.md`, memory | sequence + dependencies + risks + blockers (returned to parent) | Yes | Read-only. Pairs with `architect` during `/arib-wave-start`. |
| `ci-pr-engineer` | `.github/**`, `CONTRIBUTING.md`, `SECURITY.md`, ADR-012, optional `gh api` | CI/PR audit report (returned to parent); proposes init scaffolding | Conditional | Read-only by default (audit/review/branch-protection modes). Sequential in `init` mode while parent applies writes. |
| `verification-agent` | the diff/PR (unit) or `waves/<name>/PLAN.md` + composed branch (wave), gate evidence | RECONCILED / GAP / HOLD verdict (returned to parent) | Yes | Read-only pre-merge reconciler (intent ↔ actual change). The closing gate for auto-merge in `/arib-engine` (unit scope) and Waves (wave scope). Runs AFTER `code-reviewer`/`security-auditor` — they judge quality, it judges fulfillment. ADR-027. |

**Total:** 16 agents (matches `.claude/agents/` count, excluding `README.txt`).

---

## Parallel dispatch recipes

### Recipe 1 — Review fan-out (used by `arib-dev-review`)

Three agents in one Task batch. All three read the same diff and return
independent findings. The skill body merges the three reports into a single
summary.

```
Task(code-reviewer)
Task(security-auditor)
Task(test-engineer, mode=report-only)
```

Wall-clock: ~90 seconds vs. ~5–10 minutes sequential.

### Recipe 2 — Pre-deploy fan-out (used by `arib-check-deploy`)

Four read-only agents in one batch.

```
Task(security-auditor)
Task(performance)
Task(accessibility)
Task(deploy-guardian)
```

Each produces a phase verdict. The skill blocks the deploy if any returns
BLOCKED.

### Recipe 3 — Architecture review (used during `arib-dev-feature` planning)

```
Task(architect)
Task(reality-auditor)
```

Architect proposes; reality-auditor verifies the proposal against the actual
codebase. Both read-only.

### Recipe 4 — Wave start (used by `arib-wave-start`)

```
Task(architect)
Task(planner)
```

Architect proposes scope; planner sequences it with risks. Both read-only.
Parent merges into `waves/<name>/PLAN.md`.

### Recipe 5 — CI/PR audit (used by `arib-ci-audit`)

```
Task(ci-pr-engineer, mode=audit)
```

Single agent. Can run in parallel with other read-only audits (e.g.,
section 9 of `/arib-deep-audit` documentation completeness):

```
Task(ci-pr-engineer, mode=audit)
Task(api-docs, mode=audit)
Task(language)
```

---

## When NOT to dispatch in parallel

- **Any agent that writes files** — `refactor-specialist`, `api-docs` when
  generating, `test-engineer` when writing tests.
- **Agents touching the same memory record** — keep memory writes in the parent
  session, not inside parallel tasks.
- **When B depends on A's output** — sequence them.

If in doubt, run sequentially. The wall-clock cost of being wrong about
parallel-safety (corrupted file, lost write) outweighs the wall-clock saving.

---

## What this document is NOT

- **Not a runtime.** No new orchestration layer; the `Task` tool already does
  what we need.
- **Not Anthropic's experimental Agent Teams flag.** That flag may stabilize
  later; until then we use plain Task fan-out.
- **Not Tier-3 cross-session orchestration via Composio / n8n-MCP.** Out of
  scope for v3.2; revisit if a real workload demands it.

---

## Review schedule

Update this document when:
- An agent is added, removed, or renamed.
- An agent's read/write surface changes (e.g., a previously read-only agent
  starts writing).
- A new parallel recipe proves useful in a skill.

Last updated: 2026-05-08 (v3.2 "Honest")
