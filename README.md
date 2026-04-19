# Claude Code Methodology

### The Complete AI Development Operating System

A professional, production-grade methodology that turns Claude Code from a code assistant into a **full development team** — with persistent memory, specialist agents, safety hooks, and a strategic architecture that governs every session.

Works for **new projects** (start from zero), **existing codebases** (reverse-engineer and overlay), **version upgrades** (v-old → v-new), and **legacy migrations** (old claude-code-system → methodology).

```
 ╔═══════════════════════════════════════════════════════════════════╗
 ║                                                                   ║
 ║   YOUR PROJECT  ──▶  claude-code-methodology/  ──▶  EXCELLENCE   ║
 ║                                                                   ║
 ║   New project?      ──▶  Bootstrap Protocol (25 questions)       ║
 ║   Existing project? ──▶  Reverse Bootstrap (auto-scan)           ║
 ║   Old CCM version?  ──▶  Upgrade Protocol (preserve + update)    ║
 ║   Old code-system?  ──▶  Migration Guide (6-phase migration)     ║
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
| No consistent code quality       | **13 Specialist Agents** — each with checklists |
| Dangerous operations slip through| **Safety Hooks** — block before damage happens |
| Every session starts from scratch| **Session Protocol** — read → work → write    |
| Architecture decisions are lost  | **Decision Records** — permanent, searchable  |
| "It works on my machine"         | **Implementation Layer** — docker, runbook, env|

---

## The 4-Layer Architecture

```
╔══════════════════════════════════════════════════════════════╗
║  L4 — AGENTS          13 specialists with scoped context    ║
║  Architect · Security · Reviewer · Tester · Debugger        ║
║  Refactor · Language · Deploy Guardian · Reality Auditor     ║
║  Database Guardian · Performance · API Docs · Accessibility  ║
╠══════════════════════════════════════════════════════════════╣
║  L3 — HOOKS           Safety gates & automation             ║
║  PreToolUse · PostToolUse · PreCommit · Notification        ║
╠══════════════════════════════════════════════════════════════╣
║  L2 — SKILLS          21 auto-invoked knowledge packs       ║
║  Frontend · Debugging · Security · TDD · Git Worktrees ...  ║
╠══════════════════════════════════════════════════════════════╣
║  I/O — CHANNEL        Inter-agent nervous system            ║
║  Requests · Results · Signals · Pipelines · Threads         ║
╠══════════════════════════════════════════════════════════════╣
║  L1 — CLAUDE.md       The Master Brain — rules everything   ║
║  Session protocol · Memory · Constraints · Golden Rules     ║
╚══════════════════════════════════════════════════════════════╝
```

**L1 overrides everything.** Skills advise, hooks enforce, agents execute — but `CLAUDE.md` governs all.

---

## What's Inside

```
claude-code-methodology/
│
├── CLAUDE.md                          ← The Master Brain
│
├── .claude/
│   ├── settings.json                  ← Claude Code configuration
│   ├── agents/                        ← 13 specialist agent definitions
│   │   ├── architect.md               ← System design authority
│   │   ├── security-auditor.md        ← OWASP Top 10 expert
│   │   ├── code-reviewer.md           ← Quality gatekeeper
│   │   ├── test-engineer.md           ← TDD specialist
│   │   ├── debugger.md                ← Scientific debugging
│   │   ├── refactor-specialist.md     ← Safe code improvement
│   │   ├── language.md                ← Universal language & i18n specialist
│   │   ├── reality-auditor.md         ← Mock data & fake API detector
│   │   ├── database-guardian.md       ← Migration safety & schema protection
│   │   ├── performance.md             ← N+1 detection & performance budgets
│   │   ├── api-docs.md                ← API documentation & OpenAPI generator
│   │   ├── accessibility.md           ← WCAG 2.1 AA compliance auditor
│   │   └── deploy-guardian.md         ← Deployment gatekeeper
│   └── commands/                      ← 14 slash commands
│       ├── session-start.md           ← /session-start
│       ├── session-end.md             ← /session-end
│       ├── new-feature.md             ← /new-feature [name]
│       ├── debug.md                   ← /debug [issue]
│       ├── review.md                  ← /review [target]
│       ├── deploy-check.md            ← /deploy-check
│       ├── language-audit.md           ← /language-audit [component] [--locale]
│       ├── reality-check.md           ← /reality-check [scope]
│       ├── migrate-check.md           ← /migrate-check [migration-file]
│       ├── perf-check.md              ← /perf-check [scope]
│       ├── dependency-audit.md        ← /dependency-audit [--fix]
│       ├── api-docs.md                ← /api-docs [scope]
│       ├── a11y-audit.md              ← /a11y-audit [component|page]
│       └── document.md                ← /document [target]
│
├── io/                                ← I/O Channel (inter-agent communication)
│   ├── IO_PROTOCOL.md                 ← The law governing all I/O
│   ├── status.md                      ← Live dashboard (queue + metrics)
│   ├── BRIEFING_COWORK.md             ← Role brief: Cowork = the critical eye
│   ├── BRIEFING_CLAUDE_CODE.md        ← Role brief: Claude Code = the hand
│   ├── requests/                      ← Cowork writes requests here
│   ├── results/                       ← Claude Code writes results here
│   ├── signals/                       ← Emergency interrupts
│   ├── pipelines/                     ← Multi-step chained workflows
│   ├── threads/                       ← Follow-up conversations
│   ├── archive/                       ← Completed pairs (monthly)
│   └── .templates/                    ← 9 pre-built templates
│
├── memory/                            ← Persistent memory system
│   ├── MEMORY_PROTOCOL.md             ← How memory works
│   ├── project_status.md              ← Where the project stands
│   ├── session_notes.md               ← Session handoff log
│   ├── change_log.md                  ← Chronological changes
│   ├── architecture_decisions.md      ← ADRs (why things are this way)
│   ├── bugs_and_fixes.md              ← Bug pattern database
│   └── testing_log.md                 ← Test results & coverage
│
├── architecture/                      ← What to build
│   ├── CONSTRAINTS.md                 ← Rules that must never break
│   ├── TECH_STACK.md                  ← Approved technologies only
│   ├── CONTEXT_MAP.md                 ← Folder structure & data flows
│   ├── ERROR_PATTERNS.md              ← 10 universal pitfalls + prevention
│   ├── DECISIONS.md                   ← Architecture Decision Records
│   ├── SECURITY.md                    ← Full security specification
│   ├── WORKFLOW.md                    ← Branch strategy & conventions
│   ├── SERVICE_MAP.md                 ← [Microservices] Service registry + dependencies
│   └── INTER_SERVICE.md              ← [Microservices] Communication patterns + saga
│
├── implementation/                    ← How to start coding
│   ├── API_ENDPOINTS.md               ← Complete route inventory
│   ├── docker-compose.yml             ← Container orchestration
│   ├── DOCKER_LOCAL.md                ← Local dev environment guide
│   ├── EVENT_SCHEMA.md                ← Async event contracts
│   ├── MIGRATION_ORDER.md             ← Database dependency graph
│   ├── LOCAL_RUNBOOK.md               ← Clone to running in 15 min
│   ├── GATEWAY_ROUTES.md              ← API gateway routing
│   └── CONTRACT_TESTING.md           ← [Microservices] Inter-service contracts
│
├── operations/                        ← How work gets done
│   ├── WORKFLOW.md                    ← Git flow & CI/CD pipeline
│   ├── DEPLOYMENT.md                  ← Ship to production guide
│   ├── OPERATIONS_LOG.md              ← Audit trail of all operations
│   ├── INCIDENT_RESPONSE.md          ← Incident response, post-mortems, runbooks
│   ├── MONITORING.md                 ← Production monitoring, alerting, SLOs
│   ├── OBSERVABILITY.md              ← [Microservices] Logging, tracing, metrics
│   └── ORCHESTRATION.md             ← [Microservices] Docker, K8s, Helm, scaling
│
├── hooks/
│   └── HOOKS_PROTOCOL.md             ← 6 hook types, 7 recipes
│
├── bootstrap/                         ← Project instantiation
│   ├── BOOTSTRAP.md                   ← New project → 25 questions → filled system
│   ├── REVERSE_BOOTSTRAP.md           ← Existing project → auto-scan → filled system
│   ├── REENGINEERING_GUIDE.md         ← How to overlay on existing code
│   ├── UPGRADE_PROTOCOL.md            ← Safe v-old → v-new upgrade
│   └── MIGRATION_GUIDE.md             ← Old claude-code-system → CCM migration
│
├── reference/
│   ├── MASTER_GUIDE.md                ← Quick reference card
│   ├── SKILLS_REGISTRY.md             ← 21 skills catalog
│   └── USAGE_GUIDE.md                 ← How to use Agents, Skills, Hooks & Commands
│
├── scripts/
│   ├── git-setup.sh                   ← One-time repo initialization
│   ├── validate-system.sh             ← System integrity check
│   ├── services-check.sh             ← [Microservices] Verify all services running
│   └── install-claude-skills-v2.sh    ← Master skill installer (21 skills)
│
├── .env.example                       ← Environment variable template
├── .gitignore                         ← Git ignore rules
└── LICENSE                            ← MIT License
```

**96 files · 24 directories · ~35,000 lines of professional methodology**
**13 agents · 14 commands · 122 features · Monolith + Microservices**

---

## Quick Start

### Case 1: New Project (Starting from Zero)

```bash
# 1. Clone the methodology
git clone https://github.com/YOUR_USERNAME/claude-code-methodology.git
cp -r claude-code-methodology/ my-new-project/

