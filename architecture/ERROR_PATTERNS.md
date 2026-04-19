# ERROR_PATTERNS — Known Pitfalls and Prevention Database for [PROJECT]

This document catalogs common errors found in [PROJECT], their symptoms, root causes, prevention strategies, and fix templates. Use this as a reference when debugging or designing new features.

---

## Pattern 1: N+1 Queries

### Symptoms
- API endpoint is slow even with small dataset.
- Database shows 100+ queries for a single request.
- Response time increases linearly with number of results (O(n) instead of O(1)).
- High CPU and memory usage on database server.

### Root Cause
Fetching parent object, then looping over results to fetch child objects one-by-one. Each parent triggers a separate query.

### Example (Bad)
```typescript
// This makes 1 + N queries
const users = await userRepository.getAll(); // 1 query
for (const user of users) {
  user.orders = await orderRepository.getByUserId(user.id); // N queries
}
```

### Prevention
- **Use JOIN:** Fetch parent + children in one query.
- **Use ORM eager loading:** `.include()`, `.populate()`, `.join()`.
- **Use batch fetch:** Fetch all needed IDs, then query once with WHERE IN.
- **Add query profiling:** Log query counts per request.
- **Code review:** Reviewer should spot loops with nested queries.

### Fix Template (Repository Layer)
```typescript
// Good: Use JOIN
async getUsersWithOrders() {
  return db.query(`
    SELECT u.*, o.*
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
  `);
}

// Or ORM approach
async getUsersWithOrders() {
  return User.find().include('orders').fetch();
}

// Or batch fetch
async getUsersWithOrders() {
  const users = await User.find();
  const userIds = users.map(u => u.id);
  const ordersByUserId = await this.getOrdersByUserIds(userIds);
  users.forEach(u => {
    u.orders = ordersByUserId[u.id] || [];
  });
  return users;
}
```

---

## Pattern 2: Connection Pool Exhaustion

### Symptoms
- Requests timeout or hang randomly.
- Error: "no more connections available" or "connection pool full".
- Some users can access the app, others get 503 Service Unavailable.
- Database connections stay open (netstat shows many ESTABLISHED connections).

### Root Cause
- Not releasing database connections after queries.
- Connection timeout too high, lingering connections.
- Concurrent requests exceed pool size.
- Connections leak on error (exceptions not caught).

### Example (Bad)
```typescript
// Connection never released
const connection = await pool.getConnection();
const rows = await connection.query('SELECT * FROM users');
// Missing: connection.release() or await connection.end()
```

### Prevention
- **Use connection pooling library** with auto-release (most ORMs do this).
- **Set reasonable pool size** (default 10, max 100 for high concurrency).
- **Set connection timeout** (30s max).
- **Monitor pool utilization:** Alert if > 80% of connections in use.
- **Always release:** Use try-finally or async context managers.
- **Test with load:** Simulate 1000 concurrent users.

### Fix Template
```typescript
// Good: Use connection pool with automatic release
const rows = await pool.query('SELECT * FROM users');
// Connection auto-released after query

// Or explicit try-finally
const connection = await pool.getConnection();
try {
  const rows = await connection.query('SELECT * FROM users');
} finally {
  connection.release();
}

// Configure pool size in config
const pool = new Pool({
  max: 20, // max concurrent connections
  idleTimeoutMillis: 30000, // close idle connections after 30s
  connectionTimeoutMillis: 2000, // fail if can't get connection in 2s
});
```

### Monitoring
```typescript
// Log pool stats periodically
setInterval(() => {
  console.log(`Pool: ${pool.totalCount} total, ${pool.idleCount} idle, ${pool.activeCount} active`);
}, 30000);
```

---

## Pattern 3: Race Conditions

### Symptoms
- Intermittent bugs that are hard to reproduce.
- Data corruption (amounts off by 1, duplicate records).
- "Lost update" problem (concurrent updates, last one wins).
- Inventory goes negative or exceeds stock.

