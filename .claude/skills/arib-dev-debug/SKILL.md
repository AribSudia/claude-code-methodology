---
argument-hint: "<issue-description>"
description: Dev | Scientific debugging - observe, 3 hypotheses, test, fix, verify, document
---

# /arib-dev-debug Command

## Purpose
Activate scientific debugging protocol to systematically diagnose and fix issues using hypothesis testing, not guessing.

## Trigger
User types `/arib-dev-debug [description]`

Example: `/arib-dev-debug API timeout errors in user registration`

## Overview
Debugging is a science: observe behavior, form testable hypotheses, run experiments, narrow down root cause. Wild guesses waste hours. This protocol forces systematic thinking: 3 different hypotheses, test one at a time, gather evidence before moving on, prevent regression with tests.

## When to Use
- **User reports a bug** - Reproduce it first, then systematically diagnose
- **Tests are failing** - Don't rerun forever; identify WHY they fail
- **Feature works in one environment but not another** - Environment issue? Data? Config?
- **Intermittent bugs** - Use binary search to narrow down timing window
- **Production incident** - Rapid diagnosis to restore service

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

### Step 4: Hypothesis Formation Examples

#### Bug Category: State Issue

**Error:** Button state not updating after click

**Hypotheses:**
1. **State update not triggered** - onClick handler not firing (check DevTools event listener)
2. **State update lost in async** - async operation completes but state setter called on unmounted component
3. **Component not re-rendering** - state updated but React.memo or shouldComponentUpdate blocking

#### Bug Category: Timing Issue

**Error:** Request timeout, works sometimes but not always

**Hypotheses:**
1. **N+1 queries** - Each user.map() makes a DB query; 10 users = 10 queries (50ms each = 500ms total, hitting timeout)
2. **Network latency** - Endpoint is slow due to network, not code (trace backend performance)
3. **Race condition** - Request A starts, B starts before A finishes, B's result overrides A's (test with delays)

#### Bug Category: Data Issue

**Error:** User data shows as undefined in component

**Hypotheses:**
1. **API not called** - Component assumes data exists but never fetches it
2. **API call failed silently** - Fetch error not logged, component never gets data
3. **Race condition** - Component renders before API response arrives; missing null check

#### Bug Category: Config Issue

**Error:** Feature works locally but not in production

**Hypotheses:**
1. **Missing environment variable** - API_URL not set in prod, falls back to invalid default
2. **Different dependency versions** - Prod installed different version of package with breaking change
3. **Missing feature flag** - Feature disabled in prod environment, not in dev

