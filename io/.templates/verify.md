# Verification Request Template

## Meta
- **ID**: `VERIFY-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `verify`
- **Priority**: `high` | `medium` | `low`
- **Status**: `pending`
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to originating request)

---

## Scope

### What to Verify
- **Feature/Component**: (what functionality is being verified?)
- **Files/Modules Involved**: (list relevant files)
- **Environment**: (dev | staging | production)
- **Dependencies**: (what must be in place for verification?)

### Context
- **Previous state**: (what was the system state before?)
- **Expected state**: (what should be true after changes?)
- **Trigger**: (what request/change prompted this verification?)

---

## Verification Checklist

### Functionality
- [ ] Core feature works as documented
- [ ] User workflows complete successfully
- [ ] Happy path executes without errors
- [ ] Invalid input handled gracefully
- [ ] Edge cases work (empty state, boundary values)
- [ ] Timeouts/retries function properly

### Testing
- [ ] Unit tests pass (100% coverage?)
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] No new test failures introduced
- [ ] Regression test coverage adequate

### Edge Cases & Error Handling
- [ ] Handles null/undefined inputs
- [ ] Handles large datasets
- [ ] Handles concurrent operations
- [ ] Error messages are clear and actionable
- [ ] Recovery from failure works

### No Regressions
- [ ] Existing functionality unchanged
- [ ] Performance not degraded
- [ ] No new warnings/errors in logs
- [ ] Backward compatibility maintained
- [ ] Related features still work

### UI/Visual (if applicable)
- [ ] Layout renders correctly
- [ ] Responsive design works (mobile, tablet, desktop)
- [ ] Accessibility standards met (contrast, focus states)
- [ ] No visual glitches or layout shifts

---

## Expected Output

### Pass/Fail Summary
| Item | Status | Notes |
|------|--------|-------|
| (Feature/test name) | PASS / FAIL | (details if failed) |
| | | |

### Test Results
- **Unit Tests**: X/Y passing
- **Integration Tests**: X/Y passing
- **E2E Tests**: X/Y passing
- **Overall**: PASS / FAIL

### Evidence
- Test execution logs (timestamp, results)
- Screenshots (before/after, if UI)
- Performance metrics (if measured)
- Browser console output (if web app)

### Issues Found
(If any tests failed or verification items are not met, list them here with severity)

### Sign-off
- **Verified by**: (agent performing verification)
- **Verification Status**: ✅ PASS | ❌ FAIL
- **Confidence Level**: High | Medium | Low
- **Date Verified**: `YYYY-MM-DD HH:mm UTC`

---

## Execution Notes

- **Verification Method**: Manual testing | Automated tests | Mixed
- **Environment**: (development, staging, production)
- **Test Data Used**: (describe test data, synthetic vs. real)
- **Duration**: (how long verification took)
- **Blockers**: (any issues preventing completion)

---

## Recommendations

If FAIL:
- [ ] Specific issues to fix
- [ ] Re-verification needed after fixes

If PASS:
- [ ] Ready to proceed to next stage
- [ ] Blockers for deployment/release (if any)
