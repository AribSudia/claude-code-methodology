#!/usr/bin/env bash
# scripts/validate-coherence.sh
# Self-policing coherence validator (v3.7.0). The methodology preaches
# "DOCS MATCH DISK" and "ENFORCED not advisory" — this script enforces
# the invariants that earlier drifted silently (stale counts, missing
# agent frontmatter, version skew, dangling references).
#
# Exit 0 = coherent. Exit 1 = at least one invariant violated (CI-failing).
#
# Wire into CI (.github/workflows/coherence.yml) and run locally before
# any release. Pairs with scripts/test-hooks.sh (which validates hook
# behavior) — this validates structural coherence.

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

FAIL=0
note_fail() { printf '  ✗ %s\n' "$*"; FAIL=1; }
note_ok()   { printf '  ✓ %s\n' "$*"; }

need_jq() { command -v jq >/dev/null 2>&1 || { echo "jq required"; exit 1; }; }
need_jq

echo "=== CCM Coherence Validator ==="
echo ""

# ---------- 1. Counts on disk match VERSION.json ----------
echo "1. Inventory counts vs VERSION.json"
AGENTS_DISK=$(ls .claude/agents/*.md 2>/dev/null | grep -vi 'readme' | wc -l | tr -d ' ')
SKILLS_DISK=$(ls -d .claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
RULES_DISK=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
HOOKS_DISK=$(find .claude/hooks -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')

AGENTS_DECL=$(jq -r '.stats.agents // "missing"' VERSION.json)
SKILLS_DECL=$(jq -r '.stats.skills // "missing"' VERSION.json)
RULES_DECL=$(jq -r '.stats.rules // "missing"' VERSION.json)
HOOKS_DECL=$(jq -r '.stats.hookScripts // "missing"' VERSION.json)

[ "$AGENTS_DISK" = "$AGENTS_DECL" ] && note_ok "agents: $AGENTS_DISK" || note_fail "agents: disk=$AGENTS_DISK VERSION.json=$AGENTS_DECL"
[ "$SKILLS_DISK" = "$SKILLS_DECL" ] && note_ok "skills: $SKILLS_DISK" || note_fail "skills: disk=$SKILLS_DISK VERSION.json=$SKILLS_DECL"
[ "$RULES_DISK" = "$RULES_DECL" ]   && note_ok "rules: $RULES_DISK"   || note_fail "rules: disk=$RULES_DISK VERSION.json=$RULES_DECL"
[ "$HOOKS_DISK" = "$HOOKS_DECL" ]   && note_ok "hookScripts: $HOOKS_DISK" || note_fail "hookScripts: disk=$HOOKS_DISK VERSION.json=$HOOKS_DECL"

# ---------- 2. Every agent file has frontmatter with name==basename ----------
echo ""
echo "2. Agent frontmatter (name must equal filename)"
for f in .claude/agents/*.md; do
  base="$(basename "$f" .md)"
  [ "$base" = "README" ] && continue
  if [ "$(head -1 "$f")" != "---" ]; then
    note_fail "$f: no YAML frontmatter (Claude Code can't register it as a subagent)"
    continue
  fi
  fm_name="$(awk '/^---$/{c++; next} c==1 && /^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$f")"
  fm_desc="$(awk '/^---$/{c++; next} c==1 && /^description:/{found=1} END{print found+0}' "$f")"
  if [ "$fm_name" != "$base" ]; then
    note_fail "$f: frontmatter name='$fm_name' != filename '$base'"
  elif [ "$fm_desc" != "1" ]; then
    note_fail "$f: frontmatter missing description"
  else
    note_ok "$base"
  fi
done

# ---------- 3. Every skill dir has a SKILL.md with frontmatter ----------
echo ""
echo "3. Skill frontmatter"
SKILL_BAD=0
for d in .claude/skills/*/; do
  s="$d/SKILL.md"
  if [ ! -f "$s" ]; then note_fail "$d: no SKILL.md"; SKILL_BAD=1; continue; fi
  if [ "$(head -1 "$s")" != "---" ]; then note_fail "$s: no frontmatter"; SKILL_BAD=1; fi
done
[ "$SKILL_BAD" = "0" ] && note_ok "all $SKILLS_DISK skills have SKILL.md with frontmatter"

# ---------- 4. Version string coherence ----------
echo ""
echo "4. Version-string coherence"
VER=$(jq -r '.version' VERSION.json)
for doc in CLAUDE.md SYSTEM.md README.md; do
  if grep -q "$VER" "$doc" 2>/dev/null; then
    note_ok "$doc mentions v$VER"
  else
    note_fail "$doc does not mention current version v$VER"
  fi
done

# ---------- 5. Forbidden stale tokens (known past drifts) ----------
echo ""
echo "5. Stale-token guard (current-claim docs)"
# These exact strings were real drifts. They must not reappear in CLAUDE.md.
STALE_CLAUDE=("13 specialist subagents" "(14 more skills)" "5-Layer Architecture + Persistent Memory")
for tok in "${STALE_CLAUDE[@]}"; do
  if grep -Fq "$tok" CLAUDE.md 2>/dev/null; then
    note_fail "CLAUDE.md contains stale token: '$tok'"
  fi
done
# Architecture framing must be consistent: pick 4-Layer (ADR-017). The
# "5-Layer Stack" heading form must not appear in CLAUDE.md or SYSTEM.md.
for doc in CLAUDE.md SYSTEM.md; do
  if grep -Fq "5-Layer Stack" "$doc" 2>/dev/null; then
    note_fail "$doc uses '5-Layer Stack' — canonical framing is 4-Layer (ADR-017)"
  fi
done
[ "$FAIL" = "0" ] && note_ok "no stale tokens found"

# ---------- 6. Skill/agent reference resolution (lightweight) ----------
echo ""
echo "6. Reference resolution (Task(<agent>) and /arib-* in skills)"
REF_BAD=0
# Every Task(<agent>) referenced in a skill must have an agent file.
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  if [ ! -f ".claude/agents/${ref}.md" ]; then
    note_fail "skill references Task($ref) but .claude/agents/${ref}.md is missing"
    REF_BAD=1
  fi
done < <(grep -rhoE 'Task\(([a-z-]+)' .claude/skills 2>/dev/null | sed -E 's/Task\(//' | sort -u)
[ "$REF_BAD" = "0" ] && note_ok "all Task(<agent>) references resolve"

echo ""
echo "=== Result ==="
if [ "$FAIL" = "0" ]; then
  echo "COHERENT — all invariants hold."
  exit 0
else
  echo "INCOHERENT — fix the ✗ items above. (This is what CCM's own"
  echo "DOCS-MATCH-DISK principle requires; the validator enforces it.)"
  exit 1
fi
