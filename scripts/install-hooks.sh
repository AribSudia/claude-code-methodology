#!/usr/bin/env bash
# scripts/install-hooks.sh
# Idempotent installer for CCM hooks.
# - Marks all hook scripts executable.
# - Installs git pre-commit hook delegating to .claude/hooks/pre-commit.sh.
# - Verifies dependencies (jq, git, curl).
# - Smoke-tests session-start.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

echo "==> Installing CCM hooks..."

# 1. Make all hook scripts executable.
find .claude/hooks -type f -name '*.sh' -exec chmod +x {} \;
chmod +x scripts/*.sh 2>/dev/null || true

# 2. Install git pre-commit hook delegating to .claude/hooks/pre-commit.sh.
mkdir -p .git/hooks
cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# Auto-installed by CCM. Delegates to .claude/hooks/pre-commit.sh.
exec "$(git rev-parse --show-toplevel)/.claude/hooks/pre-commit.sh" "$@"
EOF
chmod +x .git/hooks/pre-commit

# 3. Verify dependencies.
MISSING=()
for tool in jq git curl; do
  command -v "$tool" >/dev/null 2>&1 || MISSING+=("$tool")
done
if (( ${#MISSING[@]} > 0 )); then
  echo "WARNING: Missing required tools: ${MISSING[*]}"
  echo "  macOS:         brew install ${MISSING[*]}"
  echo "  Debian/Ubuntu: apt install ${MISSING[*]}"
  exit 1
fi

# 4. Smoke-test session-start.
echo "==> Smoke-testing session-start hook..."
if echo '{}' | .claude/hooks/session-start.sh >/dev/null 2>&1; then
  echo "    OK session-start"
else
  echo "    FAIL session-start (review output above)"
  exit 1
fi

echo ""
echo "==> CCM hooks installed."
echo "    Logs:   io/hook-logs/   (gitignored)"
echo "    Ledger: io/ledger/      (committed; rotate with care)"
echo ""
echo "    To enable CoWork notifications (opt-in), set:"
echo "      export CCM_COWORK_WEBHOOK='https://your-cowork-endpoint'"
