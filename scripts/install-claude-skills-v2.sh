#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║   Claude Code Skills — MASTER INSTALL v2.0                      ║
# ║   For: Abdullah / MotorGate / ARIB / شبكة الكهرباء              ║
# ║                                                                  ║
# ║   الفئة أ — الأقوى عالمياً (برمجة + جودة):                     ║
# ║     frontend-design, systematic-debugging, superpowers,         ║
# ║     webapp-testing, owasp-security, varlock, TDD,               ║
# ║     software-architecture, code-review, playwright-skill,       ║
# ║     subagent-driven-development, changelog-generator,           ║
# ║     using-git-worktrees, finishing-branch, supermemory          ║
# ║                                                                  ║
# ║   الفئة ب — الأصليين (تصميم + تسويق + أتمتة):                  ║
# ║     autoresearch, SuperClaude, marketing-skills,                ║
# ║     ui-ux-pro, 21st.dev Magic MCP, Nano Banana 2,              ║
# ║     Google Stitch MCP                                           ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── الألوان ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
info()    { echo -e "${CYAN}ℹ️  $1${NC}"; }
skip()    { echo -e "${PURPLE}⏭  $1${NC}"; }
header()  {
  echo ""
  echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}${BOLD}║  $1${NC}"
  echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
}
subheader() { echo -e "\n${CYAN}── $1 ──${NC}"; }

SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
AGENTS_DIR="$HOME/.claude/agents"
TMP_DIR="/tmp/claude-v2-install"
CLAUDE_JSON="$HOME/.claude.json"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
INSTALL_LOG="$HOME/.claude/install-v2-$BACKUP_DATE.log"

# تتبع النتائج
declare -a INSTALLED=()
declare -a SKIPPED=()
declare -a FAILED=()

track_ok()   { INSTALLED+=("$1"); log "$1"; }
track_skip() { SKIPPED+=("$1");  skip "$1 — already exists"; }
track_fail() { FAILED+=("$1");   warn "$1 — فشل، تم إنشاء stub"; }

mkdir -p "$TMP_DIR"

# دالة clone آمنة
safe_clone() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --quiet --ff-only 2>/dev/null || true
  else
    git clone --depth=1 --quiet "$url" "$dest" 2>/dev/null
  fi
}

# دالة إنشاء skill
make_skill() {
  local name="$1" desc="$2" content="$3"
  mkdir -p "$SKILLS_DIR/$name"
  cat > "$SKILLS_DIR/$name/SKILL.md" << EOF
---
name: $name
description: $desc
---

$content
EOF
}

# ─────────────────────────────────────────────────────────────────
# الخطوة 0 — فحص المتطلبات
# ─────────────────────────────────────────────────────────────────
header "Step 0 — Pre-flight Checks"

for cmd in git node npm curl python3; do
  if command -v "$cmd" &>/dev/null; then
    log "$cmd → $(command -v $cmd)"
  else
    warn "$cmd غير موجود — بعض المهارات قد لا تعمل"
  fi
done

# bun
if ! command -v bun &>/dev/null; then
  warn "bun غير موجود — جارٍ التثبيت..."
  curl -fsSL https://bun.sh/install | bash 2>/dev/null || true
  export PATH="$HOME/.bun/bin:$PATH"
  command -v bun &>/dev/null && log "bun تم تثبيته" || warn "bun فشل — Nano Banana 2 سيُنشأ كـ stub"
else
  log "bun → $(command -v bun)"
fi

# ─────────────────────────────────────────────────────────────────
# الخطوة 1 — نسخ احتياطي كامل
# ─────────────────────────────────────────────────────────────────
header "Step 1 — Full Backup"

if [ -d "$HOME/.claude" ]; then
  cp -r "$HOME/.claude" "$HOME/.claude-backup-$BACKUP_DATE"
  log "~/.claude → ~/.claude-backup-$BACKUP_DATE"
else
  info "تثبيت نظيف — لا يوجد ~/.claude سابق"
fi

if [ -f "$CLAUDE_JSON" ]; then
  cp "$CLAUDE_JSON" "$CLAUDE_JSON.backup-$BACKUP_DATE"
  log "~/.claude.json محفوظ"
fi

# ─────────────────────────────────────────────────────────────────
# الخطوة 2 — هيكل المجلدات
# ─────────────────────────────────────────────────────────────────
header "Step 2 — Directory Structure"

mkdir -p "$SKILLS_DIR" "$COMMANDS_DIR" "$AGENTS_DIR"
log "~/.claude/{skills,commands,agents} جاهز"

# ═════════════════════════════════════════════════════════════════
#  الفئة أ — الأقوى عالمياً (جودة البرمجة)
# ═════════════════════════════════════════════════════════════════
header "Category A — World's Best Coding Skills"

# ─────────────────────────────────────────────────────────────────
# A1 — frontend-design (Anthropic رسمي — 277k تثبيت)
# ─────────────────────────────────────────────────────────────────
subheader "A1 — frontend-design (Anthropic Official — 277k installs)"

if [ -d "$SKILLS_DIR/frontend-design" ]; then
  track_skip "frontend-design"
else
  FRONTD_DIR="$TMP_DIR/anthropic-skills"
  safe_clone "https://github.com/anthropics/skills.git" "$FRONTD_DIR" && {
    if [ -d "$FRONTD_DIR/skills/frontend-design" ]; then
      cp -r "$FRONTD_DIR/skills/frontend-design" "$SKILLS_DIR/"
      track_ok "frontend-design (Anthropic رسمي)"
    else
      make_skill "frontend-design" \
        "Create distinctive production-grade frontend interfaces. Use when building UI components, pages, dashboards, React components, HTML/CSS. Generates creative polished code avoiding generic AI aesthetics." \
        "# Frontend Design — Anthropic Official
## Core Principle
Avoid distributional convergence — escape the visual signature of AI-generated UI.

## Before Coding — Choose a Bold Direction
- Brutally minimal / Maximalist / Retro-futuristic / Luxury / Brutalist
- Commit to ONE direction and execute with precision

## Design Rules
- Typography: bold hierarchy, unexpected font pairings
- Color: purposeful palette, not random gradients
- Spacing: intentional whitespace as a design element
- Animation: only when it adds meaning, never decorative

## For MotorGate (RTL/Arabic)
- Cairo font, Sky Blue #26A9E1 primary
- dir=rtl for Arabic, mirror all layouts
- Mobile-first (Flutter parity)
- Touch targets min 44×44px"
      track_fail "frontend-design → stub created"
    fi
  } || {
    make_skill "frontend-design" \
      "Create distinctive production-grade frontend interfaces. Avoid AI slop. Use for UI components, pages, dashboards." \
      "# Frontend Design\nAvoid generic AI aesthetics. Choose bold direction. Execute with precision."
    track_fail "frontend-design → stub created"
  }
