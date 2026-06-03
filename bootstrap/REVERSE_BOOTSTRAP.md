# Reverse Bootstrap — Reengineering an Existing Project

> **Decisive behavior** (v3.5.1+): per `bootstrap/PROTOCOL_PRINCIPLES.md`,
> the auto-scan determines stack, routes, models, and configs from
> the codebase. Ask the user only when scan results are genuinely
> ambiguous — never present a 1-of-3 menu when a default is correct.
>
> **Purpose**: When you already have a working codebase and want to overlay
> the Claude Code Methodology on top of it. Claude Code scans your actual
> code, extracts everything, and CREATES every methodology file in your
> project root — filled with real data from your existing code.

---

## WHEN TO USE THIS

- You have an existing project with real code, real routes, real database
- You want Claude Code to understand and work with it professionally
- You want persistent memory, agents, constraints, and the full system
- You're potentially renaming or restructuring the project

---

## HOW TO USE

```
1. Place the claude-code-methodology/ folder inside your existing project
   (or make it accessible by path)
2. If you have extra project docs (specs, designs, schemas, wireframes),
   create a core/ folder in project root and drop them there
3. Open Claude Code in your PROJECT ROOT (cd ~/Projects/YourExistingProject/)
4. Paste the prompt below
5. Claude Code reads core/ + scans your codebase, extracts real data,
   and CREATES all methodology files directly in your project root
6. Type /arib-session-start → BUILD
```

---

## Copy-Paste Prompt for Claude Code

Open Claude Code in your **existing project root**, then paste this:

═══════════════════════════════════════════════════════════════════════

Read `claude-code-methodology/bootstrap/REVERSE_BOOTSTRAP.md` and execute
the full reverse bootstrap protocol on this existing codebase. Follow every phase exactly.

**CONTEXT:**
- SOURCE (methodology templates): `./claude-code-methodology/`
- TARGET (my project): `.` — the current working directory (project root)
- This project already has code — scan it and extract real data
- My code is in this directory (src/, controllers, models, routes, etc.)

**YOUR JOB:**
1. Read `core/` folder first if it exists - these are my project docs (specs, designs, schemas)
   Read EVERY file in core/ for extra context beyond the code itself.
   If core/ doesn't exist or is empty, skip to step 2.
2. Perform the Deep Codebase Scan (Phase 1) - scan every file, route, model, config
3. Analyze & Synthesize findings (Phase 2) - report what you found (from code AND core/) inline, then PROCEED autonomously (per PROTOCOL_PRINCIPLES Rule 5 — no stop-and-wait gate; only the genuine blockers pause execution)
4. Create the directory structure in my project root:
   mkdir -p .claude/agents .claude/skills .claude/rules .claude/agent-memory .claude/output-styles
   mkdir -p memory architecture implementation operations
   mkdir -p io/requests io/results io/signals io/pipelines io/threads io/archive io/.templates
   mkdir -p hooks reference scripts bootstrap core
5. Generate EVERY methodology file filled with REAL data from my codebase and core/ docs
6. WRITE every file to the PROJECT ROOT (.), NOT inside claude-code-methodology/
7. Verify all files exist and report the results

**CRITICAL RULES:**
- SCAN my actual code to extract real entities, routes, tech stack, business rules
- WRITE files to `.` (project root), NOT to `claude-code-methodology/`
- NO placeholders — everything comes from my actual codebase scan
- The bootstrap is NOT done until files physically exist in the project root
- Skills go in `.claude/skills/`, NOT `.claude/commands/` (commands are deprecated)
- After writing, verify with: ls .claude/skills/ && ls .claude/agents/ && ls memory/

═══════════════════════════════════════════════════════════════════════

---

## Detailed Protocol (for Claude Code to follow)

You are a senior software architect performing a **codebase reengineering audit**.

Your mission: scan this entire existing codebase, understand everything about
it, then generate a complete Claude Code Methodology system — every file
filled with real data extracted from the actual code. Not templates. Not
guesses. Real data from real files.

---

## PHASE 1 — Deep Codebase Scan

Perform a systematic scan of the entire project. Execute these commands
and analyze the results. Do NOT skip any step.

### 1.1 — Project Structure Discovery

```bash
# Overall structure
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' | head -200

# Directory tree (top 3 levels)
find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -maxdepth 3 | sort

# File type distribution
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20
```

### 1.2 — Tech Stack Detection

