#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — mac-setup.sh
# Run on a brand new Mac to go from zero to Claude Code ready.
# Installs everything: Xcode CLI, Homebrew, Node, Python, Git,
# Claude Code, then runs the toolkit setup.
#
# Usage: curl the script or copy it to the Mac and run:
#   bash mac-setup.sh
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[setup]${RESET} $1"; }
success() { echo -e "${GREEN}[ok]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $1"; }
fail()    { echo -e "${RED}[fail]${RESET}  $1"; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Strong Tower Media AI Studio${RESET}"
echo -e "${BOLD}  Mac Mini Setup — Zero to Claude Code${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo ""

# ── Xcode Command Line Tools ─────────────────────────────────
header "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  success "Xcode CLI tools already installed"
else
  log "Installing Xcode Command Line Tools (this may take a few minutes)..."
  xcode-select --install 2>/dev/null || true
  # Wait for installation to complete
  echo ""
  echo "  A dialog should have appeared to install Xcode CLI tools."
  echo "  Click 'Install' and wait for it to finish."
  echo ""
  read -p "  Press Enter when the install is complete..."

  if xcode-select -p &>/dev/null; then
    success "Xcode CLI tools installed"
  else
    fail "Xcode CLI tools installation failed — install manually and re-run"
  fi
fi

# ── Homebrew ──────────────────────────────────────────────────
header "Homebrew"

if command -v brew &>/dev/null; then
  success "Homebrew already installed"
else
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session (Apple Silicon vs Intel)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if command -v brew &>/dev/null; then
    success "Homebrew installed"
  else
    fail "Homebrew installation failed"
  fi
fi

# ── Core packages ─────────────────────────────────────────────
header "Core Packages"

PACKAGES=(git node python3 jq)

for pkg in "${PACKAGES[@]}"; do
  if command -v "$pkg" &>/dev/null; then
    success "${pkg} already installed"
  else
    log "Installing ${pkg}..."
    brew install "$pkg" --quiet
    success "${pkg} installed"
  fi
done

# ── npm (comes with node, but verify) ────────────────────────
if command -v npm &>/dev/null; then
  success "npm ready ($(npm --version))"
else
  warn "npm not found — should have come with node"
fi

# ── Python pip ────────────────────────────────────────────────
header "Python Dependencies"

if command -v pip3 &>/dev/null; then
  pip3 install --quiet Pillow anthropic 2>/dev/null || true
  success "Python deps installed (Pillow, anthropic)"
else
  warn "pip3 not found — install manually: pip3 install Pillow anthropic"
fi

# ── Claude Code ───────────────────────────────────────────────
header "Claude Code"

if command -v claude &>/dev/null; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  log "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code

  if command -v claude &>/dev/null; then
    success "Claude Code installed"
  else
    fail "Claude Code installation failed"
  fi
fi

# ── Claude Code Authentication ────────────────────────────────
header "Claude Code Authentication"

echo ""
echo "  You need to authenticate Claude Code before continuing."
echo "  This will open a browser for Anthropic login."
echo ""
read -p "  Press Enter to start authentication (or Ctrl+C to skip and do it later)..."

claude auth login 2>/dev/null || claude login 2>/dev/null || {
  warn "Auto-auth failed. Run 'claude' manually to authenticate."
}

# ── Directory Structure ───────────────────────────────────────
header "Directory Structure"

mkdir -p "${HOME}/projects"
mkdir -p "${HOME}/bin"
mkdir -p "${HOME}/.keys"
success "~/projects, ~/bin, ~/.keys created"

# ── Clone ai-dev-toolkit ─────────────────────────────────────
header "AI Dev Toolkit"

TOOLKIT_DIR="${HOME}/ai-dev-toolkit"

if [[ -d "${TOOLKIT_DIR}/.git" ]]; then
  log "Toolkit already cloned — pulling latest..."
  git -C "$TOOLKIT_DIR" pull --quiet origin main 2>/dev/null || true
  success "Toolkit updated"
else
  log "Cloning ai-dev-toolkit..."
  git clone https://github.com/root-homie-anon/ai-dev-toolkit.git "$TOOLKIT_DIR"
  success "Toolkit cloned to ~/ai-dev-toolkit"
fi

# ── Run Toolkit Setup ─────────────────────────────────────────
header "Running Toolkit Setup"

bash "${TOOLKIT_DIR}/initial-setup.sh"

# ── Shell Config (macOS uses zsh by default) ──────────────────
header "Shell Config (zsh)"

# macOS defaults to zsh — make sure our config is in .zshrc too
MARKER="# ai-dev-toolkit"
BASHRC_ADDITIONS="${TOOLKIT_DIR}/dotfiles/bashrc-additions.sh"

# .zshrc
if [[ -f "${HOME}/.zshrc" ]] || [[ ! -f "${HOME}/.bashrc" ]]; then
  if ! grep -qF "$MARKER" "${HOME}/.zshrc" 2>/dev/null; then
    {
      echo ""
      echo "$MARKER"
      cat "$BASHRC_ADDITIONS"
      echo "# /ai-dev-toolkit"
    } >> "${HOME}/.zshrc"
    success "Aliases added to ~/.zshrc"
  else
    log "~/.zshrc already configured — skipping"
  fi
fi

# Also ensure Homebrew is in zsh PATH
if ! grep -qF "homebrew" "${HOME}/.zshrc" 2>/dev/null; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zshrc"
    success "Homebrew PATH added to ~/.zshrc"
  fi
fi

# Ensure ~/bin is in PATH
if ! grep -qF 'HOME/bin' "${HOME}/.zshrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
  success "~/bin added to PATH in ~/.zshrc"
fi

# ── KeyMaster Vault Migration ────────────────────────────────
header "KeyMaster Vault Migration"

echo ""
echo "  If you have a vault to migrate from another machine:"
echo ""
echo "    bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine"
echo ""
echo "  Or from a USB/shared folder:"
echo ""
echo "    bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh file /path/to/vault.json"
echo ""
echo "  Then run: keymaster sync"
echo ""

# ── Verify ────────────────────────────────────────────────────
header "Verification"

echo ""
command -v git     &>/dev/null && success "git $(git --version | awk '{print $3}')" || warn "git missing"
command -v node    &>/dev/null && success "node $(node --version)" || warn "node missing"
command -v python3 &>/dev/null && success "python3 $(python3 --version 2>&1 | awk '{print $2}')" || warn "python3 missing"
command -v npm     &>/dev/null && success "npm $(npm --version)" || warn "npm missing"
command -v jq      &>/dev/null && success "jq found" || warn "jq missing"
command -v claude  &>/dev/null && success "claude found" || warn "claude missing"
command -v brew    &>/dev/null && success "brew found" || warn "brew missing"

echo ""
AGENT_COUNT=$(find "${HOME}/.claude/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "${HOME}/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
success "${AGENT_COUNT} agents installed"
success "${SKILL_COUNT} skills installed"
[[ -f "${HOME}/.claude/CLAUDE.md" ]] && success "Global CLAUDE.md ready" || warn "CLAUDE.md missing"
[[ -f "${HOME}/bin/keymaster" ]] && success "KeyMaster ready" || warn "KeyMaster not installed (migrate vault to complete)"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo -e "${GREEN}${BOLD}  Mac Mini Setup Complete${RESET}"
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo ""
echo "  Next steps:"
echo ""
echo "    1. Open a new terminal (or run: source ~/.zshrc)"
echo "    2. Migrate your vault:  bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine"
echo "    3. Sync project keys:   keymaster sync"
echo "    4. Start working:       cd ~/projects/my-app && ccnew"
echo ""
echo "  Verify install:  bash ~/ai-dev-toolkit/verify-install.sh"
echo ""
