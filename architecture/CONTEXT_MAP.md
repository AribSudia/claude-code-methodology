# CONTEXT_MAP — Architecture and Folder Structure for [PROJECT]

This document maps the codebase structure, data flows, and entry points. Use this to quickly understand where code lives and how requests flow through the system.

---

## Standard Folder Structure

```
[PROJECT]/
│
├── README.md                         # Project overview, setup, quick start
├── CHANGELOG.md                      # Release notes and version history
├── .env.example                      # Template for environment variables
├── .gitignore                        # Git ignore rules
├── .github/                          # GitHub-specific configs
│   ├── workflows/                    # CI/CD pipeline definitions
│   │   ├── test.yml
│   │   ├── lint.yml
│   │   └── deploy.yml
│   └── ISSUE_TEMPLATE/               # Issue templates
│
├── src/                              # Application source code
│   ├── index.ts                      # Entry point
│   ├── config/                       # Configuration management
│   │   ├── database.ts               # DB connection setup
│   │   ├── server.ts                 # Server/app initialization
│   │   └── constants.ts              # App-wide constants
│   ├── middleware/                   # HTTP middleware (auth, logging, CORS, etc.)
│   │   ├── auth.ts                   # Authentication middleware
│   │   ├── errorHandler.ts           # Global error handler
│   │   └── logging.ts                # Request/response logging
│   ├── controllers/                  # HTTP request handlers
│   │   ├── userController.ts         # User endpoints
│   │   ├── productController.ts      # Product endpoints
│   │   └── ...
│   ├── services/                     # Business logic (use case layer)
│   │   ├── userService.ts            # User operations
│   │   ├── productService.ts         # Product operations
│   │   └── ...
│   ├── repositories/                 # Data access layer (DAL)
│   │   ├── userRepository.ts         # User queries
│   │   ├── productRepository.ts      # Product queries
│   │   └── ...
│   ├── models/                       # Data models and schemas
│   │   ├── User.ts                   # User schema/interface
│   │   ├── Product.ts                # Product schema/interface
│   │   └── ...
│   ├── types/                        # TypeScript types and interfaces
│   │   ├── common.ts                 # Shared types (pagination, response)
│   │   └── ...
│   ├── utils/                        # Utility functions
│   │   ├── validation.ts             # Input validation helpers
│   │   ├── formatting.ts             # Data formatting
│   │   └── crypto.ts                 # Encryption/hashing utilities
│   ├── database/                     # Database setup
│   │   ├── migrations/               # Schema migrations
│   │   │   ├── 001_initial_schema.sql
│   │   │   └── ...
│   │   ├── seeds/                    # Initial data (test fixtures)
│   │   └── client.ts                 # DB connection instance
│   ├── cache/                        # Caching layer (Redis, in-memory)
│   │   ├── redisClient.ts            # Redis connection
│   │   └── cache.ts                  # Cache utilities
│   └── routes/                       # API route definitions
│       ├── users.ts                  # /api/users routes
│       ├── products.ts               # /api/products routes
│       └── index.ts                  # Route aggregation
│
├── tests/                            # Test files (mirror src structure)
│   ├── unit/                         # Unit tests
│   │   ├── services/
│   │   ├── utils/
│   │   └── ...
│   ├── integration/                  # Integration tests
│   │   ├── controllers/
│   │   ├── repositories/
│   │   └── ...
│   ├── e2e/                          # End-to-end tests
│   │   ├── user.spec.ts
│   │   └── product.spec.ts
│   ├── fixtures/                     # Test data and mocks
│   │   ├── users.ts
│   │   └── products.ts
│   └── setup.ts                      # Test configuration
│
├── docs/                             # Project documentation
│   ├── API.md                        # API documentation
│   ├── ARCHITECTURE.md               # High-level architecture
│   ├── DATABASE.md                   # Schema and migrations guide
│   ├── DEPLOYMENT.md                 # Deployment runbook
│   └── TROUBLESHOOTING.md            # Common issues and solutions
│
├── scripts/                          # Utility scripts
│   ├── seed-db.ts                    # Populate database with test data
│   ├── migrate.ts                    # Run migrations
│   └── backup.ts                     # Database backup script
│
├── docker/                           # Docker configuration
│   ├── Dockerfile                    # Application image
│   ├── docker-compose.yml            # Local dev environment
│   └── nginx.conf                    # Reverse proxy config (if applicable)
│
├── package.json                      # Dependencies and scripts
├── tsconfig.json                     # TypeScript configuration
├── jest.config.ts                    # Test runner configuration
├── eslint.config.js                  # Linter rules
├── .prettierrc                       # Code formatter rules
└── .env.example                      # Example environment variables
```