### Root Cause
Multiple concurrent requests access same resource without synchronization. Last write wins, intermediate updates are lost.

### Example (Bad)
```typescript
// Two concurrent requests both read balance = 100
const balance = await getBalance(userId); // both get 100
await updateBalance(userId, balance - 50); // both subtract, result = 50
// Expected: 0, Actual: 50 (one update lost)
```

### Prevention
- **Use transactions:** Wrap read-modify-write in a transaction (ACID).
- **Use locks:** Pessimistic (row lock) or optimistic (version column).
- **Use atomic operations:** Database-level operations (UPDATE, INCREMENT).
- **Avoid fetch-then-update:** Do it in one SQL query.
- **Test concurrency:** Use tools like `ab` (Apache Bench) to simulate concurrent requests.

### Fix Template (Pessimistic Locking)
```typescript
// BEGIN TRANSACTION
const balance = await db.query('SELECT balance FROM accounts WHERE id = ? FOR UPDATE', [userId]);
// ... calculate new balance ...
await db.query('UPDATE accounts SET balance = ? WHERE id = ?', [newBalance, userId]);
// COMMIT
```

### Fix Template (Optimistic Locking)
```typescript
// Add version column to table
// SELECT balance, version FROM accounts WHERE id = ?
// UPDATE accounts SET balance = ?, version = version + 1 WHERE id = ? AND version = ?
// If no rows updated, retry

async transferMoney(fromId, toId, amount) {
  for (let attempt = 0; attempt < 3; attempt++) {
    const { balance, version } = await getAccount(fromId);
    if (balance < amount) throw new Error('Insufficient funds');
    
    const updated = await db.query(
      `UPDATE accounts SET balance = balance - ?, version = version + 1 
       WHERE id = ? AND version = ?`,
      [amount, fromId, version]
    );
    
    if (updated.rowsAffected > 0) return; // Success
    // else retry
  }
  throw new Error('Failed to transfer after 3 attempts');
}
```

### Fix Template (Atomic Operation)
```typescript
// Best: Single atomic SQL operation
await db.query(
  'UPDATE accounts SET balance = balance - ? WHERE id = ? AND balance >= ?',
  [amount, userId, amount]
);
// If rowsAffected = 0, balance was insufficient (atomically checked)
```

---

## Pattern 4: Circular Dependencies

### Symptoms
- Module import fails with "Circular dependency detected".
- Linter warns about cyclic imports.
- Code is confusing and hard to refactor.
- Tests are brittle (order-dependent).

### Root Cause
Module A imports B, B imports C, C imports A. Forms a cycle.

### Example (Bad)
```typescript
// user.ts
import { Order } from './order';
export class User { orders: Order[] }

// order.ts
import { User } from './user';
export class Order { user: User }

// results in circular dependency
```

### Prevention
- **Use interfaces:** Export interfaces, not implementations.
- **Extract common types:** Shared types in separate module.
- **One-way dependencies:** A → B → C (no backward edges).
- **Avoid sibling imports:** If A and B are siblings, don't have them import each other.
- **Use dependency injection:** Pass dependencies, don't import them.
- **Lint:** `npm run madge --detect-cycles` finds cycles automatically.

### Fix Template (Interfaces)
```typescript
// types.ts (no imports)
export interface IUser { id: string; name: string }
export interface IOrder { id: string; userId: string }

// user.ts (only imports types)
import { IUser, IOrder } from './types';
export class User implements IUser { ... }

// order.ts (only imports types)
import { IOrder, IUser } from './types';
export class Order implements IOrder { ... }
```

### Fix Template (Dependency Injection)
```typescript
// Before (circular)
class UserService {
  orderService = new OrderService();
}
class OrderService {
  userService = new UserService();
}

// After (injected)
class UserService {
  constructor(private orderService: OrderService) {}
}
class OrderService {
  constructor(private userService: UserService) {}
}

// Create in container
const userService = new UserService(orderService);
const orderService = new OrderService(userService);
```

---

## Pattern 5: Memory Leaks

