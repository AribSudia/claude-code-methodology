#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# System Validation (v3.10.0 rewrite) — verify the deployed CCM
# structure against VERSION.json, DYNAMICALLY.
#
# The previous version hard-coded a v1.0-era inventory: it still
# required `.claude/agent-memory/` (removed v3.8.3, ADR-022), listed
# 16 skills and 13 agents by name (reality: 26 and 15), and never
# exited non-zero on failure. This rewrite derives expectations from
# VERSION.json stats + the actual layout, so counts cannot go stale:
#   - structural: every load-bearing dir/file exists
#   - counts: disk inventory == VERSION.json stats
#   - retired: deprecated paths are ABSENT (agent-memory)
#   - executable bits on hooks and scripts
#   - settings.json hook commands resolve to real files
#
# Exit 0 = valid, exit 1 = failures found.
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "${REPO_ROOT}"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

ok()   { echo -e "  ${GREEN}✅${NC} $1"; PASS=$((PASS+1)); }
bad()  { echo -e "  ${RED}❌${NC} $1";   FAIL=$((FAIL+1)); }
note() { echo -e "  ${YELLOW}⚠️${NC}  $1"; WARN=$((WARN+1)); }

check_file() { [ -f "$1" ] && ok "$1" || bad "$1 — MISSING"; }
check_dir()  { [ -d "$1" ] && ok "$1/" || bad "$1/ — MISSING"; }
check_gone() { [ ! -e "$1" ] && ok "$1 absent (retired)" || bad "$1 still present — retired in $2; remove it"; }

# check_count <expected> <label> <actual>
check_count() {
  local expected="$1" label="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    ok "$label: $actual (matches VERSION.json)"
  else
    bad "$label: disk=$actual but VERSION.json says $expected — update whichever is wrong"
  fi
}

echo -e "${BOLD}═══ CCM System Validation ═══${NC}"

# ---------- 0. Prerequisites ----------
echo -e "\n${BOLD}0. Prerequisites${NC}"
if ! command -v jq >/dev/null 2>&1; then
  bad "jq not installed — required (VERSION.json requiredTools); cannot run count checks"
  echo -e "\n${RED}Install jq and re-run.${NC}"
  exit 1
fi
ok "jq available"
check_file "VERSION.json"
[ -f VERSION.json ] || { echo -e "\n${RED}VERSION.json missing — cannot validate.${NC}"; exit 1; }

stat() { jq -r ".stats.$1" VERSION.json; }
echo -e "  ${BOLD}Validating against VERSION.json v$(jq -r '.version' VERSION.json)${NC}"

# ---------- 1. Lean core (always-on context, ADR-019) ----------
echo -e "\n${BOLD}1. Lean core (always-on)${NC}"
check_file "CLAUDE.md"
check_file "architecture/CONSTRAINTS.md"
check_file "memory/project_status.md"
check_file "memory/session_notes.md"

# ---------- 2. Layer dirs ----------
echo -e "\n${BOLD}2. Structure${NC}"
for d in .claude .claude/skills .claude/agents .claude/rules .claude/hooks \
         architecture implementation operations memory io \
         bootstrap reference scripts Training compliance waves hooks core; do
  check_dir "$d"
done

# ---------- 3. Dynamic counts vs VERSION.json ----------
echo -e "\n${BOLD}3. Inventory vs VERSION.json${NC}"
check_count "$(stat agents)"  "agents"  "$(ls .claude/agents/*.md 2>/dev/null | grep -civ readme || true)"
check_count "$(stat skills)"  "skills"  "$(ls -d .claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')"
check_count "$(stat rules)"   "rules"   "$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')"
HOOK_COUNT="$(( $(ls .claude/hooks/*.sh 2>/dev/null | wc -l) + $(ls .claude/hooks/lib/*.sh 2>/dev/null | wc -l) ))"
check_count "$(stat hookScripts)" "hook scripts (incl. lib)" "$HOOK_COUNT"
check_count "$(stat scripts)" "scripts" "$(ls scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')"
check_count "$(stat trainingManuals)" "training manuals" "$(ls Training/*.md 2>/dev/null | wc -l | tr -d ' ')"
check_count "$(stat githubWorkflows)" "github workflows" "$(ls .github/workflows/*.yml 2>/dev/null | wc -l | tr -d ' ')"
check_count "$(stat memoryFiles)" "memory files" "$(ls memory/*.md 2>/dev/null | wc -l | tr -d ' ')"
check_count "$(stat bootstrapMethods)" "bootstrap protocols" "$(ls bootstrap/BOOTSTRAP.md bootstrap/REVERSE_BOOTSTRAP.md bootstrap/UPGRADE_PROTOCOL.md bootstrap/MIGRATION_GUIDE.md bootstrap/REENGINEERING_GUIDE.md 2>/dev/null | wc -l | tr -d ' ')"

