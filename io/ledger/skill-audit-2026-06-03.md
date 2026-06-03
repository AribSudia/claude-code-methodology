# Skill Forensic Audit — Axis 1

- audit-hash: skillaudit-2026-06-03-axis1
- timestamp: 2026-06-03T00:00:00Z
- mode: skill-audit (Axis 1 of 2)
- auditor: 5 parallel file-grounded subagents (line-cited, not memory)
- skills_audited: 26 / 26
- verdict: USABLE-WITH-DEFECTS — 1 functional blocker, several structural/cosmetic
- method: each SKILL.md read in full; scores cite file:line

---

## #1 cross-cutting finding (SYNTAX, all 26)

**No skill has a `name:` frontmatter field.** All 26 have `description:`;
most have `argument-hint:`. This is the skills-analog of the agent bug
fixed in v3.7 (agents lacked `name:` → unregisterable). Skills still
invoke via the `/arib-*` slash command (directory name), and
auto-activation uses `description`, so they are not 0% today — but the
missing `name:` is a conformance gap that risks silent non-discovery on
stricter Claude Code loaders and is inconsistent with the agent fix.
**Recommended: add `name: arib-<dir>` to all 26 and have
`validate-coherence.sh` enforce it.** (`argument-hint` absence on
argument-less skills — session-start/end, io, check-deploy,
check-services — is correct, NOT a defect.)

Syntax column below is therefore ⚠ for all 26 (functional, but missing
`name:`), not ✗.

---

## Unified audit table (26 skills)

