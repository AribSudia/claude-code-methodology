# Claude Code Methodology (CCM)

### An opinionated methodology and skill pack for Claude Code

A convention layer for serious work in Claude Code: 27 branded `/arib-*` skills,
16 specialist agents, kernel-level enforcement hooks, path-scoped rules, persistent
memory files, a 5-mode bootstrap, a wave delivery overlay with auto-advancing
execution, a compliance layer, and full CI/PR governance. It is **not** a runtime,
an orchestrator, or a kernel — it is a set of conventions that make multi-session
Claude Code work durable.

**v3.12.0 "Reconcile"** · Engineered by Abdullah x Claude · Always-on token cost on session start: ~7.4K
(measure yours: `./scripts/token-audit.sh` — down from ~45.9K; reference docs load on demand)

> **What changed in v3.8.1–v3.8.3 "Lean Core"** — skill `name:` conformance
> on all 26 skills (CI-enforced); bootstrap protocols made autonomous
> (PROTOCOL_PRINCIPLES Rule 5 — run to completion, no permission gates);
> migration modernized to **"From Any System"** (Cursor/Windsurf/Copilot/Kiro;
> legacy path retired to an appendix); a **one-prompt unified entry** +
> Situation Router (you no longer pick a protocol); skill-hygiene sweep
> (linear steps, no duplicate headings); dead `agent-memory/` removed.
> ADR-020/021/022.
>
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
 ║   ⭐ ONE PROMPT (all situations):                                 ║
 ║      "Read claude-code-methodology/bootstrap/RUN.md and set up    ║
 ║       (or upgrade) CCM for this project."                         ║
 ║      → CCM detects your situation and runs the right protocol.    ║
 ║                                                                   ║
 ║   It auto-routes to:                                              ║
 ║   New project?       ──▶  Bootstrap (guided questionnaire)        ║
 ║   Existing project?  ──▶  Reverse Bootstrap (auto-scan)           ║
 ║   CCM installed?     ──▶  Upgrade (drift detection, preserves data)║
 ║   From Cursor/etc.?  ──▶  Migration (From Any System)             ║
 ║   Overlay on legacy  ──▶  Reengineering                          ║
 ║                                                                   ║
 ╚═══════════════════════════════════════════════════════════════════╝
```

> **The one-prompt method** (v3.8.3): you don't choose a protocol — paste the
> single prompt above and CCM's Situation Router detects your state from the
> filesystem and runs the right one autonomously. See `bootstrap/RUN.md`.

---

## Why This Exists

Claude Code is powerful — but without structure, every session starts from zero. Decisions get re-debated. Architecture drifts. Bugs come back. Context is lost.

This methodology solves all of that:

| Problem                          | Solution                                     |
|----------------------------------|----------------------------------------------|
| Claude forgets between sessions  | **Persistent Memory** — 6 file types, auto-updated |
| No consistent code quality       | **16 Specialist Agents** — each with checklists |
| Dangerous operations slip through| **Safety Hooks** — block before damage happens |
| Every session starts from scratch| **Session Protocol** — read → work → write    |
| Architecture decisions are lost  | **Decision Records** — permanent, searchable  |
| "It works on my machine"         | **Implementation Layer** — docker, runbook, env|
| Skills are shallow checklists    | **Deep Skills** — 27 comprehensive reference skills |

---

## The 4-Layer Architecture

```
╔══════════════════════════════════════════════════════════════╗
║  L4 — AGENTS          16 specialists with scoped context    ║
║  Architect · Security · Reviewer · Tester · Debugger        ║
║  Refactor · Language · Deploy Guardian · Reality Auditor     ║
║  Database Guardian · Performance · API Docs · Accessibility  ║
╠══════════════════════════════════════════════════════════════╣
║  L3 — HOOKS           Safety gates & automation             ║
║  PreToolUse · PostToolUse · PreCommit · Notification        ║
╠══════════════════════════════════════════════════════════════╣
║  L2 — SKILLS          27 branded /arib-* deep reference     ║
║  Session·Dev·Check·Wave·Audit·Docs·Engine (27 skills)    ║
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
# 1. Pull CCM straight from GitHub into your project (no manual download)
cd my-new-project
curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
#    (equivalent manual path: git clone … && cp -r claude-code-methodology/ my-new-project/)

