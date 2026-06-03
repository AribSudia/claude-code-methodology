---
name: arib-memory-search
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

## Examples

### Example 1 — Architecture decision, present in markdown

```text
User: /arib-memory-search "why did we drop kafka"

Layer 1 (claude-mem): not configured (CLAUDE_MEM_API_KEY unset).
Layer 2 (grep): 3 hits.
  - memory/architecture_decisions.md:142
    "ADR-007: dropped kafka in favor of redis streams. Headcount didn't
    justify kafka ops cost. Confirmed redis caps at 1M msg/day."
  - memory/change_log.md:88
    "kafka producer code removed in PR #421"
  - memory/bugs_and_fixes.md:203
    "redis-streams: fixed consumer-group rebalance bug (2026-04-12)"

Answer: kafka was dropped in ADR-007 (memory/architecture_decisions.md:142)
because headcount didn't justify the ops cost. Redis streams replaced
it; production cap was 1M msg/day at decision time. Producer code
removed in change_log.md:88. One known issue post-migration: rebalance
bug fixed 2026-04-12 (bugs_and_fixes.md:203).
```

### Example 2 — Decision present semantically but not lexically

```text
User: /arib-memory-search "should we use a queue"

Layer 1 (claude-mem): 2 results, scores 0.87 and 0.81.
  - session-2026-04-22 — "ADR-007: dropped kafka..." (score 0.87)
  - session-2026-04-29 — "considered SQS for X but went with redis..."

Layer 2 (grep): 0 hits for "queue".

Answer: I found 2 relevant decisions in semantic recall (cite session
ids), even though grep on "queue" returned nothing — the discussion
was about kafka and SQS specifically. ADR-007 is the most relevant.
Layer-2 grep miss is expected: the decision is paraphrased, not
literal.

Note to user: confirms the value of the semantic layer for paraphrased
recall. Without claude-mem configured, this query would have returned
"no hits".
```

### Example 3 — Both layers empty

```text
User: /arib-memory-search "graphql federation strategy"

Layer 1: 0 results above 0.5 threshold.
Layer 2: 0 hits.

Answer: No prior decision recorded about graphql federation. If you're
about to make a decision, consider:
- Adding an ADR to architecture/DECISIONS.md
- Recording the decision in memory/architecture_decisions.md after
  the session

Do NOT fabricate prior context. Empty is empty.
```

## Decision tree

```
Query received
    |
    v
[Is CLAUDE_MEM_API_KEY set AND MCP responding?]
    |
    +-- yes --> Layer 1 query (vector search, top-5 by score)
    |              |
    |              +--> Always also run Layer 2 (grep) for cross-check
    |
    +-- no  --> Layer 2 only (grep memory/*.md)
    |
    v
[Layer 1 and Layer 2 agree?]
    |
    +-- yes --> Report unified answer with both sets of citations
    +-- no  --> Report both, flag the divergence to the user
                Layer 1 may have a record the export hasn't captured
                yet, or Layer 2 may show a more recent markdown edit
                the MCP hasn't re-indexed.
    |
    v
[Both empty?]
    |
    +-- yes --> Say so explicitly. Suggest creating a memory record
    |          if the user is about to make a decision worth preserving.
    +-- no  --> Cite every claim. No citation = drop the claim.
```

## Edge cases

- **Stale MCP index.** If `memory/semantic_export.md` is newer than the
  MCP's last indexed timestamp, Layer 2 will see records Layer 1
  doesn't. Report from both; flag the staleness to the user; suggest
  running `scripts/memory-export.sh` and reindexing.

- **Conflicting records (same fact, different decisions).** Memory is
  append-only — older decisions can be superseded but are never edited.
  If a query returns conflicting facts, sort by date and report the
  newest as authoritative; mention the older ones for context.

- **Query is too vague.** "what did we decide" — refuse and ask for
  refinement. Don't dump 100 hits.

- **Query is a question about CCM itself, not the project.** This skill
  searches `memory/`, which is project state. Methodology questions
  belong in CLAUDE.md, Training/, or `reference/`. Redirect.

- **Regulated-data project with MCP disabled.** This is the intended
  configuration. Layer 2 alone is the correct answer; do not warn
  about Layer 1 absence.

## Failure modes

- **claude-mem MCP timeout (>3s):** report Layer 2 results only; note
  the MCP failure. Never wait indefinitely.
- **claude-mem returns malformed response:** treat as timeout.
- **`memory/` files missing or corrupted:** report what you can; flag
  to the user that memory state needs attention before proceeding with
  decisions.
- **Grep returns 1000+ hits:** narrow the query before reporting.
  Suggest a tighter phrase to the user.
- **Citation rule violation:** if you cannot find a source for a claim,
  drop the claim rather than fabricate.

## Related

- `scripts/memory-export.sh` — exports the live MCP into `memory/semantic_export.md`.
- `memory/MEMORY_PROTOCOL.md` — full protocol for memory file format and lifecycle.
- `.mcp.json` — `claude-mem` server stub.
- `.claude/skills/arib-session-start/SKILL.md` — runs at session start; reads `memory/*.md` to seed context.
- `.claude/skills/arib-session-end/SKILL.md` — writes session_notes.md and other memory files at session end. Memory grows from there.
