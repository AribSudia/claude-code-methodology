# Branded Command Naming System

> **Version**: v3.20.0+
> **Purpose**: Every CCM skill uses the official `arib` brand for its slash
> command, with hierarchical categories so the picker filters as you type.
>
> **Scope note:** this file is the on-demand reference for CCM's own **33
> `/arib-*` skills**. It is NOT the same as `reference/SKILLS_REGISTRY.md`,
> which catalogs ~30 *external / community* Claude Code ecosystem skills &
> tools (with `npx` / `git clone` install commands). Two different lists —
> don't conflate them. The always-on canonical table is **CLAUDE.md §4**;
> this doc mirrors it for the skill-prefix/autocomplete convention.

---

## How It Works

Commands use the pattern: `/arib-{category}-{name}`

```
/arib-session-start        ← type /arib → see ALL skills
/arib-dev-feature          ← type /arib-dev → see dev skills only
/arib-check-deploy         ← type /arib-check → see check skills only
/arib-docs-api             ← type /arib-docs → see docs skills only
```

## Brand

The official command prefix is **`arib`** — used across all projects.

| Brand | Prefix | Example |
|-------|--------|---------|
| ARIB (official) | `arib` | `/arib-session-start` |

---

## Command Categories (9)

| Category | Count | Commands | Autocomplete filter |
|----------|-------|----------|---------------------|
| **Session** | 5  | start, end, io, memory-search, graph | `/arib-session` / `/arib-memory-search` / `/arib-graph` |
| **Dev**     | 4  | feature, debug, review, lean | `/arib-dev` |
| **Wave**    | 4  | plan, start, run, end | `/arib-wave` |
| **Audit**   | 1  | deep-audit | `/arib-deep-audit` |
| **Check**   | 11 | deploy, services, reality, migrate, perf, deps, a11y, design, arabic, security, compliance | `/arib-check` |
| **CI**      | 1  | ci-audit | `/arib-ci-audit` |
| **Docs**    | 3  | api, generate, language | `/arib-docs` |
| **Engine**  | 2  | engine, build | `/arib-engine` / `/arib-build` |
| **Stack**   | 2  | nestjs, postgres | `/arib-nestjs` / `/arib-postgres` |

> Note: a few categories are single-skill or use a flat name (`/arib-deep-audit`,
> `/arib-ci-audit`, `/arib-engine`, `/arib-build`, `/arib-nestjs`, `/arib-postgres`)
> rather than the `category-name` form — they predate or sit outside the nested
> filters but still carry the `arib` brand.

---

## Full Command Map (34 skills)

| Skill | Category |
|-------|----------|
| `arib-session-start` | Session |
| `arib-session-end` | Session |
| `arib-io` | Session (I/O Channel bridge) |
| `arib-memory-search` | Session (memory recall) |
| `arib-graph` | Session (code-graph — import graph) |
| `arib-dev-feature` | Dev |
| `arib-dev-debug` | Dev |
| `arib-dev-review` | Dev |
| `arib-dev-lean` | Dev (over-engineering review) |
| `arib-wave-plan` | Wave (pre-wave requirement lock) |
| `arib-wave-start` | Wave |
| `arib-wave-run` | Wave (auto-advancing execution) |
| `arib-wave-end` | Wave |
| `arib-deep-audit` | Audit |
| `arib-check-deploy` | Check |
| `arib-check-services` | Check (infrastructure health) |
| `arib-check-reality` | Check |
| `arib-check-migrate` | Check |
| `arib-check-perf` | Check |
| `arib-check-deps` | Check |
| `arib-check-a11y` | Check |
| `arib-check-design` | Check (design system contract) |
| `arib-check-arabic` | Check (Arabic/RTL) |
| `arib-check-security` | Check (OWASP) |
| `arib-check-compliance` | Check (framework alignment) |
| `arib-ci-audit` | CI |
| `arib-docs-api` | Docs |
| `arib-docs-generate` | Docs |
| `arib-docs-language` | Docs |
| `arib-engine` | Engine (autonomous campaign) |
| `arib-build` | Engine (command the team for a known goal) |
| `arib-plan` | Engine (plan → task mesh across sessions) |
| `arib-nestjs` | Stack (NestJS) |
| `arib-postgres` | Stack (PostgreSQL) |

**Total: 34 skills across 9 categories** (Session 5 · Dev 4 · Wave 4 · Audit 1 ·
Check 11 · CI 1 · Docs 3 · Engine 3 · Stack 2). Authoritative source: CLAUDE.md §4.

---

## Deployment

Skills are **project-local** — they live in `.claude/skills/<name>/SKILL.md` and
need no installer or copy step. During bootstrap the methodology's `.claude/skills/`
is brought into the project as-is; the `arib-` prefix is the official brand, so no
rename is needed.

> Legacy: `.claude/commands/arib-*.md` files are kept for back-compat only and are
> deprecated — skills (`.claude/skills/*/SKILL.md`) are canonical.

---

## Autocomplete Behavior

When you type `/` in Claude Code, the picker shows all commands.
The branded prefix enables **hierarchical filtering**:

The picker filters by the **literal command-name prefix**, so a filter only
matches skills whose name actually starts with it:

```
User types:    Shows:
/              ALL commands from all sources
/arib          ALL 33 ARIB skills
/arib-session  2 skills (session-start, session-end)
/arib-dev      4 skills (feature, debug, review, lean)
/arib-wave     4 skills (plan, start, run, end)
/arib-check    11 skills (deploy, services, reality, migrate, perf, deps, a11y, design, arabic, security, compliance)
/arib-docs     3 skills (api, generate, language)
```

Skills with a flat name don't sit under a `category-` prefix and so surface as
their own top-level filters: `/arib-io`, `/arib-memory-search`, `/arib-graph`,
`/arib-deep-audit`, `/arib-ci-audit`, `/arib-engine`, `/arib-build`,
`/arib-nestjs`, `/arib-postgres`. (This is why the Session category has 5 skills
but `/arib-session` matches only 2 — `io`, `memory-search`, and `graph` are
Session-category but not `arib-session-*` by name.)

This makes skills discoverable without memorizing all 33 names.
