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

STEP 0b: Check the plan mesh (ADR-039):
  $ bash scripts/ccm-plan.sh status
  - If a plan is ACTIVE -> report ready tasks + who else is attached,
    read the inbox, and join with /arib-plan join instead of re-planning
  - If UNREAD messages -> another session left you something; read it
  - If no active plan -> continue to Step 1

STEP 1: Read the LEAN CORE only (v3.8.0 Lean Core — ADR-019).
  These four are always-on; read them every session:
  1. CLAUDE.md                          <- the master brain
  2. architecture/CONSTRAINTS.md        <- hard rules (must see before acting)
  3. memory/project_status.md           <- current state
  4. memory/session_notes.md            <- last session's handoff

  Do NOT bulk-read the reference docs at start. Read them ON DEMAND when
  the task touches them (this keeps always-on context ~8K, not ~46K):
  - architecture/TECH_STACK.md     -> when choosing a library / new feature
  - architecture/CONTEXT_MAP.md    -> when deciding where code lives (the
                                      pre-tool-use hook already reads its
                                      allowed_write_paths block directly)
  - architecture/ERROR_PATTERNS.md -> when debugging (arib-dev-debug loads it)
  - architecture/DECISIONS.md      -> when a decision's rationale matters
  - architecture/SECURITY.md       -> when touching auth/data (security-auditor)
  - implementation/API_ENDPOINTS.md, EVENT_SCHEMA.md, MIGRATION_ORDER.md
                                   -> when touching those subsystems
  - operations/WORKFLOW.md         -> when the dev workflow is in question
  See CLAUDE.md section 6 ("Where to Find Everything") for the full map.

STEP 2: Check environment:
  $ git status && git branch && git log --oneline -5

STEP 3: Report to user:
  - I/O status (pending requests, signals, pipelines)
  - Current branch and recent commits
  - Current task from project_status.md
  - Any blockers or warnings from last session
  - Proposed plan for this session

STEP 4: Wait for user confirmation before writing any code.
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
