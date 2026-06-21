# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v3.19.0 "Code Graph"** (`/loop` iter 4, ADR-034): native **import graph** (rg/grep,
honest — not semantic) — `build-code-graph.sh`, `/arib-graph` (build/refresh/query),
advisory `graph-consult.sh` (PreToolUse, exit-0/no-op-when-absent), session-start
staleness note. **Zero always-on.** Self-hosted: 33 skills, 17 agents, 11 hook scripts.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 61/61 tests); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- `/loop` iter 5 (close): move always-on §4 skill table out of CLAUDE.md → `reference/`;
  final 'Plan deliverables → status in CCM' table; STOP loop. No blockers.
