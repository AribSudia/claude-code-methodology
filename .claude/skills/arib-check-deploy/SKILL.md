---
description: Check | Pre-deployment 7-phase verification - tests, security, DB, env, performance, docs, rollback
---

# /arib-check-deploy Command

## Overview

Deploying untested code to production causes outages, data loss, and user frustration. This skill enforces a strict pre-deployment verification protocol that catches ~95% of common deployment failures before they reach customers. It acts as a decision gate: code either passes all checks (safe to deploy) or hits a blocker that must be fixed first.

The protocol covers seven critical domains:
- **Pipeline integrity**: Linting, type checking, tests, build
- **Security**: No hardcoded secrets, secrets management validated
- **Data safety**: Migrations planned, rollback verified
- **Configuration**: Environment variables set correctly
- **Technical debt**: No critical TODOs/FIXMEs
- **Documentation**: Runbooks and rollback steps recorded
- **Risk mitigation**: Deployment plan and rollback gates

This is not optional - every production deployment must pass this protocol.

## Purpose
Pre-deployment verification to ensure the system is ready for production release.

## Trigger
User types `/arib-check-deploy`

## When to Use

**Required before EVERY production deployment:**
- New features going to prod
- Bug fixes on production branch
- Dependency updates
- Configuration changes
- Database schema changes
- Infrastructure changes

**Decision gates:** This skill produces either CLEARED (safe) or BLOCKED (do not deploy) verdict. No partial approvals.

## Deployment Readiness Checklist with Decision Gates

```
GATE 1: Pipeline Integrity
├─ Linting passes? [ ] YES [ ] NO
├─ Type checking passes? [ ] YES [ ] NO
├─ All tests passing? [ ] YES [ ] NO
└─ Build successful? [ ] YES [ ] NO
   └─ If ANY fail: BLOCKED - Fix and re-run

GATE 2: Security Validation
├─ No hardcoded secrets? [ ] YES [ ] NO
├─ Secrets use env vars? [ ] YES [ ] NO
├─ .env.example has no prod values? [ ] YES [ ] NO
└─ Secret manager configured? [ ] YES [ ] NO
   └─ If ANY fail: BLOCKED - No exceptions

GATE 3: Database & Data
├─ Migrations planned? [ ] YES [ ] NO [ ] N/A
├─ Rollback scripts exist? [ ] YES [ ] NO [ ] N/A
├─ Backup taken? [ ] YES [ ] NO [ ] N/A
└─ Schema is backwards-compatible? [ ] YES [ ] NO [ ] N/A
   └─ If migration fails: BLOCKED

GATE 4: Environment Configuration
├─ All required env vars documented? [ ] YES [ ] NO
├─ Staging/prod configs differ? [ ] YES [ ] NO
├─ Config management tool configured? [ ] YES [ ] NO
└─ Feature flags planned for gradual rollout? [ ] YES [ ] NO
   └─ If ANY fail: BLOCKED

GATE 5: Technical Debt Scan
├─ No TODOs in security code? [ ] YES [ ] NO
├─ No FIXMEs in critical paths? [ ] YES [ ] NO
├─ Documentation updated? [ ] YES [ ] NO
└─ Rollback plan written? [ ] YES [ ] NO
   └─ If TODOs in critical code: BLOCKED

GATE 6: Performance & Health
├─ Load tests passing? [ ] YES [ ] NO [ ] N/A
├─ Error budget OK? [ ] YES [ ] NO
├─ Monitoring alerts configured? [ ] YES [ ] NO
└─ Incident response team ready? [ ] YES [ ] NO
   └─ If monitoring missing: BLOCKED

GATE 7: Final Deployment Plan
├─ Deployment strategy defined? [ ] Zero-downtime [ ] Maintenance window [ ] Canary
├─ Rollback tested? [ ] YES [ ] NO
├─ Communication sent? [ ] YES [ ] NO
└─ On-call engineer assigned? [ ] YES [ ] NO
   └─ If plan incomplete: BLOCKED
```

## Environment-Specific Checks

### Staging Environment
- Use realistic data (cloned from prod if possible)
- Run full load tests
- Test backup/restore procedures
- Smoke test all critical user workflows
- Verify monitoring dashboards

