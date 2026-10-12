# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v4.2.1 "Mesh"** (ADR-040): self-measurement pass — no new capability, less weight and
fewer false claims. Every repo-size claim recomputed from disk (SYSTEM.md had said "96 files ·
24 directories" against a real 263/67; VERSION.json said 308/59 — wrong both ways) and now
**CI-guarded** by `validate-coherence.sh` §9, which also fails if session stubs re-accumulate.
`io/ledger/` went from 108 committed stubs (312 KB, 12% of the repo) to a 7.5 KB index, and
`stop.sh` now self-rotates via `io-archive.sh --ledger --keep 10`. README shed 77 lines of
release notes duplicating its own Version History table. Prior: v4.2.0 (plan mesh — `/arib-plan`
+ `ccm-plan.sh`, 34th skill) / v4.1.1 (registered-entity identity) / v4.0.0 relicense
MIT→PolyForm-NC (≤v3.20.0 stays MIT). Self-hosted: 34 skills, 17 agents, 11 hooks, 7 workflows,
263 files.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 61/61 tests); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- **v4.0.0 license PR open — awaiting human merge** (high-stakes legal). Synthesis campaign
  (v3.12→v3.20) COMPLETE (`io/ledger/synthesis-campaign-scorecard-2026-06-21.md`). Open
  follow-ups: contributor CLA (preserve relicensing), trademark "arib"/CCM. No blockers.