```bash
# Package manager and dependencies
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat *.csproj 2>/dev/null || cat Cargo.toml 2>/dev/null || cat go.mod 2>/dev/null || cat Gemfile 2>/dev/null

# Framework detection
grep -r "express\|fastify\|koa\|nest\|next\|nuxt\|django\|flask\|fastapi\|spring\|rails\|laravel\|gin\|fiber" package.json requirements.txt *.csproj 2>/dev/null | head -20

# Database detection
grep -ri "postgres\|mysql\|mongodb\|sqlite\|redis\|prisma\|sequelize\|typeorm\|mongoose\|entity.framework\|sqlalchemy\|drizzle" . --include='*.json' --include='*.ts' --include='*.js' --include='*.py' --include='*.cs' --include='*.yaml' --include='*.yml' --include='*.env*' -l 2>/dev/null | head -20

# Docker check
cat docker-compose.yml 2>/dev/null || cat docker-compose.yaml 2>/dev/null || cat Dockerfile 2>/dev/null
```

### 1.3 — Database Entity Extraction

```bash
# Prisma models
cat prisma/schema.prisma 2>/dev/null

# SQL migrations
find . -path '*/migrations/*' -name '*.sql' -o -path '*/migrations/*' -name '*.ts' -o -path '*/migrations/*' -name '*.cs' 2>/dev/null | sort

# TypeORM / Sequelize entities
find . -name '*.entity.ts' -o -name '*.entity.js' -o -name '*.model.ts' -o -name '*.model.js' -o -name '*.model.py' 2>/dev/null

# Entity Framework models
find . -name '*Context.cs' -o -name '*.Entity.cs' 2>/dev/null

# Read each entity/model file to extract fields
```

### 1.4 — API Route Extraction

```bash
# Express/Nest routes
grep -rn "router\.\(get\|post\|put\|patch\|delete\)\|@Get\|@Post\|@Put\|@Patch\|@Delete\|app\.\(get\|post\|put\|delete\)" . --include='*.ts' --include='*.js' --include='*.controller.*' 2>/dev/null | head -50

# FastAPI routes
grep -rn "@app\.\(get\|post\|put\|patch\|delete\)\|@router\.\(get\|post\|put\|patch\|delete\)" . --include='*.py' 2>/dev/null | head -50

# .NET controllers
grep -rn "\[Http\(Get\|Post\|Put\|Patch\|Delete\)\]" . --include='*.cs' 2>/dev/null | head -50

# Next.js API routes
find . -path '*/api/*' -name '*.ts' -o -path '*/api/*' -name '*.js' 2>/dev/null | sort

# Route file listing
find . -name '*route*' -o -name '*router*' -o -name '*controller*' -o -name '*endpoint*' 2>/dev/null | grep -v node_modules | sort
```

### 1.5 — Authentication & Authorization

```bash
# Auth-related files
find . -name '*auth*' -o -name '*login*' -o -name '*session*' -o -name '*jwt*' -o -name '*token*' -o -name '*middleware*' -o -name '*guard*' -o -name '*permission*' -o -name '*role*' 2>/dev/null | grep -v node_modules | sort

# Role/permission definitions
grep -rn "role\|permission\|admin\|user\|manager\|supervisor\|operator" . --include='*.ts' --include='*.js' --include='*.py' --include='*.cs' -l 2>/dev/null | grep -v node_modules | head -20

# Read the main auth files
```

### 1.6 — Environment & Configuration

```bash
# Environment files
cat .env.example 2>/dev/null || cat .env.sample 2>/dev/null || cat .env.template 2>/dev/null

# Config files
find . -name 'config.*' -o -name '*.config.*' -o -name 'settings.*' 2>/dev/null | grep -v node_modules | sort

# Sensitive patterns (check what secrets exist)
grep -rn "SECRET\|API_KEY\|PASSWORD\|TOKEN\|CREDENTIAL" .env.example .env.sample .env.template 2>/dev/null
```

### 1.7 — Testing Infrastructure

```bash
# Test files
find . -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' 2>/dev/null | grep -v node_modules | wc -l

# Test configuration
cat jest.config.* 2>/dev/null || cat vitest.config.* 2>/dev/null || cat playwright.config.* 2>/dev/null || cat pytest.ini 2>/dev/null

# Test runner
grep -i "test\|jest\|vitest\|mocha\|pytest\|xunit\|playwright" package.json 2>/dev/null | head -10
```

### 1.8 — Microservices Detection

