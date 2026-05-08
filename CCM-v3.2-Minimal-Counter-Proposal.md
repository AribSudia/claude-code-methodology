# CCM v3.2 "Honest" — Minimal Counter-Proposal

**Target repository:** `AribSudia/claude-code-methodology`
**Current version:** v3.1.0 "Deep Skills"
**Proposed version:** v3.2.0 "Honest"
**Author:** Abdullah Alzahrani (maintainer)
**Date:** 2026-05-08
**Document type:** Counter-proposal to `CCM-v3.2-Enforced-Proposal.md`

---

## Why this document exists

A separate proposal (`CCM-v3.2-Enforced-Proposal.md`) recommends 11 additions across enforcement, parallelism, hybrid memory, real I/O transport, deep-audit, wave delivery, MENA compliance, design system, TestSprite, autonomy mode, and token discipline.

That proposal is well-researched, but as the maintainer of this repo I'm rejecting most of it. The reasoning:

- **Marketing fix is cheaper than scope expansion.** Six of the eleven proposals exist to close the gap between the README's "AI Development Operating System" framing and what the repo actually delivers. Rewriting the README closes that gap in one PR; building an OS does not.
- **Vendor pull-in.** Claude Mem, TestSprite, CoWork, n8n-MCP, Composio, SuperClaude. Each defensible alone — together a stack migration. CCM's value is being self-contained markdown + bash. Don't trade that.
- **Roadmap fit.** Wave delivery (#6), MENA compliance (#7), autonomy mode (#10) are valuable in someone else's production stack. They are scope creep here until a real project demands them.
- **One claim is non-negotiable.** `hooks/HOOKS_PROTOCOL.md` documents an enforcement layer that doesn't exist on disk. Anyone who reads the README, then runs `ls .claude/hooks/`, sees the gap immediately. That's the single biggest credibility risk and it gets fixed first.

This counter-proposal ships **three items** instead of eleven. The aim: docs match reality, marketing matches engineering, no new dependencies.

---

## What ships in v3.2 "Honest"

### Item A — Hooks enforcement (adopt original Item #1, with revisions)

Adopt the patch in §7 of the original proposal, with these changes before merge:

1. **Drop the color-literal hook** (lines 607–616). It will false-positive on legitimate token files, syntax-highlighting libraries, generated code, and tests. CCM is methodology-agnostic — pinning the design system to Tailwind via a hook is overreach. Belongs in a per-project hook, not the repo's baseline.
2. **Fix `stop.sh` git math.** `git diff HEAD~N` where `N=COMMITS_THIS_SESSION` fails on first commit, on rebases, and when the branch is shallower than `N`. Replace with `git diff --name-only ORIG_HEAD..HEAD` guarded by `ORIG_HEAD` existence, or just count files staged at session start vs end.
3. **Tighten secret regex review.** The `sk-[a-zA-Z0-9]{32,}` pattern matches lots of non-secrets (commit hashes, tokens in test fixtures, hex strings). Add an allowlist for `*.test.*`, `*.spec.*`, `tests/`, `__fixtures__/`.
4. **The PreToolUse `git commit` matcher in §836** uses `$CLAUDE_TOOL_INPUT`. Confirm against current Claude Code docs that this env var is the right surface — if not, route through a wrapper script that reads the JSON payload via `jq`.
5. **CoWork webhook is opt-in only.** No defaults. Document that the variable is empty by default and the hook is a no-op without it.
6. **Don't gitignore `io/ledger/`.** The ledger is the audit trail; gitignoring it defeats the purpose. Gitignore only `io/hook-logs/` (high-volume) and rotate ledgers (e.g. keep last 30 days committed).

**Rationale:** the enforcement layer is the one critical fix. Everything else in this counter-proposal depends on it landing first, because every other "this is enforced" claim in CCM is honor-system until hooks exist.

**Outcome:** advisory rules become enforced rules. `hooks/HOOKS_PROTOCOL.md` stops being aspirational.

---

### Item B — Token discipline + README rewrite (adopt original Item #11, expand)

Two parts.

**B1. Lazy skill loading.**
- Each skill ships a `SUMMARY.md` (≤20 lines) loaded on session start.
- Full `SKILL.md` loads only on slash-command invocation.
- Add `scripts/token-audit.sh` — measures tokens consumed by CCM scaffolding on a cold session start. Target: <8K tokens. Commit the audit number into the README so future PRs can be measured against it.

**B2. README rewrite — drop the "Operating System" framing.**

This is the larger change. The current README leads with:
- "AI Development Operating System"
- "58,000+ lines"
- "7,393 lines of deep skills"

Rewrite to lead with:
- **What it is:** an opinionated methodology + skill pack for Claude Code.
- **What you get:** 16 branded skills, 14 agents, path-scoped rules, a 5-mode bootstrap, hooks enforcement.
- **What it isn't:** a runtime, a kernel, an orchestrator. It's a convention layer.
- **Token cost on session start:** measured number from `token-audit.sh`.

Lines of markdown is not a quality metric. Smaller, sharper README beats bigger one every time.

**Outcome:** docs match reality. Reviewers stop bouncing on the README/disk gap. Token cost becomes a bragging point instead of a hidden cost.

---

### Item C — Agent parallelism as documentation only (subset of original Item #2)

Adopt only the documentation half of original Item #2.

- Add `architecture/AGENT_ARCHITECTURE.md` listing each of the 14 agents with:
  - Its trigger keywords
  - Whether it's safe to dispatch in parallel via the existing Task tool
  - What state it reads/writes (so conflicts are visible)
- Update `arib-dev-review` skill to dispatch reviewer + security + tester via parallel Task tool calls in a single message (this works *today* with no env vars or new infrastructure).

**Skip these parts of the original Item #2:**
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — experimental flag, no stability guarantee, externalizes risk to users.
- T3 orchestration via Composio / n8n-MCP — vendor pull-in, out of scope.
- New `arib-orchestrate` skill — premature.

**Outcome:** review loops actually parallelize using primitives that already exist. No new flags, no new MCP servers, no new dependencies.

---

## What's deliberately NOT shipping in v3.2

| # | Original proposal | Why deferred |
|---|-------------------|--------------|
| #3 | Hybrid memory (Claude Mem MCP) | Vendor pull-in. Markdown grep is fine until a real session count makes it not. Revisit when CCM has users hitting the wall. |
| #4 | CoWork I/O transport | Vendor pull-in + the `io/` polling layer is fine for the workloads CCM actually serves. |
| #5 | `/arib-deep-audit` (21 sections) | The existing `arib-check-*` skills cover this in aggregate. Bundling into one mega-skill adds rope, not value. |
| #6 | Wave delivery overlay | This is the proposal author's production pattern. Adopt only if CCM ships a real wave-delivered project. |
| #7 | MENA compliance layer | Adopt when there's a Saudi institutional project consuming CCM. Don't pre-build for hypothetical users. |
| #8 | Design system as architecture | Same. Methodology-agnostic > opinionated. |
| #9 | TestSprite integration | Vendor pull-in. The phrase "deploy gates have teeth" is true; TestSprite isn't the only tooth. |
| #10 | Autonomy mode protocol | Premature. Document only when someone is actually running long autonomous sessions on CCM. |

These can come back later. Shipping a smaller, accurate v3.2 buys the credibility to ship them when they're justified.

---

## Sequencing

Three PRs, each independently mergeable.

1. **PR #1 — Item A (hooks enforcement, revised).** Land first. Closes the docs/disk gap.
2. **PR #2 — Item B (token discipline + README rewrite).** Quick win. Resets external positioning.
3. **PR #3 — Item C (agent architecture doc + parallel review skill).** Small, useful, no new deps.

Total estimated diff: ~1,200 lines bash + markdown, zero new external dependencies.

After all three land, v3.2 ships as **"Honest"** — rules become enforceable, docs match the disk, marketing matches engineering. No promises CCM doesn't keep.

---

## On the original proposal's §10 ("Fallback Strategy")

The original proposal's §10 outlines forking and rebranding the project to `pbm-*` if upstream is inactive within 7 days. Recording it here for transparency:

- I'm the maintainer; I'm responding within 7 days; the fork scenario is moot for this proposal.
- The MIT license permits forks; that's fine. Attribution is the only obligation, and §10 commits to it.
- I'm choosing this counter-proposal over the original because it serves *this* repo's positioning, not the author's production stack.

No hard feelings — the diagnosis work in the original was useful, and Item #1 (hooks) is genuinely the right call. The rest is scope I don't want.

---

## Codename

v3.0 "Aligned" → v3.1 "Deep Skills" → v3.2 **"Honest"**.

The codename is the entire point: docs, marketing, and disk align. No more enforcement claims for hooks that don't exist. No more "Operating System" framing for a markdown convention pack. No more bragging about line count when token count is the actual constraint.

---

**Document end.**
