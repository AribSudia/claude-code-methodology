---
argument-hint: "[<path-or-glob>]"
description: "Check | Design system contract — tokens, components, typography, dark mode"
---

# Design Contract Check — /arib-check-design

## Overview

Audits a directory or set of files against `architecture/DESIGN_SYSTEM.md`.
The pre-tool-use hook already blocks raw color literals at write time; this
skill checks **everything else**: component baseline drift, typography
mixing, dark-mode default, motion patterns, spacing literals.

This skill complements `arib-check-a11y` — accessibility checks WCAG; this
checks the visual contract that prevents drift toward inconsistency.

## When to Use

- Before merging a feature that touches UI.
- During a design-system audit (e.g. quarterly).
- When onboarding a new contributor — runs the contract once and surfaces
  drift introduced before they joined.
- As section 4 of `/arib-deep-audit`.

## Usage

```bash
/arib-check-design                  # whole UI tree
/arib-check-design components/      # subdir
/arib-check-design components/billing/checkout.tsx  # single file
```

## Protocol

### Step 1 — Read the contract

Read `architecture/DESIGN_SYSTEM.md`. If absent, abort and tell the user to
run the bootstrap (which generates a default).

### Step 2 — Check 1: Token discipline

Scan target files for forbidden patterns (raw hex, rgb(), hsl(), named CSS
colors) outside the exempt paths declared in DESIGN_SYSTEM.md.

```bash
grep -rEn '#[0-9a-fA-F]{3,8}\b|\brgb[a]?\([^)]*\)|\bhsl[a]?\([^)]*\)' \
  --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' \
  --exclude-dir=node_modules --exclude-dir=tests \
  <target>
```

Expected: zero hits in non-exempt paths. Each hit is a finding.

### Step 3 — Check 2: Component baseline drift

Detect components imported from forbidden libraries when the baseline is
shadcn. Examples of drift:
- `import {} from '@mui/material'` when baseline is shadcn.
- `import {} from 'antd'` when baseline is shadcn.
- Custom button/input/select components that duplicate shadcn primitives.

Report the import statement and the file. Suggest the shadcn equivalent.

### Step 4 — Check 3: Typography stack

Look in `app/layout.tsx`, `_app.tsx`, `index.html`, `tailwind.config.*` for
font declarations. Flag:
- More than 2 sans-serif families on the same scope.
- Missing Arabic font when the project has `dir="rtl"` or `lang="ar"` in
  any source file.
- Raw `font-size: <px>` literals (warn — too noisy to block).

### Step 5 — Check 4: Dark mode default

For Tailwind projects: confirm `darkMode: 'class'` in tailwind config.
For other projects: confirm a `dark` class or `data-theme="dark"` is the
default applied to `<html>` or `<body>`.

If the project is consumer-facing and explicitly chose light-default, expect
an ADR in `architecture/DECISIONS.md`. If neither dark-default nor an ADR
exists, raise a WARN.

### Step 6 — Check 5: Motion

```bash
grep -rEn 'animate-[a-z]+|@keyframes|<motion\.' --include='*.tsx' --include='*.css' <target>
```

For each match, check whether it respects `prefers-reduced-motion`. The
common pattern is a `motion-safe:` Tailwind prefix or a media query around
the animation.

Auto-playing animations on dashboards/tables/forms = BLOCK.

### Step 7 — Verdict

```text
PASS:  no findings.
WARN:  drift exists but is bounded (e.g. one stray hex literal in a non-
       critical component).
BLOCK: token rules violated in ≥3 files, or a forbidden component library
       is imported in a primary user surface, or auto-play motion on data
       screens.
```

## Output format

```markdown
# Design Contract Audit — <target> — <date>

## Summary
- token violations: N
- component drift:  N
- typography mix:   N
- dark mode:        OK | WARN | BLOCK
- motion:           OK | WARN | BLOCK

## Findings

### F1 — <file:line> — <severity>
<one-paragraph description>
**Fix:** <one-sentence actionable suggestion>

(...)
```

## Failure modes

- **DESIGN_SYSTEM.md missing:** abort with a clear error; do not invent rules.
- **Project has no UI yet:** return PASS with note "no UI surface to check".
- **Tailwind config not found and project is Tailwind-shaped:** WARN that
  the contract can't be fully verified.

## Related

- `architecture/DESIGN_SYSTEM.md` — the contract itself.
- `arib-check-a11y` — accessibility (separate concern).
- `.claude/hooks/pre-tool-use.sh` — write-time token enforcement.
