# Analysis Request Template

## Meta
- **ID**: `ANALYZE-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `analyze`
- **Priority**: `high` | `medium` | `low`
- **Status**: `pending`
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to originating request)

---

## Scope

### What to Analyze
- **System/Component**: (what system or code is being analyzed?)
- **Focus Area**: (performance, data flow, dependencies, etc.)
- **Time Period**: (current state, last 24h, last week, etc.)
- **Metrics of Interest**: (specific things to measure)

### Context
- **Baseline**: (previous metrics, if available)
- **Trigger**: (why is this analysis needed now?)
- **Constraints**: (what can't we do?)
- **Out of Scope**: (explicitly exclude)

---

## Analysis Dimensions

### Performance Metrics
- [ ] Response time (API calls, function execution)
- [ ] Throughput (requests/sec, operations/sec)
- [ ] Latency percentiles (p50, p95, p99)
- [ ] Memory usage (peak, average, trends)
- [ ] CPU usage
- [ ] Garbage collection stats (if relevant)

### Database Metrics
- [ ] Query execution time
- [ ] Query frequency (top slow queries)
- [ ] Connection pool utilization
- [ ] Index efficiency
- [ ] Data volume (table sizes, growth rate)
- [ ] Locking/deadlock events

### API Metrics
- [ ] Response times by endpoint
- [ ] Error rates (4xx, 5xx)
- [ ] Timeout frequency
- [ ] Rate limiting impact
- [ ] Request payload sizes
- [ ] Cache hit rates

### Resource Usage
- [ ] Memory consumption
- [ ] Disk I/O
- [ ] Network bandwidth
- [ ] CPU utilization
- [ ] Thread count
- [ ] File descriptor count

### Bundling/Build Metrics
- [ ] Bundle size (total, by chunk)
- [ ] Gzip size
- [ ] Code coverage
- [ ] Build time
- [ ] Dependency tree size
- [ ] Module count

---

## Expected Output

### Metrics Summary Table
| Metric | Current | Previous | Threshold | Status |
|--------|---------|----------|-----------|--------|
| Response Time (ms) | | | | |
| Error Rate (%) | | | | |
| Memory (MB) | | | | |
| | | | | |

### Findings

#### Bottlenecks Identified 🔴
1. **Issue**: (specific bottleneck)
   - **Impact**: (performance impact)
   - **Location**: (file, function, system)
   - **Severity**: Critical | High | Medium

2. 

#### Performance Issues 🟠
1. **Issue**: (degradation or concern)
   - **Metric**: (what's affected)
   - **Current vs Expected**: 
   - **Severity**: High | Medium | Low

2. 

#### Optimization Opportunities 🟡
1. **Opportunity**: (potential improvement)
   - **Estimated Impact**: (performance gain)
   - **Effort**: (implementation difficulty)
   - **Recommendation**: (specific action)

2. 

---

## Recommendations (Prioritized)

### Immediate Action (Critical)
1. (High-impact, urgent fixes)

### Short-term (1-2 weeks)
1. (Important improvements)

### Medium-term (1 month)
1. (Strategic optimizations)

### Long-term (Architectural)
1. (Fundamental improvements)

---

## Analysis Details

### Data Sources
- **Method**: (profiling, monitoring, synthetic tests, logs)
- **Tools Used**: (profiler, APM, custom script, etc.)
- **Duration**: (how long analysis ran)
- **Sample Size**: (requests/transactions analyzed)

### Methodology
- (Describe how analysis was conducted)
- (Any assumptions made?)
- (Limitations of analysis?)

### Evidence
- Graphs/charts (if visual comparison)
- Raw metrics/logs (if detailed)
- Stack traces (if performance issues found)
- Query plans (if database issues)

---

## Sign-off

- **Analyzed by**: (agent performing analysis)
- **Date Analyzed**: `YYYY-MM-DD HH:mm UTC`
- **Confidence Level**: High | Medium | Low
- **Next Steps**: (what's needed to act on findings?)

---

## Blockers
- (Any data unavailable?)
- (Systems unreachable?)
- (Permissions needed?)