### Production Environment
- Feature flags enabled for gradual rollout
- Database backups verified and tested
- On-call team briefed
- Runbook prepared
- Rollback plan reviewed and tested
- Deployment time window approved
- Customer communication prepared

## Common Deployment Failures and Prevention

| Failure | Root Cause | Prevention |
|---------|-----------|-----------|
| API key leaked | Committed secrets to git | Check for hardcoded secrets in every PR |
| Database locked during migration | Large ALTER on big table without CONCURRENTLY | Analyze table size, use zero-downtime patterns |
| Memory leak after deploy | Dependency vulnerability | Run `npm audit` before deploy |
| Configuration mismatch | Wrong env vars in prod | Use env var validation on startup |
| Cannot rollback | Irreversible migrations | Always create DOWN migration |
| Data corruption | Invalid migration logic | Test migrations on staging data |
| Users locked out | Authentication service down | Run integration tests pre-deploy |
| Missing monitoring | No alerts configured | Use deployment checklist |
| Cascading failures | One service down breaks others | Circuit breakers, timeout settings |
| Performance degradation | New index missing | Run EXPLAIN on queries |

## Zero-Downtime Deployment Patterns

### Pattern 1: Feature Flags (Recommended)
```javascript
// Deploy code for new feature behind flag
if (featureFlags.newCheckout) {
  return <NewCheckout />;
} else {
  return <OldCheckout />;
}

// Deployment: 1) Deploy code, 2) Enable flag gradually, 3) Monitor, 4) Full rollout
// Rollback: Flip flag off, no code rollback needed
```

### Pattern 2: Blue-Green Deployment
```
Step 1: Run both old and new services simultaneously
Step 2: Point load balancer to new service
Step 3: Monitor for errors
Step 4: Keep old service running for instant rollback
Step 5: After stability, shut down old service
```

### Pattern 3: Canary Deployment
```
Step 1: Deploy new version to 5% of instances
Step 2: Monitor error rates and latency
Step 3: If good, roll out to 25%, then 100%
Step 4: If problems, rollback the 5%
```

### Pattern 4: Database Migrations (Add/Deprecate/Drop)
```
Deployment 1 (Weeks 1-2):
- Add new column with default value
- New code writes to both old+new
- Old code still reads from old

Deployment 2 (Weeks 3-4):
- All code reads from new column
- Can safely rollback to Deployment 1

Deployment 3 (Weeks 5+):
- Drop old column
- Cannot rollback past this point
```

## Rollback Plan Template

```markdown
## Rollback Procedure [Release ID]

### Quick Rollback (< 5 minutes)
1. Feature flag rollback:
   - Set FEATURE_FLAGS="old_checkout:off,new_checkout:off"
   - Restart services
   
2. Code rollback:
   - git revert [commit] && git push
   - Wait for CI/CD pipeline
   
3. Verify:
   - Check error dashboard
   - Run smoke tests

### Full Rollback (< 15 minutes)
1. Stop new services: `kubectl scale deployment prod-new --replicas=0`
2. Verify traffic on old: `kubectl logs -f deployment/prod-old`
3. Restore from backup if data corruption:
   - POSTGRES_BACKUP=prod-20260419-1400
   - pg_restore $POSTGRES_BACKUP
   
4. Notify status page

### What NOT to do:
- Do NOT manually delete database records
- Do NOT try to "fix forward" during incident
- Do NOT skip the backup restore test

### Success Criteria:
- Homepage loads < 1 second
- Login success rate > 99%
- Database queries < 100ms
- Error rate < 0.1%

### Communication:
- Post: "We're rolling back due to [reason]"
- Update: "Rollback in progress - ETA 10 minutes"
- Resolved: "Service restored - no data loss - full incident report in 24h"
```

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
- [ ] Monitoring alerts configured
- [ ] Feature flags tested
- [ ] On-call team briefed
- [ ] Backup verified
- [ ] Load tests passed
- [ ] Incident response plan reviewed

## Edge Cases

### Edge Case: Large Data Migration
**Scenario:** Adding a NOT NULL column to a 500M-row table
**Problem:** Migration will lock entire table, users get 503 errors
**Solution (Add/Deprecate/Drop pattern):**
```sql
-- Deployment 1: Add column with default
ALTER TABLE users ADD COLUMN preferences JSONB DEFAULT '{}';
-- Application uses new column immediately

-- Deployment 2 (weeks later): Drop old way of doing it
ALTER TABLE users DROP COLUMN old_settings;
```

