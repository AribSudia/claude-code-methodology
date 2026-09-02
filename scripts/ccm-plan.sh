#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# ccm-plan.sh — Plan → tasks → dispatch, with a cross-session mesh.
#
# Turns a plan (the live Claude Code plan panel, or any markdown plan)
# into an addressable task graph, then lets every attached session see
# the same graph, claim work without collisions, and talk to each other.
#
# The Claude-side orchestration lives in /arib-plan (.claude/skills/).
# This script is the deterministic substrate: state, locking, ordering.
#
# Store: $(git rev-parse --git-common-dir)/ccm-plan  — shared by every
# worktree of the repo, invisible to git status. Override: $CCM_PLAN_HOME
#
# Usage: bash scripts/ccm-plan.sh <command> [options]
#        bash scripts/ccm-plan.sh help
# Exit:  0 ok · 1 usage/precondition error · 2 nothing to do (next/inbox)
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "ccm-plan: jq is required (VERSION.json requiredTools)" >&2; exit 1; }

# ── colors (tty only) ──────────────────────────────────────────────────
if [ -t 1 ]; then
  RED=$'\033[0;31m'; GRN=$'\033[0;32m'; YEL=$'\033[1;33m'; CYA=$'\033[0;36m'
  DIM=$'\033[2m'; BLD=$'\033[1m'; NC=$'\033[0m'
else
  RED=''; GRN=''; YEL=''; CYA=''; DIM=''; BLD=''; NC=''
fi

die()  { printf '%sccm-plan: %s%s\n' "$RED" "$*" "$NC" >&2; exit 1; }
need_arg() { [ "$1" -ge 2 ] || die "$2 needs a value"; }   # empty IS a value; missing is not
warn() { printf '%sccm-plan: %s%s\n' "$YEL" "$*" "$NC" >&2; }
now()  { date -u +%Y-%m-%dT%H:%M:%SZ; }

STALE_AFTER=900   # a session unseen for 15 min is stale

