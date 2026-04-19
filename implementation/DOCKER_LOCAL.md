# Local Development Environment Guide

Complete setup and troubleshooting for [PROJECT] local Docker development environment.

## Services Configuration

| Service | Port | Credentials | Purpose |
|---------|------|-------------|---------|
| PostgreSQL | 5432 | user: `dev` / password: `devpass` / db: `[PROJECT]_dev` | Primary database |
| Redis | 6379 | No auth (localhost only) | Cache, sessions, queues |
| Application | 3000 | - | Node.js/API server |
| MailHog (optional) | 1025/8025 | No auth | Email capture & testing |
| Elasticsearch (optional) | 9200 | No auth | Full-text search & analytics |
| RabbitMQ (optional) | 5672/15672 | user: `guest` / password: `guest` | Message queue broker |

## First-Time Setup

### Prerequisites
- Docker Desktop 4.0+ or Docker Engine + Docker Compose 2.0+
- 4GB+ available memory (8GB recommended)
- 10GB+ free disk space
- Basic Unix shell knowledge

### Step 1: Start Docker Services

```bash
# From project root directory
docker compose up -d

# Verify all services are running
docker compose ps
```

Expected output shows all services as "healthy" or "running":
```
NAME                 COMMAND                  SERVICE      STATUS      PORTS
[project]-postgres   "docker-entrypoint..."   postgres     Up 2s       0.0.0.0:5432->5432/tcp
[project]-redis      "redis-server"           redis        Up 2s       0.0.0.0:6379->6379/tcp
[project]-app        "npm run dev"            app          Up 1s       0.0.0.0:3000->3000/tcp
```

### Step 2: Install Dependencies

```bash
npm install
# or
yarn install
```

### Step 3: Setup Environment Variables

Copy template and customize:
```bash
cp .env.example .env.local
```

Verify these settings match your docker-compose configuration:
```
DATABASE_URL=postgresql://dev:devpass@localhost:5432/[PROJECT]_dev
REDIS_URL=redis://localhost:6379
NODE_ENV=development
```

### Step 4: Run Database Migrations

```bash
npm run migrate:latest
# Verify migrations applied
npm run migrate:status
```

Expected output: All migration files marked as completed

### Step 5: Seed Database (Optional)

```bash
npm run db:seed
```

This populates the database with test data for development.

### Step 6: Start Application

```bash
npm run dev
```

Application should start on http://localhost:3000 with hot-reload enabled.

---

## Common Commands

### Starting & Stopping Services

```bash
# Start all services in background
docker compose up -d

# Stop all services (preserve data)
docker compose stop

# Stop and remove containers (preserve volumes/data)
docker compose down

# Stop and remove everything including volumes (CLEAN SLATE)
docker compose down -v

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f postgres
docker compose logs -f redis
docker compose logs -f app
```

### Database Operations

```bash
# Connect to PostgreSQL CLI
docker compose exec postgres psql -U dev -d [PROJECT]_dev

# Backup database
docker compose exec postgres pg_dump -U dev [PROJECT]_dev > backup.sql

# Restore database from backup
docker compose exec postgres psql -U dev [PROJECT]_dev < backup.sql

# List all tables
docker compose exec postgres psql -U dev -d [PROJECT]_dev -c "\dt"

# View specific table
docker compose exec postgres psql -U dev -d [PROJECT]_dev -c "SELECT * FROM users LIMIT 10;"
```

### Redis Operations

```bash
# Connect to Redis CLI
docker compose exec redis redis-cli

# Flush cache (CAUTION: removes all cached data)
docker compose exec redis redis-cli FLUSHALL

# Monitor real-time commands
docker compose exec redis redis-cli MONITOR

# Check memory usage
docker compose exec redis redis-cli INFO memory
```

### Rebuild Services

```bash
# Rebuild application container after Dockerfile changes
docker compose up --build -d app

# Rebuild specific service
docker compose up --build -d postgres

# Full rebuild (all services)
docker compose up --build -d
```

---

## Health Checks

Run these commands to verify all services are functioning correctly:

### PostgreSQL Health Check

```bash
docker compose exec postgres pg_isready -U dev -d [PROJECT]_dev
```

Expected output: `accepting connections`

### Redis Health Check

```bash
docker compose exec redis redis-cli ping
```

Expected output: `PONG`

### Application Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:45Z",
  "uptime_seconds": 234,
  "database": "connected",
  "cache": "connected"
}
```

### Full Stack Health Check

```bash
npm run health:check
```

This runs all health checks and provides a summary report.

---

## Troubleshooting

### Port Already in Use

**Error:** `Error response from daemon: Ports are not available: exposing port 5432: Address already in use`

**Solution:**
```bash
# Find process using port 5432
lsof -i :5432

# Kill process (macOS)
kill -9 <PID>

# Or change port in docker-compose.yml:
# Change: ports: - "5432:5432"
# To:     ports: - "5433:5432"
# Then update DATABASE_URL in .env.local
```

### Volume Mount Issues

**Error:** `Error: connect ENOENT /var/run/docker.sock`

**Solution:**
```bash
# Ensure Docker daemon is running
docker ps

