# Security Policy

Thank you for taking the time to look at CCM's security posture and
report what you find.

This file is the **vulnerability disclosure policy** for the
methodology repository itself. For application-level security guidance,
see `architecture/SECURITY.md` and `compliance/frameworks/owasp.md`.

---

## Supported versions

| Version | Supported          |
|---------|--------------------|
| 3.11.x  | ✅ active          |
| 3.10.x  | ✅ critical fixes only |
| 3.9.x   | ⚠️ best-effort     |
| < 3.9   | ❌ unsupported — upgrade via the one-liner in bootstrap/RUN.md |

The single canonical version is in `VERSION.json`. If you're on an
older release, upgrade per `bootstrap/UPGRADE_PROTOCOL.md` before
filing a security report — the bug may already be fixed.

---

## What counts as a vulnerability in CCM

CCM is a methodology repo with bash hooks. The threat surface is small
but real:

- **Hook bypass** — a way to defeat `pre-tool-use.sh`, `pre-commit.sh`,
  `autonomy-guard.sh`, or `notification.sh` that allows operations the
  hook is supposed to block.
- **Path-scoping bypass** — writing outside `allowed_write_paths`
  through a quoting / encoding / glob trick.
- **Secret-pattern bypass** — credential format that should be caught
  but isn't.
- **Wave-merge gate bypass** — pushing to main from a `wave/*` branch
  without a real audit hash.
- **Autonomy-guard bypass** — circumventing a guardrail during
  `CCM_AUTONOMY=1` sessions.
- **MCP injection** — malicious MCP config that the bootstrap or skill
  flow accepts.
- **Notification leakage** — the hooks' webhook fan-out leaking session
  metadata to an attacker-controlled endpoint.
- **Supply chain** — a CCM-shipped dependency or referenced npm package
  exposing users (especially relevant for the placeholder MCP packages
  in `.mcp.json`).

**Out of scope:** application-layer issues in projects that *use* CCM.
Those belong to the project, not to CCM.

---

## How to report

### High or Critical severity

**Do NOT file a public issue.** Use GitHub's private security advisory:

➡️ https://github.com/AribSudia/claude-code-methodology/security/advisories/new

This routes directly to the maintainer with no public visibility until
a fix ships. Include:

- A clear description of the issue.
- A concrete reproduction (fixture under `tests/fixtures/payloads/` or
  step-by-step).
- Affected versions.
- Suggested mitigation if you have one.

### Low or Medium severity

You may file a public issue using the **Security disclosure** template
at `.github/ISSUE_TEMPLATE/security.yml`. Examples of what's
appropriate publicly:

- Documentation gaps about security posture.
- Hardening suggestions.
- Concerns about the v3.3 honesty principle vs. shipped behavior.

When in doubt, use the private advisory.

---

## What you can expect

- **Acknowledgement:** within 3 business days of report.
- **Severity assessment:** within 7 business days.
- **Fix or mitigation plan:** within 30 days for High/Critical, 90 days
  for Medium, best-effort for Low.
- **Public disclosure:** coordinated. We aim for fix-then-disclose; if
  a fix takes more than 90 days, we'll discuss disclosure timing with
  the reporter.

We will credit reporters by name (or handle, or anonymously — your
choice) in the CHANGELOG and the security advisory.

---

## What this policy does NOT cover

- **Compliance gaps** — CCM does not claim certification for any
  framework. If you find that CCM's `compliance/frameworks/*.md` overstate
  what's enforceable, that's a docs bug — file a regular issue. See
  `compliance/README.md` for the honesty principle.
- **MCP packages** — three MCP entries in `.mcp.json` (claude-mem,
  cowork, testsprite) are stubs / placeholders. CCM does not own those
  upstream packages; report issues to their respective maintainers.
- **Secrets the maintainer accidentally committed** — file privately,
  but the fix is rotation, not a code change.

---

## Bounty

CCM has no bounty program. If your finding is significant, the
maintainer may offer a private acknowledgement gift; this is at the
maintainer's discretion and is not promised.

---

## Hall of fame

(Reporters credited for accepted security findings will be listed
here, with their permission.)

_None yet — be the first._
