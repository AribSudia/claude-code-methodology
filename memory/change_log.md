# Change Log

> Newest on top. Condensed — one line per release; full detail in `CHANGELOG.md`
> and `architecture/DECISIONS.md`. (Backfilled 2026-06-20 after the memory audit
> found this file frozen at the v1.0 entry; freshness is now CI-gated.)

## 2026-06-20

- **v3.13.0 "Honest Memory"** — memory-freshness CI gate + Stop-hook reminder;
  backfilled the always-on handoff files; semantic layer reframed (grep default,
  claude-mem opt-in); §2.3/file-count contradictions reconciled. ADR-028.
- **v3.12.0 "Reconcile"** — `verification-agent` (16th) reconciles discovered↔fixed
  pre-merge; `/arib-engine` + Waves auto-merge by default gated on reconciliation;
  Waves reference-based dynamic loop; drill-deeper fetcher. ADR-027.
- **v3.11.0 "Engine"** — adopted AEPG as `/arib-engine` (27th skill); folded
  adversarial find→refute→confirm into deep-audit; constraints #14–#17. ADR-026.
- **v3.10.0 "Integrity"** — six-agent audit; hooks fail CLOSED; `validate-system.sh`
  rewritten dynamic; docs-match-disk sweep; dead infra removed. ADR-025.
- **v3.9.x "Live Update"** — `ccm-fetch.sh` pulls CCM from GitHub (install +
  upgrade); curl one-liner universal entry; 2-step fetch/merge. ADR-024.

## 2026-05–06 (condensed)

- v3.5–v3.8.4: CI/PR subsystem + `ci-pr-engineer` (ADR-013); decisive bootstrap
  protocols + PROTOCOL_PRINCIPLES (ADR-014); wave auto-advance (ADR-015);
  enforcement made real — `block()` `exit 2`, agent frontmatter (ADR-016/017);
  Lean Core 45.9K→7.4K always-on (ADR-019); skill `name:` conformance,
  migration "From Any System", one-prompt entry, dead `agent-memory/` removed
  (ADR-020/021/022); invocation telemetry + upgrade Phase 1.6 (ADR-023).

## 2026-04-15

### [chore]: Initialize Claude Code Methodology v1.0
- Created: Complete 4-layer architecture system
- Created: 40+ interconnected files across 10 directories
- Established: Universal methodology for AI-assisted development
- Ready: Bootstrap protocol for project instantiation
- System: CLAUDE.md, Memory, Agents, Skills, Hooks, Architecture, Implementation, Operations, Commands, Bootstrap

---

> New entries are appended at the top of this file.
> Condense entries older than the last few releases into this file's summary lines (no auto-rotation — v3.13.0).
