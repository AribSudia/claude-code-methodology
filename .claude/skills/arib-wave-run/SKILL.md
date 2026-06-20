---
name: arib-wave-run
argument-hint: "[<wave-name> | --from <step-number>]"
description: "Wave | Execute wave steps as a reference-based dynamic loop — auto-advance, per-step + wave-level reconciliation (verification-agent: objective ↔ achieved), re-engineer on GAP, AUTO-MERGE on RECONCILED by default (--hold-merge / high-stakes hold for a human)"
---

# Wave Run — /arib-wave-run

## Overview

The **execution engine** for a wave. Reads `waves/<name>/PLAN.md`,
executes each step in order, and **auto-advances** from one step to the
next without asking for approval. The wave pauses only on a genuine
issue or an explicit `checkpoint: true` step.

This is the "fetcher" — once a wave is running, CCM fetches and begins
the next step automatically. You don't get asked "should I continue?"
after every step. You get asked only when a decision is genuinely
yours to make.

This skill applies the v3.5.1 decisive-protocol discipline (see
`bootstrap/PROTOCOL_PRINCIPLES.md`) to wave execution: don't stop when
the right action is determinable; don't present a continue/stop menu
between steps; act and report.

## Lifecycle position

```
/arib-wave-start <name>   → scaffolds dir, branch, PLAN.md (architect + planner)
/arib-wave-run            → executes PLAN steps with auto-advance   ◀ THIS SKILL
/arib-wave-end            → deep-audit gate, REPORT, audit-hash tag
```

## When to Use

- Right after `/arib-wave-start`, once you've reviewed the generated
  PLAN.md and are ready to build.
- To resume a partially-executed wave (`--from <step>`).
- Inside an autonomy-mode session (`CCM_AUTONOMY=1`) — auto-advance and
  the autonomy guard compose: steps flow automatically, and the guard's
  caps (wall-clock, calls-since-commit, BLOCK-rate) still apply.

## Usage

```bash
/arib-wave-run                    # execute current wave from step 1
/arib-wave-run payment-integration # execute a named wave
/arib-wave-run --from 3           # resume from step 3 (skip 1-2)
/arib-wave-run --hold-merge       # validate + re-engineer, but hold merge for a human
```

## The wave as a reference-based dynamic loop (v3.12.0)

A wave is the **reference-based** cousin of the `/arib-engine` loop. Where the
engine *discovers* its own backlog, a wave's `PLAN.md` **is** the reference —
the success contract. The execution is a self-correcting loop, not a one-shot
pass:

```
        ┌──────────────────────────────────────────────────────┐
        ▼                                                        │
  build step → gates (done_when) → RECONCILE (verification-agent) │
        │                              │                          │
        │                       GAP → re-engineer ────────────────┘
        │                              │
        │                       RECONCILED → next step
        ▼
  all steps done → WAVE-LEVEL reconcile (objective ↔ achieved, composed-trunk)
        │                              │
        │                       GAP → re-engineer the gap ──┐
        │                                                    │ (re-validate)
        │                       RECONCILED → wave-end + AUTO-MERGE (default)
        ▼                       HOLD → human (high-stakes / opt-out)
```

The loop is **dynamic and adaptive**: each GAP verdict lists the specific unmet
criteria, so the next pass targets them rather than blindly retrying — and it's
bounded (2 non-converging rounds → escalate). `PLAN.md` stays the single source
of truth throughout; the loop runs until the plan's exit-criteria are evidenced,
then merges. (Contrast `/arib-engine`, whose loop runs until a *discovered*
backlog is exhausted.)

## The auto-advance contract

After a step completes successfully, **fetch and begin the next step
immediately**. Do NOT emit "Step N done. Shall I continue to Step N+1?"
— that question is forbidden by this skill (it's the
`PROTOCOL_PRINCIPLES.md` Rule 2 anti-pattern applied to waves).

Report each step's outcome in a running log, then move on. The human
sees progress; the human is not a gate between every step.

### The ONLY reasons to pause

1. **Step failed.** `done_when` not met, a test failed, a command
   errored, a hook returned BLOCK. Honor the step's `on_failure`:
   - `halt` (default) — stop, report the failure, await the user.
   - `retry-once` — retry the step exactly once; if it fails again, halt.
   - `skip-and-flag` — record the failure, mark the step SKIPPED, and
     auto-advance to the next step (only for genuinely optional steps).
