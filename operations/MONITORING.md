# Production Monitoring & Alerting Guide

> **For all projects:** Every deployed application needs monitoring.
> This guide covers health checks, metrics, alerting rules, dashboards,
> SLOs/SLIs, on-call rotation, and escalation — the bridge between
> deployment and incident response.

---

## 1. The Monitoring Pyramid

```
                    ┌─────────────┐
                    │  BUSINESS   │  Revenue, signups, conversions
                    │  METRICS    │  "Is the business healthy?"
                    ├─────────────┤
                    │ APPLICATION │  Latency, errors, throughput
                    │   METRICS   │  "Is the app healthy?"
                    ├─────────────┤
                    │ INFRASTRUCTURE │  CPU, memory, disk, network
                    │    METRICS     │  "Are the servers healthy?"
                    ├────────────────┤
                    │   SYNTHETIC    │  Uptime checks, ping, health
                    │   MONITORING   │  "Is anything alive?"
                    └────────────────┘
```

Monitor **bottom-up** (you need servers before app, app before business),
but **alert top-down** (business impact matters more than CPU usage).

---

## 2. Health Check Standard

### Health Check Endpoint

Every service MUST expose a health check endpoint:

```
GET /health          → 200 OK (basic liveness)
GET /health/ready    → 200 OK (ready to serve traffic)
GET /health/deep     → 200 OK (all dependencies connected)
```

### Health Check Response Format

```json
{
  "status": "healthy",
  "version": "2.5.0",
  "uptime": "3d 14h 22m",
  "timestamp": "2026-04-18T10:30:00Z",
  "checks": {
    "database": { "status": "healthy", "latency": "3ms" },
    "redis": { "status": "healthy", "latency": "1ms" },
    "external_api": { "status": "degraded", "latency": "850ms" },
    "disk": { "status": "healthy", "usage": "42%" }
  }
}
```

### Health Status Values

| Status       | HTTP Code | Meaning                              | Action        |
|--------------|-----------|--------------------------------------|---------------|
| `healthy`    | 200       | Everything works                     | None          |
| `degraded`   | 200       | Working but a dependency is slow     | Monitor       |
| `unhealthy`  | 503       | Cannot serve requests properly       | Alert + page  |

### Implementation Examples

```typescript
// Express.js
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', version: process.env.APP_VERSION });
});

app.get('/health/deep', async (req, res) => {
  const checks = {};
  try {
    const dbStart = Date.now();
    await db.raw('SELECT 1');
    checks.database = { status: 'healthy', latency: `${Date.now() - dbStart}ms` };
  } catch (e) {
    checks.database = { status: 'unhealthy', error: e.message };
  }
  try {
    const redisStart = Date.now();
    await redis.ping();
    checks.redis = { status: 'healthy', latency: `${Date.now() - redisStart}ms` };
  } catch (e) {
    checks.redis = { status: 'unhealthy', error: e.message };
  }

  const allHealthy = Object.values(checks).every(c => c.status === 'healthy');
  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'healthy' : 'unhealthy',
    checks
  });
});
```

```python
# FastAPI
@app.get("/health")
async def health():
    return {"status": "healthy", "version": settings.APP_VERSION}

@app.get("/health/deep")
async def health_deep():
    checks = {}
    try:
        await database.execute("SELECT 1")
        checks["database"] = {"status": "healthy"}
    except Exception as e:
        checks["database"] = {"status": "unhealthy", "error": str(e)}

    all_healthy = all(c["status"] == "healthy" for c in checks.values())
    status_code = 200 if all_healthy else 503
    return JSONResponse(
        status_code=status_code,
        content={"status": "healthy" if all_healthy else "unhealthy", "checks": checks}
    )
```

---

## 3. The Four Golden Signals (Google SRE)

Every service should track these four signals:

### 3.1 — Latency

**What**: Time to serve a request (distinguish success from error latency).

```
Metric: http_request_duration_seconds
Labels: method, route, status_code
Percentiles: p50, p95, p99
```

