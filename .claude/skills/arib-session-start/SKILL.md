---
description: "Session | Initialize session — read context, check I/O channel, report status, wait for approval"
---

# Session Start — /arib-session-start

## Overview

Session Start is the foundation of productive Claude Code work. Every session—whether it's the first of the day or a quick check-in after switching branches—must begin with full context awareness. This skill ensures Claude Code never starts blind.

**Why it matters:**
- **Context continuity**: You load the exact state where the last session left off (what was done, what's blocked, what's next)
- **No wasted work**: You read constraints and error patterns upfront, not after coding yourself into a corner
- **Safety gates**: You check the I/O channel for urgent signals from Cowork (user overrides, blockers, pivots) before committing to a plan
- **Alignment**: You explicitly wait for user approval, so unexpected changes or priorities get surfaced before you write a single line

Without Session Start, you might:
- Repeat a solved problem because you don't know it was solved
- Violate a constraint and waste an hour reworking code
- Miss a critical blocker that invalidates the current plan
- Start coding without knowing the user's actual priority for today

**Session Start is mandatory. No exceptions.**


## When to Use

- **First thing in every session** — Type `/arib-session-start` before doing anything else
- **After a long break (>24h)** — To re-sync with changes other developers may have pushed
- **After switching branches** — To load context specific to the new branch
- **After another developer pushed changes** — To ensure your mental model matches the actual codebase
- **When context feels stale** — If you're unsure whether your assumptions are still valid, re-run

**Short answer:** When in doubt, run it. The cost is 2 minutes of reading; the benefit is avoiding hours of rework.


## The Protocol — 6 Steps

### Step 0: I/O Channel Scan

The I/O channel is the bridge between Cowork (user oversight, async requests) and Claude Code (execution engine). It carries three types of information:

- **SIGNALS**: Urgent directives that stop everything else (halt, escalate, hotfix, rollback)
- **REQUESTS**: Queued work items awaiting processing
- **Clear**: No pending items; proceed normally

**Run:**
```bash
bash scripts/io-watcher.sh
```

**Decision tree:**

- **SIGNALS found** → Process immediately, before anything else
  - `halt` → Stop all work, report to user, wait for new direction
  - `escalate` → Notify user of a critical issue, wait for response
  - `hotfix` / `rollback` → Execute the code action specified, then report
  
- **REQUESTS pending** → Report all pending items to user with priorities; propose processing order
  - Do not start core session work until user confirms the priority list
  
- **Clear** → No urgent items; continue to Step 1

**Key principle**: "The I/O channel bridges Cowork (oversight) and Claude Code (execution). Signals are urgent and interrupt the plan; requests are queued work that needs user prioritization."


### Step 1: Read Core Documentation

These five files form the foundation of everything you do. Read them in this exact order—each builds on the previous.

**1. CLAUDE.md** (Project Identity & Rules)
- **Why**: This is the master brain. It defines what this project is, who maintains it, the golden rules that never bend, the overall structure, and a reference guide to all skills
- **What to look for**: Architecture overview, key principles, forbidden patterns, project goals, team structure, skill descriptions
- **Impact**: If CLAUDE.md says something, it's the law

**2. CONSTRAINTS.md** (Hard Boundaries)
- **Why**: Hard limits you must never violate. Framework versions, maximum file sizes, performance budgets, API limits, architectural constraints
- **What to look for**: Version pins (Node 18.x, Python 3.11+, etc.), forbidden libraries, maximum bundle size, latency SLOs, test coverage minimums
- **Impact**: Violate these and your code will be rejected. Read this before proposing any technical approach

**3. TECH_STACK.md** (Approved Libraries & Versions)
- **Why**: The approved toolkit. If it's not on this list, ask before using it
- **What to look for**: Backend framework, ORM, testing library, CSS approach, build tool, observability, database
- **Impact**: If you want to use a library not listed, propose it explicitly—don't surprise the user with a new dependency

**4. CONTEXT_MAP.md** (Folder Structure & Ownership)
- **Why**: Prevents you from creating files in the wrong place or duplicating what already exists
- **What to look for**: High-level folder structure, ownership of each area (frontend, backend, infra), where configs live, where tests go, where to add new features
- **Impact**: Saves you from "I created a file but it should have gone in /services not /lib"

