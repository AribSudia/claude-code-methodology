---
name: arib-io
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

## Signal Type Reference with Examples

### HALT Signal
**Purpose:** Stop all work immediately due to critical issue. Diagnose and present options.

**File format:** `io/signals/halt-[description].md`

**Example content:**
```markdown
# HALT: Database Migration Conflict

Issue: Migration #47 created duplicate schema
Location: /db/migrations/047_users_table.sql
Severity: Critical
Discovered: 2026-04-19 14:30 UTC

Details:
We were running migration #45 when a second process ran #46 and #47,
creating orphaned tables. Table "users" now has duplicate definition
in two migration files.

Current state:
- Database has: users_old, users (duplicate), users_final
- Code expects: single "users" table
- Tests will fail on schema assumptions

Blocking:
- Cannot deploy until resolved
- Can't run new migrations (will compound the issue)
```

**Claude Code response:**
```markdown
# HALT RESULT: Database Migration Conflict

Status: Analyzed
Recommendation: Execute rollback path OR manual cleanup

Options (trade-offs):

Option 1: Rollback to before migration #46
- Pro: Guaranteed clean state
- Con: Loses ~2 hours of data (can be restored from backup)
- Effort: 10 minutes
- Risk: Low
- Recovery: Can re-run migrations in correct order

Option 2: Manual cleanup of duplicate schema
- Pro: Preserves recent data
- Con: Requires manual SQL, higher error risk
- Effort: 30 minutes
- Risk: High (need DBA review)
- Recovery: Need to revert and rollback if wrong

Option 3: Parallel table swap (advanced)
- Pro: Zero downtime, preserves data
- Con: Very complex, new risk vectors
- Effort: 2+ hours
- Risk: Very High (only try with expert)
- Recovery: Complex

Recommended: Option 1 (Rollback)
Reason: This is time-critical. Clean rollback is safest path.

Waiting for your decision before proceeding.
```

**Cowork decides → Claude Code executes → writes result with verification:**
```markdown
# HALT RESULT: Database Migration Conflict - RESOLVED

Status: Complete
Executed: Option 1 (Rollback)

Actions taken:
1. Stopped all services (kubernetes scale down)
2. Backed up current schema to io/backups/schema-2026-04-19-1430.sql
3. Executed rollback SQL: migration #45 (reverted #46 and #47)
4. Verified schema matches code expectations
5. Ran test suite: All 142 tests pass ✓
6. Brought services back online

Verification:
- Schema state: CORRECT (users table, correct columns, no duplicates)
- Data integrity: VERIFIED (all records intact from before conflict)
- Service health: UP (all services responding)
- Ready to re-run migrations: YES

Next step: Cowork can merge clean migration #46 and re-run in correct order.
```

### ESCALATE Signal
**Purpose:** Present options to human decision-maker. Too complex or risky for autonomous decision.

**File format:** `io/signals/escalate-[description].md`

**Example content:**
```markdown
# ESCALATE: Breaking API Change Detected

Change: /api/users response format changed
Old: { id, name, email, created_at }
New: { userId, user_name, user_email, created_on }
Impact: All clients break if we deploy this

Options:
A) Deploy breaking change (notify all clients 30 days in advance)
B) Support both formats (old and new) for 6 months (backward compatible)
C) Reject change and revert to old format
D) Create API v2, keep v1 alive indefinitely

Effort:
A) 15 minutes (release notes + PR merge)
B) 4 hours (add response transform layer)
C) 1 hour (revert commit)
D) 12 hours (create versioning layer)

Business impact varies significantly. Need product decision.
```

