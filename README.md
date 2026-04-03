# ai-dev-toolkit

> Personal AI development infrastructure for Claude Code — clone once, use everywhere.

A public toolkit that travels with you across every machine and project. One setup command brings Claude Code to full power instantly — agents, skills, slash commands, templates, standards, and prompts all wired up and ready.

---

## What's Inside

| Folder | What It Does |
|--------|-------------|
| `agent-factory/` | Auto-creates CC agents with matched skills at session start |
| `agent-factory/agents/` | 26 pre-built specialist agents (from ECC) |
| `claude-md-templates/` | CLAUDE.md starter files per project type |
| `hooks/` | Hook orchestrator — chains all system hooks in order |
| `commands/` | Custom slash commands for common workflows |
| `standards/` | Code standards, commit conventions, PR templates |
| `prompts/` | Reusable prompt library for recurring tasks |
| `references/` | Source documentation for all integrated tools |
| `docs/` | Guides and references |

---

## Quick Start (any machine)

```bash
# 1. Clone the toolkit
git clone https://github.com/root-homie-anon/ai-dev-toolkit.git ~/ai-dev-toolkit

# 2. Run headless setup (installs everything that doesn't need CC open)
bash ~/ai-dev-toolkit/initial-setup.sh

# 3. Open Claude Code and run post-setup instructions
bash ~/ai-dev-toolkit/post-setup.sh

# 4. Start a new project — pick a CLAUDE.md template
cp ~/ai-dev-toolkit/claude-md-templates/saas-nextjs.md YOUR_PROJECT/CLAUDE.md
```

---

## Keeping Up To Date

```bash
# Pull latest from all source repos — only installs what's new
bash ~/ai-dev-toolkit/update.sh
```

---

## Setup Scripts

| Script | When To Run | What It Does |
|--------|-------------|--------------|
| `initial-setup.sh` | Fresh machine, or anytime (idempotent) | Installs all headless tools, agents, rules, skills |
| `post-setup.sh` | After initial-setup, inside CC session | Prints plugin install commands for CC-dependent tools |
| `update.sh` | Anytime to pull latest | Checks all source repos, installs only what's new |

---

## Agent Factory

At every CC session start, the hook fires automatically.

1. Session starts → orchestrator fires → agent factory runs
2. Shows existing agents for this project
3. "Create a new agent? (y/N)"
4. You provide: name → role → task description
5. Skills auto-matched from `agent-factory/skills-library.json`
6. Agent created at `.claude/agents/<name>.md`, invoke with `@name`

### Pre-built Agents

26 specialist agents available immediately after setup (from ECC):

| Agent | Role |
|-------|------|
| `planner` | Feature planning and task breakdown |
| `architect` | System design and architecture |
| `tdd-guide` | Test-driven development enforcement |
| `code-reviewer` | Code quality and security review |
| `security-reviewer` | OWASP audits, vulnerability analysis |
| `build-error-resolver` | Build failures and dependency conflicts |
| `e2e-runner` | Playwright end-to-end testing |
| `refactor-cleaner` | Dead code removal, tech debt |
| `doc-updater` | Documentation sync |
| `docs-lookup` | API research before implementation |
| `chief-of-staff` | Communication triage and drafts |
| `loop-operator` | Autonomous loop execution |
| `harness-optimizer` | CC config and performance tuning |
| `go-reviewer` | Go code review |
| `python-reviewer` | Python code review |
| `typescript-reviewer` | TypeScript/JavaScript review |
| `database-reviewer` | Query and schema review |
| `rust-reviewer` + `rust-build-resolver` | Rust development |
| `cpp-reviewer` + `cpp-build-resolver` | C++ development |
| `java-reviewer` + `java-build-resolver` | Java/Spring Boot |
| `kotlin-reviewer` + `kotlin-build-resolver` | Kotlin/Android |
| `pytorch-build-resolver` | PyTorch/CUDA training |

---

## Hook Architecture

All hooks chain through a single orchestrator — no conflicts, no duplicate firing.

```
~/.claude/hooks/orchestrator.sh
  └── 1. Agent Factory    (session-start.sh — interactive)
  └── 2. ECC              (registered via plugin system)
  └── 3. GSD              (registered via npx install)
  └── 4. claude-mem       (registered via /plugin)
```

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

## System-Wide Tools

These install globally and are available in every CC session regardless of project:

| Tool | What It Does |
|------|-------------|
| **claude-mem** | Persistent memory across sessions — auto-captures context, injects back on start |
| **get-shit-done (GSD)** | Spec-driven development — `/gsd:new-project`, `/gsd:plan-phase`, `/gsd:execute-phase` |
| **codebase-to-course** | "Turn this into a course" — generates interactive HTML course from any codebase |
| **ECC** | 26 agents, rules, hooks, and skills for agent harness performance |

---

## Project-Scoped Skills

These install globally but activate per-project via the agent factory role/keyword matching:

| Skill | Roles | Keywords |
|-------|-------|---------|
| **ui-ux-pro-max** | frontend, fullstack, mobile | ui, ux, design system, landing page, dashboard |
| **web-asset-generator** | frontend, fullstack, mobile | favicon, app icon, og image, pwa, social image |

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

## References

Source documentation for all integrated tools lives in `references/`:

- `references/claude-mem.md`
- `references/everything-claude-code.md`
- `references/ui-ux-pro-max.md`
- `references/codebase-to-course.md`
- `references/web-asset-generator.md`
- `references/get-shit-done.md`

---

## Credits & Attributions

See `ATTRIBUTION.md` for full details.

---

## License

MIT — see LICENSE
