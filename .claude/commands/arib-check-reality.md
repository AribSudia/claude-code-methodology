---
argument-hint: "<scope>"
description: Check | Scan for mock data, fake APIs, hardcoded responses - verify the system is genuinely connected
---

# /arib-check-reality Command

## Purpose
Perform a comprehensive reality audit of the codebase to detect mock data, fake APIs, hardcoded responses, placeholder content, and disconnected frontend-backend wiring. Produces a detailed report and remediation plan.

## Trigger
User types `/arib-check-reality [scope]`

Examples:
- `/arib-check-reality` - Full codebase scan
- `/arib-check-reality frontend` - Frontend code only
- `/arib-check-reality src/components` - Specific directory
- `/arib-check-reality auth` - Auth-related code only
- `/arib-check-reality payment-flow` - Specific feature

## Instructions

### Step 0: Verify Infrastructure (Microservices)
If the project uses microservices:
```bash
bash scripts/services-check.sh
```
- If services are down, warn: "Backend services aren't running. Some 'disconnected' findings may be false positives."
- Recommend starting services first: `bash scripts/services-check.sh --start`

### Step 1: Activate Reality Auditor Agent
Read `.claude/agents/reality-auditor.md` and follow the 10-step protocol.

### Step 2: Mock Library Detection
Scan for mock/fake libraries in production dependencies:
- Check `package.json` for `faker`, `msw`, `miragejs`, `json-server`, `nock`, `casual`, `chance`
- Check if these are in `dependencies` (BAD) or `devDependencies` (check usage)
- Scan source code (excluding test files) for imports of these libraries

### Step 3: Hardcoded Data Scan
Search for hardcoded data in production source code:
- Hardcoded arrays used as component data
- Mock data files (`mockData.ts`, `fakeUsers.js`, `sampleData.json`) imported by production code
- `setTimeout` / `setInterval` simulating API responses
- Hardcoded emails, names, UUIDs in non-test files
- Lorem ipsum or placeholder text in UI components

### Step 4: API Connection Audit
For every component that displays or submits data:
- Trace where the data comes from (API call, hardcoded, or mock)
- Verify API base URL is configured via environment variable
- Check if API calls reach real endpoints or are intercepted by MSW/mocks
- Verify form submissions actually POST/PUT to real endpoints

### Step 5: Auth Reality Check
Verify authentication is real:
- Check for `isAuthenticated = true` hardcoded anywhere
- Check auth guards actually validate tokens
- Check login flow calls real auth endpoint
- Check JWT/session tokens are real, not hardcoded strings

### Step 6: Classify Every Data-Driven Component
For each component/module that handles data, classify:
- 🟢 **REAL** - Connected to backend, real data flows
- 🟡 **PARTIAL** - Some real, some mocked
- **FAKE** - Entirely mock/hardcoded data
- ⚫ **DISCONNECTED** - Has API code but not connected
- ⚪ **STATIC** - Legitimately static content

### Step 7: Calculate Reality Score
```
Reality Score = (REAL components) / (total data-driven components) × 100%
```

### Step 8: Generate Remediation Plan
For each FAKE or PARTIAL finding:
1. Show the exact file and line number
2. Show the current (fake) code
3. Show the proposed (real) code
4. List what backend endpoint is required
5. Note any dependencies (e.g., "fix API client first")

Order remediation phases:
- **Phase A**: Foundation (API client, auth, env vars)
- **Phase B**: Data layer (replace mocks with real API calls)
- **Phase C**: Cleanup (remove mock files, remove fake deps)

### Step 9: Report
Present the complete Reality Audit Report with:
- Executive summary table
- Reality score
- Critical findings with evidence
- Mock library inventory
- Remediation plan with phases
- Verification checklist

### Step 10: Commit Report (if requested)
```bash
git add docs/reality-audit-[date].md
git commit -m "[audit]: reality check - [score]% genuine, [N] findings"
```

## Output Format

```
🔍 Reality Audit Complete

Reality Score: XX% genuine

| Classification | Count |
|----------------|-------|
| 🟢 REAL        | N     |
| 🟡 PARTIAL     | N     |
| FAKE        | N     |
| ⚫ DISCONNECTED | N     |
| ⚪ STATIC      | N     |

Critical Findings: N
Remediation Steps: N
Estimated Fix Time: X hours

[Detailed report follows...]
```

## Notes
- This command activates the Reality Auditor agent
- Mock data in TEST files is legitimate - never flag it as a problem
- Seed data / fixture data is legitimate - distinguish from production mocks
- Static content (about pages, FAQ) is legitimate - don't classify as fake
- Always verify services are running before declaring APIs "disconnected"
- The remediation plan is a PROPOSAL - user must approve before any changes
