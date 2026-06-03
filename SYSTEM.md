# Claude Code Methodology — System Specification

```
 ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗     ██████╗ ██████╗ ██████╗ ███████╗
██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║     ██║     ███████║██║   ██║██║  ██║█████╗      ██║     ██║   ██║██║  ██║█████╗
██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██║     ██║   ██║██║  ██║██╔══╝
╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ╚██████╗╚██████╔╝██████╔╝███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

 ███╗   ███╗███████╗████████╗██╗  ██╗ ██████╗ ██████╗  ██████╗ ██╗      ██████╗  ██████╗██╗   ██╗
 ████╗ ████║██╔════╝╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔═══██╗██║     ██╔═══██╗██╔════╝╚██╗ ██╔╝
 ██╔████╔██║█████╗     ██║   ███████║██║   ██║██║  ██║██║   ██║██║     ██║   ██║██║  ███╗╚████╔╝
 ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║   ██║██║  ██║██║   ██║██║     ██║   ██║██║   ██║ ╚██╔╝
 ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║╚██████╔╝██████╔╝╚██████╔╝███████╗╚██████╔╝╚██████╔╝  ██║
 ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝  ╚═╝
```

---

| Field                | Value                                                    |
|----------------------|----------------------------------------------------------|
| **System Name**      | Claude Code Methodology (CCM)                            |
| **Version**          | 3.8.3                                                    |
| **Codename**         | "Lean Core"                                          |
| **Classification**   | AI Development Operating System                          |
| **Created**          | 2026-04-15                                               |
| **Last Updated**     | 2026-04-18                                               |
| **Engineered By**    | Abdullah × Claude Opus 4.6                               |
| **License**          | MIT                                                      |
| **Status**           | Production-Ready                                         |

---

## Part I — What This System Is

### 1.1 — Definition

The Claude Code Methodology (CCM) is a **complete AI development operating system** — a
structured, version-controlled, upgradable framework that transforms Claude Code from a
stateless code assistant into a disciplined engineering team with persistent memory,
specialist agents, safety gates, inter-agent communication, and architectural governance.

It is not a template. It is not a boilerplate. It is an **operating system for AI-assisted
software development** — a living system that reads, remembers, decides, builds, reviews,
communicates, deploys, and evolves.

### 1.2 — The Problem It Solves

Without CCM, every Claude Code session:
- Starts from zero — no memory of what happened before
- Guesses architecture — no constraints, no decisions recorded
- Drifts on quality — no consistent review, testing, or security standards
- Has no communication channel — Cowork and Claude Code cannot collaborate
- Produces rework — because inferred decisions conflict with past decisions
- Cannot be audited — no operations log, no change trail, no accountability

With CCM, every Claude Code session:
- Starts with full context — reads 7+ files before writing a single line
- Follows architectural governance — constraints, approved stack, decision records
- Maintains quality — 15 specialist agents enforce standards automatically
- Communicates through I/O — structured requests, results, signals, pipelines
- Eliminates rework — every decision documented, every pattern recorded
- Is fully auditable — operations log, change log, session notes, testing log

### 1.3 — Design Philosophy

The system is built on five engineering principles:

**1. Documentation-Driven Development**
> If it is not written down, Claude Code does not know it.
> Every decision, rule, pattern, and constraint lives in a file.

**2. Separation of Concerns (4-Layer Architecture)**
> L1 governs. L2 advises. L3 enforces. L4 executes.
> Each layer has clear boundaries that never bleed.

**3. Memory-First Design**
> A session without memory updates is a session that never happened.
> Read at start. Write during. Commit at end.

**4. Communication Through Protocol**
> All inter-agent communication flows through the I/O Channel.
> Structured, traceable, archivable, searchable.

**5. Upgradable by Design**
> The system has a version number. It has a changelog. It has an upgrade protocol.
> It evolves without breaking what already works.

---

## Part II — System Architecture

### 2.1 — The 4-Layer Stack (+ I/O Channel + Memory)

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║  L4 — AGENTS                   15 autonomous specialists             ║
║  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               ║
║  │Architect │ │ Security │ │ Reviewer │ │  Tester  │               ║
║  └──────────┘ └──────────┘ └──────────┘ └──────────┘               ║
║  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               ║
║  │ Debugger │ │ Refactor │ │ Language │ │  Deploy  │               ║
║  └──────────┘ └──────────┘ └──────────┘ └──────────┘               ║
║  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               ║
║  │ Reality  │ │ Database │ │  Perf    │ │ API Docs │               ║
║  └──────────┘ └──────────┘ └──────────┘ └──────────┘               ║
║  ┌──────────┐                                                       ║
║  │  A11y    │                                                       ║
║  └──────────┘                                                       ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L3 — HOOKS                     Safety gates & automation            ║
║  PreToolUse │ PostToolUse │ PreCommit │ SessionStart │ Notification  ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L2 — SKILLS                    26 auto-invoked skills      ║
║  Category A: 15 Coding Skills │ Category B: 6 Design/Automation     ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  I/O — CHANNEL                  Inter-agent nervous system           ║
║  Requests │ Results │ Signals │ Pipelines │ Threads │ Dashboard     ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L1 — CLAUDE.md                 The Master Brain                     ║
║  Session Protocol │ Memory │ Constraints │ Golden Rules │ Governance ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

### 2.2 — Layer Override Hierarchy

```
L1 (CLAUDE.md) ── overrides everything
    │
    ├── I/O Channel ── bound by L1 rules, signals can pause L4
    │
    ├── L2 (Skills) ── advisory only, L1 constraints always win
    │
    ├── L3 (Hooks) ── mandatory enforcement, cannot be bypassed
    │
    └── L4 (Agents) ── inherit L1, scoped autonomy, report back
```

