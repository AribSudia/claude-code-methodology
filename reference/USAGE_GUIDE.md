# Usage Guide — How to Use Agents, Skills, Hooks & Commands

> This guide explains how each layer of the Claude Code Methodology is
> invoked, activated, and used in practice. Each layer has a different
> activation mechanism — understanding this is key to using the system effectively.

---

## Quick Reference

| Layer        | How It Activates              | You Invoke It?    | Example                                    |
|--------------|-------------------------------|-------------------|--------------------------------------------|
| **Commands** | You type `/command-name`      | Yes, manually     | `/session-start`                           |
| **Agents**   | Auto-activate on keywords OR you call explicitly | Both | Say "design this" or run `--agent`  |
| **Skills**   | Auto-activate on task match   | No, automatic     | Claude detects TDD task → reads TDD skill  |
| **Hooks**    | Auto-fire on events           | No, automatic     | Pre-commit hook blocks bad commits         |

---

## 1. Slash Commands — You Type Them

Commands are the **only thing you invoke directly** with a `/` prefix.

### Available Commands

| Command            | What It Does                                     | When to Use                          |
|--------------------|--------------------------------------------------|--------------------------------------|
| `/session-start`   | Initialize session — reads context, checks I/O   | **Every time** you open Claude Code  |
| `/session-end`     | Close session — update memory, commit, push      | **Every time** you finish working    |
| `/new-feature`     | Start a feature with branch + TDD workflow       | Starting a new feature               |
| `/debug`           | Scientific debugging protocol (3 hypotheses)     | Something is broken                  |
| `/review`          | Code review with quality gates                   | Before merging code                  |
| `/deploy-check`    | Pre-deployment verification pipeline             | Before shipping to production        |
| `/language-audit`  | Universal language/locale compliance check        | Before releasing for a new market    |
| `/document`        | Generate documentation for a target              | When docs are needed                 |

### How to Use

Just type the command in Claude Code:

```
/session-start
```

```
/new-feature user-authentication
```

```
/debug the login page returns 500 after clicking submit
```

```
/language-audit checkout --locale ar-SA
```

```
/deploy-check
```

### Where They Live

Commands are defined in `.claude/commands/*.md`. Each file contains:
- Purpose and trigger syntax
- Step-by-step instructions Claude Code follows
- Expected output format

You can create custom commands by adding new `.md` files to `.claude/commands/`.

---

## 2. Agents — They Activate Themselves (or You Call Them)

Agents are **specialist modes** that Claude Code enters when specific tasks
are detected. Each agent has its own expertise, checklist, and constraints.

### Auto-Activation (Most Common)

Just describe what you need — Claude Code detects the right agent automatically:

| You Say...                                     | Agent That Activates         |
|------------------------------------------------|------------------------------|
| "Design the database schema for..."            | **Architect**                |
| "This login page is broken, it returns 500..." | **Debugger**                 |
| "Review this pull request before we merge"     | **Code Reviewer**            |
| "Write tests for the payment service"          | **Test Engineer**            |
| "Clean up this file, it's too messy"           | **Refactor Specialist**      |
| "Check if this endpoint is secure"             | **Security Auditor**         |
| "We need to deploy this to production"         | **Deploy Guardian**          |
| "Add Arabic support to the dashboard"          | **Language Specialist**      |
| "Make this work in Japanese"                   | **Language Specialist**      |
| "Check the RTL layout"                         | **Language Specialist**      |

You don't need to say the agent's name. Claude Code reads the trigger patterns
from each agent file and activates the right one.

### Explicit Invocation (Advanced)

You can also call an agent directly from your terminal as a subagent:

```bash
# Run a specific agent on a specific task
claude --agent .claude/agents/security-auditor.md "audit the auth module for OWASP top 10"

# Run the language specialist
claude --agent .claude/agents/language.md "verify Arabic support in the checkout flow"

# Run the architect
claude --agent .claude/agents/architect.md "design the notification microservice"
```

This is useful when you want a focused, isolated analysis without mixing
it into your current session context.

### What Each Agent Does

**Architect** (`.claude/agents/architect.md`)
- System design, schema planning, trade-off analysis
- Produces: Design document with alternatives, recommendation, approval gate
- Constraints: Never writes implementation code, only designs

**Security Auditor** (`.claude/agents/security-auditor.md`)
- OWASP Top 10:2025 compliance, ASVS 5.0, full vulnerability scanning
- Produces: Audit report with severity levels (CRITICAL/HIGH/MEDIUM/LOW)
- Constraints: Never approves code with known vulnerabilities

**Code Reviewer** (`.claude/agents/code-reviewer.md`)
- Quality gates: function length, file length, duplication, test coverage
- Produces: APPROVED or NEEDS CHANGES with specific line-level feedback
- Constraints: Blocks merge if quality gates fail

**Test Engineer** (`.claude/agents/test-engineer.md`)
- TDD enforcement, RED-GREEN-REFACTOR cycle, coverage targets
- Produces: Test files, coverage reports, regression test suites
- Constraints: Tests must pass before any PR is approved