---

## Entry Points by Concern

| Concern | Start Here | Then Read | Purpose |
|---------|-----------|-----------|---------|
| **New API endpoint** | `src/routes/` | `src/controllers/` → `src/services/` → `src/repositories/` | Trace request flow |
| **Understanding business logic** | `src/services/` | `src/repositories/` → `src/models/` | See what the app actually does |
| **Database schema** | `docs/DATABASE.md` | `src/database/migrations/` | Understand data model |
| **Authentication** | `src/middleware/auth.ts` | `src/config/server.ts` | See how auth works |
| **Error handling** | `src/middleware/errorHandler.ts` | `src/types/common.ts` | See error response format |
| **Adding a test** | `tests/unit/` or `tests/integration/` | Test fixtures in `tests/fixtures/` | See test patterns |
| **Environment setup** | `.env.example` | `src/config/` | Configure the app |
| **Deployment** | `docs/DEPLOYMENT.md` | `.github/workflows/deploy.yml` | Deploy changes |
| **External integrations** | `src/services/` (search for API calls) | `src/utils/` | See how external services are called |

---

## Request Flow Diagram (Typical MVC Pattern)

```
HTTP Request
    ↓
Router (src/routes/xxx.ts)
    ↓
Middleware (src/middleware/)
    ├── Authentication
    ├── Logging
    ├── Validation
    └── CORS/headers
    ↓
Controller (src/controllers/xxxController.ts)
    ├── Parse request body
    ├── Call service(s)
    └── Format response
    ↓
Service (src/services/xxxService.ts)
    ├── Business logic
    ├── Validation
    ├── Call repository or external API
    └── Transform data
    ↓
Repository (src/repositories/xxxRepository.ts)
    ├── Build query
    ├── Execute query
    └── Return raw data
    ↓
Database (src/database/client.ts)
    ├── Parse parameterized query
    ├── Execute SQL
    └── Return rows
    ↓
Response → Middleware (logging, serialization)
    ↓
HTTP Response
```

---

## Data Flow Diagram (Create User Example)

```
POST /api/users { name, email, password }
    ↓
[authMiddleware] ← Check JWT token
    ↓
[validationMiddleware] ← Validate email format, password strength
    ↓
userController.createUser()
    ├── Extract name, email, password from request
    └── Call userService.createUser(name, email, password)
    ↓
userService.createUser()
    ├── Check email already exists → call userRepository.getByEmail()
    ├── Hash password → crypto.hash(password)
    ├── Create user object
    └── Call userRepository.create(user)
    ↓
userRepository.create(user)
    ├── Build INSERT query with parameterized placeholders
    ├── Execute query via database.query()
    └── Return created user (id, name, email)
    ↓
userService returns user
    ↓
userController formats response { id, name, email }
    ↓
[loggingMiddleware] ← Log request and response
    ↓
HTTP 201 { id, name, email }
```

---

## Danger Zones — High-Risk Files

These files have broad impact and require extra care when modifying:

| File | Risk | Why | Who Reviews |
|------|------|-----|-------------|
| `src/config/server.ts` | HIGH | Initializes middleware stack, auth, CORS | Tech Lead, Security |
| `src/middleware/auth.ts` | HIGH | Authentication gate; bypass = security breach | Security Lead |
| `src/database/migrations/` | HIGH | Schema changes; hard to undo; data loss risk | Tech Lead, DB Admin |
| `src/models/` | HIGH | Data schema; changes require migration | Tech Lead |
| `.github/workflows/deploy.yml` | HIGH | Deployment logic; wrong config = downtime | Tech Lead, DevOps |
| `src/services/` (critical) | MEDIUM | Business logic errors affect users | Domain Expert + Reviewer |
| `src/repositories/` | MEDIUM | Query errors = data loss or corruption | Tech Lead |
| `src/utils/crypto.ts` | HIGH | Encryption; mistakes leak data | Security Lead |
| `package.json` (dependencies) | MEDIUM | Supply chain risk; incompatible versions | Tech Lead |

