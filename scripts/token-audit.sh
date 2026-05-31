#!/usr/bin/env bash
# scripts/token-audit.sh
# Estimates the token cost of CCM scaffolding loaded on session start.
#
# What we count: every file listed under .claude/settings.json -> "context.include",
# plus CLAUDE.md, plus the always-loaded path-scoped rules under .claude/rules/.
#
# What we DO NOT count: skill bodies (.claude/skills/*/SKILL.md). Skills are
# documented as lazy-loaded — full body only enters context on slash-command
# invocation. If that ever stops being true, this script will under-report.
#
# Token estimate: ~4 chars/token for English markdown. This is a heuristic, not
# tokenizer-accurate. Treat the number as a budget signal, not an exact count.
#
# Target for v3.2 "Honest": <8,000 tokens on session start.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "${REPO_ROOT}"

CHARS_PER_TOKEN=4
TARGET_TOKENS=8000

declare -a FILES=()

# 1. CLAUDE.md (always loaded).
[[ -f CLAUDE.md ]] && FILES+=("CLAUDE.md")

# 2. context.include from .claude/settings.json
if [[ -f .claude/settings.json ]] && command -v jq >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -n "$f" ]] && [[ -f "$f" ]] && FILES+=("$f")
  done < <(jq -r '.context.include[]? // empty' .claude/settings.json 2>/dev/null)
fi

# 3. Path-scoped rules (.claude/rules/*.md) are NOT always-on — they load
# only when the working file path matches the rule's scope. Counting them
# as session-start cost was a v3.6-and-earlier over-count (~5K tokens). They
# are reported separately below, not in the always-on headline. (ADR-016.)
RULE_FILES=()
if [[ -d .claude/rules ]]; then
  while IFS= read -r f; do
    RULE_FILES+=("$f")
  done < <(find .claude/rules -maxdepth 1 -type f -name '*.md' 2>/dev/null)
fi

# 4. Deduplicate, preserving order. macOS bash 3.2 has no associative arrays,
# so we use a plain string of seen paths separated by null-ish delimiters.
SEEN_LIST=$'\n'
declare -a UNIQUE_FILES=()
for f in "${FILES[@]}"; do
  if [[ "$SEEN_LIST" != *$'\n'"$f"$'\n'* ]]; then
    SEEN_LIST="${SEEN_LIST}${f}"$'\n'
    UNIQUE_FILES+=("$f")
  fi
done
FILES=("${UNIQUE_FILES[@]}")

# 5. Compute totals.
TOTAL_CHARS=0
TOTAL_LINES=0

printf '%-50s %10s %10s %10s\n' "FILE" "LINES" "CHARS" "~TOKENS"
printf '%s\n' "------------------------------------------------------------------------------------"

for f in "${FILES[@]}"; do
  [[ ! -f "$f" ]] && continue
  LINES=$(wc -l < "$f" | tr -d ' ')
  CHARS=$(wc -c < "$f" | tr -d ' ')
  TOKENS=$(( CHARS / CHARS_PER_TOKEN ))
  TOTAL_CHARS=$(( TOTAL_CHARS + CHARS ))
  TOTAL_LINES=$(( TOTAL_LINES + LINES ))
  printf '%-50s %10d %10d %10d\n' "${f:0:50}" "$LINES" "$CHARS" "$TOKENS"
done

TOTAL_TOKENS=$(( TOTAL_CHARS / CHARS_PER_TOKEN ))

printf '%s\n' "------------------------------------------------------------------------------------"
printf '%-50s %10d %10d %10d\n' "ALWAYS-ON TOTAL" "$TOTAL_LINES" "$TOTAL_CHARS" "$TOTAL_TOKENS"

# Path-scoped rules — loaded on demand, NOT at session start.
if (( ${#RULE_FILES[@]} > 0 )); then
  RULE_CHARS=0; RULE_LINES=0
  printf '\n%s\n' "Path-scoped rules (.claude/rules/) — loaded ON DEMAND, not counted above:"
  for f in "${RULE_FILES[@]}"; do
    [[ ! -f "$f" ]] && continue
    L=$(wc -l < "$f" | tr -d ' '); C=$(wc -c < "$f" | tr -d ' ')
    RULE_CHARS=$(( RULE_CHARS + C )); RULE_LINES=$(( RULE_LINES + L ))
    printf '  %-48s %10d %10d %10d\n' "${f#.claude/rules/}" "$L" "$C" "$(( C / CHARS_PER_TOKEN ))"
  done
  printf '  %-48s %10d %10d %10d\n' "(path-scoped subtotal)" "$RULE_LINES" "$RULE_CHARS" "$(( RULE_CHARS / CHARS_PER_TOKEN ))"
fi

printf '\n'
printf 'Headline = ALWAYS-ON TOTAL (what loads on every session start).\n'
printf 'Target on session start: <%d tokens.\n' "$TARGET_TOKENS"

if (( TOTAL_TOKENS > TARGET_TOKENS )); then
  printf 'Result:  OVER BUDGET by %d tokens.\n' "$(( TOTAL_TOKENS - TARGET_TOKENS ))"
  printf 'Action:  trim the largest file above, or move it from context.include\n'
  printf '         to a path-scoped or lazy-loaded location.\n'
  exit 1
else
  printf 'Result:  UNDER BUDGET by %d tokens.\n' "$(( TARGET_TOKENS - TOTAL_TOKENS ))"
  exit 0
fi
