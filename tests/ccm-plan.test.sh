#!/usr/bin/env bash
# tests/ccm-plan.test.sh — CI entry point for the plan-mesh tool (ADR-039).
# Runs ccm-plan.sh's built-in suite against a throwaway store.
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export CCM_PLAN_HOME="$(mktemp -d)/ccm-plan"
trap 'rm -rf "$(dirname "$CCM_PLAN_HOME")"' EXIT
echo "=== ccm-plan selftest ==="
bash scripts/ccm-plan.sh selftest
