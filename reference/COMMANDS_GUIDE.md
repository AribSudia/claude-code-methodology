# Commands Guide — Complete Reference

> All 8 slash commands in the Claude Code Methodology.
> Type the command in Claude Code to invoke it.

---

## Quick Reference

| Command            | Syntax                                     | Purpose                              |
|--------------------|--------------------------------------------|--------------------------------------|
| `/session-start`   | `/session-start`                           | Initialize session with full context |
| `/session-end`     | `/session-end`                             | Close session, save memory, push     |
| `/new-feature`     | `/new-feature [feature-name]`              | Start feature with branch + TDD      |
| `/debug`           | `/debug [issue-description]`               | Scientific debugging (3 hypotheses)  |
| `/review`          | `/review [target]`                         | Code review with quality gates       |
| `/deploy-check`    | `/deploy-check`                            | Pre-deployment verification          |
| `/language-audit`  | `/language-audit [component] --locale [code]` | Language/i18n compliance check    |
| `/document`        | `/document [target]`                       | Generate documentation               |

---

## 1. /session-start

**Purpose:** Initialize every Claude Code session with full project context.

**Syntax:**
```
/session-start
```

**What It Does (Step by Step):**

1. **Check I/O Channel** — Runs `scripts/io-watcher.sh`
   - If SIGNALS exist → process immediately (halt, rollback, escalate, hotfix)
   - If REQUESTS pending → report to user, propose processing order
   - If clear → continue

2. **Read Core Files** (in order):
   - `CLAUDE.md` — the Master Brain
   - `architecture/CONSTRAINTS.md` — hard rules
   - `architecture/TECH_STACK.md` — approved libraries
   - `architecture/CONTEXT_MAP.md` — folder structure
   - `architecture/ERROR_PATTERNS.md` — known pitfalls

3. **Read Memory Files:**
   - `memory/project_status.md` — current state
   - `memory/session_notes.md` — last session's handoff

4. **Check Environment:**
   ```bash
   git status && git branch && git log --oneline -5
   ```

5. **Report to User:**
   - I/O status (pending requests, signals, pipelines)
   - Current branch and recent commits
   - Current task from project_status.md
   - Any blockers or warnings
   - Proposed plan for this session

6. **Wait** for user confirmation before writing any code.

**When to Use:** Every single time you open Claude Code. No exceptions.

**Expected Output:**
```
SESSION START — [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I/O Status: ✅ Clear (no pending signals or requests)
Branch: feature/user-auth (3 commits ahead of main)
Last Session: Implemented login endpoint, tests passing

Current Task: Add password reset flow
Blockers: None

Proposed Plan:
1. Create password reset token model
2. Build /forgot-password endpoint
3. Build /reset-password endpoint
4. Add email notification service
5. Write tests for all endpoints

Ready to proceed? (y/n)
```

---

## 2. /session-end

**Purpose:** Properly close a session — save memory, commit, push.

**Syntax:**
```
/session-end
```

**What It Does:**

1. **Update Memory Files:**
   - `memory/project_status.md` — update feature tracker, current phase
   - `memory/session_notes.md` — log what happened this session
   - `memory/change_log.md` — record all changes made
   - Other memory files as needed (bugs, architecture decisions, testing log)

2. **Run Final Tests:**
   ```bash
   npm test   # or dotnet test, pytest, etc.
   ```

3. **Create Session-End Commit:**
   ```bash
   git add -A
   git commit -m "[session-end]: [summary of what was accomplished]"
   ```

4. **Push to Remote:**
   ```bash
   git push
   ```

5. **Report:**
   ```
   ✅ Done: [what was completed]
   ⚠️ Issues: [any unresolved problems]
   🎯 Next: [what the next session should tackle]
   ```

**When to Use:** Every time you're done working. Ensures context is preserved.

---

## 3. /new-feature

**Purpose:** Start a new feature with proper branch, planning, and TDD workflow.

**Syntax:**
```
/new-feature [feature-name]
```

**Examples:**
```
/new-feature user-authentication
/new-feature payment-integration
/new-feature vehicle-search-filter
```

**What It Does:**

1. **Check Constraints** — Read `CONSTRAINTS.md` for relevant rules
2. **Create Feature Branch:**
   ```bash
   git checkout -b feature/[feature-name]
   ```
3. **Create Safety Snapshot:**
   ```bash
   git add . && git commit -m "[snapshot]: before feature/[feature-name]"
   ```
4. **Plan the Feature:**
   - Break into sub-tasks
   - Identify affected files
   - Check for architectural impacts
   - Propose implementation order
5. **Activate TDD Cycle:**
   - RED: Write failing tests first
   - GREEN: Implement minimum code to pass
   - REFACTOR: Clean up
6. **For Each Sub-Task:**
   - Announce what's being done
   - Implement with TDD
   - Commit: `[feat]: [what was done]`
   - Update change_log.md

---

## 4. /debug

**Purpose:** Scientific debugging protocol — no guessing, only evidence.

**Syntax:**
```
/debug [issue-description]
```

**Examples:**
```
/debug login returns 500 error after clicking submit
/debug search results not showing Arabic text correctly
/debug payment webhook failing intermittently
```

**What It Does:**

1. **Activate Debugger Agent** — enters scientific debugging mode
2. **Observe:** Reproduce the issue, collect exact error messages
3. **Hypothesize:** Form 3 ranked hypotheses:
   - H1: Most likely cause
   - H2: Second possibility
   - H3: Unlikely but possible
4. **Test:** Test each hypothesis one at a time
   - Design minimal reproduction
   - Confirm or eliminate