### 2.3 — Directory Architecture

```
claude-code-methodology/                   96 files · 24 directories · 870 KB
│
├── SYSTEM.md                    ← THIS FILE — complete system specification
├── CLAUDE.md                    ← The Master Brain (session governance)
├── VERSION.json                 ← Machine-readable version manifest
├── CHANGELOG.md                 ← Release history
├── README.md                    ← GitHub showcase
├── LICENSE                      ← MIT License
│
├── io/                          ← I/O CHANNEL (14 files)
│   ├── IO_PROTOCOL.md           ← Communication law
│   ├── status.md                ← Live dashboard
│   ├── BRIEFING_COWORK.md       ← Cowork role instructions
│   ├── BRIEFING_CLAUDE_CODE.md  ← Claude Code role instructions
│   ├── requests/                ← Inbound requests
│   ├── results/                 ← Outbound results
│   ├── signals/                 ← Emergency interrupts
│   ├── pipelines/               ← Multi-step workflows
│   ├── threads/                 ← Follow-up conversations
│   ├── archive/                 ← Completed pairs
│   └── .templates/ (9)          ← Pre-built templates
│
├── .claude/                     ← CLAUDE CODE CONFIG (28 files)
│   ├── settings.json            ← Permissions, hooks, context
│   ├── agents/ (13)             ← Specialist agent definitions
│   ├── commands/ (14)           ← Slash command definitions
│   ├── hooks/                   ← Hook scripts
│   └── skills/                  ← Installed skill packs
│
├── memory/                      ← PERSISTENT MEMORY (7 files)
│   ├── MEMORY_PROTOCOL.md       ← How memory works
│   ├── project_status.md        ← Where the project stands
│   ├── session_notes.md         ← Session handoff log
│   ├── change_log.md            ← Chronological changes
│   ├── architecture_decisions.md← ADRs
│   ├── bugs_and_fixes.md        ← Bug pattern database
│   ├── testing_log.md           ← Test results & coverage
│   └── archive/                 ← Archived old entries
│
├── architecture/                ← ARCHITECTURE LAYER (7 files)
│   ├── CONSTRAINTS.md           ← Hard rules
│   ├── TECH_STACK.md            ← Approved technologies
│   ├── CONTEXT_MAP.md           ← Folder structure & flows
│   ├── ERROR_PATTERNS.md        ← 10 universal pitfalls
│   ├── DECISIONS.md             ← Architecture Decision Records
│   ├── SECURITY.md              ← Security specification
│   └── WORKFLOW.md              ← Branch strategy & conventions
│
├── implementation/              ← IMPLEMENTATION LAYER (8 files)
│   ├── API_ENDPOINTS.md         ← Complete route inventory
│   ├── docker-compose.yml       ← Container orchestration
│   ├── DOCKER_LOCAL.md          ← Local dev environment
│   ├── EVENT_SCHEMA.md          ← Async event contracts
│   ├── MIGRATION_ORDER.md       ← Database dependency graph
│   ├── LOCAL_RUNBOOK.md         ← Clone to running guide
│   ├── GATEWAY_ROUTES.md        ← API gateway config
│   └── README.md                ← Implementation index
│
├── operations/                  ← OPERATIONS LAYER (5 files)
│   ├── WORKFLOW.md              ← Git flow & CI/CD pipeline
│   ├── DEPLOYMENT.md            ← Ship to production guide
│   ├── OPERATIONS_LOG.md        ← Audit trail
│   ├── INCIDENT_RESPONSE.md    ← Incident response & post-mortems
│   └── MONITORING.md           ← Production monitoring & alerting
│
├── hooks/                       ← HOOKS DOCUMENTATION (1 file)
│   └── HOOKS_PROTOCOL.md        ← 6 hook types, 7 recipes
│
├── bootstrap/                   ← PROJECT INSTANTIATION (3 files)
│   ├── BOOTSTRAP.md             ← New project (25 questions)
│   ├── REVERSE_BOOTSTRAP.md     ← Existing project (auto-scan)
│   └── REENGINEERING_GUIDE.md   ← Overlay methodology guide
│
├── reference/                   ← READ-ONLY REFERENCE (2 files)
│   ├── MASTER_GUIDE.md          ← Quick reference card
│   └── SKILLS_REGISTRY.md       ← 21 skills catalog
│
├── scripts/                     ← AUTOMATION (5 files)
│   ├── git-setup.sh             ← One-time repo setup
│   ├── github-push.sh           ← Push to GitHub
│   ├── validate-system.sh       ← Integrity check
│   ├── io-watcher.sh            ← Check pending I/O
│   └── io-archive.sh            ← Archive completed I/O
│
├── .env.example                 ← Environment template
└── .gitignore                   ← Git ignore rules
```

---

## Part III — The Four Use Cases

The Claude Code Methodology serves exactly four use cases. Each has its own
entry point, protocol, and outcome.

### Case 1: New Project — Building from Zero

**Entry Point**: `bootstrap/BOOTSTRAP.md`

**When**: You have an idea but no code. You want Claude Code to build it
right from the first line.

**How It Works**:

