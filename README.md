# Claude Code Methodology (CCM)

### An opinionated methodology and skill pack for Claude Code

A convention layer for serious work in Claude Code: 26 branded `/arib-*` skills,
15 specialist agents, kernel-level enforcement hooks, path-scoped rules, persistent
memory files, a 5-mode bootstrap, a wave delivery overlay with auto-advancing
execution, a compliance layer, and full CI/PR governance. It is **not** a runtime,
an orchestrator, or a kernel — it is a set of conventions that make multi-session
Claude Code work durable.

**v3.8.0 "Lean Core"** · Engineered by Abdullah x Claude · Always-on token cost on session start: ~7.4K
(measure yours: `./scripts/token-audit.sh` — down from ~45.9K; reference docs load on demand)

> **What changed in v3.8.0 "Lean Core"** — the headline fix. Always-on
> session-start context cut **~45.9K → ~7.4K tokens (84%)** — UNDER the 8K
> target for the first time. Only the master brain, hard rules, and current
> state/handoff stay always-on; every reference doc (DECISIONS, SECURITY,
> ERROR_PATTERNS, schemas, etc.) loads **on demand** via the skill/agent
> that needs it (map in CLAUDE.md §6). This was the single defect keeping
> CCM at C+; ADR-019 records it. `project_status.md` rewritten lean
> (history → CHANGELOG). The 26-skill audit + dev-feature `develop`-branch
> blocker shipped in v3.7.2.
>
> **What changed in v3.7.1 (patch)** — closes the review's deferred
> P2/P3 findings: `memory-export.sh` no longer writes failure strings
> into the git-committed audit trail (honest header + last-known-good
> preserved); a **real drift classifier** (`gen-template-hashes.sh` +
> `reference/template-hashes.json` + `drift-detect.sh`) replaces the
> upgrade heuristic that could overwrite user edits; hook hardening
> (whitespace-normalized bash matching, `git push -f`, Stripe/GitLab/
> npm/JWT secret patterns); the session ledger now records transport +
> notifications; stale counts in SYSTEM.md/Training corrected. ADR-018.
>
> **What changed in v3.7** — a 23-agent review of CCM found that the
> system did not fully live up to its own principles, and v3.7 fixes the
> critical gaps. **The enforcement layer now actually enforces**:
> `block()` was using `exit 1` (which Claude Code treats as *non-blocking*)
> — fixed to `exit 2`, so secret/dangerous-bash/OWASP/design-token/
> wave-merge gates finally block instead of warn. **All 15 agents got YAML
> frontmatter** so Claude Code can register them as dispatchable subagents
> (they were prose before). **New `scripts/validate-coherence.sh` + CI**
> self-polices the invariants CCM preaches (counts match disk, agent
> frontmatter valid, version coherent, no stale tokens, references
> resolve). The token metric is now **honest** (always-on vs path-scoped
> separated; the stale ~39.6K corrected to ~43.4K). Three "documented but
> unwired" claims were wired or downgraded. ADR-016 + ADR-017 record it.
>
> **What changed in v3.6** — waves now execute themselves. New
> `/arib-wave-run` skill reads the wave PLAN's Steps contract and
> **auto-advances** from step to step without asking "continue?" between
> them. It pauses only on a real issue (failed step), an explicit
> `checkpoint: true` step (irreversible/high-stakes), genuine ambiguity,
> a blocker, an autonomy-guard trip, or a user interrupt. One commit per
> step; `/arib-wave-end` stays the explicit finish-line gate. Extends
> the v3.5.1 decisive discipline from bootstrap protocols into wave
> execution. ADR-015 records it. See
> [arib-wave-run](.claude/skills/arib-wave-run/SKILL.md).
>
> **What changed in v3.5.1 (patch)** — fixes a bug across all 5 bootstrap
> protocols: same-version runs no longer terminate prematurely. Adds
> `bootstrap/PROTOCOL_PRINCIPLES.md` (binding charter), a new mandatory
> Phase 1.5 (drift detection) in `UPGRADE_PROTOCOL.md`, ADR-014, and
> methodology constraint #11. Forbidden anti-patterns enumerated:
> "STOP on matching versions", "your options are 1, 2, 3" multiple-choice
> menus, asking the user about determinable things.
>
> **What changed in v3.5** — CI/PR is now an executable subsystem, not
> just static configuration. New `ci-pr-engineer` agent (15th in the
> inventory) and `/arib-ci-audit` skill with four modes: `audit`
> (default), `init` (bootstrap CI/PR for a fresh project), `review
> <file>` (focused PR-review aid), `branch-protection` (live `gh api`
> check against the binding settings). Output goes to
> `io/ledger/ci-pr-<mode>-<date>.md` with the same audit-trail format
> as `/arib-deep-audit`. ADR-013 records the decision. CCM now follows
> the same agent+skill pattern for CI/PR as it uses for code review,
> compliance, and waves.
>
> v3.4 "Reviewed" (previous): adopted GitHub PR/CI governance as
> first-class methodology — PR template, issue templates, CODEOWNERS,
> four CI workflows, Dependabot, CONTRIBUTING.md, repo-root SECURITY.md,
> CODE_OF_CONDUCT.md. v3.3 "Operating" (before that): the 8 deferred
> items from the original Enforced proposal shipped with honest framing.
> See [Training/11-CI-PR-MANUAL.md](Training/11-CI-PR-MANUAL.md),
> [CONTRIBUTING.md](CONTRIBUTING.md),
> [CHANGELOG](CHANGELOG.md), [compliance/README.md](compliance/README.md),
> and [proposals/archive/](proposals/archive/) for context.

