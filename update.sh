#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — update.sh
# Pulls latest from all source repos. Only installs what's new.
# Safe to re-run at any time — all operations are idempotent.
# Usage: bash ~/ai-dev-toolkit/update.sh
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

log()     { echo -e "${CYAN}[update]${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET}  $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}   $1"; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }
new_item(){ echo -e "${GREEN}+ NEW${RESET} $1"; }

UPDATES_FOUND=0

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       ai-dev-toolkit  Update             ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── Self-update (pull toolkit repo) ──────────────────────────
header "Toolkit Repo"
if [[ -d "${TOOLKIT_DIR}/.git" ]]; then
  git -C "$TOOLKIT_DIR" pull --quiet origin main 2>/dev/null && \
    success "ai-dev-toolkit repo updated" || \
    warn "Could not pull toolkit repo — check network"
else
  log "Not a git repo — skipping self-update"
fi

# ── Agent Factory files ───────────────────────────────────────
header "Agent Factory"

cp "${TOOLKIT_DIR}/agent-factory/skills-library.json" \
   "${CLAUDE_HOME}/skills-library.json"
success "skills-library.json updated"

cp "${TOOLKIT_DIR}/agent-factory/hooks/session-start.sh" \
   "${CLAUDE_HOME}/hooks/session-start.sh"
chmod +x "${CLAUDE_HOME}/hooks/session-start.sh"

cp "${TOOLKIT_DIR}/agent-factory/scripts/agent-factory.sh" \
   "${CLAUDE_HOME}/scripts/agent-factory.sh"
chmod +x "${CLAUDE_HOME}/scripts/agent-factory.sh"

cp "${TOOLKIT_DIR}/hooks/orchestrator.sh" \
   "${CLAUDE_HOME}/hooks/orchestrator.sh"
chmod +x "${CLAUDE_HOME}/hooks/orchestrator.sh"
success "Hook orchestrator updated"

# ── Pre-built Agents — only add new ones ─────────────────────
header "Pre-built Agents (ECC)"

for agent_file in "${TOOLKIT_DIR}/agent-factory/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  dest="${AGENTS_DIR}/$(basename "$agent_file")"
  if [[ ! -f "$dest" ]]; then
    cp "$agent_file" "$dest"
    new_item "Agent: $(basename "$agent_file" .md)"
    UPDATES_FOUND=$((UPDATES_FOUND + 1))
  fi
done

# ── ECC — rules and skills ────────────────────────────────────
header "ECC Rules + Skills"

TMP_ECC=$(mktemp -d)
trap 'rm -rf "$TMP_ECC"' EXIT

if git clone --depth=1 --quiet \
   https://github.com/affaan-m/everything-claude-code.git "${TMP_ECC}/ecc" 2>/dev/null; then

  # Rules — update existing, add new
  for lang in common typescript python golang; do
    src="${TMP_ECC}/ecc/rules/${lang}"
    dest="${RULES_DIR}/${lang}"
    if [[ -d "$src" ]]; then
      mkdir -p "$dest"
      # Copy only files that are new or updated
      while IFS= read -r -d '' file; do
        rel="${file#${src}/}"
        if [[ ! -f "${dest}/${rel}" ]]; then
          cp "$file" "${dest}/${rel}"
          new_item "Rule: ${lang}/${rel}"
          UPDATES_FOUND=$((UPDATES_FOUND + 1))
        fi
      done < <(find "$src" -type f -print0)
      success "ECC rules checked: ${lang}"
    fi
  done

  # Skills — add new only
  ECC_CORE_SKILLS=(
    "continuous-learning" "continuous-learning-v2" "iterative-retrieval"
    "strategic-compact" "tdd-workflow" "security-review" "eval-harness"
    "verification-loop" "search-first" "backend-patterns" "frontend-patterns"
    "api-design" "deployment-patterns" "docker-patterns" "e2e-testing"
    "database-migrations"
  )

  for skill in "${ECC_CORE_SKILLS[@]}"; do
    src="${TMP_ECC}/ecc/skills/${skill}"
    dest="${SKILLS_DIR}/${skill}"
    if [[ -d "$src" ]] && [[ ! -d "$dest" ]]; then
      cp -r "$src" "$dest"
      new_item "ECC skill: ${skill}"
      UPDATES_FOUND=$((UPDATES_FOUND + 1))
    fi
  done

  success "ECC check complete"
