#!/usr/bin/env bash
set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
SKILLS_LIBRARY="${CLAUDE_HOME}/skills-library.json"
AGENTS_REGISTRY_LOG="${CLAUDE_HOME}/agents-registry.log"
SKILLS_DIR="${CLAUDE_HOME}/skills"

PROJECT_NAME="${1:-unknown}"
PROJECT_PATH="${2:-$(pwd)}"
PROJECT_AGENTS_DIR="${PROJECT_PATH}/.claude/agents"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[agent-factory]${RESET} $1"; }
success() { echo -e "${GREEN}+${RESET} $1"; }
warn()    { echo -e "${YELLOW}!${RESET} $1"; }
header()  { echo -e "\n${BOLD}${BLUE}$1${RESET}"; }

list_roles() {
  echo "  backend          - Backend API, services, business logic"
  echo "  frontend         - UI, React, web interfaces"
  echo "  fullstack        - Full stack across frontend and backend"
  echo "  mobile           - React Native, Expo, mobile apps"
  echo "  devops           - Infrastructure, CI/CD, deployment, monitoring"
  echo "  qa               - Testing, QA, quality assurance"
  echo "  security         - Security auditing, threat modeling"
  echo "  architect        - System design, architecture decisions"
  echo "  database         - Database design, schema, migrations"
  echo "  product          - Product management, roadmap, strategy"
  echo "  pm               - Project management, sprints, delivery"
  echo "  marketing        - Marketing, content, ASO, growth"
  echo "  release          - Release management, versioning"
  echo "  advisor          - Strategic advisory, C-level decisions"
  echo "  video-compiler   - Remotion video compilation"
  echo "  content-automation - AI content generation pipelines"
}

get_role_skills() {
  local role="$1"
  if command -v jq &>/dev/null; then
    jq -r --arg r "$role" '.roles[$r].base_skills // [] | .[]' "$SKILLS_LIBRARY" 2>/dev/null
  else
    echo ""
  fi
}

get_task_skills() {
  local task="$1"
  local task_lower
  task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
  local matched=""

  if command -v jq &>/dev/null; then
    while IFS= read -r keyword; do
      if echo "$task_lower" | grep -q "$keyword"; then
        local found
        found=$(jq -r --arg k "$keyword" '.task_keywords[$k] // [] | .[]' "$SKILLS_LIBRARY" 2>/dev/null)
        matched="${matched}"$'\n'"${found}"
      fi
    done < <(jq -r '.task_keywords | keys[]' "$SKILLS_LIBRARY" 2>/dev/null)
  fi

  echo "$matched" | sort -u | grep -v '^$' || true
}

merge_skills() {
  local role_skills="$1"
  local task_skills="$2"
  printf '%s\n%s\n' "$role_skills" "$task_skills" | sort -u | grep -v '^$' || true
}

skill_installed() {
  local skill_path="$1"
  local skill_name
  skill_name=$(basename "$skill_path")
  [[ -d "${SKILLS_DIR}/${skill_name}" ]]
}

install_skill() {
  local skill_path="$1"
  local skill_name
  skill_name=$(basename "$skill_path")

  if skill_installed "$skill_path"; then
    log "Already installed: ${skill_name}"
    return 0
  fi

  log "Installing skill: ${skill_name}..."
  local tmp_dir
  tmp_dir=$(mktemp -d)

  if git clone --depth=1 --quiet https://github.com/alirezarezvani/claude-skills.git "${tmp_dir}/claude-skills" 2>/dev/null; then
    local src="${tmp_dir}/claude-skills/${skill_path}"
    if [[ -d "$src" ]]; then
      mkdir -p "$SKILLS_DIR"
      cp -r "$src" "${SKILLS_DIR}/${skill_name}"
      success "Installed ${skill_name}"
    else
      warn "Skill path not found: ${skill_path}"
    fi
  else
    warn "Could not install ${skill_name} - add manually to ${SKILLS_DIR}/"
  fi

  rm -rf "$tmp_dir"
}

generate_agent_file() {
  local agent_name="$1"
  local role="$2"
  local task="$3"
  local skills_list="$4"
  local output_dir="$5"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M')

  mkdir -p "$output_dir"

  local skill_refs=""
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    local skill_name
    skill_name=$(basename "$skill")
    skill_refs="${skill_refs}- ${skill_name}: ~/.claude/skills/${skill_name}/SKILL.md"$'\n'
  done <<< "$skills_list"

  cat > "${output_dir}/${agent_name}.md" << EOF
---
name: ${agent_name}
role: ${role}
project: ${PROJECT_NAME}
created: ${timestamp}
---

# Agent: ${agent_name}

## Role
${role}

## Task Context
${task}

## Loaded Skills
${skill_refs}

## Instructions

You are a specialized ${role} agent for the ${PROJECT_NAME} project.
Your task: ${task}

Apply the most relevant loaded skill to every task.
Always read CLAUDE.md in the project root before starting work.
Flag blockers immediately rather than working around them.
Commit with clean conventional commit messages daily.
EOF

  success "Agent file created: ${output_dir}/${agent_name}.md"
}

register_agent() {
  local agent_name="$1"
  local role="$2"
  local task="$3"
  local timestamp
  timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
  echo "${timestamp}|${PROJECT_NAME}|${agent_name}|${role}|${task}" >> "${AGENTS_REGISTRY_LOG}"
}

agent_exists() {
  local agent_file="${PROJECT_AGENTS_DIR}/${1}.md"
  [[ -f "$agent_file" ]]
}

create_agent() {
  header "Claude Code Agent Factory"
  log "Project: ${PROJECT_NAME} (${PROJECT_PATH})"
  echo ""

  echo -e "${BOLD}Agent name?${RESET} (e.g. backend-api, mobile-ui, db-migrations)"
  read -rp "> " agent_name
  agent_name=$(echo "$agent_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  if agent_exists "$agent_name"; then
    warn "Agent '${agent_name}' already exists for this project"
    read -rp "Recreate it? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return 0
  fi

  echo ""
  echo -e "${BOLD}Select a role:${RESET}"
  list_roles
  echo ""
  read -rp "> Role: " role

  echo ""
  echo -e "${BOLD}Describe this agent's specific task:${RESET}"
  echo -e "${CYAN}Example: implement JWT auth and PostgreSQL schema migrations${RESET}"
  read -rp "> Task: " task

  echo ""
  log "Resolving skills for role '${role}' and task context..."

  local role_skills task_skills all_skills skill_count

  role_skills=$(get_role_skills "$role")
  task_skills=$(get_task_skills "$task")
  all_skills=$(merge_skills "$role_skills" "$task_skills")
  skill_count=$(echo "$all_skills" | grep -c . || true)

  echo ""
  echo -e "${BOLD}Skills matched (${skill_count}):${RESET}"
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    echo -e "  ${GREEN}+${RESET} $(basename "$skill")"
  done <<< "$all_skills"

  echo ""
  read -rp "Install missing skills and create agent? (Y/n): " confirm
  [[ "$confirm" == "n" || "$confirm" == "N" ]] && log "Cancelled." && return 0

  echo ""
  log "Checking skill installations..."
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    install_skill "$skill"
  done <<< "$all_skills"

  echo ""
  log "Generating agent file..."
  generate_agent_file "$agent_name" "$role" "$task" "$all_skills" "$PROJECT_AGENTS_DIR"
  register_agent "$agent_name" "$role" "$task"

  echo ""
  success "Agent '${agent_name}' is ready!"
  log "Invoke with: @${agent_name} in CC"
  echo ""
}

create_agent
