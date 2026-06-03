#!/usr/bin/env bash
# scripts/memory-export.sh
# Item #3 — exports the semantic memory layer (claude-mem MCP) into the
# git-versioned markdown audit trail at memory/. Runs nightly via cron, or on
# the Stop hook, or on demand.
#
# Contract: when claude-mem is configured, this script appends a dated section
# to memory/semantic_export.md with whatever the MCP returns for the project.
# When it is not configured, the script is a no-op (exits 0 with a notice).
#
# This is the "audit trail" half of the hybrid model:
#   Layer 1 (live):   claude-mem MCP, queried mid-session via /arib-memory-search
#   Layer 2 (audit):  memory/*.md, exported here, committed to git

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "${REPO_ROOT}"

EXPORT_FILE="memory/semantic_export.md"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 0. Ensure the referenced export file always exists with an HONEST header,
# even before any live export — so the reference is never dangling and the
# file never looks like data when it isn't.
mkdir -p memory
if [[ ! -f "$EXPORT_FILE" ]]; then
  cat > "$EXPORT_FILE" <<'HEAD'
# Semantic Memory Export

> **No live export has run yet.** This file is the markdown audit trail of the
> optional semantic memory layer (claude-mem MCP). It is populated by
> `scripts/memory-export.sh` only when claude-mem is configured and returns
> real data. Until then this header is the only content — that is expected,
> not an error. The authoritative memory is the markdown files in `memory/`.

Sections are appended chronologically once exports begin. Old sections are not
edited; if a recorded fact is later proven wrong, add a section that supersedes it.

---
HEAD
fi

# 1. Detect whether claude-mem is reachable. If not, no-op (file already seeded).
if [[ -z "${CLAUDE_MEM_API_KEY:-}" ]]; then
  echo "[memory-export] CLAUDE_MEM_API_KEY not set — skipping export (no-op). $EXPORT_FILE seeded/unchanged."
  exit 0
fi

# 2. Probe the MCP for a real dump. Returns the dump on stdout and exit 0 on
# success; on any failure returns non-zero and prints the reason to STDERR
# (never to stdout — a failure reason must NEVER be appended to the
# git-committed audit trail. Honest failure beats a polluted ledger.)
fetch_semantic_dump() {
  if ! command -v claude-mem >/dev/null 2>&1; then
    echo "[memory-export] claude-mem CLI not installed — skipping export (no-op)." >&2
    return 1
  fi
  local out
  if ! out="$(claude-mem export --project "${CLAUDE_MEM_PROJECT:-ccm}" --format markdown 2>/dev/null)"; then
    echo "[memory-export] claude-mem export failed — check CLAUDE_MEM_API_KEY/project. Last-known-good preserved." >&2
    return 1
  fi
  if [[ -z "${out// }" ]]; then
    echo "[memory-export] claude-mem returned empty — skipping append, preserving last-known-good." >&2
    return 1
  fi
  printf '%s' "$out"
}

# 3. Seed the export file with an HONEST header on first creation — one that
# states plainly that no live export has run yet (rather than a stub that
# looks like data).
mkdir -p memory
if [[ ! -f "$EXPORT_FILE" ]]; then
  cat > "$EXPORT_FILE" <<'HEAD'
# Semantic Memory Export

> **No live export has run yet.** This file is the markdown audit trail of the
> optional semantic memory layer (claude-mem MCP). It is populated by
> `scripts/memory-export.sh` only when claude-mem is configured and returns
> real data. Until then this header is the only content — that is expected,
> not an error. The authoritative memory is the markdown files in `memory/`.

Sections are appended chronologically once exports begin. Old sections are not
edited; if a recorded fact is later proven wrong, add a section that supersedes it.

---
HEAD
fi

# 4. Append ONLY on a successful real dump. On failure, skip the append so the
# audit trail keeps its last-known-good state (as MEMORY_PROTOCOL.md promises).
if DUMP="$(fetch_semantic_dump)"; then
  {
    printf '\n## Export — %s\n\n' "$TS"
    printf '%s\n' "$DUMP"
  } >> "$EXPORT_FILE"
  echo "[memory-export] appended export to $EXPORT_FILE"
else
  echo "[memory-export] no-op (see stderr above); $EXPORT_FILE unchanged."
  exit 0
fi
