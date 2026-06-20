---
name: arib-build
argument-hint: "<goal>"
description: "Engine | Command the engineering team to deliver a known goal — dispatches the engineer-manager agent to decompose → dispatch specialists (parallel where safe) → integrate → reconcile (verification-agent) → merge gate. Use when a goal needs a coordinated TEAM, not one specialist. Sibling of /arib-engine: the engine DISCOVERS its own backlog; /arib-build EXECUTES a goal you hand it."
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
`/arib-wave-plan` lock already exists to use as the decompose input). Then dispatch:

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

## Step 2 — The merge gate (unchanged, never weakened)

The manager holds **no** new authority. Merge to `main` follows CONSTRAINTS #17: blocking
CI green **and** `verification-agent` RECONCILED **and** not a high-stakes class.
Money/tax, auth, tenant-isolation, compliance, secrets, breaking-migration **always hold
for a human**. Under
`CCM_AUTONOMY=1`, the autonomy guard's caps stop the run exactly as they stop a wave.

## Examples

```text
/arib-build add a soft-delete flag to the Patient entity

Manager: decompose → architect (schema impact) + planner (sequence) ▶ task graph (4 nodes)
  ▶ database-guardian (migration safety) ▶ implement ▶ fan-out: code-reviewer + security-auditor + test-engineer
  ▶ integrate ▶ verification-agent → GAP (cascade on related rows unhandled) → re-loop node 3
  ▶ verification-agent → RECONCILED ▶ high-stakes? (migration) → HOLD for human merge.
```

## Anti-patterns

Doing the work in the skill instead of dispatching the manager · inventing merge authority
(the gate is CONSTRAINTS #17) · using `/arib-build` for a one-line fix · treating it as a
rival to `/arib-engine` rather than its known-plan sibling.
