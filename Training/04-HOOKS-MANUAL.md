# Claude Code Methodology v3.2.0
## Hooks Manual: Complete User Guide

---

## v3.2 "Honest" — Active Hooks (read this first)

CCM ships actual enforcement hooks as of v3.2. Before v3.2, this manual described
patterns. As of v3.2, the patterns are wired up and running on every session.

### Advisory vs enforced

| Kind | Where | How it works | Bypassable? |
|------|-------|--------------|-------------|
| **Advisory** | `architecture/CONSTRAINTS.md`, `.claude/rules/*.md` | Claude reads them and *should* comply | Yes — model can violate |
| **Enforced** | `.claude/hooks/*.sh` | Run outside the agent loop, can block tool calls | No — kernel-level |

### Active hooks in v3.2

| Event | Script | What it does |
|-------|--------|--------------|
| `SessionStart` | `session-start.sh` | Hash CLAUDE.md (drift detection), warn on protected branch, capture session-start SHA |
| `PreToolUse` (Write/Edit/MultiEdit) | `pre-tool-use.sh` | Hard-deny `.git/`, `.env*`, `~/.ssh/`, `~/.aws/`; soft-scope via `architecture/CONTEXT_MAP.md` `allowed_write_paths`; secret-pattern scan (test/fixture paths exempt) |
| `PreToolUse` (Bash) | `pre-tool-use.sh` | Block dangerous commands (`rm -rf /`, fork bombs, force-push to main, `DROP DATABASE`, `curl \| sh`, etc.) |
| Git pre-commit | `pre-commit.sh` | Block credential files, secret patterns, oversized files (>1 MB), `console.log`/`debugger` in production source |
| `Stop` | `stop.sh` | Write per-session ledger entry to `io/ledger/`, optional CoWork ping |

### Installation

```bash
./scripts/install-hooks.sh
```

Idempotent. Verifies `jq`, `git`, `curl`. Smoke-tests `session-start.sh`. Wires
the git pre-commit hook to delegate to `.claude/hooks/pre-commit.sh`.

### CoWork notifications (opt-in)

```bash
export CCM_COWORK_WEBHOOK='https://your-cowork-endpoint/hook'
```

Empty/unset = no-op. The hooks never call out to anything by default.

### Adjusting allowed write paths

Edit `architecture/CONTEXT_MAP.md` between the markers:

```markdown
<!-- allowed_write_paths:start -->
- apps/
- packages/
<!-- allowed_write_paths:end -->
```

Paths are matched as prefixes against the absolute path resolved from
repo root. Hard-denied paths cannot be overridden through this list.

### Audit trail

- `io/hook-logs/YYYY-MM-DD.log` — every hook invocation. **Gitignored** (high volume).
- `io/ledger/session-<timestamp>.md` — per-session summary. **Committed** (this is the trail).

### Testing a hook before shipping

CCM ships a regression suite under `tests/fixtures/payloads/` and
`scripts/test-hooks.sh`. Run it before committing any hook change:

```bash
./scripts/test-hooks.sh
```

The suite asserts:
- Each documented guard fires on its negative case (e.g., `rm -rf /`,
  real secrets, eval on user input, hex literals in components).
- Each documented exemption holds (e.g., test fixtures, tokens/theme
  paths).
- Every hook script passes `bash -n` (syntax check).
- `.claude/settings.json` parses as JSON and has the expected hook shape.
- Autonomy guard no-ops when `CCM_AUTONOMY` is unset and activates when set.

**Adding a new guard:** add a fixture payload under
`tests/fixtures/payloads/` (one positive, one negative case is the
minimum), then add an assertion to `scripts/test-hooks.sh`. CI runs the
suite on every change to `.claude/hooks/**`, `.claude/settings.json`,
or `scripts/**`.

**Local debugging tip:** use `bash -x` to trace a hook against a
fixture:

```bash
cat tests/fixtures/payloads/pretooluse-bash-dangerous.json | bash -x .claude/hooks/pre-tool-use.sh
```

### Bypassing — when you must

1. **Update CONTEXT_MAP** for legitimate new directories.
2. **Run manually outside Claude Code** for one-off operations.
3. **`git commit --no-verify`** as a last resort. Leaves an audit gap; explain in the commit body.

Never edit hook scripts to lower the bar. If a hook is wrong, fix the hook.

---

## Legacy reference (pre-v3.2 patterns)

The sections below predate the v3.2 enforcement layer. They remain useful as a
reference catalog of hook patterns, but the canonical list of *currently active*
hooks is the table above.

---

---

## Table of Contents

