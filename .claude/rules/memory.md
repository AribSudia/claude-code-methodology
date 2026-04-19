---
paths:
  - "memory/**"
---

# Memory System Rules

## Memory File Hierarchy

Memory files form a tree. Higher-level memories persist across projects.
Lower-level memories are project-scoped.

```
~/.claude/CLAUDE.md              <- Global - all projects
    |
    +-- /project/CLAUDE.md       <- Project-scoped (THIS FILE)
        |
        +-- /project/src/CLAUDE.md <- Module-scoped (optional)
```

## Memory Files (in /memory/)

| File                       | Purpose                                  | Updated When            |
|----------------------------|------------------------------------------|-------------------------|
| `project_status.md`        | Current phase, feature tracker, blockers | Every task completion   |
| `session_notes.md`         | Per-session log of what happened         | Every session end       |
| `change_log.md`            | Chronological record of all changes      | Every commit            |
| `architecture_decisions.md`| ADRs - why things are built this way     | Every architectural choice |
| `bugs_and_fixes.md`        | Bug patterns, root causes, fixes applied | Every bug fix           |
| `testing_log.md`           | Test results, coverage trends, regressions| Every test run         |

## Memory Rules

- Keep each file under 200 lines. Archive older entries to `memory/archive/`.
- Subfolder files APPEND; they never overwrite parent context.
- Memory files are committed with every session-end commit.
- Format: structured markdown with dates, not prose paragraphs.
- A session without memory updates is a session that never happened.
