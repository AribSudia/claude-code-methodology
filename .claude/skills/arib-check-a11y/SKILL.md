---
argument-hint: "[component|page]"
description: Check | Accessibility audit - WCAG 2.1 AA compliance, color contrast, ARIA, keyboard navigation, screen reader
---

# /arib-check-a11y Command

## Overview

Accessibility is not optional. WCAG 2.1 Level AA compliance is a legal requirement in most jurisdictions (US ADA, EU EN 301 549, UK Equality Act 2010) and an ethical obligation to serve all users. This audit identifies barriers that prevent people with disabilities from using your application, then provides concrete remediation steps.

The audit covers four WCAG principles:
- **Perceivable**: Users can see/hear content (contrast, alt text, captions)
- **Operable**: Users can navigate via keyboard (focus management, skip links)
- **Understandable**: Content is clear and forms are easy to use (labels, errors)
- **Robust**: Works with assistive technologies (semantic HTML, ARIA)

Automated tools catch ~30% of issues. Manual testing with real screen readers and keyboards catches the rest.

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

## When to Use

- **Pre-launch**: Before any public release, required for legal compliance
- **Component review**: Before merging PRs that add interactive components
- **Accessibility regressions**: When notified by users or accessibility advocates
- **Design updates**: When colors, contrast, or layout changes affect perceivability
- **Post-incident**: After accessibility bugs are reported, run full audit to find similar issues

## WCAG 2.1 AA Quick Reference

| Principle | Key Requirements | Severity if Missing |
|-----------|------------------|---------------------|
| **Perceivable** | Images have alt text; text has 4.5:1 contrast; videos have captions | CRITICAL - Complete barrier for blind/low-vision users |
| **Operable** | Keyboard navigation works; focus visible; no keyboard traps | CRITICAL - Complete barrier for motor disability users |
| **Understandable** | Form inputs labeled; error messages clear; language set | HIGH - Confusing for all users, severe for cognitive disabilities |
| **Robust** | Semantic HTML; valid ARIA; works with screen readers | CRITICAL - Assistive tech depends on this |

## Common Violations with Examples

### 1. Missing or Incorrect Alt Text

**Bad (missing alt):**
```html
<img src="user-avatar.png" />
```

**Bad (uninformative alt):**
```html
<img src="product.png" alt="image" />
```

**Good:**
```html
<img src="user-avatar.png" alt="Sarah Chen, Product Manager" />
<img src="chart.png" alt="Sales revenue grew 23% YoY from Q1 2025 to Q1 2026" />
```

**Decorative images should have empty alt:**
```html
<img src="separator-line.png" alt="" aria-hidden="true" />
```

### 2. Low Color Contrast

**Contrast Ratio Requirements:**
- Normal text (< 14pt): 4.5:1 minimum
- Large text (≥ 14pt bold or ≥ 18pt): 3:1 minimum
- Icons and UI components: 3:1 minimum

**Bad (2.1:1 ratio - fails):**
```css
color: #777; /* light gray on white = too light */
background: white;
```

**Good (4.5:1 ratio - passes):**
```css
color: #333; /* dark gray on white */
background: white;
```

Use tools: WebAIM Contrast Checker, Lighthouse, axe DevTools.

### 3. Form Inputs Without Labels

**Bad:**
```html
<input type="email" placeholder="Enter email" />
```
Placeholder text disappears when typing; screen readers can't find the label.

**Good:**
```html
<label for="email-input">Email Address</label>
<input id="email-input" type="email" aria-describedby="email-hint" />
<span id="email-hint">We'll never share your email</span>
```

### 4. No Keyboard Focus Indicator

**Bad:**
```css
button:focus {
  outline: none; /* Removes visible focus ring */
}
```

**Good:**
```css
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
/* Or use modern focus-visible */
button:focus-visible {
  outline: 3px solid #0066cc;
}
```

### 5. Links Without Clear Text

**Bad:**
```html
<a href="/privacy">Click here</a> for our privacy policy
<a href="/docs">Read more</a>
```
Screen reader users hear "link click here" - not descriptive.

**Good:**
```html
<a href="/privacy">Read our privacy policy</a>
<a href="/docs">View full documentation on database migrations</a>
```

### 6. Modal Trap (Keyboard Can't Escape)

