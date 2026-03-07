#!/usr/bin/env bash
# ============================================================
# Claude Code Agent Factory — agent-factory.sh
# Global location: ~/.claude/scripts/agent-factory.sh
# ============================================================
# Creates agents with auto-matched skills based on role + task.
# Called by session-start.sh or directly.
# Usage: agent-factory.sh <project_name> <project_path>
# ============================================================

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────
CLAUDE_HOME="${HOME}/.claude"
SKILLS_LIBRARY="${CLAUDE_HOME}/skills-library.json"
AGENTS_REGISTRY="${CLAUDE_HOME}/agents-registry.json"
SKILLS_DIR="${CLAUDE_HOME}/skills"

PROJECT_NAME="${1:-unknown}"
PROJECT_PATH="${2:-$(pwd)}"
PROJECT_AGENTS_DIR="${PROJECT_PATH}/.claude/agents"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()     { echo -e "${CYAN}[agent-factory]${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${BLUE}$1${RESET}"; echo -e "${BLUE}$(printf '%.0s─' {1..50})${RESET}"; }

# ── Init registry if missing ─────────────────────────────────
init_registry() {
  if [[ ! -f "$AGENTS_REGISTRY" ]]; then
    echo '{"agents": []}' > "$AGENTS_REGISTRY"
    log "Created agents registry at ${AGENTS_REGISTRY}"
  fi
}

# ── Check if agent already exists ────────────────────────────
agent_exists() {
  local agent_name="$1"
  local project="$2"
  if command -v jq &>/dev/null; then
    local count
    count=$(jq --arg n "$agent_name" --arg p "$project" \
      '[.agents[] | select(.name == $n and .project == $p)] | length' \
      "$AGENTS_REGISTRY" 2>/dev/null || echo "0")
    [[ "$count" -gt 0 ]]
  else
    grep -q "\"$agent_name\"" "$AGENTS_REGISTRY" 2>/dev/null
  fi
}

# ── List available roles ──────────────────────────────────────
list_roles() {
  if command -v jq &>/dev/null; then
    jq -r '.roles | to_entries[] | "  \(.key) — \(.value.description)"' \
      "$SKILLS_LIBRARY" 2>/dev/null
  else
    echo "  backend, frontend, fullstack, mobile, devops, qa, security,"
    echo "  architect, database, product, pm, marketing, release, advisor"
  fi
}

# ── Get base skills for a role ────────────────────────────────
get_role_skills() {
  local role="$1"
  if command -v jq &>/dev/null; then
    jq -r --arg r "$role" '.roles[$r].base_skills // [] | .[]' \
      "$SKILLS_LIBRARY" 2>/dev/null
  else
    echo ""
  fi
}

# ── Match extra skills from task description ──────────────────
get_task_skills() {
  local task="$1"
  local task_lower
  task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
  local matched_skills=()

  if command -v jq &>/dev/null; then
    while IFS= read -r keyword; do
      if echo "$task_lower" | grep -q "$keyword"; then
        while IFS= read -r skill; do
          matched_skills+=("$skill")
        done < <(jq -r --arg k "$keyword" '.task_keywords[$k] // [] | .[]' \
          "$SKILLS_LIBRARY" 2>/dev/null)
      fi
    done < <(jq -r '.task_keywords | keys[]' "$SKILLS_LIBRARY" 2>/dev/null)
  fi

  printf '%s\n' "${matched_skills[@]}" | sort -u
}

# ── Merge role + task skills, deduplicated ────────────────────
merge_skills() {
  local role_skills="$1"
  local task_skills="$2"
  printf '%s\n%s\n' "$role_skills" "$task_skills" | sort -u | grep -v '^
}

# ── Check if a skill is already installed ─────────────────────
skill_installed() {
  local skill_path="$1"
  local skill_name
  skill_name=$(basename "$skill_path")
  [[ -d "${SKILLS_DIR}/${skill_name}" ]]
}

# ── Install a skill ───────────────────────────────────────────
install_skill() {
  local skill_path="$1"
  local skill_name
  skill_name=$(basename "$skill_path")

  if skill_installed "$skill_path"; then
    log "Already installed: ${skill_name}"
    return 0
  fi

  log "Installing skill: ${skill_name}..."

  # Try plugin install first
  if command -v claude &>/dev/null; then
    claude --dangerously-skip-permissions \
      "run: /plugin install ${skill_name}@claude-code-skills" \
      2>/dev/null && success "Installed ${skill_name} via plugin" && return 0
  fi

  # Fallback: clone from GitHub and copy
  local tmp_dir
  tmp_dir=$(mktemp -d)
  if git clone --depth=1 --quiet \
    https://github.com/alirezarezvani/claude-skills.git \
    "${tmp_dir}/claude-skills" 2>/dev/null; then
    local src="${tmp_dir}/claude-skills/${skill_path}"
    if [[ -d "$src" ]]; then
      mkdir -p "$SKILLS_DIR"
      cp -r "$src" "${SKILLS_DIR}/${skill_name}"
      success "Installed ${skill_name} via git clone"
    else
      warn "Skill path not found: ${skill_path}"
    fi
    rm -rf "$tmp_dir"
  else
    warn "Could not install ${skill_name} — add manually to ${SKILLS_DIR}/"
    rm -rf "$tmp_dir"
  fi
}

