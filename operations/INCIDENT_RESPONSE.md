# Incident Response — When Production Breaks

> **For all projects:** Even monoliths break. Every deployed project needs
> an incident response plan. The severity levels and communication protocol
> apply to all architectures. The distributed debugging sections apply mainly
> to microservices.

---

## Severity Classification

| Severity | Definition | Response Time | Who's Involved | Examples |
|----------|-----------|---------------|----------------|----------|
| **SEV1** | Complete outage, all users affected | **Immediate** (< 15 min) | Everyone available | Database down, app won't start, data breach |
| **SEV2** | Major feature broken, many users affected | **< 30 minutes** | On-call + relevant team | Payment processing down, auth broken, data corruption |
| **SEV3** | Minor feature broken, some users affected | **< 2 hours** | On-call engineer | Search not working, notifications delayed, minor UI bug |
| **SEV4** | Cosmetic issue or edge case | **Next business day** | Assigned engineer | Typo in UI, rare edge case, non-blocking bug |

### Severity Decision Tree

```
Is the application completely down?
  YES → SEV1
  NO  → Can users complete their primary workflow?
          NO  → Is it affecting >50% of users?
                  YES → SEV1
                  NO  → SEV2
          YES → Is a secondary feature broken?
                  YES → Is it customer-facing?
                          YES → SEV3
                          NO  → SEV4
                  NO  → SEV4
```

---

## The First 5 Minutes (SEV1/SEV2)

When you discover production is broken, follow this exact sequence:

```
MINUTE 0-1: CONFIRM
  □ Is it really broken? (not a local issue, not a test environment)
  □ Check monitoring dashboard / health endpoints
  □ Check error logs for the last 5 minutes
  □ Assign severity level

MINUTE 1-2: COMMUNICATE
  □ Post in #incidents channel: "Investigating [description], SEV[N]"
  □ Notify relevant team members
  □ Do NOT promise a timeline yet

MINUTE 2-5: ASSESS
  □ What changed? Check last deployment (git log, CI/CD)
  □ When did it start? (monitoring timeline)
  □ What's the blast radius? (which users, which features)
  □ Is there a quick mitigation? (rollback, feature flag, restart)
```

---

## Rollback Decision Framework

### Should You Rollback?

```
Was the last deployment < 4 hours ago?
  YES → Did the issue start after that deployment?
          YES → Can you rollback safely?
                  YES → ROLLBACK NOW, investigate later
                  NO  → Fix forward (see below)
          NO  → Issue is unrelated to deployment, investigate
  NO  → Issue is unrelated to recent deployment, investigate
```

### How to Rollback

```bash
# Option 1: Revert the deployment (most common)
git revert HEAD            # Revert last commit
git push origin main       # Trigger CI/CD to redeploy previous version

# Option 2: Deploy specific previous version
git checkout v1.2.2        # Known good version
# Deploy via CI/CD

# Option 3: Kubernetes rollback
kubectl rollout undo deployment/auth-service -n production

# Option 4: Helm rollback
helm rollback auth-service 1 --namespace production

# Option 5: Feature flag
# Disable the broken feature via feature flag dashboard
# No deployment needed
```

### When NOT to Rollback

