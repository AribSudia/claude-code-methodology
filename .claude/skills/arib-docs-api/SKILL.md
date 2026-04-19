---
argument-hint: "[scope]"
description: Docs | Generate or sync API documentation - discover endpoints, produce OpenAPI spec, detect undocumented routes
---

# /arib-docs-api Command

## Purpose
Auto-discover all API endpoints in the codebase, generate/update OpenAPI specification, detect undocumented or stale endpoints, and produce an API Documentation Report. Supports endpoint discovery in Express.js, FastAPI, Django, and other frameworks via pattern matching. Detects schema drift, undocumented routes, and generates OpenAPI 3.0 specs with sync quality metrics.

## Trigger
User types `/arib-docs-api [scope]`

Examples:
- `/arib-docs-api` - Full API documentation audit
- `/arib-docs-api /api/users` - Document specific resource endpoints
- `/arib-docs-api --generate` - Generate OpenAPI spec from code
- `/arib-docs-api --sync` - Sync existing docs with current code
- `/arib-docs-api --validate` - Validate existing OpenAPI spec
- `/arib-docs-api --scope src/routes --depth 2` - Audit specific directory

## Instructions

### Step 1: Activate API Documentation Agent
Read `.claude/agents/api-docs.md` and follow the 8-step protocol.

### Step 2: Discover Endpoints by Framework

**Express.js/Node.js:**
```bash
# Find all route definitions
grep -rn "app\.\(get\|post\|put\|delete\|patch\)\(" src/ --include="*.js" --include="*.ts"
# Alternative: check route mounting
grep -rn "\.use\(" src/ --include="*.js" --include="*.ts"
```

**FastAPI/Python:**
```bash
# Find decorators
grep -rn "@app\.\(get\|post\|put\|delete\|patch\)" src/ --include="*.py"
grep -rn "@router\.\(get\|post\|put\|delete\|patch\)" src/ --include="*.py"
```

**Django:**
```bash
# Find urlpatterns
grep -rn "path\|re_path\|url" --include="urls.py"
```

For each discovered endpoint, capture:
- Method (GET, POST, PUT, DELETE, PATCH)
- Path pattern (with variable segments)
- Handler function/view name
- Line number and file path

### Step 3: Extract Request/Response Schemas

**Check for JSDoc/docstring schemas:**
```javascript
/**
 * @param {Object} req - Request object
 * @param {string} req.params.id - User ID
 * @param {Object} req.body - { email: string, name: string }
 * @returns {Object} { id: string, email: string, createdAt: ISO8601 }
 */
```

**Check for TypeScript interfaces (preferred):**
```typescript
interface CreateUserRequest {
  email: string;
  name: string;
  role?: "admin" | "user";
}

interface UserResponse {
  id: string;
  email: string;
  name: string;
  createdAt: string;
  role: string;
}
```

**Check for validation rules:**
```javascript
// Zod, Joi, Yup, Pydantic
const schema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150)
});
```

**Check for response type hints (Python):**
```python
def get_user(user_id: str) -> UserResponse:
    # Extract UserResponse schema from return type
```

### Step 4: Classify Sync Status

For each endpoint, assign one of:

| Status | Definition | Action |
|--------|-----------|--------|
| **DOCUMENTED** | Endpoint found in code AND docs match implementation | Keep as-is, verify parameters match |
| **UNDOCUMENTED** | Endpoint exists in code but NOT in docs/OpenAPI spec | Add to spec with inferred schema |
| **STALE** | Docs exist but endpoint signature changed (params/response) | Update docs to match current implementation |
| **GHOST** | Endpoint documented but NOT found in code (deleted?) | Remove from docs, add to deprecation note |
| **NEW** | Just added to codebase, no docs yet | Generate docs immediately |
| **DEPRECATED** | Endpoint marked with deprecation notice in code | Keep with deprecation flag in OpenAPI spec |

Example classification:
```
/api/users/:id
  Status: STALE
  Issue: Docs show response field "createdAt" but code returns "created_at"
  Action: Update schema to match current implementation
```

### Step 5: Build OpenAPI 3.0 Spec Fragment

For each endpoint, extract/generate:

```yaml
/api/users/{userId}:
  get:
    summary: Retrieve user by ID
    description: >
      Fetch a single user record by their unique identifier.
      Requires authentication. Limited to viewing own profile
      unless user has admin role.
    operationId: getUser
    parameters:
      - name: userId
        in: path
        required: true
        schema:
          type: string
          format: uuid
          example: "550e8400-e29b-41d4-a716-446655440000"
    responses:
      "200":
        description: User found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      "404":
        description: User not found
      "401":
        description: Authentication required
    security:
      - bearerAuth: []
    x-sync-status: DOCUMENTED  # Custom extension for tracking
    x-last-verified: "2026-04-19"
```

