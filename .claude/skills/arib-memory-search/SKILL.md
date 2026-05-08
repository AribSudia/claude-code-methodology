---
argument-hint: "<search query>"
description: "Memory | Semantic search across project memory — claude-mem MCP with grep fallback"
---

# Memory Search — /arib-memory-search

## Overview

This skill answers "what did we decide / discover / document about X?" across
the project's persistent memory.

It uses a **two-layer hybrid**:

- **Layer 1 (live, semantic):** the `claude-mem` MCP if configured. Vector
  search across all session memory; returns the top semantically relevant
  records regardless of which markdown file they live in.
- **Layer 2 (audit, lexical):** `grep` across `memory/*.md`. Always available.
  Finds exact strings and known phrases.

The skill prefers Layer 1 when available and falls back to Layer 2 otherwise.
Both layers are queried for high-stakes lookups so the answer is cross-checked.

## When to Use

- Before re-debating an architecture decision: search memory first.
- When debugging a familiar-looking bug: it may already be in `bugs_and_fixes.md`.
- When onboarding to a new area of the codebase.
- When a session is about to make a constraint-related call and the rule may
  be recorded but not in `CONSTRAINTS.md`.

## Usage

```bash
/arib-memory-search "auth token rotation"
/arib-memory-search "why did we drop kafka"
/arib-memory-search "migration that broke staging"
```

## Protocol

### Step 1 — Detect the live layer

```text
If `CLAUDE_MEM_API_KEY` is set AND the claude-mem MCP responds → Layer 1 active.
Otherwise → Layer 2 only.
```

### Step 2 — Query Layer 1 (when active)

Call the MCP's semantic search with the user's query. Expect ranked results
with a relevance score and the source session id.

```text
Top results:
  - [score 0.91] session 2026-04-19 — "decided to drop kafka in favor of
    redis streams because the team headcount didn't justify kafka ops cost"
  - [score 0.83] session 2026-04-22 — "kafka mention: confirmed redis streams
    cap at 1M msg/day; revisit at 800K"
```

### Step 3 — Query Layer 2 always

Run a grep across `memory/*.md` for the literal query string and the 2–3
strongest keywords from it.

```bash
grep -rni --include='*.md' "<query>" memory/ | head -20
```

### Step 4 — Reconcile

If the two layers agree: report the unified answer with citations to both.
If they disagree: report both and flag the divergence — the live layer may
have a record the export hasn't captured yet, or vice versa.

If neither layer has a hit: say so explicitly. Do not fabricate.

### Step 5 — Cite, always

Every claim in the answer must point to either:
- A claude-mem session id (e.g. `session-2026-04-19T13:22:01Z`)
- A markdown file + line number (e.g. `memory/architecture_decisions.md:142`)

No citation = do not include the claim.

## Failure modes

- **MCP times out:** report Layer 2 results only, note the MCP failure.
- **Grep returns 1000+ hits:** narrow the query before reporting; ask the user
  for a tighter phrase.
- **Both layers empty:** say so. Suggest adding a memory record now if the
  user is making a decision worth preserving.

## Related

- `scripts/memory-export.sh` — exports the live MCP into `memory/semantic_export.md`.
- `memory/MEMORY_PROTOCOL.md` — full protocol for memory file format and lifecycle.
- `.mcp.json` — `claude-mem` server stub.