### Symptoms
- Application memory usage increases over time (never decreases).
- Process crashes with "out of memory" after hours/days.
- Garbage collection does not free memory.
- Heap dumps show unreferenced objects still in memory.

### Root Cause
- Event listeners registered but never unregistered.
- Timers (setInterval) not cleared.
- Large objects kept in global scope.
- Circular references preventing garbage collection.
- Missing cleanup in error paths.

### Example (Bad)
```typescript
// Event listener never removed
emitter.on('data', (data) => {
  console.log(data);
}); // Registers listener, never removes it

// Interval never cleared
setInterval(() => {
  cleanup();
}, 5000); // Accumulates over time if process doesn't exit

// Global variable
const cache = {}; // Grows unbounded
```

### Prevention
- **Unregister listeners:** Always call `.off()` or `.removeListener()`.
- **Clear timers:** Store return value, call `clearInterval()` on cleanup.
- **Use WeakMap for caches:** Allows garbage collection when key is not referenced.
- **Monitor memory:** Log memory usage, alert if grows > 50%.
- **Test for leaks:** Run app under load for 1 hour, check heap.
- **Use memory profiler:** Chrome DevTools, Node.js `--inspect` flag.

### Fix Template
```typescript
// Good: Register and unregister
class Handler {
  onData = (data) => console.log(data);
  
  register() {
    emitter.on('data', this.onData);
  }
  
  unregister() {
    emitter.off('data', this.onData);
  }
}

// Good: Clear timers
class Cleaner {
  timer: NodeJS.Timeout;
  
  start() {
    this.timer = setInterval(() => cleanup(), 5000);
  }
  
  stop() {
    clearInterval(this.timer);
  }
}

// Good: Bounded cache with WeakMap
const cache = new WeakMap(); // Automatically garbage collected
const key = { id: 1 };
cache.set(key, 'value');
```

---

## Pattern 6: Timezone Bugs

### Symptoms
- Times are off by N hours (often your local timezone offset).
- Scheduled tasks run at wrong time.
- User sees 2:00 AM but backend says 4:00 AM.
- Dates shift by 1 day.

### Root Cause
- Storing local time instead of UTC in database.
- Forgetting to convert between client (local) and server (UTC).
- JavaScript Date object confused about timezone.
- Using string dates without timezone info.

### Example (Bad)
```typescript
// Storing local time
const localNow = new Date(); // 2:00 PM PST (14:00)
await db.query('INSERT INTO events (time) VALUES (?)', [localNow]);
// Database stores: 2:00 PM (no timezone info)
// When someone in EST reads it: thinks it's 2:00 PM EST = wrong!

// Sending time to client without timezone
const event = await getEvent(id);
res.json({ time: event.time }); // "2023-01-01 14:00:00"
// Client doesn't know if this is UTC, local, or something else
```

### Prevention
- **Always store UTC:** `new Date().toISOString()` returns UTC.
- **Always include timezone:** Send ISO 8601 format with Z (UTC) or offset.
- **Convert on client:** Client converts UTC to local time for display.
- **Avoid Date.parse():** Only parse ISO 8601 strings, not ambiguous formats.
- **Test across timezones:** Run tests in PST, EST, UTC.
- **Use libraries:** `moment-timezone`, `luxon`, or `date-fns` for conversions.

### Fix Template
```typescript
// Good: Store UTC
async createEvent(title: string, localTime: Date, userTimezone: string) {
  const utcTime = new Date(localTime); // Already UTC in JS
  await db.query('INSERT INTO events (time) VALUES (?)', [utcTime.toISOString()]);
}

// Good: Send ISO 8601 with timezone
async getEvent(id: string) {
  const event = await db.query('SELECT * FROM events WHERE id = ?', [id]);
  return {
    ...event,
    time: event.time.toISOString(), // "2023-01-01T22:00:00Z"
  };
}

// Good: Client converts to local
const event = await getEvent(123);
const localTime = new Date(event.time); // JS parses ISO 8601, assumes UTC
const options = { timeZone: 'America/Los_Angeles' };
const displayTime = localTime.toLocaleString('en-US', options);
```

