# I/O Channel Templates

This directory contains pre-built template files for the Claude Code Methodology I/O Channel system. These templates are designed to be copied and minimally modified when agents create requests, results, signals, and pipelines.

## Request Templates (Input)

### audit.md
**Purpose**: Deep code inspection and quality assessment  
**Use when**: You need comprehensive evaluation of code quality, security, performance, patterns, and documentation  
**Key sections**: Meta, Scope, Audit Checklist (code quality, security, performance, patterns, docs), Expected Output with findings by severity

### verify.md
**Purpose**: Confirm that something works as expected  
**Use when**: You need to validate functionality, test results, edge cases, and regressions after changes  
**Key sections**: Meta, Scope, Verification Checklist (functionality, testing, edge cases, regressions), Pass/Fail Summary

### review.md
**Purpose**: Review specific code changes for quality and compliance  
**Use when**: You're reviewing a PR, branch, or specific code changes before merge  
**Key sections**: Meta, Scope, Review Checklist (code quality, security, testing, docs, architecture), APPROVED/NEEDS CHANGES decision

### analyze.md
**Purpose**: Data and performance analysis  
**Use when**: You need to measure metrics, identify bottlenecks, or analyze system performance  
**Key sections**: Meta, Scope, Analysis Dimensions (performance, database, API, resource usage, bundling), Metrics table and bottleneck identification

### compare.md
**Purpose**: Compare two implementations, versions, or approaches  
**Use when**: You need to evaluate two options side-by-side to make a decision  
**Key sections**: Meta, Version A/B Definitions, Comparison Dimensions, Side-by-side table, Recommendation with scoring

### fix.md
**Purpose**: Request a specific code fix (requires explicit user approval before execution)  
**Use when**: You've identified a bug and need to request the fix be implemented  
**Key sections**: Meta, Issue Description, Expected vs Actual, Fix Scope, Constraints, Approval Requirements (signature required), Execution Details  
**⚠️ Important**: This template requires explicit user approval before execution

## Result Templates (Output)

### result.md
**Purpose**: Standard format for delivering results from any request  
**Use for**: Output from audit, verify, review, analyze, compare, or fix requests  
**Key sections**: Meta (linking to request), Executive Summary, Findings by Severity (Critical/High/Medium/Low with emojis), Code References table, Recommendations, Test Results, Performance Metrics, Sign-off

## Advanced Templates

### pipeline.md
**Purpose**: Define and execute multi-step workflows  
**Use when**: You need to chain multiple requests together (e.g., security audit → tests → performance → release review)  
**Key sections**: Meta, Pipeline Overview, Steps table, Step Details, Pre-built examples (Pre-Release, Feature Validation, Incident Response), Execution Tracking, Results Summary  
**Pattern**: Each step creates an INPUT request and produces an OUTPUT result

### signal.md
**Purpose**: Emergency/interrupt signals to halt, rollback, escalate, or pause work  
**Use when**: You need to stop execution, revert changes, or escalate to human authority  
**Key sections**: Meta, Signal Definition (halt/rollback/escalate/hotfix/revert/pause/resume), Reason, Impact, Requested Action, Executor Response, Resolution, Sign-off  
**Pattern**: Signals are critical-priority and interrupt normal pipeline execution

---

## Workflow Patterns

### Standard Request → Result Pattern
1. Copy the appropriate **request template** (audit, verify, review, analyze, compare, or fix)
2. Fill in the Meta section and specific details
3. Executor completes the work
4. Copy the **result template** and link it back to the request
5. Include findings, recommendations, and sign-off

### Pipeline Pattern (Multi-Step)
1. Copy **pipeline.md**
2. Define the steps and dependencies
3. For each step:
   - Create an INPUT request file (audit/verify/review/analyze/compare)
   - Execute the step
   - Create an OUTPUT result file
   - Check success criteria and decide whether to proceed
4. Compile all step results into the pipeline summary
5. Sign off on overall pipeline completion

### Signal Pattern (Emergency)
1. Copy **signal.md**
2. Specify signal type (halt/rollback/escalate/hotfix/revert/pause/resume)
3. Provide context and requested action
4. Executor acknowledges and acts
5. Document resolution and lessons learned

---

## Key Conventions

### File Naming
- **Requests (Input)**: `INPUT-{TYPE}-YYYY-MM-DD-HHmm-{DESCRIPTION}.md`
  - Example: `INPUT-audit-2026-04-17-1015-security-review.md`
  
- **Results (Output)**: `OUTPUT-{TYPE}-YYYY-MM-DD-HHmm-{DESCRIPTION}.md`
  - Example: `OUTPUT-audit-2026-04-17-1045-security-review.md`

- **Pipeline Steps**: `PIPELINE-{NAME}-{STEP}-INPUT.md` and `PIPELINE-{NAME}-{STEP}-OUTPUT.md`

### IDs
- **Audit Request**: `AUDIT-YYYY-MM-DD-HHmm`
- **Verify Request**: `VERIFY-YYYY-MM-DD-HHmm`
- **Review Request**: `REVIEW-YYYY-MM-DD-HHmm`
- **Analyze Request**: `ANALYZE-YYYY-MM-DD-HHmm`
- **Compare Request**: `COMPARE-YYYY-MM-DD-HHmm`
- **Fix Request**: `FIX-YYYY-MM-DD-HHmm`
- **Pipeline**: `PIPELINE-YYYY-MM-DD-HHmm`
- **Signal**: `SIGNAL-YYYY-MM-DD-HHmm`
- **Result**: `OUTPUT-YYYY-MM-DD-HHmm`

### Status Tracking
- **Request Status**: `pending` → `in_progress` → `complete`
- **Result Status**: `complete` | `incomplete` | `blocked`
- **Severity Emojis**: 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
- **Approval Icons**: ✅ Approved, 🔄 Needs Changes, ❌ Rejected

---

## Tips for Using Templates

1. **Copy, don't edit originals**: Always copy a template to a new file rather than modifying the template
2. **Customize sections**: Remove sections that don't apply to your use case
3. **Keep it clear**: Rewrite placeholder text to be specific to your context
4. **Link everything**: Always link requests to results and results back to requests
5. **Document decisions**: Explain not just "what" but "why" in recommendations and findings
6. **Prioritize findings**: Always sort by severity (Critical → High → Medium → Low)
7. **Estimate effort**: Include effort estimates in recommendations when applicable
8. **Sign off**: Always include executor name and date in sign-off section

---

## Template Statistics

| Template | Lines | Purpose |
|----------|-------|---------|
| audit.md | 104 | Code quality & security inspection |
| verify.md | 117 | Functionality & regression verification |
| review.md | 147 | Code review with decision criteria |
| analyze.md | 161 | Performance & metrics analysis |
| compare.md | 195 | Side-by-side comparison evaluation |
| fix.md | 194 | Bug fix request & execution |
| pipeline.md | 197 | Multi-step workflow coordination |
| signal.md | 212 | Emergency interrupt & resolution |
| result.md | 244 | Standard result delivery format |
| **Total** | **1,571** | **All templates combined** |

---

Last updated: 2026-04-17
