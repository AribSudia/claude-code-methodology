---
name: arib-check-security
argument-hint: "[<path-or-glob>]"
description: "Check | Application security audit — OWASP Top 10 + supply chain"
---

# Security Check — /arib-check-security

## Overview

Application-security audit. Combines two concerns the proposal originally
split across `arib-check-deps` (supply chain) and the `security-auditor`
agent (code patterns):

- **OWASP Top 10:2025** — code-level patterns and anti-patterns.
- **Supply chain** — dependency CVEs, license compliance, transitive
  vulnerabilities.

This is **section 1** of `/arib-deep-audit`. It also runs standalone for
spot checks before merging security-sensitive code.

## When to Use

- Before merging any change to authentication, payment, data, or
  API-boundary code.
- Before a release.
- As section 1 of `/arib-deep-audit`.
- After a known vulnerability is published in any dependency.
- During incident response when a security defect is suspected.

## Usage

```bash
/arib-check-security                    # whole codebase
/arib-check-security src/auth/          # subdir
/arib-check-security src/api/users.ts   # single file
```

## Protocol

### Step 1 — Dispatch the security-auditor agent

Call `Task(security-auditor)` with the target path. The agent reads
`compliance/frameworks/owasp.md` and applies every code-checkable rule
across A01–A10.

**Why dispatch instead of running inline?** The security-auditor agent
has scoped context for OWASP patterns and produces a structured report
faster. Per `architecture/AGENT_ARCHITECTURE.md`, this is parallel-safe
with other read-only agents (e.g., `performance`, `accessibility`,
`reality-auditor`).

Expected agent output: a finding list per OWASP item, with file:line
citations and severity (BLOCK / WARN / INFO).

### Step 2 — Dispatch arib-check-deps in parallel

```bash
/arib-check-deps
```

Returns the supply-chain audit: outdated packages with CVEs, license
issues, transitive vulnerabilities. Both can run concurrently in a single
Task batch.

### Step 3 — Apply hook-enforcement signals

Look at `io/hook-logs/` for any recent BLOCKs from the secret-detection
or OWASP A03 hooks. Recent blocks indicate the model has been trying to
write things that the hook stopped — sometimes a false positive, often
a real attempt-to-skirt that should surface in the security report.

### Step 4 — Merge findings

Combine the three sources (security-auditor output + arib-check-deps
output + hook-log signals) into a unified report:

```markdown
# Security Audit — <target> — <date>

## Summary
- OWASP findings:        N (BLOCK: x, WARN: y)
- Supply-chain findings: N (BLOCK: x, WARN: y)
- Hook signals (24h):    N (informational)

## OWASP Top 10
### A01 — Broken Access Control
(... findings with file:line and severity ...)
### A02 — Cryptographic Failures
(...)

## Supply chain
(... arib-check-deps output ...)

## Hook signals
(... summarized recent BLOCK events ...)
```

### Step 5 — Verdict

| Severity | Trigger |
|----------|---------|
| BLOCK | Any OWASP finding marked BLOCK in `compliance/frameworks/owasp.md` (e.g., string-concat SQL with user input, eval() on user input, hardcoded credential, MD5 for passwords, missing auth on private route, critical CVE in a dependency). |
| WARN  | Missing rate limit on login, CORS `*` on authenticated API, low-severity CVE, dependency more than 2 majors behind, license question. |
| PASS  | All clean. |

## Output format

The skill writes a report at `io/ledger/security-<date>-<short-hash>.md`
with the format above. When called as section 1 of `/arib-deep-audit`,
the deep-audit skill folds this report into the unified audit ledger and
contributes the security verdict to the overall PASS/WARN/BLOCK roll-up.

## Failure modes

- **`security-auditor` agent times out:** report partial findings; mark
  the section as INCONCLUSIVE; do not return PASS.
- **`compliance/frameworks/owasp.md` missing:** abort with a clear
  error. Do not invent OWASP rules.
- **Project has no production code yet:** return PASS with note "no
  production surface to audit".
- **Supply-chain audit fails (npm/pip down):** report partial; mark
  supply-chain as INCONCLUSIVE.

## Related

- `.claude/agents/security-auditor.md` — does the heavy lifting on
  code-pattern detection.
- `.claude/skills/arib-check-deps/SKILL.md` — supply-chain audit.
- `compliance/frameworks/owasp.md` — the rule list this skill enforces.
- `compliance/frameworks/iso27001.md`, `soc2.md`, `gdpr.md` — overlapping
  controls; this skill produces evidence for those frameworks too.
- `.claude/skills/arib-deep-audit/SKILL.md` — the wave-end gate that
  calls this skill as section 1.
- `.claude/hooks/pre-tool-use.sh` — write-time OWASP A03 enforcement
  (eval, new Function, exec template literal).
- `.claude/hooks/pre-commit.sh` — commit-time PII-in-log-line
  enforcement.
