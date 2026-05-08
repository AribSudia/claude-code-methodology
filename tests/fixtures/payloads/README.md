# Hook payload fixtures

Canonical JSON payloads that Claude Code passes on stdin to PreToolUse,
SessionStart, Stop, and Notification hooks. Use these as the contract
when authoring or testing a new hook.

Fixtures are named `<hook-event>-<scenario>.json`.

## Files

| File | Hook event | Scenario |
|------|-----------|----------|
| `pretooluse-bash-safe.json` | PreToolUse | Bash with `ls` (allowed) |
| `pretooluse-bash-dangerous.json` | PreToolUse | Bash with `rm -rf /` (blocked) |
| `pretooluse-write-secret.json` | PreToolUse | Write with sk-ant-... in src/ (blocked) |
| `pretooluse-write-test-fixture.json` | PreToolUse | Write with sk-ant-... in tests/ (allowed; exempt) |
| `pretooluse-write-hex-component.json` | PreToolUse | Write hex literal in .tsx (blocked by design-token hook) |
| `pretooluse-write-out-of-scope.json` | PreToolUse | Write to a non-allowed path (blocked) |
| `pretooluse-write-eval.json` | PreToolUse | Write `eval(input)` in src/ (blocked, OWASP A03) |
| `sessionstart-empty.json` | SessionStart | Default `{}` payload |
| `stop-empty.json` | Stop | Default `{}` payload |
| `notification-test.json` | Notification | Generic event for fan-out test |

## Usage

```bash
# Manual smoke test
cat tests/fixtures/payloads/pretooluse-bash-dangerous.json | .claude/hooks/pre-tool-use.sh
# Expect: exit 1 with BLOCK message

# Run the full regression suite
./scripts/test-hooks.sh
```

## Adding a new fixture

1. Capture the payload from a real Claude Code run by adding `cat > /tmp/payload.json` to your hook temporarily.
2. Sanitize (no real secrets, no PII).
3. Save to this directory with a descriptive name.
4. Add a matching scenario to `scripts/test-hooks.sh`.
