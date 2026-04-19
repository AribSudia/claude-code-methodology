#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Services Health Check — Verify ALL Microservices Are Running
# ═══════════════════════════════════════════════════════════════
#
# PURPOSE:
#   Before any development, testing, or agent work, this script
#   verifies that ALL microservices are running and healthy.
#   Claude Code agents MUST NOT work against partial infrastructure.
#
# USAGE:
#   bash scripts/services-check.sh              # Check all services
#   bash scripts/services-check.sh --start      # Start all + check
#   bash scripts/services-check.sh --restart    # Restart all + check
#   bash scripts/services-check.sh --stop       # Stop all services
#   bash scripts/services-check.sh --status     # Quick status table
#   bash scripts/services-check.sh --wait       # Wait until all healthy (timeout 120s)
#
# INTEGRATION:
#   Called automatically by /session-start when architecture = microservices
#   Called by agents before running integration tests
#   Called by /deploy-check before deployment verification
#
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

# ── Colors ──
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Configuration ──
# Override these in .env or pass as environment variables
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-5}"        # seconds per health check
WAIT_TIMEOUT="${WAIT_TIMEOUT:-120}"          # seconds for --wait mode
WAIT_INTERVAL="${WAIT_INTERVAL:-3}"          # seconds between polls in --wait
PROJECT_ROOT="${PROJECT_ROOT:-.}"

# ── Detect compose command ──
if command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  echo -e "${RED}ERROR: Neither 'docker-compose' nor 'docker compose' found.${NC}"
  echo "Install Docker Compose: https://docs.docker.com/compose/install/"
  exit 1
fi

# ── State ──
TOTAL=0
HEALTHY=0
UNHEALTHY=0
STARTING=0
STOPPED=0
SERVICES_STATUS=()

# ═══════════════════════════════════════════════════════════════
# Functions
# ═══════════════════════════════════════════════════════════════

header() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║  Microservices Health Check                             ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

# Get all services defined in docker-compose
get_services() {
  $COMPOSE_CMD -f "$COMPOSE_FILE" config --services 2>/dev/null | sort
}

# Check if a container is running
container_running() {
  local service="$1"
  local state
  state=$($COMPOSE_CMD -f "$COMPOSE_FILE" ps --format json "$service" 2>/dev/null | head -1)
  if [ -z "$state" ]; then
    echo "stopped"
    return
  fi
  # Handle both old and new docker compose output formats
  if echo "$state" | grep -q '"running"' 2>/dev/null; then
    echo "running"
  elif echo "$state" | grep -q '"Up"' 2>/dev/null; then
    echo "running"
  elif echo "$state" | grep -q '"starting"' 2>/dev/null; then
    echo "starting"
  elif echo "$state" | grep -q '"restarting"' 2>/dev/null; then
    echo "restarting"
  else
    # Fallback: use docker compose ps with grep
    if $COMPOSE_CMD -f "$COMPOSE_FILE" ps "$service" 2>/dev/null | grep -q "Up"; then
      echo "running"
    else
      echo "stopped"
    fi
  fi
}

# Check health endpoint of a service
check_health() {
  local service="$1"
  local port="$2"

  if [ -z "$port" ]; then
    echo "no-port"
    return
  fi

  local health_url="http://localhost:${port}/health"
  local response
  response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$HEALTH_TIMEOUT" "$health_url" 2>/dev/null)

  if [ "$response" = "200" ]; then
    echo "healthy"
  elif [ "$response" = "503" ]; then
    echo "unhealthy"
  elif [ "$response" = "000" ]; then
    echo "unreachable"
  else
    echo "error-$response"
  fi
}

# Extract host port mapping for a service
get_service_port() {
  local service="$1"
  # Try to get the first mapped port
  $COMPOSE_CMD -f "$COMPOSE_FILE" port "$service" 3000 2>/dev/null | sed 's/.*://' || \
  $COMPOSE_CMD -f "$COMPOSE_FILE" port "$service" 8080 2>/dev/null | sed 's/.*://' || \
  $COMPOSE_CMD -f "$COMPOSE_FILE" port "$service" 80 2>/dev/null | sed 's/.*://' || \
  echo ""
}

# Get port from docker-compose.yml directly (fallback)
get_configured_port() {
  local service="$1"
  # Parse ports from compose file — get first host port
  $COMPOSE_CMD -f "$COMPOSE_FILE" config 2>/dev/null | \
    awk "/^  ${service}:/,/^  [a-z]/" | \
    grep -A1 "ports:" | \
    grep -oP '"\K[0-9]+(?=:)' | head -1 || echo ""
}

