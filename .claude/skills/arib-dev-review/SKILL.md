---
name: arib-dev-review
argument-hint: "<target-branch-or-path>"
description: "Dev | Code review with quality gates — function length, duplication, security, tests"
---

# Code Review — /arib-dev-review

## Overview

A code review is your **last gate before merge**. It's the moment to catch bugs, security issues, poor design decisions, and undocumented code before they hit your codebase. This skill transforms Claude into a **CODE REVIEWER agent** that applies eight quality gates systematically.

Why this matters: Code reviews prevent cascading failures. A 10-minute review that catches a security vulnerability saves hours of incident response later. A review that enforces function length limits prevents the 500-line monoliths that slow down future developers. This methodology ensures every merge maintains standards.

Claude Code acts as the CODE REVIEWER during this skill — thorough, specific, and fair.

## Parallel Dispatch (v3.2 "Honest")

For non-trivial diffs (>5 files, or any change touching auth/payment/data
boundaries), open the review by dispatching three subagents **in a single
message** — all in parallel — instead of running the gates sequentially.

```text
Task(code-reviewer)        — runs Gates 1-4 (structure, maintainability)
Task(security-auditor)     — runs Gate 5 (security) deeper than this skill alone
Task(test-engineer, mode=report-only)
                           — runs Gate 7 (tests) deeper than this skill alone
```

All three are read-only on the diff and write nothing to disk. Per
`architecture/AGENT_ARCHITECTURE.md`, this fan-out is parallel-safe.

**Merge their findings:** wait for all three reports, then write the unified
review report yourself. Conflicts (one agent says ship, another blocks) are
resolved by the more conservative call — when in doubt, block.

Wall-clock: ~90 seconds parallel vs. ~5–10 minutes sequential.

**When NOT to fan out:**
- Single-file or trivial diffs — overhead exceeds the saving.
- Diffs that include test-engineer asking to *write* tests, not report on
  them. In that case run reviewer + security in parallel, then test-engineer
  sequentially with the merged findings as input.
- Refactor-specialist work in flight — never overlap a fan-out review with an
  agent that's actively rewriting files.

## When to Use

- **Before merging any feature branch** into develop or main
- **When reviewing a specific file** for quality or correctness  
- **Before deploying to staging or production** (final sanity check)
- **When onboarding to unfamiliar code** (review acts as guided learning)
- **After a pair-programming session** (fresh eyes on the code)
- **When a collaborator requests review** on a specific feature

## Input Modes

Use the skill with different targets:

```bash
# Review all changes on a branch vs develop
/arib-dev-review feature/user-auth

# Review a specific file
/arib-dev-review src/auth/login.ts

# Review all uncommitted changes
/arib-dev-review .

# Review a specific commit range
/arib-dev-review develop..HEAD
```

---

## Review Protocol — 8 Gates

Each gate is a checkpoint. Gates 1–4 focus on structure and maintainability. Gates 5–7 focus on safety and reliability. Gate 8 is your final verdict.

### Gate 1: Scope Assessment

**Before diving into code, understand what changed.**

Scope creep is the enemy of good reviews. If a PR changes 50 files and 2000 lines, it's hard to review carefully. Scope assessment tells you whether this is focused work or something that needs splitting.

**Commands to run:**
```bash
# For branch review
git diff develop...[branch] --stat
git log develop...[branch] --oneline

# For file review  
git diff HEAD -- [file] --stat

# For uncommitted changes
git status --short
git diff --stat
```

**Assessment matrix:**

| Files Changed | Lines Changed | Verdict | Action |
|---------------|---------------|---------|--------|
| 1–5 | <200 | ✅ Focused | Proceed with full review |
| 5–15 | 200–500 | ⚠️ Moderate | Section-by-section review |
| 15–30 | 500–1000 | 🔶 Large | Review in logical groups, flag for splitting if not necessary |
| 30+ | 1000+ | ❌ Too Large | Request developer to split PR into smaller, logical units |

**Example verdict:** "This branch changes 8 files with 350 lines added. This is a focused, reviewable change. Proceeding with full review."

---

### Gate 2: Function Length Analysis

**Scan all changed and new functions for excessive length.**

Long functions are a code smell. They do too much, are hard to test, hard to understand, and hard to reuse. This gate enforces function length discipline.

**How to check:**
1. Read each modified/added file
2. Identify every function/method definition
3. Count lines from function start to end (exclude blank lines and comments)
4. Note the line number range

**Length thresholds:**