| Skill | Syntax | Triggers | Depth/10 | Coherence | Depth justification (file:line) | Top improvement |
|-------|--------|----------|----------|-----------|----------------------------------|-----------------|
| arib-session-start | ⚠ no name | ✓ | 8 | ⚠ | decision trees + 6 common-mistakes + 4 edge branches (session-start:249-256) | Fix dangling `/bootstrap` & `/reverse-bootstrap` refs (session-start:229-230) — they are docs, not skills |
| arib-session-end | ⚠ no name | ✓ | 9 | ⚠ | templated handoff + emergency-stop stash + archiving (session-end:317-325) | **Remove fictional `develop` branch** (session-end:217) — repo is main-only |
| arib-io | ⚠ no name | ⚠ Cowork jargon | 9 | ⚠ | 4 worked signal lifecycles + JS priority-sort (io:448-496) | Add plain-language auto-activation cues to description; reference `io/ledger/` (never mentioned) |
| arib-memory-search | ⚠ no name | ✓ | 9 | ✓ | semantic-hit/grep-miss divergence example (memory-search:119-139) | Merge duplicate "Failure modes" (memory-search:87 & 212) |
| arib-dev-feature | ⚠ no name | ✓ | 8 | ✗ | 7-step + risk-mapping + 3 edge cases (dev-feature:209-234) | **BLOCKER: `git checkout develop` (dev-feature:42-47)** — no `develop` branch exists; every feature fails at step 2. Default to `main`/configurable |
| arib-dev-debug | ⚠ no name | ✓ | 9 | ⚠ | 4 bug-category worked examples, 3 hypotheses each (dev-debug:48-85) | Fix triplicated step numbers (two Step 4/5/6 at :48/:86, :94/:162, :172/:179) |
| arib-dev-review | ⚠ no name | ✓ | 10 | ✓ | 8 gates + threshold tables + good/bad pairs + severity matrix (dev-review:124-154,498-502) | Reconcile "Gates 5-7 safety" prose (dev-review:77) — Gate 7 is Documentation, not safety |
| arib-deep-audit | ⚠ no name | ⚠ no trigger verbs | 8 | ✓ | 21-section ownership table + hash computation (deep-audit:51-73,122-129) | Add a worked PASS/BLOCK sample report block |
| arib-ci-audit | ⚠ no name | ✓ | 9 | ✓ | 4 modes + live `gh api` worked example + decision tree (ci-audit:254-281,286-320) | Clarify it is a *contributor* to deep-audit §9, not the owner (ci-audit:34 vs deep-audit:61) |
| arib-wave-start | ⚠ no name | ✓ | 9 | ✓ | 3 worked examples incl. agent-disagreement (wave-start:147-165) | Dedup the two near-identical "Failure modes" (wave-start:104-110 & 252-264) |
| arib-wave-run | ⚠ no name | ✓ | 9 | ✓ | 6 pause-reasons + ambiguity-not-menu example (wave-run:60-81,219-232) | Formally define `done_when` grammar (used at :116,:296 but never specified) |
| arib-wave-end | ⚠ no name | ✓ | 9 | ⚠ | 3 worked examples + REPORT depth (wave-end:154-215,111-136) | Verify `io/ledger/audit-*.md` contract end-to-end (wave-end:80) — no audit-* files exist yet (unexercised) |
| arib-check-deploy | ⚠ no name | ⚠ | 8 | ⚠ | 7 gates + APPROVED/BLOCKED worked examples + zero-downtime patterns (check-deploy:421-487) | Reconcile "7-phase" vs Steps 1-8/gates 1-7; dispatch real `deploy-guardian` agent (check-deploy:220 prose) |
| arib-check-services | ⚠ no name | ✓ | 8 | ✗ | project-type tree + adaptive reports + connectivity matrix (check-services:64-80,280-309) | **Fix triple-broken step numbering** (dup Step 2 :60/:82, Step 3 :215/:246, Step 4 :276/:317) |
| arib-check-deps | ⚠ no name | ✓ | 10 | ✓ | auto-fix tree + CVSS/license matrices + multi-ecosystem (check-deps:118-149,40-74) | Wire or drop advertised `--licenses`/`--critical` flags (check-deps:37-38, not in arg-hint/steps) |
| arib-check-reality | ⚠ no name | ⚠ no trigger verbs | 9 | ⚠ | classification rubric + Reality Score formula + remediation template (reality:258-332) | Collapse dup Step 2/3 "Details" sections (reality:97-102,170-176) |
| arib-check-migrate | ⚠ no name | ✓ | 9 | ⚠ | 3 worked verdicts APPROVED/CONDITIONS/BLOCKED + lock matrix (migrate:180-293,141-152) | Remove dup `## Notes` (migrate:316-323 vs 381-386); move `## Instructions` up (currently :325, after Notes) |
| arib-check-perf | ⚠ no name | ✓ | 9 | ✓ | code-split/index/caching decision trees + per-framework N+1 (perf:128-138,40-87) | Relabel mis-titled "API Response Budgets" table (perf:104-110 is bundle-size) |
| arib-check-a11y | ⚠ no name | ✓ | 9 | ✓ | 6 before/after examples + contrast math + keyboard protocol (a11y:52-183,251-260) | Wire or drop `--page/--contrast/--keyboard` example flags (a11y:28-31) |
| arib-check-security | ⚠ no name | ✓ | 6 | ✓ | orchestration-only: 5 steps + verdict table; depth delegated to agent (check-security:100-105) | Specify the `Task(security-auditor)` I/O contract (arg path + return schema) so the merge step (check-security:73-96) isn't guessing |
| arib-check-design | ⚠ no name | ✓ | 7 | ⚠ | 5 checks + severity ladder, but no worked example, no decision tree (design:96-105) | Add a worked sample run + decision tree (shortest skill, 139 lines) |
| arib-check-arabic | ⚠ no name | ⚠ overlaps docs-language | 7 | ⚠ dup | 9-step protocol + severity table, but no worked example/decision tree (arabic:110-115) | De-dup vs docs-language: make arabic the canonical Arabic deep-dive; docs-language defers Arabic to it |
| arib-check-compliance | ⚠ no name | ✓ | 9 | ✓ | per-framework execution + 3 worked examples + decision tree (compliance:266-363) | Merge dup "Failure modes" (compliance:122 & 365) |
| arib-docs-api | ⚠ no name | ✓ | 9 | ✓ | sync-score formula + STALE/GHOST classifier + worked examples (docs-api:159-189) | Label the two sync-score datasets as independent (docs-api:176-182=58% vs :303=87%) |
| arib-docs-generate | ⚠ no name | ⚠ | 8 | ✓ | decision tree + JSDoc/Python/Go templates + checklists (docs-generate:181-203) | Fill the empty fenced code blocks (docs-generate:113-114,128-129) |
| arib-docs-language | ⚠ no name | ⚠ overlaps check-arabic | 9 | ⚠ dup | 10-step + per-script fonts + Intl + bidi patterns (docs-language:557-733) | Hand Arabic depth to check-arabic; keep this skill multi-script generic |