```
 ╔═══════════════════════════════════════════════════════════════════╗
 ║                                                                   ║
 ║   YOUR PROJECT  ──▶  claude-code-methodology/  ──▶  EXCELLENCE   ║
 ║                                                                   ║
 ║   New project?      ──▶  Bootstrap Protocol (25 questions)       ║
 ║   Existing project? ──▶  Reverse Bootstrap (auto-scan)           ║
 ║   Old CCM version?  ──▶  Upgrade Protocol (preserve + update)    ║
 ║   Old code-system?  ──▶  Migration Guide (6-phase migration)     ║
 ║   Overlay on legacy ──▶  Reengineering Guide                     ║
 ║                                                                   ║
 ╚═══════════════════════════════════════════════════════════════════╝
```

---

## Why This Exists

Claude Code is powerful — but without structure, every session starts from zero. Decisions get re-debated. Architecture drifts. Bugs come back. Context is lost.

This methodology solves all of that:

| Problem                          | Solution                                     |
|----------------------------------|----------------------------------------------|
| Claude forgets between sessions  | **Persistent Memory** — 6 file types, auto-updated |
| No consistent code quality       | **15 Specialist Agents** — each with checklists |
| Dangerous operations slip through| **Safety Hooks** — block before damage happens |
| Every session starts from scratch| **Session Protocol** — read → work → write    |
| Architecture decisions are lost  | **Decision Records** — permanent, searchable  |
| "It works on my machine"         | **Implementation Layer** — docker, runbook, env|
| Skills are shallow checklists    | **Deep Skills** — 7,393 lines of reference docs |

---

## The 4-Layer Architecture

```
╔══════════════════════════════════════════════════════════════╗
║  L4 — AGENTS          15 specialists with scoped context    ║
║  Architect · Security · Reviewer · Tester · Debugger        ║
║  Refactor · Language · Deploy Guardian · Reality Auditor     ║
║  Database Guardian · Performance · API Docs · Accessibility  ║
╠══════════════════════════════════════════════════════════════╣
║  L3 — HOOKS           Safety gates & automation             ║
║  PreToolUse · PostToolUse · PreCommit · Notification        ║
╠══════════════════════════════════════════════════════════════╣
║  L2 — SKILLS          26 branded /arib-* deep reference     ║
║  Session · Dev · Check · Docs (7,393 lines total)           ║
╠══════════════════════════════════════════════════════════════╣
║  I/O — CHANNEL        Inter-agent nervous system            ║
║  Requests · Results · Signals · Pipelines · Threads         ║
╠══════════════════════════════════════════════════════════════╣
║  L1 — CLAUDE.md       The Master Brain (179 lines)          ║
║  + .claude/rules/ (9 path-scoped rule files)                ║
╚══════════════════════════════════════════════════════════════╝
```

**L1 overrides everything.** Skills advise, hooks enforce, agents execute — but `CLAUDE.md` governs all.

---

## 5 Use Cases

### Use Case 1: New Project (Starting from Zero)

You have an idea but no code. CCM gives you a fully structured project with all architecture, constraints, memory, and CI/CD from day one.

```bash
# 1. Clone the methodology
git clone https://github.com/AribSudia/claude-code-methodology.git
cp -r claude-code-methodology/ my-new-project/
cd my-new-project

# 2. Open Claude Code and paste the bootstrap prompt from bootstrap/BOOTSTRAP.md
#    Claude asks 25 questions about your project (name, stack, features, auth, DB...)
#    Then generates ALL methodology files filled with YOUR real data

# 3. Start building
#    Type: /arib-session-start
#    Claude reads everything, knows your project, and begins
```

