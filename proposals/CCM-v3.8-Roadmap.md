# CCM v3.8 Roadmap — Axis 2

> Companion to `io/ledger/skill-audit-2026-06-03.md` (Axis 1).
> Author: forensic audit + evidence-gathered structural checks, 2026-06-03.
> **Framing decision:** CCM is C+, not A+, for one dominant reason — the
> ~43K always-on token baseline. The A+ path is **subtraction, not
> addition**. This roadmap is therefore ordered by leverage, and several
> "new skill" proposals are deliberately downgraded to "fold into existing
> surface" or "opt-in, defer." Adding surface to a system whose main flaw
> is too much surface must clear a high bar.

---

## The leverage ranking (what actually moves C+ → A+)

| Rank | Work | Type | Why |
|------|------|------|-----|
| **1** | **Token restructure**: lean core (<8K) + lazy-load reference docs | SUBTRACTION | The single disqualifying flaw. 43K → <8K is the difference between "usable" and "fast". |
| **2** | Add `name:` to all 26 skills + enforce in validator | FIX | The #1 Axis-1 syntax finding; conformance + future-proofing. |
| **3** | Fold skill-linting into `validate-coherence.sh` (the "skill-validate" ask) | FIX/FOLD | Auto-catches #2 forever. No new surface. |
| **4** | Sweep the Axis-1 defect classes (step-numbering, dup sections, dead refs) | FIX | Cheap quality wins across many skills. |
| **5** | `scripts/ccm-health.sh` weekly KPI report | ADD (small) | Self-policing KPIs; aligns with the v3.7 ethos. |
| 6 | `/arib-check-context` as a hook+statusline, NOT a skill | ADD (small) | Useful, but a skill can't measure live tokens — see A1. |
| 7 | Decide agent-memory: wire minimally OR delete the claim | FIX | It's currently dead infra (B2). |
| 8 | `/arib-cross-review` | ADD (opt-in) | Real value but vendor-dependent + token cost; defer until #1 done. |

Everything below #1 is secondary to the token restructure. Build #1 first.

---

## AXIS 2A — the three proposed skills, assessed honestly

### `/arib-check-context` — feasibility: PARTIAL → ship as hook+statusline, not a skill

**The problem with making it a skill:** a SKILL.md body cannot read its own
live token count or an "MI score" — Claude Code does not expose running
context size to skill execution. cc-context-stats (the cited research)
works as a **statusline/CLI telemetry** integration, not a skill. A
300-line `/arib-check-context` skill would be guidance the model recites,
not a measurement.

**Honest design:**
- A `SessionStart`/`PreToolUse` hook computes a *proxy*: always-on bytes
  (from `token-audit.sh`) + a transcript-size signal if the runtime
  exposes one (`$CLAUDE_*` env), and emits 3 thresholds
  (caution / code-only / start-fresh) to stderr + `io/ledger/`.
- Optionally a statusline script (`.claude/statusline.sh`) showing a
  context-health chip live.
- **Verdict: SHIP as a small hook + optional statusline.** Do NOT ship as
  a heavyweight skill. Cost: ~80 lines bash. Honest about what it can and
  can't measure (a proxy, clearly labeled).

### `/arib-skill-validate` — feasibility: HIGH → fold into `validate-coherence.sh`, don't add a skill

This is agnix for CCM, and it's the highest-value item in 2A. But it
**overlaps `validate-coherence.sh`**, which already checks agent
frontmatter, disk counts, dangling `Task(<agent>)` refs, and manifest
freshness. Adding a separate skill duplicates that surface.

**Honest design:** extend `validate-coherence.sh` with a skill-lint pass:
- every `.claude/skills/*/SKILL.md` has `name:` (== dir) AND `description:`;
- `description` is non-generic (length ≥ N, not a placeholder);
- no duplicate section headings (catches the "Failure modes ×2" class);
- no duplicate step numbers (catches the dev-debug/check-services class);
- emit `io/ledger/SKILL_HEALTH_REPORT-<date>.md` with pass/fail + auto-fix
  hints.
