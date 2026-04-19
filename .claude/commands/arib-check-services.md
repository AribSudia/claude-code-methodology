---
description: Check | Infrastructure health - adapts to project type, checks only what exists
---

# /arib-check-services Command

## Purpose
Check the health of whatever infrastructure THIS project actually uses. Adapts automatically - monolith, microservices, frontend-only, backend-only, full-stack, or any combination.

## Trigger
User types `/arib-check-services`

## Instructions

### Step 1: Understand This Project

Before checking anything, figure out what this project IS:

```bash
# What exists in the project root?
test -f docker-compose.yml && echo "HAS_DOCKER=true" || echo "HAS_DOCKER=false"
test -f docker-compose.dev.yml && echo "HAS_DOCKER_DEV=true" || echo "HAS_DOCKER_DEV=false"
test -f package.json && echo "HAS_NODE=true" || echo "HAS_NODE=false"
test -f requirements.txt && echo "HAS_PYTHON=true" || echo "HAS_PYTHON=false"
test -f go.mod && echo "HAS_GO=true" || echo "HAS_GO=false"
test -f Gemfile && echo "HAS_RUBY=true" || echo "HAS_RUBY=false"
test -d frontend && echo "HAS_FRONTEND_DIR=true" || echo "HAS_FRONTEND_DIR=false"
test -d backend && echo "HAS_BACKEND_DIR=true" || echo "HAS_BACKEND_DIR=false"
test -d src && echo "HAS_SRC_DIR=true" || echo "HAS_SRC_DIR=false"
```

Then read these files to understand the EXPECTED architecture:
- `architecture/TECH_STACK.md` - what technologies and services this project uses
- `implementation/LOCAL_RUNBOOK.md` - how to run the project locally (ports, commands)
- `architecture/SERVICE_MAP.md` - (if exists) microservices boundaries
- `CLAUDE.md` - project type and identity

Based on what you find, classify the project:

| Type | Indicators |
|------|-----------|
| **Frontend only** | package.json with react/vue/angular, no backend dir, no API code |
| **Backend only** | API code, no frontend framework, maybe serves JSON only |
| **Full-stack monolith** | Both frontend and backend in one repo, single process or simple docker-compose |
| **Microservices** | docker-compose with multiple services, SERVICE_MAP.md exists |
| **Static site** | HTML/CSS/JS only, maybe a static site generator |

**IMPORTANT: Only check what this project actually has. Skip everything else.**

### Step 2: Check What Applies

Run ONLY the checks that match this project's type. Do NOT check for things the project doesn't use.

#### IF project has Docker (docker-compose.yml exists):
```bash
bash scripts/services-check.sh
```
Reports all containers, ports, and health status.

If services-check.sh doesn't exist, fall back to:
```bash
docker compose ps
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
```

#### IF project has a backend API:
Check the backend port from TECH_STACK.md or LOCAL_RUNBOOK.md. If not documented, try common ports:
```bash
# Only check ports that make sense for this project's stack
curl -s -o /dev/null -w "%{http_code}" http://localhost:[PORT]/health --connect-timeout 3 2>/dev/null
```

If not responding:
- Check if process is running based on the project's language
- Suggest the start command from LOCAL_RUNBOOK.md

#### IF project has a frontend:
Check the frontend port from TECH_STACK.md. If not documented, detect from framework:
- Next.js / React (CRA): port 3000
- Vite: port 5173
- Angular: port 4200
- Nuxt: port 3000
- SvelteKit: port 5173

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:[PORT] --connect-timeout 3 2>/dev/null
```

If not responding:
- Suggest start command from LOCAL_RUNBOOK.md or package.json scripts

#### IF project uses a database:
Only check the database type this project actually uses (from TECH_STACK.md or docker-compose.yml or .env):
```bash
# PostgreSQL
pg_isready -h localhost -p 5432 2>/dev/null

# MySQL
mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null

# MongoDB
mongosh --eval "db.runCommand({ping:1})" --quiet 2>/dev/null

# Redis
redis-cli ping 2>/dev/null

# SQLite - just check file exists
test -f [path-to-db] && echo "SQLITE: EXISTS"
```

#### IF project is microservices (multiple services in docker-compose):
Check inter-service connectivity:
```bash
docker compose exec [service-a] curl -s http://[service-b]:PORT/health 2>/dev/null
```

Check API Gateway if defined in GATEWAY_ROUTES.md.

#### IF project is frontend-only (no backend, no Docker):
Just check:
- Is the dev server running?
- Are dependencies installed? (`node_modules` exists?)
- Any build errors? (`npm run build --dry-run` or check last build output)

#### IF project is a simple script or CLI tool:
Just check:
- Are dependencies installed?
- Does the main entry point exist?
- Can it run? (quick smoke test)

### Step 3: Check for Port Conflicts
Only check ports that this project actually uses:
```bash
lsof -i -P -n 2>/dev/null | grep LISTEN | grep -E ":(PORTS_THIS_PROJECT_USES)" | sort
```

### Step 4: Report

Adapt the report to show ONLY what this project has. Do not show empty sections.

**Example for a full-stack monolith:**
```
INFRASTRUCTURE HEALTH CHECK
============================
Project type: Full-stack monolith

Backend:   running on :8080 (healthy)
Frontend:  running on :3000 (Vite)
Database:  PostgreSQL up on :5432
Redis:     up on :6379

Overall: ALL GREEN - ready to develop
```

**Example for a frontend-only project:**
```
INFRASTRUCTURE HEALTH CHECK
============================
Project type: Frontend (React + Vite)

Dev server:    running on :5173
Dependencies:  node_modules present (last install: 2 days ago)

Overall: ALL GREEN - ready to develop
```

**Example for microservices:**
```
INFRASTRUCTURE HEALTH CHECK
============================
Project type: Microservices (5 services)

Docker:
  auth-service:     running :3001 (healthy)
  user-service:     running :3002 (healthy)
  payment-service:  running :3003 (unhealthy - check logs)
  notification-svc: stopped
  api-gateway:      running :8080 (healthy)

Database:  PostgreSQL up on :5432
Redis:     up on :6379
RabbitMQ:  up on :5672

Network:
  auth -> user:       connected
  auth -> payment:    timeout (payment unhealthy)
  gateway -> all:     3/4 reachable

Overall: 2 ISSUES - payment-service unhealthy, notification-svc stopped
```

### Step 5: Offer Actions

Based on findings, suggest ONLY relevant actions:

If services are down, suggest the correct start command for THIS project:
- Docker project: `docker compose up -d` or `docker compose up -d [specific-service]`
- Node backend: the command from LOCAL_RUNBOOK.md or `npm run start:dev`
- Frontend: the command from package.json scripts
- Database: depends on whether it's Docker-managed or local

If all healthy:
- "All infrastructure is running. Ready to develop."

Wait for user to choose before making any changes.

## Notes
- This command adapts to whatever project type it finds - never assumes microservices
- It reads TECH_STACK.md and LOCAL_RUNBOOK.md to know what ports and services to expect
- It does NOT start services automatically - it reports and offers options
- For a project with no infrastructure (pure library, CLI tool), it just checks dependencies
- The report only shows sections that are relevant to THIS project
