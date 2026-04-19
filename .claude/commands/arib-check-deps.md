---
argument-hint: "[--fix]"
description: Check | Audit dependencies - vulnerabilities, outdated packages, license compliance, supply chain safety
---

# /arib-check-deps Command

## Purpose
Audit all project dependencies for security vulnerabilities (CVEs), outdated packages, license compliance issues, and supply chain risks. Produces a risk report and remediation plan.

## Trigger
User types `/arib-check-deps [options]`

Examples:
- `/arib-check-deps` - Full dependency audit
- `/arib-check-deps --fix` - Audit + auto-fix safe updates
- `/arib-check-deps --licenses` - License compliance only
- `/arib-check-deps --critical` - Show only critical vulnerabilities

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

## Notes
- This command extends the Security Auditor agent's scope to dependencies
- Run this audit at least weekly in active development
- Always run tests after dependency updates
- Major version updates should be done one at a time
- Keep a DEPENDENCY_DECISIONS.md for why specific versions are pinned
- License issues need legal review for commercial projects
