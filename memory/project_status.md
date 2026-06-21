# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v3.20.0 "Lean Core II"** (`/loop` iter 5 — the close, ADR-035): the `/arib-*` skill
table moved out of always-on CLAUDE.md §4 → `reference/SKILLS_CATALOG.md` (on-demand);
§4 keeps a pointer + category summary. Always-on **7987→7212** (UNDER 8000, ~788 headroom);
CI drift-guard pins catalog rows to VERSION. Self-hosted: 33 skills, 17 agents, 11 hooks.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 61/61 tests); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- Autonomous Synthesis-backlog campaign (v3.12→v3.20) is **COMPLETE** (scorecard:
  `io/ledger/synthesis-campaign-scorecard-2026-06-21.md`). No active backlog. No blockers.
