# Master Guide — Quick Reference

> **This is the quick-reference card for the entire methodology.**
> For full details, read the specific file referenced in each section.

---

## System Map at a Glance

```
CLAUDE.md (Master Brain)
    ├── architecture/    → WHAT to build (constraints, tech, patterns)
    ├── implementation/  → HOW to start (endpoints, docker, migrations)
    ├── memory/          → WHAT happened (status, notes, logs, decisions)
    ├── operations/      → HOW work flows (git, deploy, ops log)
    ├── .claude/agents/  → WHO does the work (15 specialist agents)
    ├── .claude/skills/  → KNOWLEDGE packs (27 auto-invoked skills)
    ├── .claude/hooks/   → SAFETY gates (pre/post action checks)
    ├── .claude/commands/ → SHORTCUTS (8 slash commands)
    ├── hooks/           → PROTOCOL docs for safety system
    ├── bootstrap/       → INSTANTIATION (25-question setup)
    ├── reference/       → READ-ONLY guides (this file, skills registry)
    └── scripts/         → AUTOMATION (git setup, validation, install)
```

---

## Session Lifecycle

```
/session-start → Read all context → Report status → Propose plan → Wait for approval
     │
     ▼
WORK → Announce → Check constraints → Snapshot → Implement (TDD) → Test → Log → Commit
     │
     ▼
/session-end → Update memory → Final tests → Commit → Push → Report
```

---

## The 6 Golden Rules

1. **If it's not written, Claude Code doesn't know it** — document everything
2. **Both layers required before coding** — Architecture + Implementation
3. **Memory at every boundary** — read at start, write during, commit at end
4. **Safety snapshot before modifying** — always recoverable
5. **Constraints are absolute** — no skill or agent overrides them
6. **One commit = one change** — atomic, traceable, reversible

---

## Agent Quick Reference

| Agent              | Trigger              | Output                    |
|--------------------|----------------------|---------------------------|
| ARCHITECT          | Design, plan, schema | Design → Trade-offs → Approval |
| SECURITY AUDITOR   | Auth, payments, data | Audit report (pass/fail)  |
| CODE REVIEWER      | Review, PR, merge    | APPROVED or NEEDS CHANGES |
| TEST ENGINEER      | Test, coverage, spec | Test files + coverage     |
| DEBUGGER           | Bug, broken, error   | 3 hypotheses → fix → doc  |
| REFACTOR           | Refactor, cleanup    | Snapshot → refactor → verify |
| ARABIC-RTL         | Arabic, RTL, عربي    | Compliance report + fixes |
| DEPLOY GUARDIAN    | Deploy, ship, release| CLEARED or BLOCKED        |

---

## Command Quick Reference

| Command          | Purpose                          |
|------------------|----------------------------------|
| `/session-start` | Initialize session with context  |
| `/session-end`   | Close session, save memory       |
| `/new-feature`   | Start feature with proper flow   |
| `/debug`         | Scientific debugging protocol    |
| `/review`        | Code review with quality gates   |
| `/deploy-check`  | Pre-deployment verification      |
| `/language-audit` | Universal language/locale compliance |
| `/document`      | Generate documentation           |

---

## Commit Types

`[feat]` `[fix]` `[refactor]` `[test]` `[docs]` `[chore]` `[snapshot]` `[security]`

---

## File Priority (Read Order)

1. CLAUDE.md
2. architecture/CONSTRAINTS.md
3. architecture/TECH_STACK.md
4. memory/project_status.md
5. memory/session_notes.md

---

## Instantiation Checklist

- [ ] Copy methodology to project root
- [ ] Add project spec to reference/
- [ ] Run Bootstrap Protocol (paste bootstrap/BOOTSTRAP.md)
- [ ] Answer 25 questions
- [ ] Replace templates with generated files
- [ ] Run scripts/git-setup.sh
- [ ] Open Claude Code → /session-start
- [ ] Build with confidence

---

> **End of Quick Reference**
