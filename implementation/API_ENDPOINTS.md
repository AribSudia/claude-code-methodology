# API Endpoints Documentation

Complete endpoint inventory for [PROJECT] API services.

## Versioning Strategy

All API endpoints are versioned using URL path prefix: `/api/v1`, `/api/v2`, etc.
- Current version: v1
- Deprecated versions are supported for 12 months before removal
- New breaking changes increment major version

## Pagination Standard

### Cursor-Based Pagination (Recommended)
Use for large datasets with frequent updates:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6IDU0MzIxfQ==",
    "prev_cursor": "eyJpZCI6IDEyMzQ1fQ==",
    "has_more": true
  }
}
```

### Offset Pagination (Legacy Support)
Use for small, static datasets:
```json
{
  "data": [...],
  "pagination": {
    "offset": 0,
    "limit": 25,
    "total": 500,
    "page": 1
  }
}
```

## Error Response Format Standard

All errors follow this schema:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "status": 400,
    "request_id": "req_123abc",
    "details": {
      "field": "error_detail"
    },
    "timestamp": "2024-01-15T10:30:45Z"
  }
}
```

### Common Error Codes
- `INVALID_REQUEST`: Malformed request (400)
- `UNAUTHORIZED`: Missing or invalid credentials (401)
- `FORBIDDEN`: Insufficient permissions (403)
- `NOT_FOUND`: Resource does not exist (404)
- `CONFLICT`: Resource conflict/duplicate (409)
- `RATE_LIMITED`: Request quota exceeded (429)
- `INTERNAL_ERROR`: Server error (500)
- `SERVICE_UNAVAILABLE`: Service temporarily down (503)

## Rate Limiting Tiers

### Tier 1: Public Endpoints
- 100 requests per minute per IP
- 10,000 requests per day per IP
- Header: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Tier 2: Authenticated Endpoints
- 500 requests per minute per user
- 50,000 requests per day per user
- Same headers as Tier 1

### Tier 3: Premium/Admin Endpoints
- 1,000 requests per minute per user
- 500,000 requests per day per user
- Custom limits by API key

When rate limited (429 response), client must wait `X-RateLimit-Reset` seconds before retrying.

---

## Endpoint Template

```
### METHOD /api/v1/path
**Auth Level:** [public | authenticated | role-based:ROLE | admin-only]
**Rate Limit Tier:** [1 | 2 | 3]

**Description:** Brief description of endpoint behavior

**Request Body:**
```json
{
  "field": "type or description"
}
```

**Response (200):**
```json
{
  "data": {},
  "request_id": "req_123abc"
}
```

**Common Error Codes:**
- 400: INVALID_REQUEST
- 401: UNAUTHORIZED
- 404: NOT_FOUND
- 429: RATE_LIMITED

---
```

## Example: CRUD Endpoints for Resources

### GET /api/v1/resources
**Auth Level:** authenticated
**Rate Limit Tier:** 2

**Description:** List all resources for authenticated user with pagination support

**Query Parameters:**
- `limit` (integer, default: 25, max: 100): Results per page
- `cursor` (string, optional): Pagination cursor for next page
- `sort` (string, default: "-created_at"): Sort field (prefix with `-` for descending)
- `filter[status]` (string, optional): Filter by status (active, archived, deleted)
- `filter[tag]` (array, optional): Filter by tags

**Response (200):**
```json
{
  "data": [
    {
      "id": "res_1234567890",
      "name": "Resource 1",
      "status": "active",
      "created_at": "2024-01-15T10:30:45Z",
      "updated_at": "2024-01-15T10:30:45Z",
      "created_by": "user_123",
      "tags": ["production", "critical"]
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6IDU0MzIxfQ==",
    "has_more": true
  },
  "request_id": "req_abc123"
}
```

**Common Error Codes:**
- 400: INVALID_REQUEST (invalid filter or sort)
- 401: UNAUTHORIZED
- 429: RATE_LIMITED

---

### POST /api/v1/resources
**Auth Level:** authenticated
**Rate Limit Tier:** 2

**Description:** Create a new resource

