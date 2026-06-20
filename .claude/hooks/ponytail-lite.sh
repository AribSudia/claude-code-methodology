#!/usr/bin/env bash
# .claude/hooks/ponytail-lite.sh
# PostToolUse (Write|Edit|MultiEdit) — over-engineering tripwire (plan §3.5).
#
# HONEST: this is a NATIVE, deliberately-conservative heuristic — NOT the Ponytail
# tool (which isn't installed). It is ADVISORY (always exit 0, never blocks) and
# tuned for HIGH PRECISION / near-silence: it fires only on a clear single-use
# over-abstraction smell in a small edit, so it doesn't fight legitimate NestJS
# ceremony. The real bloat review is the on-demand `/arib-dev-lean` skill. The
# fail-closed safety gate is pre-tool-use.sh, untouched. (ADR-033.)

HOOK_NAME="ponytail-lite"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

command -v jq >/dev/null 2>&1 || exit 0
TOOL_NAME="$(payload_get '.tool_name' 2>/dev/null || echo)"
[[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]] || exit 0
TARGET_PATH="$(payload_get '.tool_input.file_path' 2>/dev/null || echo)"
[[ "$TARGET_PATH" =~ \.(ts|tsx|js|jsx|py|go|java)$ ]] || exit 0
[[ "$TARGET_PATH" == *node_modules* ]] && exit 0

# Exempt legitimate structural ceremony (NestJS modules/controllers/etc.) and
# anything explicitly marked, plus test/generated files.
case "$TARGET_PATH" in
  *.module.*|*.controller.*|*.service.*|*.guard.*|*.dto.*|*.entity.*|*.config.*|*.generated.*) exit 0 ;;
esac
is_test_or_fixture_path "$TARGET_PATH" 2>/dev/null && exit 0

NEW="$(payload_get '[.tool_input.content, .tool_input.new_string, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null || echo)"
[[ -n "$NEW" ]] || exit 0
printf '%s' "$NEW" | grep -q 'ccm-ceremony:' && exit 0

# High-precision smell: a SMALL change (≤ 25 non-blank lines) that introduces
# 2+ distinct single-use abstraction layers (interface/abstract + a
# Factory/Wrapper/Strategy/Manager/Provider) — abstraction with no second user.
# `grep -c` already prints a count (incl. 0) and exits 1 on no-match — use
# `|| true` to swallow that exit WITHOUT appending a second number.
LINES="$(printf '%s' "$NEW" | grep -cve '^[[:space:]]*$' || true)"
[[ "${LINES:-0}" -le 25 ]] || exit 0
# No `\b` — BSD grep (macOS) doesn't honor it reliably (v3.10 portability lesson).
LAYER1="$(printf '%s' "$NEW" | grep -Eci '(^|[^A-Za-z])(interface|abstract class)([^A-Za-z]|$)' || true)"
LAYER2="$(printf '%s' "$NEW" | grep -Eci '[A-Za-z]+(Factory|Wrapper|Strategy|Manager|Provider)' || true)"

if [[ "${LAYER1:-0}" -ge 1 && "${LAYER2:-0}" -ge 1 ]]; then
  printf '[CCM/ponytail-lite] possible over-engineering in %s — a small edit adds an interface/abstract layer AND a Factory/Wrapper for one use. Consider inlining, or mark intentional with `// ccm-ceremony:`. Full review: /arib-dev-lean %s\n' \
    "$TARGET_PATH" "$TARGET_PATH" >&2
fi

exit 0
