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

# Catalog drift guard (v3.20.0, ADR-035): the /arib-* skill table moved out of
# CLAUDE.md §4 into reference/SKILLS_CATALOG.md (on-demand). Since it left the
# always-on view where drift is obvious, gate its row count against VERSION.json.
if [ -f reference/SKILLS_CATALOG.md ]; then
  CATALOG_ROWS=$(grep -cE '^\| /arib-' reference/SKILLS_CATALOG.md 2>/dev/null || true)
  [ "$CATALOG_ROWS" = "$SKILLS_DECL" ] && note_ok "SKILLS_CATALOG.md rows: $CATALOG_ROWS" \
    || note_fail "SKILLS_CATALOG.md rows=$CATALOG_ROWS != VERSION.json skills=$SKILLS_DECL"
else
  note_fail "reference/SKILLS_CATALOG.md missing (the canonical /arib-* catalog, ADR-035)"
fi

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
echo "3. Skill frontmatter (name==dir + description; v3.8.1 skill-lint)"
SKILL_BAD=0
for d in .claude/skills/*/; do
  dname="$(basename "$d")"
  s="$d/SKILL.md"
  if [ ! -f "$s" ]; then note_fail "$dname: no SKILL.md"; SKILL_BAD=1; continue; fi
  if [ "$(head -1 "$s")" != "---" ]; then note_fail "$dname: no frontmatter"; SKILL_BAD=1; continue; fi
  fm_name="$(awk 'NR>1 && /^---$/{exit} /^name:/{sub(/^name:[[:space:]]*/,"");print;exit}' "$s")"
  fm_desc="$(awk 'NR>1 && /^---$/{exit} /^description:/{found=1} END{print found+0}' "$s")"
  if [ "$fm_name" != "$dname" ]; then
    note_fail "$dname: frontmatter name='$fm_name' != dir (skills with wrong/missing name risk silent non-discovery)"; SKILL_BAD=1
  elif [ "$fm_desc" != "1" ]; then
    note_fail "$dname: frontmatter missing description"; SKILL_BAD=1
  fi
done
[ "$SKILL_BAD" = "0" ] && note_ok "all $SKILLS_DISK skills have frontmatter with name==dir + description"

# Advisory skill-hygiene: duplicate section headings within a skill (the
# "Failure modes x2" class from the v3.8 audit). WARN, does not fail CI.
echo ""
echo "3b. Skill hygiene (advisory — duplicate section headings)"
HYG=0
for d in .claude/skills/*/; do
  dname="$(basename "$d")"; s="$d/SKILL.md"
  [ -f "$s" ] || continue
  dups="$(grep -E '^## ' "$s" | sort | uniq -d | sed 's/^## //')"
  if [ -n "$dups" ]; then
    while IFS= read -r h; do [ -n "$h" ] && printf '  ~ %s: duplicate section "## %s"\n' "$dname" "$h"; done <<< "$dups"
    HYG=1
  fi
done
[ "$HYG" = "0" ] && note_ok "no duplicate section headings"

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
# License-drift guard (v4.1.1, ADR-038): since v4.0.0 the current license is
# PolyForm Noncommercial, not MIT. Flag a license-FIELD declaration of MIT (the
# identity-table "| **License** | MIT |" form, or "License: MIT") in a current-facing
# doc. Legacy ≤3.20.0 references that mention MIT always carry a qualifier (3.20 /
# earlier / ≤ / remain / those versions) and are exempt; the dependency-scanner's
# educational "MIT=safe" risk table is NOT a License field, so it does not match.
for doc in CLAUDE.md SYSTEM.md README.md Training/01-SYSTEM-OVERVIEW.md; do
  [ -f "$doc" ] || continue
  if grep -nE "\*\*License\*\*[^|]*\|[^|]*\bMIT\b|License:[[:space:]]*MIT" "$doc" 2>/dev/null \
       | grep -viE "3\.20|earlier|legacy|≤|<=|remain|stay|prior|LICENSE-MIT|those versions" \
       | grep -q .; then
    note_fail "$doc declares MIT as a current license field — v4.0.0+ is PolyForm Noncommercial (qualify legacy ≤3.20.0 refs)"
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
echo "7. Template-hashes manifest (drift classifier)"
MANIFEST="reference/template-hashes.json"
if [[ ! -f "$MANIFEST" ]]; then
  note_fail "$MANIFEST missing — run scripts/gen-template-hashes.sh (drift-detect depends on it)"
else
  MAN_VER="$(jq -r '.version // "?"' "$MANIFEST")"
  if [[ "$MAN_VER" == "$VER" ]]; then
    note_ok "manifest version matches ($MAN_VER), $(jq '.files | length' "$MANIFEST") files"
  else
    note_fail "manifest version $MAN_VER != VERSION.json $VER — regenerate with scripts/gen-template-hashes.sh"
  fi
fi

echo ""
echo "8. Memory freshness + integrity (v3.13.0, ADR-028)"
# The memory system preaches "a session without memory updates never happened"
# but nothing enforced it — the always-on handoff files silently froze at the
# v1.0 bootstrap. This gate makes freshness a CI invariant, like docs-match-disk.
#
# a. project_status.md must name the current version (it is the "current state"
#    file). Fixed-string match so the version dots aren't treated as wildcards.
if grep -qF "$VER" memory/project_status.md 2>/dev/null; then
  note_ok "project_status.md names current v$VER"
else
  note_fail "project_status.md does not name current v$VER (stale — it loads every session)"
fi
# b. session_notes.md must not have reverted to the v1.0 bootstrap handoff.
if grep -Eq 'Bootstrap Session|Methodology v1\.0' memory/session_notes.md 2>/dev/null; then
  note_fail "session_notes.md still carries the v1.0 bootstrap handoff — backfill it (it is always-on)"
else
  note_ok "session_notes.md is past the bootstrap handoff"
fi
# c. The newest handoff ENTRY must be current — not just the version appearing
#    somewhere (the freshness-header boilerplate would self-satisfy that). Anchor
#    to a `## Session:` heading carrying the current major.minor (dots escaped).
VER_MM="$(printf '%s' "$VER" | cut -d. -f1-2)"
VER_MM_RE="$(printf '%s' "$VER_MM" | sed 's/\./\\./g')"
if grep -Eq "^## Session:.*${VER_MM_RE}" memory/session_notes.md 2>/dev/null; then
  note_ok "session_notes.md has a current-line session heading (v$VER_MM)"
else
  note_fail "session_notes.md has no '## Session: … v$VER_MM' heading — update the handoff at session end (it is always-on)"
fi
# d. no unresolved git conflict markers in any memory file (bare divider too).
if grep -rEn '^(<<<<<<< |={7}$|>{7} )' memory/*.md >/dev/null 2>&1; then
  note_fail "memory/*.md contains git conflict markers — resolve before committing"
else
  note_ok "no conflict markers in memory/*.md"
fi
# e. no duplicate ADR numbers in the decision record (append-only must not collide).
DUP_ADR="$(grep -hoE '^# ADR-[0-9]+' architecture/DECISIONS.md 2>/dev/null | sort | uniq -d)"
if [ -n "$DUP_ADR" ]; then
  note_fail "duplicate ADR heading(s) in DECISIONS.md: $(echo "$DUP_ADR" | tr '\n' ' ')"
else
  note_ok "no duplicate ADR numbers"
fi

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
