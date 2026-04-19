# Claude Code Methodology v2.6.0: Bootstrap System Manual

## Table of Contents
1. [What is Bootstrap?](#what-is-bootstrap)
2. [The Four Bootstrap Protocols](#the-four-bootstrap-protocols)
3. [Protocol 1: New Project Bootstrap](#protocol-1-new-project-bootstrap)
4. [Protocol 2: Reverse Bootstrap](#protocol-2-reverse-bootstrap)
5. [Protocol 3: Upgrade Protocol](#protocol-3-upgrade-protocol)
6. [Protocol 4: Migration Guide](#protocol-4-migration-guide)
7. [Bootstrap Troubleshooting](#bootstrap-troubleshooting)

---

## What is Bootstrap?

**Bootstrap** is the Claude Code Methodology system for setting up projects. It answers the question: *"I have a project (new or existing). How do I set up all the CCM files?"*

Bootstrap is NOT about:
- Setting up build systems or CI/CD (that's beyond scope)
- Installing dependencies (you handle that)
- Creating initial project files (you handle that)

Bootstrap IS about:
- Answering questions to capture your project's shape
- Generating CLAUDE.md files filled with YOUR real data
- Optionally migrating from old systems
- Optionally upgrading from older CCM versions

### When to Use Bootstrap

| Scenario | Protocol |
|----------|----------|
| Starting a new project from scratch | **New Project Bootstrap** |
| Existing codebase, want CCM on top | **Reverse Bootstrap** |
| Upgrading from CCM v2.0 to v2.6 | **Upgrade Protocol** |
| Migrating from old claude-code-system (35-file template) | **Migration Guide** |

---

## The Four Bootstrap Protocols

### Quick Reference

```
┌─────────────────────────────────────────────────────────────────┐
│ Bootstrap Decision Tree                                         │
└─────────────────────────────────────────────────────────────────┘

START HERE: Do you have a project yet?

├─ NO, it's brand new
│  └─ Use: PROTOCOL 1 - New Project Bootstrap
│     Input: 25-question questionnaire
│     Output: Fully populated CLAUDE.md + memory/ files
│     Time: 30-45 minutes
│
├─ YES, it exists (code already written)
│  ├─ Which version of CCM are you using?
│  │  ├─ None (we're using old claude-code-system template)
│  │  │  └─ Use: PROTOCOL 4 - Migration Guide
│  │  │     Input: Old template files
│  │  │     Output: New CCM v2.6.0 structure
│  │  │     Time: 2-3 hours
│  │  │
│  │  ├─ Old CCM (v1.0 - v2.0)
│  │  │  └─ Use: PROTOCOL 3 - Upgrade Protocol
│  │  │     Input: Existing CCM files
│  │  │     Output: Upgraded to CCM v2.6.0
│  │  │     Time: 30-45 minutes
│  │  │
│  │  └─ Current CCM (v2.6.0)
│  │     └─ No bootstrap needed! Just use the project.
│  │
│  └─ Want to add CCM to existing codebase (no old template)
│     └─ Use: PROTOCOL 2 - Reverse Bootstrap
│        Input: Existing code (auto-scan)
│        Output: CLAUDE.md populated from code analysis
│        Time: 1-2 hours

END: Use appropriate protocol
```

---

## Protocol 1: New Project Bootstrap

### When to Use
- Starting a project from zero (no code yet)
- Want to capture all architectural decisions upfront
- Using new development methodology (CCM)

### Overview
Answer a 25-question questionnaire organized into 5 groups. Claude will generate fully populated CLAUDE.md files with your real data.

### The 25-Question Questionnaire

#### GROUP 1: Identity (5 Questions)
Questions that define what your project IS.

**Q1: What's the project name?**
```
Example: "OnboardHub" | "PaymentOrchestrator" | "ContentGenAI"
Purpose: Identifies the project
Note: Used for file headers, documentation, git repo name
```

**Q2: What's the project type?**
```
Choices:
  - Web app (frontend + backend)
  - Mobile app (iOS, Android, or both)
  - API/Backend service
  - CLI tool
  - Library/SDK
  - Full-stack (web + mobile)
  - Monorepo (multiple projects)
  - Data pipeline
  - AI/ML system
  - Other: ___

Example: "Web app with React frontend + Node.js backend"
Purpose: Determines technology recommendations and architecture patterns
```

**Q3: Who owns/sponsors this project?**
```
Example: "Marketing team" | "Product team" | "My startup" | "Client: Acme Inc"
Purpose: Identifies stakeholder, helps with documentation
Note: Used in CLAUDE.md for context
```

**Q4: What problem does it solve?**
```
Example: "Simplify employee onboarding with self-service workflows"
Example: "Provide real-time payment processing with fraud detection"
Purpose: Captures project mission/vision
Note: Used in CLAUDE.md project description
```

**Q5: Who are the target users?**
```
Example: "SMB HR managers, 100-1000 employees per company"
Example: "SaaS payment platforms (merchants)"
Example: "Internal: Data engineers at company"
Purpose: Defines user personas, helps prioritize features
Note: Used in testing strategy, feature prioritization
```

#### GROUP 2: Technical (7 Questions)
Questions about technology stack.

**Q6: Backend framework/language?**
```
Choices:
  - Node.js (Express, Fastify, etc.)
  - Python (Django, FastAPI, Flask, etc.)
  - Go
  - Java (Spring, Quarkus, etc.)
  - C# (.NET)
  - Ruby on Rails
  - PHP/Laravel
  - Rust (Actix, Axum, etc.)
  - Multiple backends
  - Other: ___

Example: "Node.js with Express"
Purpose: Determines code style, testing strategy, deployment model
```

**Q7: Frontend framework (if applicable)?**
```
Choices:
  - React
  - Vue
  - Angular
  - Svelte
  - Next.js
  - Nuxt
  - Vanilla JS/HTML
  - Multiple frontends
  - N/A (backend only)
  - Other: ___

Example: "React with TypeScript"
Purpose: Determines component strategy, state management, build setup
```

**Q8: Mobile app (if applicable)?**
```
Choices:
  - iOS native (Swift)
  - Android native (Kotlin)
  - React Native
  - Flutter
  - Expo
  - Capacitor
  - N/A (not mobile)
  - Multiple: ___

Example: "React Native (iOS + Android from single codebase)"
Purpose: Determines mobile strategy, build setup, deployment model
```

**Q9: Database(s)?**
```
Choices:
  - PostgreSQL (relational)
  - MySQL (relational)
  - MongoDB (document)
  - DynamoDB (NoSQL)
  - Firestore (NoSQL)
  - Redis (cache/session store)
  - Elasticsearch (search)
  - GraphQL (API layer)
  - Multiple databases
  - Other: ___

Example: "PostgreSQL (primary), Redis (cache/sessions)"
Purpose: Determines schema design, query patterns, backup strategy
Note: You can use multiple (e.g., "PostgreSQL + Redis")
```

**Q10: Caching layer?**
```
Choices:
  - Redis
  - Memcached
  - In-memory (application level)
  - CDN (for static assets)
  - None
  - Multiple: ___

Example: "Redis for session + object cache, CloudFront CDN for static assets"
Purpose: Determines performance strategy, cache invalidation patterns
```

**Q11: Authentication mechanism?**
```
Choices:
  - JWT (Bearer tokens)
  - Session + cookies
  - OAuth2 (sign in with Google/GitHub/etc.)
  - SAML (enterprise SSO)
  - API keys
  - No authentication
  - Multiple: ___

Example: "JWT for API + OAuth2 (Google, GitHub) for web"
Purpose: Determines security, token lifecycle, token refresh strategy
```

**Q12: Payments (if applicable)?**
```
Choices:
  - Stripe
  - PayPal
  - Square
  - Custom payment processor
  - None
  - Multiple: ___

Example: "Stripe for credit cards, PayPal fallback"
Purpose: Determines payment flow, webhook handling, PCI compliance needs
```

#### GROUP 3: Architecture (5 Questions)
Questions about how the system is structured.

**Q13: Monolith or microservices?**
```
Choices:
  - Monolith (single deployable unit)
  - Microservices (multiple services, separate deploys)
  - Monorepo (one repo, multiple deployable units)
  - Hybrid

Example: "Microservices (auth service, order service, payment service)"
Purpose: Determines folder structure, deployment, communication patterns

⚠️  ARCHITECTURE-AWARE BRANCHING:
If "Microservices" selected, ask follow-up questions Q13a-Q13e:

Q13a: How many services (estimate)?
  Example: "6-8 services"
  
Q13b: Service communication pattern?
  - REST/HTTP
  - gRPC
  - Message queue (RabbitMQ, Kafka)
  - Event streaming (Kafka)
  - Multiple patterns
  Example: "REST for synchronous, Kafka for async events"
  
Q13c: Shared database or per-service?
  - Shared (all services access same DB)
  - Per-service (each service has own DB)
  - Hybrid (shared for some, separate for others)
  Example: "Per-service (Auth service has auth_db, Order service has orders_db)"
  
Q13d: API gateway or direct service calls?
  - API Gateway (Kong, AWS API Gateway, etc.)
  - Direct service-to-service calls
  - Both
  Example: "API Gateway (Kong) fronting all services"
  
Q13e: Service discovery mechanism?
  - Kubernetes service discovery
  - Consul
  - Manual configuration
  - Docker Compose service names
  Example: "Kubernetes (production), Docker Compose (dev)"
```

**Q14: Event-driven (async) patterns?**
```
Choices:
  - Yes, events everywhere (event sourcing)
  - Yes, some async workflows (order events, email events, etc.)
  - No, synchronous only
  - Hybrid (mostly sync, some async)

Example: "Yes, async for: order placed, user registered, payment processed"
Purpose: Determines webhook handling, message queue setup, eventual consistency patterns
```

**Q15: API gateway or load balancer?**
```
Choices:
  - API Gateway (Kong, AWS API Gateway, etc.)
  - Load balancer (Nginx, AWS ALB, etc.)
  - Both
  - None

Example: "Kong API Gateway for rate limiting + request transformation"
Purpose: Determines rate limiting, request/response transformation, routing logic
```

**Q16: External integrations (3rd party APIs)?**
```
Example: "Stripe (payments), SendGrid (email), Twilio (SMS), Slack API"
Purpose: Determines webhook handling, secret management, integration testing
Note: List as many as apply
```

**Q17: Internationalization (i18n)?**
```
Choices:
  - Multi-language (English, Spanish, French, etc.)
  - Single language only
  - Future planning (not yet needed)

Example: "Multi-language: English, Spanish, French (Europe market)"
Purpose: Determines i18n library, translation workflow, database schema
```

#### GROUP 4: Data Model (3 Questions)
Questions about your core entities and relationships.

**Q18: What are the core entities (list 3-5)?**
```
Example: "User, Order, Product, Inventory, PaymentMethod"
Example: "Workspace, Project, Task, Comment, Attachment"
Purpose: Determines database schema, API endpoints, data relationships
Note: Think of primary nouns in your domain
```

**Q19: Key relationships between entities?**
```
Example: 
  "User -> Order (1:many)
   Order -> Product (many:many via OrderItem)
   Order -> PaymentMethod (many:1)
   Inventory -> Product (1:1)"
Purpose: Determines foreign keys, junction tables, indexes
```

**Q20: Core business rules?**
```
Example:
  "User can only have one active subscription
   Order total = sum(items) + tax + shipping - discounts
   Payment refund permitted within 30 days
   Inventory can never go negative
   Admin can soft-delete users (never hard-delete)"
Purpose: Determines validation logic, database constraints, application logic
```

#### GROUP 5: Scope (5 Questions)
Questions about what you're building.

**Q21: MVP features (launch with these)?**
```
Example:
  "User registration + authentication
   Product catalog (read-only)
   Shopping cart
   Checkout + Stripe payment
   Order tracking"
Purpose: Determines Phase 1 scope, prioritization, database schema
Note: Be realistic—what's truly needed for launch?
```

**Q22: Phase 2 features (after launch)?**
```
Example:
  "User reviews and ratings
   Wishlist
   Recommendations (basic ML)
   Admin analytics dashboard
   Email notifications"
Purpose: Determines architecture decisions (do we need to prepare for these?)
```

**Q23: Non-functional requirements (NFRs)?**
```
Example:
  "Support 1,000 concurrent users
   Page load time < 2 seconds
   99.99% uptime
   Compliance: GDPR, CCPA, PCI-DSS
   Accessibility: WCAG 2.1 AA"
Purpose: Determines performance strategy, security measures, testing requirements
```

**Q24: Deployment target?**
```
Choices:
  - AWS (EC2, Lambda, RDS, etc.)
  - Google Cloud
  - Azure
  - Heroku
  - DigitalOcean
  - Docker + self-hosted
  - Vercel (frontend)
  - Netlify (frontend)
  - Multiple: ___

Example: "AWS: EC2 (backend), RDS (database), CloudFront (CDN)"
Purpose: Determines infrastructure-as-code, CI/CD pipeline, deployment model
```

**Q25: Timeline?**
```
Example: "MVP by July 31, 2026"
Purpose: Determines sprint planning, feature prioritization
```

### What Happens After Answering

Claude generates:

```
/project/CLAUDE.md
├─ Project Overview (from Q1, Q3, Q4, Q5)
├─ Technology Stack (from Q6-Q12)
├─ Architecture (from Q13-Q17)
├─ Data Model (from Q18-Q20)
├─ Scope & Timeline (from Q21-Q25)
└─ Initial Recommendations

/project/memory/
├─ MEMORY_PROTOCOL.md (rules for memory system)
├─ project_status.md (Phase 1 features, blockers, next tasks)
├─ session_notes.md (empty, ready for first session)
├─ change_log.md (empty, ready for first commit)
├─ architecture_decisions.md (ADRs from your answers)
├─ bugs_and_fixes.md (empty, ready for bug tracking)
└─ testing_log.md (empty, ready for test tracking)

/project/.github/
├─ pull_request_template.md (for code review)
├─ bug_report_template.md (for issue tracking)
└─ workflows/ (CI/CD starters)

/project/docs/
├─ ARCHITECTURE.md (technical deep-dive)
├─ API.md (API documentation)
├─ DEPLOYMENT.md (deployment guide)
└─ DEVELOPMENT.md (developer setup guide)
```

### Step-by-Step Walkthrough Example

**Project:** PaymentOrchestrator (Stripe alternative for SAAS platforms)

**Step 1: Start bootstrap**
```bash
cd /my/new/project
claude-code --bootstrap new
```

Claude: "Let me ask 25 questions to set up your project."

**Step 2: Answer identity questions**
```
Q1: Project name?
> PaymentOrchestrator

Q2: Project type?
> Web app (API backend + dashboard frontend)

Q3: Who owns it?
> My startup (B2B SaaS)

Q4: What problem does it solve?
> Unified payment processing API for SaaS platforms. 
> Handles Stripe, PayPal, Square with single interface.
> Reduces merchant integration time from weeks to hours.

Q5: Who are target users?
> SaaS platform founders/engineers. 
> Mid-market (50-500 employees).
> Currently using 2+ payment processors.
```

**Step 3: Answer tech questions**
```
Q6: Backend framework?
> Node.js with Express + TypeScript

Q7: Frontend framework?
> React with TypeScript (admin dashboard only)

Q8: Mobile?
> N/A (API backend only)

Q9: Databases?
> PostgreSQL (transactions, merchants, webhooks)
> Redis (request queuing, rate limiting)

Q10: Caching?
> Redis (already mentioned) + CloudFront (static assets)

Q11: Authentication?
> JWT for API calls + OAuth2 for dashboard (GitHub SSO)

Q12: Payments?
> Stripe (primary), PayPal (fallback), Square (optional)
```

**Step 4: Answer architecture questions**
```
Q13: Monolith or microservices?
> Microservices (too big for monolith)

  [Claude asks Q13a-Q13e]
  
  Q13a: How many services?
  > 4: auth-service, payment-service, webhook-service, analytics-service
  
  Q13b: Communication pattern?
  > REST for sync, Kafka for async (payment events)
  
  Q13c: Shared database or per-service?
  > Hybrid: PostgreSQL shared for transactions (atomic),
  >        Redis per-service for cache
  
  Q13d: API gateway?
  > Kong API Gateway for rate limiting + auth validation
  
  Q13e: Service discovery?
  > Kubernetes (production), Docker Compose (dev)

Q14: Event-driven?
> Yes: payment_processed, webhook_delivered, merchant_created events

Q15: API gateway or load balancer?
> API Gateway (Kong) + AWS ALB behind it

Q16: External integrations?
> Stripe API, PayPal API, Square API, SendGrid (email), Slack (alerts)

Q17: Internationalization?
> Not needed (API, no UI to translate)
```

**Step 5: Answer data model questions**
```
Q18: Core entities?
> Merchant, PaymentMethod, Transaction, Webhook, EventLog, RateLimit

Q19: Key relationships?
> Merchant -> PaymentMethod (1:many)
> Merchant -> Transaction (1:many)
> Transaction -> Webhook (1:many)
> PaymentMethod -> RateLimit (1:1)

Q20: Business rules?
> Only one default PaymentMethod per merchant
> Transaction immutable after created (no changes, only refunds)
> Refund only allowed within 365 days of transaction
> Webhook retry: 5 attempts over 24 hours
> Rate limit: 1000 req/min per merchant
> Admin can view all merchants, merchants can only view themselves
```

**Step 6: Answer scope questions**
```
Q21: MVP features?
> Single payment processor (Stripe only for MVP)
> Merchant dashboard (view transactions, manage account)
> Payment processing API (charge, refund)
> Webhook delivery (to merchant apps)
> Basic rate limiting

Q22: Phase 2 features?
> Multi-processor support (PayPal, Square)
> Advanced analytics (revenue trends, failure rates)
> Custom webhook retry logic
> Merchant API keys (current: OAuth only)

Q23: NFRs?
> Support 500 concurrent users
> API p99 latency < 200ms
> 99.9% uptime SLA (production)
> PCI DSS Level 1 compliance
> Webhook delivery within 30 seconds

Q24: Deployment target?
> AWS: ECS (services), RDS (PostgreSQL), ElastiCache (Redis),
>      API Gateway, CloudWatch (monitoring)

Q25: Timeline?
> MVP by Sept 1, 2026 (8 weeks from now)
```

**Step 7: Claude generates everything**

```
✅ Generated /project/CLAUDE.md (2,400 lines)
✅ Generated /project/memory/MEMORY_PROTOCOL.md
✅ Generated /project/memory/project_status.md
✅ Generated /project/memory/architecture_decisions.md (Phase 1 ADRs)
✅ Generated /project/docs/ARCHITECTURE.md (microservices diagram)
✅ Generated /project/docs/API.md (Swagger/OpenAPI skeleton)
✅ Generated /project/.github/pull_request_template.md

Project bootstrap complete!

Next steps:
1. Review /project/CLAUDE.md (verify all data)
2. Review /project/memory/architecture_decisions.md (understand ADRs)
3. Create initial directory structure (src/, tests/, docs/)
4. Make first commit: "feat: Initial project bootstrap"
5. See Training/07-MEMORY-MANUAL.md for memory system usage
```

### Output Files Generated

**File: /project/CLAUDE.md**
```markdown
# PaymentOrchestrator v1.0.0

## Project Overview
**Owner:** PaymentOrchestrator (startup)
**Problem:** Simplify payment processing for SaaS platforms
**Target Users:** Platform engineers at mid-market SaaS companies (50-500 employees)

**Mission:** Provide unified payment API that abstracts away Stripe, PayPal, Square complexity.
Launch goal: One integration instead of three.

## Technology Stack
- **Backend:** Node.js 18+ (Express) + TypeScript
- **Frontend:** React 18 (admin dashboard only, no mobile)
- **Database:** PostgreSQL 14+ (transactions), Redis 7+ (cache, queuing)
- **Deployment:** AWS ECS, RDS, ElastiCache
- **CI/CD:** GitHub Actions (TBD)

## Architecture
**Pattern:** Microservices (4 services)
- auth-service: OAuth2, JWT validation
- payment-service: Stripe/PayPal/Square integration
- webhook-service: Async webhook delivery + retry logic
- analytics-service: Transaction analytics, reporting

**Communication:**
- Sync: REST/HTTP (service-to-service)
- Async: Kafka (payment_processed, webhook_delivered events)
- Gateway: Kong API Gateway (rate limiting, auth validation)
- Discovery: Kubernetes (prod), Docker Compose (dev)

## Data Model
**Entities:** Merchant, PaymentMethod, Transaction, Webhook, EventLog, RateLimit

**Key Relationships:**
```
Merchant (1) ---> (many) PaymentMethod
Merchant (1) ---> (many) Transaction
Transaction (1) ---> (many) Webhook
```

**Business Rules:**
- One default PaymentMethod per merchant
- Transactions immutable after creation
- Refunds only within 365 days
- 5 webhook retry attempts over 24 hours
- Rate limit: 1000 req/min per merchant

## Scope & Timeline

### MVP (by Sept 1, 2026)
- [ ] Stripe integration (primary processor)
- [ ] Merchant dashboard (transactions, settings)
- [ ] Payment processing API (charge, refund)
- [ ] Webhook delivery system
- [ ] Basic rate limiting

### Phase 2 (Post-launch)
- [ ] Multi-processor (PayPal, Square)
- [ ] Advanced analytics dashboard
- [ ] Custom webhook retry policies
- [ ] Merchant API keys

### Non-Functional Requirements
- Support 500 concurrent users
- p99 API latency < 200ms
- 99.9% uptime SLA
- PCI DSS Level 1 compliance
- Webhook delivery within 30 seconds

## Next Steps
1. Review this document (verify correctness)
2. Create directory structure
3. Set up Git + initial commit
4. See docs/ARCHITECTURE.md for system design
5. See memory/project_status.md for task list
```

**File: /project/memory/project_status.md**
```markdown
# Project Status: PaymentOrchestrator

## Current Phase
**Phase:** 1 - MVP Core Features
**Start:** 2026-04-18
**Target:** 2026-09-01 (MVP launch)
**Progress:** 0% (project starting)

## Feature Tracker

### Stripe Integration (MVP blocker)
- [ ] Stripe API client setup
- [ ] Transaction.charge() endpoint
- [ ] Transaction.refund() endpoint
- [ ] Webhook receiver for payment events

### Merchant Dashboard
- [ ] Authentication (OAuth2 GitHub)
- [ ] Transaction list view
- [ ] Transaction detail view
- [ ] Account settings page

### Webhook System
- [ ] Webhook delivery (at-least-once)
- [ ] Retry logic (5 attempts, exponential backoff)
- [ ] Event logging

### Rate Limiting
- [ ] Rate limit enforcement (1000 req/min per merchant)
- [ ] Redis-backed counter
- [ ] Rate limit headers in API response

## Current Blockers
None yet (project starting fresh).

## Next 5 Tasks
1. **Set up microservices structure** (2 hours)
   - Create src/ directories for each service
   - Set up Docker Compose for local dev
   - Create shared libraries (types, utilities)

2. **Set up Stripe sandbox account** (1 hour)
   - Get API keys
   - Review Stripe API docs
   - Set up test cards

3. **Implement auth-service skeleton** (3 hours)
   - OAuth2 setup (GitHub provider)
   - JWT token generation/validation
   - Basic auth middleware

4. **Implement payment-service skeleton** (4 hours)
   - Stripe API client
   - Transaction.charge() endpoint
   - Transaction.refund() endpoint
   - Transaction data model

5. **Set up webhook delivery system** (3 hours)
   - Webhook model + storage
   - Queue-based delivery (Redis queue)
   - Retry logic

## Timeline
- Week 1-2: Microservices setup, Stripe integration
- Week 3-4: Dashboard frontend
- Week 5-6: Webhook + rate limiting
- Week 7: Testing + performance tuning
- Week 8: Launch prep + monitoring setup
```

**File: /project/memory/architecture_decisions.md**
```markdown
# Architecture Decisions

## ADR #1 - Microservices Architecture
**Date:** 2026-04-18
**Status:** Active

### Problem
Single monolithic API would combine multiple concerns:
- Payment processing (Stripe integration)
- Merchant auth (OAuth, JWT)
- Async webhooks (event delivery + retries)
- Analytics (reporting)

These have different scaling needs, testing requirements, deployment cadence.

### Decision
Use microservices (4 independent services):
- **auth-service:** OAuth2, JWT validation (low traffic, stable)
- **payment-service:** Stripe integration (high traffic, needs scaling)
- **webhook-service:** Async event delivery (IO-bound, separate scaling)
- **analytics-service:** Reporting queries (batch processing, separate scaling)

### Alternatives Considered
1. **Monolith** (single deployable)
   - Pros: Simpler, shared database
   - Cons: Different services can't scale independently
   - Status: Rejected (analytics queries would block payment processing)

2. **Monorepo monolith** (single repo, single deployment)
   - Pros: Code sharing, single deployment pipeline
   - Cons: Same scaling problem as monolith
   - Status: Rejected

### Consequences
**Pros:**
- payment-service can auto-scale during traffic spikes
- analytics-service can run batch queries without blocking payments
- Services can be deployed independently
- Teams can own individual services

**Cons:**
- Increased operational complexity (4 deployments vs 1)
- Service-to-service communication adds latency
- Distributed tracing needed for debugging
- Database coordination required (transactions across services)

### Implementation Notes
- Kong API Gateway routes requests to appropriate service
- Services communicate via REST (sync) + Kafka (async)
- Each service has own database schema (separate tables)
- Shared transaction log in PostgreSQL for consistency

---

## ADR #2 - PostgreSQL + Redis (Not Just PostgreSQL)
**Date:** 2026-04-18
**Status:** Active

### Problem
Payment data (transactions, merchants) must be persistent + transactional (PostgreSQL).
But high-traffic read operations (rate limit checks, webhook queues) would overload PostgreSQL.

### Decision
Use both:
- **PostgreSQL:** Persistent storage (merchants, transactions, webhooks)
- **Redis:** Ephemeral data (rate limit counters, webhook queue, session cache)

### Consequences
**Pros:**
- Transaction writes are durable (PostgreSQL)
- Rate limiting is fast (Redis in-memory)
- Webhook queue is fast (Redis list)

**Cons:**
- Two systems to manage (backup, replication, upgrades)
- Data consistency issues (cache invalidation)
- Operational overhead increases

### Cache Invalidation Strategy
- Rate limit counters reset every minute (TTL)
- Webhook queue consumed immediately (ephemeral)
- Merchant cache invalidated on write (active invalidation)

---

## ADR #3 - Kafka for Async Events (Not Direct HTTP)
**Date:** 2026-04-18
**Status:** Active

### Problem
When payment is processed, 3 systems need notification:
1. Merchant (webhook delivery)
2. Analytics (update stats)
3. Audit log (record event)

Direct HTTP calls to each would:
- Block payment API while webhooks sent
- Fail if any downstream service is slow
- Lose events if services go down during processing

### Decision
Use Kafka event streaming:
1. payment-service publishes `payment_processed` event to Kafka
2. webhook-service consumes event, delivers webhook
3. analytics-service consumes event, updates stats
4. audit-service consumes event, logs it

Each consumer processes independently.

### Consequences
**Pros:**
- payment-service doesn't wait for webhooks (faster API response)
- Lost events are recovered (Kafka retains for 7 days)
- Easy to add new consumers (don't modify payment-service)

**Cons:**
- Increased operational complexity (Kafka cluster)
- Eventual consistency (webhook delay ~1-5 seconds)
- Requires consumer group management + monitoring

...
```

---

## Protocol 2: Reverse Bootstrap

### When to Use
- You have an existing codebase (code already written)
- You want to add CCM on top (without old template)
- Code is in a stable state (can pause development for 1-2 hours)

### Overview
Reverse Bootstrap auto-scans your codebase to understand its structure, then generates CLAUDE.md populated with real data extracted from your code.

### The 10-Step Auto-Scan

Claude automatically:

**Step 1: Structure Discovery**
- Scan directory tree
- Identify backend/ frontend/ services/ directories
- List all top-level folders
- Output: Directory map

**Step 2: Tech Stack Detection**
- Read package.json / requirements.txt / go.mod
- Identify frameworks (Express, React, Django, etc.)
- Identify key dependencies (Stripe, Kafka, etc.)
- Output: Technology stack summary

**Step 3: Entity Extraction**
- Scan database models (schema.sql, models/, entities/)
- Extract table names, columns, relationships
- Identify primary/foreign keys
- Output: Data model diagram

**Step 4: Route Extraction**
- Scan API routes (routes/, controllers/, handlers/)
- Extract endpoints (GET /users, POST /orders, etc.)
- Identify authentication requirements
- Output: API endpoint list

**Step 5: Authentication Analysis**
- Identify auth implementations (JWT, sessions, OAuth)
- Extract auth middleware locations
- Identify protected routes
- Output: Authentication strategy summary

**Step 6: Config Audit**
- Scan .env.example, config/ files
- Extract environment variables needed
- Identify secrets vs. non-secrets
- Output: Configuration checklist

**Step 7: Test Assessment**
- Count test files, test types (unit, integration, E2E)
- Extract test runner config (Jest, Mocha, pytest, etc.)
- Estimate test coverage
- Output: Testing summary

**Step 8: Git History**
- Extract commit messages (last 50)
- Identify common patterns
- Extract key technology decisions from commit messages
- Output: Project history summary

**Step 9: Business Logic Analysis**
- Scan main business logic files
- Extract key algorithms, calculations
- Identify complex modules
- Output: Business logic summary

**Step 10: Frontend Analysis (if web app)**
- Identify components, pages, routes
- Extract component structure
- Identify state management
- Output: Frontend architecture summary

### What Gets Generated

```
/project/CLAUDE.md
├─ Project overview (guessed from code + directory names)
├─ Technology stack (extracted from package.json, imports)
├─ Data model (extracted from schema / models)
├─ API endpoints (extracted from routes)
├─ Authentication (extracted from middleware)
├─ Testing strategy (inferred from existing tests)
├─ Architecture diagram (inferred from structure)
└─ Next steps (based on what's missing)

/project/memory/
├─ MEMORY_PROTOCOL.md
├─ project_status.md (current phase guessed from code maturity)
├─ architecture_decisions.md (inferred from code patterns)
├─ bugs_and_fixes.md (extracted from comment patterns like "TODO", "BUG")
└─ [other memory files]

/project/RENAME_MAP.md (if project name unclear)
```

### Step-by-Step Walkthrough Example

**Project:** Existing Node.js API for an e-commerce platform

**Step 1: Start reverse bootstrap**
```bash
cd /existing/ecommerce/api
claude-code --bootstrap reverse
```

Claude: "Scanning your codebase... (1-2 minutes)"

**Step 2: Claude scans and reports**

```
✅ Structure Discovery
   Found structure:
   - src/
     - models/ (User.js, Product.js, Order.js, etc.)
     - routes/ (users.js, products.js, orders.js, etc.)
     - middleware/ (auth.js, errorHandler.js, etc.)
     - services/ (stripe.js, email.js, etc.)
     - utils/ (validators.js, logger.js, etc.)
   - tests/ (unit/, integration/)
   - config/ (.env.example, database.js, etc.)

✅ Tech Stack Detection
   - Backend: Node.js 16.13 (Express 4.17)
   - Database: PostgreSQL 13 (using Knex migrations)
   - Auth: JWT + bcrypt
   - Payments: Stripe API integration
   - Email: SendGrid
   - Testing: Jest + Supertest
   - Deployment: Docker

✅ Entity Extraction
   Found entities:
   - User (id, email, password_hash, role, created_at, updated_at)
   - Product (id, name, price, inventory, category)
   - Order (id, user_id, total_price, status, shipping_address)
   - OrderItem (id, order_id, product_id, quantity, price)
   - PaymentMethod (id, user_id, stripe_token, is_default)

   Relationships:
   - User (1) -> (many) Order
   - User (1) -> (many) PaymentMethod
   - Order (1) -> (many) OrderItem
   - Product (1) -> (many) OrderItem

✅ Route Extraction
   Found endpoints:
   - GET /users/:id (protected, requires auth)
   - POST /users (public, register)
   - GET /products (public)
   - GET /products/:id (public)
   - POST /orders (protected)
   - GET /orders/:id (protected, own orders only)
   - PUT /orders/:id/cancel (protected)
   - POST /orders/:id/payment (protected)

   Auth: JWT Bearer tokens, 8-hour expiry

✅ Test Assessment
   - Unit tests: 34 (models, utils, services)
   - Integration tests: 12 (API routes, database)
   - E2E tests: 0 (none found)
   - Test runner: Jest
   - Coverage: ~65% (low)

✅ Config Audit
   Env variables needed:
   - DATABASE_URL (PostgreSQL connection)
   - JWT_SECRET (token signing)
   - STRIPE_SECRET_KEY (Stripe API)
   - SENDGRID_API_KEY (email)
   - NODE_ENV (dev/prod)

✅ Git History
   Last 5 commits:
   - "feat: Add order cancellation with refund"
   - "fix: Address validation regex"
   - "feat: Add SendGrid email notifications"
   - "refactor: Extract payment logic to service"
   - "test: Add order integration tests"

✅ Business Logic Analysis
   Complex modules:
   - OrderService.calculateTotal() (calculates tax, shipping, discounts)
   - StripeService.handleWebhook() (payment confirmations)
   - EmailService.sendOrderConfirmation() (notification workflow)

✅ Frontend Analysis
   (No frontend found—API backend only)

---

Generated files:
✅ /project/CLAUDE.md (populated with scanned data)
✅ /project/memory/project_status.md (guessed Phase 1, 70% complete)
✅ /project/memory/architecture_decisions.md (inferred patterns)
✅ /project/RENAME_MAP.md (to help identify project name)

Next steps:
1. Review /project/CLAUDE.md (verify auto-detected info)
2. Review /project/RENAME_MAP.md (confirm project identity)
3. Answer questions Claude couldn't auto-detect
4. Update /project/memory/project_status.md with correct phase
5. Make commit: "chore: Add CCM bootstrap files"
```

**Step 3: Review CLAUDE.md**

Claude generated:
```markdown
# E-Commerce API (Phase 1 - MVP)

## Project Overview
**Type:** REST API backend
**Tech:** Node.js + Express + PostgreSQL
**Estimated Maturity:** Phase 1 (70% complete—stable, missing tests)

[Claude auto-populated from code scan]

## Technology Stack
- **Backend:** Node.js 16.13, Express 4.17, TypeScript (not used yet)
- **Database:** PostgreSQL 13, Knex.js migrations
- **Authentication:** JWT + bcrypt
- **Payment:** Stripe API
- **Email:** SendGrid
- **Testing:** Jest, Supertest
- **Deployment:** Docker

## Data Model
**Entities:** User, Product, Order, OrderItem, PaymentMethod

**Key Relationships:**
```
User (1) ---> (many) Order
User (1) ---> (many) PaymentMethod
Product (1) ---> (many) OrderItem
Order (1) ---> (many) OrderItem
```

## API Surface
**Authenticated endpoints:**
- POST /users (register)
- GET /users/:id (view profile)
- POST /orders (create order)
- GET /orders/:id (view order)
- PUT /orders/:id/cancel (cancel)
- POST /orders/:id/payment (pay)

**Public endpoints:**
- GET /products (list)
- GET /products/:id (detail)

## Identified Gaps
1. No E2E tests (only unit + integration)
2. No order refunds (cancel implemented, refund not)
3. No rate limiting
4. No API documentation (Swagger/OpenAPI)
5. Missing inventory management (can over-sell products)

## Recommendations for Phase 2
1. Improve test coverage (currently ~65%, target 85%)
2. Add API documentation
3. Implement inventory locking
4. Add order refund workflow
5. Add rate limiting to API
```

**Step 4: Review RENAME_MAP.md**

Claude couldn't determine the project name, so:
```markdown
# Project Name Mapping

Claude couldn't determine the official project name from the codebase.
(Package.json just says "ecommerce-api", no marketing name found.)

What's the actual project name?
- If known: Update this file with the name
- If unknown: Use "ecommerce-api" (from package.json)

Example:
  name: "ShopHub" (if official name exists)
  type: "E-Commerce Platform (API Backend)"
  owner: "Acme Inc"
```

**Step 5: Answer clarifying questions**

If anything is unclear or auto-detected wrong, Claude asks:
```
A few clarifying questions based on the scan:

1. Project name: Is "ecommerce-api" the official name, 
   or do you have a marketing name?

2. Ownership: Who owns this project?
   (I guessed "internal team", but want to confirm)

3. Target phase: The code looks ~70% complete 
   (MVP features + some enhancements). Is this Phase 1 or Phase 2?

4. Known issues: The scan found some patterns 
   (inventory can over-sell, no refunds). Are these known limitations?

5. Next priorities: What's the top priority after current state?
```

**Step 6: Update memory files**

After clarifications:
```bash
Updated /project/CLAUDE.md with correct project name
Updated /project/memory/project_status.md with real phase
Updated /project/memory/architecture_decisions.md with actual patterns
```

**Step 7: Commit**

```bash
git add -A
git commit -m "chore: Add Claude Code Methodology (CCM) bootstrap

- Auto-scanned codebase structure, tech stack, data model
- Generated CLAUDE.md with project overview
- Set up memory system (7 core files)
- Identified gaps: E2E tests, API docs, inventory locking

See:
- /project/CLAUDE.md (project reference)
- /project/memory/ (session-to-session context)
- Training/07-MEMORY-MANUAL.md (memory system usage)
"
```

---

## Protocol 3: Upgrade Protocol

### When to Use
- You're using an older CCM version (v1.0-v2.0)
- You want to upgrade to CCM v2.6.0
- Code is stable (development can pause for 30-45 minutes)

### Overview
5-phase process to upgrade CLAUDE.md and memory files from old format to new format.

### Phase 1: Preserve
**Goal:** Back up old files before making changes.

```bash
# Create backup branch
git checkout -b ccm-upgrade-backup
git push origin ccm-upgrade-backup

# Create archive directory
mkdir -p docs/ccm-archive
cp CLAUDE.md docs/ccm-archive/CLAUDE.md.v2.0
cp -r memory/ docs/ccm-archive/memory.v2.0/
git add docs/ccm-archive/
git commit -m "chore: Back up old CCM files (v2.0) before upgrade"

# Return to main branch
git checkout main
```

### Phase 2: Update Core Format

**What changed from v2.0 to v2.6.0:**
- CLAUDE.md structure (cleaner sections)
- memory/ files (added testing_log.md)
- Archive system (formalized > 200 line rule)
- Git integration (explicit commit reference)

**Action items:**
```markdown
1. Update /project/CLAUDE.md
   - Reorganize sections to match new format
   - Add "Testing Strategy" section (if missing)
   - Add "CI/CD" section (if missing)
   - Verify all 7 sections present

2. Create /project/memory/ (if not exists)
   - Confirm all 7 files present:
     1. MEMORY_PROTOCOL.md ✓
     2. project_status.md ✓
     3. session_notes.md ✓
     4. change_log.md ✓
     5. architecture_decisions.md ✓
     6. bugs_and_fixes.md ✓
     7. testing_log.md (NEW in v2.6)

3. Create testing_log.md (if missing)
   - Migrate test results from CLAUDE.md "Testing" section
   - Format: See Training/07-MEMORY-MANUAL.md
   - Initialize with most recent test run
```

### Phase 3: Merge Old → New

**Goal:** Consolidate old CLAUDE.md into new format while preserving content.

```markdown
1. Copy old content into new CLAUDE.md sections
   - Old "Architecture" → New "Architecture" section
   - Old "API" → New "API Surface" section
   - Old "Entities" → New "Data Model" section

2. Update memory files
   - Old "Recent Changes" → change_log.md
   - Old "Known Issues" → bugs_and_fixes.md
   - Old "Test Results" → testing_log.md

3. Format everything to match new standards
   - Use consistent heading levels
   - Use consistent code block syntax
   - Verify cross-references are correct
```

### Phase 4: Add Missing v2.6 Features

**New in v2.6 that old versions didn't have:**
- Archive system (move entries > 200 lines)
- Explicit testing_log.md
- Formalized architecture_decisions.md (ADRs)
- Session notes (per-session context)

**Action items:**
```markdown
1. Set up archive system
   - Create /project/memory/archive/ directory
   - Move old entries (> 200 lines) to archive files
   - Keep recent 200 lines in main files

2. Populate testing_log.md
   - Extract recent test runs from history
   - Format with summary, suite breakdown, coverage
   - Set coverage target (if not set)

3. Formalize architecture_decisions.md
   - Extract architectural choices from old docs
   - Format each as ADR (decision, alternatives, consequences)
   - Cross-reference with code

4. Create initial session_notes.md
   - Document current state
   - Note work completed in v2.0
   - Identify next priorities
```

### Phase 5: Verify & Commit

**Verification checklist:**
```markdown
- [ ] CLAUDE.md has all 7 sections (Overview, Stack, Architecture, Data Model, API, Testing, Deployment)
- [ ] All 7 memory files present + populated
- [ ] memory/ files under 200 lines (archived if needed)
- [ ] change_log.md has recent 15-20 commits
- [ ] architecture_decisions.md has 3+ ADRs
- [ ] testing_log.md has recent test results
- [ ] No old format markers (@deprecated, ##OLD##)
- [ ] All cross-references verified (no broken links)
- [ ] Git history clean (backup branch created)
```

**Commit:**
```bash
git add -A
git commit -m "upgrade: Migrate from CCM v2.0 to v2.6.0

Breaking changes: None (backward compatible)

Changes:
- Updated CLAUDE.md to new structure
- Added testing_log.md (new in v2.6)
- Formalized architecture_decisions.md as ADRs
- Set up memory archive system (>200 line rule)
- Created initial session notes

See:
- /project/CLAUDE.md (updated structure)
- /project/memory/ (all 7 files)
- docs/ccm-archive/ (backup of old v2.0 files)

Old format: /docs/ccm-archive/CLAUDE.md.v2.0
New format: /project/CLAUDE.md
"
```

---

## Protocol 4: Migration Guide

### When to Use
- You're using the old claude-code-system (35-file template)
- You want to migrate to CCM v2.6.0
- Old system has lots of files scattered across directories

### Overview
6-phase process to consolidate 35 files into streamlined CCM structure.

### The 35-File Template (Old System)

Old system had files spread across multiple directories:
```
/docs/
├─ adr/ (10 files: ADR-001.md, ADR-002.md, etc.)
├─ decisions/ (5 files: tech-stack.md, database.md, etc.)
├─ development/ (8 files: setup.md, testing.md, guidelines.md, etc.)
└─ reference/ (12 files: api.md, models.md, endpoints.md, etc.)

/.github/
├─ CODEOWNERS
├─ pull_request_template.md
└─ issue_templates/ (4 files)

/config/
├─ jest.config.js
├─ eslint.config.js
└─ tsconfig.json

/project_metadata/
├─ CURRENT_STATUS.md
├─ ROADMAP.md
├─ KNOWN_ISSUES.md
└─ TEAM.md
```

### Phase 1: Inventory

**Goal:** Understand what you have, what it means.

```markdown
1. List all 35 files
   - Where they live
   - What they contain (1-line summary)

2. Categorize by purpose
   - Architecture/Design (ADRs, decisions)
   - Development (setup, testing, guidelines)
   - API/Data (models, endpoints, reference)
   - Project Management (status, roadmap, issues)

3. Identify content relationships
   - Which files reference each other?
   - Which files have duplicated content?
   - Which files are outdated?

Example inventory:
  docs/adr/ADR-001-microservices.md
    → Describes microservices decision
    → Related: docs/decisions/architecture.md (duplicate?)

  docs/development/TESTING.md
    → Test strategy, coverage targets
    → Related: /project_metadata/CURRENT_STATUS.md (mentions tests)
```

### Phase 2: Safety

**Goal:** Create backups before massive restructure.

```bash
# Create migration branch
git checkout -b migrate-ccm-v35-to-v2.6
git push origin migrate-ccm-v35-to-v2.6

# Create archive of old structure
mkdir -p docs/old-ccm-system-backup
cp -r docs/ docs/old-ccm-system-backup/docs/
cp -r project_metadata/ docs/old-ccm-system-backup/project_metadata/
git add docs/old-ccm-system-backup/
git commit -m "chore: Back up old CCM system (35-file template) before migration"

# Keep migration branch as safety net
git log --oneline -1
# [Verify all old files in backup before proceeding]
```

### Phase 3: Scaffold New Structure

**Goal:** Create new CCM v2.6 directories + files.

```bash
# Create new structure
mkdir -p project/memory
mkdir -p project/docs

# Create skeleton files (empty, will populate next)
touch project/CLAUDE.md
touch project/memory/MEMORY_PROTOCOL.md
touch project/memory/project_status.md
touch project/memory/session_notes.md
touch project/memory/change_log.md
touch project/memory/architecture_decisions.md
touch project/memory/bugs_and_fixes.md
touch project/memory/testing_log.md

git add project/
git commit -m "scaffold: Create new CCM v2.6.0 file structure"
```

### Phase 4: Migrate Content

**Goal:** Move content from 35 files into new structure.

**Mapping:**
```markdown
OLD STRUCTURE → NEW STRUCTURE

docs/adr/ADR-*.md
  → project/memory/architecture_decisions.md (merge all into one)

docs/decisions/*.md
  → project/memory/architecture_decisions.md (merge + format as ADRs)

docs/development/TESTING.md
  → project/memory/testing_log.md (test strategy + recent results)

docs/development/SETUP.md
  → project/docs/DEVELOPMENT.md (keep as-is, reference from CLAUDE.md)

docs/development/GUIDELINES.md
  → project/docs/DEVELOPMENT.md (merge with SETUP)

docs/reference/API.md
  → project/docs/API.md (keep as-is, reference from CLAUDE.md)

docs/reference/MODELS.md
  → project/CLAUDE.md "Data Model" section + project/docs/MODELS.md

docs/reference/ENDPOINTS.md
  → project/docs/API.md (merge with existing)

project_metadata/CURRENT_STATUS.md
  → project/memory/project_status.md (reformat)

project_metadata/KNOWN_ISSUES.md
  → project/memory/bugs_and_fixes.md (reformat as bugs)

project_metadata/ROADMAP.md
  → project/memory/project_status.md (merge into "Phase 2 features")

project_metadata/TEAM.md
  → project/CLAUDE.md "Team" section (or keep separate if large)

.github/pull_request_template.md
  → Keep as-is (unchanged)

config/*.js
  → Keep as-is (unchanged)
```

**Detailed migration for each memory file:**

**→ project/memory/architecture_decisions.md**
```markdown
# Consolidate these old files:
- docs/adr/ADR-001.md
- docs/adr/ADR-002.md
- ... (all 10 ADRs)
- docs/decisions/tech-stack.md
- docs/decisions/database.md
- ... (all 5 decision files)

# Reformat into unified ADR format:
Each becomes one section with:
- Decision ID
- Date
- Problem
- Decision
- Alternatives considered
- Consequences
- Status (Active / Superseded)
- Related decisions
```

**→ project/memory/testing_log.md**
```markdown
# Consolidate test information:
- docs/development/TESTING.md (test strategy)
- Extract test results history (from git commits or test reports)
- Include:
  - Test coverage target (from TESTING.md)
  - Current coverage % (from latest test run)
  - Recent test results
  - Identified gaps
```

**→ project/memory/bugs_and_fixes.md**
```markdown
# Consolidate known issues:
- project_metadata/KNOWN_ISSUES.md
- Extract from docs/reference/ (any "Known Issues" sections)
- Reformat each issue as:
  - Bug ID + date found
  - Symptom
  - Root cause
  - Status (Fixed / Workaround / Known issue)
  - Related bugs
```

**→ project/memory/project_status.md**
```markdown
# Consolidate project management:
- project_metadata/CURRENT_STATUS.md (current phase, progress)
- project_metadata/ROADMAP.md (Phase 2 features, future)
- Reformat into:
  - Current phase
  - Feature tracker (with checkboxes)
  - Blockers
  - Next 3-5 tasks
  - Timeline
```

**→ project/CLAUDE.md**
```markdown
# Create master project document:
- Synthesize from old docs/:
  - Project name/type (from CODEOWNERS or README)
  - Tech stack (from config/, docs/decisions/tech-stack.md)
  - Data model (from docs/reference/MODELS.md)
  - API surface (from docs/reference/API.md)
  - Architecture (from docs/decisions/architecture.md, ADRs)
  - Testing (summary from docs/development/TESTING.md)
  - Deployment (from old docs or infer from code)

# Include links to detailed docs:
- "See docs/API.md for full API reference"
- "See docs/DEVELOPMENT.md for setup instructions"
- "See memory/architecture_decisions.md for architectural choices"
```

### Phase 5: Add New Files (v2.6 Features)

**Goal:** Add files/features unique to CCM v2.6 that didn't exist in old system.

```markdown
1. Create change_log.md
   - Extract git history (last 20-30 commits)
   - Format each commit with:
     - Hash
     - Date
     - Message
     - Files changed
     - Why the change
     - Impact

2. Create session_notes.md
   - Document final state of old system
   - Note work completed
   - Identify starting point for next Claude

3. Add memory archive system
   - Create memory/archive/ directory
   - Document archive rules (files > 200 lines)
```

### Phase 6: Verify & Cleanup

**Verification:**
```markdown
1. Content completeness
   - [ ] All ADRs migrated to architecture_decisions.md?
   - [ ] All known issues migrated to bugs_and_fixes.md?
   - [ ] All test info migrated to testing_log.md?
   - [ ] All status info migrated to project_status.md?
   - [ ] No content lost in migration?

2. Format verification
   - [ ] All memory files < 200 lines (archive if > 200)?
   - [ ] All markdown formatted correctly?
   - [ ] All cross-references valid (no broken links)?
   - [ ] All code examples syntax-highlighted?

3. Deduplication
   - [ ] No duplicate content between files?
   - [ ] Architecture decisions not repeated in multiple places?
   - [ ] Test info not duplicated between CLAUDE.md and testing_log.md?

4. Git history
   - [ ] Old backup branch exists (safety net)?
   - [ ] Old files can be restored from backup?
   - [ ] New migration branch ready to merge?
```

**Cleanup:**
```bash
# Remove old directories (keep backup)
# Option 1: Delete old directories (content preserved in backup)
rm -rf docs/adr/
rm -rf docs/decisions/
rm -rf docs/development/  # NO - keep setup/guidelines for DEVELOPMENT.md
rm -rf project_metadata/

# Option 2: Keep old directories but mark deprecated
echo "# DEPRECATED - See /project/CLAUDE.md instead" > docs/adr/README.md
echo "# DEPRECATED - See /project/memory/architecture_decisions.md instead" > docs/adr/README.md

git add -A
git commit -m "migrate: Clean up old 35-file CCM system

Migrated to streamlined CCM v2.6.0 structure:
- 35 scattered files → 7 core memory files
- docs/adr/ → memory/architecture_decisions.md
- project_metadata/ → memory/project_status.md
- docs/development/TESTING.md → memory/testing_log.md
- Etc. (see migration guide for full mapping)

Old system preserved in docs/old-ccm-system-backup/ for reference.
See /project/CLAUDE.md for new project reference.
"
```

**Merge to main:**
```bash
git checkout main
git merge migrate-ccm-v35-to-v2.6
git push origin main
```

---

## Bootstrap Troubleshooting

### Problem: "I don't know the answer to this question"

**If answering a bootstrap question:**

*Option 1: Skip and come back*
```
Q10: Caching layer?
> [I don't know what caching we'll need]

Claude: That's okay. Skip for now, default to "None".
We can add caching later (Phase 2).

Continue to Q11...
```

*Option 2: Make a reasonable assumption*
```
Q9: Database(s)?
> I'm building a web app, not sure which DB yet.

Claude: Reasonable default: PostgreSQL (most flexible, good for web apps).
You can change this later if you choose a different DB.

Continue...
```

*Option 3: Ask Claude for guidance*
```
Q13: Monolith or microservices?
> Not sure... what's the difference?

Claude: 
- Monolith: Single deployable unit (simpler, good for <50k users)
- Microservices: Multiple services (complex, good for 100k+ users)

What's your expected user count?
```

### Problem: "This answer is wrong after I answer more questions"

**Revisit earlier questions if later context changes them:**

*Example:*
```
Q6: Backend framework?
> Node.js with Express

Q13: Monolith or microservices?
> Microservices (6 services, message-based communication)

Claude: Wait, your earlier answer (Node.js + Express) assumed monolith.
For microservices, you might also consider:
- Deno (better for distributed systems)
- Go (lighter-weight than Node for microservices)

Should I update your Q6 answer, or keep Express?
```

**Solution:** Say "go back" and Claude re-asks earlier questions.

### Problem: "The generated files don't match my project"

**Common causes:**

1. **Auto-scan found wrong structure**
   - Reverse bootstrap misidentified your tech stack
   - Solution: Edit CLAUDE.md directly (auto-generated is just a starting point)

2. **Project doesn't fit the 25-question format**
   - Unusual architecture (embedded systems, IoT, blockchain, etc.)
   - Solution: Answer best you can, then edit CLAUDE.md to match reality

3. **Project is hybrid (multiple tech stacks)**
   - Monorepo with Node + Python + Go services
   - Solution: Use checkboxes to select multiple (Q6 allows this)

### Problem: "Memory files feel too big after bootstrap"

**Bootstrap generates full initial memory, may exceed 200 lines:**

```
project_status.md = 450 lines (too big!)
architecture_decisions.md = 280 lines (too big!)
```

**Solution: Archive immediately after bootstrap**

```bash
# Create memory/archive/ directory
mkdir -p project/memory/archive

# Move old entries to archive
mv project/memory/architecture_decisions.md \
   project/memory/archive/architecture_decisions.md

# Keep recent entries in main file (< 200 lines)
# See Training/07-MEMORY-MANUAL.md "Archive System" section
```

### Problem: "We're using CCM but haven't touched bootstrap"

**If you started a project without bootstrap:**

You don't NEED bootstrap. You can:
1. Start coding (don't use bootstrap)
2. Use memory system (bootstrap pre-populates memory, but you can create manually)
3. Manually create CLAUDE.md (template in Training/01-GETTING-STARTED.md)

**Bootstrap is optional.** It just saves time if you're starting fresh.

---

## Conclusion

Bootstrap accelerates project setup in three ways:

1. **New Project:** Answer 25 questions → Get fully populated CLAUDE.md + memory
2. **Existing Project:** Auto-scan code → Get CLAUDE.md populated from reality
3. **Upgrade/Migration:** Convert old system → Migrate to CCM v2.6

Use whichever protocol matches your situation. All paths lead to the same streamlined, effective system.

**Remember:** Bootstrap is not mandatory. You can always create CLAUDE.md and memory files manually. But if you're starting fresh or migrating, bootstrap saves hours of setup work.

Next steps:
- For bootstrap questions: Use the appropriate protocol above
- For memory system usage: See Training/07-MEMORY-MANUAL.md
- For getting started: See Training/01-GETTING-STARTED.md