**Debugger** (`.claude/agents/debugger.md`)
- Scientific debugging: observe → hypothesize (3) → test → fix → verify
- Produces: Root cause analysis, fix, regression test, documentation
- Constraints: Never guesses — always proves with evidence

**Refactor Specialist** (`.claude/agents/refactor-specialist.md`)
- Safe code improvement — behavior must be preserved
- Produces: Cleaner code with before/after tests proving equivalence
- Constraints: Separate commits for refactoring, never mixed with features

**Language Specialist** (`.claude/agents/language.md`)
- Universal i18n/l10n: RTL, LTR, CJK, Indic, Bidi, mixed-script
- Produces: Language compliance report, font/locale/direction fixes
- Constraints: Zero hardcoded strings, CSS logical properties only, Intl APIs

**Deploy Guardian** (`.claude/agents/deploy-guardian.md`)
- Pre-deployment verification: 7-phase checklist
- Produces: CLEARED (safe to deploy) or BLOCKED (with reasons)
- Constraints: Never approves deployment with failing tests or missing migrations

### Where They Live

Agent definitions are in `.claude/agents/*.md`. Each file contains:
- Identity (who the agent is)
- Activation Rules (when to auto-activate)
- Mandatory Checklist (steps the agent always follows)
- Output Format (what the agent produces)
- Constraints (what the agent must never do)

---

## 3. Skills — Fully Automatic

Skills are **knowledge packs** that Claude Code reads when it detects a
matching task. You never invoke them — they activate silently in the background.

### How They Work

1. You give Claude Code a task
2. Claude Code checks the `description` field of each installed skill
3. If a skill matches, Claude Code reads its `SKILL.md` file
4. Claude Code uses that knowledge to do a better job

### Example Flow

```
You: "Set up the frontend project with React and Tailwind"

Claude Code internally:
  → Detects "React" and "frontend" keywords
  → Finds skill: .claude/skills/frontend/SKILL.md
  → Reads the skill's best practices
  → Uses that knowledge while building
```

You never see the skill activation — it just makes Claude Code smarter.

### Installing Skills

Skills live in `.claude/skills/[skill-name]/SKILL.md`. The methodology
includes a Skills Registry (`reference/SKILLS_REGISTRY.md`) with 21 pre-cataloged
skills across two categories:

**Category A — Coding Skills (15):**
Frontend, Debugging, Security, TDD, Git Worktrees, Performance, Database,
API Design, Docker, CI/CD, Code Review, Refactoring, Documentation,
Error Handling, Logging

**Category B — Design & Automation Skills (6):**
Algorithmic Art, Presentation Design, Spreadsheet Automation, PDF Processing,
Word Document Generation, Canvas Design

### How to Install a Skill

```bash
# Create the skill directory
mkdir -p .claude/skills/my-skill

# Create the skill file with instructions
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
# My Custom Skill

## description
Activates when the task involves [your trigger words here].

## Instructions
[Knowledge and best practices Claude Code should follow]
EOF
```

### Where They Live

```
.claude/skills/
├── frontend/
│   └── SKILL.md          ← Instructions for frontend tasks
├── debugging/
│   └── SKILL.md          ← Debugging best practices
├── security/
│   └── SKILL.md          ← Security patterns
└── [your-custom-skill]/
    ├── SKILL.md           ← Required: instructions
    ├── helpers.py         ← Optional: utility scripts
    └── templates/         ← Optional: starter files
```

---

## 4. Hooks — Event-Driven Safety Gates

Hooks are **automatic guards** that fire on specific events. They prevent
dangerous operations before they happen.

### How They Work

Hooks are configured in `.claude/settings.json` and fire automatically:

```
Event occurs → Hook fires → Hook checks → ALLOW or BLOCK
```

You never call hooks. They protect you silently.

### Hook Types

| Hook Type          | When It Fires                        | Example Use                           |
|--------------------|--------------------------------------|---------------------------------------|
| `PreToolUse`       | Before Claude runs a tool            | Block `rm -rf /`, prevent force push  |
| `PostToolUse`      | After a tool completes               | Auto-lint after file edit             |
| `PreCommit`        | Before a git commit                  | Verify tests pass, check for secrets  |
| `SessionStart`     | When a session begins                | Check I/O channel, read memory        |
| `SessionSummarize` | When summarizing session context     | Ensure memory files are included      |
| `Notification`     | When Claude wants to notify user     | Custom alert formatting               |

### Example Configuration

