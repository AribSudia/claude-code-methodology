# Bootstrap Protocol — New Project Instantiation

> **Purpose**: Transform the universal methodology into a project-specific
> Claude Code system. Claude Code asks the questionnaire, understands your
> project, then CREATES every file in your project root — pre-filled with
> YOUR actual data, not blank templates.

---

## HOW TO USE

```
1. Place the claude-code-methodology/ folder inside your project root
   (or make it accessible by path)
2. Create a core/ folder in your project root and drop your project files
   (specs, designs, schemas, wireframes, API docs — anything that describes your project)
3. Open Claude Code in your PROJECT ROOT (cd ~/Projects/YourProject/)
4. Paste the prompt below
5. Claude Code reads core/ first, then asks smarter questions,
   then CREATES all files directly in your project root
6. Type /arib-session-start → BUILD
```

---

## Copy-Paste Prompt for Claude Code

Open Claude Code in your **project root**, then paste this:

═══════════════════════════════════════════════════════════════════════

Read `claude-code-methodology/bootstrap/BOOTSTRAP.md` and execute the
full bootstrap protocol for this new project. Follow every step exactly.

**CONTEXT:**
- SOURCE (methodology templates): `./claude-code-methodology/`
- TARGET (my project): `.` — the current working directory (project root)
- This is a NEW project — no methodology files exist yet in the root

**YOUR JOB:**
1. Read `core/` folder first — these are my real project files (specs, designs, schemas).
   Read EVERY file in core/ to deeply understand my project before asking anything.
   If core/ is empty or doesn't exist, skip to step 2.
2. Read the methodology's CLAUDE.md, architecture templates, and SKILLS_REGISTRY
3. Ask me the 25-question Project Questionnaire (from BOOTSTRAP.md).
   For any question where core/ already provides the answer, CONFIRM instead of asking:
   "I see from your schema that you have a users table with 12 fields — is this current?"
4. Wait for ALL answers before proceeding
5. Create the directory structure in my project root:
   mkdir -p .claude/agents .claude/skills .claude/rules .claude/agent-memory .claude/output-styles
   mkdir -p memory architecture implementation operations
   mkdir -p io/requests io/results io/signals io/pipelines io/threads io/archive io/.templates
   mkdir -p hooks reference scripts bootstrap core
6. Generate EVERY file customized with my real project data
   (use core/ files as primary source - they have the real specs, schemas, designs)