- Wire into the existing `coherence.yml` CI job (already required).
- **Verdict: SHIP as a fold-in. No new skill.** This would have caught the
  26× missing-`name:` finding automatically.

### `/arib-cross-review` — feasibility: CONDITIONAL → opt-in, defer to post-token

Cross-LLM review (Gemini/Codex as a second reviewer) has real evidence
behind it, but: it needs external CLIs + API keys (vendor dependency,
against the opt-in principle unless gated), it costs tokens/latency, and
the "~40% fewer escaped defects" figure is from general research, not
measured on CCM.

**Honest design:** a skill that, *if* a second-model CLI is configured
(`CCM_CROSSREVIEW_CMD`), pipes the same review prompt to it and diffs the
findings; divergences → high-priority flags. Degrades to no-op (like the
other opt-in MCPs) when unconfigured.
- **Verdict: DESIGN now, BUILD after the token restructure.** Low priority.
  It adds review rigor to a system that already has a 23-agent review —
  diminishing returns until the core is lean.

---

## AXIS 2B — structural integrity checks (EVIDENCE-BACKED, 2026-06-03)

### B1 — Auto-activation reality check

**Evidence (measured):**
- `0 / 26` skills have a `triggers:` field. `0 / 26` have a `name:` field.
- `15 / 15` agents have `name:` (the v3.7 fix).
- **No skill-invocation telemetry exists on disk** — `io/ledger/` has
  session + drift reports but nothing logging which skills/agents actually
  fired. **Real invocation rate is therefore unmeasurable today.**

**Finding:** auto-activation for skills is *description-only*. Whether a
skill fires depends entirely on the quality of its `description` string;
there is no `triggers` allow-list and no `name`. Explicit `/arib-*`
invocation always works (dir name). The honest conclusion: we cannot claim
an activation rate — we have no instrumentation. This motivates (a) adding
`name:`, (b) a lightweight invocation log, (c) KPI #6 below as "needs
telemetry, not yet measurable" rather than a fabricated number.

### B2 — agent-memory read verification

**Evidence (measured):**
- `.claude/agent-memory/` contains exactly one file: `README.md` (760 B).
  No per-agent memory files exist.
- The ONLY reference to `agent-memory/` anywhere in hooks/skills/agents/
  CLAUDE.md is the project-structure line `CLAUDE.md:97`.
- **Nothing reads or writes it.** No hook injects it at subagent start;
  no agent file instructs reading its own memory; no skill touches it.

**Finding: agent-memory/ is DEAD INFRASTRUCTURE — declared but never read
or written.** The docs imply "persistent memory per agent" that does not
exist in practice. This is a coherence violation (DOCS-MATCH-DISK).
**Decision required:** either (a) wire it — each subagent reads
`.claude/agent-memory/<name>.md` at start and appends learnings at end
(real feature, real token cost), or (b) delete the directory + the
CLAUDE.md claim. Given the token reality, **recommend (b) delete** unless
per-agent memory demonstrably earns its cost. Do not leave it dead.

### B3 — Hook enforcement audit (re-test the v3.7 exit-2 fix)

**Evidence (live re-test, 2026-06-03):**
- `block()` in `lib/common.sh:60` → `exit 2`. ✓
- `{"command":"rm -rf /"}` → **exit 2** (blocks). ✓
- `{"command":"ls"}` → exit 0 (allows). ✓
- No hook uses `exit 1` as a block path. ✓
- `scripts/test-hooks.sh` → **37/37 PASS.** ✓

**Finding: the v3.7 fix HELD.** Enforcement is real, not advisory. This is
CCM's strongest verified property and should be protected by a permanent
regression test (it is — the suite asserts exit 2).

---

## AXIS 2C — CCM Health Score: 10 machine-measurable KPIs