**Claude Code response shows trade-offs:**
```markdown
# ESCALATE RESULT: Breaking API Change Decision

Status: Pending human decision
Context: 

Option A: Breaking Change + Notification
- Timeline: Deploy immediately, notify 30 days before support ends
- Clients affected: 23 known clients, 5 unknown (monitoring needed)
- Cost to clients: Moderate (1-day engineer time each)
- Business: Faster, cleaner codebase
- Risk: Some clients may ignore notice, deploy blind

Option B: Backward Compatibility Layer
- Timeline: Deploy within 2 hours, support old format 6 months
- Clients affected: 0 (automatic compatibility)
- Cost to us: 4 hours dev now + ongoing maintenance
- Business: Slower, safer, shows respect to clients
- Risk: Technical debt from supporting two formats

Option C: Reject & Revert
- Timeline: 1 hour
- Impact: Keeps old format, loses improvements
- Cost: 4 hours of dev work wasted
- Business: Status quo, safe
- Risk: None, but misses improvement opportunity

Option D: API Versioning
- Timeline: 12 hours initially, then parallel maintenance
- Clients: Can upgrade on their schedule
- Cost to us: Higher maintenance (maintain two versions)
- Cost to clients: One-time migration effort
- Business: Professional, scalable long-term
- Risk: Complexity, but proven pattern

My assessment: Option D (Versioning) is best long-term.
This addresses both breaking change safely AND enables future improvements.
But Option B is fastest if we need to ship today.

What's the decision? (A/B/C/D or custom approach)
```

### HOTFIX Signal
**Purpose:** Critical bug affecting production. Drop everything, fix immediately, verify.

**File format:** `io/signals/hotfix-[description].md`

**Example content:**
```markdown
# HOTFIX: Security vulnerability in auth

Issue: JWT validation accepts expired tokens (30-day expiry ignored)
Affected: /api/auth/verify endpoint
Severity: Critical (CVSS 9.1)
Discovered: 2026-04-19 13:45 UTC
Time to exploit: <1 minute (already seeing suspicious activity in logs)

Fix: Check /src/auth/jwt-verify.js line 42
Expected: if (token.exp < Date.now()) throw new Error("Expired")
Actual: if (token.exp < Date.now() - 1000*60*60*24*30) throw ... (wrong math)

Immediate action required:
1. Fix the condition to: if (token.exp < Date.now()) throw
2. Revoke all tokens issued > 30 days ago
3. Force re-authentication
4. Deploy within 15 minutes
```

**Claude Code response:**
```markdown
# HOTFIX RESULT: Auth validation bug - FIXED

Status: Complete
Time elapsed: 8 minutes

Actions taken:
1. ✓ Fixed JWT expiry validation (/src/auth/jwt-verify.js:42)
   Old: if (token.exp < Date.now() - (30 * 24 * 60 * 60 * 1000))
   New: if (token.exp < Date.now())

2. ✓ Ran test suite (all tests pass)
   - auth tests: 47 pass, 0 fail
   - integration tests: 89 pass, 0 fail

3. ✓ Deployed to production
   - Built: 2026-04-19T13:53:00Z
   - Deployed: 2026-04-19T13:55:00Z
   - All services UP and responding

4. ✓ Monitored suspicious activity
   - Attempted exploits since fix: 0
   - Normal auth traffic: 1,243 req/s (expected)
   - Log anomalies: None

5. ✓ Created incident report
   - Root cause: Arithmetic error in expiry check
   - Detection: Automated log monitoring caught pattern
   - Prevention: Added unit test for edge case

Status: SAFE - vulnerability patched, no further action needed
```

### ROLLBACK Signal
**Purpose:** Revert a recent change that broke production. Execute rollback, verify stability.

**File format:** `io/signals/rollback-[description].md`

**Example content:**
```markdown
# ROLLBACK: Last commit broke checkout flow

Commit: d4a2c8f (Update payment provider integration)
Issue: 50% of checkout requests failing with "provider error"
Affected: All users attempting purchase
Revenue impact: ~$5,000/hour loss
Discovered: 2026-04-19 14:22 UTC (20 minutes after deploy)

Action: Revert to previous stable version
Previous commit: a1b2c3d (tests: improve payment test coverage)
Previous status: All tests pass, deployed 2 hours, stable

Execution:
1. Stop accepting new orders (prevent failures)
2. Revert code to commit a1b2c3d
3. Re-deploy
4. Verify checkout works
5. Resume accepting orders
```

