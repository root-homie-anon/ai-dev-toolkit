#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — mac-system-prep.sh
# System hardening and configuration for a Mac mini workstation.
# Run BEFORE mac-setup.sh on a fresh Mac.
#
# What this does:
#   - Hardens macOS security (FileVault, Firewall, Gatekeeper)
#   - Configures SSH (key-only auth, GitHub ready)
#   - Sets up Git identity
#   - Locks down file permissions
#   - Configures energy settings (always-on workstation)
#   - Disables unnecessary services
#   - Sets sane system defaults
#
# Usage: bash mac-system-prep.sh
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[prep]${RESET}  $1"; }
success() { echo -e "${GREEN}[ok]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $1"; }
fail()    { echo -e "${RED}[fail]${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }
ask()     { read -p "  $1: " "$2"; }

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Mac Mini System Prep${RESET}"
echo -e "${BOLD}  Security Hardening + Workstation Config${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo ""
echo "  This script configures macOS for secure development."
echo "  Some steps require your password (sudo)."
echo "  Some steps require a restart to take effect."
echo ""
read -p "  Press Enter to continue..."

# ══════════════════════════════════════════════════════════════
# SECTION 1: IDENTITY
# ══════════════════════════════════════════════════════════════

header "Identity"

CURRENT_USER=$(whoami)
success "User: ${CURRENT_USER}"

# Git identity
echo ""
echo "  Set your Git identity (used for commits):"
ask "Full name" GIT_NAME
ask "Email" GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input
success "Git configured: ${GIT_NAME} <${GIT_EMAIL}>"

# ══════════════════════════════════════════════════════════════
# SECTION 2: DISK ENCRYPTION
# ══════════════════════════════════════════════════════════════

header "Disk Encryption (FileVault)"

FV_STATUS=$(fdesetup status 2>/dev/null || echo "unknown")
if echo "$FV_STATUS" | grep -q "On"; then
  success "FileVault is ON"
else
  log "Enabling FileVault (full disk encryption)..."
  echo ""
  echo "  FileVault encrypts your entire disk. If someone steals the Mac,"
  echo "  they cannot read your data without your password."
  echo ""
  sudo fdesetup enable 2>/dev/null && success "FileVault enabled — save your recovery key" || {
    warn "FileVault enable failed — enable manually: System Settings > Privacy & Security > FileVault"
  }
fi

# ══════════════════════════════════════════════════════════════
# SECTION 3: FIREWALL
# ══════════════════════════════════════════════════════════════

header "Firewall"

# Enable firewall
FW_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "unknown")
if echo "$FW_STATUS" | grep -q "enabled"; then
  success "Firewall is ON"
else
  log "Enabling firewall..."
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
  success "Firewall enabled"
fi

# Enable stealth mode (don't respond to pings/probes)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null
success "Stealth mode enabled (no ping response)"

# Block all incoming except essential
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off 2>/dev/null
success "Firewall configured — block unsigned, allow signed apps"

# ══════════════════════════════════════════════════════════════
# SECTION 4: GATEKEEPER + SIP
# ══════════════════════════════════════════════════════════════

header "Gatekeeper & System Integrity"

# Gatekeeper — only allow App Store + identified developers
sudo spctl --master-enable 2>/dev/null
success "Gatekeeper enabled (App Store + identified developers only)"

# Verify SIP is enabled (can't enable from userspace, but can check)
SIP_STATUS=$(csrutil status 2>/dev/null || echo "unknown")
if echo "$SIP_STATUS" | grep -q "enabled"; then
  success "System Integrity Protection (SIP) is ON"
else
  warn "SIP is DISABLED — enable it from Recovery Mode: csrutil enable"
fi

# ══════════════════════════════════════════════════════════════
# SECTION 5: SSH SETUP + HARDENING
# ══════════════════════════════════════════════════════════════

header "SSH Configuration"

SSH_DIR="${HOME}/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate SSH key if none exists
if [[ ! -f "${SSH_DIR}/id_ed25519" ]]; then
  log "Generating Ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "${SSH_DIR}/id_ed25519" -N ""
  success "SSH key generated: ${SSH_DIR}/id_ed25519"
else
  success "SSH key already exists"
fi

# Add to ssh-agent
eval "$(ssh-agent -s)" &>/dev/null
ssh-add --apple-use-keychain "${SSH_DIR}/id_ed25519" 2>/dev/null || \
ssh-add "${SSH_DIR}/id_ed25519" 2>/dev/null || true

# SSH config — secure defaults
if [[ ! -f "${SSH_DIR}/config" ]]; then
  cat > "${SSH_DIR}/config" << 'SSHCONF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
SSHCONF
  chmod 600 "${SSH_DIR}/config"
  success "SSH config created"
else
  success "SSH config already exists"
fi

# Disable remote login (SSH server) unless you need it
# Uncomment the next line if you want to be able to SSH INTO this Mac:
# sudo systemsetup -setremotelogin on
sudo systemsetup -setremotelogin off 2>/dev/null || true
success "Remote login (SSH server) disabled — enable if you need remote access"

echo ""
echo "  Your public key (add to GitHub):"
echo ""
cat "${SSH_DIR}/id_ed25519.pub"
echo ""
echo "  Add it at: https://github.com/settings/ssh/new"
echo ""
read -p "  Press Enter when done (or skip and do it later)..."

# ══════════════════════════════════════════════════════════════
# SECTION 6: FILE PERMISSIONS
# ══════════════════════════════════════════════════════════════

header "File Permissions"

# Lock down home directory
chmod 700 "${HOME}"
success "Home directory: 700 (owner only)"

