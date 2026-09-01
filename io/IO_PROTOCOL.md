# I/O Channel Protocol — Inter-Agent Communication System

> **Purpose**: The I/O Channel is the nervous system of the Claude Code Methodology.
> It enables structured, traceable, asynchronous communication between any two
> agents — Claude Cowork (the critical eye), Claude Code (the executing hand),
> human operators, CI/CD systems, or any future agent that joins the project.
>
> **Rule #1**: All inter-agent communication passes through `io/`. No exceptions.
> **Rule #2**: Every request gets a result. Every result references its request.
> **Rule #3**: The dashboard (`status.md`) is the single source of truth for I/O state.
>
> **Sibling channel**: `io/PLAN_MESH.md` describes the *plan mesh* — the shared
> task graph and inter-session channel behind `/arib-plan` and `scripts/ccm-plan.sh`
> (ADR-039). Requests/results coordinate *agents*; the mesh coordinates *tasks*.

---

## 1. Architecture Overview

```
io/                                    ← The Communication Nerve Center
│
├── IO_PROTOCOL.md                     ← YOU ARE HERE — the law
├── status.md                          ← LIVE DASHBOARD — queue + metrics
│
├── requests/                          ← INBOUND — requests waiting for execution
│   └── [type]-[scope]-[date]-[seq].md
│
├── results/                           ← OUTBOUND — completed execution results
│   └── [type]-[scope]-[date]-[seq]-result.md
│
├── signals/                           ← INTERRUPTS — emergency / escalation / pause
│   └── [signal-type]-[date]-[seq].md
│
├── pipelines/                         ← WORKFLOWS — chained multi-step operations
│   └── [pipeline-name]-[date].md
│
├── threads/                           ← FOLLOW-UPS — conversations on results
│   └── [request-id]/
│       ├── follow-up-001.md
│       └── follow-up-002.md
│
├── archive/                           ← HISTORY — completed request+result pairs
│   └── [YYYY-MM]/
│       ├── [request].md
│       └── [result].md
│
└── .templates/                        ← TEMPLATES — pre-built request types
    ├── audit.md
    ├── verify.md
    ├── review.md
    ├── analyze.md
    ├── compare.md
    ├── fix.md
    ├── pipeline.md
    └── signal.md
```

---

## 2. The Communication Model

### 2.1 — Roles

| Role              | Identity            | Can Read          | Can Write               |
|-------------------|---------------------|-------------------|-------------------------|
| **Requester**     | Cowork / Human / CI | results/, status  | requests/, signals/     |
| **Executor**      | Claude Code         | requests/, signals| results/, status, code  |
| **Observer**      | Any agent           | everything in io/ | threads/ only           |

### 2.2 — The Request-Result Loop

```
REQUESTER                              EXECUTOR
    │                                      │
    ├─── writes request ──────────────────▶│
    │    (io/requests/)                    │
    │                                      ├─── reads request
    │                                      ├─── updates status → in-progress
    │                                      ├─── EXECUTES the work
    │                                      ├─── writes result
    │                                      │    (io/results/)
    │◀──────────────────── updates status ─┤
    │                      → done          │
    ├─── reads result                      │
    │                                      │
    ├─── (optional) writes follow-up ─────▶│
    │    (io/threads/[req-id]/)            │
    │                                      ├─── reads follow-up
    │                                      ├─── writes follow-up response
    │◀─────────────────────────────────────┤
    │                                      │
    └─── RESOLVED                          └─── ARCHIVED
```

### 2.3 — Signal Override (Emergency Channel)

```
ANY AGENT                              EXECUTOR
    │                                      │
    ├─── writes SIGNAL ───────────────────▶│
    │    (io/signals/)                     │
    │    priority: CRITICAL                │
    │                                      ├─── STOPS current work
    │                                      ├─── reads signal
    │                                      ├─── executes signal action
    │                                      ├─── writes signal result
    │◀─────────────────────────────────────┤
    │                                      │
    └─── Signal resolved                   └─── Resumes previous work
```

