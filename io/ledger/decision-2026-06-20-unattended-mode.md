# Decision Ledger — Unattended Autonomy Mode (rule-17 change)

- date: 2026-06-20
- version: v3.15.0 "Unattended"
- decision-ref: ADR-030
- requested-by: Abdullah (owner), via /loop
- status: ACCEPTED & SHIPPED

## What changed

The developer plan's **rule 17 — "single human trigger / maximize auto-fire"** (stated as
based on v3.13.0 "Synthesis", rebased on v3.12.0) is re-cast — per owner directive — into
an explicit **mode of autonomous operation without intervention**:

- In **unattended mode** (`CCM_UNATTENDED=1` atop `CCM_AUTONOMY=1`) the agent runs to
  completion and **does not proactively request intervention**. Where it would have asked
  "one question on genuine ambiguity," it now **assumes-and-records** (rationale logged)
  and proceeds.
- The **"request intervention" feature fires ONLY on an explicit user command**
  (`intervene` / `pause` / `hold`, or `CCM_INTERVENE=1`).

## The floor that stays (not "intervention" — infrastructure)

Recorded so it is unambiguous: unattended mode does **not** remove —
1. Branch protection + CONSTRAINTS #17 (high-stakes merges need a human approver);
2. the autonomy guard caps (wall-clock / calls-since-commit / BLOCK-rate);
3. the fail-closed `pre-tool-use.sh` hooks.

The owner may lift floor item (1) for a specific run only by an explicit per-run override;
it is never lifted silently.

## Where it lives

- `operations/AUTONOMY_MODE.md` §9 (the canonical spec).
- `architecture/DECISIONS.md` ADR-030 (the decision record).
- This ledger entry (the registry trace requested by the owner).