**Alerting thresholds:**
| Metric | Warning    | Critical   |
|--------|------------|------------|
| p50    | > 200ms    | > 500ms    |
| p95    | > 500ms    | > 1000ms   |
| p99    | > 1000ms   | > 3000ms   |

### 3.2 — Traffic

**What**: Requests per second (demand on the system).

```
Metric: http_requests_total
Labels: method, route, status_code
Rate: requests_per_second = rate(http_requests_total[5m])
```

**Alerting thresholds:**
| Condition               | Alert                              |
|-------------------------|------------------------------------|
| Traffic drops > 50%     | Possible outage or routing issue   |
| Traffic spikes > 3x     | Load test, viral event, or DDoS   |
| Zero traffic > 5 min    | Service likely down                |

### 3.3 — Errors

**What**: Rate of failed requests (5xx, timeouts, application errors).

```
Metric: http_errors_total
Labels: method, route, status_code, error_type
Rate: error_rate = rate(http_errors_total[5m]) / rate(http_requests_total[5m])
```

**Alerting thresholds:**
| Metric          | Warning | Critical |
|-----------------|---------|----------|
| Error rate (5xx)| > 1%    | > 5%     |
| Error rate (4xx)| > 10%   | > 25%    |
| Timeout rate    | > 0.5%  | > 2%     |

### 3.4 — Saturation

**What**: How full the system is (CPU, memory, disk, connections).

```
Metrics:
  cpu_usage_percent
  memory_usage_percent
  disk_usage_percent
  db_connection_pool_usage_percent
  message_queue_depth
```

**Alerting thresholds:**
| Resource          | Warning | Critical |
|-------------------|---------|----------|
| CPU               | > 70%   | > 90%    |
| Memory            | > 75%   | > 90%    |
| Disk              | > 80%   | > 95%    |
| DB connections    | > 70%   | > 90%    |
| Queue depth       | > 1000  | > 10000  |

---

## 4. SLOs, SLIs, and Error Budgets

### Service Level Indicators (SLIs)

SLIs are the metrics you measure:

| SLI                    | Formula                                              |
|------------------------|------------------------------------------------------|
| Availability           | successful_requests / total_requests × 100            |
| Latency (p99)          | 99th percentile response time                        |
| Throughput             | requests per second at peak                          |
| Error Rate             | error_requests / total_requests × 100                |
| Freshness              | time since last successful data update               |

### Service Level Objectives (SLOs)

SLOs are the targets you set:

| Service Type           | Availability | Latency (p99) | Error Rate |
|------------------------|--------------|---------------|------------|
| User-facing API        | 99.9%        | < 500ms       | < 0.1%     |
| Internal API           | 99.5%        | < 1000ms      | < 1%       |
| Background jobs        | 99%          | < 30s         | < 5%       |
| Static content (CDN)   | 99.99%       | < 100ms       | < 0.01%    |

### Error Budget

```
Error Budget = 1 - SLO

Example: 99.9% availability SLO
  Error budget = 0.1% = 43.8 minutes/month of downtime allowed
  
  If you've used 30 minutes this month:
    Remaining budget: 13.8 minutes
    Action: slow down risky deployments

  If budget is exhausted:
    Action: freeze features, focus on reliability
```

| SLO       | Monthly Error Budget | Quarterly Error Budget |
|-----------|---------------------|----------------------|
| 99%       | 7.3 hours           | 21.9 hours           |
| 99.5%     | 3.65 hours          | 10.95 hours          |
| 99.9%     | 43.8 minutes        | 2.19 hours           |
| 99.95%    | 21.9 minutes        | 65.7 minutes         |
| 99.99%    | 4.38 minutes        | 13.14 minutes        |

---

## 5. Alerting Rules

### Alert Classification

| Severity  | Meaning                                  | Response Time | Notification      |
|-----------|------------------------------------------|---------------|-------------------|
| **P1**    | Service down, all users affected         | Immediate     | Page on-call      |
| **P2**    | Major degradation, many users affected   | < 15 min      | Page on-call      |
| **P3**    | Minor issue, some users affected         | < 1 hour      | Slack notification |
| **P4**    | Non-urgent, cosmetic or edge case        | Next business  | Ticket            |

