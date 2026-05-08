# Claude Code Methodology v3.5.0 "Engineered"
## Training Manual 11 — CI / PR Governance

> **Purpose.** v3.4 makes the discipline CCM teaches into the discipline
> CCM lives by. This manual covers the GitHub-side artifacts (templates,
> CODEOWNERS, workflows, branch protection) and how they integrate
> with the rest of the methodology.

---

## Why this exists

A methodology repo that pushes straight to `main` cannot credibly
recommend PR discipline to its users. Bootstrapped projects inherit
the patterns this repo models. v3.4 closes the gap between
"recommended" and "practiced."

The v3.3 audit also flagged a real Linux-vs-macOS bash drift risk
(BSD `date -j -f` vs GNU `date -d` in `autonomy-guard.sh`) that local
macOS testing couldn't catch. CI on Ubuntu would have. v3.4 makes that
catch automatic.

---

## What v3.5 adds: agent + skill

v3.4 shipped CI/PR plumbing as static configuration. v3.5 makes it an
executable capability with the standard CCM agent+skill pair.

### Agent: `ci-pr-engineer`

Lives at `.claude/agents/ci-pr-engineer.md`. Owns the **review of the
review process** — workflows, PR/issue templates, CODEOWNERS, branch
protection, dependabot, secret scanning, and the binding rules in
`CONTRIBUTING.md` and `SECURITY.md`. Read-only by default; conditional
sequential in `init` mode while the parent applies writes.

Severity ladder:

| Finding | Severity |
|---------|----------|
| Required workflow missing | BLOCK |
| Workflow uses unpinned `@main` action | WARN |
| Workflow has no `paths:` filter | WARN |
| `permissions:` block missing | WARN |
| Script injection sink (`${{ github.event.* }}` into `run:`) | BLOCK |
| CODEOWNERS path with no living reviewer | BLOCK |
| Branch protection missing required check | BLOCK |
| Branch protection allows admin bypass | WARN |
| Branch protection requires < 1 approval | BLOCK |
| `SECURITY.md` missing or has no private-advisory link | WARN |
| `.markdownlint.json` missing while markdown-lint workflow runs | BLOCK |

### Skill: `/arib-ci-audit`

Single user-facing entry point. Four modes:

```bash
/arib-ci-audit                                       # full audit (default)
/arib-ci-audit init                                  # bootstrap CI/PR for a fresh project
/arib-ci-audit review .github/workflows/hooks.yml    # focused review of one file
/arib-ci-audit branch-protection                     # query GitHub API for live BP state
```

Output: `io/ledger/ci-pr-<mode>-<date>.md` with the same YAML-style
header as `/arib-deep-audit` (audit-hash, short-hash, timestamp,
branch, head-sha, mode, target, verdict, finding counts).

Recipe for parallel use as section 9 of `/arib-deep-audit`:

```text
Task(ci-pr-engineer, mode=audit)
Task(api-docs, mode=audit)
Task(language)
```

All three are read-only; safe to fan out in a single Task batch.

### When to run

- **Quarterly** — catches drift between CONTRIBUTING.md and the
  workflows.
- **Before a release** — verify required checks still match branch
  protection.
- **After a CI failure that should have been caught earlier** —
  diagnose the gap.
- **When bootstrapping CCM into a fresh project** — `init` mode
  scaffolds the full set.
- **As a PR review aid** when a contributor touches `.github/**` —
  `review <file>` mode focuses on one file.
