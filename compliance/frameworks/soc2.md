# SOC 2 — Trust Services Criteria, attestation-level (not enforceable)

> **Honest framing:** SOC 2 is an *attestation*, not a certification.
> A licensed CPA firm observes your controls over a period (Type I:
> point-in-time; Type II: 6-12 months) and produces a report. No script
> "produces SOC 2 compliance".
>
> What CCM **can** do: align with the Trust Services Criteria, automate
> evidence collection where possible, and keep the audit trail clean
> enough that the auditor's job is easier.

---

## The 5 Trust Services Criteria

SOC 2 covers up to five criteria. Most reports include Security; the others
are optional based on customer demand.

### 1. Security (always included)

Maps closely to ISO 27001 Annex A controls. CCM coverage:
- Access control: OWASP A01 + audit logging.
- Vulnerability management: `arib-check-deps`.
- Change management: git + hooks + wave overlay (Item #6).
- Incident response: `operations/INCIDENT_RESPONSE.md` (template).
- Risk assessment: manual; document in `compliance/CONTROLS.md`.

### 2. Availability

Code-checkable bits:
- Health-check endpoint exists.
- Monitoring and alerting documented (`operations/MONITORING.md`).
- Backup strategy declared.
- DR plan declared.

The first three are skill-checkable. The DR plan is operational.

### 3. Confidentiality

Same coverage as Security plus:
- Data classification documented.
- Access reviews performed (manual, periodic).
- Encryption at rest + in transit (config-level — outside CCM).

### 4. Processing Integrity

- Input validation in code (OWASP A03 overlap).
- Idempotency of mutation endpoints.
- Reconciliation reports for financial / billing data.

### 5. Privacy

Overlaps with GDPR for EU and PDPL for KSA. See those docs.

---

## What the `/arib-check-compliance soc2` skill does

Same shape as ISO: alignment report, not pass/fail. Sample output:

```markdown
# SOC 2 alignment — <project> — <date>

## Security criterion
- Access control patterns       ✓ OWASP A01 clean
- Vulnerability management      ✓ arib-check-deps clean
- Secrets management            ✓ hook active
- Change management             ✓ wave overlay in use, audit hash present

## Availability criterion
- Health-check endpoint         ✓ /health found
- Monitoring documented         ✓ operations/MONITORING.md present
- Backup strategy declared      ⚠ CONTROLS.md does not declare backup frequency

## Confidentiality criterion
- Encryption at rest            → infra-level; not checkable here
- Access reviews                → CONTROLS.md missing

## Processing Integrity criterion
- Input validation              ⚠ 3 routes accept body without validator middleware
- Idempotency keys              → manual review

## Privacy criterion
- See gdpr.md and mena-pdpl.md
```

## Evidence the auditor will want

CCM contributes to:
- **Change management evidence** — git history, wave reports, audit hashes.
- **Vulnerability scan evidence** — `arib-check-deps` output.
- **Code review evidence** — `arib-dev-review` output, parallel review fan-out.
- **Logging evidence** — `io/ledger/` and `io/hook-logs/`.
- **Incident response runbook** — `operations/INCIDENT_RESPONSE.md`.
- **Security training evidence** — your manual records.

The auditor will also want:
- Background check evidence on team members (manual).
- Vendor risk assessments (manual).
- Annual penetration test reports (vendor).
- Org chart (manual).
- Policies — acceptable use, data handling, breach notification (manual).
- Ticket-system traces showing reviewed access changes (manual).

None of those are CCM's job. They live with HR, legal, the security team,
and the ticketing system.

## What CCM does NOT replace

- A SOC 2 readiness assessment.
- The auditor's fieldwork.
- Your security policies.
- A control framework like Vanta, Drata, or Tugboat Logic. (CCM works
  alongside these; it does not replace them.)

If a customer asks "are you SOC 2?", the answer is your auditor's report,
not this directory.

## Related

- `compliance/COMPLIANCE.md` — cross-framework controls map.
- `compliance/frameworks/iso27001.md` — sibling; same operational shape.
- `compliance/frameworks/owasp.md` — code-level overlap.
- `compliance/frameworks/gdpr.md` — privacy criterion overlap (EU).
- `compliance/frameworks/mena-pdpl.md` — privacy criterion overlap (KSA).
