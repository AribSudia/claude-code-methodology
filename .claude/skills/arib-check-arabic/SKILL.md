---
name: arib-check-arabic
argument-hint: "[<path>]"
description: "Check | Arabic typography, RTL, numerals, punctuation — MENA compliance"
---

# Arabic / RTL Audit — /arib-check-arabic

## Overview

Audits Arabic-language UI surfaces against the rules in
`.claude/rules/i18n-ar.md` and `compliance/frameworks/mena-pdpl.md`.

This is the original Item #7 deliverable. It complements `arib-docs-language`
(generic i18n covering CJK, Indic, etc.) by going deeper on Arabic-specific
typography, direction, numerals, punctuation, and mirroring.

## When to Use

- Before merging UI work that includes Arabic content.
- As section 7 of `/arib-deep-audit`.
- When onboarding to a project that already serves Arabic users — runs
  the full audit and surfaces drift.

## Usage

```bash
/arib-check-arabic                              # whole codebase
/arib-check-arabic components/checkout/          # a subdir
/arib-check-arabic locales/ar.json               # a single file
```

## Protocol

### Step 1 — Detect Arabic content

```bash
# Find files containing U+0600-U+06FF
grep -rlE '[\x{0600}-\x{06FF}]' --include='*.{tsx,jsx,vue,svelte,html,json}' \
  --exclude-dir=node_modules <target>
```

If zero hits: return PASS with note "no Arabic content found".

### Step 2 — Typography

For each Arabic-content file:
- Confirm font family is IBM Plex Arabic, Noto Sans Arabic, or a stack
  starting with one of those.
- Confirm Latin pairing is Inter or Geist (or matches the project's
  declared font in tailwind config).
- Flag any third sans-serif family.

### Step 3 — Direction

```bash
# Look for dir="rtl" on root containers in Arabic locale rendering
grep -rEn '<html\s+lang="ar"' <target>
grep -rEn '<body\s+dir="' <target>
```

Confirm `dir="rtl"` is set when locale is `ar`. Flag missing directionality.

### Step 4 — Numerals policy

Read `architecture/DECISIONS.md` for a declared numeral policy. If absent,
emit INFO finding asking to declare one.

If present, scan Arabic content for inconsistent numerals:
- Policy = Western Arabic but Arabic-Indic digits in code: WARN.
- Policy = Arabic-Indic but Western digits in user-facing strings: WARN.

### Step 5 — Punctuation

```bash
# Find Latin punctuation INSIDE Arabic strings
# Use jq for ar.json files; regex pass on .tsx/.jsx/.vue
```

For each Arabic string containing `?`, `,`, or `;` — flag with the right
replacement (`؟`, `،`, `؛`).

### Step 6 — Mirroring

```bash
grep -rEn 'Chevron|Arrow|Caret' --include='*.tsx' <target>
```

For each match, check whether `rtl:rotate-180` or an RTL-aware variant is
used. Flag bare directional icons in pages that ship Arabic.

### Step 7 — Hard-coded strings

```bash
# Look for English strings inside .tsx files where dir="rtl" is set
```

Flag hard-coded English. Suggest moving to `locales/ar.json`.

### Step 8 — Compliance overlay (KSA institutional only)

If the project declares KSA institutional context (in
`compliance/CONTROLS.md` or `architecture/DECISIONS.md`):
- Confirm Hijri-or-dual date display.
- Confirm Arabic privacy notice exists.
- Confirm data residency configured (skill hands off to
  `arib-check-compliance pdpl`).

### Step 9 — Verdict

| Severity | Trigger |
|----------|---------|
| BLOCK | Missing `dir="rtl"` on Arabic UI root, no Arabic privacy notice for customer-facing institutional, data residency outside KSA for KSA institutional |
| WARN  | Latin punctuation in Arabic strings, wrong font family, mirroring issues, hard-coded English |
| INFO  | Numeral policy not declared |
| PASS  | All clean |

## Output format

```markdown
# Arabic / RTL Audit — <target> — <date>

## Summary
- typography:    OK | WARN | BLOCK
- direction:     OK | WARN | BLOCK
- numerals:      OK | WARN | INFO
- punctuation:   OK | WARN
- mirroring:     OK | WARN
- hardcoded:     OK | WARN
- compliance:    n/a | OK | BLOCK

## Findings
### F1 — <file:line> — <severity>
<description>
**Fix:** <action>
```

## Failure modes

- **No Arabic content found:** PASS with note. Don't invent findings.
- **Tailwind config missing on a Tailwind-shaped project:** WARN that
  font/direction enforcement can't be verified.
- **`compliance/CONTROLS.md` absent:** skip the institutional compliance
  overlay; emit INFO that institutional context is unconfirmed.

## Related

- `.claude/rules/i18n-ar.md` — auto-loads on Arabic content paths.
- `compliance/frameworks/mena-pdpl.md` — KSA framework alignment.
- `.claude/skills/arib-check-compliance/SKILL.md` — meta-skill for all frameworks.
- `.claude/skills/arib-docs-language/SKILL.md` — generic i18n (CJK, Indic).
