---
paths:
  - "io/**"
---

# I/O Channel Rules

The I/O Channel is the nervous system of the methodology. It enables
structured, traceable communication between Claude Cowork (the critical eye),
Claude Code (the executing hand), human operators, or any agent.

```
╔══════════════════════════════════════════════════════════════╗
║  I/O CHANNEL ARCHITECTURE                                    ║
║                                                              ║
║  REQUESTER (Cowork/Human)          EXECUTOR (Claude Code)   ║
║       │                                   │                  ║
║       ├── io/requests/ ──────────────────▶│                  ║
║       │                                   ├── reads request  ║
║       │                                   ├── EXECUTES       ║
║       │◀──────────────── io/results/ ─────┤                  ║
║       │                                   │                  ║
║       ├── io/signals/  ──────────────────▶│ (EMERGENCY)      ║
║       │                                   ├── STOPS + acts   ║
║       │                                   │                  ║
║       ├── io/pipelines/ ─────────────────▶│ (WORKFLOWS)      ║
║       │                                   ├── steps 1→2→3    ║
║       │                                   │                  ║
║       └── io/threads/  ◀────────────────▶│ (FOLLOW-UPS)     ║
║                                           │                  ║
║  io/status.md ◀────── LIVE DASHBOARD ────┘                  ║
╚══════════════════════════════════════════════════════════════╝
```

## Directory Structure

```
io/
├── IO_PROTOCOL.md          <- The law governing all I/O
├── status.md               <- Live dashboard (queue, signals, metrics)
├── BRIEFING_COWORK.md      <- Role instructions for Cowork
├── BRIEFING_CLAUDE_CODE.md <- Role instructions for Claude Code
├── requests/               <- Inbound requests (Cowork writes)
├── results/                <- Outbound results (Claude Code writes)
├── signals/                <- Emergency interrupts (anyone writes)
├── pipelines/              <- Multi-step chained workflows
├── threads/                <- Follow-up conversations on results
├── archive/                <- Completed pairs (auto-archived)
└── .templates/             <- Pre-built templates for each type
```

## Request Types

| Type      | Purpose                            | Example                        |
|-----------|------------------------------------|--------------------------------|
| `audit`   | Deep code inspection               | Security audit of auth module  |
| `verify`  | Confirm something works            | Verify payment flow end-to-end |
| `review`  | Code review of changes             | Review PR #42 before merge     |
| `analyze` | Performance/data analysis          | Analyze API response times     |
| `compare` | Compare two implementations        | Compare auth strategies        |
| `fix`     | Request a fix (needs user approval)| Fix XSS in search endpoint     |

## Signal Types (Emergency Channel)

| Signal     | When                              | Executor Response              |
|------------|-----------------------------------|--------------------------------|
| `halt`     | Critical bug, stop everything     | Save state, stop, respond      |
| `rollback` | Something broke, revert           | Execute rollback, verify       |
| `escalate` | Needs human decision              | Pause, document options        |
| `hotfix`   | Production broken                 | Drop everything, fix           |

## Session Integration

At every `/arib-session-start`:
- If SIGNALS exist -> process immediately before anything else
- If REQUESTS exist -> report to user, propose processing order
- If clear -> proceed with normal session protocol

Full I/O Protocol: see `io/IO_PROTOCOL.md`
Role briefings: see `io/BRIEFING_COWORK.md` and `io/BRIEFING_CLAUDE_CODE.md`