**Request Body:**
```json
{
  "name": "string (required, 1-255 chars)",
  "description": "string (optional, max 2000 chars)",
  "status": "string (optional, default: 'active', one of: active, inactive, archived)",
  "tags": ["string"] (optional, max 10 tags)
}
```

**Response (201):**
```json
{
  "data": {
    "id": "res_1234567890",
    "name": "Resource 1",
    "description": "A test resource",
    "status": "active",
    "tags": [],
    "created_at": "2024-01-15T10:30:45Z",
    "updated_at": "2024-01-15T10:30:45Z",
    "created_by": "user_123"
  },
  "request_id": "req_abc123"
}
```

**Common Error Codes:**
- 400: INVALID_REQUEST (missing required fields, name too long)
- 401: UNAUTHORIZED
- 409: CONFLICT (resource with same name already exists)
- 429: RATE_LIMITED

---

### GET /api/v1/resources/{id}
**Auth Level:** authenticated
**Rate Limit Tier:** 2

**Description:** Retrieve a specific resource by ID

**Path Parameters:**
- `id` (string, required): Resource ID (format: res_*)

**Response (200):**
```json
{
  "data": {
    "id": "res_1234567890",
    "name": "Resource 1",
    "description": "A test resource",
    "status": "active",
    "tags": ["production"],
    "created_at": "2024-01-15T10:30:45Z",
    "updated_at": "2024-01-16T14:22:10Z",
    "created_by": "user_123",
    "last_modified_by": "user_456"
  },
  "request_id": "req_abc123"
}
```

**Common Error Codes:**
- 401: UNAUTHORIZED
- 404: NOT_FOUND (resource does not exist)
- 429: RATE_LIMITED

---

### PATCH /api/v1/resources/{id}
**Auth Level:** authenticated
**Rate Limit Tier:** 2

**Description:** Update an existing resource (partial update, only provided fields are updated)

**Path Parameters:**
- `id` (string, required): Resource ID (format: res_*)

**Request Body:**
```json
{
  "name": "string (optional, 1-255 chars)",
  "description": "string (optional, max 2000 chars)",
  "status": "string (optional, one of: active, inactive, archived)",
  "tags": ["string"] (optional, max 10 tags)
}
```

**Response (200):**
```json
{
  "data": {
    "id": "res_1234567890",
    "name": "Resource 1 Updated",
    "description": "Updated description",
    "status": "active",
    "tags": ["production", "updated"],
    "created_at": "2024-01-15T10:30:45Z",
    "updated_at": "2024-01-16T15:45:32Z",
    "created_by": "user_123",
    "last_modified_by": "user_456"
  },
  "request_id": "req_abc123"
}
```

**Common Error Codes:**
- 400: INVALID_REQUEST (invalid field values)
- 401: UNAUTHORIZED
- 403: FORBIDDEN (user lacks update permission)
- 404: NOT_FOUND (resource does not exist)
- 409: CONFLICT (update conflicts with existing data)
- 429: RATE_LIMITED

---

### DELETE /api/v1/resources/{id}
**Auth Level:** authenticated
**Rate Limit Tier:** 2

**Description:** Soft delete a resource (marks as deleted, does not remove from database)

**Path Parameters:**
- `id` (string, required): Resource ID (format: res_*)

**Query Parameters:**
- `hard_delete` (boolean, default: false): If true, permanently delete resource (requires admin role)

**Response (204):** No content

**Common Error Codes:**
- 401: UNAUTHORIZED
- 403: FORBIDDEN (user lacks delete permission or hard_delete requires admin)
- 404: NOT_FOUND (resource does not exist)
- 429: RATE_LIMITED

---

## [PROJECT] Endpoints

Document your project-specific endpoints below, following the template format:

### GET /api/v1/[PROJECT]/...
**Auth Level:** 
**Rate Limit Tier:** 

**Description:** 

**Request/Response:** 

**Common Error Codes:**

---

## Authentication

All authenticated endpoints require:
- **Header:** `Authorization: Bearer {token}`
- Token format: JWT with issuer claim, user ID, expiration, scopes
- Token lifespan: 1 hour (short-lived) with refresh token rotation
- Invalid/expired tokens return 401 UNAUTHORIZED

## Deprecation Notice

Endpoints marked with `@deprecated` will be removed on the specified date. Plan migration accordingly.
