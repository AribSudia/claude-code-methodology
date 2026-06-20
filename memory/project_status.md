# Project Status

> Lean by design (v3.8.0): this file is **current state only** — it loads on
> every session (always-on context), so it stays small. Full history lives in
> `CHANGELOG.md`; decisions in `architecture/DECISIONS.md`. Freshness is
> CI-enforced (v3.13.0): this file must name the current `VERSION.json` version.

## Current Phase

**v3.13.0 "Honest Memory"** — the memory subsystem now enforces its own
freshness (ADR-028): a CI gate (`validate-coherence.sh` §8) + a non-blocking
Stop-hook reminder, after an audit found the always-on handoff files frozen at
the v1.0 bootstrap. CCM is self-hosted: 27 skills, 16 agents, 9 rules, 8 hook
scripts, real CI/PR governance on `main`.

## Current State (summary — see CHANGELOG for history)

- Enforcement: real (hooks `exit 2`, 49/49 + jq fail-closed); memory freshness now gated too.
- Self-policing: `validate-coherence.sh` + `drift-detect.sh` + 5 CI checks.
- Agents: 16, incl. `verification-agent` (pre-merge intent↔implementation reconciler).
- Engine + Waves: auto-merge by default, gated on reconciliation; high-stakes always human.

## Blockers

- None. (Token target: 8K; current ~7.9K, under budget.)

## Next Tasks (priority order)

1. (Optional P2) generated `memory/INDEX.md` + memory-lint for required sections.
2. (Optional P2) parallel-session conflict aggregation for the global memory files.
3. Wire the health KPIs (agent coverage, per-skill usage) into a report from `invocations.jsonl`.
