# Reengineering Guide — Applying Methodology to Existing Projects

> **The difference between starting fresh and reengineering**:
> Starting fresh = methodology drives the code.
> Reengineering = code drives the methodology, then methodology governs future code.

---

## 1. The Reengineering Process

```
EXISTING CODEBASE
      │
      ▼
Phase 1: SCAN — Read every file, understand everything
      │
      ▼
Phase 2: EXTRACT — Pull out entities, routes, stack, patterns, rules
      │
      ▼
Phase 3: GENERATE — Fill methodology files with extracted real data
      │
      ▼
Phase 4: RENAME — If project is being renamed, map old → new
      │
      ▼
Phase 5: OVERLAY — Place methodology alongside existing code
      │
      ▼
Phase 6: GOVERN — From this point forward, methodology governs
      │
      ▼
ENHANCED CODEBASE
  with persistent memory, agents, constraints, and structure
```

---

## 2. What Changes, What Doesn't

### Things that DO NOT change:
- Your existing source code (not a single line)
- Your existing folder structure
- Your existing git history
- Your existing CI/CD pipeline
- Your existing deployment

### Things that GET ADDED:
- `CLAUDE.md` at project root (the brain)
- `architecture/` folder (constraints, tech stack, patterns)
- `implementation/` folder (endpoint docs, docker docs)
- `memory/` folder (persistent session memory)
- `operations/` folder (workflow, deployment guide)
- `.claude/` folder (agents, commands, settings, hooks)
- `hooks/` folder (safety gate documentation)
- `bootstrap/` and `reference/` (methodology reference)
- `scripts/` (validation, setup automation)

### Things that MAY change (with your approval):
- `.gitignore` (adding methodology-specific ignores)
- `.env.example` (completing missing variables)
- Project README (adding methodology reference)

---

## 3. Folder Placement Strategy

### Option A: Methodology at Project Root (Recommended)

```
your-project/
├── src/                    ← your existing code (untouched)
├── tests/                  ← your existing tests (untouched)
├── package.json            ← your existing config (untouched)
├── CLAUDE.md               ← NEW: Master Brain
├── architecture/           ← NEW: Architecture layer
├── implementation/         ← NEW: Implementation docs
├── memory/                 ← NEW: Persistent memory
├── operations/             ← NEW: Workflow & deploy
├── .claude/                ← NEW: Agents, commands, hooks
├── hooks/                  ← NEW: Hook documentation
├── bootstrap/              ← NEW: Instantiation tools
├── reference/              ← NEW: Reference material
└── scripts/                ← NEW: Automation
```

### Option B: Methodology in Subfolder

```
your-project/
├── src/                    ← your existing code
├── claude-system/          ← all methodology files here
│   ├── CLAUDE.md
│   ├── architecture/
│   ├── memory/
│   └── ...
└── package.json
```

Option A is recommended because Claude Code reads `CLAUDE.md` from the
project root automatically.

---

## 4. The Reengineering Checklist

### Before Starting
- [ ] Commit all current work (clean working directory)
- [ ] Create a safety branch: `git checkout -b methodology/overlay`
- [ ] Backup .env files (they won't be committed but save locally)

### During Scan
- [ ] Run the Reverse Bootstrap prompt (bootstrap/REVERSE_BOOTSTRAP.md)
- [ ] Verify all entities were detected
- [ ] Verify all routes were detected
- [ ] Verify tech stack is accurate
- [ ] Confirm any rename mapping is correct

### After Generation
- [ ] Review CLAUDE.md — does it accurately describe the project?
- [ ] Review CONSTRAINTS.md — are domain rules correct?
- [ ] Review API_ENDPOINTS.md — are all routes captured?
- [ ] Review MIGRATION_ORDER.md — is the dependency graph right?
- [ ] Run scripts/validate-system.sh to check file completeness

### Activation
- [ ] Merge methodology branch to develop
- [ ] Run first Claude Code session with /session-start
- [ ] Verify Claude Code reads all context correctly
- [ ] Complete one small task to validate the workflow

---

## 5. Handling Project Renames

If you're renaming the project (e.g., "Work Order System" → "[New Name]"):

### Safe Rename Order

```
1. Update documentation first (lowest risk)
   - CLAUDE.md, README, memory files
   - All methodology files

2. Update configuration
   - package.json name field
   - docker-compose.yml service names
   - Environment variable prefixes (if they contain old name)

3. Update code references
   - Import paths (if project name is in paths)
   - API response metadata (if project name appears)
   - Error messages and logs

4. Update infrastructure
   - Database name (requires migration)
   - Docker image names
   - CI/CD pipeline references
   - DNS / domain names

5. Update git
   - Repository name on GitHub/GitLab
   - Remote URLs: git remote set-url origin [new-url]
```

### Rename Safety Rules

- **Never** rename database and code in the same commit
- **Always** create a migration for database renames
- **Test** after each rename step (don't batch)
- **Search** for old name after completion: `grep -r "old-name" . --exclude-dir=.git`

---

## 6. Common Reengineering Scenarios

### Scenario A: Clean, Well-Structured Codebase
- Scan is fast and accurate
- Methodology files are comprehensive
- Minimal gaps to fill
- Time: 1 session

### Scenario B: Legacy Code, No Tests
- Scan reveals missing patterns
- CONSTRAINTS.md gets extra rules
- project_status.md lists "Add tests" as critical
- Testing_log.md starts empty with targets
- Time: 1 session for scan + ongoing for test addition

### Scenario C: Multiple Services / Monorepo
- Scan each service separately
- Create per-service CLAUDE.md files (module-scoped)
- Root CLAUDE.md describes the overall system
- Time: 1 session per service

### Scenario D: Mid-Rename, Inconsistent Naming
- Scan detects both old and new names
- RENAME_MAP.md shows every inconsistency
- Priority: complete rename before adding features
- Time: 1-2 sessions

---

## 7. Post-Reengineering: What's Different

After the methodology is in place, every Claude Code session now:

1. **Starts with context** — reads CLAUDE.md, knows the project
2. **Remembers across sessions** — memory files carry forward
3. **Follows constraints** — won't break business rules
4. **Uses agents** — right specialist for each task
5. **Documents automatically** — change_log, session_notes, decisions
6. **Catches mistakes** — hooks block dangerous operations
7. **Maintains consistency** — approved tech stack, commit convention

The codebase doesn't change. The way Claude Code WORKS with it changes completely.

---

> **End of Reengineering Guide**
> Your code stays yours. The methodology makes it better.
