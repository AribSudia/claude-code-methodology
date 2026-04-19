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

## RTL vs LTR Comprehensive Checklist

### HTML/DOM Level

| Element | RTL Check | LTR Check |
|---------|-----------|-----------|
| `<html>` | `dir="rtl"` set | `dir="ltr"` or omitted |
| `<body>` | Inherits from html or explicit | Inherits from html or omitted |
| Language attribute | `lang="ar"` or `lang="ar-SA"` | `lang="en"` or `lang="en-US"` |
| Input/form elements | `dir="auto"` for user input | `dir="ltr"` or omit |
| Embedded content | Nested lang attribute if different | lang attribute if needed |

### CSS Logical Properties Reference

Replace physical properties with logical equivalents for bidirectional support:

**Margins:**
```css
/* Physical (problematic in RTL) */
margin-left: 1rem;       /* RIGHT in RTL */
margin-right: 1rem;      /* LEFT in RTL */

/* Logical (correct) */
margin-inline-start: 1rem;    /* Always left in LTR, right in RTL */
margin-inline-end: 1rem;      /* Always right in LTR, left in RTL */
```

**Padding:**
```css
/* Physical */
padding-left: 20px;
padding-right: 20px;

/* Logical */
padding-inline-start: 20px;
padding-inline-end: 20px;
```

**Text Alignment:**
```css
/* Physical */
text-align: left;   /* WRONG in RTL */
text-align: right;  /* WRONG in LTR */

/* Logical */
text-align: start;  /* Left in LTR, right in RTL */
text-align: end;    /* Right in LTR, left in RTL */
```

**Borders:**
```css
/* Physical */
border-left: 2px solid red;
border-right: 2px solid blue;

/* Logical */
border-inline-start: 2px solid red;
border-inline-end: 2px solid blue;
```

**Positioning:**
```css
/* Physical */
left: 10px;
right: 10px;

/* Logical */
inset-inline-start: 10px;  /* Left in LTR, right in RTL */
inset-inline-end: 10px;    /* Right in LTR, left in RTL */
```

**Width/Height on blocks:**
```css
/* Physical block offset */
left: 0;
top: 0;

/* Logical equivalent */
inset: 0;  /* All sides */
inset-inline-start: 0;  /* Start of line */
inset-block-start: 0;   /* Top of block */
```

## i18n Key Naming Conventions

**Standard hierarchy for translation keys:**
```
feature.section.action.description

Examples:
├─ navigation
│  ├─ menu.home
│  ├─ menu.about
│  ├─ menu.contact
│  └─ breadcrumb.separator
├─ user
│  ├─ profile.title
│  ├─ profile.email.label
│  ├─ profile.email.error.required
│  └─ profile.save.button
├─ forms
│  ├─ login.title
│  ├─ login.email.label
│  ├─ login.email.error.invalid
│  ├─ login.password.label
│  ├─ login.password.error.weak
│  └─ login.submit.button
└─ errors
   ├─ http.404.title
   ├─ http.404.message
   ├─ http.500.title
   └─ http.500.message
```

**Avoid:**
- Generic keys: `label.1`, `text.2`, `msg` (unscalable)
- Concatenated keys: `title_subtitle_desc` (hard to translate)
- Feature duplication: `user_profile_title` and `admin_profile_title` (use context instead)

**Do use:**
- Contextual nesting: `pages.settings.profile.title`
- Semantic naming: `validation.email.invalid`
- Feature-scoped keys: `checkout.payment.method.label`

## Number/Date/Currency Formatting by Locale Examples

### Number Formatting

**JavaScript using Intl.NumberFormat:**
```javascript
const num = 1234567.89;

// US English
new Intl.NumberFormat('en-US').format(num);
// Output: 1,234,567.89

// German (dot for thousands, comma for decimal)
new Intl.NumberFormat('de-DE').format(num);
// Output: 1.234.567,89

// Arabic (Eastern Arabic numerals)
new Intl.NumberFormat('ar-SA').format(num);
// Output: 1,234,567.89 (with Eastern Arabic digits)

// Indian English (lakh/crore system)
new Intl.NumberFormat('en-IN').format(num);
// Output: 12,34,567.89
```

