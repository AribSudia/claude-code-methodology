---
argument-hint: "<component> --locale <code>"
description: Docs | Universal language/i18n compliance - RTL, LTR, CJK, Indic, fonts, formatting, accessibility
---

# /arib-docs-language Command

## Purpose
Verify language, localization, and script-direction compliance for any target locale or writing system.

## Trigger
User types `/arib-docs-language [component] [--locale <code>]`

Examples:
- `/arib-docs-language header --locale ar-SA`
- `/arib-docs-language user-profile --locale zh-CN`
- `/arib-docs-language checkout --locale ja`
- `/arib-docs-language all --locale he`
- `/arib-docs-language dashboard --locale hi`
- `/arib-docs-language all` ← audits all locales configured in the project

## Instructions

### Step 1: Activate LANGUAGE SPECIALIST Agent Mode
Enter universal language verification mode by reading `.claude/agents/language.md`.

Determine the **target script direction** from the locale:
- `ar`, `he`, `fa`, `ur` → RTL
- `zh`, `ja`, `ko` → CJK
- `hi`, `bn`, `ta`, `te` → Indic
- `en`, `fr`, `de`, `es`, `pt`, `tr`, `ru` → LTR
- Mixed content → Bidirectional

### Step 2: Scan for Hardcoded Strings
Search the target component for hardcoded user-facing text:
```bash
# Detect any hardcoded text (not just Arabic)
grep -rn ">[^<{]*[a-zA-Z\u0600-\u06FF\u4E00-\u9FFF\u3040-\u309F][^<{]*<" \
  --include="*.js" --include="*.tsx" --include="*.ts" --include="*.vue" \
  --include="*.jsx" --include="*.svelte" [component-path]
```

For each match found:
- Flag the hardcoded string
- Check if it should be an i18n key instead
- Verify the string exists in the target locale's translation file
- Document location and replacement needed

Expected: All user-facing text should use i18n keys like `t('key.name')` or equivalent.

### Step 3: Check Content Direction Implementation
Verify proper direction markup for the target locale:

**For RTL locales (ar, he, fa, ur):**
- Root/body has `dir="rtl"` when locale is active
- Dynamically set based on language selection
- Check: `<html dir={isRTL ? 'rtl' : 'ltr'}>`

**For CJK locales (zh, ja, ko):**
- Verify `lang` attribute is set correctly
- Check for `writing-mode` support if vertical text is needed
- Verify CJK line-break rules (`word-break: keep-all` for Korean, etc.)

**For Bidi content:**
- Check `<bdi>` / `unicode-bidi` usage for mixed-direction text
- Verify user-generated content is isolated with `dir="auto"`

### Step 4: Check CSS Logical Properties
Verify CSS uses logical properties for bidirectional support:

**Correct (logical properties):**
- `margin-inline-start` instead of `margin-left`
- `margin-inline-end` instead of `margin-right`
- `padding-inline-start` instead of `padding-left`
- `text-align: start` instead of `text-align: left`
- `inset-inline-start` instead of `left`
- `border-inline-start` instead of `border-left`

**Scan for problematic patterns:**
```bash
grep -rn "margin-left\|margin-right\|padding-left\|padding-right\|text-align:\s*left\|text-align:\s*right" \
  --include="*.css" --include="*.scss" --include="*.module.css" [component-path]
```

Document each instance that should use logical properties.

### Step 5: Check Font & Typography
Verify font support for the target locale:

| Script Group  | Required Check                                          |
|---------------|---------------------------------------------------------|
| **Arabic**    | Arabic font family, correct shaping, tashkeel rendering |
| **CJK**       | CJK font loaded, correct weight, character coverage     |
| **Indic**     | Devanagari/Bengali/Tamil font, complex ligatures        |
| **Cyrillic**  | Extended Cyrillic coverage for all target languages      |
| **Latin Ext.** | Accented characters, special glyphs (ñ, ß, ø, etc.)   |

Check:
- Font family specified in CSS for the locale
- Fallback fonts in correct priority order
- `@font-face` declarations load properly
- No font-weight issues with the target script

### Step 6: Check Number, Date, Currency Formatting
Verify locale-aware formatting using `Intl` APIs:

| Format    | What to Check                                              |
|-----------|------------------------------------------------------------|
| Numbers   | Correct digit system (Eastern Arabic ٠١٢, Devanagari ०१२) |
| Decimals  | Correct separator (comma vs. period vs. momayyez)          |
| Dates     | Correct format (DD/MM, MM/DD, YYYY年MM月DD日)               |
| Calendar  | Correct calendar system (Gregorian, Hijri, Buddhist, etc.) |
| Currency  | Correct symbol, placement, and formatting                  |
| Time      | 12-hour vs. 24-hour based on locale convention             |
| Timezone  | Correct default timezone for the target market             |

Expected: All formatting should use `Intl.NumberFormat`, `Intl.DateTimeFormat`, `Intl.DisplayNames` - never hardcoded logic.