2. **Checkpoint step.** The step has `checkpoint: true` (irreversible /
   high-stakes: prod deploy, data migration, external send, spending
   money). Pause, summarize what's about to happen, await explicit go.
3. **Genuine ambiguity.** The next step requires a decision CCM cannot
   determine from PLAN.md, the codebase, or memory. Ask ONE specific
   question — never a numbered continue/stop menu.
4. **Blocker.** A missing dependency, an external wait, a locked
   resource. Report the blocker and what's needed to clear it.
5. **Autonomy guard trip.** In `CCM_AUTONOMY=1`, if the guard blocks
   (wall-clock cap, calls-since-commit cap, BLOCK-rate cap), the wave
   pauses per the guard's message.
6. **User interrupt.** The user says stop.
7. **Reconciliation HOLD.** `verification-agent` (Step c2 / Step N+1) returns
   HOLD — a high-stakes class (money/auth/compliance/secrets/migration) or
   non-convergence after 2 GAP rounds. Pause for the human.

A reconciliation **GAP** is NOT a pause — it loops back to re-engineer the
step/build against the listed gaps, then re-validates. Anything else → keep
advancing.

## Protocol

### Step 0 — Pre-flight

```text
1. Determine wave name:
   - argument provided → use it
   - else → derive from current branch (wave/<name>)
   - neither → abort: "not on a wave branch; pass a wave name or run
     /arib-wave-start first"
2. Verify waves/<name>/PLAN.md exists. If not, abort with pointer to
   /arib-wave-start.
3. Verify the branch is wave/<name>. If on a different branch, offer to
   checkout (determinable — do it, don't ask) unless the tree is dirty.
4. Parse the Steps section: ordered list of {title, goal, done_when,
   checkpoint, on_failure}.
5. Echo the execution plan: N steps, which are checkpoints, estimated
   order. Then BEGIN — do not wait for "go" unless step 1 is a
   checkpoint.
```

### Step 1..N — The execution loop

For each step S in order (starting at `--from` if provided):

```text
a. Announce: "▶ Step <i>/<N>: <title>"
b. Execute the work to achieve S.goal. Use the right specialist agent
   where appropriate (per AGENT_ARCHITECTURE.md):
     - code work → implement directly or dispatch
     - review → code-reviewer (or parallel fan-out for big diffs)
     - tests → test-engineer
     - schema/migration → database-guardian
c. Verify S.done_when:
     - run the named command / test / file check
     - if it passes → gates PASS (internal correctness proven)
     - if it fails → honor S.on_failure (halt | retry-once | skip-and-flag)
c2. RECONCILE the step (reference-based): dispatch `verification-agent` (wave
    scope, this step) to check S.goal ↔ what was actually built —
    `done_when` green proves the gate ran, not that the step's GOAL was met.
     - RECONCILED → step PASS, advance
     - GAP → re-engineer THIS step against the listed gaps, re-run (c), re-run
       (c2). Bounded: after 2 non-converging GAPs, escalate (treat as halt).
     - HOLD (high-stakes / ambiguous) → pause for the human
d. Commit the step's work:
     git commit -m "feat(wave/<name>): step <i> — <title>"
     (one commit per step keeps the autonomy guard's calls-since-commit
      counter healthy and the wave history granular)
e. Log the outcome to the running progress report.
f. Is S a checkpoint, or is S+1 a checkpoint?
     - S is checkpoint and not yet approved → (handled before S ran)
     - S+1 is checkpoint → pause AFTER this step, summarize S+1, await go
     - neither → AUTO-ADVANCE to S+1 immediately
g. Repeat.
```

### Step N+1 — Wave-level reconciliation, then close (auto-merge by default)

When the last step completes (or all remaining steps are SKIPPED/done), run the
**wave-level reconciliation** — the dynamic validate → re-engineer loop:

```text
1. Dispatch verification-agent (WAVE scope): reconcile the wave's OBJECTIVE +
   every step's done_when/exit-criteria (PLAN.md is the reference) against what
   the composed wave branch actually achieved. Re-run the COMPOSED-trunk gate
   (not just per-step green).
2. On the verdict:
   - RECONCILED → the wave met its objective. AUTO-RUN /arib-wave-end, which
     writes the deep-audit hash and AUTO-MERGES (default — see below).
   - GAP → re-engineer the build against the listed gaps (loop back into the
     relevant step), then re-run this wave-level reconciliation. Adaptive:
     each pass targets the specific unmet criteria, not a blind retry.
   - HOLD → pause for the human (high-stakes class, or non-convergence after
     2 wave-level GAP rounds).
```

