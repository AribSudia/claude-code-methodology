# Changelog

All notable changes to Claude Code Methodology are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.8.3] "Lean Core" — 2026-06-03

Skill-hygiene sweep, dead-infra removal, and a unified one-prompt entry.
ADR-022.

### Added — the user-friendly method for ALL situations
- `bootstrap/RUN.md` leads with **one auto-routing prompt** + a **Situation
  Router**: detect project state from the filesystem and run the right
  protocol (CCM installed → upgrade; tool markers → migrate; existing code
  → reverse-bootstrap; empty → bootstrap; legacy → migration Appendix A).
  No protocol selection, no wrong choice. The 5 explicit prompts are demoted
  to an "advanced / override" section.

### Removed
- **Standalone Legacy/Migration invocation dropped** — the router
  auto-invokes `MIGRATION_GUIDE.md` on detected tool markers; the user
  never chooses "migrate." The guide remains as the called protocol.
- **`.claude/agent-memory/` deleted** (dead infra — only a README, nothing
  read/wrote it; hybrid memory + `memory/*.md` cover persistence).

### Fixed — skill hygiene (deferred v3.8 defect classes)
- `arib-dev-debug` dup Step 4/5/6 → linear Steps 1-8 (supplementary
  sections un-numbered). `arib-check-services` dup Step 2/3/4 → linear
  Steps 1-5 + reference sections. De-duplicated repeated `##` headings in
  6 skills. `validate-coherence.sh` §3b now reports zero duplicates.

### Upgrade-method audit (answer)
`UPGRADE_PROTOCOL.md` changed materially since v3.1: v3.5.1 made it
decisive (Phase 0 branches, never "stop if same version") + added Phase
1.5 drift detection; v3.7.1 wired it to the real `drift-detect.sh` +
`template-hashes.json`. It never says "already up to date" — always runs
drift detection, refreshes stale templates, preserves project edits.

---

## [3.8.2] "Lean Core" — 2026-06-03

Bootstrap modernization in response to an external review. ADR-021.

### Review verification (honesty first)
The review's #1 "Critical" gap — that `drift-detect.sh` and
`template-hashes.json` "do not exist" — is **FALSE**. Both shipped in
v3.7.1 and are CI-verified; the reviewer tested nothing outside
`bootstrap/` (their own footnote). Its claim that REENGINEERING lacks the
decisive header is also false. Its migration and questionnaire findings
are correct and are actioned below.

### Changed — Migration retired & modernized
- `MIGRATION_GUIDE.md` restructured **"From Any System"**: Step 0 source
  detection (Cursor / Windsurf / Copilot / Kiro / unstructured CLAUDE.md /
  legacy claude-code-system) + per-source mapping §A–§E. The legacy
  `claude-code-system` path is **retired to Appendix A** (intact, marked
  historical) rather than deleted — almost no one is on it in 2026.

### Added
- `bootstrap/RUN.md` — the **reengineering** prompt (5 prompts now, was 4)
  and a modernized "migrate from any system" prompt.
- BOOTSTRAP questionnaire **Q26–Q30** (conditional): AI/LLM integration,
  vector DB/RAG, multi-tenancy, real-time (WS/SSE), edge/serverless —
  asked only when relevant; "no" is a valid common answer.

### Deferred (not built — subtraction discipline)
The review's larger proposals (Coexistence Mode, a unified Bootstrap
Health Score, BOOTSTRAP_TEAMS.md) add surface to a system whose current
strength is leanness. Noted as candidates, not committed; a health score,
if built, should reuse `validate-coherence.sh` / `token-audit.sh`, not a
new framework. The v3.8 skill-hygiene sweep (6 duplicate-heading skills)
also remains tracked by `validate-coherence.sh` §3b.

---

## [3.8.1] "Lean Core" — 2026-06-03

Two v3.8 roadmap items: skill `name:` conformance (the #1 audit finding)
and making the bootstrap protocols systematic/non-interactive. ADR-020.

### Fixed
- **All 26 skills now have a `name:` frontmatter field** (== directory).
  The audit found 0/26 had one — the skills-analog of the v3.7 agent fix.

### Added
- `validate-coherence.sh` §3 now HARD-enforces skill `name:` == dir +
  `description` present (CI-gated). New §3b advisory surfaces duplicate
  section headings within skills.
- `bootstrap/PROTOCOL_PRINCIPLES.md` **Rule 5 — Autonomous Execution**:
  an invoked protocol runs end-to-end without permission-gating. The
  greenfield questionnaire is input (asked once when a new project has no
  facts), not intervention. Genuine blockers remain the only pauses.
- `bootstrap/RUN.md` — the 4 canonical invocation prompts, each specifying
  autonomous-to-completion.

### Changed
- `REVERSE_BOOTSTRAP.md` — two mid-flight "wait for confirmation" gates
  softened to "report inline and proceed" (Rule 5).

### Deferred (tracked, not hidden)
- 6 skills have duplicate section headings; a few have broken step
  numbering. Cosmetic; now surfaced by `validate-coherence.sh` §3b
  (advisory). Sweep in v3.8.2.

---

## [3.8.0] "Lean Core" — 2026-06-03

The headline fix. The single defect keeping CCM at C+ — the ~45.9K
always-on session-start token cost — is resolved. **Always-on context
cut to ~7.4K (84% reduction), UNDER the 8K target for the first time.**

### Changed (the restructure — ADR-019)
- `.claude/settings.json` `context.include` reduced from 13 files to the
  **lean core of 4**: `CLAUDE.md`, `architecture/CONSTRAINTS.md`,
  `memory/project_status.md`, `memory/session_notes.md`. Everything else
  is read **on demand** by the skill/agent/hook that needs it.
- `.claude/rules/session-protocol.md` STEP 1 now reads the lean core only,
  with an explicit on-demand map for the reference docs. Steps renumbered.
- `.claude/skills/arib-session-start/SKILL.md` aligned: lean-core reading;
  TECH_STACK/CONTEXT_MAP/ERROR_PATTERNS marked *read on demand*.
- `CLAUDE.md` §6 reframed as the canonical on-demand loading map, with a
  Lean Core callout naming the 4 always-on files.
- `memory/project_status.md` rewritten lean and current (was a stale
  40-row historical tracker at v3.1/16-skills/8-agents — history belongs
  in CHANGELOG, not always-on context). Saves ~900 tokens + fixes stale.

### Measured result
- Always-on: **45,855 → 7,401 tokens (84% cut)** via `token-audit.sh`.
- Reference docs moved to on-demand: DECISIONS (11.7K), SECURITY (6.1K),
  ERROR_PATTERNS (5.1K), CONTEXT_MAP (3.5K), the 3 implementation schemas
  (9K), WORKFLOW, TECH_STACK.
- `CONSTRAINTS.md` and `CLAUDE.md` stay always-on by design — hard rules
  and governance must be seen before acting (never lazy-loaded).

### Why
Two external reviews and the v3.7 self-audit agreed: token bloat was THE
blocker. The fix is subtraction, not a moved goalpost (ADR-016 forbids
massaging the target). ~38K tokens of headroom returned to every session.
KPI #3 (always-on token cost) now passes.

### Trade-off (honest)
A session that needs a reference doc reads it on demand (one tool call).
The CLAUDE.md §6 map makes "which file to pull" obvious. Hard rules and
current state remain always-on, so nothing safety-relevant is deferred.

---

## [3.7.2] "Self-Policing" — 2026-06-03

Forensic skill audit (all 26 skills, file-grounded) + v3.8 roadmap, plus
the one functional blocker the audit found.

### Fixed (functional blocker)
- `arib-dev-feature` hard-coded `git checkout develop`; the repo is
  main-only, so **every feature start failed at step 2**. Now detects the
  integration branch (`develop` if present, else `main`). The skill ran
  at 0% on main-only projects before this.
- `arib-session-start` referenced `/bootstrap` and `/reverse-bootstrap`
  as slash commands — they are protocol docs, not skills. Corrected to
  point at `bootstrap/BOOTSTRAP.md` / `REVERSE_BOOTSTRAP.md`.

### Added (analysis deliverables)
- `io/ledger/skill-audit-2026-06-03.md` — forensic audit of all 26 skills
  across 5 dimensions (syntax/triggers/depth/coherence/improvement), with
  line citations, a unified table, TOP-5/BOTTOM-5, and 8 cross-cutting
  defect classes. Headline: **0/26 skills have a `name:` field** (the
  skills-analog of the v3.7 agent fix); mean depth 8.4.
- `proposals/CCM-v3.8-Roadmap.md` — evidence-backed v3.8 plan. Structural
  checks verified on disk: B1 (no skill triggers/name + no invocation
  telemetry → activation rate unmeasurable), B2 (**`.claude/agent-memory/`
  is dead infra — only a README, nothing reads/writes it**), B3 (exit-2
  enforcement re-tested, **held**, 37/37). Proposes 10 KPIs (4 measurable
  today, 3 need telemetry, honestly labeled) and a leverage-ordered
  sequence that leads with the **token restructure (43K → <8K)** — the
  real C+→A+ gate — over adding new skills.

### Note
The audit's verdict matches two independent external reviews: CCM's
enforcement and self-policing are genuinely strong; its blockers are
token bloat and surface sprawl. v3.8 should make it leaner, not bigger.

---

## [3.7.1] "Self-Policing" — 2026-05-08

Patch release closing the P2/P3 findings the v3.7.0 review deferred.
No overclaiming — several fixes make a previously-aspirational claim
true or downgrade it to the truth. ADR-018 records it.

### Fixed
- **memory-export.sh no longer pollutes the audit trail.** Failure
  reasons go to STDERR only; the export is appended ONLY on a real,
  non-empty claude-mem dump (last-known-good preserved on failure).
  `memory/semantic_export.md` is seeded with an honest "no live export
  has run yet" header so the reference is never dangling.
- **"seven files" miscount** corrected to six data files in
  MEMORY_PROTOCOL.md, VERSION.json (`memoryFiles` 7→6), CLAUDE.md.
- **PR template** dropped the hard-coded "31/31 pass" (the suite prints
  its own count) and added the coherence check.

### Added
- `scripts/gen-template-hashes.sh` + `reference/template-hashes.json`
  (sha256 manifest of 151 shipped framework files; project-state
  excluded) + `scripts/drift-detect.sh` — the real drift classifier
  that `UPGRADE_PROTOCOL` Phase 1.5 depended on. Classifies
  IDENTICAL/DIFFERS/MISSING and NEVER auto-overwrites (DIFFERS →
  NEEDS-REVIEW, human decides). Replaces the heuristic that could
  clobber user edits — the exact data loss the protocol claimed to
  prevent.
- `validate-coherence.sh` now also checks the manifest exists and its
  version matches VERSION.json (CI-enforced freshness).

### Changed — hook hardening
- pre-tool-use.sh normalizes whitespace before matching (`rm -rf  /`
  double-space, tabs now caught); added `git push -f` /
  `--force-with-lease` short forms, `git clean -fd`, `DROP TABLE`,
  `rm -fr`; added Stripe (`sk_live_`/`sk_test_`/`rk_live_`), GitLab
  (`glpat-`), GitHub fine-grained (`github_pat_`), npm (`npm_`), and
  JWT secret patterns. New fixtures + 5 new regression tests
  (suite now 35+).
- stop.sh ledger records `transport` and `notifications_sent` (the
  fields IO_PROTOCOL promised but the ledger omitted).
- UPGRADE_PROTOCOL Phase 1.5 invokes `scripts/drift-detect.sh` instead
  of describing a heuristic.
- SYSTEM.md / Training/01 stale counts corrected (13→15 agents,
  21→26 skills, 8→15, 7→6 memory files); Training/01 layer framing
  reconciled to canonical 4-Layer (ADR-017).
- VERSION.json bumped 3.7.0 → 3.7.1; scripts 12→14.

### Known remaining (tracked, not hidden)
- GDPR consent/deletion checks remain advisory (gdpr.md), not yet a hook.
- <8K token target remains ~5x off; ratchet plan in ADR-016.
- SYSTEM.md/Training/01 illustrative prose may still reference older
  specifics in places; high-visibility counts are corrected.

---

## [3.7.0] "Self-Policing" — 2026-05-08

A 23-agent workflow review graded CCM v3.6.0 at **C+**: best-in-class
design and honesty, but several load-bearing mechanisms were advisory in
practice rather than enforced — violating CCM's own "ENFORCED not
advisory" and "DOCS-MATCH-DISK" principles. This release fixes the
critical gaps. The unifying theme: **make CCM enforce its own rules.**

### Fixed (critical)
- **`block()` exit code 1 → 2.** Claude Code treats PreToolUse `exit 1`
  as a NON-blocking error; only `exit 2` blocks. Every write-time gate
  (secrets, dangerous-bash, OWASP-A03, design-token, wave-merge) was
  advisory — logging and warning but letting the tool call proceed. Now
  they actually block. `pre-commit.sh` final exit also → 2. The test
  suite's 5 blocking assertions flipped from `1` to `2` (they had
  codified the bug as green). **This is the single highest-leverage fix
  in the system's history.**
