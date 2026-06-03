---
name: arib-check-migrate
argument-hint: "<migration-file>"
description: Check | Database migration safety review - risk classification, lock analysis, rollback verification
---

# /arib-check-migrate Command

## Overview

Database migrations are the #1 cause of production outages. A single badly-written migration can lock an entire table (100M rows = hours of downtime), corrupt data, or become irreversible.

This skill classifies migration risk before execution, calculates lock duration, detects dangerous patterns, and verifies rollback procedures. It acts as a safety gate: migrations are APPROVED, APPROVED WITH CONDITIONS, or BLOCKED.

Key decisions:
- **Table size matters**: 1K row ALTER is instant; 100M row ALTER locks for minutes
- **Lock-free patterns exist**: Use ADD COLUMN, deprecate OLD, DROP - not direct modification
- **Rollback must work**: Every UP migration needs a working DOWN
- **Test on staging**: Exact table size replica, measure lock duration

## Purpose
Review database migrations for safety before execution. Classifies risk, detects dangerous operations, verifies rollback plan, and produces a migration safety report.

## When to Use

- **Before deployment**: EVERY migration must pass this check before going to prod
- **During peak hours**: Never deploy migrations during high-traffic windows (use maintenance window)
- **After data changes**: Any schema change affecting prod data requires safety review
- **Quarterly**: Audit entire migration history for orphaned/unsafe patterns

## Trigger
User types `/arib-check-migrate [target]`

Examples:
- `/arib-check-migrate` - Review all pending migrations
- `/arib-check-migrate 20260418_add_user_status` - Specific migration
- `/arib-check-migrate prisma/migrations/` - All Prisma migrations
- `/arib-check-migrate --all` - Comprehensive schema audit

## Dangerous SQL Pattern Reference

### Pattern 1: ALTER COLUMN TYPE (Rewrites Table)

**Bad (locks table for minutes/hours):**
```sql
ALTER TABLE users ALTER COLUMN age TYPE VARCHAR(3);
```
For 100M rows, this blocks read/write for 30+ minutes.

**Good (instant):**
```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN age_str VARCHAR(3);
-- Step 2: Copy data (in batches if large)
UPDATE users SET age_str = age::text;
-- Step 3: Application uses both columns
-- Step 4: After verification, drop old column
ALTER TABLE users DROP COLUMN age;
```

### Pattern 2: CREATE INDEX Without CONCURRENTLY

**Bad (locks table):**
```sql
CREATE INDEX idx_users_email ON users(email);
```
Blocks writes while building index.

**Good (concurrent, no locks):**
```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
-- Takes longer but table remains writable
```

### Pattern 3: ADD NOT NULL Without Default

**Bad (fails if rows exist):**
```sql
ALTER TABLE users ADD COLUMN is_verified BOOLEAN NOT NULL;
-- ERROR: column "is_verified" contains nulls
```

**Good (safe):**
```sql
-- Step 1: Add column with default
ALTER TABLE users ADD COLUMN is_verified BOOLEAN NOT NULL DEFAULT false;
-- Step 2: Update any existing rows if needed
-- Step 3: Remove default if application handles it
ALTER TABLE users ALTER COLUMN is_verified DROP DEFAULT;
```

### Pattern 4: DROP TABLE/COLUMN (Data Loss)

**Bad (irreversible):**
```sql
DROP TABLE legacy_users;  -- If only backup is 3 days old, you've lost recent data
```

**Good (safe):**
```sql
-- Step 1: Rename, don't drop
ALTER TABLE legacy_users RENAME TO legacy_users_backup_20260419;
-- Step 2: Monitor for 1 week
-- Step 3: Only then drop
DROP TABLE legacy_users_backup_20260419;
```

### Pattern 5: UPDATE Without WHERE

**Bad (corrupts data):**
```sql
UPDATE users SET status = 'active';  -- Sets ALL users to active!
```

**Good (safe):**
```sql
UPDATE users SET status = 'active' WHERE status IS NULL;
-- Affected rows: 1,234 (visible before committing)
```

### Pattern 6: Foreign Key CASCADE Delete

**Bad (unintended deletions):**
```sql
ALTER TABLE orders ADD CONSTRAINT fk_users
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE;  -- Deletes all orders when user is deleted!
```

**Good (explicit):**
```sql
ALTER TABLE orders ADD CONSTRAINT fk_users
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE RESTRICT;  -- Prevents deletion if orders exist
-- Application handles cleanup explicitly
```

## Lock Duration Estimation

**Table Size × Operation = Lock Duration**

```
Operation | 1K Rows | 100K Rows | 10M Rows | 100M Rows
-----------|---------|-----------|----------|----------
ADD COLUMN (default) | < 1ms | < 1ms | < 1ms | < 1ms ✓
CREATE INDEX | 10ms | 100ms | 5s | 2min
ALTER TYPE | 100ms | 1s | 1min | 30min
DROP INDEX | < 1ms | < 1ms | 100ms | 1s
DELETE (all) | 10ms | 100ms | 10s | 2min
UPDATE (all) | 20ms | 200ms | 20s | 5min
CREATE UNIQUE INDEX | 50ms | 500ms | 20s | 10min
VACUUM FULL | 1s | 5s | 5min | 1hour
```

**Test procedure:**
1. Get exact row count: `SELECT COUNT(*) FROM table_name`
2. Run migration on staging with same data size
3. Measure lock duration: `SELECT * FROM pg_stat_activity`
4. If > 5 minutes: Use lock-free pattern instead

## Migration Testing Protocol

**Before running migration on production:**

