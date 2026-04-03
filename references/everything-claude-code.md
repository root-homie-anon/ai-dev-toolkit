# Reference: everything-claude-code (ECC)

**Repo:** https://github.com/affaan-m/everything-claude-code
**License:** MIT
**Author:** Affaan Mustafa (@affaan-m)

## What It Does
Agent harness performance optimization system. Ships 28 pre-built agents, 125 skills, rules, hooks, and MCP configs evolved over 10+ months of production use.

## How It's Integrated
- **Agents:** All 27 pre-built agents copied to `agent-factory/agents/` — installed to `~/.claude/agents/` by `initial-setup.sh`
- **Rules:** `common/` + `typescript/` + `python/` + `golang/` copied to `~/.claude/rules/` by `initial-setup.sh`
- **Skills:** Selected skills cloned to `~/.claude/skills/` by `initial-setup.sh`
- **Plugin:** `post-setup.sh` installs via `/plugin` commands for hooks and commands
- **CLAUDE.md templates:** 5 new templates added to `claude-md-templates/`

## Install Commands (run inside CC session)
```
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

## Update
`update.sh` pulls latest agents, rules, and skills from repo. Plugin updates via CC.
