# Agent Memory

Subagents with `memory: project` in their frontmatter get a dedicated
memory directory here. Each agent reads and writes its own MEMORY.md.

This directory is auto-populated when agents run. Do not create files
manually - agents manage their own memory.

## How It Works

1. Agent runs with `memory: project` frontmatter
2. Claude Code creates `<agent-name>/MEMORY.md` here
3. Agent reads it at start of each task
4. Agent writes back what it learned
5. First 200 lines (max 25KB) loaded into agent context

## Memory Scopes

- `memory: project` - stored here, committed with repo (shared with team)
- `memory: local` - stored in `.claude/agent-memory-local/` (gitignored)
- `memory: user` - stored in `~/.claude/agent-memory/` (cross-project)