### Step 7: Check Input & Text Processing
Verify the component handles multilingual input correctly:

- **IME Support:** Input method editors work for CJK, Indic scripts
- **Text selection:** Multi-byte characters select correctly
- **Text truncation:** Respects grapheme clusters, not byte length
- **Search/filter:** Unicode-aware comparison and sorting
- **Form validation:** Regex patterns allow target script characters
- **Placeholder text:** Translated and direction-correct
- **Max-length:** Counts graphemes, not bytes or code units

### Step 8: Check UI Layout & Mirroring
For RTL locales, verify:
- Icons with directional meaning are mirrored (arrows, back/forward)
- Icons with universal meaning are NOT mirrored (clock, search, checkmark)
- Scrollbars, sliders, progress bars reverse direction
- Tables and data grids read correctly in target direction
- Breadcrumbs, navigation flow match reading direction
- No absolute positioning that breaks in mirrored layout

For CJK locales, verify:
- Text doesn't overflow fixed-width containers (CJK chars are wider)
- Line height accommodates taller characters
- Ruby text (furigana) renders correctly for Japanese

### Step 9: Check Accessibility
Verify locale-aware accessibility:
- `lang` attribute set on elements with different-language content
- Screen reader announces text in correct language
- Keyboard navigation follows locale's reading direction
- Focus order matches visual layout for the locale
- ARIA labels are translated

### Step 10: Generate Compliance Report

**COMPLIANT**
```
✅ LANGUAGE AUDIT - COMPLIANT

Component: [component-name]
Target Locale: [locale-code] ([script-direction])
Audit Date: [date]

Findings:
- Hardcoded strings:           PASS (all use i18n keys)
- Content direction:           PASS (dir attribute correct)
- CSS logical properties:      PASS (no physical properties)
- Font & typography:           PASS (target script supported)
- Number/Date/Currency:        PASS (Intl APIs used)
- Input & text processing:     PASS (Unicode-aware)
- UI layout & mirroring:       PASS (direction-correct)
- Accessibility:               PASS (lang + ARIA correct)

Status: Ready for [locale-name] market
```

**NON-COMPLIANT**
```
❌ LANGUAGE AUDIT - NON-COMPLIANT

Component: [component-name]
Target Locale: [locale-code] ([script-direction])
Audit Date: [date]

Issues Found:

1. [CRITICAL] Hardcoded Strings:
   - File: [path], Line [n]: "[text]"
   - Action: Move to i18n translation file under key [suggested-key]

2. [HIGH] Direction Support:
   - Missing dir="rtl" on [element]
   - Action: Add dynamic dir attribute based on locale

3. [MEDIUM] CSS Physical Properties:
   - File: [path]: margin-left used instead of margin-inline-start
   - Action: Replace with CSS logical property

4. [MEDIUM] Font Loading:
   - Missing [script] font configuration
   - Action: Add font-face declaration with fallback stack

5. [LOW] Accessibility:
   - Missing lang="[code]" on [element]
   - Action: Add lang attribute for embedded content

Priority Actions:
1. [Most critical fix]
2. [Next fix]
3. [Next fix]

Re-run audit after fixes: /arib-docs-language [component] --locale [code]
```

## Supported Locales (Non-Exhaustive)

| Code   | Language       | Script    | Direction |
|--------|----------------|-----------|-----------|
| ar-SA  | Arabic (Saudi) | Arabic    | RTL       |
| ar-EG  | Arabic (Egypt) | Arabic    | RTL       |
| he     | Hebrew         | Hebrew    | RTL       |
| fa     | Persian        | Arabic    | RTL       |
| ur     | Urdu           | Arabic    | RTL       |
| zh-CN  | Chinese (Simp) | Han       | LTR       |
| zh-TW  | Chinese (Trad) | Han       | LTR       |
| ja     | Japanese       | Han+Kana  | LTR/TTB   |
| ko     | Korean         | Hangul    | LTR       |
| hi     | Hindi          | Devanagari| LTR       |
| bn     | Bengali        | Bengali   | LTR       |
| ta     | Tamil          | Tamil     | LTR       |
| th     | Thai           | Thai      | LTR       |
| ru     | Russian        | Cyrillic  | LTR       |
| en     | English        | Latin     | LTR       |
| fr     | French         | Latin     | LTR       |
| de     | German         | Latin     | LTR       |
| es     | Spanish        | Latin     | LTR       |
| pt-BR  | Portuguese     | Latin     | LTR       |
| tr     | Turkish        | Latin     | LTR       |

## Notes
- This audit ensures users of ANY locale have a proper experience
- CSS logical properties are essential for bidirectional support
- All user-visible text must be i18n compliant
- Font loading is critical for proper character display across scripts
- Regional standards (calendars, number systems, currencies) matter for UX
- Run this audit before any release targeting a new market
- For multi-locale projects, run once per locale: `/arib-docs-language all --locale ar-SA` then `/arib-docs-language all --locale zh-CN`