### Alert Rules Template

```yaml
# Prometheus alert rules example

groups:
  - name: application
    rules:
      # P1: Service completely down
      - alert: ServiceDown
        expr: up{job="app"} == 0
        for: 2m
        labels:
          severity: P1
        annotations:
          summary: "Service {{ $labels.instance }} is down"
          description: "Health check has failed for > 2 minutes"

      # P1: Error rate critical
      - alert: HighErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m])
          / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: P1
        annotations:
          summary: "Error rate above 5% for {{ $labels.service }}"

      # P2: Latency degradation
      - alert: HighLatency
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 3
        for: 10m
        labels:
          severity: P2
        annotations:
          summary: "p99 latency above 3s for {{ $labels.service }}"

      # P3: Disk filling up
      - alert: DiskSpaceLow
        expr: disk_usage_percent > 80
        for: 30m
        labels:
          severity: P3
        annotations:
          summary: "Disk usage above 80% on {{ $labels.instance }}"

      # P2: Database connection exhaustion
      - alert: DBConnectionsHigh
        expr: db_connection_pool_usage_percent > 90
        for: 5m
        labels:
          severity: P2
        annotations:
          summary: "DB connection pool above 90%"

      # P3: Memory usage high
      - alert: MemoryHigh
        expr: memory_usage_percent > 90
        for: 15m
        labels:
          severity: P3
        annotations:
          summary: "Memory usage above 90% on {{ $labels.instance }}"
```

### Alert Quality Rules

1. **Every alert must be actionable** — if no human action is needed, it's not an alert
2. **Every alert must have a runbook link** — on-call should know what to do
3. **Reduce alert fatigue** — tune thresholds, use `for` duration to avoid flapping
4. **Alert on symptoms, not causes** — "error rate high" not "CPU high"
5. **Test alerts** — deliberately trigger alerts to verify they fire correctly

---

## 6. Dashboard Design

### Dashboard Hierarchy

```
Level 1: Executive Dashboard (1 screen)
  └── Overall system health: green/yellow/red
  └── Key business metrics: revenue, active users, conversion
  └── Error budget remaining

Level 2: Service Dashboard (per service)
  └── Four Golden Signals for this service
  └── Dependency health
  └── Recent deployments overlay

Level 3: Debug Dashboard (drill-down)
  └── Per-endpoint latency and error rates
  └── Database query performance
  └── Resource utilization details
```

### Dashboard Layout (per service)

```
┌─────────────────────────────────────────────────────────┐
│  SERVICE: auth-service    Status: ✅ Healthy            │
│  Version: 2.5.0           Uptime: 14d 6h               │
├──────────────────────┬──────────────────────────────────┤
│  REQUEST RATE        │  ERROR RATE                      │
│  ████████ 250 rps    │  ▁▁▁▁▁▂ 0.3%                   │
├──────────────────────┼──────────────────────────────────┤
│  LATENCY (p99)       │  SATURATION                     │
│  ████▃ 180ms         │  CPU: 35%  MEM: 62%  DISK: 41% │
├──────────────────────┴──────────────────────────────────┤
│  RECENT DEPLOYMENTS: v2.5.0 (2h ago) v2.4.9 (3d ago)  │
├─────────────────────────────────────────────────────────┤
│  TOP ERRORS (last 1h)                                   │
│  1. 401 /api/auth/login — 45 occurrences               │
│  2. 500 /api/auth/refresh — 3 occurrences              │
├─────────────────────────────────────────────────────────┤
│  DEPENDENCIES                                           │
│  PostgreSQL: ✅ 3ms  Redis: ✅ 1ms  Email API: ⚠️ 850ms │
└─────────────────────────────────────────────────────────┘
```

---

## 7. On-Call & Escalation

### On-Call Rotation

