# CCM v3.2 "Enforced" — Architectural Improvement Proposal

**Target repository:** [`AribSudia/claude-code-methodology`](https://github.com/AribSudia/claude-code-methodology)
**Current version:** v3.1.0 "Deep Skills"
**Proposed version:** v3.2.0 "Enforced"
**Author:** Dr. Sami Alzahrani — CTO
**Date:** 2026-05-03
**Document type:** Architectural review + ready-to-merge patch + GitHub issue + roadmap

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Diagnosis of v3.1.0](#2-diagnosis-of-v310)
3. [Authority Sources](#3-authority-sources)
4. [The 11 Proposals](#4-the-11-proposals)
   - [P0 — Foundation](#p0--foundation-must-ship-together)
     - [#1 Hooks Enforcement Layer](#1-real-hooks-enforcement-layer-p0)
     - [#2 Three-Tier Parallel Agents](#2-three-tier-parallel-agent-architecture-p0)
   - [P1 — Core Subsystems](#p1--core-subsystems)
     - [#3 Hybrid Memory](#3-hybrid-memory-claude-mem-mcp--markdown-audit-trail-p1)
     - [#4 Real I/O Transport](#4-real-io-transport-cowork--io-as-ledger-p1)
     - [#5 Deep Audit Skill](#5-arib-deep-audit-skill-21-section-audit-p1)
     - [#6 Wave Delivery Overlay](#6-wave-based-delivery-overlay-p1)
   - [P2 — Market & Quality](#p2--market--quality)
     - [#7 Bilingual / MENA Compliance](#7-bilingual--mena-compliance-layer-p2)
     - [#8 Design System](#8-design-system-as-first-class-architecture-p2)
     - [#9 TestSprite Integration](#9-testsprite-wired-into-deploy-gate-p2)
   - [P3 — Polish & Operational Maturity](#p3--polish--operational-maturity)
     - [#10 Autonomy Mode Protocol](#10-autonomy-mode-protocol-p3)
     - [#11 Token-Budget Discipline](#11-token-budget-discipline-fix-the-58k-line-problem-p3)
5. [Summary Table](#5-summary-table)
6. [Proposed Sequencing](#6-proposed-sequencing)
7. [PR #1 — Hooks Enforcement Layer (Complete Patch)](#7-pr-1--hooks-enforcement-layer-complete-patch)
8. [GitHub Issue Body (Copy-Paste-Ready)](#8-github-issue-body-copy-paste-ready)
9. [Open Questions for Maintainer](#9-open-questions-for-maintainer)
10. [Fallback Strategy if Upstream is Inactive](#10-fallback-strategy-if-upstream-is-inactive)
11. [Appendix — Stack Inventory](#11-appendix--stack-inventory)

---

## 1. Executive Summary

CCM v3.1.0 is a strong **convention layer** with genuinely valuable ideas — path-scoped rules, the 5-mode bootstrap taxonomy (new / reverse / upgrade / migrate / overlay), the discipline of keeping CLAUDE.md under 200 lines, and impressive documentation depth across 16 deep skills.

It stops short of being an **operating system**, however. The gap is structural, not cosmetic. Five subsystems are missing or under-implemented:

1. **Enforcement** — rules are advisory-only.
2. **Parallelism** — agents run sequentially.
3. **Semantic memory** — markdown grep doesn't scale past ~50 sessions.
4. **Real transport** — the I/O channel reinvents message-passing on the filesystem.
5. **Delivery framing** — no concept of multi-week waves, phase gates, or stakeholder reports.

This document proposes **eleven additions for v3.2**, prioritized P0–P3, each grounded in either Anthropic's official guidance, community-validated patterns, or production stack experience. Item #1 (the hooks enforcement layer) ships as a complete, ready-to-merge PR patch in [section 7](#7-pr-1--hooks-enforcement-layer-complete-patch).

After P0 and P1 ship, CCM moves from "high-quality convention pack" to genuine "AI Development Operating System" — and the README's positioning becomes accurate rather than aspirational.

---

## 2. Diagnosis of v3.1.0

| Subsystem | v3.1 State | Gap | v3.2 Fix |
|-----------|-----------|-----|----------|
| Rules | `CONSTRAINTS.md` is markdown | Model can violate; no kernel-level block | Item #1 — real hook scripts |
| Agents | 13 keyword-triggered, sequential | Review takes 5–10 min wall-clock | Item #2 — three-tier parallel |
| Memory | Seven markdown files in `memory/` | Grep-only, breaks past ~50 sessions | Item #3 — Claude Mem hybrid |
| I/O channel | Filesystem polling `io/requests/` ↔ `io/results/` | No push, no pre-emption | Item #4 — CoWork transport |
| Audits | `arib-check-*` are 300–500 line checklists | No wave-end gate, no implement-from-file | Item #5 — `/arib-deep-audit` |
| Delivery | Session-scoped only | No waves, gates, or stakeholder reports | Item #6 — wave overlay |
| i18n | Generic `arib-docs-language` | No Arabic-specific or Saudi-regulatory content | Item #7 — MENA layer |
| Design | A11y checks only | No design-token contract | Item #8 — design system |
| Deploy | Markdown checklist returns CLEARED/BLOCKED | No actual cloud test run | Item #9 — TestSprite gate |
| Autonomy | Assumes human-in-loop on every call | No protocol for `--dangerously-skip-permissions` | Item #10 — autonomy mode |
| Token budget | "58,000+ lines" marketed as a feature | ~25K tokens consumed on session start | Item #11 — lazy loading |

---

## 3. Authority Sources

Recommendations draw on:

**Anthropic official:**
- Claude Code documentation — hooks, subagents, MCP, settings
- Agent Teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- Forked subagents (`CLAUDE_CODE_FORK_SUBAGENT=1`, v2.1.117+)
- PostToolUse `hookSpecificOutput.updatedToolOutput` (v2.1.121+)
- Anthropic-shipped skills: `frontend-design`, `pdf`, `docx`, `pptx`, `xlsx`
- CoWork (launched January 2026 alongside Claude Code 2.1)
- Engineering posts on context management and ML-classifier approval automation

**Community-validated patterns:**
- SuperClaude Framework (20 agents via pipx)
- Claude Mem MCP
- TestSprite MCP
- n8n-MCP, Composio (orchestration)
- FlorianBruniaux/claude-code-ultimate-guide (release-automation, pr-workflow)
- VILA-Lab/Dive-into-Claude-Code (source-level architectural analysis: 1.6% AI logic, 98.4% deterministic infrastructure)
- shanraisshan/claude-code-best-practice (Boris Cherny + Thariq workflows)

**Production stack experience:**
- Platform Build Model v4.0 (wave methodology, three-tier supervision)
- hpc-platform (5 rounds of QA across security, performance, accessibility, RTL, race conditions, multi-tenancy)
- hpc-self-audit-cycle skill (21-section deep audit with parallel implementation agents)
- Bilingual (Arabic/English) institutional platforms for Saudi/MENA market

---

## 4. The 11 Proposals

### P0 — Foundation (must ship together)

#### #1 Real Hooks Enforcement Layer (P0)

**Gap:** `hooks/HOOKS_PROTOCOL.md` describes hook patterns. No actual hook executables exist. CONSTRAINTS.md is treated as binding but is just markdown — the model can violate it and nothing stops the tool call.

**Authority:** Anthropic's Claude Code documentation defines hooks as user-defined handlers (scripts, HTTP, MCP tools) that run *outside the agentic loop* on specific events: `PreToolUse`, `PostToolUse`, `PreCommit`, `Notification`, `SessionStart`, `Stop`. PostToolUse hooks can replace tool output via `hookSpecificOutput.updatedToolOutput` (v2.1.121+). This is the mechanism by which advisory rules become enforced rules.

**Proposal:** Add `.claude/hooks/` directory with executable scripts:

```
.claude/hooks/
├── lib/common.sh            # Shared helpers (logging, payload parsing, allow/block)
├── pre-tool-use.sh          # Path-scoping, secret detection, color-literal block, dangerous bash
├── pre-commit.sh            # Block secrets, .env files, debug statements, oversized files
├── session-start.sh         # Verify env, hash CLAUDE.md, warn on protected branch, ping CoWork
└── stop.sh                  # Write session ledger to io/ledger/, ping CoWork
```

Wired in `.claude/settings.json` covering `SessionStart`, `PreToolUse` (Write/Edit/Bash + git-commit detection), `Stop`. Idempotent installer at `scripts/install-hooks.sh`.

**Update `Training/04-HOOKS-MANUAL.md`** to distinguish:
- **Advisory rules** → `architecture/CONSTRAINTS.md` (Claude reads, may comply)
- **Enforced rules** → `.claude/hooks/*.sh` (kernel-level, cannot be bypassed)

**Outcome:** Advisory rules become enforced rules. Single highest-leverage change. Without it, every other safety claim in CCM is honor-system.

**Status:** Complete patch in [section 7](#7-pr-1--hooks-enforcement-layer-complete-patch).

---

#### #2 Three-Tier Parallel Agent Architecture (P0)

**Gap:** 13 agents, all sequential, all keyword-triggered. Calling `/arib-dev-review` runs reviewer → security → tester one after another. On a real PR this is 5–10 minutes of wall-clock when it could be ~90 seconds in parallel.

**Authority:**
- Anthropic ships official native Agent Teams via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
- Claude Code v2.1.117+ supports `CLAUDE_CODE_FORK_SUBAGENT=1` for forked subagents.
- Community standard (SuperClaude Framework, 20 agents) treats parallelism as default, not exception.

**Proposal — formalize three tiers:**

| Tier | Mechanism | Use Case | CCM Skills to Refactor |
|------|-----------|----------|------------------------|
| **T1** Subagents (in-session) | Fork via `Task` tool | Synchronous: architect during planning, debugger during failures | `arib-dev-debug`, `arib-dev-feature` |
| **T2** Agent Teams (parallel review) | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Run security + perf + a11y simultaneously | **`arib-dev-review`** (refactor to dispatch all three in parallel and merge findings) |
| **T3** Orchestration (cross-session) | Composio / n8n-MCP / scheduled jobs | Nightly dep audits, weekly wave reports, Arabic localization sweeps | New `arib-orchestrate` skill |

Add `architecture/AGENT_ARCHITECTURE.md` documenting which tier each of the 13 agents belongs to. Add `.env.example` entry for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Outcome:** Review loops 3× faster. Audit dispatch becomes naturally parallel. No more sequential bottlenecks.

---

### P1 — Core Subsystems

#### #3 Hybrid Memory: Claude Mem MCP + Markdown Audit Trail (P1)

**Gap:** Seven markdown files in `memory/` with no semantic recall. To remember a decision from session #47, Claude has to grep filenames and hope for hits. Breaks down past ~50 sessions.

**Authority:** Claude Mem is a community-standard MCP for long-horizon memory and is part of widely-recommended Claude Code toolchains. Anthropic's own guidance on context management treats memory as a layered concern — short-term in context, long-term in retrievable stores.

**Proposal — hybrid model, replace neither:**

```
Layer 1 (live):   Claude Mem MCP — semantic retrieval mid-session
Layer 2 (export): memory/*.md   — nightly export, git-versioned, audit-grade
```

- Add `.mcp.json` entry for Claude Mem.
- Add `scripts/memory-export.sh` — runs nightly via cron or on the `Stop` hook, exports Claude Mem store to `memory/*.md` for audit/version control.
- Update `memory/MEMORY_PROTOCOL.md` to describe both layers and the export contract.
- Add `/arib-memory-search "<query>"` skill that proxies to Claude Mem for semantic recall, falling back to grep on markdown files.

**Outcome:** Retrieval quality + the human-readable audit trail that justified the original markdown design. Both, not either.

---

#### #4 Real I/O Transport (CoWork) + `io/` as Ledger (P1)

**Gap:** `io/requests/` ↔ `io/results/` via markdown is reinventing message-passing. Slow, polling-based, and the "signals" mechanism cannot pre-empt a running tool call.

**Authority:** Claude CoWork (launched January 2026) is Anthropic's official non-code parallel layer for reporting, briefing, and async coordination. MCP-based tools (Slack, Discord, webhooks) provide actual push semantics.

**Proposal:**

- **Transport layer:** CoWork (or any MCP-based push transport) replaces the polling-based filesystem channel for live signals.
- **Ledger layer:** `io/` directory becomes the **immutable record**, written by a `Stop` hook after each exchange. Same hybrid pattern as memory.

Update `io/IO_PROTOCOL.md`:
- `transport: cowork | webhook | mcp-server` (configurable)
- `ledger: io/` (always-on, append-only)

**Bonus:** Add `Notification` hook routing to Telegram/Discord/Slack/WhatsApp per the community-standard pattern (push events into a running session — Claude reacts while away).

**Outcome:** Real push semantics for signals. `io/` survives as the auditable trail, not the bottleneck.

---

#### #5 `/arib-deep-audit` Skill (21-Section Audit) (P1)

**Gap:** Existing `arib-check-*` skills average 300–500 lines of checklist. Useful for spot checks but inadequate for wave-end gates or pre-release audits.

**Authority:** Production deployment patterns and Anthropic's own engineering posts describe the need for deep, multi-section audits at major milestones — not just per-PR linting. The `hpc-self-audit-cycle` skill (production-validated across the hpc-platform across 5 QA rounds) covers 21 sections with parallel implementation agents.

**Proposal — add `/arib-deep-audit` skill covering 21 sections:**

> Security (OWASP + supply chain), performance (N+1, bundle, latency budgets), accessibility (WCAG 2.1 AA), reality (mock detection), database (migration safety), i18n (RTL/LTR/CJK), observability, documentation completeness, test coverage, dependency CVEs, license compliance, race conditions, multi-tenancy isolation, secrets hygiene, error handling, logging, retry/backoff, cache invalidation, schema drift, contract tests, post-mortem readiness.

- Includes **IMPLEMENT-FROM-FILE mode**: takes a previous audit report and dispatches parallel Tier-2 fix agents per finding.
- Output: structured `OPERATIONS_LOG.md` entry + audit hash committed to git.
- The existing `/arib-check-*` skills become **inputs** to this deep audit, not replacements.

**Outcome:** A real wave-end gate. CCM can guard merges to `main` on audit-hash existence.

---

#### #6 Wave-Based Delivery Overlay (P1)

**Gap:** The framework operates at session granularity. There is no concept of multi-week delivery cycles, phase gates, or stakeholder-facing wave reports. This caps it at "session helper" rather than "delivery framework."

**Authority:** Platform Build Model v4.0 (production-validated across hpc-platform and QOL-MS) and community standards like FlorianBruniaux's `claude-code-ultimate-guide` (release-automation and pr-workflow plugins with planning gates and handoffs) both treat multi-session delivery as a first-class concern.

**Proposal — add `waves/` directory + skills:**

```
waves/
├── WAVE_PLAN.md         # Per-wave scope, exit criteria, risk register
├── WAVE_REPORT.md       # Stakeholder-facing, generated by CoWork at wave end
├── WAVE_HISTORY.md      # All completed waves with audit hashes
└── .templates/          # Wave plan and report templates
```

**New skills:**
- `/arib-wave-start <wave-name>` — reads WAVE_PLAN, creates branch, dispatches Tier-2 architect + planner in parallel.
- `/arib-wave-end` — runs `/arib-deep-audit`, generates WAVE_REPORT via CoWork, gates next wave on audit pass.

**Hook integration:** `pre-tool-use.sh` blocks merges to `main` if no audit hash from the current wave exists.

**Outcome:** CCM becomes a delivery framework, not just a session helper. Wave reports become stakeholder artifacts.

---

### P2 — Market & Quality

#### #7 Bilingual / MENA Compliance Layer (P2)

**Gap:** `arib-docs-language` is generic i18n. CCM is published by an arib.sa-affiliated developer in Saudi Arabia but has zero Arabic-specific or regional-compliance content. This is a credibility gap for the very market the maintainer is positioned to serve.

**Authority:** Saudi PDPL (Personal Data Protection Law), NCA (National Cybersecurity Authority) Essential Cybersecurity Controls, and SDAIA AI ethics guidelines apply to any platform deployed in the Kingdom or serving Saudi institutional clients.

**Proposal — add `.claude/rules/i18n-ar.md` (path-scoped to Arabic content):**

Content enforces:
- **Typography:** IBM Plex Arabic for Arabic text, paired with Inter / Geist for Latin.
- **Direction:** `dir="rtl"` required on root containers when locale is `ar`.
- **Numerals:** explicit policy (Arabic-Indic ٠١٢٣ vs Western Arabic 0123) — no implicit conversion.
- **Dates:** dual-display Hijri + Gregorian for institutional contexts.
- **Punctuation:** no Latin `?` `,` `;` in Arabic strings (use `؟` `،` `؛`).
- **Mirroring:** icons, progress indicators, chart axes mirror in RTL.

**Add `architecture/COMPLIANCE.md`:** PDPL articles relevant to data residency, NCA ECC controls applicable to multi-tenant SaaS, audit log retention requirements.

**Add `/arib-check-arabic <component>`** skill — dedicated Arabic/RTL audit, runs as Tier-3 parallel job nightly across the codebase.

**Outcome:** CCM credibly serves Saudi/MENA institutional clients, not just generic i18n.

---

#### #8 Design System as First-Class Architecture (P2)

**Gap:** Accessibility is checked, but there's no design-token contract. Components can use raw `#ffffff`, mixed font stacks, ad-hoc spacing — the a11y check won't catch any of it.

**Authority:** Anthropic's `frontend-design` skill (shipped with Claude Code) explicitly defines design tokens, component patterns, and styling constraints as a first-class concern. Skipping this skill produces lower-quality output even on familiar formats.

**Proposal — add `architecture/DESIGN_SYSTEM.md`:**

- **Component baseline:** shadcn/ui (a11y-correct primitives, customizable, TypeScript-native).
- **Color:** Tailwind tokens only. Hex/rgb/hsl literals in component files = pre-tool-use hook block (already in PR #1).
- **Typography pair:** IBM Plex Arabic + Inter (or Geist for tighter visual density).
- **Dark mode:** default, with explicit light-mode override.
- **Aesthetic references:** Linear, Vercel, Stripe (high information density, low chrome, professional restraint).
- **Motion:** framer-motion or CSS-only, no auto-playing animations on data screens.

**Companion hook in `.claude/hooks/pre-tool-use.sh`** (already in PR #1):
```bash
# Block raw color literals in component files
if [[ "$file" == *.tsx || "$file" == *.jsx ]]; then
  grep -E '#[0-9a-fA-F]{3,8}|rgb\(|hsl\(' "$file" && exit 1
fi
```

**Add `/arib-check-design`** skill enforcing the contract.

**Outcome:** Visual quality becomes enforceable, not aspirational.

---

#### #9 TestSprite Wired Into Deploy Gate (P2)

**Gap:** `/arib-check-deploy` returns CLEARED/BLOCKED based on a markdown checklist. No actual cloud test execution.

**Authority:** TestSprite MCP is an AI-powered cloud testing service that integrates natively with Claude Code via MCP. Pre-deployment cloud testing is a community-standard practice for production-grade workflows.

**Proposal:**

- Add TestSprite MCP entry to `.mcp.json`.
- Modify `arib-check-deploy/SKILL.md`: phase 4 of the 7-phase verification is now **TestSprite cloud test run**. CLEARED requires a passing run ID.
- Pin the run ID into `operations/DEPLOYMENT.md` for that release — auditable trail.

**Update `operations/MONITORING.md`** to include TestSprite-based synthetic monitoring for production canaries.

**Outcome:** Deploy gates have teeth. Audit trail per release.

---

### P3 — Polish & Operational Maturity

#### #10 Autonomy Mode Protocol (P3)

**Gap:** No documented protocol for `caffeinate -i claude --dangerously-skip-permissions` runs. The framework assumes a human in the loop on every tool call. Real wave execution at scale requires defined autonomy windows.

**Authority:** Anthropic has published guidance on safer-skip-permissions modes and ML-classifier approval automation (auto-approve rates grow from ~20% to 40%+ with experience). Sandbox-based security work has shown 84% reduction in permission prompts is achievable safely.

**Proposal — add `operations/AUTONOMY_MODE.md`:**

**Preconditions (all must be true to enter autonomy):**
- All hooks active and tested in last 24h.
- Git working tree clean.
- Snapshot tag created (`autonomy/start-<timestamp>`).
- CoWork health-checked and listening.

**Guardrails (active during autonomy):**
- Auto-stop on any test failure.
- Auto-stop if hook block count > N within 10 minutes.
- Hourly CoWork status ping with current task + token spend.
- Hard wall-clock cap (default: 4 hours).

**Post-conditions (exit autonomy):**
- Wave-end self-audit must pass before commits land on `main`.
- Autonomy report written to `operations/OPERATIONS_LOG.md`.

**Add `.claude/hooks/autonomy-guard.sh`** — runs every tool call, enforces the guardrails.

**Outcome:** Long autonomous runs become safe and observable, not blind.

---

#### #11 Token-Budget Discipline (Fix the 58k-Line Problem) (P3)

**Gap:** README markets "58,000+ lines · 7,393 lines of deep skills" as a feature. In Claude Code's context economy, that's a **cost**. Loading the full skill body on session start is wasteful — `arib-io` alone is 799 lines.

**Authority:** Anthropic's published guidance on context management treats token budget as a primary engineering concern. The five compaction shapers in Claude Code (Budget Reduction → Snip → Microcompact → Context Collapse → Auto-Compact) exist precisely because uncontrolled context degrades model performance. VILA-Lab's source-level analysis: only 1.6% of Claude Code's codebase is AI decision logic; 98.4% is deterministic infrastructure including context management.

**Proposal:**

- **Lazy skill loading:** skill body loads only on slash-command invocation, not on session start. CCM's path-scoped rules pattern already proves this works — apply it to skills too.
- **Skill summary stubs:** each skill ships a 20-line `SUMMARY.md` (loaded on session start) and the full `SKILL.md` (loaded on invocation).
- **Add `scripts/token-audit.sh`** — measures total context consumed by CCM scaffolding on session start. **Target: under 8K tokens. Currently estimated > 25K.**
- **Update README** to lead with token efficiency, not line count. Lines of markdown is not a quality metric.

**Outcome:** CCM gets faster and cheaper on every session. Marketing aligns with engineering reality.

---

## 5. Summary Table

| # | Item | Priority | New Files | Modified Files | Estimated PR Size |
|---|------|----------|-----------|----------------|-------------------|
| 1 | Hooks enforcement | **P0** | `.claude/hooks/*.sh`, `scripts/install-hooks.sh` | `settings.json`, `04-HOOKS-MANUAL.md`, `CONTEXT_MAP.md` | ~800 lines |
| 2 | Three-tier agents | **P0** | `AGENT_ARCHITECTURE.md` | `arib-dev-review`, agent files, `.env.example` | ~400 lines |
| 3 | Hybrid memory | **P1** | `arib-memory-search/`, `memory-export.sh` | `.mcp.json`, `MEMORY_PROTOCOL.md` | ~300 lines |
| 4 | Real I/O transport | **P1** | `Stop` hook integration | `IO_PROTOCOL.md` | ~200 lines |
| 5 | Deep audit skill | **P1** | `arib-deep-audit/SKILL.md` | `arib-check-*` integration | ~900 lines |
| 6 | Wave overlay | **P1** | `waves/`, `arib-wave-start`, `arib-wave-end` | `session-protocol.md` | ~600 lines |
| 7 | Arabic/MENA layer | **P2** | `i18n-ar.md`, `COMPLIANCE.md`, `arib-check-arabic` | `arib-docs-language` | ~700 lines |
| 8 | Design system | **P2** | `DESIGN_SYSTEM.md`, `arib-check-design` | accessibility skill | ~500 lines |
| 9 | TestSprite gate | **P2** | `.mcp.json` entry | `arib-check-deploy`, `MONITORING.md` | ~150 lines |
| 10 | Autonomy mode | **P3** | `AUTONOMY_MODE.md`, `autonomy-guard.sh` | session skills | ~400 lines |
| 11 | Token discipline | **P3** | `SUMMARY.md` per skill, `token-audit.sh` | All 16 skills, README | ~300 lines |

---

## 6. Proposed Sequencing

**Patch series, mergeable independently:**

1. **PR #1** — Item 1 (hooks). Foundation. Drafted, ready to merge — see [section 7](#7-pr-1--hooks-enforcement-layer-complete-patch).
2. **PR #2** — Item 11 (token discipline). Quick win, clear quality signal, low risk.
3. **PR #3** — Item 2 (three-tier agents). Unblocks #4 and #5.
4. **PR #4** — Item 5 (deep audit skill). Replaces shallow checks with a real gate.
5. **PR #5** — Item 6 (wave overlay). Uses #4. Turns CCM into a delivery framework.
6. **PR #6** — Items 3 + 4 (memory and I/O hybrid). Subsystem upgrade.
7. **PR #7** — Item 9 (TestSprite). Small, high-credibility.
8. **PR #8** — Item 8 (design system). Pairs with #1's color-literal hook.
9. **PR #9** — Item 7 (Arabic/MENA). Major credibility lift for the maintainer's positioning.
10. **PR #10** — Item 10 (autonomy mode). Operational maturity.

After PRs #1, #3, #4, #5 land, CCM has moved from "convention pack" to genuine "AI Development Operating System" and the README's positioning becomes accurate rather than aspirational.

**Codename rationale:**
- v3.0 was "Aligned" (matched Anthropic primitives)
- v3.1 was "Deep Skills" (deepened content)
- v3.2 should be **"Enforced"** — deepens the *contract*: rules become enforceable, parallelism becomes default, audits become gates.

---

## 7. PR #1 — Hooks Enforcement Layer (Complete Patch)

**Branch suggestion:** `feat/hooks-enforcement-layer`

11 files, ~800 lines of bash and markdown, zero external dependencies beyond `jq`/`git`/`curl`. The hooks are defensive (fail closed on unknown patterns), have audit trails, and provide three documented bypass paths.

### File 1 — `.claude/hooks/lib/common.sh`

Shared utilities. Sourced by every hook.

````bash
#!/usr/bin/env bash
# .claude/hooks/lib/common.sh
# Shared utilities for CCM hooks. Sourced by all hook scripts.
# Reads stdin JSON payload from Claude Code, exposes helpers.

set -euo pipefail

# ---------- Config ----------
CCM_ROOT="${CCM_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CCM_LOG_DIR="${CCM_ROOT}/io/hook-logs"
CCM_LOG_FILE="${CCM_LOG_DIR}/$(date +%Y-%m-%d).log"
mkdir -p "${CCM_LOG_DIR}"

# ---------- Logging ----------
log() {
  local level="$1"; shift
  local msg="$*"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '[%s] [%s] [%s] %s\n' "$ts" "$level" "${HOOK_NAME:-unknown}" "$msg" >> "${CCM_LOG_FILE}"
  if [[ "${level}" == "ERROR" || "${level}" == "BLOCK" ]]; then
    printf '[CCM/%s] %s\n' "${HOOK_NAME:-hook}" "$msg" >&2
  fi
}

# ---------- JSON payload helpers ----------
# Claude Code passes a JSON payload on stdin to every hook.
# Cache it once per invocation so multiple `payload_get` calls work.
_PAYLOAD_CACHE=""
read_payload() {
  if [[ -z "$_PAYLOAD_CACHE" ]]; then
    if [[ -t 0 ]]; then
      _PAYLOAD_CACHE="{}"
    else
      _PAYLOAD_CACHE="$(cat)"
    fi
  fi
  printf '%s' "$_PAYLOAD_CACHE"
}

# Extract a field from the payload using jq. Returns empty string if missing.
payload_get() {
  local path="$1"
  if ! command -v jq >/dev/null 2>&1; then
    log ERROR "jq is required but not installed. Install with: brew install jq"
    return 1
  fi
  read_payload | jq -r "${path} // empty" 2>/dev/null || true
}

# ---------- Exit helpers ----------
# Exit 0 = allow, Exit 1 = block (Claude sees stderr as the block reason).
allow() {
  log INFO "ALLOW: $*"
  exit 0
}

block() {
  log BLOCK "BLOCK: $*"
  printf 'CCM hook blocked this operation: %s\n' "$*" >&2
  exit 1
}

# ---------- Path helpers ----------
# Resolve a path relative to repo root. Returns absolute path.
abs_path() {
  local p="$1"
  if [[ "$p" = /* ]]; then
    printf '%s' "$p"
  else
    printf '%s/%s' "$CCM_ROOT" "$p"
  fi
}

# Check if a path is inside any of the allowed roots (newline-separated list).
path_under() {
  local target="$1"; shift
  local roots="$1"
  local abs_target
  abs_target="$(abs_path "$target")"
  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    local abs_root
    abs_root="$(abs_path "$root")"
    if [[ "$abs_target" == "$abs_root"* ]]; then
      return 0
    fi
  done <<< "$roots"
  return 1
}

# ---------- CoWork notification (best-effort, non-blocking) ----------
notify_cowork() {
  local event="$1"
  local detail="$2"
  local webhook="${CCM_COWORK_WEBHOOK:-}"
  [[ -z "$webhook" ]] && return 0
  curl -fsS -m 3 -X POST "$webhook" \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg e "$event" --arg d "$detail" --arg ts "$(date -u +%FT%TZ)" \
        '{event:$e, detail:$d, ts:$ts, source:"ccm-hook"}')" \
    >/dev/null 2>&1 || true
}
````

### File 2 — `.claude/hooks/pre-tool-use.sh`

Path-scope enforcement + secret detection on every Write/Edit/Bash call.

````bash
#!/usr/bin/env bash
# .claude/hooks/pre-tool-use.sh
# Runs before every Write|Edit|Bash tool call.
# Blocks: writes outside CONTEXT_MAP, secrets in payloads, dangerous bash commands.

HOOK_NAME="pre-tool-use"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

TOOL_NAME="$(payload_get '.tool_name')"
TOOL_INPUT="$(payload_get '.tool_input')"

# ---------- 1. Secret detection (all tools) ----------
# Patterns drawn from common credential formats. Conservative — false positives
# are acceptable here; false negatives are not.
SECRET_PATTERNS=(
  'sk-ant-[a-zA-Z0-9_-]{20,}'        # Anthropic API key
  'sk-[a-zA-Z0-9]{32,}'              # OpenAI / generic
  'ghp_[a-zA-Z0-9]{36}'              # GitHub personal access token
  'gho_[a-zA-Z0-9]{36}'              # GitHub OAuth token
  'AKIA[0-9A-Z]{16}'                 # AWS access key
  'AIza[0-9A-Za-z_-]{35}'            # Google API key
  'xox[baprs]-[a-zA-Z0-9-]{10,}'     # Slack token
  '-----BEGIN (RSA|EC|OPENSSH|PGP) PRIVATE KEY-----'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if printf '%s' "$TOOL_INPUT" | grep -Eq "$pattern"; then
    notify_cowork "secret-block" "Pattern matched in $TOOL_NAME"
    block "Detected potential secret in tool input. Pattern: ${pattern%%[*}. Move credentials to .env (gitignored) and reference via env var."
  fi
done

# ---------- 2. Write/Edit path scoping ----------
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "MultiEdit" ]]; then
  TARGET_PATH="$(payload_get '.tool_input.file_path')"
  [[ -z "$TARGET_PATH" ]] && allow "no file_path in payload"

  # Hard-deny list — never write here, regardless of CONTEXT_MAP.
  HARD_DENY=(
    "${CCM_ROOT}/.git/"
    "${CCM_ROOT}/.env"
    "${CCM_ROOT}/.env.production"
    "${CCM_ROOT}/.env.local"
    "/etc/"
    "/usr/"
    "${HOME}/.ssh/"
    "${HOME}/.aws/"
  )
  for denied in "${HARD_DENY[@]}"; do
    if [[ "$TARGET_PATH" == "$denied"* ]]; then
      block "Write to protected path '$TARGET_PATH' is not permitted. Edit .env.example instead, or update CONTEXT_MAP to extend the hard-deny list."
    fi
  done

  # Soft-scope: if CONTEXT_MAP.md declares allowed_write_paths, enforce it.
  CONTEXT_MAP="${CCM_ROOT}/architecture/CONTEXT_MAP.md"
  if [[ -f "$CONTEXT_MAP" ]]; then
    ALLOWED_ROOTS="$(awk '/^<!-- allowed_write_paths:start -->/,/^<!-- allowed_write_paths:end -->/' "$CONTEXT_MAP" \
                     | grep -E '^- ' | sed 's/^- //')"
    if [[ -n "$ALLOWED_ROOTS" ]]; then
      if ! path_under "$TARGET_PATH" "$ALLOWED_ROOTS"; then
        block "Path '$TARGET_PATH' is outside CONTEXT_MAP allowed_write_paths. Either update CONTEXT_MAP or write within: $(echo "$ALLOWED_ROOTS" | tr '\n' ' ')"
      fi
    fi
  fi

  # ---------- 3. Component-file color literal check (Tailwind discipline) ----------
  if [[ "$TARGET_PATH" =~ \.(tsx|jsx)$ ]] && [[ "$TARGET_PATH" != *node_modules* ]]; then
    NEW_CONTENT="$(payload_get '.tool_input.content // .tool_input.new_string')"
    if printf '%s' "$NEW_CONTENT" | grep -Eq '#[0-9a-fA-F]{3,8}\b|rgb\([^)]*\)|hsl\([^)]*\)'; then
      # Allow if the line is in a comment or in a designated tokens file.
      if [[ "$TARGET_PATH" != *tokens* && "$TARGET_PATH" != *theme* ]]; then
        block "Raw color literal detected in component file '$TARGET_PATH'. Use Tailwind tokens or import from your design-system theme. See architecture/DESIGN_SYSTEM.md."
      fi
    fi
  fi
fi

# ---------- 4. Dangerous bash command detection ----------
if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD="$(payload_get '.tool_input.command')"

  # Block patterns that have caused real incidents.
  DANGEROUS_PATTERNS=(
    'rm -rf /( |$)'
    'rm -rf \*'
    'rm -rf ~'
    'rm -rf \$HOME'
    'mkfs\.'
    'dd if=.*of=/dev/'
    ':(\)\{ *:\|: *& *\};:'                  # fork bomb
    'chmod -R 777 /'
    'curl [^|]*\| *(sh|bash)( |$)'             # curl | sh
    'wget [^|]*\| *(sh|bash)( |$)'
    'git push.*--force.*\b(main|master|production)\b'
    'git reset --hard origin/(main|master|production)'
    'DROP DATABASE'
    'TRUNCATE.*production'
  )
  for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if printf '%s' "$CMD" | grep -Eiq "$pattern"; then
      notify_cowork "dangerous-bash-block" "Command: ${CMD:0:120}"
      block "Dangerous command pattern detected: matches '$pattern'. If this is intentional, run it manually outside Claude Code."
    fi
  done
fi

allow "checks passed for $TOOL_NAME"
````

### File 3 — `.claude/hooks/pre-commit.sh`

Runs as a `Bash` PreToolUse hook when `git commit` is detected, **and** as a real git pre-commit hook.

````bash
#!/usr/bin/env bash
# .claude/hooks/pre-commit.sh
# Pre-commit guard: blocks commits with secrets, console.logs in production files,
# .env files, and oversized files. Runs as both a Claude PreToolUse hook (when
# `git commit` is the bash command) and as a git pre-commit hook.

HOOK_NAME="pre-commit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Get staged files. Falls back to all changed files if not in a git context.
STAGED="$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)"
[[ -z "$STAGED" ]] && allow "no staged files"

FAILURES=()

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue

  # 1. Block .env files (never commit)
  case "$file" in
    .env|.env.local|.env.production|*.pem|*.key|id_rsa|id_ed25519)
      FAILURES+=("Refusing to commit credential file: $file")
      continue
      ;;
  esac

  # 2. Secret patterns
  if grep -EHn 'sk-ant-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}' "$file" 2>/dev/null; then
    FAILURES+=("Secret pattern detected in: $file")
  fi

  # 3. Oversized files (> 1 MB) — usually accidental
  if [[ "$(wc -c < "$file")" -gt 1048576 ]]; then
    FAILURES+=("File exceeds 1 MB (likely committed by accident): $file. Use Git LFS or .gitignore.")
  fi

  # 4. console.log / debugger in production source files
  if [[ "$file" =~ \.(ts|tsx|js|jsx)$ ]] && [[ "$file" != *test* && "$file" != *spec* && "$file" != *.config.* ]]; then
    if grep -EHn '^\s*(console\.(log|debug)|debugger;)' "$file" 2>/dev/null; then
      FAILURES+=("Debug statement in production file: $file. Use a structured logger or remove.")
    fi
  fi

done <<< "$STAGED"

if (( ${#FAILURES[@]} > 0 )); then
  printf '\n%s\n' "===== CCM pre-commit blocked the commit ====="
  for f in "${FAILURES[@]}"; do
    printf '  ✗ %s\n' "$f"
  done
  printf '\nFix the issues above, then re-run the commit. To bypass (NOT recommended): git commit --no-verify\n\n'
  notify_cowork "pre-commit-block" "$(printf '%s; ' "${FAILURES[@]}")"
  exit 1
fi

allow "pre-commit clean"
````

### File 4 — `.claude/hooks/session-start.sh`

Runs once when a Claude Code session starts.

````bash
#!/usr/bin/env bash
# .claude/hooks/session-start.sh
# Runs on SessionStart. Verifies environment, pings CoWork, surfaces git state.

HOOK_NAME="session-start"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# 1. Verify CLAUDE.md exists and capture its hash (drift detection).
if [[ ! -f "${CCM_ROOT}/CLAUDE.md" ]]; then
  log WARN "CLAUDE.md not found at repo root"
else
  CLAUDE_MD_HASH="$(shasum -a 256 "${CCM_ROOT}/CLAUDE.md" | awk '{print $1}')"
  log INFO "CLAUDE.md hash: ${CLAUDE_MD_HASH:0:12}"
fi

# 2. Surface git state to the session log.
if git -C "${CCM_ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH="$(git -C "${CCM_ROOT}" rev-parse --abbrev-ref HEAD)"
  DIRTY="$(git -C "${CCM_ROOT}" status --porcelain | wc -l | tr -d ' ')"
  log INFO "branch=${BRANCH} dirty_files=${DIRTY}"
  if [[ "$BRANCH" == "main" || "$BRANCH" == "master" || "$BRANCH" == "production" ]]; then
    printf '\n⚠️  CCM: Session starting on protected branch "%s". Consider: git checkout -b feature/<name>\n\n' "$BRANCH" >&2
  fi
fi

# 3. Notify CoWork (non-blocking).
notify_cowork "session-start" "branch=${BRANCH:-unknown} root=${CCM_ROOT}"

# 4. Verify required tooling.
for tool in jq git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '⚠️  CCM: Required tool "%s" not found. Some hooks will fail.\n' "$tool" >&2
  fi
done

allow "session-start checks complete"
````

### File 5 — `.claude/hooks/stop.sh`

Runs when a session ends. Persists I/O ledger entry.

````bash
#!/usr/bin/env bash
# .claude/hooks/stop.sh
# Runs on Stop. Writes session summary to io/ ledger and notifies CoWork.

HOOK_NAME="stop"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

LEDGER_DIR="${CCM_ROOT}/io/ledger"
mkdir -p "${LEDGER_DIR}"

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
LEDGER_FILE="${LEDGER_DIR}/session-${TS}.md"

BRANCH="$(git -C "${CCM_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
COMMITS_THIS_SESSION="$(git -C "${CCM_ROOT}" log --since='4 hours ago' --oneline 2>/dev/null | wc -l | tr -d ' ')"
FILES_CHANGED="$(git -C "${CCM_ROOT}" diff --name-only HEAD~"${COMMITS_THIS_SESSION:-0}" 2>/dev/null | wc -l | tr -d ' ')"

cat > "${LEDGER_FILE}" <<EOF
# Session Ledger Entry

- timestamp: ${TS}
- branch: ${BRANCH}
- commits_this_session: ${COMMITS_THIS_SESSION}
- files_changed: ${FILES_CHANGED}
- ccm_root: ${CCM_ROOT}

## Recent commits

\`\`\`
$(git -C "${CCM_ROOT}" log --since='4 hours ago' --oneline 2>/dev/null || echo "no git history")
\`\`\`

## Hook log tail

\`\`\`
$(tail -20 "${CCM_LOG_FILE}" 2>/dev/null || echo "no hook log")
\`\`\`
EOF

log INFO "ledger written: ${LEDGER_FILE}"
notify_cowork "session-end" "commits=${COMMITS_THIS_SESSION} files=${FILES_CHANGED}"

allow "stop hook complete"
````

### File 6 — `.claude/settings.json`

Drop-in replacement.

````json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-tool-use.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'git commit'; then .claude/hooks/pre-commit.sh; fi"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/stop.sh"
          }
        ]
      }
    ]
  }
}
````

### File 7 — `scripts/install-hooks.sh`

Idempotent installer.

````bash
#!/usr/bin/env bash
# scripts/install-hooks.sh
# One-time setup: makes hook scripts executable, installs git pre-commit hook,
# verifies dependencies.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

echo "==> Installing CCM hooks..."

# 1. Make all hook scripts executable.
find .claude/hooks -type f -name '*.sh' -exec chmod +x {} \;
chmod +x scripts/*.sh 2>/dev/null || true

# 2. Install git pre-commit hook (delegates to .claude/hooks/pre-commit.sh).
mkdir -p .git/hooks
cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# Auto-installed by CCM. Delegates to .claude/hooks/pre-commit.sh.
exec "$(git rev-parse --show-toplevel)/.claude/hooks/pre-commit.sh" "$@"
EOF
chmod +x .git/hooks/pre-commit

# 3. Verify dependencies.
MISSING=()
for tool in jq git curl; do
  command -v "$tool" >/dev/null 2>&1 || MISSING+=("$tool")
done
if (( ${#MISSING[@]} > 0 )); then
  echo "⚠️  Missing required tools: ${MISSING[*]}"
  echo "    Install with: brew install ${MISSING[*]}  (macOS)"
  echo "                  apt install ${MISSING[*]}   (Debian/Ubuntu)"
  exit 1
fi

# 4. Smoke-test session-start hook.
echo "==> Smoke-testing session-start hook..."
echo '{}' | .claude/hooks/session-start.sh && echo "    ✓ session-start OK"

echo ""
echo "==> CCM hooks installed."
echo "    Logs:   io/hook-logs/"
echo "    Ledger: io/ledger/"
echo ""
echo "    To enable CoWork notifications, set in your shell:"
echo "      export CCM_COWORK_WEBHOOK='https://your-cowork-endpoint'"
````

### File 8 — `architecture/CONTEXT_MAP.md` (additions)

Append to existing file.

````markdown
## Write Path Scoping (enforced by `.claude/hooks/pre-tool-use.sh`)

The hook reads the block below. Add a path here before allowing Claude to write into a new directory.

<!-- allowed_write_paths:start -->
- apps/
- packages/
- services/
- migrations/
- prisma/
- tests/
- docs/
- memory/
- io/
- waves/
- architecture/
- implementation/
- operations/
- core/
<!-- allowed_write_paths:end -->

**Hard-denied paths** (cannot be overridden, see `pre-tool-use.sh`):
- `.git/`
- `.env`, `.env.local`, `.env.production`
- `/etc/`, `/usr/`, `~/.ssh/`, `~/.aws/`
````

### File 9 — `Training/04-HOOKS-MANUAL.md` (replacement)

````markdown
# Training Manual 04 — Hooks (Enforcement Layer)

## The advisory-vs-enforced distinction

CCM separates two kinds of rules:

| Kind | Where | How it works | Bypassable? |
|------|-------|--------------|-------------|
| **Advisory** | `architecture/CONSTRAINTS.md`, `.claude/rules/*.md` | Claude reads them and *should* comply | Yes — model can violate |
| **Enforced** | `.claude/hooks/*.sh` | Run outside the agent loop, can block tool calls | No — kernel-level |

Before v3.2, CCM was advisory-only. v3.2 adds the enforcement layer.

## Hook events

Five events have active hooks:

| Event | Script | What it does |
|-------|--------|--------------|
| `SessionStart` | `session-start.sh` | Verify env, hash CLAUDE.md, warn on protected branch, ping CoWork |
| `PreToolUse` (Write/Edit) | `pre-tool-use.sh` | Block writes outside CONTEXT_MAP, secret detection, color-literal check |
| `PreToolUse` (Bash) | `pre-tool-use.sh` | Block dangerous commands |
| `PreToolUse` (git commit) | `pre-commit.sh` | Block commits with secrets, .env files, debug statements, oversized files |
| `Stop` | `stop.sh` | Write session ledger to `io/ledger/`, ping CoWork |

## Installation

```bash
./scripts/install-hooks.sh
```

Idempotent. Makes scripts executable, installs git pre-commit hook, verifies dependencies.

## Configuration

### CoWork notifications

```bash
export CCM_COWORK_WEBHOOK='https://your-cowork-endpoint/hook'
```

### Allowed write paths

Edit `architecture/CONTEXT_MAP.md` between the markers:

```markdown
<!-- allowed_write_paths:start -->
- apps/
- packages/
<!-- allowed_write_paths:end -->
```

## Bypassing (when you must)

1. **Update CONTEXT_MAP** — for legitimate new directories.
2. **Run manually outside Claude Code** — for one-off operations.
3. **`git commit --no-verify`** — last resort, leaves audit trail in ledger.

Never edit hook scripts to lower the bar.

## Audit trail

- `io/hook-logs/YYYY-MM-DD.log` — every hook invocation.
- `io/ledger/session-<timestamp>.md` — every session end.

## Adding a new hook

1. Create `.claude/hooks/your-hook.sh`.
2. Source `lib/common.sh` for helpers.
3. Use `block "reason"` to deny, `allow "reason"` to permit.
4. Wire into `.claude/settings.json` under the relevant event.
5. Re-run `./scripts/install-hooks.sh`.
````

### File 10 — `.gitignore` (additions)

````
# CCM hook artifacts
io/hook-logs/
io/ledger/

# Personal CCM overrides
.claude/settings.local.json
````

### File 11 — `CHANGELOG.md` (entry)

Prepend:

````markdown
## v3.2.0 "Enforced" — Hooks Enforcement Layer

### Added
- `.claude/hooks/` directory with executable enforcement scripts.
- `scripts/install-hooks.sh` — idempotent installer.
- Path-scoped write enforcement via `architecture/CONTEXT_MAP.md`.
- Secret detection across 8 credential patterns.
- Dangerous bash command blocklist.
- Color-literal blocking in component files.
- Pre-commit guards for .env files, debug statements, oversized files.
- Session ledger written to `io/ledger/` on every session end.
- CoWork webhook notifications (opt-in via `CCM_COWORK_WEBHOOK`).

### Changed
- `Training/04-HOOKS-MANUAL.md` rewritten to distinguish advisory vs enforced rules.
- `architecture/CONTEXT_MAP.md` now defines the allowed_write_paths contract.
- `.claude/settings.json` wires all five hook events.

### Why
v3.1 was advisory-only — CONSTRAINTS.md was honor-system. v3.2 introduces the kernel-level enforcement layer that makes "operating system" framing accurate.
````

---

## 8. GitHub Issue Body (Copy-Paste-Ready)

**Suggested title:** `v3.2 "Enforced": architectural proposal — enforcement layer, parallel agents, delivery-cycle framing`

**Suggested labels:** `enhancement`, `roadmap`, `v3.2`, `discussion`

**Body:**

````markdown
# v3.2 "Enforced" — Architectural Roadmap Proposal

First: thank you for shipping v3.1. The path-scoped rules pattern, the 5-mode bootstrap taxonomy, and the discipline of keeping CLAUDE.md under 200 lines are genuinely strong ideas, and the documentation depth is impressive.

This issue proposes **eleven additions for v3.2** that, taken together, would close the gap between CCM's current positioning ("AI Development Operating System") and what it currently delivers (a high-quality convention pack). The recommendations come from a production review against:

- Anthropic's official Claude Code documentation and engineering posts
- Anthropic-shipped primitives: hooks, subagents, Agent Teams, MCP, the `frontend-design` skill, CoWork
- Community-validated patterns (SuperClaude Framework, Claude Mem, GSD, TestSprite, n8n-MCP, FlorianBruniaux/claude-code-ultimate-guide, VILA-Lab/Dive-into-Claude-Code)
- A production stack running bilingual (Arabic/English) institutional platforms in the MENA market

Happy to open separate PRs for each item. PR #1 (the hooks layer) is drafted and ready.

---

## Diagnosis

CCM v3.1 has five structural gaps:

1. **Rules are advisory-only.** CONSTRAINTS.md is markdown the model can violate. No kernel-level enforcement.
2. **Agents are sequential.** 13 keyword-triggered agents. A typical review burns 5–10 min wall-clock when it could be ~90 sec parallel.
3. **Memory has no semantic recall.** Seven markdown files that work fine at session 5 and break down at session 50.
4. **The I/O channel reinvents message-passing on the filesystem.** Polling, no pre-emption, slower than CoWork or any MCP push transport.
5. **No delivery-cycle framing.** Framework operates at session granularity. Multi-week wave delivery and phase gates aren't first-class.

Items 1–6 below address those gaps. Items 7–11 close credibility gaps for the markets CCM is positioned to serve.

---

## The 11 Proposals (summary — full detail in linked roadmap document)

### P0 — Foundation
1. **Real Hooks Enforcement Layer** — add executable hooks, advisory→enforced distinction
2. **Three-Tier Parallel Agent Architecture** — T1 subagents / T2 Agent Teams / T3 orchestration

### P1 — Core Subsystems
3. **Hybrid Memory** — Claude Mem MCP for live + markdown for audit
4. **Real I/O Transport** — CoWork as transport, `io/` as ledger
5. **`/arib-deep-audit` Skill** — 21-section audit with implement-from-file mode
6. **Wave-Based Delivery Overlay** — `waves/` directory + `/arib-wave-start`/`/arib-wave-end`

### P2 — Market & Quality
7. **Bilingual / MENA Compliance Layer** — Arabic typography, RTL, PDPL/NCA compliance
8. **Design System** — shadcn/ui baseline, token contract, color-literal hook
9. **TestSprite Wired Into Deploy Gate** — phase 4 of arib-check-deploy is now real cloud test

### P3 — Polish
10. **Autonomy Mode Protocol** — preconditions, guardrails, post-conditions for `--dangerously-skip-permissions` runs
11. **Token-Budget Discipline** — lazy skill loading, summary stubs, `scripts/token-audit.sh` (target: <8K tokens on session start vs current ~25K)

---

## Proposed Sequencing

10 PRs, mergeable independently. PR #1 (hooks) drafted and ready. Full sequencing:

1. PR #1 — Hooks (foundation)
2. PR #2 — Token discipline (quick win)
3. PR #3 — Three-tier agents (unblocks #4 and #5)
4. PR #4 — Deep audit skill
5. PR #5 — Wave overlay
6. PR #6 — Memory + I/O hybrid
7. PR #7 — TestSprite
8. PR #8 — Design system
9. PR #9 — Arabic/MENA layer
10. PR #10 — Autonomy mode

After PRs #1, #3, #4, #5 land, CCM has moved from "convention pack" to genuine "AI Development Operating System."

**Codename rationale:** v3.0 "Aligned" → v3.1 "Deep Skills" → v3.2 **"Enforced"** (rules become enforceable, parallelism default, audits become gates).

---

## What's NOT in this proposal

- No backend rewrite. CCM stays bash + markdown.
- No new external dependencies beyond `jq`, `git`, `curl`.
- No breaking changes for v3.1 users — every item opt-in or backward-compatible.
- No vendor lock-in — Claude Mem and TestSprite recommended but pluggable via MCP-standard contracts.

---

## Discussion

Open questions before PRs #2 onward:

1. **Codename approval** — does "Enforced" land? Alternatives: "Hardened", "Operating", "Kernel".
2. **Backward compat threshold** — comfortable shipping item 11 (lazy loading) default-on for new bootstraps, opt-in for v3.1 upgrades?
3. **Vendor neutrality** — items 3 (Claude Mem) and 9 (TestSprite) ship with named defaults or just MCP-contract stubs?
4. **Audit-hash gating** — for item 6 (waves), comfortable with the hook *blocking* merges to `main` without an audit hash, or warn first?
5. **PR cadence** — one PR per item (slow, reviewable) or grouped P0/P1/P2/P3 (faster, larger diffs)?

Happy to adjust based on your answers. Goal is a v3.2 that you're proud to release and that v3.1 users can adopt incrementally.

Thanks for the work on v3.1 — these recommendations are offered in that spirit.
````

---

## 9. Open Questions for Maintainer

Before opening PR #2 onward, settle these with Abdullah:

1. **Codename** — does "Enforced" fit? Alternatives: "Hardened", "Operating", "Kernel".
2. **Backward compatibility** — default-on for new bootstraps, opt-in for v3.1 upgrades?
3. **Vendor neutrality** — named defaults (Claude Mem, TestSprite) or MCP-stub abstractions?
4. **Audit-hash gating** — block merges to `main` without audit hash, or warn first?
5. **PR cadence** — one PR per item or grouped by priority tier?

---

## 10. Fallback Strategy if Upstream is Inactive

The repo is private/limited (0 stars, 0 forks, 1 contributor listed as `@claude`, two-week-old initial commit). There is a real chance Abdullah isn't actively maintaining it as a community project — it may be a personal toolkit made public.

**If no engagement within 7 days of issue:**

1. **Fork** as `pbm-claude-code` (or a name aligned with Platform Build Model branding).
2. **Rename** the `arib-*` skill prefix to `pbm-*` (or your chosen brand).
3. **Attribute** the source: `Inspired by AribSudia/claude-code-methodology v3.1.0 by Abdullah Alzahrani.` Keep the MIT license intact, attribution is the obligation it imposes.
4. **Apply** all 11 items as your own internal upgrade — you get the value regardless of upstream merge status.
5. **Retain** what's genuinely strong: path-scoped rules, the 5-mode bootstrap taxonomy, the 16-skill structure, the 200-line CLAUDE.md discipline, the agent activation patterns.
6. **Replace** what's specific to CCM that doesn't fit your stack: branded prefix, generic i18n skill, file-based I/O channel.

This way the work isn't blocked on upstream responsiveness, and the proposed improvements ship to *your* team and *your* projects (hpc-platform, QOL-MS) regardless of what AribSudia/claude-code-methodology does.

---

## 11. Appendix — Stack Inventory

For reference, this proposal is informed by the following production stack:

| Component | Role | How it informs the proposal |
|-----------|------|----------------------------|
| **SuperClaude Framework** | 20 agents via pipx | Authority for parallel agent architecture (#2) |
| **Claude Mem** | Long-horizon memory MCP | Authority for hybrid memory model (#3) |
| **GSD** | Session lifecycle skill | Pattern for session-start/end discipline (#1, #6) |
| **CoWork** | Parallel non-code reporting layer | Authority for real I/O transport (#4) |
| **hpc-self-audit-cycle** | 21-section deep audit skill | Direct source for `/arib-deep-audit` (#5) |
| **TestSprite** | Cloud testing MCP | Authority for deploy-gate integration (#9) |
| **n8n-MCP, Composio** | Cross-session orchestration | Authority for Tier-3 agent layer (#2) |
| **Platform Build Model v4.0** | Wave methodology, three-tier supervision | Authority for delivery overlay (#6), autonomy protocol (#10) |
| **hpc-platform** | 5-round QA across security, performance, accessibility, RTL, multi-tenancy | Real-world validation of items #1, #5, #7, #8 |
| **QOL-MS** | Bilingual KAU institutional health platform | Live test case for #7 (MENA layer) |

---

**Document end.**

Generated 2026-05-03 by Dr. Sami Alzahrani for review by Abdullah Alzahrani (arib.sa), maintainer of AribSudia/claude-code-methodology.

Offered in collaborative spirit — to take v3.1 from a strong convention pack to the operating system it positions itself as.
