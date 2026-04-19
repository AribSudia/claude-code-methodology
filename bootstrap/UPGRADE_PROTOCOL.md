# Upgrade Protocol — Safely Upgrade CCM to a New Version

> **Purpose**: When a new version of `claude-code-methodology/` is released,
> this protocol tells Claude Code EXACTLY how to upgrade your project's
> methodology files — safely, without losing any project-specific data.
>
> **Core Principle**: READ from methodology. WRITE to project root. PRESERVE your data. VERIFY everything.

---

## When to Use This

You have a project like this:

```
~/ARIB/                              ← PROJECT ROOT (cd here, run claude)
├── claude-code-methodology/         ← NEW VERSION (template source)
│   └── (96 files — the new release)
├── .claude/
│   ├── skills/                      ← YOUR current 16 branded skills
│   ├── rules/                       ← YOUR path-scoped rules
│   ├── agents/                      ← YOUR current 13 agents
│   └── commands/                    ← Legacy (deprecated, kept for compat)
├── CLAUDE.md                        ← YOUR project-specific brain
├── memory/                          ← YOUR session history & data
├── architecture/                    ← YOUR project architecture
├── implementation/                  ← YOUR project implementation
├── operations/                      ← YOUR project operations
├── io/                              ← YOUR I/O channel
└── src/                             ← YOUR actual code
```

You placed a new `claude-code-methodology/` folder (with a newer version)
inside your project and want to upgrade without breaking anything.

---

## HOW TO USE — Copy-Paste Prompt for Claude Code

Open Claude Code in your **project root**, then paste this prompt:

═══════════════════════════════════════════════════════════════════════

Read `claude-code-methodology/bootstrap/UPGRADE_PROTOCOL.md` and execute
the full upgrade protocol. Follow every phase exactly.

**CONTEXT:**
- SOURCE (new version): `./claude-code-methodology/` — read templates FROM here
- TARGET (my project): `.` — the current working directory (project root)
- You are upgrading files that already exist in my project root
- My project has real data in memory/, architecture/, implementation/, etc.

**YOUR JOB:**
1. Read both VERSION.json files to detect version difference
2. Read the new CHANGELOG.md to understand what changed
3. BACK UP my memory/ and io/archive/ (never lose my data)
4. For each file category, follow the correct strategy:
   - **PRESERVE files** (memory/, io/archive/) → DO NOT TOUCH
   - **UPDATE files** (agents, skills, rules, commands, scripts, hooks, templates) → REPLACE with new version from claude-code-methodology/
   - **MERGE files** (CLAUDE.md, architecture/, implementation/, operations/) → READ my current file, READ the new template, MERGE: keep ALL my project-specific data, adopt new system structure/features
   - **ADD files** (anything new in this version) → COPY from claude-code-methodology/ to project root
5. Update VERSION.json in project root to the new version
6. Run verification to confirm all files are deployed
7. Report what changed

**CRITICAL RULES:**
- NEVER overwrite memory/ files — they contain my project history
- NEVER lose project-specific data from CLAUDE.md — MERGE it
- ALWAYS write files to the PROJECT ROOT (.), not inside claude-code-methodology/
- ALWAYS verify deployment before saying "done"

═══════════════════════════════════════════════════════════════════════

---

## Detailed Phase Instructions (for Claude Code to follow)

### Phase 0: VERSION DETECTION

```bash
# Read current project version
cat VERSION.json 2>/dev/null || echo "No VERSION.json found — first install"

# Read new methodology version
cat claude-code-methodology/VERSION.json

# Read changelog to understand what's new
cat claude-code-methodology/CHANGELOG.md
```

Compare the two versions. Report:
- Current version: vX.Y.Z
- New version: vX.Y.Z
- Changes: [list from CHANGELOG.md]

If versions are the same, STOP and tell the user "Already up to date."

---

### Phase 1: SAFETY BACKUP

Before touching ANY files, create backups:

```bash
# Create safety branch
git checkout -b upgrade/arib-v$(cat claude-code-methodology/VERSION.json | grep '"version"' | cut -d'"' -f4)

# Back up memory (YOUR DATA — irreplaceable)
cp -r memory/ memory-backup-$(date +%Y%m%d)/ 2>/dev/null

# Back up I/O archive
cp -r io/archive/ io-archive-backup-$(date +%Y%m%d)/ 2>/dev/null

# Back up current CLAUDE.md (has project-specific content)
cp CLAUDE.md CLAUDE.md.backup 2>/dev/null
```

---

### Phase 2: PRESERVE — Never Touch These Files

These files contain YOUR project-specific data. DO NOT overwrite, modify,
or replace them. They stay exactly as they are.

```
DO NOT TOUCH:
├── core/                            ← your project context files (specs, designs, schemas)
├── memory/project_status.md         ← your project state
├── memory/session_notes.md          ← your session history
├── memory/change_log.md             ← your change history
├── memory/architecture_decisions.md ← your ADRs
├── memory/bugs_and_fixes.md         ← your bug patterns
├── memory/testing_log.md            ← your test results
├── memory/archive/                  ← your archived memory
├── io/archive/                      ← your completed I/O pairs
├── io/status.md                     ← your I/O metrics
└── operations/OPERATIONS_LOG.md     ← your operations history
```

---

### Phase 3: UPDATE — Replace These with New Version

These are **system files** that contain NO project-specific data.
Replace them entirely with the new version from claude-code-methodology/.

**For each file below:** read from `claude-code-methodology/[path]`,
write to `./[path]` (project root).

```bash
# Agents — replace all 13 with improved versions
cp claude-code-methodology/.claude/agents/*.md .claude/agents/

# Skills — replace commands with skills (v3.0 migration)
mkdir -p .claude/skills
cp -r claude-code-methodology/.claude/skills/arib-* .claude/skills/

# Rules — path-scoped modular rules (new in v3.0)
mkdir -p .claude/rules
cp claude-code-methodology/.claude/rules/*.md .claude/rules/

# Agent memory and output styles (new in v3.0)
mkdir -p .claude/agent-memory .claude/output-styles

# MCP configuration (new in v3.0 — lives at project root)
cp claude-code-methodology/.mcp.json ./.mcp.json 2>/dev/null

# Worktree includes (new in v3.0)
cp claude-code-methodology/.worktreeinclude ./.worktreeinclude 2>/dev/null

# Legacy commands — keep for backward compatibility but skills take precedence
cp claude-code-methodology/.claude/commands/arib-*.md .claude/commands/ 2>/dev/null

# System files
cp claude-code-methodology/SYSTEM.md ./SYSTEM.md
cp claude-code-methodology/VERSION.json ./VERSION.json
cp claude-code-methodology/CHANGELOG.md ./CHANGELOG.md
cp claude-code-methodology/README.md ./README.md

# I/O protocol and templates
cp claude-code-methodology/io/IO_PROTOCOL.md ./io/IO_PROTOCOL.md
cp claude-code-methodology/io/BRIEFING_COWORK.md ./io/BRIEFING_COWORK.md
cp claude-code-methodology/io/BRIEFING_CLAUDE_CODE.md ./io/BRIEFING_CLAUDE_CODE.md
cp -r claude-code-methodology/io/.templates/ ./io/.templates/

# Memory protocol (the protocol, not the data files)
cp claude-code-methodology/memory/MEMORY_PROTOCOL.md ./memory/MEMORY_PROTOCOL.md

# Hooks, reference, scripts
cp claude-code-methodology/hooks/HOOKS_PROTOCOL.md ./hooks/HOOKS_PROTOCOL.md
cp claude-code-methodology/reference/SKILLS_REGISTRY.md ./reference/SKILLS_REGISTRY.md
cp claude-code-methodology/reference/USAGE_GUIDE.md ./reference/USAGE_GUIDE.md
cp claude-code-methodology/reference/COMMANDS_GUIDE.md ./reference/COMMANDS_GUIDE.md
cp claude-code-methodology/scripts/*.sh ./scripts/

# Bootstrap protocols (self-updating)
cp claude-code-methodology/bootstrap/*.md ./bootstrap/
```

