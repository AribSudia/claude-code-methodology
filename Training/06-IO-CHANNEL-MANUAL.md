# Claude Code Methodology v2.6.0 — I/O Channel System Manual

## Structured Inter-Agent Communication Architecture

A complete reference for the I/O Channel system: directory structure, request types, signal protocols, pipelines, threads, role briefings, and real-world workflows.

---

## Section 1: What is the I/O Channel?

### Overview

The I/O Channel is the "nervous system" connecting multiple agents in a coordinated development workflow. It enables:

- **Cowork (Human/Manager)** to assign work to **Claude Code (Executor)**
- **Claude Code** to report findings, request reviews, signal emergencies
- **Bidirectional requests and responses** with structured format
- **Queue management** with priority, SLA, and auto-escalation
- **Follow-up conversations** on specific findings (threads)
- **Audit trail** of all communications (archive)

### Key Characteristics

- **Structured**: Every request/response follows strict format
- **Asynchronous**: Requestor and executor don't wait for immediate response
- **Transparent**: All communications logged for compliance/audit
- **Prioritized**: Critical issues escalated automatically
- **Extensible**: New request types and signal types can be added

### System Actors

| Actor | Role | Reads | Writes |
|-------|------|-------|--------|
| **Cowork (Human Manager)** | Initiates work, reviews results, gives signals | results/, signals/, status.md | requests/, signals/ |
| **Claude Code (AI Executor)** | Executes requests, reports findings | requests/, signals/, status.md | results/, signals/, threads/, status.md |
| **Archive System** | Stores completed communications | (all) | archive/ |
| **Dashboard** | Displays queue and metrics | requests/, results/, signals/, status.md | status.md (updates) |

---

## Section 2: Directory Structure

### Complete io/ Layout

```
project-root/
├── io/
│   ├── requests/                    # Incoming work requests
│   │   ├── audit-auth-2026-04-18-001.md
│   │   ├── review-dashboard-2026-04-18-002.md
│   │   └── [type]-[target]-[date]-[seq].md
│   │
│   ├── results/                     # Findings from executed requests
│   │   ├── audit-auth-2026-04-18-001.md
│   │   ├── review-dashboard-2026-04-18-002.md
│   │   └── [matches request names]
│   │
│   ├── signals/                     # Emergency notifications (halt, rollback, etc.)
│   │   ├── HALT-2026-04-18T15:30:00Z.md
│   │   ├── ROLLBACK-2026-04-18T16:00:00Z.md
│   │   └── [signal-type]-[timestamp].md
│   │
│   ├── pipelines/                   # Multi-step workflows
│   │   ├── pre-release-2026-04-18.md
│   │   ├── security-audit-cycle-2026-Q2.md
│   │   └── [pipeline-name]-[identifier].md
│   │
│   ├── threads/                     # Follow-up discussions on findings
│   │   ├── audit-auth-2026-04-18-001-thread.md
│   │   ├── review-dashboard-2026-04-18-002-thread.md
│   │   └── [request-name]-thread.md
│   │
│   ├── archive/                     # Completed communications (timestamped)
│   │   ├── 2026-04-15/
│   │   │   ├── audit-components-2026-04-15-001.md
│   │   │   └── ...
│   │   ├── 2026-04-16/
│   │   └── [YYYY-MM-DD]/
│   │
│   ├── .templates/                  # Pre-built request/result templates
│   │   ├── TEMPLATE_AUDIT.md
│   │   ├── TEMPLATE_VERIFY.md
│   │   ├── TEMPLATE_REVIEW.md
│   │   ├── TEMPLATE_ANALYZE.md
│   │   ├── TEMPLATE_COMPARE.md
│   │   ├── TEMPLATE_FIX.md
│   │   ├── BRIEFING_COWORK.md
│   │   ├── BRIEFING_CLAUDE_CODE.md
│   │   └── SIGNAL_TEMPLATE.md
│   │
│   ├── status.md                    # Live dashboard (queue, signals, metrics)
│   │
│   └── .access                      # Access control matrix (JSON)
│       └── permissions.json
```

---

## Section 3: Request Types (6 Types)

### 1. AUDIT Request

**Purpose**: Comprehensive scan for issues, compliance violations, security problems.

**Naming**: `audit-[target]-[date]-[seq].md`

**Example**: `audit-auth-2026-04-18-001.md`

**Template Content**:

```markdown
# AUDIT Request: [Target] — [Date]

## Request ID
audit-auth-2026-04-18-001

## Priority
CRITICAL | HIGH | MEDIUM | LOW

## Target
- Component: src/services/auth.ts
- Scope: Security, code quality, test coverage
- Include: Type validation, XSS prevention, CSRF protection

## Acceptance Criteria
- [] Identify all security vulnerabilities
- [] Report code quality issues
- [] Check test coverage (target: 80%+)
- [] Provide severity classification

## Notes
Previous session found N+1 in password reset. Verify if still present.

## Due
2026-04-18T18:00:00Z

## Requested By
john.manager@acme.com
```

### 2. VERIFY Request

**Purpose**: Confirm specific conditions are met (requirements, constraints, environment).

**Naming**: `verify-[target]-[date]-[seq].md`

**Example**: `verify-migration-safety-2026-04-18-001.md`

**Template Content**:

```markdown
# VERIFY Request: [Target] — [Date]

## Request ID
verify-migration-safety-2026-04-18-001

## Priority
CRITICAL | HIGH | MEDIUM | LOW

## Conditions to Verify
- [] Database migration is reversible (rollback works)
- [] No data loss risk
- [] Locks do not exceed 30 seconds
- [] Backward compatibility maintained
- [] All tests passing after migration

## Target
db/migrations/2026-04-18-001-add-audit-log.js

## Success Definition
Migration can be applied and rolled back without issue.
No data loss, latency acceptable, all safety checks pass.

## Due
2026-04-18T16:00:00Z
```

### 3. REVIEW Request

**Purpose**: Code review with quality gates, security checks, naming validation.

**Naming**: `review-[target]-[date]-[seq].md`

**Example**: `review-dashboard-2026-04-18-002.md`

### 4. ANALYZE Request

**Purpose**: Deep analysis of system behavior, performance, design trade-offs.

**Naming**: `analyze-[target]-[date]-[seq].md`

**Example**: `analyze-perf-bottlenecks-2026-04-18-001.md`

### 5. COMPARE Request

**Purpose**: Comparative analysis (versions, approaches, implementations).

**Naming**: `compare-[subject]-[date]-[seq].md`

**Example**: `compare-auth-strategies-2026-04-18-001.md`

### 6. FIX Request

**Purpose**: Implement a specific fix or solution.

**Naming**: `fix-[issue]-[date]-[seq].md`

**Example**: `fix-modal-zindex-2026-04-18-001.md`

---

## Section 4: Result Format

Results are placed in `results/` directory with matching name to request.

### Result Structure

```markdown
# RESULT: [Request ID]

## Summary
[1-2 sentence executive summary]

## Findings by Severity

### CRITICAL (0 findings)
None

### HIGH (2 findings)
1. Finding: [Description]
   Location: src/file.ts:42
   Impact: [What breaks/what's at risk]
   Fix: [Recommended fix]
   
2. Finding: [Description]
   ...

### MEDIUM (3 findings)
[Same format]

### LOW (1 finding)
[Same format]

## Recommendations
1. [Action] — Estimated effort: [X hours]
2. [Action] — Estimated effort: [X hours]

## Metadata
- **Requested By**: john.manager@acme.com
- **Executed By**: claude-code@methodology.local
- **Started**: 2026-04-18T16:00:00Z
- **Completed**: 2026-04-18T16:45:00Z
- **Status**: COMPLETE | IN_PROGRESS | BLOCKED
- **Related Requests**: audit-auth-2026-04-18-001

## Code References
[Links to specific files/lines that are relevant to findings]
```

### Example Complete Result