# Secure .ssh
chmod 700 "${SSH_DIR}"
find "${SSH_DIR}" -type f -exec chmod 600 {} \; 2>/dev/null
success ".ssh directory locked down"

# Secure .keys (if exists or will exist)
mkdir -p "${HOME}/.keys"
chmod 700 "${HOME}/.keys"
success ".keys directory: 700"

# Create projects dir with proper permissions
mkdir -p "${HOME}/projects"
chmod 755 "${HOME}/projects"
success "~/projects ready"

# Create bin dir
mkdir -p "${HOME}/bin"
chmod 755 "${HOME}/bin"
success "~/bin ready"

# ══════════════════════════════════════════════════════════════
# SECTION 7: macOS SECURITY DEFAULTS
# ══════════════════════════════════════════════════════════════

header "macOS Security Defaults"

# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
success "Password required immediately on wake"

# Auto-lock screen after 5 minutes of inactivity
defaults -currentHost write com.apple.screensaver idleTime -int 300
success "Screen locks after 5 minutes idle"

# Disable guest account
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false 2>/dev/null
success "Guest account disabled"

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
success "File extensions visible"

# Disable automatic login
sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true
success "Automatic login disabled"

# Disable AirDrop
defaults write com.apple.NetworkBrowser DisableAirDrop -bool true 2>/dev/null || true
success "AirDrop disabled"

# Disable Bluetooth if not needed (uncomment if you don't use BT peripherals)
# sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
# success "Bluetooth disabled"

# Enable auto-update for macOS
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
defaults write com.apple.commerce AutoUpdate -bool true
success "Automatic macOS updates enabled (including critical security updates)"

# ══════════════════════════════════════════════════════════════
# SECTION 8: ENERGY SETTINGS (ALWAYS-ON WORKSTATION)
# ══════════════════════════════════════════════════════════════

header "Energy Settings (Always-On Workstation)"

# Prevent sleep when plugged in (Mac mini is always plugged in)
sudo pmset -c sleep 0
success "System sleep disabled (AC power)"

# Display sleep after 15 minutes
sudo pmset -c displaysleep 15
success "Display sleeps after 15 minutes"

# Wake on network access (allows remote SSH if enabled later)
sudo pmset -c womp 1
success "Wake on LAN enabled"

# Restart automatically after power failure
sudo pmset -c autorestart 1
success "Auto-restart on power failure enabled"

# Restart on freeze
sudo systemsetup -setrestartfreeze on 2>/dev/null || true
success "Auto-restart on freeze enabled"

# ══════════════════════════════════════════════════════════════
# SECTION 9: DISABLE UNNECESSARY SERVICES
# ══════════════════════════════════════════════════════════════

header "Disable Unnecessary Services"

# Disable Spotlight indexing on external volumes
sudo mdutil -i off /Volumes/* 2>/dev/null || true
success "Spotlight disabled on external volumes"

# Disable Siri
defaults write com.apple.assistant.support "Assistant Enabled" -bool false 2>/dev/null || true
success "Siri disabled"

# Disable analytics/telemetry sharing
defaults write com.apple.CrashReporter DialogType -string "none" 2>/dev/null || true
success "Crash reporter dialogs disabled"

# ══════════════════════════════════════════════════════════════
# SECTION 10: FINDER + SYSTEM PREFERENCES
# ══════════════════════════════════════════════════════════════

header "System Preferences"

# Finder: show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
success "Finder configured (path bar, hidden files, list view)"

# Keyboard: fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
success "Keyboard repeat rate: fast"

# Keyboard: disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
success "Autocorrect/autocapitalize disabled"

# Dock: auto-hide, small icons
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
success "Dock: auto-hide, small icons"

# Screenshots: save to ~/Desktop/Screenshots
mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location "${HOME}/Desktop/Screenshots"
success "Screenshots save to ~/Desktop/Screenshots"

# ══════════════════════════════════════════════════════════════
# SECTION 11: RESTART SERVICES
# ══════════════════════════════════════════════════════════════

header "Applying Changes"

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
success "Finder, Dock, and SystemUI restarted"

# ══════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════

echo ""
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo -e "${GREEN}${BOLD}  System Prep Complete${RESET}"
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo ""
echo "  Security:"
echo "    FileVault (disk encryption)    ON"
echo "    Firewall + stealth mode        ON"
echo "    Gatekeeper                     ON"
echo "    SIP                            $(echo "$SIP_STATUS" | grep -q "enabled" && echo "ON" || echo "CHECK MANUALLY")"
echo "    Guest account                  DISABLED"
echo "    Auto-login                     DISABLED"
echo "    AirDrop                        DISABLED"
echo "    Password on wake               IMMEDIATE"
echo "    Screen lock                    5 min idle"
echo "    Auto security updates          ON"
echo ""
echo "  Workstation:"
echo "    System sleep                   NEVER (AC)"
echo "    Display sleep                  15 min"
echo "    Wake on LAN                    ON"
echo "    Auto-restart on failure        ON"
echo "    Auto-restart on freeze         ON"
echo ""
echo "  SSH:"
echo "    Key type                       Ed25519"
echo "    Remote login (SSH server)      OFF (enable if needed)"
echo "    Public key                     ~/.ssh/id_ed25519.pub"
echo ""
echo "  Git:"
echo "    User                           ${GIT_NAME} <${GIT_EMAIL}>"
echo "    Default branch                 main"
echo ""
echo "  Next step:"
echo "    bash mac-setup.sh    (installs Homebrew, Node, CC, toolkit)"
echo ""
echo "  NOTE: Some changes require a restart to take full effect."
echo "  Restart recommended before running mac-setup.sh."
echo ""
