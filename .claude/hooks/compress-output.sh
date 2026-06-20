#!/usr/bin/env bash
# .claude/hooks/compress-output.sh
# PostToolUse (Bash) — output compression via rtk (the developer plan's §3.2).
#
# HONEST + GRACEFUL by design (ADR-033):
#   - This is ADVISORY. It NEVER blocks and ALWAYS exits 0 (it is not a safety
#     gate; the fail-closed gate is pre-tool-use.sh, untouched).
#   - If `rtk` is NOT installed, this is a pure NO-OP (passthrough). It makes NO
#     claim of token savings — there is nothing to claim without the tool.
#   - The real compression win comes from RUNNING noisy build/test commands
#     *through* rtk (see implementation/RTK_PROFILES.md). A PostToolUse hook
#     cannot reliably rewrite output already captured by the harness, so when
#     rtk is present this hook only records that the command was rtk-eligible
#     (a hint), and otherwise does nothing.

HOOK_NAME="compress-output"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Advisory hook: if we can't introspect the payload, just no-op (never error).
command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME="$(payload_get '.tool_name' 2>/dev/null || echo)"
[[ "$TOOL_NAME" == "Bash" ]] || exit 0
CMD="$(payload_get '.tool_input.command' 2>/dev/null || echo)"

# Noisy build/test/install commands whose output is worth compressing.
NOISY='npm (install|ci|test)|pnpm (install|test)|yarn (install|test)|nest build|turbo run|jest|vitest|playwright test|docker compose (up|build)|gradle|mvn'
printf '%s' "$CMD" | grep -Eq -- "$NOISY" || exit 0

if command -v rtk >/dev/null 2>&1; then
  # rtk present — record the opportunity (best-effort hint; see RTK_PROFILES.md
  # for the run-through-rtk pattern that does the actual reduction).
  log INFO "rtk-eligible command: ${CMD:0:80}" 2>/dev/null || true
else
  # rtk absent (the default install) — pure passthrough. No claim, no noise.
  log INFO "rtk not installed — output passthrough (no compression)" 2>/dev/null || true
fi

exit 0