```markdown
# RESULT: audit-auth-2026-04-18-001

## Summary
Auth service has 1 critical security issue (hardcoded test credentials), 
2 medium issues (missing error handling), and 7 low issues (naming/style).

## Findings by Severity

### CRITICAL (1 finding)

1. **Hardcoded Test Credentials**
   Location: src/services/auth.ts:34
   Code: `const testUser = { email: 'test@example.com', password: 'password123' };`
   Impact: If committed to main branch, test credentials exposed in source code
   Risk: Anyone with access to repo can use test account
   Fix: Remove testUser object. Move to test files only.
   Priority: IMMEDIATE (before any push to remote)

### HIGH (2 findings)

2. **No Timeout on Token Validation**
   Location: src/services/auth.ts:89
   Issue: HTTP call to token validation endpoint has no timeout
   Impact: Request can hang indefinitely, blocking authentication
   Fix: Add timeout(5000) to request
   Effort: 5 minutes

3. **SQL Injection Risk in Email Validation**
   Location: src/services/auth.ts:156
   Code: `const user = db.query('SELECT * FROM users WHERE email = ' + email);`
   Issue: Concatenating email directly into SQL query
   Fix: Use parameterized query: `db.query('SELECT * FROM users WHERE email = ?', [email])`
   Effort: 5 minutes

### MEDIUM (2 findings)

4. **Missing Error Handler for Login Failures**
   Location: src/services/auth.ts:120
   Issue: No catch block on login promise
   Fix: Add .catch() or try-catch wrapper
   Effort: 10 minutes

### LOW (7 findings)

[... various naming/style issues ...]

## Recommendations
1. **CRITICAL**: Remove testUser constant — estimated 2 minutes
2. **HIGH**: Fix SQL injection vulnerability — estimated 5 minutes
3. **HIGH**: Add timeout to token validation — estimated 5 minutes
4. **MEDIUM**: Add error handlers — estimated 10 minutes
5. **STYLE**: Rename variables (p → password, t → timestamp) — estimated 5 minutes

**Total Recommended Effort**: 27 minutes
**Blockers for Deployment**: All CRITICAL and HIGH findings must be fixed

## Metadata
- **Requested By**: alice.secteam@acme.com
- **Executed By**: claude-code
- **Started**: 2026-04-18T16:00:00Z
- **Completed**: 2026-04-18T16:15:00Z
- **Duration**: 15 minutes
- **Status**: COMPLETE
- **Related**: (none)

## Code References
- [src/services/auth.ts](https://github.com/acme/dashboard/blob/main/src/services/auth.ts) (entire file)
- Specific lines: 34, 89, 120, 156
```

---

## Section 5: Signal System (Emergency Notifications)

Signals are urgent notifications sent when something critical needs immediate attention or action.

### Signal Types

| Signal | Purpose | Requires | Example |
|--------|---------|----------|---------|
| **halt** | Stop all work immediately | Reason + what to stop | Production is down |
| **rollback** | Revert recent changes | Commit/tag to revert to | Last deploy broke auth |
| **escalate** | Escalate issue to higher authority | Current priority + reason | Security issue found |
| **hotfix** | Apply emergency fix bypassing normal process | Issue + fix | Data corruption found |
| **revert** | Undo specific change | Commit/PR to revert | New feature causes crashes |
| **pause** | Pause ongoing work temporarily | Reason | Waiting for external input |
| **resume** | Resume paused work | Which work to resume | Dependency resolved |

### Signal Format

**Naming**: `[SIGNAL-TYPE]-[timestamp].md`

**Example**: `HALT-2026-04-18T15:30:00Z.md`

**Content**:

```markdown
# SIGNAL: HALT

## Timestamp
2026-04-18T15:30:00Z

## Severity
CRITICAL

## Message
Production deployment detected security vulnerability in auth service.
HALT all work. Do not deploy. Revert to previous stable version.

## Details
- Issue: SQL injection in email validation (src/services/auth.ts:156)
- Discovered: In production monitoring (5 malformed email attempts detected)
- Impact: Potential unauthorized database access
- Action: Immediate rollback to v2.0.5

## Rollback Instructions
```
git revert -m 1 abc1234  # Reverts the commit introducing vulnerability
git push origin main --force
```

## Authority
Security Team Lead (security@acme.com)

## Acknowledge?
Claude Code must acknowledge receipt within 5 minutes.
```

### Signal Processing

When a signal is received:

1. **Claude Code receives signal** → reads from signals/ directory
2. **Validates signal authenticity** → confirms from authorized source
3. **Executes signal action** → halts, reverts, pauses work
4. **Logs action** → documents what was done
5. **Acknowledges signal** → updates signal file with status

Example signal acknowledgment:

```markdown
# SIGNAL: HALT [ACKNOWLEDGED]

## Timestamp
2026-04-18T15:30:00Z

## Acknowledged By
claude-code

## Acknowledged At
2026-04-18T15:31:23Z

## Actions Taken
- ✓ Stopped all running tests
- ✓ Paused deployment pipeline
- ✓ Reverted to v2.0.5
- ✓ Verified rollback successful
- ✓ Notified team in #engineering-incidents

## Status
COMPLETE — Production restored to stable version
```

---

## Section 6: Pipeline System (Chained Workflows)

Pipelines are multi-step workflows where each step's output feeds the next step's input.

### Pipeline Format

**Naming**: `[pipeline-name]-[identifier].md`

