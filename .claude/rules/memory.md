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
| `semantic_export.md`       | claude-mem export snapshot (opt-in Layer 1)| Session end, if claude-mem configured |

That is **7 data files + `MEMORY_PROTOCOL.md`** (8 markdown files in `memory/`).
`project_status.md` and `session_notes.md` are **always-on** (lean core); the
rest load on demand.

## Memory Rules

- **Freshness is CI-enforced (v3.13.0, ADR-028):** `validate-coherence.sh` fails
  if `project_status.md` doesn't name the current version, or `session_notes.md`
  reverts to the v1.0 bootstrap / lacks a current-line entry. "A session without
  a memory update never happened" is now a gate, not just a maxim.
- Keep entries lean; favor one-line items. Soft target ~200 lines/file — when a
  file grows past it, condense old detail into `CHANGELOG.md` rather than letting
  the always-on files bloat. (No auto-rotation; this is a guideline, not a script.)
- Subfolder files APPEND; they never overwrite parent context.
- Memory files are committed with every session-end commit.
- Format: structured markdown with dates, not prose paragraphs.
