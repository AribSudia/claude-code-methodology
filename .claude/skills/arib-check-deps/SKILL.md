---
name: arib-check-deps
argument-hint: "[--fix]"
description: Check | Audit dependencies - vulnerabilities, outdated packages, license compliance, supply chain safety
---

# /arib-check-deps Command

## Overview

Dependencies are your supply chain - if they're compromised, your application is compromised. This skill audits three critical supply chain risks:

1. **Security vulnerabilities (CVEs)**: Known exploitable bugs in dependencies
2. **License compliance**: Legal risk from incompatible or restrictive licenses
3. **Supply chain attacks**: Typosquatting, hijacked packages, malicious post-install scripts

The audit produces a risk report with severity classifications, auto-fixes unsafe updates, and flags dangerous patterns that require manual review.

A single critical CVE like RCE in your web server library can take down your entire application and compromise user data. This audit runs weekly and before every deployment.

## Purpose
Audit all project dependencies for security vulnerabilities (CVEs), outdated packages, license compliance issues, and supply chain risks. Produces a risk report and remediation plan.

## When to Use

- **Weekly**: Automated weekly scan (should be scheduled)
- **Before deployment**: Every prod deployment must pass this
- **After security advisory**: When new CVE announced, scan immediately
- **Quarterly**: Update strategy review (major versions)
- **Post-incident**: If compromised dependency discovered, audit everything

## Trigger
User types `/arib-check-deps [options]`

Examples:
- `/arib-check-deps` - Full dependency audit
- `/arib-check-deps --fix` - Audit + auto-fix safe updates
- `/arib-check-deps --licenses` - License compliance only
- `/arib-check-deps --critical` - Show only critical vulnerabilities

## CVE Severity Quick Reference (CVSS Scores)

| CVSS | Severity | Impact | Action Timeline |
|------|----------|--------|-----------------|
| 9.0-10.0 | CRITICAL | RCE, auth bypass, data exfiltration | Fix NOW (< 24h) |
| 7.0-8.9 | HIGH | Remote crash, privilege escalation | Fix this week |
| 4.0-6.9 | MODERATE | Local attack, partial data access | Fix this sprint |
| 0.1-3.9 | LOW | Minor info leak, edge case | Fix in next update cycle |

**Examples:**
- **CRITICAL (9.8)**: express@4.17.1 - RCE via HTTP header injection
- **HIGH (7.5)**: lodash@4.17.20 - Prototype pollution via template
- **MODERATE (5.3)**: cookie@0.4.0 - Regex DoS on large cookie
- **LOW (2.5)**: marked@0.3.6 - XSS in specific markdown syntax

## License Compatibility Matrix

| License | Commercial Use | Modification | Distribution | Risk for SaaS | Risk for Closed-Source |
|---------|---|---|---|---|---|
| MIT | ✓ | ✓ | ✓ | Safe | Safe |
| Apache-2.0 | ✓ | ✓ | ✓ | Safe (include NOTICE) | Safe |
| BSD-3 | ✓ | ✓ | ✓ | Safe | Safe |
| ISC | ✓ | ✓ | ✓ | Safe | Safe |
| MPL-2.0 | ✓ | ✓ | ✓ | Safe if not modified | Risky - file-level copyleft |
| LGPL-2.1 | ✓ | ⚠ | ⚠ | Safe if dynamic link | Risky if bundled |
| GPL-2.0 | ✓ | ✓ | **Viral** | **Must open-source** | **Blocks closed-source** |
| AGPL-3.0 | ✓ | ✓ | **Network-viral** | **Must open-source entire service** | **Blocks SaaS** |
| SSPL | ⚠ | ⚠ | **Custom only** | Requires commercial license | Requires commercial license |
| Unlicensed | ? | ? | **No permission** | BLOCKED | BLOCKED |

**GPL Example Problem:**
If you use GPL-2.0 library, your entire application (even parts not using that library) must be open-sourced or you're legally at risk.

**AGPL Example Problem:**
If you use AGPL-3.0 library in a SaaS product, users can demand the source code of your entire service because they're using it over the network.

## Supply Chain Attack Patterns to Detect

### Pattern 1: Typosquatting
```
Popular package: "lodash" (17M downloads/week)
Attacker publishes: "lodahs", "lodash2", "lo-dash" (similar names)
Risk: Developers mistype, install malicious package
Detection: npm audit signatures, check package repo/homepage
```