**What you get**: Every file populated — CONSTRAINTS.md with your rules, TECH_STACK.md with your libraries, API_ENDPOINTS.md with your routes, CONTEXT_MAP.md with your folders, and all 13 agents configured for your stack.

### Use Case 2: Existing Project (Reverse Bootstrap)

You have a codebase but no structure. CCM auto-scans everything and generates methodology files from your actual code.

```bash
# 1. Copy methodology into your existing project
git clone https://github.com/AribSudia/claude-code-methodology.git
cp -r claude-code-methodology/* /path/to/your-existing-project/
cd /path/to/your-existing-project

# 2. Create a safety branch
git checkout -b methodology/overlay

# 3. Open Claude Code and paste the prompt from bootstrap/REVERSE_BOOTSTRAP.md
#    Claude auto-scans your ENTIRE codebase (10-step analysis):
#      → Discovers tech stack from package.json / *.csproj / requirements.txt
#      → Extracts database entities from schema/models
#      → Maps every API route from controllers
#      → Analyzes auth system, business logic, git history
#      → Generates all methodology files with YOUR REAL DATA

# 4. Start working with full context
#    Type: /arib-session-start
```

### Use Case 3: Upgrading from Older CCM Version

You're on v2.x and want v3.1. The upgrade protocol preserves all your project data.

```bash
# Open Claude Code and paste bootstrap/UPGRADE_PROTOCOL.md
# Claude:
#   1. Backs up your current files
#   2. Copies new structure (skills, rules, .mcp.json)
#   3. Preserves all your memory files, architecture, and implementation
#   4. Migrates commands → skills automatically
#   5. Validates everything works
```

### Use Case 4: Legacy System Migration

You used the old `claude-code-system` and want to move to CCM.

```bash
# Open Claude Code and paste bootstrap/MIGRATION_GUIDE.md
# 6-phase migration: Preparation → Backup → Structure → Content → Validation → Cleanup
```

### Use Case 5: Overlay on Legacy Codebase (Reengineering)

You have a legacy project with tech debt and want to gradually introduce the methodology without breaking anything.

```bash
# Open Claude Code and paste bootstrap/REENGINEERING_GUIDE.md
# Adds methodology as an overlay — non-destructive, incremental adoption
```

### Copy-Paste Prompts (Ready to Use)

Just paste one of these directly into Claude Code to get started:

**New Project:**
```
Read claude-code-methodology/bootstrap/BOOTSTRAP.md and execute the full bootstrap protocol for this new project.
```

**Existing Project:**
```
Read claude-code-methodology/bootstrap/REVERSE_BOOTSTRAP.md and execute the full reverse bootstrap protocol on this existing codebase.
```

**Version Upgrade:**
```
Read claude-code-methodology/bootstrap/UPGRADE_PROTOCOL.md and execute the full upgrade protocol.
```

**Legacy Migration:**
```
Read claude-code-methodology/bootstrap/MIGRATION_GUIDE.md and execute the full migration protocol.
```

---

## The 16 /arib-* Skills

All skills are deep reference documents (250-800 lines each) with decision trees, examples, templates, edge cases, and common mistakes. They live in `.claude/skills/arib-*/SKILL.md`.

### Session Skills

| Skill | Command | What It Does | Lines |
|-------|---------|-------------|-------|
| **Session Start** | `/arib-session-start` | Initialize session — read context, check I/O, report status, wait for approval | 302 |
| **Session End** | `/arib-session-end` | Close session — update memory, run tests, commit, push, report next steps | 448 |
| **I/O Channel** | `/arib-io` | Process signals from Cowork, execute requests, write results, update dashboard | 799 |

### Development Skills

| Skill | Command | What It Does | Lines |
|-------|---------|-------------|-------|
| **Feature Dev** | `/arib-dev-feature <name>` | Start feature with branch, TDD, safety snapshot, implementation plan | 253 |
| **Code Review** | `/arib-dev-review <target>` | 8-gate review — function length, duplication, security, tests, docs | 569 |
| **Debug** | `/arib-dev-debug <issue>` | Scientific debugging — observe, 3 hypotheses, binary search, root cause | 327 |

### Check Skills (Audits & Verification)

