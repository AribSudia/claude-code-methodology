---
description: "Session | Close session — update all memory files, run tests, commit, push, report next steps"
---

# Session End — /arib-session-end

## Overview

Proper session closure is what makes the next session-start work. Without it, the next session starts blind. **A session without memory updates is a session that never happened.**

This skill ensures all work is documented, tested, committed, and pushed. It's the counterpart to `/arib-session-start` — session-start reads what session-end writes. If you skip session-end, the next session has no handoff, no context, no direction. The entire team's continuity depends on this protocol.

### Why It Matters
- **Handoff clarity**: The next developer (or you, 2 weeks later) knows exactly what was done, what failed, and what to do next
- **Test health**: You verify tests pass before disappearing, avoiding the "worked on my machine" problem
- **Commit history**: Git reflects actual work, not mystery sessions with vague messages
- **Remote sync**: All changes are pushed; nothing is lost if hardware fails
- **Memory continuity**: Memory files are the only thing that lives between sessions

---

## When to Use

- **End of every work session** (mandatory)
- **Before switching to a different project**
- **Before a long break** (>24h)
- **When handing off to another developer**
- **Before pausing on a feature mid-implementation**

If you don't run session-end, you haven't properly closed the session.

---

## The Protocol (6 Steps)

### Step 1: Memory File Updates

Update each memory file with structured content. These files are read first in `/arib-session-start`.

#### **session_notes.md** — The Handoff Document

This is the primary contract with the next session. Write as if explaining to a teammate who knows nothing about what happened today.

```markdown
## Session: [YYYY-MM-DD] [HH:MM]

### Completed
- [task 1 — what was done, not just "worked on X"]
- [task 2 — specific outcome, e.g. "Added JWT auth to /api/login, returns token with 24h expiry"]
- [task 3 — or ⚠️ if partial: "Started payment integration, Stripe client configured but webhook handler incomplete"]

### Files Changed
| File | Change | Lines |
|------|--------|-------|
| src/auth/login.ts | New file — login endpoint | +82 |
| src/routes/index.ts | Added auth routes | +5/-0 |
| tests/auth.test.ts | Updated JWT expiry test | +3/-2 |

### Problems Encountered
- [Problem]: [Resolution or status]
- Example: "bcrypt hash comparison failed silently" → "Fixed: was comparing hash to hash instead of plain to hash"
- Example: "Email service timeout on reset flow" → "Unresolved: service intermittently slow, documented in ticket #4521"

### Next Session Starts With
1. [Most important task — be specific and actionable]
   - Example: "Implement password reset flow — email template is ready in src/templates/reset.html, needs backend handler at POST /api/auth/reset"
2. [Second priority]
3. [Optional: context the next session needs]
   - Example: "bcrypt comparison bug was subtle; see commit abc123def for the fix pattern"
```

**Writing good handoff notes:**

✅ Good:
- "Implement password reset flow — email template is ready in src/templates/reset.html, needs backend handler at POST /api/auth/reset"
- "Fix failing test in tests/auth.test.ts line 42 — token expiry mock is wrong, token is 24h but test expects 12h"
- "User registration complete; POST /api/auth/register accepts email/password, validates, hashes password, stores in DB. Test coverage 100%."

❌ Bad:
- "Continue working on auth"
- "Fix tests"
- "Worked on authentication stuff"

#### **project_status.md** — The Big Picture

Update this to reflect overall progress. The next session reads this to understand where the project stands.

```markdown
## Current Phase
- [Phase name, e.g. "Authentication MVP"]
- Estimated completion: [date if known]

## Feature Tracker
| Feature | Status | % Complete | Notes |
|---------|--------|------------|-------|
| User registration | ✅ Done | 100% | Commit abc123, test coverage 95% |
| Login | 🔄 In Progress | 85% | JWT token working, logout needs implementation |
| Password reset | ❌ Blocked | 0% | Waiting for email service setup |

## Known Blockers
- [Blocker]: [status and impact]
- Example: "Email service not configured in staging — blocks password reset flow"
- Example: "Database migration script failing on legacy user records — needs investigation"

## Completion Status
- Overall: 45% (18/40 features)
- Critical path: On track / At risk / Behind
- Next milestone: [date]
```

#### **change_log.md** — The Chronological Record

This is the historical audit trail. Entries are added at session-end, in reverse chronological order (most recent first).

```markdown
## [YYYY-MM-DD] Session Changes

### Added
- Added JWT authentication to /api/login (commit abc123def)
- Added bcrypt password hashing to user registration (commit abc123def)
- Added email verification template (src/templates/verify-email.html)

### Changed
- Refactored auth middleware to use new JWT validation (commit abc123def)
- Updated user schema to include password_hash field (commit abc123def)

### Fixed
- Fixed bcrypt comparison bug in login endpoint (commit abc123def) — was comparing hash to hash instead of plaintext to hash
- Fixed flaky test in auth.test.ts line 42 (commit abc123def) — mock token expiry was inconsistent

### Deprecated
- Old session_token approach no longer used; replaced by JWT (commit abc123def)
```

