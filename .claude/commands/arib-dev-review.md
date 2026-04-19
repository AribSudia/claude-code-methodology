---
argument-hint: "<target-branch-or-path>"
description: Dev | Code review with quality gates - function length, duplication, security, tests
---

# /arib-dev-review Command

## Purpose
Perform comprehensive code review with quality gates to ensure high standards before merging.

## Trigger
User types `/arib-dev-review [file-or-branch]`

Examples: 
- `/arib-dev-review app.js`
- `/arib-dev-review feature/user-auth`

## Instructions

### Step 1: Activate CODE REVIEWER Agent Mode
Enter code review mode with focus on:
- Code quality and maintainability
- Security vulnerabilities
- Testing coverage
- Documentation completeness
- Performance implications

### Step 2: Check Function Length
Analyze function/method implementations:
- Functions should be <= 50 lines ideally
- Functions > 100 lines need justification
- Document any long functions found
- Flag functions that need refactoring

### Step 3: Check File Length
Analyze file sizes:
- Files should be <= 500 lines ideally
- Files > 1000 lines need strong justification
- Identify opportunities to split large files
- Document any oversized files

### Step 4: Check Code Duplication
Search for duplicated code:
- Identify duplicated logic blocks
- Flag similar patterns across files
- Suggest DRY principle improvements
- Note code that should be extracted to utilities

### Step 5: Security Review
Verify security practices:
- No hardcoded secrets (API keys, tokens, passwords)
- Input validation on all user inputs
- Authentication checks on protected routes
- SQL injection prevention (parameterized queries)
- XSS prevention (proper escaping/sanitization)
- CSRF token validation if applicable
- Environment variable usage for sensitive data

### Step 6: Testing Verification
Check test coverage:
- All functions have corresponding tests
- Edge cases are covered
- Error conditions are tested
- Integration tests exist where applicable
- Run test suite and verify all pass

### Step 7: Documentation Review
Verify documentation completeness:
- Functions have clear JSDoc/docstring comments
- Public APIs are documented
- Complex logic has explanatory comments
- README covers the changed functionality
- CHANGELOG is updated if this is a release

### Step 8: Generate Review Output
Present findings in one of two formats:

**APPROVED**
```
APPROVED - Ready to merge

Strengths:
- [Positive observations]

Suggestions (non-blocking):
- [Optional improvements]
```

**NEEDS CHANGES**
```
NEEDS CHANGES - Do not merge yet

Required Fixes:
1. [Issue 1 with specific location]
2. [Issue 2 with specific location]
3. [Issue 3 with specific location]

Optional Improvements:
1. [Suggestion 1]
2. [Suggestion 2]
```

## Notes
- Be thorough and specific with feedback
- Reference exact line numbers or file paths
- Suggest concrete improvements, not vague criticism
- Only approve when truly merge-ready
- Remember: good code is readable, tested, and secure
- Include both blocking and non-blocking feedback