# 2. Open Claude Code and paste the bootstrap prompt from bootstrap/BOOTSTRAP.md
#    Claude asks a guided questionnaire (25 core + conditional 2026 categories: AI/LLM, vector DB, multi-tenancy, realtime, edge)
#    Then generates ALL methodology files filled with YOUR real data

# 3. Start building
#    Type: /arib-session-start
#    Claude reads everything, knows your project, and begins
```

**What you get**: Every file populated — CONSTRAINTS.md with your rules, TECH_STACK.md with your libraries, API_ENDPOINTS.md with your routes, CONTEXT_MAP.md with your folders, and all 16 agents configured for your stack.

### Use Case 2: Existing Project (Reverse Bootstrap)

You have a codebase but no structure. CCM auto-scans everything and generates methodology files from your actual code.

```bash
# 1. Pull CCM straight from GitHub into your existing project (no manual download)
cd /path/to/your-existing-project
curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
#    (equivalent manual path: git clone … && cp -r claude-code-methodology/* .)

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

You are on an older CCM and want the latest. The upgrade protocol detects your version, runs drift detection, and preserves all your project data.

```bash
# 1. Pull the latest CCM source from GitHub (no manual re-download).
#    This SAME one-liner works even on old versions that have no local
#    ccm-fetch.sh yet — it downloads the script fresh from GitHub:
curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
#    (shortcut once you already have it: ./claude-code-methodology/scripts/ccm-fetch.sh --ref vX.Y.Z)

# 2. Open Claude Code and paste bootstrap/UPGRADE_PROTOCOL.md (or the one-prompt)
# Claude:
#   1. Backs up your current files
#   2. Copies new structure (skills, rules, .mcp.json)
#   3. Preserves all your memory files, architecture, and implementation
#   4. Migrates commands → skills automatically
#   5. Validates everything works
```

### Use Case 4: Migrate from another AI-coding system

You're coming from Cursor, Windsurf, GitHub Copilot, Kiro, an unstructured
`CLAUDE.md` — or the legacy `claude-code-system`. The one-prompt method
detects which and migrates your real content (rules, context, conventions)
into CCM; you don't have to choose "migrate."

```bash
# Just use the one-prompt method — it auto-detects tool markers and routes
# to bootstrap/MIGRATION_GUIDE.md (From Any System). The legacy
# claude-code-system path is retired to that guide's Appendix A.
```

### Use Case 5: Overlay on Legacy Codebase (Reengineering)

You have a legacy project with tech debt and want to gradually introduce the methodology without breaking anything.

```bash
# Open Claude Code and paste bootstrap/REENGINEERING_GUIDE.md
# Adds methodology as an overlay — non-destructive, incremental adoption
```

### Copy-Paste Prompt (Ready to Use)

**Just paste this — it works in every situation.** CCM detects whether you're
starting new, overlaying existing code, upgrading, or migrating from another
tool, and runs the right protocol autonomously:

```
Read claude-code-methodology/bootstrap/RUN.md and set up (or upgrade) CCM for
this project. Detect my situation from the filesystem per the Situation Router
and execute the matching protocol autonomously to completion.
```

That's it — no protocol to choose. (Advanced users who want to force a specific
protocol can use the explicit prompts in `bootstrap/RUN.md`.)

---

## The 27 /arib-* Skills

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

### Engine Skill

| Skill | Command | What It Does | Lines |
|-------|---------|-------------|-------|
| **Engine** | `/arib-engine [goal] [--with-arib-family] [--hold-merge]` | Autonomous campaign engine — discover→ship→verify→**reconcile**→close across many reversible PRs; adversarial find→refute→confirm sweeps; evidence-based closure + decision-list hand-off. Standalone by default; pace it with `/loop`. Auto-merges by default, gated on a `verification-agent` RECONCILED verdict (not CI alone); high-stakes always holds for a human; `--hold-merge` holds every PR. | 300 |

**Total**: 27 skills, comprehensive reference depth (run scripts/token-audit.sh — only the lean core loads at session start).

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

## Autonomous Campaigns — `/arib-engine`

Most skills do **one** thing. `/arib-engine` runs a **campaign**: hand it ownership and
it discovers its own backlog, then loops `discover → ship → verify → integrate → record`
across many small, reversible PRs — and **decides when it's done on the evidence**, not
when you tell it to. It's the continuous-campaign cousin of the wave overlay: a wave
executes a *known* PLAN to completion; the engine *finds* the work and runs until a
closure test passes. Adopted from the AEPG methodology in v3.11.0 (ADR-026); full
reference in [`reference/AUTONOMOUS_ENGINEERING_METHODOLOGY.md`](reference/AUTONOMOUS_ENGINEERING_METHODOLOGY.md).

