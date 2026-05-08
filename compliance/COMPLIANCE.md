# COMPLIANCE.md — Framework alignment map

Top-level cross-walk of common controls across the five frameworks CCM
covers. Each row is a control area. The cell value is "yes / partial / no"
for whether CCM has automated checks in that area.

| Control area | OWASP | GDPR | ISO 27001 | SOC 2 | PDPL/NCA |
|---|---|---|---|---|---|
| Hardcoded secrets | yes (hook) | yes | yes | yes | yes |
| SQL injection patterns | yes (skill) | partial | partial | partial | partial |
| XSS patterns | yes (skill) | n/a | partial | partial | partial |
| SSRF patterns | yes (skill) | n/a | partial | partial | partial |
| Auth / session config | yes (skill) | yes | partial | partial | partial |
| Dependency CVEs | yes (`arib-check-deps`) | yes | yes | yes | yes |
| Audit log retention | n/a | yes (skill) | yes (skill) | yes (skill) | yes (skill) |
| PII in logs | partial | yes (hook) | yes | yes | yes |
| Data-deletion endpoint | n/a | yes (skill) | n/a | n/a | yes (skill) |
| Encryption at rest | n/a (config) | yes (config) | yes (config) | yes (config) | yes (config) |
| Encryption in transit | n/a (config) | yes (config) | yes (config) | yes (config) | yes (config) |
| Access control / RBAC | yes (skill) | yes | yes | yes | yes |
| Backup / DR strategy | n/a | n/a | yes (manual) | yes (manual) | yes (manual) |
| Vendor risk management | n/a | partial | yes (manual) | yes (manual) | partial |
| Incident response runbook | n/a | yes (manual) | yes (manual) | yes (manual) | yes (manual) |
| Privacy notice / DSR | n/a | yes (manual) | n/a | n/a | yes (manual) |
| Data residency | n/a | partial | partial | partial | yes (manual) |
| Arabic typography / RTL | n/a | n/a | n/a | n/a | yes (skill) |

**Legend:**
- **yes (hook)** — runtime enforced by a v3.2 hook. Can't be bypassed without `--no-verify` or editing the hook.
- **yes (skill)** — checked by a slash-command skill on demand or in the deep audit.
- **yes (manual)** — humans, with documented evidence in `compliance/CONTROLS.md` (your own file).
- **yes (config)** — checked by reading deployment configs (Terraform, Helm, etc.) — outside CCM's scope, but called out by the relevant framework doc.
- **partial** — some sub-rules are code-checkable, others aren't. Framework doc lists which.
- **n/a** — the framework doesn't address this control area.

---

## How findings flow

```text
write-time hook  →  block (highest signal)
commit-time hook →  block (audit trail)
skill-on-demand  →  /arib-check-compliance <framework> output
deep-audit       →  /arib-deep-audit, section 1, IMPLEMENT-FROM-FILE mode
manual control   →  compliance/CONTROLS.md (project-local, gitignored or not)
```

## What CCM cannot do

- Issue a SOC 2 attestation. (Auditors do that.)
- Sign off on ISO 27001 certification. (Certification bodies do that.)
- Replace a Data Protection Officer. (DPOs do that.)
- Validate a customer's right-to-be-forgotten flow against your real DB.
  (Integration tests against staging do that.)

If you ever find marketing copy that claims CCM "ensures SOC 2 compliance"
or similar, it is wrong. Use this controls map and the framework docs
instead.
