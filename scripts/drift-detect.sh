#!/usr/bin/env bash
# scripts/drift-detect.sh
# Reads a template-hashes.json manifest and classifies every shipped
# framework file in the target tree as IDENTICAL / DIFFERS / MISSING.
# Emits a YAML drift report. This makes UPGRADE_PROTOCOL Phase 1.5 real
# instead of a heuristic that could overwrite user edits (ADR-016).
#
# Usage:
#   ./scripts/drift-detect.sh                       # self-check (repo vs its own manifest)
#   ./scripts/drift-detect.sh --manifest <path> --target <dir>
#
# In a PROJECT that installed CCM, run:
#   ./scripts/drift-detect.sh \
#     --manifest claude-code-methodology/reference/template-hashes.json \
#     --target .
#
# Classification is HONEST about what it cannot know:
#   IDENTICAL  — project file hash == manifest hash. Nothing to do.
#   DIFFERS    — hashes differ. Could be (a) a stale template to refresh,
#                or (b) a local edit to preserve. We CANNOT auto-distinguish
#                without historical hashes, so we report NEEDS-REVIEW and
#                NEVER auto-overwrite. The human decides. (This is the data-
#                loss fix — the old heuristic guessed and could clobber edits.)
#   MISSING    — manifest path absent in target. Safe to copy from template.
#
# Exit 0 = report written (drift may or may not exist). Exit 1 = manifest
# unreadable. The script never modifies any file — it only reports.

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

MANIFEST="reference/template-hashes.json"
TARGET="."
while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest) MANIFEST="$2"; shift 2 ;;
    --target)   TARGET="$2"; shift 2 ;;
    *) echo "unknown arg: $1"; exit 1 ;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "jq required"; exit 1; }
[[ -f "$MANIFEST" ]] || { echo "manifest not found: $MANIFEST (run gen-template-hashes.sh on the template)"; exit 1; }

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
MAN_VER="$(jq -r '.version' "$MANIFEST")"
mkdir -p io/ledger

IDENTICAL=0; DIFFERS=0; MISSING=0
DIFF_LIST=""; MISS_LIST=""

while IFS=$'\t' read -r path want; do
  [[ -z "$path" ]] && continue
  proj="${TARGET%/}/$path"
  if [[ ! -f "$proj" ]]; then
    MISSING=$((MISSING+1)); MISS_LIST="${MISS_LIST}  - ${path}"$'\n'; continue
  fi
  got="$(sha256 "$proj")"
  if [[ "$got" == "$want" ]]; then
    IDENTICAL=$((IDENTICAL+1))
  else
    DIFFERS=$((DIFFERS+1)); DIFF_LIST="${DIFF_LIST}  - ${path}"$'\n'
  fi
done < <(jq -r '.files | to_entries[] | "\(.key)\t\(.value)"' "$MANIFEST")

# Short hash of the findings for the ledger header.
FINDINGS_HASH="$(printf '%s%s%s' "$IDENTICAL" "$DIFFERS" "$MISSING" | { sha256sum 2>/dev/null || shasum -a 256; } | awk '{print $1}')"
SHORT="${FINDINGS_HASH:0:8}"
REPORT="io/ledger/drift-${TS}-${SHORT}.md"

VERDICT="CLEAN"
(( DIFFERS > 0 || MISSING > 0 )) && VERDICT="DRIFT"

{
  echo "# Drift Detection Report"
  echo ""
  echo "- audit-hash: ${FINDINGS_HASH}"
  echo "- short-hash: ${SHORT}"
  echo "- timestamp: ${TS}"
  echo "- mode: drift-detection"
  echo "- manifest: ${MANIFEST}"
  echo "- manifest_version: ${MAN_VER}"
  echo "- target: ${TARGET}"
  echo "- verdict: ${VERDICT}"
  echo "- identical: ${IDENTICAL}"
  echo "- differs: ${DIFFERS}"
  echo "- missing: ${MISSING}"
  echo ""
  echo "## DIFFERS — NEEDS REVIEW (never auto-overwritten)"
  echo ""
  echo "Each file below differs from the template. It is EITHER a stale"
  echo "template to refresh OR a deliberate local edit to keep. drift-detect"
  echo "does not guess — you decide per file. Refresh with:"
  echo "    cp <template>/<path> ./<path>   # only if you want the template version"
  echo ""
  if [[ -n "$DIFF_LIST" ]]; then printf '%s' "$DIFF_LIST"; else echo "  (none)"; fi
  echo ""
  echo "## MISSING — safe to copy from template"
  echo ""
  if [[ -n "$MISS_LIST" ]]; then printf '%s' "$MISS_LIST"; else echo "  (none)"; fi
} > "$REPORT"

echo "[drift-detect] ${VERDICT}: identical=${IDENTICAL} differs=${DIFFERS} missing=${MISSING}"
echo "[drift-detect] report: ${REPORT}"
exit 0
