# ai-dev-toolkit

> Personal AI development infrastructure for Claude Code — clone once, use everywhere.

One setup command brings Claude Code to full power on any machine: 12 production agents, 18 skills, KeyMaster for secrets, global config, hooks, and bash aliases all wired up and ready.

---

## Quick Start (any machine)

```bash
# 1. Clone the toolkit
git clone https://github.com/root-homie-anon/ai-dev-toolkit.git ~/ai-dev-toolkit

# 2. Run setup (installs everything — no external dependencies)
bash ~/ai-dev-toolkit/initial-setup.sh

# 3. Source your shell
source ~/.bashrc

# 4. Add your API keys
keymaster add ANTHROPIC_API_KEY

# 5. Start working
cd ~/projects/my-app && ccnew
```

---

## What's Inside

| Folder | What It Does |
|--------|-------------|
| `global/` | Global CLAUDE.md, settings.json, skills-library.json |
| `agents/` | 12 production specialist agents |
| `skills/` | 15 bundled skills mapped to agents |
| `agent-factory/` | On-demand project agent creation (hooks + scripts) |
| `keymaster/` | Centralized API key management |
| `dotfiles/` | Bash aliases and PATH setup |
| `claude-md-templates/` | CLAUDE.md starter files per project type |
| `hooks/` | Hook orchestrator — chains all system hooks |
| `standards/` | Code standards, commit conventions |
| `prompts/` | Reusable prompt library |
| `references/` | Source documentation for integrated tools |

---

## Production Agents

12 specialist agents with rich instructions, protocols, and handoff patterns:

| Agent | Alias | Role |
|-------|-------|------|
| `chief-of-ops` | **Marcus** | Session lead — scans repo, routes to permanent team |
| `architect` | **Tony** | System design, APIs, schemas, structure decisions |
| `sr-dev` | **Doug** | Feature implementation, pipeline integrity, data contracts |
| `frontend` | **Ava** | UI, components, styling, React, visual interfaces |
| `bug-hunter` | **Nate** | Root cause detection, silent failures, error surfacing |
| `code-reviewer` | **Linda** | Code quality, SOLID, PR review, conventions |
| `database-reviewer` | **Omar** | Schema design, queries, indexes, migrations, performance |
| `security-reviewer` | **Elliot** | API security, auth, input validation, secrets |
| `devops` | **Ray** | CI/CD, scripts, hooks, automation, environment setup |
| `qa` | **Chris** | E2E testing, TDD, integration tests (non-blocking) |
| `refactor-cleaner` | **Mark** | Dead code removal, structural cleanup, tech debt |
| `claude-specialist` | **Jared** | Budget tracking, spend projections, revenue monitoring, CC platform optimization |

---

## Skills

18 skills mapped to agents via `skills-library.json`:

| Skill | Owner Agent(s) |
|-------|---------------|
| `senior-architect` | architect |
| `search-first` | architect |
| `senior-backend` | sr-dev |
| `api-design-reviewer` | architect, sr-dev |
| `verification-loop` | sr-dev |
| `code-reviewer` | code-reviewer |
| `database-engineering` | database-reviewer |
| `migration-architect` | database-reviewer |
| `supabase-postgres-best-practices` | database-reviewer |
| `senior-security` | security-reviewer |
| `env-secrets-manager` | security-reviewer, devops |
| `ui-ux-pro-max` | frontend |
| `web-asset-generator` | frontend |
| `codebase-to-course` | frontend |
| `tdd-workflow` | qa |
| `e2e-testing` | qa |
| `api-test-suite-builder` | qa |
| `find-skills` | general |

---

## KeyMaster

Centralized API key management. Single vault at `~/.keys/vault.json`, generates per-project `.env` files.

```bash
keymaster status              # Dashboard
keymaster add API_KEY_NAME    # Add a key (interactive)
keymaster sync PROJECT        # Generate .env for a project
keymaster audit               # Security check
keymaster require PROJECT K1 K2  # Declare project key requirements
```

See `keymaster/README.md` for full reference.

---

## Project Agent Templates

Every new project gets Vincent (Project Lead) scaffolded into `.claude/agents/`. The template lives in `project-agents/` and includes the full orchestration protocol — just fill in the delegation map and pipeline sequence.

| Agent | Alias | Job Title |
|-------|-------|-----------|
| `orchestrator` | **Vincent** | Project Lead |

Additional domain agents (e.g. `@researcher`, `@backend`, `@designer`) are created per-project via the agent factory based on what the project needs.

---

## Agent Factory

Create project-specific agents on demand during any session:

1. Session starts — `session-start.sh` fires automatically
2. Shows existing agents for this project
3. Offers interactive agent creation
4. Skills auto-matched from role + task keywords
5. Agent created at `.claude/agents/<name>.md`

Supports 16 roles: backend, frontend, fullstack, mobile, devops, qa, security, architect, database, product, pm, marketing, release, advisor, video-compiler, content-automation.

---

## CLAUDE.md Templates

| Template | Best For |
|----------|---------|
| `saas-mobile.md` | React Native + Node.js + AWS |
| `saas-web.md` | React/Next.js + Node.js + AWS |
| `saas-nextjs.md` | Next.js + Supabase + Stripe |
| `api-only.md` | Pure backend API service |
| `go-microservice.md` | Go + gRPC + PostgreSQL |
| `django-api.md` | Django REST + Celery + PostgreSQL |
| `laravel-api.md` | Laravel + PostgreSQL + Redis |
| `rust-api.md` | Rust + Axum + SQLx + PostgreSQL |

---

## Scripts

| Script | When To Run | What It Does |
|--------|-------------|--------------|
| `initial-setup.sh` | Fresh machine (idempotent) | Installs everything from local repo |
| `update.sh` | Anytime | Pulls latest toolkit, refreshes installed files |
| `verify-install.sh` | After setup | Confirms everything installed correctly |

---

## Shell Aliases

After setup, these are available:

| Alias | What It Does |
|-------|-------------|
| `cc` | Launch Claude Code with session-start hook |
| `ccnew` | Same as `cc` — launch in current project dir |

---

## Keeping Up To Date

```bash
bash ~/ai-dev-toolkit/update.sh          # Normal update
bash ~/ai-dev-toolkit/update.sh --force  # Force overwrite CLAUDE.md + agents
```

---

## Credits & Attributions

See `ATTRIBUTION.md` for full details.

---

## License

MIT — see LICENSE