**Example**: `pre-release-2026-04-18.md`

**Content**:

```markdown
# PIPELINE: Pre-Release Security Check

## Identifier
pre-release-2026-04-18

## Stage 1: Security Audit
**Request**: audit-security-2026-04-18-001
**Status**: PENDING
**Blocks**: Stage 2

Step: Run /security-review on all commits since last release
Output: security-audit-2026-04-18-001.md

## Stage 2: Unit Tests
**Request**: verify-tests-2026-04-18-001
**Status**: PENDING (waiting for Stage 1)
**Blocks**: Stage 3

Step: Run npm test --coverage
Acceptance: All tests pass, coverage > 80%
Output: test-results-2026-04-18.json

## Stage 3: Code Review
**Request**: review-pr-2026-04-18-001
**Status**: PENDING (waiting for Stages 1-2)
**Blocks**: Stage 4

Step: Review all commits in PR
Acceptance: No critical/high issues, all feedback addressed
Output: code-review-2026-04-18.md

## Stage 4: Deployment
**Request**: deploy-staging-2026-04-18-001
**Status**: PENDING (waiting for Stages 1-3)
**Blocks**: (final stage)

Step: Deploy to staging, run smoke tests
Acceptance: All smoke tests pass, metrics normal
Output: deployment-log-2026-04-18.txt

## Summary
Pipeline created: 2026-04-18T10:00:00Z
Current stage: Waiting for Stage 1
Estimated completion: 2026-04-18T15:00:00Z
```

### Pipeline Status Tracking

As each stage completes:

```markdown
# PIPELINE: Pre-Release Security Check [UPDATE]

## Timeline
- Stage 1 (Security Audit): ✓ COMPLETE [15 min]
- Stage 2 (Tests): 🔄 IN_PROGRESS [started 16:15]
- Stage 3 (Code Review): ⏳ PENDING
- Stage 4 (Deploy): ⏳ PENDING

## Status
2 of 4 stages complete. Next: Monitor Stage 2 (tests running)
```

---

## Section 7: Thread System (Follow-up Conversations)

Threads are focused discussions on specific findings from a result.

### Thread Creation

After receiving a result with findings, Cowork can create a thread to discuss next steps.

**Naming**: `[request-name]-thread.md`

**Example**: `audit-auth-2026-04-18-001-thread.md`

**Content**:

```markdown
# THREAD: Discussion on auth audit findings

Related Request: audit-auth-2026-04-18-001

## Question 1: SQL Injection Fix
Cowork (2026-04-18T16:30:00Z):
  The SQL injection fix you recommended — parameterized queries.
  Will that work with our current database driver? We're using knex.js.

Claude Code (2026-04-18T16:32:00Z):
  Yes, knex.js has built-in support for parameterized queries.
  Example:
  ```
  db('users').where('email', '=', userEmail).first()
  ```
  Knex automatically parameterizes the value, preventing injection.

Cowork (2026-04-18T16:35:00Z):
  Great! Adding that to the fix now.

## Question 2: Token Timeout
Cowork (2026-04-18T16:37:00Z):
  You recommended 5-second timeout. Why 5s vs 10s?
  Our API sometimes takes 3-4s to respond.

Claude Code (2026-04-18T16:39:00Z):
  Good catch. If your API has p95 latency of 4s, 5s might be too aggressive.
  Recommend: Use 8-10 seconds (allows for network jitter).
  OR: Implement circuit breaker + exponential backoff for retries.

Cowork (2026-04-18T16:42:00Z):
  We'll go with 10s for now. Circuit breaker is on the backlog.

## Summary
Thread opened: 2026-04-18T16:30:00Z
Status: RESOLVED (all questions answered, fixes implemented)
Next: Verify fixes in merge request review
```

### Thread Workflow

1. **Cowork opens thread** with questions/clarifications needed
2. **Claude Code responds** with detailed answers
3. **Back-and-forth** until all questions resolved
4. **Thread marked RESOLVED** when implementation complete
5. **Thread archived** after 7 days or when task complete

---

## Section 8: Live Dashboard (status.md)

The `status.md` file is a real-time view of queue status, active signals, pipeline progress, and key metrics.

### Dashboard Template