```bash
# Multiple services? (separate package.json, Dockerfile, or go.mod per service)
find . -name 'package.json' -not -path '*/node_modules/*' 2>/dev/null | sort
find . -name 'Dockerfile' -not -path '*/node_modules/*' 2>/dev/null | sort
find . -name 'go.mod' -not -path '*/vendor/*' 2>/dev/null | sort

# Services directory?
ls -la services/ 2>/dev/null || ls -la apps/ 2>/dev/null || ls -la packages/ 2>/dev/null

# Docker Compose services count
grep -c "build:" docker-compose.yml 2>/dev/null

# Kubernetes manifests?
find . -name '*.yaml' -o -name '*.yml' | xargs grep -l 'kind: Deployment' 2>/dev/null | head -20

# Helm charts?
find . -name 'Chart.yaml' 2>/dev/null | sort

# Message broker detection
grep -ri "rabbitmq\|amqp\|kafka\|sqs\|redis.*stream\|nats\|pubsub" . --include='*.json' --include='*.yaml' --include='*.yml' --include='*.ts' --include='*.js' --include='*.env*' -l 2>/dev/null | grep -v node_modules | head -10

# gRPC / proto files
find . -name '*.proto' 2>/dev/null | sort

# Event/message handlers
find . -name '*consumer*' -o -name '*subscriber*' -o -name '*listener*' -o -name '*handler*' -o -name '*producer*' -o -name '*publisher*' -o -name '*emitter*' 2>/dev/null | grep -v node_modules | sort
```

**Decision:** If multiple Dockerfiles, multiple package.json files in a services/
directory, Kubernetes manifests, or message broker configs are found, classify
this as a microservices project and flag it for the Microservices Extension
files in Phase 3.

### 1.9 — Git History Analysis

```bash
# Recent commits (understand current velocity and patterns)
git log --oneline -20 2>/dev/null

# Contributors
git shortlog -sn --all 2>/dev/null | head -10

# Branch structure
git branch -a 2>/dev/null

# Most changed files (hot spots)
git log --pretty=format: --name-only -20 2>/dev/null | sort | uniq -c | sort -rn | head -15
```

### 1.10 — Business Logic Discovery

```bash
# Service layer (where business rules live)
find . -name '*service*' -o -name '*usecase*' -o -name '*handler*' -o -name '*manager*' 2>/dev/null | grep -v node_modules | sort

# Read each service file to understand business rules
```

### 1.11 — Frontend Analysis (if applicable)

```bash
# Component structure
find . -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' 2>/dev/null | grep -v node_modules | head -30

# Page structure (routing)
find . -path '*/pages/*' -o -path '*/views/*' -o -path '*/screens/*' 2>/dev/null | grep -v node_modules | sort

# i18n / localization
find . -name '*i18n*' -o -name '*locale*' -o -name '*lang*' -o -name '*translation*' 2>/dev/null | grep -v node_modules | sort

# RTL/Arabic detection
grep -rn "rtl\|dir=\|arabic\|عربي\|locale.*ar" . --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.css' 2>/dev/null | head -20
```

---

## PHASE 2 — Analysis & Synthesis

After completing Phase 1, synthesize your findings. Answer ALL of these:

### Project Identity
1. **Project name** (current name, and new name if renaming)
2. **What it does** (one paragraph based on the code, not assumptions)
3. **Target users** (every role found in auth/permissions)
4. **Current state** (MVP complete? Stable? Under heavy development?)

### Technical Architecture
5. **Full tech stack** (every technology with version)
6. **Architecture pattern** (monolith, microservices, modular)
   → If **microservices detected**: also answer 6a–6e:
   6a. **Service inventory** (every service name, port, responsibility, database)
   6b. **Inter-service communication** (REST, gRPC, events — which pairs use which)
   6c. **Message broker** (RabbitMQ, Kafka, Redis Streams, SQS — detected from config)
   6d. **Container orchestration** (Kubernetes manifests found? Docker Compose? ECS config?)
   6e. **Repo structure** (monorepo with services/ folder, or separate repos?)
7. **Database entities** (every table/model with fields and relationships)
8. **API endpoints** (every route with method, path, auth level)
9. **Authentication system** (strategy, token type, role model)
10. **External integrations** (payments, storage, email, SMS, maps)

### Code Health
11. **Test coverage** (approximate %, frameworks used)
12. **Code organization** (clean architecture? MVC? domain-driven?)
13. **Technical debt** (patterns that need refactoring)
14. **Security posture** (secrets management, input validation, auth coverage)
15. **Documentation state** (README? API docs? Inline comments?)

### Business Rules
16. **Core workflows** (the 3-5 most important user journeys)
17. **Constraints** (business rules that must never be violated)
18. **Edge cases** (tricky logic discovered in the code)

### Evolution Needs
19. **What's being renamed** (old name → new name, affected files)
20. **What's missing** (features planned but not built)
21. **What needs fixing** (bugs, tech debt, security gaps)

