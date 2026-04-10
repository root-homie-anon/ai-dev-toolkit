#!/usr/bin/env bash
# ============================================================
# post-edit-commit-reminder.sh — Team Operating Model:
# commit-due proactive flag
# ------------------------------------------------------------
# Fires on PostToolUse for Edit/Write. Inspects git status in
# the session cwd. If >= THRESHOLD files are uncommitted,
# injects a reminder to route the commit to @devops (Ray).
#
# Self-resetting: once a commit lands, git status drops and
# the reminder stops firing until the next threshold crossing.
# ============================================================

set -euo pipefail

THRESHOLD=5

INPUT=$(cat)

CWD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('cwd', '') or '')
except Exception:
    pass
" 2>/dev/null) || exit 0

[[ -z "$CWD" ]] && exit 0
[[ ! -d "$CWD" ]] && exit 0

cd "$CWD" 2>/dev/null || exit 0

# Only act inside a git repo
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[[ -z "$COUNT" ]] && exit 0
[[ "$COUNT" -lt "$THRESHOLD" ]] && exit 0

PROJECT=$(basename "$CWD")
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
BRANCH="${BRANCH%%$'\n'*}"
[[ -z "$BRANCH" ]] && BRANCH="unknown"

export HOOK_COUNT="$COUNT"
export HOOK_BRANCH="$BRANCH"
export HOOK_PROJECT="$PROJECT"

python3 <<'PY'
import json, os
msg = (
    f"COMMIT-DUE FLAG: {os.environ.get('HOOK_COUNT','?')} uncommitted changes "
    f"on branch '{os.environ.get('HOOK_BRANCH','?')}' in "
    f"{os.environ.get('HOOK_PROJECT','?')}. "
    f"Per Team Operating Model -> Proactive Flag Triggers, a logical unit is "
    f"likely complete. Route to @devops (Ray) for commit review. Do not commit "
    f"directly unless the user has explicitly authorized it this session. Ray "
    f"owns git per Role Purity."
)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": msg,
    }
}))
PY

exit 0
