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

# Input validation (v3.10.0 hardening). The script promises to write ONLY
# inside ./<DEST>/ — enforce that promise, and keep flag-like values out of
# the git invocations (git's parser scans the whole argv for options).
case "${REF}" in
  -*) echo "ccm-fetch: --ref must not start with '-' (got: ${REF})." >&2; exit 2 ;;
esac
case "${DEST}" in
  -*|/*|*..*|*/*|"")
    echo "ccm-fetch: --dest must be a simple relative directory name (got: '${DEST}')." >&2
    exit 2 ;;
esac
case "${REPO}" in
  -*|*" "*|"") echo "ccm-fetch: --repo must be a plain owner/name (got: '${REPO}')." >&2; exit 2 ;;
esac

URL="https://github.com/${REPO}.git"

# Read a version string out of a VERSION.json (best-effort, no jq dependency).
read_ver() {
  [[ -f "$1" ]] || { echo ""; return; }
  grep -E '"version"' "$1" | head -1 | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/'
}

# The version that actually matters to the user is what's DEPLOYED at the
# project root (./VERSION.json) — that's what they're upgrading FROM. Fall
# back to the source folder's version if no root deployment exists yet.
DEPLOYED_VER="$(read_ver "./VERSION.json")"
SOURCE_VER="$(read_ver "${DEST}/VERSION.json")"
OLD_VER="${DEPLOYED_VER:-${SOURCE_VER:-(none)}}"
[[ -z "${OLD_VER}" ]] && OLD_VER="(none)"

# Is CCM already DEPLOYED in this project (root files present), vs. just the
# source folder sitting here? Drives install-vs-upgrade wording below.
IS_UPGRADE=0
if [[ -f "./CLAUDE.md" || -d "./.claude" || -n "${DEPLOYED_VER}" ]]; then
  IS_UPGRADE=1
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
  # `--` terminates option parsing so REF can never be read as a git flag.
  if ! ( cd "${TMP}/repo" && git fetch --depth 1 --quiet origin -- "${REF}" \
         && git checkout --quiet FETCH_HEAD ) 2>/dev/null; then
    echo "ccm-fetch: could not resolve ref '${REF}' in ${REPO}." >&2
    exit 1
  fi
fi

# Sanity-check: did we actually get a CCM tree? VERSION.json alone is too
# weak a marker (any repo can have one) — require the CCM skeleton too,
# since the swap below replaces a known-good copy (v3.10.0 hardening).
if [[ ! -f "${TMP}/repo/VERSION.json" || ! -f "${TMP}/repo/CLAUDE.md" || ! -d "${TMP}/repo/.claude/skills" ]]; then
  echo "ccm-fetch: fetched tree doesn't look like CCM (need VERSION.json + CLAUDE.md + .claude/skills/). Aborting; nothing was changed." >&2
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
fi
mv "${TMP}/repo" "${DEST}"

echo ""
echo "==> STEP 1 of 2 done — source folder updated."
echo "    ${DEST}/   ${OLD_VER}  ->  ${NEW_VER}"
[[ -e "${DEST}.prev" ]] && echo "    (previous source kept at ${DEST}.prev for rollback)"
echo ""
echo "    NOT changed yet: your project files at the root — CLAUDE.md,"
echo "    .claude/, architecture/, memory/, etc. Nothing outside ${DEST}/"
echo "    was touched. Step 2 (below) is what updates those, safely."

# ---- Hand off to the Claude-driven upgrade --------------------------------
if [[ "${DO_HANDOFF}" -eq 1 ]]; then
  if [[ "${IS_UPGRADE}" -eq 1 ]]; then
    ACTION_LINE="CCM is already installed here (${OLD_VER}). Claude will run the"
    ACTION_LINE2="UPGRADE protocol: UPDATE skills/agents/hooks/rules/scripts,"
    ACTION_LINE3="MERGE CLAUDE.md + architecture + docs (keeping your content),"
    ACTION_LINE4="and PRESERVE memory/ + your project data. Then re-verify."
  else
    ACTION_LINE="No CCM is deployed at the root yet. Claude will run the right"
    ACTION_LINE2="bootstrap protocol to scaffold the methodology into this"
    ACTION_LINE3="project from the source folder — filling files with your"
    ACTION_LINE4="real project data, not placeholders."
  fi
  cat <<EOF

────────────────────────────────────────────────────────────────────────
STEP 2 of 2 — apply it to your project (this is the part Claude does).

Open Claude Code in this directory and paste:

    Read ${DEST}/bootstrap/RUN.md and set up (or upgrade) CCM for this
    project. Detect my situation from the filesystem per the Situation
    Router and execute the matching protocol autonomously to completion
    (PROTOCOL_PRINCIPLES Rule 5). Finish with ./scripts/install-hooks.sh
    and ./scripts/validate-coherence.sh, and report what you did.

${ACTION_LINE}
${ACTION_LINE2}
${ACTION_LINE3}
${ACTION_LINE4}

Why two steps: the download is mechanical (this script). The merge needs
judgment — keep your data, reconcile your edits, re-verify changed skills.
A blind copy would overwrite memory/ and your CLAUDE.md; Claude won't.
────────────────────────────────────────────────────────────────────────
EOF
fi
