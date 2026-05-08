# AUTONOMY_MODE.md — Long autonomous Claude Code runs

> **Scope:** sessions started with `claude --dangerously-skip-permissions`
> (or equivalent), typically wrapped in `caffeinate` for hours-long
> wave execution without human-in-the-loop on every tool call.
>
> **Premise:** the framework otherwise assumes a human approves every
> destructive action. Autonomy mode trades that for tighter machine-
> enforced guardrails — fewer prompts, more checks.
>
> **Status:** opt-in. Default CCM behavior is full human-in-loop.

---

## 1. When to use

- Multi-hour wave execution where you'd be approving the same patterns
  hundreds of times.
- Overnight refactors with a well-scoped plan and a dry run already passed.
- Audits in IMPLEMENT-FROM-FILE mode where the fix patterns are known.

## 2. When NOT to use

- First time running a workflow — observe at full friction first.
- Production hotfixes — autonomy traded for speed is wrong here.
- Anything touching customer data, billing, or auth that hasn't been
  rehearsed in staging first.
- After-hours when no human can intervene if guardrails fail.

## 3. Preconditions (ALL required to enter autonomy)

- [ ] **Hooks healthy.** `./scripts/install-hooks.sh` ran clean within the
      last 24 hours.
- [ ] **Working tree clean.** `git status` shows nothing.
- [ ] **Snapshot tag created.** `git tag autonomy/start-<timestamp>` written
      so a hard reset is one command away.
- [ ] **Wave plan exists** (if running a wave). `waves/<name>/PLAN.md`
      populated and reviewed.
- [ ] **Dry run passed** for non-trivial workflows. The exact prompt /
      skill chain succeeded under human-in-the-loop in the last 7 days.
- [ ] **Notification transport configured.** `CCM_COWORK_WEBHOOK` or
      `CCM_NOTIFY_WEBHOOK` set; test ping went through.
- [ ] **Wall-clock cap chosen.** Default 4h. Override via
      `CCM_AUTONOMY_MAX_SECONDS=14400`.

If any are missing, autonomy refuses to start.

## 4. Guardrails (active during autonomy)

The `autonomy-guard.sh` hook (PreToolUse) enforces these:

| Guardrail | Action on trip |
|-----------|----------------|
| Test suite failure | Stop session immediately. Notify. |
| > N hook BLOCKs in a 10-minute window | Stop. Notify. (Default N=5.) |
| > N total tool calls without a commit | Stop. Notify. (Default N=50.) |
| Wall-clock cap exceeded | Stop. Notify. |
| Push to `main` from any branch except `wave/*/end-*` tag | Block (always). |
| Hourly status: tokens spent, current task | Notify (informational). |

The guardrails are configurable via environment variables read by the hook.
Defaults are conservative — start there, loosen only after a clean run.

## 5. Post-conditions (exit autonomy)

When the session ends or is stopped:

- [ ] **Wave-end self-audit must pass** before any commit lands on `main`.
      If autonomy stopped mid-wave, no merge — fix and re-audit.
- [ ] **Autonomy report written** to `operations/OPERATIONS_LOG.md` with:
      - Start/end timestamps
      - Branches touched
      - Commits made
      - Guardrails tripped (if any) and what stopped the run
      - Tokens consumed (estimated)
      - Files changed
- [ ] **Snapshot tag retained** for at least 7 days. Don't delete the
      `autonomy/start-*` tag until you've reviewed the diff.

## 6. The autonomy report (template)

```markdown
## Autonomy Run — <YYYY-MM-DD HH:MM-HH:MM UTC>

- **Wave:** <name | n/a>
- **Branch:** <branch>
- **Snapshot:** autonomy/start-<ts>
- **Wall-clock:** <duration>
- **Tool calls:** <count>
- **Commits:** <count>
- **Guardrails tripped:** <list | none>
- **Stopped by:** <user | guardrail:<which> | natural completion>

### What was done
- <bullet>

### What was NOT done (planned but skipped)
- <bullet>

### Follow-ups for next session
- <bullet>
```

## 7. Recovery

If autonomy went sideways:

```bash
# Inspect the diff vs. snapshot
git diff autonomy/start-<ts>..HEAD

# Reset to snapshot (DESTRUCTIVE — confirm first)
git reset --hard autonomy/start-<ts>

# Or cherry-pick the parts that worked
git cherry-pick <good-sha>
```

The snapshot tag is the safety net. Use it.

## 8. Why this is opt-in

Skipping permissions is a sharp tool. Anthropic ships it; we use it; it
doesn't make sense to ship it as the default. Defaults should optimize for
"safe to install, opt in for power" — not the reverse.

The same logic applies to ML-classifier auto-approval at higher rates: it
works in production once you've run thousands of sessions, and is reckless
on session three. Autonomy mode is the same. Earn it before relying on it.

## 9. Related

- `.claude/hooks/autonomy-guard.sh` — runtime enforcement.
- `arib-wave-end` — required before merging to main from a wave/*.
- `arib-deep-audit` — the post-condition gate.
- `operations/OPERATIONS_LOG.md` — append-only run history.
