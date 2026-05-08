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

## Per-framework execution detail

### owasp — execution

```text
1. Read compliance/frameworks/owasp.md to enumerate A01–A10 rules.
2. Dispatch Task(security-auditor) with the OWASP rule set + scope path.
   Agent runs the code-checkable patterns (string-concat SQL,
   eval(), MD5/SHA-1, missing CSRF, broken auth checks, SSRF
   patterns).
3. Run /arib-check-deps inline (or as parallel Task call) for A06.
4. Read io/hook-logs/$(date +%Y-%m-%d).log for recent OWASP-pattern
   blocks. Recent blocks are signals — sometimes false positives,
   often attempts to write code that the hook stopped.
5. Output: per-A0N section with status (PASS/WARN/BLOCK), findings
   list with file:line citations.

Severity ladder reproduced from owasp.md:
  - String-concat SQL with user input → BLOCK
  - eval() on user input → BLOCK
  - MD5/SHA-1 for passwords → BLOCK
  - Missing auth check on private route → BLOCK
  - Critical CVE in dep → BLOCK (via arib-check-deps)
  - Missing rate limit on login → WARN
  - CORS * on authed API → WARN
  - Outdated dep, low CVE → WARN
```

### gdpr — execution

```text
1. Read compliance/frameworks/gdpr.md.
2. Probe the project's route table for:
   a. Data-deletion endpoint (Art. 17): grep route handlers for
      DELETE /me|/users/me|/account|/gdpr/erasure patterns.
   b. Data-export endpoint (Art. 15): grep for GET /me/export|
      /api/account/data|/gdpr/export.
3. Inspect User/Account/Profile model for consent column (e.g.,
   marketing_consent, privacy_consent, gdpr_consent, tos_accepted_at).
4. Cookie-banner check: grep app entry points (index.html, _app.tsx,
   layout.tsx) for cookie-consent libs or homemade CookieBanner.
5. Audit-log retention: read compliance/CONTROLS.md for the declared
   retention period. WARN if missing.
6. PII-in-logs: this is hook-enforced at commit time
   (.claude/hooks/pre-commit.sh). Cite recent BLOCKs as evidence.
7. Output operational checklist (RoPA, DPIA, DPA, breach
   notification) — these are NOT code-checkable; flag for human.

Severity ladder:
  - PII in logs (hook block) → BLOCK
  - No data-deletion endpoint, EU users → BLOCK
  - No data-export endpoint, EU users → WARN (BLOCK if regulated)
  - No consent column, marketing emails sent → WARN
  - No retention period declared → WARN
  - Operational items missing → INFO (checklist for human)
```

### iso27001 — execution

```text
1. Read compliance/frameworks/iso27001.md.
2. For each Annex A control with CCM coverage (table in iso27001.md):
   verify the corresponding hook/skill is active.
   - 5.17 (Authentication info) → secrets-block hook active?
   - 8.8  (Vulnerability mgmt)  → arib-check-deps clean?
   - 8.12 (Data leakage)        → PII-in-log hook active?
   - 8.15 (Logging)             → audit-log retention declared?
   - 8.24 (Cryptography)        → no MD5/SHA-1 in code?
   - 8.25 (SDLC)                → CCM in use? (yes, by definition)
   - 8.28 (Secure coding)       → OWASP findings?
   - 8.29 (Security testing)    → /arib-check-deploy + TestSprite?
3. For each manual control, read compliance/CONTROLS.md and check
   for completed rows.
4. Compute alignment level:
   - NONE   = no automated controls active, CONTROLS.md mostly empty
   - PARTIAL= ~half of automated + manual controls present
   - STRONG = substantially all controls present with current evidence

Output: alignment table per Annex A control + manual checklist for
the rest. Never says "ISO 27001 compliant" or "certified".
```

### soc2 — execution

```text
Same shape as iso27001. Trust Services Criteria:
  Security      — overlaps heavily with ISO + OWASP
  Availability  — health-check route present? backup declared?
                  monitoring documented in operations/MONITORING.md?
  Confidentiality — encryption at rest/in transit (config-level;
                    ask user to confirm via CONTROLS.md)
  Processing Integrity — input validation in code (OWASP A03 overlap),
                         idempotency keys for mutations
  Privacy       — see gdpr / mena-pdpl

Output: alignment table per criterion + evidence map.
Never says "SOC 2 compliant".
```

### pdpl — execution

```text
1. Read compliance/frameworks/mena-pdpl.md.
2. Hand off Arabic-content checks to /arib-check-arabic.
3. Verify data residency: read infra config (Terraform, Helm,
   docker-compose) for KSA-region declarations or read
   CONTROLS.md for documented exemption.
4. Hijri date: grep for hijri|umm-al-qura|toLocaleDateString.*ar-SA|
   dayjs.*hijri patterns. WARN if missing in institutional context.
5. Arabic privacy notice: grep for /privacy.*ar|locales/ar/privacy
   or PrivacyNotice.tsx with Arabic translation. BLOCK if missing on
   customer-facing institutional product.
6. NCA ECC subset: cross-reference with ISO 27001 alignment.
7. SDAIA AI ethics: checklist in CONTROLS.md (manual).

Output: alignment per PDPL section + Arabic audit summary.
```

