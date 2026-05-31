# Wave Plan: <wave-name>

- **Started:** <YYYY-MM-DD>
- **Owner:** <name>
- **Branch:** `wave/<wave-name>`
- **Target end:** <YYYY-MM-DD>

## Goal

<one paragraph — what does this wave accomplish for the user / business?>

## Scope

### In scope
- <bullet>

### Out of scope (explicit)
- <bullet — write down what tempted you that you're saying no to>

## Exit criteria

A wave can only end when ALL of the following are true:

- [ ] All in-scope items shipped or explicitly deferred with a recorded reason.
- [ ] `/arib-deep-audit` returns PASS.
- [ ] Stakeholder REPORT.md generated.
- [ ] No `BLOCK`-severity findings outstanding.

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| <risk> | low/med/high | low/med/high | <plan> |

## Dependencies

- <upstream changes, env config, third-party readiness>

## Execution mode (v3.6 — auto-advance)

> Read by `/arib-wave-run`. Default behavior: execute steps in order,
> **auto-advancing** from one to the next without asking for approval.
> The wave only pauses on a genuine issue or an explicit checkpoint.

- **mode:** auto-advance
- **on_failure (default):** halt
- **pause only when:** a step fails, a step is `checkpoint: true`, the
  next step is genuinely ambiguous, a blocker is hit, or the user
  interrupts. (See `bootstrap/PROTOCOL_PRINCIPLES.md` — same decisive
  discipline, applied to wave execution.)

## Steps

Each step is a unit `/arib-wave-run` executes and verifies before
auto-advancing. Keep `checkpoint: true` rare — reserve it for
irreversible or high-stakes actions (prod deploy, data migration,
sending external communications, spending money).

### Step 1: <title>
- **goal:** <what this step achieves>
- **done_when:** <verifiable completion criteria — a command, a test, a file exists>
- **checkpoint:** false
- **on_failure:** halt        # halt | retry-once | skip-and-flag

### Step 2: <title>
- **goal:** <...>
- **done_when:** <...>
- **checkpoint:** false
- **on_failure:** halt

### Step 3: <title> (example of a guarded step)
- **goal:** deploy to production
- **done_when:** health check green on the new release
- **checkpoint:** true         # irreversible/high-stakes → human gate
- **on_failure:** halt

(populated by the architect + planner agents at /arib-wave-start;
executed by /arib-wave-run)
