#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — setup.sh
# Run once on any new machine to install everything globally.
# Usage: bash ~/ai-dev-toolkit/setup.sh
# ============================================================

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[setup]${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET}  $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}   $1"; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║        ai-dev-toolkit  Setup             ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo -e "  Installing to: ${CLAUDE_HOME}"
echo ""

# ── Create ~/.claude structure ────────────────────────────────
header "Directory Structure"
mkdir -p "${CLAUDE_HOME}/skills"
mkdir -p "${CLAUDE_HOME}/scripts"
mkdir -p "${CLAUDE_HOME}/hooks"
mkdir -p "${CLAUDE_HOME}/agents"
mkdir -p "${CLAUDE_HOME}/commands"
success "~/.claude directory structure ready"

# ── Agent Factory ─────────────────────────────────────────────
header "Agent Factory"

cp "${TOOLKIT_DIR}/agent-factory/skills-library.json" \
   "${CLAUDE_HOME}/skills-library.json"
success "skills-library.json installed"

cp "${TOOLKIT_DIR}/agent-factory/scripts/agent-factory.sh" \
   "${CLAUDE_HOME}/scripts/agent-factory.sh"
chmod +x "${CLAUDE_HOME}/scripts/agent-factory.sh"
success "agent-factory.sh installed"

cp "${TOOLKIT_DIR}/agent-factory/hooks/session-start.sh" \
   "${CLAUDE_HOME}/hooks/session-start.sh"
chmod +x "${CLAUDE_HOME}/hooks/session-start.sh"
success "session-start.sh installed"

if [[ ! -f "${CLAUDE_HOME}/agents-registry.json" ]]; then
  echo '{"agents": []}' > "${CLAUDE_HOME}/agents-registry.json"
  success "agents-registry.json created"
else
  log "agents-registry.json already exists — skipping"
fi

# ── Slash Commands ────────────────────────────────────────────
header "Slash Commands"

if [[ -d "${TOOLKIT_DIR}/commands" ]]; then
  for cmd in "${TOOLKIT_DIR}/commands"/*.md; do
    [[ -f "$cmd" ]] || continue
    cp "$cmd" "${CLAUDE_HOME}/commands/"
    success "Installed command: $(basename "$cmd" .md)"
  done
else
  warn "No commands directory found — skipping"
fi

# ── Standards (reference copy) ───────────────────────────────
header "Standards"

mkdir -p "${HOME}/ai-dev-toolkit-resources"
if [[ -d "${TOOLKIT_DIR}/standards" ]]; then
  cp -r "${TOOLKIT_DIR}/standards" "${HOME}/ai-dev-toolkit-resources/"
  success "Standards copied to ~/ai-dev-toolkit-resources/standards/"
fi

if [[ -d "${TOOLKIT_DIR}/prompts" ]]; then
  cp -r "${TOOLKIT_DIR}/prompts" "${HOME}/ai-dev-toolkit-resources/"
  success "Prompts copied to ~/ai-dev-toolkit-resources/prompts/"
fi

# ── Dependency check ──────────────────────────────────────────
header "Dependency Check"

if command -v jq &>/dev/null; then
  success "jq found — full skill matching enabled"
else
  warn "jq not found — install for full skill matching:"
  echo "       Ubuntu/Debian: sudo apt install jq"
fi

if command -v git &>/dev/null; then
  success "git found"
else
  warn "git not found — required for skill installation fallback"
fi

# ── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║          Setup Complete! 🚀              ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Start a new project:"
echo "     cp ~/ai-dev-toolkit/claude-md-templates/saas-mobile.md YOUR_PROJECT/CLAUDE.md"
echo ""
echo "  2. Open CC in that project — agent factory fires automatically"
echo ""
echo "  3. Answer y to create your first agent"
echo ""
echo "  Manual agent creation anytime:"
echo "     bash ~/.claude/scripts/agent-factory.sh <project-name> <path>"
echo ""
