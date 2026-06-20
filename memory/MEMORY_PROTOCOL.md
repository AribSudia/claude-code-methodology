# Memory Protocol — Persistent Memory Architecture

> **Purpose**: Claude Code has no built-in memory between sessions.
> This protocol defines how memory is created, stored, retrieved, and
> maintained so that every session starts with full context.

---

## 1. The Memory Problem

Without persistent memory:
- Every session starts from zero
- Decisions are re-debated
- Bugs are re-introduced
- Architecture drifts
- Context is lost, time is wasted

This protocol solves all of these.

---

## 2. Memory File Definitions

### 2.1 — project_status.md

**Purpose**: Single source of truth for where the project stands right now.

**Format**:
```markdown
# Project Status

## Current Phase
[Phase name]: [brief description]

## Active Sprint / Milestone
[Name]: [target date if applicable]

## Feature Tracker

| Feature              | Status       | Assignee | Priority | Notes           |
|----------------------|--------------|----------|----------|-----------------|
| User Authentication  | ✅ Complete  | —        | Critical | Tested + merged  |
| Payment Integration  | 🔄 Active   | Session  | Critical | Tap webhooks WIP |
| Search & Filters     | ⏳ Pending  | —        | High     | After payments   |

## Blockers
- [Blocker description] — [who can unblock] — [since when]

## Next Tasks (Priority Order)
1. [Task 1 — specific enough to start immediately]
2. [Task 2]
3. [Task 3]
```

**Update Rule**: Updated at every task completion and every session end.

---

### 2.2 — session_notes.md

**Purpose**: Handoff document between sessions. The next session reads this
to know exactly where the last one ended.

**Format**:
```markdown
# Session Notes

## Session: 2026-04-15 14:30 → 16:45

### Completed
- Implemented user registration endpoint (POST /api/v1/auth/register)
- Added bcrypt password hashing with salt rounds = 12
- Created user model migration (001_create_users)

### Files Changed
- src/auth/register.controller.ts — new file
- src/auth/auth.service.ts — added register method
- prisma/migrations/001_create_users/ — new migration

### Problems Encountered
- PostgreSQL connection pool exhaustion under test load
  → Fixed: increased pool size from 5 to 20 in test config
  → Added to ERROR_PATTERNS.md

### Decisions Made
- Chose bcrypt over argon2 for password hashing (broader library support)
  → Added ADR-003 to architecture/DECISIONS.md

### Next Session Starts With
1. Implement login endpoint (POST /api/v1/auth/login)
2. Add JWT token generation (access + refresh)
3. Write integration tests for auth flow

---

## Session: 2026-04-14 10:00 → 12:30
[previous session...]
```

**Update Rule**: Written at every session end. Keep the last few sessions;
condense older detail into `CHANGELOG.md` (no `memory/archive/` — see §4).

---

### 2.3 — change_log.md

**Purpose**: Chronological record of every change. Acts as a project
timeline that Claude Code can search.

**Format**:
```markdown
# Change Log

## 2026-04-15

### [feat]: User registration endpoint
- Added: POST /api/v1/auth/register
- Added: User model with email, password_hash, role, created_at
- Added: Input validation (email format, password min 8 chars)
- Commit: abc1234

### [fix]: Connection pool exhaustion
- Fixed: PostgreSQL pool size in test config (5 → 20)
- Root cause: concurrent test suites sharing single pool
- Commit: def5678

## 2026-04-14

### [chore]: Project initialization
- Created: directory structure per CONTEXT_MAP.md
- Created: docker-compose.yml with PostgreSQL + Redis
- Created: .env.example with all required variables
- Commit: 789abcd
```

**Update Rule**: Updated after every commit during a session.

---

### 2.4 — architecture_decisions.md

**Purpose**: Why things are built the way they are. Prevents re-debating
settled decisions. New team members (or new Claude Code sessions) can read
the reasoning behind every choice.

**Format**:
```markdown
# Architecture Decision Records

## ADR-001: [Decision Title]
- **Date**: 2026-04-15
- **Status**: Accepted / Superseded by ADR-XXX / Deprecated
- **Context**: [What situation prompted this decision]
- **Decision**: [What was decided]
- **Alternatives Considered**:
  1. [Alternative A] — rejected because [reason]
  2. [Alternative B] — rejected because [reason]
- **Consequences**: [What this decision means going forward]
- **Review Date**: [When to reconsider, if applicable]
```

**Update Rule**: New ADR created whenever a significant technical decision
is made (framework choice, architecture pattern, library selection, etc.)

---

### 2.5 — bugs_and_fixes.md

**Purpose**: Pattern database of bugs encountered and how they were fixed.
Claude Code checks this before debugging to see if a similar bug was
already solved.

**Format**:
```markdown
# Bugs and Fixes

## BUG-001: [Short Description]
- **Date**: 2026-04-15
- **Severity**: Critical / High / Medium / Low
- **Symptoms**: [What the user/developer saw]
- **Root Cause**: [The actual underlying issue]
- **Fix Applied**: [What was changed]
- **Files Changed**: [list]
- **Prevention**: [How to prevent recurrence]
- **Related**: ERROR_PATTERNS.md → [pattern name]
```

**Update Rule**: New entry for every non-trivial bug fix.

---

### 2.6 — testing_log.md

**Purpose**: Track test results, coverage trends, and regressions
across sessions. Catch coverage decay early.