**Python:**
```python
import babel.numbers

locale.format_number(1234567.89, locale='en_US')
# 1,234,567.89

locale.format_number(1234567.89, locale='de_DE')
# 1.234.567,89

locale.format_number(1234567.89, locale='ar_SA')
# 1,234,567.89 (with Eastern Arabic script)
```

### Date Formatting

**JavaScript:**
```javascript
const date = new Date('2026-04-19');

// US: MM/DD/YYYY
new Intl.DateTimeFormat('en-US').format(date);
// 4/19/2026

// German: DD.MM.YYYY
new Intl.DateTimeFormat('de-DE').format(date);
// 19.4.2026

// Arab: DD/MM/YYYY
new Intl.DateTimeFormat('ar-SA').format(date);
// 19/4/2026

// Chinese: YYYY年MM月DD日
new Intl.DateTimeFormat('zh-CN', {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
}).format(date);
// 2026年4月19日

// Japanese: YYYY年MM月DD日
new Intl.DateTimeFormat('ja-JP').format(date);
// 2026/4/19

// With time
new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hour12: true
}).format(date);
// Apr 19, 2026, 12:00:00 AM (12-hour format)

new Intl.DateTimeFormat('de-DE', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  hour12: false
}).format(date);
// 19. Apr 2026, 00:00 (24-hour format)
```

### Currency Formatting

**JavaScript:**
```javascript
const amount = 1234.56;

// US Dollar
new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
}).format(amount);
// $1,234.56

// Euro (Germany uses comma for decimal)
new Intl.NumberFormat('de-DE', {
  style: 'currency',
  currency: 'EUR'
}).format(amount);
// 1.234,56 €

// British Pound
new Intl.NumberFormat('en-GB', {
  style: 'currency',
  currency: 'GBP'
}).format(amount);
// £1,234.56

// Saudi Riyal (symbol after number, RTL context)
new Intl.NumberFormat('ar-SA', {
  style: 'currency',
  currency: 'SAR'
}).format(amount);
// 1,234.56 ر.س.

// Indian Rupee
new Intl.NumberFormat('en-IN', {
  style: 'currency',
  currency: 'INR'
}).format(amount);
// ₹1,234.56

// Japanese Yen (no decimal places)
new Intl.NumberFormat('ja-JP', {
  style: 'currency',
  currency: 'JPY'
}).format(amount);
// ￥1,235 (rounded up, no decimals)

// Chinese Yuan
new Intl.NumberFormat('zh-CN', {
  style: 'currency',
  currency: 'CNY'
}).format(amount);
// ¥1,234.56
```

## Bidirectional Text Handling Patterns

### Unicode Bidirectional Algorithm (UBA) Support

**Problem:** Mixed LTR and RTL text can display incorrectly without proper markup.

**Example:**
```
User input: "Hello مرحبا World" (English + Arabic + English)
Without markup: Hello مرحبا World (may display incorrectly)
With markup: Hello <bdi>مرحبا</bdi> World (correct)
```

**Solutions:**

1. **`<bdi>` tag (Bidirectional Isolation):**
```html
<!-- Isolate user-generated or potentially bidirectional content -->
<p>Posted by <bdi>Ahmed_2026</bdi> on <time>2026-04-19</time></p>
<!-- Handles usernames that might be RTL -->
```

2. **`unicode-bidi` CSS:**
```css
/* For pre-formatted text that needs isolation */
.user-input {
  unicode-bidi: isolate;
  direction: auto;  /* Auto-detect direction */
}
```