**Rule:** Any change to a "HIGH" risk file requires:
- [ ] 2 approvers minimum
- [ ] Security review (if auth/crypto/data-related)
- [ ] Migration plan (if database-related)
- [ ] Test coverage 100%

---

## Module Dependency Rules

### Allowed Dependencies

```
Controller → Service → Repository → Database
     ↓          ↓          ↓
  Middleware   Utils     Models
     ↓          ↓          ↓
   Config ← ← ← Types ← ← ←
```

### What This Means

- **Controllers** can depend on: Services, Middleware, Config, Types, Utils.
- **Services** can depend on: Repositories, Utils, Types, Config.
- **Repositories** can depend on: Models, Utils, Database, Types.
- **Middleware** can depend on: Config, Utils, Types.
- **Utils** can only depend on: Types, other Utils.
- **Database** can only depend on: Config.

### Forbidden Patterns

```
❌ Repository → Controller (data layer calling handler)
❌ Middleware → Service (middleware calling business logic)
❌ Model → Service (data structure depending on logic)
❌ Circular: A → B → A (circular dependencies)
```

### Checking Dependencies

Run: `npm run depcheck` or `npm run madge` to visualize and detect cycles.

---

## [PROJECT]-Specific Folder Map

**TODO: Add project-specific folder structure and entry points here.**

Examples:
- Multi-service architecture: `api/`, `worker/`, `scheduler/` folders.
- Plugin system: `plugins/`, `extensions/` folders.
- Frontend + backend monorepo: `frontend/`, `backend/` folders.
- Multi-tenant: `tenants/`, `shared/` folders.

---

## File Search Cheat Sheet

**Need to find something? Use these patterns:**

- "Where do I add a new API endpoint?" → `src/routes/` and `src/controllers/`
- "Where are user queries?" → `src/repositories/userRepository.ts`
- "Where is input validation?" → `src/middleware/validation.ts` or `src/utils/validation.ts`
- "Where are error types?" → `src/types/common.ts` or `src/models/errors.ts`
- "Where are database schemas?" → `src/database/migrations/` or `src/models/`
- "Where is the app initialized?" → `src/index.ts` or `src/config/server.ts`
- "Where are constants?" → `src/config/constants.ts`
- "Where is logging?" → `src/middleware/logging.ts` or `src/utils/logger.ts`
- "Where is caching?" → `src/cache/`
- "Where are tests?" → `tests/` (mirrors `src/` structure)

---

## Adding New Features

**Checklist for adding a new domain (e.g., "Products"):**

1. **Create model:** `src/models/Product.ts` (schema/interface)
2. **Create migration:** `src/database/migrations/NNN_create_products_table.sql`
3. **Create repository:** `src/repositories/productRepository.ts` (queries)
4. **Create service:** `src/services/productService.ts` (business logic)
5. **Create controller:** `src/controllers/productController.ts` (endpoints)
6. **Create routes:** `src/routes/products.ts` (HTTP routes)
7. **Add to router:** `src/routes/index.ts` (register routes)
8. **Add middleware:** Update `src/config/server.ts` if needed (auth, logging)
9. **Add tests:** `tests/unit/` and `tests/integration/`
10. **Update docs:** `docs/API.md` and `docs/DATABASE.md`
11. **Create migration script:** `scripts/seed-products.ts` (if needed)

---

## Review Schedule

Last updated: [DATE]  
Next review: [DATE + 6 months]  
Owner: [PROJECT] Tech Lead

---

## Write Path Scoping (enforced by `.claude/hooks/pre-tool-use.sh`)

The pre-tool-use hook reads the block below. To allow Claude to write into a new
top-level directory, add it here. Paths outside this list are blocked with a
clear error message. Hard-denied paths (`.git/`, `.env*`, `~/.ssh/`, `~/.aws/`,
`/etc/`, `/usr/`) cannot be overridden via this list — see `pre-tool-use.sh`.

<!-- allowed_write_paths:start -->
- apps/
- packages/
- services/
- src/
- migrations/
- prisma/
- tests/
- docs/
- memory/
- io/
- waves/
- compliance/
- proposals/
- architecture/
- implementation/
- operations/
- core/
- bootstrap/
- reference/
- scripts/
- hooks/
- Training/
- .claude/
<!-- allowed_write_paths:end -->
