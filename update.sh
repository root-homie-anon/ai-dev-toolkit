#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — update.sh
# Pulls latest toolkit and refreshes all installed files.
# Safe to re-run at any time — all operations are idempotent.
# Usage: bash ~/ai-dev-toolkit/update.sh [--force]
# ============================================================

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_HOME}/skills"
AGENTS_DIR="${CLAUDE_HOME}/agents"
RULES_DIR="${CLAUDE_HOME}/rules"
FORCE=false

[[ "${1:-}" == "--force" ]] && FORCE=true

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[update]${RESET} $1"; }
success() { echo -e "${GREEN}[ok]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

UPDATES=0

echo ""
echo -e "${BOLD}======================================${RESET}"
echo -e "${BOLD}  ai-dev-toolkit  Update${RESET}"
echo -e "${BOLD}======================================${RESET}"
echo ""

# ── Self-update ───────────────────────────────────────────────
header "Toolkit Repo"
if [[ -d "${TOOLKIT_DIR}/.git" ]]; then
  git -C "$TOOLKIT_DIR" pull --quiet origin main 2>/dev/null && \
    success "Toolkit repo updated" || \
    warn "Could not pull — check network or branch"
else
  log "Not a git repo — skipping self-update"
fi

# ── Global Config ─────────────────────────────────────────────
header "Global Config"

if $FORCE || [[ ! -f "${CLAUDE_HOME}/CLAUDE.md" ]]; then
  cp "${TOOLKIT_DIR}/global/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md"
  success "CLAUDE.md updated"
  UPDATES=$((UPDATES + 1))
else
  log "CLAUDE.md exists — use --force to overwrite"
fi

cp "${TOOLKIT_DIR}/global/settings.json" "${CLAUDE_HOME}/settings.json"
success "settings.json refreshed"

cp "${TOOLKIT_DIR}/global/skills-library.json" "${CLAUDE_HOME}/skills-library.json"
success "skills-library.json refreshed"

# ── Agents ────────────────────────────────────────────────────
header "Production Agents"

for agent_file in "${TOOLKIT_DIR}/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  name="$(basename "$agent_file")"
  dest="${AGENTS_DIR}/${name}"
  if $FORCE || [[ ! -f "$dest" ]] || ! diff -q "$agent_file" "$dest" &>/dev/null; then
    cp "$agent_file" "$dest"
    success "Agent updated: ${name%.md}"
    UPDATES=$((UPDATES + 1))
  fi
done

# ── Skills ────────────────────────────────────────────────────
header "Skills"

for skill_dir in "${TOOLKIT_DIR}/skills/"*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  dest="${SKILLS_DIR}/${name}"
  if [[ ! -d "$dest" ]]; then
    cp -r "$skill_dir" "$dest"
    success "Skill installed: ${name}"
    UPDATES=$((UPDATES + 1))
  else
    log "Skill exists: ${name} — skipping"
  fi
done

# ── Rules (canonical domain conventions) ──────────────────────
header "Rules"

mkdir -p "$RULES_DIR"
if [[ -d "${TOOLKIT_DIR}/rules" ]]; then
  for rule_file in "${TOOLKIT_DIR}/rules/"*.md; do
    [[ -f "$rule_file" ]] || continue
    name="$(basename "$rule_file")"
    dest="${RULES_DIR}/${name}"
    if $FORCE || [[ ! -f "$dest" ]] || ! diff -q "$rule_file" "$dest" &>/dev/null; then
      cp "$rule_file" "$dest"
      success "Rule updated: ${name%.md}"
      UPDATES=$((UPDATES + 1))
    fi
  done
else
  log "No rules directory in toolkit — skipping"
fi

# ── Hooks & Scripts ───────────────────────────────────────────
header "Hooks & Scripts"

mkdir -p "${CLAUDE_HOME}/hooks" "${CLAUDE_HOME}/logs"

cp "${TOOLKIT_DIR}/agent-factory/hooks/session-start.sh" \
   "${CLAUDE_HOME}/hooks/session-start.sh"
chmod +x "${CLAUDE_HOME}/hooks/session-start.sh"

cp "${TOOLKIT_DIR}/hooks/orchestrator.sh" \
   "${CLAUDE_HOME}/hooks/orchestrator.sh"
chmod +x "${CLAUDE_HOME}/hooks/orchestrator.sh"

# Team Operating Model enforcement hooks (tool-call hooks)
for hook in pre-task-log post-edit-flag post-edit-commit-reminder; do
  if [[ -f "${TOOLKIT_DIR}/hooks/${hook}.sh" ]]; then
    cp "${TOOLKIT_DIR}/hooks/${hook}.sh" "${CLAUDE_HOME}/hooks/${hook}.sh"
    chmod +x "${CLAUDE_HOME}/hooks/${hook}.sh"
  fi
done

cp "${TOOLKIT_DIR}/agent-factory/scripts/agent-factory.sh" \
   "${CLAUDE_HOME}/scripts/agent-factory.sh"
chmod +x "${CLAUDE_HOME}/scripts/agent-factory.sh"

success "Hooks and scripts refreshed"

# ── KeyMaster ─────────────────────────────────────────────────
header "KeyMaster"

cp "${TOOLKIT_DIR}/keymaster/keymaster" "${HOME}/bin/keymaster"
chmod +x "${HOME}/bin/keymaster"
success "keymaster updated"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}======================================${RESET}"
echo -e "${GREEN}${BOLD}  Update Complete${RESET}"
echo -e "${GREEN}${BOLD}======================================${RESET}"
echo ""
if [[ $UPDATES -gt 0 ]]; then
  echo "  ${UPDATES} items updated."
else
  echo "  Everything already up to date."
fi
echo ""
echo "  To verify: bash ${TOOLKIT_DIR}/verify-install.sh"
echo ""