```markdown
# I/O CHANNEL DASHBOARD

Last updated: 2026-04-18T17:00:00Z
Next auto-update: 2026-04-18T17:10:00Z

## QUEUE STATUS

### Incoming Requests (5 pending)

| Priority | Type | Target | Age | Status |
|----------|------|--------|-----|--------|
| CRITICAL | audit | security | 2h | IN_PROGRESS |
| HIGH | verify | migration | 45m | PENDING |
| HIGH | review | dashboard-pr | 30m | PENDING |
| MEDIUM | analyze | perf | 1h | IN_PROGRESS |
| LOW | document | api | 3h | PENDING |

### SLA Status
- CRITICAL: 0 overdue (2h SLA)
- HIGH: 0 overdue (4h SLA)
- MEDIUM: 1 overdue (8h SLA)
- LOW: 1 overdue (24h SLA)

### Backlog Velocity
- Last 7 days: 23 requests completed
- Average resolution time: 45 minutes
- Current queue depth: 5 requests

---

## SIGNAL BOARD

### Active Signals (0)
None

### Recent Signals (last 7 days)
- 2026-04-15: ESCALATE — Security team took ownership
- 2026-04-12: PAUSE → RESUME — Dependency resolved

---

## PIPELINES

### Running Pipelines (1)

**pre-release-2026-04-18**
```
[████████░░] Stage 2/4 (50% complete)
Stage 1: ✓ COMPLETE [15m]
Stage 2: 🔄 IN_PROGRESS [8m remaining]
Stage 3: ⏳ PENDING
Stage 4: ⏳ PENDING
```

---

## THREADS

### Open Threads (2)
- [audit-auth-2026-04-18-001-thread] 3 comments, last update 10m ago
- [review-dashboard-2026-04-18-002-thread] 1 comment, needs response

---

## KEY METRICS (7-day rolling)

- Requests completed: 23
- Avg resolution time: 45 min
- CRITICAL found: 2
- HIGH found: 8
- Tests added: 15
- Bugs fixed: 5
- Security issues: 2

---

## ACCESS & PERMISSIONS

Current user: john.manager@acme.com
Permissions: READ (all), WRITE (requests, signals), ADMIN (no)

Last action: Created audit-security-2026-04-18-001 (45m ago)
```

---

## Section 9: Request Naming Convention

All requests follow a strict naming pattern:

```
[type]-[target]-[date]-[seq].md

- type: audit | verify | review | analyze | compare | fix (6 options)
- target: what is being worked on (e.g., "auth", "dashboard-pr", "migration-safety")
- date: YYYY-MM-DD (ISO format)
- seq: 001, 002, 003... (sequence if multiple requests same day for same target)
```

### Examples

| Request | Meaning |
|---------|---------|
| `audit-auth-2026-04-18-001` | Audit the auth service on April 18 (first one) |
| `verify-migration-2026-04-18-001` | Verify migration is safe on April 18 |
| `review-dashboard-pr-2026-04-18-002` | Code review of dashboard PR (second review today) |
| `fix-modal-zindex-2026-04-18-001` | Fix the modal z-index bug |
| `analyze-perf-2026-04-18-001` | Performance analysis (first one) |
| `compare-auth-strategies-2026-04-18-001` | Compare auth implementation approaches |

---

## Section 10: 9 Pre-Built Templates

Located in `io/.templates/`

### Template 1: TEMPLATE_AUDIT.md

Audit template for comprehensive scanning.

```markdown
# AUDIT REQUEST TEMPLATE

## Metadata
- **Type**: audit
- **Target**: [component/service/scope]
- **Date**: YYYY-MM-DD
- **Priority**: CRITICAL | HIGH | MEDIUM | LOW
- **SLA**: Complete within [X hours]

## Scope
Describe what should be audited:
- Security vulnerabilities
- Code quality issues
- Performance bottlenecks
- Test coverage
- Compliance violations

## Acceptance Criteria
List what needs to be checked:
- [] Security: No OWASP Top 10 violations
- [] Code Quality: No functions > 50 lines
- [] Tests: Coverage > 80%
- [] Performance: No N+1 queries
- [] Accessibility: WCAG 2.1 AA compliant

## Context
Any additional context (recent changes, known issues, etc.)

## Due Date
YYYY-MM-DDTHH:MM:SSZ
```

### Template 2-6: TEMPLATE_VERIFY.md, TEMPLATE_REVIEW.md, TEMPLATE_ANALYZE.md, TEMPLATE_COMPARE.md, TEMPLATE_FIX.md

[Similar structure, customized for each request type]

### Template 7: BRIEFING_COWORK.md

Brief for Cowork (Human Manager) on their role and responsibilities.

