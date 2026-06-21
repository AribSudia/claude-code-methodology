# Code Graph Report

> **Not built yet in this repo.** This is the seed. The code-graph is a *native,
> lightweight import graph* (ADR-034) — generated on demand by `/arib-graph build`
> (`scripts/build-code-graph.sh`), not committed runtime state. CCM itself is a
> methodology repo (markdown + shell), so its graph is empty; in a downstream
> TS/JS/Python project, `build` populates this report with file/edge counts,
> god-node candidates (most-imported), and the busiest importers.

- Files: 0 (run `/arib-graph build`)
- Import edges: 0

Loaded **on demand only** — nothing here is always-on (the 8K session budget is
untouched). Query the built graph with `/arib-graph query <entity>`.
