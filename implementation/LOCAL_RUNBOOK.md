# Local Development Runbook

Get [PROJECT] cloned, running, and verified in under 15 minutes.

## Prerequisites Checklist

Before starting, verify you have:

- [ ] **Node.js** v18.x or v20.x
  ```bash
  node --version  # Should output v18.x.x or v20.x.x
  ```

- [ ] **npm** v9.x or higher (or yarn/pnpm equivalent)
  ```bash
  npm --version  # Should output v9.x.x or higher
  ```

- [ ] **Docker Desktop** v4.0+ or Docker Engine + Docker Compose v2.0+
  ```bash
  docker --version  # Should output Docker version 20.10+
  docker compose version  # Should output v2.0.0+
  ```

- [ ] **Git** v2.30+
  ```bash
  git --version
  ```

- [ ] **4GB+ available RAM** (8GB recommended for smooth development)
  ```bash
  # macOS
  system_profiler SPHardwareDataType | grep Memory

  # Linux
  free -h

  # Windows
  wmic OS get TotalVisibleMemorySize,FreePhysicalMemory
  ```

- [ ] **10GB+ free disk space**
  ```bash
  # macOS/Linux
  df -h / | tail -1

  # Windows
  powershell "Get-PSDrive C | Select-Object Used,Free"
  ```

---

## Step-by-Step Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/[ORG]/[PROJECT].git
cd [PROJECT]
```

Expected: Repository cloned with `.git` directory present.

### Step 2: Create Environment File

```bash
cp .env.example .env.local
```

Verify `.env.local` contains:
```
NODE_ENV=development
DATABASE_URL=postgresql://dev:devpass@localhost:5432/[PROJECT]_dev
REDIS_URL=redis://localhost:6379
API_PORT=3000
LOG_LEVEL=info
```

Edit `.env.local` if you changed any defaults (e.g., different ports, database name).

### Step 3: Install Dependencies

```bash
npm install
# or
yarn install
# or
pnpm install
```

Expected: `node_modules/` directory created, no error messages in console.

Troubleshooting:
- If you see `npm ERR! code EACCES`, try: `sudo chown -R $(whoami) ~/.npm`
- If you see peer dependency warnings, they're generally safe to ignore

### Step 4: Start Docker Services

```bash
docker compose up -d
```

Wait for services to start (10-30 seconds):
```bash
docker compose ps
```

Expected output: All services show as "Running" or "Healthy"
```
NAME                 COMMAND                  SERVICE      STATUS
[project]-postgres   "docker-entrypoint..."   postgres     Up 2s (healthy)
[project]-redis      "redis-server"           redis        Up 2s (healthy)
[project]-app        "npm run dev"            app          Up 1s
```

If any service shows "Exited" or "Unhealthy":
```bash
# View error logs
docker compose logs postgres  # or redis
```

### Step 5: Run Database Migrations

```bash
npm run migrate:latest
```

Expected output: Shows list of applied migrations
```
✓ 20240115093000_create_user_roles_enum.sql
✓ 20240115093001_create_status_enum.sql
✓ 20240115093002_create_users_table.sql
... (more migrations) ...
✓ 20240115093202_add_performance_indexes.sql
```

Verify migrations applied:
```bash
npm run migrate:status
```

Troubleshooting:
- If you see "connection refused": ensure PostgreSQL is healthy (`docker compose ps postgres`)
- If you see "migration already applied": this is normal on re-runs
- If you see "constraint violation": run `docker compose down -v` to clear data and restart

### Step 6: Seed Database (Optional but Recommended)

```bash
npm run db:seed
```

This populates test data:
- 5 test users (dev@localhost, etc.)
- 20 sample resources
- Related tags and associations

Expected output:
```
Seeding database...
✓ Created 5 users
✓ Created 20 resources
✓ Created 15 tags
✓ Created 50 resource-tag associations
Seed complete!
```

Skip this step if you prefer an empty database.

### Step 7: Start Application

In a new terminal window:

```bash
npm run dev
```

Expected output:
```
> [PROJECT] dev
[10:30:45] Starting development server...
[10:30:48] ✓ Database connected
[10:30:49] ✓ Redis cache connected
[10:30:50] ✓ Server running on http://localhost:3000
[10:30:50] ✓ Watching for file changes...
```

Application is now running! Leave this terminal open.

---

## Verification Commands

Run these commands to verify everything is working:

### Health Check Endpoint

```bash
curl http://localhost:3000/health
```

Expected response (200):
```json
{
  "status": "ok",
  "uptime_seconds": 45,
  "database": "connected",
  "cache": "connected",
  "timestamp": "2024-01-15T10:30:45Z"
}
```

### Database Connection

```bash
npm run db:verify
```

Expected output:
```
✓ Database connection verified
✓ Schema version: 20240115093202
✓ User table: 5 rows
✓ Resource table: 20 rows
```

### Redis Connection

```bash
docker compose exec redis redis-cli ping
```

Expected output:
```
PONG
```

### Test User Login (if seeded)

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@localhost","password":"password"}'
```

Expected response (200):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "user_123",
    "email": "dev@localhost",
    "name": "Dev User",
    "role": "admin"
  }
}
```

### API Test

Get the token from login above, then:

```bash
TOKEN="<token from login response>"

curl http://localhost:3000/api/v1/resources \
  -H "Authorization: Bearer $TOKEN"
```

Expected response (200): Array of resources (or empty array if not seeded).

### Run Test Suite

```bash
npm test
```

Expected: All tests pass (or show reasonable failures for first-time setup).

---

## Development Workflow Shortcuts

### Code Changes Auto-Reload

The development server watches for changes and auto-reloads:
```bash
# Just save your file in your editor
# Server will show: [HMR] /src/routes/users.ts updated
# No need to restart manually
```

### Database Changes

```bash
# Create a new migration
npm run migrate:create -- --name=add_new_column

