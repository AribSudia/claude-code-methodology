---
name: arib-wave-end
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

### Step 8 — Closure test + decision-list hand-off (campaign-level, ADR-026)

A single wave closing is not the same as the *whole effort* being done. When
this wave is the last planned one — or when running under `/arib-engine` — apply
the **evidence-based closure test** before declaring the campaign complete. "Done"
is justified ONLY when all three hold:

1. **Backlog exhausted on evidence** — the most recent discovery sweeps return
   only false-positives / already-handled / by-design items (diminishing returns
   is the signal), not "I'm out of time."
2. **Remainder is operator-owned** — everything left genuinely needs a human
   decision or an external action (the escalation classes), not more engineering.
3. **Composed-trunk green** — a final full gate run on the integrated `main`
   (not just per-PR green) passes.

> **Honest caveat to state in the hand-off:** diminishing returns measures *the
> agent's search distribution* running dry, not the absence of bugs — classes
> outside the lens catalog never lower the signal. Report closure as "this
> campaign's lenses are exhausted," not "the codebase is clean."

If the test passes, **own the call** and emit a **decision list** (not a vague
"blocked"). For each item: the specific question, the options with trade-offs,
your recommendation, and what you've already de-risked. Separate:

- **Decisions** (need a human choice): compliance/tax interpretation, framework
  majors, pricing/policy, risk acceptance.
- **Deploy-time actions** (code is ready; a human executes): inject secrets, run
  migrations, run a staging validation.

