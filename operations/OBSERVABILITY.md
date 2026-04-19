# Observability — Monitoring, Tracing & Logging

> **For all projects:** Logging and health checks sections apply to monoliths too.
> **Microservices-specific:** Distributed tracing, service mesh, and cross-service
> correlation are only needed for multi-service architectures.

---

## The Three Pillars

| Pillar           | What It Answers                           | Tool Examples                        |
|------------------|-------------------------------------------|--------------------------------------|
| **Logs**         | What happened?                            | ELK, Loki, CloudWatch, Datadog      |
| **Metrics**      | How is the system performing?             | Prometheus, Grafana, CloudWatch      |
| **Traces**       | Where did time go across services?        | Jaeger, Zipkin, OpenTelemetry, X-Ray |

All three are needed. Logs alone are not observability.

---

## 1. Structured Logging

### Format Standard

Every log entry MUST be structured JSON (not plain text):

```json
{
  "timestamp": "2026-04-17T10:30:00.123Z",
  "level": "info",
  "service": "auth-service",
  "traceId": "abc123def456",
  "spanId": "span_789",
  "correlationId": "req_xyz",
  "userId": "usr_456",
  "message": "User login successful",
  "data": {
    "method": "POST",
    "path": "/auth/login",
    "statusCode": 200,
    "durationMs": 45
  }
}
```

### Log Levels

| Level    | When to Use                                              | Example                              |
|----------|----------------------------------------------------------|--------------------------------------|
| `error`  | Something failed, needs attention                        | Database connection lost             |
| `warn`   | Something unexpected, system recovered                   | Retry succeeded after 2 attempts     |
| `info`   | Normal business events worth recording                   | User logged in, order created        |
| `debug`  | Development-only details (disabled in production)        | SQL query executed, cache hit/miss   |

### Rules

- **NEVER log secrets** — passwords, tokens, API keys, PII
- **ALWAYS include correlationId** — trace a request across services
- **ALWAYS include service name** — know which service generated the log
- **ALWAYS use structured format** — no `console.log("something happened")`
- **ALWAYS log request duration** — detect slow endpoints
- Keep log volume manageable — warn/info in prod, debug in dev only
- Rotate logs — max 7 days in prod, 30 days in archive

### Sensitive Data Masking

```javascript
// ❌ NEVER
logger.info("User login", { email: "user@example.com", password: "secret123" });

// ✅ ALWAYS
logger.info("User login", { email: maskEmail("user@example.com"), userId: "usr_456" });
// Output: { email: "u***@example.com", userId: "usr_456" }
```

---

## 2. Distributed Tracing (Microservices)

### What It Does

Traces a single request as it flows through multiple services:

```
Client → API Gateway → auth-service → core-service → payment-service
  │                        │               │               │
  └── traceId: abc123 ─────┴───────────────┴───────────────┘
        span 1: gateway (2ms)
          └── span 2: auth.validate (15ms)
              └── span 3: core.createOrder (45ms)
                  └── span 4: payment.charge (120ms)
```

### OpenTelemetry Setup

```javascript
// tracing.js — instrument at startup
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const provider = new NodeTracerProvider();
provider.addSpanProcessor(
  new BatchSpanProcessor(new JaegerExporter({
    endpoint: process.env.JAEGER_ENDPOINT || 'http://jaeger:14268/api/traces'
  }))
);
provider.register();
```

### Correlation ID Propagation

Every request gets a correlation ID at the API Gateway. Pass it through ALL services:

```
Header: X-Correlation-ID: req_abc123

Service A → includes in logs, passes to Service B
Service B → includes in logs, passes to Service C
Service C → includes in logs

All logs for this request can be found by searching: correlationId = "req_abc123"
```

### Rules
- Every HTTP request between services MUST propagate trace headers
- Every event published MUST include correlationId
- Every log entry MUST include traceId and correlationId
- Use OpenTelemetry (vendor-neutral) — don't lock into a specific tracing tool

---

## 3. Metrics & Monitoring

### The Four Golden Signals (Google SRE)

| Signal       | What It Measures                     | Alert When                         |
|--------------|--------------------------------------|------------------------------------|
| **Latency**  | How long requests take               | p99 > 500ms                        |
| **Traffic**  | Requests per second                  | Sudden spike or drop               |
| **Errors**   | Failed requests (5xx rate)           | Error rate > 1%                    |
| **Saturation**| Resource usage (CPU, memory, disk)  | CPU > 80%, memory > 85%           |

### Per-Service Metrics

Every service MUST expose:

```
# Request metrics
http_requests_total{service, method, path, status}
http_request_duration_seconds{service, method, path}

# Business metrics
[domain]_[entity]_created_total{service}
[domain]_[entity]_failed_total{service, reason}

# Infrastructure metrics
db_connections_active{service}
db_query_duration_seconds{service, query_type}
cache_hits_total{service}
cache_misses_total{service}
queue_messages_pending{service, queue}
circuit_breaker_state{service, target_service}
```

### Prometheus Endpoint

Every service exposes metrics at `/metrics`:

```
GET /metrics

# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/api/users",status="200"} 15234
http_requests_total{method="POST",path="/api/orders",status="201"} 892
http_requests_total{method="POST",path="/api/orders",status="500"} 3
```

---

## 4. Health Checks

### Standard Health Endpoint

Every service MUST expose `/health`:

```json
{
  "status": "healthy",
  "service": "core-service",
  "version": "1.2.3",
  "uptime": "4h 23m 12s",
  "checks": {
    "database": { "status": "healthy", "latencyMs": 2 },
    "redis": { "status": "healthy", "latencyMs": 1 },
    "auth-service": { "status": "healthy", "latencyMs": 15 },
    "message-broker": { "status": "healthy", "latencyMs": 3 }
  }
}
```

### Health Check Types

| Type          | Endpoint           | What It Checks                      | Used By              |
|---------------|--------------------|-------------------------------------|----------------------|
| **Liveness**  | `/health/live`     | Is the process running?             | Kubernetes           |
| **Readiness** | `/health/ready`    | Can it serve traffic?               | Load balancer        |
| **Startup**   | `/health/startup`  | Has it finished initializing?       | Kubernetes           |
| **Deep**      | `/health`          | All dependencies healthy?           | Monitoring dashboard |

---

## 5. Alerting Rules

### Critical (Page On-Call Immediately)

| Alert                         | Condition                       | Action                   |
|-------------------------------|---------------------------------|--------------------------|
| Service down                  | Health check fails 3x in a row  | Restart / investigate    |
| Error rate spike              | 5xx rate > 5% for 5 minutes     | Check logs, rollback?    |
| Database connection exhausted | Active connections > 90% of max | Scale DB or fix leak     |
| Circuit breaker OPEN          | Any circuit opens               | Check target service     |
| Disk usage critical           | Disk > 90%                      | Clean logs, expand disk  |

### Warning (Investigate Soon)

| Alert                         | Condition                       | Action                   |
|-------------------------------|---------------------------------|--------------------------|
| Latency degradation           | p99 > 500ms for 10 minutes      | Profile, check DB        |
| Queue backlog growing         | Pending messages > 1000         | Scale consumers          |
| Memory usage high             | Memory > 80%                    | Check for leaks          |
| Certificate expiring          | < 14 days to expiry             | Renew certificates       |

---

## 6. Dashboard Layout

### Service Overview Dashboard

```
╔══════════════════════════════════════════════════════════════╗
║  SERVICE HEALTH                                              ║
║  auth ● core ● notify ● payment ● analytics                 ║
║  (green = healthy, red = unhealthy, yellow = degraded)      ║
╠══════════════════════════════════════════════════════════════╣
║  REQUEST RATE          ERROR RATE           LATENCY (p99)   ║
║  [line chart]          [line chart]         [line chart]    ║
║  150 req/s             0.2%                 120ms           ║
╠══════════════════════════════════════════════════════════════╣
║  CPU USAGE             MEMORY USAGE         DB CONNECTIONS  ║
║  [gauge: 45%]          [gauge: 62%]         [gauge: 30/100]║
╠══════════════════════════════════════════════════════════════╣
║  RECENT ALERTS                                               ║
║  10:30 ⚠️ payment-service latency spike (p99: 650ms)         ║
║  09:15 ✅ auth-service circuit breaker recovered              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Observability Checklist

### For Every Service

- [ ] Structured JSON logging with correlation ID
- [ ] Health check endpoint (`/health`)
- [ ] Metrics endpoint (`/metrics`)
- [ ] Request duration logging
- [ ] Error rate tracking
- [ ] No secrets in logs

### For Microservices (Additional)

- [ ] Distributed tracing (OpenTelemetry)
- [ ] Trace header propagation (X-Correlation-ID)
- [ ] Circuit breaker state metrics
- [ ] Inter-service latency tracking
- [ ] Event processing metrics (published, consumed, failed)
- [ ] Dead-letter queue monitoring
- [ ] Service dependency dashboard