### Step 6: Detect Freshness & Calculate Sync Score

**Freshness detection:**
- Check `x-last-verified` timestamp in OpenAPI spec
- Compare with last code modification date (git log)
- If code modified after last verified: flag as POTENTIALLY_STALE
- If >30 days since verification: flag for review

**Sync Score calculation:**
```
Total endpoints found in code: N
Endpoints with matching docs:  D
Endpoints marked STALE:        S
Endpoints marked GHOST:        G

SyncScore = ((D - S) / (N + G)) * 100

Example:
  Found 50 endpoints
  35 documented accurately
  5 stale
  2 ghost (in docs but not code)
  
  Score = ((35 - 5) / (50 + 2)) * 100 = 58%
```

**Quality metrics:**
- Coverage: % of implemented endpoints documented
- Accuracy: % of documented endpoints matching implementation
- Freshness: days since last verification vs. days since code change
- Completeness: % endpoints with request/response examples

### Step 7: Example: Well-Documented vs Poorly-Documented Endpoint

**WELL-DOCUMENTED endpoint:**
```javascript
/**
 * Create a new blog post
 * 
 * Validates title (3-200 chars), body (10+ chars), publishes draft.
 * Slug auto-generated from title. Returns full post with metadata.
 * 
 * @param {Object} req.body
 * @param {string} req.body.title - Post title (required, 3-200 chars)
 * @param {string} req.body.body - Post content (required, 10+ chars)
 * @param {string[]} req.body.tags - Tags (optional, max 10)
 * @param {boolean} req.body.published - Publish immediately (default: false)
 * @param {string} req.user.id - From auth middleware
 * 
 * @returns {Object}
 * @returns {string} .id - Post UUID
 * @returns {string} .slug - URL-safe slug
 * @returns {string} .title - Post title
 * @returns {string} .authorId - Creator user ID
 * @returns {string[]} .tags - Tags array
 * @returns {boolean} .published - Publication status
 * @returns {string} .createdAt - ISO 8601 timestamp
 * 
 * @throws {400} Title too short/long
 * @throws {401} Not authenticated
 * @throws {403} User banned from posting
 * 
 * @example
 * POST /api/posts
 * {
 *   "title": "Getting Started with Node.js",
 *   "body": "Node.js is a JavaScript runtime...",
 *   "tags": ["nodejs", "javascript"],
 *   "published": true
 * }
 * 
 * Response:
 * {
 *   "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
 *   "slug": "getting-started-with-nodejs",
 *   "title": "Getting Started with Node.js",
 *   "authorId": "user-123",
 *   "tags": ["nodejs", "javascript"],
 *   "published": true,
 *   "createdAt": "2026-04-19T14:30:00Z"
 * }
 */
router.post('/posts', auth, createPost);
```

**POORLY-DOCUMENTED endpoint:**
```javascript
// Create post
router.post('/posts', auth, createPost);

function createPost(req, res) {
  // TODO: add validation
  const post = new Post(req.body);
  post.save();
  res.json(post);
}
```

Issues with poor version:
- No parameter documentation
- No response schema
- No error handling documented
- No auth requirements stated
- Unclear if validation exists
- No examples

### Step 8: Cross-Reference with Existing Docs

Compare discovered endpoints with:
- `implementation/API_ENDPOINTS.md` - manual endpoint inventory
- `docs/openapi.yaml` - OpenAPI spec (if exists)
- `docs/swagger.json` - Swagger spec (if exists)
- README.md - Quick API reference
- Postman collection (if exported)

Mark discrepancies:
```
Endpoint: DELETE /api/users/:id
Found in: code (line 245, users-router.js)
Documented in: API_ENDPOINTS.md, openapi.yaml
Status: DOCUMENTED

BUT:
  Code parameter: userId (string, UUID)
  Docs parameter: id (string, integer)
  → STALE: Parameter type mismatch

  Code returns: 204 No Content
  Docs returns: 200 OK with { success: true }
  → STALE: Response format changed
```

### Step 9: Generate Output