else
  warn "Could not reach ECC repo — skipping"
fi

# ── ui-ux-pro-max ─────────────────────────────────────────────
header "ui-ux-pro-max"

if command -v uipro &>/dev/null; then
  uipro update 2>/dev/null && success "ui-ux-pro-max updated" || \
    warn "uipro update failed — run manually: uipro update"
else
  warn "uipro not found — run initial-setup.sh first"
fi

# ── web-asset-generator ───────────────────────────────────────
header "web-asset-generator"

WAG_REPO="${SKILLS_DIR}/../.toolkit-repos/web-asset-generator"
WAG_DIR="${SKILLS_DIR}/web-asset-generator"
mkdir -p "${SKILLS_DIR}/../.toolkit-repos"

if [[ -d "${WAG_REPO}/.git" ]]; then
  git -C "$WAG_REPO" pull --quiet origin main 2>/dev/null && \
    cp -r "${WAG_REPO}/skills/web-asset-generator/." "${WAG_DIR}/" && \
    success "web-asset-generator updated" || \
    warn "web-asset-generator update failed"
else
  if git clone --depth=1 --quiet \
     https://github.com/alonw0/web-asset-generator.git "$WAG_REPO" 2>/dev/null; then
    cp -r "${WAG_REPO}/skills/web-asset-generator" "$WAG_DIR"
    success "web-asset-generator installed"
    UPDATES_FOUND=$((UPDATES_FOUND + 1))
  else
    warn "Could not reach web-asset-generator repo — skipping"
  fi
fi

# ── codebase-to-course ────────────────────────────────────────
header "codebase-to-course"

C2C_REPO="${SKILLS_DIR}/../.toolkit-repos/codebase-to-course"
C2C_DIR="${SKILLS_DIR}/codebase-to-course"
mkdir -p "${SKILLS_DIR}/../.toolkit-repos"

if [[ -d "${C2C_REPO}/.git" ]]; then
  git -C "$C2C_REPO" pull --quiet origin main 2>/dev/null && \
    cp "${C2C_REPO}/SKILL.md" "${C2C_DIR}/" && \
    cp -r "${C2C_REPO}/references/." "${C2C_DIR}/references/" 2>/dev/null || true
    success "codebase-to-course updated" || \
    warn "codebase-to-course update failed"
else
  if git clone --depth=1 --quiet \
     https://github.com/zarazhangrui/codebase-to-course.git "$C2C_REPO" 2>/dev/null; then
    mkdir -p "$C2C_DIR"
    cp "${C2C_REPO}/SKILL.md" "$C2C_DIR/"
    cp -r "${C2C_REPO}/references" "$C2C_DIR/"
    success "codebase-to-course installed"
    UPDATES_FOUND=$((UPDATES_FOUND + 1))
  else
    warn "Could not reach codebase-to-course repo — skipping"
  fi
fi

# ── get-shit-done ─────────────────────────────────────────────
header "get-shit-done (GSD)"

if command -v npx &>/dev/null; then
  npx get-shit-done-cc@latest --claude --global --yes 2>/dev/null || \
  npx get-shit-done-cc@latest --claude --global 2>/dev/null || true
  success "GSD updated to latest"
else
  warn "npx not found — GSD not updated"
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║          Update Complete! ✓              ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
if [[ $UPDATES_FOUND -gt 0 ]]; then
  echo -e "  ${GREEN}${UPDATES_FOUND} new items installed${RESET}"
else
  echo "  Everything already up to date."
fi
echo ""
echo "  Plugin-based tools (claude-mem, ECC plugin) update"
echo "  automatically via CC plugin system."
echo ""