```
YOUR IDEA
    │
    ▼
Step 1: Write a project specification document
    │    (features, roles, entities, tech stack, business rules)
    │
    ▼
Step 2: Place it in reference/ alongside the methodology
    │
    ▼
Step 3: Paste BOOTSTRAP.md into Claude Cowork
    │
    ▼
Step 4: Answer 25 questions about your project
    │    ┌─── Identity (5): name, type, owner, problem, users
    │    ├─── Technical (7): backend, frontend, mobile, DB, cache, auth, payments
    │    ├─── Architecture (5): pattern, events, gateway, integrations, i18n
    │    ├─── Data Model (3): entities, relationships, business rules
    │    └─── Scope (5): MVP features, phase 2, NFRs, deploy target
    │
    ▼
Step 5: Claude Cowork generates ALL files filled with YOUR real data
    │    Every [PROJECT] placeholder replaced with actual names
    │    Every route, entity, field, role — specific to your project
    │
    ▼
Step 6: Run scripts/git-setup.sh → initialize repository
    │
    ▼
Step 7: Open Claude Code → /session-start → BUILD
    │
    ▼
RESULT: Claude Code knows everything about your project
        from the very first line of code
```

**Outcome**: A fully contextualized development environment where Claude Code
never guesses, never drifts, and every session starts with total awareness.

---

### Case 2: Existing Project — Reengineering

**Entry Point**: `bootstrap/REVERSE_BOOTSTRAP.md`

**When**: You already have a working codebase (like a Work Order System) that
was built without the methodology. You want to add CCM on top without
modifying a single line of existing code.

**How It Works**:

```
YOUR EXISTING CODEBASE
    │
    ▼
Step 1: Copy methodology folder into your project root
    │
    ▼
Step 2: Create safety branch: git checkout -b methodology/overlay
    │
    ▼
Step 3: Paste REVERSE_BOOTSTRAP.md into Claude Code
    │
    ▼
Step 4: Claude Code performs a 10-STEP DEEP SCAN:
    │    ┌─── Structure Discovery    → maps directory tree
    │    ├─── Tech Stack Detection   → reads package.json, lock files
    │    ├─── Entity Extraction      → reads every model/schema file
    │    ├─── Route Extraction       → maps every API endpoint
    │    ├─── Auth Analysis          → understands permission model
    │    ├─── Config Audit           → checks env vars and secrets
    │    ├─── Test Assessment        → measures coverage, frameworks
    │    ├─── Git History Analysis   → finds hot spots, patterns
    │    ├─── Business Logic Scan    → reads services, handlers
    │    └─── Frontend Analysis      → components, pages, i18n, RTL
    │
    ▼
Step 5: Claude Code auto-generates ALL methodology files
    │    filled with REAL data extracted from your actual code
    │    (not templates — real routes, real entities, real rules)
    │
    ▼
Step 6: If renaming → generates RENAME_MAP.md
    │    (every file, every code reference, safe execution order)
    │
    ▼
Step 7: Review, approve, merge methodology branch
    │
    ▼
RESULT: Your existing code is untouched
        The methodology sits alongside as a knowledge layer
        Every future session starts with full context
```

**Outcome**: Your existing project gains persistent memory, agents, constraints,
I/O communication, and the full operating system — without changing a single
line of your working code.

---

### Case 3: System Upgrade — Migrating from Old Version to New

**Entry Point**: `bootstrap/UPGRADE_PROTOCOL.md`

**When**: You already have CCM installed (e.g., v1.0) and a new version is
released (e.g., v2.0). You want to upgrade without losing your project-specific
data — your memory files, your filled-in templates, your decision records.

**How It Works**:

```
YOUR PROJECT WITH CCM v1.x
    │
    ▼
Step 1: Read CHANGELOG.md for the new version
    │    Understand what's new, what changed, what's deprecated
    │
    ▼
Step 2: Run the UPGRADE PROTOCOL:
    │    ┌─── PRESERVE: memory/, custom decisions, project data
    │    ├─── UPDATE: protocol files, templates, scripts
    │    ├─── ADD: new features (e.g., I/O Channel, Pipelines)
    │    ├─── MIGRATE: settings format changes
    │    └─── VERIFY: run validate-system.sh
    │
    ▼
Step 3: Resolve any conflicts (upgrade guide per section)
    │
    ▼
Step 4: Update VERSION.json → new version number
    │
    ▼
Step 5: Commit: [chore]: upgrade CCM v1.x → v2.0
    │
    ▼
RESULT: Latest methodology features
        All project-specific data preserved
        Seamless transition, zero data loss
```

**Outcome**: The methodology evolves. Your project data stays. You get new
features, improved agents, better templates — without starting over.

---

### Case 4: Migration — Moving from Old claude-code-system

**Entry Point**: `bootstrap/MIGRATION_GUIDE.md`

**When**: You already have the OLD `claude-code-system` (the flat 35-file template
system) and want to migrate to the NEW `claude-code-methodology` (the full
5-layer operating system).

**How It Works**:

```
YOUR PROJECT WITH OLD claude-code-system
    │
    ▼
Step 1: INVENTORY — Map every file in your old system
    │    Classify: has real data? still a template? customized?
    │
    ▼
Step 2: SAFETY — Create backup branch
    │    git checkout -b safety/pre-migration-backup
    │
    ▼
Step 3: SCAFFOLD — Create new directory structure
    │    mkdir memory/ architecture/ implementation/ operations/
    │    mkdir io/ bootstrap/ reference/ hooks/
    │
    ▼
Step 4: MIGRATE — Move data to new locations (6 sub-steps):
    │    ┌─── docs/*.md ──────────▶ memory/*.md (reformat)
    │    ├─── AGENTS.md ──────────▶ .claude/agents/*.md (split to 8 files)
    │    ├─── Root *.md ──────────▶ architecture/*.md (relocate)
    │    ├─── Implementation ─────▶ implementation/*.md (relocate)
    │    ├─── WORKFLOW.md ────────▶ operations/WORKFLOW.md (relocate)
    │    └─── CLAUDE.md ──────────▶ CLAUDE.md (REBUILD with new structure)
    │
    ▼
Step 5: ADD NEW — Install components that didn't exist:
    │    I/O Channel (14 files), Bootstrap Protocol,
    │    Version Control, Hooks Protocol, Session Commands,
    │    Language Agent, Usage Guide
    │
    ▼
Step 6: VERIFY — Run validate-system.sh
    │    All 63+ files must pass
    │    No stale references to old paths
    │
    ▼
RESULT: Your project data is preserved in the new structure
        You gain: I/O Channel, 8 agents, session protocol,
        version control, hooks, universal language support
        The old flat system is replaced by a proper architecture
```

