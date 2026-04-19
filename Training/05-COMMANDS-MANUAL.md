# Claude Code Methodology v2.6.0 — Commands Manual

## Complete Reference for All 14 Slash Commands

This manual documents every command in the CCM slash command suite, with syntax, use cases, execution flow, examples, and best practices.

---

## 1. /session-start

### Syntax
```
/session-start
```

### Purpose
Initialize a new CCM session with full context loading, constraint validation, and I/O channel setup. Verifies all prerequisites before proceeding.

### When to Use
- Beginning a new work session on any project
- Returning to a project after a break
- Starting paired work (Cowork + Claude Code)
- Need full context awareness before making changes

### What Happens Step-by-Step

1. **Load CLAUDE.md** — Reads project metadata: project name, tech stack, architecture overview, key files
2. **Load Constraints** — Reads CONSTRAINTS.md: architectural decisions, coding standards, no-go zones, approved patterns
3. **Load Tech Stack** — Reads TECH_STACK.md: frameworks, versions, dependencies, tooling
4. **Load Context Map** — Reads context-map.md: component relationships, data flow, integration points
5. **Load Error Patterns** — Reads error-patterns.md: known failure modes, mitigation strategies
6. **Load Memory Files** — Reads all .mem files in memory/ directory (session state, decisions, lessons learned)
7. **Check Git Status** — Runs `git status`, `git log --oneline -5` to verify clean state and recent history
8. **Validate I/O Channel** — Checks io/ directory structure, lists pending requests/signals
9. **Report Current State** — Outputs summary: project name, tech stack, current branch, pending work, any open signals
10. **Wait for Confirmation** — Prompts user to confirm ready to proceed

### Example Session

```
$ /session-start

═══════════════════════════════════════════════════════════════════
  CLAUDE CODE METHODOLOGY v2.6.0 — SESSION INITIALIZING
═══════════════════════════════════════════════════════════════════

📦 PROJECT CONTEXT
   Name: Acme Dashboard
   Root: /workspace/acme-dashboard
   Last Updated: 2026-04-15

🔧 TECH STACK
   Frontend: React 19.0 + TypeScript + Tailwind CSS
   Backend: Node.js 22 + Express + PostgreSQL 15
   Testing: Jest + Vitest + Cypress
   CI/CD: GitHub Actions

📋 CONSTRAINTS LOADED (5 active)
   ✓ No direct DOM manipulation (use React hooks)
   ✓ All async ops wrapped in try-catch
   ✓ No hardcoded URLs (use env config)
   ✓ Tests required for new features (min 80% coverage)
   ✓ Security review mandatory for auth changes

🗺️  CONTEXT MAP
   Components: 47 (12 containers, 35 presentational)
   Services: 8 (auth, api, storage, notifications, etc.)
   Data Flow: Redux store → selectors → components

🧠 MEMORY LOADED
   session_notes.mem — Last session: "Implemented user auth flow, found N+1 in reports"
   decisions.mem — 12 active decisions (last: "Use UUID v7 for all IDs")
   lessons.mem — 8 lessons from recent debugging sessions

📊 GIT STATUS
   Branch: feature/dashboard-redesign
   Last 5 commits:
     abc1234 (2m ago) feat: add user profile card
     def5678 (1h ago) style: update color palette
     ghi9012 (3h ago) fix: resolve modal z-index issue
     jkl3456 (1d ago) chore: upgrade React to 19
     mno7890 (2d ago) feat: implement dark mode toggle
   
   Status: CLEAN (no uncommitted changes)

🔌 I/O CHANNEL STATUS
   Pending Requests: 1
     - verify-auth-security-2026-04-18-001.md (CRITICAL, 2h old)
   Open Signals: None
   Active Pipelines: 1 (pre-release-security)
   Threads: 2 (from previous sessions)

═══════════════════════════════════════════════════════════════════

✅ All prerequisites validated. Session ready.

Ready to proceed? (yes/no)
> yes

SESSION INITIALIZED
Current context: Acme Dashboard | main codebase | 12 pending tasks in queue
```

### Tips and Best Practices

- **Run at every session start** — Even if you were just here, context resets between conversations. Always run /session-start.
- **Check pending I/O before proceeding** — If there are CRITICAL or HIGH signals, address those first.
- **Review constraints** — Spend 30 seconds re-reading the project constraints to avoid violations.
- **Use memory recall** — Skim session_notes.mem to pick up where you left off.
- **Clean git state required** — If git status shows uncommitted changes, commit or stash before proceeding.

---

## 2. /session-end

### Syntax
```
/session-end
```

### Purpose
Close the current session with memory persistence, changelog updates, and final push to remote. Ensures no context is lost.

### When to Use
- Ending work session (before logging off)
- Handing off to another team member
- Wrapping up a feature branch
- Preparing for deployment

### What Happens Step-by-Step

1. **Save Session Notes** — Updates memory/session_notes.mem with summary of work completed, decisions made, blockers
2. **Update Project Status** — Updates memory/project_status.mem with current state, open branches, deployment readiness
3. **Update Changelog** — Appends CHANGELOG.md with entries for each commit since session start
4. **Generate Memory Summary** — Creates timestamped entry in memory/archive with session overview
5. **Commit Changes** — Runs `git add -A && git commit -m "chore: session-end $(date)"`
6. **Push to Remote** — Runs `git push origin $(current-branch)`
7. **Final Report** — Outputs session summary with metrics: files changed, lines added/removed, commits, test status

### Example Session

```
$ /session-end

═══════════════════════════════════════════════════════════════════
  SESSION CLOSING — MEMORY & PERSISTENCE
═══════════════════════════════════════════════════════════════════

📝 SAVING SESSION NOTES
   Added to memory/session_notes.mem:
   - Completed user profile card component (2 reviews, all tests passing)
   - Fixed modal z-index regression (root cause: Tailwind specificity)
   - Discovered N+1 in reports endpoint (logged as ISSUE-482)
   - Refactored auth context to use useCallback (10% perf gain)
   - Blockers: waiting on design team for avatar mockups

📊 UPDATING PROJECT STATUS
   Current State:
   - Active Branch: feature/dashboard-redesign
   - Test Coverage: 84% (target: 80%, ✓ passing)
   - Deployment Ready: No (2 bugs, 1 design blocker)
   - Next: Code review with @alice, deploy to staging

📋 CHANGELOG UPDATED
   [2026-04-18]
   - feat: add user profile card with avatar + bio
   - fix: resolve modal z-index regression (#482)
   - refactor: optimize auth context with useCallback
   - chore: update test snapshots

🔄 COMMITTING & PUSHING
   [feature/dashboard-redesign abc1def] chore: session-end 2026-04-18T16:45:00Z
   5 files changed, 142 insertions(+), 38 deletions(-)
   
   Pushing to origin/feature/dashboard-redesign... ✓ 1 new commit

═══════════════════════════════════════════════════════════════════

✅ SESSION SUMMARY
   Duration: 3h 22m
   Files Modified: 5
   Lines Added: 142
   Lines Removed: 38
   Commits Created: 3
   Tests Added: 4
   Test Status: ✓ All passing (84% coverage)
   Memory Saved: ✓ Session archived for recall

Ready for next session!
```

