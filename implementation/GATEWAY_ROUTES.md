# API Gateway Routing Map

Complete request routing configuration and authentication levels for [PROJECT].

## Gateway Architecture Overview

For **microservices architectures**, this document defines how the API Gateway routes requests to backend services.

For **monolith projects**, see the "Monolith Note" section below - no separate gateway required.

---

## Route Table Template

```
| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| /api/v1/path | service-name | 3000 | [yes/no] | [tier] | Brief description |
```

### Columns Explained

- **Path Prefix:** URL pattern that gateway matches (e.g., `/api/v1/resources`)
- **Target Service:** Backend service name (corresponds to docker-compose service)
- **Port:** Service port inside Docker network
- **Auth Required:** Whether Authorization header is required
- **Rate Limit:** Tier 1/2/3 (see rate limiting section)
- **Purpose:** What this route does

---

## Route Table: Microservices Architecture

### Authentication Routes (Public)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| POST /auth/register | auth-service | 3000 | No | Tier 1 | User registration endpoint |
| POST /auth/login | auth-service | 3000 | No | Tier 1 | User login endpoint |
| POST /auth/refresh | auth-service | 3000 | No | Tier 1 | Refresh access token |
| POST /auth/logout | auth-service | 3000 | Yes | Tier 1 | User logout endpoint |
| POST /auth/password-reset | auth-service | 3000 | No | Tier 1 | Password reset request |
| GET /auth/verify/:token | auth-service | 3000 | No | Tier 1 | Email verification |
| GET /well-known/openid-configuration | auth-service | 3000 | No | Tier 1 | OIDC configuration (if using OAuth) |

### Health & Metadata Routes (Public)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /health | gateway | - | No | Tier 1 | Gateway health status |
| GET /api/v1/health | gateway | - | No | Tier 1 | Full system health check |
| GET /api/v1/status | gateway | - | No | Tier 1 | Detailed service status |
| GET /api/v1/version | gateway | - | No | Tier 1 | API version info |
| GET /docs | gateway | - | No | Tier 1 | API documentation (OpenAPI/Swagger) |
| GET /api/v1/openapi.json | gateway | - | No | Tier 1 | OpenAPI specification |

### User Routes (Authenticated)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/users/me | user-service | 3001 | Yes | Tier 2 | Get current user profile |
| PATCH /api/v1/users/me | user-service | 3001 | Yes | Tier 2 | Update current user |
| GET /api/v1/users/:id | user-service | 3001 | role:admin | Tier 2 | Get user by ID (admin only) |
| DELETE /api/v1/users/me | user-service | 3001 | Yes | Tier 2 | Delete current user account |

### Resource Routes (Authenticated)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/resources | resource-service | 3002 | Yes | Tier 2 | List user's resources |
| POST /api/v1/resources | resource-service | 3002 | Yes | Tier 2 | Create new resource |
| GET /api/v1/resources/:id | resource-service | 3002 | Yes | Tier 2 | Get resource details |
| PATCH /api/v1/resources/:id | resource-service | 3002 | Yes | Tier 2 | Update resource |
| DELETE /api/v1/resources/:id | resource-service | 3002 | Yes | Tier 2 | Delete resource |
| GET /api/v1/resources/:id/history | resource-service | 3002 | Yes | Tier 2 | Resource change history |

### Tag Routes (Authenticated)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/tags | resource-service | 3002 | Yes | Tier 2 | List all tags |
| POST /api/v1/tags | resource-service | 3002 | Yes | Tier 2 | Create new tag |
| DELETE /api/v1/tags/:id | resource-service | 3002 | Yes | Tier 2 | Delete tag |

### Search Routes (Authenticated)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/search | search-service | 3003 | Yes | Tier 2 | Full-text search |
| GET /api/v1/search/suggestions | search-service | 3003 | Yes | Tier 2 | Search autocomplete |

### Admin Routes (Admin Only)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/admin/users | user-service | 3001 | role:admin | Tier 3 | List all users |
| GET /api/v1/admin/resources | resource-service | 3002 | role:admin | Tier 3 | List all resources |
| GET /api/v1/admin/analytics | analytics-service | 3004 | role:admin | Tier 3 | System analytics |
| GET /api/v1/admin/health | gateway | - | role:admin | Tier 3 | Detailed health metrics |
| GET /api/v1/admin/config | gateway | - | role:admin | Tier 3 | System configuration (read-only) |

### WebSocket Routes (if applicable)

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| WS /api/v1/ws | notification-service | 3005 | Yes | Tier 2 | Real-time notifications |
| WS /api/v1/resources/:id/updates | resource-service | 3002 | Yes | Tier 2 | Real-time resource updates |

---

## Authentication Levels