Then stand down — re-engagement must be frictionless (operator says "do X", you
resume cold from `memory/` + `io/ledger/`). If the test does NOT pass, say so and
name what remains; do not declare done. (Merge-to-main still goes through PR +
branch protection — CONSTRAINTS #10/#17 — never an autonomous merge.)

## Failure modes

- **Not on a wave/* branch:** abort with clear instruction to check out the
  wave branch first.
- **Audit BLOCK:** halt; report; suggest follow-up wave for unfixable items.
- **Audit hash not found in io/ledger/:** /arib-deep-audit didn't write the
  ledger entry; investigate why before retrying. Do not skip the gate.

## Stakeholder REPORT generation — depth

The auto-generated REPORT.md is what a non-engineering reader sees.
Generation rules:

- **"What shipped"** — list user-visible outcomes, not commit names.
  "Stripe checkout works for one-time payments" beats
  "feat(payment): add CheckoutSession handler".
- **"What did NOT ship"** — every in-scope PLAN item that didn't ship,
  plus an honest one-line reason. Silent deferrals erode trust faster
  than the missed item itself.
- **"Audit summary"** — the 21-section table from `/arib-deep-audit`.
  Show severity per section (PASS/WARN/BLOCK), not raw findings.
- **"Stakeholder summary"** — 3-5 bullets, plain English, lead with
  outcomes. Test: would a non-engineer read this and understand what
  changed?
- **"Risks for next wave"** — carry-forward items, unknown unknowns,
  dependencies that slipped. Include the risks the wave didn't get to
  resolve.
- **"Commits"** — `git log --oneline` for the wave window. Append-only;
  don't curate.

If the audit verdict is WARN (not BLOCK), the report includes a
"Watch list" section calling out the WARN findings that should be
addressed in the next wave. WARNs accumulate if ignored.

## PR opening — when to and when not to

Step 7 (optional PR) depends on project policy:

- **Use `gh pr create`** when the project uses GitHub PR workflow and
  `gh` is installed/authed. Use REPORT.md as the PR body.
- **Skip PR creation** when the project merges directly to main from
  the wave branch (rare; sometimes solo-maintainer workflows).
- **Skip PR creation** when the project uses a different code-review
  tool (GitLab MR, Gerrit, Phabricator). Generate the appropriate
  artifact instead.

Tag the audit hash regardless of PR mechanism. The tag is the proof
the wave passed; the PR is a workflow detail.

## Examples

### Example 1 — Clean wave, PASS verdict, PR opened

```text
User: /arib-wave-end (on branch wave/payment-integration)

Step 1: pre-flight ✓ (clean tree, PLAN exists, branch matches)
Step 2: /arib-deep-audit payment-integration
        → 21 sections; verdict PASS; audit hash 7f3a8c2d
Step 3: REPORT.md generated
        - 3 features shipped (checkout, webhooks, subscriptions)
        - 0 deferred
        - audit table all PASS or WARN
        - stakeholder summary in plain English
        - 14 commits over 12 days
Step 4: WAVE_HISTORY appended
        2026-05-15 | payment-integration | PASS | 7f3a8c2d | Stripe checkout, webhooks, subscriptions live
Step 5: tag wave/payment-integration/end-7f3a8c2d
Step 6: commit + announce
Step 7: gh pr create with REPORT.md body
```

### Example 2 — BLOCK verdict, halt

```text
User: /arib-wave-end (on branch wave/auth-rewrite)

Step 1: pre-flight ✓
Step 2: /arib-deep-audit auth-rewrite
        → section 5 (reality) BLOCK: 3 mock auth endpoints found in
          src/auth/__tests__/ that look like prod handlers.
          Section 1 (security) BLOCK: hardcoded JWT secret in
          src/lib/jwt.ts.
        → Verdict: BLOCK

Step 3 onward: HALTED.

Skill outputs:
  Wave NOT closed. Two BLOCK findings:
    1. src/lib/jwt.ts — hardcoded JWT secret. Move to env var.
    2. src/auth/__tests__/* — mock handlers may be reachable in prod.
  Recommended actions:
    - Fix in-place and re-run /arib-wave-end.
    - Or open a follow-up wave (wave/auth-rewrite-2) for the
      mock-handler removal if scope grew.
  Audit hash NOT tagged. Wave-merge gate remains active.
```

### Example 3 — PLAN scope changed mid-wave

```text
User: /arib-wave-end (on branch wave/i18n-rollout)

Pre-flight: PLAN.md scope was "Arabic + Hebrew + CJK" but only
Arabic shipped. Hebrew and CJK are referenced in commits as deferred.

Skill behavior:
  REPORT.md "What did NOT ship" lists Hebrew and CJK with reasons:
    - Hebrew: deferred to next wave; RTL infra reusable from Arabic.
    - CJK: out of MVP scope; recorded as risk for v2.
  Audit may PASS even with deferrals — the deferrals are honest.
  Wave closes; next wave can pick up the deferred items.
```

## Decision tree

```
/arib-wave-end (no args)
    |
    v
[On a wave/* branch?]
    |
    +-- no  --> abort with instruction to checkout the wave branch
    +-- yes --> extract <wave-name>
    |
    v
[Working tree clean?]
    |
    +-- no  --> abort; user must commit or stash first
    +-- yes --> continue
    |
    v
Run /arib-deep-audit <wave-name>
    |
    v
[Verdict]
    |
    +-- BLOCK --> HALT. Report findings. Suggest fix-in-place
    |             or follow-up wave. Do not tag, do not write
    |             REPORT, do not append to history.
    +-- WARN  --> proceed (warnings are acceptable wave exits)
    +-- PASS  --> proceed
    |
    v
Generate REPORT.md from PLAN + audit + commit log
    |
    v
Append one line to WAVE_HISTORY.md
    |
    v
Tag commit as wave/<name>/end-<short-hash>
    |
    v
Commit + announce
    |
    v
[Project uses PR workflow?]
    |
    +-- yes --> offer to gh pr create with REPORT body
    +-- no  --> done; user merges per their workflow
```

## Edge cases

- **Audit hash already exists for this wave.** This means /arib-wave-end
  was previously run and wrote a hash. Re-run with caution: confirm
  with the user whether to re-audit (creates a new hash, supersedes
  the prior one) or use the existing hash to generate the REPORT.
  Default: re-audit, since branch state may have changed.

- **PLAN.md has unchecked exit criteria.** Surface the unchecked
  criteria to the user before proceeding to /arib-deep-audit. The
  audit will catch some of these; the user should confirm the rest
  manually.

- **Branch has commits but no /arib-wave-start record.** This wave was
  started without the skill (manual branch). REPORT generation can
  still work but `waves/<name>/PLAN.md` may be missing — fall back to
  using the branch's first commit as the wave start point.

- **Wave-end runs in autonomy mode.** The autonomy guard requires a
  wave/<name>/end-<hash> tag for the push-to-main check. /arib-wave-end
  produces exactly this tag. Sequence is: autonomy session → /arib-
  wave-end PASS → tag created → push allowed.

## Failure modes (extended)

- **Not on a wave/* branch:** abort with clear instruction to check
  out the wave branch first.
- **Audit BLOCK:** halt. Do not partial-write artifacts. Do not tag.
  Do not append to history. The wave is not closed.
- **/arib-deep-audit doesn't write `audit-hash:` to ledger:** the skill
  fails to extract the hash and tags with empty. This is the bug Phase
  1 fixed — keep the contract.
- **gh not authed and PR is requested:** skip PR creation; tell the
  user to push and open the PR manually using REPORT.md as the body.
- **Concurrent /arib-wave-end calls (same branch):** only the first
  succeeds; the second sees the new tag and aborts as duplicate.

## Related

- `waves/README.md` — wave concept.
- `arib-wave-start` — opens a wave.
- `arib-deep-audit` — the gate. Defines the ledger format with
  `wave: <name>` and `audit-hash: <sha>` keys this skill greps for.
- `.claude/hooks/pre-tool-use.sh` — enforces the hash-on-merge rule.
- `waves/WAVE_HISTORY.md` — append-only history.
- `.claude/hooks/autonomy-guard.sh` — refuses push to main without
  wave/*/end-* tag during CCM_AUTONOMY=1 sessions.