**Outcome**: Your existing project-specific data (routes, entities, decisions,
bugs, session history) is preserved and reorganized into a professional
5-layer architecture. You gain ~40 new files and capabilities that the
old system never had.

---

## Part IV — Complete Feature Inventory

### 4.1 — Core Systems

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 1  | **Master Brain**                 | CLAUDE.md                  | Single source of truth governing all sessions              |
| 2  | **4-Layer Architecture**         | L1→L4                      | Hierarchical system: governance → skills → hooks → agents  |
| 3  | **Session Protocol**             | CLAUDE.md §5               | Mandatory read→work→write lifecycle for every session      |
| 4  | **7 Golden Rules**               | CLAUDE.md §2               | Absolute rules that no agent or skill can override         |
| 5  | **Version Control**              | VERSION.json + CHANGELOG   | Semantic versioning with upgrade protocol                  |

### 4.2 — Persistent Memory System

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 6  | **Memory Protocol**              | memory/MEMORY_PROTOCOL.md  | Complete lifecycle: create, store, retrieve, maintain, archive |
| 7  | **Project Status Tracking**      | memory/project_status.md   | Live feature tracker, blockers, next tasks                 |
| 8  | **Session Handoff**              | memory/session_notes.md    | Detailed session log — what happened, what's next          |
| 9  | **Change Log**                   | memory/change_log.md       | Chronological record of every change with commits          |
| 10 | **Architecture Decision Records**| memory/architecture_decisions.md | Why things are built this way — prevents re-debating  |
| 11 | **Bug Pattern Database**         | memory/bugs_and_fixes.md   | Bug symptoms, root causes, fixes — prevents recurrence     |
| 12 | **Testing Log**                  | memory/testing_log.md      | Test results, coverage trends, regression tracking         |
| 13 | **Memory Hierarchy**             | Global → Project → Module  | Multi-level memory tree with inheritance                   |
| 14 | **Auto-Archival**                | memory/archive/            | Entries >200 lines archived, searchable history            |

### 4.3 — Specialist Agent System

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 15 | **Architect Agent**              | .claude/agents/architect.md| System design, schema planning, trade-off analysis         |
| 16 | **Security Auditor Agent**       | .claude/agents/security-auditor.md | OWASP Top 10:2025 + ASVS 5.0, full security audit |
| 17 | **Code Reviewer Agent**          | .claude/agents/code-reviewer.md | Quality gates: function/file length, duplication, tests |
| 18 | **Test Engineer Agent**          | .claude/agents/test-engineer.md | TDD enforcement, RED-GREEN-REFACTOR, coverage targets |
| 19 | **Debugger Agent**               | .claude/agents/debugger.md | Scientific debugging: hypothesize → test → fix → verify    |
| 20 | **Refactor Specialist Agent**    | .claude/agents/refactor-specialist.md | Safe code improvement, behavior preserved        |
| 21 | **Language Agent**               | .claude/agents/language.md   | Universal i18n/l10n — all scripts, locales, writing systems |
| 22 | **Deploy Guardian Agent**        | .claude/agents/deploy-guardian.md | Pre-deployment verification, 7-phase checklist      |
| 23 | **Reality Auditor Agent**        | .claude/agents/reality-auditor.md | Detects mock data, fake APIs, hardcoded responses    |
| 24 | **Database Guardian Agent**      | .claude/agents/database-guardian.md | Migration safety, risk classification, lock analysis |
| 25 | **Performance Profiler Agent**   | .claude/agents/performance.md | N+1 detection, bundle analysis, performance budgets    |
| 26 | **Agent Auto-Activation**        | CLAUDE.md §6               | Agents activate on keyword detection without explicit call |
| 27 | **Agent Context Inheritance**    | CLAUDE.md §1               | Every agent reads CLAUDE.md before its own context         |

### 4.4 — I/O Channel (Inter-Agent Communication)

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 25 | **I/O Protocol**                 | io/IO_PROTOCOL.md          | Complete communication law — naming, routing, security     |
| 26 | **Request System**               | io/requests/               | 6 request types: audit, verify, review, analyze, compare, fix |
| 27 | **Result System**                | io/results/                | Structured findings by severity with code references       |
| 28 | **Signal System (Emergency)**    | io/signals/                | 7 signal types: halt, rollback, escalate, hotfix, revert, pause, resume |
| 29 | **Pipeline System (Workflows)**  | io/pipelines/              | Chained multi-step operations with dependency tracking     |
| 30 | **Thread System (Follow-ups)**   | io/threads/                | Discussion threads on specific findings                    |
| 31 | **Live Dashboard**               | io/status.md               | Queue, signal board, pipelines, metrics, update log        |
| 32 | **Role Briefings**               | io/BRIEFING_*.md           | Self-contained instructions for each side of the channel   |
| 33 | **9 Pre-Built Templates**        | io/.templates/             | Copy-paste templates for every I/O operation type          |
| 34 | **Priority Queue**               | io/IO_PROTOCOL.md §5       | Critical/high/medium/low with SLA and auto-escalation      |
| 35 | **Auto-Archival**                | scripts/io-archive.sh      | Monthly archive of completed request-result pairs          |
| 36 | **I/O Watcher**                  | scripts/io-watcher.sh      | Session-start detection of pending items and signals       |
| 37 | **Access Control Matrix**        | io/IO_PROTOCOL.md §13      | Who can read/write what in the I/O system                  |