# ── store location ─────────────────────────────────────────────────────
store_home() {
  if [ -n "${CCM_PLAN_HOME:-}" ]; then printf '%s' "$CCM_PLAN_HOME"; return; fi
  local common
  common="$(git rev-parse --git-common-dir 2>/dev/null || true)"
  [ -n "$common" ] || die "not a git repository (and CCM_PLAN_HOME is unset)"
  case "$common" in /*) : ;; *) common="$(cd "$common" && pwd)" ;; esac
  printf '%s/ccm-plan' "$common"
}
HOME_DIR="$(store_home)"
PLANS_DIR="$HOME_DIR/plans"
SESSIONS="$HOME_DIR/sessions.json"
MESSAGES="$HOME_DIR/messages.jsonl"
ACTIVE_F="$HOME_DIR/active"
LOCK="$HOME_DIR/.lock"

init_store() {
  mkdir -p "$PLANS_DIR"
  [ -f "$SESSIONS" ] || echo '{"sessions":[]}' > "$SESSIONS"
  [ -f "$MESSAGES" ] || : > "$MESSAGES"
}

# ── locking (mkdir is atomic on every POSIX fs, incl. APFS) ────────────
LOCK_HELD=0
lock() {
  local waited=0
  until mkdir "$LOCK" 2>/dev/null; do
    if [ -f "$LOCK/pid" ] && ! kill -0 "$(cat "$LOCK/pid" 2>/dev/null || echo 0)" 2>/dev/null; then
      rm -rf "$LOCK"; continue          # holder died — reclaim
    fi
    waited=$((waited + 1))
    [ "$waited" -gt 100 ] && die "could not acquire lock at $LOCK (held for >10s)"
    sleep 0.1
  done
  echo "$$" > "$LOCK/pid"; LOCK_HELD=1
}
unlock() { [ "$LOCK_HELD" = "1" ] && rm -rf "$LOCK"; LOCK_HELD=0; }
on_exit() { local rc=$?; unlock; exit "$rc"; }   # preserve the real status
trap on_exit EXIT
trap 'unlock; exit 130' INT TERM

write_json() {  # write_json <file> <json-text>
  local f="$1" tmp; tmp="$(mktemp "${f}.XXXXXX")"
  printf '%s\n' "$2" > "$tmp" && mv "$tmp" "$f"
}

# ── plan resolution ────────────────────────────────────────────────────
active_plan() {
  [ -n "${PLAN_ID:-}" ] && { printf '%s' "$PLAN_ID"; return; }
  [ -f "$ACTIVE_F" ] || die "no active plan — run: ccm-plan.sh import ..."
  cat "$ACTIVE_F"
}
plan_file() { printf '%s/%s/plan.json' "$PLANS_DIR" "$(active_plan)"; }
events_file() { printf '%s/%s/events.jsonl' "$PLANS_DIR" "$(active_plan)"; }
require_plan() { local f; f="$(plan_file)"; [ -f "$f" ] || die "plan '$(active_plan)' not found in $PLANS_DIR"; printf '%s' "$f"; }

session_id() { printf '%s' "${SESSION:-${CLAUDE_SESSION_ID:-local-$(hostname -s 2>/dev/null || echo host)-$$}}"; }

log_event() {  # log_event <event> <task> <detail>
  local f; f="$(events_file)"; mkdir -p "$(dirname "$f")"
  jq -cn --arg ts "$(now)" --arg actor "$(session_id)" --arg ev "$1" --arg task "$2" --arg detail "$3" \
     '{ts:$ts,actor:$actor,event:$ev,task:$task,detail:$detail}' >> "$f"
}

# ═══════════════════════════════════════════════════════════════════════
# IMPORT
# ═══════════════════════════════════════════════════════════════════════

transcript_dir() { printf '%s/.claude/projects/%s' "$HOME" "$(pwd | sed 's/[\/.]/-/g')"; }

# Newest transcript for this working directory.
newest_transcript() {
  local d; d="$(transcript_dir)"
  [ -d "$d" ] || die "no transcript directory for this cwd ($d) — use --from file instead"
  local f; f="$(ls -t "$d"/*.jsonl 2>/dev/null | head -1 || true)"
  [ -n "$f" ] || die "no .jsonl transcript in $d — use --from file instead"
  printf '%s' "$f"
}

# Emit tasks JSON from the last TodoWrite (preferred) or ExitPlanMode plan
# in a Claude Code transcript. Format is Claude Code's, not ours — if it
# changes, this returns empty and the caller falls back to file import.
parse_transcript() {
  local f="$1" todos
  todos="$(jq -c 'select(.message.content? != null) | .message.content[]?
                  | select(.type? == "tool_use" and .name? == "TodoWrite")
                  | .input.todos' "$f" 2>/dev/null | tail -1 || true)"
  if [ -n "$todos" ] && [ "$todos" != "null" ]; then
    printf '%s' "$todos" | jq -c '[ .[] | {
        title: (.content // .activeForm // "untitled"),
        imported_status: (.status // "pending")
      } ]'
    return 0
  fi
  # Fallback: the markdown plan from the last ExitPlanMode call.
  local plan
  plan="$(jq -r 'select(.message.content? != null) | .message.content[]?
                 | select(.type? == "tool_use" and .name? == "ExitPlanMode")
                 | .input.plan // empty' "$f" 2>/dev/null | tail -1 || true)"
  [ -n "$plan" ] || return 1
  printf '%s' "$plan" | parse_markdown
}

# Markdown → tasks JSON. Recognises, in priority order:
#   1. the wave Steps contract  (### Step N: title + goal/done_when/checkpoint)
#   2. checkbox items           (- [ ] / - [x])
#   3. bullets & numbered items under a Tasks/Steps/Plan heading
#   4. all top-level bullets
parse_markdown() {
  awk '
    function flush() {
      if (title != "") {
        gsub(/\\/, "\\\\", title); gsub(/"/, "\\\"", title)
        gsub(/\\/, "\\\\", dw);    gsub(/"/, "\\\"", dw)
        gsub(/\\/, "\\\\", goal);  gsub(/"/, "\\\"", goal)
        printf "%s{\"title\":\"%s\",\"done_when\":\"%s\",\"goal\":\"%s\",\"checkpoint\":%s,\"imported_status\":\"%s\"}",
               (n++ ? "," : ""), title, dw, goal, (cp == "true" ? "true" : "false"), st
      }
      title = ""; dw = ""; goal = ""; cp = "false"; st = "pending"
    }
    BEGIN { printf "["; n = 0; mode = "steps"; title = ""; dw = ""; goal = ""; cp = "false"; st = "pending" }
    /^###+[[:space:]]+Step[[:space:]]/ {
      flush()
      t = $0; sub(/^###+[[:space:]]+Step[[:space:]]*[0-9]*[:.)]?[[:space:]]*/, "", t)
      title = t; seen_step = 1; next
    }
    seen_step && /^[[:space:]]*-[[:space:]]*\*\*done_when:\*\*/ {
      t = $0; sub(/^[[:space:]]*-[[:space:]]*\*\*done_when:\*\*[[:space:]]*/, "", t); dw = t; next
    }
    seen_step && /^[[:space:]]*-[[:space:]]*\*\*goal:\*\*/ {
      t = $0; sub(/^[[:space:]]*-[[:space:]]*\*\*goal:\*\*[[:space:]]*/, "", t); goal = t; next
    }
    seen_step && /^[[:space:]]*-[[:space:]]*\*\*checkpoint:\*\*/ {
      cp = ($0 ~ /true/) ? "true" : "false"; next
    }
    { line[++L] = $0 }
    END {
      if (seen_step) { flush(); printf "]"; exit }
      # --- pass 2: checkboxes ---
      for (i = 1; i <= L; i++) {
        if (line[i] ~ /^[[:space:]]*[-*][[:space:]]+\[[ xX~-]\][[:space:]]+/) {
          t = line[i]
          state = (t ~ /\[[xX]\]/) ? "completed" : "pending"
          sub(/^[[:space:]]*[-*][[:space:]]+\[[ xX~-]\][[:space:]]+/, "", t)
          gsub(/\\/, "\\\\", t); gsub(/"/, "\\\"", t)
          printf "%s{\"title\":\"%s\",\"done_when\":\"\",\"goal\":\"\",\"checkpoint\":false,\"imported_status\":\"%s\"}",
                 (n++ ? "," : ""), t, state
        }
      }
      if (n > 0) { printf "]"; exit }
      # --- pass 3: bullets/numbers under a task-ish heading ---
      inside = 0
      for (i = 1; i <= L; i++) {
        if (line[i] ~ /^#+[[:space:]]/) {
          inside = (tolower(line[i]) ~ /task|step|plan|todo|backlog|work/) ? 1 : 0
          continue
        }
        if (!inside) continue
        if (line[i] ~ /^[[:space:]]*([-*][[:space:]]+|[0-9]+[.)][[:space:]]+)/) {
          t = line[i]; sub(/^[[:space:]]*([-*][[:space:]]+|[0-9]+[.)][[:space:]]+)/, "", t)
          if (t == "") continue
          gsub(/\\/, "\\\\", t); gsub(/"/, "\\\"", t)
          printf "%s{\"title\":\"%s\",\"done_when\":\"\",\"goal\":\"\",\"checkpoint\":false,\"imported_status\":\"pending\"}", (n++ ? "," : ""), t
        }
      }
      if (n > 0) { printf "]"; exit }
      # --- pass 4: every top-level bullet / numbered line ---
      for (i = 1; i <= L; i++) {
        if (line[i] ~ /^([-*][[:space:]]+|[0-9]+[.)][[:space:]]+)/) {
          t = line[i]; sub(/^([-*][[:space:]]+|[0-9]+[.)][[:space:]]+)/, "", t)
          if (t == "") continue
          gsub(/\\/, "\\\\", t); gsub(/"/, "\\\"", t)
          printf "%s{\"title\":\"%s\",\"done_when\":\"\",\"goal\":\"\",\"checkpoint\":false,\"imported_status\":\"pending\"}", (n++ ? "," : ""), t
        }
      }
      printf "]"
    }
  '
}

