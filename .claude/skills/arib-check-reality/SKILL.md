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

## Overview
Real vs mock is binary: either data flows from actual backend systems or it doesn't. This audit finds every place where the codebase pretends to be connected when it isn't, preventing the experience of walking past a critical disconnect during QA or after deployment. Reality Score (% of data-driven components connected to real backends) is the key metric.

## When to Use
- **End of dev sprint** - Verify features actually connect to backend before merging
- **Before major releases** - Ensure no mock data ships to production
- **New team member orientation** - Show which parts are real, which are stubs
- **Integrating third-party services** - Verify OAuth/API connections are real, not hardcoded
- **Testing environment setup** - Distinguish between test fixtures (OK) and production mocks (BAD)

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

#### Common Mock Patterns by Framework

**Jest (JavaScript/TypeScript testing):**
```javascript
// LEGITIMATE (test file):
jest.mock('./api', () => ({
  fetchUser: jest.fn(() => Promise.resolve({ id: 1, name: 'Alice' }))
}));

// ILLEGITIMATE (production file):
import { fetchUser } from './__mocks__/api'; // Should not exist in src/
```

**Vitest (Vite testing):**
```javascript
// LEGITIMATE (test file):
vi.mock('./data', () => ({
  userData: [{ id: 1, name: 'Test' }]
}));

// ILLEGITIMATE (production):
import { vi } from 'vitest'; // Should never import in non-test code
```

**MSW (Mock Service Worker - legitimate in dev only):**
```javascript
// LEGITIMATE (dev environment):
if (process.env.NODE_ENV === 'development') {
  import('./mocks/handlers').then(({ worker }) => worker.start());
}

// ILLEGITIMATE (production build):
// MSW should be stripped by build tool, if it appears in production bundle = bug
```

**Detection Strategy:**
- Scan `package.json` for: `faker`, `msw`, `miragejs`, `json-server`, `nock`, `casual`, `chance`, `factory.bot`
- If in `dependencies` (not `devDependencies`) = potential red flag
- Search production source (exclude `__tests__/`, `*.test.ts`, `*.spec.ts`) for imports
- Check webpack/Vite config for mock provider plugins

#### Library Risk Matrix

| Library | Legitimate Use | Red Flag |
|---------|---|---|
| `faker` | Test fixtures only | Imported in production code |
| `msw` | Dev/test environments | MSW handler in production bundle |
| `miragejs` | Dev server interceptor | Used in production code |
| `json-server` | Local dev only | Running in production |
| `nock` | Test HTTP mocking | Used outside test files |

### Step 2: Mock Library Detection Details
Scan for mock/fake libraries in production dependencies:
- Check `package.json` for `faker`, `msw`, `miragejs`, `json-server`, `nock`, `casual`, `chance`
- Check if these are in `dependencies` (BAD) or `devDependencies` (check usage)
- Scan source code (excluding test files) for imports of these libraries

### Step 3: Hardcoded Data Scan

#### Hardcoded Data Red Flags

| Red Flag | Pattern | Example | Severity |
|----------|---------|---------|----------|
| **Lorem ipsum** | "Lorem ipsum dolor sit amet" | FAQ, help text, placeholders | MEDIUM (user-facing) |
| **Fake phone** | "555-" prefix or "(XXX) XXX-XXXX" | `const phone = "555-0123"` | CRITICAL (if user-facing) |
| **Fake email** | example.com, test.com, demo.com | `email: "user@example.com"` | CRITICAL (invalid email) |
| **Test UUIDs** | UUID patterns in plain text | `"123e4567-e89b-12d3-a456-426614174000"` | CRITICAL (auth/data) |
| **Hardcoded array** | `const users = [{ id: 1, name: 'Alice' }]` | Component renders static data | CRITICAL (data) |
| **Mock file import** | Import from mockData.ts in non-test | `import { mockUsers } from '../mockData'` | CRITICAL |
| **setTimeout response** | `setTimeout(() => callback(...), 1000)` | Faking API latency | CRITICAL |

#### Detection Patterns