### 4.5 — Architecture Governance

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 38 | **Hard Constraints**             | architecture/CONSTRAINTS.md| Rules that must NEVER be violated — security, quality, git |
| 39 | **Approved Tech Stack**          | architecture/TECH_STACK.md | Only listed technologies may be used, 4 preset stacks      |
| 40 | **Context Map**                  | architecture/CONTEXT_MAP.md| Folder structure, entry points, data flows, danger zones   |
| 41 | **Error Pattern Database**       | architecture/ERROR_PATTERNS.md | 10 universal pitfalls with prevention and fix templates |
| 42 | **Decision Records**             | architecture/DECISIONS.md  | ADR template + 3 pre-filled examples                       |
| 43 | **Security Specification**       | architecture/SECURITY.md   | Auth, RBAC, encryption, input validation, OWASP checklist  |
| 44 | **Workflow Definition**          | architecture/WORKFLOW.md   | Branch strategy, commit convention, PR requirements        |

### 4.6 — Implementation Readiness

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 45 | **API Endpoint Inventory**       | implementation/API_ENDPOINTS.md | Every route documented: method, path, auth, body, response |
| 46 | **Docker Orchestration**         | implementation/docker-compose.yml | PostgreSQL, Redis, optional services with health checks |
| 47 | **Local Environment Guide**      | implementation/DOCKER_LOCAL.md | Setup, commands, troubleshooting, health checks          |
| 48 | **Event Schema Contracts**       | implementation/EVENT_SCHEMA.md | Async event naming, envelope, payload, consumers        |
| 49 | **Migration Dependency Graph**   | implementation/MIGRATION_ORDER.md | Table creation order by foreign key dependency        |
| 50 | **Local Runbook**                | implementation/LOCAL_RUNBOOK.md | Clone → running in 15 minutes                          |
| 51 | **API Gateway Configuration**    | implementation/GATEWAY_ROUTES.md | Route table, auth levels, rate limits, CORS           |
| 52 | **Two-Layer Readiness Gate**     | CLAUDE.md §2.2             | Architecture + Implementation both required before coding  |

### 4.7 — Operations & Monitoring

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 53 | **Git Workflow**                 | operations/WORKFLOW.md     | Branch strategy, commit types, PR template, CI/CD pipeline |
| 54 | **Deployment Guide**             | operations/DEPLOYMENT.md   | Pre-deploy checklist, deploy process, rollback procedure   |
| 55 | **Operations Log (Audit Trail)** | operations/OPERATIONS_LOG.md | Every significant operation logged with metadata        |
| 56 | **Monitoring Integration**       | io/status.md metrics       | Request volume, resolution rate, signal count, avg time    |
| 57 | **Session Monitoring**           | memory/session_notes.md    | Every session tracked: completed, files, problems, next    |
| 58 | **Coverage Monitoring**          | memory/testing_log.md      | Per-module coverage tracking across sessions               |
| 59 | **Bug Frequency Monitoring**     | memory/bugs_and_fixes.md   | Pattern detection across bug occurrences                   |

### 4.8 — Slash Commands

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 60 | **/session-start**               | .claude/commands/          | Initialize session with full context + I/O check           |
| 61 | **/session-end**                 | .claude/commands/          | Close session with memory update + push                    |
| 62 | **/new-feature**                 | .claude/commands/          | Feature branch workflow with TDD                           |
| 63 | **/debug**                       | .claude/commands/          | Scientific debugging protocol                              |
| 64 | **/review**                      | .claude/commands/          | Code review with quality gates                             |
| 65 | **/deploy-check**                | .claude/commands/          | Pre-deployment verification pipeline                       |
| 66 | **/language-audit**              | .claude/commands/          | Universal language & locale compliance check                |
| 67 | **/document**                    | .claude/commands/          | Documentation generation                                   |

### 4.9 — Safety & Hooks

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 68 | **Hook Protocol**                | hooks/HOOKS_PROTOCOL.md    | 6 hook types documented with configuration examples        |
| 69 | **PreToolUse Hooks**             | .claude/settings.json      | Block dangerous commands before execution                  |
| 70 | **PostToolUse Hooks**            | .claude/settings.json      | Auto-lint, auto-format after file writes                   |
| 71 | **PreCommit Hooks**              | hooks/                     | Block commits with secrets, enforce tests                  |
| 72 | **7 Production Hook Recipes**    | hooks/HOOKS_PROTOCOL.md    | Ready-to-use: rm -rf block, secret scan, lint, test, notify|
| 73 | **Permission Matrix**            | .claude/settings.json      | Allow/deny lists for safe command execution                |
| 74 | **Safety Snapshots**             | CLAUDE.md §2.4             | Mandatory checkpoint commits before risky changes          |

