# Claude Code Methodology v2.6.0: Memory System Manual

## Table of Contents
1. [What is the Memory System?](#what-is-the-memory-system)
2. [Why the Memory System Exists](#why-the-memory-system-exists)
3. [The Memory Rule](#the-memory-rule)
4. [Read-Work-Write Lifecycle](#read-work-write-lifecycle)
5. [Memory Hierarchy](#memory-hierarchy)
6. [The 7 Core Memory Files](#the-7-core-memory-files)
7. [Archive System](#archive-system)
8. [Memory Rules & Governance](#memory-rules--governance)
9. [Practical Examples](#practical-examples)
10. [Common Mistakes & Solutions](#common-mistakes--solutions)
11. [Memory Maintenance Tips](#memory-maintenance-tips)

---

## What is the Memory System?

The **Memory System** is a collection of structured files stored in your project's `memory/` directory that persist context, decisions, and state across Claude sessions. These files act as the institutional knowledge of your project—tracking what has been done, why things were built a certain way, what problems were encountered, and what's coming next.

Without the memory system, each Claude session starts from zero. You'd need to re-explain the project structure, re-discuss architectural decisions, and re-discover bugs that were already fixed. The memory system prevents this by storing everything Claude learns in human-readable markdown files that survive between sessions.

### Core Concept
**Memory files are NOT git history.** Git tells you *what changed*. Memory files tell you *why it changed, what it means, and what happens next.*

---

## Why the Memory System Exists

Claude has no built-in persistence. Unlike a human developer who stays with a project for months or years, each Claude session is stateless:
- No memory of previous conversations
- No awareness of architectural debates already resolved
- No knowledge of bugs already encountered and fixed
- No visibility into current blockers or next priorities

**Problem without memory:**
- Session 1: "I'll store user sessions in Redis"
- Session 2: Claude suggests "Store user sessions in Redis" (duplicate debate)
- Session 3: Bug fix is applied, but Session 4 reintroduces the same bug because there's no record

**Solution with memory:**
- architecture_decisions.md records *why* Redis was chosen
- bugs_and_fixes.md prevents re-introducing the same bug
- session_notes.md brings the next Claude up to speed in 2 minutes

---

## The Memory Rule

### **"A session without memory updates is a session that never happened."**

This is the golden rule of the memory system. If you complete work but don't update memory files, that work is effectively invisible to the next Claude session. Your effort is wasted because the next session has no evidence that you did anything.

**Every session MUST:**
1. **Read** memory files at START (understand current state)
2. **Update** change_log during WORK (track progress)
3. **Update** ALL memory files at END (persist new knowledge)
4. **Commit** with a clear message tying memory to code changes

---

## Read-Work-Write Lifecycle

### Detailed Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│ SESSION START                                           │
├─────────────────────────────────────────────────────────┤
│ 1. CONTEXT SETUP                                        │
│    - Read MEMORY_PROTOCOL.md (understand the rules)     │
│    - Read project_status.md (what's the current phase?) │
│    - Read session_notes.md (what did last Claude do?)   │
│    - Read change_log.md (full history of commits)       │
│    - Skim architecture_decisions.md (why built this way)│
│    - Check bugs_and_fixes.md (what traps to avoid?)     │
│    - Review testing_log.md (what tests pass/fail?)      │
│                                                         │
│ 2. WORK CONTEXT                                         │
│    "I see the project is in Phase 2: Core Features.     │
│     Last session added auth module. Current blocker:    │
│     Database schema for user roles. Let me continue..." │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ SESSION WORK                                            │
├─────────────────────────────────────────────────────────┤
│ 1. DURING WORK: Update change_log.md continuously       │
│    - Log each significant change or decision            │
│    - Note file modifications                            │
│    - Record any new bugs discovered                     │
│    - Track blockers that emerge                         │
│                                                         │
│ 2. MAKE CHANGES                                         │
│    - Write code, docs, tests                            │
│    - Create commits (reference change_log)              │
│    - Test thoroughly                                    │
│                                                         │
│ 3. DOCUMENT DISCOVERIES                                 │
│    - New architectural decision? Update ADRs            │
│    - Found a bug? Log it in bugs_and_fixes.md           │
│    - Tests passing/failing? Update testing_log.md       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ SESSION END                                             │
├─────────────────────────────────────────────────────────┤
│ 1. UPDATE ALL MEMORY FILES (critical!)                  │
│    - project_status.md: new phase? new blockers?        │
│    - session_notes.md: what did I complete?             │
│    - change_log.md: finalize all entries                │
│    - architecture_decisions.md: new ADRs?               │
│    - bugs_and_fixes.md: new bugs or fixes?              │
│    - testing_log.md: final test results                 │
│    - MEMORY_PROTOCOL.md: update if process changed      │
│                                                         │
│ 2. ARCHIVE IF NEEDED                                    │
│    - Any memory file > 200 lines? Move old entries to   │
│      memory/archive/ with same name                     │
│                                                         │
│ 3. COMMIT WITH MESSAGE TYING TO MEMORY                  │
│    git commit -m "Phase 2: Implement user roles"        │
│    [reference change_log.md entries]                    │
│                                                         │
│ 4. VERIFY                                               │
│    - All memory files updated? ✓                        │
│    - Change log complete? ✓                             │
│    - Nothing exceeds 200 lines? ✓                       │
│    - Ready for next session? ✓                          │
└─────────────────────────────────────────────────────────┘
```

---

## Memory Hierarchy

Memory is organized in a **hierarchy** from global to specific:

```
┌──────────────────────────────────────────────────────┐
│ GLOBAL CONTEXT (~/.claude/CLAUDE.md)                 │
│ - Your professional identity, tools, preferences     │
│ - Applied to ALL projects you work on                │
│ Lifespan: Permanent (updated occasionally)           │
└──────────────────────────────────────────────────────┘
                        ↓ overridden by
┌──────────────────────────────────────────────────────┐
│ MONOREPO CONTEXT (/monorepo/CLAUDE.md)               │
│ - Shared patterns across multiple projects           │
│ - CI/CD, build tools, testing frameworks             │
│ - Common architectural decisions (if > 1 project)    │
│ Lifespan: Project duration (semi-permanent)          │
└──────────────────────────────────────────────────────┘
                        ↓ overridden by
┌──────────────────────────────────────────────────────┐
│ PROJECT CONTEXT (/project/CLAUDE.md)                 │
│ - This specific project's mission, tech stack        │
│ - Links to memory/ directory                         │
│ Lifespan: Project duration (semi-permanent)          │
└──────────────────────────────────────────────────────┘
                        ↓ overridden by
┌──────────────────────────────────────────────────────┐
│ MEMORY FILES (/project/memory/)                      │
│ - Session-to-session state (7 core files)            │
│ - Updated every session                              │
│ Lifespan: Project lifetime + archived                │
└──────────────────────────────────────────────────────┘
                        ↓ most specific
┌──────────────────────────────────────────────────────┐
│ MODULE-SCOPED NOTES (/project/src/module/NOTES.md)   │
│ - Deep-dive context for complex modules              │
│ - Updated when module is modified                    │
│ Lifespan: Module exists                              │
└──────────────────────────────────────────────────────┘
```

**Example:** If `~/.claude/CLAUDE.md` says "Use TypeScript everywhere," but `/project/CLAUDE.md` says "This is a Python project," Python wins. Project-specific context overrides global defaults.

---

## The 7 Core Memory Files

All memory files live in `/project/memory/`. Each has a specific purpose, format, and update cadence.

### 1. MEMORY_PROTOCOL.md
**Purpose:** The rules governing the entire memory system. This is your "constitution."

**What it contains:**
- How the memory system works (the lifecycle you just read)
- Rules for each memory file (what to update, when, why)
- Archive threshold (e.g., 200 lines)
- Naming conventions
- Permission model (who updates what?)
- Git integration rules

**When updated:** Only when the memory system itself needs change (rare)

**Format:**
```markdown
# Memory Protocol for [Project Name]

## Rules
1. Session start: Read all memory files
2. Session work: Update change_log.md continuously
3. Session end: Update ALL memory files + commit
4. Archive: Move entries > 200 lines to memory/archive/
5. Commit: Always reference change_log entries
6. Conflict: If two files conflict, architecture_decisions.md wins

## Update Cadence
- MEMORY_PROTOCOL.md: Only on system changes (rare)
- project_status.md: Every session end
- session_notes.md: Every session end
- change_log.md: During work (continuously)
- architecture_decisions.md: When architectural choice made
- bugs_and_fixes.md: When bug found or fixed
- testing_log.md: When tests run

## Archive Rules
- Any file > 200 lines: move old entries to memory/archive/{filename}
- Keep recent 200 lines in main file
- Archive is append-only (never delete)
```

**Example Update Scenario:** Your team decides all memory must be committed twice per day instead of once. Update MEMORY_PROTOCOL.md to codify this.

---

### 2. project_status.md
**Purpose:** Living snapshot of the project's current state. What phase are we in? What's blocked? What's next?

**What it contains:**
- Current phase (Alpha, Beta, MVP, Phase 1, Phase 2, etc.)
- Feature tracker (which features are done, in-progress, planned)
- Current blockers (what's preventing progress?)
- Next 3 tasks (what should the next session focus on?)
- Team status (who's working on what, if applicable)
- Deployment status (what's live, what's staging, what's dev?)

**When updated:** Every session end (critical)

**Format:**
```markdown
# Project Status: [Project Name]

## Current Phase
**Phase:** 2 - Core Features (in progress)
**Start Date:** 2026-04-10
**Target Completion:** 2026-05-10
**Progress:** 45% (6 of 13 features complete)

## Feature Tracker
- [x] User authentication (OAuth2 + local)
- [x] User profile CRUD
- [x] Dashboard skeleton
- [ ] Role-based access control (IN PROGRESS - blocker)
- [ ] Payment integration (NOT STARTED)
- [ ] Admin panel (NOT STARTED)
- [ ] Email notifications (NOT STARTED)
- [ ] Rate limiting (NOT STARTED)
- [ ] Analytics (NOT STARTED)

## Current Blockers
1. **RBAC Schema Complexity** (Critical)
   - Problem: Can't decide on role/permission model (flat vs. hierarchical)
   - Decision needed: See architecture_decisions.md entry #12
   - Impact: Blocks RBAC feature, payment flow, admin panel
   - Next step: Review ADR, make decision in next session

2. **Database Constraints** (High)
   - Problem: MySQL strict mode breaking user creation
   - Status: Root cause found, fix pending test
   - Next step: Run full test suite, merge PR

## Next 3 Tasks
1. **Resolve RBAC schema decision** (2 hours estimated)
   - Read architecture_decisions.md #12
   - Decide: flat vs. hierarchical roles
   - Update database schema accordingly

2. **Implement role/permission enforcement** (4 hours estimated)
   - Create middleware for @Authorize decorator
   - Update all API routes with permission checks
   - Write integration tests

3. **Payment module skeleton** (2 hours estimated)
   - Create payment service interface
   - Mock provider for testing
   - Integrate with order workflow

## Team Status
- Alice (frontend): Working on admin panel design
- Bob (backend): Debugging user creation issue
- Claude: Taking over core features (RBAC + payments)

## Deployment Status
- **Dev:** All features, unstable
- **Staging:** Phase 1 only, stable
- **Production:** Phase 1 only, stable
```

---

### 3. session_notes.md
**Purpose:** Per-session log. What was accomplished? What files changed? What's broken? What's the hand-off to the next Claude?

**What it contains:**
- Session date and Claude model version
- Objective (what was the goal?)
- Accomplishments (what was done?)
- Files modified (paths + brief reason)
- Tests run (pass/fail summary)
- Problems encountered (and solutions or next steps)
- Recommendations for next session

**When updated:** Every session end (critical)

**Format:**
```markdown
# Session Notes

## Session 2026-04-18 (Claude Opus 4.6)
**Duration:** 2 hours 15 minutes
**Objective:** Resolve RBAC schema blocker + implement permission enforcement

### Accomplishments
1. ✅ Decided on hierarchical role model (see architecture_decisions.md #12)
2. ✅ Updated database schema with role hierarchy
3. ✅ Implemented @Authorize decorator for Express
4. ✅ Added permission checks to 8 core API routes
5. ✅ Wrote 12 integration tests (all passing)
6. ⚠️ Started payment module skeleton (25% done)

### Files Modified
- src/models/User.ts (added roleId field)
- src/models/Role.ts (new file - role hierarchy)
- src/models/Permission.ts (new file - permission mapping)
- src/middleware/authorize.ts (new file - permission enforcement)
- src/routes/users.ts (added @Authorize decorators)
- src/routes/orders.ts (added @Authorize decorators)
- src/routes/products.ts (added @Authorize decorators)
- database/migrations/001_add_roles.sql (new schema)
- tests/integration/rbac.test.ts (new test suite)
- tests/integration/permissions.test.ts (new test suite)

### Tests Run
- RBAC unit tests: 15/15 passing
- Permission enforcement: 12/12 passing
- API integration: 8/8 passing (with new @Authorize)
- Full suite: 127/127 passing
- Coverage: 81% (target: 80%)

### Problems Encountered
1. **MySQL strict mode issue** (RESOLVED)
   - Problem: `NOT NULL` column without default in role migration
   - Solution: Added `DEFAULT 'user'` to migration
   - Lesson: Test migrations against production MySQL config

2. **Permission caching bug** (FOUND, NOT FIXED)
   - Problem: Permissions cached for 5 minutes, changes don't apply immediately
   - Impact: Admin can't grant/revoke permissions in real-time
   - Status: Documented in bugs_and_fixes.md, low priority
   - Solution: Add permission cache invalidation on role update

3. **Payment module OAuth setup** (DEFERRED)
   - Problem: Stripe API key generation requires live account
   - Status: Can't proceed without staging Stripe account setup
   - Next session: Have team set up Stripe account first

### Recommendations for Next Session
1. **Priority 1:** Get staging Stripe account set up (blocker for payment module)
2. **Priority 2:** Fix permission caching bug (nice-to-have before launch)
3. **Priority 3:** Implement payment module (4-6 hours estimated)
4. **Nice-to-have:** Add audit logging for role/permission changes

### Notes
- RBAC decision was well-motivated (see ADR #12)
- Team consensus on hierarchical approach is good
- Database schema is clean and extensible
- Next Claude should read architecture_decisions.md #12 for context
```

---

### 4. change_log.md
**Purpose:** Chronological record of ALL changes with git commit hashes. This is the "what changed and why" document.

**What it contains:**
- Date, commit hash, commit message
- Files changed
- Why the change was made
- Tickets/issues fixed (if applicable)
- Impact on other systems

**When updated:** During work (continuously), finalized at session end

**Format:**
```markdown
# Change Log

## 2026-04-18

### Session 2026-04-18 (Claude Opus 4.6) - RBAC Implementation + Permission Enforcement
[Commits: a1b2c3d..e5f6g7h]

#### Commit: a1b2c3d - "feat: Add hierarchical role model to database"
- **Files:** database/migrations/001_add_roles.sql, src/models/Role.ts
- **Changes:**
  - Created roles table with parent_id for hierarchy
  - Created role_hierarchy junction table
  - Added roleId foreign key to users table
- **Why:** Resolves architecture decision #12 (hierarchical RBAC)
- **Impact:** Unblocks permission enforcement, admin panel

#### Commit: b2c3d4e - "feat: Implement @Authorize decorator for Express"
- **Files:** src/middleware/authorize.ts (new), src/types/express.d.ts
- **Changes:**
  - Created @Authorize() decorator for route handlers
  - Checks user role against required permissions
  - Returns 403 if insufficient permissions
- **Why:** Enforce permissions at the API layer
- **Impact:** Protects all new API endpoints

#### Commit: c3d4e5f - "feat: Add permission checks to user management routes"
- **Files:** src/routes/users.ts, tests/integration/rbac.test.ts
- **Changes:**
  - Updated GET /users to require 'read:users'
  - Updated POST /users to require 'create:users'
  - Updated PUT /users/:id to require 'update:users'
  - Updated DELETE /users/:id to require 'delete:users'
  - Added 8 integration tests
- **Why:** Secure user management endpoints
- **Impact:** Only admins/managers can modify users

#### Commit: d4e5f6g - "fix: MySQL strict mode in role migration"
- **Files:** database/migrations/001_add_roles.sql
- **Changes:**
  - Added DEFAULT 'user' to roleId column
  - Fixed NOT NULL without default error
- **Why:** Migration was failing in production MySQL
- **Impact:** Migration now runs cleanly

#### Commit: e5f6g7h - "test: Add comprehensive RBAC test suite"
- **Files:** tests/integration/rbac.test.ts, tests/integration/permissions.test.ts
- **Changes:**
  - Created role hierarchy tests (15 tests)
  - Created permission enforcement tests (12 tests)
  - All 27 tests passing
- **Why:** Validate RBAC implementation works correctly
- **Impact:** Confidence in RBAC feature

---

## 2026-04-17

### Session 2026-04-17 (Claude Opus 4.6) - Auth Module Completion
[Commits: z9y8x7w..u6t5s4r]

#### Commit: z9y8x7w - "feat: Add OAuth2 integration with Google"
...
```

**Key points:**
- Every commit gets an entry
- Entry includes the why (not just what)
- Reference to architecture decisions
- Impact statement (helps next Claude understand consequences)

---

### 5. architecture_decisions.md
**Purpose:** Architecture Decision Records (ADRs). Captures WHY architectural choices were made, preventing endless re-debates.

**What it contains:**
- Decision ID and date
- Problem statement (what issue did this solve?)
- Decision (what was chosen?)
- Alternatives considered (why not the others?)
- Consequences (trade-offs, downsides)
- Status (active, superseded, etc.)
- Related decisions (cross-references)

**When updated:** When an architectural choice is made (not every session, but regularly)

**Format:**
```markdown
# Architecture Decisions

## ADR #13 - Hierarchical Role-Based Access Control
**Date:** 2026-04-18
**Status:** Active
**Supersedes:** ADR #8 (flat role model)

### Problem
We needed RBAC to support complex permission models:
- Different user types (user, moderator, admin, super-admin)
- Admin role should include all moderator permissions
- Permissions must be granular (read:users, update:users, delete:users)
- Current flat role model doesn't support inheritance

### Decision
Implement **hierarchical role model** with explicit inheritance:
```
Super Admin (inherits from Admin)
  └─ Admin (inherits from Moderator)
       └─ Moderator (inherits from User)
            └─ User (base role)
```

Each role has explicit permissions. Child roles inherit parent permissions.

### Alternatives Considered
1. **Flat role model** (previous approach)
   - Pros: Simple schema, easy to query
   - Cons: Duplicate permissions for each role, hard to maintain
   - Status: Rejected (insufficient for requirements)

2. **Attribute-based access control (ABAC)**
   - Pros: Extremely flexible, rule-based
   - Cons: Complex to implement, hard to debug, performance impact
   - Status: Rejected (overkill for current scope)

3. **Graph-based roles**
   - Pros: Support arbitrary role relationships
   - Cons: Schema complexity, query complexity
   - Status: Deferred (reconsidering in Phase 3)

### Consequences
**Pros:**
- Clean inheritance model (super-admin has all permissions)
- Granular permission control (read, update, delete separately)
- Easy to add new roles (inherit from existing)
- Simple SQL queries (two joins vs. complex RBAC matrices)

**Cons:**
- Slightly more complex schema (parent_id field + junction table)
- Must maintain consistent permission inheritance
- Role deletion must cascade carefully (can't delete role with children)

### Implementation Notes
- Database: roles table with self-referential foreign key
- ORM: Use eager loading to fetch role hierarchy
- Middleware: Check role + permissions in @Authorize decorator
- Testing: Full hierarchy and permission tests required

### Related Decisions
- ADR #8 (flat role model) - superseded by this
- ADR #14 (permission enforcement middleware) - depends on this

---

## ADR #12 - Use TypeScript for All New Code
**Date:** 2026-04-10
**Status:** Active

### Problem
Codebase mixing JavaScript and TypeScript:
- JavaScript modules lack type safety
- Developers make runtime errors (undefined properties, type mismatches)
- Refactoring is risky (no IDE support)

### Decision
All new code must be TypeScript. Gradually migrate existing JavaScript.

### Consequences
- Longer development time (type definitions upfront)
- Better IDE support and refactoring
- Fewer runtime errors in production
- Better documentation (types act as inline docs)

### Migration Plan
- New code: TypeScript only
- Legacy code: Migrate on-demand (when touching the file)
- Deadline: Phase 3 completion (all TypeScript)

...
```

**Key points:**
- ADRs prevent re-debating: "Why flat roles?" → "Read ADR #8"
- Captures trade-offs (don't just say "we chose X", explain why not Y)
- Status field tracks if decision is still active
- Cross-references prevent silos

---

### 6. bugs_and_fixes.md
**Purpose:** Catalog of bugs found, root causes, and fixes applied. Prevents re-introducing the same bug.

**What it contains:**
- Bug ID and date found
- Symptom (what goes wrong?)
- Root cause (why does it happen?)
- Fix applied (what was changed?)
- Prevention (how to avoid this in future?)
- Status (fixed, workaround, known issue, etc.)
- Related bugs (cross-references)

**When updated:** When a bug is found or fixed (ongoing)

**Format:**
```markdown
# Bugs and Fixes

## BUG #42 - Permission Cache Not Invalidating on Role Update
**Date Found:** 2026-04-18
**Severity:** Medium
**Status:** FOUND (Fix pending)

### Symptom
When an admin updates a user's role, the new permissions don't apply until cache expires (5 minutes later).

**Steps to Reproduce:**
1. Admin user has read:users permission
2. Admin changes their role to viewer (no read:users)
3. Admin can still view user list (cached permission)
4. Wait 5 minutes → permission revoked

### Root Cause
Permission middleware caches permissions for 5 minutes in memory (Redis):
```javascript
const permissions = await redis.get(`perms:${userId}`);
if (!permissions) {
  // Fetch from DB and cache for 5 minutes
  permissions = await db.query(...);
  await redis.setex(`perms:${userId}`, 300, JSON.stringify(permissions));
}
```

When a role is updated, we don't invalidate the cache. Next role change request still gets stale permissions.

### Fix (Applied in Session 2026-04-18)
Added cache invalidation in role update endpoint:
```javascript
async updateUserRole(userId, newRole) {
  // Update database
  await db.query("UPDATE users SET roleId = ? WHERE id = ?", [newRole, userId]);
  
  // Invalidate permission cache
  await redis.del(`perms:${userId}`);
  
  // Invalidate related caches
  await redis.del(`role:${newRole}`);
}
```

**Files Changed:** src/routes/users.ts, src/middleware/cache.ts
**Commit Hash:** e5f6g7h
**Tests Added:** tests/integration/cache-invalidation.test.ts (4 tests)

### Prevention
1. Always invalidate related caches when data changes
2. Consider using cache versioning instead of TTL
3. Add tests for cache invalidation (not just cache hits)
4. Document cache keys in a central cache.keys.ts file

### Related Bugs
- BUG #39 (stale session data) - similar root cause

---

## BUG #39 - Session Data Not Updating After Logout/Login
**Date Found:** 2026-04-10
**Severity:** High (security impact)
**Status:** FIXED (Session 2026-04-15)

### Symptom
User logs out, logs in as different user. Session data for old user persists.

### Root Cause
Session middleware was caching entire session objects. Logout didn't clear cache, so next request got old session.

### Fix (Applied in Session 2026-04-15)
- Added explicit cache invalidation in logout route
- Added session versioning (increment on logout)
- Commit: c3d4e5f-abc123

### Prevention
(See BUG #42 for general cache invalidation strategy)

...
```

**Key points:**
- Bug #42 prevents re-introducing the same cache invalidation issue
- Documents root cause (so developers understand the system)
- Cross-references related bugs (cache invalidation affects multiple areas)
- Prevention section helps avoid similar bugs elsewhere

---

### 7. testing_log.md
**Purpose:** Test results, coverage trends, and regressions. Tracks test health over time.

**What it contains:**
- Date and commit hash
- Test run summary (total tests, pass/fail/skip count)
- Coverage percentage
- Test suites and results
- Regressions (tests that were passing, now failing)
- Coverage gaps (untested areas)
- Next priorities for testing

**When updated:** When tests are run (typically every session end)

**Format:**
```markdown
# Testing Log

## 2026-04-18 - Full Test Suite (Post-RBAC Implementation)
**Date:** 2026-04-18 12:45 UTC
**Commit:** e5f6g7h
**Environment:** Node 18.16, MySQL 8.0 (dev machine)

### Summary
- **Total Tests:** 127
- **Passed:** 127 ✅
- **Failed:** 0 ✅
- **Skipped:** 0
- **Coverage:** 81% (target: 80%) ✅
- **Duration:** 4m 23s

### Test Suites
| Suite | Tests | Pass | Fail | Coverage |
|-------|-------|------|------|----------|
| Unit: Auth | 18 | 18 | 0 | 92% |
| Unit: Models | 24 | 24 | 0 | 85% |
| Unit: Utils | 12 | 12 | 0 | 88% |
| Integration: API Routes | 28 | 28 | 0 | 79% |
| Integration: RBAC | 15 | 15 | 0 | 90% |
| Integration: Permissions | 12 | 12 | 0 | 88% |
| E2E: User Flow | 18 | 18 | 0 | 75% |

### New Tests (Session 2026-04-18)
- RBAC role hierarchy: 15 tests ✅
- Permission enforcement: 12 tests ✅
- Permission cache invalidation: 4 tests ✅

### Regressions
None! All previously passing tests still pass. ✅

### Coverage Gaps
1. **Payment module:** Not yet implemented (0% coverage)
2. **Email service:** Not yet tested (30% coverage)
   - Missing: Email template rendering, delivery failures
3. **Admin panel backend:** Partial coverage (45%)
   - Missing: Role deletion cascade, bulk operations

### Performance Baseline
- Auth test suite: 0.8s (stable)
- Integration suite: 2.5s (stable)
- E2E suite: 1.2s (stable)
- Total: 4.5s → 4m 23s (with full report output)

### Next Testing Priorities
1. **Payment module tests** (when module implemented)
   - Credit card validation tests
   - Payment provider integration tests
   - Refund handling tests

2. **Email service tests** (improve from 30% to 80%)
   - Template rendering tests
   - Delivery failure handling
   - Bounce/complaint handling

3. **Admin panel backend tests** (improve from 45% to 80%)
   - Role deletion cascade tests
   - Bulk user import tests
   - Permission inheritance edge cases

### Known Test Issues
- BUG #35: E2E tests timeout occasionally on slow machines
  - Workaround: Use `--timeout 10000` flag
  - Solution: Refactor E2E setup to use fixtures (Phase 3)

---

## 2026-04-15 - Critical Path Test Run
**Date:** 2026-04-15 18:30 UTC
**Commit:** c3d4e5f
**Environment:** Node 18.16, MySQL 8.0

### Summary
- **Total Tests:** 112
- **Passed:** 111 ✅
- **Failed:** 1 ❌ (Fixed next session)
- **Skipped:** 0
- **Coverage:** 79% (target: 80%)
- **Duration:** 3m 58s

### Failure Details
**Test:** tests/integration/sessions.test.ts - "Should clear session on logout"
**Error:** Timeout after 5000ms
**Root Cause:** Session cache not being invalidated (BUG #39)
**Status:** Fixed in Session 2026-04-18 (Commit c3d4e5f-abc123)

...
```

**Key points:**
- Track coverage trends (is it going up or down?)
- Document regressions (which previously passing tests now fail?)
- Baseline performance (detect test slowdowns)
- Testing priorities guide next session's work

---

## Archive System

Memory files should stay **under 200 lines**. When a file exceeds 200 lines, archive old entries.

### Archive Process

1. **When:** Check file size at session end. If > 200 lines, archive.
2. **How:** Move old entries to `memory/archive/{filename}`
3. **Keep:** Most recent entries in main file (up to 200 lines)
4. **Archive Properties:** Append-only (never delete), never move back

### Example

**Before archiving (change_log.md = 280 lines):**
```
memory/
├── change_log.md (280 lines - too big!)
└── archive/
    └── (empty)
```

**After archiving:**
```
memory/
├── change_log.md (140 lines - recent entries only)
└── archive/
    └── change_log.md (140 lines - old entries)
```

**change_log.md (after archive):**
```markdown
# Change Log

## 2026-04-18
[Recent 6 commits from Session 2026-04-18]

---

## Archive
See memory/archive/change_log.md for entries before 2026-04-10
```

**memory/archive/change_log.md:**
```markdown
# Change Log Archive

## 2026-04-10
[Commits from Session 2026-04-10]

## 2026-04-05
[Commits from Session 2026-04-05]

...
```

### Archive Rules
1. **Archive only old entries**, not recent ones
2. **Never delete** archived entries
3. **Append to archive**, never replace
4. **Update main file** with "See memory/archive/..." note
5. **Archive size is unlimited** (unlike main files)
6. **Main file always under 200 lines** after archiving

---

## Memory Rules & Governance

### Core Rules

1. **Read at START**
   - Before doing ANY work, read all memory files (5-10 minutes)
   - Understand current phase, blockers, previous decisions
   - If a rule says "read X.md first," you probably should

2. **Update DURING WORK**
   - Update change_log.md as you make changes (not at the end)
   - Log each significant decision or discovery
   - Makes it easier to finalize memory at session end

3. **Update at END**
   - Update project_status.md (new phase? new blockers?)
   - Update session_notes.md (what was accomplished?)
   - Update all other files that changed
   - Finalize change_log.md
   - **CRITICAL:** No session is complete without memory updates

4. **Commit with Message**
   - Every commit message should reference memory files
   - Example: `git commit -m "feat: Add RBAC - see architecture_decisions.md #13"`
   - Ties code changes to architectural decisions

5. **Archive when Needed**
   - Check file sizes at session end
   - Archive files > 200 lines
   - Move old entries, keep recent ones

6. **Never Delete from Archive**
   - Archive is append-only
   - It's your project's institutional memory
   - Future you will want to know what happened 6 months ago

### Governance: Who Updates What?

If working alone (typical with Claude):
- **You update everything.** All 7 files are your responsibility.

If working with a team:
- **Project manager:** Updates project_status.md + blocks
- **Tech lead:** Updates architecture_decisions.md + test strategy
- **Engineers:** Update session_notes.md + bugs_and_fixes.md
- **QA/Test:** Updates testing_log.md
- **Everyone:** Updates change_log.md (what they committed)

---

## Practical Examples

### Example 1: Typical Session with Memory

**Session start:**
```markdown
Today's goal: Implement user profiles (Phase 2).
Last session: Auth module complete, roles decided.

Reading memory...
- project_status.md: Phase 2, 45% done, RBAC blocker resolved
- session_notes.md: Last session was RBAC implementation (e5f6g7h)
- architecture_decisions.md #13: Hierarchical role model
- bugs_and_fixes.md: Permission cache issue (BUG #42) found
- testing_log.md: All 127 tests passing

Current state: RBAC complete, ready to build user profiles.
Let me check what's blocking...

Reading more:
- change_log.md: Commit e5f6g7h added @Authorize decorator
- project_status.md next task: "Implement payment module skeleton"

Wait, that conflicts. Let me re-read project_status.md...
"Next 3 tasks: 1. Resolve RBAC... 2. Implement role/permission enforcement... 
3. Payment module skeleton"

So RBAC is done (Task 1 & 2 complete). Now I should do Task 3 (payment module).

Let me start work on payment module...
```

**During work (updating change_log.md):**
```markdown
## 2026-04-19

### Session 2026-04-19 (Claude Opus 4.6) - Payment Module Skeleton

#### Commit: a1b2c3d - "feat: Add payment service interface"
- Files: src/services/payment.ts (new)
- Why: Defines contract for payment providers (Stripe, PayPal, etc.)
- Impact: Ready to integrate first provider

#### Commit: b2c3d4e - "feat: Add mock payment provider for testing"
- Files: src/services/providers/mock.ts (new)
- Why: Allow testing without real payment provider
- Impact: Can test payment flow without Stripe account
```

**Session end (updating ALL memory files):**
```markdown
# session_notes.md - Updated

## Session 2026-04-19 (Claude Opus 4.6)
**Duration:** 3 hours
**Objective:** Implement payment module skeleton

### Accomplishments
1. ✅ Created payment service interface
2. ✅ Created mock provider for testing
3. ✅ Integrated with order workflow
4. ✅ Wrote 8 tests (all passing)

### Files Modified
- src/services/payment.ts (new)
- src/services/providers/mock.ts (new)
- src/services/providers/types.ts (new)
- src/routes/orders.ts (modified to use payment service)
- tests/unit/payment.test.ts (new)

### Problems Encountered
- Had to create mock provider before real Stripe integration
  (Stripe sandbox account not yet set up)

### Recommendations for Next Session
1. Set up Stripe sandbox account (blocker for real integration)
2. Implement Stripe provider (4 hours)
3. Add payment tests with Stripe fixtures (2 hours)
```

**Finalize memory files:**
- ✅ project_status.md: Updated next tasks (Stripe integration now Task 1)
- ✅ session_notes.md: Completed (above)
- ✅ change_log.md: Finalized 3 commits
- ✅ architecture_decisions.md: No new decisions (no changes needed)
- ✅ bugs_and_fixes.md: No new bugs (no changes needed)
- ✅ testing_log.md: Added test results (all 135 tests passing)
- ✅ MEMORY_PROTOCOL.md: No changes (unchanged)

**Commit message:**
```bash
git commit -m "feat: Payment module skeleton

- Created payment service interface for extensibility
- Added mock provider for testing without Stripe
- Integrated with order workflow
- All 135 tests passing (new 8 payment tests)

See:
- change_log.md: commits a1b2c3d, b2c3d4e, c3d4e5f
- project_status.md: Phase 2, 50% complete
- session_notes.md: Session 2026-04-19 summary
"
```

---

### Example 2: Handling a Bug Discovery Mid-Session

**During work:**
```
Oh no! Found a bug in email sending. Emails are going out twice.

Update change_log.md immediately:
---
#### BUG DISCOVERED: Email sending twice
- Symptom: Users receive duplicate emails
- Root cause: (investigating)
- Impact: Blocks Phase 3 email notification feature
---

Keep working on payment module (scheduled task), but note the bug.
```

**Session end (update bugs_and_fixes.md):**
```markdown
## BUG #47 - Duplicate Emails Sent
**Date Found:** 2026-04-19
**Severity:** Medium
**Status:** FOUND (Fix pending, Priority: High)

### Symptom
When a user completes checkout, they receive the order confirmation email twice.

### Root Cause
(Investigating - needs more testing)

### Recommendation for Next Session
1. Reproduce bug with test suite
2. Check email service queue logic
3. Check database triggers (might have duplicate logic)
4. Fix and add tests

### Related
- BUG #42 (cache invalidation) - different root cause but check if related
```

**Update project_status.md:**
```markdown
## Current Blockers
2. **Duplicate Email Bug** (Medium)
   - Problem: Users get order emails twice
   - Found in Session 2026-04-19
   - Status: Root cause unknown
   - Next step: Investigate email service queue logic
```

---

## Common Mistakes & Solutions

### Mistake 1: Forgetting to Update Memory at Session End

**Problem:**
```
Session 2026-04-19 (Claude): Implemented payment module, all tests passing!
[Claude session ends]

Session 2026-04-20 (Claude): What did I do yesterday? No idea. Let me re-read the code...
[Wastes 30 minutes understanding yesterday's work]
```

**Solution:**
- Make memory updates part of your session checklist
- Don't close the session until ALL memory files are updated
- Use this checklist:
  ```
  Session End Checklist:
  - [ ] project_status.md updated?
  - [ ] session_notes.md completed?
  - [ ] change_log.md finalized?
  - [ ] architecture_decisions.md (if any new decisions)?
  - [ ] bugs_and_fixes.md (if any bugs found)?
  - [ ] testing_log.md updated?
  - [ ] MEMORY_PROTOCOL.md (if rules changed)?
  - [ ] All files under 200 lines (archive if needed)?
  - [ ] Committed with message referencing memory?
  ```

---

### Mistake 2: change_log.md Too Vague

**Bad:**
```markdown
#### Commit: abc123 - "Update auth"
- Files: src/auth.ts
- Changes: Fixed stuff
```

**Good:**
```markdown
#### Commit: abc123 - "fix: OAuth2 token refresh when expiry < 5 minutes"
- Files: src/services/auth.ts
- Changes: Added expiry check before making API call, refresh if expired
- Why: Token expiry was causing "Unauthorized" errors mid-request
- Impact: OAuth2 flows now work reliably without manual refresh
```

**Solution:**
- Always explain the **why** (not just what)
- Reference architecture decisions or bugs (gives context)
- Include impact statement (helps prioritize future work)

---

### Mistake 3: Blocker Grows Stale

**Problem:**
```markdown
## Current Blockers
1. **Payment API Integration** (Critical)
   - Status: Waiting for Stripe account setup
   - Last updated: 2026-04-15
   - It's now 2026-04-20. Did anyone set up Stripe?
```

**Solution:**
- Update blockers EVERY session (even if no change)
- If blocker isn't resolved, update "Next step" to clarify what's blocking
- If blocker is resolved, update project_status.md immediately
- Add target resolution date to critical blockers

```markdown
## Current Blockers
1. **Payment API Integration** (Critical)
   - Status: Waiting for Stripe account setup
   - Blocker: Finance team must approve Stripe contract
   - Target: 2026-04-22
   - Last updated: 2026-04-19 (still pending)
   - Next step: Check with finance team on Monday
```

---

### Mistake 4: Architecture Decisions Not Recorded

**Problem:**
```
Session 2026-04-18: Decided to use hierarchical roles
Session 2026-04-25: New Claude joins: "Why hierarchical roles? Why not flat?"
[Debate happens again, same conclusion, wasted time]
```

**Solution:**
- Immediately after making architectural decision, update architecture_decisions.md
- Include problem, decision, alternatives, consequences
- Reference in change_log.md and git commits
- Next Claude reads ADR and skips the debate

---

### Mistake 5: Test Regressions Not Tracked

**Problem:**
```
Session 2026-04-15: 127 tests passing
Session 2026-04-18: 125 tests passing (silent regression)
Session 2026-04-22: Only 120 tests passing (didn't notice!)
```

**Solution:**
- Update testing_log.md after every test run
- Track total count, pass/fail, and coverage percentage
- Highlight regressions (tests that were passing, now failing)
- Make regressions a failure condition for any session

---

### Mistake 6: Archive Never Happens

**Problem:**
```
project_status.md = 450 lines (way too big!)
session_notes.md = 380 lines (bloated!)
change_log.md = 600 lines (unwieldy!)

New Claude tries to read memory: "TL;DR" - gives up
[Memory files become useless]
```

**Solution:**
- Check file sizes at session end
- If > 200 lines, archive immediately
- Archive should be your normal process (not exception)

**Archiving checklist:**
```
- [ ] change_log.md < 200 lines? (archive if not)
- [ ] session_notes.md < 200 lines? (archive if not)
- [ ] project_status.md < 200 lines? (archive if not)
- [ ] All others < 200 lines?
- [ ] Archive contains old entries?
- [ ] Main files updated with "See archive" note?
```

---

## Memory Maintenance Tips

### Tip 1: Weekly Memory Consolidation

Even if you work every day, take 15 minutes weekly to:
1. Review all memory files for consistency
2. Update cross-references (links between files)
3. Remove duplicates (if same topic in multiple files)
4. Archive stale entries
5. Verify against current code state

```markdown
# Weekly Memory Check

- [ ] Read all memory files (top to bottom)
- [ ] Are blockers current? (resolve or update target date)
- [ ] Is project_status.md next tasks still right?
- [ ] Do change_log.md entries match actual commits?
- [ ] Any cross-reference links broken?
- [ ] Architecture decisions still active? (no superseded entries?)
- [ ] Archive any file > 200 lines
```

---

### Tip 2: Memory Search Pattern

When you need to understand something:
1. **Quick answer?** → Read project_status.md (current state)
2. **Why was something built?** → Read architecture_decisions.md
3. **What changed in a feature?** → Read change_log.md
4. **What broke? How to avoid?** → Read bugs_and_fixes.md
5. **Full history of a session?** → Read session_notes.md

---

### Tip 3: Link Memory to Code Comments

When something critical is documented in memory, add a pointer in the code:

**Bad:**
```javascript
// Check permission before allowing access
if (!user.permissions.includes('read:users')) {
  throw new Error('Forbidden');
}
```

**Good:**
```javascript
// Permission enforcement: See architecture_decisions.md #13 (RBAC)
// and middleware/authorize.ts for @Authorize decorator implementation
if (!user.permissions.includes('read:users')) {
  throw new Error('Forbidden');
}
```

This lets developers jump from code to decision, understanding the why.

---

### Tip 4: Use Memory as Onboarding Tool

When a new Claude joins, skip the "re-explain everything" phase:
```
"Here's the project. Start by reading:
1. /project/CLAUDE.md (project overview)
2. memory/project_status.md (current state)
3. memory/session_notes.md (last session)
4. memory/architecture_decisions.md (how we built things)
5. memory/bugs_and_fixes.md (what to avoid)

Read those in order. Takes 10 minutes. Then you'll know everything you need."
```

Instead of: "Let me explain the project... [30 minutes later] ...does that make sense?"

---

### Tip 5: Version Your Memory Protocol

As you refine your process, document the evolution:

```markdown
# MEMORY_PROTOCOL.md

## Evolution
- v1.0 (2026-01-01): Initial protocol, 5 memory files
- v2.0 (2026-02-15): Added testing_log.md for test tracking
- v2.1 (2026-03-20): Added archive system for files > 200 lines
- v2.6 (2026-04-18): Added architecture_decisions.md for ADRs

## Current Version
2.6.0 - See changelog above for what's new
```

This helps future work understand when and why the system changed.

---

## Conclusion

The memory system is the backbone of sustainable AI-assisted development. Without it, every Claude session is an island. With it:
- ✅ Next session knows what you did
- ✅ Architectural decisions aren't re-debated
- ✅ Bugs aren't re-introduced
- ✅ Blockers are tracked and resolved
- ✅ Project momentum is maintained

**Remember: "A session without memory updates is a session that never happened."**

Update your memory files. Future you will thank you.