**5. ERROR_PATTERNS.md** (Known Pitfalls & Solutions)
- **Why**: Avoid repeating mistakes. Every recurring issue lives here with its diagnosis and solution
- **What to look for**: Common bugs, performance issues, gotchas specific to this project, patterns that seemed good but caused problems
- **Impact**: If you spot a pattern from this list, you already know the solution

**Reading order is critical.** CLAUDE.md sets global context; CONSTRAINTS.md sets boundaries; the remaining three fill in detail.


### Step 2: Read Memory Files

These files record the living state of the project—what's in progress, what's blocked, what the last session accomplished.

**1. project_status.md**
- Current project phase (planning, development, beta, production, post-launch)
- Active milestone and feature tracker
- Known blockers (API not ready, waiting on design, performance regression, etc.)
- Current focus area

**2. session_notes.md**
- Summary of the last session: what was done, what was attempted, what failed
- **"Next Session Starts With"** section — if it says "Next Session Starts With: Fix the failing auth tests", that's your top priority unless the user overrides
- Problems encountered and their status (resolved, still blocking, workaround in place)
- Changes to memory files (constraints added, error patterns discovered, architecture updated)

**Critical rule**: If `session_notes.md` explicitly states "Next Session Starts With: [task]", treat that as the default plan. The user may override it, but you must propose it first.


### Step 2.5: Infrastructure Health Check (Conditional)

**Detection logic**: Does this project have infrastructure to check?
- Look for `docker-compose.yml` in project root
- Check TECH_STACK.md for mentions of services (Redis, PostgreSQL, RabbitMQ, etc.)
- Look for multiple service directories (e.g., `/services/api`, `/services/worker`, `/services/auth`)

**If microservices architecture detected:**
```bash
bash scripts/services-check.sh
```

- **ALL HEALTHY** → Report "All N services running ✅" and continue normally
- **ANY DOWN** → Propose starting them: "N service(s) are down. Start all with `docker compose up -d`?"
  - If user says yes → Run `docker compose up -d`, wait 10 seconds, re-check
  - If user says no → Note in session report: "⚠️ Partial infrastructure — integration tests may fail"
- **ANY UNHEALTHY** (running but failing health checks) → Show recent logs: `docker compose logs --tail=30 [service-name]`, propose fix
- **No docker-compose.yml found** → Skip this step (monolith or frontend-only project)

**Why this matters**: Many tests and local development require all services running. If services are down, you'll hit mysterious failures later. Catching this now saves debugging time.


### Step 3: Environment Check

Get the ground truth about what branch you're on and what's changed recently.

**Run:**
```bash
git status
git branch
git log --oneline -5
```

**What to look for:**

- **Uncommitted changes** → Warn user: "You have N uncommitted changes. Are they intentional?" (they might be scratch work, or they might be important context)
- **Detached HEAD** → Warn user: "You're in detached HEAD state. Should I check out a branch?" (usually unintentional)
- **Branch mismatch vs. session_notes** → If session_notes say "Continue on feature/auth-refactor" but you're on develop, ask: "Last session was on feature/auth-refactor. Should I switch?"
- **Recent commits by others** → Summarize changes: "Since last session, 3 commits were merged: [list]. Any blockers or conflicts to be aware of?"
- **Behind/ahead of main/develop** → Note: "Your branch is 8 commits ahead of develop" (important for planning merge strategy)


### Step 4: Session Report

Present a structured report that gives the user a complete picture of where things stand.

**Template:**

```
## Session Report — [DATE] [TIME]

**I/O Status**: [Clear / N signals / N requests pending]

**Branch**: [branch-name] ([N commits ahead of develop] / [N commits behind])

**Infrastructure**: [All healthy / N service(s) down / N service(s) unhealthy]

**Last Session**: [date] — [brief summary from session_notes.md]

**Current Task**: [from project_status.md — the high-level focus]

**Blockers**: 
- [from session_notes or project_status]
- [any discovered in this check]

### Recent Changes (Last 5 Commits)
- abc1234 feat: added user authentication endpoint
- def5678 fix: corrected timezone handling in date picker
- ghi9012 refactor: extract validation logic into helpers
- jkl3456 docs: update API response schema
- mno7890 chore: bump lodash to 4.17.21

### Proposed Plan

Based on loaded context, propose a prioritized plan:

1. **Priority 1** — [from session_notes "Next Session Starts With" or I/O signal]
2. **Priority 2** — [from project_status blockers or identified issue]
3. **Priority 3** — [from user context or discovered opportunity]

**Estimated scope**: [10 min / 1 hour / full day]

**Risks/Notes**:
- [any constraint violations to watch for]
- [infrastructure considerations]
- [dependencies on other work]
```