**Aggregate:** Syntax ⚠×26 (missing `name:`). Depth: mean ≈ 8.4; two 10s,
fourteen 9s, four 8s, two 7s, one 6. Coherence: ✓×13, ⚠×11, ✗×2.

---

## TOP 5 strongest skills

1. **arib-dev-review (10)** — 8 quality gates with threshold tables, good/bad
   code pairs (dev-review:124-154), severity matrix (:498-502), red-flag
   patterns (:508-541), self-review edge case. Reference-grade.
2. **arib-check-deps (10)** — auto-fix decision tree (:118-149), 5 supply-chain
   patterns, CVSS + license matrices, multi-ecosystem commands. Production-ready.
3. **arib-io (9)** — 4 fully worked signal lifecycles + a JS priority-sort
   algorithm (:448-496). Deepest protocol doc in the set (trigger-weak though).
4. **arib-check-compliance (9)** — per-framework execution detail, 3 worked
   examples, decision tree, and the honesty principle baked in.
5. **arib-memory-search (9)** — best frontmatter (description + argument-hint),
   every on-disk reference verified, semantic-vs-grep divergence example.

## BOTTOM 5 needing rebuild (ranked by severity, functional > cosmetic)

1. **arib-dev-feature + arib-session-end (FUNCTIONAL BLOCKER)** — both assume a
   `develop` branch (`git checkout develop`, dev-feature:42-47;
   branch-protection on develop, session-end:217). The repo is **main-only**.
   Every feature start fails at step 2. Highest-priority fix despite high depth.
2. **arib-check-services** — step numbering broken three times (dup Step 2/3/4).
   A reader/executor cannot follow the protocol linearly.
3. **arib-dev-debug** — triplicated step numbering (two each of Step 4/5/6);
   the canonical protocol interleaves with examples and is unfollowable top-to-bottom.
4. **arib-check-security (depth 6)** — pure orchestrator with no defined
   `Task(security-auditor)` I/O contract; the merge step guesses the agent's
   output schema. Specify input arg + return shape.
5. **arib-check-design (7) / arib-check-arabic (7)** — shortest skills, no worked
   examples or decision trees; arabic duplicates docs-language and both
   auto-match Arabic requests (weak trigger disambiguation).

---

## What HELD (positive verification)

- **Zero dangling agent references.** Every `Task(<agent>)` across all 26
  skills resolves to one of the 15 agents in `.claude/agents/`. The v3.7
  agent-frontmatter fix holds.
- **Wave audit-hash contract is sound in spec.** deep-audit's `wave:`/`audit-hash:`
  ledger header (deep-audit:135-150) is grepped by wave-end (:80,307) and
  pre-tool-use.sh wave-gate (:154) — chain intact (just unexercised; no
  `audit-*.md` written yet because no deep-audit has run).
- **No real duplication between check-security and the security-auditor agent**
  — clean orchestrator/worker split.

## Cross-cutting defect classes (fix once, sweep all)

1. Missing `name:` frontmatter — all 26 (enforce in validate-coherence.sh).
2. Fictional `develop` branch — dev-feature, session-end (functional break).
3. Dangling `/bootstrap` `/reverse-bootstrap` skill refs — session-start.
4. Broken/duplicated step numbering — dev-debug, check-services, check-reality, check-migrate.
5. Duplicate "Failure modes" / "Notes" sections — memory-search, wave-start, check-compliance, check-migrate.
6. Advertised-but-unwired CLI flags — check-deps, check-a11y.
7. check-arabic ↔ docs-language duplication + weak trigger disambiguation.
8. Empty code blocks — docs-generate.

---

**Axis 1 complete. Awaiting confirmation before Axis 2 (v3.8 roadmap).**
