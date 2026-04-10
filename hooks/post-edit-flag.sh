#!/usr/bin/env bash
# ============================================================
# post-edit-flag.sh — Team Operating Model: sensitive-file flag
# ------------------------------------------------------------
# Fires on PostToolUse for Edit/Write. Inspects the file_path
# and, if it matches a security- or DB-sensitive pattern,
# injects additionalContext routing the change to the correct
# specialist per the Proactive Flag Triggers table.
#
# Never blocks. Never emits when the path is irrelevant.
# ============================================================

set -euo pipefail

INPUT=$(cat)
export HOOK_INPUT="$INPUT"

python3 <<'PY'
import json, os, re, sys

try:
    d = json.loads(os.environ.get("HOOK_INPUT", ""))
except Exception:
    sys.exit(0)

ti = d.get("tool_input", {}) or {}
path = ti.get("file_path", "") or ""
if not path:
    sys.exit(0)

p = path.lower()

SECURITY_PATTERNS = [
    (r"/auth[/_-]",            "auth module"),
    (r"/middleware",           "middleware layer"),
    (r"/\.env",                "env file"),
    (r"\bsecret",              "secret-bearing file"),
    (r"\bcredential",          "credential-bearing file"),
    (r"/api/.*\.(ts|tsx|js|jsx|py|go)$", "API route handler"),
    (r"\btoken",               "token handling"),
    (r"\bsession",             "session handling"),
    (r"\bwebhook",             "webhook handler"),
    (r"\bpermission",          "permission/authorization logic"),
]

DB_PATTERNS = [
    (r"\.sql$",                "SQL file"),
    (r"/migrations?/",         "migration"),
    (r"/prisma/schema",        "Prisma schema"),
    (r"/supabase/.*\.sql",     "Supabase SQL"),
    (r"/drizzle/",             "Drizzle schema/migration"),
]

sec_hit = next((label for pat, label in SECURITY_PATTERNS if re.search(pat, p)), None)
db_hit  = next((label for pat, label in DB_PATTERNS      if re.search(pat, p)), None)

if not sec_hit and not db_hit:
    sys.exit(0)

parts = []
if sec_hit:
    parts.append(
        f"SECURITY-SENSITIVE FILE TOUCHED ({sec_hit}: {path}). "
        f"Per Team Operating Model -> Proactive Flag Triggers, this change requires "
        f"@security-reviewer (Elliot) verification before the task closes. "
        f"Do NOT self-patch security concerns. Flag to Marcus and route to Elliot."
    )
if db_hit:
    parts.append(
        f"DB-SENSITIVE FILE TOUCHED ({db_hit}: {path}). "
        f"Per Team Operating Model -> Proactive Flag Triggers, this change requires "
        f"@database-reviewer (Omar) verification before the task closes. "
        f"Migrations additionally require @qa rollback verification."
    )

msg = " ".join(parts)

out = {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": msg,
    }
}
print(json.dumps(out))
PY

exit 0
