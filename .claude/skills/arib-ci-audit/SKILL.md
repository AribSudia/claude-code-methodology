---
argument-hint: "[audit | init | review <file> | branch-protection]"
description: "CI | Audit, init, or review CI/PR posture — workflows, templates, CODEOWNERS, branch protection"
---

# CI/PR Audit — /arib-ci-audit

## Overview

Single entry point for the v3.5 CI/PR engineering subsystem. Dispatches
the `ci-pr-engineer` agent in one of four modes. Output is always a
structured report at `io/ledger/ci-pr-<mode>-<date>.md` (parallel to
how `/arib-deep-audit` writes its ledger entry).

The skill is the methodology-side companion to the v3.4 GitHub
plumbing (PR template, CODEOWNERS, workflows, dependabot,
CONTRIBUTING.md, repo-root SECURITY.md). v3.4 shipped the artifacts;
v3.5 makes them maintainable.

## When to Use

- **Quarterly** — `audit` mode catches drift between what
  CONTRIBUTING.md describes and what the workflows actually do.
- **Before a release** — verify required CI checks still match branch
  protection.
- **After a CI failure that should have been caught earlier** —
  diagnose the gap.
- **When bootstrapping CCM into a fresh project** — `init` mode
  scaffolds the full set.
- **As a PR review aid** when a contributor touches `.github/**` —
  `review <file>` mode focuses on one file.
- **Before delegating PR access** — `branch-protection` mode confirms
  the GitHub web-UI settings match `CONTRIBUTING.md` §6.
- As section 9 of `/arib-deep-audit` (documentation completeness).

## Usage

```bash
/arib-ci-audit                                       # full audit (default)
/arib-ci-audit init                                  # bootstrap CI/PR for a fresh project
/arib-ci-audit review .github/workflows/hooks.yml    # focused review of one file
/arib-ci-audit branch-protection                     # query GitHub API for live BP state
```

## Protocol

### Step 1 — Parse mode

| Argument | Mode |
|----------|------|
| (none) or `audit` | `audit` |
| `init` | `init` |
| `review <path>` | `review` (path must exist or, in init, must not exist yet) |
| `branch-protection` or `bp` | `branch-protection` |
| anything else | print usage, exit |

### Step 2 — Pre-flight per mode

**audit:**
- Confirm `.github/` exists. If not, switch to `init` mode and notify
  the user.
- Read `architecture/DECISIONS.md` ADR-012 (the binding decision) to
  ground findings.

**init:**
- Confirm `.github/` does NOT exist (or contains only obviously
  abandoned scaffolding).
- If files exist that conflict, abort and recommend `audit` instead.

**review `<file>`:**
- Confirm file exists and is under `.github/`, `CONTRIBUTING.md`,
  `SECURITY.md`, or a workflow path.

**branch-protection:**
- Verify `gh` CLI is installed: `command -v gh`.
- Verify `gh auth status` returns success. If not, partial-audit and
  surface the limitation.

### Step 3 — Dispatch ci-pr-engineer agent

Single Task call to `ci-pr-engineer` with mode and target. The agent
runs the full audit checklist (see `agents/ci-pr-engineer.md` §2-4)
and returns a structured findings list.

```text
Task(ci-pr-engineer, mode=<mode>, target=<file-or-repo>)
```

For `audit` mode on a repo that also has compliance / hooks concerns,
this can run in parallel with other read-only agents per
`AGENT_ARCHITECTURE.md`. Common parallel-safe batch:

```text
Task(ci-pr-engineer, mode=audit)
Task(security-auditor)        # if also auditing application code
Task(accessibility)           # if also auditing UI
```

### Step 4 — Branch-protection live check (only in BP mode)

```bash
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/branches/main/protection \
  --jq '{
    approvals: .required_pull_request_reviews.required_approving_review_count,
    require_codeowners: .required_pull_request_reviews.require_code_owner_reviews,
    dismiss_stale: .required_pull_request_reviews.dismiss_stale_reviews,
    required_checks: .required_status_checks.contexts,
    strict_checks: .required_status_checks.strict,
    linear_history: .required_linear_history.enabled,
    enforce_admins: .enforce_admins.enabled
  }'
```

