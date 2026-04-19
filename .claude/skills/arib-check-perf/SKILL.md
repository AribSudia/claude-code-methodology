---
argument-hint: "<scope>"
description: Check | Performance audit - N+1 queries, bundle size, latency budgets, memory leaks, caching gaps
---

# /arib-check-perf Command

## Purpose
Perform a comprehensive performance audit of the codebase to detect N+1 queries, oversized bundles, missing pagination, memory leaks, caching gaps, and performance budget violations.

## Trigger
User types `/arib-check-perf [scope]`

Examples:
- `/arib-check-perf` - Full system performance audit
- `/arib-check-perf api` - Backend API endpoints only
- `/arib-check-perf frontend` - Frontend bundle and Web Vitals only
- `/arib-check-perf /api/orders` - Specific endpoint
- `/arib-check-perf database` - Database query analysis only

## Overview
Performance degradation compounds: one N+1 query multiplied by pagination can turn seconds into minutes. This audit detects the most common and impactful bottlenecks before users experience them. Each finding includes severity, impact (latency, bundle size, memory), and exact file location for remediation.

## When to Use
- **Before major releases** - baseline performance and verify improvements
- **When users report slowness** - pinpoint which system (API, DB, frontend) is the bottleneck
- **After adding features** - ensure bundle size and query patterns haven't degraded
- **During optimization sprints** - identify highest-ROI fixes
- **For new developers** - teach performance patterns and constraints used in this project

## Instructions

### Step 1: Activate Performance Profiler Agent
Read `.claude/agents/performance.md` and follow the 7-step protocol.

### Step 2: Backend Scan - N+1 Query Detection

#### ORM Pattern Examples (All are N+1 anti-patterns)

**Sequelize (Node.js):**
```javascript
// ANTI-PATTERN: N+1 query
const users = await User.findAll(); // 1 query: SELECT * FROM users
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } }); // N more queries
}

// FIXED: Eager loading
const users = await User.findAll({
  include: [{ association: 'posts', attributes: ['id', 'title'] }]
});
```

**Prisma (Node.js):**
```javascript
// ANTI-PATTERN: N+1
const users = await prisma.user.findMany();
const userPosts = await Promise.all(
  users.map(u => prisma.post.findMany({ where: { userId: u.id } }))
);

// FIXED: Eager loading
const users = await prisma.user.findMany({
  include: { posts: true }
});
```

**TypeORM (Node.js/Python):**
```javascript
// ANTI-PATTERN
const users = await User.find(); // 1 query
users.forEach(u => u.posts); // Access triggers N more queries (lazy loading)

// FIXED: Eager loading
const users = await User.find({ relations: ['posts'] });
```

**Django (Python):**
```python
# ANTI-PATTERN: N+1
users = User.objects.all() # 1 query
for user in users:
    print(user.posts.all()) # N more queries

# FIXED: select_related / prefetch_related
users = User.objects.prefetch_related('posts')
```

#### Detection Strategy
- Scan all endpoints for loops containing async DB calls
- Check for ORM queries inside loops (especially in controllers/handlers)
- Verify all relationships use eager loading (include, relations, select_related)
- Look for `.all()` or `.find()` followed by attribute access in loops

#### Actions
- Document each N+1 with: file, line, estimated impact (queries per request)
- Severity: CRITICAL if affects high-traffic endpoints
- Fix: Add eager loading using framework's built-in syntax

### Step 3: Backend Scan - API Response Budgets

#### Bundle Size Budgets by App Type

| App Type | API Response Limit | Reasoning |
|----------|-------------------|-----------|
| **Mobile API** | 50-100 KB | Over cellular networks, 3G common |
| **Public API** | 100-200 KB | Unknown network, clients pay per byte |
| **Internal Dashboard** | 500 KB | Trusted network, single product |
| **Admin Tools** | 1 MB | Low volume, premium features |
| **File Download** | 10+ MB | Expected, user initiated |

#### Detection
- Inspect largest API endpoints: `/graphql`, `/users`, `/reports`, `/search`
- Count objects and payload size: `JSON.stringify(response).length`
- Check for unnecessary fields: include only what frontend displays
- Identify list endpoints returning > 1000 items without pagination