### 4.10 — Skills Ecosystem

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 75 | **Skills Registry**              | reference/SKILLS_REGISTRY.md | 21 skills cataloged with install commands                |
| 76 | **15 Category A Skills**         | Coding excellence          | Frontend, debugging, TDD, security, architecture, review   |
| 77 | **6 Category B Skills**          | Design & automation        | Research, marketing, UI/UX, persistent memory              |
| 78 | **Auto-Activation System**       | SKILL.md description field | Skills activate on keyword match — no explicit invocation  |
| 79 | **Skill Priority Chain**         | CLAUDE.md §7               | Project → User → Third-party priority ordering             |

### 4.11 — Bootstrap & Instantiation

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 80 | **New Project Bootstrap**        | bootstrap/BOOTSTRAP.md     | 25-question protocol → fully filled system                 |
| 81 | **Reverse Bootstrap (Reengineer)** | bootstrap/REVERSE_BOOTSTRAP.md | 10-step auto-scan → methodology from existing code   |
| 82 | **Reengineering Guide**          | bootstrap/REENGINEERING_GUIDE.md | Overlay methodology without touching existing code   |
| 83 | **Upgrade Protocol**             | bootstrap/UPGRADE_PROTOCOL.md | Safe v-old → v-new migration with data preservation    |
| 84 | **Rename Mapping**               | REVERSE_BOOTSTRAP.md §4    | Safe project rename with file + code reference tracking    |

### 4.12 — Automation Scripts

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 85 | **Git Setup**                    | scripts/git-setup.sh       | One-time repo + branch initialization                      |
| 86 | **GitHub Push**                  | scripts/github-push.sh     | Create private repo + push in one command                  |
| 87 | **System Validation**            | scripts/validate-system.sh | Verify all files exist and are properly configured         |
| 88 | **I/O Watcher**                  | scripts/io-watcher.sh      | Detect pending requests, signals, pipelines at session start |
| 89 | **I/O Archive**                  | scripts/io-archive.sh      | Monthly archive of completed request-result pairs          |

### 4.13 — Documentation & Guides

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 90 | **Migration Guide**              | bootstrap/MIGRATION_GUIDE.md | 6-phase migration from old claude-code-system to CCM    |
| 91 | **Usage Guide**                  | reference/USAGE_GUIDE.md   | How to use Agents, Skills, Hooks, and Commands             |

### 4.14 — Microservices Extension (Optional)

| #  | Feature                          | Component                  | Description                                                |
|----|----------------------------------|----------------------------|------------------------------------------------------------|
| 92 | **Service Map**                  | architecture/SERVICE_MAP.md | Service registry, boundaries, dependencies, data ownership |
| 93 | **Inter-Service Communication**  | architecture/INTER_SERVICE.md | REST, gRPC, events, commands, sagas, circuit breaker     |
| 94 | **Observability**                | operations/OBSERVABILITY.md | Structured logging, distributed tracing, metrics, alerting |
| 95 | **Contract Testing**             | implementation/CONTRACT_TESTING.md | Consumer-driven contracts (Pact), event schema validation |
| 96 | **Container Orchestration**      | operations/ORCHESTRATION.md | Docker, Kubernetes, Helm, scaling, deployment strategies   |
| 97 | **Architecture-Aware Bootstrap** | bootstrap/BOOTSTRAP.md     | Q13 branches: microservices → generates extension files    |
| 98 | **Architecture-Aware Reverse Bootstrap** | bootstrap/REVERSE_BOOTSTRAP.md | Phase 1.8 detects microservices → generates extension files |

### 4.15 — System Integrity & Reality Verification

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 99  | **Reality Auditor Agent**        | .claude/agents/reality-auditor.md | Detects mock data, fake APIs, hardcoded responses, disconnected frontend-backend wiring |
| 100 | **/reality-check Command**       | .claude/commands/reality-check.md | 10-step scan: mock libraries → hardcoded data → API verification → auth check → classification → remediation plan |
| 101 | **Services Health Check**        | scripts/services-check.sh  | Verify all microservices running before dev/testing: --start, --wait, --restart, --stop |
| 102 | **Dev Orchestration Protocol**   | operations/ORCHESTRATION.md §9 | Session-start integration: all services must be running for reliable development |

### 4.16 — Database Safety

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 103 | **Database Guardian Agent**      | .claude/agents/database-guardian.md | Migration risk classification, lock analysis, safe patterns, rollback verification |
| 104 | **/migrate-check Command**       | .claude/commands/migrate-check.md | Pre-migration safety review: detects dangerous ops, verifies rollback, generates safety report |
| 105 | **Safe Migration Patterns**      | .claude/agents/database-guardian.md | 3-step NOT NULL, 4-step rename, CONCURRENTLY indexes, size-aware analysis |

### 4.17 — Performance Engineering

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 106 | **Performance Profiler Agent**   | .claude/agents/performance.md | 7-step audit: backend → frontend → DB → memory → caching → load test → report |
| 107 | **/perf-check Command**          | .claude/commands/perf-check.md | Performance audit: N+1 queries, bundle size, latency budgets, memory leaks, caching gaps |
| 108 | **Performance Budget System**    | .claude/agents/performance.md | API (p50<100ms, p99<500ms), Frontend (JS<200KB, LCP<2.5s), DB (query p50<10ms) |

### 4.18 — Supply Chain & Dependencies

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 109 | **/dependency-audit Command**    | .claude/commands/dependency-audit.md | CVE scanning, outdated packages, license compliance, supply chain risk |
| 110 | **License Compliance Audit**     | .claude/commands/dependency-audit.md | Risk classification: MIT=safe → GPL=risky → AGPL=critical → Unlicensed=blocked |

