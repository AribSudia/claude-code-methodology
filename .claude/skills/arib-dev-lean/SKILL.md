---
name: arib-dev-lean
argument-hint: "<path | diff>"
description: "Dev | Over-engineering review — reads a diff/module and returns a delete-list of bloat (single-use abstractions, premature generalization, speculative config, dead options) WITHOUT stripping legitimate structure. Advisory: returns recommendations, never auto-deletes. The on-demand companion to the ponytail-lite tripwire hook. Authored natively (no Ponytail dependency). ADR-033."
---

# /arib-dev-lean — review for over-engineering (YAGNI)

Read a diff or module and return a **delete-list**: the bloat that can go without losing
function. The honest counterpart to the `ponytail-lite.sh` tripwire — that hook is a quiet
edit-time hint; this is the deliberate review. **Advisory only** — it returns
recommendations; it never deletes anything itself.

> Authored natively (CCM's own YAGNI ladder) — the developer plan proposed wrapping the
> Ponytail tool, which isn't installed; this needs no external dependency.

## What it flags (the YAGNI ladder)

1. **Single-use abstraction** — an interface/abstract class/factory/strategy with exactly
   one implementer and one caller. Inline it until a second user exists.
2. **Premature generalization** — a "configurable" function whose every call passes the
   same options; a generic the codebase only instantiates one way.
3. **Speculative config / flags** — options, env vars, or feature flags that nothing reads,
   or that have exactly one value everywhere.
4. **Dead options & params** — parameters always passed the same value; branches never taken.
5. **Indirection with no payoff** — a pass-through wrapper/adapter that only forwards.
6. **Gold-plated error handling** — catch-rethrow that adds nothing; defensive checks for
   states the type system already prevents.

## What it MUST NOT flag (legitimate structure wins — CCM rule)

- Framework structure required by the stack — NestJS modules/providers/guards/DTOs,
  React boundaries, etc. (the `ponytail-lite` hook exempts `*.module/*.controller/*.service/
  *.guard/*.dto`; this review honors the same intent).
- An abstraction with a **real second user** or a **documented near-term** one.
- Anything marked `// ccm-ceremony:` — intentional scaffolding.
- Security/validation depth on a high-stakes path — never "lean away" a guard.

When in doubt, **keep it** and note it as "watch" rather than "delete". A false delete is
worse than a surviving abstraction.

## Protocol

1. Read the target (a path, a module, or `git diff <base>...<head>`).
2. Walk the ladder above; for each hit, record: file:line · what · why it's single-use ·
   the concrete simplification · a confidence (high/med/low).
3. Skip the exemptions; downgrade anything uncertain to "watch".
4. Output a **delete-list** (high-confidence) + a **watch-list** (uncertain) →
   `io/ledger/lean-review-<date>.md` (standard CCM audit format). Recommend; do not apply.
5. Optionally hand the delete-list to `/arib-build` or a specialist to action — behind the
   normal merge gate.

## Anti-patterns

Stripping required framework ceremony · deleting a guard/validation to "simplify" ·
auto-applying deletes (this is advisory) · flagging an abstraction that has a real second
user · treating low-confidence hits as deletes.
