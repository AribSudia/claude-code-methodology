# Session Notes

> Always-on handoff (lean core) — keep it SHORT. Newest session only; prior
> detail lives in `CHANGELOG.md` + `io/ledger/`. CI-freshness-gated (v3.13.0):
> must name the current line and never revert to the v1.0 bootstrap handoff.

## Session: 2026-06-23 — v4.1.1 "Commercial"

### Completed (ADR-038 — commercial-doc hardening)
- 4-lens legal-doc review + CR certificate → corrected licensor to registered entity **Areeb
  Establishment for Information Technology** (Unified CR 7004791427, owner Abdullah Alzahrani,
  brand "arib.sa") across LICENSE/CLA/COMMERCIAL/TRADEMARK/README. Fixed must-fix stale "License:
  MIT" in Training/01 + added a CI license-drift guard. Added DRAFT `COMMERCIAL_LICENSE_AGREEMENT.md`,
  `LICENSE-MIT`, `PRIVACY.md`; COMMERCIAL.md examples + 30-day eval grant + VAT(15%/ZATCA) note;
  CLA v1.0 stamp + manual-verify-until-bot-enabled rule. Non-lawyer doc work — needs-lawyer items
  (binding agreement, KSA enforceability, VAT, SAIP) flagged for counsel.
- Held for human merge (legal-adjacent).

### Next session starts with
- Merge (or decline) the v4.1.1 PR. Owner legal acts: enable CLA bot, file SAIP trademark,
  counsel review of LICENSE/COMMERCIAL/agreement/CLA/PRIVACY, send the 3 placeholders
  (address/VAT/expiry). `reference/SKILLS_REGISTRY.md` refresh still flagged separately.

### Prior (detail in CHANGELOG + io/ledger)
- **v4.0.0 Licensed (ADR-036, #31 MERGED)** MIT→PolyForm-NC + CLA · **v4.1.0 Commercial
  (ADR-037, #32 MERGED)** dormant CLA bot + TRADEMARK + pricing.
- v3.12→v3.20 Synthesis campaign complete (scorecard in io/ledger). DECISIONS ADR-024…038.
