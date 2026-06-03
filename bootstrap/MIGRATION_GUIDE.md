# Migration Guide: From Any System → claude-code-methodology

> **Decisive behavior** (v3.5.1+) + **autonomous** (Rule 5): the source
> system is **determinable from filesystem markers** — detect it, don't
> ask. Run the migration end-to-end; pause only on a genuine blocker.

**Use Case:** you have an *existing* AI-coding setup (Cursor rules,
Windsurf config, Copilot instructions, a Kiro setup, an unstructured
`CLAUDE.md`, or the legacy `claude-code-system`) and want to migrate it
to CCM — preserving your real content (rules, context, conventions).

> **v3.8.2 retirement note:** the original `claude-code-system → CCM`
> migration (the flat 35-file template) is now a *historical* path —
> almost no one is on it in 2026. It is preserved in **Appendix A**
> (below), retired but intact for the rare user who needs it. The
> **primary** content is the multi-source flow that follows.

---

## Step 0 — Detect the source system (autonomous)

Read the project root for these markers and pick the matching source. Do
NOT ask the user which system they came from — the filesystem says so.

| Marker on disk | Source system | Migrate section |
|----------------|---------------|-----------------|
| `.cursor/rules/` or `.cursorrules` | **Cursor** | §A |
| `.windsurfrules` or `.windsurf/` | **Windsurf** | §B |
| `.github/copilot-instructions.md` | **GitHub Copilot** | §C |
| `.kiro/` (steering/specs) | **Kiro** | §D |
| `CLAUDE.md` present but no `.claude/` structure | **Unstructured CLAUDE.md** | §E |
| Flat `AGENTS.md` + `docs/` + root architecture files | **Legacy claude-code-system** | Appendix A |
| None of the above | Treat as **greenfield-with-code** → use `REVERSE_BOOTSTRAP.md` instead | — |

If multiple markers exist (e.g. Cursor *and* Copilot), migrate **all**
detected sources — they are not mutually exclusive. Report which were
found and merged.

## The migration contract (all sources)