| Skill | Command | What It Does | Lines |
|-------|---------|-------------|-------|
| **Accessibility** | `/arib-check-a11y <component>` | WCAG 2.1 AA audit — contrast, ARIA, keyboard, screen reader | 453 |
| **Deploy** | `/arib-check-deploy` | 7-phase pre-deployment verification — CLEARED or BLOCKED | 481 |
| **Dependencies** | `/arib-check-deps` | CVE scan, license compliance, supply chain safety, auto-fix | 484 |
| **Migration** | `/arib-check-migrate <file>` | Database migration safety — lock analysis, dangerous patterns, rollback | 386 |
| **Performance** | `/arib-check-perf <scope>` | N+1 queries, bundle size, memory leaks, caching, latency budgets | 328 |
| **Reality** | `/arib-check-reality <scope>` | Detect mock data, fake APIs, hardcoded responses — Reality Score | 412 |
| **Services** | `/arib-check-services` | Infrastructure health — adapts to project type, checks only what exists | 414 |

### Documentation Skills

| Skill | Command | What It Does | Lines |
|-------|---------|-------------|-------|
| **API Docs** | `/arib-docs-api <scope>` | Discover endpoints, generate OpenAPI spec, detect undocumented routes | 396 |
| **Doc Generator** | `/arib-docs-generate <target>` | Generate or update documentation — JSDoc, README, architecture docs | 575 |
| **Language/i18n** | `/arib-docs-language <component>` | Universal i18n audit — RTL, LTR, CJK, Indic, fonts, formatting | 766 |

**Total Skill Content**: 7,393 lines of deep reference documentation.

### How to Use a Skill

In Claude Code, just type the command:

```
/arib-session-start                    ← Start every session with this
/arib-dev-feature user-authentication  ← Begin a new feature
/arib-dev-review feature/user-auth     ← Review before merging
/arib-check-perf backend              ← Performance audit
/arib-session-end                      ← End every session with this
```

Each skill guides Claude Code through a complete protocol — reading context, checking constraints, executing the task, and documenting results.

---

## The 13 Specialist Agents

Agents activate automatically based on keywords in your instructions. Each operates with a specific checklist and delivers a structured output.

| Agent                 | Activates On                    | Delivers                                |
|-----------------------|---------------------------------|-----------------------------------------|
| **Architect**         | "design", "plan", "schema"      | Design → Trade-offs → Approval gate     |
| **Security Auditor**  | auth, payments, user data       | OWASP audit report (pass/fail)          |
| **Code Reviewer**     | "review", PRs, before merge     | APPROVED or NEEDS CHANGES               |
| **Test Engineer**     | "test", "coverage"              | Test files + coverage report            |
| **Debugger**          | "bug", "broken", "error"        | 3 hypotheses → isolated fix → documented|
| **Refactor**          | "refactor", "cleanup"           | Snapshot → improve → verify behavior    |
| **Language**          | "i18n", "RTL", any locale/script| Universal language compliance report     |
| **Reality Auditor**   | "mock", "fake", "real data"     | Reality Score + remediation plan        |
| **Database Guardian** | "migration", "schema", "ALTER"  | APPROVED or BLOCKED + safe alternatives |
| **Perf Profiler**     | "slow", "N+1", "bundle size"    | Performance Audit Report + budgets      |
| **API Docs**          | "API docs", "OpenAPI", "Swagger"| OpenAPI spec + sync report              |
| **Accessibility**     | "a11y", "WCAG", "screen reader" | WCAG AA compliance report               |
| **Deploy Guardian**   | "deploy", "ship", "release"     | CLEARED or BLOCKED with reasons         |

Agent definitions live in `.claude/agents/`.

---

## Core Project Context

The `core/` directory contains **living project context** — the strategic business information that shapes every technical decision.

```
core/
└── CORE_CONTEXT.md    ← Business overview, stakeholders, domain terminology,
                          success metrics, timeline, constraints, and strategic goals
```

This file is read during bootstrap and referenced by agents. It ensures Claude Code understands not just *what* to build but *why* — business goals, user personas, domain language, and success criteria. Updated as the project evolves.

---

## Training Manuals (10 Guides)

The `Training/` directory contains **10 comprehensive user manuals** — everything a developer needs to learn and master the methodology.