```bash
# Step 1: Run on exact staging replica
pg_dump prod_database | psql staging_database
psql staging_database < migration.sql
# Step 2: Measure performance
\timing on
SELECT COUNT(*) FROM affected_table;  # Verify no corruption
# Step 3: Verify application still works
npm test -- --integration-db staging
# Step 4: Test rollback
psql staging_database < rollback.sql
SELECT COUNT(*) FROM affected_table;  # Same count as original?
```

## Migration Approval Examples

### APPROVED - Safe to Deploy

```markdown
## Migration: 20260419_add_user_preferences

### Risk Assessment: LOW

**Operations:**
1. ADD COLUMN user_preferences JSONB DEFAULT '{}' - Lock: < 1ms
2. CREATE INDEX CONCURRENTLY idx_user_pref - Lock: 0 (concurrent)

**Affected Table:** users (42.3M rows)
- Lock duration: < 1 second
- No data loss risk
- Backwards compatible

**Rollback:** DOWN migration tested and works
- Removes column cleanly
- Tested on staging with identical data size

**Verdict:** APPROVED - Safe to deploy during business hours
**Deployment:** Run during normal traffic, no maintenance window needed
**Monitoring:** Watch database connections for 5 minutes post-deploy
```

### APPROVED WITH CONDITIONS

```markdown
## Migration: 20260419_alter_order_amount_type

### Risk Assessment: HIGH

**Operations:**
1. ALTER TABLE orders ALTER COLUMN amount TYPE NUMERIC(12,2)
   - Current type: VARCHAR(255)
   - Table size: 87.1M rows
   - Estimated lock: 12-18 minutes
   - Data rewrite: Yes

**Conditions for Approval:**
1. REQUIRED: Deploy during maintenance window (2am-4am PT)
2. REQUIRED: Team on-call with direct DB access
3. REQUIRED: Full backup taken and verified
4. REQUIRED: Application tested with new type in staging
5. REQUIRED: Rollback plan documented and tested

**Lock Analysis:**
- 87.1M rows × ALTER TYPE = 15-minute lock
- Users will see: "Database maintenance, back in 20 minutes"
- Status page: Announced 48h in advance
- Support team: Briefed on expected downtime

**Rollback:** Available - uses old table rename trick
- Rename orders to orders_new
- Restore from backup
- Max data loss: 15 minutes

**Verdict:** APPROVED WITH CONDITIONS
**Deployment Time:** 2026-04-20 2:00 AM PT (maintenance window)
**Estimated Duration:** 25 minutes (15 min migration + 10 min verification)
```

### BLOCKED - Do Not Deploy

```markdown
## Migration: 20260419_drop_legacy_users_table

### Risk Assessment: CRITICAL - BLOCKED

**Blocking Issues:**

1. IRREVERSIBLE OPERATION
   - DROP TABLE legacy_users has no down migration
   - If data corruption discovered post-deploy, cannot recover
   - Only backup is 48 hours old (data loss risk)

2. INSUFFICIENT BACKUP VERIFICATION
   - Backup not tested for restore
   - No verification that backup is complete
   - No documented recovery time

3. MISSING IMPACT ANALYSIS
   - No check for foreign key references
   - No verification that no application code reads this table
   - 2.1M rows of data with unknown lineage

4. NO MIGRATION DOWN PATH
   - Cannot rollback if needed
   - Migration assumes data not needed - not verified

**Required Fixes:**

1. FIX: Create backup and verify restore works (30 min)
   - Run: `pg_dump prod_database | pg_restore test_restore`
   - Verify: Same row counts in both databases

2. FIX: Add safe DOWN migration (15 min)
   - Instead of DROP: RENAME table to legacy_users_archive_20260419
   - Only DROP after 1 month of monitoring
   - Document rollback procedure

3. FIX: Verify no code references this table (30 min)
   - grep -r "legacy_users" src/
   - Check all migrations for foreign keys
   - Check all application queries

4. FIX: Document why table can be dropped (15 min)
   - Who uses it? Nobody
   - When can we drop it? After monitoring period
   - What happens if we rollback? [Procedure]

**Decision:** BLOCKED - Rewrite migration using safe pattern
**Timeline:** Fix by 2026-04-21, re-submit for review
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No DOWN migration | Can't rollback | Every UP needs matching DOWN |
| ALTER TYPE directly | Table locked 30 min | Use ADD → COPY → DROP pattern |
| ADD NOT NULL no default | Fails if rows exist | Add default, then alter if needed |
| DROP without backup | Data loss is permanent | Always backup, verify restore |
| CREATE INDEX not CONCURRENTLY | Table locked during index build | Add CONCURRENTLY for production |
| No pre-check for locks | Surprised by long lock time | Test on staging first |
| UPDATE without WHERE | Corrupts all rows | Test migration query on copy first |
| Foreign key CASCADE delete | Unintended deletions | Use RESTRICT, handle in app |
| Deploying during peak hours | More downtime, more users affected | Always use maintenance window for locks |
| No application testing | Code breaks after schema change | Test new schema against application |

## Related Skills

- **arib-check-deploy**: Run migration check before each deployment
- **arib-check-a11y**: Verify schema changes don't break accessibility features
- **database-guardian-agent**: Deeper schema analysis and optimization

## Notes
- This command activates the Database Guardian agent
- For CRITICAL migrations, recommend running during low-traffic window
- Always recommend backup for HIGH/CRITICAL operations
- Never approve DROP operations without backup verification
- Check that application code doesn't reference dropped columns/tables
- Test migrations on exact staging replica before production
- Lock time on large tables can cause cascading failures - plan maintenance windows

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
