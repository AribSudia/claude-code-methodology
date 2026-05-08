# Arabic / RTL rules

> **Scope:** loads when the working file path matches `**/locales/ar/**`,
> `**/i18n/ar/**`, `**/ar.json`, `**/messages.ar.*`, or any file containing
> Unicode Arabic text (U+0600-U+06FF).

When working with Arabic content:

1. **Typography:** Latin paired with Arabic must be Inter/Geist + IBM Plex
   Arabic (or Noto Sans Arabic). Don't introduce a third sans-serif family.

2. **Direction:** root containers for Arabic content must have `dir="rtl"`.
   Tailwind: use `rtl:` / `ltr:` prefixes consistently — don't hand-roll
   direction logic.

3. **Numerals:** the project must have a declared policy
   (Arabic-Indic ٠١٢٣ vs Western Arabic 0123). Default: Western Arabic for
   technical content, Arabic-Indic for prose. Whichever you pick, document
   in `architecture/DECISIONS.md` and apply consistently.

4. **Punctuation in Arabic strings:** use Arabic punctuation, not Latin.
   - `؟` not `?`
   - `،` not `,`
   - `؛` not `;`

5. **Dates:** for institutional contexts (government, education, healthcare),
   provide dual-display Hijri + Gregorian. Otherwise Gregorian is fine.

6. **Icons mirror in RTL:** chevrons, arrows, progress indicators, chart
   axes. Add `rtl:rotate-180` or use RTL-aware icon components.

7. **Hard-coded English in Arabic UI:** flag and replace. Translation keys
   missing from `ar.json` are a bug.

8. **Compliance overlap:** Saudi institutional projects also have PDPL
   data-residency, NCA ECC, and SDAIA AI ethics obligations — see
   `compliance/frameworks/mena-pdpl.md`.

The `/arib-check-arabic` skill audits all of the above.