**Bad:**
```jsx
function Modal() {
  return (
    <div className="modal">
      <button>Close</button>
      <p>Content...</p>
      {/* No focus trap - Escape key doesn't close */}
    </div>
  );
}
```

**Good:**
```jsx
function Modal() {
  const ref = useRef(null);
  useEffect(() => {
    // Trap focus inside modal
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') closeModal();
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, []);
  
  return (
    <div className="modal" role="dialog" aria-labelledby="modal-title">
      <h2 id="modal-title">Dialog Title</h2>
      <button onClick={closeModal}>Close</button>
      <p>Content...</p>
    </div>
  );
}
```

## Automated vs Manual Testing

**Automated tools find (30%):**
- Missing alt text
- Color contrast violations
- Heading hierarchy breaks
- Form label issues
- Basic ARIA errors

Tools: axe DevTools, WAVE, Lighthouse, Pa11y

**Manual testing finds (70%):**
- Navigation flow with keyboard only
- Focus order correctness (Tab key)
- Screen reader announcements (test with NVDA/VoiceOver)
- Motion/animation triggers seizures
- Context-dependent alt text accuracy
- Real-world usability with assistive tech

**Always test with:** 
- Keyboard only (no mouse)
- Screen reader (NVDA on Windows, VoiceOver on Mac)
- Browser zoom (200%)
- High contrast mode

## Instructions

### Step 1: Activate Accessibility Auditor Agent
Read `.claude/agents/accessibility.md` and follow the 7-step protocol.

### Step 2: Semantic HTML Scan
Find non-semantic elements (div-as-button), missing alt text, heading hierarchy issues, missing lang attribute, unlabeled form inputs.

**Check for:**
```javascript
// BAD: Using div/span for interactive elements
<div onClick={handleClick}>Click me</div>

// GOOD: Using semantic elements
<button onClick={handleClick}>Click me</button>

// BAD: Non-sequential heading hierarchy
<h1>Title</h1>
<h3>Subsection</h3> <!-- Skip from h1 to h3 -->

// GOOD: Sequential headings
<h1>Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>

// BAD: No heading on page
<div class="page-content">
  Content here...
</div>

// GOOD: Semantic structure with headings
<main>
  <h1>Page Title</h1>
  <p>Content...</p>
</main>
```

### Step 3: Color Contrast Check
Extract color values from CSS/Tailwind, calculate contrast ratios, flag failures against WCAG AA thresholds (4.5:1 normal text, 3:1 large text).

**Contrast calculation:**
```
Luminance = 0.2126 * R + 0.7152 * G + 0.0722 * B (each value 0-1)
Contrast Ratio = (L1 + 0.05) / (L2 + 0.05) where L1 > L2

Example: black (#000) on white (#fff)
= (1 + 0.05) / (0 + 0.05) = 21:1 ✓ Excellent

Example: #777 on white
= (0.4 + 0.05) / (1 + 0.05) ≈ 2.1:1 ✗ Fails AA
```

### Step 4: Keyboard Navigation Audit
Check focus order, focus visibility, keyboard support for custom components, skip links, focus traps in modals.

**Test protocol:**
1. Tab through entire page - verify logical order
2. Verify focus always visible (not outline: none)
3. Shift+Tab works backwards
4. Enter/Space activates buttons
5. Arrow keys work in menus/tabs
6. Escape closes modals/dropdowns

### Step 5: ARIA & Dynamic Content
Validate ARIA usage (prefer native HTML), check live regions for notifications, verify expanded/selected states.

**ARIA hierarchy (prefer top approach):**
```html
<!-- BEST: Use semantic HTML -->
<button aria-expanded="false" aria-controls="menu">Menu</button>
<ul id="menu" hidden>...</ul>

<!-- GOOD: Use ARIA when semantic HTML insufficient -->
<div role="button" tabindex="0" aria-pressed="false">Toggle</div>

<!-- AVOID: Overusing ARIA on semantic elements -->
<button role="button">Wrong - button already has role</button>

<!-- LIVE REGIONS for dynamic updates -->
<div role="status" aria-live="polite" id="status">Ready</div>
<script>
  document.getElementById('status').textContent = 'File uploaded';
  // Screen reader announces: "File uploaded"
</script>
```

### Step 6: Responsive & Motion
Check prefers-reduced-motion, viewport zoom restrictions, reflow at 320px.

