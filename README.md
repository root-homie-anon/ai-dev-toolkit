# ai-dev-toolkit

**Strong Tower Media AI Studio** — Internal development infrastructure for AI agent-driven software engineering.

> One setup command deploys the full agent team to any machine. Every project gets the same 12-agent permanent team, 18 skills, centralized secrets, and orchestration framework — purpose-built for building and shipping AI-powered products at speed.

---

## What This Is

This toolkit is the operating system for how Strong Tower Media builds software. Every project — from automated content pipelines to SaaS platforms to trading bots — runs through the same agent architecture:

- **A permanent team of 12 specialists** handles every discipline: architecture, implementation, frontend, security, database, QA, DevOps, code review, debugging, refactoring, budget tracking, and platform optimization
- **A Project Lead (Vincent)** gets scaffolded per project to orchestrate domain-specific agents and pipelines
- **Marcus (COO)** boots every session, scans the repo, routes work to the right specialist, and spins up bench agents via the factory when the team hits a skill gap
- **All agents are stateless** — full context passed explicitly, parallel execution where possible, errors always surface

This isn't a collection of scripts. It's a complete AI development methodology that travels with you.

---

## Quick Start (any machine)

Prerequisites: Claude Code installed and authenticated.

```bash
# 1. Clone the toolkit
git clone https://github.com/root-homie-anon/ai-dev-toolkit.git ~/ai-dev-toolkit

# 2. Run setup (installs deps + full agent team)
bash ~/ai-dev-toolkit/initial-setup.sh

# 3. Source your shell
source ~/.bashrc

# 4. Migrate API keys from existing machine (if applicable)
bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine
keymaster sync

# 5. Start a project
cd ~/projects/my-app && ccnew
```

---

## The Agent Team

### Permanent Team (Global — available in every project)

12 production agents with rich instructions, protocols, handoff patterns, and delegation boundaries. Each owns a specific domain and knows who to hand off to for adjacent concerns.

| Agent | Alias | Title | Level |
|-------|-------|-------|-------|
| `chief-of-ops` | **Marcus** | Chief Operating Officer | System |
| `architect` | **Tony** | Lead Architect | Project |
| `sr-dev` | **Doug** | Senior Software Engineer | Project |
| `frontend` | **Ava** | Senior Frontend Engineer | Project |
| `bug-hunter` | **Nate** | Root Cause Analyst | Project |
| `code-reviewer` | **Linda** | Code Quality Lead | Project |
| `database-reviewer` | **Omar** | Database Engineer | Project |
| `security-reviewer` | **Elliot** | Application Security Engineer | Project |
| `devops` | **Ray** | Infrastructure & Automation Engineer | System |
| `qa` | **Chris** | QA & Test Automation Engineer | Project |
| `refactor-cleaner` | **Mark** | Tech Debt Specialist | Project |
| `claude-specialist` | **Jared** | Budget & Platform Specialist | System |

### Project Lead (Per-project — scaffolded from template)

| Agent | Alias | Title |
|-------|-------|-------|
| `orchestrator` | **Vincent** | Project Lead |

Vincent drives every project session. His template lives in `project-agents/orchestrator.md` — fill in the delegation map and pipeline sequence per project. Domain agents (e.g. `@researcher`, `@designer`, `@listing-agent`) are created per-project via the agent factory.

### Bench Agents (On-demand — created by Marcus)

When the permanent team hits a skill gap, Marcus identifies it, reports the finding, and — with your approval — invokes the agent factory to create a project-scoped specialist. Bench agents match the quality bar of the permanent 12. Promotion to permanent team is by your request only.

---

## How It Works

### Session Flow

```
Session starts
    |
    v
Marcus boots — scans repo, loads state, checks git
    |
    v
Routes to one of three states:
  A) Active work → picks up where it left off, routes to right agent
  B) Opportunities → recommends next action from git/TODOs/tech debt
  C) Clean slate → stands by for your command
    |
    v
Work flows through the permanent team:
  Tony designs → Doug implements → Linda reviews → Chris tests
  Elliot audits security → Omar reviews DB → Ray deploys
    |
    v
Jared tracks spend, flags budget alerts, optimizes tooling
```

### Project Initialization

1. Plan the project in claude.ai using `prompts/new-project-claude-ai.md`
2. Drop the generated CLAUDE.md in the project root (or start from `claude-md-templates/project-skeleton.md`)
3. Scaffold Vincent: `cp ~/ai-dev-toolkit/project-agents/orchestrator.md .claude/agents/`
4. Fill in Vincent's delegation map and pipeline sequence
5. Create domain agents via the agent factory as needed
6. `ccnew` — Marcus boots, Vincent leads, the team executes

