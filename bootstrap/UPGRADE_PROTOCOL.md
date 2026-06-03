# Upgrade Protocol — Safely Upgrade CCM to a New Version

> **Purpose**: When a new version of `claude-code-methodology/` is released,
> this protocol tells Claude Code EXACTLY how to upgrade your project's
> methodology files — safely, without losing any project-specific data.
>
> **Core Principle**: READ from methodology. WRITE to project root. PRESERVE your data. VERIFY everything.
>
> **Decisive behavior**: Per `bootstrap/PROTOCOL_PRINCIPLES.md` (v3.5.1+),
> this protocol does **not** stop on matching versions, does **not**
> present multiple-choice menus, and does **not** ask the user
> questions whose answers are determinable from the filesystem. When
> versions match, the protocol proceeds to **Phase 1.5 (drift
> detection)** automatically. When versions differ, the protocol runs
> the appropriate phase sequence without prompting.

---

## Step 0 — Get the new version (fetch from GitHub)

Before this protocol can run, your project needs the **new** CCM source on
disk at `./claude-code-methodology/`. You don't download it by hand anymore.

From your project root — **this works on any version, including old ones
that have no `ccm-fetch.sh` yet** (it pulls the script fresh from GitHub):

```bash
curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
```

(Shortcut once you already have a recent CCM:
`./claude-code-methodology/scripts/ccm-fetch.sh --ref v3.9.0` to pin.)

`ccm-fetch.sh` updates ONLY the framework source folder (keeping the old one
at `claude-code-methodology.prev`) and touches no project data. The phases
below then do the intelligent merge. If you placed the new
`claude-code-methodology/` folder manually instead, skip straight to Phase 0.

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

**Branching by comparison (per `bootstrap/PROTOCOL_PRINCIPLES.md` Rule 1):**

| Comparison | Action |
|------------|--------|
| Template version > project version | Continue to Phase 1 (full upgrade) |
| Template version == project version | **PROCEED to Phase 1.5 (drift detection)** — do NOT stop |
| Template version < project version | STOP with error: user has stale template, not stale project. Recommend they update `claude-code-methodology/` first. |

**Do NOT terminate on matching versions.** Matching versions do not
imply matching files — project extensions, prior partial merges, and
local edits all produce drift even at the current version. Drift
detection (Phase 1.5 below) is the correct continuation.

The line "If versions are the same, STOP and tell the user 'Already
up to date.'" was the v3.1-and-earlier behavior. v3.5.1 supersedes it
per `bootstrap/PROTOCOL_PRINCIPLES.md`.

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

### Phase 1.5: DRIFT DETECTION (mandatory; runs in same-version case too)

This phase exists because matching `VERSION.json` does not imply
matching files. Per `bootstrap/PROTOCOL_PRINCIPLES.md` Rule 4, drift
detection is automatic and complete.

#### 1.5.1 — Build the file inventory

```bash
# Every file the template ships, relative to claude-code-methodology/
TEMPLATE_FILES=$(cd claude-code-methodology && git ls-files 2>/dev/null \
  || find . -type f -not -path './.git/*' | sed 's|^./||')
```

#### 1.5.2 — Classify each file

**Run the real classifier (v3.7.1):**

```bash
# From the project root, with CCM installed under claude-code-methodology/:
claude-code-methodology/scripts/drift-detect.sh \
  --manifest claude-code-methodology/reference/template-hashes.json \
  --target .
```

`drift-detect.sh` reads the sha256 manifest the template ships
(`reference/template-hashes.json`, generated by
`scripts/gen-template-hashes.sh` on each release) and classifies every
shipped framework file:

```text
IDENTICAL  — project hash == manifest hash. Skip.
MISSING    — manifest path absent in project. Safe to COPY from template.
DIFFERS    — hashes differ. NEEDS REVIEW — could be a stale template to
             refresh OR a deliberate local edit to keep. The classifier
             does NOT guess and NEVER auto-overwrites; the human decides
             per file. (This is the data-loss fix: the old heuristic
             guessed and could clobber edits.)
```

Project-STATE paths (memory data files, `core/**`, `io/ledger/**`,
`io/hook-logs/**`, `compliance/CONTROLS.md`, `waves/<name>/**`) are NOT
in the manifest, so they are never classified or touched.

The report is written to `io/ledger/drift-<ts>-<hash>.md`. Apply only
the MISSING copies and the DIFFERS files you explicitly choose to
refresh — see 1.5.3.

#### 1.5.3 — Apply refreshes

For each file classified STALE-TEMPLATE:

```bash
cp -p claude-code-methodology/<path> ./<path>
```

For each file classified PROJECT-STATE or LOCAL-EDIT: do nothing.

For each file classified IDENTICAL: do nothing.

#### 1.5.4 — Drift report

Write the report to `io/ledger/drift-<YYYY-MM-DD>-<short-hash>.md`
with the same YAML-style header as `/arib-deep-audit`:

```markdown
# Drift Detection Report

- audit-hash: <sha256 of findings, sorted>
- short-hash: <first 8>
- timestamp: <ISO-8601>
- branch: <git current branch>
- mode: drift-detection
- template_version: <semver from template VERSION.json>
- project_version: <semver from project VERSION.json>
- comparison: equal | newer | older
- identical: <count>
- refreshed: <count>
- preserved_extensions: <count>
- preserved_local_edits: <count>
- preserved_project_state: <count>

## Refreshed files
- <path> (was: <short-hash-old>, now: <short-hash-new>)

## Project extensions (preserved untouched)
- <path>

## Local edits (REVIEW recommended)
- <path> — bytes differ from current template AND no prior template
  hash matches. Either a project customization to keep, or a missed
  earlier merge to redo. Confirm.

## Project state (preserved untouched)
- <path>
```