5. **Fix:** Apply targeted fix based on evidence
6. **Verify:**
   - Original issue resolved
   - Regression tests pass
   - Add test to prevent recurrence
7. **Document:**
   - Update `memory/bugs_and_fixes.md`
   - Commit: `[fix]: [description of what was fixed]`

---

## 5. /review

**Purpose:** Code review with quality gates — before merging any code.

**Syntax:**
```
/review [target]
```

**Examples:**
```
/review                        # review current branch changes
/review feature/user-auth      # review specific branch
/review src/services/payment   # review specific directory
```

**What It Does:**

1. **Activate Code Reviewer Agent**
2. **Diff Analysis:** Read all changes in scope
3. **Quality Gates Check:**
   - Functions ≤ 30 lines
   - Files ≤ 300 lines
   - No code duplication > 3 lines
   - Test coverage adequate
   - No hardcoded secrets
   - No console.log / print statements
   - Error handling present
4. **Security Scan:** Check for common vulnerabilities
5. **Performance Check:** Look for N+1 queries, unnecessary loops
6. **Produce Report:**
   ```
   APPROVED ✅ — Ready to merge
   ```
   or
   ```
   NEEDS CHANGES ❌
   1. [file:line] — [issue description]
   2. [file:line] — [issue description]
   ```

---

## 6. /deploy-check

**Purpose:** Pre-deployment verification — the last gate before production.

**Syntax:**
```
/deploy-check
```

**What It Does:**

1. **Activate Deploy Guardian Agent**
2. **7-Phase Checklist:**

   **Phase 1 — Code Quality:**
   - All tests passing
   - No lint errors
   - No TypeScript errors

   **Phase 2 — Security:**
   - No exposed secrets
   - Dependencies audited
   - OWASP checklist reviewed

   **Phase 3 — Database:**
   - Migrations tested
   - Rollback plan exists
   - No destructive migrations without approval

   **Phase 4 — Environment:**
   - Environment variables documented
   - Config matches production requirements
   - Feature flags set correctly

   **Phase 5 — Performance:**
   - No obvious performance regressions
   - Bundle size acceptable
   - Database queries optimized

   **Phase 6 — Documentation:**
   - CHANGELOG updated
   - API docs current
   - Breaking changes documented

   **Phase 7 — Rollback:**
   - Rollback procedure documented
   - Previous version tagged
   - Monitoring alerts configured

3. **Produce Verdict:**
   ```
   CLEARED ✅ — Safe to deploy
   ```
   or
   ```
   BLOCKED ❌
   Reason: [what must be fixed before deployment]
   ```

---

## 7. /language-audit

**Purpose:** Universal language and locale compliance check for any writing system.

**Syntax:**
```
/language-audit [component] --locale [locale-code]
```

**Examples:**
```
/language-audit header --locale ar-SA          # Arabic (Saudi)
/language-audit checkout --locale zh-CN        # Chinese (Simplified)
/language-audit user-profile --locale ja       # Japanese
/language-audit all --locale he                # Hebrew
/language-audit dashboard --locale hi          # Hindi
/language-audit all                            # audit all configured locales
```

**Supported Locales:** ar-SA, ar-EG, he, fa, ur, zh-CN, zh-TW, ja, ko, hi, bn, ta, th, ru, en, fr, de, es, pt-BR, tr (and more)

**What It Does:**

1. **Activate Language Specialist Agent**
2. **10-Step Audit:**
   - Hardcoded strings scan (all must use i18n keys)
   - Content direction (`dir` attribute correct for locale)
   - CSS logical properties (no physical `margin-left/right`)
   - Font & typography (correct font for target script)
   - Number/Date/Currency formatting (using `Intl` APIs)
   - Input & text processing (IME support, grapheme-aware)
   - UI layout & mirroring (icons, scrollbars, navigation)
   - Accessibility (`lang` attribute, screen reader, keyboard nav)
3. **Produce Report:** COMPLIANT or NON-COMPLIANT with prioritized fix list

---

## 8. /document

**Purpose:** Generate documentation for any target in the codebase.

**Syntax:**
```
/document [target]
```

**Examples:**
```
/document src/services/payment     # document the payment service
/document api                      # document all API endpoints
/document architecture             # document system architecture
/document setup                    # document project setup guide
```

**What It Does:**

1. **Analyze Target:** Read all files in the target scope
2. **Extract:**
   - Public interfaces and their signatures
   - Dependencies and relationships
   - Business logic flow
   - Configuration requirements
3. **Generate Documentation:**
   - Overview and purpose
   - API reference (if applicable)
   - Data flow diagrams (if applicable)
   - Usage examples
   - Configuration guide
4. **Save:** Write documentation to appropriate location
5. **Commit:** `[docs]: document [target]`

---

## Command Lifecycle in a Typical Session

```
/session-start          ← Start here (ALWAYS)
    │
    ├── /new-feature user-auth
    │   ├── (implement with TDD)
    │   ├── /review
    │   └── (merge if approved)
    │
    ├── /debug login-500-error
    │   └── (fix, test, document)
    │
    ├── /language-audit all --locale ar-SA
    │   └── (fix compliance issues)
    │
    ├── /deploy-check
    │   └── (CLEARED? → deploy)
    │
/session-end            ← End here (ALWAYS)
```

---

## Creating Custom Commands

Add a `.md` file to `.claude/commands/`:

```markdown
# /my-command Command

## Purpose
[What this command does]

## Trigger
User types `/my-command [args]`

## Instructions

### Step 1: [First action]
[Detailed instructions...]

### Step 2: [Second action]
[Detailed instructions...]

### Step 3: Generate Report
[Output format...]
```

The filename becomes the command name: `my-command.md` → `/my-command`