---

## Pattern 7: Encoding Issues

### Symptoms
- Special characters display as ??? or mojibake (乱码).
- File uploads fail for non-ASCII filenames.
- Search returns no results for accented characters.
- Database shows "?" instead of "ñ".

### Root Cause
- Database not set to UTF-8.
- HTTP response header missing charset.
- Files saved in wrong encoding.
- String comparison case-sensitive when should be case-insensitive.

### Example (Bad)
```typescript
// Database not UTF-8
CREATE TABLE users (name VARCHAR(100)); // Default encoding might not be UTF-8

// Response missing charset
res.setHeader('Content-Type', 'application/json'); // Missing; charset=utf-8

// File upload with wrong encoding
const filename = req.file.originalname; // May be in user's local encoding
await fs.writeFile(filename, data); // Writes in default encoding
```

### Prevention
- **Database encoding:** Always `COLLATE utf8mb4_unicode_ci` or equivalent.
- **HTTP response charset:** Always include `; charset=utf-8`.
- **Normalize filenames:** Convert to UTF-8, remove special chars if needed.
- **Case-insensitive search:** Use `COLLATE` or `.toLowerCase()` before comparison.
- **Test internationally:** Test with Japanese, Arabic, emoji, accented characters.

### Fix Template
```typescript
// Good: Set database encoding on creation
CREATE TABLE users (
  name VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
);

// Good: Set response charset
res.setHeader('Content-Type', 'application/json; charset=utf-8');

// Good: Normalize filename
const filename = Buffer.from(req.file.originalname, 'latin1').toString('utf8');
const safeName = sanitizeFilename(filename);

// Good: Case-insensitive search
const users = await db.query(
  'SELECT * FROM users WHERE LOWER(name) = LOWER(?)',
  [searchTerm]
);
```

---

## Pattern 8: CORS Misconfiguration

### Symptoms
- Frontend request blocked: "Cross-Origin Request Blocked".
- Browser console shows CORS error.
- Request works in Postman but not in browser.
- Preflight (OPTIONS) request fails.

### Root Cause
- CORS middleware not configured.
- Allowed origins too restrictive or too permissive.
- Credentials not sent/allowed.
- Preflight headers not set.

### Example (Bad)
```typescript
// No CORS middleware
app.use(express.json());
// Frontend can't make cross-origin requests

// Allowing all origins (security risk)
app.use(cors({ origin: '*', credentials: true })); // Contradictory!

// Missing preflight handling
app.get('/api/data', handler); // No OPTIONS route
```

### Prevention
- **Configure CORS explicitly:** Whitelist allowed origins.
- **Never allow `*` with credentials:** Risk of XSS leaking auth tokens.
- **Handle preflight:** OPTIONS requests must return 200.
- **Include credentials header:** If frontend sends cookies, allow it.
- **Test cross-origin:** Open frontend on different port/domain.

### Fix Template
```typescript
// Good: Whitelist origins
const allowedOrigins = [
  'http://localhost:3000', // development
  'https://app.example.com', // production
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true, // Allow cookies if origins are specific
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 3600,
}));

// Good: Manual preflight if not using middleware
app.options('*', cors()); // Handles all preflight requests
```

---

## Pattern 9: Database Migration Ordering Errors

### Symptoms
- Migration works locally but fails on production.
- Deployment rolls back; old schema remains.
- Foreign key constraint fails.
- Migration "hangs" or times out.

### Root Cause
- Migrations executed out of order.
- Circular foreign key dependencies.
- Index created before column exists.
- No downtime strategy for dropping columns.

### Example (Bad)
```sql
-- Migration 001: Create users table
CREATE TABLE users (id INT PRIMARY KEY);

-- Migration 002: Create orders, reference users
CREATE TABLE orders (user_id INT, FOREIGN KEY (user_id) REFERENCES users(id));

-- But if migration 002 runs before 001, foreign key fails!
```