**Check for NEW files** that didn't exist before:
```bash
# Find new agents
diff <(ls claude-code-methodology/.claude/agents/) <(ls .claude/agents/) | grep "^<"

# Find new skills
diff <(ls claude-code-methodology/.claude/skills/) <(ls .claude/skills/) | grep "^<"

# Find new rules
diff <(ls claude-code-methodology/.claude/rules/) <(ls .claude/rules/) | grep "^<"
```

If new files found, copy them too.

---

### Phase 4: MERGE — The Critical Part (Especially CLAUDE.md)

These files contain BOTH system template content AND your project-specific data.
You must MERGE them: keep your data, adopt new structure.

╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  CLAUDE.md MERGE RULE                                       ║
║                                                                  ║
║  CLAUDE.md is the MOST IMPORTANT merge. It contains:             ║
║  - System structure (sections, rules, protocols) → UPDATE these  ║
║  - Project data (name, stack, entities, routes) → KEEP these     ║
║                                                                  ║
║  HOW TO MERGE CLAUDE.md:                                         ║
║  1. Read YOUR current ./CLAUDE.md                                ║
║  2. Read the NEW claude-code-methodology/CLAUDE.md               ║
║  3. Extract YOUR project-specific data from your current file:   ║
║     - Project name, description, owner                           ║
║     - Tech stack (languages, frameworks, databases)              ║
║     - Entity list and relationships                              ║
║     - API routes and structure                                   ║
║     - User roles and permissions                                 ║
║     - Business rules and domain constraints                      ║
║     - Any custom sections you added                              ║
║  4. Take the NEW template structure (new sections, new rules,    ║
║     new agent references, new features)                          ║
║  5. INJECT your project data into the new template structure     ║
║  6. Write the merged CLAUDE.md to ./CLAUDE.md                    ║
║                                                                  ║
║  RESULT: New system structure + your project data = merged file  ║
╚══════════════════════════════════════════════════════════════════╝

**For each MERGE file, follow this pattern:**

1. Read current project file: `cat ./[path]`
2. Read new template file: `cat claude-code-methodology/[path]`
3. Compare: identify what's NEW in the template vs what's YOUR DATA
4. Write merged version to `./[path]`

```
MERGE these files:
├── CLAUDE.md                        ← MERGE (keep project data + new system structure)
├── architecture/CONSTRAINTS.md      ← keep your domain rules, adopt new universal rules
├── architecture/TECH_STACK.md       ← keep your stack, adopt updated forbidden list
├── architecture/CONTEXT_MAP.md      ← keep your structure, adopt new template sections
├── architecture/ERROR_PATTERNS.md   ← keep your patterns, add new universal ones
├── architecture/DECISIONS.md        ← keep your ADRs, adopt new template format
├── architecture/SECURITY.md         ← keep your security config, adopt new checklist items
├── architecture/SERVICE_MAP.md      ← keep your services, adopt new template (if exists)
├── architecture/INTER_SERVICE.md    ← keep your patterns, adopt new template (if exists)
│
├── implementation/API_ENDPOINTS.md  ← keep your routes, adopt new format
├── implementation/docker-compose.yml← keep your services, adopt best practices
├── implementation/DOCKER_LOCAL.md   ← keep your setup, adopt new troubleshooting
├── implementation/EVENT_SCHEMA.md   ← keep your events, adopt new format
├── implementation/MIGRATION_ORDER.md← keep your graph, adopt new template
├── implementation/LOCAL_RUNBOOK.md  ← keep your steps, adopt new format
├── implementation/GATEWAY_ROUTES.md ← keep your routes, adopt new format
│
├── operations/WORKFLOW.md           ← keep your conventions, adopt new pipeline
├── operations/DEPLOYMENT.md         ← keep your infra, adopt new checklist
├── operations/OBSERVABILITY.md      ← keep your config, adopt new template (if exists)
│
└── .claude/settings.json            ← keep your permissions, add new entries
```

---

### Phase 5: ADD — New Files in This Version

Check the CHANGELOG.md for files that are NEW in the target version.
If they don't exist in your project root, create them.

