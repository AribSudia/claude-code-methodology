# Claude Code Hooks Protocol

**Version:** 1.0  
**Last Updated:** April 2026  
**Purpose:** Comprehensive guide to implementing and managing Claude Code hooks for codebase safety, automation, and quality assurance.

---

## Table of Contents

1. [What Are Hooks?](#what-are-hooks)
2. [Why Hooks Matter](#why-hooks-matter)
3. [The 6 Hook Types](#the-6-hook-types)
4. [Exit Codes & Control Flow](#exit-codes--control-flow)
5. [Configuration Guide](#configuration-guide)
6. [Hook Recipes](#hook-recipes)
7. [Creating Custom Hooks](#creating-custom-hooks)
8. [Testing & Debugging](#testing--debugging)
9. [Best Practices](#best-practices)

---

## What Are Hooks?

Hooks are **safety gates** that intercept Claude Code operations and apply custom logic before, during, or after execution. Think of them as middleware that can:

- **Block** dangerous operations
- **Transform** operations for safety
- **Audit** what Claude is doing
- **Automate** repetitive quality checks
- **Notify** humans of important changes
- **Enforce** project standards

Hooks execute in the agent's security context and can access:
- File system state
- Git repository state
- Project configuration
- Environment variables
- Tool invocation details

---

## Why Hooks Matter

### Security

- **Prevent accidental `rm -rf`**: Block recursive deletion of critical directories
- **Enforce secrets management**: Scan for hardcoded API keys, passwords, database URLs
- **Audit sensitive operations**: Log file modifications, credential access, network calls
- **Control file writes**: Prevent overwriting critical configuration files

### Quality

- **Enforce linting**: Auto-run code quality checks after writes
- **Require tests**: Block commits without test coverage
- **Validate commits**: Ensure conventional commit format and quality
- **Dependency review**: Check for vulnerable or conflicting dependencies

### Automation

- **Auto-format code**: Run prettier after file saves
- **Generate docs**: Update documentation automatically
- **Tag versions**: Auto-version based on commit messages
- **Update changelog**: Generate release notes from commits

### Compliance

- **License scanning**: Detect incompatible dependencies
- **Audit trails**: Log all agent actions for compliance
- **Data protection**: Encrypt sensitive data in logs
- **Policy enforcement**: Ensure adherence to company standards

---

## The 6 Hook Types

### 1. PreToolUse

**When it fires:** Before any tool is executed (file write, bash command, git operation)

**What it receives:**
```json
{
  "hookType": "PreToolUse",
  "toolName": "bash",
  "toolArgs": {
    "command": "rm -rf /path/to/dir"
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "main",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Block the operation (exit code 2)
- Allow it (exit code 0)
- Transform arguments (output modified args as JSON)
- Log/audit the operation

**Example uses:**
- Block `rm -rf` commands
- Warn before deleting files
- Prevent commands on protected branches
- Validate command syntax

---

### 2. PostToolUse

**When it fires:** After a tool completes (successfully or with error)

**What it receives:**
```json
{
  "hookType": "PostToolUse",
  "toolName": "write",
  "toolArgs": {
    "filePath": "/project/src/index.js",
    "content": "..."
  },
  "result": {
    "success": true,
    "output": "File written successfully"
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "feature/auth",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Trigger side effects (run linters, formatters)
- Validate results
- Update related files
- Notify team members
- Log metrics

**Example uses:**
- Auto-run prettier after writes
- Scan for secrets in written files
- Update imports automatically
- Run tests on changed files

---

### 3. SessionStart

**When it fires:** When Claude Code session begins

**What it receives:**
```json
{
  "hookType": "SessionStart",
  "session": {
    "sessionId": "abc123",
    "startTime": "2026-04-15T10:30:00Z",
    "userContext": "refactoring-auth-module"
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "main",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Load project context and memory
- Verify preconditions
- Set up environment
- Display status/warnings
- Prepare work area

**Example uses:**
- Load development environment
- Check branch is up-to-date
- Display work queue
- Verify all secrets are configured
- Load session memory

---

### 4. SessionSummarize

**When it fires:** At the end of Claude Code session (before exit)

**What it receives:**
```json
{
  "hookType": "SessionSummarize",
  "session": {
    "sessionId": "abc123",
    "duration": 1800,
    "operations": [
      {"type": "write", "file": "src/auth.js"},
      {"type": "bash", "command": "npm test"}
    ]
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "feature/auth",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Generate session summaries
- Update memory/documentation
- Run final validation
- Suggest next steps
- Cleanup temporary files
- Send notifications

**Example uses:**
- Generate work summary
- Save session to memory
- Commit work-in-progress
- Notify team of changes
- Cleanup git worktrees

---

### 5. PreCommit

**When it fires:** Before Git commit is created

**What it receives:**
```json
{
  "hookType": "PreCommit",
  "commit": {
    "message": "feat: add OAuth2 support",
    "files": ["src/auth.js", "tests/auth.test.js"],
    "additions": 142,
    "deletions": 23
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "feature/oauth",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Validate commit message format
- Run pre-commit checks (lint, test, security)
- Prevent commits with secrets
- Enforce commit standards
- Block commits on protected branches
- Update commit message

**Example uses:**
- Block commits with hardcoded secrets
- Require test files to change
- Enforce conventional commit format
- Run security audit
- Verify no console.log() in code
- Check code coverage threshold

---

### 6. Notification

**When it fires:** When important events occur (deployments, security issues, etc.)

**What it receives:**
```json
{
  "hookType": "Notification",
  "event": "security_issue_detected",
  "severity": "high",
  "details": {
    "type": "hardcoded_secret",
    "file": "src/config.js",
    "line": 42,
    "secretType": "aws_key"
  },
  "context": {
    "cwd": "/project/root",
    "gitBranch": "feature/api",
    "projectRoot": "/project/root"
  }
}
```

**What it can do:**
- Send alerts to team
- Log to monitoring systems
- Create tickets/issues
- Block risky operations
- Store audit trail
- Trigger escalations

**Example uses:**
- Alert on security issues
- Notify on high-risk file changes
- Log all deployment operations
- Alert on dependency vulnerabilities
- Notify on protected file modifications

---

## Exit Codes & Control Flow

Hooks control Claude Code flow through exit codes:

| Exit Code | Meaning | Behavior |
|-----------|---------|----------|
| **0** | Success, allow operation | Operation proceeds normally |
| **1** | Warning, allow operation | Operation proceeds with warning logged |
| **2** | Block operation | Operation is rejected, error shown to user |
| **Other** | Error, block operation | Operation blocked, error message shown |

### Exit Code Examples

```bash
#!/bin/bash
# Example: Block rm -rf but allow other rm commands

if [[ "$COMMAND" == *"rm -rf"* ]]; then
  echo "BLOCKED: Recursive deletion is dangerous"
  exit 2  # BLOCK
fi

if [[ "$COMMAND" == *"rm"* ]]; then
  echo "WARNING: Verify file deletion is intentional"
  exit 1  # WARNING
fi

exit 0  # ALLOW
```

---

## Configuration Guide

### Basic Setup in settings.json

```json
{
  "hooks": {
    "enabled": true,
    "debug": false,
    "hooks": {
      "pre-tool-use": [
        {
          "name": "block-dangerous-bash",
          "script": "./hooks/pre-tool-use/block-dangerous-bash.sh",
          "tools": ["bash"]
        },
        {
          "name": "validate-file-writes",
          "script": "./hooks/pre-tool-use/validate-file-writes.sh",
          "tools": ["write"]
        }
      ],
      "post-tool-use": [
        {
          "name": "auto-lint",
          "script": "./hooks/post-tool-use/auto-lint.sh",
          "tools": ["write"]
        },
        {
          "name": "scan-secrets",
          "script": "./hooks/post-tool-use/scan-secrets.sh",
          "tools": ["write"]
        }
      ],
      "pre-commit": [
        {
          "name": "validate-message",
          "script": "./hooks/pre-commit/validate-message.sh"
        },
        {
          "name": "block-secrets",
          "script": "./hooks/pre-commit/block-secrets.sh"
        },
        {
          "name": "run-tests",
          "script": "./hooks/pre-commit/run-tests.sh"
        }
      ],
      "session-start": [
        {
          "name": "setup-environment",
          "script": "./hooks/session-start/setup-environment.sh"
        }
      ],
      "session-summarize": [
        {
          "name": "generate-summary",
          "script": "./hooks/session-summarize/generate-summary.sh"
        }
      ],
      "notification": [
        {
          "name": "slack-alerts",
          "script": "./hooks/notification/slack-alerts.sh"
        }
      ]
    }
  }
}
```

### Hook Script Structure

Every hook script should follow this structure:

```bash
#!/bin/bash
set -e

# Parse input (provided as JSON on stdin)
INPUT=$(cat)

# Extract hook type and relevant data
HOOK_TYPE=$(echo "$INPUT" | jq -r '.hookType')
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')
COMMAND=$(echo "$INPUT" | jq -r '.toolArgs.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs.filePath // empty')

# Implement logic
case "$HOOK_TYPE" in
  "PreToolUse")
    # Validate and possibly transform
    ;;
  "PostToolUse")
    # React to completed operation
    ;;
esac

# Exit with appropriate code
exit 0  # Allow: 0, Warn: 1, Block: 2
```

---

## Hook Recipes

### Recipe 1: Block Dangerous Bash Commands

**File:** `hooks/pre-tool-use/block-dangerous-bash.sh`

```bash
#!/bin/bash
set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.toolArgs.command // empty')

# Dangerous patterns to block
DANGEROUS_PATTERNS=(
  "rm -rf"
  "rm -rf /"
  "sudo.*rm"
  ":(){:|:&};:"  # fork bomb
  "dd if=/dev/zero"
  "dd if=/dev/urandom"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" =~ $pattern ]]; then
    echo "BLOCKED: This command is too dangerous to execute"
    echo "Command: $COMMAND"
    echo "Pattern: $pattern"
    exit 2  # BLOCK
  fi
done

# Warn on potentially risky operations
RISKY_PATTERNS=(
  "^rm "
  "^chmod 777"
  "^chown"
  "mysql.*drop"
  "psql.*drop"
)

for pattern in "${RISKY_PATTERNS[@]}"; do
  if [[ "$COMMAND" =~ $pattern ]]; then
    echo "WARNING: Verify this operation is intentional"
    echo "Command: $COMMAND"
    exit 1  # WARN
  fi
done

exit 0  # ALLOW
```

### Recipe 2: Block Commits with Secrets

**File:** `hooks/pre-commit/block-secrets.sh`

```bash
#!/bin/bash
set -e

INPUT=$(cat)
FILES=$(echo "$INPUT" | jq -r '.commit.files[]')

# Patterns that indicate secrets
SECRET_PATTERNS=(
  "AKIA[0-9A-Z]\{16\}"              # AWS Key
  "[0-9a-zA-Z_-]*API.KEY['\"]"       # API key
  "[0-9a-zA-Z_-]*SECRET['\"]"        # Secret
  "password.*=.*['\"].*['\"]"        # Password assignment
  "Bearer [A-Za-z0-9._-]+"           # Bearer token
  "Authorization:.*Bearer"           # Auth header
)

FOUND_SECRET=false
for FILE in $FILES; do
  if [[ ! -f "$FILE" ]]; then
    continue
  fi

  for PATTERN in "${SECRET_PATTERNS[@]}"; do
    if grep -E "$PATTERN" "$FILE" 2>/dev/null; then
      echo "BLOCKED: Potential secret found in $FILE"
      echo "Pattern: $PATTERN"
      echo "Please use environment variables or .env files"
      FOUND_SECRET=true
    fi
  done
done

if $FOUND_SECRET; then
  exit 2  # BLOCK
fi

exit 0  # ALLOW
```

### Recipe 3: Auto-Lint After File Write

**File:** `hooks/post-tool-use/auto-lint.sh`

```bash
#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs.filePath // empty')

# Only lint JavaScript/TypeScript files
if [[ ! "$FILE_PATH" =~ \.(js|ts|jsx|tsx)$ ]]; then
  exit 0  # ALLOW
fi

# Skip if file doesn't exist
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0  # ALLOW
fi

# Run eslint with auto-fix
if command -v eslint &> /dev/null; then
  echo "Auto-linting: $FILE_PATH"
  eslint --fix "$FILE_PATH" || true
fi

# Run prettier
if command -v prettier &> /dev/null; then
  echo "Auto-formatting: $FILE_PATH"
  prettier --write "$FILE_PATH" || true
fi

exit 0  # ALLOW
```

### Recipe 4: Require Tests Before Commit

**File:** `hooks/pre-commit/require-tests.sh`

```bash
#!/bin/bash
set -e

INPUT=$(cat)
FILES=$(echo "$INPUT" | jq -r '.commit.files[]')

# Check if test files were added/modified
HAS_TEST_CHANGES=false
for FILE in $FILES; do
  if [[ "$FILE" =~ test|spec ]] && [[ "$FILE" =~ \.(test|spec)\.(js|ts|jsx|tsx)$ ]]; then
    HAS_TEST_CHANGES=true
    break
  fi
done

# Check if non-test files were changed
HAS_CODE_CHANGES=false
for FILE in $FILES; do
  if [[ ! "$FILE" =~ test|spec ]] && [[ "$FILE" =~ \.(js|ts|jsx|tsx)$ ]]; then
    HAS_CODE_CHANGES=true
    break
  fi
done

# Warn if code changed but tests didn't
if $HAS_CODE_CHANGES && ! $HAS_TEST_CHANGES; then
  echo "WARNING: Code changed but no tests were modified"
  echo "Please add tests for your changes"
  exit 1  # WARN
fi

# Run tests if they exist
if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
  echo "Running tests..."
  npm test || exit 2  # BLOCK if tests fail
fi

exit 0  # ALLOW
```

### Recipe 5: Validate Conventional Commits

**File:** `hooks/pre-commit/validate-commit-message.sh`

```bash
#!/bin/bash

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.commit.message')

# Conventional commit format: type(scope): description
PATTERN='^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?: .{10,}$'

if ! [[ "$MESSAGE" =~ $PATTERN ]]; then
  echo "BLOCKED: Commit message doesn't follow Conventional Commits"
  echo ""
  echo "Required format:"
  echo "  type(scope): description"
  echo ""
  echo "Examples:"
  echo "  feat(auth): add OAuth2 support"
  echo "  fix(api): correct response formatting"
  echo "  docs(readme): update installation instructions"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, test, chore, perf"
  exit 2  # BLOCK
fi

exit 0  # ALLOW
```

### Recipe 6: Notify on Security-Sensitive Changes

**File:** `hooks/post-tool-use/notify-sensitive-changes.sh`

```bash
#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs.filePath // empty')

# Files that trigger security notifications
SENSITIVE_FILES=(
  "src/auth.js"
  "src/security.js"
  "env.example"
  "secrets.config.js"
  ".env.production"
  "docker-compose.yml"
  "kubernetes/"
  "terraform/"
)

for SENSITIVE_FILE in "${SENSITIVE_FILES[@]}"; do
  if [[ "$FILE_PATH" =~ $SENSITIVE_FILE ]]; then
    echo "NOTIFICATION: Security-sensitive file modified"
    echo "File: $FILE_PATH"
    echo ""
    echo "Please ensure:"
    echo "  - No secrets are exposed"
    echo "  - Changes are reviewed by security team"
    echo "  - All tests pass"
    
    # Send notification (Slack, email, etc.)
    if [[ -n "$SLACK_WEBHOOK" ]]; then
      curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"Security file modified: $FILE_PATH\"}" || true
    fi
    
    exit 0  # ALLOW (but notified)
  fi
done

exit 0  # ALLOW
```

### Recipe 7: Block Writing to Protected Files

**File:** `hooks/pre-tool-use/protect-files.sh`

```bash
#!/bin/bash

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs.filePath // empty')

# Files that should never be overwritten by Claude
PROTECTED_FILES=(
  "CLAUDE.md"
  "CONSTRAINTS.md"
  ".git/"
  ".github/"
  "node_modules/"
  ".env"
)

for PROTECTED_FILE in "${PROTECTED_FILES[@]}"; do
  if [[ "$FILE_PATH" =~ ^.*$PROTECTED_FILE ]]; then
    echo "BLOCKED: Cannot modify protected file: $FILE_PATH"
    echo ""
    echo "Protected files must be edited manually:"
    echo "  - CLAUDE.md (system constraints)"
    echo "  - CONSTRAINTS.md (project constraints)"
    echo "  - .env (secret management)"
    echo "  - .git/ (git internals)"
    exit 2  # BLOCK
  fi
done

exit 0  # ALLOW
```

---

## Creating Custom Hooks

### Step 1: Create Hook Script

```bash
#!/bin/bash
set -e

# Read input from stdin
INPUT=$(cat)

# Extract data
HOOK_TYPE=$(echo "$INPUT" | jq -r '.hookType')
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

# Your custom logic here
echo "Hook executed: $HOOK_TYPE"

# Exit with appropriate code
exit 0  # 0=allow, 1=warn, 2=block
```

### Step 2: Register in settings.json

```json
{
  "hooks": {
    "hooks": {
      "pre-tool-use": [
        {
          "name": "my-custom-hook",
          "script": "./hooks/pre-tool-use/my-custom-hook.sh",
          "tools": ["bash"]
        }
      ]
    }
  }
}
```

### Step 3: Make Executable

```bash
chmod +x hooks/pre-tool-use/my-custom-hook.sh
```

### Step 4: Test the Hook

```bash
# Create test input
cat > test-input.json << 'EOF'
{
  "hookType": "PreToolUse",
  "toolName": "bash",
  "toolArgs": {
    "command": "ls -la"
  },
  "context": {
    "cwd": "/project",
    "gitBranch": "main"
  }
}
EOF

# Run hook with test input
./hooks/pre-tool-use/my-custom-hook.sh < test-input.json
```

---

## Testing & Debugging

### Enable Debug Mode

```json
{
  "hooks": {
    "debug": true,
    "logFile": "./hooks-debug.log"
  }
}
```

### Manual Hook Testing

```bash
# Test a hook directly
echo '{"hookType":"PreToolUse","toolName":"bash","toolArgs":{"command":"rm -rf /"}}' | \
  ./hooks/pre-tool-use/block-dangerous-bash.sh

# Check exit code
echo $?  # Should be 2 for blocked
```

### View Hook Logs

```bash
tail -f hooks-debug.log
```

### Test Hook in Isolation

```bash
# Create a test directory
mkdir -p test-hooks
cd test-hooks

# Copy hook script
cp ../hooks/pre-tool-use/block-dangerous-bash.sh .

# Create test data
cat > test.json << 'EOF'
{
  "hookType": "PreToolUse",
  "toolName": "bash",
  "toolArgs": {"command": "rm -rf /"}
}
EOF

# Test
./block-dangerous-bash.sh < test.json
echo "Exit code: $?"
```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Hook not executing | Script not marked executable | `chmod +x hooks/*/script.sh` |
| Hook times out | Long-running operation | Add timeout in settings |
| Hook blocks valid operations | Regex too broad | Review pattern matching |
| Silent failures | stderr not captured | Use `set -e` and proper error handling |
| JSON parsing errors | Malformed JSON input | Validate jq version, use quotes |

---

## Best Practices

### 1. Keep Hooks Fast

Hooks block operations, so keep them under 1 second:

```bash
# Good: Quick validation
grep -q "SECRET" "$FILE" && exit 2

# Bad: Slow operation
npm audit  # Can take 30+ seconds
```

### 2. Use Clear Error Messages

```bash
# Good: Specific, actionable
echo "BLOCKED: Hardcoded AWS key detected in config.js:42"
echo "Use environment variables instead: AWS_ACCESS_KEY_ID"

# Bad: Vague
echo "Error"
```

### 3. Fail Safely

```bash
# Good: Whitelist approach (safer)
if [[ "$COMMAND" == "eslint --fix"* ]]; then
  exit 0  # ALLOW known-good commands
fi
exit 2  # BLOCK everything else

# Bad: Blacklist approach (can miss threats)
if [[ "$COMMAND" != "rm -rf" ]]; then
  exit 0  # Allow everything not specifically blocked
fi
```

### 4. Document Your Hooks

```bash
#!/bin/bash
# Hook: validate-commit-message
# Type: PreCommit
# Purpose: Enforce conventional commit format
# Requirements: jq, git
# Blocked Patterns: Commits not matching feat|fix|docs|...

set -e
INPUT=$(cat)
# ...
```

### 5. Version Your Hooks

```bash
# hooks/version.txt
HOOKS_VERSION="1.0.0"
MIN_CLAUDE_VERSION="2.0.0"
```

### 6. Test Before Deployment

```bash
# hooks/test-suite.sh
#!/bin/bash
# Run all hook tests before deploying

for hook in hooks/*/*.sh; do
  echo "Testing $hook..."
  bash "$hook" < test-data/"$(basename $hook).json" || exit 1
done

echo "All hooks passed!"
```

### 7. Monitor Hook Performance

```bash
# Add timing to hooks
START=$(date +%s%N)

# Your logic here

END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))  # milliseconds
echo "Hook execution time: ${DURATION}ms"
```

---

## Complete Example Configuration

Here's a production-ready `settings.json` with comprehensive hooks:

```json
{
  "hooks": {
    "enabled": true,
    "debug": false,
    "timeout": 5,
    "hooks": {
      "pre-tool-use": [
        {
          "name": "block-dangerous-bash",
          "script": "./hooks/pre-tool-use/block-dangerous-bash.sh",
          "tools": ["bash"],
          "timeout": 1
        },
        {
          "name": "protect-files",
          "script": "./hooks/pre-tool-use/protect-files.sh",
          "tools": ["write"],
          "timeout": 1
        }
      ],
      "post-tool-use": [
        {
          "name": "auto-lint",
          "script": "./hooks/post-tool-use/auto-lint.sh",
          "tools": ["write"],
          "timeout": 30
        },
        {
          "name": "scan-secrets",
          "script": "./hooks/post-tool-use/scan-secrets.sh",
          "tools": ["write"],
          "timeout": 5
        },
        {
          "name": "notify-sensitive-changes",
          "script": "./hooks/post-tool-use/notify-sensitive-changes.sh",
          "tools": ["write"],
          "timeout": 2
        }
      ],
      "pre-commit": [
        {
          "name": "validate-message",
          "script": "./hooks/pre-commit/validate-commit-message.sh",
          "timeout": 1
        },
        {
          "name": "block-secrets",
          "script": "./hooks/pre-commit/block-secrets.sh",
          "timeout": 10
        },
        {
          "name": "require-tests",
          "script": "./hooks/pre-commit/require-tests.sh",
          "timeout": 60
        }
      ],
      "session-start": [
        {
          "name": "setup-environment",
          "script": "./hooks/session-start/setup-environment.sh",
          "timeout": 10
        }
      ],
      "session-summarize": [
        {
          "name": "generate-summary",
          "script": "./hooks/session-summarize/generate-summary.sh",
          "timeout": 30
        }
      ]
    }
  }
}
```

---

## Troubleshooting Guide

### Hook Not Running

1. Check hook is enabled in settings.json
2. Verify hook script exists and path is correct
3. Ensure script is executable: `chmod +x script.sh`
4. Check hook type matches trigger point
5. Enable debug mode to see execution logs

### Hook Blocking Valid Operations

1. Review hook logic and regex patterns
2. Check if conditions are too broad
3. Test hook with test data: `echo '...' | hook.sh`
4. Adjust patterns to be more specific
5. Use whitelist approach instead of blacklist

### Hook Timeout

1. Check hook script for infinite loops
2. Profile hook performance: `time ./hook.sh < input.json`
3. Increase timeout in settings if necessary
4. Move long operations to background jobs
5. Cache results to avoid recomputation

### JSON Parsing Errors

1. Verify jq is installed: `which jq`
2. Test jq extraction: `echo "$INPUT" | jq '.hookType'`
3. Check hook receives valid JSON
4. Add error handling: `jq -r '.field // "default"'`
5. Use proper quoting in shell scripts

---

## Migration Guide

### From Pre-Hooks (Git hooks) to Claude Code Hooks

**Before (Git hooks):**
```bash
# .git/hooks/pre-commit
npm test
eslint .
```

**After (Claude Code hooks):**
```json
{
  "hooks": {
    "pre-commit": [
      {
        "name": "run-tests",
        "script": "./hooks/pre-commit/run-tests.sh"
      },
      {
        "name": "lint",
        "script": "./hooks/pre-commit/lint.sh"
      }
    ]
  }
}
```

### Benefits of Migration

- ✅ Hooks work in agent context, not just Git
- ✅ Better error messages and control flow
- ✅ Timeout protection
- ✅ Debug mode for troubleshooting
- ✅ Centralized configuration
- ✅ Clear exit codes and semantics

---

## Security Considerations

### Principle: Defense in Depth

Use multiple hooks for critical operations:

```json
{
  "hooks": {
    "pre-commit": [
      "validate-message",        // Format check
      "block-secrets",           // Secret scan
      "run-security-audit",      // OWASP check
      "run-tests"                // Quality gate
    ]
  }
}
```

### Preventing Hook Bypass

1. **Read-Only Hooks Config**: Make settings.json read-only for users
2. **Signed Hooks**: Cryptographically sign hook scripts
3. **Audit Trail**: Log all hook executions
4. **Regular Review**: Audit hooks monthly
5. **Testing**: Run hook test suite in CI/CD

---

## Performance Optimization

### Hook Execution Order

Place faster hooks first to fail early:

```json
{
  "hooks": {
    "pre-commit": [
      "validate-message",        // <1ms
      "check-file-count",        // <10ms
      "scan-secrets",            // <100ms
      "run-tests",               // <30000ms
      "run-security-audit"       // <10000ms
    ]
  }
}
```

### Parallel Execution

Run independent hooks in parallel:

```bash
# Hook wrapper that parallelizes
run_hooks_parallel() {
  hook1 & 
  hook2 & 
  hook3 & 
  wait
}
```

---

**Last Updated:** April 2026  
**Maintained by:** Claude Code Security Team  
**Questions?** See HOOKS_PROTOCOL.md in project root
