#!/usr/bin/env bash
# scripts/test-hooks.sh
# Regression suite for CCM hooks. Run before shipping any hook change.
#
# Each test pipes a fixture payload to a hook and asserts the exit code.
# Outputs a pass/fail summary; exits non-zero if any test fails.
#
# Add new tests when:
#  - A new hook is added (add a fixture + an assertion).
#  - A hook gets a new guard (add a positive + negative case).
#  - A bug is fixed (add a regression test for the bug).

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "${REPO_ROOT}"

PAYLOADS="tests/fixtures/payloads"
HOOKS=".claude/hooks"

PASS=0
FAIL=0
FAIL_LIST=()

# Run a test. Args:
#   $1 = test name
#   $2 = hook script path
#   $3 = payload file
#   $4 = expected exit code
#   $5..N = optional env-var assignments (KEY=VAL)
run_test() {
  local name="$1"
  local hook="$2"
  local payload="$3"
  local expect="$4"
  shift 4
  local env_args=("$@")

  if [[ ! -f "$payload" ]]; then
    printf '  [SKIP] %-50s — fixture missing: %s\n' "$name" "$payload"
    return
  fi
  if [[ ! -x "$hook" ]]; then
    printf '  [SKIP] %-50s — hook not executable: %s\n' "$name" "$hook"
    return
  fi

  local actual
  if (( ${#env_args[@]} > 0 )); then
    actual=$(env "${env_args[@]}" bash -c "cat \"$payload\" | \"$hook\"" >/dev/null 2>&1; echo $?)
  else
    actual=$(cat "$payload" | "$hook" >/dev/null 2>&1; echo $?)
  fi

  if [[ "$actual" == "$expect" ]]; then
    PASS=$((PASS+1))
    printf '  [PASS] %-50s exit=%s\n' "$name" "$actual"
  else
    FAIL=$((FAIL+1))
    FAIL_LIST+=("$name (expected $expect, got $actual)")
    printf '  [FAIL] %-50s expected=%s got=%s\n' "$name" "$expect" "$actual"
  fi
}

echo "=== CCM Hook Regression Suite ==="
echo ""

echo "1. PreToolUse — Bash"
run_test "safe bash (ls)"             "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-safe.json"      0
run_test "dangerous bash (rm -rf /)"  "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-dangerous.json" 2
run_test "dangerous bash (rm -rf  / double-space)" "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-doublespace.json" 2
run_test "dangerous bash (rm -rf // slash-collapse)" "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-doubleslash.json" 2
run_test "dangerous bash (rm -r -f / split flags)"   "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-splitflags.json"  2
run_test "force-push to main (git push -f)" "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-forcepush.json" 2
run_test "no jq -> fail CLOSED (block, not allow)" "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-bash-safe.json" 2 CCM_TEST_NO_JQ=1

# Wave-merge gate: on a wave/<name> branch, `git push ... main` without an
# audit entry in io/ledger/ must block. Isolated temp git repo as CCM_ROOT.
WAVE_TMP="$(mktemp -d)"
(
  cd "$WAVE_TMP" \
    && git init -q \
    && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init \
    && git checkout -q -b wave/testwave
) >/dev/null 2>&1
printf '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' > "$WAVE_TMP/payload.json"
run_test "wave-merge gate blocks unaudited push" "$HOOKS/pre-tool-use.sh" "$WAVE_TMP/payload.json" 2 CCM_ROOT="$WAVE_TMP"
rm -rf "$WAVE_TMP"

echo ""
echo "2. PreToolUse — Secret detection"
run_test "real secret in src/"         "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-write-secret.json"        2
# Stripe-key test: assemble the fake key at RUNTIME so no committed file
# contains a literal sk_live_<24+ chars> (GitHub push-protection would flag
# a static fixture, even a fake one). The payload still exercises the hook's
# Stripe pattern. Temp file is created here and removed after.
STRIPE_TMP="$(mktemp)"
printf '{"tool_name":"Write","tool_input":{"file_path":"src/pay.ts","content":"const k=\\"sk_live_%s\\";"}}' "$(printf 'A%.0s' $(seq 1 26))" > "$STRIPE_TMP"
run_test "stripe live secret in src/"  "$HOOKS/pre-tool-use.sh" "$STRIPE_TMP" 2
rm -f "$STRIPE_TMP"

# GitHub PAT — runtime-assembled for the same push-protection reason.
GHP_TMP="$(mktemp)"
printf '{"tool_name":"Write","tool_input":{"file_path":"src/auth.ts","content":"const t=\\"ghp_%s\\";"}}' "$(printf 'a%.0s' $(seq 1 36))" > "$GHP_TMP"
run_test "github PAT in src/"          "$HOOKS/pre-tool-use.sh" "$GHP_TMP" 2
rm -f "$GHP_TMP"

# PKCS#8 private-key block (no algorithm token) — the v3.10.0 regex fix.
# Header assembled at runtime so no committed file contains the literal.
PK_TMP="$(mktemp)"
PK_HEADER="$(printf -- '-----BEGIN %s KEY-----' 'PRIVATE')"
printf '{"tool_name":"Write","tool_input":{"file_path":"src/tls.ts","content":"const pem=\\"%s\\";"}}' "$PK_HEADER" > "$PK_TMP"
run_test "PKCS#8 private key in src/"  "$HOOKS/pre-tool-use.sh" "$PK_TMP" 2
rm -f "$PK_TMP"

run_test "secret in tests/ (exempt)"   "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-write-test-fixture.json"  0

# src/latest/ must NOT be exempt — the old '*test*' substring match wrongly
# exempted it ("la-TEST") and skipped the secret scan (v3.10.0 fix).
LATEST_TMP="$(mktemp)"
printf '{"tool_name":"Write","tool_input":{"file_path":"src/latest/client.ts","content":"const k=\\"sk-ant-%s\\";"}}' "$(printf 'b%.0s' $(seq 1 24))" > "$LATEST_TMP"
run_test "src/latest/ NOT exempt from scan" "$HOOKS/pre-tool-use.sh" "$LATEST_TMP" 2
rm -f "$LATEST_TMP"

echo ""
echo "3. PreToolUse — Path scoping"
run_test "write to allowed src/"       "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-write-hex-component.json" 2   # blocked by hex, not path
run_test "write to non-allowed path"   "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-write-out-of-scope.json"  2

echo ""
echo "4. PreToolUse — OWASP A03"
run_test "eval(input) in src/"         "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-write-eval.json"          2
run_test "eval via MultiEdit edits[] (was unscanned)" "$HOOKS/pre-tool-use.sh" "$PAYLOADS/pretooluse-multiedit-eval.json" 2

echo ""
echo "5. SessionStart / Stop / Notification"
run_test "session-start default"       "$HOOKS/session-start.sh" "$PAYLOADS/sessionstart-empty.json"            0
run_test "stop default"                "$HOOKS/stop.sh"          "$PAYLOADS/stop-empty.json"                    0
run_test "notification fan-out"        "$HOOKS/notification.sh"  "$PAYLOADS/notification-test.json"             0
run_test "invocation-log: skill (UserPromptSubmit)" "$HOOKS/invocation-log.sh" "$PAYLOADS/userpromptsubmit-skill.json" 0
run_test "invocation-log: agent (Task)"             "$HOOKS/invocation-log.sh" "$PAYLOADS/pretooluse-task-agent.json"  0

# invocation-log MUST emit nothing on stdout: UserPromptSubmit stdout is
# injected into Claude's context, so any output would poison the prompt.
IL_STDOUT="$(cat "$PAYLOADS/userpromptsubmit-skill.json" | "$HOOKS/invocation-log.sh" 2>/dev/null)"
if [[ -z "$IL_STDOUT" ]]; then
  PASS=$((PASS+1))
  printf '  [PASS] %-50s stdout empty\n' "invocation-log: silent on stdout"
else
  FAIL=$((FAIL+1))
  FAIL_LIST+=("invocation-log: silent on stdout (got: ${IL_STDOUT:0:40})")
  printf '  [FAIL] %-50s stdout NOT empty\n' "invocation-log: silent on stdout"
fi

echo ""
echo "5c. PostToolUse advisory hooks (v3.18.0 — must exit 0, never block)"
# compress-output: no-op/advisory, always exit 0.
COMP_TMP="$(mktemp)"
printf '{"tool_name":"Bash","tool_input":{"command":"pnpm test"}}' > "$COMP_TMP"
run_test "compress-output: noisy bash (exit 0)" "$HOOKS/compress-output.sh" "$COMP_TMP" 0
printf '{"tool_name":"Bash","tool_input":{"command":"ls"}}' > "$COMP_TMP"
run_test "compress-output: non-noisy bash (exit 0)" "$HOOKS/compress-output.sh" "$COMP_TMP" 0
rm -f "$COMP_TMP"
# ponytail-lite: advisory, always exit 0 (warns to stderr on a smell; never blocks).
PONY_TMP="$(mktemp)"
jq -nc '{tool_name:"Write",tool_input:{file_path:"src/x.ts",content:"interface G {}\nclass GFactory { m(){return 1} }"}}' > "$PONY_TMP"
run_test "ponytail-lite: over-abstraction smell (exit 0)" "$HOOKS/ponytail-lite.sh" "$PONY_TMP" 0
jq -nc '{tool_name:"Write",tool_input:{file_path:"src/n.ts",content:"export const add=(a,b)=>a+b;"}}' > "$PONY_TMP"
run_test "ponytail-lite: clean code (exit 0)" "$HOOKS/ponytail-lite.sh" "$PONY_TMP" 0
jq -nc '{tool_name:"Write",tool_input:{file_path:"src/x.module.ts",content:"interface X {}\nclass XFactory {}"}}' > "$PONY_TMP"
run_test "ponytail-lite: NestJS ceremony exempt (exit 0)" "$HOOKS/ponytail-lite.sh" "$PONY_TMP" 0
rm -f "$PONY_TMP"
# The ponytail-lite smell case MUST emit a warning to stderr (advisory works).
PONY_TMP="$(mktemp)"
jq -nc '{tool_name:"Write",tool_input:{file_path:"src/x.ts",content:"interface G {}\nclass GFactory { m(){return 1} }"}}' > "$PONY_TMP"
PONY_ERR="$(cat "$PONY_TMP" | "$HOOKS/ponytail-lite.sh" 2>&1 1>/dev/null)"
if printf '%s' "$PONY_ERR" | grep -q 'ponytail-lite'; then
  PASS=$((PASS+1)); printf '  [PASS] %-50s warns on smell\n' "ponytail-lite: advisory fires"
else
  FAIL=$((FAIL+1)); FAIL_LIST+=("ponytail-lite advisory did not fire"); printf '  [FAIL] %-50s no warning\n' "ponytail-lite: advisory fires"
fi
rm -f "$PONY_TMP"

echo ""
echo "5d. graph-consult (PreToolUse advisory — exit 0, no-op when graph absent)"
GC_TMP="$(mktemp)"
printf '{"tool_name":"Grep","tool_input":{"pattern":"foo"}}' > "$GC_TMP"
# CCM's committed graph manifest is built:false → must be a silent no-op, exit 0.
run_test "graph-consult: no graph built (exit 0)" "$HOOKS/graph-consult.sh" "$GC_TMP" 0
GC_OUT="$(cat "$GC_TMP" | "$HOOKS/graph-consult.sh" 2>&1)"
if [[ -z "$GC_OUT" ]]; then
  PASS=$((PASS+1)); printf '  [PASS] %-50s silent (no graph)\n' "graph-consult: no-op silent"
else
  FAIL=$((FAIL+1)); FAIL_LIST+=("graph-consult not silent without graph"); printf '  [FAIL] %-50s emitted output\n' "graph-consult: no-op silent"
fi
rm -f "$GC_TMP"

echo ""
echo "6. Autonomy guard"
# Run against an ISOLATED CCM_ROOT (temp dir) so "fresh state" is genuinely
# fresh. Otherwise the guard's BLOCK-rate check counts the BLOCK events the
# earlier tests in THIS suite just generated into the shared io/hook-logs/,
# and trips (this differs across macOS/Linux date parsing — caught by CI).
AUTONOMY_TMP="$(mktemp -d)"
run_test "autonomy off (no-op)"        "$HOOKS/autonomy-guard.sh" "$PAYLOADS/pretooluse-bash-safe.json"         0   CCM_ROOT="$AUTONOMY_TMP"
run_test "autonomy on, fresh state"    "$HOOKS/autonomy-guard.sh" "$PAYLOADS/pretooluse-bash-safe.json"         0   CCM_AUTONOMY=1 CCM_ROOT="$AUTONOMY_TMP"
rm -rf "$AUTONOMY_TMP"

echo ""
echo "7. Static checks"
# bash -n on every hook script
SYNTAX_OK=true
for h in "$HOOKS"/*.sh "$HOOKS"/lib/*.sh "$REPO_ROOT/scripts"/*.sh; do
  [[ ! -f "$h" ]] && continue
  if bash -n "$h" 2>/dev/null; then
    printf '  [PASS] bash -n %-60s\n' "$h"
    PASS=$((PASS+1))
  else
    printf '  [FAIL] bash -n %-60s\n' "$h"
    FAIL=$((FAIL+1))
    FAIL_LIST+=("bash -n $h")
    SYNTAX_OK=false
  fi
done

# settings.json shape
if command -v jq >/dev/null 2>&1; then
  if jq -e '.hooks.PreToolUse[0].hooks[0].command' .claude/settings.json >/dev/null 2>&1; then
    printf '  [PASS] %-60s\n' "settings.json hooks shape (jq)"
    PASS=$((PASS+1))
  else
    printf '  [FAIL] %-60s\n' "settings.json hooks shape (jq)"
    FAIL=$((FAIL+1))
    FAIL_LIST+=("settings.json hooks shape")
  fi
fi

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"

if (( FAIL > 0 )); then
  echo ""
  echo "Failures:"
  for f in "${FAIL_LIST[@]}"; do
    printf '  - %s\n' "$f"
  done
  exit 1
fi

exit 0