**Hardcoded Arrays (highest risk):**
```javascript
// ANTI-PATTERN: Production component with hardcoded data
export const Dashboard = () => {
  const users = [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' }
  ];
  return <UserList users={users} />;
};

// CORRECT: Fetch from API
export const Dashboard = () => {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);
  return <UserList users={users} />;
};
```

**Mock Data Files:**
```javascript
// BAD: Imported into production code
import { mockUsers } from '../__mocks__/data';
const UserProfile = ({ userId }) => {
  const user = mockUsers.find(u => u.id === userId);
  return <div>{user.name}</div>;
};

// GOOD: Mock files only in tests
// src/__tests__/UserProfile.test.ts:
import { mockUsers } from '../__mocks__/data';
```

**Fake Email Red Flags:**
- `@example.com`, `@example.org`, `@test.com`, `@demo.com`, `@localhost`
- `noreply@`, `support@`, `no-reply@` if actual addresses not configured
- Pattern: `user+test@`, `test@`, `admin@` hardcoded in seed data

**Fake Phone Red Flags:**
- `555-0000` to `555-9999` (reserved test range)
- `(XXX) XXX-XXXX` if not actual validation
- `+1-800-` if not real support line

**Lorem Ipsum Variants:**
- "Lorem ipsum dolor sit amet"
- "The quick brown fox jumps..."
- "Sample content" in actual UI strings
- "Click here" as placeholder link text

### Step 3: Hardcoded Data Scan Details
Search for hardcoded data in production source code:
- Hardcoded arrays used as component data
- Mock data files (`mockData.ts`, `fakeUsers.js`, `sampleData.json`) imported by production code
- `setTimeout` / `setInterval` simulating API responses
- Hardcoded emails, names, UUIDs in non-test files
- Lorem ipsum or placeholder text in UI components

### Step 4: API Connection Audit

#### Real vs Mock API Patterns

**Real API (GOOD):**
```javascript
// API base URL from environment
const API = process.env.REACT_APP_API_URL || 'http://localhost:8080';

export const fetchUsers = async () => {
  const response = await fetch(`${API}/api/users`);
  return response.json();
};

// Usage: Component fetches from real endpoint
const Dashboard = () => {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetchUsers().then(setUsers);
  }, []);
  return <UserList users={users} />;
};
```

**Mock Service Worker (LEGITIMATE in dev/test):**
```javascript
// handlers.ts (dev only)
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'Alice' }
    ]);
  })
];

// app.tsx
if (process.env.NODE_ENV === 'development') {
  import('./mocks/worker').then(({ worker }) => worker.start());
}
```

**Disconnected Wiring (BAD):**
```javascript
// API function exists but is never called
export const fetchUsers = async () => {
  return fetch(`${API}/api/users`).then(r => r.json());
};

// Component ignores it, uses hardcoded data
const Dashboard = () => {
  const users = [{ id: 1, name: 'Mock User' }]; // <-- BUG
  return <UserList users={users} />;
};
```

#### Detection Strategy
For every component that displays or submits data:
- Trace where the data comes from (API call, hardcoded, or mock)
- Verify API base URL is configured via environment variable
- Check if API calls reach real endpoints or are intercepted by MSW/mocks
- Verify form submissions actually POST/PUT to real endpoints
- Check HTTP interceptors (Axios, Fetch) point to real servers

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

### Step 7: Calculate Reality Score & Classification Methodology

#### Reality Score Formula
```
Reality Score = (REAL components) / (total data-driven components) × 100%

Example:
- REAL components: 12 (fetching from real APIs)
- PARTIAL components: 3 (some real, some mock)
- FAKE components: 2 (entirely hardcoded)
- Total data-driven: 17
- Reality Score = 12 / 17 = 70.6%
```

#### Component Classification Rubric

| Classification | Criteria | Example | Action |
|---|---|---|---|
| **🟢 REAL** | Connected to real backend, all data flows from API | User dashboard fetching from `/api/users` | No action needed |
| **🟡 PARTIAL** | Mix of real and mock data | Loading products from API, but prices hardcoded | Identify which parts are mock, fix |
| **🔴 FAKE** | Entirely disconnected, all hardcoded data | Component renders array of fake users | Replace with API call |
| **⚫ DISCONNECTED** | API code exists but not connected to UI | `fetchUsers()` exists but component ignores it | Wire component to API |
| **⚪ STATIC** | Intentionally static (about page, FAQ, legal) | Help text, company info | Document as intentional, no action |