cmd_import() {
  local from="auto" src="" id="" title="" force=0 chain=0 keep_done=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --from) need_arg $# "$1"; from="$2"; shift 2 ;;
      --source|-s) need_arg $# "$1"; src="$2"; shift 2 ;;
      --id) need_arg $# "$1"; id="$2"; shift 2 ;;
      --title) need_arg $# "$1"; title="$2"; shift 2 ;;
      --chain) chain=1; shift ;;
      --keep-done) keep_done=1; shift ;;
      --force) force=1; shift ;;
      -) from="stdin"; shift ;;
      *) die "import: unknown option '$1'" ;;
    esac
  done

  init_store
  local tasks_json="" source_kind="$from" source_path=""

  case "$from" in
    stdin) tasks_json="$(parse_markdown)"; source_path="(stdin)" ;;
    file)
      [ -n "$src" ] || die "import --from file needs --source <path>"
      [ -f "$src" ] || die "no such file: $src"
      tasks_json="$(parse_markdown < "$src")"; source_path="$src" ;;
    transcript)
      source_path="${src:-$(newest_transcript)}"
      tasks_json="$(parse_transcript "$source_path")" || die "no TodoWrite or ExitPlanMode plan found in $source_path" ;;
    auto)
      if [ -n "$src" ]; then
        source_kind="file"; source_path="$src"; tasks_json="$(parse_markdown < "$src")"
      else
        source_kind="transcript"; source_path="$(newest_transcript)"
        if ! tasks_json="$(parse_transcript "$source_path")"; then
          die "no plan found in the live transcript — pass --source <plan.md>"
        fi
      fi ;;
    *) die "import: --from must be transcript, file, or stdin" ;;
  esac

  [ -n "$tasks_json" ] || die "parsed 0 tasks from $source_path"
  local count; count="$(printf '%s' "$tasks_json" | jq 'length')"
  [ "$count" -gt 0 ] || die "parsed 0 tasks from $source_path (nothing matched a task pattern)"

  [ -n "$id" ] || id="plan-$(date -u +%Y%m%d-%H%M%S)"
  local dir="$PLANS_DIR/$id"
  [ -d "$dir" ] && [ "$force" = "0" ] && die "plan '$id' already exists (use --force to overwrite)"
  mkdir -p "$dir"
  [ -n "$title" ] || title="$id"

  local plan
  plan="$(printf '%s' "$tasks_json" | jq \
    --arg id "$id" --arg title "$title" --arg ts "$(now)" \
    --arg kind "$source_kind" --arg path "$source_path" \
    --argjson chain "$chain" --argjson keep "$keep_done" '
    def pad: if . < 10 then "T0\(.)" else "T\(.)" end;
    [ to_entries[]
      | (.key + 1) as $n
      | .value as $t
      | {
          id: ($n | pad),
          title: ($t.title // "untitled"),
          status: (if $keep == 1 and ($t.imported_status == "completed") then "done" else "todo" end),
          deps: (if $chain == 1 and $n > 1 then [ (($n - 1) | pad) ] else [] end),
          agent: "",
          lane: "",
          goal: ($t.goal // ""),
          done_when: ($t.done_when // ""),
          checkpoint: ($t.checkpoint // false),
          owner: "",
          claimed_at: "",
          finished_at: "",
          imported_status: ($t.imported_status // "pending"),
          notes: []
        }
    ] as $tasks
    | { id: $id, title: $title, created_at: $ts, updated_at: $ts,
        source: { kind: $kind, path: $path }, tasks: $tasks }')"

  lock
  write_json "$dir/plan.json" "$plan"
  printf '%s' "$id" > "$ACTIVE_F"
  unlock
  PLAN_ID="$id"; log_event "import" "" "$count tasks from $source_kind:$source_path"

  printf '%s✓ imported %s task(s)%s from %s%s%s into plan %s%s%s\n' \
    "$GRN" "$count" "$NC" "$DIM" "$source_path" "$NC" "$BLD" "$id" "$NC"
  printf '  %sactive plan set. Next: enrich deps/agents (ccm-plan.sh set …), then ccm-plan.sh next%s\n' "$DIM" "$NC"
}

# ═══════════════════════════════════════════════════════════════════════
# QUERY
# ═══════════════════════════════════════════════════════════════════════

# Tasks that are ready: status todo, every dep done, lane not held by an
# in-flight claim. At most one task per non-empty lane (lane = mutex).
ready_json() {
  local f; f="$(require_plan)"
  jq -c '
    (.tasks | map(select(.status == "done") | .id)) as $done
    | (.tasks | map(select(.status == "claimed" and .lane != "") | .lane)) as $busy
    | [ .tasks[]
        | select(.status == "todo")
        | select((.deps - $done) | length == 0)
        | select(.lane == "" or (.lane as $l | $busy | index($l) | not)) ]
    | reduce .[] as $t ([]; if ($t.lane != "") and (map(.lane) | index($t.lane)) then . else . + [$t] end)
  ' "$f"
}

cmd_next() {
  local count=1 json=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --count|-n) need_arg $# "$1"; count="$2"; shift 2 ;;
      --json) json=1; shift ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      --all) count=9999; shift ;;
      *) die "next: unknown option '$1'" ;;
    esac
  done
  local ready; ready="$(ready_json | jq -c --argjson n "$count" '.[0:$n]')"
  local n; n="$(printf '%s' "$ready" | jq 'length')"
  if [ "$json" = "1" ]; then printf '%s\n' "$ready"; else
    if [ "$n" = "0" ]; then
      printf '%sno ready tasks%s' "$YEL" "$NC"
      local blocked; blocked="$(jq '[.tasks[]|select(.status=="todo")]|length' "$(require_plan)")"
      [ "$blocked" -gt 0 ] && printf ' — %s todo task(s) still waiting on deps or a busy lane' "$blocked"
      printf '\n'
    else
      printf '%s' "$ready" | jq -r '.[] | "\(.id)  [\(if .lane == "" then "-" else .lane end)]  \(if .agent == "" then "(unassigned)" else .agent end)  \(.title)"'
    fi
  fi
  [ "$n" = "0" ] && return 2 || return 0
}

cmd_list() {
  local status="" json=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --status) need_arg $# "$1"; status="$2"; shift 2 ;;
      --json) json=1; shift ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      *) die "list: unknown option '$1'" ;;
    esac
  done
  local f; f="$(require_plan)"
  local sel; sel="$(jq -c --arg s "$status" '[.tasks[] | select($s == "" or .status == $s)]' "$f")"
  if [ "$json" = "1" ]; then printf '%s\n' "$sel"; return 0; fi
  printf '%s' "$sel" | jq -r '.[] | "\(.id)  \(.status | (. + "        ")[0:8])  \(if .owner == "" then "" else "@" + .owner + " " end)\(.title)"'
}