### Use cases — how to invoke it

| You want… | Invoke | What happens |
|-----------|--------|--------------|
| **One focused pass** (scoped) | `/arib-engine harden auth + payments` | One `discover→ship→verify` cycle on that goal, then it **stops** |
| **A continuous campaign** | `/loop /arib-engine <goal>` | `/loop` paces it (event-gated + heartbeat); the engine runs tick after tick until the closure test passes |
| **"Make it all"** (no scope) | `/arib-engine` | Autonomous mode — finds & ships every verified improvement, descending by severity, until done |
| **Orchestrate the whole toolkit** | `/arib-engine --with-arib-family <goal>` | Becomes the conductor: drives the `arib-check-*`, `arib-dev-*`, `arib-docs-*` skills per phase (degrades to inline for any absent) |
| **Review each merge yourself** | `/arib-engine --hold-merge <goal>` | Holds *every* PR at a human gate (otherwise merge is automatic — see below) |

> **Standalone by default.** With no `--with-arib-family`, the engine is fully
> self-contained and portable — it runs every phase inline and never reaches for sibling
> skills, even when they're installed. Family orchestration is strictly opt-in.

### How it stays safe

The engine is autonomous about *what to do next*, *when it's done*, and — as of v3.12.0
— *whether a PR is safe to merge*. The safety lives in an intelligent gate, not a blanket
human checkpoint:

- **Merge is auto by default, but gated on *reconciliation* — not CI alone.** Before any
  merge, the **`verification-agent`** reconciles what was *discovered* against what was
  *actually changed* (intent ↔ implementation). Merge fires only on a **RECONCILED**
  verdict + green blocking checks; a **GAP** loops back to re-engineer; **HOLD** routes to
  a human. CI-green alone is never merge authority.