**Format**:
```markdown
# Testing Log

## 2026-04-15 — Session End

### Test Results
- Total: 47 tests
- Passed: 45 ✅
- Failed: 2 ❌ (auth/login.spec.ts — timeout on CI)
- Skipped: 0

### Coverage
| Module       | Statements | Branches | Functions | Lines  |
|--------------|-----------|----------|-----------|--------|
| auth/        | 92%       | 85%      | 100%      | 91%    |
| users/       | 78%       | 70%      | 80%       | 76%    |
| payments/    | 0%        | 0%       | 0%        | 0%     |
| **Overall**  | **72%**   | **65%**  | **80%**   | **70%**|

### Regressions
- None this session

### Notes
- Payment module untested — implementation not started
- Auth timeout issue: likely CI resource constraint, not code bug
```

**Update Rule**: Updated after every significant test run.

### 2.7 — semantic_export.md

**Purpose**: Snapshot of the **opt-in** claude-mem semantic layer (Layer 1),
exported by `scripts/memory-export.sh` at session end *only if* claude-mem is
configured. On a stock install there is no export — the file self-labels as a
no-op seed, and `grep` over the other six files is the entire recall surface.

**Update Rule**: Written at session end when `CLAUDE_MEM_API_KEY` is set; a
no-op (last-known-good preserved) otherwise.

> **Canonical count: 7 data files** (§2.1–§2.7) **+ this `MEMORY_PROTOCOL.md`**
> = 8 markdown files in `memory/`. `project_status.md` + `session_notes.md` are
> always-on (lean core); the rest load on demand.

---

## 3. Memory Lifecycle

```
SESSION START
    │
    ├── READ: project_status.md    → know where we are
    ├── READ: session_notes.md     → know what happened last time
    ├── READ: change_log.md (last 5 entries) → recent changes
    │
    ▼
SESSION WORK
    │
    ├── WRITE: change_log.md       → after each commit
    ├── WRITE: bugs_and_fixes.md   → after each bug fix
    ├── WRITE: architecture_decisions.md → after each decision
    ├── WRITE: testing_log.md      → after test runs
    │
    ▼
SESSION END
    │
    ├── WRITE: session_notes.md    → handoff to next session
    ├── WRITE: project_status.md   → update feature tracker
    ├── COMMIT: all memory files   → persist to git
    └── PUSH: to remote            → survive machine failures
```

---

## 4. Memory Maintenance Rules

### Size Limits (guideline, not automated — v3.13.0/ADR-028)
- Soft target ~200 lines of active content per file. There is **no auto-rotation
  script** and **no `memory/archive/` directory** — when a file grows past the
  target, condense old detail into `CHANGELOG.md` / `architecture/DECISIONS.md`
  rather than letting the always-on files bloat.
- Freshness is the enforced part: `validate-coherence.sh` §8 fails CI if
  `project_status.md` / `session_notes.md` go stale (see §3).

### Consistency Checks
At every session start, verify:
1. `project_status.md` matches actual git state
2. `session_notes.md` last entry matches last git commit date
3. No memory file is empty (indicates missed session-end protocol)

### Conflict Resolution
If memory files conflict with actual code state:
1. Git log is the source of truth for what happened
2. Update memory files to match reality
3. Note the discrepancy in session_notes.md

---

## 5. Memory Search Protocol

When Claude Code needs to find something:

1. **Recent context**: Check `session_notes.md` (last 3 sessions)
2. **Specific change**: Search `change_log.md` by date or keyword
3. **Why a decision was made**: Search `architecture_decisions.md` by topic
4. **Known bug pattern**: Search `bugs_and_fixes.md` by symptom
5. **Test status**: Check `testing_log.md` latest entry
6. **Overall status**: Check `project_status.md`

If information is not found in memory files, check git log:
```bash
git log --all --oneline --grep="keyword"
git log --all --oneline -- path/to/file
```

---

## Hybrid Memory (v3.2 — Item #3)

The seven markdown data files described above remain the **audit layer**. They
are human-readable, git-versioned, and authoritative. v3.2 adds an **opt-in
semantic layer** for retrieval at scale.

> **Default install = grep only.** There is **no vector recall** out of the box —
> a stock CCM has no `claude-mem` on PATH and no `CLAUDE_MEM_API_KEY`, so Layer 2
> (grep) is the entire surface. Layer 1 is **opt-in**; don't claim "semantic
> memory" is active unless the MCP actually responds.

### Layer 1 — semantic (opt-in)

The `claude-mem` MCP server (configured in `.mcp.json`) provides vector search
across session memory. Activated by setting `CLAUDE_MEM_API_KEY`. When active,
the `/arib-memory-search` skill queries it first. When inactive (the default),
the skill falls back to grep over `memory/*.md` with no loss of correctness —
only loss of recall on novel paraphrases. (claude-mem is exposed via three
surfaces — MCP tool, CLI, npx server — pin the version and verify at setup.)

### Layer 2 — audit (always)

The seven markdown data files. The semantic layer is exported into
`memory/semantic_export.md` by `scripts/memory-export.sh` on the Stop hook
(a no-op when claude-mem isn't configured). This keeps git the source of truth
even when an external service holds the live index.

### Failure semantics

- If Layer 1 fails, Layer 2 still works. CCM never fails closed on memory.
- If `memory-export.sh` fails (MCP unreachable), the existing
  `semantic_export.md` stays as the last-known-good snapshot.
- If `claude-mem` ever changes its API surface, only `memory-export.sh` and
  the `arib-memory-search` skill need updating — `memory/*.md` is unchanged.

### Privacy note

If your project handles regulated data (PII, PHI, payment data), think before
turning Layer 1 on. The semantic store is third-party. Markdown stays local.
The fallback path is deliberately preserved so you can opt out without losing
function.

---

> **End of Memory Protocol**
> Memory is what separates a productive Claude Code session from a fresh start.
> Follow this protocol rigorously.
