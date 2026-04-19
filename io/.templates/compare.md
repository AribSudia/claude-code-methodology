# Comparison Request Template

## Meta
- **ID**: `COMPARE-YYYY-MM-DD-HHmm`
- **Date Created**: `YYYY-MM-DD HH:mm UTC`
- **Type**: `compare`
- **Priority**: `high` | `medium` | `low`
- **Status**: `pending`
- **Assigned to**: (agent ID or role)
- **Related Request**: (link to originating request)

---

## What to Compare

### Version A Definition
- **Name/Label**: (descriptive name)
- **Location**: (file path, branch, commit hash, or URL)
- **Description**: (what this version does)
- **Context**: (when/why this version exists)

### Version B Definition
- **Name/Label**: (descriptive name)
- **Location**: (file path, branch, commit hash, or URL)
- **Description**: (what this version does)
- **Context**: (when/why this version exists)

### Comparison Context
- **Purpose**: (why compare these versions?)
- **Decision**: (what choice will this comparison inform?)
- **Constraints**: (criteria that matter most?)

---

## Comparison Dimensions

### Functionality
- [ ] Feature set completeness
- [ ] User workflows supported
- [ ] Edge case handling
- [ ] Error scenarios
- [ ] Integration points

### Performance
- [ ] Execution speed
- [ ] Memory usage
- [ ] CPU utilization
- [ ] Scalability characteristics
- [ ] Resource consumption

### Code Quality
- [ ] Maintainability (complexity, readability)
- [ ] Test coverage
- [ ] Documentation completeness
- [ ] Code duplication
- [ ] Technical debt indicators

### Security
- [ ] Vulnerability exposure
- [ ] Authentication/authorization approach
- [ ] Data protection mechanisms
- [ ] Known security issues
- [ ] Dependency safety

### Maintainability
- [ ] Codebase size
- [ ] Dependency count
- [ ] Architecture clarity
- [ ] Team skill requirements
- [ ] Future enhancement ease

### Operational
- [ ] Deployment complexity
- [ ] Configuration requirements
- [ ] Monitoring capability
- [ ] Debugging difficulty
- [ ] Rollback complexity

---

## Expected Output

### Side-by-Side Comparison Table

| Dimension | Version A | Version B | Winner | Notes |
|-----------|-----------|-----------|--------|-------|
| **Functionality** | | | | |
| Feature completeness | | | | |
| Handles edge cases | | | | |
| | | | | |
| **Performance** | | | | |
| Execution speed | | | | |
| Memory usage | | | | |
| | | | | |
| **Code Quality** | | | | |
| Maintainability | | | | |
| Test coverage | | | | |
| | | | | |
| **Security** | | | | |
| Known vulnerabilities | | | | |
| Dependency safety | | | | |
| | | | | |
| **Maintainability** | | | | |
| Codebase complexity | | | | |
| Learning curve | | | | |
| | | | | |

### Detailed Analysis

#### Functionality Comparison
- **Version A**: (capabilities and limitations)
- **Version B**: (capabilities and limitations)
- **Verdict**: (which is more feature-complete?)

#### Performance Comparison
- **Version A**: (performance characteristics with metrics)
- **Version B**: (performance characteristics with metrics)
- **Verdict**: (which is faster/more efficient?)

#### Quality Comparison
- **Version A**: (code quality metrics, maintainability)
- **Version B**: (code quality metrics, maintainability)
- **Verdict**: (which is cleaner/easier to maintain?)

#### Security Comparison
- **Version A**: (security posture, known issues)
- **Version B**: (security posture, known issues)
- **Verdict**: (which is more secure?)

---

## Recommendation

### Decision
**Recommend**: Version A | Version B | Neither | Hybrid approach

### Reasoning
(Explain the recommendation based on the comparison)

### Scoring Summary
| Criterion | Weight | A Score | B Score | Result |
|-----------|--------|---------|---------|--------|
| Functionality | 30% | | | |
| Performance | 25% | | | |
| Code Quality | 20% | | | |
| Security | 15% | | | |
| Maintainability | 10% | | | |
| **TOTAL** | 100% | | | |

### Caveats & Assumptions
- (What assumptions did we make?)
- (What wasn't tested?)
- (Under what conditions might the recommendation change?)

### Next Steps
1. (Action to take based on recommendation)
2. (Any migration path if switching?)
3. (Timeline for decision/implementation)

---

## Analysis Details

### Comparison Method
- (How were versions evaluated?)
- (Tools used for measurement?)
- (Controlled variables?)

### Test Environment
- (Hardware specs)
- (Software stack)
- (Data volume/scenario)
- (Load profile)

### Evidence
- Performance graphs (if measured)
- Code metrics (if analyzed)
- Test results (if executed)
- Screenshots (if UI/UX comparison)

---

## Sign-off

- **Compared by**: (agent performing comparison)
- **Date Compared**: `YYYY-MM-DD HH:mm UTC`
- **Confidence Level**: High | Medium | Low
- **Review Status**: (approved by human reviewer?)

---

## Blockers & Notes
- (Any difficulties in comparison?)
- (Missing data or access?)
- (Additional context needed for decision?)
