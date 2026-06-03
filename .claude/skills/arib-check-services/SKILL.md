---
name: arib-check-services
description: Check | Infrastructure health - adapts to project type, checks only what exists
---

# /arib-check-services Command

## Purpose
Check the health of whatever infrastructure THIS project actually uses. Adapts automatically - monolith, microservices, frontend-only, backend-only, full-stack, or any combination.

## Trigger
User types `/arib-check-services`

## Overview
Service health failures cascade: one down service can block the entire system. This audit automatically detects what this project actually uses (rather than assuming), then checks only those services. It reports connectivity problems with diagnostic steps (port conflicts, wrong base URL, service crashed) and suggests the exact fix for THIS project.

## When to Use
- **Session start** - Verify all infrastructure is running before coding
- **Before testing** - Confirm all dependencies are available
- **Debugging connection errors** - Pinpoint which service is unreachable
- **Environment troubleshooting** - Detect port conflicts or misconfiguration
- **CI/CD validation** - Verify deployment health in staging

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

### Step 2: Project Type Detection Logic

Use this decision tree to classify the project BEFORE checking services:

```
Does docker-compose.yml exist?
├─ YES: Docker project
│  ├─ Multiple services (api, db, cache, etc.)?
│  │  └─ YES → Microservices
│  └─ Single service?
│     └─ YES → Containerized monolith
└─ NO: Non-Docker project
   ├─ Has frontend/ AND backend/ directories?
   │  └─ YES → Full-stack monolith
   ├─ Has backend/ only?
   │  └─ YES → Backend only
   ├─ Has package.json with react/vue/angular?
   │  └─ YES → Frontend only (Node-based)
   └─ Has HTML/CSS/JS only?
      └─ YES → Static site
```

### Step 3: Check What Applies

Run ONLY the checks that match this project's type. Do NOT check for things the project doesn't use.

#### Health Check Patterns by Service Type

**API Endpoints (Node, Python, Go, Ruby):**
```bash
# Best: /health endpoint (standard convention)
curl -s http://localhost:PORT/health

# Fallback: / endpoint (status 200 = running)
curl -s -I http://localhost:PORT/

# If API is slow to start, add retry:
for i in {1..5}; do
  curl -s http://localhost:PORT/health && echo "API OK" && break
  sleep 2
done
```

**Databases (Docker-managed):**
```bash
# PostgreSQL
docker compose exec postgres pg_isready -h localhost -p 5432

# MySQL
docker compose exec mysql mysqladmin ping -h 127.0.0.1

# MongoDB
docker compose exec mongo mongosh --eval "db.runCommand({ping:1})"

# Redis
docker compose exec redis redis-cli ping

# Local (not Docker)
# PostgreSQL: psql -U user -d dbname -c "SELECT 1"
# MySQL: mysql -u root -e "SELECT 1"
# SQLite: test -f ./db.sqlite3 && echo "EXISTS"
```

**Message Queues & Services:**
```bash
# RabbitMQ management UI
curl -s http://localhost:15672/api/vhosts

# Redis check
redis-cli --latency-history

# Kafka (if in Docker)
docker compose exec kafka kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

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
- Check if process is running: `lsof -i :[PORT]`
- Check logs: `tail -f [logfile]` or service logs
- Suggest the start command from LOCAL_RUNBOOK.md

#### IF project has a frontend:
Check the frontend port from TECH_STACK.md. If not documented, detect from framework:
- Next.js / React (CRA): port 3000
- Vite: port 5173
- Angular: port 4200
- Nuxt: port 3000
- SvelteKit: port 5173
- Svelte (Vite): port 5173

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:[PORT] --connect-timeout 3 2>/dev/null
```

If not responding:
- Check if dev server is running: `lsof -i :[PORT]`
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
Check inter-service connectivity using the connectivity matrix:
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

### Reference: Docker Troubleshooting Guide

Common Docker issues and diagnostics:

| Issue | Diagnosis | Fix |
|-------|-----------|-----|
| **Container exited** | `docker compose ps` shows "Exit 1" | `docker compose logs [service]` - check error |
| **Port already in use** | `docker compose up` fails with "port already allocated" | Kill existing process: `lsof -i :PORT` + `kill -9 PID` |
| **Service can't reach database** | API logs show "connection refused" | Verify DB service is running: `docker compose ps` |
| **DNS resolution fails** | Service logs show "getaddrinfo ENOTFOUND database" | Services use docker-compose network: use service name, not localhost |
| **Out of memory** | Container exits suddenly, `docker compose logs` shows OOMKilled | Increase Docker memory limit or reduce data volume |
| **Stale volumes** | Data persists unexpectedly after `docker compose down` | Remove volumes: `docker compose down -v` |