| Manual | File | What It Covers |
|--------|------|----------------|
| **01 — System Overview** | `Training/01-SYSTEM-OVERVIEW.md` | Complete system architecture, how all layers connect, mental model |
| **02 — Agents Manual** | `Training/02-AGENTS-MANUAL.md` | All 13 agents explained — triggers, checklists, outputs, customization |
| **03 — Skills Manual** | `Training/03-SKILLS-MANUAL.md` | Skills system — how they work, how to use /arib-* commands |
| **04 — Hooks Manual** | `Training/04-HOOKS-MANUAL.md` | Safety hooks — 6 types, 7 recipes, configuration, custom hooks |
| **05 — Commands Manual** | `Training/05-COMMANDS-MANUAL.md` | All slash commands explained with examples and workflows |
| **06 — I/O Channel Manual** | `Training/06-IO-CHANNEL-MANUAL.md` | Inter-agent communication — requests, signals, pipelines, templates |
| **07 — Memory Manual** | `Training/07-MEMORY-MANUAL.md` | Memory system — 7 file types, update rules, archival, continuity |
| **08 — Bootstrap Manual** | `Training/08-BOOTSTRAP-MANUAL.md` | All 5 bootstrap methods — new, existing, upgrade, migrate, reengineer |
| **09 — Microservices Manual** | `Training/09-MICROSERVICES-MANUAL.md` | Microservices extension — service map, contracts, orchestration |
| **10 — Production Safety** | `Training/10-PRODUCTION-SAFETY-MANUAL.md` | Incident response, monitoring, SLOs, on-call, post-mortems |

Start with **Manual 01** for the big picture, then dive into whichever area you need.

---

## The I/O Channel — Inter-Agent Nervous System

Enables **structured, traceable communication** between Claude Cowork, Claude Code, human operators, and CI/CD.

```
COWORK (Critical Eye)                    CLAUDE CODE (Executing Hand)
      │                                         │
      ├── writes request ──────────────────────▶│
      │   io/requests/audit-auth-2026-04-17.md  ├── reads, executes audit
      │                                         ├── writes result
      │◀──────────────────── result ────────────┤
      │   io/results/audit-auth-...-result.md   │
      │                                         │
      ├── SIGNAL (emergency) ──────────────────▶│
      │   io/signals/halt-2026-04-17-001.md     ├── DROPS everything, responds
      │                                         │
      ├── PIPELINE (multi-step) ───────────────▶│
      │   io/pipelines/pre-release-...md        ├── executes step 1→2→3→4
      │                                         │
      └── THREAD (follow-up) ◀────────────────▶└── discussion on findings
```

---

## Path-Scoped Rules

Instead of a massive CLAUDE.md, domain rules live in `.claude/rules/` and **only load when relevant files are touched**:

| Rule File | Loads When | What It Governs |
|-----------|-----------|-----------------|
| `session-protocol.md` | Always | Session start/work/end lifecycle |
| `memory.md` | `memory/**` touched | Memory hierarchy, update rules |
| `io-channel.md` | `io/**` touched | I/O architecture, request types, signals |
| `agents.md` | `.claude/agents/**` touched | Agent activation and rules |
| `hooks.md` | `hooks/**` touched | Hook types, configuration, exit codes |
| `architecture.md` | `architecture/**` touched | Architecture layer rules |
| `implementation.md` | `implementation/**` touched | Implementation layer rules |

This keeps CLAUDE.md at 179 lines (under the 200-line best practice) while preserving all domain knowledge.

---

## The 7 Golden Rules

