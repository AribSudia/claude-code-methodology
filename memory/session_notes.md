# Session Notes

> Always-on handoff (lean core) — keep it SHORT. Newest session only; prior
> detail lives in `CHANGELOG.md` + `io/ledger/`. CI-freshness-gated (v3.13.0):
> must name the current line and never revert to the v1.0 bootstrap handoff.

## Session: 2026-06-22 — v4.0.0 "Licensed"

### Completed (ADR-036 — relicense)
- Relicensed **MIT → PolyForm Noncommercial 1.0.0** for v4.0.0+ (canonical text fetched from
  polyformproject.org via gh). Free for noncommercial; commercial needs a paid license. Added
  `COMMERCIAL.md` (terms + licensing@arib.sa). v3.20.0 and earlier stay MIT. Synced
  LICENSE/VERSION/SYSTEM/README/CLAUDE/CHANGELOG; added LICENSE+COMMERCIAL.md to CONTEXT_MAP
  allow-list. Sole-copyright-holder relicense; no vendored third-party code.
- **Ships via PR, HELD for human merge** (legal/compliance high-stakes, #17) — not auto-merged.

### Next session starts with
- Merge (or decline) the v4.0.0 license PR. Open follow-ups: contributor CLA, trademark
  "arib"/CCM. `reference/SKILLS_REGISTRY.md` external-catalog refresh still flagged separately.

### Prior
- v3.12→v3.20 Synthesis campaign complete (scorecard in io/ledger). DECISIONS ADR-024…036.