- **All 15 agent files now have YAML frontmatter** (`name` == filename,
  `description`, scoped `tools`). Without it, Claude Code could not
  register them as subagents, so every `Task(<agent>)` dispatch in
  skills silently failed to resolve. The agent fleet is now functional,
  not prose. Tool scopes derived from the AGENT_ARCHITECTURE Writes
  column (read-only → Read/Grep/Glob[/Bash]; writers → +Edit/Write).

### Added
- `scripts/validate-coherence.sh` — self-policing validator. Asserts:
  disk counts == VERSION.json (agents/skills/rules/hookScripts); every
  agent has frontmatter with name==filename; every skill has SKILL.md
  with frontmatter; current version string present in
  CLAUDE.md/SYSTEM.md/README; no known stale tokens; every
  `Task(<agent>)` reference resolves. (It immediately caught a real
  drift: VERSION.json said `rules:8` while disk had 9.)
- `.github/workflows/coherence.yml` — runs the validator in CI on every
  PR touching agents/skills/rules/hooks/version docs. `permissions:
  contents: read` + concurrency cancellation.
- ADR-016 (self-policing) and ADR-017 (canonical 4-Layer framing).
- CONSTRAINTS.md constraint #13 (exit-2 + CI-enforced coherence).

### Changed
- Token audit is now honest: `scripts/token-audit.sh` separates
  always-on context (CLAUDE.md + context.include, ~43.4K) from
  path-scoped rules (~4.8K, loaded on demand, previously over-counted
  into the headline). README/VERSION.json corrected from the stale
  ~39.6K to ~43.4K. The <8K target stays, with an honest "over by ~5x"
  and a ratchet-down plan in ADR-016.
- Documentation coherence reconciled: CLAUDE.md identity line
  "5-Layer" → "4-Layer Architecture + I/O Channel + Memory"; stale
  "13 specialist subagents" → 15 and "(14 more skills)" → "(24 more)";
  README "13 specialists" → 15 (two spots); SYSTEM.md "5-Layer Stack" →
  "4-Layer Stack"; VERSION.json `rules` 8 → 9.
- Three "documented but unwired" claims wired or downgraded:
  - `security-auditor.md` now explicitly reads `compliance/frameworks/owasp.md`
    as its rule source (the skills already claimed it did).
  - `io/IO_PROTOCOL.md` no longer claims hooks "watch signals / pre-empt
    a running tool" — corrected to the truth (hooks fire on events, not
    a filesystem watch; mid-session pre-emption needs a push transport).
  - The wave-merge gate now also catches `gh pr merge`; docs note web-UI
    merges are governed by branch protection, not the local hook.