### Step 4: Form Three Hypotheses (Detailed)
Based on the error and known patterns, form exactly 3 testable hypotheses:
1. **Hypothesis A**: [Specific, testable theory about what's wrong]
2. **Hypothesis B**: [Different angle or root cause]
3. **Hypothesis C**: [Third possibility based on context]

Document each hypothesis clearly with supporting evidence.

### Step 5: Hypothesis Testing Techniques

#### Binary Search Debugging (for timing/intermittent bugs)

```
Symptom: Request times out intermittently

1. Baseline: Measure time with no modifications
2. Split: Remove half the code/features
3. Measure: Does timeout still occur?
   ├─ YES (timeout with half): bug in remaining half, go to step 2
   └─ NO (no timeout): bug in removed half, restore and split again
4. Repeat until isolated to single function/query
```

#### Hypothesis Testing Order

1. **Add logging/debugging** to isolate the issue
   ```javascript
   // Before API call
   console.time('fetchUsers');
   const users = await fetch('/api/users');
   console.timeEnd('fetchUsers');
   // Output: fetchUsers: 234.5ms
   ```

2. **Create a minimal reproduction case**
   ```javascript
   // Isolated test case
   const test = async () => {
     const result = await problematicFunction(testData);
     console.log('Result:', result);
     console.assert(result.isValid, 'Expected result to be valid');
   };
   test();
   ```

3. **Verify the hypothesis with evidence**
   - Hypothesis 1: "N+1 queries" → Count DB queries in logs
   - Hypothesis 2: "Network latency" → Measure API response time with curl
   - Hypothesis 3: "Race condition" → Add delays, reproduce consistently

4. **If confirmed, proceed to fix**
5. **If not confirmed, move to next hypothesis**

Document findings after each test:
```
## Hypothesis A: State not updating
- Test: Added console.log in onClick handler
- Result: CONFIRMED - handler fires, but setState shows stale value
- Evidence: State updates but component not re-rendering
- Next: Check if component wrapped in React.memo
```

#### Debugging Tools by Language

| Language | Tool | Usage |
|----------|------|-------|
| **JavaScript** | DevTools Console | `console.log()`, breakpoints, debugger |
| **JavaScript** | Chrome DevTools Network | See API calls, latency, response |
| **TypeScript** | VS Code Debugger | Set breakpoints, step through code |
| **React** | React DevTools | Inspect component state, props, re-renders |
| **Node.js** | node --inspect | Remote debugging via Chrome DevTools |
| **Python** | pdb | `import pdb; pdb.set_trace()` |
| **Python** | logging | `logging.debug()` for production diagnostics |
| **SQL** | EXPLAIN PLAN | `EXPLAIN SELECT...` to see query performance |
| **Docker** | docker logs | `docker logs [container]` for service issues |

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

### Step 6: Regression Test Patterns

After fixing, add tests to prevent this bug from returning:

**Unit Test (test the specific fix):**
```javascript
test('user button click updates state', () => {
  const { getByText } = render(<UserButton />);
  fireEvent.click(getByText('Click me'));
  expect(getByText('Clicked!')).toBeInTheDocument();
});
```

**Integration Test (test the full flow):**
```javascript
test('user data loads and displays on page load', async () => {
  const { getByText } = render(<Dashboard />);
  await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
});
```

**Performance Test (if it was a perf issue):**
```javascript
test('fetch users completes in < 500ms', async () => {
  const start = performance.now();
  await fetchUsers();
  const duration = performance.now() - start;
  expect(duration).toBeLessThan(500);
});
```

### Step 7: Verify and Document

**Verification Checklist:**
- [ ] Minimal test case reproduces the original error
- [ ] Test case passes after fix applied
- [ ] Full test suite passes (no regressions)
- [ ] Manual testing confirms fix works in real scenario
- [ ] Bug documented in bugs_and_fixes.md
- [ ] Root cause explanation is clear to team

**Document in bugs_and_fixes.md:**
```markdown
## Bug: User registration timeout errors

**Original Error:** "API timeout during user registration"
**Frequency:** Intermittent, ~5% of registrations
**Discovered:** 2024-04-15
**Fixed:** 2024-04-16

### Root Cause
N+1 queries: User signup endpoint fetches all users to check email uniqueness.
With 1M users, query takes 500ms, hitting 1s timeout.

### Fix Applied
Added database index on email column, reducing query time to 10ms.
```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

### Tests Added
- Unit test: Verify email uniqueness check completes in < 50ms
- Integration test: Signup flow completes in < 1s with 1M existing users

### Prevention Strategy
- Performance budget: Email check < 100ms
- CI/CD: Run load test with 1M records before release
- Monitoring: Alert if email check exceeds 200ms in production
```

### Step 8: Commit Changes
Create a clear commit message:
```
git commit -m "Fix: API timeout during user registration

Root cause: N+1 queries on email uniqueness check
Fix: Added database index on email column
Tests: Unit test for email query latency, integration test for signup flow
Performance improvement: 500ms → 10ms per signup

Fixes issue #1234"
```

## Root Cause Analysis Template

```
## Issue Summary
[One sentence describing the problem]

## How to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Root Cause Categories (pick one)
- [ ] Code logic error (typo, wrong operator, missing check)
- [ ] State management (outdated state, stale closure)
- [ ] Async/timing (race condition, missing await)
- [ ] Resource leak (unclosed connection, memory leak)
- [ ] Configuration (wrong env var, missing setting)
- [ ] Dependency (outdated library, breaking change)
- [ ] Environment (works locally not prod, missing service)
- [ ] Performance (too slow, timeout, N+1 queries)

## Evidence
- Error message and stack trace
- When it was introduced (commit hash if known)
- Reproduction rate (always, 50%, rare)

## Solution
[Describe the fix in 1-2 sentences]

## Verification
- Test case added: YES / NO
- Verified in: local / staging / production
```

## Common Mistakes

1. **Fixing the symptom, not the cause** - Adding retry logic hides timeout; fixing N+1 query solves it
2. **Over-testing the fix** - If you test wrong thing, you won't know when it breaks again
3. **Not documenting why the bug happened** - Next developer will make same mistake
4. **Testing in isolation** - Bug may only appear under load; test with production-scale data
5. **No regression test** - Fix passes once, but breaks again with next change

## Edge Cases & Debugging Scenarios

| Scenario | Debugging Technique |
|----------|---|
| Intermittent bug | Binary search (disable features until it disappears) |
| Slow API | Measure: curl, DevTools network, APM traces |
| Memory leak | Monitor process memory over time, heap dump analysis |
| Silent failure | Add error logging, check error boundaries, network tab |
| Flaky test | Run 100x in a loop; if fails even once, it's a race condition |
| Different environments | Config diff (local vs prod), dependency versions, data volume |

## Related Skills
- `/arib-check-services` - Verify backend services running (not a code bug)
- `/arib-check-reality` - Is data actually coming from real API? (not a mock issue)
- `/arib-check-perf` - Is this a performance issue? (timing issues)

## Notes
- Never guess - test each hypothesis with evidence
- Document everything for the bugs_and_fixes.md knowledge base
- Hypotheses should be different approaches, not variations
- Always add regression tests
- Share findings to help future debugging efforts
- One hypothesis per iteration - no parallel testing
- Fastest debugging: measure/profile, don't estimate
