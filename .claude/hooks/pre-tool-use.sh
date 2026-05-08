#!/usr/bin/env bash
# .claude/hooks/pre-tool-use.sh
# Runs before every Write|Edit|MultiEdit|Bash tool call.
# Blocks: writes outside CONTEXT_MAP allowed paths, secrets in payloads,
# dangerous bash commands. Test fixtures are exempted from secret-pattern
# false positives via is_test_or_fixture_path.

HOOK_NAME="pre-tool-use"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

TOOL_NAME="$(payload_get '.tool_name')"
TOOL_INPUT="$(payload_get '.tool_input')"
TARGET_PATH="$(payload_get '.tool_input.file_path')"

# ---------- 1. Secret detection ----------
# Skip for test/fixture/example files (where mock secrets are legitimate).
SKIP_SECRET_SCAN=false
if [[ -n "$TARGET_PATH" ]] && is_test_or_fixture_path "$TARGET_PATH"; then
  SKIP_SECRET_SCAN=true
  log INFO "secret scan skipped for test/fixture path: $TARGET_PATH"
fi

if [[ "$SKIP_SECRET_SCAN" != "true" ]]; then
  SECRET_PATTERNS=(
    'sk-ant-[a-zA-Z0-9_-]{20,}'
    'sk-proj-[a-zA-Z0-9_-]{20,}'
    'ghp_[a-zA-Z0-9]{36}'
    'gho_[a-zA-Z0-9]{36}'
    'AKIA[0-9A-Z]{16}'
    'AIza[0-9A-Za-z_-]{35}'
    'xox[baprs]-[a-zA-Z0-9-]{10,}'
    '-----BEGIN (RSA|EC|OPENSSH|PGP|DSA) PRIVATE KEY-----'
  )

  for pattern in "${SECRET_PATTERNS[@]}"; do
    if printf '%s' "$TOOL_INPUT" | grep -Eq -- "$pattern"; then
      notify_cowork "secret-block" "Pattern matched in $TOOL_NAME"
      block "Detected potential secret in tool input. Move credentials to .env (gitignored) and reference via env var."
    fi
  done
fi

# ---------- 2. Write/Edit path scoping ----------
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "MultiEdit" ]]; then
  [[ -z "$TARGET_PATH" ]] && allow "no file_path in payload"

  # Hard-deny list — never write here, regardless of CONTEXT_MAP.
  HARD_DENY=(
    "${CCM_ROOT}/.git/"
    "${CCM_ROOT}/.env"
    "${CCM_ROOT}/.env.production"
    "${CCM_ROOT}/.env.local"
    "/etc/"
    "/usr/"
    "${HOME}/.ssh/"
    "${HOME}/.aws/"
  )
  for denied in "${HARD_DENY[@]}"; do
    if [[ "$TARGET_PATH" == "$denied"* ]]; then
      block "Write to protected path '$TARGET_PATH' is not permitted. Edit .env.example instead, or update CONTEXT_MAP to extend the hard-deny list."
    fi
  done

  # Soft-scope: if CONTEXT_MAP.md declares allowed_write_paths, enforce it.
  CONTEXT_MAP="${CCM_ROOT}/architecture/CONTEXT_MAP.md"
  if [[ -f "$CONTEXT_MAP" ]]; then
    ALLOWED_ROOTS="$(awk '/^<!-- allowed_write_paths:start -->/,/^<!-- allowed_write_paths:end -->/' "$CONTEXT_MAP" \
                     | grep -E '^- ' | sed 's/^- //')"
    if [[ -n "$ALLOWED_ROOTS" ]]; then
      if ! path_under "$TARGET_PATH" "$ALLOWED_ROOTS"; then
        block "Path '$TARGET_PATH' is outside CONTEXT_MAP allowed_write_paths. Update CONTEXT_MAP or write within allowed roots."
      fi
    fi
  fi
fi

# ---------- 3. Dangerous bash command detection ----------
if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD="$(payload_get '.tool_input.command')"

  # ---------- Wave-merge gate (Item #6) ----------
  # If the current branch is wave/<name> and the command is `git merge` /
  # `git push` to main, require an audit hash in io/ledger/.
  CURRENT_BRANCH="$(git -C "${CCM_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo)"
  if [[ "$CURRENT_BRANCH" =~ ^wave/(.+)$ ]]; then
    WAVE_NAME="${BASH_REMATCH[1]}"
    if printf '%s' "$CMD" | grep -Eq -- '\bgit (merge|push)\b.*\b(main|master|production)\b'; then
      LATEST_AUDIT="$(ls -1t "${CCM_ROOT}/io/ledger/audit-"*.md 2>/dev/null | head -1)"
      if [[ -z "$LATEST_AUDIT" ]] || ! grep -q -- "wave: ${WAVE_NAME}" "$LATEST_AUDIT" 2>/dev/null; then
        notify_cowork "wave-gate-block" "branch=${CURRENT_BRANCH} cmd=${CMD:0:80}"
        block "Wave-merge gate: no audit hash found for wave '${WAVE_NAME}' in io/ledger/. Run /arib-wave-end first."
      fi
    fi
  fi

  DANGEROUS_PATTERNS=(
    'rm -rf /( |$)'
    'rm -rf \*'
    'rm -rf ~'
    'rm -rf \$HOME'
    'mkfs\.'
    'dd if=.*of=/dev/'
    ':\(\)\{ *:\|: *& *\};:'
    'chmod -R 777 /'
    'curl [^|]*\| *(sh|bash)( |$)'
    'wget [^|]*\| *(sh|bash)( |$)'
    'git push.*--force.*\b(main|master|production)\b'
    'git reset --hard origin/(main|master|production)'
    'DROP DATABASE'
    'TRUNCATE.*production'
  )
  for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if printf '%s' "$CMD" | grep -Eiq -- "$pattern"; then
      notify_cowork "dangerous-bash-block" "Command: ${CMD:0:120}"
      block "Dangerous command pattern detected: matches '$pattern'. If intentional, run it manually outside Claude Code."
    fi
  done
fi

allow "checks passed for $TOOL_NAME"
