# ai-dev-toolkit

> Personal AI development infrastructure for Claude Code — clone once, use everywhere.

A public toolkit that travels with you across every machine and project. One setup command brings Claude Code to full power instantly — agents, skills, slash commands, templates, standards, and prompts all wired up and ready.

---

## What's Inside

| Folder | What It Does |
|--------|-------------|
| `agent-factory/` | Auto-creates CC agents with matched skills at session start |
| `claude-md-templates/` | CLAUDE.md starter files per project type (SaaS, API, mobile, etc.) |
| `commands/` | Custom slash commands for common workflows |
| `standards/` | Code standards, commit conventions, PR templates |
| `prompts/` | Reusable prompt library for recurring tasks |
| `docs/` | Guides and references |

---

## Quick Start (any machine)
```bash
# 1. Clone the toolkit
git clone https://github.com/YOUR_USERNAME/ai-dev-toolkit.git ~/ai-dev-toolkit

# 2. Run one-time global setup
bash ~/ai-dev-toolkit/setup.sh

# 3. Install slash commands globally
cp ~/ai-dev-toolkit/commands/*.md ~/.claude/commands/

# 4. Start a new project — pick a CLAUDE.md template
cp ~/ai-dev-toolkit/claude-md-templates/saas-mobile.md YOUR_PROJECT/CLAUDE.md
```

---

## Agent Factory

At every CC session start, it asks if you need new agents, matches skills by role + task, installs missing skills, and generates the agent file.

1. Session starts → hook fires
2. Shows existing agents for this project
3. "Create a new agent? (y/N)"
4. You provide: name → role → task description
5. Skills auto-matched from agent-factory/skills-library.json
6. Agent created at .claude/agents/<name>.md, invoke with @name

---

## CLAUDE.md Templates

| Template | Best For |
|----------|---------|
| `saas-mobile.md` | React Native + Node.js + AWS |
| `saas-web.md` | React/Next.js + Node.js + AWS |
| `api-only.md` | Pure backend API service |

---

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/create-agent` | Manually trigger agent creation mid-session |
| `/project-status` | Summarize current sprint, open tasks, recent commits |
| `/code-review` | Full review of staged changes |
| `/new-feature` | Scaffold a new feature with tests and docs |
| `/release-prep` | Generate changelog, bump version, check readiness |
| `/security-check` | Run security audit on current changes |
| `/db-migration` | Generate a new migration file from schema changes |

---

## Credits & Attributions

Built on excellent open-source work by Alireza Rezvani (MIT):
- claude-skills: https://github.com/alirezarezvani/claude-skills
- claude-code-tresor: https://github.com/alirezarezvani/claude-code-tresor
- claude-code-skill-factory: https://github.com/alirezarezvani/claude-code-skill-factory

See ATTRIBUTION.md for full details.

---

## License

MIT — see LICENSE