#### Scoring Interpretation
- **90-100%** - Production-ready, almost all data is real
- **70-89%** - Good, some hardcoded config/static content is acceptable
- **50-69%** - Warning level, significant mock data exists
- **< 50%** - Critical, more fake than real, redevelop priority
- **N/A** - Static site or fixture, no real backend expected

### Step 8: Generate Remediation Plan Template

For each FAKE or PARTIAL finding, use this template:

```
## Finding: [Component name]
**File:** src/components/UserList.tsx (line 45)
**Classification:** FAKE
**Risk Level:** CRITICAL (user-facing data)
**Current Reality:** Hardcoded array of 3 fake users

### Current Code
const users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' },
  { id: 3, name: 'Charlie', email: 'charlie@example.com' }
];

### Proposed Code
const [users, setUsers] = useState([]);
const [loading, setLoading] = useState(false);

useEffect(() => {
  setLoading(true);
  fetch('/api/users')
    .then(r => r.json())
    .then(setUsers)
    .finally(() => setLoading(false));
}, []);

### Backend Dependency
- Endpoint: `GET /api/users`
- Response format: `{ id: number, name: string, email: string }[]`
- Backend status: EXISTS (already implemented)

### Dependencies
- Phase A must complete first (API client initialization)
- No other blockers

### Effort Estimate
- Implementation: 1 point (simple fetch + useState)
- Testing: 1 point (mock fetch, test loading state)
- Total: 2 points
```

#### Remediation Phases (ordered by dependency)

| Phase | Tasks | Dependencies |
|-------|-------|--------------|
| **Phase A: Foundation** | API client setup, env vars, auth | None |
| **Phase B: Data layer** | Replace mocks with real API calls | Phase A complete |
| **Phase C: Cleanup** | Remove mock files, mock libraries | Phase B complete |

**Example execution:**
1. Phase A (Day 1): Configure API_URL env var, set up Axios/Fetch client with auth headers
2. Phase B (Days 2-3): Update 5 components, each to call real endpoints instead of hardcoded data
3. Phase C (Day 4): Delete mockData.ts, faker from devDependencies, remove MSW handlers

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

## Common Mistakes

1. **Confusing test fixtures with production mocks** - Mock in `__tests__/` is OK, mock in `src/` is not
2. **Assuming hardcoded env vars are real** - Check that API_URL points to actual service, not localhost
3. **Missing pagination in "real" APIs** - API may return only 20 items by default, looks like real data but is partial
4. **Auth tokens hardcoded in code** - Real auth flows through login, not hardcoded JWT strings
5. **Seed data classified as fake** - Database fixtures for testing are legitimate, don't penalize

## Edge Cases

- **Storybook components** - Using mock data in Storybook is legitimate (dev tool), exclude from audit
- **Demo/preview mode** - If explicitly documented as feature-flagged demo, classify as STATIC
- **Fallback data** - Hardcoded data as fallback for API failure is acceptable (document clearly)
- **Offline-first apps** - Local data is primary, API is secondary - don't classify as fake
- **Static site generators** - Hardcoded data is normal, classify as STATIC (not FAKE)

## Related Skills
- `/arib-check-perf` - Performance audit (mock data may hide N+1 queries)
- `/arib-check-services` - Verify backend services running before auditing
- `/arib-dev-debug` - Debug why API calls are failing vs why code is ignoring them

## Notes
- This command activates the Reality Auditor agent
- Mock data in TEST files is legitimate - never flag it as a problem
- Seed data / fixture data is legitimate - distinguish from production mocks
- Static content (about pages, FAQ) is legitimate - don't classify as fake
- Always verify services are running before declaring APIs "disconnected"
- The remediation plan is a PROPOSAL - user must approve before any changes
- Reality Score < 80% means feature is not production-ready