Agent compares against the binding settings in `CONTRIBUTING.md` §6
and the rule in `architecture/CONSTRAINTS.md` constraint #10.

### Step 5 — Write report

Output goes to `io/ledger/ci-pr-<mode>-<YYYY-MM-DD>.md`.

The report **MUST** include the same YAML-style header that
`/arib-deep-audit` writes, so the report is part of the same audit
trail and can be referenced by hash:

```markdown
# CI/PR Audit Report

- audit-hash: <sha256 of findings, sorted>
- short-hash: <first 8>
- timestamp: <ISO-8601>
- branch: <git current branch>
- head-sha: <git HEAD>
- mode: audit | init | review | branch-protection
- target: <repo or file path>
- verdict: PASS | WARN | BLOCK
- findings-count: <N>
- block-count: <N>
- warn-count: <N>
- info-count: <N>

## Findings
(...)
```

### Step 6 — Verdict + next step

| Verdict | Trigger | Recommended action |
|---------|---------|--------------------|
| PASS | No findings or only INFO | Nothing required. Schedule next audit in 90 days. |
| WARN | One or more WARN findings, no BLOCK | Address in a follow-up PR; do not block ship. |
| BLOCK | Any BLOCK finding | Fix before merging the change that triggered the audit. |

**For init mode:** verdict is always `PASS` (or skill aborts). The
"action" is the sequenced bootstrap checklist the parent applies.

### Step 7 — Optional: append to OPERATIONS_LOG

```markdown
2026-05-08 | ci-pr-audit | <mode> | <verdict> | <short-hash> | <one-line summary>
```

This puts CI/PR audits in the same operational ledger as deep audits
and wave reports.

## Examples

### Example 1 — Quarterly audit, clean

```text
User: /arib-ci-audit

Mode: audit
Pre-flight: .github/ exists ✓; ADR-012 read ✓

Dispatch: Task(ci-pr-engineer, mode=audit)

Findings:
  - workflows checked: 4 (PASS: 4)
  - templates: PASS (PR template + 3 issue templates + config)
  - CODEOWNERS: PASS (catch-all + 7 specific paths, all reviewers exist)
  - branch protection: not checked (run with `branch-protection` mode)
  - governance docs: PASS (CONTRIBUTING + SECURITY + COC + .markdownlint.json)

Verdict: PASS
Wrote: io/ledger/ci-pr-audit-2026-05-08.md

Next step: schedule next audit ~2026-08-08.
```

### Example 2 — Init for a fresh project

```text
User: /arib-ci-audit init (in a project bootstrapped from CCM but
                          missing the .github/ scaffolding)

Mode: init
Pre-flight: .github/ does not exist ✓

Dispatch: Task(ci-pr-engineer, mode=init)

Returned plan:
  Create:
    .github/PULL_REQUEST_TEMPLATE.md  (from CCM canonical)
    .github/ISSUE_TEMPLATE/{bug_report,feature_request,security}.yml
    .github/ISSUE_TEMPLATE/config.yml
    .github/CODEOWNERS                (replace @AribSudia → @<owner>)
    .github/dependabot.yml            (timezone → <project tz>)
    .github/workflows/hooks.yml
    .github/workflows/json-validate.yml
    .github/workflows/token-budget.yml
    .github/workflows/markdown-lint.yml
    .markdownlint.json
    CONTRIBUTING.md
    SECURITY.md
    CODE_OF_CONDUCT.md

Then in repo Settings → Branches:
  Apply branch protection per CONTRIBUTING.md §6.

Parent session executes the writes through normal Write tool calls
(path-scoping hook validates each).

Verdict: PASS (init scope)
Wrote: io/ledger/ci-pr-init-2026-05-08.md
```

### Example 3 — Review a single workflow change

```text
User: /arib-ci-audit review .github/workflows/token-budget.yml

Mode: review
Pre-flight: file exists ✓

Dispatch: Task(ci-pr-engineer, mode=review,
                target=.github/workflows/token-budget.yml)

Findings:
  F1 — line 4 — WARN
    `paths:` filter is broad; runs on any architecture/** change.
    Consider scoping to architecture/{CONSTRAINTS,CONTEXT_MAP}.md and
    .claude/rules/** which actually affect token cost.
  F2 — line 24 — INFO
    Consider concurrency cancellation:
      concurrency:
        group: token-budget-${{ github.ref }}
        cancel-in-progress: true

Verdict: WARN (acceptable for ship; address in follow-up)
Wrote: io/ledger/ci-pr-review-2026-05-08.md
```