- Database migration already ran (can't easily undo schema changes)
- Data has been written in the new format
- Multiple services deployed together with interdependencies
- Rollback would cause MORE damage than the current issue

In these cases: **Fix Forward** — deploy a targeted fix as fast as possible.

---

## Investigation Protocol

### Step 1: Gather Evidence (don't fix yet, understand first)

```bash
# Recent deployments
git log --oneline -10
kubectl rollout history deployment/[service] -n production

# Error logs (last 30 minutes)
# CloudWatch / Datadog / Grafana / kubectl
kubectl logs deployment/[service] -n production --tail=100 --since=30m

# Health check status
curl -s https://api.example.com/health | jq .

# Metrics (look for anomalies)
# - Request rate: sudden drop = outage
# - Error rate: sudden spike = bug
# - Latency: sudden spike = performance issue
# - CPU/Memory: spike = resource issue
# - DB connections: max = connection leak
```

### Step 2: Identify Root Cause

| Symptom | Likely Cause | Check |
|---------|-------------|-------|
| 5xx errors spiked | Code bug or dependency failure | Error logs, stack traces |
| Timeout errors | Slow dependency, DB, or external API | Latency metrics, DB slow query log |
| Connection refused | Service crashed or can't start | Container logs, health check |
| Out of memory | Memory leak or insufficient resources | Memory metrics, heap dumps |
| Database errors | Bad migration, connection exhaustion | DB logs, connection pool stats |
| Partial failures | One service down in a chain | Service health dashboard |
| Intermittent errors | Race condition or resource contention | Error patterns, timing |

### Step 3: Correlate with Changes

```bash
# What changed in the last 24 hours?
git log --all --oneline --since="24 hours ago"

# What was deployed?
# Check CI/CD pipeline history

# What config changed?
# Check environment variables, feature flags, external service status

# What external dependencies changed?
# Check status pages of: cloud provider, payment gateway, email service, CDN
```

---

## Communication Protocol

### During Incident

| Time | What to Communicate | Where |
|------|--------------------|----|
| **T+0** | "Investigating [description], SEV[N]" | #incidents channel |
| **T+15** | "Root cause identified/investigating, ETA: [X min]" | #incidents channel |
| **T+30** | "Fix deployed / mitigation applied / still investigating" | #incidents channel + stakeholders |
| **Every 30min** | Status update even if no progress | #incidents channel |
| **Resolution** | "Resolved: [what happened, what we did]" | #incidents channel + affected users |

### Status Update Template

```
🔴 INCIDENT UPDATE — SEV[N]
Time: [HH:MM UTC]
Status: Investigating / Identified / Mitigating / Resolved
Impact: [who is affected and how]
Summary: [what we know so far]
Next update: [time]
```

### After Resolution

```
✅ INCIDENT RESOLVED — SEV[N]
Duration: [X hours Y minutes]
Impact: [who was affected and how]
Root cause: [one sentence]
Resolution: [what we did to fix it]
Post-mortem: [scheduled date] / [link when published]
```

---

## Post-Mortem Template

Every SEV1 and SEV2 incident MUST have a post-mortem. SEV3 post-mortems are optional but recommended.

```markdown
# Post-Mortem: [Incident Title]

**Date**: [incident date]
**Duration**: [start time] — [end time] ([duration])
**Severity**: SEV[N]
**Author**: [name]
**Status**: Draft / Reviewed / Final

## Summary
[2-3 sentences describing what happened and the impact]

## Timeline (all times UTC)

| Time  | Event |
|-------|-------|
| HH:MM | [First sign of problem — how it was detected] |
| HH:MM | [Investigation started] |
| HH:MM | [Root cause identified] |
| HH:MM | [Mitigation applied] |
| HH:MM | [Full resolution confirmed] |

## Root Cause
[Detailed technical explanation of why this happened.
Not "who did it" — but what systemic issue allowed it.]

## Impact
- [N] users affected
- [N] minutes of downtime
- [N] failed transactions / lost data / etc.
- [Revenue impact if applicable]

## What Went Well
- [Thing 1 — e.g., "Monitoring detected the issue within 2 minutes"]
- [Thing 2 — e.g., "Rollback was clean and fast"]

## What Went Wrong
- [Thing 1 — e.g., "No alert was configured for this failure mode"]
- [Thing 2 — e.g., "Rollback procedure was unclear"]

## Action Items

| # | Action | Owner | Priority | Deadline | Status |
|---|--------|-------|----------|----------|--------|
| 1 | [Add monitoring for X] | [name] | HIGH | [date] | Pending |
| 2 | [Add test for Y] | [name] | HIGH | [date] | Pending |
| 3 | [Update runbook for Z] | [name] | MEDIUM | [date] | Pending |

## Lessons Learned
[What should we do differently next time?
Focus on systemic improvements, not individual blame.]

## Prevention
[What would have prevented this incident entirely?
What safety net would have caught it earlier?]
```

### Post-Mortem Rules

1. **Blameless**: Focus on systems, not individuals. "The process allowed X" not "Person Y caused X"
2. **Honest**: Document what actually happened, including missteps
3. **Actionable**: Every finding must have an action item with an owner and deadline
4. **Shared**: Post-mortems are shared with the whole team — learning is collective
5. **Timely**: Complete within 5 business days of the incident
6. **Tracked**: Action items must be tracked to completion (not just written)

---

## Runbook Library

### Runbook: Service Won't Start

```
1. Check container logs:
   docker compose logs --tail=50 [service]
   kubectl logs deployment/[service] -n production

2. Common causes:
   - Missing environment variable → check .env vs required vars
   - Database unreachable → check DB health, connection string
   - Port already in use → check for zombie containers
   - Bad configuration → check last commit that changed config
   - Out of memory → check resource limits, increase if needed

3. Fix: address root cause, restart service
4. Verify: health check returns 200
```

### Runbook: Database Connection Exhaustion

```
1. Check active connections:
   SELECT count(*) FROM pg_stat_activity;

2. Identify connection hogs:
   SELECT pid, usename, application_name, state, query_start
   FROM pg_stat_activity
   WHERE state != 'idle'
   ORDER BY query_start;

3. Common causes:
   - Connection pool too small for load
   - Connection leak (not closing connections)
   - Long-running queries holding connections
   - Too many service replicas × pool size > max connections

4. Immediate fix: kill idle connections
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE state = 'idle' AND query_start < NOW() - INTERVAL '10 minutes';

5. Permanent fix: increase pool size or fix connection leak
```

### Runbook: High Error Rate

```
1. Check error distribution:
   - Which endpoint(s) are failing?
   - What error codes? (500 = bug, 503 = overloaded, 502 = upstream down)
   - When did it start? (correlate with deployments)

2. Check dependencies:
   - Database healthy?
   - Cache (Redis) healthy?
   - Message broker healthy?
   - External APIs responding?

3. Check resources:
   - CPU usage > 90%? → scale horizontally
   - Memory usage > 90%? → check for leaks, increase limits
   - Disk full? → clean logs, expand volume

4. If caused by new deployment → rollback
5. If caused by load → scale up + add caching
6. If caused by dependency → check dependency status page, implement fallback
```

---

## Incident Response Checklist

### For Every Deployed Project

- [ ] Severity classification defined (SEV1-4)
- [ ] Communication channel identified (#incidents or equivalent)
- [ ] On-call rotation established (or single owner identified)
- [ ] Health check endpoint exists and is monitored
- [ ] Alerting configured for: service down, error rate spike, latency spike
- [ ] Rollback procedure documented and tested
- [ ] Post-mortem template available

### For Microservices (Additional)

- [ ] Service dependency map current (which failure cascades where)
- [ ] Circuit breakers configured and tested
- [ ] Distributed tracing available for cross-service debugging
- [ ] Per-service health dashboards
- [ ] Canary deployment for critical services
- [ ] Feature flags for quick disable of new features

### After Every SEV1/SEV2

- [ ] Post-mortem written within 5 business days
- [ ] Action items assigned with owners and deadlines
- [ ] Action items tracked to completion
- [ ] Monitoring gap that allowed the incident is closed
- [ ] Runbook updated with new knowledge
