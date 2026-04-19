# Signal (Emergency/Interrupt) Template

## Meta
- **Signal ID**: `SIGNAL-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `signal`
- **Signal Type**: `halt` | `rollback` | `escalate` | `hotfix` | `revert` | `pause` | `resume`
- **Priority**: `critical` (always critical for signals)
- **Status**: `raised` | `acknowledged` | `in_progress` | `resolved`
- **Sender**: (agent or person who raised the signal)
- **Related Request**: (link to pipeline, deployment, or work in progress)

---

## Signal Definition

### Reason for Signal
(Why is this signal being raised? What triggered it?)

### Specific Issue
(What exactly is happening that requires intervention?)

### Severity Assessment
- **User Impact**: None | Low | Medium | High | Critical
- **System Impact**: Isolated | Component-level | System-wide
- **Business Impact**: (brief assessment)

### Timeline Urgency
(Is this urgent? How much time do we have?)

---

## Impact Analysis

### What is Affected
- (Which systems/features/users are impacted?)
- (How many users affected?)
- (Any cascading effects?)

### Estimated Scope
- (How widespread is the problem?)
- (Is it contained or spreading?)

### Current State
(What was happening when the signal was raised?)

---

## Requested Action

### Signal Type Details

#### If HALT
- **Instruction**: Stop all activity related to [specific task/pipeline]
- **Why**: (reason for halting)
- **Scope**: (what should stop? everything or specific components?)
- **What to Do**: 
  1. Stop execution
  2. Preserve current state
  3. Hold for further instructions
  4. Do NOT proceed unless explicitly authorized

#### If ROLLBACK
- **Instruction**: Revert to previous known-good state
- **Target**: (what to rollback? commit hash, deploy version, branch, etc.)
- **Why**: (reason for rollback)
- **Scope**: (full rollback or partial?)
- **Rollback Steps**:
  1. (step 1)
  2. (step 2)
  3. (verify previous state restored)

#### If ESCALATE
- **Instruction**: Escalate to human authority
- **To**: (who should be notified? team lead, engineering manager, on-call, etc.)
- **Priority**: (urgent | high | medium)
- **Context for Escalation**: (what information do they need?)
- **Required by**: (time deadline for escalation)

#### If HOTFIX
- **Instruction**: Apply urgent fix without normal approval process
- **What to Fix**: (describe the specific issue)
- **Fix Reference**: (link to fix request or fix code)
- **Why Urgent**: (reason for bypassing normal process)
- **Risk Level**: (assess implementation risk)
- **Rollback Capability**: (can we undo if needed?)

#### If REVERT
- **Instruction**: Undo specific recent changes
- **Commit/Change**: (what exactly to revert?)
- **Affected Files**: (what will change?)
- **Why**: (reason for revert)
- **Verification Steps**: (how to verify revert succeeded)

#### If PAUSE
- **Instruction**: Temporarily stop execution and wait
- **Scope**: (what should pause? specific step or entire pipeline?)
- **Duration**: (estimated pause time or condition to resume)
- **Reason**: (why pause?)
- **Expected Resume**: (when/what will trigger resume?)

#### If RESUME
- **Instruction**: Continue execution from pause point
- **Scope**: (resume what? the same step or next step?)
- **Context**: (what changed that allows resumption?)
- **Entry Point**: (where exactly to resume from)

---

## Context & Background

### What Was Happening
(Describe the activity that triggered this signal)

### Previous State
(What was the system state before this signal?)

### Related Events
(Any recent changes, deployments, or incidents that led to this?)

---

## Executor Response

### Acknowledgment
- **Signal Received by**: (who received/acknowledged this signal)
- **Acknowledgment Time**: `YYYY-MM-DD HH:mm UTC`
- **Status**: 🟢 Acknowledged | ⏳ Awaiting resources | ❌ Cannot comply

### Execution Progress
- **Action Taken**: (what was done in response to signal)
- **Timestamp**: `YYYY-MM-DD HH:mm UTC`
- **Status**: ✅ In Progress | 🔄 Blocked | ❌ Failed | ✅ Completed

### Challenges / Blockers
(Any issues encountered while acting on the signal?)

---

## Resolution

### Resolution Status
- **Status**: ⏳ Pending | 🔄 In Progress | ✅ Resolved | ❌ Unresolved

### What Was Done
(Detailed description of actions taken)

### Verification
- (How was the signal's issue confirmed resolved?)
- (Any tests run?)
- (Systems checked?)

### Outcome
- **Signal Type**: (what type was this? halt/rollback/etc.)
- **Result**: Success | Partial Success | Failed
- **Impact**: (what's different now?)

### Time to Resolution
- **Signal Raised**: `YYYY-MM-DD HH:mm UTC`
- **Resolution Completed**: `YYYY-MM-DD HH:mm UTC`
- **Total Time**: (duration)

---

## Post-Resolution

### Root Cause (if applicable)
(What caused the situation requiring this signal?)

### Follow-up Actions
1. (Post-incident investigation)
2. (Process improvements)
3. (Monitoring enhancements)
4. (Communication)

### Prevention
(How can we prevent this situation in the future?)

### Lessons Learned
(What did we learn from this signal?)

---

## Sign-off

- **Signal Raised by**: (agent or person)
- **Signal Acknowledged by**: (executor)
- **Signal Resolved by**: (who fixed the situation)
- **Date Resolved**: `YYYY-MM-DD HH:mm UTC`
- **Approved by**: (human authority who approved resolution)

---

## Notes
(Any additional context or observations?)

---

## Communication Log

### Notifications Sent
- [ ] Team lead notified
- [ ] On-call engineer notified
- [ ] Product owner notified
- [ ] Affected users notified
- [ ] Other: (specify)

**Notification Time**: `YYYY-MM-DD HH:mm UTC`

### Updates Provided
- (Who was kept informed during resolution?)
- (What information was shared?)