Report these answers clearly inline, then **proceed autonomously to
Phase 3** (PROTOCOL_PRINCIPLES Rule 5). Do not stop and wait for approval
— the scan is deterministic and the scaffolding is non-destructive. Pause
only on a genuine blocker (e.g., the project already has conflicting CCM
files that would be overwritten — then surface the conflict, don't guess).

---

## PHASE 3 — Generate AND DEPLOY Methodology Files

Now generate EVERY methodology file filled with the REAL data you extracted
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

### Step 3.0 — Create Directory Structure FIRST

Before writing any files, create the full directory structure in the project root:

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

**Critical rule**: NO placeholders. NO [PROJECT]. NO generic examples.
Everything comes from the actual codebase scan.

Generate AND WRITE to the project root in this order:

### Core
1. **CLAUDE.md** — Full project specification from real data
   - Real project name, real description, real roles from auth system
   - Real feature list from routes and services
   - Real tech stack from package.json/csproj
   - Real entities from schema/models
   - Real API structure from routes

### Architecture
2. **architecture/CONSTRAINTS.md** — Universal rules + domain-specific rules extracted from business logic
3. **architecture/TECH_STACK.md** — Exact technologies and versions from lock files
4. **architecture/CONTEXT_MAP.md** — Real folder structure from the scan
5. **architecture/ERROR_PATTERNS.md** — Universal patterns + project-specific patterns from git history
6. **architecture/DECISIONS.md** — ADRs reverse-engineered from the tech choices made
7. **architecture/SECURITY.md** — Security assessment based on actual auth implementation

### Implementation
8. **implementation/API_ENDPOINTS.md** — Every real route extracted from controllers
9. **implementation/docker-compose.yml** — Based on existing docker config (or create if missing)
10. **implementation/DOCKER_LOCAL.md** — Real setup based on actual infrastructure
11. **implementation/EVENT_SCHEMA.md** — Real events if async exists, or "sync only"
12. **implementation/MIGRATION_ORDER.md** — Real table dependency graph from schema
13. **implementation/LOCAL_RUNBOOK.md** — Real clone-to-running from actual setup
14. **implementation/GATEWAY_ROUTES.md** — Real gateway if exists, or monolith note

### Microservices Extension (ONLY if Phase 1.8 detected microservices)

If the codebase scan in Phase 1.8 found multiple services (separate Dockerfiles,
services/ directory, Kubernetes manifests, message broker configs), ALSO generate
these files filled with data extracted from the actual codebase:

14a. **architecture/SERVICE_MAP.md** — Real service inventory from services/ directory:
     - Every service with port, database, and responsibility (from its code)
     - Real dependency matrix (which services import/call which)
     - Real data ownership (which service owns which database tables)
14b. **architecture/INTER_SERVICE.md** — Real communication patterns:
     - Detected REST calls between services (from HTTP client imports)
     - Detected event publishing/consuming (from broker configs)
     - Detected gRPC contracts (from .proto files)
     - Circuit breaker configs (if found in code)
14c. **operations/OBSERVABILITY.md** — Real observability setup:
     - Existing logging format (structured or not)
     - Existing tracing setup (OpenTelemetry, Jaeger, X-Ray)
     - Existing metrics (Prometheus endpoints, custom metrics)
     - Health check endpoints found per service
14d. **implementation/CONTRACT_TESTING.md** — Real contracts:
     - Existing Pact tests (if found)
     - Event schemas from actual event files
     - API contracts between detected service pairs
14e. **operations/ORCHESTRATION.md** — Real deployment setup:
     - Existing Dockerfiles analyzed and documented
     - Existing docker-compose.yml documented
     - Existing Kubernetes manifests documented
     - Existing Helm charts documented
     - Existing CI/CD pipeline documented
     - Scaling configurations found

### Memory (Initialize with Current State)
15. **memory/project_status.md** — Current features as complete/in-progress/planned
16. **memory/session_notes.md** — "Reengineering session" entry with full scan results
17. **memory/change_log.md** — "Methodology overlay applied" entry
18. **memory/architecture_decisions.md** — ADRs for existing tech choices
19. **memory/bugs_and_fixes.md** — Known issues from git history

### Config
20. **.env.example** — Based on actual environment variables needed
21. **.gitignore** — Based on existing + methodology additions
22. **.claude/settings.json** — Include all project-specific context files

**Rules (path-scoped, from methodology):**
23. Copy rule files from `claude-code-methodology/.claude/rules/` to `.claude/rules/`

```bash
# Copy path-scoped rules to project root:
cp claude-code-methodology/.claude/rules/*.md .claude/rules/
```

**Skills (official arib brand — replaces deprecated commands):**
24. Copy all 16 skill directories from `claude-code-methodology/.claude/skills/arib-*/`

```bash
# Copy arib-branded skills to project root:
cp -r claude-code-methodology/.claude/skills/arib-* .claude/skills/
```

**Config (new in v3.0):**
25. .mcp.json — MCP server configuration at project root
26. .worktreeinclude — Gitignored files for worktrees

---

## PHASE 4 — Rename Mapping (If Applicable)

If the project is being renamed, generate:

### RENAME_MAP.md
```markdown
# Rename Mapping: [Old Name] → [New Name]

## Files to Rename
| Current Path                    | New Path                        |
|---------------------------------|---------------------------------|
| [list every file that contains old name] |

## Code References
| File                | Line | Old Reference         | New Reference         |
|---------------------|------|-----------------------|-----------------------|
| [every occurrence of old name in code] |

## Configuration Updates
- package.json: name field
- docker-compose.yml: service names
- .env: variable prefixes
- Database: schema/database name
- Git: remote URL

## Commands to Execute
[list of safe rename commands in order]
```

---

## PHASE 5 — Deployment Verification

After writing ALL files to the project root, verify the deployment:

```bash
# 1. Verify directory structure exists
ls -la .claude/agents/ .claude/skills/ .claude/rules/ memory/ architecture/ implementation/ operations/ io/

# 2. Count total files created
find . -name '*.md' -o -name '*.json' -o -name '*.yml' -o -name '*.sh' | grep -v node_modules | grep -v .git | wc -l

# 3. Verify critical files exist
test -f CLAUDE.md && echo "✅ CLAUDE.md" || echo "❌ CLAUDE.md MISSING"
test -f .claude/agents/architect.md && echo "✅ Agents" || echo "❌ Agents MISSING"
# Verify branded skills exist
test -d .claude/skills/arib-session-start && echo "✅ Skills (branded)" || echo "❌ Skills MISSING"
test -d .claude/rules && echo "✅ Rules" || echo "❌ Rules MISSING"
test -f memory/MEMORY_PROTOCOL.md && echo "✅ Memory" || echo "❌ Memory MISSING"
test -f .mcp.json && echo "✅ .mcp.json" || echo "❌ .mcp.json MISSING"

# 4. Verify skills will appear in / menu
ls .claude/skills/
```

**IMPORTANT**: If any file was NOT written to the project root,
write it now. The bootstrap is NOT complete until every file
exists as a real file in the project directory.

After verification passes, report:

1. **Summary**: Total files CREATED IN PROJECT ROOT, key findings
2. **Health Report**: Code quality score, security gaps, test coverage
3. **Priority Actions**: Top 5 things to fix/improve immediately
4. **Rename Checklist**: If renaming, exact steps in safe order
5. **First Session Prompt**: Type `/session-start` — all files are deployed

═══════════════════════════════════════════════════════════════════════

## END OF REVERSE BOOTSTRAP PROMPT

---

## FAQ

### Q: Will this modify my existing code?
**A**: No. The Reverse Bootstrap only READS your code and WRITES methodology
files. It never modifies your source code. The methodology sits alongside
your code as a knowledge layer.

### Q: What if my project has no tests?
**A**: The scan will note this. The generated CONSTRAINTS.md will add
testing requirements, and memory/project_status.md will list "Add test
infrastructure" as a high-priority task.

### Q: What if I'm halfway through a rename?
**A**: The scan detects mixed naming. The RENAME_MAP.md will show every
inconsistency and give you commands to complete the rename safely.

### Q: Can I run this multiple times?
**A**: Yes. Each run overwrites the methodology files with fresh data.
Memory files will be re-initialized (back up first if you want to keep
session history).

### Q: How long does the scan take?
**A**: Typically 5-10 minutes for a medium project (50-200 files).
Larger projects may take longer due to the deep read of each entity/route.

---

## After scan completes — activate v3.3 enforcement

The reverse bootstrap maps your existing project to CCM structure but
does not install the enforcement hooks. Do this once after the scan:

```bash
./scripts/install-hooks.sh
```

Then review `architecture/CONTEXT_MAP.md` `allowed_write_paths` — the
default list may be wider than your project needs. Tighten it to match
the directories you actually want Claude to write into.

Optional MCPs (`claude-mem`, `cowork`, `testsprite`) stay opt-in.
Set the env vars only for the ones you use; everything degrades
gracefully without them.

See `compliance/README.md` for the honesty principle if your project
has compliance obligations (PDPL, GDPR, ISO 27001, SOC 2, OWASP).
