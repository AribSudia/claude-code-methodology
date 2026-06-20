# Project Status

> Lean by design — **current state only** (always-on; history → `CHANGELOG.md`,
> decisions → `DECISIONS.md`). Freshness CI-enforced (ADR-028): must name the
> current `VERSION.json` version.

## Current Phase

**v3.14.0 "Engineering Manager"** — CCM gains a conductor: the `engineer-manager`
agent (ADR-029) commands the 16 specialists via `/arib-build` (decompose →
dispatch → integrate → reconcile). Extracted from the developer "Synthesis"
plan; external-tool absorptions staged/deferred (honesty principle). Self-hosted:
28 skills, 17 agents, 9 rules, 8 hook scripts, CI/PR governance on `main`.

## Current State (summary — see CHANGELOG for history)

- Team: 17 agents, now *commanded* — `engineer-manager` is the only `Task`-holder; merge authority unchanged (CONSTRAINTS #17/#18).
- Enforcement: hooks `exit 2` (49/49 + jq fail-closed); memory freshness gated (ADR-028).
- Self-policing: `validate-coherence.sh` + `drift-detect.sh` + 5 CI checks.
- Engine + Waves + Build: auto-merge gated on reconciliation; high-stakes always human.

## Blockers

- None. (Token target: 8K; current ~7.9K, under budget.)

## Next Tasks

- STAGE tier when tools arrive (rtk hook, native code-graph, Ponytail); DEFER ECC
  cherry-picks (need repo+license). Optional: `/arib-wave-plan` requirement-lock,
  health KPIs from `invocations.jsonl`, `memory/INDEX.md`.
