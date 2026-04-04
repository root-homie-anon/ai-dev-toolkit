#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — mac-setup.sh
# Run on a brand new Mac to go from zero to Claude Code ready.
# Installs everything: Xcode CLI, Homebrew, Node, Python, Git,
# project dependencies, Claude Code, then runs the toolkit setup.
#
# Run mac-system-prep.sh FIRST for security hardening.
#
# Usage: bash mac-setup.sh
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

brew_install() {
  local cmd="$1" pkg="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    success "${pkg} already installed"
  else
    log "Installing ${pkg}..."
    brew install "$pkg" --quiet 2>/dev/null && success "${pkg} installed" || warn "Failed to install ${pkg}"
  fi
}

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Strong Tower Media AI Studio${RESET}"
echo -e "${BOLD}  Mac Mini Setup — Zero to Claude Code${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo ""

# ══════════════════════════════════════════════════════════════
# PHASE 1: FOUNDATION
# ══════════════════════════════════════════════════════════════

# ── Xcode Command Line Tools ─────────────────────────────────
header "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  success "Xcode CLI tools already installed"
else
  log "Installing Xcode Command Line Tools (this may take a few minutes)..."
  xcode-select --install 2>/dev/null || true
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

  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  command -v brew &>/dev/null && success "Homebrew installed" || fail "Homebrew installation failed"
fi

# ══════════════════════════════════════════════════════════════
# PHASE 2: CORE RUNTIMES
# ══════════════════════════════════════════════════════════════

header "Core Runtimes"

brew_install git
brew_install node node@20
brew_install python3 python@3.11
brew_install jq
brew_install npm   # comes with node but verify

# Ensure node@20 is linked if brew installed a versioned formula
brew link --overwrite node@20 2>/dev/null || true

# ══════════════════════════════════════════════════════════════
# PHASE 3: PROJECT DEPENDENCIES (System-Level)
# ══════════════════════════════════════════════════════════════

header "Database Services"

brew_install psql postgresql@16
brew_install redis

# Start services (launchd — survive reboots)
brew services start postgresql@16 2>/dev/null && success "PostgreSQL service started" || warn "PostgreSQL service start failed"
brew services start redis 2>/dev/null && success "Redis service started" || warn "Redis service start failed"

header "Media & Image Processing"

brew_install ffmpeg
brew_install vips   # libvips for Sharp (image processing)

header "Search"

brew_install meilisearch
# Don't auto-start meilisearch — only BibleApp needs it
log "Meilisearch installed (start manually when needed: meilisearch)"

header "Browser Automation"

# Chromium for Puppeteer/Playwright
if [[ -d "/Applications/Chromium.app" ]] || command -v chromium &>/dev/null; then
  success "Chromium already installed"
else
  brew install --cask chromium --quiet 2>/dev/null && success "Chromium installed" || \
  warn "Chromium install failed — Puppeteer will download its own"
fi

header "Trading Dependencies"

# TA-Lib C library (required before pip install ta-lib)
if brew list ta-lib &>/dev/null 2>&1; then
  success "ta-lib already installed"
else
  brew install ta-lib --quiet 2>/dev/null && success "ta-lib installed" || warn "ta-lib install failed"
fi

header "Docker"

if command -v docker &>/dev/null; then
  success "Docker already installed"
else
  log "Installing Docker Desktop..."
  brew install --cask docker --quiet 2>/dev/null && success "Docker Desktop installed" || \
  warn "Docker install failed — install manually from docker.com"
  echo ""
  echo "  Open Docker Desktop from Applications to complete setup."
  echo "  It needs to run once to initialize."
  echo ""
fi

# ══════════════════════════════════════════════════════════════
# PHASE 4: PYTHON DEPENDENCIES
# ══════════════════════════════════════════════════════════════

header "Python Dependencies (Global)"

if command -v pip3 &>/dev/null; then
  pip3 install --quiet --break-system-packages \
    Pillow anthropic flask praw elevenlabs \
    google-api-python-client google-auth google-auth-oauthlib \
    edge-tts aiohttp requests python-dotenv \
    2>/dev/null || \
  pip3 install --quiet \
    Pillow anthropic flask praw elevenlabs \
    google-api-python-client google-auth google-auth-oauthlib \
    edge-tts aiohttp requests python-dotenv \
    2>/dev/null || true
  success "Core Python deps installed"

  # Trading deps (separate — ta-lib can fail if C lib missing)
  pip3 install --quiet --break-system-packages \
    pandas numpy scipy ta-lib pandas-ta sqlalchemy \
    matplotlib plotly apscheduler oandapyV20 \
    2>/dev/null || \
  pip3 install --quiet \
    pandas numpy scipy ta-lib pandas-ta sqlalchemy \
    matplotlib plotly apscheduler oandapyV20 \
    2>/dev/null || warn "Some trading deps failed — check ta-lib C library"
  success "Trading Python deps installed"
