#!/usr/bin/env bash
# scripts/gen-template-hashes.sh
# Generates reference/template-hashes.json — a sha256 manifest of every
# SHIPPED FRAMEWORK FILE in CCM. The drift classifier (scripts/drift-detect.sh,
# UPGRADE_PROTOCOL Phase 1.5) reads this to distinguish a file that matches the
# template (identical) from one that diverges (needs review) — without it the
# classifier degrades to a heuristic that can overwrite user edits (ADR-016).
#
# Run on each release (and in CI) so the manifest tracks the shipped version.
#   ./scripts/gen-template-hashes.sh && git add reference/template-hashes.json
#
# IMPORTANT: only framework files are hashed. Project-STATE files (memory data,
# core/, io/ledger, settings.local, semantic_export) are NEVER in the manifest —
# they are per-project and must never be classified as "stale template".

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

OUT="reference/template-hashes.json"
mkdir -p reference

# Portable sha256.
sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

VER="$(jq -r '.version' VERSION.json 2>/dev/null || echo unknown)"
GITSHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

# Framework file set (shipped templates). Globs expanded by find below.
# Project-state exclusions are applied after.
CANDIDATES=()
while IFS= read -r _line; do CANDIDATES+=("$_line"); done < <(
  {
    echo CLAUDE.md; echo SYSTEM.md; echo VERSION.json; echo README.md
    echo CONTRIBUTING.md; echo SECURITY.md; echo CODE_OF_CONDUCT.md; echo CHANGELOG.md
    echo .markdownlint.json; echo .mcp.json; echo .gitignore
    find .claude/agents -name '*.md' 2>/dev/null
    find .claude/skills -name 'SKILL.md' 2>/dev/null
    find .claude/rules -name '*.md' 2>/dev/null
    find .claude/hooks -name '*.sh' 2>/dev/null
    echo .claude/settings.json
    find architecture -name '*.md' 2>/dev/null
    find bootstrap -name '*.md' 2>/dev/null
    find compliance -name '*.md' 2>/dev/null
    find operations -name '*.md' 2>/dev/null
    find implementation -name '*.md' 2>/dev/null
    echo io/IO_PROTOCOL.md
    echo memory/MEMORY_PROTOCOL.md
    find scripts -name '*.sh' 2>/dev/null
    find Training -name '*.md' 2>/dev/null
    find .github -type f 2>/dev/null
    find waves/.templates -type f 2>/dev/null
    echo waves/README.md
  } | sort -u
)

# Project-state exclusion test (never hash these).
is_excluded() {
  case "$1" in
    memory/project_status.md|memory/session_notes.md|memory/change_log.md|\
    memory/architecture_decisions.md|memory/bugs_and_fixes.md|memory/testing_log.md|\
    memory/semantic_export.md|\
    core/*|io/ledger/*|io/hook-logs/*|io/requests/*|io/results/*|io/signals/*|\
    io/archive/*|.claude/settings.local.json|.claude/worktrees/*) return 0 ;;
  esac
  return 1
}

echo "{"                                              >  "$OUT"
echo "  \"version\": \"${VER}\","                     >> "$OUT"
echo "  \"generated_from_git\": \"${GITSHA}\","       >> "$OUT"
echo "  \"_note\": \"sha256 of shipped framework files. Project-state files are intentionally absent. Regenerate with scripts/gen-template-hashes.sh on each release.\","  >> "$OUT"
echo "  \"files\": {"                                 >> "$OUT"

first=1
count=0
for f in "${CANDIDATES[@]}"; do
  [[ -z "$f" ]] && continue
  [[ ! -f "$f" ]] && continue
  is_excluded "$f" && continue
  h="$(sha256 "$f")"
  if [[ $first -eq 1 ]]; then first=0; else echo "," >> "$OUT"; fi
  printf '    "%s": "%s"' "$f" "$h" >> "$OUT"
  count=$((count+1))
done
echo ""                                               >> "$OUT"
echo "  }"                                            >> "$OUT"
echo "}"                                              >> "$OUT"

echo "[gen-template-hashes] wrote $OUT — ${count} files hashed (v${VER}, ${GITSHA})"
