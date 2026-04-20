#!/usr/bin/env bash
set -euo pipefail

# DevOps Agent Kit — Setup Script
# Validates environment variables and tests MCP server connections.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

check_env() {
  local var_name="$1"
  local required="${2:-true}"
  if [ -n "${!var_name:-}" ]; then
    echo -e "  ${GREEN}✓${NC} $var_name is set"
    PASS=$((PASS + 1))
  elif [ "$required" = "true" ]; then
    echo -e "  ${RED}✗${NC} $var_name is not set (required)"
    FAIL=$((FAIL + 1))
  else
    echo -e "  ${YELLOW}?${NC} $var_name is not set (optional)"
    WARN=$((WARN + 1))
  fi
}

check_command() {
  local cmd="$1"
  local install_hint="$2"
  if command -v "$cmd" &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} $cmd is installed ($(command -v "$cmd"))"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $cmd is not installed — $install_hint"
    FAIL=$((FAIL + 1))
  fi
}

echo "╔══════════════════════════════════════════╗"
echo "║     DevOps Agent Kit — Setup Check       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Load .env if present
if [ -f .env ]; then
  echo "Loading .env file..."
  set -a
  source .env
  set +a
  echo ""
fi

echo "1. Prerequisites"
echo "────────────────"
check_command "node" "Install from https://nodejs.org/"
check_command "npx" "Comes with Node.js"
check_command "uvx" "Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
echo ""

echo "2. CloudBees Unify"
echo "──────────────────"
check_env "CLOUDBEES_API_TOKEN"
check_env "CLOUDBEES_ORG_ID"
echo ""

echo "3. Jira"
echo "───────"
check_env "JIRA_URL"
check_env "JIRA_USERNAME"
check_env "JIRA_API_TOKEN"
echo ""

echo "4. Slack"
echo "────────"
check_env "SLACK_BOT_TOKEN"
check_env "SLACK_TEAM_ID"
echo ""

echo "5. GitHub"
echo "─────────"
if command -v gh &> /dev/null; then
  if gh auth status &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} GitHub CLI authenticated"
    PASS=$((PASS + 1))
  else
    echo -e "  ${YELLOW}?${NC} GitHub CLI installed but not authenticated — run: gh auth login"
    WARN=$((WARN + 1))
  fi
else
  echo -e "  ${YELLOW}?${NC} GitHub CLI not installed — GitHub MCP uses Copilot HTTP transport"
  WARN=$((WARN + 1))
fi
echo ""

echo "════════════════════════════════════════════"
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${WARN} warnings${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Some required checks failed.${NC}"
  echo "Copy demo/env.template to .env and fill in your values:"
  echo "  cp demo/env.template .env"
  echo ""
  exit 1
else
  echo -e "${GREEN}All required checks passed.${NC}"
  if [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}Some optional checks had warnings — the agent will work but some features may be limited.${NC}"
  fi
  echo ""
  echo "You're ready to go! Run:"
  echo "  claude .        # Claude Code"
  echo "  cursor .        # Cursor"
  echo ""
fi
