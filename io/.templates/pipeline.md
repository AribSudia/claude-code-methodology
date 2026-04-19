# Pipeline (Multi-Step Workflow) Template

## Meta
- **Pipeline ID**: `PIPELINE-YYYY-MM-DD-HHmm`
- **Name**: (descriptive name for this workflow)
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `pipeline`
- **Total Steps**: (number of steps)
- **Trigger**: (what event triggered this pipeline? manual | merge | deployment | release | incident | etc.)
- **Owner**: (who initiated this pipeline?)
- **Status**: `pending` | `in_progress` | `completed` | `blocked`
- **Related Request**: (link to originating request, issue, or ticket)

---

## Pipeline Overview

### Purpose
(Why is this pipeline being run? What is the end goal?)

### Success Criteria
- (How will we know this pipeline succeeded?)
- (What's the definition of "done"?)

### Execution Rules
- **Sequential**: Steps run one after another (step N+1 waits for step N to complete)
- **Pause on Critical**: If a step generates a critical finding, pause and wait for approval before proceeding
- **Request-Result Pattern**: Each step creates a request (INPUT-step-N.md) and produces a result (OUTPUT-step-N.md)
- **Estimated Duration**: (total time for full pipeline)
- **Rollback Capable**: Yes | No (can we undo if something goes wrong?)

---

## Steps

| Step | Type | Scope | Depends On | Status | Request ID | Result ID | Notes |
|------|------|-------|-----------|--------|------------|-----------|-------|
| 1 | | | (initial) | pending | | | |
| 2 | | | (step 1) | pending | | | |
| 3 | | | (step 2) | pending | | | |
| 4 | | | (step 3) | pending | | | |

### Step Details

#### Step 1: (Name)
- **Type**: (audit | verify | review | analyze | compare | fix | etc.)
- **Scope**: (what does this step do?)
- **Depends On**: (initial or previous step)
- **Estimated Duration**: (time to complete)
- **Success Criteria**: (how do we know this step passed?)
- **Status**: ⏳ pending | 🔄 in_progress | ✅ complete | ❌ failed | ⏸ blocked
- **Request File**: `INPUT-step-1-DESCRIPTION.md`
- **Result File**: `OUTPUT-step-1-DESCRIPTION.md`
- **Notes**: (any special instructions)

#### Step 2: (Name)
- **Type**: 
- **Scope**: 
- **Depends On**: (step 1)
- **Estimated Duration**: 
- **Success Criteria**: 
- **Status**: ⏳ pending
- **Request File**: `INPUT-step-2-DESCRIPTION.md`
- **Result File**: `OUTPUT-step-2-DESCRIPTION.md`
- **Notes**: 

#### Step 3: (Name)
- **Type**: 
- **Scope**: 
- **Depends On**: (step 2)
- **Estimated Duration**: 
- **Success Criteria**: 
- **Status**: ⏳ pending
- **Request File**: `INPUT-step-3-DESCRIPTION.md`
- **Result File**: `OUTPUT-step-3-DESCRIPTION.md`
- **Notes**: 

#### Step 4: (Name)
- **Type**: 
- **Scope**: 
- **Depends On**: (step 3)
- **Estimated Duration**: 
- **Success Criteria**: 
- **Status**: ⏳ pending
- **Request File**: `INPUT-step-4-DESCRIPTION.md`
- **Result File**: `OUTPUT-step-4-DESCRIPTION.md`
- **Notes**: 

---

## Pre-Built Pipeline Examples

### Example 1: Pre-Release Pipeline
**Purpose**: Comprehensive validation before production release

| Step | Type | Scope | Notes |
|------|------|-------|-------|
| 1 | audit | Security & code quality | Check for vulnerabilities, secrets, code smells |
| 2 | verify | Full test suite | Run all unit, integration, E2E tests |
| 3 | analyze | Performance metrics | Measure response times, memory, CPU before release |
| 4 | review | Release readiness | Verify versioning, changelog, documentation |

**Execution**: Sequential, pause on critical findings  
**Duration**: 2-4 hours  
**Success**: All steps pass, no critical issues

---

### Example 2: Feature Validation Pipeline
**Purpose**: Validate a new feature is production-ready

| Step | Type | Scope | Notes |
|------|------|-------|-------|
| 1 | review | Code changes | Review feature code quality and architecture |
| 2 | verify | Test coverage | Verify unit and integration tests pass |
| 3 | verify | End-to-end flows | Manual or automated E2E testing |
| 4 | audit | Accessibility | WCAG compliance check (if web) |

**Execution**: Sequential, pause on medium+ findings  
**Duration**: 4-8 hours  
**Success**: Code reviewed, tests pass, feature works end-to-end

---

### Example 3: Incident Response Pipeline
**Purpose**: Rapid diagnosis and remediation of production issues

| Step | Type | Scope | Notes |
|------|------|-------|-------|
| 1 | analyze | Diagnose issue | Root cause analysis, error logs, metrics |
| 2 | fix | Implement fix | Hot-fix the identified problem |
| 3 | verify | Validate fix | Verify the issue is resolved |
| 4 | review | Post-mortem | Document what happened and how to prevent |

**Execution**: Sequential, pause on blockers only  
**Duration**: 1-2 hours (urgent)  
**Success**: Issue fixed, verified, documented

---

## Execution Tracking

### Timeline
| Step | Start Time | Duration | End Time | Status |
|------|-----------|----------|----------|--------|
| 1 | | | | |
| 2 | | | | | |
| 3 | | | | |
| 4 | | | | |
| **Total** | | | | |

### Blockers & Issues
(Any obstacles encountered during execution?)

### Decision Points
(Any points where manual approval was needed?)

### Communications
(Who was notified during pipeline execution?)

---

## Results Summary

### Overall Pipeline Status
- **Status**: ✅ COMPLETE | 🔄 IN PROGRESS | ❌ FAILED | ⏸ BLOCKED
- **Completion Date**: `YYYY-MM-DD HH:mm UTC`
- **Total Duration**: (hours/minutes)

### Step Results Summary
| Step | Result | Key Findings | Status |
|------|--------|--------------|--------|
| 1 | (PASS/FAIL) | (highlights) | |
| 2 | (PASS/FAIL) | (highlights) | |
| 3 | (PASS/FAIL) | (highlights) | |
| 4 | (PASS/FAIL) | (highlights) | |

### Critical Findings Across Pipeline
(Summarize any critical issues found in any step)

### Recommendations
1. (Based on pipeline results)
2. (Next steps)
3. (Follow-up tasks)

---

## Rollback Plan
(If something went wrong, how do we undo?)

---

## Sign-off
- **Pipeline Executor**: (agent who ran pipeline)
- **Date Completed**: `YYYY-MM-DD HH:mm UTC`
- **Approved by**: (human reviewer if required)
- **Next Stage**: (what happens after this pipeline completes?)
