---
description: Session | Initialize session - read context, check I/O channel, report status, wait for approval
---

# /arib-session-start Command

## Purpose
Initialize a new Claude Code session with full context and awareness of the project state.

## Trigger
User types `/arib-session-start`

## Instructions

### Step 1: Read Core Documentation
Read the following files in order to establish foundational context:
1. `CLAUDE.md` - Core Claude Code guidelines
2. `CONSTRAINTS.md` - Project constraints and limitations
3. `TECH_STACK.md` - Technology stack and dependencies
4. `CONTEXT_MAP.md` - Project structure and file organization
5. `ERROR_PATTERNS.md` - Known error patterns and solutions

### Step 2: Read Memory Files
Load current session state from:
1. `project_status.md` - Current project status and progress
2. `session_notes.md` - Previous session notes and context

### Step 2.5: Microservices Health Check (if applicable)
If the project uses microservices (check CLAUDE.md or docker-compose.yml for multiple services):
```
bash scripts/services-check.sh
```
- If ALL HEALTHY → report "All N services running ✅" and continue
- If ANY DOWN → ask user: "N service(s) are down. Start all with `docker compose up -d`?"
  - If yes → run `bash scripts/services-check.sh --start`, re-check
  - If no → WARN in report: "⚠️ Partial infrastructure - integration tests unreliable"
- If ANY UNHEALTHY → show `docker compose logs --tail=20 [service]`, propose fix
- If no docker-compose.yml found → skip this step (monolith project)

### Step 3: Check Git Status
Execute in project root:
```
git status
git branch
git log --oneline -5
```

### Step 4: Report Findings
Present a structured report containing:
- **Current Branch**: The git branch currently checked out
- **Last 5 Commits**: Recent commit history
- **Current Task**: What was being worked on (from session_notes.md)
- **Blockers**: Any identified blockers or issues
- **Project Status**: High-level status summary

### Step 5: Propose Session Plan
Based on the loaded context, propose a clear session plan including:
- Priority items for this session
- Recommended next steps
- Any preparatory work needed

### Step 6: Wait for Approval
Pause and wait for user approval before proceeding with any actual work.

## Notes
- This command should be the first thing run at the start of any work session
- Always complete all 6 steps before asking for approval
- Do not make code changes during this command
- Focus on context gathering and reporting
