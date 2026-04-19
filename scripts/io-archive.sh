#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# I/O Archive — Move completed request-result pairs to archive
#
# Scans io/results/ for files, finds matching requests,
# moves both to io/archive/YYYY-MM/, including any threads.
#
# Usage: bash scripts/io-archive.sh [--dry-run]
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

IO_DIR="io"
ARCHIVE_DIR="$IO_DIR/archive"
REQUESTS_DIR="$IO_DIR/requests"
RESULTS_DIR="$IO_DIR/results"
THREADS_DIR="$IO_DIR/threads"

ARCHIVED=0
SKIPPED=0

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  I/O Channel — Archive Completed Requests        ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

$DRY_RUN && echo -e "${YELLOW}DRY RUN — no files will be moved${NC}\n"

# Process each result file
for result_file in "$RESULTS_DIR"/*-result.md 2>/dev/null; do
  [ -f "$result_file" ] || continue

  result_name=$(basename "$result_file")
  # Derive request filename: remove "-result" suffix
  request_name="${result_name%-result.md}.md"
  request_file="$REQUESTS_DIR/$request_name"

  # Extract date for archive folder (YYYY-MM from filename)
  date_part=$(echo "$result_name" | grep -oP '\d{4}-\d{2}' | head -1)
  if [ -z "$date_part" ]; then
    echo -e "  ${YELLOW}⚠️  Cannot extract date from: $result_name — skipping${NC}"
    ((SKIPPED++))
    continue
  fi

  archive_month="$ARCHIVE_DIR/$date_part"

  # Check if request file exists
  if [ ! -f "$request_file" ]; then
    echo -e "  ${YELLOW}⚠️  No matching request for: $result_name — skipping${NC}"
    ((SKIPPED++))
    continue
  fi

  # Extract request ID for thread lookup
  req_id=$(grep -oP 'REQ-\d{4}-\d{2}-\d{2}-\d{3}' "$request_file" 2>/dev/null | head -1)

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

  ((ARCHIVED++))
done

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "  Archived: ${GREEN}$ARCHIVED${NC}  Skipped: ${YELLOW}$SKIPPED${NC}"
$DRY_RUN && echo -e "  ${YELLOW}(dry run — nothing was actually moved)${NC}"
echo ""
