#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# System Validation v3.0 — Verify all methodology files exist
# and are properly structured for the aligned architecture
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
  if [ -f "$1" ]; then
    echo -e "  ${GREEN}✅${NC} $1"
    ((PASS++))
  else
    echo -e "  ${RED}❌${NC} $1 — MISSING"
    ((FAIL++))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "  ${GREEN}✅${NC} $1/"
    ((PASS++))
  else
    echo -e "  ${RED}❌${NC} $1/ — MISSING"
    ((FAIL++))
  fi
}

warn_check() {
  if [ -f "$1" ]; then
    echo -e "  ${GREEN}✅${NC} $1"
    ((PASS++))
  else
    echo -e "  ${YELLOW}⚠️${NC}  $1 — optional, not found"
    ((WARN++))
  fi
}

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Claude Code Methodology v3.0 — Validation      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Core Files:${NC}"
check "CLAUDE.md"
check ".mcp.json"
warn_check ".worktreeinclude"

echo -e "\n${BOLD}Claude Directory — Settings:${NC}"
check ".claude/settings.json"
warn_check ".claude/settings.local.json"

echo -e "\n${BOLD}Claude Directory — Rules (path-scoped):${NC}"
check ".claude/rules/io-channel.md"
check ".claude/rules/memory.md"
check ".claude/rules/session-protocol.md"
check ".claude/rules/agents.md"
check ".claude/rules/hooks.md"
check ".claude/rules/architecture.md"
check ".claude/rules/implementation.md"

echo -e "\n${BOLD}Claude Directory — Skills (branded arib-*):${NC}"
check ".claude/skills/arib-session-start/SKILL.md"
check ".claude/skills/arib-session-end/SKILL.md"
check ".claude/skills/arib-io/SKILL.md"
check ".claude/skills/arib-dev-feature/SKILL.md"
check ".claude/skills/arib-dev-debug/SKILL.md"
check ".claude/skills/arib-dev-review/SKILL.md"
check ".claude/skills/arib-check-deploy/SKILL.md"
check ".claude/skills/arib-check-services/SKILL.md"
check ".claude/skills/arib-check-reality/SKILL.md"
check ".claude/skills/arib-check-migrate/SKILL.md"
check ".claude/skills/arib-check-perf/SKILL.md"
check ".claude/skills/arib-check-deps/SKILL.md"
check ".claude/skills/arib-check-a11y/SKILL.md"
check ".claude/skills/arib-docs-api/SKILL.md"
check ".claude/skills/arib-docs-generate/SKILL.md"
check ".claude/skills/arib-docs-language/SKILL.md"

echo -e "\n${BOLD}Claude Directory — Legacy Commands (deprecated, kept for compat):${NC}"
LEGACY_COUNT=$(ls .claude/commands/arib-*.md 2>/dev/null | wc -l)
if [ "$LEGACY_COUNT" -gt 0 ]; then
  echo -e "  ${YELLOW}⚠️${NC}  $LEGACY_COUNT legacy command files in .claude/commands/ (deprecated)"
  ((WARN++))
else
  echo -e "  ${GREEN}✅${NC} No legacy commands (clean)"
  ((PASS++))
fi

echo -e "\n${BOLD}Claude Directory — Agents:${NC}"
check ".claude/agents/architect.md"
check ".claude/agents/security-auditor.md"
check ".claude/agents/code-reviewer.md"
check ".claude/agents/test-engineer.md"
check ".claude/agents/debugger.md"
check ".claude/agents/refactor-specialist.md"
check ".claude/agents/language.md"
check ".claude/agents/reality-auditor.md"
check ".claude/agents/database-guardian.md"
check ".claude/agents/performance.md"
check ".claude/agents/api-docs.md"
check ".claude/agents/accessibility.md"
check ".claude/agents/deploy-guardian.md"

echo -e "\n${BOLD}Claude Directory — Agent Memory & Output Styles:${NC}"
check_dir ".claude/agent-memory"
check_dir ".claude/output-styles"

echo -e "\n${BOLD}Memory Layer:${NC}"
check "memory/MEMORY_PROTOCOL.md"
check "memory/project_status.md"
check "memory/session_notes.md"
check "memory/change_log.md"
check "memory/architecture_decisions.md"
check "memory/bugs_and_fixes.md"
check "memory/testing_log.md"

echo -e "\n${BOLD}Architecture Layer:${NC}"
check "architecture/CONSTRAINTS.md"
check "architecture/TECH_STACK.md"
check "architecture/CONTEXT_MAP.md"
check "architecture/ERROR_PATTERNS.md"
check "architecture/DECISIONS.md"
check "architecture/SECURITY.md"

echo -e "\n${BOLD}Implementation Layer:${NC}"
check "implementation/API_ENDPOINTS.md"
check "implementation/DOCKER_LOCAL.md"
check "implementation/docker-compose.yml"
check "implementation/EVENT_SCHEMA.md"
check "implementation/MIGRATION_ORDER.md"
check "implementation/LOCAL_RUNBOOK.md"
check "implementation/GATEWAY_ROUTES.md"

echo -e "\n${BOLD}Operations Layer:${NC}"
check "operations/WORKFLOW.md"
check "operations/OPERATIONS_LOG.md"
check "operations/DEPLOYMENT.md"

echo -e "\n${BOLD}Microservices Extension (optional):${NC}"
warn_check "architecture/SERVICE_MAP.md"
warn_check "architecture/INTER_SERVICE.md"
warn_check "operations/OBSERVABILITY.md"
warn_check "implementation/CONTRACT_TESTING.md"
warn_check "operations/ORCHESTRATION.md"

echo -e "\n${BOLD}Incident Response & Production Safety:${NC}"
check "operations/INCIDENT_RESPONSE.md"
check "operations/MONITORING.md"

echo -e "\n${BOLD}I/O Channel:${NC}"
check "io/IO_PROTOCOL.md"
check "io/status.md"
check "io/BRIEFING_COWORK.md"
check "io/BRIEFING_CLAUDE_CODE.md"
check "io/.templates/audit.md"
check "io/.templates/verify.md"
check "io/.templates/review.md"
check "io/.templates/result.md"
check "io/.templates/signal.md"
check "io/.templates/pipeline.md"

echo -e "\n${BOLD}Core Project Context:${NC}"
check "core/CORE_CONTEXT.md"

echo -e "\n${BOLD}Version & System:${NC}"
check "SYSTEM.md"
check "VERSION.json"
check "CHANGELOG.md"

echo -e "\n${BOLD}Bootstrap:${NC}"
check "bootstrap/BOOTSTRAP.md"
check "bootstrap/REVERSE_BOOTSTRAP.md"
check "bootstrap/REENGINEERING_GUIDE.md"
check "bootstrap/UPGRADE_PROTOCOL.md"
check "bootstrap/MIGRATION_GUIDE.md"

echo -e "\n${BOLD}Configuration:${NC}"
check "hooks/HOOKS_PROTOCOL.md"
check "reference/SKILLS_REGISTRY.md"
check "reference/USAGE_GUIDE.md"
check "reference/COMMANDS_GUIDE.md"
check "reference/COMMAND_PREFIX.md"
check "scripts/git-setup.sh"
check "scripts/services-check.sh"
warn_check "scripts/install-claude-skills-v2.sh"
warn_check ".env.example"
warn_check ".gitignore"

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Warnings: $WARN${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}${BOLD}System is complete and ready!${NC}"
else
  echo -e "${RED}${BOLD}System has $FAIL missing files. Fix before proceeding.${NC}"
fi
echo ""
