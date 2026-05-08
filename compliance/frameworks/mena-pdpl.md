# Saudi PDPL + NCA ECC + SDAIA AI ethics — MENA compliance

The original Item #7 scope. Maintained as its own framework doc rather
than rolled into GDPR because the requirements diverge in important ways
(data residency, Hijri/Gregorian dates, Arabic-language obligations).

## The three reference documents

1. **Saudi PDPL (Personal Data Protection Law)** — KSA's privacy law.
   Comparable to GDPR in spirit; differs in detail.
2. **NCA ECC (Essential Cybersecurity Controls)** — National Cybersecurity
   Authority baseline for KSA-deployed systems.
3. **SDAIA AI ethics principles** — Saudi Data and AI Authority guidance
   for AI/ML system development.

All three apply when:
- The platform is deployed inside the Kingdom.
- The platform serves Saudi institutional clients.
- Data subjects are KSA residents.

## PDPL — code-checkable parts

Most overlap with GDPR (right to access, erasure, rectification, consent).
Use `compliance/frameworks/gdpr.md` for those — the skill checks the same
endpoints. KSA-specific differences:

### 1. Data residency (PDPL Art. 29)

**Check:** if the project ships to Saudi clients, infra config should
declare data residency. The skill greps:

```text
- AWS region == me-south-1 / me-central-1
- GCP region == me-central1 / me-central2
- Azure region == saudiarabia*
- Or a documented exemption in CONTROLS.md
```

### 2. Privacy notice in Arabic

**Check:** if the project has a privacy notice (`privacy.md`,
`/privacy` route, `PrivacyNotice.tsx`), confirm an Arabic version exists
or the file is structured for i18n.

### 3. Hijri date support

**Check:** for institutional contexts (government, education, healthcare),
date-display code should support Hijri or dual-display.

```bash
# Skill greps for one of:
grep -rE 'hijri|umm-al-qura|toLocaleDateString.*ar-SA|dayjs.*hijri'
```

WARN if the project ships to KSA institutional clients and no Hijri support
is found.

## NCA ECC — code-checkable subset

NCA ECC is the KSA cybersecurity baseline. Most controls map to
ISO 27001 Annex A. KSA-specific items the skill checks:

- **Encryption with NCA-approved algorithms.** No DES, no 3DES, no MD5
  for sensitive data. (Already covered by OWASP A02.)
- **Audit log retention ≥ 12 months.** PDPL + NCA both require this.
  Skill checks `compliance/CONTROLS.md` declaration.
- **Network segmentation declared.** Manual.

## SDAIA AI ethics — checklist (not code-checkable)

If your project ships an AI feature, document compliance with SDAIA's
seven principles in `compliance/CONTROLS.md`:

1. Fairness
2. Privacy and security
3. Humanity
4. Social and environmental benefit
5. Reliability and safety
6. Transparency and explainability
7. Accountability

CCM cannot judge fairness or transparency; humans must. The doc just
reminds you to record the decisions.

---

## Arabic typography enforcement

This is the original Item #7 deliverable. The `arib-check-arabic` skill
audits Arabic-language UI surfaces against:

### Typography

- **Font family:** IBM Plex Arabic (preferred) or Noto Sans Arabic.
- **Pairing:** Inter or Geist for Latin text.
- **No mixed sans-serif families on a single screen.**

### Direction

- `dir="rtl"` on root containers when locale is `ar`.
- Tailwind: use `rtl:` and `ltr:` prefixes consistently.
- Icons mirror in RTL (chevrons, breadcrumb separators, progress bars).

### Numerals — explicit policy required

- Arabic-Indic: `٠ ١ ٢ ٣ ٤ ٥ ٦ ٧ ٨ ٩`
- Western Arabic: `0 1 2 3 4 5 6 7 8 9`

CCM does **not** auto-convert. Pick a policy in
`architecture/DECISIONS.md` and stick with it.

### Dates

- Dual-display Hijri + Gregorian for institutional contexts.
- ISO 8601 internally; localized at the edge.

### Punctuation

Use Arabic punctuation in Arabic strings:
- Question mark: `؟` (NOT `?`)
- Comma: `،` (NOT `,`)
- Semicolon: `؛` (NOT `;`)

The skill greps Arabic-language strings (Unicode range U+0600-U+06FF) for
Latin punctuation and warns.

### Mirroring

Icons, progress indicators, chart axes mirror in RTL. The skill checks
common icon imports for `Chevron*`, `Arrow*` and ensures a `rtl:rotate-180`
class is applied or the component is RTL-aware.

---

## The `/arib-check-arabic` skill

```bash
/arib-check-arabic                    # whole codebase
/arib-check-arabic components/checkout/
```

Outputs an alignment report covering all sections above.

---

## Severity ladder

| Finding | Severity |
|---------|----------|
| Latin punctuation in Arabic string | WARN |
| Wrong font family in Arabic content | WARN |
| Missing `dir="rtl"` on Arabic UI root | BLOCK |
| Numeral policy not declared in DECISIONS.md | INFO |
| Data residency outside KSA, KSA institutional client | BLOCK |
| No Arabic privacy notice | BLOCK on customer-facing |

---

## Related

- `compliance/frameworks/gdpr.md` — overlapping privacy controls.
- `compliance/frameworks/iso27001.md` — overlapping security controls.
- `.claude/rules/i18n-ar.md` — path-scoped rules that load on Arabic content paths.
- `.claude/skills/arib-check-arabic/SKILL.md` — the runnable audit.
- `.claude/skills/arib-docs-language/SKILL.md` — generic i18n (CJK, Indic, etc.).