### 4.19 — Incident Response

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 111 | **Incident Response Protocol**   | operations/INCIDENT_RESPONSE.md | SEV1-4 classification, first 5 minutes protocol, rollback decision framework |
| 112 | **Post-Mortem Template**         | operations/INCIDENT_RESPONSE.md | Blameless post-mortem: timeline, root cause, action items, lessons learned |
| 113 | **Runbook Library**              | operations/INCIDENT_RESPONSE.md | 3 runbooks: Service Won't Start, DB Connection Exhaustion, High Error Rate |

### 4.20 — API Documentation

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 114 | **API Documentation Agent**      | .claude/agents/api-docs.md | Auto-discover endpoints, generate OpenAPI spec, detect undocumented/stale routes |
| 115 | **/api-docs Command**            | .claude/commands/api-docs.md | Generate/sync API documentation, validate schemas, produce sync report |
| 116 | **OpenAPI Spec Generation**      | .claude/agents/api-docs.md | Produce valid OpenAPI 3.0+ spec from code with schemas, auth, examples |

### 4.21 — Accessibility

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 117 | **Accessibility Auditor Agent**  | .claude/agents/accessibility.md | WCAG 2.1/2.2 AA compliance, color contrast, ARIA, keyboard, screen reader |
| 118 | **/a11y-audit Command**          | .claude/commands/a11y-audit.md | Frontend accessibility audit with violation classification and remediation plan |
| 119 | **WCAG Compliance Checklist**    | .claude/agents/accessibility.md | Complete Level A + Level AA checklist (Perceivable, Operable, Understandable, Robust) |

### 4.22 — Production Monitoring

| #   | Feature                          | Component                  | Description                                                |
|-----|----------------------------------|----------------------------|------------------------------------------------------------|
| 120 | **Monitoring & Alerting Guide**  | operations/MONITORING.md   | Health checks, four golden signals, SLOs/SLIs, error budgets, dashboards |
| 121 | **Alert Classification System**  | operations/MONITORING.md   | P1-P4 severity, escalation policies, on-call rotation, handoff templates |
| 122 | **SLO & Error Budget Tracking**  | operations/MONITORING.md   | SLI definitions, SLO targets per service type, error budget calculation |

---

**Total: 122 documented features across 22 categories.**

---

## Part V — How It Works (End-to-End Flow)

### 5.1 — A Typical Day with CCM

```
08:00  Developer opens Claude Code
       │
       └─▶ Types: /session-start
           │
           ├── I/O WATCHER runs → 2 pending requests from overnight Cowork audit
           ├── CLAUDE.md read → full project context loaded
           ├── CONSTRAINTS.md read → rules refreshed
           ├── memory/project_status.md read → "Payment integration: in-progress"
           ├── memory/session_notes.md read → "Last session: Tap webhook handler done"
           ├── git status → on feature/payment-flow, 3 commits ahead
           │
           └── Reports to developer:
               "2 I/O requests pending (security audit + test verify).
                Current task: complete payment confirmation flow.
                Propose: process I/O requests first, then continue feature."
           │
08:05  Developer: "Process the requests first"
       │
       └─▶ SECURITY AUDITOR agent activates
           ├── Reads io/requests/audit-payment-2026-04-17-001.md
           ├── Updates io/status.md → in-progress
           ├── Audits: Tap webhook signature, amount validation, idempotency
           ├── Writes io/results/audit-payment-2026-04-17-001-result.md
           │   (2 medium findings, 1 recommendation)
           ├── Updates io/status.md → done
           └── Processes second request (test verification)
           │
08:30  Developer: "Now continue the payment flow"
       │
       └─▶ /new-feature payment-confirmation
           ├── Safety snapshot: git commit "[snapshot]: before payment confirmation"
           ├── TEST ENGINEER agent: writes failing test first (RED)
           ├── Implements minimum code to pass (GREEN)
           ├── REFACTOR: extracts payment service
           ├── Updates memory/change_log.md
           ├── Commits: [feat]: add payment confirmation with webhook verification
           │
09:30  Developer: "Review and wrap up"
       │
       └─▶ /review
           ├── CODE REVIEWER agent activates
           ├── Functions <30 lines ✅, no secrets ✅, tests passing ✅
           └── Result: APPROVED
           │
       └─▶ /session-end
           ├── Updates memory/session_notes.md (completed, files, next)
           ├── Updates memory/project_status.md (payment confirmation → done)
           ├── Updates memory/testing_log.md (coverage: 78%)
           ├── Commits: [chore]: end of session — payment confirmation complete
           ├── Pushes to origin
           └── Reports:
               ✅ Completed: payment confirmation + 2 I/O requests
               ⚠️ Issues: none
               🎯 Next: implement refund flow
```

---

## Part VI — Version Scheme

### Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR  → Breaking changes to file structure or protocol
         (files renamed, removed, or restructured)
MINOR  → New features, new files, new capabilities
         (backward compatible, no existing files broken)
PATCH  → Bug fixes, typo corrections, template improvements
         (no new features, no structural changes)
```

### Current Version

```
v2.6.0 "Fortress"