#### **testing_log.md** — Test Health

Record test results at session-end. This helps track test stability and regressions.

```markdown
## [YYYY-MM-DD] Test Results

- **Total**: 42 tests
- **Passed**: 40 ✅
- **Failed**: 2 ❌
  - `test/auth.test.ts:18` "should hash password correctly" — crypto module mock issue (pre-existing, see issue #456)
  - `test/email.test.ts:5` "should send verification email" — flaky, passed on retry
- **Skipped**: 0 ⏭️
- **Coverage**: 87% (if available)
- **New tests added**:
  - `test/auth.test.ts:35` "should create JWT with 24h expiry"
  - `test/auth.test.ts:42` "should reject expired JWT"
```

---

### Step 2: Run Final Tests

Execute the project's test suite:

```bash
npm test  # or project-specific command
```

**Decision tree:**

- **All pass** → proceed to Step 3
- **Some fail** → investigate before proceeding:
  - If failures are from THIS session's work → fix before closing. Don't leave broken tests in your wake.
  - If failures are pre-existing → document in session_notes with timestamp: "Pre-existing failure: [test name] as of [date]"
  - If failures are flaky/intermittent → rerun once; if it passes, document: "Flaky test: [test name] — passed on retry"

Never push with failing tests that are your responsibility. It breaks the next developer's environment.

---

### Step 3: Final Commit

Create a commit documenting the session closure:

```bash
git add [specific-files]
git commit -m "[chore]: end of session — [summary of all work]"
```

**Commit message examples:**

✅ Good:
- `[chore]: end of session — completed user auth (register/login), added JWT token validation, 40/42 tests passing`
- `[chore]: end of session — WIP on payment integration, Stripe webhook handler 50% done, see session_notes for next steps`
- `[chore]: end of session — fixed bcrypt comparison bug, updated 3 tests, all passing`

❌ Bad:
- `[chore]: end of session` (too vague)
- `[chore]: session end` (missing summary)
- `[chore]: updates` (what updates?)

**Important:** Include memory files in the commit. They are part of the project and must be in version control:

```bash
git add memory/session_notes.md memory/project_status.md memory/change_log.md memory/testing_log.md
```

---

### Step 4: Push to Remote

Push all changes to the remote repository:

```bash
git push origin [current-branch]
```

**If push fails:**

- **Auth error** → Check credentials. Ask user if needed.
- **Conflict** → `git pull --rebase origin [branch]`, resolve conflicts, push again.
- **Branch protection** → You're trying to push to main/develop directly. Create a feature branch instead; ask for a pull request review.
- **Large files** → Check if you accidentally committed binaries or node_modules. Remove and re-commit.

Never end a session with unpushed changes. Remote must always have the latest work.

---

### Step 5: Session Report

Present a concise report to the user. This is their summary of what happened.

```markdown
## Session Complete — [DATE]

### Completed
- ✅ [Task 1 — outcome]
- ✅ [Task 2 — outcome]
- ⚠️ [Task 3 — partial, see notes]

### Test Status
[N passing]/[N total] tests passing

### Issues
- [Any unresolved problems and impact]

### Next Session
1. [Top priority for next time — be specific]
2. [Secondary priority]
3. [Optional: context or warnings]

### Commit
[commit-hash] on branch [branch-name] → pushed to origin
```

**Example:**

```markdown
## Session Complete — 2024-01-15

### Completed
- ✅ Implemented user registration endpoint with email validation
- ✅ Added bcrypt password hashing
- ✅ Created 8 new tests for auth module
- ⚠️ JWT token expiry working but logout not yet implemented

### Test Status
40/42 tests passing (2 pre-existing failures in email module)

### Issues
- Email service timeout intermittently in staging; may affect password reset feature
- One test flaky but passes on retry

### Next Session
1. Implement logout endpoint — clear JWT token from client
2. Integrate email service for password reset flow (handler at POST /api/auth/reset)
3. Monitor email service reliability; consider adding retry logic

### Commit
abc123def on branch auth/jwt → pushed to origin
```

---

### Step 6: Closing Confirmation

Confirm the session is properly closed. The session is not over until all of these are done:

- [x] All memory files updated (session_notes, project_status, change_log, testing_log)
- [x] Tests run (pass or failures documented)
- [x] Changes committed with clear message
- [x] Changes pushed to origin
- [x] Report delivered to user

---

## Edge Cases

### Nothing Was Accomplished

Still run session-end. Document what was attempted and why it didn't work.

