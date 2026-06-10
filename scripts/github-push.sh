#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# GitHub Push — Create private repo and push methodology
#
# PREREQUISITES:
#   1. Install GitHub CLI: https://cli.github.com/
#   2. Authenticate: gh auth login
#   3. Run this script from the methodology root folder
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Claude Code Methodology — GitHub Setup          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
if ! command -v gh &>/dev/null; then
  echo -e "${YELLOW}⚠️  GitHub CLI (gh) not found.${NC}"
  echo ""
  echo "Install it first:"
  echo "  macOS:   brew install gh"
  echo "  Windows: winget install --id GitHub.cli"
  echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  echo ""
  echo "Then authenticate:"
  echo "  gh auth login"
  exit 1
fi

# Check auth
if ! gh auth status &>/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Not authenticated with GitHub.${NC}"
  echo "Run: gh auth login"
  exit 1
fi

echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"

# Initialize git if needed
if [ ! -d ".git" ]; then
  git init
  echo -e "${GREEN}✅ Git initialized${NC}"
fi

# Stage all files
git add -A
git status --short

# Check if we need an initial commit
if git rev-parse HEAD &>/dev/null 2>&1; then
  echo -e "${CYAN}ℹ️  Repository already has commits${NC}"
else
  CCM_VER="$(command -v jq >/dev/null 2>&1 && jq -r '.version // "unknown"' VERSION.json 2>/dev/null || echo unknown)"
  git commit -m "Initial commit: Claude Code Methodology v${CCM_VER}

  Complete AI Development Operating System:
  - 4-Layer Architecture (CLAUDE.md, Skills, Hooks, Agents)
  - Persistent memory system + I/O Channel
  - Specialist agents, branded /arib-* skills, safety hooks
  - Bootstrap / Reverse Bootstrap / Upgrade / Migration / Reengineering
  - Architecture + Implementation + Operations templates
  (see VERSION.json for the exact inventory)"
  echo -e "${GREEN}✅ Initial commit created${NC}"
fi

# Create private repo and push
REPO_NAME="claude-code-methodology"

echo ""
echo -e "${CYAN}Creating private repository: $REPO_NAME${NC}"

gh repo create "$REPO_NAME" \
  --private \
  --source=. \
  --push \
  --description "Complete AI Development Operating System for Claude Code — 4-Layer Architecture, Persistent Memory, 8 Specialist Agents, Safety Hooks, Bootstrap & Reverse Bootstrap for new and existing projects."

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Done! Repository created and pushed.${NC}"
echo ""
echo -e "  Repository: ${CYAN}https://github.com/$(gh api user --jq .login)/$REPO_NAME${NC}"
echo -e "  Visibility: ${YELLOW}Private${NC}"
echo ""
echo -e "  To make it public later:"
echo -e "    gh repo edit $REPO_NAME --visibility public"
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""
