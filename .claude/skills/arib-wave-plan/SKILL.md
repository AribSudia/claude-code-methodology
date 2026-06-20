---
name: arib-wave-plan
argument-hint: "<goal>"
description: "Wave | Pre-wave requirement lock — Act 1 derives the requirements from the codebase + memory (an honest grill, not guesswork), Act 2 hands the locked plan to an independent model (Codex) to tear apart until sign-off. Produces waves/<id>/PLAN.md + PLAN-REVIEW-LOG.md. Auto-chained idempotently from /arib-wave-start. If Act 2 can't run (no Codex), the wave proceeds but HOLDS MERGE for a human. Absorbs grill-me-codex (ADR-032)."
---

# /arib-wave-plan — lock the requirements before the build

The gap this closes: `/arib-wave-start` scaffolds a plan, but nothing **adversarially
locks the requirements** before code is written. `/arib-wave-plan` is the pre-wave gate —
two acts, then a clean `PLAN.md` the wave executes against. Absorbed from grill-me-codex,
CCM-native (ADR-032).

> Normally **auto-invoked by `/arib-wave-start`** (idempotent — skips if `PLAN.md` already
> exists). Invoke directly to lock a plan before starting the wave.

## Act 1 — Grill: derive the requirements (honest, not guesswork)

Walk the design tree for `<goal>` and, for each decision, **derive the answer from ground
truth** — the codebase (use the code-graph / `/arib-graph` when present), `memory/`,
`architecture/DECISIONS.md`, and existing conventions — rather than inventing it. Record
every derived decision **with its evidence** in `PLAN.md` so the reasoning is auditable.

Posture depends on mode (see `operations/AUTONOMY_MODE.md`):
- **Default (attended):** surface the derived requirements and the open questions; confirm
  the *what* with the operator before locking.
- **Unattended mode (ADR-030):** do **not** pause — record each derived decision +
  rationale and proceed (assume-and-record). Still **escalate genuinely-unknowable
  decisions** — an external business/pricing/compliance/policy call that no amount of
  code-reading can settle — as a structured decision-list entry (same posture as
  `/arib-engine` §6.1). "Verify the claim before deciding" (CONSTRAINTS #14) applies to
  every auto-derived answer.

Act 1 output → `waves/<wave-id>/PLAN.md`: the goal, the locked requirements, each decision
+ evidence/rationale, the open decision-list (if any), and the Steps contract
(`goal`/`done_when`/`checkpoint`/`on_failure`) that `/arib-wave-run` consumes.

## Act 2 — Adversarial review: an independent model tries to break the plan

Hand the locked `PLAN.md` to an **independent** reviewer (read-only) that attacks it —
missing requirements, unhandled edge cases, wrong assumptions, security/data gaps — across
rounds until both sides sign off.

```bash
# Codex present (verified at setup): independent second model, read-only each round.
codex exec --sandbox read-only "Adversarially review waves/<id>/PLAN.md against the
codebase. List every missing requirement, wrong assumption, edge case, and
security/data-integrity gap. Be specific and cite files. Do not write code."
# → iterate: address each round's findings in PLAN.md, re-review, until Codex has no
#   material objections. Record every round (findings + resolution) in PLAN-REVIEW-LOG.md.
```

- **Codex absent → honest fallback + HOLD MERGE.** Do **not** fake a review. Record in
  `PLAN-REVIEW-LOG.md` that Act 2 was skipped (no independent model available), optionally
  run a CCM-internal second-opinion pass (`verification-agent` / a review Workflow) — but
  label it as *not independent* — and **flag the wave `merge-hold: human-review`** so its
  PRs route to a human regardless of mode. An un-independently-reviewed plan never reaches
  `main` without a human.

Act 2 output → `waves/<wave-id>/PLAN-REVIEW-LOG.md` (round-by-round findings + resolutions,
matching CCM's audit-ledger format), and the wave's `merge-hold` flag if Act 2 couldn't run.

## The merge-hold rule (enforced via the existing gate, not a new authority)

The requirement lock does not invent a new merge control — it sets a flag the existing
gate honors. A wave's PRs auto-merge only when CONSTRAINTS #17 holds **and** Act 2 signed
off; if Act 2 was skipped (Codex absent) the wave is `merge-hold: human-review`. High-stakes
classes (money/tax, auth, tenant-isolation, compliance, secrets, breaking-migration) always
hold regardless of Act 2. Branch protection still governs the actual merge.

## Auto-chain from /arib-wave-start (idempotent)

`/arib-wave-start` runs `/arib-wave-plan` as a pre-flight **before** it reads the wave
contract:
```
/arib-wave-start <goal>
  └─ PLAN.md exists?  yes → skip planning, proceed   |   no → run /arib-wave-plan (Act 1 + Act 2)
                                                          └─ Codex absent → flag merge-hold
  → /arib-wave-run (auto-advancing)  →  /arib-wave-end (close gate)
```
Idempotent: a hand-run `/arib-wave-plan` makes the chain skip straight to execution.

## Anti-patterns

Faking Act 2 when Codex is absent (log + merge-hold instead) · guessing requirements
instead of deriving them from the codebase · pausing in unattended mode on a
code-answerable question (assume-and-record) · NOT escalating a genuinely-unknowable
business/compliance decision · treating the merge-hold flag as optional on high-stakes work.
