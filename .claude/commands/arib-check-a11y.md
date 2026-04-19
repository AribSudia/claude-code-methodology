---
argument-hint: "[component|page]"
description: Check | Accessibility audit - WCAG 2.1 AA compliance, color contrast, ARIA, keyboard navigation, screen reader
---

# /arib-check-a11y Command

## Purpose
Audit frontend code for WCAG 2.1/2.2 Level AA compliance. Checks semantic HTML, color contrast, ARIA usage, keyboard navigation, focus management, and screen reader compatibility. Produces an Accessibility Audit Report with remediation plan.

## Trigger
User types `/arib-check-a11y [scope]`

Examples:
- `/arib-check-a11y` - Full frontend accessibility audit
- `/arib-check-a11y src/components/LoginForm.tsx` - Specific component
- `/arib-check-a11y --page /dashboard` - Specific page route
- `/arib-check-a11y --contrast` - Color contrast check only
- `/arib-check-a11y --keyboard` - Keyboard navigation audit only

## Instructions

### Step 1: Activate Accessibility Auditor Agent
Read `.claude/agents/accessibility.md` and follow the 7-step protocol.

### Step 2: Semantic HTML Scan
Find non-semantic elements (div-as-button), missing alt text, heading hierarchy issues, missing lang attribute, unlabeled form inputs.

### Step 3: Color Contrast Check
Extract color values from CSS/Tailwind, calculate contrast ratios, flag failures against WCAG AA thresholds (4.5:1 normal text, 3:1 large text).

### Step 4: Keyboard Navigation Audit
Check focus order, focus visibility, keyboard support for custom components, skip links, focus traps in modals.

### Step 5: ARIA & Dynamic Content
Validate ARIA usage (prefer native HTML), check live regions for notifications, verify expanded/selected states.

### Step 6: Responsive & Motion
Check prefers-reduced-motion, viewport zoom restrictions, reflow at 320px.

### Step 7: Generate Report
Produce the Accessibility Audit Report with:
- Compliance score per WCAG principle (Perceivable, Operable, Understandable, Robust)
- All violations classified by severity (Level A critical, Level AA moderate)
- File locations and code snippets for each violation
- Before/after fix examples
- Remediation plan with effort estimates

## Notes
- This command activates the Accessibility Auditor agent
- Level A violations are critical and must be fixed before launch
- Level AA violations are required for legal compliance in most jurisdictions
- Always test with a real screen reader (VoiceOver on Mac, NVDA on Windows)
- Automated checks catch ~30% of issues - manual review catches the rest
- Browser extensions for validation: axe DevTools, WAVE, Lighthouse