**Default output (API Documentation Report):**
```markdown
# API Documentation Report
Generated: 2026-04-19

## Summary
- Total Endpoints: 47
- Documented: 42 (89%)
- Undocumented: 3 (6%)
- Stale: 2 (4%)
- Sync Score: 87%

## Endpoint Inventory

| Path | Method | Status | Last Verified |
|------|--------|--------|---------------|
| /api/users | GET | DOCUMENTED | 2026-04-15 |
| /api/users | POST | DOCUMENTED | 2026-04-18 |
| /api/users/:id | GET | DOCUMENTED | 2026-04-15 |
| /api/users/:id | PUT | STALE | 2026-03-20 |
| /api/posts | GET | DOCUMENTED | 2026-04-19 |
| /api/posts/:id/comments | GET | UNDOCUMENTED | - |

## Critical Issues

### UNDOCUMENTED Endpoints (3)
- [ ] GET /api/admin/reports - No schema, no auth docs
- [ ] POST /api/webhooks/register - Payment-related, no safety docs
- [ ] DELETE /api/cache/clear - Internal endpoint, undocumented scope

### STALE Endpoints (2)
- [ ] PUT /api/users/:id - Param type mismatch (int vs UUID)
- [ ] POST /api/posts - Response format changed

## Recommendations (Priority Order)
1. [HIGH] Document webhook endpoint (security concern) - Effort: 30 min
2. [MEDIUM] Fix parameter type in users/:id (5 min)
3. [MEDIUM] Update POST /api/posts response docs (10 min)
4. [LOW] Add internal endpoints to separate spec (20 min)
```

**With `--generate` flag:**
Creates or updates `docs/openapi.yaml` with full spec.

**With `--sync` flag:**
Updates `implementation/API_ENDPOINTS.md` with discovered endpoints.

**With `--validate` flag:**
Validates existing OpenAPI spec for syntax and completeness.

## Decision Tree: When to Use Each Flag

```
User wants to:
├─ See current state?
│  └─ No flag (default) → API Documentation Report
├─ Create/update OpenAPI spec?
│  └─ --generate → Create docs/openapi.yaml
├─ Update endpoint inventory?
│  └─ --sync → Update implementation/API_ENDPOINTS.md
├─ Check spec validity?
│  └─ --validate → Lint against OpenAPI 3.0 schema
└─ Custom scope?
   └─ --scope [path] --depth [n] → Audit specific directory
```

## Edge Cases & Common Issues

| Issue | Detection | Fix |
|-------|-----------|-----|
| **Endpoints with same path, different methods** | Check if GET and POST both exist on /api/users | Ensure OpenAPI spec combines them under single path object |
| **Parameterized paths** | `/users/:id` vs `/users/{id}` | Convert to OpenAPI format: `/users/{id}` |
| **Nested resource endpoints** | `/api/users/:userId/posts/:postId` | Document as separate resource with proper path parameters |
| **Endpoint aliases** | Same logic on `/api/users` and `/users` | Document primary path, note alias in description |
| **Content negotiation** | Single endpoint serving JSON and XML | Document both in OpenAPI `content:` section |
| **Deprecated endpoints** | Old /v1/ endpoints still in code | Mark with `deprecated: true` in spec, add sunset date |
| **Undocumented query params** | Code accepts `?limit=10&offset=20` but not documented | Scan request handler for query parsing, extract to schema |

## Common Mistakes

1. **Forgetting async/await behavior** - Document timeout limits and error handling for long-running endpoints
2. **Assuming default HTTP status codes** - Always verify actual status codes returned (200 vs 201 vs 204)
3. **Schema mismatch in nested objects** - Deeply nested responses (users.profile.settings) need careful schema definition
4. **Missing authentication docs** - Always document which endpoints require auth and which scope/role
5. **Ignoring backward compatibility** - When updating docs, note if change breaks existing clients
6. **Forgetting error response examples** - Document 400, 401, 403, 404, 500 responses with actual error format
7. **Not version-controlling the OpenAPI spec** - Treat openapi.yaml as a first-class file in git
8. **Mixing manual and generated docs** - Pick one source of truth (auto-generated or hand-written), not both

## Related Skills

- `/arib-docs-generate` - Generate comprehensive docs for any target
- `/arib-io` - Process requests and signals through I/O channel
- `review` - Review API changes in pull requests
- `security-review` - Audit API endpoints for auth/permissions issues

## Notes
- This command activates the API Documentation Agent
- Run after adding new endpoints to keep docs in sync
- Integrate into CI/CD: fail build if sync score drops below threshold
- Generated OpenAPI spec can feed Postman, Swagger UI, or client SDK generators
- Always validate generated spec: `npx @redocly/cli lint docs/openapi.yaml`
- Store OpenAPI spec as `docs/openapi.yaml` (YAML is more readable than JSON for version control)
- Use `x-` extensions to track custom metadata (sync status, last verified, examples)
