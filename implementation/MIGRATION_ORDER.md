# Database Migration Order & Dependencies

Complete database schema dependency graph and migration strategy for [PROJECT].

## Migration Naming Convention

All migrations follow the pattern: `{timestamp}_{description}.sql` or `.ts`

**Format:** `YYYYMMDDHHMMSS_{kebab-case-description}`

**Examples:**
- `20240115093045_create_users_table.sql`
- `20240115093046_create_user_roles_enum.sql`
- `20240115093047_add_email_index_to_users.sql`
- `20240115093048_create_resources_table.sql`
- `20240115093049_add_fk_user_id_to_resources.sql`

**Guidelines:**
- Use timestamp from migration creation time
- Use kebab-case for description
- Describe the single change in the migration name
- Never reuse filenames

## Layer Concept

Migrations are organized into layers based on dependencies:

- **Layer 0:** No dependencies (can run in parallel)
- **Layer 1:** Depends on Layer 0
- **Layer 2:** Depends on Layer 1
- **Layer N:** Depends on Layer N-1

Each migration declares its dependencies, enabling safe parallel execution within layers.

## Migration Structure Template

```sql
-- Migration: {timestamp}_{description}
-- Layer: {layer_number}
-- Dependencies: {list of previous migration IDs or "none"}
-- Description: {detailed explanation}

-- ============================================================================
-- MIGRATION UP (forward)
-- ============================================================================

BEGIN;

-- Create table / Add column / Create index, etc.
CREATE TABLE schema.table_name (
  -- definition
);

-- Record migration completion (managed by framework)
COMMIT;

-- ============================================================================
-- MIGRATION DOWN (rollback)
-- ============================================================================

BEGIN;

-- Drop table / Remove column / Drop index, etc.
DROP TABLE IF EXISTS schema.table_name CASCADE;

COMMIT;
```

## Example 3-Layer Dependency Graph

### Layer 0: Foundation (No Dependencies)

These migrations can run in parallel. They establish basic types, enums, and core tables.

```
20240115093000_create_user_roles_enum.sql
├─ Creates enum: user_role (admin, user, guest)
├─ Layer: 0
└─ Dependencies: none

20240115093001_create_status_enum.sql
├─ Creates enum: status (active, inactive, archived)
├─ Layer: 0
└─ Dependencies: none

20240115093002_create_timestamps_trigger.sql
├─ Creates trigger function: update_timestamp()
├─ Layer: 0
└─ Dependencies: none

20240115093003_create_users_table.sql
├─ Creates table: users
│  ├─ id (uuid primary key)
│  ├─ email (unique, not null)
│  ├─ name (text)
│  ├─ role (user_role enum)
│  ├─ created_at (timestamp)
│  ├─ updated_at (timestamp)
├─ Creates index: idx_users_email
├─ Layer: 0
└─ Dependencies: none
```

### Layer 1: Relationships (Depends on Layer 0)

These migrations establish foreign keys and cross-table relationships.

```
20240115093100_create_resources_table.sql
├─ Creates table: resources
│  ├─ id (uuid primary key)
│  ├─ user_id (uuid, foreign key → users.id)
│  ├─ title (text)
│  ├─ status (status enum)
│  ├─ created_at (timestamp)
│  ├─ updated_at (timestamp)
├─ Creates index: idx_resources_user_id
├─ Creates index: idx_resources_status
├─ Layer: 1
└─ Dependencies: 20240115093000_create_user_roles_enum, 20240115093001_create_status_enum, 20240115093003_create_users_table

20240115093101_create_tags_table.sql
├─ Creates table: tags
│  ├─ id (uuid primary key)
│  ├─ name (text unique)
│  ├─ created_at (timestamp)
├─ Creates index: idx_tags_name
├─ Layer: 1
└─ Dependencies: none (no external references)

20240115093102_create_resource_tags_junction.sql
├─ Creates table: resource_tags (junction table)
│  ├─ resource_id (uuid, foreign key → resources.id)
│  ├─ tag_id (uuid, foreign key → tags.id)
│  ├─ PRIMARY KEY (resource_id, tag_id)
├─ Creates index: idx_resource_tags_tag_id (for reverse lookup)
├─ Layer: 1
└─ Dependencies: 20240115093100_create_resources_table, 20240115093101_create_tags_table
```

