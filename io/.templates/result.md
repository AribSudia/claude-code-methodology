# Result Template

## Meta
- **Result ID**: `OUTPUT-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `result`
- **Related Request ID**: (link to INPUT request)
- **Request Type**: (audit | verify | review | analyze | compare | fix | etc.)
- **Executor**: (agent or person who performed the work)
- **Execution Date**: `YYYY-MM-DD HH:mm UTC`
- **Execution Duration**: (how long it took to complete)
- **Status**: `complete` | `incomplete` | `blocked`

---

## Executive Summary

(1-3 sentences summarizing the key findings and overall outcome)

### Quick Stats
- **Total Findings**: (number of issues/observations)
- **Critical**: 🔴 (count)
- **High**: 🟠 (count)
- **Medium**: 🟡 (count)
- **Low**: 🟢 (count)

### Overall Assessment
(One sentence conclusion: PASS/FAIL, APPROVED/REJECTED, READY/NOT READY, etc.)

---

## Findings by Severity

### Critical 🔴
(Issues that block progress or present serious risk)

1. **Finding**: (clear description)
   - **Location**: (file, line number, function)
   - **Impact**: (what's the consequence?)
   - **Recommendation**: (how to fix it)
   - **Code Reference**: (code snippet, 5-10 lines)
   ```
   (problematic code)
   ```

2. **Finding**: 
   - **Location**: 
   - **Impact**: 
   - **Recommendation**: 
   - **Code Reference**: 

---

### High 🟠
(Issues that should be addressed before merge/release)

1. **Finding**: (clear description)
   - **Location**: (file, line number, function)
   - **Impact**: (what's the consequence?)
   - **Recommendation**: (how to fix it)
   - **Effort**: (low | medium | high)

2. **Finding**: 
   - **Location**: 
   - **Impact**: 
   - **Recommendation**: 
   - **Effort**: 

---

### Medium 🟡
(Nice to fix, improves quality/maintainability)

1. **Finding**: (clear description)
   - **Location**: (file, line number)
   - **Recommendation**: (suggestion)
   - **Benefit**: (what improves if addressed)

2. **Finding**: 
   - **Location**: 
   - **Recommendation**: 
   - **Benefit**: 

---

### Low 🟢
(Style/consistency suggestions)

1. **Finding**: (clear description)
   - **Location**: (file, line)
   - **Suggestion**: (recommendation)

2. **Finding**: 
   - **Location**: 
   - **Suggestion**: 

---

## Code References Table

| File | Line(s) | Function | Issue | Severity | Status |
|------|---------|----------|-------|----------|--------|
| src/auth.js | 45-52 | validateToken() | No input sanitization | 🔴 Critical | Open |
| src/db.js | 120 | executeQuery() | Missing error handling | 🟠 High | Open |
| src/utils.js | 67-75 | formatDate() | Inconsistent formatting | 🟡 Medium | Open |
| tests/auth.test.js | 12 | test suite | Incomplete coverage | 🟢 Low | Open |

---

## Test Results (if applicable)

### Unit Tests
- **Total**: X tests
- **Passed**: X ✅
- **Failed**: X ❌
- **Skipped**: X ⏭
- **Coverage**: X%

### Integration Tests
- **Total**: X tests
- **Passed**: X ✅
- **Failed**: X ❌
- **Coverage**: X%

### End-to-End Tests
- **Total**: X tests
- **Passed**: X ✅
- **Failed**: X ❌
- **Coverage**: X%

---

## Performance Metrics (if applicable)

| Metric | Baseline | Current | Status | Notes |
|--------|----------|---------|--------|-------|
| Response Time (ms) | 150 | 145 | ✅ Improved | 3% faster |
| Memory (MB) | 512 | 520 | 🟡 Slight increase | Within limits |
| Bundle Size (KB) | 250 | 252 | 🟢 Acceptable | +2KB gzipped |

---

## Recommendations (Prioritized)

### Immediate Action (Critical - Must Fix)
1. **Fix authentication validation** in `src/auth.js:45-52`
   - Implement input sanitization on all token parameters
   - Add unit tests for edge cases
   - Estimated effort: 2-3 hours

2. **Add error handling** in database queries (`src/db.js:120`)
   - Wrap all DB calls in try-catch blocks
   - Implement retry logic for transient failures
   - Estimated effort: 3-4 hours

### Short-term (High - Should Fix)
3. **Complete test coverage** for critical paths
   - Current coverage: 65%
   - Target coverage: 85%
   - Estimated effort: 4-6 hours

4. **Update documentation** for new API endpoints
   - API docs are outdated
   - Add examples for each endpoint
   - Estimated effort: 2-3 hours

### Medium-term (Medium - Nice to Have)
5. **Refactor date formatting** for consistency
   - Consolidate 3 different date formats into 1
   - Estimated effort: 2-3 hours

### Long-term (Strategic)
6. **Consider architectural review** for scalability
   - System approaching limits at 10k concurrent users
   - Evaluate microservices migration
   - Estimated effort: 2-4 weeks (planning only)

---

## Blockers & Dependencies

### Blockers
(Are there any issues preventing full completion of this result?)

### Dependencies
(What external factors affect these findings?)

### Outstanding Questions
(What remains unclear or unresolved?)

---

## Verification Evidence

### Logs & Output
(Paste relevant logs, test output, or screenshots)

### Graphs/Charts
(If performance or metrics-based analysis, include visuals)

### Tool Output
(Linter results, profiler output, test report, etc.)

---

## Comparison to Previous Results (if applicable)

| Metric | Previous | Current | Change | Trend |
|--------|----------|---------|--------|-------|
| Critical Issues | 3 | 1 | ✅ -2 | Improving |
| Test Coverage | 65% | 72% | ✅ +7% | Improving |
| Performance | 150ms | 145ms | ✅ +3% | Improving |

---

## Next Steps

1. (What should happen with these findings?)
2. (Who needs to review/approve?)
3. (When should re-assessment happen?)
4. (Any follow-up work required?)

---

## Sign-off

- **Performed by**: (agent name/ID)
- **Date Completed**: `YYYY-MM-DD HH:mm UTC`
- **Review Status**: (awaiting review | approved | rejected)
- **Reviewed by**: (human reviewer, if required)
- **Approval Date**: 
- **Confidence Level**: High | Medium | Low
- **Retest Needed**: Yes | No
- **Retest Scheduled**: (date/time if yes)

---

## Link Back to Request
**Original Request**: [link to INPUT request file]

---

## Notes & Observations
(Any additional context, assumptions, or observations?)
