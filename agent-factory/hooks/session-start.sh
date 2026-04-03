#!/usr/bin/env bash
# ============================================================
# Claude Code Agent Factory — session-start.sh
# Global location: ~/.claude/hooks/session-start.sh
# ============================================================
# Fires at the start of every CC session via the hook in
# your project's CLAUDE.md. Shows existing agents for this
# project and offers to create new ones.
# Usage: session-start.sh <project_name> <project_path>
# ============================================================

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────
CLAUDE_HOME="${HOME}/.claude"
AGENT_FACTORY="${CLAUDE_HOME}/scripts/agent-factory.sh"
SYNC_ENV="${CLAUDE_HOME}/scripts/sync-env.sh"
PROJECT_NAME="${1:-$(basename "$(pwd)")}"
PROJECT_PATH="${2:-$(pwd)}"
PROJECT_AGENTS_DIR="${PROJECT_PATH}/.claude/agents"

# ── Colors ───────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()  { echo -e "${CYAN}[session-start]${RESET} $1"; }

# ── Show existing agents for this project ─────────────────────
show_project_agents() {
  if [[ ! -d "$PROJECT_AGENTS_DIR" ]] || \
     [[ -z "$(ls -A "$PROJECT_AGENTS_DIR" 2>/dev/null)" ]]; then
    echo "  (none yet)"
    return
  fi

  for agent_file in "${PROJECT_AGENTS_DIR}"/*.md; do
    [[ -f "$agent_file" ]] || continue
    local name role
    name=$(basename "$agent_file" .md)
    role=$(grep -m1 '^role:' "$agent_file" 2>/dev/null | sed 's/role: //' || echo "unknown")
    echo -e "  ${GREEN}@${name}${RESET}  [${role}]"
  done
}

# ── Count agents for this project ────────────────────────────
count_project_agents() {
  if [[ ! -d "$PROJECT_AGENTS_DIR" ]]; then
    echo "0"
    return
  fi
  find "$PROJECT_AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' '
}

# ── Sync master env keys into this project ───────────────────
sync_env() {
  if [[ -f "$SYNC_ENV" ]] && [[ -f "${HOME}/.env.master" ]]; then
    log "Syncing ~/.env.master into project .env ..."
    bash "$SYNC_ENV" "$PROJECT_PATH"
  else
    [[ ! -f "${HOME}/.env.master" ]] && log "No ~/.env.master found — skipping env sync."
    [[ ! -f "$SYNC_ENV" ]]          && log "No sync-env.sh found at ${SYNC_ENV} — skipping env sync."
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}  Claude Code — Agent Factory  ${RESET}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  Project: ${BOLD}${PROJECT_NAME}${RESET}"
  echo ""

  # Sync master env keys before doing anything else
  sync_env
  echo ""

  local count
  count=$(count_project_agents)

  if [[ "$count" -gt 0 ]]; then
    echo -e "${BOLD}  Active agents for this project (${count}):${RESET}"
    show_project_agents
    echo ""
  else
    log "No agents configured for this project yet."
    echo ""
  fi

  # Ask if new agent needed
  read -rp "  Create a new agent for this session? (y/N): " answer
  echo ""

  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    if [[ ! -f "$AGENT_FACTORY" ]]; then
      echo "ERROR: agent-factory.sh not found at ${AGENT_FACTORY}"
      echo "Run setup first: bash ~/ai-dev-toolkit/setup.sh"
      exit 1
    fi
    bash "$AGENT_FACTORY" "$PROJECT_NAME" "$PROJECT_PATH"

    # Offer to create another
    while true; do
      read -rp "  Create another agent? (y/N): " more
      [[ "$more" != "y" && "$more" != "Y" ]] && break
      bash "$AGENT_FACTORY" "$PROJECT_NAME" "$PROJECT_PATH"
    done
  else
    if [[ "$count" -gt 0 ]]; then
      log "Using existing agents. Invoke with @agent-name in your prompts."
    else
      log "Skipping. Run bash ~/.claude/scripts/agent-factory.sh anytime to create one."
    fi
  fi

  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

main
