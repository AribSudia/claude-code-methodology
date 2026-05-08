---
argument-hint: "<wave-name>"
description: "Wave | Start a multi-session delivery wave — branch, plan, parallel architect+planner"
---

# Wave Start — /arib-wave-start

## Overview

Opens a new delivery wave. A wave is a unit of work larger than a session
and smaller than a release — typically 1–3 weeks toward a coherent outcome.

This skill creates the wave directory, branch, and plan, and dispatches the
architect + planner agents in parallel to populate the plan with their input.

See `waves/README.md` for the full wave concept and lifecycle.

## When to Use

- Starting a coherent multi-session feature.
- Starting a chunk of refactoring that will span multiple sessions.
- Starting work that will be reported to stakeholders at the end.

**Do NOT use for:** single-session work, hotfixes, exploratory spikes.

## Usage

```bash
/arib-wave-start payment-integration
/arib-wave-start auth-rewrite
/arib-wave-start i18n-rollout
```

## Protocol

### Step 1 — Pre-flight

```text
1. Verify git working tree is clean (advisory).
2. Verify <wave-name> matches /^[a-z0-9-]+$/ — kebab case only.
3. Verify waves/<wave-name>/ does not exist (no overwrite).
4. Verify branch wave/<wave-name> does not exist.
```

### Step 2 — Scaffold

```bash
mkdir -p waves/<wave-name>
cp waves/.templates/PLAN.md waves/<wave-name>/PLAN.md
git checkout -b wave/<wave-name>
```

### Step 3 — Dispatch architect + planner (parallel)

In a single message, fan out two Task calls (per `architecture/AGENT_ARCHITECTURE.md`):

```text
Task(architect)   — proposes scope decomposition, exit criteria, risk register
Task(planner)     — sequences the work, identifies dependencies and blockers
                    (use the architect agent in planning mode if no dedicated
                    planner agent exists)
```

Both are read-only on the codebase; their output goes into PLAN.md.

### Step 4 — Populate PLAN.md

Merge the architect and planner outputs into the template. Specifically:
- **Scope (in/out)** ← architect's decomposition + planner's deferral list.
- **Exit criteria** ← architect.
- **Risk register** ← architect risks + planner sequencing risks.
- **Dependencies** ← planner.
- **Plan (high-level)** ← planner's sequence.

Do NOT skip the "Out of scope" section. If everything is in scope, the wave
is undefined and will sprawl.

### Step 5 — Commit + announce

```bash
git add waves/<wave-name>/
git commit -m "feat(wave): start <wave-name>"
```

Announce to user:
- Wave directory created.
- Branch `wave/<wave-name>` checked out.
- PLAN.md populated. Review and adjust before starting work.
- Reminder: `/arib-wave-end` is the only way to land on `main` from this branch.

## Failure modes

- **Wave name collides with existing dir or branch:** abort. Pick a different name.
- **Architect or planner returns empty:** ask the user to refine the wave goal,
  then retry.
- **Working tree dirty:** warn but allow; the wave commit will be the first
  commit on the new branch.

## Related

- `waves/README.md` — wave concept and lifecycle.
- `arib-wave-end` — wave-end gate.
- `arib-deep-audit` — runs at /arib-wave-end.
- `architecture/AGENT_ARCHITECTURE.md` — parallel-dispatch governance.
