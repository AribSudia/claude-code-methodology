# Session Notes

> Always-on handoff (lean core) — keep it SHORT. Newest session only; prior
> detail lives in `CHANGELOG.md` + `io/ledger/`. CI-freshness-gated (v3.13.0):
> must name the current line and never revert to the v1.0 bootstrap handoff.

## Session: 2026-10-12 — v4.2.1 "Mesh"

### Completed (ADR-040 — self-measurement)
- **Audited whether CCM needed a real update: it did not need a feature, it needed accuracy.**
  Found ten stale self-claims in the spec CCM polices with its own DOCS-MATCH-DISK gate —
  SYSTEM.md "96 files · 24 directories" vs a real 263/67 (stated twice), eight wrong per-dir
  tree counts, README "33 skills"/"14 scripts". VERSION.json was wrong in both directions
  (308/59), proving the numbers were never derived from disk. All corrected from measurement;
  "122 features" deleted rather than re-guessed.
- **`validate-coherence.sh` §9** now recomputes files/dirs from `git ls-files`, greps every
  `N files · N directories` claim in SYSTEM/README/CLAUDE, and caps committed ledger stubs at
  30. **All three branches mutation-tested** (fail on mutant, pass on fix).
- **Ledger rotation is a mechanism now, not a .gitignore note.** `io-archive.sh --ledger
  [--keep N]` folds stubs into `ARCHIVE-<YYYY>.md` (idempotent); `stop.sh` calls it at
  `--keep 10`. One-time roll-up: **108 stubs / 312 KB → 7.5 KB, 108 rows, zero loss.**
  Rotation proven end-to-end (13 stubs → 10 kept, 3 folded, index +3).
- Fixed a latent `set -e` bug in `io-archive.sh` (`((ARCHIVED++))` aborts on first increment).
- **README 781 → 704 lines** — cut 7 stacked v3.5–v3.8.3 release-note blocks duplicating the
  Version History table 560 lines below; onboarding block now at line 20, was line 98.

### Next session starts with
- **PR is open and intentionally NOT merged** — owner's call.
- Optional next cut, measured but untouched: `Training/` is 508 KB across 11 manuals;
  `02-AGENTS-MANUAL.md` alone is 82 KB describing 17 agents whose definitions are another
  264 KB. Likely heavy duplication — measure before cutting, separate PR.
- Carried: merge/decline the v4.1.1 PR; owner legal acts (CLA bot, SAIP trademark, counsel
  review). `reference/SKILLS_REGISTRY.md` (30 KB, external skills) still flagged stale.

### Prior (detail in CHANGELOG + io/ledger)
- **v4.2.0 (ADR-039)** plan mesh: `/arib-plan` (34th skill) + `ccm-plan.sh`, 50/50 selftest ·
  **v4.1.1 (ADR-038)** registered-entity identity · **v4.1.0 (ADR-037, #32 MERGED)** CLA bot +
  TRADEMARK · **v4.0.0 (ADR-036, #31 MERGED)** MIT→PolyForm-NC.
- v3.12→v3.20 Synthesis campaign complete. DECISIONS ADR-024…040.