# Edit /database/migrations/YYYYMMDDHHMMSS_add_new_column.sql

# Apply immediately
npm run migrate:latest

# Rollback if needed
npm run migrate:rollback
```

### Create New Test User

```bash
npm run create:test-user -- --email=user@test.com --password=test123 --role=user
```

### Check Code Quality

```bash
npm run lint          # Run linter
npm run lint:fix      # Auto-fix lint issues
npm run format        # Format code with Prettier
npm run type:check    # Run TypeScript type checking
```

### Run Specific Test

```bash
npm test -- --testNamePattern="user login"
```

### View Application Logs

```bash
# From another terminal, while app is running
docker compose logs -f app
```

### Access Database Directly

```bash
docker compose exec postgres psql -U dev -d [PROJECT]_dev

# Inside PostgreSQL:
SELECT * FROM users LIMIT 5;
\dt  # List all tables
\q   # Quit
```

### View Redis Data

```bash
docker compose exec redis redis-cli

# Inside Redis:
KEYS *           # View all keys
GET key_name     # Get value
DBSIZE           # Total keys in database
FLUSHDB          # Clear current database (careful!)
```

---

## Troubleshooting FAQ

### "Address already in use" error on port 3000/5432/6379

**Cause:** Another process is using the port

**Solution:**
```bash
# Find which process uses port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use different port in .env.local
DATABASE_URL=postgresql://dev:devpass@localhost:5433/[PROJECT]_dev  # Changed 5432 to 5433
```

### "Cannot find module 'express'" or similar

**Cause:** Dependencies not installed

**Solution:**
```bash
rm -rf node_modules package-lock.json
npm install
```

### "connection refused" when running migrations

**Cause:** PostgreSQL not running or not ready

**Solution:**
```bash
# Check if container is running
docker compose ps postgres

# If not running, start it
docker compose up -d postgres

# Wait 10 seconds for PostgreSQL to be ready
sleep 10

# Then run migrations
npm run migrate:latest
```

### "ENOENT: no such file or directory" during seed

**Cause:** Migrations didn't run

**Solution:**
```bash
# Verify migrations ran
npm run migrate:status

# If not, run them
npm run migrate:latest

# Then seed
npm run db:seed
```

### "Token invalid" when calling API

**Cause:** Token expired or login failed

**Solution:**
```bash
# Get a fresh token
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@localhost","password":"password"}'

# Use the new token in requests
```

### "Database is locked" error

**Cause:** Migration or query holding lock

**Solution:**
```bash
# Restart PostgreSQL
docker compose restart postgres

# Wait for it to become healthy
docker compose ps postgres

# Re-run migrations
npm run migrate:latest
```

### Application won't start after changes

**Cause:** TypeScript compilation error or syntax error

**Solution:**
```bash
# Check the error in dev terminal (should show error)
# Fix the code and save - it should auto-reload

# Or check build manually
npm run build
```

### "Redis connection refused"

**Cause:** Redis not running

**Solution:**
```bash
# Restart Redis
docker compose restart redis

# Verify it's healthy
docker compose ps redis

# Test connection
docker compose exec redis redis-cli ping
# Should output: PONG
```

### Slow performance / high CPU usage

**Cause:** Docker resource constraints

**Solution:**
```bash
# Increase Docker memory allocation in Docker Desktop settings
# Or in docker-compose.yml:
services:
  postgres:
    deploy:
      resources:
        limits:
          memory: 2G

# Restart services
docker compose down
docker compose up -d
```

### "Too many open files" error

**Cause:** macOS/Linux file descriptor limit reached

**Solution:**
```bash
# Check current limit
ulimit -n

# Increase limit
ulimit -n 4096

# Make permanent (add to ~/.zshrc or ~/.bashrc)
echo "ulimit -n 4096" >> ~/.zshrc
```

---

## Full Reset Instructions

Use this when you want a completely clean slate:

```bash
# 1. Stop all services
docker compose down

# 2. Remove all volumes (DELETES ALL LOCAL DATA)
docker compose down -v

# 3. Clear npm cache (optional, for clean dependency install)
rm -rf node_modules package-lock.json
npm cache clean --force

# 4. Start fresh from Step 1 above
docker compose up -d
npm install
npm run migrate:latest
npm run db:seed
npm run dev
```

**Warning:** This deletes all local database data. Use only when necessary.

---

## Next Steps

Once setup is complete:

1. **Read the architecture guide:** See `/docs/ARCHITECTURE.md` for system overview
2. **Explore the API:** Visit http://localhost:3000/docs for API documentation
3. **Check the code:** Start in `/src/routes/` to see API endpoint implementations
4. **Run tests:** `npm test` to understand the testing setup
5. **Read contributing guide:** See `CONTRIBUTING.md` for development guidelines

---

## Getting Help

If you're stuck:

1. **Check logs:** `docker compose logs -f [service_name]`
2. **Run health check:** `npm run health:check`
3. **Ask in Slack:** #engineering-help channel
4. **File an issue:** Create issue in GitHub with:
   - Setup steps you followed
   - Error message (paste full output)
   - Your OS and Docker version
   - Steps to reproduce

---

## System Architecture Summary

[PROJECT] is a full-stack application with:

- **Frontend:** React (http://localhost:3000)
- **API:** Node.js + Express (http://localhost:3000/api/v1)
- **Database:** PostgreSQL (localhost:5432)
- **Cache:** Redis (localhost:6379)
- **Queue:** (Optional, configured in docker-compose.yml)

All services communicate via Docker network bridge and are accessible from your local machine.
