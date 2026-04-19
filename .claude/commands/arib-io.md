---
description: Session | I/O Channel - check signals, process requests from Cowork, write results, update dashboard
---

# /arib-io Command

## Purpose
Process the I/O Channel - the communication bridge between Claude Cowork (the critical eye) and Claude Code (the executing hand). Check for emergencies, read pending requests, execute work, write results, and keep the dashboard updated.

## Trigger
User types `/arib-io`

## Instructions

### Step 0: Read the Protocol
Read `io/IO_PROTOCOL.md` to understand the full I/O channel rules.

### Step 1: Check Signals (EMERGENCY - always first)
```bash
ls io/signals/ 2>/dev/null
```

If any signal files exist:
- **STOP all other work immediately**
- Read every signal file
- Process by type:
  - `halt` - Save state, diagnose the issue, recommend action (rollback or fix), WAIT for human decision
  - `escalate` - Present options with trade-offs, WAIT for human choice
  - `hotfix` - Drop everything, implement the fix immediately, verify it works
  - `rollback` - Execute the rollback, verify system is stable
- Write signal result in `io/signals/` with `-result` suffix
- Update `io/status.md` with signal status
- Only proceed to Step 2 after ALL signals are resolved

If no signals exist, proceed to Step 2.

### Step 2: Read the Dashboard
Read `io/status.md` to understand the current state:
- What requests are pending?
- What was recently completed?
- Any blocked items?
- Current metrics

### Step 3: Scan for Pending Requests
```bash
ls io/requests/ 2>/dev/null
```

For each request file found, check if it has been processed already (look for matching result in `io/results/`).

Sort pending requests by priority:
1. `critical` (process immediately)
2. `high` (process this session)
3. `normal` (process if time allows)
4. `low` (can wait)

If no pending requests exist:
- Report "I/O Channel is clear - no pending requests"
- Show recent completions from `io/status.md`
- Ask user if they want to check anything specific

### Step 4: Report Queue to User
Before processing, present the queue:

```
I/O Channel Status:
  Signals:  [count] (0 = clear)
  Pending:  [count] requests
  Queue:
    1. [priority] [type] - [title] (from [filename])
    2. [priority] [type] - [title] (from [filename])
    ...

Shall I process these in order, or do you want to pick specific ones?
```

Wait for user confirmation before processing.

### Step 5: Process Each Request
For each approved request, follow this exact workflow:

**5.1 - Read the request thoroughly**
- Understand the type (audit/verify/review/analyze/compare/fix)
- Understand the scope (which files, line numbers)
- Understand what "done" looks like (the checklist)
- Note any dependencies or related context

**5.2 - Update status to in-progress**
In `io/status.md`, mark this request as `in-progress` with timestamp.

**5.3 - Execute the work**
Based on request type:
- **audit** - Read the specified code, check against the audit checklist, report findings by severity
- **verify** - Run the specified checks/tests, confirm or deny what was asked
- **review** - Review the code for issues, improvements, and risks
- **analyze** - Study the specified code/data, explain how it works
- **compare** - Side-by-side analysis of two implementations
- **fix** - Implement the fix, run tests, verify it works (ONLY if type=fix was explicitly requested)

**5.4 - Write the result**
Create result file in `io/results/` with the SAME filename + `-result` suffix.

Result must include:
- Request ID reference
- Status: complete | partial | blocked
- Summary (honest, no sugarcoating)
- Findings organized by severity (Critical > High > Medium > Low)
- Exact file paths and line numbers for every finding
- Specific actionable recommendations
- Checklist verification (which items passed/failed)

**5.5 - Update status to done**
In `io/status.md`, mark as `done` with completion timestamp.

**5.6 - Update memory**
If relevant, update:
- `memory/change_log.md` (if code was changed)
- `memory/session_notes.md` (what was done)
- `memory/bugs_and_fixes.md` (if bugs were found)

### Step 6: Check for Pipelines
```bash
ls io/pipelines/ 2>/dev/null
```

If active pipelines exist:
- Read pipeline file
- Identify which step is next
- Execute it as a request (follow Step 5 workflow)
- Update pipeline file with step status
- If step finds a critical issue, pause pipeline and report

### Step 7: Check Threads
```bash
ls io/threads/ 2>/dev/null
```

If follow-up threads exist with unanswered questions:
- Read the thread
- Write a response follow-up file
- Reference the original finding

### Step 8: Archive Completed Work
For any request-result pairs older than 7 days with status `done`:
```bash
# Move to monthly archive folder
mkdir -p io/archive/$(date +%Y-%m)
mv io/requests/[completed-file] io/archive/$(date +%Y-%m)/
mv io/results/[completed-result] io/archive/$(date +%Y-%m)/
```

### Step 9: Final Report
Present summary to user:

```
I/O Processing Complete:
  Processed:  [count] requests
  Signals:    [count] handled
  Findings:   [critical] critical, [high] high, [medium] medium
  Archived:   [count] old pairs

  Results written:
    - io/results/[filename-1]
    - io/results/[filename-2]

  Cowork can read the results and write follow-ups.
  Next: Cowork reviews results and writes new requests if needed.
```

## Important Rules
- Signals ALWAYS come first, before any request processing
- Never write request files (that is Cowork's exclusive territory)
- Never execute a fix unless the request type is explicitly "fix"
- Always update io/status.md within 60 seconds of any state change
- Always include exact file paths and line numbers in results
- Be honest in results - no sugarcoating findings
- If a request is unclear, set status to "blocked" and explain what you need

## Notes
- This command should be run whenever Cowork has written new requests
- It can also be run at session start to check the I/O channel status
- The /arib-session-start command already checks I/O as part of its protocol
- This command provides deeper I/O processing beyond the basic session check