- All 5 GitHub workflows gained `permissions:` + `concurrency:` (they
  would have failed the ci-pr-engineer agent's own checklist).
- VERSION.json stats refreshed: scripts 8→12, githubWorkflows 4→5,
  tokenCostOnSessionStart 39560→43357 with an honesty note.

### Why
The review's root-cause finding: nearly every drift, false count, and
unenforced gate survived because no script validated the invariants the
methodology preaches. The fixes are small and shippable, and none make
CCM overclaim — several trade an aspirational claim for an honest one,
which is exactly what the honesty principle requires.

---

## [3.6.0] "Flowing" — 2026-05-08

Waves now execute themselves. The wave overlay (v3.3) had a plan and an
end gate but no execution engine — CCM would finish a step and ask
"continue?" after every one. v3.6 adds auto-advance: a wave runs
step-to-step without between-steps prompts, pausing only on a genuine
issue or an explicit checkpoint.

This is the v3.5.1 decisive discipline (no continue/stop menus when the
right action is determinable) extended from bootstrap protocols into
wave execution.

### Added
- `.claude/skills/arib-wave-run/SKILL.md` — the wave execution engine
  (skill #26). Reads PLAN.md Steps, executes each, verifies `done_when`,
  commits per step, and **auto-advances**. Pauses only on: step failure
  (per `on_failure`: halt | retry-once | skip-and-flag), a
  `checkpoint: true` step, genuine ambiguity, a blocker, an
  autonomy-guard trip, or a user interrupt. Supports `--from <step>` to
  resume. v3.1-depth skill: 4 examples, decision tree, edge cases,
  failure modes.
- `architecture/DECISIONS.md` ADR-015 — Wave Auto-Advance Execution.
- `architecture/CONSTRAINTS.md` constraint #12 — wave execution
  auto-advances; pauses only on the six enumerated conditions; an
  unverifiable step is treated as ambiguity (pause), never falsely
  marked PASS.

### Changed
- `waves/.templates/PLAN.md` — adds an "Execution mode" section and a
  structured "Steps" contract: each step has `goal`, `done_when`,
  `checkpoint` (default false), `on_failure` (default halt). Includes a
  worked example of a guarded `checkpoint: true` step (prod deploy).
- `.claude/skills/arib-wave-start/SKILL.md` — generates the Steps
  contract; new Step 6 offers to hand off to `/arib-wave-run`.
- `waves/README.md` — lifecycle diagram now shows start → run → end.
- CLAUDE.md §4 skills table grows to 26 (added `/arib-wave-run`);
  identity table bumped.
- VERSION.json, SYSTEM.md, Training/01 bumped to v3.6.0 "Flowing".
  Training/01 also fixed two stale attribute tables (one was still at
  3.3.0 "Operating" — version drift caught and corrected).

### Why
The user reported: "in this wave more than one step, let CCM not ask me
to start next unless [there is an] issue." Asking after every step is
the exact Rule 2 anti-pattern (numbered continue/stop prompts) that
ADR-014 forbade for bootstrap protocols. ADR-015 applies the same fix
to waves.

`checkpoint: true` is the minimal honest exception — irreversible or
high-stakes steps (prod deploy, data migration, external send, spending
money) still get a human gate. `/arib-wave-end` stays explicit: it's
the finish line and merge-to-main control, not a between-steps prompt.

---

## [3.5.1] "Engineered" — 2026-05-08

Patch release fixing decisive-protocol behavior across all 5 bootstrap
protocols. No new capability; corrects pre-existing anti-patterns.

### Why this release exists

A user reported that running `UPGRADE_PROTOCOL.md` on a project with
matching `VERSION.json` (3.1.0 == 3.1.0) hit a Phase 0 STOP rule and
then offered three opt-in alternatives ("1. Force-reapply, 2. Diff
drift check, 3. Drop newer release"). Both behaviors are wrong:
matching versions don't imply matching files (project extensions,
prior partial merges, local edits all produce drift), and numbered
option menus delegate the protocol's own job. ADR-014 records the
decision; this release fixes the protocols.

### Added
- `bootstrap/PROTOCOL_PRINCIPLES.md` — binding charter for the 5
  bootstrap protocols. Four rules (no STOP on matching versions, no
  multiple-choice menus, ask only what's undeterminable, drift
  detection is automatic and complete), 7 legitimate STOP conditions,
  forbidden phrases enumerated.
- `architecture/DECISIONS.md` ADR-014 — Decisive Bootstrap Protocols.
  Records the user report, the principle, and the alternatives
  rejected.
- `architecture/CONSTRAINTS.md` constraint #11 — methodology-level
  rule binding the discipline.

### Changed
- `bootstrap/UPGRADE_PROTOCOL.md`:
  - Phase 0 STOP rule replaced with branching table (template > project
    → continue; template == project → PROCEED to Phase 1.5; template <
    project → honest error).
  - NEW Phase 1.5 (DRIFT DETECTION) — mandatory. Inventory + classify
    each file (IDENTICAL / PROJECT-EXTENSION / STALE-TEMPLATE /
    LOCAL-EDIT / PROJECT-STATE) + auto-refresh stale templates +
    write report to `io/ledger/drift-<date>-<short-hash>.md` with the
    same YAML-style header as `/arib-deep-audit`.
  - Header gains "Decisive behavior" preface.
- `bootstrap/{BOOTSTRAP,REVERSE_BOOTSTRAP,MIGRATION_GUIDE,REENGINEERING_GUIDE}.md`
  — each gets a "Decisive behavior" header note pointing to
  PROTOCOL_PRINCIPLES.md with protocol-specific guidance.
- VERSION.json bumped 3.5.0 → 3.5.1; previousVersion → 3.5.0.
- CLAUDE.md identity table bumped; §6 gains pointer to
  `bootstrap/PROTOCOL_PRINCIPLES.md`.

### Migration notes
- Projects upgrading from v3.5.0 will see the v3.5.1 behavior on the
  next `/arib-session-start` or `UPGRADE_PROTOCOL` invocation.
- Projects on v3.4.x or earlier will benefit from the change once
  they pull v3.5.1; the new Phase 1.5 will run on their first
  upgrade attempt.

---

## [3.5.0] "Engineered" — 2026-05-08

The "Engineered" release promotes CI/PR from static configuration to
an executable methodology subsystem. v3.4 shipped templates, workflows,
and governance docs. v3.5 makes CI/PR review repeatable and bootstrap-
able through the established CCM agent+skill pattern.

### Added — Agent + skill
- `.claude/agents/ci-pr-engineer.md` — new agent (15th in inventory).
  Owns review of the review process: workflows, PR/issue templates,
  CODEOWNERS, branch protection, dependabot, secret scanning, the
  binding rules in CONTRIBUTING.md and SECURITY.md. Read-only by
  default; conditional sequential in `init` mode while parent
  applies writes. Severity ladder maps every finding type to
  BLOCK/WARN/INFO with ADR-012 references.
- `.claude/skills/arib-ci-audit/SKILL.md` — single user-facing entry
  point with four modes:
  - `audit` (default) — full posture check.
  - `init` — bootstrap CI/PR for a fresh project (replaces manual
    file copying).
  - `review <file>` — focused PR-review aid for a single workflow,
    template, or governance doc.
  - `branch-protection` — live query via `gh api` against the binding
    settings in CONTRIBUTING.md §6 and constraint #10.
  Output: `io/ledger/ci-pr-<mode>-<date>.md` using the same YAML-style
  header as `/arib-deep-audit` for shared audit-trail format.

### Added — Records
- `architecture/DECISIONS.md` ADR-013: CI/PR as a Standalone Technique.
  Documents why agent+skill pair was chosen over alternatives
  (multiple skills, write-by-default agent, session-start hook).
- `architecture/AGENT_ARCHITECTURE.md` — agent inventory grows from
  13 to 15 (added `planner` from earlier work + `ci-pr-engineer`).
  New parallel-dispatch Recipe 4 (wave start: architect+planner) and
  Recipe 5 (CI/PR audit composing into deep-audit section 9).
- `Training/11-CI-PR-MANUAL.md` — gains "What v3.5 adds" section
  documenting the agent and skill, severity ladder, when to run.

### Changed
- README, CLAUDE.md, SYSTEM.md, Training/01, VERSION.json bumped to
  v3.5.0 "Engineered".
- CLAUDE.md §4 skills table grows from 24 to 25 entries (added
  `/arib-ci-audit`); §5 agents from 14 to 15.

### Why
ADR-012 (v3.4) made CI/PR a first-class artifact. But the artifacts
were static — no agent owned them, no skill made them executable.
Quarterly review and project bootstrap had no methodology-side entry
point. v3.5 closes that gap with the standard CCM extension pattern.

The agent is read-only and parallel-safe in audit mode, so it composes
into `/arib-deep-audit` as section 9. The skill's `init` mode replaces
manual file copying when bootstrapping CCM into fresh projects.

---

## [3.4.0] "Reviewed" — 2026-05-08

The "Reviewed" release closes the loop: CCM now lives by the discipline
it teaches. A repo that recommends PR governance to its users while
pushing straight to main can't be taken seriously. v3.4 adopts GitHub's
PR/CI best practices as a first-class methodology artifact alongside
hooks, waves, and compliance.

### Added — GitHub plumbing
- `.github/PULL_REQUEST_TEMPLATE.md` — binding contract for every PR:
  summary, type, ADR/issue links, test plan, token-budget delta, wave
  audit hash, compliance impact, reviewer checklist.
- `.github/ISSUE_TEMPLATE/{bug_report,feature_request,security}.yml` +
  `config.yml` — structured triage. Security template explicitly
  routes HIGH/CRITICAL severity to GitHub private advisories.
- `.github/CODEOWNERS` — auto-routes review for hooks, architecture
  records, compliance, gate skills, methodology brain, and `.github/`.
- `.github/dependabot.yml` — weekly updates for github-actions and
  npm; security patches grouped.
- `.github/workflows/json-validate.yml` — validates every committed
  JSON file plus VERSION.json semver shape, .mcp.json, settings.json.
- `.github/workflows/token-budget.yml` — measures session-start cost
  on PRs (base vs head), comments delta, fails at >10K regression.
- `.github/workflows/markdown-lint.yml` — markdownlint-cli2 + TODO/
  FIXME detection in shipped docs.
- `.markdownlint.json` — lint config tuned for the project's style.

### Added — Governance docs
- `CONTRIBUTING.md` — full workflow: branch naming, Conventional
  Commits, test discipline, branch protection settings to apply, how
  to add hooks/skills/agents, release procedure.
- `SECURITY.md` (repo-root) — vulnerability disclosure policy. Threat
  surface, out-of-scope, reporting paths (private advisory for
  HIGH/CRITICAL), SLA per severity.
- `CODE_OF_CONDUCT.md` — Contributor Covenant 2.1.

### Added — Methodology integration
- `.claude/rules/ci-pr.md` — path-scoped rules that auto-load when
  editing `.github/**`, `CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, or workflow files. 10 binding rules.
- `architecture/DECISIONS.md` ADR-012 — CI/PR Governance Model.
- `architecture/CONSTRAINTS.md` constraint #10 — PRs through CI green
  and CODEOWNERS-approved; direct pushes to main reserved for
  emergencies and logged in `operations/OPERATIONS_LOG.md`.
- `Training/11-CI-PR-MANUAL.md` — user-facing manual matching the
  existing 10-manual structure.
- `bootstrap/BOOTSTRAP.md` STEP 4 — now activates CI/PR governance
  alongside hook installation; enumerates files to copy and branch
  protection settings to apply.

### Changed
- `architecture/CONTEXT_MAP.md` — adds `.github/` to allowed_write_paths
  so the path-scoping hook permits workflow edits.
- README, CLAUDE.md, SYSTEM.md, Training/01, VERSION.json bumped to
  v3.4.0 "Reviewed".

### Why
v3.3 "Operating" was the system shipped. v3.4 "Reviewed" is the
discipline that keeps it shipping correctly. Bootstrapped projects
inherit the scaffolding by default — CCM models the governance it
recommends.

### Honesty notes
- Branch protection rules are GitHub web-UI settings, not files. They
  are documented in `CONTRIBUTING.md` §6 and applied once by the repo
  owner. The maintainer's prior direct-push-to-main pattern is now an
  emergency-only exception, not the norm.
- The MCP package names from v3.3 remain placeholders (cowork) /
  verified (claude-mem, testsprite). No change here.

---

## [3.3.0] "Operating" — 2026-05-08

The "Operating" release ships the eight items from the original v3.2
"Enforced" proposal that the v3.2 "Honest" counter-proposal had deferred.

**Why the override?** After v3.2 "Honest" landed, the maintainer reversed
the deferral and asked for the full proposal scope. The work was completed
with the safeguards from the counter-proposal carried forward — every new
MCP server stays opt-in, every framework doc states honestly what CCM can
and cannot enforce, no false certification claims.

A 20-agent parallel audit then verified the implementation against the
proposal. This release also fixes the gaps that audit surfaced: the
wave-merge gate ledger format, the missing `compliance/` write-path, the
missing `planner` agent, the missing `arib-check-security` skill, version
drift across 5 files, and 7 unregistered skills.

### Added — Hybrid Memory (Item #3)
- `.mcp.json` — opt-in `claude-mem` MCP stub.
- `scripts/memory-export.sh` — exports semantic store to
  `memory/semantic_export.md`. No-op when MCP unavailable.
- `.claude/skills/arib-memory-search/SKILL.md` — semantic-first with
  grep fallback.
- `memory/MEMORY_PROTOCOL.md` — hybrid section + privacy note.

### Added — Real I/O Transport (Item #4)
- `.mcp.json` — opt-in `cowork` MCP stub.
- `.claude/hooks/notification.sh` — Notification event hook.
- `.claude/hooks/lib/common.sh` — `notify_cowork()` fans out to both
  `CCM_COWORK_WEBHOOK` and `CCM_NOTIFY_WEBHOOK`.
- `io/IO_PROTOCOL.md` — Transport+Ledger split documented.

### Added — Deep Audit (Item #5)
- `.claude/skills/arib-deep-audit/SKILL.md` — 21-section audit with
  IMPLEMENT-FROM-FILE mode and a defined ledger format
  (`wave: <name>` + `audit-hash: <sha>` keys are the contract that the
  wave-merge gate and `arib-wave-end` skill grep for).

### Added — Wave Delivery Overlay (Item #6)
- `waves/README.md`, `WAVE_HISTORY.md`, `.templates/{PLAN,REPORT}.md`.
- `.claude/skills/arib-wave-start/SKILL.md` — scaffolds wave + parallel
  architect+planner dispatch.
- `.claude/skills/arib-wave-end/SKILL.md` — runs `/arib-deep-audit`,
  generates REPORT, tags audit hash.
- `.claude/agents/planner.md` — sequence, dependencies, risks, blockers.
- `.claude/hooks/pre-tool-use.sh` — wave-merge gate blocks `git push|merge`
  to main from `wave/*` without an audit-hash matching the wave.

### Added — Compliance Layer (Item #7 expanded)
- `compliance/README.md` — explicit honesty principle.
- `compliance/COMPLIANCE.md` — cross-framework controls map.
- `compliance/frameworks/{owasp,gdpr,iso27001,soc2,mena-pdpl}.md` —
  per-framework alignment with code-checkable vs operational distinction.
- `.claude/skills/arib-check-arabic/SKILL.md` — typography, RTL,
  numerals, mirroring, KSA institutional checks.
- `.claude/skills/arib-check-compliance/SKILL.md` — meta-skill across
  all frameworks; outputs alignment reports, never "compliant" claims.
- `.claude/skills/arib-check-security/SKILL.md` — OWASP + supply chain
  entry point, delegates to security-auditor agent + arib-check-deps.
- `.claude/rules/i18n-ar.md` — path-scoped Arabic rules.
- `.claude/hooks/pre-tool-use.sh` — OWASP A03 write-time blocks
  (eval, new Function, exec template-literal).
- `.claude/hooks/pre-commit.sh` — PII-in-log-line patterns.

### Added — Design System (Item #8)
- `architecture/DESIGN_SYSTEM.md` — visual contract.
- `.claude/skills/arib-check-design/SKILL.md` — token discipline,
  component baseline, typography, dark-default, motion.
- `.claude/hooks/pre-tool-use.sh` — write-time block on raw color
  literals in components (exempts tokens/theme/test paths).

### Added — TestSprite Gate (Item #9)
- `.mcp.json` — opt-in `testsprite` MCP stub.
- `arib-check-deploy/SKILL.md` Step 4 — real cloud test run when
  configured, honest LOCAL-ONLY fall-through otherwise.
- `operations/MONITORING.md` — synthetic monitoring section.

### Added — Autonomy Mode (Item #10)
- `operations/AUTONOMY_MODE.md` — preconditions, guardrails,
  post-conditions, recovery protocol.
- `.claude/hooks/autonomy-guard.sh` — fast-path no-op unless
  `CCM_AUTONOMY=1`. Wall-clock cap, calls-since-commit cap, BLOCK rate
  cap, refuses unsanctioned push to main.

### Added — Operational records
- `architecture/AGENT_ARCHITECTURE.md` — 14 agents with read/write
  surfaces and parallel-dispatch governance.
- `scripts/token-audit.sh` — measured baseline 39,560 tokens (target 8K).

### Changed
- README and CLAUDE.md identity table bumped to v3.3.0 "Operating".
- VERSION.json bumped (was 3.1.0; skipped 3.2.0 in this file).
- SYSTEM.md bumped (was 2.6.0).
- Training/01-SYSTEM-OVERVIEW.md bumped (was 2.6.0).
- CLAUDE.md §3 project structure now lists `compliance/` and `waves/`.
- CLAUDE.md §4 skills table grew from 16 to 24 entries.
- CLAUDE.md §5 agents from 13 to 14 (added `planner`).
- `architecture/CONTEXT_MAP.md` — adds `compliance/` to allowed_write_paths.
- `arib-session-end/SKILL.md` — replaces dangling `/arib-consolidate-memory`
  reference with `/arib-memory-search`.

### Honesty notes
- Three MCP package names in `.mcp.json` are placeholders — verify
  against npm before relying on them. Marked clearly in the `_comment`
  field. Skills degrade gracefully without them.
- Token cost remains far above the proposal's 8K target. The audit
  script is committed so the gap stays visible. Trim recommendations
  in commit `edf1acb` (Item B).

---

## [3.2.0] "Honest" — 2026-05-08

The "Honest" release closes the gap between CCM's marketing and what shipped on
disk. Three items: hooks enforcement (advisory rules become enforced rules),
token discipline + README rewrite (positioning matches reality), and agent
architecture documentation (parallel review is a documented capability rather
than a buried possibility).

Eight items from the v3.2 "Enforced" proposal were deliberately deferred — see
`proposals/archive/CCM-v3.2-Minimal-Counter-Proposal.md` for the rationale.

### Added — Hooks Enforcement Layer (Item A)
- `.claude/hooks/lib/common.sh` — shared helpers (logging, JSON payload parsing,
  path scoping, opt-in CoWork webhook).
- `.claude/hooks/pre-tool-use.sh` — secret detection, path scoping via
  CONTEXT_MAP `allowed_write_paths`, dangerous bash command blocklist.
  Test/fixture paths exempted from secret scans.
- `.claude/hooks/pre-commit.sh` — blocks credential files, secret patterns,
  oversized files, and debug statements in production source files.
- `.claude/hooks/session-start.sh` — CLAUDE.md drift detection, protected-branch
  warning, captures session-start SHA for accurate stop-hook diffs.
- `.claude/hooks/stop.sh` — writes per-session ledger to `io/ledger/` using the
  start-SHA marker (no fragile `HEAD~N` math).
- `scripts/install-hooks.sh` — idempotent installer; wires git pre-commit hook,
  verifies dependencies, smoke-tests session-start.
- `architecture/CONTEXT_MAP.md` — `allowed_write_paths` block defining which
  directories Claude may write into.

### Added — Token Discipline (Item B)
- `scripts/token-audit.sh` — measures tokens consumed by CCM scaffolding on a
  cold session start. Target: <8K tokens.

### Added — Agent Architecture (Item C)
- `architecture/AGENT_ARCHITECTURE.md` — all 13 agents with parallel-dispatch
  safety, state surfaces, and trigger keywords.
- `arib-dev-review` skill refactored to dispatch reviewer + security + tester
  in a single parallel Task call instead of sequential invocations.

### Changed
- `README.md` rewritten to drop "AI Development Operating System" framing in
  favor of "opinionated methodology + skill pack". Lines-of-markdown removed
  as a featured metric.
- `.claude/settings.json` hooks block now wires real enforcement scripts
  (previous version was a placeholder echoing log lines).
- `.gitignore` adds `io/hook-logs/` and `io/.session-start-sha`. `io/ledger/`
  is intentionally **not** ignored — it's the audit trail.

### Why
v3.1.0 documented an enforcement layer that did not exist on disk. v3.2.0
ships the layer the documentation already promised, and rewrites the parts of
the README that the layer alone could not redeem.

---

## [3.1.0] "Deep Skills" — 2026-04-19

### Changed
- **All 16 skills enriched to Anthropic-grade depth**: Every `arib-*/SKILL.md` transformed from basic checklists (~70 lines each) into comprehensive, self-contained reference documents (250-800 lines each). Total skill content grew from ~1,100 lines to 7,393 lines (6.7x increase).
- Skills now include: detailed overviews explaining *why* each skill matters, decision trees for edge cases, concrete code examples (good vs bad patterns), severity classifications, reusable templates, common mistakes with fixes, and cross-references to related skills.
- This aligns with Anthropic's official skill depth pattern — their production skills (docx, algorithmic-art, skill-creator) are comprehensive reference documents, not step-by-step checklists.

### Enriched Skills (all 16)
- **Session**: `arib-session-start` (302 lines), `arib-session-end` (448 lines)
- **Dev**: `arib-dev-feature` (253 lines), `arib-dev-review` (569 lines), `arib-dev-debug` (327 lines)
- **Check**: `arib-check-a11y` (453 lines), `arib-check-deploy` (481 lines), `arib-check-deps` (484 lines), `arib-check-migrate` (386 lines), `arib-check-perf` (328 lines), `arib-check-reality` (412 lines), `arib-check-services` (414 lines)
- **Docs**: `arib-docs-api` (396 lines), `arib-docs-generate` (575 lines), `arib-docs-language` (766 lines), `arib-io` (799 lines)

### Why v3.1 (Minor Version)
No breaking changes — all skill frontmatter (description, argument-hint) preserved. This is a quality upgrade: skills that previously told Claude Code *what to do* now teach it *how to think about each task*, with the depth and decision-making context needed for autonomous operation.

---

## [3.0.0] "Aligned" — 2026-04-19

### BREAKING CHANGES
- **Commands migrated to Skills**: All 16 `arib-*.md` commands migrated from `.claude/commands/` to `.claude/skills/arib-*/SKILL.md`. Legacy commands kept for backward compatibility but skills take precedence. This aligns with Anthropic's official deprecation of `.claude/commands/` in favor of `.claude/skills/`.
- **CLAUDE.md slimmed from 650 to 179 lines**: Domain-specific rules extracted into `.claude/rules/` path-scoped files. CLAUDE.md now contains only core identity, golden rules, and routing table.

### Added
- `.claude/rules/` — 7 path-scoped rule files that load only when relevant files are touched:
  - `io-channel.md` (paths: io/**) — I/O channel architecture, request types, signals
  - `memory.md` (paths: memory/**) — Memory hierarchy, files, update rules
  - `session-protocol.md` — Session start/work/end lifecycle (always loaded)
  - `agents.md` (paths: .claude/agents/**) — Agent activation table and rules
  - `hooks.md` (paths: hooks/**) — Hook types, configuration, exit codes
  - `architecture.md` (paths: architecture/**) — Architecture layer rules
  - `implementation.md` (paths: implementation/**) — Implementation layer rules
- `.claude/skills/` — 16 branded skills migrated from commands, each as `arib-*/SKILL.md`
- `.mcp.json` — Project-scoped MCP server configuration at project root (official pattern)
- `.claude/settings.local.json` — Personal settings overrides (gitignored)
- `.claude/agent-memory/` — Persistent memory per subagent (project scope)
- `.claude/output-styles/` — Custom output styles for the project
- `.worktreeinclude` — Gitignored files to copy into new worktrees
- `.gitignore` updated with `.claude/settings.local.json` and `.claude/agent-memory-local/`

### Changed
- CLAUDE.md: 650 lines -> 179 lines (under 200-line best practice target)
- 4-Layer Architecture diagram updated: L2 now references `.claude/skills/*/SKILL.md`
- File system map rewritten to show new structure (skills, rules, .mcp.json, agent-memory)
- All 4 bootstrap files updated to generate skills instead of commands
- UPGRADE_PROTOCOL.md updated with skills/rules/MCP migration steps
- `validate-system.sh` rewritten for v3.0 structure (checks skills, rules, .mcp.json, agent-memory)
- VERSION.json: renamed `commands` -> `skills`, added `rules` count

### Why v3.0 (Major Version)
This is a structural breaking change that aligns CCM with the official Claude Code architecture as documented at code.claude.com. The three key alignments are: (1) commands -> skills migration following Anthropic's deprecation, (2) path-scoped rules for modular CLAUDE.md following official best practices, (3) .mcp.json for MCP server configuration following the official plugin standard. Projects using v2.x commands will still work (legacy commands preserved) but should migrate to skills.

---

## [2.9.0] "Connected" — 2026-04-19

### Added
- **`/arib-io` Command**: I/O Channel bridge - check signals, process requests from Cowork, write results, update dashboard (9-step workflow)
- **`/arib-check-services` Command**: Full infrastructure health check - Docker containers, backend API, frontend dev server, database, Redis, ports, inter-service connectivity
- **Cowork Role Prompt** (`io/COWORK_PROMPT.md`): Full copy-paste prompt for Claude Cowork explaining its role, the I/O channel, how to write requests, and how to direct Claude Code

### Design Decisions
- **`/arib-session-start` stays simple**: No I/O channel check - keeps it clean for any new starter. I/O processing is exclusively in `/arib-io`
- **Command responsibility separation**: session-start (context), arib-io (Cowork bridge), check-services (infrastructure)
- **16 commands total**: 3 session, 3 dev, 7 check, 3 docs

---

## [2.8.0] "ARIB" — 2026-04-19

### Added
- **Official ARIB Brand**: All 14 commands now use fixed `arib-` prefix across all projects
- **Single Brand Policy**: No more per-project prefix rename — one brand for everything

### Changed
- **All 14 Commands Renamed**: `ccm-*` → `arib-*` (official brand)
  - `ccm-session-start.md` → `arib-session-start.md`
  - `ccm-session-end.md` → `arib-session-end.md`
  - `ccm-dev-feature.md` → `arib-dev-feature.md`
  - `ccm-dev-debug.md` → `arib-dev-debug.md`
  - `ccm-dev-review.md` → `arib-dev-review.md`
  - `ccm-check-deploy.md` → `arib-check-deploy.md`
  - `ccm-check-reality.md` → `arib-check-reality.md`
  - `ccm-check-migrate.md` → `arib-check-migrate.md`
  - `ccm-check-perf.md` → `arib-check-perf.md`
  - `ccm-check-deps.md` → `arib-check-deps.md`
  - `ccm-check-a11y.md` → `arib-check-a11y.md`
  - `ccm-docs-api.md` → `arib-docs-api.md`
  - `ccm-docs-generate.md` → `arib-docs-generate.md`
  - `ccm-docs-language.md` → `arib-docs-language.md`
- **COMMAND_PREFIX.md**: Simplified to single `arib` brand, removed per-project rename logic
- **BOOTSTRAP.md**: Removed Q26 (prefix question), simplified to direct `arib-*` copy
- **REVERSE_BOOTSTRAP.md**: Removed prefix detection, simplified to direct `arib-*` copy
- **UPGRADE_PROTOCOL.md**: Removed prefix rename logic, simplified to direct `arib-*` copy
- **MIGRATION_GUIDE.md**: Removed prefix rename logic, simplified to direct `arib-*` copy
- **CLAUDE.md**: File system map updated to `arib-*` filenames
- **VERSION.json**: `commandPrefix` changed from `ccm` to `arib`
- **validate-system.sh**: Now checks `arib-*` command files

### Fixed
- **Command Discovery**: Removed emoji characters (▶, 🔵, 🔴, 📄, ⏹) from YAML frontmatter descriptions — these prevented Claude Code from parsing commands
- **Em-dash Characters**: Replaced Unicode em-dashes (—) with ASCII dashes (-) in all frontmatter — another cause of YAML parse failure
- **YAML Consistency**: Standardized all description fields to unquoted plain text

---

## [2.7.0] "Branded" — 2026-04-19

### Added
- **Branded Command System**: All 14 commands now use `{prefix}-{category}-{name}` pattern
- **4 Command Categories**: Session (▶), Dev (🔵), Check (🔴), Docs (📄)
- **Hierarchical Autocomplete**: Type `/{prefix}` to see all, `/{prefix}-check` to filter
- **Command Prefix Reference**: `reference/COMMAND_PREFIX.md` — naming guide + rename script
- **Bootstrap Q26**: New question asks for command prefix during project setup
- **Auto-Prefix in Upgrade**: Upgrade protocol auto-detects existing prefix and preserves it
- **Executable Prompts**: All 4 bootstrap files now have copy-paste prompts for Claude Code
- **Deployment Verification**: Every bootstrap enforces file creation in PROJECT ROOT

### Changed
- **BOOTSTRAP.md**: Added Q26 (prefix), deployment rules, branded command generation
- **REVERSE_BOOTSTRAP.md**: Added prefix detection, branded command deployment
- **UPGRADE_PROTOCOL.md**: Complete rewrite with executable prompt, CLAUDE.md merge rules
- **MIGRATION_GUIDE.md**: Added branded command migration from flat names
- **CLAUDE.md**: Updated file system map to show branded command names
- **VERSION.json**: Added `commandCategories`, `commandPrefix` fields

### Renamed (14 commands)
- `session-start.md` → `ccm-session-start.md`
- `session-end.md` → `ccm-session-end.md`
- `new-feature.md` → `ccm-dev-feature.md`
- `debug.md` → `ccm-dev-debug.md`
- `review.md` → `ccm-dev-review.md`
- `deploy-check.md` → `ccm-check-deploy.md`
- `reality-check.md` → `ccm-check-reality.md`
- `migrate-check.md` → `ccm-check-migrate.md`
- `perf-check.md` → `ccm-check-perf.md`
- `dependency-audit.md` → `ccm-check-deps.md`
- `a11y-audit.md` → `ccm-check-a11y.md`
- `api-docs.md` → `ccm-docs-api.md`
- `document.md` → `ccm-docs-generate.md`
- `language-audit.md` → `ccm-docs-language.md`

### Fixed
- Bootstrap files now explicitly instruct Claude Code to WRITE files to project root
- CLAUDE.md is now MERGED during upgrades (not replaced), preserving project data
- All bootstrap files include copy-paste prompts with CONTEXT, YOUR JOB, CRITICAL RULES

---

## [2.6.0] "Fortress" — 2026-04-18

### Added
- **API Documentation Agent** — `.claude/agents/api-docs.md`
  - 8-step protocol: discover endpoints → extract details → check existing docs → validate schemas → generate OpenAPI → human-readable docs → detect design issues → report
  - Multi-framework: Express, Next.js, FastAPI, .NET, Django, Go/Gin
  - Sync status classification: DOCUMENTED, UNDOCUMENTED, STALE, GHOST, NEW
  - Generates valid OpenAPI 3.0+ specification from code
  - API design issue detection (inconsistent naming, missing pagination, verb in URL)
- **/api-docs Command** — `.claude/commands/api-docs.md`
  - Scoped: `/api-docs`, `/api-docs /api/users`, `/api-docs --generate`, `/api-docs --sync`, `/api-docs --validate`
- **Accessibility Auditor Agent** — `.claude/agents/accessibility.md`
  - 7-step protocol: semantic HTML → color contrast → keyboard navigation → ARIA usage → dynamic content → responsive/motion → report
  - Complete WCAG 2.1 Level A + Level AA checklist (Perceivable, Operable, Understandable, Robust)
  - Color contrast ratio verification (4.5:1 normal, 3:1 large text)
  - Keyboard navigation audit (focus order, focus visibility, skip links, focus traps)
  - ARIA rules of use (5 rules), dynamic content live regions, tabindex validation
  - Responsive accessibility (prefers-reduced-motion, zoom restrictions, reflow)
- **/a11y-audit Command** — `.claude/commands/a11y-audit.md`
  - Scoped: `/a11y-audit`, `/a11y-audit src/components/LoginForm.tsx`, `/a11y-audit --contrast`, `/a11y-audit --keyboard`
- **Production Monitoring Guide** — `operations/MONITORING.md`
  - Monitoring pyramid (synthetic → infrastructure → application → business)
  - Health check standard with response format and implementation examples (Express, FastAPI)
  - Four Golden Signals (latency, traffic, errors, saturation) with alerting thresholds
  - SLOs, SLIs, and Error Budgets with calculation tables (99% → 99.99%)
  - Alert classification (P1-P4) with Prometheus alert rules examples
  - Dashboard design (3-level hierarchy: executive → service → debug)
  - On-call rotation, escalation policy, handoff template
  - Monitoring stack options (open source vs managed)
  - Monitoring checklists: every project, production launch, quarterly review
- **Training Manuals** — `Training/` directory (10 comprehensive manuals)
  - System Overview, Agents, Skills, Hooks, Commands, I/O Channel, Memory, Bootstrap, Microservices, Production Safety
- **Feature categories 4.20–4.22** — API Documentation (3), Accessibility (3), Production Monitoring (3)

### Changed
- **CLAUDE.md** — Version 2.6.0 "Fortress", agent table (13 agents), file system map updated
- **SYSTEM.md** — Version 2.6.0, feature count 113→122, 19→22 categories, agent diagram (13 agents)
- **README.md** — 13 agents, 14 commands, 122 features, directory tree updated
- **VERSION.json** — Bumped to 2.6.0 (96 files, 122 features, 13 agents, 14 commands, 10 training manuals)

---

## [2.5.0] "Guardian" — 2026-04-18

### Added
- **Database Guardian Agent** — `.claude/agents/database-guardian.md`
  - 8-step Migration Safety Protocol: detect framework → read migrations → classify risk → analyze table sizes → check dangerous patterns → verify rollback → generate report
  - Risk classification: LOW (ADD nullable column) → MEDIUM (ADD index) → HIGH (ALTER column type) → CRITICAL (DROP TABLE)
  - Safe migration patterns: 3-step NOT NULL addition, 4-step column rename, CONCURRENTLY index creation
  - Size-aware analysis: different strategies for <100K, 100K-1M, 1M-10M, >10M row tables
  - Pre-migration checklist, dangerous operation detection, backup protocol, post-migration verification
  - N+1 detection checklist, index strategy guide
- **Performance Profiler Agent** — `.claude/agents/performance.md`
  - 7-step Performance Audit Protocol: backend scan → frontend scan → DB query analysis → memory/resource scan → caching audit → load testing guide → report generation
  - Performance Budget System: API (p50<100ms, p99<500ms, ≤5 queries/req), Frontend (JS<200KB gzipped, LCP<2.5s, CLS<0.1), Database (query p50<10ms, p99<100ms)
  - N+1 query detection with patterns and fixes (Prisma include, Django select_related)
  - Bundle analysis (webpack-bundle-analyzer, vite-bundle-visualizer)
  - Memory leak pattern detection (missing cleanup in useEffect, unclosed streams)
  - Caching audit checklist (what to cache, what not to, invalidation strategies)
  - Load testing guide (k6, Artillery, Locust, JMeter) with 5 test scenarios
- **/migrate-check Command** — `.claude/commands/migrate-check.md`
  - Detects migration framework (Prisma, Knex, Sequelize, TypeORM, Django, Alembic, Entity Framework)
  - Reads pending migration files, classifies risk per operation
  - Checks for dangerous patterns: DROP without backup, ALTER TYPE on large tables, CREATE INDEX without CONCURRENTLY
  - Verifies rollback plan exists and is valid
  - Generates Migration Safety Report with verdict: APPROVED / APPROVED WITH CONDITIONS / BLOCKED
- **/perf-check Command** — `.claude/commands/perf-check.md`
  - Scoped audit: `/perf-check`, `/perf-check api`, `/perf-check frontend`, `/perf-check database`
  - Activates Performance Profiler agent with 7-step protocol
  - Produces Performance Audit Report with scores per area and optimization plan
- **/dependency-audit Command** — `.claude/commands/dependency-audit.md`
  - Multi-ecosystem support: npm, Yarn, pnpm, pip, NuGet, Go modules, Cargo, Bundler
  - Vulnerability scan (CVE detection via npm audit, pip-audit, govulncheck, etc.)
  - Outdated package check with major/minor/patch classification
  - License compliance audit: MIT/ISC/BSD=safe → MPL/LGPL=moderate → GPL/AGPL=high risk → Unlicensed=critical
  - Supply chain risk detection: typosquatting, postinstall scripts, package provenance
  - Auto-fix capability with `--fix` flag (PATCH updates only, test after update)
- **Incident Response Protocol** — `operations/INCIDENT_RESPONSE.md`
  - Severity classification (SEV1-4) with decision tree
  - "First 5 Minutes" protocol for SEV1/SEV2: confirm → communicate → assess
  - Rollback Decision Framework with 5 rollback methods (git revert, deploy previous version, K8s rollout undo, Helm rollback, feature flag)
  - Investigation protocol with symptom→cause→check correlation table
  - Communication protocol with status update templates and timing
  - Full blameless post-mortem template: timeline, root cause, impact, action items, lessons learned
  - 3 runbooks: Service Won't Start, Database Connection Exhaustion, High Error Rate
  - Incident response checklists for all projects + microservices additional
- **Feature categories 4.16–4.19** — Database Safety (3), Performance Engineering (3), Supply Chain (2), Incident Response (3)

### Changed
- **CLAUDE.md** — Version 2.5.0 "Guardian", agent table (11 agents including Database Guardian + Performance Profiler), file system map (added database-guardian.md, performance.md, migrate-check.md, perf-check.md, dependency-audit.md, INCIDENT_RESPONSE.md)
- **SYSTEM.md** — Version 2.5.0, feature count 102→113, 15→19 categories, agent diagram (11 agents), operations layer (4 files), version history updated
- **README.md** — 11 agents, 12 commands, 113 features, directory tree updated, agent table expanded
- **VERSION.json** — Bumped to 2.5.0 (91 files, 113 features, 11 agents, 12 commands, 6 operations files)

---

## [2.4.0] "Sentinel" — 2026-04-18

### Added
- **Reality Auditor Agent** — `.claude/agents/reality-auditor.md`
  - 10-step protocol: mock library detection → hardcoded data scan → API connection audit → auth reality check → component classification → dependency mapping → remediation plan → execution order → verification
  - Detects: faker/MSW/miragejs in production code, hardcoded arrays, setTimeout-simulated APIs, `isAuthenticated = true` hardcoded, Lorem ipsum, disconnected frontend-backend wiring
  - Reality classification system: 🟢 REAL, 🟡 PARTIAL, 🔴 FAKE, ⚫ DISCONNECTED, ⚪ STATIC
  - Calculates Reality Score (% of genuinely connected components)
  - Generates phased remediation plan (Foundation → Data Layer → Cleanup) with before/after code snippets
  - Integration with Code Reviewer, Deploy Guardian, Test Engineer, Debugger agents
  - Framework-specific mock patterns: React/Next.js, Vue/Nuxt, Angular, Node.js, Python, .NET
- **/reality-check Command** — `.claude/commands/reality-check.md`
  - Full codebase or scoped scan (`/reality-check frontend`, `/reality-check auth`)
  - Outputs Reality Score, findings table, mock library inventory, remediation plan
  - YAML frontmatter for Claude Code `/` autocomplete
- **Services Health Check Script** — `scripts/services-check.sh`
  - Verifies ALL microservices are running and healthy before development
  - Commands: `--start` (start all + check), `--wait` (poll until healthy), `--restart`, `--stop`, `--status`
  - Checks container state + health endpoint (HTTP /health) for each service
  - Color-coded output with pass/fail summary
  - Configurable via environment variables (COMPOSE_FILE, HEALTH_TIMEOUT, WAIT_TIMEOUT)
- **Dev Orchestration Protocol** — `operations/ORCHESTRATION.md §9`
  - Rule: ALL services MUST be running during development — partial infrastructure produces false results
  - Session-start integration: services-check runs automatically for microservices projects
  - Agent integration rules: which agents must verify services before proceeding
  - Hot-reload development workflow with docker-compose.override.yml
  - Common issues troubleshooting table
- **Feature category 4.15** — System Integrity & Reality Verification (4 features: 99–102)

### Changed
- **CLAUDE.md** — Version 2.4.0 "Sentinel", agent table (9 agents), file system map (reality-auditor.md, reality-check.md, services-check.sh)
- **SYSTEM.md** — Version 2.4.0, feature count 98→102, 14→15 categories, version history updated
- **VERSION.json** — Bumped to 2.4.0 (85 files, 102 features, 9 agents, 9 commands, 6 scripts)
- **session-start.md** — Added Step 2.5: microservices health check before development

---

## [2.3.0] "Architect" — 2026-04-18

### Added
- **Microservices Extension** — 5 new files for multi-service architectures:
  - `architecture/SERVICE_MAP.md` — Service registry, boundaries, dependency matrix, data ownership rules, per-service CLAUDE.md pattern, monorepo vs multi-repo strategy, health check standard, new service checklist
  - `architecture/INTER_SERVICE.md` — Communication decision matrix, 5 patterns (REST, gRPC, Events, Commands, Saga), choreography vs orchestration saga, circuit breaker with state diagram, retry with exponential backoff + jitter, idempotency, service-to-service auth, 6 anti-patterns
  - `operations/OBSERVABILITY.md` — Three pillars (logs, metrics, traces), structured JSON logging, distributed tracing (OpenTelemetry), 4 Golden Signals (Google SRE), per-service Prometheus metrics, health checks (liveness/readiness/startup/deep), alerting rules, dashboard layout
  - `implementation/CONTRACT_TESTING.md` — Consumer-driven contract testing (Pact), event contract testing (JSON Schema), API versioning strategy, breaking change detection, CI/CD integration
  - `operations/ORCHESTRATION.md` — Multi-stage Dockerfile standard, Docker Compose for multi-service dev, Kubernetes manifests (Deployment, Service, ConfigMap, Ingress), Helm charts with Helmfile, HPA + PDB scaling policies, deployment strategies (rolling/canary/blue-green), CI/CD per-service pipelines, service mesh (Istio)
- **Architecture-Aware Bootstrap** — Q13 now branches: if user answers "microservices", additional questions (Q13a–Q13e) and file generation (SERVICE_MAP, INTER_SERVICE, OBSERVABILITY, CONTRACT_TESTING, ORCHESTRATION) are triggered
- **Architecture-Aware Reverse Bootstrap** — Phase 1.8 added: microservices detection (multiple Dockerfiles, services/ directory, K8s manifests, broker configs, proto files) → conditional generation of extension files
- **Feature category 4.14** — Microservices Extension (7 features: 92–98)

### Changed
- **CLAUDE.md** — Version 2.3.0 "Architect", file system map updated with microservices extension files
- **SYSTEM.md** — Version 2.3.0, feature count 91→98, 13→14 categories, version history updated, strength 6.5 added (monolith-to-microservices scaling)
- **README.md** — Directory tree updated with microservices extension files
- **VERSION.json** — Bumped to 2.3.0, stats updated (82 files, 98 features, 9 architecture files, 5 operations files)
- **bootstrap/BOOTSTRAP.md** — Added Q13a–Q13e microservices questions, added Layer B+ conditional file generation section
- **bootstrap/REVERSE_BOOTSTRAP.md** — Added Phase 1.8 microservices detection, Phase 2 Q6a–Q6e, Phase 3 conditional microservices file generation

---

## [2.2.0] "Navigator" — 2026-04-17

### Added
- **Migration Guide** — `bootstrap/MIGRATION_GUIDE.md`
  - Complete 6-phase migration from old `claude-code-system` (35-file template) to `claude-code-methodology`
  - File mapping table (old path → new path) with action classification (MOVE/MIGRATE/REBUILD/SPLIT/REPLACE/MERGE/NEW)
  - Phase-by-phase instructions: Inventory → Safety → Scaffold → Migrate → Add New → Verify
  - Troubleshooting guide and before/after comparison table
- **Usage Guide** — `reference/USAGE_GUIDE.md`
  - Complete guide on how to use Agents, Skills, Hooks, and Commands
  - Explains activation mechanisms: slash commands (manual), agents (auto + explicit), skills (auto), hooks (event-driven)
  - Practical examples for each layer
  - Common questions and answers
  - End-to-end session walkthrough showing all layers working together
- **Use Case 4** — Legacy system migration (old claude-code-system → CCM)
  - Added to SYSTEM.md Part III alongside the existing 3 use cases
  - Flow diagram showing the 6-phase migration process

### Changed
- **SYSTEM.md** — Updated from 3 to 4 use cases, feature count from 89 to 91, added category 4.13
- **CLAUDE.md** — Version bumped to 2.2.0 "Navigator"
- **README.md** — Updated intro, directory tree (added MIGRATION_GUIDE.md, UPGRADE_PROTOCOL.md, USAGE_GUIDE.md), 4 use cases in banner
- **VERSION.json** — Bumped to 2.2.0, added "legacy-system-migration" use case

---

## [2.1.0] "Polyglot" — 2026-04-17

### Added
- **Language Agent** — Universal language & localization specialist (`language.md`)
  - Covers ALL writing systems: RTL (Arabic, Hebrew, Persian, Urdu), LTR (Latin, Cyrillic), CJK (Chinese, Japanese, Korean), Indic (Hindi, Bengali, Tamil, Telugu, Thai), and Bidirectional mixed-script
  - Script Direction Registry with complete Unicode ranges
  - Font Family Map for 10+ script groups with fallback stacks
  - Locale Configuration Map for 18+ locales (direction, calendar, number system, timezone, currency)
  - 8-section mandatory checklist (strings, direction, fonts, formatting, input, layout, accessibility, backend)
  - CSS logical properties mapping table
  - Intl API usage examples for every locale
  - 15 NEVER/ALWAYS constraints
  - 3 real-world audit examples (Arabic, CJK, Bidi)
  - Automated + manual testing protocol
- **/language-audit** — Universal locale compliance command replacing /arabic-audit
  - Accepts `--locale <code>` parameter for any target locale
  - 10-step audit: strings → direction → CSS → fonts → formatting → input → layout → accessibility → report
  - Supports 20+ locale codes out of the box

### Removed
- **Arabic-RTL Agent** — Replaced by the universal Language Agent
- **/arabic-audit command** — Replaced by /language-audit (universal)

### Changed
- **CLAUDE.md** — Updated agent table, file system map, version to 2.1.0 "Polyglot"
- **SYSTEM.md** — Updated agent feature table, command table, strength description
- **README.md** — Updated architecture diagram, agent table, directory tree, version
- **VERSION.json** — Bumped to 2.1.0

### Migration Guide
- Replace any references to `arabic-rtl.md` with `language.md`
- Replace `/arabic-audit` usage with `/language-audit [component] --locale ar-SA`
- No breaking changes — all other v2.0 files remain valid

---

## [2.0.0] "Foundation" — 2026-04-17

### Added
- **SYSTEM.md** — Complete system specification (identity, architecture, 3 use cases, 89 features, strengths, objectives)
- **I/O Channel** — Full inter-agent communication system (14 files)
  - `io/IO_PROTOCOL.md` — Communication law with naming, routing, security matrix
  - `io/status.md` — Live dashboard with queue, signal board, metrics
  - `io/BRIEFING_COWORK.md` — Self-contained role instructions for Cowork
  - `io/BRIEFING_CLAUDE_CODE.md` — Self-contained role instructions for Claude Code
  - `io/requests/` — Structured inbound request directory
  - `io/results/` — Structured outbound result directory
  - `io/signals/` — Emergency interrupt system (halt, rollback, escalate, hotfix, revert, pause, resume)
  - `io/pipelines/` — Multi-step chained workflow system
  - `io/threads/` — Follow-up conversation system
  - `io/archive/` — Monthly auto-archival of completed pairs
  - `io/.templates/` — 9 pre-built templates (audit, verify, review, analyze, compare, fix, pipeline, signal, result)
- **Version Control** — System now versioned with semantic versioning
  - `VERSION.json` — Machine-readable version manifest
  - `CHANGELOG.md` — This file
- **Upgrade Protocol** — `bootstrap/UPGRADE_PROTOCOL.md` for safe version migration
  - 5-phase process: Preserve → Update → Merge → Add → Verify
  - Version-specific upgrade guides
  - Data preservation guarantees
- **Automation Scripts**
  - `scripts/io-watcher.sh` — Detect pending I/O items at session start
  - `scripts/io-archive.sh` — Archive completed request-result pairs
- **Priority Queue** — Requests prioritized (critical/high/medium/low) with SLA and auto-escalation
- **Access Control Matrix** — Who can read/write what in the I/O system
- **I/O Metrics** — Request volume, resolution rate, signal count, average response time

### Changed
- **CLAUDE.md** — Major update:
  - Added Section 3: I/O Channel architecture and integration
  - Added Golden Rule 2.7: I/O Channel Rule
  - Updated Session Protocol (§5.1): Step 0 now checks I/O Channel first
  - Renumbered sections 4→5, 5→6, 6→7, 7→8, 8→9, 9→10, 10→11, 11→12
  - Updated file system map to include io/ directory
- **README.md** — Major update:
  - Added I/O Channel showcase section with architecture diagram
  - Updated 4-layer diagram to include I/O Channel
  - Updated directory tree with io/ system
  - Updated file count table (54→77 files)
  - Updated golden rules (6→7)
- **Version numbering** — System now tracks its own version

### Fixed
- Nothing — this is the first versioned release

### Migration Guide
- See `bootstrap/UPGRADE_PROTOCOL.md` for v1.0 → v2.0 upgrade steps
- No breaking changes — all v1.0 files remain valid
- New files need to be added (io/ directory, SYSTEM.md, VERSION.json, CHANGELOG.md)

---

## [1.0.0] "Genesis" — 2026-04-15

### Added
- **Core**: CLAUDE.md (Master Brain with 4-layer architecture, 6 golden rules, session protocol)
- **Memory System**: 7 files (MEMORY_PROTOCOL.md, project_status, session_notes, change_log, architecture_decisions, bugs_and_fixes, testing_log)
- **Agent System**: 8 specialist agents (Architect, Security Auditor, Code Reviewer, Test Engineer, Debugger, Refactor Specialist, Arabic-RTL, Deploy Guardian)
- **Skills Registry**: 21 skills cataloged (15 Category A + 6 Category B)
- **Hooks Protocol**: 6 hook types, 7 production recipes
- **Architecture Layer**: 7 files (Constraints, Tech Stack, Context Map, Error Patterns, Decisions, Security, Workflow)
- **Implementation Layer**: 8 files (API Endpoints, Docker Compose, Docker Local, Event Schema, Migration Order, Local Runbook, Gateway Routes, README)
- **Operations Layer**: 3 files (Workflow, Deployment, Operations Log)
- **Commands**: 8 slash commands (session-start, session-end, new-feature, debug, review, deploy-check, arabic-audit, document)
- **Bootstrap**: New project protocol (25 questions) + Reverse Bootstrap (existing project auto-scan) + Reengineering Guide
- **Scripts**: git-setup.sh, github-push.sh, validate-system.sh
- **Config**: .claude/settings.json, .env.example, .gitignore, LICENSE

---

> **Note**: Versions before 1.0.0 were not tracked.
> The methodology was conceived, designed, and built in a single
> engineering session on 2026-04-15, then expanded to v2.0 on 2026-04-17.