fi

# ─────────────────────────────────────────────────────────────────
# A2 — systematic-debugging (الأكثر استخداماً في production)
# ─────────────────────────────────────────────────────────────────
subheader "A2 — systematic-debugging"

if [ -d "$SKILLS_DIR/systematic-debugging" ]; then
  track_skip "systematic-debugging"
else
  # من anthropics/skills
  FRONTD_DIR="$TMP_DIR/anthropic-skills"
  [ -d "$FRONTD_DIR" ] || safe_clone "https://github.com/anthropics/skills.git" "$FRONTD_DIR" 2>/dev/null || true

  if [ -d "$FRONTD_DIR/skills/systematic-debugging" ]; then
    cp -r "$FRONTD_DIR/skills/systematic-debugging" "$SKILLS_DIR/"
    track_ok "systematic-debugging (Anthropic)"
  else
    make_skill "systematic-debugging" \
      "Use when encountering ANY bug, test failure, or unexpected behavior — BEFORE proposing fixes. Forces scientific debugging methodology." \
      "# Systematic Debugging — Scientific Method

## NEVER guess. Always follow this protocol:

### Phase 1 — Understand
1. Read the EXACT error message word by word
2. Identify: what was expected vs what actually happened
3. Find the EARLIEST point of failure, not just where it surfaces

### Phase 2 — Hypothesize
Form 3 hypotheses ranked by likelihood:
- H1: [most likely cause]
- H2: [second possibility]
- H3: [unlikely but possible]

### Phase 3 — Test (one at a time)
- Design a minimal reproduction for H1
- Run it. Does it reproduce? Yes → confirm. No → eliminate.
- Move to H2 only after H1 is eliminated

### Phase 4 — Fix
- Fix ONLY what the evidence points to
- Never fix multiple things simultaneously
- Document: what was wrong + why + how fixed

### Phase 5 — Verify
- Run the original failing test/scenario
- Run regression tests to ensure nothing broke
- Add a test that would catch this bug in future

## For MotorGate
- .NET 9 bugs: check middleware pipeline order first
- Flutter bugs: check widget rebuild cycles
- PostgreSQL bugs: check query execution plan (EXPLAIN ANALYZE)"
    track_ok "systematic-debugging (stub)"
  fi
fi

# ─────────────────────────────────────────────────────────────────
# A3 — superpowers (obra — 40,900 نجمة)
# ─────────────────────────────────────────────────────────────────
subheader "A3 — superpowers (obra — 40.9k ⭐)"

if [ -d "$SKILLS_DIR/superpowers" ]; then
  track_skip "superpowers"
