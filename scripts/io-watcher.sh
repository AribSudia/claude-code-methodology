#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# I/O Watcher — Check for pending requests and active signals
#
# Designed to be called at session-start or as a hook.
# Reports any pending I/O items that need attention.
#
# Usage: bash scripts/io-watcher.sh
# Exit codes:
#   0 = no pending items
#   1 = pending requests exist
#   2 = active signals exist (urgent)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

IO_DIR="io"
EXIT_CODE=0

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  I/O Channel — Watcher Report                    ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check signals first (highest priority)
SIGNAL_COUNT=0
if [ -d "$IO_DIR/signals" ]; then
  SIGNAL_COUNT=$(find "$IO_DIR/signals" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$SIGNAL_COUNT" -gt 0 ]; then
  echo -e "  ${RED}🚨 ACTIVE SIGNALS: $SIGNAL_COUNT${NC}"
  echo ""
  for sig in "$IO_DIR/signals"/*.md; do
    [ -f "$sig" ] || continue
    sig_name=$(basename "$sig")
    sig_type=$(echo "$sig_name" | cut -d'-' -f1)
    echo -e "    ${RED}▸${NC} [$sig_type] $sig_name"
  done
  echo ""
  echo -e "  ${RED}${BOLD}⚠️  SIGNALS TAKE PRIORITY — process before any other work${NC}"
  EXIT_CODE=2
fi

# Check pending requests
REQUEST_COUNT=0
if [ -d "$IO_DIR/requests" ]; then
  REQUEST_COUNT=$(find "$IO_DIR/requests" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$REQUEST_COUNT" -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}📥 PENDING REQUESTS: $REQUEST_COUNT${NC}"
  echo ""
  for req in "$IO_DIR/requests"/*.md; do
    [ -f "$req" ] || continue
    req_name=$(basename "$req")
    # Try to extract priority
    priority=$(grep -i "Priority:" "$req" 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d '*' | tr -d ' ')
    type=$(echo "$req_name" | cut -d'-' -f1)
    echo -e "    ${CYAN}▸${NC} [$type] $req_name ${YELLOW}($priority)${NC}"
  done
  [ "$EXIT_CODE" -eq 0 ] && EXIT_CODE=1
fi

# Check active pipelines
PIPELINE_COUNT=0
if [ -d "$IO_DIR/pipelines" ]; then
  PIPELINE_COUNT=$(find "$IO_DIR/pipelines" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$PIPELINE_COUNT" -gt 0 ]; then
  echo ""
  echo -e "  ${CYAN}🔄 ACTIVE PIPELINES: $PIPELINE_COUNT${NC}"
  for pipe in "$IO_DIR/pipelines"/*.md; do
    [ -f "$pipe" ] || continue
    echo -e "    ${CYAN}▸${NC} $(basename "$pipe")"
  done
fi

# Check threads needing response
THREAD_COUNT=0
if [ -d "$IO_DIR/threads" ]; then
  for thread_dir in "$IO_DIR/threads"/*/; do
    [ -d "$thread_dir" ] || continue
    # Count follow-ups — odd number means waiting for response
    fu_count=$(find "$thread_dir" -name "follow-up-*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ $((fu_count % 2)) -ne 0 ]; then
      ((THREAD_COUNT++))
    fi
  done
fi

if [ "$THREAD_COUNT" -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}💬 THREADS AWAITING RESPONSE: $THREAD_COUNT${NC}"
fi

# Summary
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo -e "  ${GREEN}✅ I/O Channel is clear — no pending items${NC}"
else
  TOTAL=$((SIGNAL_COUNT + REQUEST_COUNT + THREAD_COUNT))
  echo -e "  ${YELLOW}📋 Total items needing attention: $TOTAL${NC}"
fi
echo ""

exit $EXIT_CODE