- **High-stakes always holds for a human.** Money/auth/compliance/secrets/breaking-migration
  PRs never auto-merge regardless of mode (CONSTRAINTS #17), and `--hold-merge` holds
  *everything*. Branch protection still governs — auto-merge never bypasses a required review.
- **Discovery is adversarial, not credulous.** Every finding runs `find → refute → confirm`
  (skeptics that default to "not a bug", then a ground-truth code read) — but
  security/authz/tenant-isolation/money/secrets findings are **exempt** from that
  reject-biased filter, because there a false negative is catastrophic.
- **It escalates the calls it shouldn't make.** Compliance/tax/pricing/policy decisions,
  secrets, and breaking migrations are handed back as a structured **decision list**
  (question + options + recommendation + what's de-risked), not decided unilaterally.

### When to reach for it (and when not)

- **Use `/arib-engine`** for a sustained "harden / audit / sweep / keep shipping value"
  effort across many concerns.
- **Use a wave** (`/arib-wave-start → run → end`) when you already know the plan.
- **Just do the fix** for a single quick change — a campaign engine is overkill.

---

## The 16 Specialist Agents

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
| **Planner**           | wave-start, "sequence", "plan steps" | Step sequence + dependency map + risk register |
| **CI/PR Engineer**    | "/arib-ci-audit", workflows, CODEOWNERS | CI/PR posture report (audit/init/review/BP) |
| **Verification Agent**| pre-merge in `/arib-engine` + Waves     | RECONCILED / GAP / HOLD — reconciles discovered↔fixed before merge |

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

## Training Manuals (11 Guides)

The `Training/` directory contains **11 comprehensive user manuals** — everything a developer needs to learn and master the methodology.

| Manual | File | What It Covers |
|--------|------|----------------|
| **01 — System Overview** | `Training/01-SYSTEM-OVERVIEW.md` | Complete system architecture, how all layers connect, mental model |
| **02 — Agents Manual** | `Training/02-AGENTS-MANUAL.md` | All 15 agents explained — triggers, checklists, outputs, customization |
| **03 — Skills Manual** | `Training/03-SKILLS-MANUAL.md` | Skills system — how they work, how to use /arib-* commands |
| **04 — Hooks Manual** | `Training/04-HOOKS-MANUAL.md` | Safety hooks — 6 types, 7 recipes, configuration, custom hooks |
| **05 — Commands Manual** | `Training/05-COMMANDS-MANUAL.md` | All slash commands explained with examples and workflows |
| **06 — I/O Channel Manual** | `Training/06-IO-CHANNEL-MANUAL.md` | Inter-agent communication — requests, signals, pipelines, templates |
| **07 — Memory Manual** | `Training/07-MEMORY-MANUAL.md` | Memory system — 7 file types, update rules, archival, continuity |
| **08 — Bootstrap Manual** | `Training/08-BOOTSTRAP-MANUAL.md` | All 5 bootstrap methods — new, existing, upgrade, migrate, reengineer |
| **09 — Microservices Manual** | `Training/09-MICROSERVICES-MANUAL.md` | Microservices extension — service map, contracts, orchestration |
| **10 — Production Safety** | `Training/10-PRODUCTION-SAFETY-MANUAL.md` | Incident response, monitoring, SLOs, on-call, post-mortems |
| **11 — CI/PR Manual** | `Training/11-CI-PR-MANUAL.md` | CI workflows, PR governance, CODEOWNERS, branch protection, /arib-ci-audit |

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
claude-code-methodology/                  ← v3.10 "Integrity" — counts live in VERSION.json
│
├── CLAUDE.md                             ← The Master Brain (lean core, always-on)
├── SYSTEM.md                             ← Full system spec
├── VERSION.json                          ← Version metadata + canonical stats
├── CHANGELOG.md                          ← Full version history (v1.0 → current)
├── CONTRIBUTING.md / SECURITY.md / CODE_OF_CONDUCT.md
├── .mcp.json                             ← MCP server configuration (opt-in servers)
├── .worktreeinclude                      ← Gitignored files to copy into worktrees
│
├── .claude/
│   ├── settings.json                     ← Permissions + hook wiring (committed)
│   ├── settings.local.json               ← Personal overrides (gitignored)
│   ├── rules/                            ← 9 path-scoped rule files (load on matching paths)
│   ├── skills/                           ← 27 branded skills (/arib-*) — see the table above
│   ├── agents/                           ← 15 specialist agent definitions — see the table above
│   ├── hooks/                            ← 7 hook scripts + lib/common.sh (exit-2 blocking gates)
│   ├── commands/                         ← legacy commands (deprecated; kept for back-compat)
│   └── output-styles/                    ← Custom output styles
│
├── core/                                 ← Living project context (your specs, schemas)
│
├── Training/                             ← 11 user manuals (01-SYSTEM-OVERVIEW → 11-CI-PR)
│
├── memory/                               ← Persistent memory (7 data files + MEMORY_PROTOCOL.md)
│   ├── project_status.md                 ← Where the project stands (always-on)
│   ├── session_notes.md                  ← Session handoff log (always-on)
│   └── change_log / architecture_decisions / bugs_and_fixes / testing_log / semantic_export
│
├── architecture/                         ← Layer A — what to build
│   ├── CONSTRAINTS.md                    ← Hard rules (always-on)
│   ├── TECH_STACK / CONTEXT_MAP / ERROR_PATTERNS / DECISIONS / SECURITY / WORKFLOW
│   ├── AGENT_ARCHITECTURE.md             ← Agent dispatch governance
│   ├── DESIGN_SYSTEM.md                  ← Design-token contract (hook-enforced)
│   └── SERVICE_MAP / INTER_SERVICE       ← [Microservices extension]
│
├── implementation/                       ← Layer B — how to start coding
│   ├── API_ENDPOINTS / EVENT_SCHEMA / MIGRATION_ORDER / GATEWAY_ROUTES
│   ├── docker-compose.yml / DOCKER_LOCAL / LOCAL_RUNBOOK
│   └── CONTRACT_TESTING                  ← [Microservices extension]
│
├── operations/                           ← How work gets done
│   ├── WORKFLOW / DEPLOYMENT / OPERATIONS_LOG / AUTONOMY_MODE
│   ├── INCIDENT_RESPONSE / MONITORING
│   └── OBSERVABILITY / ORCHESTRATION     ← [Microservices extension]
│
├── io/                                   ← I/O Channel (inter-agent comms + audit ledger)
│   ├── IO_PROTOCOL.md / status.md / BRIEFING_* / COWORK_PROMPT.md
│   ├── ledger/                           ← Audit reports, invocation telemetry
│   └── .templates/                       ← Pre-built request templates
│
├── waves/                                ← Multi-session delivery overlay (PLAN/REPORT/HISTORY)
├── compliance/                           ← OWASP/GDPR/ISO/SOC2/PDPL alignment + honesty principle
├── hooks/                                ← HOOKS_PROTOCOL.md (executables live in .claude/hooks/)
│
├── bootstrap/                            ← Project instantiation (one-prompt entry: RUN.md)
│   ├── RUN.md                            ← ⭐ Situation Router — the one prompt for all cases
│   ├── PROTOCOL_PRINCIPLES.md            ← Binding charter (Rules 1-5, autonomous execution)
│   ├── BOOTSTRAP.md                      ← New project (guided questionnaire)
│   ├── REVERSE_BOOTSTRAP.md              ← Existing project (auto-scan)
│   ├── REENGINEERING_GUIDE.md            ← Overlay on legacy code (non-destructive)
│   ├── UPGRADE_PROTOCOL.md               ← Safe v-old → v-new upgrade (drift detection)
│   └── MIGRATION_GUIDE.md                ← From Any System (Cursor/Windsurf/Copilot/Kiro)
│
├── reference/                            ← MASTER_GUIDE, registries, template-hashes.json
│
├── tests/fixtures/payloads/              ← Hook regression fixtures
│
└── scripts/                              ← 14 automation scripts
    ├── ccm-fetch.sh                      ← ⭐ Pull latest CCM from GitHub (install + update)
    ├── validate-coherence.sh             ← Self-policing invariants (CI-enforced)
    ├── validate-system.sh                ← Structure + counts vs VERSION.json (dynamic)
    ├── test-hooks.sh                     ← Hook regression suite
    ├── token-audit.sh                    ← Always-on vs path-scoped token cost
    ├── drift-detect.sh / gen-template-hashes.sh  ← Upgrade drift classifier
    ├── install-hooks.sh / io-watcher.sh / io-archive.sh / memory-export.sh
    └── git-setup.sh / github-push.sh / services-check.sh
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
| v3.8 | Lean Core | Always-on context 45.9K→7.4K (84%), under the 8K target — reference docs load on demand (ADR-019). The C+→A+ token gate, cleared. |
| v3.8.1 | Lean Core | Skill `name:` conformance (all 26, CI-enforced) + autonomous bootstrap execution (PROTOCOL_PRINCIPLES Rule 5) (ADR-020) |
| v3.8.2 | Lean Core | Migration modernized to "From Any System" (Cursor/Windsurf/Copilot/Kiro), legacy path retired to Appendix A (ADR-021) |
| v3.8.3 | Lean Core | One-prompt unified entry + Situation Router, skill-hygiene sweep, dead `agent-memory/` removed (ADR-022) |
| v3.8.4 | Lean Core | Invocation telemetry (`invocation-log.sh`) + upgrade Phase 1.6 re-verification recommendations (ADR-023) |
| v3.9.0 | Live Update | Fetch CCM directly from GitHub — `scripts/ccm-fetch.sh` + curl one-liner; no manual re-download (ADR-024) |
| v3.9.1 | Live Update | Doc fix: curl one-liner is the universal entry — old versions without a local `ccm-fetch.sh` upgrade with the same line |
| v3.9.2 | Live Update | `ccm-fetch.sh` UX: explicit 2-step output (source vs. project root), reads the deployed version, install-vs-upgrade-aware hand-off |
| v3.10.0 | Integrity | Six-agent full audit + fix wave: hooks fail CLOSED, validate-system.sh rewritten dynamic, docs-match-disk sweep, ccm-fetch hardening, dead infra deleted (ADR-025) |
| v3.11.0 | Engine | `/arib-engine` autonomous-campaign skill (standalone-first, opt-in family orchestration, `/loop`-paced) + folded AEPG into CCM: adversarial find→refute→confirm in deep-audit, verify-before-fix/`TZ=UTC`/backward-compat constraints (#14–#17), wave-end closure test (ADR-026) |
| **v3.12.0** | **Reconcile** | **`verification-agent` (16th) reconciles discovered↔fixed before merge; `/arib-engine` + Waves flip to AUTO-MERGE by default gated on reconciliation (not CI alone), `--hold-merge` opt-out, high-stakes always human; Waves become a reference-based validate→re-engineer loop (ADR-027)** |

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