**Merge mode — AUTO by default (v3.12.0).** The wave is reference-based: its
PLAN *is* the success contract, so when `verification-agent` confirms the
objective is met and the composed trunk is green, closing+merging is the
evidence-driven default — wave-end runs automatically and auto-merges.

- **Client opt-out** — `/arib-wave-run --hold-merge` (or a `hold_merge: true`
  PLAN flag) keeps wave-end as an explicit human gate: validate, report
  "ready to merge," and stop.
- **High-stakes carve-out (always)** — if the wave touches money/auth/
  compliance/secrets/breaking-migration, wave-end holds for a human regardless
  of mode (CONSTRAINTS #17). Branch protection still governs the actual merge.

Rationale (updated v3.12.0): auto-advance flows *within* the build steps; the
*close* is no longer a blind human gate but an **intelligent** one — the
wave-validator decides merge-vs-re-engineer on evidence, and only genuine
human-class decisions (high-stakes / opt-out) stop the flow.

## Running progress report format

```text
Wave: payment-integration  (5 steps)

▶ Step 1/5: Stripe client + env wiring
  done_when: `npm test -- stripe.test.ts` green
  → PASS (committed 3a1f9c2)
▶ Step 2/5: Checkout session endpoint
  done_when: POST /api/checkout returns 200 in integration test
  → PASS (committed 7b2e4d8)
▶ Step 3/5: Webhook handler + signature verify
  done_when: webhook integration test green
  → FAIL: signature verify rejects valid test payload
  on_failure: halt
  ⏸ PAUSED — see failure detail below. Fix and re-run with --from 3.
```

## Examples

### Example 1 — Clean multi-step run, full auto-advance

```text
User: /arib-wave-run payment-integration

Pre-flight: PLAN has 5 steps, step 5 (prod deploy) is checkpoint:true.
Beginning. Steps 1-4 auto-advance.

▶ 1/5 Stripe client + env       → PASS (commit 3a1f9c2) → advancing
▶ 2/5 Checkout endpoint         → PASS (commit 7b2e4d8) → advancing
▶ 3/5 Webhook handler           → PASS (commit 9c4a1e0) → advancing
▶ 4/5 Subscription mgmt         → PASS (commit b2f7d33) → advancing
⏸ 5/5 Prod deploy is a CHECKPOINT.
      About to: deploy release v1.4 to production, run canary.
      This is irreversible. Reply "go" to proceed.

(no "shall I continue?" appeared between steps 1-4 — that's the point)
```

### Example 2 — Step fails, halt, resume

```text
User: /arib-wave-run

▶ 1/4 → PASS → advancing
▶ 2/4 → FAIL: done_when `npm run e2e` exited 1 (2 specs failing)
       on_failure: halt
⏸ PAUSED at step 2. Failure detail:
   - checkout.e2e.ts: expected 200, got 500 (missing STRIPE_SECRET)
   Recommended fix: set STRIPE_SECRET in test env.

User: (fixes env) /arib-wave-run --from 2

▶ 2/4 → PASS (commit ...) → advancing
▶ 3/4 → PASS → advancing
▶ 4/4 → PASS → reconcile (objective met) → /arib-wave-end auto-merges (RECONCILED)
```

### Example 3 — skip-and-flag for an optional step

```text
PLAN step 3 has on_failure: skip-and-flag (it's an optional perf
optimization, not load-bearing).

▶ 3/5 Add Redis cache layer → FAIL: Redis not available in this env
       on_failure: skip-and-flag
   ⚠ SKIPPED step 3, flagged in wave report. Auto-advancing to step 4.
▶ 4/5 → PASS → advancing
```

### Example 4 — ambiguity pause (one question, not a menu)

```text
▶ 3/5 Choose session store
   PLAN says "wire session storage" but doesn't specify backend, and
   the codebase has neither Redis nor a DB session table yet.
   This is genuinely undeterminable.

⏸ One question: session store — Redis (fast, needs new infra) or
   Postgres table (reuses existing DB, slightly slower)?

(NOT: "1. Redis 2. Postgres 3. Skip 4. Let me decide later" — a single
 specific question with the trade-off, per PROTOCOL_PRINCIPLES Rule 2.)
```

## Decision tree

```
/arib-wave-run [name|--from N]
    |
    v
Pre-flight (wave name, PLAN exists, on correct branch)
    |
    v
Parse Steps → ordered list
    |
    v
For each step S (from N):
    |
    +-- S.checkpoint == true AND not approved?
    |       yes → PAUSE, summarize, await "go"
    |       no  → continue
    |
    v
   Execute S.goal
    |
    v
   Verify S.done_when (gates)
    |
    +-- pass → RECONCILE step (verification-agent, wave scope): S.goal ↔ built
    |          |
    |          +-- RECONCILED → commit; log PASS
    |          |        +-- next step is checkpoint? → finish S, PAUSE before next
    |          |        +-- else → AUTO-ADVANCE
    |          +-- GAP  → re-engineer this step (bounded: 2 non-converging → halt)
    |          +-- HOLD → PAUSE (high-stakes / ambiguous)
    |
    +-- fail → honor on_failure:
               halt          → PAUSE, report, await
               retry-once    → retry; pass→advance, fail→halt
               skip-and-flag → log SKIPPED, AUTO-ADVANCE
    |
    v
All steps done → WAVE-LEVEL reconcile (verification-agent: objective ↔ achieved,
                 composed-trunk green)
    |
    +-- RECONCILED → /arib-wave-end → AUTO-MERGE (default)
    |               (held for a human if --hold-merge OR high-stakes class)
    +-- GAP        → re-engineer the gap, re-validate (bounded: 2 rounds → HOLD)
    +-- HOLD       → human
```

## Edge cases

- **PLAN has no Steps section (old-format wave):** fall back to the
  "Plan (high-level)" numbered list, treat each as a step with
  `done_when: <agent judges completion>`, `checkpoint: false`,
  `on_failure: halt`. Warn that the wave predates v3.6 and recommend
  regenerating PLAN with the step contract.
- **A step's work is itself large enough to be a wave:** that's a
  planning smell. Don't recursively start a sub-wave; flag it and
  recommend the user split the wave at `/arib-wave-start` time.
- **All steps are checkpoints:** the wave has no auto-advance benefit;
  it behaves like the old ask-between-every-step flow. Fine, but note
  it — usually a sign the checkpoints are over-applied.
- **`--from N` beyond the last step:** abort with "wave already at or
  past step N; run /arib-wave-end to close."
- **Dirty working tree at pre-flight:** if resuming, the dirty state
  may be the in-progress step's work. Don't auto-checkout; ask whether
  to commit current work as the step or stash it.
- **Autonomy guard trips mid-flow:** the guard's BLOCK message is the
  pause reason. Report it; the wave is suspended until the guard
  condition clears (commit, time window, etc.).

## Failure modes

- **Step verification command not specified (`done_when` vague):**
  the agent judges completion conservatively; if it can't verify,
  treat as a checkpoint (pause) rather than silently advancing on an
  unverified step. An unverifiable step is an ambiguity, not a pass.
- **Commit fails (pre-commit hook BLOCK):** that's a step failure;
  honor on_failure. The hook block detail goes in the pause report.
- **Wave branch diverged from main mid-flow:** keep building on the
  wave branch; the divergence resolves at /arib-wave-end via the
  merge gate. Don't auto-rebase.
- **User interrupts mid-step:** stop cleanly; the partial step is
  uncommitted; report exactly where the wave stands so `--from` can
  resume precisely.

## How this respects the methodology's principles

- **Decisive (v3.5.1):** no continue/stop menus between steps; act on
  what's determinable, ask only the genuinely-yours decisions.
- **Honest:** an unverifiable step is paused, not falsely marked PASS.
- **Auditable:** one commit per step; the running report is preserved;
  `/arib-wave-end` audits the whole wave.
- **Safe:** checkpoints gate irreversible actions; the autonomy guard's
  caps still apply; merge is reconciliation-gated — auto on RECONCILED, held for high-stakes/--hold-merge.

## Related

- `waves/README.md` — wave concept and lifecycle.
- `.claude/skills/arib-wave-start/SKILL.md` — opens the wave, generates PLAN.
- `.claude/skills/arib-wave-end/SKILL.md` — the end gate (deep-audit + merge).
- `waves/.templates/PLAN.md` — the step contract this skill executes.
- `bootstrap/PROTOCOL_PRINCIPLES.md` — the decisive discipline this extends.
- `.claude/hooks/autonomy-guard.sh` — caps that still apply during auto-advance.
- `architecture/AGENT_ARCHITECTURE.md` — which agents to dispatch per step.
- `architecture/DECISIONS.md` ADR-015 — the decision record for auto-advance.