# Every skill dir must contain a SKILL.md
SKILL_BAD=0
for d in .claude/skills/*/; do
  s="${d%/}"
  if [ ! -f "$s/SKILL.md" ]; then bad "$s/SKILL.md missing"; SKILL_BAD=1; fi
done
[ "$SKILL_BAD" -eq 0 ] && ok "every skill dir has SKILL.md"

# ---------- 4. Retired infra must be ABSENT ----------
echo -e "\n${BOLD}4. Retired infra (must be absent)${NC}"
check_gone ".claude/agent-memory" "v3.8.3 (ADR-022)"

# ---------- 5. Key files ----------
echo -e "\n${BOLD}5. Key files${NC}"
for f in SYSTEM.md CHANGELOG.md README.md CONTRIBUTING.md SECURITY.md \
         .claude/settings.json .mcp.json \
         architecture/DECISIONS.md architecture/CONTEXT_MAP.md \
         bootstrap/RUN.md bootstrap/PROTOCOL_PRINCIPLES.md \
         memory/MEMORY_PROTOCOL.md io/IO_PROTOCOL.md hooks/HOOKS_PROTOCOL.md \
         reference/template-hashes.json compliance/README.md; do
  check_file "$f"
done

# ---------- 6. Executable bits ----------
echo -e "\n${BOLD}6. Executable bits${NC}"
# lib/*.sh are sourced, not executed — no +x needed there.
NOEXEC=""
for s in .claude/hooks/*.sh scripts/*.sh; do
  [ -f "$s" ] && [ ! -x "$s" ] && NOEXEC="${NOEXEC} ${s}"
done
if [ -z "$NOEXEC" ]; then
  ok "all hook + script files executable"
else
  bad "not executable:${NOEXEC} — run: chmod +x${NOEXEC}"
fi

# ---------- 7. settings.json hook wiring ----------
echo -e "\n${BOLD}7. Hook wiring${NC}"
if jq -e '.hooks.PreToolUse[0].hooks[0].command' .claude/settings.json >/dev/null 2>&1; then
  ok "settings.json hooks shape valid"
else
  bad "settings.json hooks shape invalid (expected .hooks.PreToolUse[].hooks[].command)"
fi
MISSING_HOOK=""
while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  rel="${cmd#\$CLAUDE_PROJECT_DIR/}"
  [ -f "$rel" ] || MISSING_HOOK="${MISSING_HOOK} ${rel}"
done < <(jq -r '.hooks | to_entries[] | .value[].hooks[].command' .claude/settings.json 2>/dev/null | sort -u)
if [ -z "$MISSING_HOOK" ]; then
  ok "every settings.json hook command exists on disk"
else
  bad "settings.json references missing hook script(s):${MISSING_HOOK}"
fi

# ---------- 8. Legacy commands (informational) ----------
echo -e "\n${BOLD}8. Legacy${NC}"
if [ -d .claude/commands ]; then
  note ".claude/commands/ present ($(ls .claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ') files) — deprecated, kept for back-compat; skills are canonical"
else
  ok ".claude/commands/ not present (fine — skills are canonical)"
fi

# ---------- Summary ----------
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Warnings: $WARN${NC}"
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}${BOLD}System has $FAIL validation failure(s). Fix before proceeding.${NC}"
  exit 1
fi
echo -e "${GREEN}${BOLD}System valid — structure, counts, and wiring all match.${NC}"
exit 0
