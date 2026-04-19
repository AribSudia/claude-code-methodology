---
argument-hint: "<feature-name>"
description: "Dev | Start a new feature with branch, planning, TDD workflow, and safety snapshot"
---

# Feature Development — /arib-dev-feature

## Overview

Structured feature development prevents costly mistakes: **scope creep** that derails timelines, **untested code** landing in production, **lost work** from missing recovery points, and **undocumented changes** that confuse future sessions (or future you). This skill enforces a 7-step protocol that turns feature requests into production-ready code.

Use this skill every time you start a new feature. Do NOT use for bug fixes (use `/arib-dev-debug`) or pure refactoring (just branch and commit).

## When to Use

- Starting any new feature (mandatory)
- Adding significant new functionality to existing code
- Introducing new API endpoints or data models
- NOT for bug fixes (use `/arib-dev-debug`)
- NOT for refactoring without new functionality (just branch + commit)

## The Protocol (7 Steps)

### Step 1: Research Phase

Before writing a single line of code, gather intelligence. This prevents implementing something that already exists or violates project constraints.

**Read these files in order:**

1. **API_ENDPOINTS.md** — What endpoints/APIs already exist? What formats do they use? What does this feature need to integrate with?
2. **CONSTRAINTS.md** — Hard rules: max function length, file size limits, required test coverage, forbidden patterns, framework version restrictions
3. **TECH_STACK.md** — Approved libraries only. Check if the tool you want to use is on the approved list
4. **Search the codebase** — Use `grep` to find similar patterns, existing features, shared utilities you can reuse

**Decision point**: "Does a similar feature already exist? If yes, extend it rather than duplicating."

Outcome: A one-paragraph summary of what the feature needs, what constraints apply, and what it can reuse.

### Step 2: Create Feature Branch

Always branch from `develop`, never from `main`. Feature branches are your sandbox.

```bash
git checkout develop
git pull origin develop
git checkout -b feature/[feature-name]
git push -u origin feature/[feature-name]
```

**Branch naming conventions:**
- ✅ `feature/user-authentication` (kebab-case, descriptive)
- ✅ `feature/JIRA-123-user-auth` (ticket reference + description)
- ❌ `feature/fix-stuff` (too vague)
- ❌ `feat/auth` (use `feature/` not `feat/`)

Why remote immediately? Because branches get lost if they only exist locally. Push to remote as your first backup.

### Step 3: Safety Snapshot

Tag the clean state before you start implementing. If things go sideways, this is your ejection seat.

```bash
git tag -a feature/[feature-name]/snapshot -m "Safety snapshot before implementing [feature-name]"
git push origin feature/[feature-name]/snapshot
```

**When to use rollback:**
```bash
git reset --hard feature/[feature-name]/snapshot
git push --force-with-lease origin feature/[feature-name]
```

Use `--force-with-lease` instead of `--force` — it's safer because it rejects the push if someone else has pushed since your last pull.

### Step 4: Implementation Plan

Create a structured plan document. Present this to the user; do NOT write it to a file yet (they need to approve first).

**Format:**

```
## Implementation Plan: [feature-name]

### Scope
[1–2 sentences on what this feature does and who uses it]

### Files to Create
| File | Purpose | Est. Lines |
|------|---------|-----------|
| src/auth/login.ts | Login handler | ~80 |

### Files to Modify
| File | Change | Risk Level |
|------|--------|------------|
| src/routes/index.ts | Add auth routes | Low |

### Tests Required
| Test File | What It Tests | Type |
|-----------|---------------|------|
| tests/auth/login.test.ts | Login flow | Unit |

### Dependencies
- [ ] New packages needed: [list or "none"]
- [ ] Database migrations: [yes/no, describe if yes]
- [ ] Environment variables: [list or "none"]
- [ ] API changes: [describe breaking changes or new endpoints]

### Risk Assessment
- Complexity: [Low/Medium/High]
- Files touched: [N]
- Breaking changes: [Yes/No — explain impact if yes]
- Rollback plan: Safety snapshot at `feature/[feature-name]/snapshot`
```

### Step 5: User Approval Gate

Present the plan and ask three explicit questions:
1. "Does this plan align with your vision for [feature-name]?"
2. "Any changes to the approach?"
3. "Should I proceed?"

NEVER skip this step, even for "obvious" features. An unexpected scope change discovered here costs minutes; discovered after implementation costs hours.

Wait for explicit approval (yes/confirm/approved) before moving to Step 6.

### Step 6: TDD Implementation

Follow the RED → GREEN → REFACTOR cycle religiously. This ensures code is both correct and refactorable.

