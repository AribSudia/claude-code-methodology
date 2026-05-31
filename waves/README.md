# Waves — Multi-session delivery overlay

A **wave** is a unit of delivery larger than a session and smaller than a
release. Typically 1–3 weeks of work toward a coherent outcome (e.g.
"payment integration", "i18n rollout", "auth rewrite"). Waves give multi-
session work shape: a plan up front, an audit at the end, a stakeholder
report that survives the work.

## Layout

```
waves/
├── README.md                 ← this file
├── WAVE_HISTORY.md           ← append-only log of every completed wave
├── .templates/
│   ├── PLAN.md               ← copied into each wave dir at /arib-wave-start
│   └── REPORT.md             ← generated at /arib-wave-end
└── <wave-name>/              ← one directory per wave
    ├── PLAN.md               ← scope, exit criteria, risk register
    └── REPORT.md             ← stakeholder-facing wave report (post-audit)
```

## Lifecycle

```text
/arib-wave-start <name>
    ├─ creates waves/<name>/ from .templates/
    ├─ creates branch wave/<name>
    ├─ dispatches architect + planner (Tier-2 parallel)
    ├─ writes initial PLAN.md with the Steps contract
    └─ offers to hand off to /arib-wave-run

/arib-wave-run            ◀ v3.6 auto-advance execution engine
    ├─ reads PLAN.md Steps (goal / done_when / checkpoint / on_failure)
    ├─ executes each step, verifies done_when, commits per step
    ├─ AUTO-ADVANCES to the next step without asking
    └─ pauses ONLY on: step failure, checkpoint:true step, genuine
       ambiguity, blocker, autonomy-guard trip, or user interrupt

(... steps flow automatically; one commit per step on wave/<name> ...)

/arib-wave-end
    ├─ runs /arib-deep-audit (21 sections)
    ├─ requires PASS verdict to continue
    ├─ generates REPORT.md from PLAN + audit + commit history
    ├─ appends one-line summary to WAVE_HISTORY.md
    ├─ commits and tags as wave/<name>/end-<audit-hash>
    └─ stages PR or merges (per project policy)
```

## Why waves matter

Without a wave concept, multi-session work has no exit gate. Sessions end,
features land, but nothing forces a structured review of "did we ship what
we said we'd ship?" Waves make that review mandatory.

The hook integration (see `architecture/CONTEXT_MAP.md` and
`.claude/hooks/pre-tool-use.sh`) blocks merges to `main` when the working
branch is a `wave/*` branch and no audit hash for the current wave exists
in `io/ledger/`.

## When NOT to use waves

- Single-session work — overhead exceeds the value.
- Hot-fixes — the gate is too slow for an incident.
- Exploratory spikes that may be thrown away — use a feature branch
  without the wave overlay.

Waves are for deliberate, multi-session, stakeholder-visible delivery. Use
them when you'd otherwise be writing a status update to a non-engineering
audience anyway.