---

## 3. Naming Conventions

### 3.1 — Request Files

```
io/requests/[type]-[scope]-[YYYY-MM-DD]-[seq].md
```

| Component | Values                                         | Example                |
|-----------|-------------------------------------------------|------------------------|
| type      | audit, verify, review, analyze, compare, fix    | audit                  |
| scope     | module name, feature, file, layer               | user-auth              |
| date      | ISO date                                        | 2026-04-17             |
| seq       | 3-digit sequence (per day)                      | 001                    |

**Full example**: `audit-user-auth-2026-04-17-001.md`

### 3.2 — Result Files

```
io/results/[type]-[scope]-[YYYY-MM-DD]-[seq]-result.md
```

**Must exactly mirror** the request filename + `-result` suffix.

### 3.3 — Signal Files

```
io/signals/[signal-type]-[YYYY-MM-DD]-[seq].md
```

Signal types: `halt`, `rollback`, `escalate`, `hotfix`, `revert`, `pause`, `resume`

### 3.4 — Pipeline Files

```
io/pipelines/[pipeline-name]-[YYYY-MM-DD].md
```

### 3.5 — Thread Files

```
io/threads/REQ-[YYYY-MM-DD]-[seq]/follow-up-[NNN].md
```

---

## 4. Request Types & When to Use Each

| Type        | Purpose                                            | Executor Action                    |
|-------------|----------------------------------------------------|------------------------------------|
| `audit`     | Deep inspection of code quality, security, patterns| Read + analyze + report findings   |
| `verify`    | Confirm something works as expected                | Run tests + check behavior         |
| `review`    | Code review of specific changes or modules         | Review + grade + recommend         |
| `analyze`   | Data analysis, performance profiling, pattern study| Measure + profile + report         |
| `compare`   | Compare two versions, approaches, or implementations| Side-by-side analysis + recommend |
| `fix`       | Apply a specific fix (requires explicit user approval)| Implement + test + document     |

---

## 5. Priority System

| Priority    | SLA (Response Time) | Signal Allowed | Queue Position |
|-------------|---------------------|----------------|----------------|
| `critical`  | Immediate           | Yes            | Top of queue   |
| `high`      | Same session        | Yes            | After critical |
| `medium`    | Next session         | No             | After high     |
| `low`       | When convenient      | No             | After medium   |

### Priority Escalation Rules

- If a `medium` request is not addressed within 2 sessions → auto-escalates to `high`
- If a `high` request is not addressed within 1 session → auto-escalates to `critical`
- `critical` requests trigger a signal if not picked up within 30 minutes

---

## 6. Status Flow

```
pending ──▶ in-progress ──▶ done
                │               │
                ├──▶ blocked    ├──▶ archived
                │               │
                └──▶ partial    └──▶ follow-up-needed
```

| Status              | Meaning                                                |
|---------------------|--------------------------------------------------------|
| `pending`           | Request written, waiting for executor to pick up       |
| `in-progress`       | Executor is actively working on this request           |
| `done`              | Result written, request fully answered                 |
| `partial`           | Some items completed, others need more info            |
| `blocked`           | Cannot proceed — clarification needed                  |
| `follow-up-needed`  | Result written but requester has follow-up questions   |
| `archived`          | Completed and moved to archive                         |

---

## 7. The Dashboard: `status.md`

The `status.md` file is the **live control panel** for all I/O activity.
It is updated by the executor after every state change.

### Dashboard Sections

1. **Active Queue** — currently pending and in-progress requests
2. **Signal Board** — any active signals (emergencies)
3. **Active Pipelines** — multi-step workflows in progress
4. **Recent Completions** — last 5 completed request-result pairs
5. **Metrics** — request volume, resolution rate, average response time

See `status.md` for the live dashboard.

---

## 8. Pipelines — Chained Workflows