# 2. Add your project specification
#    Write a spec file describing your idea, features, tech stack
cp my-project-spec.md my-new-project/reference/

# 3. Open Claude Cowork and paste bootstrap/BOOTSTRAP.md
#    Answer 25 questions about your project
#    Claude generates all files filled with YOUR real data

# 4. Initialize git
cd my-new-project
bash scripts/git-setup.sh

# 5. Open Claude Code and start building
#    Type: /session-start
#    Claude reads everything, knows your project, and begins
```

### Case 2: Existing Project (Reengineering)

```bash
# 1. Clone the methodology
git clone https://github.com/YOUR_USERNAME/claude-code-methodology.git

# 2. Copy methodology into your existing project
cp -r claude-code-methodology/* /path/to/your-existing-project/
cd /path/to/your-existing-project

# 3. Create a safety branch
git checkout -b methodology/overlay

# 4. Open Claude Code and paste bootstrap/REVERSE_BOOTSTRAP.md
#    Claude auto-scans your ENTIRE codebase:
#      → Discovers tech stack from package.json / *.csproj
#      → Extracts database entities from schema/models
#      → Maps every API route from controllers
#      → Analyzes auth system, business logic, git history
#      → Generates all methodology files with YOUR REAL DATA
#
#    If you're renaming the project, it generates a RENAME_MAP.md

# 5. Review generated files, approve, commit
git add . && git commit -m "[chore]: add Claude Code Methodology"

# 6. Start working with full context
#    Type: /session-start
#    Claude now knows your entire codebase intimately
```

---

## The I/O Channel — Inter-Agent Nervous System

The I/O Channel enables **structured, traceable communication** between Claude Cowork, Claude Code, human operators, and CI/CD — all through a single directory.

```
COWORK (Critical Eye)                    CLAUDE CODE (Executing Hand)
      │                                         │
      ├── writes request ──────────────────────▶│
      │   io/requests/audit-auth-2026-04-17.md  ├── reads, executes audit
      │                                         ├── writes result
      │◀──────────────────── result ────────────┤
      │   io/results/audit-auth-...-result.md   │
      │                                         │
      ├── 🚨 SIGNAL (emergency) ───────────────▶│
      │   io/signals/halt-2026-04-17-001.md     ├── DROPS everything, responds
      │                                         │
      ├── PIPELINE (multi-step) ───────────────▶│
      │   io/pipelines/pre-release-...md        ├── executes step 1→2→3→4
      │                                         │
      └── THREAD (follow-up) ◀────────────────▶└── discussion on findings
```

| Component     | Purpose                                             |
|---------------|-----------------------------------------------------|
| **Requests**  | Structured audit/verify/review/analyze/compare/fix  |
| **Results**   | Findings by severity + code refs + recommendations  |
| **Signals**   | Emergency halt/rollback/escalate/hotfix             |
| **Pipelines** | Chained workflows (pre-release, incident response)  |
| **Threads**   | Follow-up conversations on specific findings        |
| **Dashboard** | Live queue, metrics, signal board                   |
| **Templates** | 9 pre-built templates for every request type        |
| **Archive**   | Monthly auto-archive of completed pairs             |

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

Every Claude Code session follows this protocol automatically:

```
/session-start
    │
    ├── READ: CLAUDE.md + Constraints + Tech Stack + Memory
    ├── CHECK: git status, branch, recent commits
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
/session-end
    │
    ├── WRITE: Update all memory files
    ├── TEST: Run final tests
    ├── COMMIT: Session-end commit
    ├── PUSH: To remote
    └── REPORT: ✅ Done · ⚠️ Issues · 🎯 Next
```

---

## Agents at a Glance

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

---

## Stack Agnostic

This methodology works with any tech stack. Pre-configured presets included:

| Preset                  | Stack                                          |
|-------------------------|------------------------------------------------|
| **Node.js Full-Stack**  | Express + React + Prisma + PostgreSQL          |
| **.NET + Flutter**      | .NET 9 + Flutter + EF Core + PostgreSQL        |
| **Next.js**             | Next.js 14 + TypeScript + Prisma + Tailwind    |
| **Python FastAPI**      | FastAPI + React + SQLAlchemy + PostgreSQL       |

Or define your own — the methodology adapts to whatever you're building.

---

## For Existing Projects: The Reverse Bootstrap

The **Reverse Bootstrap** (`bootstrap/REVERSE_BOOTSTRAP.md`) is the key tool for existing codebases. It runs a 10-step systematic scan:

1. **Structure Discovery** — maps your entire directory tree
2. **Tech Stack Detection** — identifies frameworks, languages, versions
3. **Entity Extraction** — reads every database model/schema
4. **Route Extraction** — maps every API endpoint
5. **Auth Analysis** — understands your permission model
6. **Config Audit** — checks environment variables and secrets
7. **Test Assessment** — measures test coverage and framework
8. **Git History Analysis** — finds hot spots and patterns
9. **Business Logic Discovery** — reads services and handlers
10. **Frontend Analysis** — components, pages, i18n, RTL

Then it **auto-generates all 30+ methodology files** filled with your actual data. No templates. No placeholders. Real routes, real entities, real business rules.

If you're renaming your project, it also generates a **RENAME_MAP.md** showing every file and code reference that needs updating, in a safe execution order.

---

## File Count

| Category          | Files | Lines  | Purpose                              |
|-------------------|-------|--------|--------------------------------------|
| Core              | 1     | ~450   | CLAUDE.md — The Master Brain         |
| I/O Channel       | 13    | ~3,500 | Inter-agent communication system     |
| Agents            | 8     | ~2,500 | Specialist agent definitions         |
| Commands          | 8     | ~500   | Slash command definitions            |
| Memory            | 7     | ~600   | Persistent memory system             |
| Architecture      | 7     | ~2,800 | What to build (constraints, stack)   |
| Implementation    | 8     | ~3,500 | How to start (API, docker, migrations)|
| Operations        | 3     | ~700   | Workflow, deploy, ops log            |
| Hooks             | 1     | ~1,200 | Safety gate protocol                 |
| Bootstrap         | 3     | ~1,500 | Instantiation (new + existing)       |
| Reference         | 2     | ~1,000 | Quick ref + skills catalog           |
| Scripts & Config  | 8     | ~600   | Automation, watcher, archival        |
| **Total**         | **69**| **~21K**| **Complete AI dev operating system** |

---

## Contributing

This is currently a private repository. If you'd like to contribute or suggest improvements, open an issue or submit a pull request.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Built by Abdullah** — powered by Claude Code Methodology v2.6.0 "Fortress"
