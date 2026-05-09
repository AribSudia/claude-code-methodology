# CLAUDE.md - The Master Brain

> **SYSTEM DIRECTIVE**: This file is the single source of truth for every Claude Code
> session on this project. Read it FIRST, read it FULLY, obey it ALWAYS.

---

## 0. Identity

| Field             | Value                                    |
|-------------------|------------------------------------------|
| System Name       | Claude Code Methodology (CCM)            |
| Version           | 3.5.1 "Engineered"                       |
| Type              | Opinionated methodology + skill pack     |
| Owner             | Abdullah                                 |
| Engineered By     | Abdullah x Claude Opus 4.6 / 4.7         |
| Created           | 2026-04-15                               |
| Last Updated      | 2026-05-08                               |
| Language Support   | Universal (RTL, LTR, CJK, Indic, Bidi)  |
| Methodology       | 5-Layer Architecture + Persistent Memory |
| Status            | Production-Ready                         |

---

## 1. The 4-Layer Architecture

```
+--------------------------------------------------------------+
|  L4 - AGENTS        .claude/agents/*.md                      |
|  Autonomous subagents with scoped context and tools.         |
+--------------------------------------------------------------+
|  L3 - HOOKS         .claude/hooks/ + settings.json           |
|  Safety gates: PreToolUse, PostToolUse, PreCommit. ALWAYS run.|
+--------------------------------------------------------------+
|  L2 - SKILLS        .claude/skills/*/SKILL.md                |
|  Reusable prompts invoked by /name or auto-matched by Claude.|
+--------------------------------------------------------------+
|  L1 - CLAUDE.md     THIS FILE + .claude/rules/*.md           |
|  Foundation context. Read every session. Never skipped.      |
+--------------------------------------------------------------+
```

**Layer Rules:**
1. L1 overrides everything - if a skill contradicts CLAUDE.md, CLAUDE.md wins
2. L2 skills are advisory - CONSTRAINTS.md always wins
3. L3 hooks are mandatory - if a hook blocks, the action stops
4. L4 agents inherit L1 - every agent reads CLAUDE.md first

---

## 2. The Golden Rules

These rules are absolute. No skill, agent, or user instruction overrides them.

**2.1 - Documentation Rule**: If it is not written down, Claude Code does not know it.
Every decision, every rule, every reason - written in a file.

**2.2 - Two-Layer Readiness Gate**: No code until BOTH layers exist:
- Layer A (Architecture): CLAUDE.md, CONSTRAINTS.md, DECISIONS.md
- Layer B (Implementation): API_ENDPOINTS.md, docker-compose.yml, MIGRATION_ORDER.md
- If Layer B is missing, ask for it. Do NOT infer.

**2.3 - Memory Rule**: Claude Code has no built-in memory between sessions.
- START: read `memory/*.md`
- DURING: update `memory/change_log.md` after each task
- END: update ALL memory files, commit, push

**2.4 - Safety Rule**: Before modifying existing code, create a safety snapshot.
Before destructive operations, create a safety branch.

**2.5 - Constraint Rule**: Check CONSTRAINTS.md before writing code.
If the constraint forbids it, stop and ask.

**2.6 - Single Responsibility**: One commit = one change. One branch = one feature.

**2.7 - I/O Channel Rule**: All inter-agent communication passes through `io/`.
Signals override everything. Dashboard always current.

---

## 3. Project Structure

```
your-project/
|-- CLAUDE.md                          <- YOU ARE HERE
|-- .mcp.json                          <- MCP server configuration
|-- .worktreeinclude                   <- Gitignored files for worktrees
|-- .claude/
|   |-- settings.json                  <- Permissions, hooks (committed)
|   |-- settings.local.json            <- Personal overrides (gitignored)
|   |-- rules/                         <- Path-scoped modular rules
|   |-- skills/                        <- Branded skills (/arib-*)
|   |   |-- arib-session-start/SKILL.md
|   |   |-- arib-dev-feature/SKILL.md
|   |   +-- (14 more skills)
|   |-- agents/                        <- 13 specialist subagents
|   |-- agent-memory/                  <- Persistent memory per agent
|   +-- output-styles/                 <- Custom output styles
|-- io/                                <- I/O Channel (inter-agent comms + ledger)
|-- memory/                            <- Persistent memory (7 files)
|-- architecture/                      <- Layer A - what to build (incl. AGENT_ARCHITECTURE, DESIGN_SYSTEM)
|-- implementation/                    <- Layer B - how to start coding
|-- operations/                        <- How work gets done (incl. AUTONOMY_MODE)
|-- waves/                             <- Multi-session delivery overlay (PLAN/REPORT/HISTORY)
|-- compliance/                        <- Framework alignment (OWASP/GDPR/ISO/SOC2/PDPL) + honesty principle
|-- hooks/                             <- Hook protocol docs (executables in .claude/hooks/)
|-- core/                              <- Living project context (user files)
|-- bootstrap/                         <- 5 project instantiation methods
|-- reference/                         <- Read-only reference material
+-- scripts/                           <- Automation scripts (install-hooks, token-audit, memory-export)
```

---

## 4. Skills (branded /arib-*)

