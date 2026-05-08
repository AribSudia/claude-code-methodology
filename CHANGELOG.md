# Changelog

All notable changes to Claude Code Methodology are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
`CCM-v3.2-Minimal-Counter-Proposal.md` for the rationale.

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
