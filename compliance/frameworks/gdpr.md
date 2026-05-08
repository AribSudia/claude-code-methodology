# GDPR — Privacy by design, partially code-checkable

GDPR is a data-protection regulation. Most of it is operational (DPO,
Records of Processing Activities, DPIAs, vendor contracts). Some of it is
genuinely code-checkable.

The `/arib-check-compliance gdpr` skill runs the code-checkable parts. The
rest is documented here so the human-driven parts are visible.

## Code-checkable

### 1. Data-deletion endpoint (Right to erasure, Art. 17)

**Check:** every project that handles personal data must expose a
delete-my-account endpoint or admin-callable equivalent. The skill greps
the route table for one of:

```text
DELETE /me              DELETE /api/users/me
DELETE /accounts/:id    /api/gdpr/erasure
/api/account/delete     /api/users/:id/anonymize
```

If no candidate is found, raise WARN. If the project has no user-data
model at all, return PASS with note.

### 2. Data-export endpoint (Right to access, Art. 15)

**Check:** same pattern as deletion. Common shapes:

```text
GET  /me/export         GET  /api/account/data
GET  /api/gdpr/export   GET  /api/users/:id/export
```

WARN if not found and the project has user data.

### 3. Consent flag in user model

**Check:** if there's a `User` / `Account` / `Profile` model and
marketing/analytics in use, look for a consent column or table:

```text
column: marketing_consent | privacy_consent | gdpr_consent | tos_accepted_at
```

WARN if none exists and the project sends marketing email or has analytics.

### 4. Audit log retention

**Check:** projects with audit logging should declare retention. The skill
greps `logs/`, infrastructure config, or `compliance/CONTROLS.md` for a
retention period statement.

WARN if no retention is declared. Operational decision; CCM doesn't pick
the period.

### 5. PII in logs

**Hook-enforced (added with this commit):** `pre-commit.sh` rejects
diffs that look like they're logging structured PII:

```text
console.log(...email...)         logger.info(...phone...)
logger.warn(...credit_card...)   console.error(...ssn...)
```

False positives are likely (variable names that contain `email` but log
nothing sensitive). The hook errs on the side of warning; in practice,
review surface manually if you hit a false block.

### 6. Cookie consent (web projects)

**Check:** if `index.html` or `_app.tsx` exists, look for a cookie banner
component or library reference (`cookie-consent`, `tarteaucitron`,
`onetrust`, or a homemade `CookieBanner.tsx`).

WARN if absent and the project ships analytics or tracking pixels.

### 7. SAR (subject access request) workflow

**Check:** if `compliance/CONTROLS.md` exists, look for a documented
workflow. Otherwise WARN.

## NOT code-checkable

These are operational. The skill outputs a checklist for the human; it
does not block:

- **Records of Processing Activities (Art. 30)** — written register.
- **DPIA for high-risk processing (Art. 35)** — documented assessment.
- **Data Processing Agreement (DPA) with vendors (Art. 28)** — contracts.
- **Lawful basis for each processing activity (Art. 6)** — register.
- **Cross-border transfer safeguards (Art. 44+)** — SCCs, adequacy
  decisions, or BCRs.
- **Breach notification procedure (72h) (Art. 33)** — runbook.
- **DPO designation (Art. 37)** — appointment letter.
- **Privacy notice content** — legal review.
- **Genuine consent flow** — UX review (consent must be freely given,
  specific, informed, unambiguous; CCM cannot judge "freely given").

## Severity ladder (skill output)

| Finding | Severity |
|---------|----------|
| No data-deletion endpoint, project has user data | WARN (BLOCK if EU users) |
| No data-export endpoint, project has user data | WARN |
| PII in logs (hook block) | BLOCK |
| No consent column on User, project sends marketing | WARN |
| No retention period declared | WARN |
| No cookie banner, project ships analytics | WARN |
| Missing operational items (RoPA, DPIA, DPA) | INFO (checklist) |

## Related

- `compliance/COMPLIANCE.md` — controls map.
- `compliance/frameworks/owasp.md` — application security overlap.
- `compliance/frameworks/mena-pdpl.md` — Saudi PDPL covers similar
  ground for KSA processing.