**Reduce motion support:**
```css
/* Always allow animations, but respect user preference */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

**Never restrict zoom:**
```html
<!-- BAD: Prevents zoom at 200% -->
<meta name="viewport" content="user-scalable=no, maximum-scale=1" />

<!-- GOOD: Allow full zoom -->
<meta name="viewport" content="width=device-width, initial-scale=1" />
```

### Step 7: Generate Report
Produce the Accessibility Audit Report with:
- Compliance score per WCAG principle (Perceivable, Operable, Understandable, Robust)
- All violations classified by severity (Level A critical, Level AA moderate)
- File locations and code snippets for each violation
- Before/after fix examples
- Remediation plan with effort estimates

**Report template:**
```markdown
# Accessibility Audit Report
**Date:** 2026-04-19
**Scope:** Full application
**Compliance:** 72% WCAG 2.1 AA

## Summary
- Perceivable: 85% (images, contrast)
- Operable: 60% (keyboard, focus)
- Understandable: 80% (labels, errors)
- Robust: 75% (semantic HTML, ARIA)

## Critical Issues (Must Fix Before Launch)
### 1. Missing Alt Text on Product Images
- **File:** src/components/ProductCard.tsx:45
- **Severity:** Level A - Blocks blind users
- **Count:** 12 occurrences
- **Fix:** Add descriptive alt text to all <img> tags
- **Effort:** 30 min

## High Issues (Must Fix This Sprint)
### 2. Low Color Contrast on Links
- **Affected:** All links in white text on light gray background
- **Ratio:** 3.2:1 (need 4.5:1)
- **Fix:** Change text color from #666 to #222
- **Effort:** 5 min

## Edge Cases & Testing Notes

### Edge Case: Dynamic Content Updates
When content updates after page load, always announce to screen reader:
```javascript
const announcement = document.createElement('div');
announcement.setAttribute('role', 'status');
announcement.setAttribute('aria-live', 'polite');
announcement.textContent = 'New messages loaded';
document.body.appendChild(announcement);
```

### Edge Case: Custom Select Dropdowns
Don't build custom selects - they break accessibility. If you must:
```jsx
function CustomSelect({ options, onChange }) {
  const [open, setOpen] = useState(false);
  
  return (
    <div>
      <label htmlFor="custom-select">Choose option</label>
      <button
        id="custom-select"
        aria-haspopup="listbox"
        aria-expanded={open}
        onClick={() => setOpen(!open)}
      >
        {selectedOption}
      </button>
      {open && (
        <ul role="listbox">
          {options.map(opt => (
            <li
              key={opt}
              role="option"
              aria-selected={opt === selectedOption}
              onClick={() => {
                onChange(opt);
                setOpen(false);
              }}
            >
              {opt}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

### Edge Case: Tables with Headers
```html
<!-- GOOD: Proper table structure for screen readers -->
<table>
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Email</th>
      <th scope="col">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Alice</td>
      <td>alice@example.com</td>
      <td>Active</td>
    </tr>
  </tbody>
</table>
```

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|------------|-----|
| `<img alt="image">` | Empty/meaningless alt | `<img alt="Team photo at 2026 conference">` |
| `<button style="cursor: pointer">` with no outline | Focus invisible | Add `:focus { outline: 2px solid... }` |
| `<label>Email</label><input>` (unassociated) | Screen reader can't link them | Use `<label for="id">` + `<input id="id">` |
| `onclick` handlers on `<div>` | Not keyboard accessible | Use `<button>` instead |
| Images in CSS backgrounds | Can't have alt text | Use HTML `<img>` or add `aria-label` to container |
| Color alone to communicate state | Colorblind users miss it | Add text/icon + color |
| "Click here" links | Not descriptive | "Download PDF report" |
| `prefers-reduced-motion` ignored | Triggers motion sickness/seizures | Respect @media query |

## Related Skills

- **arib-check-deploy**: Run this audit before deployment - A11y issues are release blockers
- **design-review**: Coordinate with design on color palette and contrast ratios
- **test-coverage**: Add automated accessibility tests to CI/CD (e.g., jest-axe)

## Notes
- This command activates the Accessibility Auditor agent
- Level A violations are critical and must be fixed before launch
- Level AA violations are required for legal compliance in most jurisdictions
- Always test with a real screen reader (VoiceOver on Mac, NVDA on Windows)
- Automated checks catch ~30% of issues - manual review catches the rest
- Browser extensions for validation: axe DevTools, WAVE, Lighthouse