### Edge Case: Cannot Rollback
**Scenario:** Used DROP TABLE without backup plan
**Prevention:** BLOCKED - migrations must have rollback plan
```sql
-- BAD - no rollback possible
DROP TABLE legacy_data;

-- GOOD - safe to rollback
BEGIN;
ALTER TABLE legacy_data RENAME TO legacy_data_backup;
-- Monitor for 24h, then: DROP TABLE legacy_data_backup;
COMMIT;
```

### Edge Case: Downtime Window Requested
**Scenario:** Team wants 5-minute maintenance window
**Validation:**
- Announce on status page 48h in advance
- Disable traffic 30 seconds before
- Run migrations
- Smoke test
- Re-enable traffic
- Verify < 1s response times

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Skipping linting | Code quality degrades | ALL gate 1 checks mandatory |
| Hardcoded secrets | Credential theft | Grep for password/key/token |
| No rollback plan | Cannot recover from failure | Every migration needs DOWN |
| Testing only on staging | Production surprises | Run exact deploy command on staging first |
| Migrating without backup | Data loss | Verify backup can be restored |
| Deploying during traffic peak | Cascading failures | Deploy during low-traffic window |
| No monitoring configured | Can't detect failures | Alerts before deploy |
| Assuming rollback works | Won't recover in crisis | Test rollback procedure |
| Skipping security check | Leaked credentials | Grep all files for secrets |
| Single point of failure | Service down = total outage | Load balancers, circuit breakers |

## APPROVED vs BLOCKED Examples

### APPROVED - Safe to Deploy
```
CLEARED - Ready for deployment

Pipeline Status:
- Linting: PASS
- Type Checking: PASS
- Tests: PASS (287/287 passing, 100% coverage on changed files)
- Build: PASS (bundle size +2%, within limits)

Security:
- No hardcoded secrets found
- All dependencies have no critical CVEs
- Environment variables properly injected

Database:
- No migrations needed for this release

Environment:
- All prod env vars configured in Kubernetes
- Feature flags validated
- Monitoring alerts active

Technical Debt:
- 0 TODOs in security-critical code
- 0 FIXMEs in payment processing
- Rollback plan: Feature flag off, no code rollback needed

Deployment Plan:
- Strategy: Feature flag gradual rollout (5% -> 25% -> 100%)
- Duration: < 5 minutes
- Rollback: Feature flag off
- On-call: Sarah Chen (sarah@company.com, +1-555-0123)
- Announced: 2026-04-19 at 8am PT

Deployment can proceed.
```

### BLOCKED - Do Not Deploy
```
BLOCKED - Deployment is not safe

Blocking Issues:
1. 3 integration tests failing (PaymentService mock not returning correct response)
2. Hardcoded API key found in src/services/stripe.ts:142
3. Production database backup missing - last backup was 48h ago

Warnings:
- 12 npm vulnerabilities (2 HIGH): express@4.17.1 has RCE vulnerability
- Database migration without rollback plan
- No monitoring configured for new payment service

Required Actions Before Deployment:
1. FIX: Run test suite and fix failing tests (Estimated: 30 min)
2. FIX: Remove hardcoded key, inject via AWS Secrets Manager (Est: 15 min)
3. FIX: Create backup and verify restore works (Est: 20 min)
4. FIX: Upgrade express to 4.19.2 (Est: 10 min)
5. FIX: Create rollback plan for database changes (Est: 15 min)
6. ADD: Configure alerting for new payment service (Est: 20 min)
7. TEST: Run integration tests in staging environment (Est: 45 min)

Timeline Estimate: 2-3 hours of work

Once these are resolved, re-run /arib-check-deploy
```

## Related Skills

- **arib-check-migrate**: Run before deploying database changes
- **arib-check-deps**: Run before deploying dependency updates
- **arib-check-a11y**: Ensure new UI changes don't regress accessibility

## Notes
- ALL pipeline steps must pass before giving CLEARED status
- Be strict about security checks - this protects production
- Document environment variables clearly
- No exceptions to the pipeline requirements
- Always verify migrations carefully
- Critical path code must be clean of TODOs/FIXMEs
- Deployment is not optional - every change to prod needs this check