### Tips and Best Practices

- **Run before every logout** — Memory loss is the #1 session-end mistake.
- **Review your notes before saving** — The notes you write become context for your future self. Be specific: what worked, what didn't, what's next.
- **Ensure tests pass** — If tests fail, fix them before /session-end (don't push broken code).
- **Update CHANGELOG** — Be descriptive in entries. Future readers (including you) need to understand what changed and why.
- **Verify push succeeded** — Check that git output shows "1 new commit" or similar. If push fails, resolve before ending session.

---

## 3. /new-feature [name]

### Syntax
```
/new-feature [feature-name]
```

### Purpose
Create a new feature branch with RED→GREEN→REFACTOR TDD cycle. Generates safety snapshot, establishes scaffolding, and guides development.

### When to Use
- Starting a new feature (not a bug fix)
- Following TDD discipline
- Need structured workflow with checkpoints
- Working on larger features requiring planning

### What Happens Step-by-Step

1. **Validate Feature Name** — Checks name format (kebab-case), uniqueness against existing branches
2. **Create Safety Snapshot** — Runs `git stash`, creates signed copy of current state in .snapshots/
3. **Create Feature Branch** — `git checkout -b feature/[name] origin/main` (or current base branch)
4. **Generate Test Scaffold** — Creates empty test file with describe/it structure
5. **RED Phase Setup** — Guides writing failing tests that define desired behavior
6. **Implementation Guidance** — Prompts for feature implementation
7. **GREEN Phase Verification** — Runs tests, confirms all passing
8. **REFACTOR Phase** — Guides code cleanup, performance optimization, code quality improvements
9. **Feature Summary** — Documents what was built, test coverage, any edge cases

### Example Session

```
$ /new-feature dashboard-export

═══════════════════════════════════════════════════════════════════
  NEW FEATURE WORKFLOW — TDD CYCLE
═══════════════════════════════════════════════════════════════════

🔒 SAFETY SNAPSHOT CREATED
   Location: .snapshots/main-2026-04-18T16-45-32Z.tar.gz
   Size: 2.4 MB
   Restore: git stash pop && tar -xzf [snapshot]

🌿 FEATURE BRANCH CREATED
   Branch: feature/dashboard-export
   Base: origin/main (at abc1234)

📋 TEST SCAFFOLD GENERATED
   File: src/features/export/__tests__/export.test.ts
   
   describe('Dashboard Export Feature', () => {
     describe('exportToCSV', () => {
       it('should export dashboard data as CSV', () => {
         // RED: Write your test here
       });
     });
   });

╶─ RED PHASE ─╶

Write failing tests that define the feature. Tests should:
  • Cover happy path (normal usage)
  • Test edge cases (empty data, special chars)
  • Verify error handling (network failure, invalid format)

Example test framework (Jest):

  it('should export dashboard data with headers and rows', () => {
    const mockData = [{name: 'Q1', revenue: 50000}, {name: 'Q2', revenue: 65000}];
    const csv = exportToCSV(mockData);
    expect(csv).toContain('name,revenue');
    expect(csv).toContain('Q1,50000');
    expect(csv).toContain('Q2,65000');
  });

  it('should handle empty data gracefully', () => {
    const csv = exportToCSV([]);
    expect(csv).toBe(''); // or header-only, depending on spec
  });

  it('should escape commas and quotes in CSV values', () => {
    const mockData = [{name: 'Company, Inc.', desc: 'Says "hello"'}];
    const csv = exportToCSV(mockData);
    expect(csv).toContain('"Company, Inc."');
    expect(csv).toContain('"Says ""hello"""');
  });

Ready to write RED tests? (Complete tests then run: /new-feature dashboard-export green)
```

*[User writes tests in test file]*

```
$ /new-feature dashboard-export green

╶─ GREEN PHASE ─╶

Tests currently failing. Now implement feature to make all tests pass.

Current Test Results:
  ✗ should export dashboard data with headers and rows
  ✗ should handle empty data gracefully
  ✗ should escape commas and quotes

Implementation checklist:
  □ Create export.ts with exportToCSV function
  □ Parse input array
  □ Generate CSV headers
  □ Handle escaping (commas, quotes, newlines)
  □ Format output string

[User implements feature]

$ npm test -- src/features/export/__tests__/export.test.ts

  Dashboard Export Feature
    exportToCSV
      ✓ should export dashboard data with headers and rows (3ms)
      ✓ should handle empty data gracefully (1ms)
      ✓ should escape commas and quotes (2ms)

  3 passed (6ms)

All GREEN! ✓

╶─ REFACTOR PHASE ─╶

Code is now functional. Optimize and improve:

Refactor Checklist:
  □ Extract magic strings to constants
  □ Add JSDoc comments
  □ Check performance (O(n) complexity is good for CSV)
  □ Consider accessibility (if UI component)
  □ Code review for naming clarity
  □ Add usage examples in comments

Current Metrics:
  Lines: 34
  Complexity: 4 (low, ✓)
  Coverage: 100% (excellent)

Refactor suggestions:
  1. Extract CSV escaping logic to separate function
  2. Use const for headers instead of magic string
  3. Add unit test for escapeCSVValue helper

[User refactors]

$ npm test -- src/features/export/__tests__/export.test.ts

  Dashboard Export Feature
    exportToCSV
      ✓ should export dashboard data with headers and rows (2ms)
      ✓ should handle empty data gracefully (1ms)
      ✓ should escape commas and quotes (2ms)

  3 passed (5ms)

═══════════════════════════════════════════════════════════════════

✅ FEATURE COMPLETE

   Feature: dashboard-export
   Branch: feature/dashboard-export (5 new commits)
   Tests: 3 passing, 100% coverage
   Ready for: Code review, merge to main

Next: git push origin feature/dashboard-export && create pull request
```

### Tips and Best Practices

- **Write tests first** — Define expected behavior before implementation. Tests become documentation.
- **Commit at each phase** — Make separate commits for RED, GREEN, REFACTOR so history is clear.
- **Don't skip REFACTOR** — The refactor phase catches technical debt early.
- **Use the snapshot** — If you need to abort, `git reset --hard && tar -xzf snapshot` recovers your work.
- **Pair with code review** — After REFACTOR, have another developer review before merging.

---

## 4. /debug [issue]

### Syntax
```
/debug [issue-description]
```

### Purpose
Execute scientific debugging protocol: form 3 hypotheses, isolate, test, fix, verify, and document the root cause.

### When to Use
- Investigating a bug reported by users or tests
- Unexpected behavior in production
- Regression from recent changes
- Cryptic error messages
- Need structured approach to complex issues

### What Happens Step-by-Step

1. **Issue Analysis** — Reads error messages, stack traces, context
2. **Form 3 Hypotheses** — Generates 3 plausible root causes ranked by likelihood
3. **Isolation Phase** — Creates minimal reproducible case, adds logging
4. **Hypothesis Testing** — Tests each hypothesis in order (most likely first)
5. **Root Cause Identification** — Confirms which hypothesis is correct
6. **Implementation Fix** — Codes the fix with safety checks
7. **Verification** — Runs tests, confirms fix works, no regressions
8. **Documentation** — Updates error-patterns.md with this issue + solution for future reference

### Example Session

```
$ /debug "User profile page crashes when avatar URL is malformed"

═══════════════════════════════════════════════════════════════════
  SCIENTIFIC DEBUGGING PROTOCOL
═══════════════════════════════════════════════════════════════════

📋 ISSUE ANALYSIS
   Title: User profile page crashes when avatar URL is malformed
   Severity: HIGH (affects user experience)
   Frequency: Intermittent (not all users)
   Error: Uncaught TypeError: Cannot read property 'width' of undefined
   Stack:
     at Image.onLoad (components/Avatar.tsx:42)
     at Image.<anonymous> (...)
     ...
   Context: Avatar component, likely related to image loading

🔍 HYPOTHESIS GENERATION (3 candidates)

   HYPOTHESIS 1 (70% likelihood): Avatar image fails to load due to malformed URL.
   When img.onload is never called, image dimensions are undefined, code tries to read
   width without null check → crash.
   Evidence: Error mentions "Cannot read property 'width'"
   Test: Add defensive null check before accessing dimensions

   HYPOTHESIS 2 (20% likelihood): Race condition in useEffect cleanup.
   Image load event fires after component unmounts, state update on unmounted component.
   Test: Check if component unmounts while image is loading

   HYPOTHESIS 3 (10% likelihood): Browser doesn't trigger onload for certain MIME types.
   Non-standard image format (WebP, AVIF) unsupported by user's browser.
   Test: Check browser version and image format compatibility

╶─ ISOLATION PHASE ─╶

Minimal reproducible case:

  // Trigger crash with this URL:
  <Avatar src="data:image/invalid" alt="test" />

Logging added to Avatar component:

  useEffect(() => {
    console.log('[Avatar] Mount with src:', src);
    const img = new Image();
    img.onload = () => {
      console.log('[Avatar] Image loaded, dimensions:', img.width, img.height);
      setDimensions({ width: img.width, height: img.height });
    };
    img.onerror = () => {
      console.log('[Avatar] Image failed to load:', src);
    };
    img.src = src;
  }, [src]);

Running minimal case... ✓ Crash reproduced

Console output:
  [Avatar] Mount with src: data:image/invalid
  (no onload or onerror fired)
  (component tries to access dimensions.width)
  TypeError: Cannot read property 'width' of undefined

╶─ HYPOTHESIS TESTING ─╶

HYPOTHESIS 1: Null check on dimensions ✓ CONFIRMED

  Test: Add defensive check:
  
    if (!dimensions) {
      return <div className="avatar-placeholder" />;
    }
  
  Result: ✓ Crash is prevented. Component renders placeholder instead.

HYPOTHESIS 2: Race condition ✗ NOT RELEVANT (but good to handle anyway)

  Test: Add cleanup to abort in-flight loads:
  
    useEffect(() => {
      let isMounted = true;
      const img = new Image();
      img.onload = () => {
        if (isMounted) setDimensions({ ... });
      };
      return () => { isMounted = false; };
    }, [src]);
  
  Result: No change, but defensive pattern is good practice.

HYPOTHESIS 3: Format compatibility ✗ SECONDARY (unlikely, but monitor)

  Test: Check if malformed URL is the real issue:
  
  // Valid URL: ✓ onload fires, dimensions available
  // Malformed URL: ✗ onerror doesn't fire either (browser quirk)
  
  Recommendation: Implement img.onerror handler

╶─ ROOT CAUSE CONFIRMED ─╶

Avatar component accesses image dimensions without null check.
When image fails to load (malformed URL), onload never fires,
dimensions remain undefined, accessing dimensions.width crashes.

FIX IMPLEMENTATION:

  // Before (crash on malformed URL)
  img.onload = () => {
    setDimensions({ width: img.width, height: img.height });
  };
  
  // After (safe)
  img.onload = () => {
    setDimensions({ width: img.width, height: img.height });
  };
  img.onerror = () => {
    setDimensions(null); // Signal load failure
  };
  
  // Render with null check
  if (!dimensions) {
    return <div className="avatar-placeholder" />;
  }

╶─ VERIFICATION ─╶

Test Results:
  ✓ Existing tests still pass (8/8)
  ✓ New test for malformed URL added (PASS)
  ✓ Edge case: empty src="" (PASS - shows placeholder)
  ✓ Edge case: valid HTTPS URL (PASS - loads correctly)
  ✓ Manual verification on staging: reproduced with bad URL, now shows placeholder ✓

Code Coverage:
  Avatar.tsx: 94% → 100% (added onerror path)

═══════════════════════════════════════════════════════════════════

✅ BUG FIX COMPLETE

   Root Cause: No error handling for failed image loads
   Fix Applied: Added onerror handler + null check
   Verification: 8/8 tests pass, 100% coverage
   Status: READY FOR MERGE

📚 DOCUMENTATION UPDATED
   error-patterns.md entry added:
   
   Issue: Avatar component crashes on malformed image URLs
   Root Cause: onload never fires, dimensions undefined, uncaught property access
   Solution: Implement onerror handler, add null check before rendering
   Prevention: Always check image load completion before using dimensions
   Lesson: Image APIs don't throw on malformed URLs; use both onload AND onerror
```

### Tips and Best Practices

- **Start with 3 hypotheses** — Don't guess. Generate candidates ranked by likelihood.
- **Test most likely first** — Saves time and validates your understanding.
- **Always add error handling** — If onload is used, add onerror. Defensive coding prevents future issues.
- **Document the lesson** — Update error-patterns.md so others learn from this fix.
- **Commit with clear message** — `git commit -m "fix: handle malformed avatar URLs safely"` tells future readers the issue.

---

## 5. /review [target]

### Syntax
```
/review [target]
```

Where `[target]` is: function, file, module, or pull request

### Purpose
Comprehensive code review with automated quality gates: function length, file size, duplication, test coverage, security, naming conventions.

### When to Use
- Before merging a pull request
- Reviewing own code before committing
- Code quality audit of a module
- Security-sensitive code paths
- Need structured review checklist

### What Happens Step-by-Step

1. **Target Analysis** — Parses target (file/function/PR) and loads code
2. **Run Quality Gates** — Checks function length, file size, cyclomatic complexity, duplication
3. **Test Coverage Check** — Runs test suite, reports coverage for target
4. **Security Audit** — Scans for common vulnerabilities (SQL injection, XSS, auth bypass, secrets exposure)
5. **Naming Review** — Validates variable/function names for clarity (no `x`, `data`, `temp`)
6. **Dependencies Check** — Confirms all imports are necessary and versions safe
7. **Generate Report** — Creates summary with findings by severity (CRITICAL/HIGH/MEDIUM/LOW)
8. **Provide Suggestions** — Offers specific fixes for each issue found

### Example Session

```
$ /review src/services/auth.ts

═══════════════════════════════════════════════════════════════════
  CODE REVIEW — QUALITY GATES & SECURITY
═══════════════════════════════════════════════════════════════════

📄 TARGET ANALYSIS
   File: src/services/auth.ts
   Lines: 287
   Functions: 8
   Test File: src/services/__tests__/auth.test.ts (exists, 156 lines)

╶─ QUALITY GATES ─╶

✓ Function Length
  checkPassword (12 lines) — OK
  validateToken (18 lines) — OK
  refreshAccessToken (34 lines) — WARNING (at threshold, consider refactoring)
  All other functions under 30 lines — OK

✓ File Size
  287 lines — OK (under 300 line threshold)

✓ Cyclomatic Complexity
  validateToken: 6 (medium, acceptable)
  refreshAccessToken: 8 (high, watch for edge cases)
  avg: 4.2 — OK

✓ Code Duplication
  Checked against entire codebase
  No duplication detected — OK

╶─ TEST COVERAGE ─╶

Current Coverage: 89% (target: 80%)
Functions:
  checkPassword — 100% ✓
  validateToken — 95% ✓
  refreshAccessToken — 80% (missing 1 error case)
  getTokenFromStorage — 0% (NEEDS TESTING)

Recommendations:
  □ Add test for getTokenFromStorage null case
  □ Add test for refreshAccessToken token expiry edge case

╶─ SECURITY AUDIT ─╶

🔍 CRITICAL FINDINGS: 0

🔍 HIGH FINDINGS: 1
   Location: Line 145, refreshAccessToken
   Issue: Token stored in localStorage (XSS vulnerability risk)
   Recommendation: Use httpOnly cookie instead, or encrypt localStorage value
   Reference: OWASP A01:2021 Broken Access Control

🔍 MEDIUM FINDINGS: 2
   Location: Line 89, validateToken
   Issue: No timeout on token validation call
   Recommendation: Add timeout (5s) to prevent hanging
   Severity: Medium (affects availability)

   Location: Line 156, getTokenFromStorage
   Issue: No validation of token format before returning
   Recommendation: Check JWT format (3 parts separated by dots) before use
   Severity: Medium (malformed token could crash parser)

🔍 LOW FINDINGS: 1
   Location: Line 203, error message
   Issue: Error message leaks internal function names to client
   Message: "validateToken failed in __validateJWTSignature"
   Recommendation: Use generic message to client, log detailed message server-side
   Severity: Low (information disclosure)

╶─ NAMING REVIEW ─╶

✓ Function Names — Clear and action-oriented
  checkPassword, validateToken, refreshAccessToken — all good

✓ Variable Names — Mostly good, few issues
  ⚠️ Line 67: let `p` = password.split('') — RENAME to `chars`
  ⚠️ Line 102: let `t` = Date.now() — RENAME to `timestamp`
  ⚠️ Line 178: let `data` = response.json() — RENAME to `tokenPayload` (context-specific)

✓ Constants — Well-named
  TOKEN_EXPIRY_MS, MAX_ATTEMPTS, etc. — OK

╶─ DEPENDENCIES ─╶

✓ All imports are used
✓ No unused dependencies
✓ jwt-decode version 2.1.0 (latest: 2.1.1) — minor update available
✓ axios version 1.6.0 (latest: 1.7.2) — consider updating

Recommendation: Run `npm update` to get patches

═══════════════════════════════════════════════════════════════════

✅ REVIEW SUMMARY

   Quality Gates: ✓ PASS
   Test Coverage: ✓ PASS (89% > 80% target)
   Security: ⚠️  NEEDS ATTENTION (1 HIGH, 2 MEDIUM findings)
   Naming: ⚠️  MINOR ISSUES (3 variable renames)
   Status: CONDITIONAL APPROVAL (fix security before merge)

📋 ACTION ITEMS (prioritized)

   BEFORE MERGE (Critical):
   1. Fix HIGH: Use httpOnly cookies or encrypt localStorage
   2. Fix MEDIUM: Add timeout to token validation call
   3. Fix MEDIUM: Validate JWT format before returning

   BEFORE MERGE (Important):
   4. Fix naming: p → chars, t → timestamp, data → tokenPayload
   5. Add test: getTokenFromStorage null case

   AFTER MERGE (Nice to have):
   6. Update dependencies: jwt-decode, axios
   7. Consider refactoring refreshAccessToken (34 lines, at threshold)

Fixes estimated: 2-3 hours
Reviewer: Ready to approve after fixes ✓
```

### Tips and Best Practices

- **Run /review before any PR** — Catches issues automatically before human review.
- **Don't ignore CRITICAL/HIGH** — These are real security or stability risks.
- **Use specific suggestions** — When /review recommends a change, implement the exact suggestion provided.
- **Check test coverage** — Code without tests is code you don't understand yet.
- **Review your own code first** — Self-review is faster and catches embarrassing mistakes before others see them.

---

## 6. /deploy-check

### Syntax
```
/deploy-check
```

### Purpose
Pre-deployment verification pipeline: execute 7-phase checks covering tests, linting, security, environment, containerization, database migrations, and final sign-off.

### When to Use
- Before deploying to staging or production
- Final verification before release
- Automated gate in CI/CD pipeline
- Ensuring no surprises post-deployment

### What Happens Step-by-Step

1. **Phase 1: Test Suite** — Runs all tests (unit, integration, e2e). Fails if any test fails.
2. **Phase 2: Linting** — Runs ESLint, Prettier. Fails on violations.
3. **Phase 3: Security** — Runs security scanner (npm audit, OWASP scan). Reports vulnerabilities.
4. **Phase 4: Environment** — Validates all required env vars present and properly formatted.
5. **Phase 5: Docker Build** — Builds Docker image, checks size and layer efficiency.
6. **Phase 6: Database Migrations** — Checks for pending migrations, tests rollback.
7. **Phase 7: Final Sign-Off** — Generates deployment manifest, requests confirmation.

### Example Session

```
$ /deploy-check

═══════════════════════════════════════════════════════════════════
  PRE-DEPLOYMENT VERIFICATION PIPELINE
═══════════════════════════════════════════════════════════════════

🔄 PHASE 1: TEST SUITE
   Running: jest --coverage
   
   Tests: 247 passed, 0 failed
   Coverage: 
     Statements: 87%
     Branches: 82%
     Functions: 89%
     Lines: 88%
   
   ✓ PASS (all tests passing, coverage > 80%)

🔄 PHASE 2: LINTING
   Running: eslint . && prettier --check .
   
   ESLint: 0 errors, 0 warnings
   Prettier: All files formatted correctly
   
   ✓ PASS (code quality clean)

🔄 PHASE 3: SECURITY SCAN
   Running: npm audit && snyk test
   
   npm audit: 0 vulnerabilities
   snyk: 1 LOW severity (info-disclosure in old dependency)
   
   ⚠️  WARNING: 1 LOW severity issue found
       Package: lodash-es@4.17.11
       Issue: Prototype pollution vulnerability
       Recommendation: Upgrade to 4.17.21+
       Action: Optional (LOW severity, no known exploits in this version)
   
   ⚠️  PASS (critical issues: 0, acceptable risk)

🔄 PHASE 4: ENVIRONMENT
   Checking required env vars: 15 required
   
   PRODUCTION environment variables:
     DATABASE_URL — ✓ Present
     JWT_SECRET — ✓ Present (validated: 32+ chars)
     OAUTH_CLIENT_ID — ✓ Present
     OAUTH_CLIENT_SECRET — ✓ Present
     REDIS_URL — ✓ Present
     SENDGRID_API_KEY — ✓ Present
     AWS_ACCESS_KEY_ID — ✓ Present
     AWS_SECRET_ACCESS_KEY — ✓ Present
     LOG_LEVEL — ✓ Present (value: info)
     NODE_ENV — ✓ Present (value: production)
     [10 more] — ✓ All present
   
   ✓ PASS (all env vars configured)

🔄 PHASE 5: DOCKER BUILD
   Running: docker build -t acme-dashboard:v2.1.0 .
   
   Step 1/12: FROM node:22-alpine ... ✓
   Step 2/12: WORKDIR /app ... ✓
   Step 3/12: COPY package.json ... ✓
   ...
   Step 12/12: CMD ["node", "dist/server.js"] ✓
   
   Image: acme-dashboard:v2.1.0
   Size: 287 MB (within 300 MB limit)
   Layers: 12 (efficient)
   
   ✓ PASS (Docker image built successfully)

🔄 PHASE 6: DATABASE MIGRATIONS
   Checking for pending migrations...
   
   Current Schema Version: 2026-04-15-001-add-user-roles
   Pending Migrations: 2
     - 2026-04-16-001-add-avatar-column.js
     - 2026-04-18-001-create-audit-log-table.js
   
   Testing migrations:
     [2026-04-16-001] Apply... ✓ Applied (elapsed: 120ms)
     [2026-04-16-001] Rollback... ✓ Rolled back (elapsed: 45ms)
     [2026-04-18-001] Apply... ✓ Applied (elapsed: 240ms)
     [2026-04-18-001] Rollback... ✓ Rolled back (elapsed: 180ms)
   
   ✓ PASS (migrations reversible and tested)

🔄 PHASE 7: FINAL SIGN-OFF
   Generating deployment manifest...

═══════════════════════════════════════════════════════════════════

📋 DEPLOYMENT MANIFEST

   Version: 2.1.0
   Timestamp: 2026-04-18T17:23:45Z
   Branch: release/v2.1.0
   Commits: 23 since last release
   
   Changes Summary:
   - Features: 7 new features
   - Fixes: 12 bug fixes
   - Security: 2 security patches
   - Perf: 3 performance improvements
   
   Pre-Deployment Checklist:
     ✓ All tests passing (247/247)
     ✓ Code quality: 0 violations
     ✓ Security: 0 critical issues
     ✓ Environment: All vars configured
     ✓ Docker: Image built and tested
     ✓ Migrations: Tested and reversible
   
   Risk Assessment: LOW
   Estimated Deployment Time: 5-10 minutes
   Rollback Plan: Automatic (tag: v2.0.5 ready)

═══════════════════════════════════════════════════════════════════

Ready to deploy to STAGING? (yes/no)
> yes

Deploying to staging...

  [1/5] Pushing image to registry... ✓
  [2/5] Rolling out pods... ✓
  [3/5] Running smoke tests... ✓
  [4/5] Health check... ✓
  [5/5] Finalizing... ✓

✅ DEPLOYMENT COMPLETE
   Environment: staging
   Status: Live
   Health: All services healthy
   Next: Validate in staging, then deploy to production

```

### Tips and Best Practices

- **Run before every deployment** — Non-negotiable gate. Catches issues automatically.
- **Fix all CRITICAL/HIGH security issues** — Don't deploy with known vulnerabilities.
- **Migrations must be reversible** — Always test rollback, not just apply.
- **Keep deployment time short** — Large deployments increase risk. Aim for < 15 minutes.
- **Have a rollback plan** — Before deploying, tag current version as rollback target.

---

## 7. /language-audit [component] [--locale code]

### Syntax
```
/language-audit [component]
/language-audit [component] --locale fr
/language-audit [component] --locale ar
/language-audit [component] --locale zh-Hans
```

### Purpose
Universal language compliance audit for internationalization (i18n). Validates RTL/LTR support, character encoding, locale-specific formatting (dates, numbers, currencies), and cultural considerations across 20+ locales.

### When to Use
- Building features for international markets
- Supporting right-to-left (RTL) languages (Arabic, Hebrew, Persian)
- CJK text (Chinese, Japanese, Korean)
- Complex scripts (Indic, Thai, Khmer)
- New component requires i18n support
- Pre-launch audit for multilingual product

### What Happens Step-by-Step

1. **Load Component** — Reads component code, identifies text/strings
2. **Extract Strings** — Finds all hardcoded strings, placeholder text, labels
3. **Locale Selection** — Loads specified locale(s) or audits all supported locales
4. **Render Testing** — Tests component rendering with selected locale
5. **Character Set Validation** — Confirms font supports required character set (CJK, Indic, Arabic, etc.)
6. **Directionality Check** — Validates RTL/LTR layout (padding, margins, text-align)
7. **Format Validation** — Tests date, number, currency formatting for locale
8. **Accessibility Check** — Validates label/aria-label for locale
9. **Generate Report** — Lists all findings by severity

### Example Session

```
$ /language-audit src/components/UserProfile.tsx --locale ar

═══════════════════════════════════════════════════════════════════
  LANGUAGE AUDIT — INTERNATIONALIZATION (i18n) COMPLIANCE
═══════════════════════════════════════════════════════════════════

📄 COMPONENT ANALYSIS
   Component: UserProfile.tsx
   Locale Target: ar (Arabic)
   Locale Type: RTL (right-to-left)
   Script: Arabic (complex script with ligatures, diacritics)

╶─ STRING EXTRACTION ─╶

Found 12 hardcoded strings:
  1. "User Profile" (header)
  2. "Email Address" (label)
  3. "Phone Number" (label)
  4. "Update Profile" (button)
  5. "Save Changes" (button)
  6. "Cancel" (button)
  7. "Profile Picture" (label)
  8. "Upload New Photo" (button)
  9. "Remove Photo" (button)
  10. "Member since {date}" (message)
  11. "Last updated {date}" (message)
  12. "Joined on {date}" (message)

⚠️  All strings should be i18n-wrapped (use t() function)

╶─ CHARACTER SET VALIDATION ─╶

Testing Arabic text rendering:
  "مرحبا بك" (Hello) — ✓ Renders correctly
  "اسم المستخدم" (Username) — ✓ Renders correctly
  "رقم الهاتف" (Phone Number) — ✓ Renders correctly
  
  Font: Inter (Google Fonts) — ⚠️ LIMITED ARABIC SUPPORT
  Recommendation: Use "Droid Arabic Naskh" or "Cairo" for better Arabic rendering
  
  ✓ Character set validation PASS (text renders, but not optimally)

╶─ DIRECTIONALITY CHECK (RTL) ─╶

Component Layout Analysis:

  Issue 1: CRITICAL
    Location: ProfilePicture.tsx:42
    Code: <img style={{ marginLeft: '16px' }} ... />
    Problem: Uses marginLeft (LTR assumption)
    Impact: Image floats wrong side in RTL
    Fix: Use marginInlineEnd instead
    
    Before: marginLeft: '16px'
    After: marginInlineEnd: '16px'

  Issue 2: MEDIUM
    Location: UserProfile.tsx:78
    Code: flex-direction: row
    Problem: Form fields in row direction (assumes LTR)
    Impact: Labels right, inputs left (reversed in RTL)
    Fix: Use flex-direction-inline or container query
    
    Recommendation:
      .container {
        display: flex;
        flex-direction: row;
        direction: ltr; /* or rtl based on locale */
      }

  Issue 3: MEDIUM
    Location: Button.tsx:15
    Code: padding: 12px 16px 12px 20px (left, right asymmetric)
    Problem: Padding assumes LTR
    Impact: Button text indented wrong side in RTL
    Fix: Use logical properties: paddingInline, paddingBlock
    
    Before: padding: 12px 16px 12px 20px
    After: padding: 12px; paddingInlineStart: 20px; paddingInlineEnd: 16px;

  ✓ 3 issues found, 2 require fixes

╶─ FORMAT VALIDATION ─╶

Date Formatting:
  Input: new Date('2026-04-18')
  English format: April 18, 2026
  Arabic format: ١٨ أبريل ٢٠٢٦ (correct, using Arabic numerals)
  ✓ Date formatting correct

Number Formatting:
  Input: 1234567.89
  English format: 1,234,567.89
  Arabic format: ١٬٢٣٤٬٥٦٧٫٨٩ (correct, using Arabic digits + Arabic decimal)
  ✓ Number formatting correct

Currency Formatting:
  Input: USD 100.00
  English format: $100.00
  Arabic format: ١٠٠٫٠٠ $ (or ر.س ١٠٠٫٠٠ for SAR)
  ✓ Currency formatting correct

  Note: Component uses locale-aware Intl.NumberFormat, ✓ GOOD

╶─ ACCESSIBILITY CHECK ─╶

Labels and ARIA:
  <input label="Email Address" /> — ⚠️ Not i18n-wrapped
  <button>Update Profile</button> — ⚠️ Missing aria-label in Arabic
  
  Recommendation:
    <label htmlFor="email">{t('email_label')}</label>
    <button aria-label={t('update_profile_button')}>{t('update_profile')}</button>

  ✓ Accessibility structure OK, needs i18n strings

╶─ CULTURAL CONSIDERATIONS ─╶

Questions for your product team:
  □ Avatar display in RTL context (should profile pic be left or right)?
  □ Date format expectations (Gregorian vs Hijri calendar)?
  □ Name input fields (Arabic names often have spaces, compound structures)?
  □ Phone number format (different countries have different formats)?

═══════════════════════════════════════════════════════════════════

✅ AUDIT SUMMARY (Arabic / RTL)

   Character Set: ⚠️  NEEDS FONT UPGRADE (use Cairo or Droid Arabic Naskh)
   Directionality: ⚠️  3 ISSUES (marginLeft, flex-direction, padding asymmetry)
   Formatting: ✓ PASS (dates, numbers, currency correct)
   Accessibility: ⚠️ NEEDS i18n STRINGS (12 hardcoded strings)
   
   Status: NEEDS FIXES BEFORE LAUNCH

📋 ACTION ITEMS

   CRITICAL (do not launch):
   1. Wrap all 12 strings in t() function for i18n
   2. Add missing aria-labels in translation strings
   
   HIGH (launch blocker):
   3. Fix marginLeft → marginInlineEnd in ProfilePicture
   4. Fix flex-direction to use logical properties
   5. Fix button padding asymmetry
   6. Change font to "Cairo" or "Droid Arabic Naskh" for better Arabic rendering
   
   MEDIUM (before RTL launch):
   7. Test with actual Arabic speakers (cultural review)
   8. Validate phone number format for Arabic regions
   9. Add Hijri calendar option (if target market is Saudi/Gulf)

Estimated effort: 4-6 hours (mostly string wrapping)
Testing with: ar (Arabic), he (Hebrew), fa (Persian) — all RTL tests
```

### Tips and Best Practices

- **Use logical CSS properties** — `marginInlineEnd` instead of `marginLeft`, `paddingBlockStart` instead of `paddingTop`. These auto-flip for RTL.
- **Externalize all strings** — Never hardcode UI text. Use i18n framework (react-i18next, next-intl, etc.).
- **Test with real RTL languages** — Arabic, Hebrew, Persian, Urdu all have specific behaviors.
- **Watch fonts** — Western fonts often don't support CJK or Indic scripts well. Choose appropriate fonts per locale.
- **Get native speakers to review** — Automated tools catch technical issues, but native speakers catch cultural/linguistic issues.

---

## 8. /reality-check [scope]

### Syntax
```
/reality-check frontend
/reality-check auth
/reality-check api
/reality-check full
```

### Purpose
Scan codebase for mock data, fake APIs, test doubles, and placeholder implementations. Verify all integrations are connected to real services, not development stubs.

### When to Use
- Before deployment to production
- Ensuring test doubles aren't deployed to prod
- Code review for accidental mock data commits
- Compliance verification (production must use real services)

### What Happens Step-by-Step

1. **Scope Selection** — Targets frontend, auth, api, or full codebase
2. **Mock Detection** — Searches for patterns: mock(), jest.fn(), faker, msw handlers, stub APIs
3. **Fake Data Scan** — Finds hardcoded test data (test@example.com, "john doe", placeholder IDs)
4. **Integration Verification** — Checks that API calls point to real endpoints (not localhost:3001)
5. **Environment Check** — Confirms production environment is used
6. **Generate Report** — Lists Reality Score (0-100%), items requiring verification
7. **Risk Assessment** — Flags critical items that must be fixed before deploy

### Example Session

```
$ /reality-check full

═══════════════════════════════════════════════════════════════════
  REALITY CHECK — MOCK DATA & FAKE API DETECTION
═══════════════════════════════════════════════════════════════════

📊 SCOPE: FULL CODEBASE
   Searching for test doubles, mocks, fake APIs, placeholder data

🔍 MOCK DETECTION

CRITICAL FINDINGS: 2

   1. File: src/services/auth.ts:45
      Code: const mockUser = { id: '1', email: 'test@example.com', name: 'John Doe' };
      Risk: Test data committed to source control
      Fix: Remove or move to test file only
      Status: CRITICAL — must be removed before production

   2. File: src/api/client.ts:12
      Code: const API_URL = process.env.API_URL || 'http://localhost:3001/api';
      Risk: Falls back to localhost if env var missing
      Impact: Would silently hit development server in production
      Fix: Remove fallback, require explicit env var
      Status: CRITICAL — env validation must fail if API_URL missing

HIGH FINDINGS: 3

   3. File: src/__mocks__/handlers.ts (MSW handlers)
      Code: rest.get('/api/users/:id', (req, res, ctx) => { ... })
      Risk: Mock service worker set up in prod code
      Check: Verify MSW is disabled in production
      Status: HIGH — confirm MSW only active in test/dev

   4. File: src/components/Dashboard.tsx:89
      Code: if (process.env.NODE_ENV === 'development') {
               const mockData = [{ ... }];
             }
      Risk: Dev-only mock data, but still in production bundle
      Impact: Dead code, but could confuse future developers
      Status: MEDIUM — consider removing unused code

🔍 FAKE DATA SCAN

MEDIUM FINDINGS: 5

   5. src/forms/RegisterForm.tsx:102
      Mock Email: "test-user-123@example.com" (appears in error message)
      Status: MEDIUM — not a critical issue, but consider generic message

   6. src/mocks/seed.ts:15
      Faker usage: faker.internet.email(), faker.name.fullName()
      Status: OK (only in mock file, not committed to prod code)

   7. Tests: 127 test files use faker data — ✓ OK (test files only)

🔍 INTEGRATION VERIFICATION

CRITICAL FINDINGS: 1

   8. File: src/utils/api.ts:5
      Code: export const API_BASE = `${window.location.origin}/api`;
      Status: ✓ GOOD (uses real API endpoint, not mock)

   9. File: src/services/auth.ts:120
      Code: const response = await fetch('/api/auth/login', { ... })
      Status: ✓ GOOD (relative URL, will use real API in prod)

   10. File: src/services/stripe.ts:30
        Code: const stripe = Stripe(process.env.REACT_APP_STRIPE_KEY || 'pk_test_...');
        Risk: Falls back to test key if env var missing
        Status: CRITICAL — must require env var, no fallback to test key

🔍 ENVIRONMENT CHECK

   NODE_ENV: ✓ production
   API_BASE: ✓ https://api.acme.com (not localhost)
   DATABASE_URL: ✓ postgresql://prod-db-01...
   STRIPE_KEY: ⚠️  pk_test_... (TEST KEY ACTIVE!)
   SENDGRID_KEY: ✓ sg_live_... (production key)
   AWS_REGION: ✓ us-east-1 (production)

   ⚠️  Stripe using TEST key in PRODUCTION environment

═══════════════════════════════════════════════════════════════════

📊 REALITY SCORE: 72/100 (NEEDS FIXES)

   Breakdown:
   - Mock APIs: 95% (MSW properly disabled in prod)
   - Fake Data: 80% (minimal test data in source)
   - API Integration: 65% (2 critical env fallbacks)
   - Environment: 55% (Stripe test key in prod)

🚨 CRITICAL BLOCKERS (must fix before deploy)

   1. Remove mockUser from auth.ts (or move to test file)
   2. Remove API_URL localhost fallback — require env var
   3. Remove Stripe test key fallback — require env var
   4. VERIFY: Stripe env var is set to pk_live_... in production

HIGH PRIORITY (strongly recommended before deploy)

   5. Verify MSW is disabled in production build
   6. Review all process.env fallbacks — consider if they're intentional

═══════════════════════════════════════════════════════════════════

Fixes required: 3 critical, 2 high
Estimated time: 30 minutes
Ready to fix? (yes/no)
```

### Tips and Best Practices

- **Run before every production deployment** — Non-negotiable. Catches accidental test data.
- **Remove all env fallbacks to test/development** — If a required env var is missing in production, fail fast.
- **Verify third-party credentials** — Stripe, SendGrid, AWS keys should be production keys (not test/sandbox).
- **Check for localhost URLs** — Should never appear in production code.
- **Disable test doubles in production** — MSW, jest mocks, faker should not be bundled for production.

---

## 9. /migrate-check [migration-file]

### Syntax
```
/migrate-check db/migrations/2026-04-18-001-add-user-roles.js
/migrate-check --pending
```

### Purpose
Database migration safety review: risk classification, lock analysis, rollback verification, table scan for data loss risk, and reversibility testing.

### When to Use
- Before applying a database migration
- Code review of migration files
- Verifying backward compatibility
- Ensuring rollback is possible

### What Happens Step-by-Step

1. **Load Migration** — Reads migration file, parses SQL/code
2. **Risk Classification** — Categorizes migration: trivial, low, medium, high, critical
3. **Structural Analysis** — Checks for destructive operations (DROP, DELETE, ALTER with potential data loss)
4. **Lock Analysis** — Identifies which tables will be locked and for how long
5. **Rollback Verification** — Tests that down() or rollback function works
6. **Data Safety** — Scans for operations that could lose data
7. **Performance Impact** — Estimates migration time based on table size
8. **Generate Report** — Lists findings and recommendations

### Example Session

```
$ /migrate-check db/migrations/2026-04-18-001-add-audit-log-table.js

═══════════════════════════════════════════════════════════════════
  MIGRATION SAFETY REVIEW
═══════════════════════════════════════════════════════════════════

📄 MIGRATION ANALYSIS
   File: db/migrations/2026-04-18-001-add-audit-log-table.js
   Size: 145 lines
   Type: Schema migration (CREATE TABLE)

╶─ MIGRATION CONTENT ─╶

exports.up = async (db) => {
  await db.schema.createTable('audit_logs', (t) => {
    t.increments('id').primary();
    t.integer('user_id').unsigned().notNullable();
    t.enum('action', ['create', 'update', 'delete']).notNullable();
    t.text('changes').nullable();
    t.timestamp('created_at').defaultTo(db.fn.now());
    t.foreign('user_id').references('users.id').onDelete('cascade');
  });
};

exports.down = async (db) => {
  await db.schema.dropTable('audit_logs');
};

╶─ RISK CLASSIFICATION ─╶

Risk Level: 🟢 LOW

Reasoning:
  ✓ New table only (no modifications to existing tables)
  ✓ No data loss risk (CREATE TABLE is additive)
  ✓ Foreign key constraint (maintains referential integrity)
  ✓ Rollback is simple (DROP TABLE)
  ✓ No performance impact (new table, doesn't affect existing queries)

Risk Factors:
  • CASCADE delete on user (when user deleted, audit logs deleted)
    Mitigation: This is intentional; audit logs are user-scoped

╶─ STRUCTURAL ANALYSIS ─╶

SQL Operations:
  CREATE TABLE audit_logs — ✓ SAFE (new table, no data at risk)
  Columns:
    id (increments) — ✓ GOOD (auto-increment PK)
    user_id (FK) — ✓ GOOD (foreign key to users.id)
    action (enum) — ✓ GOOD (constraint ensures valid values)
    changes (text nullable) — ✓ GOOD (optional field)
    created_at (timestamp) — ✓ GOOD (auto-set to NOW())

Indexes Recommended (not yet added):
  CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
  CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

  Recommendation: Add these indexes to enable efficient querying by user or date

╶─ LOCK ANALYSIS ─╶

Table Locks:
  CREATE TABLE — ✓ SHORT LOCK (milliseconds, production-safe)
  No existing tables modified — ✓ NO LOCK CONFLICTS

Migration Time Estimate:
  Expected: < 100ms (very fast)
  Safe to run: During peak hours (minimal disruption)

╶─ ROLLBACK VERIFICATION ─╶

Testing rollback...

  Step 1: Apply migration
    CREATE TABLE audit_logs ... ✓ Applied (elapsed: 45ms)
  
  Step 2: Rollback migration
    DROP TABLE audit_logs ... ✓ Rolled back (elapsed: 12ms)
  
  Step 3: Re-apply migration
    CREATE TABLE audit_logs ... ✓ Re-applied (elapsed: 48ms)
  
  ✓ Rollback works correctly and is reversible

╶─ DATA SAFETY ANALYSIS ─╶

Existing Data Impact: ✓ NONE (new table, no existing data)

Potential Issues:
  None identified. This migration is safe.

Future Considerations:
  If you later add a NOT NULL column to audit_logs without default,
  it could cause issues. Always provide defaults or backfill existing data.

═══════════════════════════════════════════════════════════════════

✅ MIGRATION APPROVED FOR DEPLOYMENT

   Risk Level: 🟢 LOW
   Rollback: ✓ Tested and working
   Impact: Minimal (new table only)
   Safe to Deploy: YES
   Recommended Timing: Any time (fast enough for production)

📋 RECOMMENDATIONS (before merging)

   Before Deploy:
   1. ✓ Rollback works (already tested)
   2. Add indexes on user_id and created_at for query performance
   3. Update ORM models to include AuditLog entity

   Optional (nice to have):
   4. Add seed migration for sample audit log entries
   5. Add database documentation comment on audit_logs table

Next Step: Merge to main, then run migration in production
```

### Tips and Best Practices

- **Always test rollback** — A migration that can't roll back is dangerous.
- **Add indexes for foreign keys** — Queries by foreign key will be slow without indexes.
- **Estimate migration time** — Large tables (1M+ rows) can take minutes. Plan downtime accordingly.
- **Never drop tables without backup** — If dropping a table, back it up first (export to file).
- **Keep migrations small** — One logical change per migration file. Easier to debug.

---

## 10. /perf-check [scope]

### Syntax
```
/perf-check api
/perf-check frontend
/perf-check database
/perf-check full
```

### Purpose
Performance audit scanning for N+1 queries, bundle bloat, latency bottlenecks, and memory leaks.

### When to Use
- Before deployment
- After adding features (to catch perf regressions)
- Slow endpoint investigation
- Frontend bundle optimization needed

### What Happens Step-by-Step

1. **Load Profiling Data** — Runs performance tests, collects metrics
2. **N+1 Detection** — Scans for database queries in loops (API scope)
3. **Bundle Analysis** — Checks JavaScript bundle size, unused dependencies (frontend)
4. **Latency Analysis** — Identifies slow endpoints, functions
5. **Memory Analysis** — Checks for memory leaks, large allocations
6. **Generate Report** — Lists findings by scope

### Example Session

```
$ /perf-check api

═══════════════════════════════════════════════════════════════════
  PERFORMANCE AUDIT — API SCOPE
═══════════════════════════════════════════════════════════════════

📊 N+1 QUERY DETECTION

HIGH FINDINGS: 1

   1. File: src/services/dashboard.ts:42
      Issue: Fetching user dashboards, then user details in loop
      
      Code:
        const dashboards = await db('dashboards').where(...);
        const withUsers = dashboards.map(async (d) => {
          const user = await db('users').where('id', d.user_id).first();
          return { ...d, user };
        });

      Problem: 1 query for dashboards + N queries for users (N+1)
      Solution: Use JOIN
      
      Fixed code:
        const dashboards = await db('dashboards')
          .join('users', 'dashboards.user_id', 'users.id')
          .select('dashboards.*', 'users.name', 'users.email');

      Impact: 100 dashboards = 101 queries → 1 query (100x faster)

📊 LATENCY ANALYSIS

CRITICAL FINDINGS: 1

   2. Endpoint: GET /api/reports/summary
      Current latency: 8234ms (8.2 seconds)
      Target latency: < 500ms
      
      Breakdown:
        DB Query: 7800ms (95%)
        Processing: 300ms (3%)
        JSON serialization: 134ms (2%)
      
      Root Cause: Generating report scans full 10M-row table
      Solution: Add indexes, cache results, or paginate
      
      Recommendation: Cache for 1 hour, invalidate on data change

   3. Endpoint: POST /api/users
      Current latency: 2100ms
      Root Cause: Email validation does external DNS lookup (blocking)
      Solution: Async email validation, return response while validating in background

📊 MEMORY ANALYSIS

MEDIUM FINDINGS: 1

   4. Function: aggregateReports (src/services/reports.ts:120)
      Issue: Loading 10M rows into memory array
      Current memory: 2.4 GB (for single aggregation)
      Solution: Use database aggregation (SUM, COUNT, etc.) instead
      
      Bad:
        const rows = await db('reports').select('*');
        const total = rows.reduce((sum, r) => sum + r.amount, 0);
      
      Good:
        const total = await db('reports').sum('amount').first();

═══════════════════════════════════════════════════════════════════

✅ PERFORMANCE SUMMARY

   N+1 Queries: 1 critical (100x slowdown potential)
   Latency: 2 critical endpoints (8.2s, 2.1s)
   Memory: 1 issue (2.4 GB bloat)
   Bundle Size: N/A (API scope)

Estimated improvement after fixes: 10-50x faster
```

---

## 11. /dependency-audit [--fix]

### Syntax
```
/dependency-audit
/dependency-audit --fix
```

### Purpose
Scan for CVE vulnerabilities, outdated packages, license compliance, and supply chain risk.

### When to Use
- Regular security audits (weekly)
- Before deployment
- When vulnerabilities are disclosed
- License compliance checks

### What Happens Step-by-Step

1. **Run npm audit** — Scans for known CVEs
2. **Check outdated packages** — Identifies updates available
3. **License compliance** — Verifies licenses match policy
4. **Supply chain risk** — Checks package provenance
5. **Generate report** — Lists findings by severity
6. **Auto-fix (if --fix)** — Safely updates packages

---

## 12. /api-docs [scope]

### Syntax
```
/api-docs
/api-docs full
/api-docs --sync
```

### Purpose
Generate/sync API documentation from code. Creates OpenAPI specs, endpoint discovery, and keeps docs in sync with implementation.

### When to Use
- Creating API documentation
- Keeping API docs up-to-date
- Generating OpenAPI/Swagger specs
- Publishing API documentation

---

## 13. /a11y-audit [component|page]

### Syntax
```
/a11y-audit LoginForm
/a11y-audit src/pages/Dashboard.tsx
```

### Purpose
Accessibility audit for WCAG 2.1 AA compliance: contrast ratios, ARIA labels, keyboard navigation, screen reader compatibility.

### When to Use
- Before launching component
- Compliance verification
- User accessibility issues
- WCAG 2.1 AA audit

---

## 14. /document [target]

### Syntax
```
/document src/services/auth.ts
/document Dashboard
/document api/users
```

### Purpose
Generate documentation for specified code target: function signatures, usage examples, parameter descriptions, return values.

### When to Use
- Documenting new code
- Creating developer guides
- API documentation generation
- Code comments/JSDoc auto-generation

---

## End of Commands Manual

All 14 commands are documented with full syntax, use cases, examples, and best practices. Each command integrates with the I/O Channel system for request tracking and result reporting.

