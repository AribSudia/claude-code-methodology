# Contract Testing — Inter-Service Verification

> **When to use this file:** Only for microservices or multi-service architectures
> where services communicate via APIs or events. Monolith projects skip this file.

---

## Why Contract Testing

Unit tests verify a service works internally. Integration tests verify services
work together. But neither catches this:

**Service A expects** `{ userId: string, name: string }`
**Service B returns** `{ user_id: number, fullName: string }`

Contract tests verify that **the agreement between services is maintained**
even when they're developed and deployed independently.

---

## Types of Contracts

| Type                | What It Tests                              | Who Writes It          |
|---------------------|--------------------------------------------|------------------------|
| **Consumer-Driven** | Consumer defines what it needs from provider | Consumer team         |
| **Provider-Driven** | Provider defines what it offers              | Provider team         |
| **Event Contract**  | Published event matches expected schema      | Publisher team        |

**Recommended:** Consumer-driven contracts (CDC) — the consumer is always right.

---

## Consumer-Driven Contract Testing (Pact)

### How It Works

```
1. Consumer writes a PACT:
   "When I call GET /users/123, I expect { id, email, name }"

2. Pact file is generated (JSON contract)

3. Provider verifies the Pact:
   "Does my actual GET /users/123 return { id, email, name }?"

4. If provider changes the response → Pact verification FAILS
   → Provider knows they're about to break a consumer
```

### Consumer Side (writes the contract)

```javascript
// auth-service.consumer.test.js
const { PactV3 } = require('@pact-foundation/pact');

describe('Auth Service Consumer', () => {
  const provider = new PactV3({
    consumer: 'core-service',
    provider: 'auth-service'
  });

  it('returns user by ID', async () => {
    // Define expected interaction
    provider
      .given('user with ID usr_123 exists')
      .uponReceiving('a request for user usr_123')
      .withRequest({
        method: 'GET',
        path: '/users/usr_123',
        headers: { Authorization: 'Bearer valid-token' }
      })
      .willRespondWith({
        status: 200,
        body: {
          id: 'usr_123',
          email: like('user@example.com'),
          name: like('Abdullah'),
          role: like('admin')
        }
      });

    // Execute test against mock
    await provider.executeTest(async (mockServer) => {
      const user = await authClient.getUser('usr_123', mockServer.url);
      expect(user.id).toBe('usr_123');
      expect(user.email).toBeDefined();
    });
  });
});
```

### Provider Side (verifies the contract)

```javascript
// auth-service.provider.test.js
const { Verifier } = require('@pact-foundation/pact');

describe('Auth Service Provider Verification', () => {
  it('validates all consumer contracts', async () => {
    const verifier = new Verifier({
      providerBaseUrl: 'http://localhost:3001',
      pactUrls: ['./pacts/core-service-auth-service.json'],
      stateHandlers: {
        'user with ID usr_123 exists': async () => {
          await seedDatabase({ id: 'usr_123', email: 'user@example.com' });
        }
      }
    });

    await verifier.verifyProvider();
  });
});
```

---

## Event Contract Testing

### Schema Registry Approach

Define event schemas centrally, validate at publish and consume time:

```json
// schemas/auth.user.registered.v1.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["eventId", "eventType", "timestamp", "data"],
  "properties": {
    "eventId": { "type": "string", "pattern": "^evt_" },
    "eventType": { "const": "auth.user.registered" },
    "version": { "const": "1.0" },
    "timestamp": { "type": "string", "format": "date-time" },
    "data": {
      "type": "object",
      "required": ["userId", "email", "role"],
      "properties": {
        "userId": { "type": "string" },
        "email": { "type": "string", "format": "email" },
        "role": { "type": "string", "enum": ["admin", "user", "seller"] }
      }
    }
  }
}
```

### Publisher Test (validates event matches schema)

```javascript
it('publishes valid user.registered event', async () => {
  const event = await authService.registerUser(validUserData);

  const schema = require('./schemas/auth.user.registered.v1.json');
  const valid = ajv.validate(schema, event);
  expect(valid).toBe(true);
  expect(ajv.errors).toBeNull();
});
```

### Consumer Test (validates handler accepts schema)

```javascript
it('handles user.registered event correctly', async () => {
  const event = generateEvent('auth.user.registered', {
    userId: 'usr_123',
    email: 'user@example.com',
    role: 'user'
  });

  const result = await notificationHandler.handle(event);
  expect(result.emailSent).toBe(true);
});
```

---

## API Versioning Strategy

### URL Versioning (Recommended)

```
/api/v1/users      ← current
/api/v2/users      ← new version (breaking changes)
```

### Versioning Rules

- **Adding a field** → NOT a breaking change (v1 still works)
- **Removing a field** → BREAKING change (bump to v2)
- **Changing a field type** → BREAKING change (bump to v2)
- **Renaming a field** → BREAKING change (bump to v2)

### Deprecation Process

```
Phase 1: Release v2, keep v1 running
Phase 2: Log warnings when v1 is called
Phase 3: Notify consumers to migrate (30 days)
Phase 4: Remove v1
```

---

## Breaking Change Detection

### Automated Schema Comparison

```bash
# Compare current API schema against previous version
# Flag any removals, type changes, or renamed fields

# OpenAPI diff example
npx openapi-diff old-api.yaml new-api.yaml

# Output:
# BREAKING: Removed field 'user.name' from GET /users/:id response
# BREAKING: Changed field 'user.age' from string to number
# COMPATIBLE: Added field 'user.avatar' to GET /users/:id response
```

### CI/CD Integration

```yaml
# In CI pipeline:
contract-test:
  steps:
    - name: Run consumer contract tests
      run: npm test -- --grep "consumer"

    - name: Verify provider contracts
      run: npm test -- --grep "provider"

    - name: Check for breaking API changes
      run: npx openapi-diff main.yaml current.yaml --fail-on-breaking
```

---

## Contract Testing Checklist

### For Each Service Pair (A calls B)

- [ ] Consumer contract written (Service A defines what it expects from B)
- [ ] Provider verification passing (Service B confirms it matches the contract)
- [ ] Contract tests run in CI for BOTH services
- [ ] Breaking changes blocked by CI pipeline

### For Each Event

- [ ] Event schema defined (JSON Schema or Avro)
- [ ] Publisher validates event against schema before publishing
- [ ] Consumer validates event against schema on receipt
- [ ] Schema stored in shared contracts package

### Before Any Service Deployment

- [ ] All contract tests pass
- [ ] No breaking changes detected (or migration plan exists)
- [ ] Deprecated APIs have migration timeline
- [ ] Event schema versions are backward compatible

---

## Tools Reference

| Tool              | Language       | Purpose                             |
|-------------------|----------------|-------------------------------------|
| **Pact**          | JS, Java, .NET | Consumer-driven contract testing    |
| **Ajv**           | JavaScript     | JSON Schema validation for events   |
| **openapi-diff**  | CLI            | API breaking change detection       |
| **Avro**          | Multi-language | Binary event schema with evolution  |
| **Protobuf**      | Multi-language | gRPC contract definition            |
| **Spectral**      | JavaScript     | OpenAPI linting and validation      |
