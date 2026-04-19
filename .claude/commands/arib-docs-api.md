---
argument-hint: "[scope]"
description: Docs | Generate or sync API documentation - discover endpoints, produce OpenAPI spec, detect undocumented routes
---

# /arib-docs-api Command

## Purpose
Auto-discover all API endpoints in the codebase, generate/update OpenAPI specification, detect undocumented or stale endpoints, and produce an API Documentation Report.

## Trigger
User types `/arib-docs-api [scope]`

Examples:
- `/arib-docs-api` - Full API documentation audit
- `/arib-docs-api /api/users` - Document specific resource endpoints
- `/arib-docs-api --generate` - Generate OpenAPI spec from code
- `/arib-docs-api --sync` - Sync existing docs with current code
- `/arib-docs-api --validate` - Validate existing OpenAPI spec

## Instructions

### Step 1: Activate API Documentation Agent
Read `.claude/agents/api-docs.md` and follow the 8-step protocol.

### Step 2: Discover Endpoints
Scan route files, controllers, and framework-specific patterns to find all API endpoints.

### Step 3: Cross-Reference with Existing Docs
Compare discovered endpoints with `implementation/API_ENDPOINTS.md` and any existing `openapi.yaml` / `swagger.json`.

### Step 4: Classify Sync Status
Mark each endpoint as: DOCUMENTED, UNDOCUMENTED, STALE, GHOST, or NEW.

### Step 5: Extract Schemas
Read DTOs, validation rules, serializers, and response types to build accurate request/response schemas.

### Step 6: Generate Output
Depending on flags:
- Default: produce API Documentation Report (sync status + issues)
- `--generate`: create/update `docs/openapi.yaml`
- `--sync`: update `implementation/API_ENDPOINTS.md` with discovered endpoints
- `--validate`: validate existing OpenAPI spec against code

### Step 7: Report Results
Output the API Documentation Report with:
- Sync Score (% documented and accurate)
- Endpoint inventory table
- Critical issues (undocumented, stale, design problems)
- Recommendations with effort estimates

## Notes
- This command activates the API Documentation Agent
- Run after adding new endpoints to keep docs in sync
- Integrate into CI/CD: fail build if sync score drops below threshold
- Generated OpenAPI spec can feed Postman, Swagger UI, or client SDK generators
- Always validate generated spec: `npx @redocly/cli lint docs/openapi.yaml`