7. Copy skills from methodology: cp -r claude-code-methodology/.claude/skills/arib-* .claude/skills/
8. Copy rules from methodology: cp claude-code-methodology/.claude/rules/*.md .claude/rules/
9. Create .mcp.json at project root with MCP server config
10. WRITE every file to the PROJECT ROOT (.), NOT inside claude-code-methodology/
11. Verify all files exist and report the results

**CRITICAL RULES:**
- WRITE files to `.` (project root), NOT to `claude-code-methodology/`
- NO placeholders like [PROJECT] or [YOUR NAME] - use my REAL data
- Every file must contain my actual project info (entities, routes, stack)
- The bootstrap is NOT done until files physically exist in the project root
- Skills go in `.claude/skills/`, NOT `.claude/commands/` (commands are deprecated)
- After writing, verify with: ls .claude/skills/ && ls .claude/agents/ && ls .claude/rules/

═══════════════════════════════════════════════════════════════════════

---

## Detailed Protocol (for Claude Code to follow)

You are a senior software architect and Claude Code expert.
Your job in this session is to read my project reference files,
fully understand the idea and all its details, then customize a
complete Claude Code system — every file pre-filled with my actual
project data, not blank templates.

---

## STEP 0 — Read core/ Project Context (FIRST)

Before reading anything else, check if a `core/` folder exists in the project root:

```bash
ls core/ 2>/dev/null
```

**If core/ exists and has files:**
Read EVERY file in core/. These are the user's real project documents - specs, designs, schemas, wireframes, API docs, database schemas, business requirements.

After reading, build a mental model of:
- What the project IS (purpose, users, domain)
- What entities/tables exist (from schemas)
- What the UI looks like (from wireframes/mockups)
- What technologies are planned (from specs)
- What APIs exist or are planned (from API docs)
- What business rules matter (from requirements)

This context makes the questionnaire in Step 2 a CONFIRMATION exercise instead of a discovery exercise. Instead of asking "what's your database schema?" you say "I see from your schema.sql that you have 8 tables - users, shifts, locations... Is this current?"

**If core/ doesn't exist or is empty:**
Skip to Step 1. The questionnaire will gather everything from scratch.

---

## STEP 1 — Read My Reference Files

Read these files now. Do not skip any.

**System files (read first — these define the structure):**
- CLAUDE.md → The Master Brain. Defines the 4-layer architecture,
  session protocol, and all system rules.
- architecture/CONSTRAINTS.md → Hard rules template
- architecture/SECURITY.md → Security specification template
- implementation/API_ENDPOINTS.md → Endpoint inventory template
- reference/SKILLS_REGISTRY.md → Available skills catalog

**Project specification (read second):**
- reference/[PROJECT_SPEC].md → My project specification file.
  Contains the full idea, features, entities, user roles, business
  rules, and tech stack.

After reading both sets of files, answer the Project Questionnaire
below. If any answer is unclear from the reference files, ask me.

---

## STEP 2 — Project Questionnaire (25 Questions)

### Identity
1. What is the project name?
2. What type of system is it? (Web app, mobile, API, SaaS, marketplace, etc.)
3. Who owns it? (Person or organization)
4. What problem does it solve? (One paragraph)
5. Who are the target users? (List every role with permissions)

### Technical Foundation
6. What is the backend technology? (Language, framework, version)
7. What is the frontend technology? (Framework, styling, version)
8. What is the mobile technology? (If applicable)
9. What database? (Type, version, managed or self-hosted)
10. What caching layer? (Redis, Memcached, none)
11. What authentication strategy? (JWT, session, OAuth, MFA)
12. What payment provider? (If applicable)

### Architecture
13. Monolith, modular monolith, or microservices?
    → If **microservices**: also answer Q13a–Q13e below
14. Does it use async events? (Queues, pub/sub, webhooks)
15. Does it need an API gateway?
16. What external services does it integrate with? (Storage, email, SMS, maps, etc.)
17. Does it need Arabic/RTL support?
18. What timezone is the primary market? (e.g., Asia/Riyadh)

### Architecture — Microservices Extension (only if Q13 = microservices)
13a. List every service with its responsibility (one sentence each)
13b. How do services communicate? (REST, gRPC, events, or hybrid)
13c. What message broker? (RabbitMQ, Kafka, Redis Streams, SQS, none)
13d. What container orchestration? (Kubernetes, Docker Swarm, ECS, none)
13e. Monorepo or multi-repo?

### Data Model
19. What are the core entities? (List every database table with key fields)
20. What are the relationships between entities? (Foreign keys, many-to-many)
21. Are there any complex business rules? (e.g., "a shift cannot be approved after publication")

### Scope
22. What are the MVP features? (List every feature that must exist at launch)
23. What are the Phase 2 features? (Post-launch)
24. What are the non-functional requirements? (Performance, uptime, compliance)
25. What is the deployment target? (Cloud provider, containerized, serverless)

Do not proceed to Step 3 until all 25 questions are answered clearly.

---

## STEP 3 — Generate AND DEPLOY Customized Files

Once you fully understand the project, customize every file below
AND WRITE THEM DIRECTLY INTO THE PROJECT ROOT DIRECTORY.

╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  CRITICAL DEPLOYMENT RULE                                   ║
║                                                                  ║
║  You MUST create every file listed below as REAL FILES in the    ║
║  CURRENT WORKING DIRECTORY (the project root where Claude Code   ║
║  is running). Do NOT just display them in chat. Do NOT just      ║
║  print code blocks. Do NOT leave them only inside                ║
║  claude-code-methodology/.                                       ║
║                                                                  ║
║  USE: mkdir -p, then write each file to the PROJECT ROOT.        ║
║                                                                  ║
║  EXAMPLE: If Claude Code is running in ~/Projects/MotorGate/     ║
║  then CLAUDE.md goes to ~/Projects/MotorGate/CLAUDE.md           ║
║  and agents go to ~/Projects/MotorGate/.claude/agents/*.md       ║
║                                                                  ║
║  The project root is: . (current working directory)              ║
╚══════════════════════════════════════════════════════════════════╝

Each file must contain my ACTUAL project data — real entity names,
real field names, real route paths, real service names, real
environment variables, real business rules.

**NO blank placeholders like "[Your Name]" or "[Feature]".**
**NO generic examples. Everything must be specific to THIS project.**

### Step 3.0 — Create Directory Structure FIRST

Before writing any files, create the full directory structure:

```bash
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p .claude/rules
mkdir -p .claude/agent-memory
mkdir -p .claude/output-styles
mkdir -p .claude/commands
mkdir -p memory
mkdir -p architecture
mkdir -p implementation
mkdir -p operations
mkdir -p io/requests io/results io/signals io/pipelines io/threads io/archive io/.templates
mkdir -p hooks
mkdir -p reference
mkdir -p scripts
mkdir -p bootstrap
mkdir -p core
```

### Files to Generate AND WRITE to Project Root (in order):

**Layer A — Architecture (customize all [PROJECT] sections):**
1. CLAUDE.md — Fill project overview, roles, features, tech stack, entities, API structure
2. architecture/CONSTRAINTS.md — Add project-specific domain rules
3. architecture/TECH_STACK.md — Only technologies this project uses
4. architecture/WORKFLOW.md — Project-specific git flow customizations
5. architecture/CONTEXT_MAP.md — Real folder structure for this project
6. architecture/ERROR_PATTERNS.md — Add domain-specific error patterns
7. architecture/DECISIONS.md — ADR for each major tech decision already made
8. architecture/SECURITY.md — Project-specific security requirements

**Layer B — Implementation (fill with real data):**
9. implementation/API_ENDPOINTS.md — COMPLETE endpoint inventory with real routes
10. implementation/docker-compose.yml — Only services this project needs
11. implementation/DOCKER_LOCAL.md — Real ports, credentials, setup steps
12. implementation/EVENT_SCHEMA.md — Real events with real payloads (or "sync only" note)
13. implementation/MIGRATION_ORDER.md — Real table dependency graph
14. implementation/LOCAL_RUNBOOK.md — Real clone-to-running steps
15. implementation/GATEWAY_ROUTES.md — Real routing (or "monolith, no gateway" note)

**Layer B+ — Microservices Extension (ONLY if Q13 = microservices):**
If the user answered "microservices" to Q13, ALSO generate these files.
If monolith or modular monolith, SKIP this entire section.

15a. architecture/SERVICE_MAP.md — Complete service registry with:
     - Architecture pattern table filled
     - Every service documented (name, port, owner, database, responsibility)
     - Service dependency matrix (which services call which)
     - Data ownership rules (which service owns which entities)
     - Communication patterns per service pair
15b. architecture/INTER_SERVICE.md — Filled with real service interactions:
     - Communication decision for each service pair (REST/gRPC/event/command)
     - Event envelope with real event names and real payloads
     - Saga definition for multi-service transactions (if any)
     - Circuit breaker config per dependency
     - Retry policy per call type
15c. operations/OBSERVABILITY.md — Filled with real service names:
     - Structured log format with real service names
     - Distributed tracing setup for the chosen infra (Jaeger/Zipkin/X-Ray)
     - Per-service metrics with real endpoint paths
     - Health check config per service
     - Alerting rules tuned to this project
15d. implementation/CONTRACT_TESTING.md — Filled with real contracts:
     - Consumer contract for each service pair (who calls whom)
     - Event schema for each published event
     - API versioning strategy for this project
15e. operations/ORCHESTRATION.md — Filled with real deployment config:
     - Dockerfile per service (customized for the tech stack)
     - docker-compose.yml with all services + databases + broker
     - Kubernetes manifests (if Q13d = Kubernetes)
     - Helm values per service
     - CI/CD pipeline per service
     - Scaling policy per service

**Memory (initialize):**
16. memory/project_status.md — Current phase: Setup, all features "Not Started"
17. memory/session_notes.md — Bootstrap session entry
18. memory/change_log.md — Initial entry listing all files created
19. memory/architecture_decisions.md — ADRs for decisions already made

**Config:**
20. .env.example — ALL real environment variables this project needs
21. .gitignore — Standard + project-specific ignores (include .claude/settings.local.json)
22. .claude/settings.json — Include all project context files
23. .mcp.json — MCP server configuration at project root (NOT inside .claude/)
24. .worktreeinclude — Gitignored files to copy into worktrees

**Rules (path-scoped, extracted from CLAUDE.md):**
25. Copy rule files from `claude-code-methodology/.claude/rules/` to `.claude/rules/`

```bash
# Copy path-scoped rules to project root:
mkdir -p .claude/rules
cp claude-code-methodology/.claude/rules/*.md .claude/rules/
```

**Skills (official arib brand — replaces deprecated commands):**
26. Copy all 16 skill directories from `claude-code-methodology/.claude/skills/arib-*/`
    to the project root `.claude/skills/`

```bash
# Copy arib-branded skills to project root:
mkdir -p .claude/skills
cp -r claude-code-methodology/.claude/skills/arib-* .claude/skills/
```

**Legacy Commands (optional backward compatibility):**
27. Optionally copy legacy command files for projects still using the old format

```bash
# Optional: Copy legacy commands for backward compatibility
mkdir -p .claude/commands
cp claude-code-methodology/.claude/commands/arib-*.md .claude/commands/
```

---

## STEP 4 — Activate v3.4 enforcement layer + CI/PR governance

Before verification, **install the hooks AND wire CI/PR governance**.
Without these, the methodology ships as docs only — every "blocked by
hook" or "required check" claim is honor-system until the scripts and
workflows are wired.

```bash
# Make hooks executable, install git pre-commit hook delegate, smoke-test.
./scripts/install-hooks.sh
```

The installer is idempotent (safe to re-run), verifies dependencies
(`jq`, `git`, `curl`), and exits non-zero if anything is missing.

**Wire optional MCP servers (skip any you don't use):**

```bash
# Hybrid memory (Item #3) — semantic search across sessions.
export CLAUDE_MEM_API_KEY=...