v2.6 completes all 7 SDLC gaps: adds API Documentation agent,
Accessibility Auditor agent, Production Monitoring guide, /api-docs
and /a11y-audit commands, and comprehensive Training manuals —
achieving full lifecycle coverage from plan to monitor.
```

### Version History

| Version | Codename    | Date       | Highlights                                    |
|---------|-------------|------------|-----------------------------------------------|
| 1.0.0   | Genesis     | 2026-04-15 | Initial release: 4-layer architecture, memory, agents, skills, hooks, bootstrap |
| 2.0.0   | Foundation  | 2026-04-17 | I/O Channel, upgrade protocol, SYSTEM.md, version control, monitoring |
| 2.1.0   | Polyglot    | 2026-04-17 | Universal Language Agent, /language-audit command, removed Arabic-RTL  |
| 2.2.0   | Navigator   | 2026-04-17 | Migration Guide, Usage Guide, Commands Guide, Use Case 4              |
| 2.3.0   | Architect   | 2026-04-18 | Microservices Extension: SERVICE_MAP, INTER_SERVICE, OBSERVABILITY, CONTRACT_TESTING, ORCHESTRATION, architecture-aware bootstrap |
| 2.4.0   | Sentinel    | 2026-04-18 | Reality Auditor agent, /reality-check command, services-check.sh, dev orchestration protocol |
| 2.5.0   | Guardian    | 2026-04-18 | Database Guardian agent, Performance Profiler agent, /migrate-check, /perf-check, /dependency-audit commands, Incident Response Protocol |
| 2.6.0   | Fortress    | 2026-04-18 | API Documentation agent, Accessibility Auditor agent, /api-docs, /a11y-audit commands, Production Monitoring guide, Training manuals |

### Upgrade Compatibility

| From   | To    | Difficulty | Data Loss | Method           |
|--------|-------|------------|-----------|------------------|
| 1.0.0  | 2.0.0 | Low        | None      | UPGRADE_PROTOCOL |
| 2.x    | 2.y   | Minimal    | None      | UPGRADE_PROTOCOL |
| Any    | Next  | Documented | None      | UPGRADE_PROTOCOL |

---

## Part VII — Strengths

### Why This System is Different

**1. It is not a template — it is an operating system.**
Templates are static. CCM is alive. It reads, writes, remembers, communicates,
and evolves. Every session is more informed than the last.

**2. It works for new AND existing projects.**
Most development methodologies assume a blank slate. CCM has the Reverse Bootstrap
that scans your actual code and builds the system from reality, not assumptions.

**3. It is upgradable.**
CCM has a version number, a changelog, and an upgrade protocol. When new features
are added, you upgrade — you don't start over.

**4. It has a nervous system.**
The I/O Channel isn't just messaging — it's structured communication with types,
priorities, SLAs, escalation, pipelines, threads, archival, and a live dashboard.
Two agents can collaborate on a complex multi-day workflow without losing a thread.

**5. It enforces quality at every layer.**
L1 governs with golden rules. L2 provides expert knowledge. L3 blocks dangerous
actions. L4 executes with specialized checklists. Quality isn't optional — it's
structural.

**6. It is stack-agnostic.**
Node, .NET, Python, Flutter, Next.js — the methodology doesn't care. It adapts
to whatever you're building. Four preset stacks included, or define your own.

**6.5. It scales from monolith to microservices.**
Start with a monolith and the core methodology. When you grow to microservices,
the Microservices Extension activates — SERVICE_MAP, INTER_SERVICE, OBSERVABILITY,
CONTRACT_TESTING, ORCHESTRATION. The bootstrap asks about your architecture and
generates the right files. No separate version needed.

**7. It is language-aware.**
Universal Language agent covering every writing system (RTL, LTR, CJK, Indic,
Bidi), i18n compliance audit for any locale, timezone handling, font loading,
and cultural adaptation — built for the real world where software serves every market.

**8. It is auditable.**
Operations log, change log, session notes, testing log, architecture decisions,
I/O archive — every action is traceable, searchable, and accountable.

**9. It prevents the #1 AI development failure.**
The #1 reason AI-assisted projects fail is **context loss**. CCM's persistent
memory system ensures that no matter how many sessions pass, no matter how
complex the project becomes, Claude Code always knows where it is, what was
done, and what comes next.

**10. It was engineered, not generated.**
Every file, every protocol, every agent was designed with intent. The 4-layer
architecture follows separation of concerns. The memory protocol follows the
read-work-write lifecycle. The I/O Channel follows the producer-consumer pattern.
The upgrade protocol follows semantic versioning. This is engineering.

---

## Part VIII — Objectives

### Primary Objectives

1. **Eliminate context loss** — Every session starts with full awareness
2. **Enforce quality by structure** — Not by willpower, but by architecture
3. **Enable agent collaboration** — Cowork and Claude Code as a team, not isolated tools
4. **Make AI development auditable** — Every decision, change, and operation logged
5. **Support project evolution** — From zero to production, methodology grows with project

### Secondary Objectives

6. **Reduce rework** — Decisions documented, patterns recorded, constraints enforced
7. **Accelerate onboarding** — New sessions (or new developers) understand everything instantly
8. **Standardize workflows** — Same commit convention, same branch strategy, same review process
9. **Prevent security gaps** — OWASP audit agent, secret scanning hooks, security specification
10. **Enable continuous improvement** — System versioned, changelog maintained, upgrades smooth

---

## Part IX — System Requirements

### Minimum Requirements

- Claude Code CLI installed (requires Node.js 18+)
- Git 2.30+ installed
- A terminal (macOS, Linux, or WSL on Windows)
- A text editor or IDE

### Recommended

- GitHub CLI (`gh`) for repository management
- Docker for local development environments
- Claude Cowork for the I/O Channel collaboration

### No Requirements

- No specific programming language required
- No specific framework required
- No cloud provider required
- No paid services required (methodology is free and open)

---

> **End of SYSTEM.md**
>
> *Claude Code Methodology v2.6.0 "Fortress"*
> *Engineered by Abdullah × Claude Opus 4.6*
> *96 files · 24 directories · 35,000+ lines · 122 features*
> *The AI development operating system that remembers, communicates, and evolves.*
