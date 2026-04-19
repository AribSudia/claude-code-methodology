---
description: Session lifecycle protocol - start, work, and end procedures
---

# Session Protocol

Every Claude Code session follows this exact protocol. No shortcuts.

## Session Start (READ Phase)

```
STEP 0: Check I/O Channel:
  $ bash scripts/io-watcher.sh
  - If SIGNALS exist -> process immediately (see io/IO_PROTOCOL.md)
  - If REQUESTS pending -> report to user, propose processing order
  - If clear -> continue to Step 1

STEP 1: Read core files (in this order):
  1. CLAUDE.md                          <- the master brain
  2. architecture/CONSTRAINTS.md        <- hard rules
  3. architecture/TECH_STACK.md         <- approved libraries
  4. architecture/CONTEXT_MAP.md        <- folder structure
  5. architecture/ERROR_PATTERNS.md     <- known pitfalls

STEP 2: Read memory files:
  6. memory/project_status.md           <- current state
  7. memory/session_notes.md            <- last session's handoff

STEP 3: Check environment:
  $ git status && git branch && git log --oneline -5

STEP 4: Report to user:
  - I/O status (pending requests, signals, pipelines)
  - Current branch and recent commits
  - Current task from project_status.md
  - Any blockers or warnings from last session
  - Proposed plan for this session

STEP 5: Wait for user confirmation before writing any code.
```

## During Session (WORK Phase)

```
FOR EACH TASK:
  1. Announce what you are about to do
  2. Check CONSTRAINTS.md for relevant rules
  3. Create safety snapshot if modifying existing code
  4. Implement using TDD when possible (RED -> GREEN -> REFACTOR)
  5. Run tests after implementation
  6. Update memory/change_log.md
  7. Commit with conventional format:
     [type]: concise description
     Types: feat | fix | refactor | test | docs | chore | snapshot | security
  8. Report completion to user

IF BLOCKED:
  - Document the blocker in memory/session_notes.md
  - Propose 3 alternative approaches
  - Wait for user decision
  - Never silently work around a blocker
```

## Session End (WRITE Phase)

```
STEP 1: Update memory/session_notes.md:
  ## Session: [DATE] [TIME]
  ### Completed
  - [task 1 - what was done]
  ### Files Changed
  - [file path - what changed]
  ### Problems Encountered
  - [issue - resolution or status]
  ### Next Session Starts With
  - [task 1 - clear instruction]

STEP 2: Update memory/project_status.md

STEP 3: Final commit:
  $ git add . && git commit -m "[chore]: end of session - [summary]"
  $ git push origin [branch]

STEP 4: Report to user:
  - Completed: [list]
  - Issues: [list]
  - Next: [recommendation]
```
