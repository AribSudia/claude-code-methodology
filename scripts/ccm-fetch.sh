#!/usr/bin/env bash
# scripts/ccm-fetch.sh
# Fetch the latest CCM methodology source directly from GitHub.
#
# This replaces the manual "download the new claude-code-methodology/ folder
# and drop it into your project" step. Run it from your PROJECT ROOT. It pulls
# the framework source into ./claude-code-methodology/ and then hands off to
# bootstrap/UPGRADE_PROTOCOL.md (or BOOTSTRAP/REVERSE_BOOTSTRAP for first use),
# which does the *intelligent* merge — preserving your memory/, decisions, and
# project data. This script ONLY fetches; it never touches your project data.
#
# First install (no CCM present yet) — one line, no clone needed:
#   curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
#
# Updating an existing project (CCM already vendored):
#   ./claude-code-methodology/scripts/ccm-fetch.sh
#
# Pin a specific ref (branch, tag, or commit):
#   ./claude-code-methodology/scripts/ccm-fetch.sh --ref v3.9.0
#
# SAFETY: writes ONLY to ./claude-code-methodology/ (the framework source dir).
# The previous source is kept at ./claude-code-methodology.prev for rollback.
# Your project files (memory/, core/, CLAUDE.md, src/, …) are never touched —
# the actual upgrade/merge is a separate, Claude-driven step you run after.

set -euo pipefail

# ---- Defaults -------------------------------------------------------------
REPO="${CCM_REPO:-AribSudia/claude-code-methodology}"
REF="${CCM_REF:-main}"            # main = latest release (CCM ships from main)
DEST="${CCM_DEST:-claude-code-methodology}"
DO_HANDOFF=1

usage() {
  cat <<'EOF'
ccm-fetch.sh — fetch the latest CCM source from GitHub into ./claude-code-methodology/

Usage:
  ccm-fetch.sh [--ref <branch|tag|sha>] [--dest <dir>] [--repo <owner/name>]
               [--no-handoff] [-h|--help]

Options:
  --ref REF       Git ref to fetch (default: main = latest release)
  --dest DIR      Destination folder (default: claude-code-methodology)
  --repo O/N      Source repo (default: AribSudia/claude-code-methodology)
  --no-handoff    Don't print the follow-up upgrade prompt
  -h, --help      Show this help

After fetching, run Claude Code in your project root and paste the
upgrade prompt this script prints (or see bootstrap/UPGRADE_PROTOCOL.md).
EOF
}

# ---- Parse args -----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)        REF="${2:?--ref needs a value}"; shift 2 ;;
    --dest)       DEST="${2:?--dest needs a value}"; shift 2 ;;
    --repo)       REPO="${2:?--repo needs a value}"; shift 2 ;;
    --no-handoff) DO_HANDOFF=0; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "ccm-fetch: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# ---- Pre-flight -----------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "ccm-fetch: git is required but not found on PATH." >&2
  exit 1
fi

URL="https://github.com/${REPO}.git"

# Capture the currently-installed version (if any) for the report.
OLD_VER="(none)"
if [[ -f "${DEST}/VERSION.json" ]]; then
  OLD_VER="$(grep -E '"version"' "${DEST}/VERSION.json" | head -1 | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/' || true)"
  [[ -z "${OLD_VER}" ]] && OLD_VER="(unknown)"
fi

echo "==> Fetching CCM from ${URL} (ref: ${REF})"

# ---- Fetch into a temp dir ------------------------------------------------
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ccm-fetch.XXXXXX")"
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

# Shallow-clone the default branch, then fetch the requested ref if different.
# This handles branches, tags, AND arbitrary commit SHAs on GitHub.
if ! git clone --depth 1 --quiet "${URL}" "${TMP}/repo" 2>/dev/null; then
  echo "ccm-fetch: failed to clone ${URL} — check the repo name and your network." >&2
  exit 1
fi

if [[ "${REF}" != "main" ]]; then
  if ! ( cd "${TMP}/repo" && git fetch --depth 1 --quiet origin "${REF}" \
         && git checkout --quiet FETCH_HEAD ) 2>/dev/null; then
    echo "ccm-fetch: could not resolve ref '${REF}' in ${REPO}." >&2
    exit 1
  fi
fi

# Sanity-check: did we actually get a CCM tree?
if [[ ! -f "${TMP}/repo/VERSION.json" ]]; then
  echo "ccm-fetch: fetched tree has no VERSION.json — not a CCM repo? Aborting." >&2
  exit 1
fi

NEW_VER="$(grep -E '"version"' "${TMP}/repo/VERSION.json" | head -1 | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/' || true)"
[[ -z "${NEW_VER}" ]] && NEW_VER="(unknown)"

# Strip VCS metadata — the project vendors plain files, not a nested git repo.
rm -rf "${TMP}/repo/.git"

# ---- Swap into place (keep previous for rollback) -------------------------
if [[ -e "${DEST}" ]]; then
  rm -rf "${DEST}.prev"
  mv "${DEST}" "${DEST}.prev"
  echo "==> Previous source preserved at ${DEST}.prev (rollback safety)"
fi
mv "${TMP}/repo" "${DEST}"

echo ""
echo "==> CCM source updated: ${OLD_VER}  ->  ${NEW_VER}"
echo "    Location: ${DEST}/"

# ---- Hand off to the Claude-driven upgrade --------------------------------
if [[ "${DO_HANDOFF}" -eq 1 ]]; then
  cat <<EOF

────────────────────────────────────────────────────────────────────────
NEXT STEP — run the intelligent merge (preserves your data).

The fetch above only updated the framework SOURCE. To apply it to your
project, open Claude Code in this directory and paste:

    Read ${DEST}/bootstrap/RUN.md and set up (or upgrade) CCM for this
    project. Detect my situation from the filesystem per the Situation
    Router and execute the matching protocol autonomously to completion
    (PROTOCOL_PRINCIPLES Rule 5). Finish with ./scripts/install-hooks.sh
    and ./scripts/validate-coherence.sh, and report what you did.

CCM will detect that ${OLD_VER} is already installed and run the UPGRADE
protocol (drift detection + Phase 1.6 re-verification), preserving
memory/, decisions, and all project-specific data.
────────────────────────────────────────────────────────────────────────
EOF
fi