Whatever the source, migration means: **extract the real content** (the
user's rules, context, conventions, domain facts) and **re-home it into
CCM's structure** — never discard it, never overwrite CCM scaffolding
blindly. Then scaffold the rest of CCM around it and verify.

- **Rules/conventions** (lint rules, "always/never" directives, style) →
  `architecture/CONSTRAINTS.md` (hard rules) + `.claude/rules/*.md`
  (path-scoped) as appropriate.
- **Project/architecture context** (stack, structure, domain notes) →
  `CLAUDE.md` (identity/overview) + `architecture/CONTEXT_MAP.md` +
  `architecture/TECH_STACK.md`.
- **Task/workflow instructions** → the matching skill, or `operations/WORKFLOW.md`.
- **Agent/persona definitions** (if any) → `.claude/agents/*.md` with
  proper `name:`/`description:` frontmatter (see existing agents).
- Then run the standard scaffold + `./scripts/install-hooks.sh` +
  `./scripts/validate-coherence.sh`, and write a migration report to
  `io/ledger/`.

## §A — From Cursor (`.cursor/rules/*.mdc`, `.cursorrules`)

Cursor rules are MDC/markdown directives. Map:
- Global `.cursorrules` / `.cursor/rules/*.mdc` "always" rules → split
  into hard rules (`CONSTRAINTS.md`) vs advisory guidance (`CLAUDE.md` or
  a path-scoped `.claude/rules/*.md`, mirroring Cursor's glob scoping).
- Cursor `globs:` frontmatter → CCM path-scoped rule scope (the
  `.claude/rules/*.md` description/scope line).
- Preserve the original under `core/` for reference.

## §B — From Windsurf (`.windsurfrules`, `.windsurf/`)

- `.windsurfrules` (single-file directives) → same split as Cursor:
  hard → CONSTRAINTS, advisory → CLAUDE/rules.
- Any Windsurf workflows → the matching `/arib-*` skill or WORKFLOW.md.

## §C — From GitHub Copilot (`.github/copilot-instructions.md`)

- The single instructions file → `CLAUDE.md` (project identity + overview)
  for the descriptive parts; the imperative "always/never" lines →
  `CONSTRAINTS.md`.
- `.github/instructions/*.instructions.md` (path-scoped) → `.claude/rules/`
  with matching scope.

## §D — From Kiro (`.kiro/steering/`, `.kiro/specs/`)

- Kiro **steering** docs → `CLAUDE.md` + `architecture/` files.
- Kiro **specs** (requirements/design/tasks) → `core/` (the source specs)
  + seed `memory/project_status.md` from the tasks.

## §E — From an unstructured `CLAUDE.md`

- The existing `CLAUDE.md` already loads in Claude Code. Split it: keep
  identity/overview in the new `CLAUDE.md`; move hard rules to
  `CONSTRAINTS.md`; move any decisions to `DECISIONS.md`. Then scaffold
  the rest of CCM around it. This is the most common 2026 case.

---

# Appendix A — Legacy: claude-code-system → CCM (RETIRED, historical)

> **Retired in v3.8.2.** This is the original migration path for the flat
> 35-file `claude-code-system`. It is preserved intact for the rare user
> still on that system, but it is **not** the primary migration flow —
> see the source-detection table and §A–§E above for the 2026 sources
> (Cursor / Windsurf / Copilot / Kiro / unstructured CLAUDE.md). If you
> are not migrating from `claude-code-system` specifically, ignore this
> appendix.

## Copy-Paste Prompt for Claude Code (legacy claude-code-system only)

Open Claude Code in your **project root** (where the old claude-code-system files are), then paste:

═══════════════════════════════════════════════════════════════════════

Read `claude-code-methodology/bootstrap/MIGRATION_GUIDE.md` and execute
the full migration protocol. Follow every phase exactly.

**CONTEXT:**
- SOURCE (new methodology): `./claude-code-methodology/`
- OLD SYSTEM: My project currently uses the old `claude-code-system` structure
  (flat files: AGENTS.md, docs/ folder, root-level architecture files)
- TARGET: `.` — the current working directory (project root)

**YOUR JOB:**
1. Read `core/` folder first — these are my real project files (specs, designs, schemas).
   Read EVERY file in core/ to deeply understand my project before doing anything.
   If core/ is empty or doesn't exist, skip to step 2.
2. INVENTORY: Read every old file, map what has real data vs empty templates
3. SAFETY: Create a backup branch before touching anything
4. SCAFFOLD: Create the new directory structure (memory/, architecture/, core/, etc.)
5. MIGRATE: Move my data from old locations to new (docs/ → memory/, etc.)
6. SPLIT: Break AGENTS.md into 13 individual agent files in .claude/agents/
7. REBUILD: Merge my CLAUDE.md — keep my project data, adopt new structure
8. ADD: Install all new components (I/O channel, bootstrap, hooks, etc.)
9. DEPLOY: Copy agents and commands from methodology to .claude/
10. VERIFY: Run validate-system.sh, confirm all files exist in project root

**CRITICAL RULES:**
- PRESERVE all my existing project data (memory, routes, business rules)
- WRITE everything to the PROJECT ROOT (.), NOT inside claude-code-methodology/
- CLAUDE.md must be MERGED — keep my project data, adopt new system structure
- The migration is NOT done until files physically exist in the project root
- After writing, verify: ls .claude/commands/ && ls .claude/agents/ && ls memory/

═══════════════════════════════════════════════════════════════════════

---

## Before You Start

### What Is the Old System?

The `claude-code-system` was a flat template structure with ~35 files:

```
claude-code-system/
├── CLAUDE.md                    ← Basic brain (no versioning, no I/O)
├── AGENTS.md                    ← All agents in one file
├── PROMPT.md                    ← Bootstrap prompt
├── docs/                        ← Memory files (flat names)
│   ├── Project_Status.md
│   ├── Session_Notes.md
│   ├── Change_Log.md
│   ├── Architecture.md
│   ├── Bugs_and_Fixes.md
│   └── Testing_Log.md
├── .claude/
│   ├── settings.json
│   └── commands/                ← 5 commands (no session-start/end)
│       ├── new-feature.md
│       ├── debug.md
│       ├── review.md
│       ├── deploy-check.md
│       ├── arabic-audit.md
│       └── document.md
├── architecture files (flat)    ← CONSTRAINTS, TECH_STACK, etc.
├── implementation files (flat)  ← API_ENDPOINTS, docker-compose, etc.
├── scripts/
│   └── git-setup.sh
└── CLAUDE_CODE_MASTER_GUIDE.md  ← Reference guide
```

### What Is the New System?

The `claude-code-methodology` v2.6.0 "Fortress" is a **5-layer architecture** with:

- **96 files** organized in 24 purpose-driven directories
- **13 specialist agent files** (each with own context, checklist, constraints)
- **14 slash commands** including `/session-start` and `/session-end`
- **Persistent Memory Protocol** with lifecycle rules
- **I/O Channel** for inter-agent communication
- **Bootstrap + Reverse Bootstrap + Upgrade + Migration protocols**
- **Version control** (semantic versioning, changelog)
- **Universal Language Agent** (replaces Arabic-RTL)
- **Production Safety**: Incident Response, Monitoring, Database Guardian
- **122 features** across 22 categories

### What You Keep

Your existing data is **preserved**. The migration copies your content into the
new structure — it does NOT delete your old files.

---

## Migration Process (6 Phases)

╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  CRITICAL DEPLOYMENT RULE                                   ║
║                                                                  ║
║  All migration operations happen in the PROJECT ROOT — the       ║
║  directory where Claude Code is running and where your actual    ║
║  project code lives.                                             ║
║                                                                  ║
║  SOURCE: claude-code-methodology/ (read templates FROM here)     ║
║  TARGET: . (current working directory = project root)            ║
║                                                                  ║
║  Every file you create, move, or generate MUST end up in the     ║
║  PROJECT ROOT directory structure. Do NOT leave files only in    ║
║  claude-code-methodology/ or only in chat output.                ║
║                                                                  ║
║  When done, the project root MUST contain:                       ║
║  ./CLAUDE.md                                                     ║
║  ./.claude/commands/*.md   (14 commands → appear in / menu)      ║
║  ./.claude/agents/*.md     (13 agents → callable by name)        ║
║  ./memory/*.md             (7 memory files)                      ║
║  ./architecture/*.md       (architecture layer)                  ║
║  ./implementation/*.md     (implementation layer)                ║
║  ./operations/*.md         (operations layer)                    ║
║  ./io/                     (I/O channel system)                  ║
╚══════════════════════════════════════════════════════════════════╝

### Phase 1: INVENTORY — Map What You Have

Before touching anything, inventory your old system.

**Tell Claude Code:**
```
Read every file in my current project that came from claude-code-system.
Create an inventory showing:
1. Which files have REAL project data (filled in, not template placeholders)
2. Which files are still empty templates
3. Which files have been customized beyond the original template

Save the inventory as migration-inventory.md
```

**Expected output — a table like:**

| Old File                        | Has Real Data? | Customized? | Maps To (New)                        |
|---------------------------------|----------------|-------------|--------------------------------------|
| CLAUDE.md                       | Yes            | Yes         | CLAUDE.md                            |
| AGENTS.md                       | Yes            | No          | .claude/agents/*.md (8 files)        |
| docs/Project_Status.md          | Yes            | Yes         | memory/project_status.md             |
| docs/Session_Notes.md           | Yes            | Yes         | memory/session_notes.md              |
| docs/Change_Log.md              | Yes            | Yes         | memory/change_log.md                 |
| docs/Architecture.md            | Yes            | Yes         | memory/architecture_decisions.md     |
| docs/Bugs_and_Fixes.md          | Partial        | No          | memory/bugs_and_fixes.md             |
| docs/Testing_Log.md             | Empty          | No          | memory/testing_log.md                |
| CONSTRAINTS.md                  | Yes            | Yes         | architecture/CONSTRAINTS.md          |
| TECH_STACK.md                   | Yes            | Yes         | architecture/TECH_STACK.md           |
| CONTEXT_MAP.md                  | Yes            | Yes         | architecture/CONTEXT_MAP.md          |
| ERROR_PATTERNS.md               | Partial        | No          | architecture/ERROR_PATTERNS.md       |
| API_ENDPOINTS.md                | Yes            | Yes         | implementation/API_ENDPOINTS.md      |
| docker-compose.yml              | Yes            | Yes         | implementation/docker-compose.yml    |
| DOCKER_LOCAL.md                 | Yes            | Yes         | implementation/DOCKER_LOCAL.md       |
| EVENT_SCHEMA.md                 | Partial        | No          | implementation/EVENT_SCHEMA.md       |
| MIGRATION_ORDER.md              | Yes            | Yes         | implementation/MIGRATION_ORDER.md    |
| LOCAL_RUNBOOK.md                | Partial        | No          | implementation/LOCAL_RUNBOOK.md      |
| GATEWAY_ROUTES.md               | Partial        | No          | implementation/GATEWAY_ROUTES.md     |
| WORKFLOW.md                     | Yes            | No          | operations/WORKFLOW.md               |
| .claude/settings.json           | Yes            | Yes         | .claude/settings.json                |
| .claude/commands/arabic-audit.md| Yes            | No          | .claude/commands/language-audit.md   |
| scripts/git-setup.sh            | Yes            | No          | scripts/git-setup.sh                 |
| CLAUDE_CODE_MASTER_GUIDE.md     | Reference      | No          | reference/MASTER_GUIDE.md            |

---

### Phase 2: SAFETY — Create Backup Branch

**Tell Claude Code:**
```
Create a safety branch before migration:

git checkout -b safety/pre-migration-backup
git add -A
git commit -m "[snapshot]: complete state before CCM migration"
git checkout -  # return to working branch
```

This ensures you can always return to your old system if anything goes wrong.

---

### Phase 3: SCAFFOLD — Create New Directory Structure

**Tell Claude Code:**
```
Create the claude-code-methodology directory structure WITHOUT overwriting
any existing files. Create only the NEW directories and NEW files that
don't exist yet:

mkdir -p memory architecture implementation operations
mkdir -p io/requests io/results io/signals io/pipelines io/threads io/archive io/.templates
mkdir -p bootstrap reference hooks
mkdir -p .claude/agents .claude/commands
```

---

### Phase 4: MIGRATE — Move Data to New Locations

This is the critical phase. For each file with real data, move it to the new location.

#### 4.1 — Memory Files (docs/ → memory/)

**Tell Claude Code:**
```
Migrate my memory files from the old structure to the new:

1. Copy docs/Project_Status.md → memory/project_status.md
   - Add the structured format from MEMORY_PROTOCOL.md
   - Preserve ALL existing project data

2. Copy docs/Session_Notes.md → memory/session_notes.md
   - Preserve all session entries

3. Copy docs/Change_Log.md → memory/change_log.md
   - Preserve all change entries

4. Copy docs/Architecture.md → memory/architecture_decisions.md
   - Convert to ADR format if not already

5. Copy docs/Bugs_and_Fixes.md → memory/bugs_and_fixes.md
6. Copy docs/Testing_Log.md → memory/testing_log.md

Then create memory/MEMORY_PROTOCOL.md from the methodology template.
```

#### 4.2 — Architecture Files (root → architecture/)

**Tell Claude Code:**
```
Move architecture files to their new directory:

1. Move CONSTRAINTS.md → architecture/CONSTRAINTS.md
2. Move TECH_STACK.md → architecture/TECH_STACK.md
3. Move CONTEXT_MAP.md → architecture/CONTEXT_MAP.md
4. Move ERROR_PATTERNS.md → architecture/ERROR_PATTERNS.md

Then create these NEW files from methodology templates:
5. Create architecture/DECISIONS.md (ADR template)
6. Create architecture/SECURITY.md (security specification)
```

#### 4.3 — Implementation Files (root → implementation/)

**Tell Claude Code:**
```
Move implementation files to their new directory:

1. Move API_ENDPOINTS.md → implementation/API_ENDPOINTS.md
2. Move docker-compose.yml → implementation/docker-compose.yml
3. Move DOCKER_LOCAL.md → implementation/DOCKER_LOCAL.md
4. Move EVENT_SCHEMA.md → implementation/EVENT_SCHEMA.md
5. Move MIGRATION_ORDER.md → implementation/MIGRATION_ORDER.md
6. Move LOCAL_RUNBOOK.md → implementation/LOCAL_RUNBOOK.md
7. Move GATEWAY_ROUTES.md → implementation/GATEWAY_ROUTES.md
```

#### 4.4 — Operations (WORKFLOW.md → operations/)

**Tell Claude Code:**
```
Move and expand operations files:

1. Move WORKFLOW.md → operations/WORKFLOW.md
2. Create operations/DEPLOYMENT.md from methodology template
3. Create operations/OPERATIONS_LOG.md with initial migration entry
```

#### 4.5 — Agents (AGENTS.md → .claude/agents/*.md)

The old system had ALL agents in a single `AGENTS.md` file. The new system
splits each agent into its own file with full context, checklist, and constraints.

**Tell Claude Code:**
```
Split AGENTS.md into 8 individual agent files:

Read the current AGENTS.md and extract each agent's section.
For each agent, create a full agent file using the methodology's
agent template format (Identity, Activation Rules, Checklist,
Output Format, Constraints).

Create these files:
1. .claude/agents/architect.md
2. .claude/agents/security-auditor.md
3. .claude/agents/code-reviewer.md
4. .claude/agents/test-engineer.md
5. .claude/agents/debugger.md
6. .claude/agents/refactor-specialist.md
7. .claude/agents/language.md          ← NEW (replaces Arabic-RTL)
8. .claude/agents/deploy-guardian.md

Preserve any project-specific customizations from the old AGENTS.md.
```

#### 4.6 — Commands (branded naming system)

The new system uses branded command names: `{prefix}-{category}-{name}`.

**Tell Claude Code:**
```
1. Determine the command prefix from the project name:
   - Use 2-5 lowercase letters (e.g., MotorGate → mg, ARIB → arib)
   - Confirm with the user

2. Remove ALL old flat-named commands:
   rm -f .claude/commands/new-feature.md
   rm -f .claude/commands/debug.md
   rm -f .claude/commands/review.md
   rm -f .claude/commands/deploy-check.md
   rm -f .claude/commands/arabic-audit.md
   rm -f .claude/commands/document.md
   rm -f .claude/commands/session-start.md
   rm -f .claude/commands/session-end.md

3. Copy the 14 arib-branded commands from methodology:
   cp claude-code-methodology/.claude/commands/arib-*.md .claude/commands/
```

#### 4.7 — CLAUDE.md (Rebuild the Brain)

This is the most important file. The old CLAUDE.md was simpler. The new one
is the full Master Brain with 5-layer architecture, 7 golden rules, I/O
integration, and session protocol.

**Tell Claude Code:**
```
Rebuild CLAUDE.md using the methodology's Master Brain template.

CRITICAL: Preserve ALL project-specific data from the old CLAUDE.md:
- Project name, description, owner
- Tech stack choices
- Business rules and domain knowledge
- Any custom constraints or decisions

Merge this data INTO the new CLAUDE.md structure which includes:
- §0 Identity & Purpose (with project data)
- §1 4-Layer Architecture
- §2 7 Golden Rules
- §3 I/O Channel
- §4 Memory Hierarchy
- §5 Session Protocol
- §6 Agent System
- §7 Skills System
- §8 Hooks System
- §9 File System Map
- §10 Communication Standards
- §11 Instantiation Checklist
- §12 Evolution Protocol
```

---

### Phase 5: ADD NEW — Install New System Components

These files don't exist in the old system at all. Create them fresh.

**Tell Claude Code:**
```
Create all new methodology components:

I/O Channel (full system):
1. io/IO_PROTOCOL.md
2. io/status.md
3. io/BRIEFING_COWORK.md
4. io/BRIEFING_CLAUDE_CODE.md
5. io/.templates/ (all 9 templates)

Bootstrap & Upgrade:
6. bootstrap/BOOTSTRAP.md
7. bootstrap/REVERSE_BOOTSTRAP.md
8. bootstrap/REENGINEERING_GUIDE.md
9. bootstrap/UPGRADE_PROTOCOL.md
10. bootstrap/MIGRATION_GUIDE.md (this file)

Version & System:
11. SYSTEM.md
12. VERSION.json
13. CHANGELOG.md

Reference:
14. reference/MASTER_GUIDE.md
15. reference/SKILLS_REGISTRY.md
16. reference/USAGE_GUIDE.md

Hooks:
17. hooks/HOOKS_PROTOCOL.md

Scripts:
18. scripts/validate-system.sh
19. scripts/io-watcher.sh
20. scripts/io-archive.sh

Config:
21. .env.example
22. .gitignore
```

---

### Phase 6: VERIFY DEPLOYMENT — Confirm Files Are in Project Root

**Tell Claude Code:**
```
Verify ALL methodology files exist in the PROJECT ROOT (not inside claude-code-methodology/):

1. Verify directory structure:
   ls -la .claude/agents/ .claude/commands/ memory/ architecture/ implementation/ operations/ io/

2. Verify critical files:
   test -f CLAUDE.md && echo "✅ CLAUDE.md" || echo "❌ MISSING"
   test -f .claude/agents/architect.md && echo "✅ Agents" || echo "❌ MISSING"
   test -f .claude/commands/session-start.md && echo "✅ Commands" || echo "❌ MISSING"
   test -f memory/MEMORY_PROTOCOL.md && echo "✅ Memory" || echo "❌ MISSING"

3. Run full system validation:
   bash scripts/validate-system.sh

4. Count files: find . -name '*.md' | grep -v node_modules | grep -v .git | wc -l

5. Verify no stale references to old paths (docs/, AGENTS.md, arabic-*)

6. Verify CLAUDE.md references correct file paths

IMPORTANT: If ANY file is missing from the project root, create it now.
The migration is NOT complete until every file exists as a real file
in the project directory and /session-start works.

If validation passes, commit:
git add -A
git commit -m "[chore]: migrate from claude-code-system to claude-code-methodology v2.6.0"
```

---

## File Mapping Reference (Old → New)

| Old Path (claude-code-system)       | New Path (claude-code-methodology)        | Action     |
|-------------------------------------|-------------------------------------------|------------|
| `CLAUDE.md`                         | `CLAUDE.md`                               | REBUILD    |
| `AGENTS.md`                         | `.claude/agents/*.md` (8 files)           | SPLIT      |
| `PROMPT.md`                         | `bootstrap/BOOTSTRAP.md`                  | REPLACE    |
| `CLAUDE_CODE_MASTER_GUIDE.md`       | `reference/MASTER_GUIDE.md`               | REPLACE    |
| `docs/Project_Status.md`            | `memory/project_status.md`                | MIGRATE    |
| `docs/Session_Notes.md`             | `memory/session_notes.md`                 | MIGRATE    |
| `docs/Change_Log.md`                | `memory/change_log.md`                    | MIGRATE    |
| `docs/Architecture.md`              | `memory/architecture_decisions.md`        | MIGRATE    |
| `docs/Bugs_and_Fixes.md`            | `memory/bugs_and_fixes.md`                | MIGRATE    |
| `docs/Testing_Log.md`               | `memory/testing_log.md`                   | MIGRATE    |
| `CONSTRAINTS.md`                    | `architecture/CONSTRAINTS.md`             | MOVE       |
| `TECH_STACK.md`                     | `architecture/TECH_STACK.md`              | MOVE       |
| `CONTEXT_MAP.md`                    | `architecture/CONTEXT_MAP.md`             | MOVE       |
| `ERROR_PATTERNS.md`                 | `architecture/ERROR_PATTERNS.md`          | MOVE       |
| `WORKFLOW.md`                       | `operations/WORKFLOW.md`                  | MOVE       |
| `API_ENDPOINTS.md`                  | `implementation/API_ENDPOINTS.md`         | MOVE       |
| `docker-compose.yml`                | `implementation/docker-compose.yml`       | MOVE       |
| `DOCKER_LOCAL.md`                   | `implementation/DOCKER_LOCAL.md`          | MOVE       |
| `EVENT_SCHEMA.md`                   | `implementation/EVENT_SCHEMA.md`          | MOVE       |
| `MIGRATION_ORDER.md`                | `implementation/MIGRATION_ORDER.md`       | MOVE       |
| `LOCAL_RUNBOOK.md`                  | `implementation/LOCAL_RUNBOOK.md`         | MOVE       |
| `GATEWAY_ROUTES.md`                 | `implementation/GATEWAY_ROUTES.md`        | MOVE       |
| `.claude/settings.json`             | `.claude/settings.json`                   | MERGE      |
| `.claude/commands/arabic-audit.md`  | `.claude/commands/{prefix}-check-language.md` | REPLACE    |
| `.claude/commands/new-feature.md`   | `.claude/commands/{prefix}-session-feature.md` | BRANDED    |
| `.claude/commands/debug.md`         | `.claude/commands/{prefix}-dev-debug.md`  | BRANDED    |
| `.claude/commands/review.md`        | `.claude/commands/{prefix}-check-review.md` | BRANDED    |
| `.claude/commands/deploy-check.md`  | `.claude/commands/{prefix}-check-deploy.md` | BRANDED    |
| `.claude/commands/document.md`      | `.claude/commands/{prefix}-docs-document.md` | BRANDED    |
| `scripts/git-setup.sh`              | `scripts/git-setup.sh`                    | UPDATE     |
| _(did not exist)_                   | `.claude/commands/{prefix}-session-start.md` | NEW        |
| _(did not exist)_                   | `.claude/commands/{prefix}-session-end.md` | NEW        |
| _(did not exist)_                   | `memory/MEMORY_PROTOCOL.md`              | NEW        |
| _(did not exist)_                   | `architecture/DECISIONS.md`              | NEW        |
| _(did not exist)_                   | `architecture/SECURITY.md`               | NEW        |
| _(did not exist)_                   | `operations/DEPLOYMENT.md`               | NEW        |
| _(did not exist)_                   | `operations/OPERATIONS_LOG.md`           | NEW        |
| _(did not exist)_                   | `io/` (entire directory, 14 files)       | NEW        |
| _(did not exist)_                   | `bootstrap/` (5 files)                   | NEW        |
| _(did not exist)_                   | `SYSTEM.md`                              | NEW        |
| _(did not exist)_                   | `VERSION.json`                           | NEW        |
| _(did not exist)_                   | `CHANGELOG.md`                           | NEW        |
| _(did not exist)_                   | `hooks/HOOKS_PROTOCOL.md`                | NEW        |
| _(did not exist)_                   | `reference/USAGE_GUIDE.md`               | NEW        |

**Action legend:**
- **MOVE** = File content preserved, just relocate to new path
- **MIGRATE** = Move + reformat to new structure
- **REBUILD** = Reconstruct using new template, preserving project data
- **SPLIT** = One file → multiple files
- **REPLACE** = Old file replaced by completely new version
- **MERGE** = Combine old config with new config additions
- **UPDATE** = Keep file, add new methodology features
- **NEW** = Entirely new, did not exist in old system

---

## After Migration

Once migration is complete:

1. **Delete old artifacts** (optional — they're backed up on safety branch):
   - Remove `docs/` directory (data now in `memory/`)
   - Remove root-level `AGENTS.md` (data now in `.claude/agents/*.md`)
   - Remove `PROMPT.md` (replaced by `bootstrap/BOOTSTRAP.md`)
   - Remove `CLAUDE_CODE_MASTER_GUIDE.md` (replaced by `reference/MASTER_GUIDE.md`)

2. **Test the system:**
   ```
   /session-start
   ```
   Claude Code should read CLAUDE.md, check I/O channel, read memory, and report.

3. **First session commit:**
   ```
   git add -A
   git commit -m "[chore]: complete CCM migration, remove old system artifacts"
   ```

---

## Troubleshooting

| Problem                                    | Solution                                         |
|--------------------------------------------|--------------------------------------------------|
| Claude Code reads old `docs/` instead of `memory/` | Update CLAUDE.md §5 session protocol paths |
| Old `AGENTS.md` conflicts with new agents  | Delete `AGENTS.md` after splitting to agent files |
| Missing slash commands                     | Verify `.claude/commands/` has all 8 files       |
| I/O watcher errors                         | Run `bash scripts/io-watcher.sh` to diagnose     |
| Validation fails                           | Run `bash scripts/validate-system.sh` to see which files are missing |

---

## Summary

| Metric              | Old System          | New System              |
|---------------------|---------------------|-------------------------|
| Total files         | ~35                 | 77+                     |
| Directory depth     | Flat (mostly root)  | Organized (8 dirs)      |
| Agents              | 1 file (all agents) | 8 individual files      |
| Commands            | 5                   | 8                       |
| Memory protocol     | None                | Full lifecycle          |
| I/O Channel         | None                | Full inter-agent comms  |
| Version control     | None                | Semantic versioning     |
| Language support     | Arabic-only         | Universal (all scripts) |
| Bootstrap           | Basic prompt        | 25-question protocol    |
| Reverse Bootstrap   | None                | 10-step auto-scan       |
| Upgrade protocol    | None                | 6-phase migration       |

> **Note**: This migration is one-way. Once you're on claude-code-methodology,
> use the Upgrade Protocol (`bootstrap/UPGRADE_PROTOCOL.md`) for all future
> version updates.