else
  warn "pip3 not found"
fi

# ══════════════════════════════════════════════════════════════
# PHASE 5: CLAUDE CODE
# ══════════════════════════════════════════════════════════════

header "Claude Code"

if command -v claude &>/dev/null; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  log "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
  command -v claude &>/dev/null && success "Claude Code installed" || fail "Claude Code installation failed"
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

# ══════════════════════════════════════════════════════════════
# PHASE 6: AI DEV TOOLKIT
# ══════════════════════════════════════════════════════════════

header "AI Dev Toolkit"

mkdir -p "${HOME}/projects" "${HOME}/bin" "${HOME}/.keys"

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

header "Running Toolkit Setup"

bash "${TOOLKIT_DIR}/initial-setup.sh"

# ══════════════════════════════════════════════════════════════
# PHASE 7: SHELL CONFIG (macOS zsh)
# ══════════════════════════════════════════════════════════════

header "Shell Config (zsh)"

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

if ! grep -qF "homebrew" "${HOME}/.zshrc" 2>/dev/null; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zshrc"
    success "Homebrew PATH added to ~/.zshrc"
  fi
fi

if ! grep -qF 'HOME/bin' "${HOME}/.zshrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
  success "~/bin added to PATH in ~/.zshrc"
fi

# ══════════════════════════════════════════════════════════════
# PHASE 8: VERIFICATION
# ══════════════════════════════════════════════════════════════

header "Verification"

echo ""
echo -e "${BOLD}Runtimes:${RESET}"
command -v git      &>/dev/null && success "git $(git --version | awk '{print $3}')" || warn "git missing"
command -v node     &>/dev/null && success "node $(node --version)" || warn "node missing"
command -v python3  &>/dev/null && success "python3 $(python3 --version 2>&1 | awk '{print $2}')" || warn "python3 missing"
command -v npm      &>/dev/null && success "npm $(npm --version)" || warn "npm missing"
command -v jq       &>/dev/null && success "jq found" || warn "jq missing"
command -v claude   &>/dev/null && success "claude found" || warn "claude missing"

echo ""
echo -e "${BOLD}Services:${RESET}"
command -v psql     &>/dev/null && success "postgresql found" || warn "postgresql missing"
command -v redis-cli &>/dev/null && success "redis found" || warn "redis missing"
command -v ffmpeg   &>/dev/null && success "ffmpeg found" || warn "ffmpeg missing"
command -v meilisearch &>/dev/null && success "meilisearch found" || warn "meilisearch missing"
command -v docker   &>/dev/null && success "docker found" || warn "docker missing"
command -v vips     &>/dev/null && success "libvips found" || warn "libvips missing — Sharp may fail"

echo ""
echo -e "${BOLD}Toolkit:${RESET}"
AGENT_COUNT=$(find "${HOME}/.claude/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "${HOME}/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
success "${AGENT_COUNT} agents installed"
success "${SKILL_COUNT} skills installed"
[[ -f "${HOME}/.claude/CLAUDE.md" ]] && success "Global CLAUDE.md ready" || warn "CLAUDE.md missing"
[[ -f "${HOME}/bin/keymaster" ]] && success "KeyMaster ready" || warn "KeyMaster not installed"

# ══════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════

echo ""
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo -e "${GREEN}${BOLD}  Mac Mini Setup Complete${RESET}"
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo ""
echo "  Next steps:"
echo ""
echo "    1. Open a new terminal (or: source ~/.zshrc)"
echo ""
echo "    2. Migrate your vault:"
echo "       bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine"
echo "       keymaster sync"
echo ""
echo "    3. Configure MCP servers in Claude Code:"
echo "       Open CC and connect these MCPs for your projects:"
echo ""
echo "       Required:"
echo "         - GitHub          (all projects — PRs, issues)"
echo "         - Supabase        (JobApp, Nudge_AI, YT_Channel_Auto, frequency-soundscape)"
echo ""
echo "       Recommended:"
echo "         - Notion          (printpilot — template creation)"
echo "         - Telegram        (printpilot, YT_Channel_Auto, RedForge — notifications)"
echo "         - Stripe          (ADForge, Nudge_AI, JobApp — payments + revenue data)"
echo "         - Gmail           (notifications, alerts)"
echo "         - Google Calendar (scheduling)"
echo ""
echo "       To connect: open CC, type /mcp, or configure in ~/.claude/settings.json"
echo ""
echo "    4. Start working:"
echo "       cd ~/projects/my-app && ccnew"
echo ""
echo "  Verify install:  bash ~/ai-dev-toolkit/verify-install.sh"
echo ""