### Prevention
- **Version migrations:** 001_*, 002_*, 003_*.
- **Test migration order:** Run migrations on clean database.
- **Avoid circular FKs:** If needed, use deferred constraints.
- **Plan zero-downtime:** For dropping columns, use multi-step approach.
- **Backward compatibility:** New code must work with old schema during rollout.
- **Verify migrations:** Always test on staging before production.

### Fix Template (Zero-Downtime Migrations)
```sql
-- Step 1: Add column (safe, backward-compatible)
ALTER TABLE users ADD COLUMN email_new VARCHAR(255);

-- Step 2: Backfill data
UPDATE users SET email_new = email;

-- Step 3: Deploy code to use email_new
-- (old code still uses email, no breakage)

-- Step 4: Add constraints (if needed)
ALTER TABLE users ADD UNIQUE (email_new);

-- Step 5: Code switches to email_new (after verification)

-- Step 6: Drop old column (after verification in production)
ALTER TABLE users DROP COLUMN email;
```

---

## Pattern 10: State Management Bugs

### Symptoms
- UI shows stale data.
- User sees their change, then it reverts.
- Two windows of same app show different data.
- Cache not invalidating after mutation.

### Root Cause
- Server state not synced with client state.
- Cache invalidation logic missing.
- Concurrent mutations overwrite each other.
- WebSocket/real-time updates not received.

### Example (Bad)
```typescript
// Client fetches data once, caches it forever
const [data, setData] = useState(null);
useEffect(() => {
  fetch('/api/data').then(r => r.json()).then(setData);
}, []); // Only runs once; if server changes, client doesn't know

// Another user updates data, but first user still sees old data
```

### Prevention
- **Cache versioning:** Include ETag or version in response.
- **Cache invalidation:** Clear cache after mutations (POST, PUT, DELETE).
- **Real-time sync:** Use WebSockets or polling for frequently-changed data.
- **Optimistic updates:** Update UI immediately, sync with server.
- **Refetch on focus:** Re-fetch data when user returns to tab.
- **Stale-while-revalidate:** Serve stale data, fetch fresh in background.

### Fix Template (React Query / SWR)
```typescript
// Good: React Query manages cache, invalidation
import { useQuery, useMutation, useQueryClient } from 'react-query';

function MyComponent() {
  const queryClient = useQueryClient();
  
  // Fetch data (auto-refreshes when cache is stale)
  const { data } = useQuery('users', () => fetch('/api/users').then(r => r.json()));
  
  // Mutation invalidates cache
  const mutation = useMutation(
    (newUser) => fetch('/api/users', { method: 'POST', body: JSON.stringify(newUser) }),
    {
      onSuccess: () => {
        // Invalidate and refetch
        queryClient.invalidateQueries('users');
      },
    }
  );
  
  return (
    <button onClick={() => mutation.mutate({ name: 'Alice' })}>
      Create User
    </button>
  );
}
```

---

## [PROJECT]-Specific Error Patterns

**TODO: Add project-specific error patterns here.**

Examples:
- Multi-tenant isolation breaches (leaking cross-tenant data).
- Specific performance bottlenecks (API endpoints, database tables).
- Integration-specific issues (payment processor timeouts, webhook ordering).
- Domain-specific logic bugs (business rule violations).

---

## How to Use This Document

1. **Debugging:** When you encounter a weird bug, search this document for symptoms.
2. **Code Review:** Before approving a PR, check if it's implementing any of these anti-patterns.
3. **Design:** When designing a new feature, think about which patterns might apply.
4. **Learning:** Read this as a catalog of common mistakes to avoid.

---

## Adding New Patterns

When you discover a new error pattern in [PROJECT]:

1. Document the symptoms, root cause, and example (bad code).
2. Add prevention strategies and fix templates.
3. Create a test that reproduces the issue.
4. Share with the team in code review.
5. Update this document.

---

## Review Schedule

Last updated: [DATE]  
Next review: [DATE + 3 months]  
Owner: [PROJECT] Tech Lead
