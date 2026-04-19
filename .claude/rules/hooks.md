---
paths:
  - "hooks/**"
  - ".claude/hooks/**"
---

# Hooks System Rules

Hooks are safety gates that run before or after specific actions. They are
the immune system of the codebase - catching mistakes before they persist.
Unlike CLAUDE.md rules (which are guidance), hooks ALWAYS run - guaranteed.

## Hook Types

| Hook              | When It Fires                    | Purpose                        |
|-------------------|----------------------------------|--------------------------------|
| `PreToolUse`      | Before any tool executes         | Block dangerous operations     |
| `PostToolUse`     | After any tool completes         | Auto-lint, auto-format         |
| `SessionStart`    | When Claude Code session begins  | Load context, check env        |
| `SessionSummarize`| On context compression           | Save session summaries         |
| `PreCommit`       | Before git commit                | Run tests, lint, security scan |
| `Notification`    | On specific events               | Slack/webhook alerts           |

## Hook Configuration (in settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "scripts/pre-bash-check.sh",
          "timeout": 5
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "scripts/auto-lint.sh",
          "timeout": 10
        }]
      }
    ]
  }
}
```

## Exit Codes

- `0` -> Allow (action proceeds)
- `2` -> Block (action is stopped, user notified)
- Any other -> Block with error message

Full protocol: see `hooks/HOOKS_PROTOCOL.md`
