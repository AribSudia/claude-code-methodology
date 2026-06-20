---
name: arib-wave-start
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

### Step 0 — Requirement lock (auto-chained, idempotent — v3.17.0/ADR-032)

Before scaffolding, run the pre-wave requirement lock:

```text
- waves/<wave-name>/PLAN.md already exists? → SKIP (operator locked it manually). Proceed.
- else → auto-invoke /arib-wave-plan <goal>:
    Act 1 (grill): derive requirements from codebase + memory, record decisions+evidence.
                   Unattended mode → assume-and-record; escalate only unknowable-from-code.
    Act 2 (Codex): independent adversarial review until sign-off → PLAN-REVIEW-LOG.md.
                   Codex absent → log honestly + flag the wave `merge-hold: human-review`.
```

This is the one auto-chained pre-flight; the rest of the wave is unchanged. See
`.claude/skills/arib-wave-plan/SKILL.md`.

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
- PLAN.md populated, including the **Steps** section with the
  auto-advance execution contract (each step has goal / done_when /
  checkpoint / on_failure).
- **Next:** review and adjust PLAN.md, then run `/arib-wave-run` to
  execute. It auto-advances through the steps — you won't be asked
  "continue?" between steps; it pauses only on a failure, a
  `checkpoint: true` step, genuine ambiguity, or a blocker.
- Reminder: `/arib-wave-end` is the only way to land on `main` from this branch.

### Step 6 — Offer to begin execution

After announcing, **offer to run `/arib-wave-run` immediately** (don't
force it — the user may want to edit PLAN first). If the user confirms,
hand off to `/arib-wave-run`. If the wave's step 1 is a `checkpoint:
true` step, `/arib-wave-run` will pause before it regardless.

## Failure modes

- **Wave name collides with existing dir or branch:** abort. Pick a different name.
- **Architect or planner returns empty:** ask the user to refine the wave goal,
  then retry.
- **Working tree dirty:** warn but allow; the wave commit will be the first
  commit on the new branch.

## Examples

### Example 1 — Greenfield wave

```text
User: /arib-wave-start payment-integration

Step 1 — Pre-flight
  Working tree: clean ✓
  Wave name: payment-integration (kebab-case ✓)
  waves/payment-integration/: doesn't exist ✓
  branch wave/payment-integration: doesn't exist ✓

Step 2 — Scaffold
  Created waves/payment-integration/
  Copied .templates/PLAN.md
  Checked out branch wave/payment-integration

Step 3 — Dispatch (parallel)
  Task(architect)  → returned scope decomposition + risk register
  Task(planner)    → returned sequence + dependencies + blockers

Step 4 — Populate PLAN.md
  Goal: Integrate Stripe for one-time payments + subscriptions.
  In scope: webhook handler, checkout session, subscription mgmt.
  Out of scope (explicit): refund automation, invoicing, tax calc.
  Exit criteria: 3 in-scope items shipped + /arib-deep-audit PASS.
  Risks: Stripe API key rotation (mitigated via env vars + KMS).
         Webhook reliability (mitigated via DLQ + replay).
  Plan: (1) checkout flow; (2) webhooks; (3) subscriptions.

Step 5 — Commit + announce
  PR-able commit landed. Branch ready.
```

### Example 2 — Architect and planner disagree on sequencing

```text
User: /arib-wave-start auth-rewrite

Architect proposes: build new flow alongside old, switch in step 3.
Planner identifies: new flow can't share schema with old; concurrent
  build means duplicate test fixtures and migration ordering risk.

Resolution path: don't pick a side; surface the conflict to the user.

Skill output:
  PLAN.md is partially populated (scope + exit criteria are agreed).
  Sequencing has a conflict — see PLAN.md "Sequencing options" section.
  Architect prefers parallel build; planner prefers cutover.
  Resolution required before work begins.

User decides → planner updates PLAN, work proceeds.
```

### Example 3 — User skips planner (wave-name only goal stated)

```text
User: /arib-wave-start cleanup

Pre-flight: wave name is too vague for a non-trivial wave.
  Skill prompts: "What does 'cleanup' include? Specifically which areas?"
  User responds with detail → re-dispatch architect+planner.

Or, if the user insists "just basic cleanup", proceed with a single
architect call (skip planner) and a thin PLAN.md. Note the deferral
in the wave's risk register so it's not invisible later.
```

## Decision tree

```
/arib-wave-start <name>
    |
    v
[Wave name valid (kebab-case, no collision)?]
    |
    +-- no  --> abort with clear error; suggest a valid name
    +-- yes --> continue
    |
    v
[Working tree clean?]
    |
    +-- no  --> warn (don't abort); offer to stash or commit
    +-- yes --> continue
    |
    v
[Goal clear enough for architect+planner to act?]
    |
    +-- no  --> ask user for refinement; do not dispatch yet
    +-- yes --> continue
    |
    v
Scaffold dir + branch
    |
    v
Dispatch architect AND planner in single Task message
    |
    v
[Both returned non-empty plans?]
    |
    +-- one empty --> ask user to refine wave goal; retry
    +-- both ok    --> merge into PLAN.md
    |
    v
[Architect and planner agree on sequence?]
    |
    +-- no  --> populate PLAN.md with both options labeled;
    |          surface conflict to user; do not pick a side
    +-- yes --> single sequence in PLAN.md
    |
    v
Commit + announce
```

## Edge cases

- **Wave goal touches regulated data.** The PLAN must cite the
  relevant compliance frameworks in `compliance/frameworks/` (GDPR for
  EU, PDPL for KSA, etc.). The planner agent should flag this in its
  risk register.

- **Wave depends on unmerged work in another wave.** Document the
  dependency in PLAN's "Dependencies" section. The wave-merge gate will
  not block on it (gates are per-wave), but the dependency may push
  the exit date.

- **The wave is a refactor with no new feature.** Set "What shipped"
  expectations correctly — the stakeholder REPORT will list reduced
  complexity, removed dead code, and improved test coverage rather
  than user-visible features.

- **The architect agent fails or returns empty.** Don't proceed with
  planner-only output — the wave's scope is the architect's domain.
  Ask the user to refine the goal and retry both.

- **The planner agent identifies a cyclic dependency.** Surface the
  cycle to the user immediately and require resolution before the wave
  starts. Cyclic plans never complete.

## Failure modes (extended)

- **Wave name collides with existing dir or branch:** abort. Pick a
  different name. Do not overwrite.
- **Architect or planner returns empty:** ask the user to refine the
  wave goal, then retry both agents.
- **Working tree dirty:** warn but allow; the wave commit will be the
  first commit on the new branch. The user may want to commit-then-
  branch or stash-then-branch instead.
- **No PLAN template found:** abort with a clear error pointing to
  `waves/.templates/PLAN.md`. The bootstrap should have installed it.
- **Goal genuinely ambiguous:** refuse to start. A wave without a
  defined goal sprawls. Better to push back than ship a broken wave.

## Related

- `waves/README.md` — wave concept and lifecycle.
- `arib-wave-end` — wave-end gate.
- `arib-deep-audit` — runs at /arib-wave-end.
- `architecture/AGENT_ARCHITECTURE.md` — parallel-dispatch governance.
- `.claude/agents/architect.md` — what to build.
- `.claude/agents/planner.md` — sequence, dependencies, risks, blockers.