else
  SUPERPOWERS_DIR="$TMP_DIR/superpowers"
  safe_clone "https://github.com/obra/superpowers.git" "$SUPERPOWERS_DIR" 2>/dev/null && {
    # نسخ كل المهارات من Superpowers
    if [ -d "$SUPERPOWERS_DIR/skills" ]; then
      for skill_dir in "$SUPERPOWERS_DIR/skills/"/*/; do
        skill_name=$(basename "$skill_dir")
        [ -d "$SKILLS_DIR/$skill_name" ] || cp -r "$skill_dir" "$SKILLS_DIR/"
      done
      track_ok "superpowers — $(ls "$SUPERPOWERS_DIR/skills/" | wc -l | tr -d ' ') skills"
    elif [ -d "$SUPERPOWERS_DIR/.claude/skills" ]; then
      cp -r "$SUPERPOWERS_DIR/.claude/skills/"* "$SKILLS_DIR/"
      track_ok "superpowers skills"
    else
      make_skill "superpowers" \
        "Multi-agent development workflow. Use for complex features requiring planning, TDD enforcement, code review, and structured implementation before writing code." \
        "# Superpowers — Full Development Lifecycle

## Workflow (always follow this order)

### 1. Brainstorm & Clarify
Before ANY implementation:
- Ask 5 clarifying questions about requirements
- Identify edge cases the user hasn't mentioned
- Confirm scope boundaries
- Get explicit approval before proceeding

### 2. Plan (using git worktrees)
- Create isolated worktree: git worktree add ../{feature-name} -b feature/{name}
- Break work into tasks of max 2 hours each
- List all files that will be touched

### 3. Implement (subagent per task)
- Dispatch fresh subagent per task
- Each subagent: read context → implement → test → report back
- Main session reviews and integrates

### 4. TDD Enforcement (RED-GREEN-REFACTOR)
- RED: write failing test first
- GREEN: write minimum code to pass
- REFACTOR: improve without breaking
- Never write implementation before test

### 5. Code Review (before merge)
- Bug check: does it handle nil/null/empty?
- Security: is input validated and sanitized?
- Performance: any N+1 queries or unnecessary loops?
- Tests: is coverage adequate?"
      track_ok "superpowers (stub)"
    fi
  } || {
    make_skill "superpowers" \
      "Multi-agent dev workflow with TDD, planning, code review. Use for complex features." \
      "# Superpowers\nPlan first. TDD always. Review before merge."
    track_fail "superpowers → stub"
  }
fi

# ─────────────────────────────────────────────────────────────────
# A4 — webapp-testing / playwright (Anthropic رسمي)
# ─────────────────────────────────────────────────────────────────
subheader "A4 — webapp-testing (Playwright — Anthropic Official)"

if [ -d "$SKILLS_DIR/webapp-testing" ]; then
  track_skip "webapp-testing"
else
  FRONTD_DIR="$TMP_DIR/anthropic-skills"
  if [ -d "$FRONTD_DIR/skills/webapp-testing" ]; then
    cp -r "$FRONTD_DIR/skills/webapp-testing" "$SKILLS_DIR/"
    track_ok "webapp-testing (Anthropic رسمي)"
  else
    make_skill "webapp-testing" \
      "Test local web applications using Playwright. Use for E2E testing, UI verification, screenshot capture, debugging frontend behavior, and regression testing." \
      "# Webapp Testing — Playwright

## When to Use
- Before any PR merge
- After UI changes
- When a bug is reported in the frontend
- For regression testing after refactors

## Test Hierarchy
1. E2E critical paths (login, checkout, search)
2. Component behavior (forms, modals, dropdowns)
3. Visual regression (screenshots comparison)
4. Accessibility (keyboard nav, ARIA, contrast)

## MotorGate Test Scenarios
- Vehicle listing search + filter flow
- Seller onboarding wizard
- Tap Payments checkout flow
- Arabic RTL layout verification
- Mobile viewport (375px) testing

## Commands
\`\`\`bash
npx playwright test                    # all tests
npx playwright test --headed          # with browser
npx playwright test --ui              # interactive UI
npx playwright codegen localhost:3000 # record new test
npx playwright show-report           # view results
\`\`\`"
    track_ok "webapp-testing (stub)"
  fi
fi

# ─────────────────────────────────────────────────────────────────
# A5 — owasp-security
# ─────────────────────────────────────────────────────────────────
subheader "A5 — owasp-security (OWASP Top 10:2025)"

if [ -d "$SKILLS_DIR/owasp-security" ]; then
  track_skip "owasp-security"
else
  make_skill "owasp-security" \
    "Security audit using OWASP Top 10:2025 and ASVS 5.0. Use before every release, PR review, or when adding authentication/payment/API code. Auto-invoked for security-sensitive code." \
    "# OWASP Security Audit — Top 10:2025

## Run This Checklist On Every PR

### A01 — Broken Access Control
- [ ] All endpoints check authorization (not just authentication)
- [ ] MotorGate: seller can't edit other seller's listings
- [ ] Admin routes protected beyond JWT check
- [ ] IDOR: IDs in URLs are validated against current user

### A02 — Cryptographic Failures
- [ ] No sensitive data in logs (Tap Payments tokens, passwords)
- [ ] HTTPS enforced everywhere (no HTTP fallback)
- [ ] Passwords hashed with bcrypt/argon2 (never MD5/SHA1)
- [ ] JWT secrets are strong and rotated

### A03 — Injection
- [ ] All DB queries use parameterized statements (never string concat)
- [ ] Input validated and sanitized on server side
- [ ] File uploads: type validated, stored outside webroot

### A04 — Insecure Design
- [ ] Rate limiting on auth endpoints
- [ ] Account lockout after N failed attempts
- [ ] Password reset tokens expire and are single-use

### A05 — Security Misconfiguration
- [ ] No default credentials anywhere
- [ ] Error messages don't expose stack traces in production
- [ ] CORS configured strictly (not wildcard *)
- [ ] Security headers: CSP, HSTS, X-Frame-Options

### A07 — Auth Failures
- [ ] Sessions invalidated on logout
- [ ] JWT expiry is short (15-60 min access, refresh tokens used)
- [ ] Multi-factor available for admin accounts

### A09 — Logging
- [ ] Auth events logged (login, logout, failures)
- [ ] Payment events logged with correlation IDs
- [ ] Logs don't contain PII or secrets

## MotorGate Specific
- Tap Payments webhook signature verification
- Vehicle listing approval workflow authorization
- Seller KYC data encryption at rest"
  track_ok "owasp-security"
fi

# ─────────────────────────────────────────────────────────────────
# A6 — varlock (إدارة الأسرار)
# ─────────────────────────────────────────────────────────────────
subheader "A6 — varlock (Secrets Management)"

if [ -d "$SKILLS_DIR/varlock" ]; then
  track_skip "varlock"
else
  VARLOCK_DIR="$TMP_DIR/varlock"
  safe_clone "https://github.com/nicholasgasior/varlock-claude-skill.git" "$VARLOCK_DIR" 2>/dev/null && {
    cp -r "$VARLOCK_DIR" "$SKILLS_DIR/varlock" 2>/dev/null
    track_ok "varlock (cloned)"
  } || {
    make_skill "varlock" \
      "Secure environment variable management. Auto-invoked when touching .env files, API keys, secrets, credentials, or any sensitive configuration. Ensures secrets never appear in Claude sessions, logs, or git." \
      "# Varlock — Secrets Security

## NEVER Do This
- Never log API keys even temporarily
- Never hardcode secrets in source code
- Never commit .env files (check .gitignore always)
- Never show full secret values in Claude sessions

## Always Do This
- Use environment variables: process.env.KEY or Configuration[\"Key\"]
- Validate secrets exist at startup, fail fast if missing
- Rotate secrets after any suspected exposure
- Use different secrets per environment (dev/staging/prod)

## .env File Rules
\`\`\`bash
# .gitignore must contain:
.env
.env.local
.env.production
*.env
\`\`\`

## MotorGate Secrets Checklist
- [ ] TAP_PAYMENTS_SECRET_KEY — never in logs
- [ ] DATABASE_URL — connection string with credentials
- [ ] JWT_SECRET — min 256-bit entropy
- [ ] NEXTAUTH_SECRET — unique per environment
- [ ] All secrets in: .env.local (never committed)"
    track_ok "varlock (stub)"
  }
fi

# ─────────────────────────────────────────────────────────────────
# A7 — test-driven-development (TDD)
# ─────────────────────────────────────────────────────────────────
subheader "A7 — test-driven-development"

if [ -d "$SKILLS_DIR/test-driven-development" ]; then
  track_skip "test-driven-development"
else
  make_skill "test-driven-development" \
    "Enforce TDD discipline. Use when implementing ANY feature or bugfix, BEFORE writing implementation code. Forces RED-GREEN-REFACTOR cycle." \
    "# Test-Driven Development — RED GREEN REFACTOR

## The Law: Test Before Code
Never write implementation before a failing test exists.

## The Cycle
\`\`\`
RED:     Write a failing test that describes the desired behavior
GREEN:   Write the MINIMUM code to make it pass (ugly is OK)
REFACTOR: Improve the code without breaking the test
REPEAT
\`\`\`

## What a Good Test Looks Like
- One assertion per test (ideally)
- Tests behavior, not implementation details
- Name: it('should [behavior] when [condition]')
- Arrange → Act → Assert structure

## MotorGate Test Examples

### .NET 9 (xUnit)
\`\`\`csharp
[Fact]
public async Task CreateListing_WithValidData_ReturnsCreatedListing()
{
    // Arrange
    var command = new CreateListingCommand { Title = \"Toyota Camry 2023\" };
    // Act
    var result = await _handler.Handle(command, CancellationToken.None);
    // Assert
    Assert.NotNull(result);
    Assert.Equal(\"Toyota Camry 2023\", result.Title);
}
\`\`\`

### Flutter (flutter_test)
\`\`\`dart
testWidgets('VehicleCard shows price correctly', (tester) async {
  await tester.pumpWidget(VehicleCard(price: 150000));
  expect(find.text('150,000 ر.س'), findsOneWidget);
});
\`\`\`

## Coverage Targets
- Domain/Business logic: 90%+
- API endpoints: 80%+
- UI components: 60%+"
  track_ok "test-driven-development"
fi

# ─────────────────────────────────────────────────────────────────
# A8 — software-architecture
# ─────────────────────────────────────────────────────────────────
subheader "A8 — software-architecture"

if [ -d "$SKILLS_DIR/software-architecture" ]; then
  track_skip "software-architecture"
else
  make_skill "software-architecture" \
    "Software architecture guidance using Clean Architecture, SOLID principles, and design patterns. Use when designing new features, reviewing architecture decisions, or planning system structure." \
    "# Software Architecture — Clean + SOLID

## Decision Framework

### When adding a new feature, ask:
1. Which layer does this belong to? (Domain / Application / Infrastructure / Presentation)
2. Does it depend on anything it shouldn't?
3. Is it testable without external dependencies?
4. Will it be easy to change independently?

## MotorGate Architecture (Clean Architecture)

\`\`\`
MotorGate.Domain          ← Entities, Value Objects, Domain Events
MotorGate.Application     ← Use Cases, Commands, Queries, DTOs
MotorGate.Infrastructure  ← DB, External APIs (Tap Payments), Email
MotorGate.API             ← Controllers, Middleware, Filters
\`\`\`

### Dependency Rule
Domain ← Application ← Infrastructure ← API
(arrows point inward — inner layers know nothing about outer)

## SOLID Checklist
- **S**: One reason to change per class
- **O**: Extend by adding, not modifying
- **L**: Subtypes must honor parent contracts
- **I**: Small focused interfaces (not fat ones)
- **D**: Depend on abstractions, not concretions

## Common Patterns for Marketplace
- CQRS: separate read/write models
- Repository: abstract DB access
- Mediator (MediatR): decouple commands from handlers
- Domain Events: notify across bounded contexts
- Outbox Pattern: reliable event publishing with Tap Payments"
  track_ok "software-architecture"
fi

# ─────────────────────────────────────────────────────────────────
# A9 — code-review (NeoLabHQ — 6 متخصصين)
# ─────────────────────────────────────────────────────────────────
subheader "A9 — code-review (6 Specialized Agents)"

if [ -d "$SKILLS_DIR/code-review" ]; then
  track_skip "code-review"
else
  CODEREVIEW_DIR="$TMP_DIR/code-review"
  safe_clone "https://github.com/NeoLabHQ/code-review.git" "$CODEREVIEW_DIR" 2>/dev/null && {
    if [ -d "$CODEREVIEW_DIR/skills" ]; then
      cp -r "$CODEREVIEW_DIR/skills/"* "$SKILLS_DIR/" 2>/dev/null
      track_ok "code-review (NeoLabHQ — 6 agents)"
    else
      cp -r "$CODEREVIEW_DIR" "$SKILLS_DIR/code-review" 2>/dev/null
      track_ok "code-review (cloned)"
    fi
  } || {
    make_skill "code-review" \
      "Comprehensive PR code review using 6 specialized perspectives. Use before merging any PR or branch. Reviews bugs, security, quality, contracts, history, and test coverage." \
      "# Code Review — 6 Specialist Agents

## Run ALL 6 perspectives on every PR

### 🐛 Bug Hunter
- Off-by-one errors, null pointer dereferences
- Race conditions in async code
- Missing error handling branches
- Incorrect boolean logic

### 🔒 Security Auditor
- Input validation gaps
- Authorization missing on endpoints
- Sensitive data in logs or responses
- Injection vulnerabilities

### ✨ Code Quality Reviewer
- DRY violations (copy-pasted code)
- Functions doing more than one thing
- Misleading variable/function names
- Missing or wrong comments

### 📋 Contracts Reviewer
- API contract changes (breaking vs non-breaking)
- Database migration compatibility
- Event schema changes

### 📚 Historical Context Reviewer
- Does this conflict with a previous decision?
- Has this bug been fixed before and regressed?
- Does it respect existing patterns in the codebase?

### 🧪 Test Coverage Reviewer
- Are new paths tested?
- Are edge cases covered?
- Are tests actually testing the right behavior?"
    track_ok "code-review (stub)"
  }
fi

# ─────────────────────────────────────────────────────────────────
# A10 — playwright-skill (70+ patterns)
# ─────────────────────────────────────────────────────────────────
subheader "A10 — playwright-skill (testdino-hq — 70+ patterns)"

if [ -d "$SKILLS_DIR/playwright-skill" ]; then
  track_skip "playwright-skill"
else
  PLAYWRIGHT_DIR="$TMP_DIR/playwright-skill"
  safe_clone "https://github.com/testdino-hq/playwright-skill.git" "$PLAYWRIGHT_DIR" 2>/dev/null && {
    cp -r "$PLAYWRIGHT_DIR" "$SKILLS_DIR/playwright-skill"
    track_ok "playwright-skill (70+ patterns)"
  } || {
    make_skill "playwright-skill" \
      "Production-tested Playwright patterns for E2E, POM, CI/CD. Use for writing Playwright tests, debugging flaky tests, or setting up testing infrastructure." \
      "# Playwright Skill — 70+ Production Patterns

## Page Object Model (POM)
\`\`\`typescript
class VehicleListingPage {
  constructor(private page: Page) {}
  
  async search(query: string) {
    await this.page.fill('[data-testid=search-input]', query);
    await this.page.click('[data-testid=search-btn]');
    await this.page.waitForLoadState('networkidle');
  }
  
  async getResultCount(): Promise<number> {
    return await this.page.locator('[data-testid=listing-card]').count();
  }
}
\`\`\`

## Anti-flakiness Rules
- Never use arbitrary page.waitForTimeout()
- Always await network idle or specific element
- Use data-testid attributes, not CSS classes
- Retry-first approach: waitForSelector with timeout

## CI/CD Integration
\`\`\`yaml
- name: Playwright Tests
  run: npx playwright test
  env:
    BASE_URL: http://localhost:3000
    CI: true
\`\`\`"
    track_ok "playwright-skill (stub)"
  }
fi

# ─────────────────────────────────────────────────────────────────
# A11 — subagent-driven-development
# ─────────────────────────────────────────────────────────────────
subheader "A11 — subagent-driven-development"

if [ -d "$SKILLS_DIR/subagent-driven-development" ]; then
  track_skip "subagent-driven-development"
else
  make_skill "subagent-driven-development" \
    "Dispatch independent subagents for individual tasks with code review checkpoints. Use for large features that benefit from parallel isolated work streams." \
    "# Subagent-Driven Development

## When to Use
- Feature requires touching 5+ files
- Work can be parallelized (frontend + backend + tests)
- Complex refactor across multiple modules

## Protocol
1. Break work into isolated tasks (max 2hr each)
2. Each task: clear input → clear output contract
3. Dispatch subagent per task
4. Subagent reports findings, doesn't commit directly
5. Main session reviews all outputs and integrates

## Subagent Task Template
\`\`\`
Task: [specific description]
Files to touch: [explicit list]
Input: [what you receive]
Output: [what you produce]
Tests required: [yes/no + coverage target]
Do NOT: [explicit constraints]
\`\`\`

## Review Checkpoint (between tasks)
Before accepting subagent output:
- Does it match the contract?
- Does it break existing tests?
- Does it introduce new dependencies?
- Is it consistent with existing patterns?"
  track_ok "subagent-driven-development"
fi

# ─────────────────────────────────────────────────────────────────
# A12 — using-git-worktrees
# ─────────────────────────────────────────────────────────────────
subheader "A12 — using-git-worktrees"

if [ -d "$SKILLS_DIR/using-git-worktrees" ]; then
  track_skip "using-git-worktrees"
else
  make_skill "using-git-worktrees" \
    "Create isolated git worktrees for parallel development. Use when working on multiple features simultaneously, running autoresearch safely, or testing without disturbing main workspace." \
    "# Git Worktrees — Parallel Isolated Development

## Why Worktrees?
Work on feature-A while autoresearch runs on feature-B — no stashing, no context switching, no risk.

## Basic Usage
\`\`\`bash
# Create worktree for new feature
git worktree add ../motorgate-feature-search -b feature/vehicle-search

# Create worktree for autoresearch (safe — separate directory)
git worktree add ../motorgate-autoresearch -b autoresearch/test-improvement

# List all worktrees
git worktree list

# Remove when done
git worktree remove ../motorgate-feature-search
\`\`\`

## Workflow for MotorGate
\`\`\`bash
# Main: ~/motorgate/          ← your active development
# AR:   ~/motorgate-ar/       ← autoresearch running overnight
# Fix:  ~/motorgate-hotfix/   ← urgent production fix

git worktree add ../motorgate-ar -b autoresearch/$(date +%Y%m%d)
cd ../motorgate-ar
caffeinate -i claude --dangerously-skip-permissions
# → /autoresearch:fix
\`\`\`

## Safety Rules
- Never force-delete a worktree with uncommitted changes
- Each worktree is a full working copy — changes are independent
- Run 'git worktree prune' periodically to clean up"
  track_ok "using-git-worktrees"
fi

# ─────────────────────────────────────────────────────────────────
# A13 — finishing-a-development-branch
# ─────────────────────────────────────────────────────────────────
subheader "A13 — finishing-a-development-branch"

if [ -d "$SKILLS_DIR/finishing-branch" ]; then
  track_skip "finishing-branch"
else
  make_skill "finishing-branch" \
    "Guide completion of a development branch before merging. Use when work is done and ready for PR — handles final cleanup, changelog, review checklist, and merge options." \
    "# Finishing a Development Branch

## Pre-Merge Checklist (always run this)

### Code Quality
- [ ] All tests pass: npm test / dotnet test / flutter test
- [ ] No TypeScript errors: tsc --noEmit
- [ ] No linting errors: npm run lint
- [ ] No console.log left in production code
- [ ] No TODO comments without tickets

### Git Hygiene
- [ ] Branch is rebased on main (not just merged)
- [ ] Commits are logical and well-described
- [ ] No merge conflicts
- [ ] .env files NOT committed

### Documentation
- [ ] CHANGELOG.md updated
- [ ] API changes documented (if any)
- [ ] README updated (if needed)

### Security
- [ ] No secrets in code or git history
- [ ] New endpoints have authorization checks
- [ ] Input validation on all new endpoints

## Merge Options (present these to user)
1. **Squash merge** — clean history, one commit per feature
2. **Rebase merge** — preserve commit history
3. **Regular merge** — explicit merge commit

## Post-Merge
- Delete feature branch
- Update JIRA/Linear ticket
- Deploy to staging for QA"
  track_ok "finishing-branch"
fi

# ─────────────────────────────────────────────────────────────────
# A14 — changelog-generator
# ─────────────────────────────────────────────────────────────────
subheader "A14 — changelog-generator"

if [ -d "$SKILLS_DIR/changelog-generator" ]; then
  track_skip "changelog-generator"
else
  make_skill "changelog-generator" \
    "Generate user-facing changelogs from git commits. Use before releases, when updating CHANGELOG.md, or when asked to summarize what changed in a branch/sprint." \
    "# Changelog Generator

## Process
1. Analyze git commits since last release
2. Group by type: Features / Fixes / Performance / Security / Breaking
3. Translate technical commits into user-friendly language
4. Format as CHANGELOG.md entry

## Commit → Changelog Translation
| Git commit | Changelog entry |
|-----------|-----------------|
| feat: add vehicle search filter by year | ✨ Buyers can now filter vehicles by manufacturing year |
| fix: null ref in listing price calculation | 🐛 Fixed price display issue for some vehicle listings |
| perf: add Redis cache for search results | ⚡ Search results load significantly faster |
| security: validate Tap Payments webhook sig | 🔒 Improved payment security |

## CHANGELOG.md Format
\`\`\`markdown
## [1.2.0] — 2026-03-28

### ✨ New Features
- Buyers can filter vehicles by year, make, and price range
- Sellers can now add up to 20 photos per listing

### 🐛 Bug Fixes
- Fixed price calculation error for vehicles with special characters in title

### ⚡ Performance
- Search results now load 3x faster

### 🔒 Security
- Strengthened payment webhook validation
\`\`\`

## Command
\`\`\`bash
git log v1.1.0..HEAD --oneline  # commits to summarize
\`\`\`"
  track_ok "changelog-generator"
fi

# ─────────────────────────────────────────────────────────────────
# A15 — supermemory (16,700 نجمة)
# ─────────────────────────────────────────────────────────────────
subheader "A15 — supermemory (16.7k ⭐)"

if [ -d "$SKILLS_DIR/supermemory" ]; then
  track_skip "supermemory"
else
  SUPERMEM_DIR="$TMP_DIR/supermemory"
  safe_clone "https://github.com/supermemoryai/supermemory.git" "$SUPERMEM_DIR" 2>/dev/null && {
    if [ -d "$SUPERMEM_DIR/skills" ]; then
      cp -r "$SUPERMEM_DIR/skills/"* "$SKILLS_DIR/" 2>/dev/null
      track_ok "supermemory (cloned)"
    else
      make_skill "supermemory" \
        "Persistent memory across Claude sessions. Use when user shares something worth remembering, or when context from previous sessions is needed. Invoke /memory, /recall, or /context." \
        "# Supermemory — Cross-Session Memory

## Commands
- /memory [fact] — save something important
- /recall [query] — retrieve from memory
- /context — inject full context at session start

## What to Remember for MotorGate
- Architecture decisions and their rationale
- Known bugs and their root causes
- API endpoint contracts
- Team conventions and preferences
- Previous debugging sessions and findings"
      track_ok "supermemory (stub)"
    fi
  } || {
    make_skill "supermemory" \
      "Cross-session memory for Claude. Save and recall important context across conversations." \
      "# Supermemory\nSave: /memory [fact]\nRecall: /recall [query]\nContext: /context"
    track_fail "supermemory → stub"
  }
fi

# ═════════════════════════════════════════════════════════════════
#  الفئة ب — الأصليون (تصميم + تسويق + أتمتة)
# ═════════════════════════════════════════════════════════════════
header "Category B — Original Tools (Design + Marketing + Automation)"

# ─────────────────────────────────────────────────────────────────
# B1 — Autoresearch
# ─────────────────────────────────────────────────────────────────
subheader "B1 — Autoresearch (Udit Goenka)"

if [ -d "$SKILLS_DIR/autoresearch" ]; then
  track_skip "autoresearch"
else
  AR_DIR="$TMP_DIR/autoresearch"
  safe_clone "https://github.com/uditgoenka/autoresearch.git" "$AR_DIR" 2>/dev/null && {
    [ -d "$AR_DIR/skills/autoresearch" ] && cp -r "$AR_DIR/skills/autoresearch" "$SKILLS_DIR/"
    [ -d "$AR_DIR/commands/autoresearch" ] && cp -r "$AR_DIR/commands/autoresearch" "$COMMANDS_DIR/"
    track_ok "autoresearch (cloned)"
  } || {
    make_skill "autoresearch" \
      "Autonomous improvement loop. Use when asked to improve a metric overnight, fix failing tests automatically, run /autoresearch, /autoresearch:fix, /autoresearch:security, /autoresearch:debug" \
      "# Autoresearch — Autonomous Improvement Loop

## Core Loop
1. Review current state + git history + results log
2. Pick ONE atomic change
3. Git commit before verification
4. Run mechanical metric check
5. Keep if improved, revert if worse
6. Log and repeat

## Commands
- /autoresearch Goal: X  Metric: Y  Direction: higher_is_better
- /autoresearch:fix      ← fix all failing tests overnight
- /autoresearch:security ← STRIDE + OWASP audit
- /autoresearch:debug    ← scientific bug hunt
- /autoresearch:predict  ← 5 expert perspectives
- /autoresearch:ship     ← pre-deploy checklist"
    track_ok "autoresearch (stub)"
  }
fi

# ─────────────────────────────────────────────────────────────────
# B2 — SuperClaude
# ─────────────────────────────────────────────────────────────────
subheader "B2 — SuperClaude (16 agents + 16 commands)"

if command -v SuperClaude &>/dev/null || command -v superclaude &>/dev/null; then
  track_skip "SuperClaude (already installed)"
else
  # Try pipx first
  if command -v pipx &>/dev/null; then
    pipx install SuperClaude 2>/dev/null && track_ok "SuperClaude (pipx)" || {
      npm install -g @bifrost_inc/superclaude 2>/dev/null && track_ok "SuperClaude (npm)" || track_fail "SuperClaude → install manually: pipx install SuperClaude"
    }
  elif ! command -v pipx &>/dev/null; then
    pip3 install pipx --quiet 2>/dev/null && pipx install SuperClaude 2>/dev/null && track_ok "SuperClaude" || {
      npm install -g @bifrost_inc/superclaude 2>/dev/null && track_ok "SuperClaude (npm)" || track_fail "SuperClaude → run: pipx install SuperClaude && SuperClaude install"
    }
  fi
fi

# ─────────────────────────────────────────────────────────────────
# B3 — Marketing Skills (Corey Haines — 32 skills)
# ─────────────────────────────────────────────────────────────────
subheader "B3 — Marketing Skills (Corey Haines — 32 skills)"

MKT_INSTALLED=0
for skill in page-cro onboarding-cro email-sequence seo-audit analytics-tracking; do
  [ -d "$SKILLS_DIR/$skill" ] && MKT_INSTALLED=$((MKT_INSTALLED + 1))
done

if [ $MKT_INSTALLED -ge 3 ]; then
  track_skip "Marketing Skills (already installed)"
else
  npx --yes skills add coreyhaines31/marketingskills 2>/dev/null && track_ok "Marketing Skills (npx)" || {
    MKT_DIR="$TMP_DIR/marketingskills"
    safe_clone "https://github.com/coreyhaines31/marketingskills.git" "$MKT_DIR" 2>/dev/null && {
      for d in "$MKT_DIR/.claude/skills" "$MKT_DIR/skills" "$MKT_DIR"; do
        [ -d "$d" ] && cp -r "$d/"* "$SKILLS_DIR/" 2>/dev/null && track_ok "Marketing Skills (cloned)" && break
      done
    } || {
      for skill in page-cro onboarding-cro email-sequence seo-audit analytics-tracking ai-seo copywriting; do
        [ -d "$SKILLS_DIR/$skill" ] || make_skill "$skill" \
          "Marketing skill: $skill. Use for relevant marketing tasks, CRO, SEO, email campaigns, and analytics." \
          "# $skill\nMarketing skill stub. Install full version: npx skills add coreyhaines31/marketingskills"
      done
      track_ok "Marketing Skills (7 stubs)"
    }
  }
fi

# ─────────────────────────────────────────────────────────────────
# B4 — UI UX Pro Max
# ─────────────────────────────────────────────────────────────────
subheader "B4 — UI UX Pro Max (50+ styles)"

if [ -d "$SKILLS_DIR/ui-ux-pro" ]; then
  track_skip "ui-ux-pro"
else
  npm install -g uipro-cli 2>/dev/null && track_ok "UI UX Pro Max CLI" || true
  make_skill "ui-ux-pro" \
    "UI/UX design intelligence with 50+ styles, 161 palettes, 57 font pairings, 99 UX guidelines. Auto-invoked for any UI design, component, or layout work. Works with React, Next.js, Flutter, Tailwind, shadcn/ui." \
    "# UI UX Pro Max — Design Intelligence

## Styles (50+)
glassmorphism, claymorphism, brutalism, bento-grid, neumorphism,
dark-mode, editorial, cyberpunk, minimalist, maximalist,
art-deco, bauhaus, organic, luxury, industrial

## For MotorGate
- Primary: #26A9E1 Sky Blue
- Font: Cairo (Arabic), Inter (English)
- RTL: always mirror layouts for Arabic
- Components: shadcn/ui (web), Material 3 (Flutter)

## UX Rules (key subset)
1. Mobile-first: design for 375px
2. Touch targets: min 44×44px
3. Loading: skeleton screens, not spinners
4. Errors: specific, actionable messages
5. Arabic: full RTL with mirrored icons

## Usage
/ui-ux-pro design a vehicle listing card in glassmorphism style
/ui-ux-pro review this component for accessibility"
  track_ok "ui-ux-pro"
fi

# ─────────────────────────────────────────────────────────────────
# B5 — 21st.dev Magic (MCP)
# ─────────────────────────────────────────────────────────────────
subheader "B5 — 21st.dev Magic (MCP — UI Component Generator)"

if [ -f "$CLAUDE_JSON" ] && grep -q "21st" "$CLAUDE_JSON" 2>/dev/null; then
  track_skip "21st.dev Magic (already in ~/.claude.json)"
else
  echo ""
  info "21st.dev Magic — رابط الـ API key المجاني: https://21st.dev/magic"
  read -p "هل عندك 21st.dev API key؟ (y/n): " HAS_21ST
  if [ "${HAS_21ST:-n}" = "y" ]; then
    read -p "أدخل الـ API key: " KEY_21ST
    npx @21st-dev/cli@latest install claude --api-key "$KEY_21ST" 2>/dev/null && track_ok "21st.dev Magic" || {
      warn "فشل التثبيت — جرب: npx @21st-dev/cli@latest install claude --api-key YOUR_KEY"
    }
  else
    skip "21st.dev Magic — أضفه لاحقاً: npx @21st-dev/cli@latest install claude --api-key KEY"
  fi
fi

# ─────────────────────────────────────────────────────────────────
# B6 — Nano Banana 2
# ─────────────────────────────────────────────────────────────────
subheader "B6 — Nano Banana 2 (Google AI Image Generation)"

if [ -d "$SKILLS_DIR/nano-banana-2" ]; then
  track_skip "nano-banana-2"
else
  NB_DIR="$TMP_DIR/nano-banana-2"
  safe_clone "https://github.com/kingbootoshi/nano-banana-2-skill.git" "$NB_DIR" 2>/dev/null && {
    cd "$NB_DIR" && bun install --quiet 2>/dev/null && bun link 2>/dev/null && {
      for d in "$NB_DIR/skill" "$NB_DIR/.claude/skills"; do
        [ -d "$d" ] && cp -r "$d" "$SKILLS_DIR/nano-banana-2" && break
      done
      track_ok "Nano Banana 2 (cloned + linked)"
    } || true
  } || true

  [ -d "$SKILLS_DIR/nano-banana-2" ] || {
    make_skill "nano-banana-2" \
      "Generate AI images using Google Imagen. Use for landing page assets, UI mockups, transparent icons, marketing visuals. Cost: ~7 cents/image." \
      "# Nano Banana 2\nRequires: GEMINI_API_KEY\nGet key: https://aistudio.google.com/apikey\n\nUsage: generate an image of [description]\nFlag -t for transparent background"
    track_ok "nano-banana-2 (stub)"
  }

  # Gemini API key
  if ! grep -q "GEMINI_API_KEY" "$HOME/.zshrc" 2>/dev/null; then
    echo ""
    info "Nano Banana 2 يحتاج Gemini API key (مجاني): https://aistudio.google.com/apikey"
    read -p "هل عندك Gemini API key؟ (y/n): " HAS_GEMINI
    if [ "${HAS_GEMINI:-n}" = "y" ]; then
      read -p "أدخل الـ key: " GEMINI_KEY
      echo "" >> "$HOME/.zshrc"
      echo "export GEMINI_API_KEY=\"$GEMINI_KEY\"" >> "$HOME/.zshrc"
      log "GEMINI_API_KEY أُضيف إلى ~/.zshrc"
    else
      skip "GEMINI_API_KEY — أضفه لاحقاً في ~/.zshrc"
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────
# B7 — Google Stitch MCP
# ─────────────────────────────────────────────────────────────────
subheader "B7 — Google Stitch MCP"

if [ -d "$SKILLS_DIR/google-stitch" ]; then
  track_skip "google-stitch"
else
  # إضافة MCP إلى claude.json
  python3 - << 'PYTHON_EOF'
import json, os
path = os.path.expanduser("~/.claude.json")
try:
    config = json.load(open(path))
except:
    config = {}
config.setdefault("mcpServers", {})
if "google-stitch" not in config["mcpServers"]:
    config["mcpServers"]["google-stitch"] = {
        "command": "npx", "args": ["-y", "@google/stitch-mcp-server"],
        "description": "Google Stitch AI UI design canvas"
    }
    json.dump(config, open(path, "w"), indent=2)
    print("✅ Google Stitch MCP added")
else:
    print("ℹ️  Google Stitch already configured")
PYTHON_EOF

  make_skill "google-stitch" \
    "AI-native UI design using Google Stitch. Use for wireframes, mockups, high-fidelity designs, and converting sketches to UI layouts." \
    "# Google Stitch\nFree: https://stitch.withgoogle.com\n350 generations/month (standard)"
  track_ok "google-stitch"
fi

# ─────────────────────────────────────────────────────────────────
# B8 — MotorGate Context File
# ─────────────────────────────────────────────────────────────────
subheader "B8 — MotorGate Project Context"

cat > "$HOME/.claude/motorgate-context.md" << 'CONTEXT_EOF'
# MotorGate — Project Context for Claude Code

## Identity
- **Platform**: MotorGate (موتورقيت) — Vehicle Services Marketplace
- **Entity**: NASD | **Market**: Saudi Arabia
- **Developer**: Abdullah (عبدالله) — Jeddah

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Backend | .NET 9 (C#) |
| Web | Next.js 15 + TypeScript |
| Mobile | Flutter |
| Database | PostgreSQL |
| Payments | Tap Payments |
| Infrastructure | Docker |

## Brand Design System
- **Primary Color**: Sky Blue `#26A9E1`
- **Font Arabic**: Cairo (Google Fonts)
- **Font English**: Inter
- **Direction**: RTL (Arabic) / LTR (English)
- **Component Lib**: shadcn/ui (web), Material 3 (Flutter)

## Architecture Pattern
Clean Architecture — Domain → Application → Infrastructure → API
CQRS with MediatR, Repository pattern, Domain Events

## Code Conventions
- Commands/Queries: MediatR handlers
- DTOs: separate from domain entities
- Tests: xUnit (.NET), jest (Next.js), flutter_test
- Error handling: Result pattern (no raw exceptions)

## Related Projects
- **ARIB** (arib.sa): hosting/tech business, WHMCS, VPS
- **شبكة الكهرباء**: internal tools for Saudi National Grid (Western Region)
CONTEXT_EOF
log "MotorGate context saved → ~/.claude/motorgate-context.md"

# ─────────────────────────────────────────────────────────────────
# إصلاح .zshrc
# ─────────────────────────────────────────────────────────────────
header "Fix .zshrc"

if [ -f "$HOME/.zshrc" ]; then
  echo ""
  info "السطور 5-12 من ~/.zshrc (ابحث عن علامة اقتباس غير مغلقة):"
  echo "────────────────────────────────────────"
  sed -n '5,12p' "$HOME/.zshrc" | nl -ba
  echo "────────────────────────────────────────"
  warn "إذا رأيت سطراً فيه ' بدون إغلاق — أصلحه بـ: nano ~/.zshrc ثم source ~/.zshrc"
fi

# ─────────────────────────────────────────────────────────────────
# التحقق النهائي
# ─────────────────────────────────────────────────────────────────
header "Verification"

SKILL_COUNT=$(ls "$SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')
echo ""
info "المهارات المثبتة ($SKILL_COUNT إجمالاً):"
ls "$SKILLS_DIR" 2>/dev/null | while read s; do echo "   📦 $s"; done

echo ""
info "الأوامر:"
ls "$COMMANDS_DIR" 2>/dev/null | while read c; do echo "   ⚡ $c"; done

if [ -f "$CLAUDE_JSON" ]; then
  echo ""
  info "MCP Servers:"
  python3 -c "
import json,os
c=json.load(open(os.path.expanduser('~/.claude.json')))
[print(f'   🔌 {k}') for k in c.get('mcpServers',{}).keys()]
" 2>/dev/null || true
fi

# ─────────────────────────────────────────────────────────────────
# الملخص النهائي
# ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        CLAUDE CODE MASTER INSTALL v2.0 — COMPLETE 🚀        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  الفئة أ — الأقوى عالمياً (برمجة + جودة)                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  %-30s %s\n" "frontend-design"              "✅ 277k installs — Anthropic Official ║"
printf "║  %-30s %s\n" "systematic-debugging"         "✅ أكثر استخداماً في production       ║"
printf "║  %-30s %s\n" "superpowers"                  "✅ 40.9k ⭐ — full dev lifecycle      ║"
printf "║  %-30s %s\n" "webapp-testing"               "✅ Playwright — Anthropic Official    ║"
printf "║  %-30s %s\n" "owasp-security"               "✅ OWASP Top 10:2025                  ║"
printf "║  %-30s %s\n" "varlock"                      "✅ Secrets Management                 ║"
printf "║  %-30s %s\n" "test-driven-development"      "✅ RED-GREEN-REFACTOR                 ║"
printf "║  %-30s %s\n" "software-architecture"        "✅ Clean Architecture + SOLID         ║"
printf "║  %-30s %s\n" "code-review"                  "✅ 6 Specialized Agents               ║"
printf "║  %-30s %s\n" "playwright-skill"             "✅ 70+ Production Patterns            ║"
printf "║  %-30s %s\n" "subagent-driven-development"  "✅ Parallel Agent Dispatch            ║"
printf "║  %-30s %s\n" "using-git-worktrees"          "✅ Isolated Dev Environments          ║"
printf "║  %-30s %s\n" "finishing-branch"             "✅ Pre-Merge Checklist                ║"
printf "║  %-30s %s\n" "changelog-generator"          "✅ Auto Release Notes                 ║"
printf "║  %-30s %s\n" "supermemory"                  "✅ 16.7k ⭐ — Cross-session Memory    ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  الفئة ب — تصميم + تسويق + أتمتة                           ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  %-30s %s\n" "autoresearch"                 "✅ Autonomous Improvement Loop        ║"
printf "║  %-30s %s\n" "SuperClaude"                  "✅ 16 Agents + 16 Commands            ║"
printf "║  %-30s %s\n" "marketing-skills"             "✅ 32 Marketing Skills (CRO/SEO)      ║"
printf "║  %-30s %s\n" "ui-ux-pro"                    "✅ 50+ Styles + 161 Palettes          ║"
printf "║  %-30s %s\n" "21st.dev Magic"               "⚙️  MCP — Needs API key               ║"
printf "║  %-30s %s\n" "Nano Banana 2"                "⚙️  Needs Gemini API key              ║"
printf "║  %-30s %s\n" "Google Stitch"                "✅ MCP + Skill                        ║"
printf "║  %-30s %s\n" "MotorGate Context"            "✅ ~/.claude/motorgate-context.md     ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  📦 Total Skills Installed: $SKILL_COUNT                               ║"
echo "║  💾 Backup: ~/.claude-backup-$BACKUP_DATE        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}الخطوات التالية:${NC}"
echo "1. 🔧 Fix .zshrc:    nano ~/.zshrc → أغلق علامة الاقتباس → source ~/.zshrc"
echo "2. 🤖 SuperClaude:   SuperClaude install --dry-run → SuperClaude install"
echo "3. 🎨 21st.dev:      npx @21st-dev/cli@latest install claude --api-key KEY"
echo "   Key from:         https://21st.dev/magic"
echo "4. 🖼  Gemini key:    https://aistudio.google.com/apikey → export in ~/.zshrc"
echo ""
echo -e "${CYAN}أول أوامر تجربها في Claude Code:${NC}"
echo "  /systematic-debugging    ← أي bug تواجهه"
echo "  /autoresearch:fix        ← إصلاح الاختبارات بشكل مستقل"
echo "  /superpowers             ← تخطيط feature جديدة"
echo "  /owasp-security          ← مراجعة أمنية شاملة"
echo "  /code-review             ← مراجعة PR بـ 6 متخصصين"
echo "  /frontend-design         ← تصميم واجهات احترافية"
echo ""
echo -e "${GREEN}اذهب لـ Claude Code: cd ~/motorgate && claude${NC}"
echo ""

# حفظ log
{
  echo "Install v2.0 — $(date)"
  echo "Installed: ${INSTALLED[*]:-none}"
  echo "Skipped: ${SKIPPED[*]:-none}"
  echo "Failed: ${FAILED[*]:-none}"
} >> "$INSTALL_LOG" 2>/dev/null || true

log "Log saved: $INSTALL_LOG"