Weekly report → `io/ledger/ccm-health-<date>.md`, produced by a new
`scripts/ccm-health.sh`. Each KPI is tagged **[disk]** (measurable now from
the repo) or **[telemetry]** (requires session instrumentation that does
not yet exist — reported honestly as "not yet measurable", never faked).

| # | KPI | Target | Source | Measurable now? |
|---|-----|--------|--------|-----------------|
| 1 | % skills with valid frontmatter (`name`+`description`) | 100% | lint skills | **[disk]** — today **0%** (no `name:`) |
| 2 | % sessions updating all 6 memory files | 100% | session ledger | [telemetry] |
| 3 | Always-on token cost (and 4-week trend) | <8K (stable/↓) | `token-audit.sh` | **[disk]** — today ~43.4K |
| 4 | Hook block-rate vs warn-rate | 0 warns (block or pass only) | `io/hook-logs/` | **[disk]** — post-exit-2, structurally 0 warns |
| 5 | Agent invocation coverage (all 15 ≥1×/wave) | 100% | invocation log | [telemetry] |
| 6 | Per-skill invocation rate (flag 0% over 30d) | no 0% skills | invocation log | [telemetry] |
| 7 | **Coherence validator status** | green | `validate-coherence.sh` | **[disk]** |
| 8 | **Drift count** (DIFFERS + MISSING vs manifest) | 0 | `drift-detect.sh` | **[disk]** |
| 9 | **Dangling-reference count** (Task/skill/file refs that don't resolve) | 0 | grep + disk check | **[disk]** — agents 0; session-start skill-ref was 1 (now fixed) |
| 10 | **Skill-hygiene defects** (dup section headings + dup step numbers) | 0 | skill-lint | **[disk]** — today ≥7 (dev-debug, check-services, etc.) |

**Why these 4 additions (7–10):** they are the exact defect classes the
Axis-1 audit surfaced, made into standing metrics so they can't silently
return. KPIs 1, 3, 9, 10 would all currently FAIL — which is the point:
the health report should tell the truth about a C+ system.

**Honesty rule for the report:** KPIs 2/5/6 require an invocation/session
telemetry layer that does not exist. The report prints them as
`NOT-MEASURABLE (needs telemetry)` — never a fabricated percentage. Adding
that telemetry is itself a tracked v3.8 task (a `SessionStart`/`Stop` hook
that appends skill+agent invocations to `io/ledger/invocations.jsonl`).

---

## Recommended v3.8 sequence (PR-gated, smallest leverage-ordered steps)

1. **v3.8.0 "Lean Core"** — the token restructure. Move pure reference docs
   (`DECISIONS.md`, `SECURITY.md`, `ERROR_PATTERNS.md`, large training docs)
   out of always-on `context.include` into lazy/path-scoped loading; keep
   `CLAUDE.md` + `CONSTRAINTS.md` always-on. Target <8K. This is the A+ gate.
2. **v3.8.1** — add `name:` to 26 skills + skill-lint fold-in to
   `validate-coherence.sh` + sweep the defect classes (step numbers, dup
   sections, dead refs). Ship `ccm-health.sh` (KPIs 1,3,4,7,8,9,10).
3. **v3.8.2** — decide agent-memory (wire or delete); add invocation
   telemetry hook (unlocks KPIs 2,5,6); ship `/arib-check-context` as a
   hook+statusline.
4. **v3.8.3 (opt-in)** — `/arib-cross-review`, gated on `CCM_CROSSREVIEW_CMD`.

**The honest verdict on the external reviews:** they are right. CCM is an
excellent PoC with real enforcement and self-policing, undermined by token
bloat and surface sprawl. v3.8 should make it *leaner*, and resist the
instinct to answer "needs improvement" with "add more skills." The audit
found the existing 26 are mostly strong (mean depth 8.4); they don't need
siblings, they need a lean core to run in and a linter to keep them honest.
