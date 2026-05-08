#!/usr/bin/env bash
# .claude/hooks/autonomy-guard.sh
# Item #10 — runtime guardrails for autonomous Claude Code sessions.
#
# Activated by setting CCM_AUTONOMY=1 in the session environment. Only then
# does this hook enforce. With CCM_AUTONOMY unset, this is a fast-path no-op
# so it can sit in settings.json permanently without affecting normal sessions.
#
# Guardrails (defaults — override via env):
#   CCM_AUTONOMY_MAX_SECONDS      4 hours wall-clock cap
#   CCM_AUTONOMY_MAX_BLOCKS_10MIN max BLOCK exits in 10 min before stop (5)
#   CCM_AUTONOMY_MAX_CALLS_NOCOMMIT max tool calls between commits (50)

HOOK_NAME="autonomy-guard"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# 0. No-op if autonomy not active.
if [[ "${CCM_AUTONOMY:-0}" != "1" ]]; then
  allow "autonomy not active"
fi

STATE_DIR="${CCM_ROOT}/io/.autonomy"
mkdir -p "$STATE_DIR"

START_FILE="$STATE_DIR/start"
CALLS_FILE="$STATE_DIR/calls-since-commit"
BLOCKS_FILE="$STATE_DIR/blocks-log"

# 1. First call: record start time.
if [[ ! -f "$START_FILE" ]]; then
  date +%s > "$START_FILE"
  printf '0\n' > "$CALLS_FILE"
  : > "$BLOCKS_FILE"
  notify_cowork "autonomy-start" "session=$(date -u +%FT%TZ) cap=${CCM_AUTONOMY_MAX_SECONDS:-14400}s"
fi

# 2. Wall-clock cap.
NOW=$(date +%s)
START=$(cat "$START_FILE" 2>/dev/null || echo "$NOW")
ELAPSED=$(( NOW - START ))
MAX="${CCM_AUTONOMY_MAX_SECONDS:-14400}"
if (( ELAPSED > MAX )); then
  notify_cowork "autonomy-stop" "reason=wall_clock elapsed=${ELAPSED}s cap=${MAX}s"
  block "Autonomy wall-clock cap exceeded (${ELAPSED}s > ${MAX}s). Stopping. Review the diff vs. autonomy/start-* tag before continuing."
fi

# 3. Tool calls without commit.
CALLS=$(cat "$CALLS_FILE" 2>/dev/null || echo 0)
TOOL_NAME="$(payload_get '.tool_name')"
CMD="$(payload_get '.tool_input.command')"

# Reset counter on a successful git commit.
if [[ "$TOOL_NAME" == "Bash" ]] && printf '%s' "$CMD" | grep -Eq -- '^\s*git\s+commit\b'; then
  printf '0\n' > "$CALLS_FILE"
else
  CALLS=$(( CALLS + 1 ))
  printf '%d\n' "$CALLS" > "$CALLS_FILE"
fi

MAX_CALLS="${CCM_AUTONOMY_MAX_CALLS_NOCOMMIT:-50}"
if (( CALLS > MAX_CALLS )); then
  notify_cowork "autonomy-stop" "reason=no_commit calls=${CALLS} cap=${MAX_CALLS}"
  block "Autonomy: ${CALLS} tool calls since the last commit (cap=${MAX_CALLS}). Stopping. Either commit progress or split the workflow."
fi

# 4. BLOCK rate limit (looks at recent block events from the daily hook log).
TEN_MIN_AGO=$(( NOW - 600 ))
RECENT_BLOCKS=0
if [[ -f "$CCM_LOG_FILE" ]]; then
  while IFS= read -r line; do
    # log line: [2026-05-08T...] [BLOCK] [pre-tool-use] BLOCK: ...
    line_ts="$(printf '%s' "$line" | awk -F'[][]' '{print $2}')"
    [[ -z "$line_ts" ]] && continue
    line_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$line_ts" +%s 2>/dev/null || \
                 date -d "$line_ts" +%s 2>/dev/null || echo 0)
    [[ "$line_epoch" -ge "$TEN_MIN_AGO" ]] && RECENT_BLOCKS=$(( RECENT_BLOCKS + 1 ))
  done < <(grep '\[BLOCK\]' "$CCM_LOG_FILE" 2>/dev/null | tail -50)
fi

MAX_BLOCKS="${CCM_AUTONOMY_MAX_BLOCKS_10MIN:-5}"
if (( RECENT_BLOCKS > MAX_BLOCKS )); then
  notify_cowork "autonomy-stop" "reason=block_rate blocks_10min=${RECENT_BLOCKS} cap=${MAX_BLOCKS}"
  block "Autonomy: ${RECENT_BLOCKS} hook BLOCKs in 10 minutes (cap=${MAX_BLOCKS}). Stopping. Investigate why the model keeps hitting guardrails."
fi

# 5. Hard rule: from any branch, refuse a push to main unless the current
# commit is tagged as a wave-end (wave/*/end-*).
if [[ "$TOOL_NAME" == "Bash" ]] && printf '%s' "$CMD" | grep -Eq -- '\bgit push\b.*\b(main|master|production)\b'; then
  HEAD_SHA="$(git -C "${CCM_ROOT}" rev-parse HEAD 2>/dev/null || echo)"
  if [[ -n "$HEAD_SHA" ]]; then
    if ! git -C "${CCM_ROOT}" tag --points-at "$HEAD_SHA" 2>/dev/null | grep -Eq '^wave/.+/end-'; then
      notify_cowork "autonomy-stop" "reason=unsanctioned_push_to_main"
      block "Autonomy: refusing push to main without a wave/*/end-* tag on HEAD. Run /arib-wave-end to produce one."
    fi
  fi
fi

# 6. Hourly informational ping.
LAST_PING_FILE="$STATE_DIR/last-ping"
LAST_PING=$(cat "$LAST_PING_FILE" 2>/dev/null || echo 0)
if (( NOW - LAST_PING > 3600 )); then
  date +%s > "$LAST_PING_FILE"
  notify_cowork "autonomy-status" "elapsed=${ELAPSED}s calls_since_commit=${CALLS} recent_blocks=${RECENT_BLOCKS}"
fi

allow "autonomy-guard pass"