- **Before delegating PR access** — `branch-protection` mode confirms
  the GitHub web-UI settings match the binding rule (constraint #10).

---

## What v3.4 shipped (artifact map)

```
.github/
├── PULL_REQUEST_TEMPLATE.md     ← every PR's contract
├── CODEOWNERS                   ← review routing by path
├── dependabot.yml               ← weekly dep updates
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml
│   ├── feature_request.yml
│   ├── security.yml             ← routes high-severity to private advisories
│   └── config.yml
└── workflows/
    ├── hooks.yml                ← v3.3 (kept) — runs the 31-test regression
    ├── json-validate.yml        ← every JSON file + VERSION semver
    ├── token-budget.yml         ← measures session-start cost on PRs
    └── markdown-lint.yml        ← markdownlint + TODO/FIXME detection

CONTRIBUTING.md                  ← branch naming, commits, review process
SECURITY.md                      ← vulnerability disclosure policy
CODE_OF_CONDUCT.md               ← Contributor Covenant 2.1
.markdownlint.json               ← lint config
.claude/rules/ci-pr.md           ← path-scoped Claude rules for .github/
```

---

## The four required CI workflows

### 1. Hooks regression (`hooks.yml`)

Runs `./scripts/test-hooks.sh` (31 assertions covering every documented
hook guard, plus `bash -n` syntax checks across all shell scripts and
JSON shape validation of `settings.json`).

**Triggers:** PR or push to `main` touching `.claude/hooks/**`,
`.claude/settings.json`, `scripts/**`, `tests/**`,
`architecture/CONTEXT_MAP.md`, `architecture/DESIGN_SYSTEM.md`.

**Failure:** any guard regression. The pre-existing `io-archive.sh`
syntax bug Phase 5a found is exactly the class of thing this catches.

### 2. JSON validation (`json-validate.yml`)

Validates every committed `.json` file with `jq`, then specific shape
checks for:
- `VERSION.json` — semver format, codename present.
- `.mcp.json` — `mcpServers` is an object.
- `.claude/settings.json` — `hooks.PreToolUse[0].hooks[0].command` exists.

**Triggers:** PR or push touching any `.json` file.

### 3. Token budget (`token-budget.yml`)

Runs `./scripts/token-audit.sh` against base and head branches,
computes the delta, comments it on the PR, and:
- **Warns** at >5K token regression.
- **Fails** at >10K token regression.

This is the load-bearing check that keeps `context.include` from
slowly drifting upward. CCM's stated target is <8K (per ADR-007 / Item
#11); the current measurement is honest about the gap. CI prevents
new drift on top.

**Triggers:** PR touching files that affect session-start cost
(`CLAUDE.md`, `.claude/settings.json`, `.claude/rules/**`,
`architecture/**`, `implementation/**`, `memory/MEMORY_PROTOCOL.md`,
`operations/WORKFLOW.md`, `scripts/token-audit.sh`).

### 4. Markdown lint (`markdown-lint.yml`)

Runs `markdownlint-cli2` against every shipped `*.md`, plus a
TODO/FIXME/XXX detector for shipped docs (excludes
`proposals/archive/`, `.github/`, and `tests/` where placeholders are
fine).

**Triggers:** PR or push touching any `.md` file.

---

## Branch protection (apply once in repo Settings)

Settings → Branches → Branch protection rules → `main`:

- ✅ Require a pull request before merging
- ✅ Require approvals (1 minimum)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners
- ✅ Require status checks to pass before merging:
  - `Hooks regression / test-hooks`
  - `JSON validation / validate-json`
  - `Token budget / measure`
  - `Markdown lint / lint`
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Require linear history (squash or rebase merge only)
- ✅ Restrict who can push to matching branches: maintainer only
- ✅ Do not allow bypassing the above settings

**Direct pushes to `main` are emergency-only.** Document each in
`operations/OPERATIONS_LOG.md`.

---

## The PR template (binding contract)

Every PR fills in:

1. **Summary** — 2-4 sentences, lead with user-visible outcome.
2. **Type** — feat / fix / docs / refactor / test / chore / security /
   perf / wave (multiple OK).
3. **Linked issues / ADRs** — cite ADR if changing an architectural
   decision.
4. **Test plan** — concrete steps. `./scripts/test-hooks.sh` must pass
   for hook changes.
5. **Token-budget impact** — base/head/delta. Required if
   `context.include` or `.claude/rules/` changed.
6. **Wave audit hash** — required for PRs closing a wave.
7. **Compliance impact** — required for hooks / auth / data /
   `compliance/` changes. Use the honesty principle — never "compliant".

The reviewer checklist runs through CI status, CODEOWNERS approvals,
secret-block compliance, registration of new agents/skills/ADRs in
CLAUDE.md, breaking-change CHANGELOG entries, and branch protection
preservation.

---

## CODEOWNERS routing

Auto-requested reviewers per path:

| Path | Why |
|------|-----|
| `.claude/hooks/**` | Kernel-level enforcement; one bug breaks every project |
| `.claude/settings.json` | Hook wiring; misconfig disables enforcement |
| `architecture/{CONSTRAINTS,DECISIONS,SECURITY,AGENT_ARCHITECTURE}.md` | Load-bearing decisions |
| `compliance/**` | Honesty principle is load-bearing |
| `arib-deep-audit`, `arib-wave-{start,end}`, `arib-check-compliance` | Gate behavior |
| `CLAUDE.md`, `SYSTEM.md`, `VERSION.json`, `CHANGELOG.md` | Methodology brain |
| `.github/`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md` | Meta-discipline |

The catch-all `*` rule routes everything else to the maintainer.
Adding paths to CODEOWNERS is not free — it adds review burden — so
add only what materially changes the system.

---

## Branch naming and commit conventions

```
feat/<short>          new capability
fix/<short>           bug fix
docs/<short>          docs only
refactor/<short>      internal change
chore/<short>         tooling, deps, CI
security/<short>      security finding
wave/<wave-name>      multi-session delivery (uses arib-wave-start)
```

`wave/*` branches go through the wave-merge gate (`pre-tool-use.sh`):
no `git push|merge` to `main` without an audit hash from
`/arib-deep-audit`.

Commit messages follow Conventional Commits:

```
<type>(<scope>): <subject ≤72 chars>

<optional body, wrap 72>

Closes #123
Refs ADR-007
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

---

## Issue templates

Three structured templates plus a config:

- **`bug_report.yml`** — what broke, repro, expected behavior, version,
  OS, bash version, hook log tail.
- **`feature_request.yml`** — problem, proposal, alternatives, scope,
  vendor impact, compliance honesty check.
- **`security.yml`** — severity dropdown that explicitly redirects
  HIGH/CRITICAL to GitHub private advisories (so they don't disclose
  publicly).
- **`config.yml`** — disables blank issues, points to private advisory
  link for high-severity, points to Discussions for open-ended
  questions, points to compliance honesty principle for "isn't this
  ISO/SOC2 compliant?" reports.

---

## Vulnerability disclosure

Repo-root `SECURITY.md` defines:

- **Threat surface** — hook bypass, path-scoping bypass, secret-pattern
  bypass, wave-merge gate bypass, autonomy-guard bypass, MCP injection,
  notification leakage, supply chain (especially relevant for the 3
  placeholder MCP packages).
- **Out of scope** — application-layer issues in projects that *use*
  CCM.
- **Reporting paths** — private advisory for HIGH/CRITICAL; public
  issue (security template) for LOW/MEDIUM.
- **SLA** — acknowledge in 3 business days, severity in 7, fix plan in
  30 days for HIGH/CRITICAL.

---

## Dependabot

Weekly updates Mondays 09:00 Asia/Riyadh:

- `github-actions` — keep workflow runner versions current.
- `npm` — security patches grouped into a single PR.

Dependabot PRs are still PRs. They go through the same CI and
CODEOWNERS review. Auto-merge for patch-level updates after CI
passes is acceptable; never auto-merge minor or major bumps.

---

## How CI/PR integrates with the rest of the methodology

| Layer | Integration point |
|-------|-------------------|
| L1 (CLAUDE.md) | §6 lists CI/PR docs in "Where to Find Everything" |
| L1 (rules) | `.claude/rules/ci-pr.md` auto-loads when editing `.github/**` |
| L2 (skills) | PR template requires test plan; `arib-wave-end` produces audit hash for `wave/*` PRs |
| L3 (hooks) | CI runs `./scripts/test-hooks.sh` on every PR touching hooks |
| L4 (agents) | CODEOWNERS doesn't auto-route to agents — humans review |
| Compliance | PR template's compliance section enforces the honesty principle |
| Waves | Wave-merge gate + audit hash + PR template work together |
| Autonomy | Branch protection prevents autonomy from bypassing review |
| Token discipline | `token-budget.yml` workflow keeps drift visible |

---

## Adding a new workflow

1. Create `.github/workflows/<name>.yml`.
2. Scope `paths:` precisely — broad triggers waste CI minutes.
3. Verify it passes on a representative branch BEFORE adding it as a
   required check in branch protection.
4. Update `CONTRIBUTING.md` and this manual if it becomes a required
   check.
5. Open a PR; the workflow runs on its own creation.

---

## Failure modes

- **Required check renamed without updating branch protection:**
  permanent block on every PR. Fix: rename in branch protection
  settings or revert the workflow rename.
- **Token-budget workflow times out on large repos:** the audit
  script is fast, but the dual-checkout (base + head) doubles the
  clone size. Add `fetch-depth: 1` if needed.
- **Markdown lint catches false positives in archived docs:** the
  workflow excludes `proposals/archive/` and `.github/`. Add new
  exclusions if a legitimate doc is being flagged.
- **Dependabot opens 50 PRs on first run:** set
  `open-pull-requests-limit: 5` in `dependabot.yml` (already done).

---

## Related

- `CONTRIBUTING.md` — full contribution workflow (the user-facing
  document; this manual is the methodology-side companion).
- `SECURITY.md` — vulnerability disclosure.
- `CODE_OF_CONDUCT.md` — Contributor Covenant.
- `architecture/DECISIONS.md` ADR-012 — the decision record.
- `architecture/CONSTRAINTS.md` constraint #10 — the binding rule.
- `.claude/rules/ci-pr.md` — path-scoped guidance.
- `.github/PULL_REQUEST_TEMPLATE.md` — PR contract.
- `.github/CODEOWNERS` — review routing.
- `.github/workflows/*.yml` — actual CI.
- `Training/04-HOOKS-MANUAL.md` — the hook layer the regression suite tests.
