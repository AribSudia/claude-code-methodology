---
name: arib-graph
argument-hint: "[build | refresh | query <entity>]"
description: "Memory | Code-graph subsystem — a native lightweight IMPORT graph (which file imports which, god-node candidates) built with ripgrep/grep, so a large monorepo can be navigated by structure instead of re-grepping every session. build/refresh/query. Honest scope: structural import graph, NOT semantic (no call-graph/type resolution); no Graphify dependency. Loads ON DEMAND only (zero always-on tokens). ADR-034."
---

# /arib-graph — the code-graph subsystem

CCM's memory remembers *decisions and state*; the code-graph remembers *structure*. It's a
**native, lightweight import graph** — built with ripgrep/grep, git-diffable JSON — so on a
large monorepo you navigate by "what imports `QoLService`?" instead of grepping the whole
tree every session.

> **Honest scope (ADR-034):** this is an **import/symbol graph** (file → file edges +
> in/out degree), **NOT** Graphify's semantic analysis — no call-graph, no type
> resolution. It is dependency-free (rg preferred, grep fallback) and loads **on demand
> only** — nothing about it is always-on, so the 8K session budget is untouched.

## Files (in `memory/code-graph/`)

| File | Committed? | What |
|------|-----------|------|
| `graph.json` | **No** (gitignored) | the generated graph — nodes (files) + edges (imports) + stats |
| `GRAPH_REPORT.md` | Yes (seed) | readable summary — counts, god-node candidates, busiest importers |
| `graph-manifest.json` | Yes (seed) | freshness — `built`, `last_build_commit`, `file_count`, `stale` |

## Modes

### `build`
Full graph generation — run once per repo, or after a major refactor:
```bash
scripts/build-code-graph.sh            # whole repo
scripts/build-code-graph.sh --root apps/api --max 8000
```
Writes `graph.json` + refreshes `GRAPH_REPORT.md` + `graph-manifest.json`. On CCM itself
(markdown + shell) the graph is empty — that's honest; it's meant for downstream
TS/JS/Python/Go codebases.

### `refresh`
Re-run `build` to pick up changes since the last build commit (the MVP refresh is a full
rebuild — cheap on rg). Updates the manifest's `last_build_commit` so staleness resets.

### `query <entity>`
Ask the built graph directly, e.g. "what imports `b`?" — read `graph.json` and filter:
```bash
jq --arg e "<entity>" '.edges | map(select(.to|test($e))) | map(.from) | unique' memory/code-graph/graph.json   # importers of <entity>
jq --arg f "<file>"   '.edges | map(select(.from==$f)) | map(.to)'              memory/code-graph/graph.json   # what <file> imports
```
If the graph isn't built (`graph-manifest.json` `built:false`), say so and offer `build`.

## How it surfaces (advisory only)

- **`graph-consult.sh`** (PreToolUse, advisory exit-0) — before a `Grep`/`Glob` search,
  if the graph exists it surfaces a one-line structural hint pointing at `/arib-graph
  query`; **pure no-op when the graph is absent**, and it **never blocks** (the blocking
  gate is `pre-tool-use.sh`).
- **`/arib-session-start`** — when `graph-manifest.json` is stale (or missing in a code
  project), it *recommends* `/arib-graph refresh`; it never auto-runs (autonomy guard).

## Anti-patterns

Claiming semantic/call-graph capability (it's an import graph) · committing the generated
`graph.json` (it's gitignored, per-project) · adding a graph digest to always-on context
(it loads on demand only) · the consult hook ever blocking (advisory exit-0 only).