### Pattern 2: Hijacked Maintainer Account
```
Scenario: Popular package maintainer account hacked
Attacker publishes: "react@17.0.999" with malicious postinstall script
Detection: Monitor version activity, check publish dates, look for unusual changes
```

### Pattern 3: Postinstall Scripts
```bash
# BAD: Package runs arbitrary code on install
"scripts": {
  "postinstall": "node download.js" // Downloads and executes external code
}

# Detection: grep -r "postinstall" package.json
# Question: Why does this package need to run code during install?
```

### Pattern 4: Single-Maintainer With Many Downloads
```
Scenario: One person maintains 3,000-star package alone
Risk: Account compromise, burnout abandonment, sole point of failure
Detection: npm info [package] - check maintainers, github contributors
```

### Pattern 5: Recently Published (< 7 days)
```
Young package with high permissions: "crypto-util@1.0.0" published 2 days ago
Red flag: New packages don't have track record
Detection: npm info [package] | grep time
```

## Auto-Fix Decision Tree

```
START: Run npm audit
  |
  +-- CRITICAL vulnerabilities found?
  |   +-- YES: BLOCK deployment, show affected packages
  |   +-- NO: Continue
  |
  +-- Suggested fix is PATCH version bump? (e.g., 4.5.1 -> 4.5.2)
  |   +-- YES: Auto-fix safe, run tests
  |   +-- NO: Continue (MINOR/MAJOR require manual review)
  |
  +-- Tests pass after patch bump?
  |   +-- YES: Approve patch, commit separately
  |   +-- NO: Revert patch, mark as needs manual review
  |
  +-- Any MAJOR version bumps suggested?
  |   +-- YES: MANUAL REVIEW - check breaking changes in changelog
  |   +-- NO: Done
  |
  +-- License compliance check:
  |   +-- GPL/AGPL detected? BLOCK - needs legal review
  |   +-- Unlicensed? BLOCK - no permission to use
  |   +-- OK: Continue
  |
  +-- Supply chain check:
  |   +-- Postinstall script? MANUAL REVIEW
  |   +-- < 7 days old? MANUAL REVIEW
  |   +-- Single maintainer? FLAG for monitoring
  |   +-- OK: Complete
```

### When Safe to Auto-Fix
- PATCH updates only (x.y.Z where Z changes)
- All tests pass after update
- No breaking changes in code
- No new dependencies added
- Commit separately with message: "chore(deps): patch update [package]@[version]"

### When MUST Manual Review
- MAJOR version bumps (requires changelog review)
- GPL/AGPL licenses (legal implications)
- Postinstall scripts (code execution risk)
- New maintainer (verify legitimacy)
- Unlicensed packages (no permission)

## Instructions

### Step 1: Detect Package Manager

Identify the package manager and ecosystem:
- `package.json` + `package-lock.json` → npm
- `package.json` + `yarn.lock` → Yarn
- `package.json` + `pnpm-lock.yaml` → pnpm
- `requirements.txt` / `Pipfile` → pip / pipenv
- `*.csproj` / `packages.config` → NuGet
- `go.mod` → Go modules
- `Cargo.toml` → Cargo (Rust)
- `Gemfile` → Bundler (Ruby)

### Step 2: Vulnerability Scan

Run the appropriate audit command:

```bash
# Node.js (npm)
npm audit --json 2>/dev/null

# Node.js (yarn)
yarn audit --json 2>/dev/null

# Node.js (pnpm)
pnpm audit --json 2>/dev/null

# Python
pip-audit --format=json 2>/dev/null || safety check --json 2>/dev/null

# .NET
dotnet list package --vulnerable --format json 2>/dev/null

# Go
govulncheck ./... 2>/dev/null

# Ruby
bundle audit check 2>/dev/null
```

If the audit tool is not installed, recommend installation:
```bash
# For pip-audit
pip install pip-audit --break-system-packages

# For safety
pip install safety --break-system-packages

# For govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest
```

### Step 3: Classify Vulnerabilities

| Severity | Action Required | Timeline |
|----------|-----------------|----------|
| **CRITICAL** | Must fix immediately | Before next deploy |
| **HIGH** | Fix this sprint | Within 1 week |
| **MODERATE** | Plan fix | Within 1 month |
| **LOW** | Track | Next dependency update cycle |