### Layer 2: Refinement (Depends on Layer 1)

These migrations add constraints, indexes, and refinements after relationships are established.

```
20240115093200_add_resource_constraints.sql
├─ Adds constraint: resources.status must not be NULL
├─ Adds constraint: resources.title must not be NULL
├─ Adds constraint: resources.title length >= 1
├─ Layer: 2
└─ Dependencies: 20240115093100_create_resources_table

20240115093201_add_audit_columns.sql
├─ Adds column: resources.created_by (uuid, foreign key → users.id)
├─ Adds column: resources.updated_by (uuid, nullable)
├─ Adds column: resources.change_reason (text, nullable)
├─ Creates index: idx_resources_created_by
├─ Layer: 2
└─ Dependencies: 20240115093100_create_resources_table, 20240115093003_create_users_table

20240115093202_add_performance_indexes.sql
├─ Creates index: idx_resources_user_status (composite)
├─ Creates index: idx_resources_created_at (for time-range queries)
├─ Creates partial index: idx_archived_resources (WHERE status = 'archived')
├─ Layer: 2
└─ Dependencies: 20240115093100_create_resources_table
```

## Dependency Visualization

```
Layer 0 (Foundation - No Dependencies)
├── create_user_roles_enum
├── create_status_enum
├── create_timestamps_trigger
└── create_users_table

        ↓ (All depend on Layer 0)

Layer 1 (Relationships - Depends on Layer 0)
├── create_resources_table
├── create_tags_table
└── create_resource_tags_junction

        ↓ (All depend on Layer 0 & 1)

Layer 2 (Refinement - Depends on Layer 1)
├── add_resource_constraints
├── add_audit_columns
└── add_performance_indexes
```

## Migration Execution Order

### Development Environment

```bash
# Run all pending migrations in dependency order
npm run migrate:latest

# View current schema version
npm run migrate:status

# Expected output:
# ✓ 20240115093000_create_user_roles_enum.sql
# ✓ 20240115093001_create_status_enum.sql
# ✓ 20240115093002_create_timestamps_trigger.sql
# ✓ 20240115093003_create_users_table.sql
# ✓ 20240115093100_create_resources_table.sql
# ✓ 20240115093101_create_tags_table.sql
# ✓ 20240115093102_create_resource_tags_junction.sql
# ✓ 20240115093200_add_resource_constraints.sql
# ✓ 20240115093201_add_audit_columns.sql
# ✓ 20240115093202_add_performance_indexes.sql
```

### Production Deployment

Migrations run automatically as part of pre-deployment verification:

```bash
# Verify migrations would apply without errors
npm run migrate:dry-run --env=production

# Apply migrations with rollback capability
npm run migrate:up --env=production

# If critical error, rollback to previous version
npm run migrate:rollback --count=3 --env=production
```

## Cross-Service Boundary Rules

For microservices architectures, each service owns its own database schema.

### Cross-Service Foreign Keys (PROHIBITED)

```sql
-- ❌ DON'T: Foreign key to another service's table
ALTER TABLE orders ADD CONSTRAINT fk_payment_id
  FOREIGN KEY (payment_id) REFERENCES payment_service.payments(id);
```

### Cross-Service References (ALLOWED)

```sql
-- ✓ OK: Store ID as reference, not foreign key
ALTER TABLE orders ADD COLUMN payment_id UUID NOT NULL;
-- Payment ID from payment_service, not enforced at DB level

-- ✓ OK: Service-to-service API call to validate
-- In application code:
const payment = await paymentService.getPayment(paymentId);
if (!payment) throw new Error('Payment not found');
```

### Shared Types (OPTIONAL)

For frequently shared enums/types, use shared seed data:

```sql
-- Create enum in both services' databases
CREATE TYPE order_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- Document shared enum in both services
-- sync_frequency: Never (immutable after creation)
-- ownership: Shared (agreed upon by order-service and payment-service)
```

## Rollback Strategy

### Forward-Compatible Rollback

Ensure every migration can be safely rolled back without data loss:

