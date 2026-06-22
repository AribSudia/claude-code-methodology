# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v4.1.0 "Commercial"** (ADR-037): hardens the commercial program — CLA-enforcement workflow
`.github/workflows/cla.yml` (dormant until `CLA_ENABLED=true`), `TRADEMARK.md` (arib/CCM marks;
usage policy, not a registration), README commercial/pricing section. Prior: **v4.0.0 Licensed**
(ADR-036) relicensed MIT → PolyForm Noncommercial 1.0.0 for v4.0.0+ (free noncommercial; paid
commercial via licensing@arib.sa; ≤v3.20.0 stays MIT) + CLA. Self-hosted: 33 skills, 17 agents,
11 hooks, 6 workflows.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 61/61 tests); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- **v4.0.0 license PR open — awaiting human merge** (high-stakes legal). Synthesis campaign
  (v3.12→v3.20) COMPLETE (`io/ledger/synthesis-campaign-scorecard-2026-06-21.md`). Open
  follow-ups: contributor CLA (preserve relicensing), trademark "arib"/CCM. No blockers.
