# Claude Code Methodology v2.6.0
## Training Manual 10: Production Safety Manual

**Version:** 2.6.0  
**Last Updated:** April 2026  
**Audience:** Full-stack developers, DevOps engineers, platform teams, engineering managers

---

## Table of Contents

1. [Introduction](#introduction)
2. [Database Guardian Agent](#database-guardian-agent)
3. [Performance Profiler Agent](#performance-profiler-agent)
4. [Dependency Audit](#dependency-audit)
5. [Incident Response Protocol](#incident-response-protocol)
6. [Monitoring & Alerting](#monitoring-alerting)
7. [API Documentation](#api-documentation)
8. [Accessibility Audit](#accessibility-audit)
9. [Production Launch Checklist](#production-launch-checklist)
10. [Example Scenario: Code to Production](#example-scenario)

---

## Introduction

Production safety is not about preventing all failures (impossible in distributed systems). It's about:

1. **Catching issues before they reach users**
2. **Containing failures when they happen**
3. **Recovering quickly with minimal data loss**
4. **Learning systematically from incidents**

This manual documents five safety gates that every feature must pass before reaching production. Together, they catch 90%+ of common issues.

### Safety Gates

```
Code
  ↓
├─→ [1] Database Guardian (migration safety)
├─→ [2] Performance Profiler (latency & resources)
├─→ [3] Dependency Audit (security vulnerabilities)
├─→ [4] Accessibility Audit (WCAG compliance)
├─→ [5] Incident Response Prep (runbooks ready)
  ↓
Production
```

---

## Database Guardian Agent

**When to Use:** Before any schema migration, data modification, or addition of constraints.

**Command:** `/migrate-check <migration-file>`

### Risk Classification

Every migration is classified LOW → CRITICAL:

| Risk | Characteristics | Example | Time to Revert |
|------|---|---|---|
| **LOW** | Backward-compatible, no lock, fast (<1s) | Add nullable column | <1min |
| **MEDIUM** | Non-blocking but requires monitoring | Add index CONCURRENTLY | 5-10min |
| **HIGH** | Locks table briefly, requires validation | Add NOT NULL with default | 30-60min |
| **CRITICAL** | Long lock or data loss risk | Change column type, drop column | >2 hours |

### Safe Migration Patterns

#### Pattern 1: Adding NOT NULL Column (3 Steps)

Problem: Adding `NOT NULL` locks table during backfill.

Solution:
```sql
-- Step 1: Add nullable column (no lock)
ALTER TABLE users ADD COLUMN phone_number VARCHAR(20);

-- Deploy code that populates phone_number
-- Monitor for 24 hours to ensure backfill working

-- Step 2: Add NOT NULL constraint (blocks INSERTs, not SELECTs)
ALTER TABLE users ADD CONSTRAINT phone_number_not_null 
  CHECK (phone_number IS NOT NULL) NOT VALID;
ALTER TABLE users VALIDATE CONSTRAINT phone_number_not_null;

-- Deploy code that requires phone_number
-- Monitor for 1 hour

-- Step 3: Make it a proper NOT NULL constraint
ALTER TABLE users ALTER COLUMN phone_number SET NOT NULL;
```

Timeline:
- Step 1: Prod deploy (1 minute, no impact)
- Wait 24 hours
- Step 2: Prod deploy (1 minute, validates constraint)
- Wait 1 hour
- Step 3: Prod deploy (1 minute, makes it real)

Total: 25+ hours (safe)

vs. Risky approach:
```sql
-- ✗ RISKY: Locks entire table for 30+ minutes
ALTER TABLE users ADD COLUMN phone_number VARCHAR(20) NOT NULL DEFAULT '';
-- Everything blocks while backfilling!
```

#### Pattern 2: Renaming Column (4 Steps)

Problem: Renaming breaks client code that uses old column name.

Solution:
```sql
-- Step 1: Add new column with data copy
ALTER TABLE orders ADD COLUMN total_price DECIMAL(10,2);
UPDATE orders SET total_price = amount WHERE amount IS NOT NULL;

-- Deploy code to write to BOTH columns
-- sql: INSERT INTO orders (amount, total_price) VALUES (..., ...)
-- sql: UPDATE orders SET amount = ?, total_price = ? WHERE id = ?

-- Monitor in production for 1 week (both columns in use)

-- Step 2: Deploy code to read new column
-- Replace all: SELECT amount FROM orders
-- With: SELECT total_price FROM orders
-- Keep writing to both for safety

-- Monitor for 1 week

-- Step 3: Stop writing to old column
-- Remove the write: sql: UPDATE orders SET amount = ...
-- Keep reads from new column

-- Monitor for 1 week (reads use new, writes use new)

-- Step 4: Drop old column
ALTER TABLE orders DROP COLUMN amount;
```

Timeline:
- Step 1: Backfill + deploy (1 hour total)
- Wait 1 week
- Step 2: Deploy (5 minutes)
- Wait 1 week
- Step 3: Deploy (5 minutes)
- Wait 1 week
- Step 4: Drop (30 seconds)

Total: 3+ weeks (safe)

#### Pattern 3: Adding Index CONCURRENTLY

Problem: `CREATE INDEX` locks table, blocking queries.

Solution:
```sql
-- CONCURRENT doesn't lock table (only locks transaction that uses new index)
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- Monitor index creation progress
SELECT * FROM pg_stat_progress_create_index;

-- Takes 2x longer but zero downtime
```

#### Pattern 4: Change Column Type

Problem: Converting `VARCHAR(20)` to `DECIMAL` requires table rewrite.

Solution: Don't do it in single migration. Use 3-step approach:

```sql
-- Step 1: Add new column with correct type
ALTER TABLE inventory ADD COLUMN stock_level_new INTEGER;

-- Deploy code that writes to both
-- INSERT INTO inventory (stock_level, stock_level_new)
-- UPDATE inventory SET stock_level_new = stock_level::INTEGER

-- Step 2: Backfill and migrate reads
-- Monitor data quality
SELECT COUNT(*) WHERE stock_level_new IS NULL;

-- Step 3: Drop old column
ALTER TABLE inventory DROP COLUMN stock_level;
ALTER TABLE inventory RENAME COLUMN stock_level_new TO stock_level;
```

### Size-Aware Analysis

The Guardian Agent analyzes your table size and estimates operation duration:

```
Table: orders
Size: 50 GB
Rows: 200 million

Proposed migration: ALTER TABLE orders ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT NOW()

Analysis:
- Operation: Full table rewrite (adds column to every row)
- Estimated duration: 4 hours
- Lock type: AccessExclusiveLock (blocks everything)
- Risk: CRITICAL

Recommendation:
- Add as nullable first (1 minute)
- Backfill in batches (4 hours, non-blocking)
- Add NOT NULL in 2 steps (2 minutes, 25 hours total)
```

Large tables (>1GB) require special handling:

```sql
-- ✗ Wrong: Locks table for hours
ALTER TABLE orders ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT NOW();

-- ✓ Right: Non-locking backfill
ALTER TABLE orders ADD COLUMN created_at TIMESTAMP;

-- Backfill in batches (allows normal traffic)
UPDATE orders SET created_at = NOW() 
  WHERE id BETWEEN 1 AND 1000000 AND created_at IS NULL;
-- Run this 200 times in separate transactions
-- Each transaction is fast and short-lived

-- Then add constraint
ALTER TABLE orders ALTER COLUMN created_at SET NOT NULL;
```

### Pre-Migration Checklist

Before any migration runs:

- [ ] Guardian Agent ran and classified risk
- [ ] If CRITICAL: Discussed with team and on-call
- [ ] Backup taken (and verified restorable)
- [ ] Rollback plan documented
- [ ] Code changes deployed first
- [ ] Monitoring dashboards ready
- [ ] On-call engineer aware
- [ ] Estimated duration < SLO window
- [ ] Lock duration < 5 minutes
- [ ] Data loss impossible (safe direction)

### Examples

**Example 1: Add indexes for new feature**
```
Migration: CREATE INDEX idx_orders_status ON orders(status);
Risk: MEDIUM (locks writes briefly)
Action: Use CONCURRENTLY, deploy at off-peak
```

**Example 2: Change int to bigint for ID overflow**
```
Migration: ALTER TABLE users ALTER COLUMN id TYPE BIGINT;
Risk: CRITICAL (table rewrite)
Action: Add new column, migrate in steps, 3 weeks
```

**Example 3: Add foreign key to existing data**
```
Migration: 
  ALTER TABLE orders ADD CONSTRAINT fk_orders_users 
  FOREIGN KEY (user_id) REFERENCES users(id);
Risk: CRITICAL if data is inconsistent
Action: First validate all orders.user_id exist in users
        Then add constraint
```

---

## Performance Profiler Agent

**When to Use:** Before deploying any feature that changes:
- API endpoints
- Database queries
- Frontend bundle
- Infrastructure

**Command:** `/perf-check <feature-name>`

### The 7-Step Protocol

#### Step 1: Establish Performance Budgets

Hard limits that code cannot exceed:

**API Performance Budgets:**
```
Endpoint: GET /v1/orders
- p50 latency: < 100ms (50th percentile, typical user)
- p95 latency: < 250ms (95th percentile, slower users)
- p99 latency: < 500ms (99th percentile, slowest users)
- Error rate: < 0.1% (SLA: 99.9% availability)

Endpoint: POST /v1/orders
- p50 latency: < 200ms (includes database write)
- p99 latency: < 1000ms (allows for retry logic)
- Error rate: < 0.01% (mission-critical endpoint)
```

**Frontend Performance Budgets:**
```
JavaScript Bundle:
- Size: < 200 KB (gzipped)
- Parse/Eval: < 50ms

CSS Bundle:
- Size: < 50 KB (gzipped)

Largest Contentful Paint (LCP):
- Target: < 2.5 seconds
- Threshold: < 4 seconds

First Input Delay (FID):
- Target: < 100ms
- Threshold: < 300ms

Cumulative Layout Shift (CLS):
- Target: < 0.1
- Threshold: < 0.25
```

**Database Performance Budgets:**
```
Query latency:
- p50: < 10ms
- p99: < 100ms

Full table scans:
- Count: 0 (should use index)

Missing indexes:
- Count: 0

```

#### Step 2: Baseline Measurement

Measure current state before code changes:

```bash
# API latency baseline
ab -n 1000 -c 10 https://api.example.com/v1/orders

# Results:
# Requests per second: 500
# p50 latency: 45ms ✓
# p99 latency: 280ms ✓

# Database query analysis
SELECT 
  query, 
  calls, 
  mean_time, 
  max_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 20;

# Results:
# Most expensive query: "SELECT ... FROM orders" - 8ms ✓

# Frontend bundle size
webpack --mode production --analyze

# Results:
# Bundle size: 145 KB ✓
# LCP: 2.1 seconds ✓
```

#### Step 3: Profile Under Load

Run the code with production-like traffic patterns:

```bash
# Load test with realistic traffic profile
k6 run load-test.js --vus 100 --duration 5m

# Results:
# p50: 52ms ✓
# p95: 198ms ✓
# p99: 410ms ✓
# 5xx errors: 0 ✓
```

#### Step 4: Analyze Flame Graphs

Identify where time is spent:

```
Before:
ORDER_GET (89ms)
├─ Auth verification (12ms)
├─ Query orders (45ms) ← DB is bottleneck
│  ├─ Table scan (35ms)
│  └─ JSON serialization (10ms)
├─ Cache lookup (8ms)
└─ Response send (24ms)

Problem: Orders table scan is missing index

After:
ORDER_GET (32ms)
├─ Auth verification (12ms)
├─ Query orders (8ms) ← Index hit, much faster
│  ├─ Index lookup (3ms)
│  └─ JSON serialization (5ms)
├─ Cache lookup (8ms)
└─ Response send (4ms)

Result: 2.8x faster (89ms → 32ms)
```

#### Step 5: Check for N+1 Patterns

Typical pattern: Query user, then loop and query profile for each:

```javascript
// ✗ Wrong: N+1 queries
const users = await db.query('SELECT * FROM users LIMIT 100');
for (const user of users) {
  user.profile = await db.query('SELECT * FROM profiles WHERE user_id = ?', user.id);
}
// 1 query for users + 100 queries for profiles = 101 total

// ✓ Right: Single batch query
const users = await db.query('SELECT * FROM users LIMIT 100');
const profiles = await db.query('SELECT * FROM profiles WHERE user_id IN (?)', users.map(u => u.id));
// 2 queries total

// ✓ Also right: Include in first query (JOIN)
const data = await db.query(`
  SELECT u.*, p.* FROM users u
  LEFT JOIN profiles p ON u.id = p.user_id
  LIMIT 100
`);
// 1 query total
```

Profiler detects:
```
N+1 pattern detected: User.profile loaded separately 100 times
Recommendation: Use JOIN or batch query
Estimated improvement: 90ms → 10ms (9x faster)
```

#### Step 6: Bundle Analysis

```bash
# What's in your bundle?
webpack-bundle-analyzer dist/bundle.js

# Results:
# react.js: 40 KB (38%)
# lodash: 25 KB (24%)
# moment.js: 15 KB (14%)
# your code: 20 KB (19%)

# Recommendations:
# - Replace moment.js with date-fns (3 KB, 80% smaller)
# - Remove unused lodash methods (tree-shake)
# - Code split: Move non-critical code to separate bundle

# After optimization:
# React: 40 KB
# date-fns: 3 KB
# your code: 18 KB
# Total: 61 KB (was 100 KB, 39% reduction)
```

#### Step 7: Memory Leak Detection

Run under sustained load and check memory:

```bash
# Start app and monitor memory
node --inspect app.js

# Connect Chrome DevTools
# Record heap snapshots at 1 hour, 2 hours, 3 hours

# Healthy: Memory stable or growing <10% per hour
# Leak: Memory growing >50% per hour

# Example leak:
# 1 hour: 120 MB
# 2 hours: 280 MB (leaked 160 MB)
# 3 hours: 420 MB (leaked 140 MB more)
# = Memory leak of ~140 MB/hour

# Root cause analysis:
# 1. Take heap snapshot when large
# 2. Compare to previous snapshot
# 3. Find retained objects

# Common causes:
# ✗ Event listeners not removed
# ✗ Timer callbacks not cleared
// ✓ Listen once: listener('event', once: true)
// ✓ Clear timer: clearInterval(timerHandle)
```

### Performance Budgets (Complete Reference)

#### API Endpoints

```yaml
Budgets:
  ListEndpoints (GET /v1/resource):
    p50: 100ms
    p99: 500ms
    error_rate: < 0.1%
  
  CreateEndpoint (POST /v1/resource):
    p50: 200ms
    p99: 1000ms
    error_rate: < 0.01%
  
  UpdateEndpoint (PUT /v1/resource/:id):
    p50: 150ms
    p99: 750ms
    error_rate: < 0.01%
  
  DeleteEndpoint (DELETE /v1/resource/:id):
    p50: 100ms
    p99: 500ms
    error_rate: < 0.01%
```

#### Frontend

```yaml
Budgets:
  JavaScript:
    # Modern browsers can parse/eval 1MB per second
    # Target: <200KB so even slow networks (slow 3G) load in <2s
    InitialBundle: 200 KB
    LazyLoadBundles: 50 KB each
    
  CSS:
    # CSS blocks rendering until loaded
    # Keep small to not block LCP
    CriticalCSS: 15 KB
    TotalCSS: 50 KB
  
  Web Vitals:
    # Core Web Vitals from Google
    LCP: 2.5 seconds  # When largest element paints
    FID: 100 ms       # How fast page responds to input
    CLS: 0.1          # How much does layout shift? (0 = stable)
    
    # Additional important metrics
    TTFB: 600 ms      # Time to first byte from server
    FCP: 1.8 seconds  # When any content paints
    TTI: 3.5 seconds  # When page is interactive
```

#### Database

```yaml
Budgets:
  Query:
    p50: 10 ms
    p99: 100 ms
  
  Transaction:
    p50: 50 ms
    p99: 500 ms
  
  Constraints:
    FullTableScans: 0
    MissingIndexes: 0
    SlowQueries: 0
```

### Real-World Examples

**Example 1: Adding Filter to List Endpoint**

Before:
```
GET /v1/orders (no filter)
- Query: SELECT * FROM orders LIMIT 100
- Duration: 45ms
- Result: 100 orders
```

After:
```
GET /v1/orders?status=pending (with filter)
- Query: SELECT * FROM orders WHERE status = ? LIMIT 100
- WITHOUT INDEX: 450ms ✗ (10x slower, exceeds budget)
- WITH INDEX: 48ms ✓ (same speed)

Action: Add index
CREATE INDEX idx_orders_status ON orders(status);
```

**Example 2: Frontend Bundle Growing**

Before:
```
npm run build
- Bundle size: 145 KB ✓
- LCP: 2.1s ✓
```

After adding feature:
```
npm run build
- Bundle size: 285 KB ✗ (exceeds 200 KB budget)
- LCP: 3.8s ✗ (exceeds 2.5s budget)

Analysis:
- Added lodash-es (full): +50 KB
- Added moment.js: +60 KB
- Added react-select (not tree-shook): +30 KB

Actions:
- Replace lodash with cherry-picked functions: -45 KB
- Replace moment with date-fns: -55 KB
- Code split react-select: -30 KB
- Result: 145 KB ✓, LCP: 2.2s ✓
```

**Example 3: N+1 on User Profile**

Profile page loads user + 5 related queries:

Before:
```
User fetch: 5ms
Address fetch: 8ms
Orders fetch: 12ms
Notifications fetch: 6ms
Preferences fetch: 4ms
Total: 35ms (serial) → 6ms (parallel with Promise.all)
```

But had N+1:
```
Actually doing:
for each user:
  fetch address → 8ms
  fetch orders → 12ms
  fetch notifications → 6ms
  fetch preferences → 4ms
Total per user: 30ms
For 20 users on page: 600ms ✗

Fix: Batch all queries
SELECT addresses WHERE user_id IN (...)
SELECT orders WHERE user_id IN (...)
Total: 45ms (2 queries instead of 80)
```

---

## Dependency Audit

**When to Use:** Before deploying any dependency change (add, update, remove).

**Command:** `/dependency-audit <package-name>` or `/dependency-audit --fix`

### CVE Scanning

Automatically scan for security vulnerabilities:

```bash
$ npm audit
found 12 vulnerabilities (8 moderate, 4 critical)

lodash 4.17.19:
  Prototype Pollution in lodash
  Severity: high
  Affected: lodash@4.17.19
  Fixed: lodash@4.17.21
  https://nvd.nist.gov/vuln/detail/CVE-2021-23337

  # Risk: Can cause DoS or code execution
  # Action: npm install lodash@4.17.21
```

### Outdated Packages

Identify packages that are out of date:

```
Package      Current  Latest  Type     Risk
lodash       4.17.19  4.17.21 PATCH    LOW
express      4.17.0   4.18.2  MINOR    LOW
react        16.13.1  18.2.0  MAJOR    HIGH
next         10.0.0   13.0.0  MAJOR    CRITICAL
```

**Version meaning:**
- PATCH (4.17.19 → 4.17.21): Bug fixes only, safe
- MINOR (4.17 → 4.18): New features, backward compatible
- MAJOR (16 → 18): Breaking changes, requires code updates

**Decision:**
- PATCH: Always update
- MINOR: Usually safe, test first
- MAJOR: Requires code review, test thoroughly

### License Compliance

Verify all dependencies have acceptable licenses:

```
Package        License    Risk      Action
lodash         MIT        ✓ Safe    OK
express        MIT        ✓ Safe    OK
moment         MIT        ✓ Safe    Replace with date-fns
react          MIT        ✓ Safe    OK
webpack        MIT        ✓ Safe    OK
webpack-cli    MIT        ✓ Safe    OK
GPL-3-package  GPL-3      ✗ RISK    Remove or replace

License Risk Scale:
MIT/Apache/BSD      → SAFE (permissive)
ISC/Unlicense       → SAFE (public domain)
GPL-2/GPL-3         → CAUTION (reciprocal)
AGPL-3              → CRITICAL (restrict)
Proprietary/Custom  → CRITICAL (unclear)
```

### Supply Chain Risk

Identify suspicious packages:

```
Package: leftpad
Version: 1.0.0
Published: 5 minutes ago  ← TOO RECENT
Downloads: 2             ← TOO LOW
GitHub: None             ← NO SOURCE
Author: NEW              ← NO HISTORY

Risk: CRITICAL
Action: Do not use
Recommendation: Use trusted packages with history
```

Audit questions:
- [ ] Is package actively maintained? (commit in last 3 months)
- [ ] Does it have multiple maintainers? (reduces bus factor)
- [ ] Is it published from verified account? (no compromised accounts)
- [ ] Are there security policies? (SECURITY.md)
- [ ] How many downloads? (>1M weekly = trusted)

### Auto-Fix Strategy

```bash
# Option 1: Fix all PATCH updates (safe)
npm update

# Option 2: Fix major version for specific package
npm install react@18.2.0

# Option 3: Fix with audit
npm audit fix

# Results:
# Before: 12 vulnerabilities
# After: 0 vulnerabilities
# Updated: lodash, express, react
# Manual review needed: 2 MAJOR versions
```

### Examples

**Example 1: Security vulnerability in production**

```
Package: express
CVE: Express is vulnerable to XSS if not escaped
Status: CRITICAL

Decision: Emergency patch
Action: npm install express@4.18.2
Test: npm run test:security
Deploy: Immediate
```

**Example 2: Major version upgrade**

```
Package: react 16 → 18
Changes: Hooks required, concurrent rendering
Complexity: 3-4 day refactor

Decision: Schedule in next sprint
Action: Create branch, upgrade, fix tests
Test: Thoroughly (react is core)
Risk: HIGH (fundamental to app)
Timeline: Sprint 5
```

**Example 3: GPL dependency conflict**

```
Package: GPL-3 package in commercial product
Risk: CRITICAL (GPL requires open-sourcing)

Decision: Remove or replace
Options:
1. Remove (if optional feature)
2. Replace with MIT alternative
3. Consult legal team (if critical)

Example: webpack-contrib-plugin (GPL)
Alternative: webpack-cli (MIT) + custom plugin
```

---

## Incident Response Protocol

**Location:** `operations/INCIDENT_RESPONSE.md`

### SEV Classification with Decision Tree

```
🔴 Severity 1 (SEV1) - Critical

Impact: Large portion of users cannot use service
Examples:
- API down (0 RPS)
- Database unreachable
- Payment processing failing
- Authentication broken

Response: IMMEDIATE
Duration: < 5 minutes
- Page on-call engineer
- War room started
- Post-mortem scheduled
- Customer comms prepared

Status: All hands on deck
```

```
🟠 Severity 2 (SEV2) - Major

Impact: Many users affected but workaround possible
Examples:
- API responding but with errors (>50% failure rate)
- Feature broken but other features working
- Degraded performance (p99 > 10s)
- One service down, others operational

Response: URGENT (within 15 min)
Duration: < 30 minutes
- Assign incident commander
- Alert team leads
- Prepare customer comms

Status: Most hands on deck
```

```
🟡 Severity 3 (SEV3) - Moderate

Impact: Small subset of users, feature degraded
Examples:
- One feature slow (p99 > 500ms)
- Error rate < 1%
- One region affected
- Degradation during peak hours

Response: SOON (within 1 hour)
Duration: < 2 hours
- Assign engineer
- Monitor closely
- Investigate root cause

Status: Notify relevant team
```

```
🟢 Severity 4 (SEV4) - Minor

Impact: Cosmetic or very few users
Examples:
- Email delivery delayed (users don't notice)
- Typo in UI
- Scheduling issue (resolved on next run)
- One user reported issue

Response: NEXT BUSINESS DAY
Duration: No urgency
- Log for future sprint
- Fix in normal flow

Status: No special response
```

### Decision Tree

```
Is production service down or has >50% failure rate?
  YES → SEV1
  NO → Continue

Are many users (>1% of daily active) affected?
  YES → SEV2
  NO → Continue

Are some users affected?
  YES → SEV3
  NO → SEV4
```

### First 5 Minutes Protocol

**Minute 1: Detect & Alert**
```
- Monitoring fires alert
- On-call engineer pages
- War room opened (Slack or Zoom)
- Incident declared in status page
```

**Minute 2: Assess & Triage**
```
Engineer joins and immediately:
- What is broken? (which service, feature, endpoint)
- How many users affected? (RPS, error rate)
- What changed? (recent deployments, config changes)
- What's the severity? (SEV1-4)
```

Quick assessment checklist:
- [ ] Is error rate > 50%? (SEV1)
- [ ] How many users can't complete action? (0 = normal)
- [ ] Is this known issue? (check docs)
- [ ] What was last deployment? (correlation)

**Minute 3: Initiate Response**
```
If SEV1:
  - Start recording for post-mortem
  - Notify customers (status page update)
  - Assemble full team
  - Begin investigation

If SEV2-3:
  - Single engineer investigates
  - Team on standby

If SEV4:
  - Log and continue monitoring
```

**Minute 4-5: Stop the Bleeding**
```
Quick wins to consider:
- Restart service (50% of issues)
- Rollback last deployment (if timing matches)
- Scale up service (if CPU/memory maxed)
- Disable feature flag (if safe)
- Drain traffic to backup service
```

### Rollback Decision Framework

Decide in <2 minutes whether to rollback:

```
Question 1: Can we rollback in <5 minutes?
  NO → Investigate (5 min for root cause)
  YES → Continue

Question 2: Is rollback safe?
  (Check: data inconsistency risk, in-flight transactions)
  NO → Investigate instead
  YES → Continue

Question 3: Does rollback solve the issue?
  (Check: was this deployed in last 30 min?)
  NO → Investigate instead
  YES → ROLLBACK

Decision: ROLLBACK
Execution:
  1. Inform customers (status page: "deploying fix")
  2. Rollback: git revert + deploy
  3. Monitor: 5 min until stable
  4. Verify: test critical paths
  5. Root cause investigation (async)
```

**5 Rollback Methods:**

1. **git revert + re-deploy** (safest)
   ```bash
   git revert HEAD
   git push
   # Deploy system picks up change
   # Time: 2-5 minutes
   ```

2. **Restart with previous Docker image**
   ```bash
   kubectl set image deployment=api api=registry/api:v1.2.3
   # Instant (pull from cache)
   # Time: 30 seconds
   ```

3. **Scale to previous version via traffic split**
   ```bash
   # If running v1.2.3 and v1.2.4 side-by-side
   # Shift 100% traffic back to v1.2.3
   # Time: <10 seconds
   ```

4. **Disable feature flag**
   ```bash
   # If issue is in new feature behind flag
   redis-cli SET feature:new-checkout enabled false
   # Time: <1 second
   ```

5. **Restore from database backup**
   ```bash
   # Only if data corruption
   # Time: 30 minutes+
   # Last resort
   ```

### Investigation Protocol

```
Phase 1: Gather Information (5 minutes)
- What's the error? (logs, user reports, metrics)
- When did it start? (correlation with deployment/alert)
- What's the pattern? (all users, one region, one endpoint?)
- What's the scope? (just this service, cascading to others?)

Phase 2: Correlate (5 minutes)
Timeline:
  15:23:00 - Service started seeing errors
  15:23:02 - Monitoring alert fired
  15:23:30 - Engineer picked up alert
  15:22:45 - Deployment v1.2.4 to api-service ← CORRELATION
  
Hypothesis: Deployment v1.2.4 caused issue

Phase 3: Validate Hypothesis (5 minutes)
- Rollback to v1.2.3 → Error stops? → CONFIRMED
- Compare code changes between versions
- Identify the specific change

Phase 4: Deep Dive (30+ minutes)
- Reproduce in staging
- Add logging/debugging
- Understand root cause
- Implement permanent fix

Phase 5: Deploy Fix
- Test thoroughly
- Deploy during low traffic
- Monitor closely
- Collect metrics
```

### Communication Protocol

For SEV1-2 incidents, communicate every 5 minutes:

```
15:23 - "Our API is experiencing elevated error rates. Investigating."
15:28 - "Root cause identified: recent deployment. Rolling back now."
15:33 - "Rollback in progress, should be resolved in 2 minutes."
15:38 - "Service recovered. Monitoring for stability. Will post post-mortem within 24 hours."
```

### Post-Mortem Template

**Blameless Post-Mortem** (within 24 hours):

```markdown
# Incident Post-Mortem: API errors on Apr 18

## Summary
- **Date:** April 18, 2026, 15:23 UTC
- **Duration:** 15 minutes
- **Severity:** SEV2
- **Impact:** 45% of API requests failed for 15 minutes, affecting ~100k users

## What Happened
Deployment v1.2.4 contained a change to the order processing logic that 
assumed an optional field was present. This field was null for 30% of orders, 
causing JSON serialization to fail.

## Timeline
- 15:22:45 - Deployment v1.2.4 to production
- 15:23:00 - Error rate spike detected
- 15:23:30 - Engineer on-call alerted
- 15:25:00 - Rollback initiated
- 15:27:00 - Error rate returned to normal
- 15:38:00 - Service stable, post-mortem started

## Root Cause
The code change in v1.2.4 did not handle the case where `order.discount` 
could be null (backward compatibility with old orders). New code assumed 
it was always a number.

**Code:**
```javascript
// v1.2.4 (broken)
const totalWithDiscount = order.total - order.discount;
// ✗ If order.discount is null, result is NaN

// v1.2.3 (working)
const totalWithDiscount = order.total - (order.discount || 0);
// ✓ Treats null as 0
```

## Why It Wasn't Caught
1. **Unit tests** didn't cover null case (test gap)
2. **Staging** doesn't have legacy data with null discounts
3. **Code review** focused on logic, not edge cases

## Action Items
1. [IMMEDIATE] Update unit tests to include null/undefined cases
2. [TODAY] Update code review checklist to include "edge cases"
3. [THIS WEEK] Load prod data (anonymized) into staging
4. [THIS WEEK] Add contract tests to verify old/new format compatibility
5. [NEXT SPRINT] Add automated testing for backward compatibility

## Lessons
- Backward compatibility is easy to miss
- Staging should mirror prod data
- Code reviews should focus on edge cases
- Better to ship with feature flag (canary deployment)

## What Went Well
- Alert fired immediately
- Engineer responded quickly
- Rollback was simple and fast
- Communication was clear
```

### Three Runbooks

**Runbook 1: API Down (SEV1)**

```markdown
# API Down - SEV1

## Verify
- [ ] Check monitoring: Is error rate > 50%?
- [ ] Can you hit the API? `curl https://api.example.com/health`
- [ ] Check deployment status: Did something just deploy?

## Immediate Action (0-2 min)
1. Declare SEV1 incident
2. Notify team (Slack #incident, page on-call)
3. Update status page: "Investigating API issue"
4. Check metrics: CPU, memory, database connections

## Diagnosis (2-5 min)
- [ ] Check logs: `kubectl logs -f deployment/api --all-containers=true | tail -50`
- [ ] Check recent deployments: `kubectl rollout history deployment/api`
- [ ] Check service health: `curl -s http://api:3000/health | jq`
- [ ] Check database: `psql -h db -c "SELECT * FROM pg_stat_activity;" | wc -l`

## Quick Fixes (5-10 min)

**If CPU maxed:**
```bash
kubectl scale deployment/api --replicas=5  # Scale up
# Wait 60s, check if recovered
```

**If memory maxed:**
```bash
kubectl rollout restart deployment/api  # Restart service
# This forces garbage collection
```

**If recent deploy broke it:**
```bash
kubectl rollout undo deployment/api  # Rollback to previous version
# Monitor for 5 minutes
```

**If database down:**
```bash
# Try to connect to backup database
psql -h db-backup -d production
# If working, switch DNS to backup
```

## If Not Resolved (10+ min)
- [ ] Start focused investigation
- [ ] Keep team updated every 5 minutes
- [ ] Prepare customer communications
```

**Runbook 2: Database Performance Degradation (SEV2)**

```markdown
# Database Slow - SEV2

## Verify
- [ ] Check query latency: p99 > 100ms? (threshold for SEV2)
- [ ] Is CPU high? >80%
- [ ] Are connections maxed? (`SELECT count(*) FROM pg_stat_activity`)

## Immediate Action (0-2 min)
1. Notify team (not all hands like SEV1, but alert)
2. Check what changed: deployments, traffic spike?
3. Update internal Slack: "Database slow, investigating"

## Diagnosis (2-10 min)

**Top slow queries:**
```sql
SELECT 
  query, 
  calls, 
  mean_time, 
  stddev_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

**Connection count:**
```sql
SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;
```

**Lock wait:**
```sql
SELECT * FROM pg_locks 
WHERE granted = false;  -- Queries waiting for locks
```

## Quick Fixes

**If high connection count:**
```bash
# Restart application pool to close idle connections
kubectl rollout restart deployment/api
# If issue is connection leak
```

**If slow query found:**
```sql
-- Add index if missing
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- Or rewrite query to use existing index
-- Get execution plan:
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';
```

**If lock conflict:**
```sql
-- See what's locked
SELECT pid, usename, application_name, query 
FROM pg_stat_activity 
WHERE query ~ 'ALTER TABLE';  -- Likely culprit

-- Kill if necessary:
SELECT pg_terminate_backend(pid);
```

## If Not Resolved (10+ min)
- [ ] May need to rewrite query or add index
- [ ] May need to scale database vertically (more CPU/RAM)
- [ ] Check: Is this a baseline shift or temporary spike?
```

**Runbook 3: High Error Rate on Specific Feature (SEV3)**

```markdown
# Feature Broken - SEV3

## Verify
- [ ] Error rate >1% but <50% (SEV3 threshold)
- [ ] Which endpoint? `GET /v1/users/{id}` etc.
- [ ] What's the error? (parse error, timeout, etc.)

## Diagnosis (5-15 min)

**Check logs for this endpoint:**
```bash
kubectl logs -f deployment/api | grep "GET /v1/users" | tail -20
```

**Error types:**
```
- 400: Client error (bad request)
- 404: Not found (endpoint missing?)
- 500: Server error (exception)
- 503: Service unavailable (downstream service down)
- 504: Timeout (slow response)
```

**Get stack trace:**
```bash
# Find error in logs
kubectl logs deployment/api | grep -A 20 "Error:"
```

## Determine Severity
- Is workaround available? (e.g., use different endpoint) → SEV3
- Are many users blocked? → SEV2
- Is alternative service working? → SEV3

## Quick Fixes

**If recent deployment:**
```bash
kubectl rollout undo deployment/api
```

**If missing dependency:**
```bash
# Check if downstream service is up
curl http://inventory-service:3000/health

# If down:
kubectl get pods | grep inventory
kubectl describe pod inventory-xxx
```

**If code issue:**
- Add logging to narrow down
- Deploy hotfix with `--force` for urgent issues

## Resolution
- Fix code
- Deploy
- Monitor for 30 minutes
- No post-mortem needed for SEV3 (just log issue)
```

---

## Monitoring & Alerting

**Location:** `operations/MONITORING.md`

### Monitoring Pyramid

```
        Dashboards & Reports
       (strategic understanding)
              ↑
           Alerts
        (wake engineers)
             ↑
          Metrics
      (quantifiable data)
             ↑
        Structured Logs
    (complete information)
             ↑
         Events
    (what happened)
```

### Health Check Standard

Every service exposes:

```
GET /health (liveness)
GET /ready (readiness)
GET /startup (startup complete)
GET /health/deep (comprehensive check)
```

Kubernetes probes:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2

startupProbe:
  httpGet:
    path: /startup
    port: 3000
  failureThreshold: 30
  periodSeconds: 1
```

### Four Golden Signals

Monitor per service:

1. **Latency (p50, p95, p99)**
   ```
   histogram_quantile(0.50, http_request_duration_seconds{service="order-api"}) 
   histogram_quantile(0.95, http_request_duration_seconds{service="order-api"}) 
   histogram_quantile(0.99, http_request_duration_seconds{service="order-api"})
   ```

2. **Traffic (RPS)**
   ```
   rate(http_requests_total{service="order-api"}[5m])
   ```

3. **Errors (rate and types)**
   ```
   rate(http_requests_total{service="order-api",status=~"5.."}[5m])  # 5xx errors
   rate(http_requests_total{service="order-api",status=~"4.."}[5m])  # 4xx errors
   ```

4. **Saturation (resource utilization)**
   ```
   container_cpu_usage_seconds_total{service="order-api"}
   container_memory_usage_bytes{service="order-api"}
   pg_stat_database_connections{database="orders"}
   ```

### SLOs/SLIs/Error Budgets

**SLO (Service Level Objective):** What you commit to
```
"99.9% of requests succeed within 500ms"
= 0.9999 * 86400 seconds per day = 86,399 seconds up per day
= ~13 seconds of allowed downtime per day
```

**SLI (Service Level Indicator):** How you measure it
```
SLI = (successful requests < 500ms) / (total requests)

If SLI = 99.95%, you're exceeding SLO (99.9%)
If SLI = 99.85%, you're below SLO (99.9%)
```

**Error Budget:** How much you can break things
```
SLO: 99.9% (allows 0.1% errors)
Error budget = 0.1% = 43 seconds/day

If you had 5 incidents totaling 20 seconds downtime:
- Remaining budget = 43 - 20 = 23 seconds
- Can afford 23 more seconds this month before missing SLO
```

Incident priorities:
```
If error budget > 30% remaining:
  → Feature development prioritized

If error budget 15-30% remaining:
  → Balance features + stability

If error budget < 15% remaining:
  → Only reliability work until recovered
```

### Alert Classification

| P1 (Page on-call immediately) | P2 (Alert next morning) | P3 (Log only) |
|---|---|---|
| Error rate > 1% | Error rate 0.5-1% | Error rate 0.1-0.5% |
| p99 latency > 1s | p99 latency 500-1000ms | p99 latency 100-500ms |
| Service completely down | Service degraded | Feature slow |
| Data corruption | Data inconsistency | Data gap |

### Dashboard Design

**Service Health Dashboard (view every morning):**
```
┌─────────────────────────────────────────┐
│ Production Status - April 18, 2026       │
├─────────────────────────────────────────┤

API Service
  Status: ✓ Healthy
  Requests: 5,200 RPS ↑
  p50 latency: 42ms ✓
  p99 latency: 180ms ✓
  Error rate: 0.02% ✓
  CPU: 35% | Mem: 62%
  
Inventory Service
  Status: ✓ Healthy
  Requests: 800 RPS
  p50 latency: 28ms ✓
  p99 latency: 95ms ✓
  Error rate: 0.01% ✓
  CPU: 18% | Mem: 48%

Database
  Status: ✓ Healthy
  Query p99: 12ms ✓
  Connections: 85/100
  Replication lag: 50ms ✓
  Last backup: 4 hours ago ✓

Recent Alerts:
  (none in last 24h)

Error Budget:
  April: 99.92% uptime (87.5% of budget remaining)
```

### On-Call Rotation

Structure:
```
Primary on-call: Handles first page
Secondary: Escalation if primary unavailable
Tertiary: Backup for high-severity issues

Duration: 1 week per rotation
Handoff: Every Monday 9am

Slack notifications:
- Page-worthy alerts → @on-call-primary in #incidents
- Non-page alerts → #alerts channel
```

### Escalation Policy

```
t=0:        Alert fires
t=1min:     Attempt to contact on-call primary
t=3min:     Page secondary if primary unavailable
t=5min:     Escalate to team lead
t=10min:    Escalate to director
t=15min:    Page all engineers (SEV1 only)
```

---

## API Documentation

**Command:** `/api-docs`

### Endpoint Discovery

Automatically discovers all API endpoints:

```bash
$ /api-docs

Discovered 23 endpoints:

  POST   /v1/orders           [2 params]
  GET    /v1/orders           [1 param]
  GET    /v1/orders/{id}      [0 params]
  PUT    /v1/orders/{id}      [5 params]
  DELETE /v1/orders/{id}      [0 params]

  POST   /v1/inventory/reserve
  GET    /v1/inventory/{sku}
  
  POST   /v1/users
  GET    /v1/users/{id}
  ...
```

### OpenAPI Generation

Generates OpenAPI 3.1 spec:

```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "Order API",
    "version": "1.2.3"
  },
  "paths": {
    "/v1/orders": {
      "post": {
        "summary": "Create order",
        "parameters": [...],
        "requestBody": {...},
        "responses": {
          "201": {...},
          "400": {...}
        }
      }
    }
  }
}
```

### Sync Status

Verifies documentation matches actual code:

```
Checking sync between code and OpenAPI...

✓ All endpoints documented
✓ All parameters match code
✓ All response types match
✓ No undocumented endpoints

Status: SYNCHRONIZED
Last sync: 2 hours ago
```

---

## Accessibility Audit

**Command:** `/a11y-audit`

### WCAG 2.1 AA Checklist

- [ ] **Perceivable**: Information presented multiple ways (not just color)
- [ ] **Operable**: All functionality available via keyboard
- [ ] **Understandable**: Language clear, instructions provided
- [ ] **Robust**: Compatible with assistive technologies

### Color Contrast

```
Text color: #333 (dark gray)
Background: #FFF (white)
Contrast ratio: 12.6:1

WCAG AA requirement: 4.5:1 ✓
WCAG AAA requirement: 7:1 ✓
```

Checker: Use WebAIM contrast checker

### Keyboard Navigation

All functionality available without mouse:
- [ ] All buttons reachable via Tab
- [ ] Focus visible (not hidden)
- [ ] No keyboard traps
- [ ] Forms submittable via Enter

### ARIA Labels

```html
<!-- ✗ Bad: Image without alt -->
<img src="logo.png">

<!-- ✓ Good: Image with alt -->
<img src="logo.png" alt="Company logo">

<!-- ✗ Bad: Icon button without label -->
<button class="close">×</button>

<!-- ✓ Good: Icon button with aria-label -->
<button aria-label="Close dialog">×</button>

<!-- ✗ Bad: Form without label -->
<input type="email">

<!-- ✓ Good: Form with associated label -->
<label for="email">Email</label>
<input id="email" type="email">
```

---

## Production Launch Checklist

**Complete before deploying to production:**

### Code Safety
- [ ] All tests passing (unit, integration, contract)
- [ ] Code review approved by 2+ engineers
- [ ] Performance profiler passed (/perf-check)
- [ ] No console errors or warnings
- [ ] Secrets not hardcoded (use config/env vars)

### Database
- [ ] Database Guardian approved migration (/migrate-check)
- [ ] Backup taken and tested
- [ ] Rollback plan documented
- [ ] Data validation queries run
- [ ] Migration tested in staging

### Dependencies
- [ ] Dependency audit passed (/dependency-audit)
- [ ] No critical CVEs
- [ ] No GPL/incompatible licenses
- [ ] All dependencies up to date

### Observability
- [ ] Structured logging implemented
- [ ] Metrics instrumented
- [ ] Distributed tracing configured
- [ ] Health checks implemented
- [ ] Dashboards created

### Monitoring & Alerts
- [ ] Performance budgets defined
- [ ] Alerts configured (p99, error rate, etc.)
- [ ] On-call engineer assigned
- [ ] Runbook created
- [ ] Escalation policy documented

### Documentation
- [ ] API endpoints documented (/api-docs)
- [ ] Runbook created (for SEV1 issues)
- [ ] Architectural decisions documented
- [ ] Deployment steps documented
- [ ] Rollback procedure tested

### Accessibility
- [ ] Accessibility audit passed (/a11y-audit)
- [ ] WCAG 2.1 AA compliance verified
- [ ] Color contrast verified
- [ ] Keyboard navigation works
- [ ] ARIA labels present

### Deployment
- [ ] Deployment tested in staging
- [ ] Feature flag ready (for gradual rollout)
- [ ] Deployment procedure documented
- [ ] Monitoring dashboards open
- [ ] Customer communication prepared
- [ ] Deployment scheduled during low traffic
- [ ] Rollback procedure tested

### Post-Deployment
- [ ] Monitor for 1 hour (critical)
- [ ] Monitor for 24 hours (important features)
- [ ] Collect performance metrics
- [ ] Verify business metrics (revenue, etc.)
- [ ] Gather customer feedback
- [ ] Document any issues

---

## Example Scenario: Code to Production

**Feature:** Add gift card balance to order page

### Step 1: Development

```bash
git checkout -b feature/gift-card-balance
# Code the feature...
npm test  # Tests pass ✓
npm run build  # Build succeeds ✓
```

### Step 2: Performance Profile

```bash
/perf-check feature/gift-card-balance

Results:
- Database query: SELECT * FROM gift_cards WHERE order_id = ?
  Without index: 45ms ✗ (exceeds p50 budget of 100ms)
  With index: 8ms ✓
  
Action: Add index to gift_cards(order_id)

- Frontend bundle: +2 KB (still 148 KB total) ✓
- API response time: +5ms (still 52ms p50) ✓
```

### Step 3: Database Migration

```sql
-- Migration: add_gift_card_index.sql
CREATE INDEX CONCURRENTLY idx_gift_cards_order_id 
  ON gift_cards(order_id);
```

```bash
/migrate-check add_gift_card_index.sql

Risk classification: MEDIUM
- No lock (CONCURRENTLY)
- Estimated duration: 2 minutes
- Safe to deploy
Recommendation: Deploy during high traffic (less impact)
```

### Step 4: Dependency Check

```bash
/dependency-audit

No new dependencies added ✓
```

### Step 5: Accessibility

```bash
/a11y-audit

- Gift card balance displayed with currency symbol ✓
- No color-only indication (also shows text) ✓
- All interactive elements keyboard accessible ✓
- WCAG 2.1 AA compliant ✓
```

### Step 6: Staging Deployment

```bash
# Merge to staging branch
git push origin feature/gift-card-balance:staging

# Deploy to staging
kubectl set image deployment/api api=registry/api:staging
kubectl rollout status deployment/api

# Run integration tests
npm run test:integration

# Smoke test manually
curl https://staging-api.example.com/v1/orders/123
# Verify gift_card_balance in response ✓
```

### Step 7: Incident Response Prep

Create runbook: `operations/runbooks/gift-card-balance-failure.md`

```markdown
# Gift Card Balance Feature - Runbook

## If gift card balance not showing:

1. Check database:
   SELECT * FROM gift_cards LIMIT 10;
   
2. Check API response:
   curl https://api.example.com/v1/orders/123 | jq .gift_card_balance
   
3. Check logs for errors:
   kubectl logs deployment/api | grep -i gift

## Quick fixes:
- If index missing: CREATE INDEX idx_gift_cards_order_id ON gift_cards(order_id);
- If service down: kubectl rollout restart deployment/api
- If database slow: Check connections: SELECT count(*) FROM pg_stat_activity;
```

### Step 8: API Documentation

```bash
/api-docs

Discovered new endpoint:
GET /v1/orders/{id}

Updated response schema:
{
  "id": "order-123",
  ...
  "gift_card_balance": 25.50  ← New field
}

OpenAPI generated ✓
```

### Step 9: Production Deployment

Pre-deployment checklist:
- [ ] Code review approved ✓
- [ ] Perf check passed ✓
- [ ] Database migration safe ✓
- [ ] Dependency check passed ✓
- [ ] A11y audit passed ✓
- [ ] Staging tested ✓
- [ ] Runbook created ✓
- [ ] Alerts configured ✓
- [ ] Dashboards ready ✓

**Deploy:**
```bash
# Create feature flag (in case we need to disable)
redis-cli SET feature:gift-card-balance enabled true

# Deploy migration (index)
kubectl apply -f migrations/add_gift_card_index.sql

# Wait 5 minutes (index creation)
watch kubectl get pods

# Deploy code
kubectl set image deployment/api api=registry/api:v2.3.0
kubectl rollout status deployment/api --timeout=10m

# Verify
curl https://api.example.com/health  # ✓ Health check
curl https://api.example.com/v1/orders/123 | jq .gift_card_balance  # ✓ Has value
```

### Step 10: Post-Deployment Monitoring

**Hour 1 (Critical):**
```
Metrics:
- Error rate: 0.02% ✓
- p99 latency: 185ms ✓
- GET /orders latency: +3ms (acceptable)
- Database query p99: 14ms ✓

Status: ✓ All green
```

**Hour 2-24 (Monitor):**
```
Check every 4 hours:
- Error rate stable ✓
- No latency regression ✓
- Customer feedback: No issues reported ✓

Business metrics:
- Orders completed: Normal ✓
- Revenue: Normal ✓
- Refunds: Normal ✓
```

### Step 11: Wrap-Up

After 24 hours of stability:

```markdown
# Deployment Summary

Feature: Gift Card Balance on Order Page
Deployed: 2026-04-18 14:00 UTC
Duration: 5 minutes (database index) + 2 minutes (code)
Rollback: Not needed
Status: ✓ Success

Metrics:
- Zero errors
- No latency impact
- Index creation: 1.8 minutes (within estimate)
- Database query speedup: 45ms → 8ms

Next: Feature flag can be removed in next deployment
      (currently checking feature:gift-card-balance, but always true)

Lessons:
- Adding index CONCURRENTLY worked perfectly
- Need to verify staging has gift cards data in future
```

---

## Summary

Production safety is a system, not individual checks. These five gates work together:

1. **Database Guardian** → Migrations don't break schema
2. **Performance Profiler** → Features meet latency budgets
3. **Dependency Audit** → No security holes
4. **Incident Response** → If something breaks, you can fix it fast
5. **Monitoring & Alerts** → You know when problems happen

Every feature going to production passes all five gates. This prevents 90%+ of production incidents.

The production launch checklist ensures nothing is forgotten. Use it religiously.