```markdown
## On-Call Schedule

| Role           | Hours          | Responsibility                     |
|----------------|----------------|------------------------------------|
| Primary        | 24/7 (1 week)  | First responder for all P1/P2      |
| Secondary      | 24/7 (1 week)  | Backup if primary doesn't respond  |
| Manager        | Business hours | Escalation for > 30 min incidents  |

### Rotation rules:
- Rotate weekly (Monday 10am handoff)
- Minimum 1 week between on-call shifts
- Handoff includes: open incidents, known issues, upcoming deployments
- Compensatory time off after on-call week
```

### Escalation Policy

```
T+0      Alert fires
  │
  ├── P1/P2: Page primary on-call (PagerDuty / OpsGenie / phone)
  │     │
  │     ├── T+5min: No acknowledgment → page secondary on-call
  │     │
  │     ├── T+15min: No acknowledgment → page engineering manager
  │     │
  │     └── T+30min: No resolution → escalate to VP Engineering
  │
  ├── P3: Slack notification to #alerts channel
  │     │
  │     └── T+1hr: No acknowledgment → page primary on-call
  │
  └── P4: Create ticket, assign to backlog
```

### On-Call Handoff Template

```markdown
## On-Call Handoff: [DATE]

### Open Issues
- [Issue 1]: Status, what's been done, what's needed

### Known Risks
- [Risk 1]: Deployment scheduled for [date], rollback plan ready
- [Risk 2]: External API has been flaky, circuit breaker at 50%

### Recent Changes
- [Change 1]: Deployed v2.5.0 — new auth flow, watch error rates
- [Change 2]: Database migration ran — monitor query latency

### Contacts
- Database team: @db-team in #database
- Infrastructure: @infra-team in #infrastructure
- Product: @product-manager for business impact decisions
```

---

## 8. Monitoring Stack Options

### Recommended Stacks

| Component       | Open Source           | Managed Service           |
|-----------------|----------------------|---------------------------|
| **Metrics**     | Prometheus + Grafana | Datadog / New Relic       |
| **Logs**        | ELK (Elasticsearch,  | CloudWatch / Datadog Logs |
|                 | Logstash, Kibana)    |                           |
| **Tracing**     | Jaeger / Zipkin      | Datadog APM / Honeycomb   |
| **Alerting**    | Alertmanager         | PagerDuty / OpsGenie      |
| **Uptime**      | Blackbox Exporter    | Pingdom / UptimeRobot     |
| **Error Track** | Sentry (self-hosted) | Sentry (cloud)            |

### Minimum Viable Monitoring

For a single-service application, start with:

```
1. Health check endpoint (/health)           ← Required
2. Uptime monitoring (UptimeRobot, free)     ← Required
3. Error tracking (Sentry, free tier)        ← Required
4. Application logs (stdout → CloudWatch)    ← Required
5. Basic metrics (Prometheus + Grafana)      ← Recommended
6. Alerting (PagerDuty or email alerts)      ← Recommended
```

---

## 9. Monitoring Checklist

### For Every Deployed Project

- [ ] Health check endpoint exists (`/health`)
- [ ] Uptime monitoring configured (checks every 1-5 minutes)
- [ ] Error tracking installed (Sentry or equivalent)
- [ ] Application logs structured (JSON, not plaintext)
- [ ] Four Golden Signals tracked (latency, traffic, errors, saturation)
- [ ] Alerting rules configured for P1 and P2 conditions
- [ ] On-call rotation established
- [ ] Escalation policy documented
- [ ] Dashboard exists for service health
- [ ] SLOs defined and tracked

### For Production Launch

- [ ] All monitoring checklist items above completed
- [ ] Load testing completed (know the system's limits)
- [ ] Alert thresholds tuned (no false positives in staging)
- [ ] Runbooks written for each alert (what to do when it fires)
- [ ] On-call engineers trained on the system
- [ ] Error budget tracking established
- [ ] Incident response plan linked to monitoring (see INCIDENT_RESPONSE.md)

### Quarterly Review

- [ ] Review alert frequency (too many = alert fatigue, tune thresholds)
- [ ] Review SLO compliance (meeting targets? adjust if needed)
- [ ] Review error budget consumption (burning too fast? slow down features)
- [ ] Update dashboards for new features/services
- [ ] Practice incident response (game day / chaos engineering)
