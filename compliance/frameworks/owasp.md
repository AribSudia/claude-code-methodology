# OWASP Top 10:2025 — code-checkable application security

OWASP is the most code-checkable of the five frameworks. The Top 10 is, by
design, a list of patterns and anti-patterns that show up in source. This
doc lists each item, what's enforced, and where.

The `/arib-check-compliance owasp` skill runs every check below.

## A01 — Broken Access Control

**Code-checkable:**
- Routes that read `req.user` but skip an authorization check.
- IDOR patterns: routes accepting `:id` and querying without ownership scope.
- Hard-coded `role === 'admin'` strings (use a constant + RBAC table).
- Missing CSRF tokens on state-changing requests (POST/PUT/PATCH/DELETE).

**Skill checks** (`/arib-check-compliance owasp`):
- Grep for routes without `requireAuth`, `authorize`, `@Authorize`, or
  framework-specific decorator.
- Flag `params.id` or `params.userId` queries that don't include
  `req.user.id` in the WHERE clause.
- Report missing CSRF middleware on Express/Koa/Fastify apps.

## A02 — Cryptographic Failures

**Code-checkable:**
- MD5 / SHA-1 used for passwords or sensitive data.
- `bcrypt` rounds < 10 (use 12+).
- AES in ECB mode.
- Random tokens generated with `Math.random()` instead of CSPRNG.
- TLS version pinned to < 1.2 in client code.

**Skill checks:**
- `grep -E '\bcreateHash\(["\']md5|sha1["\']'`
- `grep -E 'bcrypt.hash.*[0-9],\s*function'` (rounds < 10).
- `grep -E '\bMath\.random\(\).*token|secret|salt|nonce'`
- `grep -E 'createCipheriv\([^,]*,[^,]*,[^,]*\)' | grep -i ecb`

## A03 — Injection

**Code-checkable, hook-enforced + skill:**
- String-concatenated SQL: `"SELECT * FROM users WHERE id = " + id`.
- Template-literal SQL with user input: ``query(`...${userInput}...`)``.
- `eval()`, `Function()` constructors, `child_process.exec(userInput)`.
- Mongo query operators in user input (`$where`, `$ne`).

**Hook-enforced (`pre-tool-use.sh` extends in this commit):**
- Block writes containing `eval(\b` and `new Function(\b` in non-test files.
- Block `child_process.exec(\$\{` (template literal in exec).

**Skill checks:**
- ORM bypass detection: raw SQL helpers used in code that has an ORM.
- Concatenation patterns into query() calls.

## A04 — Insecure Design

**Skill checks (warns, doesn't block — design issues are judgment calls):**
- Missing rate limiting on auth endpoints.
- Email-only password reset (no second factor).
- Sensitive ops without audit logging.

## A05 — Security Misconfiguration

**Code-checkable:**
- `DEBUG=true` in env files committed to repo.
- CORS `*` on authenticated APIs.
- `helmet`/`secure-headers` not loaded in Node apps.
- Default admin credentials.

**Hook-enforced:**
- `.env` files already blocked by v3.2 Item A pre-commit hook.
- `cors({ origin: '*' })` on routes that look authenticated → skill warn.

## A06 — Vulnerable and Outdated Components

**Skill: `/arib-check-deps` already covers this.** OWASP A06 is the
deps audit. No additional checks needed.

## A07 — Identification and Authentication Failures

**Code-checkable:**
- Sessions with no `httpOnly: true` and `secure: true`.
- Passwords compared with `==` instead of constant-time.
- Magic link tokens with predictable generation.
- Login endpoints without rate limiting.

**Skill checks:**
- `grep cookie.*session` and confirm flags.
- `grep -E 'password.*===' ` in auth code.

## A08 — Software and Data Integrity Failures

**Code-checkable:**
- `unserialize` / `pickle.loads` on user input.
- Untrusted CDN scripts without SRI hashes.
- CI/CD secrets in repo.

**Hook-enforced:**
- Already covered by secret-scanning hook (v3.2 Item A).

## A09 — Security Logging and Monitoring Failures

**Code-checkable:**
- Auth failures not logged.
- Sensitive ops not audit-logged.
- Logs containing passwords or tokens (PII regex).

**Hook-enforced (added in this commit):**
- `pre-commit.sh` extends to detect `console.log(.*password)`,
  `logger.info(.*token)` patterns.

**Skill checks:**
- Grep auth handlers for `logger.warn`/`logger.error` on failure paths.
- Confirm all `200 OK` auth responses are not logged with the password.

## A10 — Server-Side Request Forgery (SSRF)

**Code-checkable:**
- `fetch(req.body.url)` / `axios.get(userInput)` without allowlist.
- Server-side image fetchers without host validation.

**Skill checks:**
- Grep for `fetch(`, `axios.get(`, `http.get(` with arguments derived
  from `req.body`, `req.query`, `req.params` and no obvious validation.

---

## Severity ladder

| Finding | Severity |
|---------|----------|
| String-concat SQL with user input | BLOCK |
| `eval()` on user input | BLOCK |
| Hardcoded credentials | BLOCK (already enforced) |
| MD5/SHA-1 for passwords | BLOCK |
| Missing auth check on a private route | BLOCK |
| Missing rate limit on login | WARN |
| CORS `*` on authenticated API | WARN |
| Outdated dependency w/ critical CVE | BLOCK (via `arib-check-deps`) |
| Outdated dependency, low-severity | WARN |

---

## What the OWASP framework does NOT cover

- Compliance with privacy law (use GDPR / PDPL docs).
- Operational security program maturity (use ISO 27001 doc).
- Audit attestation (use SOC 2 doc).

Use this doc for application-layer security. Use the others for the rest.
