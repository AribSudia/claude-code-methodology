#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Git Setup — One-time repository initialization
# Run this ONCE after bootstrapping the Claude Code system
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Claude Code Methodology — Git Setup             ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if git is initialized
if [ -d ".git" ]; then
  info "Git already initialized"
else
  git init
  log "Git initialized"
fi

# Step 2: Set up branches
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [ -z "$CURRENT_BRANCH" ]; then
  # No commits yet — create initial commit
  git add .
  git commit -m "[chore]: initialize project with Claude Code Methodology v1.0

  - 4-Layer Architecture (CLAUDE.md, Skills, Hooks, Agents)
  - Persistent Memory System (6 memory files)
  - 8 Specialist Agents
  - 21 Skills Registry
  - 6 Architecture Templates
  - 7 Implementation Templates
  - 8 Slash Commands
  - Bootstrap Protocol for project instantiation"
  log "Initial commit created on main"
fi

# Create develop branch if it doesn't exist
if ! git rev-parse --verify develop &>/dev/null; then
  git branch develop
  log "Branch 'develop' created"
else
  info "Branch 'develop' already exists"
fi

# Step 3: Verify .gitignore
if [ -f ".gitignore" ]; then
  log ".gitignore exists"
else
  warn "No .gitignore found — creating one"
  cp scripts/.gitignore.template .gitignore 2>/dev/null || {
    cat > .gitignore << 'GITIGNORE'
# Environment
.env
.env.local
.env.production
*.env

# Dependencies
node_modules/
vendor/
.venv/

# Build
dist/
build/
out/
.next/
bin/
obj/

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs
*.log
logs/

# Testing
coverage/
.nyc_output/

# Docker
docker-compose.override.yml

# Secrets
*.pem
*.key
credentials.json
GITIGNORE
    log ".gitignore created"
  }
fi

# Step 4: Summary
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Branches:"
git branch --list | sed 's/^/  /'
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in this directory"
echo "  2. Type: /session-start"
echo "  3. Claude Code reads all context files"
echo "  4. Start building!"
echo ""
