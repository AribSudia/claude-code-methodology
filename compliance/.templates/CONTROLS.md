# compliance/CONTROLS.md — Project-local controls register

> **What this file is:** the project-local register of controls, evidence,
> and operational decisions that the framework docs in `compliance/frameworks/`
> reference but that CCM cannot enforce automatically.
>
> **Copy this template to `compliance/CONTROLS.md`** when starting a new
> project. Then fill it in. Keep it under version control. The
> `/arib-check-compliance` skill reads this file when assessing alignment
> level for ISO 27001, SOC 2, GDPR, and PDPL.

---

## Project metadata

- **Project:** [Name]
- **Owner:** [Tech lead / DPO / CISO]
- **Compliance scope:** [Which frameworks apply — e.g. "OWASP + GDPR + PDPL"]
- **Data residency:** [Region — e.g. "EU only", "KSA only", "Global"]
- **Last review:** [YYYY-MM-DD]
- **Next review:** [YYYY-MM-DD + 6 months]

---

## OWASP — operational items

(OWASP is mostly code-checkable; see `compliance/frameworks/owasp.md`.
Operational items recorded here are usually rate-limits, monitoring,
and incident-response that aren't in code.)

| Item | Status | Evidence | Reviewed |
|------|--------|----------|----------|
| Rate limiting on auth endpoints | [done/in-progress/n-a] | [link / runbook ref] | [date] |
| Audit log retention period | [period] | [config link] | [date] |
| Penetration test cadence | [annual/biennial/n-a] | [last report link] | [date] |
| Bug bounty / responsible disclosure | [yes/no] | [program URL] | [date] |

---

## GDPR — operational items

| Article | Item | Status | Evidence | Reviewed |
|---------|------|--------|----------|----------|
| Art. 6 | Lawful basis register | [done/in-progress/n-a] | [register link] | |
| Art. 13/14 | Privacy notice content | [done] | [URL] | |
| Art. 28 | Data Processing Agreements (vendors) | [list] | [folder link] | |
| Art. 30 | Records of Processing Activities | [done] | [register link] | |
| Art. 33 | Breach notification procedure (72h) | [done] | [runbook link] | |
| Art. 35 | DPIA for high-risk processing | [list per activity] | | |
| Art. 37 | DPO designation | [name / external] | [appointment] | |
| Art. 44+ | Cross-border transfer safeguards | [SCC/adequacy/BCR] | [contracts] | |

---

## ISO/IEC 27001 — manual Annex A controls

(Only the manual ones — the code-checkable controls are covered by the
`/arib-check-compliance iso27001` skill.)

| Annex A | Control | Status | Evidence | Reviewed |
|---------|---------|--------|----------|----------|
| 5.7 | Threat intelligence | | | |
| 5.10 | Acceptable use of information | | | |
| 5.15 | Access control policy | | | |
| 5.23 | Information security in cloud services | | | |
| 5.30 | ICT readiness for business continuity | | | |
| 6.3 | Awareness, training | | | |
| 8.7 | Protection against malware | | | |
| 8.16 | Monitoring activities | | | |
| 8.21 | Security of network services | | | |
| 8.30 | Outsourced development | | | |
| 8.31 | Separation of dev/test/prod | | | |
| 8.34 | Protection during audit testing | | | |

(Add rows as your ISMS scope expands.)

---

## SOC 2 — Trust Services Criteria evidence

Pick the criteria your customers ask for. Most SOC 2 reports cover Security
plus 1-2 others.

| Criterion | Sub-control | Status | Evidence | Reviewed |
|-----------|-------------|--------|----------|----------|
| Security | Access reviews (quarterly) | | | |
| Security | Incident response runbook | | | |
| Security | Vendor risk assessments | | | |
| Availability | DR plan + recovery objectives | | | |
| Availability | Backup frequency + retention | | | |
| Confidentiality | Data classification scheme | | | |
| Processing Integrity | Reconciliation reports | | | |
| Privacy | (cross-references GDPR / PDPL above) | | | |

---

## PDPL / NCA ECC / SDAIA — KSA institutional

(Only when the project serves KSA users / institutional clients.)

| Item | Status | Evidence | Reviewed |
|------|--------|----------|----------|
| Data residency in KSA region | [me-south-1 / me-central-1 / azure-saudiarabia / exemption] | [infra config link] | |
| Audit log retention ≥ 12 months | [period] | [config] | |
| Network segmentation | | | |
| Arabic-language privacy notice | [URL] | [link] | |
| Hijri date display (institutional) | | | |
| SDAIA AI ethics — Fairness | | | |
| SDAIA AI ethics — Privacy and security | | | |
| SDAIA AI ethics — Transparency | | | |
| SDAIA AI ethics — Accountability | | | |
| SDAIA AI ethics — Reliability | | | |
| SDAIA AI ethics — Social benefit | | | |
| SDAIA AI ethics — Humanity | | | |

---

## Vendor register

| Vendor | Service | DPA / contract | Data accessed | Region | Reviewed |
|--------|---------|----------------|---------------|--------|----------|
| [Name] | [Hosting/email/etc.] | [link] | [data classes] | [region] | [date] |

---

## How `/arib-check-compliance` reads this file

The skill greps for completed rows (Status filled with done/yes) vs.
empty rows when computing alignment level:

- **NONE** — most rows empty.
- **PARTIAL** — about half completed.
- **STRONG** — substantially all rows completed with current evidence.

This file is **not** a substitute for a real audit. It is the input the
auditor will ask for.
