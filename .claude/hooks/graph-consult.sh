#!/usr/bin/env bash
# .claude/hooks/graph-consult.sh
# PreToolUse (Grep|Glob) — code-graph navigation hint (advisory, v3.19.0, ADR-034).
#
# HONEST + SAFE:
#   - ADVISORY ONLY. Always exit 0. It is NOT a safety gate (that is
#     pre-tool-use.sh, untouched) and it NEVER blocks.
#   - PURE NO-OP when the graph isn't built (the default, incl. CCM itself).
#   - When the graph IS built, it surfaces a one-line structural hint (stderr)
#     pointing at `/arib-graph query` so navigation goes by structure instead of
#     re-grepping the whole tree. It does not rewrite the search or inject the
#     full graph (that would be unreliable + token-heavy); the authoritative
#     lookup is `/arib-graph query <entity>`.

HOOK_NAME="graph-consult"
CCM_ROOT="${CCM_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MANIFEST="${CCM_ROOT}/memory/code-graph/graph-manifest.json"
GRAPH="${CCM_ROOT}/memory/code-graph/graph.json"

# No graph, no jq, or graph not built → nothing to consult. Silent no-op.
command -v jq >/dev/null 2>&1 || exit 0
[[ -f "$MANIFEST" && -f "$GRAPH" ]] || exit 0
BUILT="$(jq -r '.built // false' "$MANIFEST" 2>/dev/null || echo false)"
[[ "$BUILT" == "true" ]] || exit 0

FC="$(jq -r '.stats.files // 0' "$GRAPH" 2>/dev/null || echo 0)"
[[ "${FC:-0}" -gt 0 ]] || exit 0

# Advisory hint only — never blocks, never rewrites the search.
printf '[CCM/graph-consult] code-graph available (%s files) — for structural navigation use `/arib-graph query <entity>` instead of a broad grep.\n' "$FC" >&2
exit 0
