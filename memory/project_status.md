# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v3.17.0 "Requirement Lock"** (`/loop` backlog iter 2): `/arib-wave-plan` —
pre-wave grill (derive requirements from code) + Codex adversarial review,
auto-chained from `/arib-wave-start`, merge-hold if no Codex. ADR-032.
Self-hosted: 31 skills, 17 agents, 9 rules, 8 hook scripts, CI/PR on `main`.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 49/49); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- `/loop` STAGE: rtk hook, native code-graph (`/arib-graph`), Ponytail; `/arib-wave-plan`.
  DEFER: ECC repo cherry-picks (need repo+license). No blockers.
