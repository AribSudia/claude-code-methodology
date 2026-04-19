---
argument-hint: "<migration-file>"
description: Check | Database migration safety review - risk classification, lock analysis, rollback verification
---

# /arib-check-migrate Command

## Purpose
Review database migrations for safety before execution. Classifies risk, detects dangerous operations, verifies rollback plan, and produces a migration safety report.

## Trigger
User types `/arib-check-migrate [target]`

Examples:
- `/arib-check-migrate` - Review all pending migrations
- `/arib-check-migrate 20260418_add_user_status` - Specific migration
- `/arib-check-migrate prisma/migrations/` - All Prisma migrations
- `/arib-check-migrate --all` - Comprehensive schema audit

## Instructions

### Step 1: Activate Database Guardian Agent
Read `.claude/agents/database-guardian.md` and follow the 8-step Migration Safety Protocol.

### Step 2: Detect Migration Framework
Identify which migration tool is used:
- Prisma (`prisma/migrations/`)
- Knex (`migrations/`)
- Sequelize (`migrations/` or `db/migrate/`)
- TypeORM (`src/migrations/`)
- Django (`*/migrations/`)
- Alembic (`alembic/versions/`)
- Entity Framework (`Migrations/`)
- Raw SQL files

### Step 3: Read Migration Files
Read all pending/target migration files. For each migration, extract:
- SQL operations (CREATE, ALTER, DROP, INSERT, UPDATE, DELETE)
- Affected tables and columns
- Whether a DOWN/rollback migration exists

### Step 4: Classify Risk
For each operation, classify as LOW / MEDIUM / HIGH / CRITICAL per the Database Guardian protocol.

### Step 5: Analyze Table Sizes
If connected to a database, check row counts for affected tables:
```sql
SELECT relname, n_live_tup FROM pg_stat_user_tables WHERE relname IN ('affected_tables');
```
If not connected, ask user for approximate table sizes.

### Step 6: Check for Dangerous Patterns
Scan for:
- DROP TABLE / DROP COLUMN (data loss)
- ALTER TYPE on large tables (lock + rewrite)
- CREATE INDEX without CONCURRENTLY (lock)
- NOT NULL without default on existing table (fails on existing rows)
- CASCADE operations (unintended deletions)
- Raw data manipulation (UPDATE/DELETE without WHERE)

### Step 7: Verify Rollback
Confirm:
- DOWN migration exists for every UP migration
- DOWN migration actually reverses the UP (not just empty)
- For irreversible operations (DROP), backup protocol is specified

### Step 8: Generate Report
Produce the Migration Safety Report with:
- Risk classification per operation
- Lock analysis with estimated duration
- Warnings for dangerous patterns
- Recommendations for safer alternatives
- Rollback plan verification
- Final verdict: APPROVED / APPROVED WITH CONDITIONS / BLOCKED

## Notes
- This command activates the Database Guardian agent
- For CRITICAL migrations, recommend running during low-traffic window
- Always recommend backup for HIGH/CRITICAL operations
- Never approve DROP operations without backup verification
- Check that application code doesn't reference dropped columns/tables