In `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash hooks/pre-tool-check.sh \"$TOOL_INPUT\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix \"$FILE_PATH\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### Production Recipes (7 Built-In)

The methodology includes 7 ready-to-use hook recipes in `hooks/HOOKS_PROTOCOL.md`:

1. **Dangerous Command Blocker** — blocks `rm -rf`, `DROP TABLE`, `force push`
2. **Auto-Linter** — runs linter after every file edit
3. **Secret Scanner** — prevents committing API keys, passwords, tokens
4. **Test Runner** — runs tests before every commit
5. **Migration Validator** — checks migration safety before running
6. **Bundle Size Monitor** — alerts if bundle size increases significantly
7. **Dependency Auditor** — checks for vulnerable dependencies

### Where They Live

- Configuration: `.claude/settings.json` (hooks section)
- Documentation: `hooks/HOOKS_PROTOCOL.md`
- Script files: `.claude/hooks/*.sh` (optional, for complex logic)

---

## 5. The I/O Channel — Inter-Agent Communication

The I/O Channel is how **Claude Cowork** (the critical eye) communicates with
**Claude Code** (the executing hand). It's not something you "invoke" — it's
a shared file system both agents read and write to.

### How to Use It

**From Claude Cowork (requesting work):**
1. Create a request file in `io/requests/` using a template from `io/.templates/`
2. Claude Code picks it up at next `/session-start`

**From Claude Code (delivering results):**
1. Read the request from `io/requests/`
2. Do the work
3. Write a result to `io/results/`
4. Update `io/status.md` dashboard

**Emergency signals (anyone):**
1. Create a signal file in `io/signals/` (halt, rollback, escalate, hotfix)
2. Claude Code processes signals BEFORE anything else

### Request Types

| Type      | Template                  | Use When                             |
|-----------|---------------------------|--------------------------------------|
| `audit`   | `io/.templates/audit.md`  | You want a deep code inspection      |
| `verify`  | `io/.templates/verify.md` | You want to confirm something works  |
| `review`  | `io/.templates/review.md` | You want a code review               |
| `analyze` | `io/.templates/analyze.md`| You want performance/data analysis   |
| `compare` | `io/.templates/compare.md`| You want to compare two approaches   |
| `fix`     | `io/.templates/fix.md`    | You want a specific bug fixed        |

---

## 6. Putting It All Together — A Typical Session

Here's how all the layers work together in a real development session:

```
1. You open Claude Code
   └── Type: /session-start                    ← COMMAND
       ├── SessionStart hook fires             ← HOOK (automatic)
       ├── I/O watcher checks for signals      ← I/O CHANNEL (automatic)
       ├── Claude reads CLAUDE.md + memory     ← L1 (automatic)
       └── Claude reports status, waits

2. You say: "Add Arabic support to the checkout page"
   └── Language Specialist agent activates     ← AGENT (auto-detected)
       ├── Reads .claude/agents/language.md
       ├── Frontend skill activates            ← SKILL (auto-detected)
       │   └── Reads .claude/skills/frontend/SKILL.md
       ├── Follows 8-section checklist
       ├── PreToolUse hook checks commands     ← HOOK (automatic)
       ├── PostToolUse hook auto-lints         ← HOOK (automatic)
       └── Produces compliance report

3. You say: "Review the changes before I commit"
   └── Code Reviewer agent activates           ← AGENT (auto-detected)
       ├── Runs quality gates
       └── Produces APPROVED or NEEDS CHANGES

4. You say: "Ship it"
   └── Deploy Guardian agent activates         ← AGENT (auto-detected)
       ├── Runs 7-phase checklist
       ├── PreCommit hook checks               ← HOOK (automatic)
       └── Produces CLEARED or BLOCKED

5. You type: /session-end                      ← COMMAND
   └── Memory files updated
       └── Committed and pushed
```

---

## 7. Common Questions

**Q: Do I need to memorize trigger words for agents?**
No. Just describe what you need naturally. Claude Code reads the activation
rules from each agent file and picks the right one. If you say "this is broken,"
the Debugger activates. If you say "is this secure?", the Security Auditor activates.

**Q: Can I use multiple agents in one session?**
Yes. Agents activate and deactivate as needed. You might start with Architect
to design something, then Test Engineer writes tests, then Debugger fixes an issue.

**Q: What if no agent matches my task?**
Claude Code works normally without an agent — agents are specialist modes
that enhance behavior, not requirements for operation.

**Q: Can I create my own agents?**
Yes. Add a `.md` file to `.claude/agents/` following the format:
Identity → Activation Rules → Checklist → Output Format → Constraints.

**Q: Can I create my own commands?**
Yes. Add a `.md` file to `.claude/commands/` with a clear trigger format
and step-by-step instructions.

**Q: How do I know which skills are installed?**
Check `.claude/skills/` for installed skills, and `reference/SKILLS_REGISTRY.md`
for the full catalog of available skills.

**Q: Can hooks block my work?**
Yes — that's the point. If a PreCommit hook detects a secret in your code,
it blocks the commit. Fix the issue, then commit again.

**Q: What's the difference between an agent and a command?**
A command is an explicit action you trigger with `/`. An agent is a specialist
mode that Claude enters to handle a category of work. Commands can trigger
agents (e.g., `/language-audit` activates the Language Specialist agent).