A pipeline is a sequence of requests that execute in order, where each
step's result feeds into the next step's context.

### When to Use Pipelines

- Pre-release audit (security → tests → performance → deploy-check)
- Feature validation (code review → test coverage → E2E → accessibility)
- Reengineering scan (structure → entities → routes → auth → health report)
- Incident response (diagnose → fix → verify → post-mortem)

### Pipeline Execution Rules

1. Steps execute sequentially (step N must complete before step N+1)
2. If any step produces a `critical` finding → pipeline pauses
3. If any step is `blocked` → pipeline pauses, signal sent
4. Each step creates its own request-result pair
5. Pipeline file tracks overall progress

See `io/.templates/pipeline.md` for the pipeline template.

---

## 9. Threads — Follow-Up Conversations

When a result needs discussion, don't create a new request. Instead,
create a thread on the existing request.

### Thread Rules

- Thread folder: `io/threads/REQ-[YYYY-MM-DD]-[seq]/`
- Follow-up files numbered sequentially: `follow-up-001.md`, `follow-up-002.md`
- Each follow-up has: question + context + which finding it references
- Executor responds by adding the next numbered follow-up
- When resolved, final follow-up marks thread as `resolved`

---

## 10. Signals — Emergency Channel

Signals override the normal queue. They are for situations that require
immediate attention.

| Signal     | When to Use                                        | Executor Response          |
|------------|----------------------------------------------------|----------------------------|
| `halt`     | Stop all work immediately (critical bug found)     | Save state, stop, respond  |
| `rollback` | Revert last change (something broke)               | Execute rollback, verify   |
| `escalate` | Needs human decision (ambiguity, risk)             | Pause, document options    |
| `hotfix`   | Production is broken, fix urgently                 | Drop everything, fix       |
| `revert`   | Undo specific commit or change                     | Revert, test, document     |
| `pause`    | Temporarily pause current work                     | Save state, wait           |
| `resume`   | Resume after a pause                               | Restore state, continue    |

### Signal Priority

Signals ALWAYS take priority over regular requests.
Multiple signals are processed in order received (FIFO).

---

## 11. Archival Rules

### When to Archive

- Request status is `done` AND result has been read by requester
- Request is older than 7 days and status is `done`
- Manual archive trigger by any agent

### Archive Structure

```
io/archive/
└── 2026-04/
    ├── audit-user-auth-2026-04-17-001.md          ← request
    ├── audit-user-auth-2026-04-17-001-result.md   ← result
    └── REQ-2026-04-17-001/                        ← thread (if any)
        ├── follow-up-001.md
        └── follow-up-002.md
```

### Archive Rules

- Archived files are **read-only** — never modify after archival
- Archive serves as **institutional memory** — searchable history
- Monthly folders keep things organized
- Run `scripts/io-archive.sh` to auto-archive completed requests

---

## 12. Integration with Methodology

### How I/O Connects to the 4-Layer Architecture

| Layer      | I/O Integration                                          |
|------------|----------------------------------------------------------|
| L1 (CLAUDE.md) | Session protocol references I/O check at start     |
| L2 (Skills)    | Skills can auto-generate requests (e.g., security audit)|
| L3 (Hooks)     | `session-start.sh` reads `io/signals/` at session start; the Stop hook writes the ledger. NOTE: hooks do **not** continuously watch signals or pre-empt a running tool call — Claude Code hooks fire on events (PreToolUse/Stop/etc.), not on a filesystem watch. Mid-session pre-emption requires a push transport (CoWork/webhook), not the filesystem channel. |
| L4 (Agents)    | Agents are both requesters and executors            |

### How I/O Connects to Memory

| Memory File               | I/O Updates It When                       |
|---------------------------|-------------------------------------------|
| memory/change_log.md      | A `fix` request is completed              |
| memory/bugs_and_fixes.md  | An `audit` finds bugs                     |
| memory/testing_log.md     | A `verify` runs tests                     |
| memory/session_notes.md   | Any I/O activity during a session         |
| memory/project_status.md  | A pipeline completes or signal is raised  |