## Merging multi-framework output (`all` mode)

When called with `all`:

1. Run each framework check sequentially (they share the
   security-auditor and arib-check-deps results — cache between runs).
2. Build a unified header table: framework | alignment-level | BLOCK
   count | WARN count | top-3 findings.
3. Compute overall verdict:
   - **BLOCK** if any framework returned BLOCK.
   - **WARN** if any returned WARN with no BLOCKs.
   - **STRONG-ALIGNMENT** if all frameworks reported STRONG.
   - **PARTIAL** otherwise.
4. Write `io/ledger/compliance-all-<date>.md` with sections per
   framework + the unified header.

The skill never blocks tool execution itself — it produces a report.
The hooks (write-time and commit-time) handle real blocking.

## Examples

### Example 1 — OWASP-only run, BLOCK finding

```text
User: /arib-check-compliance owasp

Output:
  ALIGNMENT-LEVEL: PARTIAL
  TOTAL findings: 7 (BLOCK: 1, WARN: 4, INFO: 2)
  Top BLOCK:
    - A03 (Injection): src/api/search.ts:42 string-concat SQL with
      req.query.q. Use parameterized query or ORM.
  Top WARNs:
    - A07: missing rate limit on /api/auth/login.
    - A05: CORS * on /api/users (authenticated route).
  Wrote io/ledger/compliance-owasp-2026-05-08.md

  NEXT STEP: fix A03 finding before merging. WARNs can be addressed
  in a follow-up.
```

### Example 2 — `all` run, mixed alignment

```text
User: /arib-check-compliance all

Output:
  Framework      Alignment   BLOCK   WARN   Notes
  owasp          PARTIAL     0       3      rate limits missing
  gdpr           PARTIAL     0       2      no consent column on User
  iso27001       PARTIAL     0       6      CONTROLS.md half-empty
  soc2           PARTIAL     0       4      no DR plan declared
  pdpl           STRONG      0       0      Arabic + RTL good

  Overall: PARTIAL.
  Wrote io/ledger/compliance-all-2026-05-08.md

  NEXT STEP: complete CONTROLS.md sections for ISO and SOC2.
  Operational items dominate the gap.
```

### Example 3 — Honest output for ISO 27001

```text
User: /arib-check-compliance iso27001

Output begins with disclaimer:
  CCM cannot certify ISO 27001. This skill produces an alignment
  report for use as audit evidence; the certification decision
  remains with an accredited certification body.

  ALIGNMENT-LEVEL: PARTIAL
  Automated controls (machine-verified): 5/8 active
  Manual controls (require human evidence): 3/12 in CONTROLS.md
  ...

The output never says "compliant" or "certified".
```

## Decision tree

```
/arib-check-compliance <framework>
    |
    v
[Framework arg present and valid?]
    |
    +-- no  --> list valid options (owasp/gdpr/iso27001/soc2/pdpl/all); exit
    +-- yes --> continue
    |
    v
[compliance/frameworks/<framework>.md exists?]
    |
    +-- no  --> abort; tell user to run bootstrap or check repo state
    +-- yes --> read rule set
    |
    v
[Framework is 'all'?]
    |
    +-- yes --> run each in sequence; merge into unified report
    +-- no  --> run single framework
    |
    v
Dispatch sub-checks (agent + skills + hook-log scan)
    |
    v
Compute alignment level (NONE / PARTIAL / STRONG)
    |
    v
Write io/ledger/compliance-<framework>-<date>.md
    |
    v
[Called from /arib-deep-audit?]
    |
    +-- yes --> contribute alignment to deep-audit's section 1 verdict
    +-- no  --> standalone report; no commit by default
```

## Failure modes

- **Framework doc missing:** abort with clear error. Do not invent.
- **`compliance/CONTROLS.md` missing:** treat all operational items
  as unconfirmed; downgrade alignment level to PARTIAL or NONE.
  Recommend the user copy `compliance/.templates/CONTROLS.md`.
- **security-auditor agent times out:** report partial OWASP findings;
  mark INCONCLUSIVE; do not return PASS.
- **Skill called with unknown framework:** list valid options and exit.
- **arib-check-arabic fails on `pdpl` run:** report what we have;
  flag the Arabic sub-audit as incomplete.

## Related

- `compliance/README.md` — honesty principle.
- `compliance/COMPLIANCE.md` — controls map.
- `compliance/.templates/CONTROLS.md` — project-local controls register
  template; copy to `compliance/CONTROLS.md` per project.
- `compliance/frameworks/*.md` — per-framework rule sets.
- `arib-check-arabic` — sub-skill for `pdpl`.
- `arib-check-security` — sub-skill for `owasp`.
- `arib-check-deps` — supply-chain audit, used by OWASP A06 and
  ISO Annex A 8.8.
- `arib-deep-audit` — calls this skill as section 1.
- `.claude/hooks/pre-tool-use.sh` — write-time OWASP A03 blocks.
- `.claude/hooks/pre-commit.sh` — commit-time PII-in-log blocks.
