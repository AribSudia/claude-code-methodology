# compliance/ — Honest framework alignment

> **What this directory is** — guidance, controls mapping, and the subset of
> rules that are *actually* code-checkable, organized by framework.
>
> **What this directory is NOT** — a certification. CCM cannot certify your
> project against ISO 27001, attest you for SOC 2, or sign off on GDPR
> compliance. Those are operational programs run by humans, auditors, and
> DPOs. This directory documents alignment and adds the automated checks
> that *do* exist.

---

## The honesty principle

Some rules in these frameworks **are code-checkable**. Examples:
- OWASP Top 10 — yes, almost all of it. Patterns, sinks, configs.
- GDPR data-deletion endpoints — yes, presence and shape can be checked.
- PII in logs — yes, regex + heuristics.
- Hard-coded secrets — yes (already enforced by v3.2 Item A hooks).

Other rules **are not code-checkable**, no matter how loud the marketing
claims. Examples:
- ISO 27001 ISMS — an organizational program. Hooks can support audit
  trails; they cannot enforce the program.
- SOC 2 Type II — an attestation over a 6-12 month observation period.
  No script enforces this. Period.
- GDPR consent practices — code can check that consent flags exist; only
  humans can check whether the consent flow is genuine.

This directory **states which is which** in each framework's doc.

---

## Layout

```
compliance/
├── README.md                            ← you are here
├── COMPLIANCE.md                        ← top-level controls map across frameworks
└── frameworks/
    ├── owasp.md                         ← Top 10:2025 — mostly code-checkable
    ├── gdpr.md                          ← Privacy by design — partial code coverage
    ├── iso27001.md                      ← ISMS — program-level, hooks support audit
    ├── soc2.md                          ← Trust criteria — same pattern as ISO
    └── mena-pdpl.md                     ← Saudi PDPL + NCA ECC + SDAIA AI ethics
```

## Skills

- `/arib-check-arabic` — Arabic/RTL/typography audit (the original Item #7).
- `/arib-check-compliance <framework>` — runs the code-checkable rules for
  one framework and reports findings. `framework` is one of:
  `owasp`, `gdpr`, `iso27001`, `soc2`, `pdpl`, `all`.

## Hooks

- `pre-tool-use.sh` — already enforces the v3.2 Item A guards (secrets,
  dangerous bash, path scoping). Item #7 adds OWASP-pattern checks at
  write time.
- `pre-commit.sh` — already blocks commits with secrets / .env / debug
  statements. Item #7 adds PII-in-log-line patterns to the commit guard.

## How to use

1. Read `COMPLIANCE.md` for the high-level controls map.
2. Read the framework doc(s) relevant to your project.
3. Run `/arib-check-compliance <framework>` regularly (and as section 1
   of `/arib-deep-audit`).
4. For frameworks that require human/operational sign-off (ISO, SOC 2),
   record the human controls in `compliance/CONTROLS.md` (your own file —
   not shipped, varies per project).
5. Do **not** quote CCM as evidence to an auditor without showing them
   this README first. The honesty principle applies externally too.
