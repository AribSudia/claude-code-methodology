---
name: arib-nestjs
argument-hint: "[module|feature|review <path>]"
description: "Stack | NestJS architecture & patterns reference — modules/providers/DI, DTO+validation, guards/interceptors/pipes/filters, config, async lifecycle, testing, and the security + performance pitfalls that bite at scale. Use when building or reviewing a NestJS backend. Composes with security-auditor (OWASP), database-guardian (TypeORM/Prisma migrations), and performance (N+1). Authored natively (the ECC graft was unsourceable; this is CCM's own, MIT)."
---

# /arib-nestjs — NestJS architecture & patterns

A reference + checklist for building and reviewing NestJS backends the way CCM
expects: typed, layered, testable, and secure by construction. This is **authored
content**, not a copied dependency — the developer plan proposed grafting ECC's
`nestjs-patterns`, but that repo isn't available here, so CCM ships its own honest
version. (If you later want the actual ECC asset, see "Intelligent graft" at the end.)

> Composes with: `security-auditor` (authz/OWASP on controllers + guards),
> `database-guardian` (migration safety), `performance` (N+1 / over-fetch),
> `test-engineer` (the testing section). Dispatch them via `/arib-build` for a full pass.

## When to use

- `/arib-nestjs module` — scaffold a clean feature module (controller/service/DTO/spec).
- `/arib-nestjs feature` — design a vertical slice end-to-end with the checklist below.
- `/arib-nestjs review <path>` — audit an existing module against the pitfalls list.

## 1. Module & dependency-injection discipline

- **One feature = one module.** `FooModule` owns its controller, service(s), and entities;
  it `exports` only what siblings legitimately need. No god-modules.
- **Provider scope is a decision, not a default.** Default (singleton) is right almost
  always. `Scope.REQUEST` is occasionally needed (per-request context) but is **viral and
  slow** — it forces every consumer request-scoped. Justify it or avoid it.
- **Inject by interface/token** for anything with more than one implementation or an
  external boundary (`@Inject('PAYMENTS')`), so it's swappable in tests.
- **No business logic in controllers.** Controllers map HTTP ⇄ DTO ⇄ service call.
  Services hold logic; repositories/data-mappers hold persistence.
- **Avoid circular module deps.** If `forwardRef()` appears, treat it as a design smell —
  usually a shared concern wants its own module.

## 2. Validation & DTOs (the input boundary)

- Every request body/query/param is a **class DTO** with `class-validator` decorators;
  enable a **global `ValidationPipe({ whitelist: true, forbidNonWhitelisted: true,
  transform: true })`** so unknown fields are stripped/rejected and types are coerced.
  `whitelist` is a real security control (mass-assignment defense), not cosmetics.
- Never accept an entity as a request type. DTO in, entity internal, **response DTO out**
  (or `@Exclude()` sensitive fields via `ClassSerializerInterceptor`) — so password hashes
  / internal columns never serialize to the client.
- Validate enums and bounds explicitly (`@IsEnum`, `@Min/@Max`, `@MaxLength`).

## 3. Cross-cutting: guards · interceptors · pipes · filters (use the right one)

- **Guard** → *can this request proceed?* (authn/authz, roles, tenant check). Authorization
  lives here, never inside the service as an afterthought.
- **Pipe** → *transform/validate input* (ValidationPipe, ParseUUIDPipe).
- **Interceptor** → *wrap the call* (logging, caching, response shaping, timeouts).
- **Exception filter** → *map errors to HTTP* — one global filter so you never leak stack
  traces or ORM errors to clients; map domain errors → typed HTTP codes.
- Order matters: middleware → guards → interceptors(pre) → pipes → handler →
  interceptors(post) → filters. Know it before debugging "why didn't my guard run?".

## 4. Config, async, and lifecycle

- **`ConfigModule` + a validated schema** (Joi/zod) at boot — fail fast on a missing env
  var, never read `process.env` scattered through services.
- **Never block the event loop.** CPU-heavy work → a worker/queue (BullMQ), not inline.
- Use `onModuleInit` / `onApplicationShutdown` for warmup/cleanup; enable
  `app.enableShutdownHooks()` so SIGTERM drains in-flight requests (graceful deploys).
- Async providers (`useFactory` + `inject`) for anything needing a connection at boot.

## 5. Data access at scale (where NestJS apps actually fall over)

- **N+1 is the #1 perf bug.** Eager-load relations you'll use (`relations: []` / query
  builder joins / Prisma `include`), or batch with DataLoader. Audit every `.find()` in a
  loop. (Hand off to `performance`.)
- **Migrations are forward-only + reversible** — never `synchronize: true` against a real
  database. Route schema changes through `database-guardian`.
- **Multi-tenancy:** enforce the tenant boundary in a guard AND at the query layer (a
  `tenantId` filter or Postgres RLS — see `/arib-postgres`); never trust the client's
  tenant id. This is a high-stakes class — CONSTRAINTS #17 holds its merge for a human.
- Wrap multi-write operations in a transaction; make external side-effects idempotent.

## 6. Testing

- **Unit-test services** with mocked providers (`Test.createTestingModule` + `useValue`).
  New behavior ships with a genuine regression test (CCM rule), never coverage padding.
- **e2e the controller** through the real pipe/guard stack (`supertest`) so validation and
  authz are exercised, not bypassed.
- Test the **failure paths** (403/422/409), not just the happy 200.

## 7. Security pitfalls (the ones that bite)

- Missing global `ValidationPipe whitelist` → mass-assignment.
- Authorization in the service instead of a guard → inconsistent enforcement / IDOR.
- Returning the entity → leaking `passwordHash`, internal flags, other tenants' columns.
- `synchronize: true` in prod → silent destructive schema drift.
- Stack traces in error responses → info disclosure (global exception filter fixes it).
- Secrets read from `process.env` un-validated → boot-time misconfig in prod.
(For a full pass, dispatch `security-auditor`; for queries, `/arib-postgres`.)

## Output

For `review <path>`: a findings list (PASS / NEEDS-CHANGES per section above) →
`io/ledger/nestjs-review-<date>.md` (standard CCM audit format). For `module`/`feature`:
the scaffolded files + a one-line note on which guards/DTOs/tests were generated.

## Intelligent graft (optional, opt-in)

This skill is self-contained. If you later obtain the ECC `nestjs-patterns` asset (verify
its MIT license first), you may *enrich* — not replace — this skill by appending its
pattern snippets under a clearly-attributed `## ECC patterns (grafted)` heading. Do not
add a runtime dependency on ECC; CCM stays the operating system (ADR-029 doctrine).
