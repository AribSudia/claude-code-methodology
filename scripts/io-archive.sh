#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# I/O Archive — Move completed request-result pairs to archive
#
# Default mode: scans io/results/ for files, finds matching requests,
# moves both to io/archive/YYYY-MM/, including any threads.
#
# --ledger mode (ADR-040): rotates io/ledger/session-*.md. The Stop hook
# writes one stub per session forever; left alone they accumulate (108 of
# them, 312 KB, by v4.2.0). This folds the old ones into a single
# per-year index table and deletes the stubs. Idempotent — a timestamp
# already in the index is never appended twice.
#
# Usage: bash scripts/io-archive.sh [--dry-run]
#        bash scripts/io-archive.sh --ledger [--keep N] [--dry-run]
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
LEDGER_MODE=false
KEEP=10
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --ledger)  LEDGER_MODE=true; shift ;;
    --keep)    KEEP="${2:?--keep needs a number}"; shift 2 ;;
    *) echo "io-archive: unknown option '$1'" >&2; exit 1 ;;
  esac
done

IO_DIR="io"
ARCHIVE_DIR="$IO_DIR/archive"
REQUESTS_DIR="$IO_DIR/requests"
RESULTS_DIR="$IO_DIR/results"
THREADS_DIR="$IO_DIR/threads"

ARCHIVED=0
SKIPPED=0


# ═══════════════════════════════════════════════════════════════
# --ledger — rotate session stubs into a per-year index
# ═══════════════════════════════════════════════════════════════
rotate_ledger() {
  local dir="$IO_DIR/ledger"
  [ -d "$dir" ] || { echo "  no $dir — nothing to rotate"; return 0; }

  shopt -s nullglob
  local files=("$dir"/session-*.md)
  local total=${#files[@]}
  if [ "$total" -le "$KEEP" ]; then
    $DRY_RUN || echo "  ledger: $total stub(s), keeping $KEEP — nothing to rotate"
    return 0
  fi

  # Oldest first (filenames are ISO timestamps, so lexical == chronological).
  local cutoff=$((total - KEEP)) rotated=0 i=0 f
  for f in "${files[@]}"; do
    [ "$i" -lt "$cutoff" ] || break
    i=$((i + 1))

    local ts branch end_sha commits changed year archive
    ts=$(awk -F': ' '/^- timestamp:/{print $2; exit}' "$f")
    [ -n "$ts" ] || { echo "  ⚠️  no timestamp in $(basename "$f") — skipping"; continue; }
    branch=$(awk -F': ' '/^- branch:/{print $2; exit}' "$f")
    end_sha=$(awk -F': ' '/^- end_sha:/{print substr($2,1,7); exit}' "$f")
    commits=$(awk -F': ' '/^- commits_this_session:/{print $2; exit}' "$f")
    changed=$(awk -F': ' '/^- files_changed:/{print $2; exit}' "$f")
    year="${ts%%-*}"
    archive="$dir/ARCHIVE-${year}.md"

    if $DRY_RUN; then
      echo -e "  ${CYAN}Would fold:${NC} $(basename "$f") → $(basename "$archive")"
      rotated=$((rotated + 1))
      continue
    fi

    if [ ! -f "$archive" ]; then
      cat > "$archive" <<HEADER
# Session Ledger Index — ${year}

> Rolled up by \`scripts/io-archive.sh --ledger\` (ADR-040). One row per
> session. The full stubs live in git history; this index is the durable,
> readable audit trail. Append-only — newest rows at the bottom.

| Timestamp | Branch | End SHA | Commits | Files changed |
|-----------|--------|---------|---------|---------------|
HEADER
    fi

    # Idempotent: never append a timestamp the index already carries.
    if grep -qF "| ${ts} |" "$archive"; then
      rm -f "$f"
      continue
    fi
    printf '| %s | %s | %s | %s | %s |\n' \
      "$ts" "${branch:-?}" "${end_sha:-?}" "${commits:-0}" "${changed:-0}" >> "$archive"
    rm -f "$f"
    rotated=$((rotated + 1))
  done

  echo -e "  ${GREEN}✅${NC} folded ${rotated} stub(s) into $dir/ARCHIVE-*.md; kept the newest $KEEP"
}

if $LEDGER_MODE; then
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║  I/O Archive — Rotate Session Ledger             ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
  echo ""
  $DRY_RUN && echo -e "${YELLOW}DRY RUN — no files will be removed${NC}\n"
  rotate_ledger
  echo ""
  exit 0
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  I/O Channel — Archive Completed Requests        ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

$DRY_RUN && echo -e "${YELLOW}DRY RUN — no files will be moved${NC}\n"

# Process each result file. nullglob makes the loop body skip when no
# files match (rather than iterating over the literal glob).
shopt -s nullglob
for result_file in "$RESULTS_DIR"/*-result.md; do
  [ -f "$result_file" ] || continue

  result_name=$(basename "$result_file")
  # Derive request filename: remove "-result" suffix
  request_name="${result_name%-result.md}.md"
  request_file="$REQUESTS_DIR/$request_name"

  # Extract date for archive folder (YYYY-MM from filename)
  date_part=$(echo "$result_name" | grep -oE '[0-9]{4}-[0-9]{2}' | head -1)
  if [ -z "$date_part" ]; then
    echo -e "  ${YELLOW}⚠️  Cannot extract date from: $result_name — skipping${NC}"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  archive_month="$ARCHIVE_DIR/$date_part"

  # Check if request file exists
  if [ ! -f "$request_file" ]; then
    echo -e "  ${YELLOW}⚠️  No matching request for: $result_name — skipping${NC}"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Extract request ID for thread lookup
  req_id=$(grep -oE 'REQ-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}' "$request_file" 2>/dev/null | head -1)

  if $DRY_RUN; then
    echo -e "  ${CYAN}Would archive:${NC} $request_name + $result_name"
    [ -n "$req_id" ] && [ -d "$THREADS_DIR/$req_id" ] && \
      echo -e "    ${CYAN}+ thread:${NC} $req_id/"
  else
    mkdir -p "$archive_month"

    mv "$request_file" "$archive_month/"
    mv "$result_file" "$archive_month/"

    # Archive thread if exists
    if [ -n "$req_id" ] && [ -d "$THREADS_DIR/$req_id" ]; then
      mv "$THREADS_DIR/$req_id" "$archive_month/"
      echo -e "  ${GREEN}✅${NC} Archived: $request_name + $result_name + thread/$req_id"
    else
      echo -e "  ${GREEN}✅${NC} Archived: $request_name + $result_name"
    fi
  fi

  ARCHIVED=$((ARCHIVED + 1))
done

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "  Archived: ${GREEN}$ARCHIVED${NC}  Skipped: ${YELLOW}$SKIPPED${NC}"
$DRY_RUN && echo -e "  ${YELLOW}(dry run — nothing was actually moved)${NC}"
echo ""