---

## 13. Security & Access Control

### Read/Write Matrix

| Path                | Cowork | Claude Code | Human | CI/CD |
|---------------------|--------|-------------|-------|-------|
| io/requests/        | RW     | R           | RW    | RW    |
| io/results/         | R      | RW          | R     | R     |
| io/signals/         | RW     | RW          | RW    | RW    |
| io/pipelines/       | RW     | RW          | RW    | R     |
| io/threads/         | RW     | RW          | RW    | —     |
| io/status.md        | R      | RW          | R     | R     |
| io/archive/         | R      | R           | R     | R     |
| io/.templates/      | R      | R           | R     | R     |

### Integrity Rules

- Result files must reference a valid request ID
- Signals must include a reason and sender identity
- Pipeline steps must reference existing request types
- Thread follow-ups must reference a valid finding number
- Status.md must be updated within 60 seconds of any state change

---

## Transport + Ledger Split (v3.2 — Item #4)

The original I/O Channel (sections above) used the filesystem for both
**transport** (inter-agent message-passing) and **audit** (the historical
record). Polling-based transport is slow and cannot pre-empt a running tool
call. v3.2 separates the two concerns.

### Transport — push-based (configurable)

```
transport: cowork | webhook | mcp-server | filesystem
```

| Transport | When to use | How |
|-----------|-------------|-----|
| `cowork` (preferred when configured) | Production multi-agent runs | `cowork` MCP in `.mcp.json`; set `COWORK_TOKEN` |
| `webhook` | Lightweight push without an MCP | Set `CCM_NOTIFY_WEBHOOK` to any HTTPS endpoint |
| `mcp-server` | Custom MCP transport | Wire your server in `.mcp.json` and set `CCM_TRANSPORT=mcp-server` |
| `filesystem` (default fallback) | Solo work, offline, or no MCP available | The `io/requests/` ↔ `io/results/` flow remains as today |

The session-start hook detects which transports are reachable. The pre-tool-use
and stop hooks honor `notify_cowork` (`.claude/hooks/lib/common.sh`); to use a
generic webhook instead, set `CCM_COWORK_WEBHOOK` to your endpoint.

### Ledger — `io/` as immutable record

Regardless of transport, every session-end writes a markdown ledger entry to
`io/ledger/session-<ts>.md` (this already ships in v3.2 Item A). When push
transport is configured, the ledger also captures **who pushed what when** so
the audit trail is complete:

```text
io/ledger/session-<ts>.md
  - branch, start_sha, end_sha, files_changed
  - transport: <cowork|webhook|filesystem>
  - notifications_sent: [event, ts]...
  - notifications_received: [from, event, ts]...
```

### Notification routing (Notification hook)

The optional `Notification` hook can route push events into any chat surface
so the human stays informed while away from the session. Recommended channels:

- **Slack / Discord / Telegram** — incoming-webhook URL via `CCM_NOTIFY_WEBHOOK`.
- **WhatsApp Business** — via the standard Cloud API; the same webhook env var.
- **Email** — via any SMTP relay; not recommended for per-tool-call signals
  (too noisy) — only for session-end and BLOCK events.

Routing is **opt-in**. Empty env var = silent. The Notification hook does not
ship with a default endpoint; this is deliberate so CCM never leaks anything
to a third party without explicit configuration.

### Failure semantics

- If push transport is configured but unreachable, the hooks degrade to
  filesystem mode and log the failure. They do not retry indefinitely.
- The ledger is written regardless. Audit trail survives transport failure.
- If both push and filesystem fail (extreme — disk full or permission lost),
  the hooks return a clear error to the user. They never silently drop.

---

> **End of I/O Protocol**
> The I/O Channel is the nervous system. Keep it clean, keep it honest, keep it flowing.