# Reset volumes (WARNING: deletes all local data)
docker compose down -v
docker compose up -d

# Check volume status
docker volume ls | grep [PROJECT]
```

### Connection Refused

**Error:** `psql: error: connection to server at "localhost" (127.0.0.1), port 5432 failed`

**Solutions:**
```bash
# Verify PostgreSQL is running
docker compose ps postgres

# Check logs for errors
docker compose logs postgres

# Restart PostgreSQL
docker compose restart postgres

# Wait for container to be healthy (up to 30 seconds)
docker compose up postgres
# Then re-run migration in separate terminal
```

### Redis Connection Refused

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:6379`

**Solutions:**
```bash
# Verify Redis is running and healthy
docker compose ps redis

# Check Redis logs
docker compose logs redis

# Restart Redis service
docker compose restart redis

# Verify connectivity
docker compose exec app redis-cli ping
```

### Memory/Performance Issues

**Symptoms:** Docker slow, application crashes, OOM kills

**Solutions:**
```bash
# Allocate more memory in Docker Desktop settings
# Recommended: 4GB minimum, 8GB for development with extras

# Check current memory usage
docker stats

# Limit container memory (in docker-compose.yml)
services:
  postgres:
    deploy:
      resources:
        limits:
          memory: 1G

# Restart with fresh state
docker compose down -v
docker compose up -d
```

### Application Won't Start

**Error:** `npm ERR! code ENOENT` or `Cannot find module`

**Solutions:**
```bash
# Clear npm cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node version
node --version
# Expected: v18.x or v20.x

# View application logs
docker compose logs -f app

# Rebuild application container
docker compose up --build -d app
```

### Database Migration Failures

**Error:** `Migration failed: duplicate key` or similar

**Solutions:**
```bash
# Check migration status
npm run migrate:status

# Rollback last migration
npm run migrate:rollback

# View migration logs
cat logs/migrations.log

# Reset to clean state
docker compose exec postgres psql -U dev -d [PROJECT]_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
npm run migrate:latest
npm run db:seed
```

### Data Seeding Issues

**Error:** `Seed failed: violates foreign key constraint`

**Solution:**
```bash
# Ensure migrations ran successfully first
npm run migrate:status

# Reset and re-seed
docker compose exec postgres psql -U dev -d [PROJECT]_dev -c "DELETE FROM table_name CASCADE;"
npm run db:seed
```

---

## Data Seeding Instructions

### Seed Test Data

```bash
# Run all seed files (idempotent)
npm run db:seed

# Run specific seed file
npm run db:seed -- --file=users

# Seed with custom environment
NODE_ENV=test npm run db:seed
```

### Seed Files Location

Seed scripts are located in `/database/seeds/` directory:
- `01-users.ts` - Test user accounts
- `02-resources.ts` - Sample resources
- `03-relationships.ts` - Links between resources

### Create Test User

```bash
# Via npm script
npm run create:test-user

# Manually in PostgreSQL
docker compose exec postgres psql -U dev -d [PROJECT]_dev

INSERT INTO users (email, name, password_hash, role) 
VALUES ('dev@localhost', 'Dev User', '$2a$10$...', 'admin');

# Get user ID for API testing
SELECT id, email FROM users WHERE email = 'dev@localhost';
```

### Reset Database to Clean State

```bash
# Full reset (remove all data, re-run migrations, re-seed)
npm run db:reset

# Or manually:
docker compose down -v
docker compose up -d
npm run migrate:latest
npm run db:seed
```

---

## Development Workflow

### Hot Reload

Application automatically restarts when source files change (configured in `docker-compose.yml` with volume mount).

```bash
# Logs show "Reloading..." when file changes detected
docker compose logs -f app
```

### Database Changes During Development

When modifying database schema:

```bash
# Create new migration
npm run migrate:create -- --name=add_new_column

# Edit the migration file in `/database/migrations/`

# Test migration
npm run migrate:latest

# Rollback if needed
npm run migrate:rollback

# Commit once verified
git add database/migrations/
git commit -m "feat: add new column to users table"
```

### Testing with Curl

```bash
# Get authorization token
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@localhost","password":"password"}'

# Use token in subsequent requests
curl http://localhost:3000/api/v1/resources \
  -H "Authorization: Bearer {token}"
```

---

## Performance Optimization

### Docker Compose Performance Tips

```yaml
# In docker-compose.yml, reduce logging
services:
  postgres:
    environment:
      # Reduce verbose logging
      POSTGRES_INITDB_ARGS: "-q"
```

### Cache Optimization

```bash
# Monitor Redis memory
docker compose exec redis redis-cli INFO memory

# Clear cache if needed
docker compose exec redis redis-cli FLUSHDB
```

---

## Environment-Specific Notes

### macOS (Docker Desktop)
- Ensure "Use VirtioFS for container mounts" is enabled in Docker Desktop settings
- May need to increase memory allocation for better performance

### Windows (WSL2)
- Use WSL2 backend (not Hyper-V)
- File operations may be slower; consider using named volumes instead of bind mounts

### Linux
- Native Docker performance
- Ensure user is in docker group: `sudo usermod -aG docker $USER`
