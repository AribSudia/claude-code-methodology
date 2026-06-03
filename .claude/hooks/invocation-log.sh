#!/usr/bin/env bash
# .claude/hooks/invocation-log.sh
# v3.8.4 — best-effort skill/agent invocation telemetry.
#
# Appends one JSONL line per detected invocation to io/ledger/invocations.jsonl:
#   {"ts":"<iso>","type":"skill","name":"arib-check-security"}
#   {"ts":"<iso>","type":"agent","name":"security-auditor"}
#
# Wired to TWO events in .claude/settings.json:
#   - UserPromptSubmit  → detects /arib-* slash commands in the prompt (skills)
#   - PreToolUse(Task)  → detects subagent_type (agents)
#
# This is the foundation for: (a) the upgrade re-verification recommendations
# (UPGRADE_PROTOCOL Phase 1.6 — "which used skills changed?"), and (b) health
# KPIs 5/6 (agent coverage, per-skill usage) that were "not measurable" before.
#
# CONTRACT: non-blocking, NO stdout (UserPromptSubmit injects stdout into
# context — we must stay silent), always exit 0. Failures are swallowed.
# The log is gitignored (high-volume, per-project runtime state).

HOOK_NAME="invocation-log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh" 2>/dev/null || exit 0

LOG="${CCM_ROOT}/io/ledger/invocations.jsonl"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || exit 0
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Skills: any /arib-<name> tokens in the submitted prompt.
PROMPT="$(payload_get '.prompt' 2>/dev/null || true)"
if [[ -n "$PROMPT" ]]; then
  while IFS= read -r sk; do
    [[ -z "$sk" ]] && continue
    printf '{"ts":"%s","type":"skill","name":"%s"}\n' "$TS" "${sk#/}" >> "$LOG" 2>/dev/null || true
  done < <(printf '%s' "$PROMPT" | grep -oE '/arib-[a-z0-9-]+' 2>/dev/null | sort -u || true)
fi

# Agents: a Task dispatch carries the subagent_type.
TOOL="$(payload_get '.tool_name' 2>/dev/null || true)"
if [[ "$TOOL" == "Task" ]]; then
  AGENT="$(payload_get '.tool_input.subagent_type' 2>/dev/null || true)"
  [[ -n "$AGENT" ]] && printf '{"ts":"%s","type":"agent","name":"%s"}\n' "$TS" "$AGENT" >> "$LOG" 2>/dev/null || true
fi

# Silent success — never emit stdout (would be injected into context on
# UserPromptSubmit) and never block.
exit 0
