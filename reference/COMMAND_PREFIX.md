# Branded Command Naming System

> **Version**: v2.7.0+
> **Purpose**: All projects use the official `arib` brand for slash commands with hierarchical categories.

---

## How It Works

Commands use the pattern: `/arib-{category}-{name}`

```
/arib-session-start       ← type /arib → see ALL commands
/arib-dev-feature          ← type /arib-dev → see dev commands only
/arib-check-deploy         ← type /arib-check → see audit commands only
/arib-docs-api             ← type /arib-docs → see docs commands only
```

## Brand

The official command prefix is **`arib`** — used across all projects.

| Brand | Prefix | Example |
|-------|--------|---------|
| ARIB (official) | `arib` | `/arib-session-start` |

---

## Command Categories

| Category | Commands | Autocomplete filter |
|----------|----------|---------------------|
| **session** | start, end, io | `/arib-session` |
| **dev** | feature, debug, review | `/arib-dev` |
| **check** | deploy, services, reality, migrate, perf, deps, a11y | `/arib-check` |
| **docs** | api, generate, language | `/arib-docs` |

---

## Full Command Map (15 commands)

### Full Command List (15 commands)

| File | Category |
|------|----------|
| `arib-session-start.md` | Session |
| `arib-session-end.md` | Session |
| `arib-io.md` | Session (I/O Channel bridge) |
| `arib-dev-feature.md` | Dev |
| `arib-dev-debug.md` | Dev |
| `arib-dev-review.md` | Dev |
| `arib-check-deploy.md` | Check |
| `arib-check-services.md` | Check (infrastructure health) |
| `arib-check-reality.md` | Check |
| `arib-check-migrate.md` | Check |
| `arib-check-perf.md` | Check |
| `arib-check-deps.md` | Check |
| `arib-check-a11y.md` | Check |
| `arib-docs-api.md` | Docs |
| `arib-docs-generate.md` | Docs |
| `arib-docs-language.md` | Docs |

---

## Deployment

During bootstrap, commands are copied from the methodology to the project root:

```bash
# Copy arib-* commands to project root
cp claude-code-methodology/.claude/commands/arib-*.md .claude/commands/
```

No rename needed — the `arib-` prefix is the official brand for all projects.

---

## Autocomplete Behavior

When you type `/` in Claude Code, the picker shows all commands.
The branded prefix enables **hierarchical filtering**:

```
User types:    Shows:
/              ALL commands from all sources
/arib          ALL 14 ARIB commands
/arib-session  2 commands (start, end)
/arib-dev      3 commands (feature, debug, review)
/arib-check    6 commands (deploy, reality, migrate, perf, deps, a11y)
/arib-docs     3 commands (api, generate, language)
```

This makes commands discoverable without memorizing all 14 names.
