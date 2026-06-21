---
paths:
  - "hooks/**"
  - ".claude/hooks/**"
---

# Hooks System Rules

Hooks are safety gates that run before or after specific actions. They are
the immune system of the codebase - catching mistakes before they persist.
Unlike CLAUDE.md rules (which are guidance), hooks ALWAYS run - guaranteed.

## Hook Events (as actually wired in settings.json)

| Event              | When It Fires                    | CCM uses it for                       |
|--------------------|----------------------------------|---------------------------------------|
| `SessionStart`     | Session begins                   | Context load, CLAUDE.md drift check    |
| `UserPromptSubmit` | User submits a prompt            | Invocation telemetry (`/arib-*`). stdout is INJECTED into context — telemetry hooks must stay silent |
| `PreToolUse`       | Before a tool executes           | Block secrets / dangerous bash / OWASP / path scoping / wave gate; autonomy guard. **Plus one advisory (v3.19.0):** `graph-consult.sh` on `Grep`/`Glob` surfaces a code-graph navigation hint — exit 0 always, no-op when the graph is absent, NEVER blocks |
| `PostToolUse`      | After a tool completes           | **Advisory only (v3.18.0)** — `compress-output.sh` (rtk-eligible Bash) + `ponytail-lite.sh` (over-engineering tripwire on edits). Exit 0 always; NEVER blocks (the blocking gate is `PreToolUse`) |
| `Stop`             | Claude finishes responding       | Session-end bookkeeping                |
| `Notification`     | Claude Code notifications        | Webhook fan-out                        |

Git's own `pre-commit` hook (installed by `scripts/install-hooks.sh`) guards
commits — it is a git hook, not a Claude Code event.

## Hook Configuration (in settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|Bash",
        "hooks": [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.sh",
          "timeout": 10
        }]
      }
    ]
  }
}
```

The payload arrives on stdin as JSON with snake_case keys:
`.tool_name`, `.tool_input.command` (Bash), `.tool_input.file_path` /
`.tool_input.content` / `.tool_input.new_string` / `.tool_input.edits[]`
(Write/Edit/MultiEdit).

## Exit Codes (the real contract)

- `0` -> Allow (action proceeds)
- `2` -> BLOCK (action stopped; stderr is fed back to Claude)
- Any other non-zero -> NON-blocking error (shown, but the tool call PROCEEDS)

Only exit 2 blocks. A hook that "fails" with exit 1 has silently allowed
the action — this is why CCM gates fail CLOSED (see pre-tool-use.sh).

Full protocol: see `hooks/HOOKS_PROTOCOL.md`
