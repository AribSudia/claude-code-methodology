---
argument-hint: "<issue-description>"
description: Dev | Scientific debugging - observe, 3 hypotheses, test, fix, verify, document
---

# /arib-dev-debug Command

## Purpose
Activate scientific debugging protocol to systematically diagnose and fix issues.

## Trigger
User types `/arib-dev-debug [description]`

Example: `/arib-dev-debug API timeout errors in user registration`

## Instructions

### Step 1: Activate DEBUGGER Agent Mode
Enter focused debugging mode. Set context to:
- "I am operating as a DEBUGGER agent"
- Systematic hypothesis testing
- Evidence-based root cause analysis
- Minimal assumptions

### Step 2: Extract and Document Error Message
Obtain the exact error message:
- If from logs: Copy the full stack trace or error output
- If from reproduction: Run the scenario and capture exact output
- Document the exact conditions that trigger the error
- Note when the error started (if known)

### Step 3: Consult Known Patterns
Read and analyze:
1. `bugs_and_fixes.md` - Search for similar error patterns
2. `ERROR_PATTERNS.md` - Check for known pitfalls in this area of code
3. Look for matching keywords in error patterns

### Step 4: Form Three Hypotheses
Based on the error and known patterns, form exactly 3 testable hypotheses:
1. **Hypothesis A**: [Specific, testable theory about what's wrong]
2. **Hypothesis B**: [Different angle or root cause]
3. **Hypothesis C**: [Third possibility based on context]

Document each hypothesis clearly with supporting evidence.

### Step 5: Test Hypotheses Systematically
Test one hypothesis at a time in this order:
1. Add logging/debugging to isolate the issue
2. Create a minimal reproduction case
3. Verify the hypothesis with evidence
4. If confirmed, proceed to fix
5. If not confirmed, move to next hypothesis

Document findings after each test.

### Step 6: Implement Fix
Once root cause is confirmed:
- Write the minimal fix addressing the root cause
- Add tests to prevent regression
- Verify the fix doesn't introduce new issues
- Test related functionality

### Step 7: Verify and Document
- Run full test suite to ensure no regressions
- Update `bugs_and_fixes.md` with:
  - Original error description
  - Root cause identified
  - Fix applied
  - Tests added
  - Prevention strategy for future

### Step 8: Commit Changes
Create a clear commit message:
```
git commit -m "Fix: [Brief description of issue]

Root cause: [One line explanation]
Fix: [What was changed]
Tests: [Which tests verify the fix]"
```

## Notes
- Never guess - test each hypothesis with evidence
- Document everything for the bugs_and_fixes.md knowledge base
- Hypotheses should be different approaches, not variations
- Always add regression tests
- Share findings to help future debugging efforts
- One hypothesis per iteration - no parallel testing