### Step 4: Outdated Package Check

```bash
# Node.js
npm outdated --json 2>/dev/null

# Python
pip list --outdated --format=json 2>/dev/null

# .NET
dotnet list package --outdated --format json 2>/dev/null

# Go
go list -m -u all 2>/dev/null
```

Classify outdated packages:
- **Major version behind** → Review changelog for breaking changes before updating
- **Minor version behind** → Usually safe to update (test first)
- **Patch version behind** → Safe to update (bug/security fixes)

### Step 5: License Compliance Audit

```bash
# Node.js - list all licenses
npx license-checker --summary 2>/dev/null

# Node.js - check for problematic licenses
npx license-checker --failOn "GPL-2.0;GPL-3.0;AGPL-3.0" 2>/dev/null
```

License risk classification:

| License | Risk for Commercial Projects | Action |
|---------|------------------------------|--------|
| MIT, ISC, BSD-2, BSD-3 | ✅ Safe | No action needed |
| Apache-2.0 | ✅ Safe | Include NOTICE file |
| MPL-2.0 | ⚠️ Moderate | File-level copyleft - OK if not modifying |
| LGPL-2.1, LGPL-3.0 | ⚠️ Moderate | OK if dynamically linked, risky if bundled |
| GPL-2.0, GPL-3.0 | High | Viral copyleft - may require open-sourcing your code |
| AGPL-3.0 | Critical | Network copyleft - affects SaaS/server usage |
| SSPL, BSL | Critical | Non-open-source - check commercial terms |
| Unlicensed / Unknown | Critical | No license = no permission to use |

### Step 6: Supply Chain Risk Check

```bash
# Check for typosquatting (packages with suspicious names)
# Check for recently published packages (< 30 days old) with high permissions
# Check for packages with few maintainers and many downloads

# Node.js - check package provenance
npm audit signatures 2>/dev/null

# Check for install scripts that run arbitrary code
grep -r "preinstall\|postinstall\|preuninstall" package.json 2>/dev/null
```

Supply chain red flags:
- Package with `postinstall` script that downloads external code
- Package published < 7 days ago with high-privileged dependencies
- Package name similar to popular package (typosquatting)
- Package with single maintainer and no GitHub repository link
- Package requesting network access during installation

### Step 7: Auto-Fix (if --fix flag)

```bash
# Node.js - fix vulnerabilities with safe updates
npm audit fix 2>/dev/null

# Node.js - update to latest minor/patch (safe)
npx npm-check-updates -u --target minor && npm install

# Python
pip install --upgrade [package] --break-system-packages
```

**Rules for auto-fix:**
- Only auto-fix PATCH updates (x.y.Z)
- Only auto-fix if tests pass after update
- NEVER auto-fix MAJOR version bumps (breaking changes)
- Always run test suite after any dependency update
- Commit dependency updates separately from feature code

### Step 8: Generate Report

```markdown
# 🔒 Dependency Audit Report
**Date**: [DATE]
**Package Manager**: npm / pip / etc.
**Total Dependencies**: N (N direct + N transitive)

## Vulnerability Summary

| Severity | Count | Auto-fixable |
|----------|-------|--------------|
| Critical | N     | N            |
| High     | N     | N            |
| Moderate | N     | N            |
| Low      | N     | N            |

## Critical Vulnerabilities

### CVE-XXXX-XXXXX: [description]
- **Package**: [name]@[version]
- **Severity**: CRITICAL
- **Fix**: Upgrade to [version]
- **Breaking**: Yes/No

[... more vulnerabilities ...]

## Outdated Packages (Major)
| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|-----------------|
| [name]  | 3.2.1   | 5.0.0  | Yes - see changelog |

## License Issues
| Package | License | Risk | Action |
|---------|---------|------|--------|
| [name]  | GPL-3.0 | HIGH | Replace or get legal approval |

## Supply Chain Warnings
- ⚠️ [package] has postinstall script
- ⚠️ [package] was published 3 days ago

## Remediation Plan
1. `npm audit fix` - fixes N safe vulnerabilities
2. Upgrade [package] to [version] - fixes N more
3. Replace [package] with [alternative] - license issue
4. Review [package] postinstall script - supply chain risk

## Compliance Status
- Vulnerabilities: ⚠️ N unresolved
- Licenses: ✅ All compatible / N incompatible
- Supply Chain: ✅ Clean / ⚠️ N warnings
```

