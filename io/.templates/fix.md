# Fix Request Template

## Meta
- **ID**: `FIX-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `fix`
- **Priority**: `critical` | `high` | `medium` | `low`
- **Status**: `pending` (requires approval before execution)
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to issue/bug report)

---

## Issue Description

### Symptoms
(What exactly is broken? What does the user observe?)

### Root Cause (if known)
(If we know why this is happening, explain it here)

### Affected Systems/Files
- (List specific modules, functions, files)
- (How widespread is the impact?)

### User/Business Impact
- (Who is affected?)
- (What's the severity of the impact?)
- (Is this blocking other work?)

---

## Expected vs Actual Behavior

### Expected Behavior
(What should happen?)

### Actual Behavior
(What is happening instead?)

### How to Reproduce
(Steps to reproduce the bug, with example data if needed)

---

## Fix Scope

### Files to Modify
| File | Type | Reason |
|------|------|--------|
| | (add/modify/delete) | |
| | | |

### Functions/Methods to Change
| Function | Change | Reason |
|----------|--------|--------|
| | | |
| | | |

### Tests to Add/Modify
| Test | Type | Coverage |
|------|------|----------|
| | (unit/integration/e2e) | |
| | | |

---

## Constraints

### What NOT to Change
- (Preserve backward compatibility? Yes/No)
- (Don't touch performance-critical paths)
- (Don't modify API contracts)
- (Other explicit constraints)

### Assumptions
- (What are we assuming about the system state?)
- (What must be true for this fix to work?)

### Dependencies
- (Does this fix depend on other PRs/fixes?)
- (Any environment setup needed?)

---

## Implementation Plan

### High-level Approach
(Describe the fix strategy at a high level)

### Detailed Steps
1. (Step 1)
2. (Step 2)
3. (etc.)

### Code Changes Summary
- (approximate lines of code)
- (files touched)
- (complexity estimate)

---

## Expected Deliverables

### Files Changed
(List all files that will be modified)

### Tests Added
(List all new tests)

### Verification Steps
(How will we verify the fix works?)

### Performance Impact
- (Should be negligible? Improved? Degraded?)
- (Any performance testing needed?)

### Breaking Changes
- (Any API changes that break compatibility?)
- (Migration path for users?)

---

## Approval Requirements

### Review Checklist
- [ ] Owner/maintainer has reviewed and approved
- [ ] Security implications assessed (if any)
- [ ] Performance impact assessed
- [ ] Backward compatibility confirmed
- [ ] Test plan is adequate

### Required Approvals
- (Who must approve before execution?)
- (Any stakeholders to notify?)

### Sign-off
- **Requested by**: (person or system that reported the bug)
- **Approved by**: (person authorizing the fix) — **SIGNATURE REQUIRED**
- **Approval Date**: `YYYY-MM-DD HH:mm UTC`

---

## Execution Details (Filled After Fix)

### Actual Files Modified
(List files actually changed)

### Tests Added
(List tests added and their results)

### Verification Results
- [ ] Fix resolves the reported issue
- [ ] No regressions introduced
- [ ] All tests pass
- [ ] Performance acceptable
- [ ] Documentation updated

### Code Review
- **Reviewed by**: (agent/human who reviewed)
- **Review Status**: ✅ APPROVED | 🔄 NEEDS CHANGES | ❌ REJECTED
- **Comments**: (review feedback)

### Deployment Readiness
- [ ] Ready for immediate deployment
- [ ] Needs testing before deployment
- [ ] Needs approval before deployment
- [ ] Blocked (specify why)

### Final Sign-off
- **Fixed by**: (agent who implemented the fix)
- **Date Completed**: `YYYY-MM-DD HH:mm UTC`
- **Verification Status**: ✅ VERIFIED | ⏳ PENDING VERIFICATION | ❌ FAILED

---

## Post-Fix

### Monitoring
(What should be monitored after this fix is deployed?)

### Rollback Plan
(How to revert if the fix causes issues?)

### Related Issues
(List any other issues that might be related)

### Follow-up Tasks
(Any additional work needed after the fix?)

---

## Notes
(Any additional context or concerns?)
