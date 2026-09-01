# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v4.2.0 "Mesh"** (ADR-039): plans become executable graphs that outlive a session.
`scripts/ccm-plan.sh` + `/arib-plan` (34th skill) import the live Claude Code plan panel — or any
markdown plan — into a dependency-aware task graph stored off the working tree
(`$(git rev-parse --git-common-dir)/ccm-plan`), so **every worktree's session shares one mesh**:
parallel **lanes** as write-collision mutexes, atomic claiming, specialist routing, durable
inter-session mail + live `SendMessage` handoff. Session protocol STEP 0b now reports it, so a new
session joins running work instead of re-planning it. 38-case selftest, CI-gated. Prior: v4.1.1
(registered-entity identity + commercial-doc hardening) / v4.1.0 (CLA bot dormant + TRADEMARK) /
v4.0.0 relicense MIT→PolyForm-NC (≤v3.20.0 stays MIT). Self-hosted: 34 skills, 17 agents, 11 hooks,
7 workflows.

## Current State

- Team of 17 *commanded* by `engineer-manager` (only `Task`-holder); merge authority
  unchanged (#17/#18). Enforcement real (hooks exit 2, 61/61 tests); memory freshness gated.
  Engine/Waves/Build auto-merge gated on reconciliation, high-stakes always human.

## Next Tasks

- **v4.0.0 license PR open — awaiting human merge** (high-stakes legal). Synthesis campaign
  (v3.12→v3.20) COMPLETE (`io/ledger/synthesis-campaign-scorecard-2026-06-21.md`). Open
  follow-ups: contributor CLA (preserve relicensing), trademark "arib"/CCM. No blockers.
