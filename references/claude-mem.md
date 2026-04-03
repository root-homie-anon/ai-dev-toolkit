# Reference: claude-mem

**Repo:** https://github.com/thedotmack/claude-mem
**License:** AGPL-3.0
**Author:** Alex Newman (@thedotmack)

## What It Does
Persistent memory compression system for Claude Code. Automatically captures tool usage observations during coding sessions, compresses them with AI, and injects relevant context back into future sessions.

## How It's Integrated
- **Install:** `post-setup.sh` — requires live CC session via `/plugin` commands
- **Scope:** System-wide infrastructure (not project-scoped)
- **Hooks:** Manages its own lifecycle hooks (SessionStart, UserPromptSubmit, PostToolUse, Stop, SessionEnd) via plugin system — documented in `hooks/orchestrator.sh`
- **Storage:** `~/.claude-mem/` — separate namespace, no collision with toolkit

## Install Commands (run inside CC session)
```
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

## Update
Plugin auto-updates via CC plugin system. No action needed in `update.sh`.