**Claude Code response:**
```markdown
# ROLLBACK RESULT: Payment integration - REVERTED

Status: Complete
Time elapsed: 6 minutes

Actions:
1. ✓ Stopped order processing (queued: 147 pending orders)
2. ✓ Reverted code to commit a1b2c3d
3. ✓ Built and deployed to production
4. ✓ Verified checkout: Test purchase successful ($0.01 charge)
5. ✓ Resumed order processing

Verification:
- Checkout flow: Working ✓
- Payment provider connectivity: OK ✓
- Queued orders from failure window: 147 (processing now)
- Current error rate: 0% (was 50%)
- Revenue recovery: Resumed

Status: STABLE - ready for investigation of broken commit

Next: Investigate what broke in d4a2c8f so we can fix and re-deploy properly.
```

## Request Priority Sorting Algorithm

```javascript
function sortRequests(requests) {
  const priorityMap = {
    critical: 4,
    high: 3,
    normal: 2,
    low: 1
  };
  
  const severityMap = {
    security: 1.5,      // Boost security issues
    performance: 1.0,
    bug: 1.2,           // Bugs rank above features
    feature: 0.8
  };

  return requests.sort((a, b) => {
    // Primary: explicit priority
    const aPriority = priorityMap[a.priority] || 0;
    const bPriority = priorityMap[b.priority] || 0;
    
    if (aPriority !== bPriority) {
      return bPriority - aPriority;  // Higher priority first
    }

    // Secondary: issue type severity
    const aSeverity = severityMap[a.type] || 1.0;
    const bSeverity = severityMap[b.type] || 1.0;
    
    if (aSeverity !== bSeverity) {
      return bSeverity - aSeverity;  // More severe first
    }

    // Tertiary: FIFO (older requests first)
    return new Date(a.createdAt) - new Date(b.createdAt);
  });
}

// Example sort result:
// [
//   { priority: critical, type: security }    -> 4 * 1.5 = 6.0
//   { priority: critical, type: bug }         -> 4 * 1.2 = 4.8
//   { priority: high, type: security }        -> 3 * 1.5 = 4.5
//   { priority: high, type: bug }             -> 3 * 1.2 = 3.6
//   { priority: high, type: feature }         -> 3 * 0.8 = 2.4
//   { priority: normal, type: bug }           -> 2 * 1.2 = 2.4 (then FIFO)
//   { priority: low, type: feature }          -> 1 * 0.8 = 0.8
// ]
```

## Cowork ↔ Claude Code Communication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Communication Loop                     │
└─────────────────────────────────────────────────────────────┘

Claude Code Session
   │
   ├─→ [Check I/O Channel] /arib-io
   │   ├─ Read: io/signals/ ← Critical signals from Cowork
   │   ├─ Read: io/status.md ← Current state, pending work
   │   ├─ Read: io/requests/ ← Work requests from Cowork
   │   │
   │   ├─→ [SIGNALS] If any exist: STOP, diagnose, present options
   │   │   ├─ halt → Present rollback/fix options
   │   │   ├─ escalate → Present decisions with trade-offs
   │   │   ├─ hotfix → Drop everything, fix immediately
   │   │   └─ rollback → Revert and verify
   │   │
   │   ├─→ [REQUESTS] Process by priority (critical → high → normal → low)
   │   │   ├─ Read request thoroughly
   │   │   ├─ Update io/status.md: in-progress
   │   │   ├─ Execute work (audit/verify/analyze/fix)
   │   │   ├─ Write result: io/results/[name]-result.md
   │   │   └─ Update io/status.md: done
   │   │
   │   ├─→ [PIPELINES] Execute next step if active
   │   │
   │   └─→ [ARCHIVE] Move completed work >7 days old
   │
   └─→ [Update Memory] session_notes.md, project_status.md
   
   Code modifications happen → Git commits → Tests pass
   
   ↓
   