```sql
-- ✓ Good: Can rollback without data loss
-- Migration: 20240115093047_add_email_index_to_users.sql
BEGIN;
CREATE INDEX idx_users_email ON users(email);
COMMIT;

-- Rollback: Drop index (no data lost)
-- Migration down:
DROP INDEX IF EXISTS idx_users_email;
```

### Backward-Incompatible Changes

For breaking changes, use a multi-step approach:

```sql
-- Step 1: Add new column, keep old column (make both nullable)
-- Migration: 20240115093050_add_phone_v2_column.sql
ALTER TABLE users ADD COLUMN phone_v2 VARCHAR(20);

-- Step 2: (Later) Migrate data from old to new column
-- Migration: 20240115093051_migrate_phone_data.sql
UPDATE users SET phone_v2 = phone WHERE phone IS NOT NULL;

-- Step 3: (Even later) Remove old column
-- Migration: 20240115093052_drop_phone_v1_column.sql
ALTER TABLE users DROP COLUMN phone;
```

### Rollback Verification

```bash
# Rollback N migrations and verify data integrity
npm run migrate:rollback --count=5 --env=development
npm run verify:data-integrity

# If verification passes, rollback is safe
# If verification fails, investigate before rolling back to production
```

## Atomic Migrations

Every migration must be atomic: either fully succeeds or fully fails with no partial state.

```sql
-- ✓ Good: All changes wrapped in transaction
BEGIN;
  CREATE TABLE resources (...);
  CREATE INDEX idx_resources_user_id (...);
  INSERT INTO migration_log VALUES (...);
COMMIT;

-- ❌ Bad: Implicit transaction, potential partial state
CREATE TABLE resources (...);
CREATE INDEX idx_resources_user_id (...);
-- If index creation fails, table exists but index doesn't
```

## Migration Testing

```bash
# Test migration in isolation on fresh database
npm run test:migrate -- --migration=20240115093100_create_resources_table

# Test rollback on fresh database
npm run test:migrate:rollback -- --migration=20240115093100_create_resources_table

# Test entire migration sequence
npm run test:migrate:full

# Load test database, verify performance
npm run test:migrate:performance -- --rows=1000000
```

## [PROJECT] Migrations

Document your project-specific migration order below:

### Layer 0: Foundation Migrations

```
(List Layer 0 migrations with dependencies: none)
```

### Layer 1: Relationship Migrations

```
(List Layer 1 migrations with Layer 0 dependencies)
```

### Layer 2: Refinement Migrations

```
(List Layer 2 migrations with Layer 1 dependencies)
```

### Layer 3+: Additional Layers

```
(Add additional layers as needed)
```

## Migration Checklist

Before committing migrations:

- [ ] Migration is atomic (wrapped in single transaction)
- [ ] Migration has reversible `DOWN` statement
- [ ] Naming follows convention: `YYYYMMDDHHMMSS_{kebab-case}`
- [ ] Dependencies are explicitly documented
- [ ] Foreign keys reference correct layer (not forward references)
- [ ] Indexes created for foreign keys and frequent filters
- [ ] Nullable columns justified (default values provided if not nullable)
- [ ] Constraint names are descriptive: `ck_`, `fk_`, `uq_` prefixes
- [ ] Migration tested in development locally
- [ ] Migration rollback tested successfully
- [ ] No passwords or sensitive data in migration
- [ ] Performance impact documented (large table alterations)

## Performance Considerations

### Large Table Operations

For tables with millions of rows, consider impact:

```sql
-- ❌ Slow: Full table lock, may timeout on large tables
ALTER TABLE users ADD COLUMN new_field TEXT;

-- ✓ Better: Add column as nullable first
ALTER TABLE users ADD COLUMN new_field TEXT;

-- Then backfill in batches (application code)
-- Then add NOT NULL constraint if needed
ALTER TABLE users ALTER COLUMN new_field SET NOT NULL;
```

### Index Creation on Existing Data

```sql
-- On large tables, use CONCURRENTLY to avoid blocking writes
CREATE INDEX CONCURRENTLY idx_users_created_at ON users(created_at);

-- Without CONCURRENTLY, may lock table for extended period
-- Not supported in transactions, so must run alone
```
