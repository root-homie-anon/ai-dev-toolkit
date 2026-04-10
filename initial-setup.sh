#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — initial-setup.sh
# Run once on any new machine to install everything globally.
# Safe to re-run — all operations are idempotent.
# Usage: bash ~/ai-dev-toolkit/initial-setup.sh
# ============================================================

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_HOME}/skills"
AGENTS_DIR="${CLAUDE_HOME}/agents"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[setup]${RESET} $1"; }
success() { echo -e "${GREEN}[ok]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

echo ""
echo -e "${BOLD}======================================${RESET}"
echo -e "${BOLD}  ai-dev-toolkit  Initial Setup${RESET}"
echo -e "${BOLD}======================================${RESET}"
echo -e "  Toolkit: ${TOOLKIT_DIR}"
echo -e "  Target:  ${CLAUDE_HOME}"
echo ""

# ── System Dependencies ──────────────────────────────────────
header "System Dependencies"

install_pkg() {
  local cmd="$1" pkg="${2:-$1}"
  if ! command -v "$cmd" &>/dev/null; then
    log "Installing ${pkg}..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y -qq "$pkg" 2>/dev/null && success "${pkg} installed" || warn "Failed to install ${pkg} — install manually"
    elif command -v brew &>/dev/null; then
      brew install --quiet "$pkg" 2>/dev/null && success "${pkg} installed" || warn "Failed to install ${pkg} — install manually"
    else
      warn "${cmd} not found — install manually"
    fi
  else
    success "${cmd} found"
  fi
}

install_pkg git
install_pkg jq
install_pkg node nodejs
install_pkg python3 python3
install_pkg pip3 python3-pip

# ── Directory Structure ───────────────────────────────────────
header "Directory Structure"
mkdir -p "${CLAUDE_HOME}/skills"
mkdir -p "${CLAUDE_HOME}/scripts"
mkdir -p "${CLAUDE_HOME}/hooks"
mkdir -p "${CLAUDE_HOME}/agents"
mkdir -p "${CLAUDE_HOME}/rules"
mkdir -p "${CLAUDE_HOME}/logs"
mkdir -p "${HOME}/bin"
mkdir -p "${HOME}/.keys"
mkdir -p "${HOME}/projects"
success "Directory structure ready"

# ── Global Config ─────────────────────────────────────────────
header "Global Config"

if [[ ! -f "${CLAUDE_HOME}/CLAUDE.md" ]]; then
  cp "${TOOLKIT_DIR}/global/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md"
  success "CLAUDE.md installed"
else
  log "CLAUDE.md already exists — skipping (edit manually or run update.sh --force)"
fi

if [[ ! -f "${CLAUDE_HOME}/settings.json" ]]; then
  cp "${TOOLKIT_DIR}/global/settings.json" "${CLAUDE_HOME}/settings.json"
  success "settings.json installed"
else
  log "settings.json already exists — skipping"
fi

cp "${TOOLKIT_DIR}/global/skills-library.json" "${CLAUDE_HOME}/skills-library.json"
success "skills-library.json installed"

if [[ ! -f "${CLAUDE_HOME}/agents-registry.json" ]]; then
  echo '{"agents": []}' > "${CLAUDE_HOME}/agents-registry.json"
  success "agents-registry.json created"
else
  log "agents-registry.json already exists — skipping"
fi

# ── Production Agents (12) ────────────────────────────────────
header "Production Agents"

for agent_file in "${TOOLKIT_DIR}/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  name="$(basename "$agent_file")"
  if [[ ! -f "${AGENTS_DIR}/${name}" ]]; then
    cp "$agent_file" "${AGENTS_DIR}/${name}"
    success "Agent installed: ${name%.md}"
  else
    log "Agent already exists: ${name%.md} — skipping (use update.sh --force to overwrite)"
  fi
done

# ── Skills (18) ───────────────────────────────────────────────
header "Skills"

for skill_dir in "${TOOLKIT_DIR}/skills/"*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  dest="${SKILLS_DIR}/${name}"
  if [[ ! -d "$dest" ]]; then
    cp -r "$skill_dir" "$dest"
    success "Skill installed: ${name}"
  else
    log "Skill already exists: ${name} — skipping"
  fi
done

# ── Rules (canonical domain conventions) ──────────────────────
header "Rules"

if [[ -d "${TOOLKIT_DIR}/rules" ]]; then
  for rule_file in "${TOOLKIT_DIR}/rules/"*.md; do
    [[ -f "$rule_file" ]] || continue
    name="$(basename "$rule_file")"
    cp "$rule_file" "${CLAUDE_HOME}/rules/${name}"
    success "Rule installed: ${name%.md}"
  done
else
  log "No rules directory in toolkit — skipping"
fi

# ── Hooks & Scripts ───────────────────────────────────────────
header "Hooks & Scripts"

cp "${TOOLKIT_DIR}/agent-factory/hooks/session-start.sh" \
   "${CLAUDE_HOME}/hooks/session-start.sh"
chmod +x "${CLAUDE_HOME}/hooks/session-start.sh"
success "hooks/session-start.sh installed"

cp "${TOOLKIT_DIR}/hooks/orchestrator.sh" \
   "${CLAUDE_HOME}/hooks/orchestrator.sh"
chmod +x "${CLAUDE_HOME}/hooks/orchestrator.sh"
success "hooks/orchestrator.sh installed"

# Team Operating Model enforcement hooks (tool-call hooks)
for hook in pre-task-log post-edit-flag post-edit-commit-reminder; do
  if [[ -f "${TOOLKIT_DIR}/hooks/${hook}.sh" ]]; then
    cp "${TOOLKIT_DIR}/hooks/${hook}.sh" "${CLAUDE_HOME}/hooks/${hook}.sh"
    chmod +x "${CLAUDE_HOME}/hooks/${hook}.sh"
    success "hooks/${hook}.sh installed"
  fi
done

cp "${TOOLKIT_DIR}/agent-factory/scripts/agent-factory.sh" \
   "${CLAUDE_HOME}/scripts/agent-factory.sh"
chmod +x "${CLAUDE_HOME}/scripts/agent-factory.sh"
success "scripts/agent-factory.sh installed"

# ── KeyMaster ─────────────────────────────────────────────────
header "KeyMaster"

cp "${TOOLKIT_DIR}/keymaster/keymaster" "${HOME}/bin/keymaster"
chmod +x "${HOME}/bin/keymaster"
success "keymaster installed to ~/bin/"

if [[ ! -f "${HOME}/.keys/vault.json" ]]; then
  echo '{}' > "${HOME}/.keys/vault.json"
  chmod 600 "${HOME}/.keys/vault.json"
  success "~/.keys/vault.json initialized (empty)"
else
  log "~/.keys/vault.json already exists — skipping"
fi

if [[ ! -f "${HOME}/.keys/config.json" ]]; then
  cat > "${HOME}/.keys/config.json" << 'KEYCONF'
{
  "vault_path": "~/.keys/vault.json",
  "projects_dir": "~/projects",
  "auto_sync": true,
  "mask_by_default": true
}
KEYCONF
  chmod 600 "${HOME}/.keys/config.json"
  success "~/.keys/config.json initialized"
else
  log "~/.keys/config.json already exists — skipping"
fi

# ── Bash Aliases & PATH ──────────────────────────────────────
header "Shell Config"

MARKER="# ai-dev-toolkit"
if ! grep -qF "$MARKER" "${HOME}/.bashrc" 2>/dev/null; then
  {
    echo ""
    echo "$MARKER"
    cat "${TOOLKIT_DIR}/dotfiles/bashrc-additions.sh"
    echo "# /ai-dev-toolkit"
  } >> "${HOME}/.bashrc"
  success "Bash aliases and PATH added to ~/.bashrc"
else
  log "Bash config already present — skipping"
fi

# ── Python Dependencies ──────────────────────────────────────
header "Python Dependencies"

if command -v pip3 &>/dev/null; then
  pip3 install --quiet --break-system-packages \
    Pillow anthropic 2>/dev/null || \
  pip3 install --quiet \
    Pillow anthropic 2>/dev/null || true
  success "Python deps installed (Pillow, anthropic)"
else
  warn "pip3 not found — install manually: pip3 install Pillow anthropic"
fi

# ── Final Verification ────────────────────────────────────────
header "Verification"

command -v claude  &>/dev/null && success "Claude Code ready" || warn "Claude Code not found — install before using the toolkit"
command -v git     &>/dev/null && success "git ready"
command -v node    &>/dev/null && success "node ready ($(node --version))"
command -v python3 &>/dev/null && success "python3 ready"
command -v keymaster &>/dev/null && success "keymaster ready" || warn "keymaster not in PATH — run: source ~/.bashrc"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}======================================${RESET}"
echo -e "${GREEN}${BOLD}  Setup Complete${RESET}"
echo -e "${GREEN}${BOLD}======================================${RESET}"
echo ""
echo "  Installed:"
echo "    15 production agents (incl. Priya, Iris, Nico)"
echo "    18 skills"
echo "    Rules (~/.claude/rules/ — canonical domain conventions)"
echo "    KeyMaster (~/bin/keymaster)"
echo "    Global CLAUDE.md + settings.json (with Team Operating Model hooks)"
echo "    Hooks (orchestrator + tool-call enforcement) + agent factory"
echo "    Bash aliases (cc, ccnew)"
echo "    Vincent (Project Lead) template in project-agents/"
echo ""
echo "  Next steps:"
echo "    1. Source your shell:  source ~/.bashrc"
echo "    2. Migrate your keys: bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine"
echo "       Or add fresh keys: keymaster add STRIPE_SECRET_KEY (etc.)"
echo "    3. Start a project:   cd ~/projects/my-app && ccnew"
echo "    4. Scaffold Vincent:  cp ~/ai-dev-toolkit/project-agents/orchestrator.md .claude/agents/"
echo ""
echo "  To verify:  bash ${TOOLKIT_DIR}/verify-install.sh"
echo "  To update:  bash ${TOOLKIT_DIR}/update.sh"
echo ""