# Comprehensive check for one service
check_service() {
  local service="$1"
  local container_state
  local health_state="—"
  local port=""

  ((TOTAL++))

  container_state=$(container_running "$service")

  if [ "$container_state" = "running" ]; then
    # Try to get port and check health
    port=$(get_service_port "$service")
    if [ -z "$port" ]; then
      port=$(get_configured_port "$service")
    fi

    if [ -n "$port" ]; then
      health_state=$(check_health "$service" "$port")
    fi

    if [ "$health_state" = "healthy" ]; then
      ((HEALTHY++))
      SERVICES_STATUS+=("${GREEN}  ✅ ${service}${NC}  │  ${GREEN}running${NC}  │  :${port}  │  ${GREEN}healthy${NC}")
    elif [ "$health_state" = "no-port" ]; then
      # Infrastructure services (DB, Redis, RabbitMQ) without health endpoints
      ((HEALTHY++))
      SERVICES_STATUS+=("${GREEN}  ✅ ${service}${NC}  │  ${GREEN}running${NC}  │  —  │  ${DIM}no endpoint${NC}")
    else
      ((UNHEALTHY++))
      SERVICES_STATUS+=("${YELLOW}  ⚠️  ${service}${NC}  │  ${YELLOW}running${NC}  │  :${port}  │  ${RED}${health_state}${NC}")
    fi
  elif [ "$container_state" = "starting" ] || [ "$container_state" = "restarting" ]; then
    ((STARTING++))
    SERVICES_STATUS+=("${YELLOW}  🔄 ${service}${NC}  │  ${YELLOW}${container_state}${NC}  │  —  │  ${YELLOW}wait...${NC}")
  else
    ((STOPPED++))
    SERVICES_STATUS+=("${RED}  ❌ ${service}${NC}  │  ${RED}stopped${NC}  │  —  │  ${RED}down${NC}")
  fi
}

# Print status table
print_status() {
  echo -e "${BOLD}  Service               │  Container  │  Port   │  Health${NC}"
  echo -e "  ──────────────────────┼─────────────┼─────────┼──────────"
  for status in "${SERVICES_STATUS[@]}"; do
    echo -e "$status"
  done
  echo ""
}