**Be explicit.** The report is the contract between you and the user. If the plan surprises them, they'll say so here.


### Step 5: Wait for Approval

**STOP. Do not proceed without explicit user approval.**

This pause is not optional—it's a safety gate. The user may:
- Reprioritize (tell you to do Priority 2 first, or skip Priority 3 entirely)
- Add context (mention a conversation with the team, a new constraint, a deadline)
- Redirect entirely (pivot to a different task)

**Never assume the report is approved.** Always end with: "Ready to start? Say yes/confirm, or let me know if you'd like to adjust the plan."


## Edge Cases & Decision Trees

### First Session Ever (No Memory Files)

**Scenario**: session_notes.md or project_status.md don't exist or are empty.

**Action:**
- Run `/arib-session-start` normally, but note in the report: "First session detected — no prior context available"
- Propose running `/bootstrap` or `/reverse-bootstrap` to initialize memory structure
- Ask user to provide the session's goal explicitly (since there's no memory to guide it)

### Conflicting Information

**Scenario**: CONSTRAINTS.md says "React only, no Vue" but session_notes say "We're refactoring to Vue in this session".

**Action:**
- CONSTRAINTS.md wins. It's the source of truth for hard rules.
- Report the conflict explicitly: "⚠️ Conflict detected: session_notes mention Vue refactoring, but CONSTRAINTS.md forbids it. Clarifying with user before proceeding."
- Wait for user decision (maybe the constraint is outdated and needs to be updated)

### Branch Mismatch

**Scenario**: session_notes say "Continue on feature/user-profiles" but you're currently on develop.

**Action:**
- Ask the user: "Last session was on feature/user-profiles, but you're currently on develop. Should I switch back to that branch?"
- Do not assume. The user might have intentionally switched (to work on something else, to merge first, etc.)

### Services Down During Session

**Scenario**: Step 2.5 shows a service is down, user declines to start it.

**Action:**
- Note prominently in the session report: "⚠️ Redis is offline — integration tests will fail, some features unavailable"
- Suggest alternative work: "Consider working on unit tests, documentation, or features that don't require Redis while we investigate why it's down"
- Continue session, but flag any test failures as potentially infrastructure-related


## Common Mistakes to Avoid

1. **Starting to code before reading all context files**
   - Mistake: See what needs fixing, jump in without reading CONSTRAINTS.md
   - Cost: Write code that violates a constraint, spend an hour reworking
   - Fix: Discipline—always finish reading before opening the editor

2. **Skipping the I/O check**
   - Mistake: Rush to Step 1, assume no signals
   - Cost: Miss a critical blocker or user override
   - Fix: Step 0 first, always

3. **Not reading session_notes.md carefully**
   - Mistake: Glance at it, miss the "Next Session Starts With" section
   - Cost: Repeat last session's work or miss the intended priority
   - Fix: Search for "Next Session Starts With" explicitly; if it exists, propose it first

4. **Assuming the environment is healthy without checking**
   - Mistake: Skip Step 2.5, run integration tests, blame the code for failures
   - Cost: Hours debugging test failures that are actually infrastructure issues
   - Fix: Always check services if the project has them

5. **Proposing a plan without reading blockers**
   - Mistake: "Let's refactor auth" without noticing project_status says "Auth API not ready until Friday"
   - Cost: Plan invalidated mid-session, waste time
   - Fix: Read blockers first, plan around them

6. **Not waiting for user approval**
   - Mistake: Finish the report, start coding immediately
   - Cost: User was about to say "Actually, let's pivot to X instead"
   - Fix: Explicit wait. End with "Ready to start?" and listen


## Related Skills

- **`/arib-session-end`** — The counterpart to session-start. Writes memory files at end of session so the next session-start has full context
- **`/arib-io`** — Detailed I/O channel processor. Called from Step 0 if there are signals or requests to handle
- **`/arib-check-services`** — Deep infrastructure diagnostics. Called from Step 2.5; session-start does a quick version

---

**Last Updated**: 2026-04-19  
**Version**: 2.0 (comprehensive reference)  
**Maintainer**: Claude Code methodology