| Length | Verdict | Action |
|--------|---------|--------|
| ≤30 lines | ✅ Excellent | No action needed |
| 31–50 lines | ⚠️ Acceptable | Note in review; acceptable if well-structured |
| 51–100 lines | 🔶 Needs Justification | Require comment explaining complexity; suggest refactor plan |
| >100 lines | ❌ Blocking | Cannot merge; must refactor into smaller functions |

**Bad example — 120-line function:**
```typescript
// ❌ Too long — does validation, processing, and logging all at once
function processUserRegistration(userData, emailService, database) {
  // ... 120 lines of mixed concerns ...
}
```

**Good refactor — broken into focused functions:**
```typescript
// ✅ Each function has one clear job
function validateUserData(userData) { /* 12 lines */ }
function createUserRecord(userData, database) { /* 18 lines */ }
function sendWelcomeEmail(user, emailService) { /* 15 lines */ }
function processUserRegistration(userData, emailService, database) {
  const validated = validateUserData(userData);
  const user = createUserRecord(validated, database);
  sendWelcomeEmail(user, emailService);
}
```

**Note:** If a function is long but justified (e.g., complex parsing algorithm), require an inline comment: `// This is 85 lines because it handles 7 different document formats. Refactoring would harm readability.`

---

### Gate 3: File Length Analysis

**Check if individual files are growing too large.**

Large files are hard to navigate, test, and maintain. If a file exceeds 1000 lines, it's doing too much. Split it.

**How to check:**
- Count total lines in each modified file (use `wc -l`)
- Compare against thresholds below

**Length thresholds:**

| File Size | Verdict | Action |
|-----------|---------|--------|
| ≤300 lines | ✅ Excellent | No action |
| 301–500 lines | ⚠️ Acceptable | Monitor; watch for future growth |
| 501–1000 lines | 🔶 Needs Justification | Require split plan; suggest refactoring |
| >1000 lines | ❌ Blocking | Must split into logical modules before merge |

**Example split plan:**
```
src/auth.ts (800 lines) → Split into:
  ├─ auth/tokens.ts (140 lines) — token generation/validation
  ├─ auth/login.ts (160 lines) — login flow
  ├─ auth/password.ts (120 lines) — password reset/hashing
  └─ auth/index.ts (30 lines) — exports
```

---

### Gate 4: Duplication Detection

**Find copy-pasted code and repeated patterns.**