---

## What's Inside

| Folder | What It Does |
|--------|-------------|
| `agents/` | 12 global production agents (the permanent team) |
| `project-agents/` | Vincent (Project Lead) template |
| `skills/` | 18 bundled skills mapped to agents |
| `global/` | Global CLAUDE.md, settings.json, skills-library.json |
| `agent-factory/` | On-demand bench agent creation (hooks + scripts) |
| `keymaster/` | Centralized API key management + vault migration |
| `claude-md-templates/` | 8 stack templates + project skeleton |
| `dotfiles/` | Bash aliases (cc, ccnew) and PATH setup |
| `hooks/` | Hook orchestrator — chains all system hooks |
| `prompts/` | Reusable prompts (including claude.ai project planning) |
| `references/` | Slash commands reference, tool docs |
| `standards/` | Code standards, commit conventions |

---

## Skills

18 skills mapped to agents via `skills-library.json`. Skills are invoked as slash commands (`/skill-name`) and auto-matched to agents by task keywords.

| Skill | Owner | Domain |
|-------|-------|--------|
| `senior-architect` | Tony | System design, architecture diagrams |
| `search-first` | Tony | Research before coding |
| `senior-backend` | Doug | APIs, microservices, auth |
| `api-design-reviewer` | Tony, Doug | API contracts, breaking changes |
| `verification-loop` | Doug | Pre-PR: build, lint, test, security |
| `code-reviewer` | Linda | PR analysis, SOLID, code smells |
| `database-engineering` | Omar | Schema, queries, indexes |
| `migration-architect` | Omar | Zero-downtime migrations |
| `supabase-postgres-best-practices` | Omar | Postgres optimization, RLS |
| `senior-security` | Elliot | Threat modeling, STRIDE, pentesting |
| `env-secrets-manager` | Elliot, Ray | Key management, secret rotation |
| `ui-ux-pro-max` | Ava | Design systems, styling, components |
| `web-asset-generator` | Ava | Favicons, app icons, OG images |
| `codebase-to-course` | Ava | Interactive HTML courses from code |
| `tdd-workflow` | Chris | RED/GREEN/REFACTOR with git checkpoints |
| `e2e-testing` | Chris | Playwright, Page Object Model |
| `api-test-suite-builder` | Chris | API test automation |
| `find-skills` | — | Discover and install new skills |

See `references/slash-commands.md` for the full command reference.

---

## KeyMaster

Centralized API key management. Single vault, per-project `.env` generation.

```bash
keymaster status              # Dashboard
keymaster add API_KEY_NAME    # Add a key
keymaster sync PROJECT        # Generate .env for a project
keymaster audit               # Security check
keymaster require PROJECT K1  # Declare project key requirements
```

Migrate vault to a new machine:
```bash
bash ~/ai-dev-toolkit/keymaster/migrate-vault.sh scp user@old-machine
```

---

## Budget Tracking

Jared maintains per-project spend and revenue data:

- **Costs**: API usage, infrastructure, external services
- **Revenue**: Sales, subscriptions, affiliate, ads
- **Projections**: Extrapolated from historical patterns + known pricing
- **Alerts**: Overspend thresholds, missing revenue tracking, cost jumps

Ask: "How much am I spending?", "What's printpilot costing me?", "Am I profitable?"

---

## Scripts

| Script | When | What It Does |
|--------|------|-------------|
| `initial-setup.sh` | Fresh machine | Installs system deps + full toolkit |
| `update.sh` | Anytime | Pulls latest, refreshes installed files |
| `update.sh --force` | When needed | Overwrites CLAUDE.md + agents |
| `verify-install.sh` | After setup | Confirms everything installed correctly |

---

## Agent Factory

When the permanent team can't cover a domain, Marcus creates bench agents:

1. Marcus identifies the skill gap mid-session
2. Reports the finding — never interrupts workflow
3. You approve — bench agents are never auto-created
4. Agent factory resolves skills from 16 supported roles
5. New agent ships production-ready in `PROJECT/.claude/agents/`

Supported roles: backend, frontend, fullstack, mobile, devops, qa, security, architect, database, product, pm, marketing, release, advisor, video-compiler, content-automation.

---

## Credits & Attributions

See `ATTRIBUTION.md` for full details.

---

## License

MIT — see LICENSE
