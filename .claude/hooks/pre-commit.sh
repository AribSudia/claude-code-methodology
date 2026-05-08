#!/usr/bin/env bash
# .claude/hooks/pre-commit.sh
# Pre-commit guard. Blocks commits with secrets, .env files, debug statements,
# oversized files. Test/fixture paths are exempted from secret-pattern checks.
# Runs as a real git pre-commit hook (installed via scripts/install-hooks.sh)
# and as a Claude PreToolUse hook when `git commit` is detected.

HOOK_NAME="pre-commit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

STAGED="$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)"
[[ -z "$STAGED" ]] && allow "no staged files"

FAILURES=()

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue

  # 1. Block credential files
  case "$file" in
    .env|.env.local|.env.production|*.pem|*.key|id_rsa|id_ed25519)
      FAILURES+=("Refusing to commit credential file: $file")
      continue
      ;;
  esac

  # 2. Secret patterns — skip for test/fixture/example paths
  if ! is_test_or_fixture_path "$file"; then
    if grep -EHn -e 'sk-ant-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}' -e '-----BEGIN (RSA|EC|OPENSSH|PGP|DSA) PRIVATE KEY-----' "$file" 2>/dev/null; then
      FAILURES+=("Secret pattern detected in: $file")
    fi
  fi

  # 3. Oversized files (> 1 MB)
  if [[ "$(wc -c < "$file")" -gt 1048576 ]]; then
    FAILURES+=("File exceeds 1 MB (likely accidental): $file. Use Git LFS or .gitignore.")
  fi

  # 4. console.log / debugger in production source files
  if [[ "$file" =~ \.(ts|tsx|js|jsx)$ ]] && [[ "$file" != *test* && "$file" != *spec* && "$file" != *.config.* ]]; then
    if grep -EHn '^\s*(console\.(log|debug)|debugger;)' "$file" 2>/dev/null; then
      FAILURES+=("Debug statement in production file: $file. Use a structured logger or remove.")
    fi
  fi

done <<< "$STAGED"

if (( ${#FAILURES[@]} > 0 )); then
  printf '\n%s\n' "===== CCM pre-commit blocked the commit ====="
  for f in "${FAILURES[@]}"; do
    printf '  x %s\n' "$f"
  done
  printf '\nFix the issues above, then re-run the commit.\nLast resort (leaves audit trail): git commit --no-verify\n\n'
  notify_cowork "pre-commit-block" "$(printf '%s; ' "${FAILURES[@]}")"
  exit 1
fi

allow "pre-commit clean"
