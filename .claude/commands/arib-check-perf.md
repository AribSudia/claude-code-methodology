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

## Instructions

### Step 1: Activate Performance Profiler Agent
Read `.claude/agents/performance.md` and follow the 7-step protocol.

### Step 2: Backend Scan
- Detect N+1 query patterns (loops with await + DB call)
- Find endpoints without pagination (returning unbounded arrays)
- Find missing eager loading (ORM queries without include/join)
- Check for missing database indexes on foreign keys and WHERE columns
- Verify API response sizes are within budget

### Step 3: Frontend Scan
- Analyze bundle size (check for full library imports: lodash, moment)
- Find missing code splitting (routes not lazy-loaded)
- Find unoptimized images (> 200KB without compression)
- Check for missing image dimensions (causes layout shift)
- Verify Core Web Vitals compliance

### Step 4: Database Scan
- Identify slow query patterns
- Check index coverage for hot queries
- Find missing pagination in data access layer
- Check connection pool configuration

### Step 5: Memory & Resource Scan
- Find event listeners without cleanup
- Find setInterval/setTimeout without clear
- Find unclosed streams, connections, file handles
- Check for growing collections without bounds

### Step 6: Caching Assessment
- Identify cacheable endpoints (read-heavy, rarely changing)
- Check if caching layer exists (Redis, in-memory)
- Verify cache invalidation strategy
- Check static asset caching headers

### Step 7: Generate Performance Report
Produce the Performance Audit Report with:
- Performance score per area (API, DB, Frontend, Memory, Caching)
- All findings with severity and file locations
- Budget compliance table (current vs budget)
- Optimization plan with estimated effort
- Priority order for fixes

## Notes
- This command activates the Performance Profiler agent
- Performance budgets are guidelines - adjust per project needs
- N+1 queries are the most common and impactful finding
- Always check real data volumes, not just dev dataset size
- Bundle analysis requires a built project (run build first)
