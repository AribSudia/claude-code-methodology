# DESIGN_SYSTEM.md — Visual contract

> **Status:** opinionated default. CCM is methodology-agnostic at the
> framework level, but visual quality is too leaky to leave undefined. This
> document is the contract that the `arib-check-design` skill and the
> design-token hook enforce.
>
> **Override:** projects can replace this file with their own. The hook reads
> token rules from this file's machine-readable section (below); replace the
> *content* but keep the *structure*.

---

## 1. Component baseline

**Default:** [shadcn/ui](https://ui.shadcn.com).

Reasons:
- Accessibility-correct primitives by default (built on Radix UI).
- TypeScript-native; no runtime style engine.
- Customizable through code, not theme objects — copy components in, own them.
- Pairs cleanly with Tailwind tokens (see §2).

**Replace with:**
- Material UI / MUI — when corporate brand mandates Material.
- Chakra UI — when team already invested.
- Custom — when the design system genuinely needs to be unique. Document
  *why* in `architecture/DECISIONS.md`.

The choice doesn't matter; the *consistency* does. Whatever you pick, pick
one and stick with it. Hooks below enforce the consistency.

---

## 2. Color

**Source of truth:** Tailwind tokens.

```text
ALLOWED:    text-zinc-900, bg-blue-600, border-red-500/20, ring-emerald-400
            theme-token references (var(--color-primary), {colors.brand.primary})
            Tailwind arbitrary values that resolve to tokens (text-[--brand])

BLOCKED:    raw hex (#ffffff, #f0f0f0)
            raw rgb()/rgba() (rgb(255 255 255))
            raw hsl()/hsla() (hsl(220 10% 50%))
            named CSS colors (color: red)
```

**Exemption paths** (raw values allowed):
- `*tokens*` files (e.g. `theme/tokens.ts`, `styles/tokens.css`).
- `*theme*` files (e.g. `theme.config.ts`).
- Generated files (`*.generated.*`).
- Test fixtures (`tests/`, `__fixtures__/`, `*.test.*`, `*.spec.*`).
- Storybook stories explicitly demonstrating raw color (rare).

The `pre-tool-use.sh` hook enforces this at write time. The rules are hardcoded
in the hook (see the "Design-token enforcement (Item #8)" block) for these
defaults:

- **File extensions checked:** `.tsx`, `.jsx`, `.vue`, `.svelte`.
- **Exempted paths:** anything matching `*tokens*`, `*theme*`, `*.generated.*`,
  test/fixture paths (via `is_test_or_fixture_path` in `lib/common.sh`),
  `node_modules/`.
- **Forbidden patterns:** raw hex `#abc[def]`, `rgb()`/`rgba()`, `hsl()`/`hsla()`.

Override by editing `.claude/hooks/pre-tool-use.sh` directly. There is no
machine-readable config block — bash-parsing YAML is more rope than help.
The contract above is the human-readable source; the hook is the machine
truth. Keep them in sync.

---

## 3. Typography

**Latin:** Inter (default) or Geist (when tighter visual density helps).
**Arabic:** IBM Plex Arabic (preferred) or Noto Sans Arabic.
**CJK:** Noto Sans CJK (default).
**Monospace:** JetBrains Mono or Geist Mono.

**Pairing rule:** never mix more than 2 sans-serif families on a single
screen. Latin + Arabic is a pair, not a mix.

**Sizes:** Tailwind scale (`text-sm`, `text-base`, ...). No raw `font-size: 13px`.

**Weights:** 400 (body), 500 (UI labels), 600 (headings). Avoid 100/200/800/900
unless the design system explicitly calls for them.

---

## 4. Spacing

Tailwind scale only. No raw `margin: 17px` literals.

The hook does not enforce spacing literals (too noisy on legitimate use cases
like grid offsets). Reviewers should call them out manually.

---

## 5. Dark mode

**Default:** dark-first.

Tailwind dark-mode strategy: `class` (toggle a `dark` class on `<html>`).
Light mode is an explicit override via `:not(.dark)` or `light:` prefix.

The reason: marketing surfaces tend to default light, but engineering tools
default dark. CCM is for engineering tools.

**Adapt:** if the project is consumer-facing (e-commerce, marketing site),
flip the default. Document in `architecture/DECISIONS.md`.

---

## 6. Motion

- **Library default:** Framer Motion (when complex), CSS keyframes (otherwise).
- **No auto-playing animations on data screens** — dashboards, tables, forms.
- **Respect `prefers-reduced-motion`** — if a user has it set, transitions
  should reduce to 50ms or skip entirely.

---

## 7. Aesthetic references

When in doubt about visual decisions, the references are:

- **Linear** — high information density, low chrome, professional restraint.
- **Vercel** — typographic confidence, monochrome with single accent.
- **Stripe** — clear hierarchy, generous whitespace, grounded illustrations.

These are descriptive, not prescriptive. Use them to break a tie, not as a
rulebook.

---

## 8. Enforcement summary

| Rule | Enforced by | Exemption |
|------|-------------|-----------|
| Raw color literals in components | `pre-tool-use.sh` design-token hook | `*tokens*`, `*theme*`, tests, generated |
| Component baseline (shadcn/ui) | review (`arib-check-design`) | `architecture/DECISIONS.md` ADR required to replace |
| Typography pair | review (`arib-check-design`) | none |
| Dark mode default | review (`arib-check-design`) | document override in DECISIONS.md |
| Reduced motion respected | `arib-check-a11y` | none |

---

## 9. Related

- `.claude/skills/arib-check-design/SKILL.md` — runs the full design contract.
- `.claude/skills/arib-check-a11y/SKILL.md` — accessibility audit.
- `.claude/hooks/pre-tool-use.sh` — enforces the design-token block above.