Also append one summary line to `operations/OPERATIONS_LOG.md`:

```text
2026-05-08 | upgrade-drift | <verdict> | <short-hash> | refreshed=N preserved=M reviewed=K
```

#### 1.5.5 — Branch on result

| Drift report | Continue with |
|--------------|---------------|
| Refreshed > 0 | Continue to Phase 2-7 (verify, commit) |
| All identical or only project state | STOP cleanly with "no drift; project synced". This is a legitimate clean exit, not a Rule 1 violation — drift was *checked*, just absent. |
| Local edits with REVIEW flag | Continue but include the REVIEW list in the final report so the user can act. |

**Do not present a numbered options menu** at this point. The
classification is deterministic; the actions are deterministic.

---

### Phase 1.6: RE-VERIFICATION RECOMMENDATIONS (v3.8.4)

The upgrade refreshes a skill's **definition** (Phase 1.5). It does NOT
re-do the skill's **prior work** — if an old, weaker version of a skill
was run on part of your project, those results are still the old results.
This phase surfaces, precisely, which prior work is worth redoing.

**It does NOT alert you to "reactivate every skill" — that would be noise.**
It recommends re-running ONLY skills that are *both* (a) materially changed
in this upgrade AND (b) actually used in this project. And it never
auto-runs them, never gates the upgrade — it reports + offers once.

#### 1.6.1 — Which skills changed materially?

From Phase 1.5: the set of `.claude/skills/*/SKILL.md` classified
`STALE-TEMPLATE` (refreshed to the new version). Exclude cosmetic-only
diffs (a heading rename, a typo fix) — only behavior/contract changes
count. The drift report already names them.

#### 1.6.2 — Which of those were used HERE?

Determine usage, best-effort, in this priority:

```text
1. PRIMARY (exact, if present): io/ledger/invocations.jsonl
   grep for {"type":"skill","name":"arib-<skill>"} — this is the
   invocation telemetry the UserPromptSubmit hook records (v3.8.4).
   If the file exists, it is authoritative for "was this run here".

2. FALLBACK (heuristic, when telemetry absent — older projects):
   grep memory/change_log.md, memory/*.md, and io/ledger/ for the skill
   name or its characteristic output (e.g. a security-*/audit-* report,
   a deploy gate verdict). A footprint = it was used.

If NEITHER signal exists, the skill was likely never used here — do NOT
recommend re-verifying it.
```

Be honest in the report about which signal was used: "(per invocation
log)" vs "(heuristic — no telemetry; may miss untracked runs)".

#### 1.6.3 — Prioritize and report (no auto-run, no gate)

For each skill that is *changed AND used*, add it to a **Recommended
re-verifications** list in the upgrade report, prioritized:

| Priority | Skills | Why |
|----------|--------|-----|
| **High** | quality/safety gates: `arib-check-security`, `arib-check-deps`, `arib-check-a11y`, `arib-check-migrate`, `arib-check-reality` | cheap to re-run, high value; an improved gate may catch what the old one missed |
| **Medium** | `arib-deep-audit`, `arib-check-perf`, `arib-check-compliance`, `arib-dev-review` | broader passes; re-run if the area is active |
| **Low** | docs/cosmetic: `arib-docs-*`, `arib-check-design` | re-run opportunistically |

Each entry states: skill, what changed in it, the usage signal, and the
exact command (`/arib-<skill>`).

Then make **one batched offer** and stop — e.g.:

> "3 skills that were used here improved in this upgrade. Re-run them to
> re-verify with the better versions?
>   High: /arib-check-security  /arib-check-deps
>   Medium: /arib-deep-audit
> Reply 'yes' to run all, or name the ones you want."

**Never** auto-run (some, like `arib-check-deploy`, touch production).
**Never** gate the upgrade on it — the upgrade is already complete; this
is a post-upgrade recommendation. **Never** prompt per-skill — one offer,
batched, per PROTOCOL_PRINCIPLES Rule 2.

If nothing qualifies (no changed-and-used skill), say so in one line and
skip the offer entirely — don't manufacture a recommendation.

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

---

## v3.3 "Operating" upgrade addendum

If upgrading from v3.1 or v3.2 to v3.3:

1. **Install the enforcement layer** — this is the single most important
   step. v3.3 hooks live as real bash scripts under `.claude/hooks/`,
   not as documentation:

   ```bash
   ./scripts/install-hooks.sh
   ```

2. **Verify `architecture/CONTEXT_MAP.md` allowed_write_paths**
   includes `compliance/` and `waves/`. Without these, the path-scoping
   hook will reject writes to the new directories.

3. **Optional MCPs** — set the env vars only for the ones you use.
   See `.mcp.json` for the list and `compliance/README.md` for the
   honesty principle (CCM never requires any MCP).

4. **Run `./scripts/token-audit.sh`** to record your project's session-
   start cost. Commit the number in your changelog as a baseline.

5. **Review the new compliance docs** at `compliance/README.md` and
   the framework files. Note especially that ISO 27001 and SOC 2 docs
   are alignment-only — CCM never claims certification.

6. **Existing memory files are untouched.** v3.3 adds a hybrid memory
   *layer* (claude-mem MCP) but does not modify the markdown audit
   trail. If you skip the MCP, behavior matches v3.1 exactly.

---

> **End of Upgrade Protocol**
> Your data is sacred. The system evolves around it.