### Level 1: Public
- **No credentials required**
- **Examples:** Login, health check, API docs
- **Use case:** Public endpoints for any caller

```bash
curl http://localhost:3000/auth/login
```

### Level 2: Authenticated
- **Requires:** Authorization header with valid JWT token
- **Examples:** List resources, get profile, create resource

```bash
curl -H "Authorization: Bearer {token}" http://localhost:3000/api/v1/resources
```

### Level 3: Role-Based (e.g., role:admin)
- **Requires:** Valid JWT token with specific role claim
- **Examples:** Admin endpoints, system configuration

```bash
curl -H "Authorization: Bearer {admin_token}" http://localhost:3000/api/v1/admin/users
```

### Level 4: Admin-Only
- **Requires:** Valid JWT token with admin role AND additional permissions
- **Examples:** System-wide operations, configuration changes

```bash
curl -H "Authorization: Bearer {admin_token}" http://localhost:3000/api/v1/admin/config
```

---

## CORS Configuration

### Allowed Origins (Development)

```json
{
  "allowed_origins": [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://localhost:8080"
  ],
  "allowed_methods": ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
  "allowed_headers": ["Content-Type", "Authorization"],
  "expose_headers": ["X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"],
  "allow_credentials": true,
  "max_age": 3600
}
```

### Allowed Origins (Production)

```json
{
  "allowed_origins": [
    "https://[PROJECT].com",
    "https://www.[PROJECT].com"
  ],
  "allowed_methods": ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
  "allowed_headers": ["Content-Type", "Authorization"],
  "expose_headers": ["X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"],
  "allow_credentials": true,
  "max_age": 86400
}
```

---

## Rate Limiting Tiers

### Tier 1: Public Endpoints
- **Limit:** 100 requests per minute per IP
- **Daily limit:** 10,000 requests per day per IP
- **Headers returned:**
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1705318245`
- **Use for:** Login, registration, public APIs
- **Exceeded response (429):**
  ```json
  {
    "error": {
      "code": "RATE_LIMITED",
      "message": "Rate limit exceeded. Retry after 60 seconds.",
      "retry_after": 60
    }
  }
  ```

### Tier 2: Authenticated Endpoints
- **Limit:** 500 requests per minute per user
- **Daily limit:** 50,000 requests per day per user
- **Use for:** Standard API endpoints requiring authentication
- **Exception handling:** Same as Tier 1 but keyed by user ID instead of IP

### Tier 3: Premium/Admin Endpoints
- **Limit:** 1,000 requests per minute per user
- **Daily limit:** 500,000 requests per day per user
- **Use for:** Admin operations, bulk operations
- **Custom limits by API key:** Negotiable for enterprise integrations

---

## Health Check Routes

### Gateway Health Endpoint

```
GET /health
```

Returns instantly (no dependencies checked):
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:45Z"
}
```

### Full System Health Check

```
GET /api/v1/health
```

Checks all service dependencies:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:45Z",
  "services": {
    "auth-service": "healthy",
    "user-service": "healthy",
    "resource-service": "healthy",
    "search-service": "healthy",
    "notification-service": "healthy",
    "database": "connected",
    "cache": "connected"
  },
  "response_time_ms": 245
}
```

### Detailed Status (Admin Only)

```
GET /api/v1/admin/health
```

```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:45Z",
  "services": {
    "auth-service": {
      "status": "healthy",
      "response_time_ms": 12,
      "version": "1.2.3"
    },
    "user-service": {
      "status": "healthy",
      "response_time_ms": 15,
      "active_connections": 42
    },
    "resource-service": {
      "status": "healthy",
      "response_time_ms": 18,
      "active_connections": 156
    },
    "database": {
      "status": "connected",
      "response_time_ms": 5,
      "active_connections": 8,
      "pool_size": 20
    },
    "cache": {
      "status": "connected",
      "response_time_ms": 3,
      "memory_used_mb": 450
    }
  },
  "uptime_seconds": 86400,
  "response_time_ms": 145
}
```

---

## WebSocket Routes

For real-time features, WebSocket connections require authentication:

### Real-Time Notifications

```
WS /api/v1/ws
```

Connection requires JWT token in query parameter:
```javascript
const ws = new WebSocket(`ws://localhost:3000/api/v1/ws?token=${token}`);

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Notification:', message);
};
```

**Message format:**
```json
{
  "type": "notification",
  "id": "notif_123abc",
  "timestamp": "2024-01-15T10:30:45Z",
  "data": {
    "title": "Resource updated",
    "body": "Your resource 'Project Alpha' was updated"
  }
}
```

### Real-Time Resource Updates

```
WS /api/v1/resources/{id}/updates
```

Subscribe to live updates for specific resource:
```javascript
const ws = new WebSocket(`ws://localhost:3000/api/v1/resources/res_123/updates?token=${token}`);

ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  console.log('Resource updated by:', update.updated_by);
};
```

---

## Monolith Note

### For Monolith Projects: No Gateway Required

If [PROJECT] is deployed as a **single monolithic application**, no API Gateway is required. Skip this configuration and follow these guidelines instead:

**Routes are defined directly in application code:**
- Use Express Router in Node.js
- Use Flask blueprints in Python
- Use Django URL patterns
- Routes in `src/routes/` directory

**Authentication:** Applied as middleware per route

**CORS:** Configure at application level, not gateway

**Rate limiting:** Implement as Express middleware

**Health checks:** Single `/health` endpoint in monolith application

**Example monolith structure:**
```
src/
├── routes/
│   ├── auth.ts        # POST /auth/login, /auth/register
│   ├── users.ts       # GET /api/v1/users/me, PATCH /api/v1/users/me
│   ├── resources.ts   # GET/POST /api/v1/resources
│   ├── admin.ts       # GET /api/v1/admin/*
│   └── health.ts      # GET /health
├── middleware/
│   ├── auth.ts        # JWT verification
│   ├── cors.ts        # CORS configuration
│   └── rateLimit.ts   # Rate limiting
└── index.ts           # Main app setup
```

**Environment variable:** `DEPLOYMENT_TYPE=monolith` (vs. `DEPLOYMENT_TYPE=microservices`)

---

## Request Flow Diagram

```
Client Request
    ↓
