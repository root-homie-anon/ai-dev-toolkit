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
RULES_DIR="${CLAUDE_HOME}/rules"

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
echo -e "${BOLD}║      ai-dev-toolkit  Initial Setup       ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo -e "  Toolkit: ${TOOLKIT_DIR}"
echo -e "  Installing to: ${CLAUDE_HOME}"
echo ""

# ── Directory Structure ───────────────────────────────────────
header "Directory Structure"
mkdir -p "${CLAUDE_HOME}/skills"
mkdir -p "${CLAUDE_HOME}/scripts"
mkdir -p "${CLAUDE_HOME}/hooks"
mkdir -p "${CLAUDE_HOME}/agents"
mkdir -p "${CLAUDE_HOME}/commands"
mkdir -p "${CLAUDE_HOME}/rules"
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

cp "${TOOLKIT_DIR}/hooks/orchestrator.sh" \
   "${CLAUDE_HOME}/hooks/orchestrator.sh"
chmod +x "${CLAUDE_HOME}/hooks/orchestrator.sh"
success "hooks/orchestrator.sh installed"

if [[ ! -f "${CLAUDE_HOME}/agents-registry.json" ]]; then
  echo '{"agents": []}' > "${CLAUDE_HOME}/agents-registry.json"
  success "agents-registry.json created"
else
  log "agents-registry.json already exists — skipping"
fi

# ── Pre-built Agents (from ECC) ───────────────────────────────
header "Pre-built Agents"

for agent_file in "${TOOLKIT_DIR}/agent-factory/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  dest="${AGENTS_DIR}/$(basename "$agent_file")"
  if [[ ! -f "$dest" ]]; then
    cp "$agent_file" "$dest"
    success "Agent installed: $(basename "$agent_file" .md)"
  else
    log "Agent already exists: $(basename "$agent_file" .md) — skipping"
  fi
done

# ── ECC Rules ─────────────────────────────────────────────────
header "ECC Rules (common + typescript + python + golang)"

TMP_ECC=$(mktemp -d)
if git clone --depth=1 --quiet \
   https://github.com/affaan-m/everything-claude-code.git "${TMP_ECC}/ecc" 2>/dev/null; then

  for lang in common typescript python golang; do
    src="${TMP_ECC}/ecc/rules/${lang}"
    if [[ -d "$src" ]]; then
      mkdir -p "${RULES_DIR}/${lang}"
      cp -rn "${src}/." "${RULES_DIR}/${lang}/" 2>/dev/null || true
      success "ECC rules installed: ${lang}"
    fi
  done
else
  warn "Could not clone ECC — rules not installed. Run update.sh to retry."
fi
rm -rf "$TMP_ECC"

# ── ECC Skills (core set) ─────────────────────────────────────
header "ECC Skills"

TMP_ECC2=$(mktemp -d)
if git clone --depth=1 --quiet \
   https://github.com/affaan-m/everything-claude-code.git "${TMP_ECC2}/ecc" 2>/dev/null; then

  ECC_CORE_SKILLS=(
    "continuous-learning"
    "continuous-learning-v2"
    "iterative-retrieval"
    "strategic-compact"
    "tdd-workflow"
    "security-review"
    "eval-harness"
    "verification-loop"
    "search-first"
    "backend-patterns"
    "frontend-patterns"
    "api-design"
    "deployment-patterns"
    "docker-patterns"
    "e2e-testing"
    "database-migrations"
  )

  for skill in "${ECC_CORE_SKILLS[@]}"; do
    src="${TMP_ECC2}/ecc/skills/${skill}"
    dest="${SKILLS_DIR}/${skill}"
    if [[ -d "$src" ]] && [[ ! -d "$dest" ]]; then
      cp -r "$src" "$dest"
      success "ECC skill installed: ${skill}"
    elif [[ -d "$dest" ]]; then
      log "ECC skill already exists: ${skill} — skipping"
    fi
  done
else
  warn "Could not clone ECC — skills not installed. Run update.sh to retry."
fi
rm -rf "$TMP_ECC2"