```markdown
# BRIEFING: I/O Channel for Cowork (Human Manager)

## Your Role
You manage work by creating requests and monitoring results.
Claude Code executes work and reports findings.

## Key Responsibilities
1. Create well-formed requests (use templates)
2. Prioritize work (CRITICAL vs LOW)
3. Review results and approve/request changes
4. Send signals for emergencies (halt, rollback, etc.)
5. Participate in threads (answer questions, clarifications)

## Creating Requests
1. Copy template from io/.templates/
2. Fill in all required fields
3. Save to io/requests/ with naming convention
4. Claude Code will pick it up within 10 minutes

## Reading Results
1. Check io/results/ for matching filename
2. Review findings by severity
3. Discuss in threads if questions
4. Follow recommendations or update next request

## Emergencies
Use signals for urgent situations:
- HALT: Stop all work (production down)
- ROLLBACK: Revert change (deployment broken)
- ESCALATE: Hand off to authority (security issue)
```

### Template 8: BRIEFING_CLAUDE_CODE.md

Brief for Claude Code (AI Executor).

```markdown
# BRIEFING: I/O Channel for Claude Code (AI Executor)

## Your Role
Execute work requests, report findings, respect signals.

## Workflow
1. **Watch requests/** directory for new requests
2. **Read request** — understand scope and acceptance criteria
3. **Execute work** — run commands, analyze code, etc.
4. **Generate result** — format findings by severity
5. **Save result** — to results/ with matching filename
6. **Respond to threads** — answer clarification questions

## Important Rules
- Honor signal directives (HALT, ROLLBACK, etc.)
- Set realistic time estimates
- Document code references for findings
- Archive completed work daily
- Never ignore CRITICAL findings
```

### Template 9: SIGNAL_TEMPLATE.md

Template for creating signals.

```markdown
# SIGNAL TEMPLATE

## Type
Choose one: halt | rollback | escalate | hotfix | revert | pause | resume

## Severity
CRITICAL | HIGH | MEDIUM

## Message
Clear, concise description of the situation

## Details
- What happened
- Why it matters
- What action is needed

## Instructions
Step-by-step commands to execute the signal action

## Authority
Who is sending this signal (must be authorized person)

## Deadline
When must this signal be acknowledged/completed?
```

---

## Section 11: Access Control Matrix

Located in `io/.access/permissions.json`

```json
{
  "roles": {
    "cowork": {
      "read": ["requests", "results", "signals", "status"],
      "write": ["requests", "signals"],
      "admin": false
    },
    "claude-code": {
      "read": ["requests", "signals", "status"],
      "write": ["results", "threads", "archive", "status"],
      "admin": false
    },
    "admin": {
      "read": ["all"],
      "write": ["all"],
      "admin": true
    }
  },
  "users": {
    "john.manager@acme.com": {
      "role": "cowork",
      "created": "2026-01-01"
    },
    "claude-code@methodology.local": {
      "role": "claude-code",
      "created": "2026-01-01"
    },
    "security-lead@acme.com": {
      "role": "admin",
      "created": "2026-02-15"
    }
  }
}
```

---

## Section 12: Session Integration (io-watcher.sh)

A background script that monitors io/ directory and alerts on new requests/signals.

### Script Behavior

```bash
#!/bin/bash
# io-watcher.sh — monitors io/requests and io/signals directories

while true; do
  # Check for new requests
  if [[ -f io/requests/NEWFILE ]]; then
    echo "New request detected: NEWFILE"
    # Trigger Claude Code to process
  fi

  # Check for new signals
  if [[ -f io/signals/NEWFILE ]]; then
    echo "SIGNAL RECEIVED: NEWFILE"
    # Parse signal, execute action
  fi

  # Update dashboard
  update_dashboard

  sleep 60
done
```

### When to Run

- Automatically at session start (/session-start)
- Continuously in background during development
- Monitors for new requests/signals
- Updates status.md every 10 minutes

---

## Section 13: Real-World Example: Complete Workflow

Follow an audit request from creation through resolution.

### Step 1: Cowork Creates Request

Cowork creates a security audit request.

**File**: `io/requests/audit-auth-2026-04-18-001.md`

```markdown
# AUDIT Request: Auth Service Security

## Request ID
audit-auth-2026-04-18-001

## Priority
CRITICAL

## Target
src/services/auth.ts

## Scope
- Authentication security (no SQL injection, XSS, CSRF)
- Token handling (JWT validation, expiry)
- Password management (hashing, reset flow)
- Third-party integrations (OAuth)

## Acceptance Criteria
- [] Identify all security vulnerabilities (CVE-style format)
- [] Test coverage for all auth paths
- [] No hardcoded secrets
- [] All findings documented with fix recommendations

## Due
2026-04-18T18:00:00Z

## Context
Previous audit found SQL injection risk in email validation.
Confirm if fixed and look for similar patterns.

## Requested By
security-lead@acme.com
```

