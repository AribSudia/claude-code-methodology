# SECURITY — Security Specification for [PROJECT]

This document defines the security requirements for [PROJECT], including authentication, authorization, data protection, input validation, API security, and incident response.

---

## CCM v3.3 enforcement layer (methodology-level)

The Claude Code Methodology ships an active enforcement layer that
reduces some classes of security risk at the *development* layer. This is
**not a substitute** for the application-level controls below — it
catches a subset of mistakes before they hit a commit.

| Risk | Enforcement | Where |
|------|-------------|-------|
| Hardcoded secrets in code | Write-time block (8 patterns) | `.claude/hooks/pre-tool-use.sh` |
| Hardcoded secrets in commits | Pre-commit block | `.claude/hooks/pre-commit.sh` |
| `eval()` on non-literals (OWASP A03) | Write-time block | `.claude/hooks/pre-tool-use.sh` |
| `new Function()` constructor | Write-time block | `.claude/hooks/pre-tool-use.sh` |
| Template-literal `exec()` | Write-time block | `.claude/hooks/pre-tool-use.sh` |
| Writes outside `allowed_write_paths` | Path scoping | `.claude/hooks/pre-tool-use.sh` + `architecture/CONTEXT_MAP.md` |
| `rm -rf /`, fork bomb, force-push to main, etc. | Bash blocklist | `.claude/hooks/pre-tool-use.sh` |
| PII in log lines | Pre-commit block | `.claude/hooks/pre-commit.sh` |
| Unsanctioned merge to main from a wave/* branch | Wave-merge gate | `.claude/hooks/pre-tool-use.sh` |
| Long autonomous runs without guardrails | Autonomy guard | `.claude/hooks/autonomy-guard.sh` (opt-in via `CCM_AUTONOMY=1`) |

Test/fixture paths are exempted from secret scans to avoid false
positives. Bypass paths (CONTEXT_MAP update, manual run, `--no-verify`)
are documented in `Training/04-HOOKS-MANUAL.md`.

For the full compliance framework alignment (OWASP, GDPR, ISO 27001,
SOC 2, PDPL), see `compliance/README.md`.

---

## Authentication Requirements

### Password-Based Authentication

**Password Policy:**
- Minimum length: 12 characters (or entropy-based: ≥ 50 bits).
- Complexity: Must contain uppercase, lowercase, number, and special character (or just long passphrase).
- Never enforce expiration (NIST guidance); expire only after breach.
- Hash algorithm: bcrypt (cost ≥ 12), Argon2, or scrypt (never MD5, SHA-1, unsalted).
- Slow hash: Intentionally slow (100-200ms per bcrypt iteration) to resist brute force.

**Example (Node.js):**
```typescript
import bcrypt from 'bcrypt';

// Registration
const password = req.body.password;
const salt = await bcrypt.genSalt(12); // 2^12 iterations
const hashedPassword = await bcrypt.hash(password, salt);

// Login
const isValid = await bcrypt.compare(inputPassword, hashedPassword);
```

**Transmission:**
- Use HTTPS only (TLS 1.2+); never HTTP.
- Send password only in POST body, never in URL.
- Clear password from memory after use (`password = null`).
- Log only that password was hashed, never the actual password.

### JWT Tokens

**Structure:**
- Access token: Short-lived (15 minutes), signed with RS256 or HS256.
- Refresh token: Long-lived (7 days), opaque, stored in database.
- Payload: `{ sub: userId, iat, exp, aud: 'web|mobile', iss: 'api.example.com' }`.

**Validation:**
- Always verify signature.
- Check expiration (with 30-second clock tolerance).
- Check audience and issuer match.
- Check token hasn't been revoked (optional, for immediate logout).

**Transmission:**
- Access token: `Authorization: Bearer <token>` header.
- Refresh token: HttpOnly, Secure, SameSite=Strict cookie.
- Never store access token in localStorage (XSS vulnerability).

### Multi-Factor Authentication (MFA)

**Supported Methods:**
1. TOTP (Time-based One-Time Password): Google Authenticator, Authy, etc.
2. Email OTP: 6-digit code sent to email (for fallback).
3. SMS OTP: 6-digit code sent to SMS (future).

**Flow:**
1. User logs in with username/password.
2. If MFA enabled, server returns 401 with `mfa_required: true`.
3. Client prompts for MFA code.
4. Client sends MFA code to `/auth/mfa-verify` endpoint.
5. Server verifies code (6-digit TOTP, 30-second window).
6. Server returns access token if valid.

**Implementation:**
```typescript
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';

// Setup MFA
const secret = speakeasy.generateSecret({
  name: `[PROJECT] (${user.email})`,
  issuer: '[PROJECT]',
  length: 32,
});

// Return QR code for user to scan
const qrCode = await QRCode.toDataURL(secret.otpauth_url);

// Store secret encrypted in database
await db.query('UPDATE users SET mfa_secret = ? WHERE id = ?', [encryptedSecret, userId]);

// Verify MFA during login
const isValid = speakeasy.totp.verify({
  secret: decryptedSecret,
  encoding: 'base32',
  token: userInput,
  window: 1, // Allow 1 time window (±30 seconds)
});
```

### Session Management

**Session Timeout:**
- Idle timeout: 30 minutes (user hasn't made request).
- Absolute timeout: 8 hours (even if user is active).
- On timeout: Clear tokens, force re-authentication.

**Concurrent Sessions:**
- Allow multiple devices (user can be logged in on phone + laptop).
- Option to revoke all sessions on password change.
- Suspicious login detection (new IP, new device) with email confirmation.

---

## Authorization Model (RBAC)

### Role-Based Access Control (RBAC)

**Roles:**
```
User
  ├── Admin (full access)
  ├── Editor (can create/edit content)
  ├── Viewer (read-only)
  └── Guest (unauthenticated, limited public endpoints)
```

**Permissions:**
```
Admin:
  ✓ Create users
  ✓ Edit users
  ✓ Delete users
  ✓ View audit logs
  ✓ Change system settings

Editor:
  ✓ Create content
  ✓ Edit own content
  ✓ View content
  ✗ Delete content
  ✗ View other users' content

Viewer:
  ✓ View content
  ✗ Create/edit/delete content
  ✗ View users

Guest:
  ✓ View public content
  ✗ Anything else
```

### Permission Matrix Template

| Resource | Guest | Viewer | Editor | Admin |
|----------|-------|--------|--------|-------|
| View public content | ✓ | ✓ | ✓ | ✓ |
| View all content | ✗ | ✓ | ✓ | ✓ |
| Create content | ✗ | ✗ | ✓ | ✓ |
| Edit own content | ✗ | ✗ | ✓ | ✓ |
| Edit any content | ✗ | ✗ | ✗ | ✓ |
| Delete content | ✗ | ✗ | ✗ | ✓ |
| Manage users | ✗ | ✗ | ✗ | ✓ |
| View audit logs | ✗ | ✗ | ✗ | ✓ |

### Authorization Enforcement

**Checks:**
- **Route-level:** Middleware checks user role before controller runs.
- **Resource-level:** Service checks if user owns/can access resource.
- **Field-level:** Exclude sensitive fields from response (passwords, tokens).

**Example:**
```typescript
// Route-level check
router.post('/api/admin/users', requireRole('Admin'), createUser);

// Resource-level check
async deletePost(postId: string, userId: string) {
  const post = await postRepository.getById(postId);
  if (post.userId !== userId && user.role !== 'Admin') {
    throw new ForbiddenError('You can only delete your own posts');
  }
  await postRepository.delete(postId);
}

// Field-level filter
function serializeUser(user) {
  return {
    id: user.id,
    email: user.email,
    // Exclude: password, mfa_secret, refresh_tokens
  };
}
```

### [PROJECT]-Specific Roles

**TODO: Define custom roles for [PROJECT].**

Examples:
- Multi-tenant: Tenant Admin, Organization Member, Guest.
- E-commerce: Seller, Buyer, Support Agent.
- SaaS: Account Owner, Billing Admin, Team Member, Guest.

---

## Data Protection

### Encryption at Rest

**Sensitive Fields:**
- Passwords: Hash with bcrypt/Argon2 (not reversible).
- PII (SSN, passport number): Encrypt with AES-256.
- Payment tokens: Tokenize (never store full card numbers).
- API keys: Hash (like passwords).
- MFA secrets: Encrypt with service key.

**Implementation:**
```typescript
// Encrypt
import crypto from 'crypto';

const algorithm = 'aes-256-gcm';
const key = crypto.scryptSync(process.env.ENCRYPTION_KEY, 'salt', 32);
const iv = crypto.randomBytes(12);
const cipher = crypto.createCipheriv(algorithm, key, iv);
const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
const tag = cipher.getAuthTag();
// Store: iv + tag + encrypted (base64)

// Decrypt
const decipher = crypto.createDecipheriv(algorithm, key, iv);
decipher.setAuthTag(tag);
const decrypted = Buffer.concat([decipher.update(encrypted), decipher.final()]).toString('utf8');
```

**Database:**
- Enable transparent data encryption (TDE) if supported (e.g., AWS RDS encryption).
- Encrypt database backups.
- Restrict database access to application only (no direct admin access in production).

### Encryption in Transit

**HTTPS/TLS:**
- TLS 1.2 minimum (prefer 1.3).
- Use strong ciphers (ECDHE + AES-256-GCM).
- Generate certificate via Let's Encrypt (free, auto-renewing).
- Enforce HSTS header: `Strict-Transport-Security: max-age=31536000; includeSubDomains`.
- Redirect HTTP → HTTPS.

**API:**
- Always use HTTPS for API endpoints.
- No sensitive data in query strings (use POST body).
- Sign requests for API-to-API calls (HMAC-SHA256).

### PII Handling

**Collection:**
- Only collect necessary PII (name, email, phone).
- Do not collect SSN unless required (e.g., payment processing).
- Inform users why you're collecting PII (privacy policy).

**Storage:**
- Encrypt PII at rest.
- Separate PII from user ID (can anonymize with separate key).
- Set data retention policy (e.g., delete after 30 days of inactivity).

**Transmission:**
- Only send PII to trusted third parties via HTTPS.
- Use tokenization for payment processing (never store full card numbers).
- No PII in logs or error messages.

**Deletion:**
- Implement "right to be forgotten" (GDPR Article 17).
- Soft delete for audit trail, hard delete after 7 days.
- Remove PII from backups after deletion.

---

## Input Validation

### Universal Rules

1. **Validate all input.** Never trust user input, even from logged-in users.
2. **Whitelist, don't blacklist.** Allow known-good values, reject everything else.
3. **Validate type, length, format, and range.**
4. **Validate on both client and server.** Client for UX, server for security.
5. **Reject unexpected input.** Never attempt to correct or sanitize; return error.

### Validation Examples

```typescript
// String: length, format
const email = req.body.email;
if (!email || typeof email !== 'string' || email.length > 255) {
  throw new BadRequestError('Invalid email');
}
if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
  throw new BadRequestError('Invalid email format');
}

// Number: range
const age = req.body.age;
if (typeof age !== 'number' || age < 0 || age > 150) {
  throw new BadRequestError('Invalid age');
}

// Enum: whitelist
const role = req.body.role;
const allowedRoles = ['Admin', 'Editor', 'Viewer'];
if (!allowedRoles.includes(role)) {
  throw new BadRequestError('Invalid role');
}

// Array: length, element validation
const tags = req.body.tags;
if (!Array.isArray(tags) || tags.length > 10) {
  throw new BadRequestError('Too many tags');
}
for (const tag of tags) {
  if (typeof tag !== 'string' || tag.length > 50) {
    throw new BadRequestError('Invalid tag');
  }
}

// Use validation library
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128),
  age: z.number().int().min(0).max(150).optional(),
  role: z.enum(['Admin', 'Editor', 'Viewer']),
});

const user = userSchema.parse(req.body);
```

### SQL Injection Prevention

**ALWAYS use parameterized queries.**

```typescript
// ❌ BAD: String concatenation
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// ✓ GOOD: Parameterized
const query = 'SELECT * FROM users WHERE id = ?';
await db.query(query, [userId]);

// ✓ GOOD: ORM (if available)
const user = await User.findById(userId);
```

### XSS Prevention

**Output Encoding:**
- Always encode user content before rendering in HTML.
- Use `textContent` instead of `innerHTML` in JavaScript.
- Use templating engines that auto-escape (EJS, Handlebars with escaping).

```typescript
// ❌ BAD
res.json({ message: req.body.message }); // If displayed in HTML, may include <script>

// ✓ GOOD
const encoded = escapeHtml(req.body.message);
res.json({ message: encoded });

// Or return raw data, let client handle encoding
res.json({ message: req.body.message }); // Client: elem.textContent = data
```

### CSRF Prevention

**Token-Based CSRF (for form submissions):**
- Generate random token per session.
- Include token in form (hidden field).
- Validate token on POST/PUT/DELETE requests.

**SameSite Cookies (modern approach):**
- Set `SameSite=Lax` or `Strict` on all cookies.
- Prevents cross-site form submissions.
- Supported by all modern browsers.

```typescript
// Express
app.use(express.urlencoded({ extended: false }));
app.use(csrf({ cookie: { httpOnly: true, secure: true, sameSite: 'strict' } }));

// Jade/EJS template
form(method='post', action='/submit')
  input(type='hidden', name='_csrf', value=csrfToken)
  input(type='text', name='comment')
  button(type='submit') Submit
```

---

## API Security

### Rate Limiting

**Goals:**
- Prevent brute force attacks (password guessing).
- Prevent DoS (denial of service).
- Fair use (prevent single user from hogging resources).

**Implementation:**
```typescript
import rateLimit from 'express-rate-limit';

// General rate limit: 100 requests per 15 minutes per IP
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  keyGenerator: (req) => req.ip,
  skip: (req) => req.user?.role === 'Admin', // Skip for admins
}));

// Strict limit on login: 5 attempts per 15 minutes
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true, // Reset after success
});
app.post('/auth/login', loginLimiter, loginHandler);

// Per-user rate limit (if authenticated)
app.use((req, res, next) => {
  if (req.user) {
    // 1000 requests per hour per user
    // Store in Redis keyed by userId
  }
  next();
});
```

### CORS Configuration

**Whitelist Origins:**
```typescript
const allowedOrigins = [
  'http://localhost:3000', // dev
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
  credentials: true, // Allow cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 3600,
}));
```

**Never allow `*` with credentials.**

### HTTP Security Headers

**Add to all responses:**
```typescript
app.use((req, res, next) => {
  // Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // Enable XSS protection (browser)
  res.setHeader('X-XSS-Protection', '1; mode=block');
  
  // Content Security Policy (strict)
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' https:;"
  );
  
  // Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Permissions policy
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  
  // HSTS (HTTPS only)
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  
  next();
});
```

---

## File Upload Security

**Whitelist File Types:**
```typescript
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'application/pdf',
];

const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.pdf'];

app.post('/upload', (req, res) => {
  const file = req.file;
  
  // Check MIME type
  if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    return res.status(400).json({ error: 'Invalid file type' });
  }
  
  // Check extension
  const ext = path.extname(file.originalname).toLowerCase();
  if (!ALLOWED_EXTENSIONS.includes(ext)) {
    return res.status(400).json({ error: 'Invalid file extension' });
  }
  
  // Check file size (max 10 MB)
  if (file.size > 10 * 1024 * 1024) {
    return res.status(400).json({ error: 'File too large' });
  }
  
  // Scan for viruses (ClamAV)
  const isSafe = await scanForViruses(file.buffer);
  if (!isSafe) {
    return res.status(400).json({ error: 'File contains malware' });
  }
  
  // Rename file (remove user-supplied name)
  const fileId = crypto.randomBytes(16).toString('hex');
  const newPath = path.join('/uploads', `${fileId}${ext}`);
  
  // Store (do NOT store in webroot, serve via download endpoint)
  await fs.promises.writeFile(newPath, file.buffer);
  
  res.json({ fileId, url: `/api/files/${fileId}` });
});
```

**Serve via Download Endpoint (not directly):**
```typescript
app.get('/api/files/:fileId', (req, res) => {
  const fileId = req.params.fileId;
  
  // Validate fileId is valid format
  if (!/^[a-f0-9]{32}$/.test(fileId)) {
    return res.status(400).json({ error: 'Invalid file ID' });
  }
  
  // Check authorization (user owns file)
  const file = await fileRepository.getById(fileId);
  if (file.userId !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  // Serve from secure location (not webroot)
  res.download(`/secure/uploads/${fileId}`, file.originalName);
});
```

---

## Logging and Audit Requirements

### What to Log

**Security Events:**
- Failed login attempts (with IP, timestamp, user identifier).
- Successful login (with IP, user agent, timestamp).
- Password changes.
- Permission changes.
- API key creation/deletion.
- Account lockout/unlock.
- Data access (for sensitive data).

**Application Events:**
- API requests (method, path, status, duration, user).
- Database queries (parameterized, not raw SQL).
- External API calls (service, endpoint, status).
- Errors and exceptions (stack trace, context).
- Configuration changes.

**Example Log Entry:**
```json
{
  "timestamp": "2024-04-15T10:30:45Z",
  "level": "INFO",
  "event": "user_login",
  "userId": "user-123",
  "email": "user@example.com",
  "ip": "203.0.113.45",
  "userAgent": "Mozilla/5.0...",
  "mfaUsed": true,
  "status": "success"
}
```

### What NEVER to Log

**Absolutely forbidden:**
- Passwords (hashed or plain).
- Credit card numbers (PAN).
- API keys, tokens, secrets.
- Encryption keys.
- Private keys.
- MFA codes or backup codes.
- Social Security numbers (SSN).
- Passport numbers.
- Medical records.

**Redact from logs:**
- Email addresses (unless necessary for security event).
- Phone numbers (unless necessary).
- URL parameters (may contain tokens).

**Example (Redacting):**
```typescript
function redactSensitive(data: any): any {
  const redacted = JSON.parse(JSON.stringify(data));
  if (redacted.password) redacted.password = '[REDACTED]';
  if (redacted.authorization) redacted.authorization = '[REDACTED]';
  if (redacted.apiKey) redacted.apiKey = '[REDACTED]';
  if (redacted.token) redacted.token = '[REDACTED]';
  return redacted;
}

logger.info('Request', { body: redactSensitive(req.body) });
```

### Log Retention

- Keep logs for ≥ 30 days (or per compliance requirement).
- Archive logs older than 30 days to cold storage (S3 Glacier).
- Implement log rotation (e.g., daily files, gzip old files).
- Never delete logs (only archive).

### Audit Trail

- For sensitive operations (delete, permission change), create immutable audit log.
- Include: who, what, when, why (comment if user-initiated), IP address.
- Audit logs must not be deletable or editable by users.

---

## Incident Response Protocol

### Detection and Initial Response

**1. Identify the incident:**
- Monitor for: unusual traffic, error rate spikes, security alerts, user reports.
- Create incident ticket with: description, detection time, scope.
- Assign incident commander (IC).

**2. Contain (within 1 hour):**
- Isolate affected systems (if needed).
- Disable compromised accounts.
- Revoke compromised tokens.
- Enable enhanced monitoring.
- Do NOT delete evidence.

**3. Investigate (within 24 hours):**
- Analyze logs and forensics.
- Determine: what happened, when it started, scope (how many users).
- Check for data exfiltration.
- Identify root cause.

### Mitigation and Recovery

**4. Mitigate:**
- Apply emergency patches.
- Reset compromised passwords.
- Rotate keys and tokens.
- Enable MFA for affected users.
- Provide remediation steps to affected users.

**5. Communicate:**
- Notify affected users (within 24 hours).
- Provide: what happened (plain language), impact, actions to take.
- Provide phone support line if needed.
- Update status page (if public incident).

**6. Recovery:**
- Restore from backup if needed.
- Verify system integrity.
- Deploy fixes.
- Monitor for recurrence.

### Post-Incident

**7. Post-mortem (within 5 days):**
- Document timeline of incident.
- Identify contributing factors.
- Propose preventive actions.
- Assign owners and deadlines.
- Review with team.

**8. Prevention:**
- Implement preventive controls.
- Update runbooks and incident response plan.
- Conduct security training (if needed).
- Monitor progress on action items.

**Example Incident Runbook:**
```markdown
# Incident: Suspected Data Breach

1. Identify: Check logs for unauthorized access
2. Contain: Revoke compromised tokens, disable accounts
3. Investigate: Analyze access logs, determine scope
4. Mitigate: Reset passwords, notify users
5. Communicate: Send user notification + incident update
6. Recovery: Apply patches, verify integrity
7. Post-mortem: Schedule for next day
```

---

## OWASP Top 10 Checklist

Use this checklist to ensure coverage of the most common web application vulnerabilities.

| # | Vulnerability | Mitigation | ✓ |
|---|---|---|---|
| 1 | Broken Access Control | RBAC, authorization checks at resource level | |
| 2 | Cryptographic Failures | Encrypt sensitive data at rest and in transit (HTTPS) | |
| 3 | Injection | Parameterized queries, input validation, escaping | |
| 4 | Insecure Design | Security by design, threat modeling, architecture review | |
| 5 | Security Misconfiguration | Principle of least privilege, secure defaults, regular audits | |
| 6 | Vulnerable Components | Dependency scanning, keep deps updated, monitor advisories | |
| 7 | Authentication Failures | Strong passwords, MFA, secure session management, rate limiting | |
| 8 | Data Integrity Failures | Code signing, secure CI/CD, integrity checks, signed updates | |
| 9 | Logging & Monitoring Failures | Comprehensive logging, centralized log storage, alerting | |
| 10 | SSRF | Whitelist allowed URLs, disable gopher/file protocols, rate limit | |

---

## [PROJECT]-Specific Security Requirements

**TODO: Add project-specific security rules here.**

Examples:
- Payment processing: PCI-DSS compliance, tokenization strategy.
- User data: GDPR/CCPA compliance, data retention, deletion.
- Healthcare: HIPAA compliance, encryption, audit logs.
- Financial: SOC 2 compliance, change management, incident response.

---

## Security Checklist (Before Production Deployment)

- [ ] All passwords hashed with bcrypt/Argon2 (cost ≥ 12).
- [ ] HTTPS enabled with valid TLS certificate.
- [ ] HSTS header configured.
- [ ] CORS whitelist configured (no `*` with credentials).
- [ ] Rate limiting enabled on login and critical endpoints.
- [ ] Input validation on all endpoints.
- [ ] Parameterized queries for all database access.
- [ ] No secrets in code or `.env.example`.
- [ ] Authentication and authorization working.
- [ ] MFA available (even if not required).
- [ ] Logging configured (no sensitive data).
- [ ] Audit trail for sensitive operations.
- [ ] File upload security implemented (whitelist, size limit, scan).
- [ ] Security headers configured (CSP, X-Frame-Options, etc.).
- [ ] Error handling doesn't leak information.
- [ ] Dependency vulnerabilities scanned.
- [ ] Secrets scanning enabled in CI/CD.
- [ ] SAST (static analysis) enabled.
- [ ] Penetration testing scheduled.
- [ ] Incident response plan documented.
- [ ] Security training completed by all developers.

---

## Review Schedule

Last updated: [DATE]  
Next review: [DATE + 6 months]  
Owner: [PROJECT] Security Lead
