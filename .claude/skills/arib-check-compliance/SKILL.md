---
argument-hint: "<owasp|gdpr|iso27001|soc2|pdpl|all>"
description: "Check | Compliance alignment — runs code-checkable rules per framework"
---

# Compliance Check — /arib-check-compliance

## Overview

Meta-skill that runs the code-checkable subset of one (or all) of the five
frameworks documented in `compliance/frameworks/`:

- **owasp** — OWASP Top 10:2025 (mostly code-checkable)
- **gdpr** — GDPR (partial coverage; operational items listed in output)
- **iso27001** — alignment report only (program-level standard)
- **soc2** — alignment report only (attestation framework)
- **pdpl** — Saudi PDPL + NCA ECC + SDAIA AI ethics
- **all** — runs all five and produces a unified report

This skill is the entry point for `compliance/`. It is honest about what
it can and cannot do (see `compliance/README.md` for the honesty principle).

## When to Use

- Before a release.
- As section 1 of `/arib-deep-audit`.
- Before an external audit (the alignment report becomes evidence).
- Quarterly, against `all`, to track drift.

## Usage

```bash
/arib-check-compliance owasp
/arib-check-compliance gdpr
/arib-check-compliance iso27001
/arib-check-compliance soc2
/arib-check-compliance pdpl
/arib-check-compliance all
```

## Protocol

### Step 1 — Read framework spec

Read `compliance/frameworks/<framework>.md` for the rule list. Each
framework doc has a "code-checkable" section that this skill executes.

### Step 2 — Dispatch checks

Per framework:

#### owasp
- Dispatch the `security-auditor` agent with the OWASP rule set as input.
- Run greps for SQL concat, eval(), MD5/SHA-1, missing CSRF, etc.
- Run `/arib-check-deps` for A06.

#### gdpr
- Probe routes for delete-my-account / export.
- Check User model for consent column.
- Verify cookie banner if analytics shipped.
- Read `compliance/CONTROLS.md` for retention period declaration.
- Output operational checklist for human follow-up.

#### iso27001
- Run all hooks healthy?
- Run `arib-check-deps` (A 8.8).
- Run secret-scan health check (A 5.17).
- Output Annex A control alignment table.
- Output operational items list.

#### soc2
- Same as iso27001 — alignment table per Trust Services Criterion.
- Plus availability checks (health endpoint, monitoring docs, backup
  declaration).

#### pdpl
- Hand off Arabic-content checks to `arib-check-arabic`.
- Check data residency config.
- Check Hijri date support if institutional context.
- Check Arabic privacy notice presence.

### Step 3 — Merge findings

Each framework produces:
```text
- automated:  [rule, status, evidence]
- operational: [item, present-in-CONTROLS.md?, severity]
- alignment-level: NONE | PARTIAL | STRONG
```

For `all`: produce a top-level summary table with one row per framework.

### Step 4 — Write report

Reports go to `io/ledger/compliance-<framework>-<date>.md`. They are
intentionally **not** auto-committed — compliance evidence often needs a
human sign-off step before it becomes part of the trail.

### Step 5 — Verdict

This skill **does not block**. It emits an alignment report. Blocks come
from upstream hooks (secrets, dangerous bash, design tokens) and from
the skills the framework checks delegate to (e.g. `security-auditor`).

The verdict format is:
```text
ALIGNMENT-LEVEL: PARTIAL
TOTAL findings:  17 (BLOCK: 0, WARN: 9, INFO: 8)
NEXT STEP:       <one-line>
```

## What this skill will NOT say

- "SOC 2 compliant"
- "ISO 27001 certified"
- "GDPR compliant"
- "PDPL compliant"

It says "alignment level: <level>" with citations. Compliance/certification
is the auditor's call, not Claude Code's.

## Failure modes

- **Framework doc missing:** abort with clear error.
- **`compliance/CONTROLS.md` missing:** treat all operational items as
  unconfirmed; downgrade alignment level accordingly.
- **Skill called with unknown framework:** list valid options and exit.

## Related

- `compliance/README.md` — honesty principle.
- `compliance/COMPLIANCE.md` — controls map.
- `compliance/frameworks/*.md` — per-framework rule sets.
- `arib-check-arabic` — sub-skill for `pdpl`.
- `arib-deep-audit` — calls this skill as section 1.
