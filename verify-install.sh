#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — verify-install.sh
# Confirms everything installed correctly.
# Usage: bash ~/ai-dev-toolkit/verify-install.sh
# ============================================================

set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

check() {
  if eval "$2" &>/dev/null; then
    echo -e "  ${GREEN}PASS${RESET}  $1"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${RESET}  $1"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo -e "${BOLD}======================================${RESET}"
echo -e "${BOLD}  ai-dev-toolkit  Verification${RESET}"
echo -e "${BOLD}======================================${RESET}"
echo ""

echo -e "${BOLD}Global Config${RESET}"
check "CLAUDE.md exists"          "[[ -f '${CLAUDE_HOME}/CLAUDE.md' ]]"
check "settings.json exists"      "[[ -f '${CLAUDE_HOME}/settings.json' ]]"
check "skills-library.json exists" "[[ -f '${CLAUDE_HOME}/skills-library.json' ]]"
echo ""

echo -e "${BOLD}Agents (12 expected)${RESET}"
AGENT_COUNT=$(find "${CLAUDE_HOME}/agents" -name '*.md' 2>/dev/null | wc -l)
check "Agents directory exists"    "[[ -d '${CLAUDE_HOME}/agents' ]]"
check "12 agents installed"        "[[ ${AGENT_COUNT} -ge 12 ]]"
for agent in architect bug-hunter chief-of-ops claude-specialist code-reviewer \
             database-reviewer devops frontend qa refactor-cleaner security-reviewer sr-dev; do
  check "  ${agent}" "[[ -f '${CLAUDE_HOME}/agents/${agent}.md' ]]"
done
echo ""

echo -e "${BOLD}Skills (18 expected)${RESET}"
SKILL_COUNT=$(find "${CLAUDE_HOME}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
check "Skills directory exists"    "[[ -d '${CLAUDE_HOME}/skills' ]]"
check "18 skills installed"        "[[ ${SKILL_COUNT} -ge 15 ]]"
echo ""

echo -e "${BOLD}Hooks & Scripts${RESET}"
check "session-start.sh exists"    "[[ -x '${CLAUDE_HOME}/hooks/session-start.sh' ]]"
check "orchestrator.sh exists"     "[[ -x '${CLAUDE_HOME}/hooks/orchestrator.sh' ]]"
check "agent-factory.sh exists"    "[[ -x '${CLAUDE_HOME}/scripts/agent-factory.sh' ]]"
echo ""

echo -e "${BOLD}KeyMaster${RESET}"
check "keymaster binary exists"    "[[ -x '${HOME}/bin/keymaster' ]]"
check "~/.keys directory exists"   "[[ -d '${HOME}/.keys' ]]"
check "vault.json exists"          "[[ -f '${HOME}/.keys/vault.json' ]]"
echo ""

echo -e "${BOLD}Shell Config${RESET}"
check "PATH includes ~/bin"        "echo \$PATH | grep -q '${HOME}/bin'"
check "Bash aliases configured"    "grep -qF 'ai-dev-toolkit' '${HOME}/.bashrc'"
echo ""

echo -e "${BOLD}System Dependencies${RESET}"
check "git installed"              "command -v git"
check "node installed"             "command -v node"
check "python3 installed"          "command -v python3"
check "jq installed"               "command -v jq"
echo ""

# ── Summary ───────────────────────────────────────────────────
TOTAL=$((PASS + FAIL))
echo -e "${BOLD}======================================${RESET}"
if [[ $FAIL -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}All ${TOTAL} checks passed${RESET}"
else
  echo -e "  ${GREEN}${PASS} passed${RESET}, ${RED}${FAIL} failed${RESET} out of ${TOTAL}"
fi
echo -e "${BOLD}======================================${RESET}"
echo ""