1. [What Are Hooks?](#what-are-hooks)
2. [The 6 Hook Types](#the-6-hook-types)
3. [Hook Configuration](#hook-configuration)
4. [Exit Codes & Control Flow](#exit-codes--control-flow)
5. [The 7 Production-Ready Hook Recipes](#the-7-production-ready-hook-recipes)
6. [Creating Custom Hooks](#creating-custom-hooks)
7. [Debugging Hooks](#debugging-hooks)
8. [Real-World Examples](#real-world-examples)
9. [Best Practices](#best-practices)

---

## What Are Hooks?

**Hooks are safety gates** that run before or after specific actions in Claude Code. They act as your development team's immune system, preventing mistakes and enforcing standards automatically.

### Key Characteristics

- **Preventive**: Stop dangerous actions before they happen
- **Automated**: Run without requiring user intervention
- **Composable**: Multiple hooks can work together
- **Configurable**: Fine-tune to your team's standards
- **Safe**: Can block actions or just notify

### What Hooks Do

Hooks intercept:
- Tool executions (bash commands, file operations, API calls)
- Git operations (commits, pushes, branch changes)
- Session lifecycle events (start, summary, completion)
- System events (errors, notifications, deployments)

### Mental Model

Think of hooks like airport security:

```
Pre-Hooks (before action):          Post-Hooks (after action):
       ↓                                   ↓
Passenger approaches ──→ Security check ──→ Board plane
                         (hooks run here)

If suspicious:                       If problem detected:
Block & investigate                  Quarantine & notify
```

---

## The 6 Hook Types

### 1. PreToolUse Hook

**When it runs:** Before any tool executes (bash, file operations, API calls)

**What it can do:**
- Block dangerous commands (like `rm -rf`)
- Warn about security-sensitive operations
- Require confirmation for destructive actions
- Log all tool usage for auditing

**Example scenarios:**
- Prevent accidental deletion of important files
- Block unencrypted secrets transmission
- Require code review before pushing to production
- Validate database commands before execution

**Hook signature:**
```bash
#!/bin/bash
# Runs before tool execution
# Input: tool name and arguments
# Exit 0 = allow, 2 = block, other = block with error

TOOL_NAME=$1
shift
TOOL_ARGS=($@)

# Example: block rm -rf
if [[ "$TOOL_NAME" == "bash" ]] && [[ "${TOOL_ARGS[0]}" == "rm -rf" ]]; then
    exit 2  # Block this action
fi

exit 0  # Allow all other actions
```

---

### 2. PostToolUse Hook

**When it runs:** After any tool completes successfully

**What it can do:**
- Auto-format code after writes
- Run linters automatically
- Execute tests after file changes
- Clean up temporary files
- Update documentation automatically

**Example scenarios:**
- Auto-run Prettier after JavaScript files are saved
- Run ESLint to catch quality issues immediately
- Execute unit tests after implementation
- Update generated API documentation
- Format YAML/JSON configuration files

**Hook signature:**
```bash
#!/bin/bash
# Runs after tool execution
# Input: tool name, status, output
# Exit 0 = continue, non-zero = error

TOOL_NAME=$1
TOOL_STATUS=$2
TOOL_OUTPUT=$3

# Example: auto-format JavaScript
if [[ "$TOOL_NAME" == "bash" ]] && echo "$TOOL_OUTPUT" | grep -q "\.js"; then
    npx prettier --write $(echo "$TOOL_OUTPUT" | grep "\.js")
fi

exit 0  # Success
```

---

### 3. SessionStart Hook

**When it runs:** When a Claude Code session begins

**What it can do:**
- Load environment-specific configuration
- Set up project context
- Check prerequisites (Node version, dependencies, etc.)
- Display important project information
- Initialize session logging

**Example scenarios:**
- Load environment variables from `.env`
- Verify Node.js version matches project requirements
- Check that all dependencies are installed
- Display recent project changes or pending PRs
- Initialize performance profiling

**Hook signature:**
```bash
#!/bin/bash
# Runs at session start
# Exit 0 = success, non-zero = error

# Check Node.js version
NODE_VERSION=$(node -v)
REQUIRED_VERSION="v18.0.0"

if [[ "$NODE_VERSION" < "$REQUIRED_VERSION" ]]; then
    echo "Error: Node.js $REQUIRED_VERSION required, found $NODE_VERSION"
    exit 1
fi

# Set up environment
export PROJECT_ENV="development"
source .env 2>/dev/null || true

echo "✓ Session initialized with Node.js $NODE_VERSION"
exit 0
```

---

### 4. SessionSummarize Hook

**When it runs:** Before session context is compressed (automatic memory management)

**What it can do:**
- Save session summaries to persistent storage
- Extract important learnings
- Archive decisions made
- Update project documentation
- Generate session reports

**Example scenarios:**
- Save a summary of code changes made
- Archive important architectural decisions
- Update CHANGELOG with session work
- Generate performance metrics report
- Create incident report for critical fixes

**Hook signature:**
```bash
#!/bin/bash
# Runs on context compression
# Input: session data available
# Exit 0 = success

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S")
SESSION_SUMMARY="Session Summary - $TIMESTAMP

Key Changes:
- Modified X files
- Fixed Y bugs
- Added Z features
"

# Save to archive
echo "$SESSION_SUMMARY" >> .claude/session-archive.txt

exit 0
```

---

### 5. PreCommit Hook

**When it runs:** Before `git commit` is executed

**What it can do:**
- Run tests before committing
- Check code quality (linting, formatting)
- Scan for secrets before commit
- Verify branch policies
- Validate commit messages
- Block commits that don't meet standards

**Example scenarios:**
- Prevent commits with failing tests
- Block commits containing API keys
- Enforce commit message format
- Prevent direct commits to `main` branch
- Require test coverage threshold

**Hook signature:**
```bash
#!/bin/bash
# Runs before git commit
# Exit 0 = allow commit, 2 = block commit, other = error

# Example: run tests before commit
if ! npm test; then
    echo "✗ Tests failed. Commit blocked."
    exit 2  # Block commit
fi

# Example: check for secrets
if git diff --cached | grep -i "api.key\|password\|secret"; then
    echo "✗ Potential secrets detected. Commit blocked."
    exit 2  # Block commit
fi

exit 0  # Allow commit
```

---

### 6. Notification Hook

**When it runs:** On specific events (deployments, errors, milestones)

**What it can do:**
- Send Slack notifications
- Trigger webhooks
- Send email alerts
- Update issue trackers
- Log to monitoring systems
- Create alerts for anomalies

**Example scenarios:**
- Notify team when code is deployed to production
- Alert on failed tests in CI/CD
- Send a Slack message when major refactoring completes
- Notify on performance regressions
- Create GitHub issues for critical bugs

**Hook signature:**
```bash
#!/bin/bash
# Runs on specific events
# Input: event type and details
# Exit 0 = success

EVENT_TYPE=$1
EVENT_DETAILS=$2

case "$EVENT_TYPE" in
    "deployment")
        curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK \
            -d "{\"text\": \"Deployment complete: $EVENT_DETAILS\"}"
        ;;
    "test_failure")
        curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK \
            -d "{\"text\": \"Test failure detected: $EVENT_DETAILS\"}"
        ;;
esac

exit 0
```

---

## Hook Configuration

### Configuration File: `.claude/settings.json`

Create this file in your project root to configure hooks:

```json
{
  "hooks": {
    "pre-tool-use": {
      "enabled": true,
      "script": "./.claude/hooks/pre-tool-use.sh",
      "timeout": 30
    },
    "post-tool-use": {
      "enabled": true,
      "script": "./.claude/hooks/post-tool-use.sh",
      "timeout": 60
    },
    "session-start": {
      "enabled": true,
      "script": "./.claude/hooks/session-start.sh",
      "timeout": 30
    },
    "session-summarize": {
      "enabled": true,
      "script": "./.claude/hooks/session-summarize.sh",
      "timeout": 60
    },
    "pre-commit": {
      "enabled": true,
      "script": "./.claude/hooks/pre-commit.sh",
      "timeout": 120
    },
    "notification": {
      "enabled": true,
      "script": "./.claude/hooks/notification.sh",
      "timeout": 30
    }
  }
}
```

### Configuration Options

**enabled** - Boolean
- `true`: Hook is active and runs automatically
- `false`: Hook is disabled

**script** - String (path)
- Path to the hook script (bash, python, or any executable)
- Can be relative to project root or absolute path

**timeout** - Integer (seconds)
- Maximum time hook is allowed to run
- If exceeded, hook is killed and treated as error
- Prevents hooks from blocking indefinitely

### Complete Configuration Example

```json
{
  "hooks": {
    "pre-tool-use": {
      "enabled": true,
      "script": "./.claude/hooks/pre-tool-use.sh",
      "timeout": 30,
      "allowlist": ["npm install", "git commit"],
      "blocklist": ["rm -rf", "sudo"]
    },
    "post-tool-use": {
      "enabled": true,
      "script": "./.claude/hooks/post-tool-use.sh",
      "timeout": 60,
      "run_on": ["file_write", "code_modification"]
    },
    "pre-commit": {
      "enabled": true,
      "script": "./.claude/hooks/pre-commit.sh",
      "timeout": 120,
      "require_tests": true,
      "require_lint": true,
      "blocklist_branches": ["main", "production"]
    },
    "notification": {
      "enabled": true,
      "script": "./.claude/hooks/notification.sh",
      "webhook_url": "${SLACK_WEBHOOK}",
      "events": ["deployment", "test_failure", "security_scan"]
    }
  }
}
```

---

## Exit Codes & Control Flow

### Exit Code Meanings

| Exit Code | Meaning | Action |
|-----------|---------|--------|
| **0** | Success / Allow | Action proceeds normally |
| **1** | Error (non-blocking) | Log error but continue |
| **2** | Block / Reject | Stop the action, don't proceed |
| **3+** | Error (blocking) | Stop the action with error message |

### Pre-Hook Exit Code Examples

```bash
#!/bin/bash
# Pre-hook: Decides whether to allow or block action

if [[ "$COMMAND" == "rm -rf" ]]; then
    echo "✗ Dangerous command blocked: rm -rf"
    exit 2  # ← Block this action
fi

if [[ "$COMMAND" == "npm test" ]]; then
    echo "⚠ Tests are running. This may take time."
    exit 0  # ← Allow, just warn
fi

if [[ ! -f "package.json" ]]; then
    echo "✗ Error: package.json not found"
    exit 3  # ← Block with error
fi

exit 0  # ← Allow all others
```

### Post-Hook Exit Code Examples

```bash
#!/bin/bash
# Post-hook: Runs after action completes

# Auto-format after JavaScript files are written
if npx prettier --write src/**/*.js; then
    echo "✓ Code automatically formatted"
    exit 0  # ← Success
fi

# If formatting fails, log but don't block
echo "⚠ Auto-format failed, manual formatting may be needed"
exit 1  # ← Non-blocking error (don't fail the whole action)
```

### Control Flow Diagram

```
┌─────────────────────────────────────────────┐
│         User initiates action               │
└────────────────────┬────────────────────────┘
                     │
              ┌──────▼──────┐
              │ Pre-Hook?   │
              └──────┬──────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    Exit 0      Exit 2 or 3    Error
    (Allow)     (Block)        (Block)
         │           │           │
         ▼           ▼           ▼
    ┌────────┐  ┌───────┐  ┌─────────┐
    │ Action │  │ STOP  │  │ STOP    │
    │Proceeds│  │ Blocked│  │& Report │
    └────┬───┘  └───────┘  └─────────┘
         │
      ┌──▼──┐
      │ Run │
      │Action
      └──┬──┘
         │
    ┌────▼──────┐
    │Post-Hook? │
    └────┬──────┘
         │
    ┌────┴────┐
    │          │
 Exit 0     Exit 1+
(Success)  (Warning)
    │          │
    ▼          ▼
 Continue   Continue
 (Report)   (Report
  Success)   Warning)
```

---

## The 7 Production-Ready Hook Recipes

### Recipe 1: rm -rf Prevention Hook

**Purpose:** Prevent accidental deletion of entire directories

**Location:** `.claude/hooks/pre-tool-use.sh`

```bash
#!/bin/bash
# Prevent dangerous rm -rf commands

set -e

TOOL_NAME=$1
shift
TOOL_ARGS=("$@")

# Block rm -rf entirely
if [[ "$TOOL_NAME" == "bash" ]]; then
    COMMAND="${TOOL_ARGS[0]} ${TOOL_ARGS[1]}"
    
    if [[ "$COMMAND" =~ rm.*-rf ]] || [[ "$COMMAND" =~ rm.*-f.*r ]]; then
        cat <<EOF
╔════════════════════════════════════════════════════════════╗
║                  ✗ DANGEROUS COMMAND BLOCKED               ║
╚════════════════════════════════════════════════════════════╝

Command: rm -rf
Reason: Recursive force-delete is extremely dangerous

Safer alternatives:
  1. Use: rm -i *.js         (interactive, asks for each file)
  2. Use: rm -r dir_name     (recursive but safe, no force)
  3. Use: trash-cli          (moves to trash instead of delete)

If you absolutely need force delete:
  - Use single file: rm -f /path/to/specific/file
  - Use with wildcard: rm -f *.log (be very specific)
  - Commit your code first: git commit before destructive ops

Blocked at: $(date)
EOF
        exit 2  # Block the command
    fi
fi

exit 0
```

**Configuration:**
```json
{
  "pre-tool-use": {
    "enabled": true,
    "script": "./.claude/hooks/pre-tool-use.sh",
    "timeout": 10,
    "blocklist": ["rm -rf", "rm -fr"]
  }
}
```

**Test It:**
```bash
# This will be blocked:
rm -rf node_modules

# This will be allowed:
rm -f old_file.txt
rm -r node_modules  # Without -f flag
```

---

### Recipe 2: Secret Scanning Hook

**Purpose:** Prevent commits containing API keys, passwords, or other secrets

**Location:** `.claude/hooks/pre-commit.sh`

```bash
#!/bin/bash
# Scan for secrets before commit

set -e

SECRETS_FOUND=0

# Patterns to detect
PATTERNS=(
    'api[_-]?key'
    'password'
    'secret'
    'token'
    'private[_-]?key'
    'oauth[_-]?token'
    'aws[_-]?secret'
    'database[_-]?url'
    'mongodb[_-]?uri'
)

echo "🔍 Scanning for secrets in staged files..."

# Check each pattern
for pattern in "${PATTERNS[@]}"; do
    if git diff --cached | grep -i "$pattern" | grep -v "\.example\|#.*$pattern"; then
        echo "⚠️  Potential secret detected: $pattern"
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
done

# Also check for common secret patterns
if git diff --cached | grep -E '[A-Za-z0-9]{40}'; then
    echo "⚠️  Potential API key pattern detected"
    SECRETS_FOUND=$((SECRETS_FOUND + 1))
fi

if [ $SECRETS_FOUND -gt 0 ]; then
    cat <<EOF
╔════════════════════════════════════════════════════════════╗
║           ✗ POTENTIAL SECRETS DETECTED                     ║
╚════════════════════════════════════════════════════════════╝

Found $SECRETS_FOUND potential security issues:

What to do:
  1. Run: git diff --cached | grep -i 'secret\|password\|key'
  2. Review the matches carefully
  3. Remove any real secrets
  4. Use environment variables instead

Never commit:
  - API keys or tokens
  - Database credentials
  - Private encryption keys
  - OAuth tokens
  - AWS/cloud provider secrets

Use instead:
  - .env files (added to .gitignore)
  - Environment variables
  - Secrets management services (Vault, AWS Secrets Manager)
  - Config files with placeholder values

EOF
    exit 2  # Block commit
fi

echo "✓ No secrets detected. Commit allowed."
exit 0
```

**Configuration:**
```json
{
  "pre-commit": {
    "enabled": true,
    "script": "./.claude/hooks/pre-commit.sh",
    "timeout": 30,
    "secret_patterns": [
      "api[_-]?key",
      "password",
      "secret",
      "token"
    ]
  }
}
```

**Test It:**
```bash
# Create a test file
echo "const apiKey = 'sk-1234567890abcdef';" > test.js
git add test.js

# Try to commit - will be blocked:
git commit -m "Add API key"
# Output: ✗ POTENTIAL SECRETS DETECTED

# Remove the secret and try again:
echo "const apiKey = process.env.API_KEY;" > test.js
git commit -m "Use environment variable for API key"
# Output: ✓ No secrets detected. Commit allowed.
```

---

### Recipe 3: Auto-Lint & Format Hook

**Purpose:** Automatically lint and format code after changes

**Location:** `.claude/hooks/post-tool-use.sh`

```bash
#!/bin/bash
# Auto-lint and format after file modifications

set -e

TOOL_NAME=$1
TOOL_OUTPUT=$2

# Only run on file writes or code modifications
if [[ "$TOOL_NAME" != "bash" ]] || [[ -z "$TOOL_OUTPUT" ]]; then
    exit 0
fi

echo "🔧 Running auto-formatting and linting..."

# Get list of modified files
MODIFIED_FILES=$(git diff --name-only HEAD)

# Format JavaScript/TypeScript
JS_FILES=$(echo "$MODIFIED_FILES" | grep -E '\.(js|jsx|ts|tsx)$' || true)
if [ -n "$JS_FILES" ]; then
    if command -v npx &> /dev/null; then
        echo "  • Formatting with Prettier..."
        npx prettier --write $JS_FILES 2>/dev/null || echo "  ⚠️  Prettier not configured"
        
        echo "  • Linting with ESLint..."
        npx eslint --fix $JS_FILES 2>/dev/null || echo "  ⚠️  ESLint not configured"
    fi
fi

# Format JSON
JSON_FILES=$(echo "$MODIFIED_FILES" | grep -E '\.json$' || true)
if [ -n "$JSON_FILES" ]; then
    echo "  • Formatting JSON files..."
    for file in $JSON_FILES; do
        if command -v python3 &> /dev/null; then
            python3 -m json.tool "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
    done
fi

# Format YAML
YAML_FILES=$(echo "$MODIFIED_FILES" | grep -E '\.(yml|yaml)$' || true)
if [ -n "$YAML_FILES" ]; then
    echo "  • Formatting YAML files..."
    if command -v yamlfmt &> /dev/null; then
        yamlfmt -i 2 $YAML_FILES
    fi
fi

# Format Python
PY_FILES=$(echo "$MODIFIED_FILES" | grep -E '\.py$' || true)
if [ -n "$PY_FILES" ]; then
    echo "  • Formatting Python..."
    if command -v black &> /dev/null; then
        black $PY_FILES 2>/dev/null || true
    fi
    if command -v autopep8 &> /dev/null; then
        autopep8 --in-place $PY_FILES || true
    fi
fi

echo "✓ Auto-formatting complete"
exit 0
```

**Configuration:**
```json
{
  "post-tool-use": {
    "enabled": true,
    "script": "./.claude/hooks/post-tool-use.sh",
    "timeout": 120,
    "run_on": ["file_write", "code_modification"],
    "formatters": {
      "js": "prettier",
      "json": "jq",
      "python": "black"
    }
  }
}
```

**Test It:**
```bash
# Modify a JavaScript file with poor formatting
cat > messy.js <<EOF
const x=1;const y=2;
function test(  ){return x+y;}
EOF

git add messy.js

# Hook runs automatically after file is written
# Output: ✓ Auto-formatting complete

# Check the file - it's now formatted!
cat messy.js
# Output: properly formatted code
```

---

### Recipe 4: Test Enforcement Hook

**Purpose:** Ensure tests pass before committing

**Location:** `.claude/hooks/pre-commit.sh`

```bash
#!/bin/bash
# Require tests to pass before commit

set -e

echo "🧪 Running tests before commit..."

# Check if test command exists
if ! grep -q '"test"' package.json 2>/dev/null; then
    echo "ℹ️  No test script found in package.json, skipping tests"
    exit 0
fi

# Run tests with coverage
if command -v npm &> /dev/null; then
    if npm test -- --coverage 2>&1; then
        echo "✓ All tests passed!"
        
        # Check coverage threshold
        COVERAGE=$(npm test -- --coverage 2>&1 | grep "Statements" | awk '{print $NF}' | sed 's/%//')
        
        if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            cat <<EOF
╔════════════════════════════════════════════════════════════╗
║           ⚠️  LOW TEST COVERAGE DETECTED                   ║
╚════════════════════════════════════════════════════════════╝

Current coverage: ${COVERAGE}%
Minimum required: 80%

While not blocking the commit, consider:
  1. Adding more tests to increase coverage
  2. Reviewing untested code paths
  3. Improving test quality, not just quantity

EOF
        fi
        
        exit 0
    else
        cat <<EOF
╔════════════════════════════════════════════════════════════╗
║               ✗ TESTS FAILED - COMMIT BLOCKED              ║
╚════════════════════════════════════════════════════════════╝

Tests must pass before committing.

What to do:
  1. Review test failures above
  2. Fix the failing code or tests
  3. Run: npm test
  4. When tests pass, commit again

For debugging:
  1. Run specific test: npm test -- --testNamePattern="test name"
  2. Run with verbose output: npm test -- --verbose
  3. Debug a specific test: node --inspect-brk ./node_modules/jest/bin/jest.js

EOF
        exit 2  # Block commit
    fi
else
    echo "⚠️  npm not found, skipping test check"
    exit 0
fi
```

**Configuration:**
```json
{
  "pre-commit": {
    "enabled": true,
    "script": "./.claude/hooks/pre-commit.sh",
    "timeout": 300,
    "require_tests": true,
    "coverage_threshold": 80
  }
}
```

**Test It:**
```bash
# Create a simple test
cat > test.js <<EOF
test('adds 1 + 1', () => {
  expect(1 + 1).toBe(2);
});
EOF

git add test.js

# Try to commit with failing tests
git commit -m "Add test"
# Output: ✗ TESTS FAILED - COMMIT BLOCKED

# Fix the tests and try again
# Output: ✓ All tests passed!
```

---

### Recipe 5: File Size Guard Hook

**Purpose:** Prevent committing large files that bloat the repository

**Location:** `.claude/hooks/pre-commit.sh`

```bash
#!/bin/bash
# Block commits with large files

set -e

# Size limits (in bytes)
WARN_SIZE=$((5 * 1024 * 1024))      # 5MB warning
BLOCK_SIZE=$((50 * 1024 * 1024))    # 50MB block

echo "📦 Checking for large files..."

LARGE_FILES=()
HUGE_FILES=()

# Check staged files
while IFS= read -r file; do
    if [ -f "$file" ]; then
        SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        
        if [ "$SIZE" -gt "$BLOCK_SIZE" ]; then
            HUGE_FILES+=("$file ($((SIZE / 1024 / 1024))MB)")
        elif [ "$SIZE" -gt "$WARN_SIZE" ]; then
            LARGE_FILES+=("$file ($((SIZE / 1024 / 1024))MB)")
        fi
    fi
done < <(git diff --cached --name-only)

if [ ${#HUGE_FILES[@]} -gt 0 ]; then
    cat <<EOF
╔════════════════════════════════════════════════════════════╗
║            ✗ FILES TOO LARGE - COMMIT BLOCKED              ║
╚════════════════════════════════════════════════════════════╝

Blocked files (>50MB):
$(printf '  • %s\n' "${HUGE_FILES[@]}")

Why this matters:
  - Large files slow down clone/fetch for everyone
  - They can't be easily removed from history
  - Repository bloat makes collaboration harder

What to do:
  1. Remove the large files: git reset HEAD large-file.zip
  2. Use Git LFS for binary files: git lfs install
  3. Use cloud storage for data files
  4. Check for accidental commits of:
     - node_modules/ or vendor/ directories
     - .zip or .tar files
     - Database dumps
     - Large media files

EOF
    exit 2  # Block commit
fi

if [ ${#LARGE_FILES[@]} -gt 0 ]; then
    cat <<EOF
╔════════════════════════════════════════════════════════════╗
║            ⚠️  LARGE FILES DETECTED (WARNING)              ║
╚════════════════════════════════════════════════════════════╝

Large files (5-50MB):
$(printf '  • %s\n' "${LARGE_FILES[@]}")

Considerations:
  - These will be included in the repository
  - Consider using Git LFS for better performance
  - Consider cloud storage alternatives

Commit will proceed, but review the files above.

EOF
fi

echo "✓ File size check complete"
exit 0
```

**Configuration:**
```json
{
  "pre-commit": {
    "enabled": true,
    "script": "./.claude/hooks/pre-commit.sh",
    "timeout": 30,
    "file_size_warn": "5MB",
    "file_size_block": "50MB"
  }
}
```

**Test It:**
```bash
# Create a large file
dd if=/dev/zero of=large-file.bin bs=1M count=60
git add large-file.bin

# Try to commit
git commit -m "Add large file"
# Output: ✗ FILES TOO LARGE - COMMIT BLOCKED

# Remove it and use Git LFS instead
git reset HEAD large-file.bin
git lfs install
git lfs track "*.bin"
git add large-file.bin .gitattributes
git commit -m "Add large file with Git LFS"
# Output: ✓ File size check complete
```

---

### Recipe 6: Branch Protection Hook

**Purpose:** Prevent direct commits to protected branches (main, production)

**Location:** `.claude/hooks/pre-commit.sh`

```bash
#!/bin/bash
# Prevent direct commits to protected branches

set -e

# Protected branches that require pull requests
PROTECTED_BRANCHES=("main" "master" "production" "develop")

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
        cat <<EOF
╔════════════════════════════════════════════════════════════╗
║       ✗ PROTECTED BRANCH - COMMIT BLOCKED                  ║
╚════════════════════════════════════════════════════════════╝

Current branch: $CURRENT_BRANCH (PROTECTED)

Direct commits to protected branches are not allowed!

What to do:
  1. Create a feature branch:
     git checkout -b feature/my-feature

  2. Make your changes and commit:
     git add .
     git commit -m "Add feature"

  3. Push your branch:
     git push origin feature/my-feature

  4. Open a Pull Request on GitHub

Why we require PRs:
  ✓ Code review before merging
  ✓ CI/CD checks run on every PR
  ✓ Maintains code quality
  ✓ Creates reviewable history
  ✓ Prevents accidental bad code in main

Still need to commit here? Override with:
  git commit --no-verify

(This bypasses hooks - use only if you know what you're doing!)

EOF
        exit 2  # Block commit
    fi
done

echo "✓ Branch protection check passed"
exit 0
```

**Configuration:**
```json
{
  "pre-commit": {
    "enabled": true,
    "script": "./.claude/hooks/pre-commit.sh",
    "timeout": 10,
    "protected_branches": ["main", "master", "production", "develop"],
    "require_pr": true
  }
}
```

**Test It:**
```bash
# Try to commit to main directly
git checkout main
echo "change" > file.txt
git add file.txt
git commit -m "Direct commit"
# Output: ✗ PROTECTED BRANCH - COMMIT BLOCKED

# Switch to feature branch and commit
git checkout -b feature/my-change
echo "change" > file.txt
git add file.txt
git commit -m "Add feature"
# Output: ✓ Branch protection check passed
```

---

### Recipe 7: Slack Notification Hook

**Purpose:** Notify team on Slack when deployments or important events occur

**Location:** `.claude/hooks/notification.sh`

```bash
#!/bin/bash
# Send Slack notifications for important events

set -e

# Get webhook URL from environment
SLACK_WEBHOOK="${SLACK_WEBHOOK_URL}"

if [ -z "$SLACK_WEBHOOK" ]; then
    echo "⚠️  SLACK_WEBHOOK_URL not set, skipping notifications"
    exit 0
fi

EVENT_TYPE=$1
EVENT_DETAILS=$2
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
GIT_USER=$(git config user.name)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Function to send Slack message
send_slack_message() {
    local title=$1
    local details=$2
    local color=$3
    
    curl -X POST \
        -H 'Content-type: application/json' \
        --data "{
            \"attachments\": [
                {
                    \"color\": \"$color\",
                    \"title\": \"$title\",
                    \"text\": \"$details\",
                    \"fields\": [
                        {
                            \"title\": \"User\",
                            \"value\": \"$GIT_USER\",
                            \"short\": true
                        },
                        {
                            \"title\": \"Branch\",
                            \"value\": \"$GIT_BRANCH\",
                            \"short\": true
                        },
                        {
                            \"title\": \"Time\",
                            \"value\": \"$TIMESTAMP\",
                            \"short\": false
                        }
                    ]
                }
            ]
        }" \
        "$SLACK_WEBHOOK" 2>/dev/null
}

case "$EVENT_TYPE" in
    "deployment")
        send_slack_message \
            "🚀 Deployment Complete" \
            "$EVENT_DETAILS" \
            "good"
        ;;
    
    "test_failure")
        send_slack_message \
            "❌ Test Failure" \
            "$EVENT_DETAILS" \
            "danger"
        ;;
    
    "merge_pr")
        send_slack_message \
            "✅ Pull Request Merged" \
            "$EVENT_DETAILS" \
            "good"
        ;;
    
    "security_scan")
        send_slack_message \
            "🔒 Security Scan Complete" \
            "$EVENT_DETAILS" \
            "warning"
        ;;
    
    "performance_regression")
        send_slack_message \
            "⚠️  Performance Regression Detected" \
            "$EVENT_DETAILS" \
            "warning"
        ;;
    
    *)
        echo "Unknown event type: $EVENT_TYPE"
        exit 1
        ;;
esac

echo "✓ Slack notification sent"
exit 0
```

**Setup Slack Webhook:**

1. Go to https://api.slack.com/apps
2. Create a new app or select existing
3. Enable "Incoming Webhooks"
4. Create a new webhook for your channel
5. Copy the webhook URL
6. Set environment variable:
   ```bash
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
   ```

**Configuration:**
```json
{
  "notification": {
    "enabled": true,
    "script": "./.claude/hooks/notification.sh",
    "timeout": 30,
    "slack_webhook": "${SLACK_WEBHOOK_URL}",
    "events": [
      "deployment",
      "test_failure",
      "merge_pr",
      "security_scan",
      "performance_regression"
    ]
  }
}
```

**Trigger Notifications:**
```bash
# After successful deployment
./.claude/hooks/notification.sh "deployment" "Version 1.2.0 deployed to production"

# On test failure
./.claude/hooks/notification.sh "test_failure" "3 tests failed in payment module"

# On PR merge
./.claude/hooks/notification.sh "merge_pr" "PR #123: Add user authentication merged to main"

# Output: ✓ Slack notification sent
```

---

## Creating Custom Hooks

### Step 1: Understand Hook Requirements

All hooks must:
- Be executable scripts (bash, python, etc.)
- Accept standard input/arguments
- Return proper exit codes (0 = success, 2 = block, etc.)
- Complete within timeout period
- Be idempotent (safe to run multiple times)

### Step 2: Write Your Hook

Create `.claude/hooks/my-custom-hook.sh`:

```bash
#!/bin/bash
# My Custom Hook Description

set -e  # Exit on error

# Function to log messages
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✓ $1"
}

log_error() {
    echo "✗ $1"
}

# Your hook logic here
log_info "Running custom hook..."

# Do something
if [ -f "src/index.js" ]; then
    log_success "Found main file"
else
    log_error "Main file not found"
    exit 1  # Non-blocking error
fi

log_success "Custom hook complete"
exit 0  # Success
```

### Step 3: Make It Executable

```bash
chmod +x .claude/hooks/my-custom-hook.sh
```

### Step 4: Configure in `.claude/settings.json`

```json
{
  "hooks": {
    "my-custom-hook": {
      "enabled": true,
      "script": "./.claude/hooks/my-custom-hook.sh",
      "timeout": 30
    }
  }
}
```

### Step 5: Test Your Hook

```bash
# Run directly
./.claude/hooks/my-custom-hook.sh

# Test error handling
# Verify exit codes
```

---

## Debugging Hooks

### Enable Hook Logging

```json
{
  "hooks": {
    "pre-commit": {
      "enabled": true,
      "script": "./.claude/hooks/pre-commit.sh",
      "timeout": 120,
      "debug": true,
      "log_file": ".claude/logs/pre-commit.log"
    }
  }
}
```

### View Hook Logs

```bash
# View all hook logs
tail -f .claude/logs/*.log

# View specific hook logs
tail -f .claude/logs/pre-commit.log

# Search for errors
grep "Error\|✗" .claude/logs/*.log
```

### Test Hooks Manually

```bash
# Run a hook directly
./.claude/hooks/pre-commit.sh

# Debug with bash -x
bash -x ./.claude/hooks/pre-commit.sh

# Debug with environment variables
DEBUG=1 ./.claude/hooks/pre-commit.sh
```

### Common Hook Issues

| Issue | Solution |
|-------|----------|
| Hook not running | Check `enabled: true` in settings.json |
| Hook running too slowly | Increase `timeout` value or optimize hook script |
| Hook gives wrong exit code | Test exit code: `; echo $?` |
| Hook loses context | Use absolute paths instead of relative |
| Hook interferes with workflow | Disable temporarily: set `enabled: false` |

---

## Real-World Examples

### Example 1: Before-After: Preventing Secrets

**Before hooks:**
```
Developer A: "git commit -m 'Add database config'"
Later...
Manager: "Oh no! Database password is in the repo!"
Dev A: "I didn't notice..."
Result: Password changed for entire database, emergency meeting
```

**After hooks with secret scanning:**
```
Developer A: "git commit -m 'Add database config'"
Hook runs: "✗ POTENTIAL SECRETS DETECTED"
Developer A: Sees error, moves password to .env
Developer A: "git commit -m 'Add database config (with env variables)'"
Hook runs: "✓ No secrets detected. Commit allowed."
Result: Database stays secure, no incidents
```

---

### Example 2: Before-After: Test Enforcement

**Before hooks:**
```
Developer B: Works on feature all day
Developer B: "git commit" (without testing)
Later in CI: Tests fail
Manager: "Why didn't you run tests?"
Dev B: "Forgot..."
Result: CI broken, team blocked, time wasted
```

**After hooks with test enforcement:**
```
Developer B: Works on feature all day
Developer B: "git commit -m 'Add feature'"
Hook runs: "🧪 Running tests before commit..."
Tests fail
Hook: "✗ TESTS FAILED - COMMIT BLOCKED"
Developer B: Sees errors immediately, fixes them
Developer B: "npm test" - tests pass
Developer B: "git commit -m 'Add feature'"
Hook: "✓ All tests passed!"
Result: Feature committed with passing tests, no CI failures
```

---

### Example 3: Before-After: Large File Prevention

**Before hooks:**
```
Developer C: "I'll commit this 100MB database dump"
git add schema.sql
git commit -m "Add schema"
git push

Later...
New developer: "Why is clone taking 30 minutes?"
Manager: "100MB database dump in the repo"
Everyone: Has to wait longer for clone
Result: Productivity loss for entire team
```

**After hooks with file size guard:**
```
Developer C: "I'll commit this 100MB database dump"
git add schema.sql
git commit -m "Add schema"
Hook: "✗ FILES TOO LARGE - COMMIT BLOCKED"
Hook: Suggests using Git LFS
Developer C: Sets up Git LFS, re-commits
Hook: "✓ File size check complete"
git push

Later...
New developer: Clone completes in 30 seconds
Everyone: Enjoys fast clones
Result: Better productivity for entire team
```

---

## Best Practices

### 1. Start with Production-Ready Recipes

Don't write hooks from scratch. Use the 7 recipes and customize them.

```bash
# Copy pre-commit recipe and modify for your needs
cp .claude/hooks/recipes/pre-commit-tests.sh .claude/hooks/pre-commit.sh
# Edit for your project
```

### 2. Make Hooks Fast

Slow hooks interrupt workflow. Keep them under 30-60 seconds.

```bash
# Fast: Check file existence (instant)
if [ -f ".env" ]; then echo "OK"; fi

# Slow: Run entire test suite (minutes)
npm test  # Put behind optional flag instead
```

### 3. Provide Clear Error Messages

When hooks block actions, explain why and how to fix.

```bash
# Good error message
cat <<EOF
✗ BRANCH PROTECTED
Current: main (you cannot commit here directly)
Solution: Create feature branch: git checkout -b feature/name
EOF

# Poor error message
echo "Error: Cannot commit"
exit 2
```

### 4. Make Hooks Bypassable for Emergencies

Allow `--no-verify` for critical situations.

```bash
# Team knows --no-verify exists for true emergencies
git commit --no-verify -m "Emergency hotfix"

# But it's logged and audited
echo "Warning: bypassed hooks at $(date)" >> audit.log
```

### 5. Document Your Hooks

Create a `.claude/HOOKS.md` file explaining your hooks.

```markdown
# Project Hooks

## pre-commit
Runs tests and scans for secrets before commits.
- Blocks commits if tests fail
- Blocks commits with API keys
- Takes ~60 seconds

## post-tool-use
Auto-formats code after changes.
- Runs Prettier on JavaScript
- Runs Black on Python
- Takes ~10 seconds

To bypass: `git commit --no-verify`
```

### 6. Review Hook Output Regularly

```bash
# Check what hooks are catching
grep "blocked\|BLOCKED" .claude/logs/*.log

# Identify patterns
# E.g., "Tests always fail for X component" → fix tests
# E.g., "Developers always use --no-verify" → hook not needed
```

### 7. Evolve Hooks with Your Team

Update hooks as your standards improve.

```markdown
## Hook Evolution

v1.0 (Initial)
- Basic test enforcement

v1.1 (Month 1)
- Added coverage threshold
- Added specific test patterns

v1.2 (Month 2)
- Faster execution (only run changed tests)
- Better error messages

v2.0 (Month 3)
- Integrated with CI/CD
- Parallel test execution
```

### 8. Test Hooks in CI Before Deploying

Create hook testing workflow:

```bash
# .github/workflows/test-hooks.yml
name: Test Hooks
on: push

jobs:
  test-hooks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test pre-commit hook
        run: ./.claude/hooks/pre-commit.sh
      - name: Test secrets hook
        run: ./.claude/hooks/pre-commit.sh "secret_scan"
```

---

## Summary

Hooks are your team's safety net. They:

- **Prevent mistakes** automatically
- **Enforce standards** consistently
- **Catch issues early** before they become problems
- **Educate team members** through feedback

By implementing the 7 production-ready recipes, you can dramatically improve code quality, security, and team productivity.

---

**Next Steps:**

1. Copy the `.claude/settings.json` template into your project
2. Choose 2-3 recipes from the 7 production-ready hooks
3. Test them in your environment
4. Document them for your team
5. Iterate based on feedback

---

*This manual covers Claude Code Methodology v2.6.0. For updates and additional resources, visit the CCM training portal.*