### Example 4 — Live branch protection check

```text
User: /arib-ci-audit branch-protection

Mode: branch-protection
Pre-flight: gh installed ✓; gh authenticated ✓

Live query:
  approvals: 1 ✓
  require_codeowners: true ✓
  dismiss_stale: true ✓
  required_checks: ["Hooks regression / test-hooks",
                    "JSON validation / validate-json",
                    "Token budget / measure",
                    "Markdown lint / lint"] ✓
  strict_checks: true ✓
  linear_history: true ✓
  enforce_admins: false ✗

Findings:
  F1 — branch-protection — WARN
    enforce_admins is false; admin can bypass required checks.
    Per ADR-012 + constraint #10, direct push reserved for emergencies.
    If you intend to keep this, document in operations/OPERATIONS_LOG.md;
    otherwise enable in Settings → Branches.

Verdict: WARN
Wrote: io/ledger/ci-pr-branch-protection-2026-05-08.md
```

## Decision tree

```
/arib-ci-audit [<mode>]
    |
    v
[Mode parsed?]
    |
    +-- no  --> print usage; exit
    +-- yes --> continue
    |
    v
Pre-flight per mode
    |
    +-- audit:    .github/ exists?
    +-- init:     .github/ does NOT exist?
    +-- review:   file exists?
    +-- bp:       gh installed + authed?
    |
    v
Dispatch ci-pr-engineer (single Task)
    |
    v
Receive findings list
    |
    v
Compute verdict (PASS / WARN / BLOCK)
    |
    v
Write io/ledger/ci-pr-<mode>-<date>.md
    |
    v
Optionally append OPERATIONS_LOG.md line
    |
    v
Report to user with next-step recommendation
```

## Edge cases

- **Self-hosted Git platform (GitLab, Gitea)**: agent skips
  GitHub-specific checks (CODEOWNERS, dependabot, branch protection
  via `gh`) and surfaces the platform mismatch as INFO. Workflow
  validation still applies if the project uses GitHub Actions.

- **`gh` auth has insufficient scope** (e.g., missing `repo` scope
  for private repo): partial branch-protection audit; report the
  scope gap explicitly. Recommend `gh auth refresh -s repo`.

- **Workflow file uses reusable workflow** (`uses: org/.github/.workflows/foo.yml@main`):
  agent reports the upstream workflow is out of scope; recommend
  pinning the SHA and auditing the upstream separately.

- **Required-check job name was renamed**: agent detects the rename
  by diffing against the previous `audit` ledger entry (if present);
  flags as BLOCK because branch protection will silently lose the
  required check.

- **CODEOWNERS lists a removed user**: agent flags as BLOCK because
  reviews will block forever waiting on a non-existent reviewer.

- **`init` mode in a repo that already has partial scaffolding**:
  agent refuses to overwrite. Recommends `audit` to identify gaps,
  then targeted fixes.

## Failure modes

- **ci-pr-engineer agent times out**: report partial findings; mark
  INCONCLUSIVE; do not return PASS.
- **`gh` rate-limited** during branch-protection mode: cache the
  last successful response (in `io/ledger/`) and report from cache
  with a note about staleness.
- **Workflow YAML unparseable**: report verbatim; abort the workflow
  section but continue other sections.
- **No `architecture/DECISIONS.md` ADR-012**: project hasn't adopted
  the binding decision. Treat as `init` mode, recommend ADR adoption.

## Related

- `.claude/agents/ci-pr-engineer.md` — does the heavy lifting.
- `architecture/DECISIONS.md` ADR-012, ADR-013 — binding records.
- `architecture/CONSTRAINTS.md` constraint #10 — binding rule.
- `Training/11-CI-PR-MANUAL.md` — user-facing manual.
- `.claude/rules/ci-pr.md` — path-scoped rules.
- `.github/` — artifacts under audit.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md` — governance docs.
- `.claude/skills/arib-deep-audit/SKILL.md` — calls this skill as section 9.
