# Audit Request Template

## Meta
- **ID**: `AUDIT-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `audit`
- **Priority**: `high` | `medium` | `low`
- **Status**: `pending`
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to originating request, if any)

---

## Scope

### What to Inspect
- **Files/Modules**: (list specific files, directories, or modules)
- **Lines/Functions**: (optional: specific line ranges or function names)
- **Dependencies**: (what external systems/libraries are in scope?)
- **Out of Scope**: (explicitly exclude)

### Context
- **Previous findings**: (reference prior audits if applicable)
- **Known issues**: (things already identified)
- **Business context**: (why this audit matters now)

---

## Audit Checklist

### Code Quality
- [ ] Function length (under 50 lines?)
- [ ] File length (under 500 lines?)
- [ ] Naming conventions (clear, consistent?)
- [ ] Complexity (cyclomatic complexity acceptable?)
- [ ] Dead code (unused variables, functions?)
- [ ] Type safety (types explicit or inferable?)

### Security
- [ ] No hardcoded secrets (API keys, tokens, passwords)
- [ ] Input validation (all external inputs validated?)
- [ ] SQL injection vulnerabilities
- [ ] XSS vulnerabilities (if web/front-end)
- [ ] Authentication/authorization checks
- [ ] Dependency vulnerabilities (known CVEs?)

### Performance
- [ ] Database queries optimized (no N+1 problems?)
- [ ] API calls efficient (batch requests where applicable?)
- [ ] Memory leaks (proper cleanup/disposal?)
- [ ] CPU usage reasonable (no infinite loops?)
- [ ] Bundle size acceptable (if packaged code?)

### Patterns & Architecture
- [ ] Follows project conventions (naming, structure)
- [ ] No architectural anti-patterns detected
- [ ] Error handling consistent and complete
- [ ] Logging adequate (not too much, not too little)
- [ ] Testability (can this be tested easily?)

### Documentation
- [ ] Functions have docstrings/comments where needed
- [ ] Complex logic is explained
- [ ] API documentation current
- [ ] README updated (if new feature/module)

---

## Expected Output

### Findings by Severity
1. **Critical** 🔴: Must fix before merge/release
2. **High** 🟠: Should fix soon, impacts quality/security
3. **Medium** 🟡: Nice to fix, improves maintainability
4. **Low** 🟢: Suggestions for code style/consistency

### Required Details for Each Finding
- **Issue**: Clear description of the problem
- **Location**: File name, line number(s), function name
- **Code Reference**: (show the problematic code snippet)
- **Severity**: Critical | High | Medium | Low
- **Recommendation**: How to fix it (specific steps preferred)

### Summary Section
- Total findings by severity
- Most impactful issues (top 3)
- Overall code health assessment
- Estimated effort to remediate

---

## Execution Notes

- **Audit Duration**: (estimated time to complete)
- **Tools/Methods Used**: (static analysis, manual review, etc.)
- **Assumptions**: (what we're assuming about this code)
- **Limitations**: (what we couldn't audit and why)

---

## Approval & Sign-off
- **Auditor**: (agent performing audit)
- **Date Completed**: 
- **Approved by**: (human reviewer if required)