# Push notifications (Item #4) — Slack / Discord / Telegram / WhatsApp.
export CCM_NOTIFY_WEBHOOK=https://your-webhook-endpoint

# Cloud test gate (Item #9) — pre-deploy verification.
export TESTSPRITE_API_KEY=...
```

If you skip them, CCM falls back gracefully — see `compliance/README.md`
for the honesty principle. The MCPs are opt-in by design.

**Populate `architecture/CONTEXT_MAP.md` `allowed_write_paths`:**

The path-scoping hook reads this list. The bootstrap writes a default
covering `apps/`, `packages/`, `services/`, `src/`, `migrations/`,
`tests/`, `docs/`, `memory/`, `io/`, `waves/`, `compliance/`,
`proposals/`, `architecture/`, `implementation/`, `operations/`,
`core/`, `bootstrap/`, `reference/`, `scripts/`, `hooks/`, `Training/`,
`.github/`, `.claude/`. Adjust per project.

**Wire CI/PR governance (v3.4):**

The bootstrap should copy:
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/`
- `.github/CODEOWNERS` (replace `@AribSudia` with the project's owner)
- `.github/dependabot.yml`
- `.github/workflows/{hooks,json-validate,token-budget,markdown-lint}.yml`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- `.markdownlint.json`

Then in the GitHub repo Settings → Branches, apply branch protection
to `main` per `CONTRIBUTING.md` §6:
- Require PR + 1 approval + Code Owner review
- Require status checks: hooks regression, JSON validate, token
  budget, markdown lint
- Require linear history (squash or rebase)
- No bypass; direct push reserved for maintainer emergencies

See `Training/11-CI-PR-MANUAL.md` for the full integration guide.

---

## STEP 5 — Deployment Verification

After writing ALL files to the project root, verify the deployment:

```bash
# 1. Verify directory structure exists
ls -la .claude/agents/ .claude/skills/ .claude/rules/ memory/ architecture/ implementation/ operations/ io/

# 2. Count total files created
find . -name '*.md' -o -name '*.json' -o -name '*.yml' -o -name '*.sh' | grep -v node_modules | grep -v .git | wc -l

# 3. Verify critical files exist
test -f CLAUDE.md && echo "✅ CLAUDE.md" || echo "❌ CLAUDE.md MISSING"
test -f .mcp.json && echo "✅ .mcp.json" || echo "❌ .mcp.json MISSING"
test -f .claude/agents/architect.md && echo "✅ Agents" || echo "❌ Agents MISSING"
test -d .claude/skills/arib-session-start && echo "✅ Skills (branded: arib-)" || echo "❌ Skills MISSING"
test -d .claude/rules && echo "✅ Rules" || echo "❌ Rules MISSING"
test -f memory/MEMORY_PROTOCOL.md && echo "✅ Memory" || echo "❌ Memory MISSING"

# 4. Verify skills will appear in / menu
ls .claude/skills/
```

Report to the user:
- Total files created in project root
- Key customizations for this project
- Confirmation that `/arib-session-start` will work
- Any warnings or issues found

**IMPORTANT**: If any file was NOT written to the project root,
write it now. The bootstrap is NOT complete until every file
exists as a real file in the project directory.

---

## STEP 5 — Reference Folder Instructions

Write explicit instructions for Claude Code explaining:
1. Where reference files live
2. Which reference files to read and in what order
3. How reference files relate to the generated system files
4. What to do if a reference conflicts with implementation reality
5. How to update generated files when the reference evolves

═══════════════════════════════════════════════════════════════════════

## END OF BOOTSTRAP PROMPT