3. **HTML5 `dir="auto"`:**
```html
<!-- Auto-detect direction based on first strong directional character -->
<input type="text" dir="auto" placeholder="Enter name">
<!-- Adapts when user types Arabic or Hebrew -->

<p dir="auto">Start typing in any direction...</p>
```

4. **Strong directional characters for resetting:**
```html
<!-- Use RLE/RLM (Right-to-Left Mark) or LRE/LRM (Left-to-Right Mark) -->
<!-- After English text, add: &#x202C; (Pop Directional Formatting) -->
<p>Email: user@example.com&#x202C; <span lang="ar">البريد الإلكتروني</span></p>
```

## Font Stack Recommendations by Script

### Arabic Script (Arabic, Urdu, Persian, Farsi)
```css
body {
  /* Modern approach: system fonts + fallbacks */
  font-family: 
    -apple-system, BlinkMacSystemFont,  /* macOS, iOS */
    "Segoe UI",                          /* Windows */
    "Traditional Arabic",                /* macOS/iOS specific */
    "Simplified Arabic",                 /* macOS/iOS specific */
    "Droid Arabic Naskh",                /* Android */
    "GE Dinar One",                      /* Arabic-specific modern */
    "Arial",                             /* Fallback */
    sans-serif;
  font-size: 16px;  /* Larger for tashkeel (diacritical marks) */
}

/* For headings, use fonts with better shaping */
h1, h2, h3 {
  font-family: "GE Dinar Two", "Arial", sans-serif;
  font-weight: 600;  /* Bold for better rendering */
}

/* Account for text shaping complexity */
.arabic-text {
  font-feature-settings: "liga" 1, "dlig" 1;  /* Enable ligatures */
  letter-spacing: 0.5px;  /* Slight increase for clarity */
}
```

### Chinese (Simplified & Traditional)
```css
/* Simplified Chinese (zh-CN) */
.zh-CN {
  font-family: 
    -apple-system, BlinkMacSystemFont,
    "Microsoft YaHei",                   /* Windows best choice */
    "WenQuanYi Micro Hei",               /* Linux open-source */
    "PingFang SC",                       /* macOS newer */
    "Hiragino Sans GB",                  /* macOS older */
    "STHeiti",                           /* macOS system */
    "sans-serif";
  line-height: 1.6;  /* Taller for CJK characters */
}

/* Traditional Chinese (zh-TW, zh-HK) */
.zh-TW {
  font-family: 
    -apple-system, BlinkMacSystemFont,
    "Microsoft JhengHei",                /* Windows best */
    "WenQuanYi Micro Hei",               /* Linux */
    "PingFang TC",                       /* macOS newer */
    "Hiragino Sans",                     /* macOS older */
    "STHeiti",
    "sans-serif";
  word-break: keep-all;  /* Keep CJK words intact */
}
```

### Japanese (CJK + Kana)
```css
body {
  font-family: 
    -apple-system, BlinkMacSystemFont,
    "Segoe UI",
    "Noto Sans JP",                      /* Google open-source */
    "Hiragino Kaku Gothic Pro",          /* macOS */
    "Yu Gothic",                         /* Windows */
    "MS PGothic",                        /* Windows fallback */
    "sans-serif";
  line-height: 1.7;  /* Account for ruby text and combining marks */
}

/* Ruby text (furigana) support */
ruby {
  ruby-position: over;
  font-size: 0.5em;
}

rt {
  font-size: inherit;
  font-family: "Hiragino Kaku Gothic Pro", sans-serif;
}

/* Line breaking for Japanese */
.japanese-text {
  word-break: break-word;
  line-break: strict;
}
```

### Korean (Hangul)
```css
body {
  font-family: 
    -apple-system, BlinkMacSystemFont,
    "Segoe UI",
    "Noto Sans CJK KR",                  /* Google open-source */
    "Apple SD Gothic Neo",               /* macOS/iOS */
    "Noto Sans Korean",
    "Malgun Gothic",                     /* Windows */
    "sans-serif";
  word-break: keep-all;  /* Preserve word boundaries */
  line-height: 1.6;
}
```