```bash
# Check for any new directories in the methodology
diff <(cd claude-code-methodology && find . -type d | sort) <(find . -type d -not -path '*/claude-code-methodology/*' -not -path '*/.git/*' -not -path '*/node_modules/*' | sort)

# Check for any new files
diff <(cd claude-code-methodology && find . -type f -name '*.md' | sort) <(find . -type f -name '*.md' -not -path '*/claude-code-methodology/*' -not -path '*/.git/*' | sort)
```

For each new file found:
1. Create the directory: `mkdir -p [directory]`
2. Copy the file: `cp claude-code-methodology/[path] ./[path]`
3. If the file needs project-specific data, customize it

---

### Phase 6: VERIFY DEPLOYMENT

After completing all phases, verify the upgrade:

```bash
echo "=== UPGRADE VERIFICATION ==="

# 1. Version check
echo "--- Version ---"
cat VERSION.json | grep '"version"'

# 2. Directory structure
echo "--- Directories ---"
for dir in .claude/agents .claude/commands memory architecture implementation operations io hooks reference scripts bootstrap; do
  test -d "$dir" && echo "✅ $dir/" || echo "❌ $dir/ MISSING"
done

# 3. Critical files
echo "--- Critical Files ---"
for file in CLAUDE.md SYSTEM.md VERSION.json .claude/agents/architect.md memory/MEMORY_PROTOCOL.md memory/project_status.md; do
  test -f "$file" && echo "✅ $file" || echo "❌ $file MISSING"
done
# Check for branded session-start command
ls .claude/commands/ | grep -E '\-session-start\.md' && echo "✅ .claude/commands/*-session-start.md (branded)" || echo "❌ Branded session-start MISSING"

# 4. Memory preserved (must still have content)
echo "--- Memory Preserved ---"
wc -l memory/project_status.md memory/session_notes.md memory/change_log.md 2>/dev/null

# 5. Commands count
echo "--- Commands ---"
ls .claude/commands/ | wc -l
echo "files in .claude/commands/"

# 6. Agents count
echo "--- Agents ---"
ls .claude/agents/ | wc -l
echo "files in .claude/agents/"

# 7. Run validation if available
echo "--- System Validation ---"
bash scripts/validate-system.sh 2>/dev/null || echo "validate-system.sh not found"
```

**CRITICAL CHECK**: Verify CLAUDE.md contains your project-specific data:
```bash
# These should return YOUR project name, not template placeholders
head -5 CLAUDE.md
grep -c "\[PROJECT\]\|\[YOUR\]\|placeholder\|REPLACE" CLAUDE.md && echo "⚠️ WARNING: Template placeholders found!" || echo "✅ No placeholders"
```

**IMPORTANT**: The upgrade is NOT complete until:
- Every file exists in the project root
- Memory files are intact (not overwritten)
- CLAUDE.md contains your real project data (not template placeholders)
- Commands appear in `/` menu (restart Claude Code to test)
- validate-system.sh passes

---

### Phase 7: COMMIT & CLEANUP

```bash
# Remove backups (they're on the safety branch anyway)
rm -rf memory-backup-*/ io-archive-backup-*/ CLAUDE.md.backup 2>/dev/null

# Commit the upgrade
git add .
git commit -m "[chore]: upgrade CCM v[OLD] → v[NEW]

- Updated: agents (13), commands (14), system files, templates
- Merged: CLAUDE.md, architecture/, implementation/, operations/
- Preserved: memory/, io/archive/, operations log
- Added: [list any new files from this version]
- Verified: validate-system.sh passes

Changes in this version:
[paste key items from CHANGELOG.md]"

# Merge to working branch
git checkout develop  # or main
git merge upgrade/arib-v[NEW]
```

---

## CLAUDE.md Merge — Detailed Example

This is the most asked-about part, so here's a concrete example:

### Your current CLAUDE.md (project-specific):
```markdown
# CLAUDE.md — MotorGate System v2.5.0
## §0 Identity
- Project: MotorGate Vehicle Management System
- Tech: .NET 8 + Angular 17 + SQL Server
- Owner: Abdullah
## §6 Agent System
| Agent | File |
| Architect | .claude/agents/architect.md |
... (only lists 10 agents from v2.5.0)
```

