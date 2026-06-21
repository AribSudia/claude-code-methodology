# Synthesis Campaign — Closing Scorecard (v3.12 → v3.20)

**Date:** 2026-06-21
**Trigger:** the developer's "Synthesis" plan (CCM-v3.13-UPGRADE-PLAN.md, supplied as an
attachment — not committed). This is the final 'Plan deliverable → status in CCM' record,
written at the campaign close (`/loop` iteration 5, v3.20.0).

**Method:** each plan deliverable was assessed against the honesty principle — a capability
that depends on an **absent** tool is never claimed live. Where the value was real but the
tool absent (rtk, Graphify, Ponytail, ECC), CCM shipped a **native equivalent** and said so.
Codex is **present and used live** (verified at setup during the campaign; the exact version
string is not recorded on disk).

## Scorecard

| # | Plan deliverable (Synthesis) | Status | Shipped as | Release / ADR |
|---|------------------------------|--------|------------|---------------|
| 1  | Verification agent — reconcile *discovered* vs *actually fixed* before merge | ✅ Shipped | `verification-agent` (unit + wave scopes) | v3.12 / ADR-027 |
| 2  | Auto-merge by default + `--hold-merge` opt-out | ✅ Shipped | CONSTRAINTS #17 (reconciliation-gated; high-stakes always human) | v3.12 / ADR-027 |
| 3  | Wave validation — objective vs achieved | ✅ Shipped | `verification-agent` wave scope | v3.12 / ADR-027 |
| 4  | Dynamic Workflow/loop for Waves | ✅ Shipped | `/arib-wave-run` auto-advance + Workflow/`/loop` escalation | v3.6 + v3.16 |
| 5  | Memory freshness enforcement | ✅ Shipped | `validate-coherence.sh` §8 (CI-gated) | v3.13 / ADR-028 |
| 6  | Project engineering manager commanding a team | ✅ Shipped | `engineer-manager` (17th agent; only `Task`-holder) | v3.14 / ADR-029 |
| 7  | Unattended mode (maximize auto-fire; intervene only on explicit command) | ✅ Shipped | `operations/AUTONOMY_MODE.md` §9; structural floor preserved | v3.15 / ADR-030 |
| 8  | NestJS skill (plan said "ECC") — *develop ourselves / intelligent graft* | ✅ Shipped (native, not an ECC copy) | `/arib-nestjs` | v3.15 / ADR-030 |
| 9  | PostgreSQL skill | ✅ Shipped (native) | `/arib-postgres` | v3.15 / ADR-030 |
| 10 | `/arib-build` escalates reach — Workflow + `/loop` when needed | ✅ Shipped | Step 0.5 execution-mode table; reach scales, authority doesn't | v3.16 / ADR-031 |
| 11 | Pre-wave requirement lock (grill + adversarial review) | ✅ Shipped | `/arib-wave-plan` (grill + `codex exec`; merge-hold if Codex absent) | v3.17 / ADR-032 |
| 12 | rtk output compression | ✅ Shipped — **honest graceful** | `compress-output.sh` (PostToolUse): records rtk-eligibility, no-op + **no token-savings claim** when rtk absent | v3.18 / ADR-033 |
| 13 | Ponytail over-engineering tripwire | ✅ Shipped (native) | `ponytail-lite.sh` (advisory exit-0) + `/arib-dev-lean` | v3.18 / ADR-033 |
| 14 | Graphify code-graph | ✅ Shipped (native **import** graph) | `/arib-graph` + `build-code-graph.sh`; honest scope (NOT semantic), zero always-on | v3.19 / ADR-034 |
| 15 | Lean the always-on core (recurring token squeeze) | ✅ Shipped | `/arib-*` table → `reference/SKILLS_CATALOG.md`; always-on 7987→7288 (~712 headroom, was 13); CI drift-guard | v3.20 / ADR-035 |
| 16 | ECC repo cherry-picks (specific rules from an external ECC repo) | ⏸ Deferred | Needs the ECC repo URL + license; **ECC absent**. The native `/arib-nestjs` covers the dependency-free majority. | — |
| 17 | Live integrations of absent tools (rtk / Graphify / Ponytail / Obsidian / ECC as runtime deps) | ⛔ Skipped — **honesty principle** | Absent tools never claimed live; native equivalents shipped where feasible (12/13/14). | — |
| 18 | CoWork custom MCP server | ⛔ Out of scope | CCM doesn't own that surface; the CoWork bridge stays an opt-in webhook (no-op unless configured). | — |

## Tally

- **Shipped: 15/18** (all dependency-free, high-value deliverables).
- **Deferred: 1** (ECC cherry-picks — gated on an absent repo + license).
- **Skipped/out-of-scope: 2** (absent-tool live integrations; CoWork MCP) — both by principle, not by omission.

## Campaign invariants held every release

Branch from `origin/main` · token < 8000 (now ~712 headroom) · `validate-coherence`
COHERENT · `validate-system` valid · adversarial pre-merge review (findings fixed) ·
PRs only (no direct push to main) · high-stakes classes always human-merge · honesty
principle (no absent-tool capability claimed live).

## ADR lineage

ADR-027 (reconcile/auto-merge) → ADR-028 (memory freshness) → ADR-029 (engineer-manager) →
ADR-030 (unattended + native stack skills) → ADR-031 (`/arib-build` escalation) →
ADR-032 (wave-plan lock) → ADR-033 (PostToolUse hooks) → ADR-034 (code-graph) →
ADR-035 (lean catalog). **Campaign complete.**
