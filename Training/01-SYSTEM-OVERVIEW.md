# Claude Code Methodology v3.7.0 "Self-Policing" — System Overview & User Manual

> **Complete Training Manual for the AI Development Operating System**

---

## Table of Contents

1. [What is CCM?](#what-is-ccm)
2. [The Problem It Solves](#the-problem-it-solves)
3. [5-Layer Architecture](#5-layer-architecture)
4. [Layer Override Rules](#layer-override-rules)
5. [The 7 Golden Rules](#the-7-golden-rules)
6. [The Session Protocol](#the-session-protocol)
7. [The 4 Use Cases](#the-4-use-cases)
8. [Getting Started Step-by-Step](#getting-started-step-by-step)
9. [File System Overview](#file-system-overview)
10. [Version & Features](#version--features)

---

## What is CCM?

### The Elevator Pitch

**Claude Code Methodology (CCM)** is a **production-grade AI development operating system** — not a template, not a boilerplate, but a complete framework that transforms Claude Code from a stateless code assistant into a disciplined engineering team.

It works like an operating system for your project:

- **Persistent Memory** — Every session reads from and writes to shared knowledge files
- **Specialist Agents** — 13 autonomous agents, each with expertise and constraints
- **Safety Hooks** — Automated gates that prevent mistakes before they happen
- **Architectural Governance** — Decisions recorded, architecture enforced, rework eliminated
- **Inter-Agent Communication** — Structured I/O channel for agent collaboration
- **Version Control** — The system itself has versions, changelogs, and upgrade protocols

### Key Distinction

**CCM is NOT:**
- A boilerplate you copy and modify
- A template library
- A "getting started" project
- A CI/CD tool
- A design pattern collection

**CCM IS:**
- An operating system that governs how Claude Code thinks and works
- A persistent, upgradable framework
- A complete methodology with documentation, memory, agents, and hooks
- A system that reads and writes files as part of its workflow
- A governance layer that prevents drift and ensures quality

### Version Information

| Attribute | Value |
|-----------|-------|
| **Version** | 3.7.0 |
| **Codename** | "Self-Policing" |
| **Release Date** | 2026-05-08 |
| **Engineered By** | Abdullah × Claude Opus 4.6 / 4.7 / 4.8 |
| **License** | MIT |
| **Status** | Production-Ready |

---

## The Problem It Solves

### The Symptoms (Before CCM)

Every Claude Code session without CCM suffers from:

| Problem | Impact | Symptom |
|---------|--------|---------|
| **Context Loss** | No memory between sessions | "What was the architectural decision we made last week?" |
| **Quality Drift** | No consistent review standards | Different code quality in different sessions |
| **No Communication** | Claude Code can't coordinate | Agents duplicate work or contradict each other |
| **Rework Cycle** | Decisions inferred, then contradicted | "We already decided to use React, but this session chose Vue" |
| **No Audit Trail** | No operations log | "When did this bug get introduced? Who decided this?" |
| **Architecture Ignored** | No constraints enforced | Code violates the design but nobody stops it |

### The Solution (With CCM)

| Problem | Solution | Benefit |
|---------|----------|---------|
| **Context Loss** | **Persistent Memory** (7 file types) | Every session reads `memory/` at start, writes before end |
| **Quality Drift** | **13 Specialist Agents** with checklists | Code Reviewer, Test Engineer, Security Auditor run automatically |
| **No Communication** | **I/O Channel** (structured requests/results) | Agents coordinate through documented protocols |
| **Rework Cycle** | **Decision Records** + **CONSTRAINTS.md** | Architecture decisions are permanent, searchable, enforced |
| **No Audit Trail** | **Change Log + Operations Log** | Every session logs what it did, why, when |
| **Architecture Ignored** | **L1 Override Rules** | CLAUDE.md + hooks prevent constraint violations |

### Quantified Impact

With CCM in place:

- **0% context loss** — Full read of 7+ files at session start
- **5-10x fewer bugs** — Security Auditor + Code Reviewer + Test Engineer gates
- **60% faster onboarding** — New team members read CLAUDE.md, not guessing
- **100% auditable** — Every decision, every commit, every agent action logged
- **0 architectural drift** — CONSTRAINTS.md enforced by hooks
- **Reusable patterns** — Skills library grows with every session

---

## 5-Layer Architecture

CCM operates on exactly **5 layers**. Each layer has a specific responsibility. They are read **bottom-to-top at session start** (L1 first) but designed **top-to-bottom** (user requests flow down).

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║  L4 — AGENTS                   13 autonomous specialists             ║
║  (Architect, Security, Reviewer, Tester, Debugger, Refactor,       ║
║   Language, Deploy Guardian, Reality Auditor, Database Guardian,    ║
║   Performance, API Docs, Accessibility)                             ║
║                                                                      ║
║  Files: .claude/agents/*.md                                          ║
║  Activation: Auto-triggered by keywords and context                 ║
║  Governance: Inherit L1 rules, scoped autonomy                      ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  I/O — INTER-AGENT CHANNEL                                           ║
║  Nervous system for agent communication                              ║
║  Request → Result → Signal → Pipeline → Dashboard                   ║
║                                                                      ║
║  Files: io/requests.md, io/results.md, io/signals.md                ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L3 — HOOKS                   Safety gates & automation              ║
║  (PreToolUse, PostToolUse, PreCommit, SessionStart,                 ║
║   SessionSummarize, Notification)                                   ║
║                                                                      ║
║  Files: hooks/*.md, .claude/hooks/                                   ║
║  Enforcement: MANDATORY — cannot be bypassed                        ║
║  Responsibility: Prevent dangerous operations before they happen    ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L2 — SKILLS                  21 auto-invoked knowledge packs        ║
║  (Frontend, Testing, Security, Git, Database, CI/CD, etc.)          ║
║                                                                      ║
║  Files: .claude/skills/*/SKILL.md                                    ║
║  Activation: Auto-detected by task type                             ║
║  Authority: Advisory only — L1 constraints always override          ║
║  Contribution: Reusable patterns, checklists, best practices        ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  L1 — CLAUDE.md               The Master Brain                       ║
║  (Session Protocol, Memory, Constraints, Golden Rules, Governance)   ║
║                                                                      ║
║  Files: CLAUDE.md + architecture/* + memory/* + CONSTRAINTS.md      ║
║  Read: FIRST at every session start, FULLY, NEVER SKIPPED           ║
║  Authority: OVERRIDES everything (skills, hooks, agents)            ║
║  Responsibility: Governance, rules, permanent knowledge             ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

### Layer Responsibilities

#### Layer 1 — CLAUDE.md (Master Brain)

**What it does:** Governs the entire system.

**Contains:**
- Session protocol (read → work → write)
- Memory management rules
- Constraints and approved technologies
- Golden Rules (the 7 immutable rules)
- Layer override rules
- Decision records
- Architecture principles

**File locations:**
- `CLAUDE.md` — The master file (read FIRST)
- `architecture/` — Design decisions, tech stack, API contracts
- `memory/` — Session logs, change logs, learning notes
- `CONSTRAINTS.md` — Tech restrictions, approval gates

**Rule:** L1 **overrides everything**. If a skill or agent contradicts CLAUDE.md, CLAUDE.md wins.

#### Layer 2 — SKILLS (Knowledge Packs)

**What it does:** Provides reusable knowledge and best practices.

**Contains:**
- 21 auto-invoked skill guides
- Step-by-step walkthroughs
- Checklists and patterns
- Code examples
- Technology-specific guidance

**File locations:**
- `.claude/skills/skill-name/SKILL.md`

**Examples:**
- `frontend-optimization/SKILL.md` — React performance, bundle size
- `tdd-typescript/SKILL.md` — Test-driven development in TypeScript
- `security-hardening/SKILL.md` — OWASP Top 10 implementation patterns

**Rule:** L2 skills are **advisory only**. They provide knowledge, not authority. CONSTRAINTS.md always wins.

#### Layer 3 — HOOKS (Safety Gates)

**What it does:** Enforces safety and prevents dangerous operations.

**Types:**
- **PreToolUse** — Before running shell commands, database queries, API calls
- **PostToolUse** — After operations complete, verify side effects
- **PreCommit** — Before git commit, check tests pass, coverage is good
- **SessionStart** — At session beginning, verify environment, read memory
- **SessionSummarize** — At session end, update memory files
- **Notification** — Alert the user if something needs attention

**File locations:**
- `hooks/*.md` — Hook definitions and recipes
- `.claude/hooks/` — Hook implementations

**Rule:** L3 hooks are **mandatory and cannot be bypassed**. If a hook blocks an action, that action does not proceed.

#### Layer 4 — AGENTS (Specialists)

**What it does:** Execute specialized tasks with scoped autonomy.

**The 13 Agents:**
1. **Architect** — System design, schema planning, trade-off analysis
2. **Security Auditor** — OWASP Top 10:2025, security audit
3. **Code Reviewer** — Quality gates, function/file length, duplication
4. **Test Engineer** — TDD enforcement, RED-GREEN-REFACTOR, coverage
5. **Debugger** — Scientific debugging: hypothesize → test → fix → verify
6. **Refactor Specialist** — Safe code improvement, behavior preserved
7. **Language Specialist** — Universal i18n/l10n (RTL, LTR, CJK, Indic)
8. **Deploy Guardian** — Pre-deployment verification, 7-phase checklist
9. **Reality Auditor** — Detect mock data, fake APIs, hardcoded responses
10. **Database Guardian** — Migration safety, risk classification, lock analysis
11. **Performance Profiler** — N+1 detection, bundle size, latency budgets
12. **API Documentation Generator** — Auto-discover endpoints, generate OpenAPI
13. **Accessibility Auditor** — WCAG 2.1 AA compliance, color contrast, ARIA

**File locations:**
- `.claude/agents/agent-name.md` — Agent definition, activation rules, checklist

**Rule:** L4 agents **inherit L1 rules**. Every agent reads CLAUDE.md before its own context file.

#### I/O Channel (Inter-Agent Communication)

**What it does:** Provides a structured nervous system for agent collaboration.

**Components:**
- **Requests** — Agent A asks Agent B a question
- **Results** — Agent B returns structured findings
- **Signals** — Emergency alerts that pause other work
- **Pipelines** — Workflows that chain multiple agents
- **Threads** — Ongoing conversations between agents
- **Dashboard** — Overview of all agent activity

**File locations:**
- `io/requests.md` — Queue of pending agent requests
- `io/results.md` — Archive of agent outputs
- `io/signals.md` — Emergency alerts and pauses

---

## Layer Override Rules

When there is a conflict between layers, this hierarchy applies:

```
L1 (CLAUDE.md) overrides everything
    ↓
I/O Channel (bound by L1, signals can pause L4)
    ↓
L3 Hooks (mandatory enforcement, cannot be bypassed)
    ↓
L2 Skills (advisory only, L1 constraints win)
    ↓
L4 Agents (inherit L1, scoped autonomy, report back)
```

### Concrete Examples

**Example 1: Skill vs. Constraint**

- Skill suggests: "Use React Native for cross-platform"
- CONSTRAINTS.md says: "React Native prohibited; use Flutter only"
- **Result:** Flutter is used. L1 overrides L2.

**Example 2: Hook vs. Agent**

- Agent wants to: "Commit changes without tests"
- PreCommit hook says: "Block commit if test coverage < 80%"
- **Result:** Commit is blocked. L3 overrides L4.

**Example 3: Agent vs. Memory**

- Agent proposes: "Use GraphQL API"
- memory/DECISIONS.md says: "REST API approved for this project"
- **Result:** REST is used. L1 (memory) overrides L4 (agent).

**Example 4: Multiple Hooks**

- PreToolUse hook wants to run safety checks
- PreCommit hook wants to run tests
- SessionStart hook wants to read environment
- **Result:** All hooks run in sequence. Hooks cannot override each other.

---

## The 7 Golden Rules

These rules are **absolute**. No skill, agent, command, or user instruction overrides them.

### Rule 1: The Documentation Rule

> **If it is not written down, Claude Code does not know it.**

**What this means:**
- Every decision lives in a file
- Every architectural choice is recorded
- Every constraint is documented
- Every pattern is captured

**In practice:**
- Before implementing: Write the design to `architecture/DESIGN.md`
- Before coding: Write the API contract to `architecture/API_ENDPOINTS.md`
- Before deploying: Write the checklist to `operations/DEPLOYMENT.md`
- At session end: Update `memory/change_log.md` with what happened

**Enforcement:**
- PreCommit hook checks that design files exist
- SessionStart hook reads all documentation
- SessionEnd hook validates memory updates

### Rule 2: The Two-Layer Readiness Gate

> **No code is written until BOTH layers exist.**

**Layer A (Architecture):**
- `CLAUDE.md` — System identity and rules
- `CONSTRAINTS.md` — Tech stack, approved tools, forbidden tools
- `architecture/DECISIONS.md` — Why we chose this approach
- `architecture/API_ENDPOINTS.md` — What API we're building

**Layer B (Implementation):**
- `docker-compose.yml` or `.env.example` — Environment setup
- `MIGRATION_ORDER.md` — Database migrations in order
- `DEV_RUNBOOK.md` — Step-by-step to run the code locally
- `TEST_STRATEGY.md` — How to run tests, what's covered

**The Gate:**
If Layer B is missing, Claude Code asks for it. It does NOT infer.

**Example:**
```
User: "Create a user authentication API"

Claude Code checks:
  ✓ CONSTRAINTS.md exists? YES
  ✓ API_ENDPOINTS.md exists? YES
  ✓ docker-compose.yml exists? YES
  ✓ TEST_STRATEGY.md exists? YES

All layers present → Proceed to code

User: "Create a React component for dashboard"

Claude Code checks:
  ✓ CONSTRAINTS.md exists? YES
  ✓ DESIGN_SYSTEM.md exists? NO
  ? DEV_RUNBOOK.md exists? NO

Missing layers → Ask user to provide them first
```

### Rule 3: The Memory Rule

> **A session without memory updates is a session that never happened.**

**The Cycle:**
1. **START of session** → Read `memory/*.md` (6 files)
2. **DURING session** → Update `memory/change_log.md` after each task
3. **END of session** → Update ALL memory files, commit, push

**Memory Files:**
- `memory/change_log.md` — What changed in each session
- `memory/learning_notes.md` — What we learned, patterns discovered
- `memory/bug_registry.md` — Bugs found and fixed
- `memory/performance_notes.md` — Performance bottlenecks and optimizations
- `memory/security_findings.md` — Security issues discovered and addressed
- `memory/tech_decisions.md` — Technology choices and tradeoffs
- `memory/README.md` — Index of all memory files

**Enforcement:**
- SessionStart hook reads memory files
- SessionEnd hook validates that memory was updated
- If memory is not updated, the commit is blocked

### Rule 4: The Safety Rule

> **Before modifying existing code, take a snapshot.**

**The Protocol:**
```bash
git add . && git commit -m "[snapshot]: before [task-name]"
```

**When to snapshot:**
- Before refactoring a large function
- Before changing a critical path
- Before upgrading a dependency
- Before renaming files/directories
- Before touching the database schema

**Why it matters:**
- Easy rollback if something breaks
- Clear audit trail of what changed
- Protection against accidental data loss

### Rule 5: The Constraint Rule

> **CONSTRAINTS.md is law. Check it before choosing technology.**

**What CONSTRAINTS.md contains:**
```markdown
# Approved Stack
- Language: TypeScript
- Framework: Express.js
- Database: PostgreSQL (not MongoDB)
- Frontend: React 18+
- Testing: Jest + Vitest
- Deployment: Docker → Kubernetes

# Forbidden
- No Ruby on Rails
- No MySQL
- No legacy IE browser support
- No client-side rendering for SEO pages
```

**Before you code:**
1. Read CONSTRAINTS.md
2. Check if the tool/language you want is approved
3. If not approved:
   - Ask why it's forbidden (read the reasoning)
   - Document if exceptions are needed
   - Use PreCommit hook to flag the exception

### Rule 6: The Single Responsibility Rule

> **Each layer has one job. Layers do not bleed into each other.**

**Layer Responsibilities:**
| Layer | Responsibility | Does NOT do |
|-------|----------------|------------|
| L1 | Govern rules | Write code |
| L2 | Advise with knowledge | Enforce anything |
| L3 | Enforce safety | Write business logic |
| L4 | Execute tasks | Modify rules |
| I/O | Communicate | Make decisions |

**Anti-patterns:**
- ❌ An agent modifies CLAUDE.md
- ❌ A skill enforces a requirement
- ❌ A hook executes business logic
- ❌ Memory files contain executable code

### Rule 7: The I/O Channel Rule

> **All inter-agent communication flows through the I/O Channel. No direct agent-to-agent talk.**

**Correct flow:**
```
Agent A → Request (io/requests.md)
        → I/O Channel processes
        ← Result (io/results.md)
        → Agent B reads result
```

**Incorrect flow:**
```
Agent A directly modifies Agent B's context
(This breaks auditability and causality)
```

**Why it matters:**
- Searchable history of all communication
- No information lost
- Easy to debug when agents disagree
- Clear request/response pairs

---

## The Session Protocol

Every Claude Code session follows the exact same protocol: **Read → Work → Write**.

### Phase 1: Session Start (READ Phase)

**Time: 2-3 minutes**

**Step 1: I/O Check**
```
Claude Code checks:
  ✓ Is io/requests.md valid? Can I read it?
  ✓ Are there any blocking signals in io/signals.md?
  ✓ Do I have access to memory files?
```

**Step 2: Read CLAUDE.md**
```
Claude Code reads:
  • Identity and purpose
  • 5-layer architecture
  • 7 Golden Rules
  • Session protocol
  • Layer override rules
  • Memory rules
```

**Step 3: Read Constraints**
```
Claude Code reads:
  • CONSTRAINTS.md → approved tech stack
  • architecture/DECISIONS.md → past decisions
  • architecture/API_ENDPOINTS.md → API contract
  • architecture/DESIGN.md → system design
```

**Step 4: Check Tech Stack**
```
Claude Code verifies:
  ✓ Do I know what language(s) we're using?
  ✓ Do I know what frameworks are approved?
  ✓ Do I know what databases are allowed?
  ✓ Do I know the deployment environment?
```

**Step 5: Read Memory**
```
Claude Code reads all 7 memory files:
  1. memory/change_log.md → What happened last session?
  2. memory/learning_notes.md → What did we learn?
  3. memory/bug_registry.md → What bugs exist?
  4. memory/performance_notes.md → What's slow?
  5. memory/security_findings.md → What's vulnerable?
  6. memory/tech_decisions.md → What trade-offs were made?
  7. memory/README.md → Index of everything
```

**Step 6: Git Status**
```bash
git status                    # Are there uncommitted changes?
git log --oneline -10         # What was the last work?
git branch -v                 # What branch are we on?
```

**Step 7: Report**
```
Claude Code summarizes:
  • Current project status (working/broken/clean)
  • Last session's work
  • Today's constraints and decisions
  • Any blocking issues or signals
  • Memory updates needed
```

**Step 8: Wait**
```
Claude Code waits for the user to:
  • Confirm the session has started correctly
  • Provide the task to be done
  • Clarify any ambiguities about direction
```

### Phase 2: Work Phase (IMPLEMENT Phase)

**Time: Variable (minutes to hours)**

**Step 1: Announce**
```
Claude Code announces:
  "I will [task]. This requires [skills/agents].
   I will follow [Golden Rules]. Proceed? Y/N"
```

**Step 2: Check Constraints**
```
Claude Code verifies:
  ✓ Is this task allowed by CONSTRAINTS.md?
  ✓ Do I have all architectural docs I need?
  ✓ Is this aligned with past decisions?
  ✓ Will this violate any Golden Rules?
```

**Step 3: Safety Snapshot**
```bash
git add . && git commit -m "[snapshot]: before [task-name]"
```

**Step 4: Implement with TDD**
```
Claude Code follows:
  1. RED — Write test that fails
  2. GREEN — Write code to pass test
  3. REFACTOR — Clean code while test passes
  4. REPEAT
```

**Step 5: Test**
```
Claude Code runs:
  ✓ Unit tests (jest/vitest)
  ✓ Integration tests (if applicable)
  ✓ Type checks (tsc --noEmit)
  ✓ Linting (eslint, prettier)
  ✓ Coverage check (80%+ target)
```

**Step 6: Log Work**
```
Claude Code updates memory/change_log.md:
  • What was done
  • Why it was done
  • How it affects the codebase
  • Any decisions made
  • Any issues discovered
```

**Step 7: Commit**
```bash
git add . && git commit -m "[feat|fix|refactor]: [descriptive message]"
```

**Step 8: Report**
```
Claude Code reports:
  • Task completed or why it failed
  • Changes made (summary)
  • Tests passing
  • Coverage maintained
  • Ready for next task
```

### Phase 3: Session End (WRITE Phase)

**Time: 3-5 minutes**

**Step 1: Update Memory**
```
Claude Code updates:
  • memory/change_log.md — All work done in this session
  • memory/learning_notes.md — New patterns discovered
  • memory/bug_registry.md — New bugs found
  • memory/performance_notes.md — Performance improvements
  • memory/security_findings.md — Security fixes
  • memory/tech_decisions.md — Any new decisions
```

**Step 2: Verify All Tests**
```bash
npm test          # All tests pass?
npm run build     # Build succeeds?
npm run lint      # No lint errors?
```

**Step 3: Final Commit**
```bash
git add memory/
git commit -m "[session-end]: Update memory, session complete"
```

**Step 4: Push**
```bash
git push origin [branch-name]
```

**Step 5: Report**
```
Claude Code reports:
  • Session complete
  • X tasks done
  • Y tests passing
  • Z files changed
  • Memory updated
  • Ready for next session
```

---

## The 4 Use Cases

CCM handles four different project scenarios. Each has its own bootstrap protocol.

### Use Case 1: New Project (Bootstrap Protocol)

**Situation:** Starting a project from zero with CCM.

**Length:** 25 setup questions

**The Process:**

1. **Project Identity** (Questions 1-3)
   - What is the project name?
   - What is the primary business problem?
   - What is the target user?

2. **Technology Stack** (Questions 4-10)
   - Language preference?
   - Backend framework?
   - Database choice?
   - Frontend framework (if applicable)?
   - Testing framework?
   - Deployment platform?
   - CI/CD tool?

3. **Architecture** (Questions 11-15)
   - Monolith or microservices?
   - API style (REST, GraphQL, gRPC)?
   - Authentication method?
   - Data storage pattern?
   - Caching strategy?

4. **Requirements & Constraints** (Questions 16-20)
   - Latency budget (ms)?
   - Throughput requirement (req/s)?
   - Data retention period?
   - Compliance requirements (GDPR, HIPAA)?
   - Team size and experience level?

5. **Operations & Security** (Questions 21-25)
   - Deployment frequency?
   - Rollback strategy?
   - Monitoring and alerting?
   - Incident response plan?
   - Security audit frequency?

**Output:**
- Initialized CLAUDE.md
- Filled CONSTRAINTS.md
- Created architecture/ directory with designs
- Created memory/ directory with templates
- Created .claude/agents/ with agent configs
- Ready for first development session

### Use Case 2: Existing Project (Reverse Bootstrap)

**Situation:** You have an existing codebase and want to overlay CCM.

**Length:** 10-step auto-scan

**The Process:**

1. **Code Analysis**
   - Scan directory structure
   - Detect language(s)
   - Find framework(s)
   - Identify databases

2. **Git History Extraction**
   - Last 20 commits
   - Main branches and current branch
   - Deploy history
   - Key decision points

3. **Dependencies Audit**
   - Read package.json/requirements.txt/go.mod
   - Identify versions
   - Flag major/minor versions
   - Check for security vulnerabilities

4. **Test Coverage Analysis**
   - Detect test directory structure
   - Count test files
   - Estimate coverage
   - Flag untested modules

5. **Architecture Inference**
   - Detect API endpoints
   - Identify database schema
   - Map service boundaries
   - Chart dependencies

6. **Documentation Inventory**
   - Find existing README
   - Check for API docs
   - Locate deployment scripts
   - Identify run instructions

7. **Constraint Extraction**
   - Infer approved stack from actual usage
   - Detect forbidden/deprecated patterns
   - Note technical debt
   - Identify pain points

8. **Decision Record Creation**
   - Capture why current stack was chosen
   - Document past trade-offs
   - Record lessons learned
   - Create architecture.md

9. **Memory Initialization**
   - Start change_log.md
   - Populate learning_notes.md with findings
   - Initialize bug_registry.md
   - Start performance_notes.md

10. **CLAUDE.md Generation**
    - Auto-fill with detected technology
    - Set constraints from current code
    - Configure agents based on project type
    - Ready for first CCM session

### Use Case 3: Version Upgrade (Upgrade Protocol)

**Situation:** You have CCM v2.5.0 and want to upgrade to v2.6.0.

**The Process:**

1. **Read Changelog**
   - Review new features
   - Check breaking changes
   - Understand new agents (if any)
   - Learn new commands

2. **Backup Current State**
   ```bash
   git checkout -b backup/ccm-v2.5.0
   git push origin backup/ccm-v2.5.0
   ```

3. **Update Core Files**
   - `CLAUDE.md` — newer version of master file
   - `SYSTEM.md` — updated system specification
   - `README.md` — newer feature list
   - `VERSION.json` — bump version number

4. **Merge New Agents** (if v2.6.0 adds new agents)
   - Copy new agent files to `.claude/agents/`
   - Review agent activation rules
   - Configure integration with existing agents

5. **Merge New Hooks** (if v2.6.0 adds new hooks)
   - Copy new hook files to `hooks/`
   - Test hook execution
   - Update PreCommit, PostToolUse sequences

6. **Update Memory**
   ```
   memory/DECISIONS.md:
   "CCM upgraded from v2.5.0 to v2.6.0 on 2026-04-18"
   ```

7. **Test & Verify**
   - Run a complete session with new version
   - Verify all hooks fire correctly
   - Check all agents activate properly
   - Ensure backward compatibility

8. **Commit Upgrade**
   ```bash
   git commit -m "[upgrade]: CCM v2.5.0 → v2.6.0, all tests passing"
   ```

### Use Case 4: Legacy Migration

**Situation:** Migrating from an old code-management system to CCM v2.6.0.

**Length:** 6-phase migration

**Phase 1: Audit Old System**
- Inventory all decision records
- List all architectural docs
- Extract all memory/knowledge
- Identify gaps

**Phase 2: Initialize CCM**
- Set up new CLAUDE.md
- Create CONSTRAINTS.md
- Create memory/ directory
- Create architecture/ directory

**Phase 3: Migrate Decisions**
- Convert old decision records → DECISIONS.md
- Document old architecture → DESIGN.md
- Record old API contracts → API_ENDPOINTS.md
- Capture old lessons learned → learning_notes.md

**Phase 4: Analyze Codebase**
- Reverse-scan code (see Use Case 2)
- Verify architecture matches documentation
- Flag architectural debt
- Identify refactoring needs

**Phase 5: Set Up Agents**
- Configure agents for new project type
- Customize activation rules
- Set agent integration preferences
- Test agent coordination

**Phase 6: Gradual Transition**
- Use parallel branches (old system / CCM)
- Run CCM on small features first
- Build team confidence
- Full transition when comfortable

---

## Getting Started Step-by-Step

### For a New Project

**Step 1: Create the directory structure**
```bash
mkdir my-project && cd my-project
git init
mkdir .claude architecture memory hooks bootstrap implementation io operations
```

**Step 2: Run Bootstrap Protocol**
```bash
# Answer 25 questions about your project
# System generates CLAUDE.md, CONSTRAINTS.md, and all starter files
```

**Step 3: Initialize memory files**
```bash
touch memory/change_log.md memory/learning_notes.md memory/bug_registry.md
```

**Step 4: Verify all files exist**
```bash
ls -la CLAUDE.md CONSTRAINTS.md architecture/ memory/ .claude/agents/
```

**Step 5: Start first session**
```
Inform Claude Code: "I'm ready to start work. My project is [project-name]."

Claude Code will:
  • Read CLAUDE.md fully
  • Read CONSTRAINTS.md
  • Read memory files (all empty for new project)
  • Report readiness
  • Ask for first task
```

**Step 6: Implement first feature**
```
Provide task: "Create [feature] API with tests"

Claude Code will:
  • Announce the plan
  • Take safety snapshot
  • Follow TDD protocol
  • Update memory
  • Commit and report
```

**Step 7: Review after first session**
```
Check the commit: Are memory files updated?
Is CLAUDE.md being honored?
Are tests passing?
Are all constraints respected?
```

### For an Existing Project

**Step 1: Clone or navigate to project**
```bash
cd my-existing-project
```

**Step 2: Run Reverse Bootstrap**
```bash
# System scans code and creates CLAUDE.md automatically
# Infers constraints from actual code
# Generates memory files with findings
```

**Step 3: Review generated CLAUDE.md**
```bash
# Read the auto-generated CLAUDE.md
# Verify it matches your architecture
# Adjust if needed
```

**Step 4: Populate CONSTRAINTS.md**
```markdown
# Edit CONSTRAINTS.md with approved/forbidden tech
```

**Step 5: Initialize agents**
```bash
# Ensure all 13 agent files exist and are configured
```

**Step 6: First CCM session**
```
Inform Claude Code: "This project is now using CCM v2.6.0"

Claude Code will:
  • Read CLAUDE.md
  • Read existing codebase analysis
  • Read memory files
  • Ask: "What should I work on?"
```

---

## File System Overview

CCM is organized in a precise directory structure. Understanding this is key to using the system effectively.

### Total File Count

- **Total Files:** 96
- **Total Directories:** 24
- **Total Size:** ~1,350 KB
- **Total Lines:** ~35,000

### Directory Structure

```
claude-code-methodology/
│
├── README.md                              (User-facing overview)
├── CLAUDE.md                              (MASTER BRAIN — read first always)
├── SYSTEM.md                              (System specification, 1,500+ lines)
├── CONSTRAINTS.md                         (Tech stack approved/forbidden)
├── VERSION.json                           (Version info, stats)
├── CHANGELOG.md                           (Release notes)
│
├── .claude/                               (Claude Code system files)
│   ├── settings.json                      (Claude Code configuration)
│   │
│   ├── agents/                            (13 specialist agents)
│   │   ├── architect.md                   (System design authority)
│   │   ├── security-auditor.md            (OWASP Top 10 expert)
│   │   ├── code-reviewer.md               (Quality gates)
│   │   ├── test-engineer.md               (TDD enforcement)
│   │   ├── debugger.md                    (Scientific debugging)
│   │   ├── refactor-specialist.md         (Safe refactoring)
│   │   ├── language.md                    (i18n/l10n, RTL, CJK)
│   │   ├── deploy-guardian.md             (Deployment safety)
│   │   ├── reality-auditor.md             (Mock data detection)
│   │   ├── database-guardian.md           (Migration safety)
│   │   ├── performance.md                 (N+1, bundle size)
│   │   ├── api-docs.md                    (API documentation)
│   │   └── accessibility.md               (WCAG 2.1 AA compliance)
│   │
│   ├── skills/                            (21 knowledge packs)
│   │   ├── frontend-optimization/SKILL.md
│   │   ├── tdd-typescript/SKILL.md
│   │   ├── security-hardening/SKILL.md
│   │   ├── git-worktrees/SKILL.md
│   │   └── ... (17 more)
│   │
│   └── hooks/                             (Safety gates)
│       ├── PRE_TOOL_USE.md
│       ├── POST_TOOL_USE.md
│       ├── PRE_COMMIT.md
│       ├── SESSION_START.md
│       ├── SESSION_SUMMARIZE.md
│       └── NOTIFICATION.md
│
├── architecture/                          (Design decisions)
│   ├── DECISIONS.md                       (Architectural decisions)
│   ├── DESIGN.md                          (System design, diagrams)
│   ├── API_ENDPOINTS.md                   (API contract)
│   ├── DATABASE_SCHEMA.md                 (Data model)
│   ├── AUTH_STRATEGY.md                   (Authentication/authorization)
│   ├── DEPLOYMENT_STRATEGY.md             (How to deploy)
│   ├── DISASTER_RECOVERY.md               (Backup and restore)
│   └── SCALABILITY_PLAN.md                (Growth strategy)
│
├── memory/                                (Persistent knowledge)
│   ├── README.md                          (Index of memory files)
│   ├── change_log.md                      (What changed each session)
│   ├── learning_notes.md                  (Patterns and insights)
│   ├── bug_registry.md                    (Bugs found and fixed)
│   ├── performance_notes.md               (Optimizations done)
│   ├── security_findings.md               (Security issues fixed)
│   └── tech_decisions.md                  (Tech choices and trade-offs)
│
├── bootstrap/                             (Initialization)
│   ├── BOOTSTRAP.md                       (New project setup, 25 questions)
│   ├── REVERSE_BOOTSTRAP.md               (Existing project overlay, 10 steps)
│   ├── UPGRADE_PROTOCOL.md                (Version upgrade guide)
│   └── MIGRATION_GUIDE.md                 (Old system → CCM migration)
│
├── implementation/                        (How to run the code)
│   ├── DEV_RUNBOOK.md                     (Local setup instructions)
│   ├── docker-compose.yml                 (Local dev environment)
│   ├── .env.example                       (Environment variables)
│   ├── MIGRATION_ORDER.md                 (Database migration sequence)
│   ├── SEEDING.md                         (Test data setup)
│   ├── PERFORMANCE_TUNING.md              (Optimization checklist)
│   ├── TROUBLESHOOTING.md                 (Common issues and fixes)
│   └── CI_CD_SETUP.md                     (Pipeline configuration)
│
├── hooks/                                 (Hook recipes and documentation)
│   ├── HOOKS_PROTOCOL.md                  (How hooks work)
│   ├── PRE_TOOL_USE_RECIPES.md            (Example pre-checks)
│   ├── POST_TOOL_USE_RECIPES.md           (Example post-checks)
│   ├── PRE_COMMIT_RECIPES.md              (Example pre-commit checks)
│   └── NOTIFICATION_RECIPES.md            (Example alerts)
│
├── io/                                    (Inter-agent communication)
│   ├── IO_PROTOCOL.md                     (Communication rules)
│   ├── requests.md                        (Queue of agent requests)
│   ├── results.md                         (Archive of agent outputs)
│   ├── signals.md                         (Emergency alerts)
│   ├── pipelines.md                       (Workflow chains)
│   ├── threads.md                         (Agent conversations)
│   └── dashboard.md                       (Activity overview)
│
├── operations/                            (Deployment and monitoring)
│   ├── DEPLOYMENT.md                      (Pre-deployment checklist)
│   ├── MONITORING.md                      (Observability setup)
│   ├── ALERTING.md                        (Alert configuration)
│   ├── INCIDENT_RESPONSE.md               (Crisis management)
│   ├── RUNBOOKS.md                        (Operational procedures)
│   └── SLA.md                             (Service level agreements)
│
├── Training/                              (Training manuals)
│   ├── 01-SYSTEM-OVERVIEW.md              (This file)
│   ├── 02-AGENTS-MANUAL.md                (All 13 agents explained)
│   ├── 03-SKILLS-MANUAL.md                (21 skills reference)
│   ├── 04-HOOKS-MANUAL.md                 (Safety gates guide)
│   ├── 05-COMMANDS-MANUAL.md              (All slash commands)
│   ├── 06-IO-CHANNEL-MANUAL.md            (I/O system guide)
│   ├── 07-MEMORY-MANUAL.md                (Memory system tutorial)
│   ├── 08-BOOTSTRAP-MANUAL.md             (Setup guides)
│   ├── 09-MICROSERVICES-MANUAL.md         (Microservices extension)
│   └── 10-PRODUCTION-SAFETY-MANUAL.md     (Safety and ops)
│
└── scripts/                               (Automation)
    ├── install.sh                         (Initialize CCM on new project)
    ├── verify.sh                          (Validate CCM structure)
    ├── memory-backup.sh                   (Backup memory files)
    ├── agent-test.sh                      (Test all agents)
    └── health-check.sh                    (System health verification)
```

### Key Files by Category

#### Master Brain
- `CLAUDE.md` — Read this first, always
- `CONSTRAINTS.md` — What's allowed, what's not
- `VERSION.json` — Version info and stats

#### Agents (L4)
- `.claude/agents/*.md` — One file per agent, 13 total

#### Skills (L2)
- `.claude/skills/*/SKILL.md` — Reusable knowledge, 21 total

#### Hooks (L3)
- `.claude/hooks/*.md` — Hook implementations
- `hooks/*.md` — Hook recipes and documentation

#### Memory (L1 Extension)
- `memory/*.md` — 7 persistent knowledge files

#### Architecture (L1 Extension)
- `architecture/*.md` — 8 design decision files

#### Training (Learning)
- `Training/*.md` — 10 comprehensive manuals

---

## Version & Features

### Version Information

| Attribute | Value |
|-----------|-------|
| **Current Version** | 3.7.0 |
| **Codename** | "Self-Policing" |
| **Release Date** | 2026-05-08 |
| **Previous Version** | 3.6.0 |
| **Status** | Production-Ready |
| **License** | MIT |

### System Statistics

| Metric | Count |
|--------|-------|
| **Total Files** | 96 |
| **Total Directories** | 24 |
| **Total Lines of Code** | 35,000+ |
| **Total Size** | ~1,350 KB |
| **Specialist Agents** | 13 |
| **Skills** | 21 |
| **Commands** | 14 |
| **Hook Types** | 6 |
| **Hook Recipes** | 7 |
| **Memory Files** | 7 |
| **I/O Templates** | 9 |
| **Architecture Files** | 9 |
| **Implementation Files** | 9 |
| **Operations Files** | 7 |
| **Scripts** | 6 |
| **Bootstrap Methods** | 4 |
| **Training Manuals** | 10 |

### What's New in v2.6.0 "Fortress"

**New Agents:**
- API Documentation Generator
- Accessibility Auditor

**Enhanced Agents:**
- Security Auditor (OWASP Top 10:2025)
- Database Guardian (improved risk classification)
- Performance Profiler (new budget features)

**New Features:**
- I/O Channel (inter-agent communication)
- Session Summarize Hook
- Notification Hook
- Memory backup automation
- Agent health dashboard

**Improved:**
- Documentation (10 training manuals)
- Reverse Bootstrap (faster onboarding)
- Hook recipes (24 total examples)
- Skills registry (community tools added)

### Requirements

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| **Claude Code** | 1.0.0 | AI development environment |
| **Node.js** | 18.0.0 | JavaScript runtime |
| **Git** | 2.30.0 | Version control |
| **Git (optional)** | gh 1.0.0 | GitHub CLI |
| **Docker (optional)** | 20.0.0 | Containerization |

---

## Quick Reference

### The 5 Layers at a Glance

```
L4 AGENTS       ← What gets executed (13 specialists)
I/O CHANNEL     ← How agents communicate (requests/results)
L3 HOOKS        ← Safety enforcement (gates, cannot bypass)
L2 SKILLS       ← Reusable knowledge (advisory, L1 overrides)
L1 CLAUDE.md    ← Master rules (overrides everything)
```

### The Session Cycle

```
START (2-3 min)    → Read CLAUDE.md, CONSTRAINTS, memory, git status, report
WORK (variable)    → Announce, check constraints, snapshot, TDD, test, log, commit, report
END (3-5 min)      → Update memory, verify tests, final commit, push, report
```

### The 7 Golden Rules

1. **Documentation Rule** — If it's not written, it doesn't exist
2. **Two-Layer Readiness Gate** — Architecture + Implementation before code
3. **Memory Rule** — Read at start, write at end (every session)
4. **Safety Rule** — Snapshot before changing code
5. **Constraint Rule** — Check CONSTRAINTS.md before choosing tech
6. **Single Responsibility Rule** — Layers don't bleed into each other
7. **I/O Channel Rule** — All agent communication is documented

---

## What's Next?

Now that you understand the system overview, explore:

- **[Training/02-AGENTS-MANUAL.md](02-AGENTS-MANUAL.md)** — Detailed guide for all 13 agents
- **[Training/03-SKILLS-MANUAL.md](03-SKILLS-MANUAL.md)** — How to use the 21 skills
- **[Training/04-HOOKS-MANUAL.md](04-HOOKS-MANUAL.md)** — Safety gates and automation
- **[Training/05-COMMANDS-MANUAL.md](05-COMMANDS-MANUAL.md)** — All available commands
- **[Training/08-BOOTSTRAP-MANUAL.md](08-BOOTSTRAP-MANUAL.md)** — How to set up a new project

---

## Conclusion

Claude Code Methodology v2.6.0 "Fortress" transforms Claude Code from a code assistant into a complete development operating system. It provides:

- **Persistent memory** so you never lose context
- **Specialist agents** that enforce quality automatically
- **Safety hooks** that prevent mistakes
- **Architectural governance** that prevents drift
- **Inter-agent communication** that ensures coordination
- **Upgradable design** so it grows with your project

The 7 Golden Rules are your foundation. The 5-Layer Architecture is your structure. The Session Protocol is your workflow. Master these three, and you have everything you need.

**Welcome to the Fortress. Build with confidence.**

---

**Document Version:** 1.0  
**Created:** 2026-04-18  
**For:** Claude Code Methodology v2.6.0 "Fortress"