cmd_show() {
  local id="${1:?show: need a task id}"
  jq --arg id "$id" '.tasks[] | select(.id == $id)' "$(require_plan)" \
    | grep -q . || die "no task '$id'"
  jq --arg id "$id" '.tasks[] | select(.id == $id)' "$(require_plan)"
}

# ═══════════════════════════════════════════════════════════════════════
# MUTATE
# ═══════════════════════════════════════════════════════════════════════

mutate() {  # mutate <jq-filter> [jq args...]
  local f; f="$(require_plan)"
  local filter="$1"; shift
  lock
  local out; out="$(jq --arg _ts "$(now)" "$filter | .updated_at = \$_ts" "$@" "$f")" || { unlock; die "update failed"; }
  write_json "$f" "$out"
  unlock
}

task_exists() { jq -e --arg id "$1" 'any(.tasks[]; .id == $id)' "$(require_plan)" >/dev/null 2>&1 || die "no task '$1'"; }

cmd_set() {
  local id="${1:?set: need a task id}"; shift
  task_exists "$id"
  local agent="" lane="" deps="" dw="" goal="" cp="" title=""
  local set_agent=0 set_lane=0 set_deps=0 set_dw=0 set_goal=0 set_cp=0 set_title=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --agent) need_arg $# "$1"; agent="$2"; set_agent=1; shift 2 ;;
      --lane) need_arg $# "$1"; lane="$2"; set_lane=1; shift 2 ;;
      --deps) need_arg $# "$1"; deps="$2"; set_deps=1; shift 2 ;;
      --done-when) need_arg $# "$1"; dw="$2"; set_dw=1; shift 2 ;;
      --goal) need_arg $# "$1"; goal="$2"; set_goal=1; shift 2 ;;
      --checkpoint) need_arg $# "$1"; cp="$2"; set_cp=1; shift 2 ;;
      --title) need_arg $# "$1"; title="$2"; set_title=1; shift 2 ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      *) die "set: unknown option '$1'" ;;
    esac
  done
  # validate deps exist and introduce no cycle
  if [ "$set_deps" = "1" ]; then
    local d
    for d in ${deps//,/ }; do
      [ "$d" = "$id" ] && die "set: task $id cannot depend on itself"
      task_exists "$d"
    done
  fi
  mutate '.tasks |= map(if .id == $id then
        (if $sa == 1 then .agent = $agent else . end)
      | (if $sl == 1 then .lane = $lane else . end)
      | (if $sd == 1 then .deps = ($deps | split(",") | map(select(length > 0))) else . end)
      | (if $sw == 1 then .done_when = $dw else . end)
      | (if $sg == 1 then .goal = $goal else . end)
      | (if $sc == 1 then .checkpoint = ($cp == "true") else . end)
      | (if $st == 1 then .title = $title else . end)
    else . end)' \
    --arg id "$id" --arg agent "$agent" --arg lane "$lane" --arg deps "$deps" \
    --arg dw "$dw" --arg goal "$goal" --arg cp "$cp" --arg title "$title" \
    --argjson sa "$set_agent" --argjson sl "$set_lane" --argjson sd "$set_deps" \
    --argjson sw "$set_dw" --argjson sg "$set_goal" --argjson sc "$set_cp" --argjson st "$set_title"
  # cycle check after the write — a cycle would deadlock `next` forever
  if [ "$set_deps" = "1" ]; then
    local cyc
    cyc="$(jq -r '
      . as $root
      | def deps_of($t): [ $root.tasks[] | select(.id == $t) | .deps[] ];
        def cyc($t; $seen):
          if ($seen | index($t)) then true
          else deps_of($t) as $d
            | if ($d | length) == 0 then false
              else any($d[]; cyc(.; $seen + [$t]))
              end
          end;
        [ $root.tasks[].id | cyc(.; []) ] | any' "$(require_plan)" 2>/dev/null || echo error)"
    case "$cyc" in
      true)  warn "dependency cycle created by $id — nothing in that ring will ever be ready; clear it: ccm-plan.sh set $id --deps ''" ;;
      false) : ;;
      *)     warn "cycle check could not run on $id (unexpected plan shape) — verify deps by hand" ;;
    esac
  fi
  log_event "set" "$id" "agent=$agent lane=$lane deps=$deps"
  printf '%s✓%s %s updated\n' "$GRN" "$NC" "$id"
}

cmd_claim() {
  local id="" force=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --session) need_arg $# "$1"; SESSION="$2"; shift 2 ;;
      --agent) need_arg $# "$1"; CLAIM_AGENT="$2"; shift 2 ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      --force) force=1; shift ;;
      --next) id="__next__"; shift ;;
      -*) die "claim: unknown option '$1'" ;;
      *) id="$1"; shift ;;
    esac
  done
  [ -n "$id" ] || die "claim: need a task id (or --next)"
  if [ "$id" = "__next__" ]; then
    id="$(ready_json | jq -r '.[0].id // empty')"
    [ -n "$id" ] || { printf '%sno ready task to claim%s\n' "$YEL" "$NC"; return 2; }
  fi
  task_exists "$id"

  local f sid; f="$(require_plan)"; sid="$(session_id)"
  lock
  local state; state="$(jq -r --arg id "$id" '.tasks[]|select(.id==$id)|.status' "$f")"
  if [ "$state" != "todo" ] && [ "$force" = "0" ]; then
    local owner; owner="$(jq -r --arg id "$id" '.tasks[]|select(.id==$id)|.owner' "$f")"
    unlock; die "$id is '$state'${owner:+ (owned by $owner)} — not claimable (use --force to steal)"
  fi
  if [ "$force" = "0" ]; then
    local unmet; unmet="$(jq -r --arg id "$id" '
      (.tasks | map(select(.status=="done")|.id)) as $d
      | .tasks[] | select(.id==$id) | (.deps - $d) | join(",")' "$f")"
    [ -n "$unmet" ] && { unlock; die "$id blocked on unfinished dep(s): $unmet"; }
    local lane busy
    lane="$(jq -r --arg id "$id" '.tasks[]|select(.id==$id)|.lane' "$f")"
    if [ -n "$lane" ]; then
      busy="$(jq -r --arg id "$id" --arg l "$lane" '[.tasks[]|select(.id!=$id and .lane==$l and .status=="claimed")|.id]|join(",")' "$f")"
      [ -n "$busy" ] && { unlock; die "lane '$lane' is busy ($busy) — pick another task"; }
    fi
  fi
  local out; out="$(jq --arg id "$id" --arg sid "$sid" --arg ts "$(now)" --arg ag "${CLAIM_AGENT:-}" '
    .updated_at = $ts
    | .tasks |= map(if .id == $id then
        .status = "claimed" | .owner = $sid | .claimed_at = $ts
        | (if $ag != "" then .agent = $ag else . end)
      else . end)' "$f")"
  write_json "$f" "$out"
  unlock
  log_event "claim" "$id" "$sid"
  jq -r --arg id "$id" '.tasks[]|select(.id==$id)|"\(.id)  \(.title)\n  agent: \(if .agent=="" then "(unassigned)" else .agent end)  lane: \(if .lane=="" then "-" else .lane end)  checkpoint: \(.checkpoint)\n  done_when: \(if .done_when=="" then "(none recorded)" else .done_when end)"' "$f"
}