| #  | Rule                                        | Why                                  |
|----|---------------------------------------------|--------------------------------------|
| 1  | **If it's not written, Claude doesn't know** | Document everything                  |
| 2  | **Both layers before coding**                | Architecture + Implementation        |
| 3  | **Memory at every boundary**                 | Read at start, write during, commit at end |
| 4  | **Safety snapshot before modifying**          | Always recoverable                   |
| 5  | **Constraints are absolute**                 | No agent or skill overrides them     |
| 6  | **One commit = one change**                  | Atomic, traceable, reversible        |
| 7  | **All agent talk goes through io/**          | Traceable, structured, no exceptions |

---

## Session Lifecycle

Every Claude Code session follows this protocol:

```
/arib-session-start
    │
    ├── SCAN: I/O channel for signals and pending requests
    ├── READ: CLAUDE.md + Constraints + Tech Stack + Memory
    ├── CHECK: git status, branch, recent commits, services
    ├── REPORT: current state, proposed plan
    └── WAIT: for user approval
         │
         ▼
    WORK PHASE
    │
    ├── For each task:
    │   ├── Announce → Check constraints → Safety snapshot
    │   ├── Implement (TDD: Red → Green → Refactor)
    │   ├── Test → Log change → Commit
    │   └── Report completion
    │
    ▼
/arib-session-end
    │
    ├── WRITE: Update all memory files
    ├── TEST: Run final tests
    ├── COMMIT: Session-end commit
    ├── PUSH: To remote
    └── REPORT: Completed · Issues · Next
```

---

## What's Inside (Complete File Tree)

```
claude-code-methodology/                  ← v3.3 "Operating" — see VERSION.json for stats
│
├── CLAUDE.md                             ← The Master Brain (179 lines)
├── SYSTEM.md                             ← Full system spec (135 features)
├── VERSION.json                          ← Version metadata + stats
├── CHANGELOG.md                          ← Full version history (v1.0 → v3.1)
├── .mcp.json                             ← MCP server configuration
├── .worktreeinclude                      ← Files to include in worktrees
│
├── .claude/
│   ├── settings.json                     ← Claude Code configuration
│   ├── settings.local.json               ← Personal overrides (gitignored)
│   ├── rules/                            ← 7 path-scoped rule files
│   │   ├── session-protocol.md           ← Always loaded
│   │   ├── memory.md                     ← Loads on memory/** changes
│   │   ├── io-channel.md                 ← Loads on io/** changes
│   │   ├── agents.md                     ← Loads on agents/** changes
│   │   ├── hooks.md                      ← Loads on hooks/** changes
│   │   ├── architecture.md               ← Loads on architecture/** changes
│   │   └── implementation.md             ← Loads on implementation/** changes
│   ├── skills/                           ← 16 branded deep-reference skills
│   │   ├── arib-session-start/SKILL.md   ← /arib-session-start (302 lines)
│   │   ├── arib-session-end/SKILL.md     ← /arib-session-end (448 lines)
│   │   ├── arib-io/SKILL.md              ← /arib-io (799 lines)
│   │   ├── arib-dev-feature/SKILL.md     ← /arib-dev-feature (253 lines)
│   │   ├── arib-dev-review/SKILL.md      ← /arib-dev-review (569 lines)
│   │   ├── arib-dev-debug/SKILL.md       ← /arib-dev-debug (327 lines)
│   │   ├── arib-check-a11y/SKILL.md      ← /arib-check-a11y (453 lines)
│   │   ├── arib-check-deploy/SKILL.md    ← /arib-check-deploy (481 lines)
│   │   ├── arib-check-deps/SKILL.md      ← /arib-check-deps (484 lines)
│   │   ├── arib-check-migrate/SKILL.md   ← /arib-check-migrate (386 lines)
│   │   ├── arib-check-perf/SKILL.md      ← /arib-check-perf (328 lines)
│   │   ├── arib-check-reality/SKILL.md   ← /arib-check-reality (412 lines)
│   │   ├── arib-check-services/SKILL.md  ← /arib-check-services (414 lines)
│   │   ├── arib-docs-api/SKILL.md        ← /arib-docs-api (396 lines)
│   │   ├── arib-docs-generate/SKILL.md   ← /arib-docs-generate (575 lines)
│   │   └── arib-docs-language/SKILL.md   ← /arib-docs-language (766 lines)
│   ├── agents/                           ← 15 specialist agent definitions
│   │   ├── architect.md                  ← System design authority
│   │   ├── security-auditor.md           ← OWASP Top 10 expert
│   │   ├── code-reviewer.md              ← Quality gatekeeper
│   │   ├── test-engineer.md              ← TDD specialist
│   │   ├── debugger.md                   ← Scientific debugging
│   │   ├── refactor-specialist.md        ← Safe code improvement
│   │   ├── language.md                   ← Universal i18n specialist
│   │   ├── reality-auditor.md            ← Mock data detector
│   │   ├── database-guardian.md          ← Migration safety
│   │   ├── performance.md                ← N+1 & performance budgets
│   │   ├── api-docs.md                   ← OpenAPI generator
│   │   ├── accessibility.md              ← WCAG 2.1 AA auditor
│   │   └── deploy-guardian.md            ← Deployment gatekeeper
│   ├── commands/                         ← 16 legacy commands (deprecated, backward compat)
│   ├── agent-memory/                     ← Persistent memory per subagent
│   └── output-styles/                    ← Custom output styles
│
├── core/                                 ← Living project context
│   └── CORE_CONTEXT.md                   ← Business goals, stakeholders, domain terms
│
├── Training/                             ← 10 comprehensive user manuals
│   ├── 01-SYSTEM-OVERVIEW.md             ← Complete system architecture
│   ├── 02-AGENTS-MANUAL.md               ← All 13 agents explained
│   ├── 03-SKILLS-MANUAL.md               ← Skills system & /arib-* commands
│   ├── 04-HOOKS-MANUAL.md                ← Safety hooks — 6 types, 7 recipes
│   ├── 05-COMMANDS-MANUAL.md             ← All slash commands with examples
│   ├── 06-IO-CHANNEL-MANUAL.md           ← Inter-agent communication
│   ├── 07-MEMORY-MANUAL.md               ← Memory system & continuity
│   ├── 08-BOOTSTRAP-MANUAL.md            ← All 5 bootstrap methods
│   ├── 09-MICROSERVICES-MANUAL.md        ← Microservices extension
│   └── 10-PRODUCTION-SAFETY-MANUAL.md    ← Incident response & monitoring
│
├── memory/                               ← Persistent memory system
│   ├── MEMORY_PROTOCOL.md                ← How memory works
│   ├── project_status.md                 ← Where the project stands
│   ├── session_notes.md                  ← Session handoff log
│   ├── change_log.md                     ← Chronological changes
│   ├── architecture_decisions.md         ← ADRs (why things are this way)
│   ├── bugs_and_fixes.md                 ← Bug pattern database
│   └── testing_log.md                    ← Test results & coverage
│
├── architecture/                         ← What to build
│   ├── CONSTRAINTS.md                    ← Rules that must never break
│   ├── TECH_STACK.md                     ← Approved technologies only
│   ├── CONTEXT_MAP.md                    ← Folder structure & data flows
│   ├── ERROR_PATTERNS.md                 ← Universal pitfalls + prevention
│   ├── DECISIONS.md                      ← Architecture Decision Records
│   ├── SECURITY.md                       ← Security specification
│   ├── WORKFLOW.md                       ← Branch strategy & conventions
│   ├── SERVICE_MAP.md                    ← [Microservices] Service registry
│   └── INTER_SERVICE.md                  ← [Microservices] Communication patterns
│
├── implementation/                       ← How to start coding
│   ├── API_ENDPOINTS.md                  ← Complete route inventory
│   ├── docker-compose.yml                ← Container orchestration
│   ├── DOCKER_LOCAL.md                   ← Local dev environment guide
│   ├── EVENT_SCHEMA.md                   ← Async event contracts
│   ├── MIGRATION_ORDER.md                ← Database dependency graph
│   ├── LOCAL_RUNBOOK.md                  ← Clone to running in 15 min
│   ├── GATEWAY_ROUTES.md                 ← API gateway routing
│   └── CONTRACT_TESTING.md              ← [Microservices] Inter-service contracts
│
├── operations/                           ← How work gets done
│   ├── WORKFLOW.md                       ← Git flow & CI/CD pipeline
│   ├── DEPLOYMENT.md                     ← Ship to production guide
│   ├── OPERATIONS_LOG.md                 ← Audit trail of all operations
│   ├── INCIDENT_RESPONSE.md              ← SEV1-4, post-mortems, runbooks
│   ├── MONITORING.md                     ← SLOs, golden signals, alerting
│   ├── OBSERVABILITY.md                  ← [Microservices] Logging & tracing
│   └── ORCHESTRATION.md                  ← [Microservices] K8s, Helm, scaling
│
├── io/                                   ← I/O Channel (inter-agent comms)
│   ├── IO_PROTOCOL.md                    ← The law governing all I/O
│   ├── status.md                         ← Live dashboard
│   ├── BRIEFING_COWORK.md                ← Role brief for Cowork
│   ├── BRIEFING_CLAUDE_CODE.md           ← Role brief for Claude Code
│   ├── COWORK_PROMPT.md                  ← Cowork session prompt
│   └── .templates/                       ← 9 pre-built request templates
│
├── hooks/
│   └── HOOKS_PROTOCOL.md                 ← 6 hook types, 7 production recipes
│
├── bootstrap/                            ← Project instantiation
│   ├── BOOTSTRAP.md                      ← New project (25 questions)
│   ├── REVERSE_BOOTSTRAP.md              ← Existing project (10-step auto-scan)
│   ├── REENGINEERING_GUIDE.md            ← Overlay methodology on legacy code
│   ├── UPGRADE_PROTOCOL.md               ← Safe v-old → v-new upgrade
│   └── MIGRATION_GUIDE.md               ← Old system → CCM migration
│
├── reference/                            ← Quick references
│   ├── MASTER_GUIDE.md                   ← Quick reference card
│   ├── SKILLS_REGISTRY.md                ← Skills catalog
│   ├── USAGE_GUIDE.md                    ← How to use Agents, Skills, Hooks
│   ├── COMMANDS_GUIDE.md                 ← Complete command reference
│   └── COMMAND_PREFIX.md                 ← Branded prefix system
│
└── scripts/                              ← Automation
    ├── git-setup.sh                      ← One-time repo initialization
    ├── validate-system.sh                ← System integrity check (102 checks)
    ├── services-check.sh                 ← Verify all services running
    ├── io-watcher.sh                     ← I/O channel monitor
    ├── io-archive.sh                     ← Archive completed I/O pairs
    └── install-claude-skills-v2.sh       ← Skill installer
```

---

## Stack Agnostic

This methodology works with **any tech stack**. Pre-configured presets included:

| Preset                  | Stack                                          |
|-------------------------|------------------------------------------------|
| **Node.js Full-Stack**  | Express + React + Prisma + PostgreSQL          |
| **.NET + Flutter**      | .NET 9 + Flutter + EF Core + PostgreSQL        |
| **Next.js**             | Next.js 14 + TypeScript + Prisma + Tailwind    |
| **Python FastAPI**      | FastAPI + React + SQLAlchemy + PostgreSQL       |

Or define your own — the bootstrap asks what you're using and adapts.

---

## Quick Reference: Daily Workflow

```bash
# Morning: Start your session
/arib-session-start

# Build a feature
/arib-dev-feature payment-integration

# Check your work
/arib-dev-review feature/payment-integration
/arib-check-perf backend
/arib-check-deps

# Before deploying
/arib-check-deploy
/arib-check-migrate migrations/add-payments.sql

# End of day: Close your session
/arib-session-end
```

---

## Version History

| Version | Codename | Key Changes |
|---------|----------|-------------|
| v1.0 | — | 5-Layer Architecture, 8 agents, memory, bootstrap |
| v2.0 | Connected | I/O Channel (14 files), version control |
| v2.1-2.4 | — | Language agent, microservices, reality auditor, DB guardian |
| v2.5 | — | Performance profiler, dependency audit, incident response |
| v2.6 | Fortress | API docs, accessibility, monitoring, 10 training manuals, SYSTEM.md |
| v2.7-2.8 | — | Branded arib-* commands, simplified bootstrap |
| v2.9 | Connected | I/O bridge, Cowork integration |
| v3.0 | Aligned | Official Claude Code architecture alignment (skills, rules, .mcp.json) |
| v3.1 | Deep Skills | All 16 skills enriched to Anthropic-grade depth |
| v3.2 | Honest | Real hook enforcement, token-audit script, README rewrite — docs match disk |
| v3.3 | Operating | 8 deferred items shipped: hybrid memory, real I/O transport, deep-audit, waves, design system, TestSprite gate, autonomy mode, compliance (OWASP/GDPR/ISO/SOC2/PDPL) |
| v3.4 | Reviewed | GitHub PR/CI governance as static configuration: PR template, CODEOWNERS, 4 CI workflows, Dependabot, CONTRIBUTING, repo-root SECURITY, COC |
| v3.5 | Engineered | CI/PR as an executable subsystem: `ci-pr-engineer` agent + `/arib-ci-audit` skill with audit/init/review/branch-protection modes |
| v3.5.1 | Engineered | Decisive bootstrap protocols: no STOP on matching versions, no options-menus, mandatory drift detection (ADR-014) |
| v3.6 | Flowing | Wave auto-advance: `/arib-wave-run` executes wave steps without asking between them, pausing only on issue/checkpoint (ADR-015) |
| v3.7 | Self-Policing | Post-review fixes: `block()` exit-2 (enforcement now real), agent frontmatter (subagents functional), coherence validator + CI, honest token metric (ADR-016/017) |
| v3.7.1 | Self-Policing | Deferred-findings patch: honest memory-export, real drift classifier (no edit-clobbering), hook hardening, ledger transport fields (ADR-018) |
| v3.7.2 | Self-Policing | 26-skill forensic audit, v3.8 roadmap, dev-feature `develop`-branch blocker fix |
| **v3.8** | **Lean Core** | **Always-on context 45.9K→7.4K (84%), under the 8K target — reference docs load on demand (ADR-019). The C+→A+ token gate, cleared.** |

---

## External Standards & Tools Disclaimer

This methodology references compliance frameworks (OWASP, GDPR, ISO 27001,
SOC 2, PDPL/NCA/SDAIA) and third-party tools (Claude Mem, CoWork,
TestSprite) for educational guidance and integration stubs.

**References do not constitute certification, compliance assertion, or
endorsement** by any standards body or vendor. CCM produces *alignment
reports* with a level (NONE / PARTIAL / STRONG) — never "compliant"
claims. Certification, attestation, and DPO functions remain with
auditors and humans.

See [`compliance/README.md`](compliance/README.md) for the honesty
principle and what CCM can / cannot do per framework.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Built by Abdullah x Claude Opus X x DR.SAMI SHM**