Duplication violates DRY (Don't Repeat Yourself). When you fix a bug in duplicated code, you have to fix it in five places. Duplication compounds maintenance cost. This gate finds and eliminates it.

**What to look for:**

1. **Copy-pasted blocks** (5+ lines of identical/near-identical code)
2. **Repeated business logic** across files (same validation, same formatting, same calculation)
3. **Utility functions that should be extracted** (multiple files doing `formatDate`, `parseQuery`, etc.)
4. **Existing solutions in the codebase** (don't rewrite, reuse)

**Search strategy:**
- Scan new/modified files for obvious copy-paste
- Use your IDE's "find similar code" features
- Check git blame for when the duplicated code first appeared
- Look at utility folders (`utils/`, `helpers/`, `lib/`) for existing solutions

**Bad duplication example:**
```typescript
// File: src/payment/stripe.ts
function formatPrice(cents) {
  return '$' + (cents / 100).toFixed(2);
}

// File: src/invoice/generator.ts  
function formatPrice(amt) {
  return '$' + (amt / 100).toFixed(2);
}

// File: src/reports/export.ts
const formatPrice = (p) => '$' + (p / 100).toFixed(2);
```

**Good fix — extract to shared utility:**
```typescript
// File: src/utils/format.ts
export function formatPrice(cents) {
  return '$' + (cents / 100).toFixed(2);
}

// Now import in all three files:
import { formatPrice } from '../utils/format';
```

**Verdict format:** "Found 3 instances of date formatting logic. Extract to `utils/format.ts` and import."

---

### Gate 5: Security Review

**Verify that code doesn't introduce security vulnerabilities.**

Security is not optional. This gate checks for hardcoded secrets, input validation gaps, auth bypass, and injection vulnerabilities.

**Checklist by category:**

#### Secrets & Credentials
- [ ] No API keys hardcoded in code (check for patterns like `apiKey: "sk-..."`)
- [ ] No database passwords in code
- [ ] No tokens or auth secrets in commits
- [ ] `.env` files not checked in; use `.env.example` instead
- [ ] Sensitive data comes from environment variables only

**Search for:**
```
password = "
apiKey: "
secret: "
token = "
-----BEGIN PRIVATE KEY
credentials: {
AWS_SECRET_ACCESS_KEY
DATABASE_PASSWORD
```

#### Input Validation
- [ ] All user-supplied input is validated before use
- [ ] File uploads have type/size checks
- [ ] URL parameters are decoded and validated
- [ ] Query parameters sanitized before use in logic
- [ ] Numeric inputs checked for valid ranges

#### Database Security
- [ ] All SQL queries use parameterized statements (no string concatenation)
- [ ] Never concatenate user input into SQL: `❌ query("SELECT * FROM users WHERE id = " + userId)`
- [ ] Use placeholders: `✅ query("SELECT * FROM users WHERE id = ?", [userId])`

#### Authentication & Authorization
- [ ] Protected routes have auth middleware attached
- [ ] Sensitive operations check user permissions (role-based access)
- [ ] Session/JWT tokens have expiry times set
- [ ] No auth bypass in error handlers (e.g., "user not found" error leaks info)
- [ ] Rate limiting on auth endpoints to prevent brute force

#### Cross-Site Vulnerabilities
- [ ] User input is escaped before rendering in HTML/JSX
- [ ] CSRF tokens present on state-changing mutations
- [ ] No `dangerouslySetInnerHTML` with user data
- [ ] Query parameters decoded but not trusted as-is

#### API Security
- [ ] Sensitive endpoints require authentication
- [ ] API keys rotated regularly (not hardcoded)
- [ ] No sensitive data in error responses (stack traces, query strings)
- [ ] Rate limiting and throttling in place

**Vulnerability severity reference:**

| Vulnerability | Example | Severity |
|---------------|---------|----------|
| SQL Injection | `SELECT * FROM users WHERE id = " + userId` | CRITICAL |
| Hardcoded Secret | `apiKey: "sk-live-abc123"` | CRITICAL |
| XSS via innerHTML | `element.innerHTML = userInput` | HIGH |
| Missing Auth | GET `/admin/users` with no auth check | HIGH |
| Path Traversal | `readFile(userPath)` without validation | HIGH |
| CSRF missing | POST `/api/transfer` with no token | MEDIUM-HIGH |
| Known CVE | `npm audit` shows dependency with CVE | MEDIUM-HIGH |
| Information Leak | Stack trace in API response | MEDIUM |

**Example verdict:** "Found hardcoded API key on line 42 of `services/payment.ts`. CRITICAL — move to `.env` and use `process.env.STRIPE_KEY`. Cannot merge until fixed."

---

### Gate 6: Test Coverage Verification

**Ensure new code is tested and tests are meaningful.**

Untested code breaks in production. But tests can be fake (tests that don't actually test anything). This gate verifies coverage is real.

**Checklist:**

- [ ] Every new function has a corresponding test
- [ ] Tests cover happy path AND error cases
- [ ] Edge cases tested (null, empty, boundary values, -1, 0, max int, etc.)
- [ ] Integration tests exist for new API endpoints
- [ ] Tests are independent (one test failure doesn't cascade)
- [ ] Test suite passes: `npm test` or equivalent
- [ ] Tests use descriptive names, not vague ones
- [ ] Mocks are used sparingly; real objects where feasible

**Test quality rules:**

| Pattern | Verdict |
|---------|---------|
| `expect(result).toBeDefined()` | ❌ Doesn't test anything meaningful |
| `expect(() => func()).not.toThrow()` | ⚠️ Minimal; tests existence not correctness |
| `expect(result).toBe(42)` | ✅ Tests actual behavior |
| `should handle null input gracefully` | ✅ Good test name |
| `test('should work')` | ❌ Vague; what should work? |
| Mocking external API in unit test | ✅ Correct |
| Mocking internal helper function | ❌ Tests are too tightly coupled |

**Example assessment:**
```typescript
// ❌ Bad test — doesn't verify correct behavior
test('calculateTotal works', () => {
  const result = calculateTotal([10, 20, 30]);
  expect(result).toBeDefined();
});

// ✅ Good test — verifies correctness and edge case
test('calculateTotal sums array of numbers', () => {
  expect(calculateTotal([10, 20, 30])).toBe(60);
});

test('calculateTotal returns 0 for empty array', () => {
  expect(calculateTotal([])).toBe(0);
});
```

**Verdict format:** "Test coverage for new `authMiddleware` function is incomplete. Missing: expired token case, invalid signature case. Require additional tests before merge."

---

### Gate 7: Documentation Review

**Verify that code changes are documented.**

Undocumented code forces future readers to reverse-engineer your intent. This gate ensures code is self-explanatory and documentation is updated.

**Checklist:**

- [ ] New public functions have JSDoc/docstring comments
- [ ] Complex logic has inline comments explaining **WHY**, not **WHAT**
- [ ] API changes documented in `API_ENDPOINTS.md` (if applicable)
- [ ] README updated if user-facing behavior changed
- [ ] CHANGELOG updated with release-worthy features
- [ ] Deprecated functions marked with deprecation notices
- [ ] Performance-critical sections explained (if non-obvious)

**Good vs. bad comments:**

```typescript
// ❌ Bad — just states what the code does (reader can see that)
const users = data.filter(x => x.active); // Filter active users

// ✅ Good — explains why and the business context
// Filter to active users only; inactive accounts lose access after 90 days (compliance req)
const users = data.filter(x => x.active);

// ❌ Bad — comment doesn't help
x = x + 1; // Increment x

// ✅ Good — explains the non-obvious logic
// Retry 3x because the payment API returns transient 503 errors during peak hours (4-6 PM PT)
const maxRetries = 3;
for (let i = 0; i < maxRetries; i++) {
  try {
    return await chargeCard(amount);
  } catch (err) {
    if (i === maxRetries - 1) throw err;
    await sleep(1000 * (i + 1)); // Exponential backoff
  }
}
```

**JSDoc template:**
```typescript
/**
 * Validates user registration data.
 * @param {Object} userData - User data to validate
 * @param {string} userData.email - User email address
 * @param {string} userData.password - Password (min 8 chars, must include number)
 * @returns {Object} { isValid: boolean, errors: string[] }
 * @throws {TypeError} If userData is null or not an object
 */
function validateUser(userData) { }
```

**Verdict format:** "New `calculateShippingCost` function lacks JSDoc and has complex multi-step calculation without explanation. Require documentation before merge."

---

### Gate 8: Final Verdict

After all gates, render one of two verdicts.

#### Verdict: APPROVED ✅

Use when ALL gates pass, or only have minor, non-blocking suggestions.

```markdown
## Review: APPROVED ✅

**Branch**: feature/user-auth
**Files Changed**: 6 files, +142 lines / -8 lines
**Tests**: All passing (18 tests, 100% coverage for new code)

### Strengths
- Clean separation of concerns — validation, auth logic, and storage are in separate modules
- Comprehensive test coverage including edge cases (expired tokens, invalid signatures, malformed requests)
- Excellent use of environment variables for secrets; no hardcoded API keys
- Clear inline comments explaining the retry logic for external API calls
- Password hashing uses industry-standard bcrypt with salt rounds = 12

### Suggestions (non-blocking)
- Consider extracting token validation logic to `auth/validate.ts`; currently mixed with refresh logic
- Add `@deprecated` notice to old `authenticateUser` function; consumers should migrate to new `authenticate` within 2 releases

**Recommendation**: Ready to merge into develop. No blockers.
```

#### Verdict: NEEDS CHANGES ❌

Use when ANY gate has blocking issues. List them specifically with file:line references.

```markdown
## Review: NEEDS CHANGES ❌

**Branch**: feature/user-auth
**Blocking Issues**: 4 issues found

### Required Fixes (must address before merge)

1. **Gate 5 — Security | Hardcoded API Key**
   Location: `src/services/stripe.ts:17`
   Issue: Stripe secret key hardcoded as `const API_KEY = "sk-live-abc123"`. This will be exposed in version control and built artifacts.
   Fix: Move to `.env` file and load via `process.env.STRIPE_SECRET_KEY`

2. **Gate 6 — Testing | Missing Error Case**
   Location: `src/auth/login.ts` + tests
   Issue: `login()` function tests happy path but not "user not found" or "wrong password" cases. These are critical flows.
   Fix: Add tests for invalid credentials, account locked scenarios, and database connection failures.

3. **Gate 2 — Function Length**
   Location: `src/auth/register.ts:34–152` (118 lines)
   Issue: `registerUser()` function exceeds 100-line limit. Currently handles validation, user creation, email sending, and logging all in one function.
   Fix: Refactor into: `validateRegistration()`, `createUser()`, `sendWelcomeEmail()`, `logSignup()`. Each should be <50 lines.

4. **Gate 4 — Duplication**
   Location: `src/auth/login.ts:45` and `src/auth/passwordReset.ts:82`
   Issue: Identical password hashing logic appears twice. Should be extracted.
   Fix: Create `src/utils/crypto.ts` with `hashPassword()` and `verifyPassword()` functions. Import in both files.

### Suggestions (non-blocking)
- Add JSDoc comments to `verifyToken()` function; currently lacks parameter documentation
- Consider adding rate limiting to `/api/login` endpoint to prevent brute force attacks (not critical but recommended)

**Next Step**: Fix the 4 blocking issues, commit, and request re-review.
```

---

## Severity Classification

Use this scale when rating issues:

| Level | Meaning | Action |
|-------|---------|--------|
| 🔴 CRITICAL | Security vulnerability, data loss risk, or impossible to use | **Block merge** — fix immediately, no exceptions |
| 🟠 HIGH | Bug, missing security check, fails constraints, untested code | **Block merge** — must be fixed before merging |
| 🟡 MEDIUM | Code quality issue, missing docs, should refactor | **Should fix** — can merge with written plan to address soon |
| 🟢 LOW | Style preference, minor suggestion, polish | **Optional** — mention in feedback, up to developer |

---

## Common Review Patterns & Red Flags

### Pattern: "Works But Wrong"
Code that passes tests but violates architecture:
- Using a non-approved library (check `TECH_STACK.md`)
- Putting business logic in the wrong layer (e.g., business logic in a route handler)
- Hardcoding values that should be in config/environment
- **Action:** Require refactor to match architecture. This is a MEDIUM or HIGH issue.

### Pattern: "Test Theater"
Tests that look good but test nothing meaningful:
```javascript
test('should work', () => {
  const result = doSomething();
  expect(result).toBeDefined(); // Proves nothing
});
```
Tests that pass regardless of correctness:
- Tests with no assertions
- Tests that stub everything but verify no behavior
- Tests that check type, not value
- **Action:** Require real tests that verify behavior. Block merge.

### Pattern: "Hidden Dependency"
Code that works now but creates implicit coupling:
- Importing from deep internal modules of another feature
- Relying on execution order of side effects
- Using global state
- **Action:** Flag as architectural debt. Can merge with documentation but require refactor in next sprint.

### Pattern: "Premature Optimization"
Code that optimizes something that isn't slow:
- Complex caching logic for rarely-called functions
- Premature concurrency that adds complexity
- **Action:** Suggest simplify first, optimize if profiling shows bottleneck. LOW issue.

---

## Edge Cases

### Reviewing Your Own Code
When Claude Code reviews code it produced earlier in same session:
- Apply the same standards — no self-bias toward your own work
- Pay extra attention to Gate 5 (security); easy to miss in your own code
- If you find issues, acknowledge them cleanly: "I missed validation here; adding fix now"

### Large PRs (>500 lines)
- Suggest splitting if logically separable
- If not splittable, review file-by-file and give verdict per file
- Aggregate final verdict: "File A approved, File B approved, File C needs changes"

### Reviewing Code From Pair Session
You have context (you helped write it), but review objectively:
- Don't give credit for partial work
- Don't lower standards because you remember the decision-making
- Review as if you're seeing it fresh

### Third-Party Dependencies
If PR adds a new library:
- Is it in `TECH_STACK.md` (approved)?
- Does it duplicate existing capability?
- Does it have known vulnerabilities (run `npm audit`)?
- Is it actively maintained?
- **Action:** Require justification for new dependencies.

---

## Related Skills

- `/arib-dev-feature` — The skill that produces code for review
- `/arib-check-perf` — Performance-specific review gate
- `/arib-check-a11y` — Accessibility-specific review gate  
- `/arib-check-deps` — Dependency security and audit review

---

## Quick Reference

**Gate sequence order:**
1. Scope Assessment → 2. Function Length → 3. File Length → 4. Duplication → 5. Security → 6. Tests → 7. Documentation → 8. Verdict

**Common blocking issues:**
- Hardcoded secrets (CRITICAL)
- Functions >100 lines (HIGH)
- Missing test coverage on new code (HIGH)
- SQL injection vulnerability (CRITICAL)
- Unvalidated user input (HIGH)
- Duplicate code (MEDIUM)

**Non-blocking but recommend:**
- JSDoc missing (LOW-MEDIUM)
- Inline comments lacking (LOW-MEDIUM)
- Code style inconsistency (LOW)
- README not updated (MEDIUM)