finish() {  # finish <status> <id> <note>
  local st="$1" id="$2" note="$3"
  task_exists "$id"
  mutate '.tasks |= map(if .id == $id then
      .status = $st | .finished_at = $ts
      | (if $note != "" then .notes += [{ts: $ts, by: $by, text: $note}] else . end)
      | (if $st == "done" then .owner = .owner else . end)
    else . end)' \
    --arg id "$id" --arg st "$st" --arg ts "$(now)" --arg by "$(session_id)" --arg note "$note"
  log_event "$st" "$id" "$note"
}

cmd_done()  { local id="${1:?done: need a task id}"; shift; local note=""; [ "${1:-}" = "--note" ] && note="${2:-}"
              finish done "$id" "$note"; printf '%s✓ %s done%s\n' "$GRN" "$id" "$NC"
              local left; left="$(ready_json | jq 'length')"; printf '  %s%s task(s) now ready%s\n' "$DIM" "$left" "$NC"; }
cmd_fail()  { local id="${1:?fail: need a task id}"; shift; local r=""; [ "${1:-}" = "--reason" ] && r="${2:-}"
              finish failed "$id" "$r"; printf '%s✗ %s failed%s %s\n' "$RED" "$id" "$NC" "$r"; }
cmd_block() { local id="${1:?block: need a task id}"; shift; local r=""; [ "${1:-}" = "--reason" ] && r="${2:-}"
              finish blocked "$id" "$r"; printf '%s⏸ %s blocked%s %s\n' "$YEL" "$id" "$NC" "$r"; }
cmd_reopen(){ local id="${1:?reopen: need a task id}"; task_exists "$id"
              mutate '.tasks |= map(if .id == $id then .status="todo" | .owner="" | .claimed_at="" | .finished_at="" else . end)' --arg id "$id"
              log_event "reopen" "$id" ""; printf '%s↻ %s reopened%s\n' "$CYA" "$id" "$NC"; }

cmd_note() {
  local id="${1:?note: need a task id}"; shift
  local text="${1:?note: need text}"
  task_exists "$id"
  mutate '.tasks |= map(if .id == $id then .notes += [{ts:$ts, by:$by, text:$text}] else . end)' \
    --arg id "$id" --arg ts "$(now)" --arg by "$(session_id)" --arg text "$text"
  printf '%s✓%s note added to %s\n' "$GRN" "$NC" "$id"
}

# ═══════════════════════════════════════════════════════════════════════
# SESSION MESH
# ═══════════════════════════════════════════════════════════════════════

cmd_attach() {
  local role="worker" name=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --session) need_arg $# "$1"; SESSION="$2"; shift 2 ;;
      --role) need_arg $# "$1"; role="$2"; shift 2 ;;
      --name) need_arg $# "$1"; name="$2"; shift 2 ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      *) die "attach: unknown option '$1'" ;;
    esac
  done
  init_store
  local sid; sid="$(session_id)"
  local branch; branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  lock
  local out; out="$(jq --arg id "$sid" --arg role "$role" --arg name "${name:-$sid}" \
      --arg cwd "$(pwd)" --arg branch "$branch" --arg ts "$(now)" --arg pid "$$" '
    .sessions = ((.sessions | map(select(.id != $id))) + [{
      id: $id, name: $name, role: $role, cwd: $cwd, branch: $branch,
      pid: $pid, attached_at: $ts, last_seen: $ts, current_task: ""
    }])' "$SESSIONS")"
  write_json "$SESSIONS" "$out"
  unlock
  [ -f "$ACTIVE_F" ] && log_event "attach" "" "$role @ $branch"
  printf '%s✓ attached%s as %s%s%s (role: %s, branch: %s)\n' "$GRN" "$NC" "$BLD" "$sid" "$NC" "$role" "$branch"
  cmd_sessions
}

cmd_detach() {
  # --session is handled globally before dispatch
  init_store
  local sid; sid="$(session_id)"
  lock
  write_json "$SESSIONS" "$(jq --arg id "$sid" '.sessions |= map(select(.id != $id))' "$SESSIONS")"
  unlock
  printf '%s✓ detached%s %s\n' "$GRN" "$NC" "$sid"
}

cmd_heartbeat() {
  # --session is handled globally before dispatch
  init_store
  local sid; sid="$(session_id)"
  lock
  write_json "$SESSIONS" "$(jq --arg id "$sid" --arg ts "$(now)" \
    '.sessions |= map(if .id == $id then .last_seen = $ts else . end)' "$SESSIONS")"
  unlock
}

cmd_sessions() {
  init_store
  local json=0; [ "${1:-}" = "--json" ] && json=1
  local nowsec; nowsec="$(date -u +%s)"
  local enriched
  enriched="$(jq -c --argjson now "$nowsec" --argjson stale "$STALE_AFTER" '
    [ .sessions[] | . + { stale: ((($now - (.last_seen | fromdateiso8601)) > $stale)) } ]' "$SESSIONS")"
  if [ "$json" = "1" ]; then printf '%s\n' "$enriched"; return 0; fi
  local n; n="$(printf '%s' "$enriched" | jq 'length')"
  if [ "$n" = "0" ]; then printf '  %sno sessions attached%s\n' "$DIM" "$NC"; return 0; fi
  printf '  %sattached sessions (%s):%s\n' "$BLD" "$n" "$NC"
  printf '%s' "$enriched" | jq -r '.[] | "    \(if .stale then "○" else "●" end) \(.id)  [\(.role)]  \(.branch)  \(if .current_task == "" then "idle" else "on " + .current_task end)\(if .stale then "  (stale)" else "" end)"'
}