API Gateway
    ↓
Routing Decision
    ├─→ No auth required → Direct to service
    ├─→ Auth required → Verify JWT token
    │   ├─→ Invalid → 401 Unauthorized
    │   ├─→ Expired → 401 with refresh hint
    │   └─→ Valid → Check rate limit
    │       ├─→ Exceeded → 429 Too Many Requests
    │       └─→ OK → Route to service
    └─→ Role check (e.g., admin) → 403 Forbidden if invalid
    ↓
Backend Service
    ├─→ Success → 200 OK (+ response data)
    └─→ Error → 4xx/5xx error response
    ↓
Response to Client
    ├─→ Success → Data + rate limit headers
    └─→ Error → Error envelope + rate limit headers
```

---

## [PROJECT] Routes

Document your project-specific routes below:

### Custom Routes

| Path Prefix | Target Service | Port | Auth Required | Rate Limit | Purpose |
|-------------|-----------------|------|---------------|------------|---------|
| GET /api/v1/[PROJECT]/... | [service] | [port] | [yes/no] | [tier] | [description] |
| POST /api/v1/[PROJECT]/... | [service] | [port] | [yes/no] | [tier] | [description] |

---

## Gateway Configuration File

Example `gateway.config.yaml`:

```yaml
gateway:
  host: 0.0.0.0
  port: 3000
  log_level: info

cors:
  allowed_origins:
    - http://localhost:3000
    - https://[PROJECT].com
  allowed_methods: [GET, POST, PATCH, DELETE, OPTIONS]
  allow_credentials: true

rate_limiting:
  tier1:
    rpm: 100
    daily: 10000
  tier2:
    rpm: 500
    daily: 50000
  tier3:
    rpm: 1000
    daily: 500000

services:
  auth-service:
    host: auth-service
    port: 3000
    health_check: /health
    health_check_interval: 30s
  
  user-service:
    host: user-service
    port: 3001
    health_check: /health
    health_check_interval: 30s
  
  resource-service:
    host: resource-service
    port: 3002
    health_check: /health
    health_check_interval: 30s

routes:
  - path: /auth/*
    service: auth-service
    rate_limit: tier1
  
  - path: /api/v1/users/*
    service: user-service
    rate_limit: tier2
    auth_required: true
  
  - path: /api/v1/resources/*
    service: resource-service
    rate_limit: tier2
    auth_required: true
```

---

## Troubleshooting

### Service Not Found (503 Bad Gateway)

**Cause:** Backend service is down or not reachable

**Solution:**
```bash
# Check service health
curl http://service-name:port/health

# Restart service
docker compose restart service-name

# Check gateway logs
docker compose logs -f gateway
```

### CORS Error

**Cause:** Client origin not in allowed list

**Solution:**
- Add origin to `allowed_origins` in gateway config
- Or configure CORS in frontend to match allowed origins

### Rate Limit Exceeded Too Quickly

**Cause:** Rate limit tier too restrictive

**Solution:**
- Check if legitimate traffic or actual spike
- Adjust rate limit tier in routing config
- Or implement request batching in client

### Auth Token Invalid

**Cause:** Token expired, malformed, or wrong secret

**Solution:**
- Client should refresh token
- Check token expiration time in JWT
- Verify auth service has correct signing key