**RED Phase: Write a failing test**
```
# Write test that describes expected behavior
# Run test → should FAIL (proves test is meaningful, not a false positive)
```

**GREEN Phase: Write minimum code to pass**
```
# Implement just enough to make the test pass
# Don't optimize yet — just make it work
# Speed > perfection in this phase
```

**REFACTOR Phase: Clean up**
```
# Improve code structure, naming, performance
# Run tests again → should still pass
# If tests break during refactor → revert refactor, try again
```

**Commit after each complete cycle:**
```bash
git add [specific-files]
git commit -m "feat([scope]): [what was implemented]"
```

**Commit message examples:**
- ✅ `feat(auth): add login endpoint with JWT generation`
- ✅ `test(auth): add login flow unit tests`
- ❌ `feat(auth): wip` (work-in-progress)
- ❌ `feat: stuff` (vague)

**When TDD doesn't fit:**
- **UI/visual work** → write tests after implementation, but before committing
- **Configuration/infrastructure** → verify manually, document verification steps
- **Third-party integrations** → write integration tests with real service if possible

### Step 7: Documentation & Closure

After all tests pass and code is committed:

1. **Update memory/change_log.md** — What was built? How many lines? How many tests?
2. **Update memory/project_status.md** — Mark feature as complete or in-progress (if multi-session)
3. **Update README.md** — If the feature is user-facing, add usage examples
4. **Add API docs** — If endpoints changed, document request/response formats
5. **Run full test suite** — `npm test` or equivalent. All tests must pass.
6. **Final commit** — Mark the feature as complete with a summary commit

Outcome: Feature is fully documented, tested, and ready for review.

## Quick Reference: Pre-Implementation Checklist

Before writing code, verify:

- [ ] I've read API_ENDPOINTS.md
- [ ] I've read CONSTRAINTS.md (checked max function length, test coverage %, forbidden patterns)
- [ ] I've read TECH_STACK.md (confirmed all libraries are approved)
- [ ] I've searched the codebase (confirmed no duplicate feature exists)
- [ ] I've created a feature branch from `develop`
- [ ] I've created a safety snapshot tag
- [ ] I've presented the implementation plan to the user
- [ ] I've received explicit user approval
- [ ] All tests will be written before implementation

## Common Mistakes

These cause rework and frustration. Avoid them.

| Mistake | Impact | Fix |
|---------|--------|-----|
| Implementing before planning | Rework, scope creep | Create plan first, get approval |
| Skipping the safety snapshot | Can't rollback cleanly | Always tag before implementing |
| Writing all code then all tests | Tests don't catch real bugs, defeats TDD | Write test first, one cycle at a time |
| Giant commits with mixed concerns | Hard to review, hard to revert | Commit after each RED→GREEN→REFACTOR |
| Not checking CONSTRAINTS.md first | Implementing something that violates rules | Read constraints in Step 1 |
| Pushing to develop/main instead of feature branch | Breaks CI, affects other developers | Always use `feature/` branches |

## Edge Cases

### Feature Depends on Another Unmerged Feature

Branch from that feature branch instead of develop:

```bash
git checkout feature/dependency-feature
git checkout -b feature/new-feature
```

Document this dependency in the implementation plan. When the dependency merges, rebase onto develop.

### Feature Requires Database Migration

1. **Create migration FIRST** — before any code changes
2. **Run `/arib-check-migrate`** — verify safety and backward compatibility
3. **Apply migration** — to your local database
4. **Implement code** — that uses the new schema
5. **Document rollback** — how to roll back migration if deployment fails

### Feature Spans Multiple Sessions

If you can't finish in one session:

1. Commit work-in-progress with: `feat([scope]): WIP - [what's done so far]`
2. Document in `memory/session_notes.md` exactly where you stopped, what's left
3. Next session reads that note and picks up from that point

## Related Skills

- `/arib-dev-review` — Review the feature before merging to develop
- `/arib-dev-debug` — If bugs arise during implementation
- `/arib-check-perf` — Performance check before merge
- `/arib-check-a11y` — Accessibility check for frontend features
- `/arib-check-migrate` — Database migration safety check

## Why This Protocol Works

Each step removes a category of risk:
- **Step 1 (Research)** — prevents duplicate work and constraint violations
- **Step 2 (Branch)** — isolates your work from others
- **Step 3 (Snapshot)** — gives you an emergency rollback point
- **Step 4 (Plan)** — aligns you with the user before expensive work
- **Step 5 (Approval)** — prevents scope surprises mid-implementation
- **Step 6 (TDD)** — ensures code is correct, refactorable, and well-tested
- **Step 7 (Documentation)** — ensures future maintainers understand what was built and why
