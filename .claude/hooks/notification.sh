#!/usr/bin/env bash
# .claude/hooks/notification.sh
# Item #4 — Notification hook. Receives push events from Claude Code and
# forwards them to whichever transports are configured (CoWork, generic
# webhook). Opt-in only; with no env vars set this is a silent no-op.
#
# Wired in .claude/settings.json under the "Notification" event.

HOOK_NAME="notification"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

EVENT="$(payload_get '.notification.type // .event // "unknown"')"
DETAIL="$(payload_get '.notification.message // .detail // ""')"

notify "${EVENT}" "${DETAIL:-(no detail)}"

allow "notification fan-out complete"
