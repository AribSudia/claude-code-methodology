#!/usr/bin/env bash
# scripts/build-code-graph.sh
# Native, lightweight CODE-GRAPH builder (v3.19.0, ADR-034).
#
# HONEST SCOPE: this is an IMPORT/SYMBOL graph built with ripgrep/grep — a
# structural map of "which file imports which", plus per-file in/out degree to
# surface god-nodes. It is NOT Graphify's semantic analysis (no call-graph,
# no type resolution). It is dependency-free (rg preferred, grep fallback),
# bounded, and portable (macOS bash 3.2). Output is git-diffable JSON + a
# readable report. The graph loads ON DEMAND only (zero always-on tokens).
#
# Usage: scripts/build-code-graph.sh [--root DIR] [--max N]
# Writes: memory/code-graph/{graph.json, GRAPH_REPORT.md, graph-manifest.json}

set -uo pipefail
ROOT="."; MAX=8000
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="${2:?}"; shift 2 ;;
    --max)  MAX="${2:?}";  shift 2 ;;
    -h|--help) echo "usage: build-code-graph.sh [--root DIR] [--max N]"; exit 0 ;;
    *) echo "build-code-graph: unknown arg: $1" >&2; exit 2 ;;
  esac
done
command -v jq >/dev/null 2>&1 || { echo "build-code-graph: jq required" >&2; exit 1; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="${REPO_ROOT}/memory/code-graph"
mkdir -p "$OUT"
cd "$ROOT" 2>/dev/null || { echo "build-code-graph: bad --root '$ROOT'" >&2; exit 1; }

EXT='ts|tsx|js|jsx|mjs|cjs|py|go|java|rb|php'
list_files() {
  if command -v rg >/dev/null 2>&1; then
    rg --files -g '!node_modules' -g '!.git' -g '!dist' -g '!build' -g '!*.min.*' 2>/dev/null \
      | grep -E "\.(${EXT})$"
  else
    find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' \
      -not -path '*/dist/*' -not -path '*/build/*' 2>/dev/null \
      | sed 's|^\./||' | grep -E "\.(${EXT})$"
  fi
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
FILES="$TMP/files"; EDGES="$TMP/edges"
list_files | head -n "$MAX" | sort -u > "$FILES"
FILE_COUNT="$(wc -l < "$FILES" | tr -d ' ')"

# Extract import edges (file<TAB>target). Best-effort, multi-language.
: > "$EDGES"
while IFS= read -r f; do
  [[ -f "$f" ]] || continue
  # JS/TS: import ... from 'X' | require('X') | export ... from 'X'
  # Python: import X | from X import ...   Go: "path"   Ruby/PHP: require 'X'
  grep -hoE "from[[:space:]]+['\"][^'\"]+['\"]|require\(['\"][^'\"]+['\"]\)|import[[:space:]]+['\"][^'\"]+['\"]|^[[:space:]]*(import|from)[[:space:]]+[a-zA-Z0-9_.]+" "$f" 2>/dev/null \
    | sed -E "s/.*['\"]([^'\"]+)['\"].*/\1/; s/^[[:space:]]*(import|from)[[:space:]]+//" \
    | sed -E 's/[[:space:]]+import.*//' \
    | while IFS= read -r tgt; do
        [[ -n "$tgt" ]] && printf '%s\t%s\n' "$f" "$tgt" >> "$EDGES"
      done
done < "$FILES"
# Dedup: one structural edge per (file, target) even if imported on several lines.
sort -u "$EDGES" -o "$EDGES"
EDGE_COUNT="$(wc -l < "$EDGES" | tr -d ' ')"

# Top imported targets (in-degree = god-node candidates) and busiest importers.
TOP_IN="$(cut -f2 "$EDGES" | sort | uniq -c | sort -rn | head -10 | awk '{$1=$1;print}')"
TOP_OUT="$(cut -f1 "$EDGES" | sort | uniq -c | sort -rn | head -10 | awk '{$1=$1;print}')"
HEAD_SHA="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"

# graph.json (diffable). nodes = files; edges = import pairs (capped for size).
jq -n \
  --arg commit "$HEAD_SHA" \
  --argjson fc "$FILE_COUNT" --argjson ec "$EDGE_COUNT" \
  --rawfile files "$FILES" \
  --rawfile edges "$EDGES" \
  '{
     schema: "ccm-code-graph/1",
     note: "lightweight native import graph (not semantic) — ADR-034",
     generated_commit: $commit,
     stats: { files: $fc, edges: $ec },
     nodes: ($files | split("\n") | map(select(length>0))),
     edges: ($edges | split("\n") | map(select(length>0) | split("\t") | {from: .[0], to: .[1]}) | .[0:4000])
   }' > "$OUT/graph.json"

# graph-manifest.json (freshness metadata).
jq -n --arg commit "$HEAD_SHA" --argjson fc "$FILE_COUNT" --argjson ec "$EDGE_COUNT" \
  '{ built: true, last_build_commit: $commit, file_count: $fc, edge_count: $ec, stale: false }' \
  > "$OUT/graph-manifest.json"

# GRAPH_REPORT.md (readable summary; loaded on demand only).
{
  echo "# Code Graph Report"
  echo ""
  echo "> Native lightweight import graph (ADR-034) — structural map only, not semantic."
  echo "> Built at commit \`${HEAD_SHA:0:8}\`. Query with \`/arib-graph query <entity>\`."
  echo ""
  echo "- Files: ${FILE_COUNT}"
  echo "- Import edges: ${EDGE_COUNT}"
  echo ""
  echo "## Most-imported (god-node candidates)"
  echo '```'
  printf '%s\n' "$TOP_IN"
  echo '```'
  echo ""
  echo "## Busiest importers (highest out-degree)"
  echo '```'
  printf '%s\n' "$TOP_OUT"
  echo '```'
} > "$OUT/GRAPH_REPORT.md"

echo "build-code-graph: ${FILE_COUNT} files, ${EDGE_COUNT} edges → memory/code-graph/ (commit ${HEAD_SHA:0:8})"