### Step 2: Claude Code Detects & Executes

Claude Code's io-watcher detects new request.

Actions:
1. Reads request file
2. Runs `/review src/services/auth.ts` command
3. Runs security scanning
4. Documents findings
5. Writes result file

### Step 3: Claude Code Creates Result

**File**: `io/results/audit-auth-2026-04-18-001.md`

```markdown
# RESULT: audit-auth-2026-04-18-001

## Summary
Auth service has 1 CRITICAL security issue (hardcoded test credentials),
2 HIGH issues (missing error handling), 3 MEDIUM issues.

## Findings by Severity

### CRITICAL (1)
1. **Hardcoded Test Credentials**
   Location: src/services/auth.ts:34
   Code: `const testUser = { email: 'test@example.com', password: 'password123' };`
   Fix: Remove from source, add to test files only
   Severity: CRITICAL (credentials exposed if leaked)

### HIGH (2)
1. **SQL Injection in Email Validation** ← SAME ISSUE FROM PREVIOUS AUDIT
   Location: src/services/auth.ts:156
   Status: NOT FIXED! Still using string concatenation
   Fix: Use parameterized query (db.where('email', email))

2. **Missing Error Handler on Token Validation**
   Location: src/services/auth.ts:120
   Issue: No catch block on async call
   Fix: Add .catch(error => handleError(error))

### MEDIUM (3)
[... other findings ...]

## Recommendations
1. IMMEDIATE: Remove testUser constant (2 min)
2. URGENT: Fix SQL injection (5 min) — THIS WAS REPORTED LAST AUDIT!
3. HIGH: Add error handlers (15 min)

## Code Scan Results
- Test Coverage: 78% (below 80% target)
- Vulnerabilities: 3 (1 critical, 2 high)
- Security Issues: CWE-89 (SQL Injection), CWE-347 (Improper Validation)

## Status
COMPLETE — 6 findings identified, 2 are regressions from previous audit

## Metadata
- Executed By: claude-code
- Started: 2026-04-18T16:00:00Z
- Completed: 2026-04-18T16:25:00Z
- Duration: 25 minutes
```

### Step 4: Cowork Reviews Result

Cowork reads result file, sees CRITICAL and HIGH issues.

Concerned: SQL injection was supposedly fixed in last audit but it's back!

### Step 5: Cowork Opens Thread

**File**: `io/threads/audit-auth-2026-04-18-001-thread.md`

```markdown
# THREAD: Auth audit findings — SQL injection regression

Related Request: audit-auth-2026-04-18-001

## Question 1: SQL Injection Not Fixed?
Cowork (2026-04-18T16:30:00Z):
  I'm concerned. The SQL injection in email validation was reported 
  in the LAST audit (March 2026). Why is it still there?
  Did someone re-introduce it, or was it never fixed?

Claude Code (2026-04-18T16:32:00Z):
  Good catch. Looking at git history:
  - Reported March 15 audit
  - Fixed March 18 (commit abc123)
  - Reverted April 8 (commit def456) during refactor
  - Not fixed since then
  
  Someone accidentally reverted the fix during a refactor.
  It's a regression, not a never-fixed issue.

Cowork (2026-04-18T16:35:00Z):
  Got it. Need to re-apply the fix and add a test to prevent
  this from happening again.
  Claude Code, can you create a fix request?

Claude Code (2026-04-18T16:37:00Z):
  Yes, I'll create fix-sql-injection-2026-04-18-001.md
  which will:
  1. Re-apply parameterized query fix
  2. Add regression test for email validation
  3. Add commit message noting this is a re-fix

Cowork (2026-04-18T16:40:00Z):
  Thanks. Let's also add a pre-commit hook that catches this pattern
  in the future. Creating a new request for that.
```

### Step 6: Cowork Creates Follow-Up Fix Request

**File**: `io/requests/fix-sql-injection-2026-04-18-001.md`