#### Actions
- Enforce pagination: 25-50 items default, max 100
- Field selection: use GraphQL fragments or API filtering params
- Compress responses: gzip usually already enabled
- Consider streaming for large datasets

### Step 4: Frontend Scan - Bundle Analysis

#### Code Splitting Decision Tree

```
Is this a route or major feature?
├─ YES → Lazy load (React.lazy, dynamic imports)
│        Route: lazy(() => import('./pages/Dashboard'))
│        Component: const Modal = lazy(() => import('./Modal'))
│
└─ NO → Keep in main bundle if:
         • Always used on page load
         • Small (< 50 KB minified)
         • Critical for initial render
```

#### Common Bloat Patterns

| Pattern | Detection | Fix |
|---------|-----------|-----|
| **Full lodash import** | `import _ from 'lodash'` | Use tree-shaking: `import { debounce } from 'lodash-es'` |
| **Moment.js** | Any `import moment` | Replace with `date-fns` or `dayjs` (5-20x smaller) |
| **Unused CSS frameworks** | Bootstrap 5 = 200+ KB | Use utility-first (Tailwind) or import only used components |
| **Multiple charting libs** | Chart.js + Recharts | Pick one, tree-shake unused features |
| **Polyfills** | Babel includes 200+ KB | Target modern browsers, conditional polyfills |

#### Actions
- Run `npm run build --analyze` or use webpack-bundle-analyzer
- List top 10 dependencies by size (target > 50 KB minified)
- Check if each can be replaced with lighter alternative
- Verify all routes are code-split (should see 10+ chunks, not 1)

### Step 5: Frontend Scan - Image Optimization

#### Image Red Flags
- SVG files > 50 KB (should be optimized)
- PNG without compression (should be WebP with PNG fallback)
- Images without explicit width/height (causes layout shift)
- High-res images (4K) served on mobile

#### Image Budget by Device

| Type | Mobile | Desktop | Format |
|------|--------|---------|--------|
| Hero image | < 200 KB | < 500 KB | WebP + JPEG fallback |
| Thumbnail | < 50 KB | < 100 KB | WebP or optimized JPEG |
| Icon | < 5 KB | < 10 KB | SVG (optimized) or PNG |
| Background | < 300 KB | < 1 MB | WebP or JPEG |

#### Core Web Vitals Checklist
- **LCP (Largest Contentful Paint)** < 2.5s - Check image load priority
- **FID (First Input Delay)** < 100ms - Check for blocking JS on main thread
- **CLS (Cumulative Layout Shift)** < 0.1 - Check for missing image dimensions

### Step 6: Database Scan - Index Coverage

#### Index Decision Tree

```
Is this column in a WHERE clause?
├─ YES → Add index (single or composite)
│
Is this a foreign key?
├─ YES → Add index (join performance)
│
Is this in an ORDER BY?
├─ YES → Add index (sort performance)
│
Is this searched frequently?
├─ YES → Consider index (trade write slowdown for read speed)
```

#### Query Analysis
- Collect slowest 10 queries from logs (> 100ms)
- For each: check if EXPLAIN PLAN shows full table scan
- Verify indexes on WHERE, JOIN, ORDER BY columns
- Check composite indexes align with query patterns

#### Connection Pool Configuration
```
Pool size = (concurrent_requests × avg_query_duration_seconds) / 1
Example: (50 req/s × 0.1s) / 1 = min 5, recommend 10-20
Maximum: 100 (diminishing returns, more memory per connection)
```

### Step 7: Memory & Resource Scan

#### Leak Patterns (All are CRITICAL)

| Pattern | Detection | Fix |
|---------|-----------|-----|
| **Event listeners** | `.addEventListener()` without `.removeEventListener()` | Always pair with cleanup in unmount/destroy |
| **setInterval** | `setInterval()` without `clearInterval()` | Store ID: `id = setInterval()`, clear in cleanup |
| **Streams** | `.pipe()` without `close` handler | Add: `stream.on('end', () => stream.destroy())` |
| **Subscriptions** | RxJS `subscribe()` without `unsubscribe()` | Use `takeUntil()` or unsubscribe in cleanup |
| **Collections** | `array.push()` in loop without bounds | Add: `if (array.length > MAX) array.shift()` |
| **Timers** | `setTimeout()` in loop | Batch with clearTimeout or use debounce |