# ── Generate the agent .md file ───────────────────────────────
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
    skill_refs+="- skill: ${skill_name}\n  path: ~/.claude/skills/${skill_name}/SKILL.md\n"
  done <<< "$skills_list"

  cat > "${output_dir}/${agent_name}.md" << EOF
---
name: ${agent_name}
role: ${role}
project: ${PROJECT_NAME}
created: ${timestamp}
generator: ai-dev-toolkit agent-factory v1.0
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

Your task context: ${task}

Apply the most relevant loaded skill's workflow and best practices to every task.
When starting work:
1. Identify which loaded skill is most relevant to the immediate task
2. Follow that skill's workflow and validation steps
3. Apply code standards from CODE_STANDARDS.md in the project root
4. Commit work with clean, descriptive messages
5. Flag blockers immediately rather than working around them

Refer to CLAUDE.md in the project root for full project context before beginning.
EOF

  success "Agent file created: ${output_dir}/${agent_name}.md"
}

# ── Register agent in global registry ────────────────────────
register_agent() {
  local agent_name="$1"
  local role="$2"
  local task="$3"
  local skills_csv="$4"
  local timestamp
  timestamp=$(date '+%Y-%m-%dT%H:%M:%S')

  if command -v jq &>/dev/null; then
    local tmp
    tmp=$(mktemp)
    jq --arg n "$agent_name" \
       --arg r "$role" \
       --arg t "$task" \
       --arg p "$PROJECT_NAME" \
       --arg pp "$PROJECT_PATH" \
       --arg ts "$timestamp" \
       --arg s "$skills_csv" \
      '.agents += [{
        name: $n,
        role: $r,
        task: $t,
        project: $p,
        project_path: $pp,
        created: $ts,
        skills: ($s | split(","))
      }]' "$AGENTS_REGISTRY" > "$tmp" && mv "$tmp" "$AGENTS_REGISTRY"
  else
    echo "${timestamp}|${PROJECT_NAME}|${agent_name}|${role}" \
      >> "${CLAUDE_HOME}/agents-registry.log"
  fi
}

# ── Main interactive agent creation ──────────────────────────
create_agent() {
  header "🤖 Claude Code Agent Factory"
  log "Project: ${PROJECT_NAME} (${PROJECT_PATH})"
  echo ""

  # Agent name
  echo -e "${BOLD}Agent name?${RESET} (e.g. backend-api, mobile-ui, db-migrations)"
  read -rp "→ " agent_name
  agent_name=$(echo "$agent_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  if agent_exists "$agent_name" "$PROJECT_NAME"; then
    warn "Agent '${agent_name}' already exists for project '${PROJECT_NAME}'"
    read -rp "Recreate it? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return 0
  fi

  # Role
  echo ""
  echo -e "${BOLD}Select a role:${RESET}"
  list_roles
  echo ""
  read -rp "→ Role: " role

  # Task description
  echo ""
  echo -e "${BOLD}Describe this agent's specific task:${RESET}"
  echo -e "${CYAN}(e.g. 'implement JWT auth and PostgreSQL schema migrations')${RESET}"
  read -rp "→ Task: " task

  # Resolve skills
  echo ""
  log "Resolving skills for role '${role}' + task context..."

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

  # Confirm
  echo ""
  read -rp "Install missing skills and create agent? (Y/n): " confirm
  [[ "$confirm" == "n" || "$confirm" == "N" ]] && log "Cancelled." && return 0

  # Install missing skills
  echo ""
  log "Checking skill installations..."
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    install_skill "$skill"
  done <<< "$all_skills"

  # Create agent file
  echo ""
  log "Generating agent file..."
  generate_agent_file "$agent_name" "$role" "$task" "$all_skills" "$PROJECT_AGENTS_DIR"

  # Register
  local skills_csv
  skills_csv=$(echo "$all_skills" | tr '\n' ',' | sed 's/,$//')
  register_agent "$agent_name" "$role" "$task" "$skills_csv"

  # Done
  echo ""
  success "Agent '${agent_name}' is ready!"
  log "Invoke with: @${agent_name} <your instruction>"
  echo ""
}

# ── Entry point ───────────────────────────────────────────────
init_registry
create_agent