### New methodology CLAUDE.md (v2.6.0 template):
```markdown
# CLAUDE.md — [Project Name] v2.6.0
## §0 Identity
- Project: [YOUR PROJECT NAME]
## §6 Agent System
| Agent | File |
... (lists all 13 agents including new API Docs + Accessibility)
## §13 Production Monitoring   ← NEW SECTION
```

### Merged result (written to ./CLAUDE.md):
```markdown
# CLAUDE.md — MotorGate System v2.6.0        ← YOUR name + NEW version
## §0 Identity
- Project: MotorGate Vehicle Management System ← YOUR data kept
- Tech: .NET 8 + Angular 17 + SQL Server       ← YOUR data kept
- Owner: Abdullah                               ← YOUR data kept
## §6 Agent System
| Agent | File |
| Architect | .claude/agents/architect.md |
... (all 13 agents — YOUR 10 + 3 NEW ones)     ← MERGED
## §13 Production Monitoring                    ← NEW SECTION added
```

**This is the correct merge**: YOUR project data + NEW system features.

---

## Quick Reference: File Upgrade Strategy

| Category | Strategy | What It Means |
|---|---|---|
| **memory/*.md** (data files) | PRESERVE | Do NOT touch. Your project history. |
| **memory/MEMORY_PROTOCOL.md** | UPDATE | System protocol, no project data. Replace. |
| **CLAUDE.md** | MERGE | Keep your project data. Adopt new structure. |
| **.claude/agents/*.md** | UPDATE | System agents, improved with each version. Replace. |
| **.claude/commands/*.md** | UPDATE | System commands, improved with each version. Replace. |
| **architecture/*.md** | MERGE | Keep your domain rules. Adopt new template sections. |
| **implementation/*.md** | MERGE | Keep your routes/config. Adopt new format. |
| **operations/OPERATIONS_LOG.md** | PRESERVE | Your operations history. Do NOT touch. |
| **operations/*.md** (others) | MERGE | Keep your config. Adopt new checklist items. |
| **io/archive/** | PRESERVE | Your completed I/O pairs. Do NOT touch. |
| **io/*.md** (protocols) | UPDATE | System protocols, no project data. Replace. |
| **scripts/*.sh** | UPDATE | Improved automation. Replace. |
| **bootstrap/*.md** | UPDATE | Improved protocols. Replace. |
| **hooks/*.md** | UPDATE | Improved recipes. Replace. |
| **reference/*.md** | UPDATE | Updated catalogs. Replace. |
| **SYSTEM.md, VERSION.json** | UPDATE | System metadata. Replace. |
| **CHANGELOG.md, README.md** | UPDATE | Release info. Replace. |
| **.claude/settings.json** | MERGE | Keep your permissions. Add new entries. |
| **.env.example** | MERGE | Keep your variables. Add new ones. |

---

## Troubleshooting

### "CLAUDE.md lost my project data after upgrade"
- Restore from backup: `cp CLAUDE.md.backup CLAUDE.md`
- The upgrade did a REPLACE instead of MERGE — redo Phase 4 carefully

### "validate-system.sh reports missing files"
- Check if the file is new in this version → Phase 5 (ADD)
- Check if the file was renamed → see CHANGELOG.md

### "Commands don't appear in / menu"
- Verify files exist: `ls .claude/commands/`
- Verify YAML frontmatter: `head -3 .claude/commands/session-start.md`
- Restart Claude Code (commands load on startup, not mid-session)

### "Agents don't seem to know about my project"
- Agents are generic system files — they don't contain project data
- Your project context comes from CLAUDE.md + memory/ + architecture/
- Verify CLAUDE.md was merged correctly (has your project data)

### "Memory files look different"
- Memory DATA files are never touched during upgrade
- If the format changed, update the format while keeping your entries
- Check memory/MEMORY_PROTOCOL.md for the new expected format

---

> **End of Upgrade Protocol**
> Your data is sacred. The system evolves around it.
