# Code Review Request Template

## Meta
- **ID**: `REVIEW-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `review`
- **Priority**: `high` | `medium` | `low`
- **Status**: `pending`
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to originating request)

---

## Scope

### What to Review
- **PR/Branch**: (branch name or PR link)
- **Files Changed**: (list of files modified)
- **Lines of Code**: (approximate number of changes)
- **Context**: (what feature/fix does this implement?)

### Related Context
- **Issue/Ticket**: (link to original issue)
- **Architecture Decision**: (if applicable)
- **Dependencies**: (external changes this depends on)
- **Out of Scope**: (explicitly exclude from review)

---

## Review Checklist

### Code Quality
- [ ] Functions are appropriately scoped (under 50 lines)
- [ ] Files are appropriately scoped (under 500 lines)
- [ ] Names are clear and consistent (variables, functions, classes)
- [ ] Code is DRY (no unnecessary duplication)
- [ ] Indentation and formatting consistent
- [ ] No unused variables or imports
- [ ] Comments explain "why", not "what"

### Security
- [ ] No hardcoded secrets (API keys, tokens, passwords, PII)
- [ ] Input validation on all external inputs
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities (if web-based)
- [ ] Authentication/authorization properly implemented
- [ ] No insecure dependencies added

### Testing
- [ ] Tests exist for new functionality
- [ ] Tests are meaningful (not just coverage cargo cult)
- [ ] All tests pass
- [ ] Edge cases have test coverage
- [ ] No test regressions

### Documentation
- [ ] Functions/classes have docstrings where needed
- [ ] Complex logic is explained
- [ ] API changes documented
- [ ] README updated (if applicable)
- [ ] Changelog entry added (if applicable)

### Architecture & Patterns
- [ ] Follows project conventions
- [ ] No anti-patterns introduced
- [ ] Error handling is consistent and complete
- [ ] Logging is appropriate
- [ ] Type safety maintained (if statically typed)

### Performance & Accessibility
- [ ] No obvious performance regressions
- [ ] Database queries reasonable (no N+1)
- [ ] No memory leaks apparent
- [ ] Accessibility standards met (if UI changes)

---

## Expected Output

### Review Decision
- **Status**: ✅ APPROVED | 🔄 NEEDS CHANGES | ❌ REJECTED
- **Confidence**: High | Medium | Low

### Findings Table
| File | Line(s) | Issue | Severity | Suggestion |
|------|---------|-------|----------|-----------|
| | | | | |
| | | | | |

### By Category

#### Critical Issues 🔴
(Must fix before merge)
1. 
2. 

#### High Priority 🟠
(Should fix before merge)
1. 
2. 

#### Medium Priority 🟡
(Nice to have)
1. 
2. 

#### Low Priority 🟢
(Style/consistency suggestions)
1. 
2. 

---

## Recommendations

### If APPROVED
- Ready to merge
- Merge strategy: (squash | rebase | merge commit)

### If NEEDS CHANGES
- Specific items that must be addressed
- Items that are optional/nice-to-have
- Re-review needed after changes

### If REJECTED
- Reason for rejection
- What needs to change for approval
- Whether partial progress is acceptable

---

## Reviewer Notes

- **Review Duration**: (time spent reviewing)
- **Reviewer**: (agent performing review)
- **Date Reviewed**: `YYYY-MM-DD HH:mm UTC`
- **Approved by**: (human lead/maintainer if required)
- **Comments/Context**: (any additional notes)

---

## Execution Details

- **Review Method**: Automated checks + manual review
- **Tools Used**: (linters, type checkers, etc.)
- **Test Results**: (pass/fail summary)
- **Blockers**: (any issues preventing approval)
