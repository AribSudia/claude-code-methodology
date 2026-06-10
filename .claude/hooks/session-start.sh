#!/usr/bin/env bash
# .claude/hooks/session-start.sh
# Runs on SessionStart. Verifies environment, hashes CLAUDE.md (drift detection),
# warns on protected branches, optionally pings CoWork.

HOOK_NAME="session-start"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# 1. CLAUDE.md drift detection.
if [[ ! -f "${CCM_ROOT}/CLAUDE.md" ]]; then
  log WARN "CLAUDE.md not found at repo root"
else
  if command -v sha256sum >/dev/null 2>&1; then
    CLAUDE_MD_HASH="$(sha256sum "${CCM_ROOT}/CLAUDE.md" | awk '{print $1}')"
  else
    CLAUDE_MD_HASH="$(shasum -a 256 "${CCM_ROOT}/CLAUDE.md" | awk '{print $1}')"
  fi
  log INFO "CLAUDE.md hash: ${CLAUDE_MD_HASH:0:12}"
fi

# 2. Git state.
BRANCH="unknown"
if git -C "${CCM_ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH="$(git -C "${CCM_ROOT}" rev-parse --abbrev-ref HEAD)"
  DIRTY="$(git -C "${CCM_ROOT}" status --porcelain | wc -l | tr -d ' ')"
  log INFO "branch=${BRANCH} dirty_files=${DIRTY}"
  if [[ "$BRANCH" == "main" || "$BRANCH" == "master" || "$BRANCH" == "production" ]]; then
    printf '\n[CCM] Session starting on protected branch "%s". Consider: git checkout -b feature/<name>\n\n' "$BRANCH" >&2
  fi
fi

# 3. Capture session start commit for accurate diffs in stop.sh.
mkdir -p "${CCM_ROOT}/io/ledger"
git -C "${CCM_ROOT}" rev-parse HEAD 2>/dev/null > "${CCM_ROOT}/io/.session-start-sha" || true

# 4. Notify CoWork (no-op unless CCM_COWORK_WEBHOOK is set).
notify_cowork "session-start" "branch=${BRANCH} root=${CCM_ROOT}"

# 5. Verify required tooling.
for tool in jq git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '[CCM] Required tool "%s" not found. Some hooks will fail.\n' "$tool" >&2
  fi
done

allow "session-start checks complete"