### Indic Scripts (Devanagari, Bengali, Tamil, Telugu)
```css
/* Devanagari (Hindi, Sanskrit) */
.devanagari {
  font-family: 
    "Noto Sans Devanagari",              /* Google open-source */
    "ITrans",
    "Arial Unicode MS",
    sans-serif;
  font-size: 18px;  /* Larger for complex ligatures */
  line-height: 1.8;  /* Account for height of marks */
  letter-spacing: 0.3px;  /* Clarity for conjuncts */
}

/* Bengali */
.bengali {
  font-family: 
    "Noto Sans Bengali",
    "Arial Unicode MS",
    sans-serif;
  font-size: 17px;
  line-height: 1.8;
}

/* Tamil */
.tamil {
  font-family: 
    "Noto Sans Tamil",
    "Arial Unicode MS",
    sans-serif;
  font-size: 18px;
  line-height: 1.8;
}
```

### Cyrillic (Russian, Ukrainian, Serbian)
```css
body {
  font-family: 
    -apple-system, BlinkMacSystemFont,
    "Segoe UI",
    "Noto Sans",
    "Roboto",
    "Arial",
    sans-serif;
  font-size: 16px;
}

/* Extended Cyrillic coverage needed for all target languages */
@font-face {
  font-family: "Roboto";
  src: url("/fonts/roboto-cyrillic-ext.woff2") format("woff2");
  unicode-range: U+0400-04FF, U+0500-052F;  /* Cyrillic + Extended */
}
```

### Emoji & Symbol Support
```css
body {
  font-family: 
    "System UI",
    "Segoe UI",
    "Helvetica",
    sans-serif,
    "Apple Color Emoji",                 /* Must come after main fonts */
    "Segoe UI Emoji",
    "Noto Color Emoji";  /* For Linux */
}
```

## Common i18n Mistakes

| Mistake | Example | Fix |
|---------|---------|-----|
| **Hardcoded dates** | `"April 19, 2026"` in code | Use `Intl.DateTimeFormat` with locale |
| **Hardcoded numbers** | `"1,234.56"` | Use `Intl.NumberFormat` |
| **String concatenation** | `"Total: " + amount` (fails in RTL) | Use message format: `t('price.total', { amount })` |
| **No dir attribute** | Assume LTR layout | Always set `dir="ltr"` or `dir="rtl"` |
| **Physical CSS** | `margin-left: 10px` | Use `margin-inline-start` |
| **Left/right icons** | Arrow always points left | Mirror for RTL, use symbolic icons instead |
| **No font stack** | Only specify Latin font | Provide fallback chain for target scripts |
| **Ignore line height** | Default 1.2 for CJK | Increase to 1.6-1.8 for complex scripts |
| **No IME support** | Assume QWERTY input | Test with CJK input method editors |
| **Email in URL param** | `?email=user@example.com` | RTL can break parameter parsing |

## Related Skills
- `/arib-docs-api` - Document API endpoints with locale support
- `/arib-docs-generate` - Generate i18n-compliant documentation
- `/arib-io` - Process i18n audit requests

## Notes
- This audit ensures users of ANY locale have a proper experience
- CSS logical properties are essential for bidirectional support
- All user-visible text must be i18n compliant
- Font loading is critical for proper character display across scripts
- Regional standards (calendars, number systems, currencies) matter for UX
- Run this audit before any release targeting a new market
- For multi-locale projects, run once per locale: `/arib-docs-language all --locale ar-SA` then `/arib-docs-language all --locale zh-CN`
- Test with actual users from target locales when possible
- Use professional translation services, not machine translation, for user-facing text
- Budget extra time for RTL projects - layout changes are complex
- Consider hiring a native speaker for QA if entering new market
