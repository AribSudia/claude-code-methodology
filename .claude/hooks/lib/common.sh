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
  exit 1
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
is_test_or_fixture_path() {
  local p="$1"
  case "$p" in
    *test*|*spec*|*__fixtures__*|*__mocks__*|*tests/*|*fixtures/*|*examples/*|*.example|*.example.*)
      return 0
      ;;
  esac
  return 1
}

# ---------- CoWork notification (best-effort, non-blocking, opt-in) ----------
# Set CCM_COWORK_WEBHOOK to enable. Empty/unset => no-op.
notify_cowork() {
  local event="$1"
  local detail="$2"
  local webhook="${CCM_COWORK_WEBHOOK:-}"
  [[ -z "$webhook" ]] && return 0
  curl -fsS -m 3 -X POST "$webhook" \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg e "$event" --arg d "$detail" --arg ts "$(date -u +%FT%TZ)" \
        '{event:$e, detail:$d, ts:$ts, source:"ccm-hook"}')" \
    >/dev/null 2>&1 || true
}
