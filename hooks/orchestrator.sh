#!/usr/bin/env bash
# ============================================================
# ai-dev-toolkit — hooks/orchestrator.sh
# Global location: ~/.claude/hooks/orchestrator.sh
#
# Single entrypoint for ALL session-start hooks.
# Add new hooks here in order. Each hook is optional —
# if it doesn't exist, it's skipped cleanly.
# ============================================================

set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
PROJECT_NAME="${1:-$(basename "$(pwd)")}"
PROJECT_PATH="${2:-$(pwd)}"

run_hook() {
  local label="$1"
  local script="$2"
  shift 2
  if [[ -f "$script" ]]; then
    bash "$script" "$@" || true   # never let one hook kill the chain
  fi
}

# ── 1. Agent Factory ─────────────────────────────────────────
run_hook "agent-factory" \
  "${CLAUDE_HOME}/hooks/session-start.sh" \
  "$PROJECT_NAME" "$PROJECT_PATH"

# ── 2. ECC hooks (loaded via hooks.json, not shell) ──────────
# ECC registers its own hooks via plugin system — no shell call needed.
# Documented here for visibility only.

# ── 3. GSD ───────────────────────────────────────────────────
# GSD registers its own hooks via npx install — no shell call needed.
# Documented here for visibility only.

# ── 4. claude-mem ────────────────────────────────────────────
# claude-mem registers its own hooks via /plugin — no shell call needed.
# Documented here for visibility only.
