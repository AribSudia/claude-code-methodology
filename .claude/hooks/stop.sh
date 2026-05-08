#!/usr/bin/env bash
# .claude/hooks/stop.sh
# Runs on Stop. Persists a session ledger entry to io/ledger/.
# Uses the start-of-session SHA captured by session-start.sh for accurate diffs
# (avoids the HEAD~N math which breaks on rebases / shallow branches / first commit).

HOOK_NAME="stop"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

LEDGER_DIR="${CCM_ROOT}/io/ledger"
mkdir -p "${LEDGER_DIR}"

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
LEDGER_FILE="${LEDGER_DIR}/session-${TS}.md"

BRANCH="$(git -C "${CCM_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
HEAD_SHA="$(git -C "${CCM_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"

START_SHA=""
START_SHA_FILE="${CCM_ROOT}/io/.session-start-sha"
if [[ -f "$START_SHA_FILE" ]]; then
  START_SHA="$(cat "$START_SHA_FILE" 2>/dev/null || echo "")"
fi

COMMITS_THIS_SESSION=0
FILES_CHANGED=0
COMMIT_LOG="(no start SHA recorded; cannot compute diff)"

if [[ -n "$START_SHA" ]] && git -C "${CCM_ROOT}" cat-file -e "${START_SHA}" 2>/dev/null; then
  if [[ "$START_SHA" != "$HEAD_SHA" ]]; then
    COMMITS_THIS_SESSION="$(git -C "${CCM_ROOT}" rev-list --count "${START_SHA}..HEAD" 2>/dev/null || echo 0)"
    FILES_CHANGED="$(git -C "${CCM_ROOT}" diff --name-only "${START_SHA}..HEAD" 2>/dev/null | wc -l | tr -d ' ')"
    COMMIT_LOG="$(git -C "${CCM_ROOT}" log --oneline "${START_SHA}..HEAD" 2>/dev/null || echo "")"
  else
    COMMIT_LOG="(no commits this session)"
  fi
fi

cat > "${LEDGER_FILE}" <<EOF
# Session Ledger Entry

- timestamp: ${TS}
- branch: ${BRANCH}
- start_sha: ${START_SHA:-unknown}
- end_sha: ${HEAD_SHA}
- commits_this_session: ${COMMITS_THIS_SESSION}
- files_changed: ${FILES_CHANGED}
- ccm_root: ${CCM_ROOT}

## Commits this session

\`\`\`
${COMMIT_LOG}
\`\`\`

## Hook log tail

\`\`\`
$(tail -20 "${CCM_LOG_FILE}" 2>/dev/null || echo "no hook log")
\`\`\`
EOF

# Clean up the start-SHA marker for next session.
rm -f "$START_SHA_FILE"

log INFO "ledger written: ${LEDGER_FILE}"
notify_cowork "session-end" "commits=${COMMITS_THIS_SESSION} files=${FILES_CHANGED}"

allow "stop hook complete"