```markdown
# FIX Request: Re-apply SQL Injection Fix + Add Test

## Request ID
fix-sql-injection-2026-04-18-001

## Priority
CRITICAL

## Issue
SQL injection in auth email validation was fixed in March but accidentally
reverted in April during refactor. Need to:
1. Re-apply fix
2. Add regression test
3. Document in changelog

## Implementation
Location: src/services/auth.ts:156

Bad code:
```
const user = db.query('SELECT * FROM users WHERE email = ' + email);
```

Good code:
```
const user = await db('users').where('email', email).first();
```

Test requirement:
```
it('should escape email in query (SQL injection prevention)', () => {
  const result = validateEmail("test'; DROP TABLE users; --");
  expect(result.isValid).toBe(false);
});
```

## Acceptance Criteria
- [] Parameterized query implemented
- [] Test added for malicious email input
- [] All tests passing
- [] Changelog updated noting regression fix

## Due
2026-04-18T17:30:00Z
```

### Step 7: Claude Code Executes Fix Request

**File**: `io/results/fix-sql-injection-2026-04-18-001.md`

```markdown
# RESULT: fix-sql-injection-2026-04-18-001

## Summary
SQL injection fix re-applied, regression test added.
All tests passing. Ready to merge.

## Changes Made
1. ✓ Parameterized query implemented (line 156)
2. ✓ Regression test added (4 test cases for malicious input)
3. ✓ All 247 tests passing (new test included)
4. ✓ Changelog updated: "fix: re-apply SQL injection prevention in email validation"

## Code Changes
- Files modified: 2 (auth.ts, auth.test.ts)
- Lines added: 18
- Test coverage: 78% → 84% (regression test fills gap)

## Verification
- Unit tests: ✓ PASS (247/247)
- Security scan: ✓ PASS (SQL injection eliminated)
- Code review: ✓ PASS (parameterized query is best practice)

## Status
COMPLETE — Ready to merge to main branch
```

### Step 8: Update Dashboard

**File**: `io/status.md` (auto-updated)

```markdown
## QUEUE STATUS

| Priority | Type | Target | Age | Status |
|----------|------|--------|-----|--------|
| CRITICAL | audit | auth | 2h | ✓ COMPLETE |
| CRITICAL | fix | sql-injection | 45m | ✓ COMPLETE |
```

### Step 9: Archive Completed Items

Daily, completed requests are moved to archive:

```
io/
├── archive/
│   ├── 2026-04-18/
│   │   ├── audit-auth-2026-04-18-001.md
│   │   ├── fix-sql-injection-2026-04-18-001.md
│   │   ├── audit-auth-2026-04-18-001-thread.md
│   │   └── ...
```

### Summary

This complete workflow shows:

1. **Cowork initiates work** with clear request
2. **Claude Code executes** and reports findings
3. **Discussion happens in threads** (questions, clarifications)
4. **Follow-up work** emerges from findings
5. **Results accumulate** in queue
6. **Completed work** is archived for audit trail
7. **Dashboard tracks** all activity in real-time

---

## Section 14: Best Practices for I/O Channel Usage

### For Cowork (Human Manager)

1. **Use templates** — Never write requests from scratch. Copy templates.
2. **Be specific** — Vague requests lead to wrong answers. Include context.
3. **Prioritize correctly** — CRITICAL is for production outages, not feature requests.
4. **Respond in threads** — When Claude Code asks questions, answer promptly.
5. **Trust the process** — Don't interrupt with signals unless truly emergency.
6. **Archive regularly** — Move old completed items to archive monthly.

### For Claude Code (AI Executor)

1. **Watch for new requests** — Check requests/ directory every 10 minutes.
2. **Honor signals immediately** — HALT, ROLLBACK are non-negotiable.
3. **Document findings** — Every result needs code references and severity levels.
4. **Be specific in recommendations** — "Fix this" is not actionable. "Change line 42 from X to Y" is.
5. **Test recommendations** — Don't suggest fixes you haven't verified work.
6. **Keep threads responsive** — Answer questions within 30 minutes.

### General

1. **Keep queue small** — Don't let backlog exceed 10 items. Prioritize.
2. **Monitor SLA** — If request > 4h old and HIGH priority, escalate.
3. **Regular retrospectives** — Weekly: What requests took too long? Why? How to improve?
4. **Automate monitoring** — Use io-watcher.sh to detect issues automatically.
5. **Archive aggressively** — Move completed work to archive daily to keep active queue clean.

---

## End of I/O Channel Manual

This system enables transparent, structured communication between Cowork and Claude Code, with clear prioritization, comprehensive audit trail, and emergency protocols.

Use it consistently for reliable, scalable development workflows.