## Lockfile Integrity Checks

**Purpose:** Verify lockfiles match package manifests and are uncorrupted.

```bash
# npm: Verify lockfile matches package.json
npm install --dry-run
npm audit  # Automatically validates lockfile

# Yarn: Verify and regenerate if needed
yarn install --frozen-lockfile  # In CI, ensures no modifications
yarn install --update-lockfile  # Regenerate if corrupted

# pnpm: Verify lockfile integrity
pnpm install --frozen-lockfile
pnpm audit

# Check lockfile for suspicious patterns
grep -E "file:|git://|local path" package-lock.json  # Should be empty
```

**What to verify:**
- No `"file:"` dependencies (local paths in prod)
- No `"git://"` URLs (unreproducible builds)
- Hashes match actual packages
- No uncommitted changes post-audit
- Lockfile version matches package manager

## Edge Cases

### Edge Case: Transitive Dependency Vulnerability
```
Scenario:
- Your app uses: webpack@5.0.0
- webpack depends on: acorn@7.1.0
- acorn@7.1.0 has: ReDoS (regex DoS) vulnerability

Result: npm audit shows acorn in your dependency tree
Fix: Upgrade webpack to newer version that includes patched acorn
OR: npm audit fix --force (if no upgrade available)
```

### Edge Case: Pinned Version Too Old
```
Scenario: Project pins "lodash": "4.17.15" (from 3 years ago)
Result: Automated audit fails on outdated package
Decision: Upgrade to 4.17.21 (latest patch) if no breaking changes
OR: Document why pinned version is required
```

### Edge Case: License Conflict
```
Scenario: Two dependencies have GPL-2.0 and Apache-2.0
Problem: Incompatible licenses (GPL is more restrictive)
Solution: 
1. Check if you can replace GPL-2.0 dependency with compatible alternative
2. Get legal review if must keep both
3. Consider changing business model if GPL-3.0 detected in SaaS
```

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Ignoring CRITICAL CVEs | Hacked service, data loss | Auto-fix or upgrade immediately |
| Using `npm audit fix --force` blindly | Breaking changes in production | Test after any MAJOR bump |
| Not checking lockfile | Unreproducible builds, supply chain risk | Commit lockfile, verify no changes |
| GPL in closed-source app | Legal liability | Replace dependency or open-source |
| Outdated dependencies for years | Accumulation of CVEs | Upgrade PATCH quarterly, MINOR annually |
| Ignoring postinstall scripts | Malicious code execution | Review script, verify source |
| Single source of truth broken | Dependency drift between devs | Lockfile mandatory in version control |
| Skipping tests after update | Broken features in production | Run full test suite after any update |

## DEPENDENCY_DECISIONS.md Template

```markdown
# Dependency Decisions

## Why We Pin Versions

This file documents non-obvious version pins. Use semantic versioning (^, ~) by default.

### express@4.18.2 (pinned to patch)
- **Reason**: express@4.19.0+ has breaking changes in middleware handling
- **Status**: Waiting for our custom middleware to be updated
- **Action**: Upgrade to 4.19.2 by 2026-06-01
- **Owner**: Backend team

### react-query@3.39.3 (MAJOR version pinned)
- **Reason**: v4 has incompatible API, requires rewrite
- **Status**: Migration planned for Q3
- **Action**: Do not auto-upgrade to v4
- **Owner**: Frontend team

### node@18.17.1 (runtime)
- **Reason**: Node 20 breaks TLS connections to legacy payment provider
- **Status**: Provider upgrade expected Q2 2026
- **Action**: Test Node 20 migration in June
- **Owner**: DevOps

## Monorepo Dependency Strategy

All packages use caret ranges (^) by default to get PATCH/MINOR updates automatically.
MAJOR versions require manual review and testing across all packages.
```

## Related Skills

- **arib-check-deploy**: Run dependency audit before deployment
- **arib-check-security**: Extended security review beyond dependencies
- **arib-session-start**: Runs quick dep check at session start

## Notes
- This command extends the Security Auditor agent's scope to dependencies
- Run this audit at least weekly in active development
- Always run tests after dependency updates
- Major version updates should be done one at a time
- Keep a DEPENDENCY_DECISIONS.md for why specific versions are pinned
- License issues need legal review for commercial projects
- Supply chain security is as critical as code security
