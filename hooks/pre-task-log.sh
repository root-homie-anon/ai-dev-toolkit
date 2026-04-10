#!/usr/bin/env bash
# ============================================================
# pre-task-log.sh — Team Operating Model: handoff audit trail
# ------------------------------------------------------------
# Fires on PreToolUse when the Task tool is invoked.
# Appends an entry to ~/.claude/logs/agent-handoffs.log so
# Marcus (and the user) can reconstruct the ledger after the
# fact: who was delegated to, when, and for what.
#
# Input: JSON on stdin with tool_input containing
#   { subagent_type, description, prompt }
# Output: none (silent success). Never blocks.
# ============================================================

set -euo pipefail

LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/agent-handoffs.log"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

PARSED=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = d.get('tool_input', {}) or {}
agent = ti.get('subagent_type', 'general-purpose')
desc  = (ti.get('description', '') or '').replace('\n', ' ')[:120]
sid   = (d.get('session_id', '') or '')[:8]
cwd   = d.get('cwd', '') or ''
print(f'{agent}\t{desc}\t{sid}\t{cwd}')
" 2>/dev/null) || exit 0

[[ -z "$PARSED" ]] && exit 0

IFS=$'\t' read -r AGENT DESC SESSION CWD <<< "$PARSED"
TS=$(date '+%Y-%m-%d %H:%M:%S')

printf '%s | session=%s | cwd=%s | agent=@%s | %s\n' \
  "$TS" "$SESSION" "$CWD" "$AGENT" "$DESC" >> "$LOG_FILE"

exit 0