# ── ui-ux-pro-max ─────────────────────────────────────────────
header "ui-ux-pro-max"

if command -v npm &>/dev/null; then
  if ! command -v uipro &>/dev/null; then
    npm install -g uipro-cli --silent
    success "uipro-cli installed"
  else
    log "uipro-cli already installed — skipping"
  fi
  uipro init --ai claude --global 2>/dev/null || true
  success "ui-ux-pro-max skill installed globally"
else
  warn "npm not found — ui-ux-pro-max not installed"
fi

# ── web-asset-generator ───────────────────────────────────────
header "web-asset-generator"

WAG_DIR="${SKILLS_DIR}/web-asset-generator"
if [[ ! -d "$WAG_DIR" ]]; then
  git clone --depth=1 --quiet \
    https://github.com/alonw0/web-asset-generator.git "${TMP:-/tmp}/wag" 2>/dev/null
  cp -r "${TMP:-/tmp}/wag/skills/web-asset-generator" "$WAG_DIR"
  rm -rf "${TMP:-/tmp}/wag"
  success "web-asset-generator installed"
else
  log "web-asset-generator already installed — skipping"
fi

# ── codebase-to-course ────────────────────────────────────────
header "codebase-to-course"

C2C_DIR="${SKILLS_DIR}/codebase-to-course"
if [[ ! -d "$C2C_DIR" ]]; then
  git clone --depth=1 --quiet \
    https://github.com/zarazhangrui/codebase-to-course.git "${TMP:-/tmp}/c2c" 2>/dev/null
  mkdir -p "$C2C_DIR"
  cp "${TMP:-/tmp}/c2c/SKILL.md" "$C2C_DIR/"
  cp -r "${TMP:-/tmp}/c2c/references" "$C2C_DIR/"
  rm -rf "${TMP:-/tmp}/c2c"
  success "codebase-to-course installed"
else
  log "codebase-to-course already installed — skipping"
fi

# ── get-shit-done ─────────────────────────────────────────────
header "get-shit-done (GSD)"

if command -v npx &>/dev/null; then
  npx get-shit-done-cc@latest --claude --global --yes 2>/dev/null || \
  npx get-shit-done-cc@latest --claude --global 2>/dev/null || true
  success "GSD installed globally"
else
  warn "npx not found — GSD not installed"
fi

# ── Python Dependencies ───────────────────────────────────────
header "Python Dependencies"

if command -v pip3 &>/dev/null; then
  pip3 install --quiet --break-system-packages Pillow pilmoji 'emoji<2.0.0' 2>/dev/null || \
  pip3 install --quiet Pillow pilmoji 'emoji<2.0.0' 2>/dev/null || true
  success "Python dependencies installed (Pillow, pilmoji)"
else
  warn "pip3 not found — install Python deps manually: pip install Pillow pilmoji 'emoji<2.0.0'"
fi

# ── Dependency Check ──────────────────────────────────────────
header "Dependency Check"

command -v jq    &>/dev/null && success "jq found" || warn "jq not found — install: sudo apt install jq"
command -v git   &>/dev/null && success "git found" || warn "git not found — required"
command -v node  &>/dev/null && success "node found ($(node --version))" || warn "node not found — required for GSD and ui-ux-pro-max"
command -v python3 &>/dev/null && success "python3 found" || warn "python3 not found — required for ui-ux-pro-max and web-asset-generator"
command -v bun   &>/dev/null && success "bun found" || warn "bun not found — required for claude-mem (install in post-setup.sh)"

# ── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║        Initial Setup Complete! 🚀        ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Open Claude Code and run post-setup.sh commands:"
echo "     bash ~/ai-dev-toolkit/post-setup.sh"
echo ""
echo "  2. Start a new project — pick a CLAUDE.md template:"
echo "     cp ~/ai-dev-toolkit/claude-md-templates/saas-nextjs.md YOUR_PROJECT/CLAUDE.md"
echo ""
echo "  3. Open CC in that project — agent factory fires automatically"
echo ""
echo "  To update all tools later:"
echo "     bash ~/ai-dev-toolkit/update.sh"
echo ""
