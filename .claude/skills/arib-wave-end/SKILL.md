---
argument-hint: ""
description: "Wave | Close a wave — deep-audit gate, stakeholder report, audit-hash tag"
---

# Wave End — /arib-wave-end

## Overview

Closes the current wave. Runs the 21-section deep audit as the gate;
generates the stakeholder REPORT.md; appends to WAVE_HISTORY.md; tags the
commit with the audit hash; optionally opens a PR.

The pre-tool-use hook **blocks merges to `main`** from a `wave/*` branch
unless an audit hash for that wave exists in `io/ledger/`. This skill is the
only sanctioned way to produce that hash.

## When to Use

When work on a `wave/*` branch is complete and ready for review/merge.

## Usage

```bash
/arib-wave-end
```

No arguments — the wave is determined by the current branch (`wave/<name>`).

## Protocol

### Step 1 — Pre-flight

```text
1. Verify current branch matches wave/* — abort if not.
2. Extract <wave-name> from branch.
3. Verify waves/<wave-name>/PLAN.md exists.
4. Verify git working tree is clean — abort if not (commit or stash first).
5. Echo wave summary to user, ask for confirmation to proceed.
```

### Step 2 — Run deep audit

```bash
/arib-deep-audit <wave-name>
```

This runs all 21 sections (see `arib-deep-audit/SKILL.md`). Block on:
- Any BLOCK-severity finding.
- Subagent timeouts that prevent a section from completing.

If BLOCK: report findings, halt, do not proceed to step 3. Recommend either
fixing in-place or opening a follow-up wave for the un-fixable items.

### Step 3 — Generate stakeholder REPORT.md

From PLAN.md + audit findings + commit history (`git log wave/<name>..` or
the wave-start tag if one exists), populate `waves/<wave-name>/REPORT.md`
from the template.

Specifically:
- **What shipped** ← PLAN's in-scope items that are now done.
- **What did NOT ship** ← in-scope items not done + reason.
- **Audit summary** ← table of 21 sections from /arib-deep-audit.
- **Stakeholder summary** ← rewrite "What shipped" in non-engineering language.
- **Risks for next wave** ← carry-forward items.
- **Commits** ← `git log --oneline` for the wave window.

### Step 4 — Update history

Append one line to `waves/WAVE_HISTORY.md`:

```text
2026-05-08 | <wave-name> | PASS | abc1234 | <one-line summary>
```

### Step 5 — Tag the audit hash

```bash
AUDIT_HASH="$(grep -oE 'audit-hash: [a-f0-9]+' io/ledger/audit-*.md | tail -1 | awk '{print $2}')"
git tag "wave/<name>/end-${AUDIT_HASH:0:8}"
```

### Step 6 — Commit + announce

```bash
git add waves/<wave-name>/REPORT.md waves/WAVE_HISTORY.md
git commit -m "feat(wave): end <wave-name> — audit ${AUDIT_HASH:0:8} PASS"
```

Announce:
- Wave closed.
- Audit verdict: PASS.
- Tag: `wave/<name>/end-<hash>`.
- REPORT.md ready for stakeholder distribution.
- Next: open PR to main (or merge directly per project policy).

### Step 7 — (Optional) Open PR

If `gh` is available and the project uses PR workflow, offer to open the PR
with REPORT.md as the body.

## Failure modes

- **Not on a wave/* branch:** abort with clear instruction to check out the
  wave branch first.
- **Audit BLOCK:** halt; report; suggest follow-up wave for unfixable items.
- **Audit hash not found in io/ledger/:** /arib-deep-audit didn't write the
  ledger entry; investigate why before retrying. Do not skip the gate.

## Related

- `waves/README.md` — wave concept.
- `arib-wave-start` — opens a wave.
- `arib-deep-audit` — the gate.
- `.claude/hooks/pre-tool-use.sh` — enforces the hash-on-merge rule.
- `waves/WAVE_HISTORY.md` — append-only history.