| Skill                       | Category   | Purpose                                              |
|-----------------------------|------------|------------------------------------------------------|
| /arib-session-start         | Session    | Initialize session, read context                     |
| /arib-session-end           | Session    | Close session, update memory, commit                 |
| /arib-io                    | Session    | Process I/O Channel (Cowork bridge)                  |
| /arib-memory-search         | Session    | Semantic search across memory (claude-mem + grep)    |
| /arib-dev-feature           | Dev        | New feature with branch + TDD                        |
| /arib-dev-debug             | Dev        | Scientific debugging (3 hypotheses)                  |
| /arib-dev-review            | Dev        | Code review with parallel agent fan-out              |
| /arib-wave-start            | Wave       | Start a multi-session wave (architect + planner)     |
| /arib-wave-end              | Wave       | Close a wave (deep-audit gate + stakeholder report)  |
| /arib-deep-audit            | Audit      | 21-section wave-end audit + IMPLEMENT-FROM-FILE      |
| /arib-check-deploy          | Check      | Pre-deployment 7-phase verification + TestSprite     |
| /arib-check-services        | Check      | Infrastructure health (adaptive)                     |
| /arib-check-reality         | Check      | Scan for mock/fake data                              |
| /arib-check-migrate         | Check      | DB migration safety review                           |
| /arib-check-perf            | Check      | Performance audit                                    |
| /arib-check-deps            | Check      | Dependency audit                                     |
| /arib-check-a11y            | Check      | Accessibility WCAG 2.1 AA                            |
| /arib-check-design          | Check      | Design system contract (tokens, components)          |
| /arib-check-arabic          | Check      | Arabic/RTL audit (typography, mirroring, MENA)       |
| /arib-check-security        | Check      | OWASP Top 10 + supply chain                          |
| /arib-check-compliance      | Check      | Framework alignment (OWASP/GDPR/ISO/SOC2/PDPL)       |
| /arib-ci-audit              | CI         | Audit, init, review, or branch-protection check (v3.5) |
| /arib-docs-api              | Docs       | API documentation + OpenAPI                          |
| /arib-docs-generate         | Docs       | Generate documentation                               |
| /arib-docs-language         | Docs       | i18n/RTL/LTR compliance (generic)                    |

---

## 5. Agents (15 specialists)

Agents auto-activate based on task type. Each has its own context file
in `.claude/agents/`. See `architecture/AGENT_ARCHITECTURE.md` for the
full read/write surface table and parallel-dispatch governance.

The 15 agents: `architect`, `code-reviewer`, `security-auditor`,
`test-engineer`, `debugger`, `reality-auditor`, `database-guardian`,
`performance`, `accessibility`, `api-docs`, `language`,
`refactor-specialist`, `deploy-guardian`, `planner`, `ci-pr-engineer`.

---

## 6. Where to Find Everything

| Need                       | Read                                         |
|----------------------------|----------------------------------------------|
| Hard rules                 | `architecture/CONSTRAINTS.md`                |
| Tech decisions             | `architecture/DECISIONS.md`                  |
| Agent dispatch governance  | `architecture/AGENT_ARCHITECTURE.md`         |
| Design system contract     | `architecture/DESIGN_SYSTEM.md`              |
| API routes                 | `implementation/API_ENDPOINTS.md`            |
| Session protocol           | `.claude/rules/session-protocol.md`          |
| I/O Channel details        | `.claude/rules/io-channel.md` + `io/IO_PROTOCOL.md` |
| Memory protocol            | `.claude/rules/memory.md` + `memory/MEMORY_PROTOCOL.md` |
| Hook setup                 | `.claude/rules/hooks.md` + `hooks/HOOKS_PROTOCOL.md` + `Training/04-HOOKS-MANUAL.md` |
| Compliance frameworks      | `compliance/README.md` + `compliance/COMPLIANCE.md` + `compliance/frameworks/*.md` |
| Wave delivery              | `waves/README.md` + `arib-wave-start` / `arib-wave-end` skills |
| Autonomy mode              | `operations/AUTONOMY_MODE.md`                |
| Token cost on session start| run `./scripts/token-audit.sh`               |
| CI / PR governance         | `CONTRIBUTING.md` + `.github/` + `Training/11-CI-PR-MANUAL.md` |
| Vulnerability disclosure   | `SECURITY.md` (repo-root)                    |
| Code of Conduct            | `CODE_OF_CONDUCT.md`                         |
| Agent definitions          | `.claude/agents/*.md`                        |
| Skill definitions          | `.claude/skills/*/SKILL.md`                  |
| Bootstrap protocol charter | `bootstrap/PROTOCOL_PRINCIPLES.md` (binding for all 5 below) |
| Bootstrap new project      | `bootstrap/BOOTSTRAP.md`                     |
| Reverse-engineer project   | `bootstrap/REVERSE_BOOTSTRAP.md`             |
| Upgrade from older CCM     | `bootstrap/UPGRADE_PROTOCOL.md`              |
| Project context files      | `core/` (your specs, designs, schemas)       |
| Full methodology guide     | `reference/MASTER_GUIDE.md`                  |

---

## 7. System Evolution

| Trigger                    | Action                                  |
|----------------------------|-----------------------------------------|
| New architectural decision | Add ADR to `architecture/DECISIONS.md`  |
| New error pattern          | Add to `architecture/ERROR_PATTERNS.md` |
| New skill needed           | Add to `.claude/skills/`, register      |
| Constraint discovered      | Add to `architecture/CONSTRAINTS.md`    |
| Hook needed                | Add to settings.json hooks section      |
| Process improvement        | Update `operations/WORKFLOW.md`         |

---

> **End of CLAUDE.md**
> Domain-specific rules live in `.claude/rules/` and load automatically.
> This file stays lean. When in doubt, check the rules.