cmd_post() {
  local to="all" text=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --session|--from) need_arg $# "$1"; SESSION="$2"; shift 2 ;;
      --to) need_arg $# "$1"; to="$2"; shift 2 ;;
      --text|-m) need_arg $# "$1"; text="$2"; shift 2 ;;
      --task) need_arg $# "$1"; MSG_TASK="$2"; shift 2 ;;
      *) die "post: unknown option '$1'" ;;
    esac
  done
  [ -n "$text" ] || die "post: need --text"
  init_store
  lock
  jq -cn --arg id "m$(date -u +%s)-$$" --arg ts "$(now)" --arg from "$(session_id)" \
     --arg to "$to" --arg text "$text" --arg task "${MSG_TASK:-}" \
     '{id:$id,ts:$ts,from:$from,to:$to,task:$task,text:$text,read_by:[]}' >> "$MESSAGES"
  unlock
  printf '%s✓ posted%s to %s\n' "$GRN" "$NC" "$to"
}

cmd_inbox() {
  local json=0 all=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --session) need_arg $# "$1"; SESSION="$2"; shift 2 ;;
      --json) json=1; shift ;;
      --all) all=1; shift ;;
      *) die "inbox: unknown option '$1'" ;;
    esac
  done
  init_store
  local sid; sid="$(session_id)"
  local msgs
  msgs="$(jq -sc --arg me "$sid" --argjson all "$all" '
    [ .[] | select(.from != $me) | select(.to == "all" or .to == $me)
      | select($all == 1 or ((.read_by // []) | index($me) | not)) ]' "$MESSAGES")"
  local n; n="$(printf '%s' "$msgs" | jq 'length')"
  if [ "$json" = "1" ]; then printf '%s\n' "$msgs"; else
    if [ "$n" = "0" ]; then printf '  %sinbox empty%s\n' "$DIM" "$NC"; else
      printf '%s' "$msgs" | jq -r '.[] | "  \(.ts)  \(.from)\(if .task == "" then "" else " [" + .task + "]" end): \(.text)"'
    fi
  fi
  if [ "$n" != "0" ] && [ "$all" = "0" ]; then   # mark read
    lock
    local tmp; tmp="$(mktemp)"
    jq -c --arg me "$sid" 'if (.from != $me) and (.to == "all" or .to == $me)
        then .read_by = ((.read_by // []) + [$me] | unique) else . end' "$MESSAGES" > "$tmp" && mv "$tmp" "$MESSAGES"
    unlock
  fi
  [ "$n" = "0" ] && return 2 || return 0
}

# ═══════════════════════════════════════════════════════════════════════
# VIEWS
# ═══════════════════════════════════════════════════════════════════════

render_board() {
  local f; f="$(require_plan)"
  jq -r '
    def row: "| \(.id) | \(.title) | \(.status) | \(if .agent == "" then "—" else .agent end) | \(if .lane == "" then "—" else .lane end) | \(if (.deps|length) == 0 then "—" else (.deps|join(", ")) end) | \(if .owner == "" then "—" else .owner end) |";
    "# Task Board — \(.title)",
    "",
    "> plan `\(.id)` · source `\(.source.kind):\(.source.path)` · updated \(.updated_at)",
    "> Generated by `scripts/ccm-plan.sh board` — do not hand-edit; edit via the CLI.",
    "",
    "| Task | Title | Status | Agent | Lane | Deps | Owner |",
    "|------|-------|--------|-------|------|------|-------|",
    (.tasks[] | row),
    "",
    "**\(.tasks | map(select(.status == "done")) | length)/\(.tasks | length) done**" +
    " · \(.tasks | map(select(.status == "claimed")) | length) in flight" +
    " · \(.tasks | map(select(.status == "blocked" or .status == "failed")) | length) blocked/failed"
  ' "$f"
}

cmd_board() {
  local export=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --export) need_arg $# "$1"; export="$2"; shift 2 ;;
      --plan) need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
      *) die "board: unknown option '$1'" ;;
    esac
  done
  if [ -n "$export" ]; then
    mkdir -p "$(dirname "$export")"
    render_board > "$export"
    printf '%s✓ board exported%s → %s\n' "$GRN" "$NC" "$export"
  else
    render_board
  fi
}

cmd_status() {
  init_store
  if [ ! -f "$ACTIVE_F" ]; then
    printf '  %sno active plan%s — import one: %sccm-plan.sh import%s\n' "$DIM" "$NC" "$CYA" "$NC"
    cmd_sessions; return 0
  fi
  local f; f="$(plan_file)"
  [ -f "$f" ] || { warn "active plan '$(active_plan)' has no plan.json"; return 0; }
  printf '\n%s╔══ CCM Plan Mesh ═══════════════════════════════════╗%s\n' "$BLD" "$NC"
  jq -r --arg g "$GRN" --arg y "$YEL" --arg r "$RED" --arg d "$DIM" --arg n "$NC" '
    "  plan: \(.id)  —  \(.title)",
    "  \($g)done \(.tasks|map(select(.status=="done"))|length)\($n) · " +
    "\($y)in-flight \(.tasks|map(select(.status=="claimed"))|length)\($n) · " +
    "todo \(.tasks|map(select(.status=="todo"))|length) · " +
    "\($r)blocked/failed \(.tasks|map(select(.status=="blocked" or .status=="failed"))|length)\($n)"' "$f"
  echo ""
  printf '  %sready now:%s\n' "$BLD" "$NC"
  local ready; ready="$(ready_json)"
  if [ "$(printf '%s' "$ready" | jq 'length')" = "0" ]; then
    printf '    %s—%s\n' "$DIM" "$NC"
  else
    printf '%s' "$ready" | jq -r '.[0:5][] | "    \(.id)  \(.title)"'
  fi
  echo ""
  cmd_sessions
  local unread; unread="$(jq -sc --arg me "$(session_id)" '[.[]|select(.from != $me)|select(.to=="all" or .to==$me)|select((.read_by//[])|index($me)|not)]|length' "$MESSAGES")"
  [ "$unread" != "0" ] && printf '\n  %s✉ %s unread message(s)%s — ccm-plan.sh inbox\n' "$YEL" "$unread" "$NC"
  echo ""
}

cmd_plans() {
  init_store
  local act=""; [ -f "$ACTIVE_F" ] && act="$(cat "$ACTIVE_F")"
  local d
  for d in "$PLANS_DIR"/*/; do
    [ -d "$d" ] || continue
    local id; id="$(basename "$d")"
    local mark="  "; [ "$id" = "$act" ] && mark="${GRN}▸ ${NC}"
    printf '%s%s  %s\n' "$mark" "$id" "$(jq -r '"\(.tasks|map(select(.status=="done"))|length)/\(.tasks|length) done  —  \(.title)"' "$d/plan.json" 2>/dev/null || echo '(unreadable)')"
  done
}

cmd_active() {
  init_store
  if [ -z "${1:-}" ]; then [ -f "$ACTIVE_F" ] && cat "$ACTIVE_F" || die "no active plan"; return 0; fi
  [ -d "$PLANS_DIR/$1" ] || die "no plan '$1'"
  printf '%s' "$1" > "$ACTIVE_F"
  printf '%s✓ active plan → %s%s\n' "$GRN" "$1" "$NC"
}

cmd_events() {
  local n=20; [ "${1:-}" = "--tail" ] && n="${2:-20}"
  local f; f="$(events_file)"
  [ -f "$f" ] || { printf '  %sno events%s\n' "$DIM" "$NC"; return 0; }
  tail -n "$n" "$f" | jq -r '"  \(.ts)  \(.actor)  \(.event)\(if .task == "" then "" else " " + .task end)  \(.detail)"'
}

cmd_help() {
  cat <<'HELP'
ccm-plan.sh — plan → tasks → dispatch, with a cross-session mesh

PLAN
  import [--from transcript|file|stdin] [--source PATH] [--id ID]
         [--title T] [--chain] [--keep-done] [--force]
                              import a plan into a task graph
                              (default: the live Claude Code plan panel)
  plans                       list every imported plan
  active [ID]                 show or switch the active plan
  board [--export PATH]       render the task board as markdown
  status                      dashboard: counts, ready tasks, sessions, mail
  events [--tail N]           append-only audit log

TASKS
  list [--status S] [--json]  list tasks
  next [--count N] [--json]   tasks ready to start (deps met, lane free)
  show ID                     one task as JSON
  set ID [--agent A] [--lane L] [--deps a,b] [--done-when S]
         [--goal S] [--checkpoint true|false] [--title S]
  claim ID|--next [--agent A] [--force]      take a task (atomic)
  done ID [--note "…"]        finish · fail ID --reason "…" · block ID --reason "…"
  reopen ID                   back to todo · note ID "text"  append a note

MESH
  attach [--role R] [--name N]  register this session
  sessions [--json]             who else is working, and on what
  heartbeat                     refresh liveness (sessions go stale after 15m)
  post --to all|SID --text "…" [--task ID]   durable message
  inbox [--all] [--json]        unread messages (marks them read)
  detach                        deregister

  selftest                      run the built-in test suite

Session id comes from --session, else $CLAUDE_SESSION_ID, else host+pid.
Store: $(git rev-parse --git-common-dir)/ccm-plan  (override: $CCM_PLAN_HOME)
Every worktree of the repo shares one store — that is what makes the mesh work.
HELP
}

# ═══════════════════════════════════════════════════════════════════════
# SELFTEST
# ═══════════════════════════════════════════════════════════════════════

cmd_selftest() {
  local tmp; tmp="$(mktemp -d)"; local self="${BASH_SOURCE[0]}"
  local pass=0 fail=0
  t() { if eval "$2" >/dev/null 2>&1; then pass=$((pass+1)); printf '  %s✓%s %s\n' "$GRN" "$NC" "$1"
        else fail=$((fail+1)); printf '  %s✗%s %s\n' "$RED" "$NC" "$1"; fi; }
  export CCM_PLAN_HOME="$tmp/store"

  cat > "$tmp/plan.md" <<'MD'
# A plan
## Tasks
- [ ] first thing
- [x] already done thing
- [ ] third "quoted" thing
MD
  echo "  --- import ---"
  t "import from file"        "bash '$self' import --from file --source '$tmp/plan.md' --id t1"
  t "3 tasks parsed"          "[ \"\$(bash '$self' list --json | jq length)\" = 3 ]"
  t "checkbox state captured" "[ \"\$(bash '$self' show T02 | jq -r .imported_status)\" = completed ]"
  t "quotes survive"          "bash '$self' show T03 | jq -e '.title | contains(\"quoted\")'"

  echo "  --- graph ---"
  t "deps set"                "bash '$self' set T02 --deps T01"
  t "next respects deps"      "[ \"\$(bash '$self' next --count 9 --json | jq 'map(.id)|index(\"T02\")')\" = null ]"
  t "lane mutex"              "bash '$self' set T01 --lane core && bash '$self' set T03 --lane core"
  t "one task per lane"       "[ \"\$(bash '$self' next --count 9 --json | jq length)\" = 1 ]"
  t "self-dep rejected"       "! bash '$self' set T01 --deps T01"
  t "unknown dep rejected"    "! bash '$self' set T01 --deps T99"

  echo "  --- claim/finish ---"
  t "claim ready task"        "bash '$self' claim T01 --session s1"
  t "double claim blocked"    "! bash '$self' claim T01 --session s2"
  t "blocked dep unclaimable" "! bash '$self' claim T02 --session s2"
  t "busy lane unclaimable"   "! bash '$self' claim T03 --session s2"
  t "done unblocks dep"       "bash '$self' done T01 && bash '$self' claim T02 --session s2"
  t "force steals"            "bash '$self' claim T02 --session s3 --force"
  t "fail records reason"     "bash '$self' fail T03 --reason boom && bash '$self' show T03 | jq -e '.notes[0].text == \"boom\"'"
  t "reopen resets owner"     "bash '$self' reopen T03 && [ \"\$(bash '$self' show T03 | jq -r .owner)\" = '' ]"

  echo "  --- mesh ---"
  t "attach"                  "bash '$self' attach --session s1 --role worker"
  t "attach second"           "bash '$self' attach --session s2 --role reviewer"
  t "sessions lists both"     "[ \"\$(bash '$self' sessions --json | jq length)\" = 2 ]"
  t "post + inbox"            "bash '$self' post --session s1 --to s2 --text hi && bash '$self' inbox --session s2 --json | jq -e 'length == 1'"
  t "inbox marks read"        "! bash '$self' inbox --session s2 --json | jq -e 'length > 0'"
  t "sender excluded"         "! bash '$self' inbox --session s1"
  t "detach"                  "bash '$self' detach --session s2 && [ \"\$(bash '$self' sessions --json | jq length)\" = 1 ]"

  echo "  --- views ---"
  t "board renders"           "bash '$self' board | grep -q '| Task |'"
  t "board exports"           "bash '$self' board --export '$tmp/B.md' && grep -q 'Task Board' '$tmp/B.md'"
  t "status runs"             "bash '$self' status"
  t "events recorded"         "bash '$self' events | grep -q claim"
  t "plans lists t1"          "bash '$self' plans | grep -q t1"

  echo "  --- parsers ---"
  cat > "$tmp/steps.md" <<'MD'
## Steps
### Step 1: build the thing
- **goal:** make it exist
- **done_when:** tests pass
- **checkpoint:** false
### Step 2: ship it
- **done_when:** health check green
- **checkpoint:** true
MD
  t "steps contract parsed"   "bash '$self' import --from file --source '$tmp/steps.md' --id t2 --chain && [ \"\$(bash '$self' list --json | jq length)\" = 2 ]"
  t "done_when captured"      "bash '$self' show T01 | jq -e '.done_when == \"tests pass\"'"
  t "checkpoint captured"     "bash '$self' show T02 | jq -e '.checkpoint == true'"
  t "--chain wires deps"      "bash '$self' show T02 | jq -e '.deps == [\"T01\"]'"
  t "stdin import"            "printf -- '- alpha\n- beta\n' | bash '$self' import - --id t3 && [ \"\$(bash '$self' list --json | jq length)\" = 2 ]"
  t "empty plan rejected"     "! printf 'nothing here\n' | bash '$self' import - --id t4"
  t "duplicate id rejected"   "! bash '$self' import --from file --source '$tmp/plan.md' --id t1"

  echo "  --- cycle guard ---"
  bash "$self" import --from file --source "$tmp/plan.md" --id t5 --force >/dev/null 2>&1
  t "legit chain is silent"   "! bash '$self' set T02 --deps T01 2>&1 | grep -i cycle"
  t "diamond is silent"       "bash '$self' set T03 --deps T01 && ! bash '$self' set T03 --deps T01,T02 2>&1 | grep -i cycle"
  t "2-node cycle warns"      "bash '$self' set T01 --deps T02 2>&1 | grep -i cycle"
  t "3-node cycle warns"      "bash '$self' set T01 --deps '' && bash '$self' set T03 --deps T02 && bash '$self' set T01 --deps T03 && bash '$self' set T02 --deps T01 2>&1 | grep -i cycle"
  t "clearing deps recovers"  "bash '$self' set T02 --deps '' && ! bash '$self' set T01 --deps T03 2>&1 | grep -i cycle"
  t "empty value accepted"    "bash '$self' set T01 --lane '' && [ \"\$(bash '$self' show T01 | jq -r .lane)\" = '' ]"
  t "missing value rejected"  "! bash '$self' set T01 --lane"
  t "cleared lane frees mutex" "bash '$self' set T02 --lane '' && bash '$self' set T03 --deps '' --lane ''"
  t "failure exit code is 1"  "bash '$self' show T99; [ \"\$?\" = 1 ]"

  echo "  --- global --session ---"
  bash "$self" import --from file --source "$tmp/plan.md" --id t6 --force >/dev/null 2>&1
  t "done attributes actor"   "bash '$self' claim T01 --session who1 && bash '$self' done T01 --session who1 && bash '$self' events --tail 3 | grep -q 'who1  done'"
  t "note attributes actor"   "bash '$self' note T02 'x' --session who2 && bash '$self' show T02 | jq -e '.notes[-1].by == \"who2\"'"
  t "set attributes actor"    "bash '$self' set T03 --agent debugger --session who3 && bash '$self' events --tail 2 | grep -q who3"
  bash "$self" active t1 >/dev/null 2>&1
  t "--force overwrites"      "bash '$self' import --from file --source '$tmp/plan.md' --id t1 --force"

  rm -rf "$tmp"
  echo ""
  if [ "$fail" = "0" ]; then printf '%s✓ selftest: %s/%s passed%s\n' "$GRN" "$pass" "$((pass+fail))" "$NC"; return 0
  else printf '%s✗ selftest: %s failed, %s passed%s\n' "$RED" "$fail" "$pass" "$NC"; return 1; fi
}

# ═══════════════════════════════════════════════════════════════════════
CMD="${1:-help}"; shift || true

# --session / --plan are GLOBAL: every command must attribute to the right
# session and act on the right plan. Parsed here so no subcommand can silently
# ignore them (done/fail/note/set once did, mis-attributing the event log).
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --session) need_arg $# "$1"; SESSION="$2"; shift 2 ;;
    --plan)    need_arg $# "$1"; PLAN_ID="$2"; shift 2 ;;
    *)         ARGS+=("$1"); shift ;;
  esac
done
set -- ${ARGS[@]+"${ARGS[@]}"}

case "$CMD" in
  import)    cmd_import "$@" ;;
  list|ls)   cmd_list "$@" ;;
  next)      cmd_next "$@" ;;
  show)      cmd_show "$@" ;;
  set)       cmd_set "$@" ;;
  claim)     cmd_claim "$@" ;;
  done)      cmd_done "$@" ;;
  fail)      cmd_fail "$@" ;;
  block)     cmd_block "$@" ;;
  reopen)    cmd_reopen "$@" ;;
  note)      cmd_note "$@" ;;
  attach)    cmd_attach "$@" ;;
  detach)    cmd_detach "$@" ;;
  heartbeat) cmd_heartbeat "$@" ;;
  sessions)  cmd_sessions "$@" ;;
  post)      cmd_post "$@" ;;
  inbox)     cmd_inbox "$@" ;;
  board)     cmd_board "$@" ;;
  status)    cmd_status "$@" ;;
  plans)     cmd_plans "$@" ;;
  active)    cmd_active "$@" ;;
  events)    cmd_events "$@" ;;
  selftest)  cmd_selftest "$@" ;;
  help|-h|--help) cmd_help ;;
  *) die "unknown command '$CMD' (try: ccm-plan.sh help)" ;;
esac
