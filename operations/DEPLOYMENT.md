# Deployment Guide — How to Ship to Production

> **Purpose**: Defines the exact process for deploying code to any environment.
> No shortcuts. No YOLO deploys.

---

## 1. Environments

| Environment | Purpose                    | URL Pattern              | Deploy Trigger        |
|-------------|----------------------------|--------------------------|-----------------------|
| Local       | Development                | localhost:[port]         | Manual                |
| Staging     | Pre-production testing     | staging.[PROJECT].com    | Merge to develop      |
| Production  | Live users                 | [PROJECT].com            | Manual approval       |

---

## 2. Pre-Deployment Checklist

Run `/deploy-check` or verify manually:

### Code Quality
- [ ] All linting passes (zero warnings)
- [ ] Type checking passes
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All E2E tests pass on staging
- [ ] Code review approved

### Security
- [ ] No secrets in codebase (`git log --all -p | grep -i "password\|secret\|api_key"`)
- [ ] Dependency audit clean (`npm audit` / `dotnet list package --vulnerable`)
- [ ] OWASP checklist reviewed for changed modules
- [ ] Security headers configured

### Data
- [ ] Database migrations tested on staging
- [ ] Migration rollback tested
- [ ] Seed data not included in production migration
- [ ] Backup taken before migration

### Configuration
- [ ] All environment variables set in production
- [ ] No development-only values in production config
- [ ] Feature flags configured correctly
- [ ] Monitoring and alerting configured

### Documentation
- [ ] API documentation updated
- [ ] Change log updated
- [ ] Memory files updated
- [ ] Runbook updated if infrastructure changed

---

## 3. Deployment Process

### Standard Deploy (Feature Release)

```
1. Merge feature → develop (after review)
2. Auto-deploy to staging
3. Run E2E tests on staging
4. QA verification on staging
5. Create release branch: release/vX.Y.Z
6. Final review + approval
7. Merge release → main
8. Tag: git tag vX.Y.Z
9. Deploy to production
10. Smoke test production
11. Monitor 30 minutes
12. Merge release → develop
13. Update operations log
```

### Hotfix Deploy (Critical Bug)

```
1. Create hotfix branch from main: hotfix/[description]
2. Fix the issue with minimal changes
3. Write regression test
4. Deploy to staging → verify fix
5. Get emergency review (1 approval minimum)
6. Merge hotfix → main
7. Tag: git tag vX.Y.(Z+1)
8. Deploy to production immediately
9. Verify fix in production
10. Merge hotfix → develop
11. Post-mortem within 24 hours
```

---

## 4. Rollback Procedure

### When to Rollback

- Error rate increases >5% after deploy
- Response time increases >50% after deploy
- Critical feature is broken
- Security vulnerability discovered

### How to Rollback

```bash
# Option 1: Git revert (preferred — maintains history)
git revert [bad-commit-hash]
git push origin main
# Redeploy from main

# Option 2: Deploy previous tag
git checkout v1.1.0    # last known good version
# Deploy this version

# Option 3: Database rollback (if migration caused issue)
# Run rollback migration FIRST, then code rollback
[framework-specific rollback command]
```

### After Rollback

1. Notify team immediately
2. Document in operations log
3. Create incident report
4. Root cause analysis within 24 hours
5. Fix on a separate branch, not directly on main

---

## 5. Monitoring Post-Deploy

### First 30 Minutes

- Watch error logs for new exceptions
- Check response times (should be within normal range)
- Verify critical paths work (login, core feature, payment if applicable)
- Check database connection pool metrics
- Verify external service integrations

### First 24 Hours

- Review error aggregation dashboard
- Check for memory leaks (gradual memory increase)
- Verify scheduled jobs are running
- Check user reports / support tickets

---

## 6. Infrastructure Configuration

### [PROJECT]-Specific Configuration

```yaml
# Fill in when instantiated for a project:
# Provider: [AWS / GCP / Azure / Vercel / Railway / etc.]
# Container: [Docker / Kubernetes / Serverless]
# CDN: [CloudFront / Cloudflare / etc.]
# DNS: [Route53 / Cloudflare / etc.]
# SSL: [ACM / Let's Encrypt / etc.]
# Monitoring: [Datadog / New Relic / Grafana / etc.]
# Logging: [CloudWatch / ELK / Loki / etc.]
# Alerting: [PagerDuty / OpsGenie / Slack / etc.]
```

---

> **End of Deployment Guide**
> Deploy with confidence. Rollback with speed. Monitor with vigilance.
