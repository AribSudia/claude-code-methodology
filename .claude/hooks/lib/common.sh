#!/usr/bin/env bash
# .claude/hooks/lib/common.sh
# Shared utilities for CCM hooks. Sourced by all hook scripts.
# Reads stdin JSON payload from Claude Code, exposes helpers.

set -euo pipefail

# ---------- Config ----------
CCM_ROOT="${CCM_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CCM_LOG_DIR="${CCM_ROOT}/io/hook-logs"
CCM_LOG_FILE="${CCM_LOG_DIR}/$(date +%Y-%m-%d).log"
mkdir -p "${CCM_LOG_DIR}"

# ---------- Logging ----------
log() {
  local level="$1"; shift
  local msg="$*"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '[%s] [%s] [%s] %s\n' "$ts" "$level" "${HOOK_NAME:-unknown}" "$msg" >> "${CCM_LOG_FILE}"
  if [[ "${level}" == "ERROR" || "${level}" == "BLOCK" ]]; then
    printf '[CCM/%s] %s\n' "${HOOK_NAME:-hook}" "$msg" >&2
  fi
}

# ---------- JSON payload helpers ----------
# Read stdin ONCE at source time. Command substitution runs in a subshell, so
# any caching scheme that mutates a variable from inside $() is silently lost.
# We just slurp stdin here and let payload_get query the captured string.
if [[ -t 0 ]]; then
  CCM_PAYLOAD="{}"
else
  CCM_PAYLOAD="$(cat || true)"
  [[ -z "$CCM_PAYLOAD" ]] && CCM_PAYLOAD="{}"
fi

payload_get() {
  local path="$1"
  if ! command -v jq >/dev/null 2>&1; then
    log ERROR "jq is required but not installed. Install with: brew install jq"
    return 1
  fi
  printf '%s' "$CCM_PAYLOAD" | jq -r "${path} // empty" 2>/dev/null || true
}

# ---------- Exit helpers ----------
allow() {
  log INFO "ALLOW: $*"
  exit 0
}

block() {
  log BLOCK "BLOCK: $*"
  printf 'CCM hook blocked this operation: %s\n' "$*" >&2
  # Exit 2 is the Claude Code contract for a BLOCKING PreToolUse hook:
  # exit 0 = allow, exit 2 = block (stderr fed back to Claude), any other
  # non-zero = NON-blocking error (shown to user, tool call proceeds).
  # This was exit 1 before v3.7.0 — which meant every gate was advisory.
  # Git also aborts a commit on any non-zero, so 2 is correct there too.
  exit 2
}

# ---------- Path helpers ----------
abs_path() {
  local p="$1"
  if [[ "$p" = /* ]]; then
    printf '%s' "$p"
  else
    printf '%s/%s' "$CCM_ROOT" "$p"
  fi
}

path_under() {
  local target="$1"; shift
  local roots="$1"
  local abs_target
  abs_target="$(abs_path "$target")"
  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    local abs_root
    abs_root="$(abs_path "$root")"
    if [[ "$abs_target" == "$abs_root"* ]]; then
      return 0
    fi
  done <<< "$roots"
  return 1
}

# Return 0 if the path is a test/fixture file (where secret-pattern false-positives
# are common — commit hashes, mock tokens, sample API keys in docs).
# Anchored to path SEGMENTS and conventional suffixes — a bare '*test*'
# substring would exempt real source like src/latest/ or src/contest/
# from the secret scan (v3.10.0 fix).
is_test_or_fixture_path() {
  local p="$1"
  case "$p" in
    test/*|tests/*|spec/*|specs/*|fixtures/*|examples/*|testdata/*) return 0 ;;
    */test/*|*/tests/*|*/spec/*|*/specs/*|*/fixtures/*|*/examples/*|*/testdata/*) return 0 ;;
    *__tests__*|*__fixtures__*|*__mocks__*|*__snapshots__*) return 0 ;;
    *.test.*|*.spec.*|*_test.*|*_spec.*|*.fixture.*|*.example|*.example.*) return 0 ;;
  esac
  return 1
}

# ---------- Notification fan-out (best-effort, non-blocking, opt-in) ----------
# Sends a structured event to whichever transports are configured. All optional;
# unset env vars => no-op for that transport. Each transport runs independently
# and never blocks or fails the calling hook.
#
#   CCM_COWORK_WEBHOOK    — CoWork (Item #4 preferred transport)
#   CCM_NOTIFY_WEBHOOK    — generic webhook (Slack/Discord/Telegram/etc.)
#
# Both can be set simultaneously; events fan out to each.
notify_cowork() {  # name kept for back-compat; routes to all configured transports
  local event="$1"
  local detail="$2"
  local payload
  payload="$(jq -nc \
      --arg e "$event" \
      --arg d "$detail" \
      --arg ts "$(date -u +%FT%TZ)" \
      --arg src "ccm-hook" \
      --arg hook "${HOOK_NAME:-unknown}" \
      '{event:$e, detail:$d, ts:$ts, source:$src, hook:$hook}' 2>/dev/null)" \
      || return 0

  local sent=0
  for var in CCM_COWORK_WEBHOOK CCM_NOTIFY_WEBHOOK; do
    local url="${!var:-}"
    [[ -z "$url" ]] && continue
    curl -fsS -m 3 -X POST "$url" \
      -H 'Content-Type: application/json' \
      -d "$payload" >/dev/null 2>&1 || true
    sent=$(( sent + 1 ))
  done

  # Optional ledger trace of notifications sent (best-effort).
  if (( sent > 0 )); then
    local notif_log="${CCM_ROOT}/io/ledger/.notifications.jsonl"
    mkdir -p "$(dirname "$notif_log")"
    printf '%s\n' "$payload" >> "$notif_log" 2>/dev/null || true
  fi
}

# Generic notification helper (clearer name; same behavior).
notify() { notify_cowork "$@"; }