```markdown
## Session: [DATE] [TIME]

### Completed
(nothing)

### Problems Encountered
- Attempted to set up Stripe integration but API key not available in staging environment
- Contacted DevOps; no ETA for key provisioning
- Blocked on external dependency

### Next Session Starts With
1. Check with DevOps if Stripe API key is available
2. If available: follow Stripe SDK setup guide in docs/STRIPE_SETUP.md
3. If not available: proceed with password reset feature instead (does not depend on Stripe)
```

This tells the next session exactly what was tried and why it failed.

### Emergency Stop (User Must Leave Immediately)

Minimum viable session-end:

1. `git stash` (saves work without committing)
2. Quick note in session_notes.md: "Emergency stop [TIME] — work stashed, resume with `git stash pop`"
3. Skip tests and push

Your work is saved; the next session can resume with `git stash pop`.

### Session Ended Mid-Feature

Commit with WIP prefix:

```bash
git commit -m "[feat]: WIP — login endpoint, missing validation and tests"
```

In session_notes, mark progress clearly:

```markdown
### Completed
- ⚠️ Login endpoint scaffolded: accepts email/password, compares with DB
- ⚠️ 50% done: missing password validation, error handling, tests

### Files Changed
| File | Status |
|------|--------|
| src/routes/auth.ts | +120 lines, WIP |
| tests/auth.test.ts | No change yet |

### Next Session Starts With
1. Add password validation (regex for strength requirements)
2. Add error handling (invalid credentials, user not found)
3. Write tests (happy path, invalid user, wrong password)
4. All 3 must complete before marking feature done
```

This way, the next session knows exactly where you stopped and what's left.

### Multiple Branches Worked On

If you worked on multiple branches in one session:

1. Commit and push each branch separately
2. In session_notes, list all branches:

```markdown
### Branches Touched
- `auth/jwt` — completed JWT implementation, pushed
- `feature/email-verification` — scaffolded, WIP, stashed (not pushed)
- `bugfix/bcrypt-comparison` — completed and merged to main, pushed

### Next Session Starts On
- Branch: `feature/email-verification` (resume with `git stash pop`)
```

---

## Memory File Size Management

If any memory file exceeds 200 lines, archive old entries:

1. Create `memory/archive/[filename]-[YYYY-MM-DD].md`
2. Move entries older than 30 days to the archive
3. Keep most recent entries in the main file
4. Add reference: "See `memory/archive/` for historical entries before [date]"

Example:

```markdown
## session_notes.md (Main)
- 50 lines: sessions from the last 7 days

## session_notes-2024-01-01.md (Archive)
- 200 lines: sessions from 2024-01-01 to 2024-01-08

## Index
See memory/archive/ for entries before [DATE]
```

---

## Common Mistakes (Don't Make These)

| Mistake | Why It's Bad | Fix |
|---------|------------|-----|
| Skipping memory updates ("I'll remember") | You won't. Next session is blind. | Always update all 4 files. |
| Vague handoff notes ("continue auth work") | Next session doesn't know what's done or what's left. | Be specific: "JWT tokens working, logout not yet implemented." |
| Not running tests ("nothing changed that would break tests") | Tests reveal hidden bugs. Always verify. | Run `npm test` every session-end. |
| Forgetting to push ("I'll push next time") | If hardware fails, work is lost. Remote must have latest. | Always push. It takes 10 seconds. |
| Not documenting failures ("the test is flaky, it'll pass next time") | Next session hits the same flaky test, wastes time. | Document everything: "Flaky test in email.test.ts line 5 — passes on retry." |
| Committing with `git add .` | You might accidentally commit node_modules, .env, or build artifacts. | Use `git add [specific-files]` or review with `git diff --staged`. |
| Leaving TODO comments without memory notes | Comments are for code, memory files are for sessions. | If a TODO is important, put it in session_notes under "Next Session Starts With." |

---

## Related Skills

- **`/arib-session-start`** — The counterpart that reads what session-end writes. Reads memory files, understands context, and plans the session.
- **`/arib-io`** — If there are I/O channel updates or signals to send before closing.
- **`/arib-consolidate-memory`** — If memory files are cluttered or have duplicates, use this to clean them up.

---

## Checklist

Use this when you reach session-end:

```
MEMORY FILES
  ☐ Updated memory/session_notes.md (completed, files changed, problems, next steps)
  ☐ Updated memory/project_status.md (phase, features, blockers)
  ☐ Updated memory/change_log.md (added, changed, fixed)
  ☐ Updated memory/testing_log.md (pass/fail counts, new tests)

TESTING
  ☐ Ran final test suite (`npm test` or equivalent)
  ☐ All tests pass OR failures documented in session_notes

COMMIT
  ☐ Staged memory files + code changes (`git add [specific-files]`)
  ☐ Created commit with clear message (`[chore]: end of session — [summary]`)

PUSH
  ☐ Pushed to remote (`git push origin [branch]`)
  ☐ No unpushed changes remain

REPORT
  ☐ Delivered session report to user
  ☐ Confirmed session is properly closed
```