# Print summary
print_summary() {
  echo -e "${BOLD}  Summary:${NC}"
  echo -e "  Total: ${TOTAL}  │  ${GREEN}Healthy: ${HEALTHY}${NC}  │  ${RED}Unhealthy: ${UNHEALTHY}${NC}  │  ${YELLOW}Starting: ${STARTING}${NC}  │  ${RED}Stopped: ${STOPPED}${NC}"
  echo ""

  if [ "$HEALTHY" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    echo -e "  ${GREEN}${BOLD}✅ ALL SERVICES HEALTHY — Safe to develop and test${NC}"
    echo ""
    return 0
  elif [ "$STOPPED" -gt 0 ]; then
    echo -e "  ${RED}${BOLD}❌ ${STOPPED} SERVICE(S) DOWN — Run: bash scripts/services-check.sh --start${NC}"
    echo ""
    echo -e "  ${YELLOW}⚠️  WARNING: Do NOT run integration tests or agent workflows"
    echo -e "     against partial infrastructure. Results will be unreliable.${NC}"
    echo ""
    return 1
  elif [ "$UNHEALTHY" -gt 0 ]; then
    echo -e "  ${YELLOW}${BOLD}⚠️  ${UNHEALTHY} SERVICE(S) UNHEALTHY — Check logs:${NC}"
    echo -e "     $COMPOSE_CMD -f $COMPOSE_FILE logs --tail=50 [service-name]"
    echo ""
    return 1
  elif [ "$STARTING" -gt 0 ]; then
    echo -e "  ${YELLOW}${BOLD}🔄 ${STARTING} SERVICE(S) STILL STARTING — Wait or run: bash scripts/services-check.sh --wait${NC}"
    echo ""
    return 1
  fi
}

# Start all services
start_services() {
  echo -e "${BLUE}Starting all services...${NC}"
  echo -e "${DIM}  $ $COMPOSE_CMD -f $COMPOSE_FILE up -d${NC}"
  echo ""
  $COMPOSE_CMD -f "$COMPOSE_FILE" up -d 2>&1
  echo ""
  echo -e "${BLUE}Waiting for services to initialize (10s)...${NC}"
  sleep 10
}

# Stop all services
stop_services() {
  echo -e "${BLUE}Stopping all services...${NC}"
  echo -e "${DIM}  $ $COMPOSE_CMD -f $COMPOSE_FILE down${NC}"
  echo ""
  $COMPOSE_CMD -f "$COMPOSE_FILE" down 2>&1
  echo ""
  echo -e "${GREEN}All services stopped.${NC}"
}

# Restart all services
restart_services() {
  echo -e "${BLUE}Restarting all services...${NC}"
  echo -e "${DIM}  $ $COMPOSE_CMD -f $COMPOSE_FILE down && $COMPOSE_CMD -f $COMPOSE_FILE up -d${NC}"
  echo ""
  $COMPOSE_CMD -f "$COMPOSE_FILE" down 2>&1
  $COMPOSE_CMD -f "$COMPOSE_FILE" up -d 2>&1
  echo ""
  echo -e "${BLUE}Waiting for services to initialize (10s)...${NC}"
  sleep 10
}

# Wait mode — poll until all healthy or timeout
wait_for_services() {
  local elapsed=0
  local all_healthy=false

  echo -e "${BLUE}Waiting for all services to become healthy (timeout: ${WAIT_TIMEOUT}s)...${NC}"
  echo ""

  while [ "$elapsed" -lt "$WAIT_TIMEOUT" ]; do
    # Reset counters
    TOTAL=0; HEALTHY=0; UNHEALTHY=0; STARTING=0; STOPPED=0
    SERVICES_STATUS=()

    local services
    services=$(get_services)
    if [ -z "$services" ]; then
      echo -e "${RED}No services found in ${COMPOSE_FILE}${NC}"
      return 1
    fi

    while IFS= read -r service; do
      check_service "$service"
    done <<< "$services"

    if [ "$HEALTHY" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
      all_healthy=true
      break
    fi

    echo -e "  ${DIM}[${elapsed}s] Healthy: ${HEALTHY}/${TOTAL} — waiting...${NC}"
    sleep "$WAIT_INTERVAL"
    elapsed=$((elapsed + WAIT_INTERVAL))
  done

  # Final status
  header
  print_status
  print_summary

  if [ "$all_healthy" = true ]; then
    return 0
  else
    echo -e "${RED}Timeout after ${WAIT_TIMEOUT}s — not all services healthy.${NC}"
    return 1
  fi
}

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

cd "$PROJECT_ROOT" || exit 1

# Check compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
  echo -e "${RED}ERROR: ${COMPOSE_FILE} not found in ${PROJECT_ROOT}${NC}"
  echo "This script requires a docker-compose.yml file."
  echo ""
  echo "If your compose file has a different name, set COMPOSE_FILE:"
  echo "  COMPOSE_FILE=docker-compose.dev.yml bash scripts/services-check.sh"
  exit 1
fi

# Parse command
case "${1:-}" in
  --start)
    header
    start_services
    # Fall through to check
    ;;
  --restart)
    header
    restart_services
    # Fall through to check
    ;;
  --stop)
    header
    stop_services
    exit 0
    ;;
  --wait)
    wait_for_services
    exit $?
    ;;
  --status|--check|"")
    header
    ;;
  --help|-h)
    echo "Usage: bash scripts/services-check.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  (none)      Check health of all services"
    echo "  --start     Start all services, then check health"
    echo "  --restart   Restart all services, then check health"
    echo "  --stop      Stop all services"
    echo "  --wait      Wait until all services are healthy (timeout: ${WAIT_TIMEOUT}s)"
    echo "  --status    Same as no option — quick status check"
    echo "  --help      Show this help"
    echo ""
    echo "Environment variables:"
    echo "  COMPOSE_FILE     Path to compose file (default: docker-compose.yml)"
    echo "  HEALTH_TIMEOUT   Seconds per health check (default: 5)"
    echo "  WAIT_TIMEOUT     Seconds for --wait mode (default: 120)"
    echo "  PROJECT_ROOT     Project root directory (default: .)"
    exit 0
    ;;
  *)
    echo -e "${RED}Unknown option: $1${NC}"
    echo "Run with --help for usage."
    exit 1
    ;;
esac

# ── Run checks ──
services=$(get_services)
if [ -z "$services" ]; then
  echo -e "${RED}No services found in ${COMPOSE_FILE}${NC}"
  echo "Make sure your docker-compose.yml defines services."
  exit 1
fi

while IFS= read -r service; do
  check_service "$service"
done <<< "$services"

print_status
print_summary
exit $?
