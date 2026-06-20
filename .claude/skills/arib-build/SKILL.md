---
name: arib-build
argument-hint: "<goal>"
description: "Engine | Command the engineering team to deliver a known goal — dispatches the engineer-manager to decompose → dispatch specialists (parallel where safe) → integrate → reconcile (verification-agent) → merge gate. Scales its own reach: runs inline for a bounded goal, escalates to a parallel Workflow for a broad one, and paces under /loop for a multi-turn campaign — only when it needs to. Use when a goal needs a coordinated TEAM, not one specialist. Sibling of /arib-engine: the engine DISCOVERS its own backlog; /arib-build EXECUTES a goal you hand it."
---

# /arib-build — command the engineering team

Hand the **project engineering manager** a goal and it runs the team: decomposes the
work, dispatches the right specialists (in parallel where safe), integrates their output,
reconciles it against your goal, and stops at the merge gate. One trigger; the manager
conducts the rest.

> This skill is thin on purpose — the orchestration logic lives in the
> `engineer-manager` agent (`.claude/agents/engineer-manager.md`). This is the invocation.

## When to use it (and when not)

- **Use `/arib-build`** when a goal needs several specialists coordinated — e.g. "add the
  refund endpoint" (architect → db migration review → implement → security + test fan-out
  → reconcile). The manager picks and sequences the team.
- **Use `/arib-engine`** for a sustained, self-directed campaign where the *backlog is
  discovered*, not given ("harden the whole codebase until done"). Engine finds the work;
  `/arib-build` executes the work you name. Same merge gate, same guardrails.
- **Just call one specialist / do the fix** for a single bounded task — a whole team is
  overkill (the manager itself will say so and shrink the dispatch).

## Step 0 — Parse the mandate

`/arib-build <goal>`

State in one line what you understood (the goal + whether a `waves/<id>/PLAN.md` or
`/arib-wave-plan` lock already exists to use as the decompose input).

## Step 0.5 — Choose the execution mode (escalate only if it needs)

`/arib-build` sizes the goal and runs the **smallest mechanism that fits**. This decision
lives at the skill level because the skill runs in the main session — which holds the
`Workflow` tool and can arm `/loop`/`ScheduleWakeup`; the `engineer-manager` *agent*
dispatches via `Task` (capped at one level), so broad/multi-turn reach is the skill's job.

| Scope signal | Mode | What runs |
|---|---|---|
| One coherent change, a few specialists, fits one turn | **Inline** (default) | `Task(engineer-manager, goal=…)` — the manager fans out via `Task` |
| **Broad / parallel / verify-heavy** — many independent units, a multi-stage pipeline, or N findings each needing adversarial verification | **Workflow** | The skill launches a **Workflow**: the manager's decompose output becomes the task list; `pipeline()`/`parallel()` run the units with bounded concurrency + schema'd verdicts |
| **Campaign** — won't finish in one turn, or each step is gated on an external event (CI, deploy, a long build) | **`/loop`** | Run under `/loop` (the canonical scheduler); each tick does one unit (inline *or* a Workflow). Under unattended mode (ADR-030) it proceeds without pausing |

**"Runs if it needs" — the discipline:** escalate *up* only when the scope warrants, never
down-justify ceremony. Don't spin a Workflow for a one-file fix; don't `/loop` a
single-turn goal. The mode can compose — a `/loop` tick may launch a Workflow, and a
Workflow stage may dispatch specialists. State the chosen mode in the one-line confirmation.

**Inline dispatch (the default path):**
```
Task(engineer-manager, goal="<goal>", plan=<PLAN.md if present>)
```

## Step 1 — Let the manager run its cycle

The `engineer-manager` agent owns the loop (see its definition):

```
decompose  → Task(architect) + Task(planner) in parallel → task graph
dispatch   → fan-out specialist batches (no write-conflicts, no read-after-write)
integrate  → parent session converges all writes
verify     → Task(verification-agent) LAST → RECONCILED | GAP (re-loop) | HOLD (human)
```

Report a running log: which specialist did what, each verdict, what merged.

## Step 2 — The merge gate (same in ALL three modes, never weakened)

The mode (inline / Workflow / `/loop`) changes only *how* the work is dispatched and
paced — it changes **nothing** about authority. In every mode, merge to `main` follows
CONSTRAINTS #17: blocking CI green **and** `verification-agent` RECONCILED **and** not a
high-stakes class. Money/tax, auth, tenant-isolation, compliance, secrets,
breaking-migration **always hold for a human**. Workflow agents and `/loop` ticks hit the
same fail-closed hooks and the same autonomy-guard caps (`CCM_AUTONOMY=1`) as an inline
run. Scaling reach never scales authority.

## Examples

```text
# Inline — bounded goal, one turn
/arib-build add a soft-delete flag to the Patient entity
Manager: decompose → architect + planner ▶ graph(4) ▶ database-guardian ▶ implement
  ▶ fan-out code-reviewer+security-auditor+test-engineer ▶ verification-agent → GAP
  → re-loop node 3 → RECONCILED ▶ high-stakes (migration) → HOLD for human merge.

# Workflow — broad goal, the skill escalates to parallel orchestration
/arib-build migrate all 40 controllers to the new auth guard
→ decompose → 40 independent units → LAUNCH Workflow: pipeline(units, migrate, verify)
  with bounded concurrency; each unit verified by verification-agent; non-high-stakes
  auto-merge, the guard change itself held for a human.

# Loop — campaign, the skill paces across turns
/loop /arib-build harden every money-math path in the billing module
→ each tick takes one path: build → reconcile → (auto-merge non-high-stakes / hold money
  paths) → re-arm; stops when the backlog is dry. Unattended mode = no pauses (ADR-030).
```

## Anti-patterns

Doing the work in the skill instead of dispatching the manager · inventing merge authority
(the gate is CONSTRAINTS #17) · using `/arib-build` for a one-line fix · **spinning a
Workflow or a `/loop` when an inline run fits** (escalate only if it needs) · letting a
Workflow/loop path quietly skip the merge gate · treating it as a rival to `/arib-engine`
rather than its known-plan sibling.