**Debug Commands:**
```bash
# See what's in the container
docker compose exec [service] sh -c 'ls -la /'

# Check environment variables
docker compose exec [service] env

# Test connectivity from container
docker compose exec [service] curl -v http://[other-service]:PORT

# View logs (last 50 lines)
docker compose logs --tail=50 [service]

# Follow logs in real-time
docker compose logs -f [service]
```

### Reference: Port Conflict Resolution

Only check ports that this project actually uses:
```bash
lsof -i -P -n 2>/dev/null | grep LISTEN | grep -E ":(PORTS_THIS_PROJECT_USES)" | sort
```

#### Common Port Conflicts

| Port | Service | Default Framework | Fix |
|------|---------|---|---|
| 3000 | Frontend | Next.js, React CRA, Node backend | Change frontend to 3001: `PORT=3001 npm start` |
| 5173 | Frontend | Vite | Usually free, check if another Vite dev server running |
| 8080 | Backend | Node, Python, Java | Change to 8081: `PORT=8081 npm start` |
| 5432 | PostgreSQL | Docker default | Check if local Postgres running: `lsof -i :5432` |
| 3306 | MySQL | Docker default | Check if local MySQL running |
| 6379 | Redis | Docker default | Check if local Redis running |

**Resolution:**
```bash
# Find what's using the port
lsof -i :PORT

# Kill the process (if safe)
kill -9 [PID]

# Or change project's port via environment variable
PORT=3001 npm start
```

### Reference: Inter-Service Connectivity Matrix Template

For microservices, document which services can reach which:

```
INTER-SERVICE CONNECTIVITY MATRIX
==================================

From \ To      | API    | Auth   | Payment | Notification | DB
---------------|--------|--------|---------|--------------|-------
api-gateway    | ✓      | ✓      | ✓       | ✓            | ✓
user-service   | (N/A)  | ✓      | N/A     | N/A          | ✓
payment-svc    | ✓      | ✓      | (N/A)   | ✓            | ✓
notify-svc     | ✓      | N/A    | N/A     | (N/A)        | ✓
background-job | ✓      | ✓      | ✓       | ✓            | ✓

✓ = Connected and working
✗ = Cannot connect (CHECK: firewall, service running, DNS, port)
N/A = Service doesn't need to connect there
```

**Test commands (Docker):**
```bash
# From api-gateway, can you reach user-service?
docker compose exec api-gateway curl -v http://user-service:3001/health

# From payment-svc, can you reach database?
docker compose exec payment-svc psql -h postgres -U user -d dbname -c "SELECT 1"

# Check all services can reach each other
docker compose exec api-gateway curl -s http://auth-service:3002/health
docker compose exec api-gateway curl -s http://payment-service:3003/health
docker compose exec api-gateway curl -s http://notification-svc:3004/health
```

**Common inter-service issues:**
- Service uses `localhost:PORT` instead of `service-name:PORT` (won't work in Docker)
- Firewall blocking traffic between containers
- Service not exposing the port in docker-compose.yml
- DNS resolution failing (service name typo in connection string)

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

## Common Mistakes

1. **Assuming localhost works inside Docker** - Containers need service name (postgres:5432), not localhost:5432
2. **Port conflicts undetected** - Check `lsof -i :[PORT]` before blaming the code
3. **Forgetting to expose ports in docker-compose** - Service runs but port not published: add `ports: ["3000:3000"]`
4. **Testing with wrong environment** - TECH_STACK.md specifies ports, but dev environment uses different ones
5. **Service startup order** - Database must be ready before API tries to connect (use `depends_on` with health checks)

## Edge Cases

- **Services with slow startup** - Database initialization takes 10+ seconds, don't declare "unhealthy" immediately
- **Optional services** - Redis cache down is warning, not critical; system still works without it
- **Health check endpoints** - Not all services expose `/health` (check TECH_STACK.md for actual endpoint)
- **Partial network failure** - One service down may cause others to appear down; diagnose from logs
- **Docker daemon not running** - `docker compose ps` fails silently; check if Docker is running first

## Related Skills
- `/arib-check-reality` - Verify APIs are genuinely connected (after confirming services running)
- `/arib-check-perf` - Performance issues may be masked by slow/unhealthy services
- `/arib-dev-debug` - Debug mysterious connection errors after confirming services healthy

## Notes
- This command adapts to whatever project type it finds - never assumes microservices
- It reads TECH_STACK.md and LOCAL_RUNBOOK.md to know what ports and services to expect
- It does NOT start services automatically - it reports and offers options
- For a project with no infrastructure (pure library, CLI tool), it just checks dependencies
- The report only shows sections that are relevant to THIS project
- Always run this before running tests or debugging connectivity issues