#### Memory Budgets
- **Node.js process** - Alert if > 500 MB (prod should be < 300 MB)
- **Browser tab** - Alert if > 200 MB (likely leak or bad data structure)
- **Single array** - Alert if > 50 MB (likely shouldn't be in memory)

### Step 8: Caching Assessment - Decision Tree

```
Is this endpoint read-heavy (mostly GET)?
└─ YES
   ├─ Does data change frequently (< 1 hour)?
   │  ├─ NO → Cache aggressive: TTL 24h
   │  └─ YES → Cache moderate: TTL 5-60 min
   ├─ Is this user-specific data (auth tokens, preferences)?
   │  └─ YES → Cache per-user (private cache)
   └─ Is this global data (products, settings)?
      └─ YES → Cache globally (shared cache)

Is this write-heavy?
└─ YES → Cache on write, not read
   ├─ Cache invalidation: delete on POST/PUT/DELETE
   └─ Cache warming: precompute expensive calculations
```

#### Caching Strategy Template

```
Endpoint: GET /api/products
Data freshness: Products rarely change (1-2x per day)
Request volume: 10,000 req/min
Cache type: Redis (distributed) or in-memory (single server)

Cache strategy:
- TTL: 1 hour (3600 seconds)
- Invalidation: Delete cache on product update/delete
- Warming: Load on server start or first request
- Fallback: If Redis down, compute fresh or return stale

Expected impact:
- Requests per minute to DB: 10,000 → 50 (if 1% hit rate)
- Latency: 50ms → 5ms (10x improvement)
- DB load: 600 queries/min → 3 queries/min (200x reduction)
```

### Step 9: Generate Performance Report
Produce the Performance Audit Report with:
- Executive summary: overall score (0-100), trending direction
- Performance metrics by area with budgets and current values
- N+1 queries: list with endpoints, estimated extra queries per request
- Bundle analysis: top 10 dependencies, opportunities for reduction
- Memory issues: list of leaks with severity
- Caching gaps: high-ROI endpoints not cached
- Optimization plan with estimated effort (1-5 points) and impact
- Priority: fix CRITICAL items first, then high-ROI quick wins

## Performance Budget Template

```yaml
performance_budget:
  api:
    p95_latency_ms: 200
    p99_latency_ms: 500
    max_response_kb: 100
  
  frontend:
    bundle_size_kb: 300
    core_web_vitals:
      lcp_ms: 2500
      fid_ms: 100
      cls: 0.1
  
  database:
    p95_query_ms: 100
    connections: 20
    slow_query_threshold_ms: 500
  
  memory:
    node_process_mb: 300
    browser_tab_mb: 200
```

## Common Mistakes

1. **Comparing dev vs prod** - Dev has small datasets. Always profile with production-scale data (1M+ records).
2. **Ignoring network latency** - 50ms API call can be 100ms over mobile 3G. Measure end-to-end.
3. **Caching without invalidation** - Stale cache is worse than no cache. Always implement invalidation.
4. **Micro-optimizations first** - Fix N+1 queries before optimizing JSON parsing (10x vs 10% gains).
5. **No before/after measurement** - Estimate impact, implement fix, measure actual impact (often different).

## Edge Cases

- **Pagination cursor vs offset** - Cursor (keyset) handles inserts/deletes better than offset
- **Caching with user data** - Use cache key = `[endpoint]_[user_id]` or mark private
- **Background jobs** - Exclude from budget, but monitor if they compete with foreground queries
- **Streaming responses** - Exempt from bundle budget, monitor memory usage instead

## Related Skills
- `/arib-check-services` - Infrastructure latency
- `/arib-check-reality` - Verify data is real (not mock) before profiling
- `/arib-dev-debug` - Investigate specific slowness hypothesis

## Notes
- This command activates the Performance Profiler agent
- Performance budgets are guidelines - adjust per project needs
- N+1 queries are the most common and impactful finding
- Always check real data volumes, not just dev dataset size
- Bundle analysis requires a built project (run build first)
