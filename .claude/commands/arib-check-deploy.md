---
description: Check | Pre-deployment 7-phase verification - tests, security, DB, env, performance, docs, rollback
---

# /arib-check-deploy Command

## Purpose
Pre-deployment verification to ensure the system is ready for production release.

## Trigger
User types `/arib-check-deploy`

## Instructions

### Step 1: Activate DEPLOY GUARDIAN Agent Mode
Enter deployment verification mode with focus on:
- Pipeline integrity
- Security validation
- Data integrity
- Production readiness
- Risk minimization

### Step 2: Run Full Pipeline
Execute the complete build pipeline in order:

```
# Lint check
npm run lint (or equivalent)

# Type checking
npm run type-check (or equivalent)

# Test execution
npm test (or equivalent)

# Build process
npm run build (or equivalent)
```

Document results after each step. All steps must pass to proceed.

### Step 3: Verify No Secrets Committed
Check for accidentally committed secrets:
```
git log -p --all -S "password\|secret\|api_key\|token" | head -20
grep -r "password\|secret\|api_key\|API_KEY\|PRIVATE_KEY" --include="*.js" --include="*.ts" --include="*.env" src/ config/ 2>/dev/null || true
```

Verify:
- No API keys in code
- No database passwords in code
- No private credentials committed
- All secrets use environment variables

### Step 4: Verify Environment Configuration
Check environment setup:
- Required environment variables documented
- .env.example contains all required keys
- No production secrets in .env.example
- Environment variables properly loaded in code
- Different configs for dev/staging/production

### Step 5: Check Database Migrations
If applicable:
- All pending migrations documented
- Migration rollback scripts exist
- Data migration strategy clear
- Backup plan in place
- Zero-downtime migration plan confirmed

### Step 6: Scan for Technical Debt
Search for critical markers:
```
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.js" --include="*.ts" src/
```

In critical paths (authentication, payment processing, data handling):
- No TODOs in critical security code
- No FIXMEs in critical business logic
- Document any found items
- Flag if any are deployment blockers

### Step 7: Deployment Readiness Summary
Present findings in a clear report:

**CLEARED - Safe to Deploy**
```
CLEARED - Ready for deployment

Pipeline Status:
- Linting: PASS
- Type Checking: PASS
- Tests: PASS (XX/XX passing)
- Build: PASS

Security: All checks passed
Environment: Properly configured
Migrations: Ready (if applicable)
Technical Debt: None in critical paths

Deployment can proceed.
```

**BLOCKED - Do Not Deploy**
```
BLOCKED - Deployment is not safe

Blocking Issues:
1. [Issue 1 - must be fixed]
2. [Issue 2 - must be fixed]
3. [Issue 3 - must be fixed]

Warnings:
- [Warning 1]
- [Warning 2]

Required actions before deployment:
1. [Action 1]
2. [Action 2]

Once resolved, re-run /arib-check-deploy
```

### Step 8: Pre-Deployment Checklist
Provide a final checklist:
- [ ] All tests passing
- [ ] No secrets in code
- [ ] Environment variables configured
- [ ] Migrations ready (if applicable)
- [ ] No TODOs in critical paths
- [ ] Build successful
- [ ] Code reviewed and approved
- [ ] Rollback plan documented

## Notes
- ALL pipeline steps must pass before giving CLEARED status
- Be strict about security checks - this protects production
- Document environment variables clearly
- No exceptions to the pipeline requirements
- Always verify migrations carefully
- Critical path code must be clean of TODOs/FIXMEs
