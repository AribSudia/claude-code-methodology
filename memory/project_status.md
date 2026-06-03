# Project Status

> Lean by design (v3.8.0): this file is **current state only** — it loads on
> every session (always-on context), so it stays small. Full history lives in
> `CHANGELOG.md`; decisions in `architecture/DECISIONS.md`.

## Current Phase

**v3.8.0 "Lean Core"** — always-on session-start context cut from ~45.9K to
~8K tokens (82%) by moving reference docs to on-demand loading. CCM is the
methodology repo itself (self-hosted): 26 skills, 15 agents, 9 rules, 7 hook
scripts, real CI/PR governance on `main`.

## Active Milestone

Lean Core token restructure (ADR-019). Next: address the v3.8 roadmap items
in `proposals/CCM-v3.8-Roadmap.md` — `name:` frontmatter on all 26 skills,
skill-lint fold-in to `validate-coherence.sh`, the defect-class sweep.

## Current State (summary — see CHANGELOG for history)

- Enforcement: real (hooks `exit 2`, verified 37/37). 
- Self-policing: `validate-coherence.sh` + `drift-detect.sh` + 5 CI checks.
- Compliance layer: alignment-only, honest (OWASP/GDPR/ISO/SOC2/PDPL).
- Waves: start → run (auto-advance) → end (deep-audit gate).

## Blockers

- None. (Token target: 8K; current ~8K after Lean Core.)

## Next Tasks (priority order)

1. v3.8.1 — add `name:` to 26 skills + skill-lint in validate-coherence.
2. Sweep Axis-1 defect classes (step-numbering, duplicate sections, dead refs).
3. Decide `.claude/agent-memory/`: wire minimally or delete (it is dead infra).
4. Invocation telemetry hook → unlocks the telemetry-gated health KPIs.