Cowork Review (human or agent)
   │
   ├─→ [Read Results] io/results/*.md
   │   ├─ Understand findings
   │   ├─ Assess quality
   │   └─ Write follow-up if needed
   │
   ├─→ [Write New Request] io/requests/[name].md
   │   ├─ Based on results
   │   ├─ Reference previous findings
   │   └─ Set priority + type
   │
   └─→ [Write Signal] io/signals/[type]-[name].md (if emergency)
   
   ↓
   
Claude Code Resumes
   └─→ /arib-io (loops back)
```

## Dashboard Update Template

**File:** `io/status.md`

```markdown
# I/O Channel Status

Updated: 2026-04-19T15:30:00Z
Session: aggressive-python-penguin

## Current Queue

| Priority | Type | Title | Status | Assigned | Due |
|----------|------|-------|--------|----------|-----|
| critical | fix | Database migration corruption | in-progress | claude-code | 2026-04-19 16:00 |
| high | audit | Security review of auth module | done | claude-code | 2026-04-19 |
| high | verify | Kubernetes deployment readiness | pending | - | 2026-04-20 |
| normal | analyze | Performance bottleneck in API | done | claude-code | 2026-04-20 |
| low | feature | Add --quiet flag to CLI | pending | - | 2026-04-25 |

## Signals (Emergencies)

| Type | Title | Status | Created | Resolved |
|------|-------|--------|---------|----------|
| halt | Database migration conflict | resolved | 14:30 | 14:45 |
| hotfix | JWT validation bug | resolved | 13:45 | 13:53 |

## Recent Completions

- ✓ Database migration conflict (halt) - Resolved via rollback - 10 minutes
- ✓ Security review of auth module (audit) - Found 3 issues - 2 hours
- ✓ Performance bottleneck analysis - Identified N+1 queries - 1.5 hours

## Metrics

- Signals this session: 2 (both resolved)
- Requests completed: 3
- Avg time to resolve signal: 8 minutes
- Avg time per request: 1.3 hours
- Requests blocked: 0
- Critical issues found: 3

## Next Steps

1. Process high-priority verification (Kubernetes readiness)
2. Implement fixes from auth audit (3 issues identified)
3. Monitor signal resolution for degradation

---
Last processed by: /arib-io
Next review: 2026-04-19T16:30:00Z
```

## Archive Management Rules

**When to archive:**
- Request + Result pair is >7 days old AND status = "done"
- Signals with status = "resolved" AND >30 days old
- Archived work is read-only (for historical reference)

**Archive structure:**
```
io/
├─ requests/           (active work)
├─ results/            (active results)
├─ signals/            (active signals)
└─ archive/
   ├─ 2026-04/
   │  ├─ req-audit-api-2026-04-10.md
   │  ├─ req-audit-api-2026-04-10-result.md
   │  ├─ sig-halt-migration-2026-04-12.md
   │  └─ sig-halt-migration-2026-04-12-result.md
   │
   └─ 2026-03/
      ├─ req-*.md
      └─ sig-*.md
```

**Archive rules:**
- Keep 2 months of history accessible
- Move older archive to `archive/old/` folder
- Update `ARCHIVE_INDEX.md` with summary
- Never delete signals (they're incident records)

## Complete I/O Cycle Example

### Step 1: Cowork writes a request
**File:** `io/requests/audit-checkout-flow-2026-04-19.md`
```markdown
# Audit Request: Checkout Flow

Type: audit
Priority: high
Requested by: Cowork (payment-audit task)
Created: 2026-04-19T14:00:00Z

## Scope
Audit the checkout flow for:
1. Security vulnerabilities
2. Data validation completeness
3. Error handling robustness
4. PCI compliance (if applicable)

## Files to Review
- /src/payments/checkout.js
- /src/payments/validators.js
- /src/payments/error-handler.js
- /tests/payments/*.test.js

## Checklist
- [ ] No hardcoded API keys or secrets
- [ ] All user inputs validated
- [ ] CORS headers correct
- [ ] Rate limiting in place
- [ ] Error messages don't leak sensitive info
- [ ] Transaction logging for compliance
- [ ] All tests passing
- [ ] No deprecated libraries used

## Expected Outcome
Report findings by severity (critical/high/medium/low) with recommendations.
```

### Step 2: Claude Code processes the request
**In session, runs:** `/arib-io`

- Reads the request
- Updates `io/status.md` → `in-progress`
- Reads the specified files
- Runs checklist against code
- Writes detailed findings

### Step 3: Claude Code writes the result
**File:** `io/results/audit-checkout-flow-2026-04-19-result.md`
```markdown
# Audit Result: Checkout Flow

Request ID: audit-checkout-flow-2026-04-19
Status: complete
Audited by: Claude Code
Completed: 2026-04-19T16:30:00Z
Effort: 2.5 hours

## Summary
Checkout flow is mostly secure with 2 critical issues and 3 recommendations.

## Findings by Severity

### CRITICAL (2)
1. **Hardcoded API key in env.js**
   - File: /src/payments/error-handler.js, line 5
   - Issue: STRIPE_SECRET_KEY visible in error messages
   - Risk: Attackers can see key in logs/monitoring
   - Fix: Mask keys in error output, use env variables only
   - Effort: 15 minutes

2. **Missing rate limiting on /checkout endpoint**
   - File: /src/payments/checkout.js, line 1
   - Issue: No rate limit, allows brute force / spam
   - Risk: DDoS attack, credit card enumeration
   - Fix: Add rate limiter (max 10 attempts/minute/IP)
   - Effort: 20 minutes

### HIGH (1)
1. **Error messages leak user ID**
   - File: /src/payments/error-handler.js, line 23
   - Issue: "Order xyz-456 failed" shows order ID to attacker
   - Risk: Enumerate valid orders, target specific users
   - Fix: Return generic error to client, log details server-side
   - Effort: 30 minutes

### MEDIUM (2)
1. **CORS allows any origin**
   - File: /src/server.js, line 45
   - Issue: cors({ origin: '*' }) allows cross-origin checkout
   - Risk: Third-party sites could trigger payments
   - Fix: Whitelist specific origins (your frontend domains)
   - Effort: 10 minutes

2. **Incomplete input validation**
   - File: /src/payments/validators.js, line 12
   - Issue: Email regex is too permissive
   - Risk: Invalid emails stored, payment failures
   - Fix: Use RFC 5322 validator or proven library
   - Effort: 10 minutes

## Checklist Results
- [✓] No hardcoded API keys (FAILED - see above)
- [✓] All user inputs validated (PARTIAL - regex issue)
- [✓] CORS headers correct (FAILED - allows any origin)
- [✓] Rate limiting in place (FAILED)
- [✓] Error messages don't leak info (FAILED)
- [✓] Transaction logging present (PASS)
- [✓] All tests passing (PASS - 47 tests)
- [✓] No deprecated libraries (PASS)

## Recommendations (Priority Order)
1. Fix critical issues: API key masking, rate limiting (1 hour)
2. Fix high issue: Error message leakage (30 min)
3. Fix medium issues: CORS, validators (20 min)
4. Add integration tests for new rate limiter
5. Run security scan against payment libraries (snyk/audit)

## Timeline
- Critical: Fix by end of day (before next production push)
- High: Fix within 24 hours
- Medium: Fix within 1 week
- Before next payment-related release: All fixed

Next: Cowork decides whether to proceed, or writes hotfix signal if urgent.
```

### Step 4: Cowork reads result and acts
- If urgent → Write `io/signals/hotfix-...md`
- If needs clarification → Write follow-up in `io/threads/`
- If ready to fix → Assigns developer, they work on code
- Code is committed, tested, deployed
- Cowork writes new request to verify fixes

## Important Rules
- Signals ALWAYS come first, before any request processing
- Never write request files (that is Cowork's exclusive territory)
- Never execute a fix unless the request type is explicitly "fix"
- Always update io/status.md within 60 seconds of any state change
- Always include exact file paths and line numbers in results
- Be honest in results - no sugarcoating findings
- If a request is unclear, set status to "blocked" and explain what you need
- Archive completed work >7 days old (monthly cleanup)
- Signal results are incident records (never delete)

## Related Skills
- `/arib-session-start` - Checks I/O channel at session start
- `/arib-docs-api` - Document API changes discovered during audits
- `/review` - Code review alongside I/O requests

## Notes
- This command should be run whenever Cowork has written new requests
- It can also be run at session start to check the I/O channel status
- The /arib-session-start command already checks I/O as part of its protocol
- This command provides deeper I/O processing beyond the basic session check
- I/O channel is the bridge between human oversight and autonomous execution
- Signals represent emergencies that must be handled immediately
- Requests represent planned work with clear scope and success criteria
- Results are the deliverable that Cowork uses to make decisions
- Dashboard (io/status.md) is the single source of truth for queue status
