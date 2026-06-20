---
name: arib-postgres
argument-hint: "[review <path> | index | tune]"
description: "Stack | PostgreSQL optimization & safety patterns — indexing, query plans, N+1, safe online migrations, connection pooling, JSONB, and Row-Level Security for multi-tenancy. Use when designing or reviewing Postgres-backed data access. Composes with database-guardian (migration safety) and performance (query budgets). Authored natively (MIT), not an ECC copy."
---

# /arib-postgres — PostgreSQL optimization & safety

A reference + checklist for Postgres-backed services. **Authored content** (the ECC
`postgres-patterns` graft was unsourceable here); composes with `database-guardian`
(migration safety verdicts) and `performance` (latency budgets). For a full pass,
dispatch them via `/arib-build`.

## 1. Indexing — the highest-leverage lever

- Index the columns in your `WHERE`, `JOIN`, and `ORDER BY` — but **measure with
  `EXPLAIN (ANALYZE, BUFFERS)`**, don't guess. A seq-scan on a hot path is the usual
  culprit; an unused index is dead write-cost.
- **Composite index column order matters**: most-selective / equality columns first, range
  last (`(tenant_id, created_at)` not the reverse).
- **Partial indexes** for skewed predicates (`WHERE deleted_at IS NULL`).
- Foreign keys are **not** auto-indexed in Postgres — index the FK column or joins crawl.
- Drop indexes that `pg_stat_user_indexes` shows unused; each one taxes every write.

## 2. Query plans & the N+1 trap

- Read `EXPLAIN ANALYZE`: watch for `Seq Scan` on large tables, `Nested Loop` over big
  row counts, and a planner row-estimate far from actual (stale stats → `ANALYZE`).
- **N+1**: one query per row in a loop. Fix with a `JOIN`, `IN (...)`, or a single
  set-based query. This is the #1 ORM-induced Postgres problem — audit every per-row query.
- Prefer set-based SQL over row-by-row procedural logic; let the planner work.
- Keyset/seek pagination (`WHERE id > $last`) over `OFFSET` for deep pages.

## 3. Safe online migrations (forward-only, lock-aware)

- **Lock awareness is the whole game** on a live DB: a naive `ALTER TABLE ... ADD COLUMN
  NOT NULL DEFAULT ...` or an un-`CONCURRENTLY` index build can take an `ACCESS EXCLUSIVE`
  lock and stall the app. Use `CREATE INDEX CONCURRENTLY`; add nullable column → backfill
  in batches → set `NOT NULL` with a validated check constraint.
- **Expand → migrate → contract** for breaking changes (add new, dual-write/backfill,
  switch reads, drop old) so a rollback is always available.
- Set a short `lock_timeout` / `statement_timeout` on migration sessions so a blocked
  DDL fails fast instead of pile-up.
- Migrations are forward-only and reversible. **Schema changes are a high-stakes class —
  route through `database-guardian` and hold the merge for a human (CONSTRAINTS #17).**

## 4. Connection pooling & concurrency

- App pools exhaust Postgres `max_connections` fast under load — front with **PgBouncer**
  (transaction pooling) for serverless / high fan-out; size the app pool deliberately.
- Transaction pooling breaks session-level features (prepared statements, `SET`, advisory
  locks held across statements) — know the mode before relying on them.
- Keep transactions **short**; never hold one open across an external HTTP call.

## 5. JSONB, and when NOT to use it

- JSONB is great for genuinely schemaless/variable attributes; index access paths with a
  **GIN index** (`jsonb_path_ops` for containment). It is **not** a substitute for columns
  you query and constrain — those want real typed columns with FKs and checks.

## 6. Multi-tenancy & Row-Level Security

- For shared-schema multi-tenancy, **Row-Level Security (RLS)** is the defense-in-depth
  layer: a policy on `tenant_id` enforced by the database, so an app-layer bug can't leak
  across tenants. Pair it with the app guard (`/arib-nestjs` §5) — belt and suspenders.
- Set the tenant via a session GUC (`SET LOCAL app.tenant_id`) inside the request
  transaction; the policy reads it. Verify the policy with a cross-tenant test.
- Tenant isolation is a high-stakes class — its changes hold merge for a human.

## 7. Integrity & reliability

- Constraints in the DB, not just the app: `NOT NULL`, `CHECK`, `UNIQUE`, FKs with the
  right `ON DELETE` (cascade vs restrict — a deliberate decision, audited by
  `database-guardian`).
- Make money exact: `NUMERIC`, never `float`. Store timestamps as `timestamptz` (UTC).
- Idempotency keys for at-least-once external calls; unique partial index enforces them.

## Output

For `review <path>`: per-section PASS / NEEDS-CHANGES → `io/ledger/postgres-review-<date>.md`.
For `index`/`tune`: the concrete DDL + the `EXPLAIN` before/after that justifies it (no
unverified index churn — show the plan).
