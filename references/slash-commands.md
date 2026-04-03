# Slash Commands Reference

Complete catalog of all slash commands available in the ai-dev-toolkit environment.

---

## Built-in (CC Default)

These ship with Claude Code — always available, no setup needed.

| Command | What It Does |
|---------|-------------|
| `/help` | Show available commands and usage help |
| `/clear` | Clear conversation history |
| `/compact` | Compress conversation context to free up space |
| `/resume` | Resume a previous session (interactive picker) |
| `/model` | Switch AI model for the session |
| `/fast` | Toggle fast mode (same Opus model, faster output) |
| `/plan` | Enter plan mode — explore and design before implementing |
| `/mcp` | List and manage MCP server connections |
| `/agents` | List available agents |

---

## Skills (User-Invokable)

Skills act as slash commands — type `/skill-name` to trigger. These are installed globally and available in every session.

### Architecture & Design
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/senior-architect` | Tony | System design, dependency analysis, architecture diagrams |
| `/search-first` | Tony | Research existing tools/libs/patterns before writing custom code |
| `/api-design-reviewer` | Tony, Doug | API contract review, design patterns, breaking change detection |

### Implementation
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/senior-backend` | Doug | REST APIs, microservices, auth, GraphQL, DB optimization |
| `/verification-loop` | Doug | Pre-PR checks: build, types, lint, tests, security scan, diff review |
| `/claude-api` | — | Build apps with Claude API or Anthropic SDK |

### Frontend
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/ui-ux-pro-max` | Ava | UI/UX design system, styling, component patterns, color/typography |
| `/web-asset-generator` | Ava | Generate favicons, app icons, OG images, PWA assets |
| `/codebase-to-course` | Ava | Turn any codebase into interactive HTML course |

### Code Quality
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/code-reviewer` | Linda | PR analysis, SOLID compliance, code smells, review reports |
| `/simplify` | — | Review changed code for reuse, quality, efficiency — fix issues found |

### Database
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/database-engineering` | Omar | Schema design, query optimization, index strategy, migrations |
| `/migration-architect` | Omar | Zero-downtime migrations, expand-migrate-contract patterns |
| `/supabase-postgres-best-practices` | Omar | Postgres optimization, connection pooling, RLS, performance |

### Security
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/senior-security` | Elliot | Threat modeling, STRIDE analysis, vulnerability analysis, pentesting |
| `/env-secrets-manager` | Elliot, Ray | Key management, .env handling, secret rotation |

### Testing
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/tdd-workflow` | Chris | RED/GREEN/REFACTOR cycle with git checkpoints |
| `/e2e-testing` | Chris | Playwright E2E patterns, Page Object Model, CI/CD integration |
| `/api-test-suite-builder` | Chris | API test automation |

### Utility
| Command | Owner Agent | What It Does |
|---------|------------|-------------|
| `/find-skills` | — | Discover and install new agent skills |
| `/update-config` | — | Configure Claude Code settings.json |
| `/keybindings-help` | — | Customize keyboard shortcuts |
| `/loop` | — | Run a prompt/command on recurring interval (e.g. `/loop 5m /foo`) |
| `/schedule` | — | Create/manage scheduled remote agents (cron triggers) |

---

## Plugin Commands

Available from the CC plugin marketplace. Not all are installed — these are discoverable.

### Git & PR Workflow
| Command | What It Does |
|---------|-------------|
| `/commit` | Create a git commit with staged changes |
| `/commit-push-pr` | Commit, push, and open a PR in one step |
| `/clean-gone` | Clean up git branches marked as [gone] on remote |
| `/review-pr` | Comprehensive PR review using specialized agents |

### Code Quality
| Command | What It Does |
|---------|-------------|
| `/code-review` | Full code review of a pull request |
| `/feature-dev` | Guided feature development with architecture focus |

### Configuration
| Command | What It Does |
|---------|-------------|
| `/hookify` | Create hooks to prevent unwanted behaviors |
| `/hookify:list` | List all configured hookify rules |
| `/hookify:configure` | Enable/disable hookify rules |
| `/revise-claude-md` | Update CLAUDE.md with learnings from the session |

### Development
| Command | What It Does |
|---------|-------------|
| `/create-plugin` | Guided plugin creation workflow |
| `/new-sdk-app` | Create a new Claude Agent SDK application |

### Automation
| Command | What It Does |
|---------|-------------|
| `/ralph-loop` | Iterative development loop |
| `/cancel-ralph` | Cancel an active Ralph Loop |

---

## Agent-Specific (Invoked via @agent, not /)

These aren't slash commands — they're invoked by mentioning the agent or by Marcus routing to them. Listed here for completeness.

| Invoke | Alias | What They Handle |
|--------|-------|-----------------|
| `@chief-of-ops` | Marcus | Session start, delegation, team routing |
| `@architect` | Tony | System design, API contracts, structure |
| `@sr-dev` | Doug | Feature implementation, data contracts |
| `@frontend` | Ava | UI, components, styling, React |
| `@bug-hunter` | Nate | Errors, silent failures, root cause |
| `@code-reviewer` | Linda | Code quality, SOLID, PR review |
| `@database-reviewer` | Omar | Schema, queries, indexes, migrations |
| `@security-reviewer` | Elliot | API security, auth, input validation |
| `@devops` | Ray | CI/CD, scripts, hooks, automation |
| `@qa` | Chris | E2E, integration, regression testing |
| `@refactor-cleaner` | Mark | Dead code, structural cleanup, tech debt |
| `@claude-specialist` | Jared | Budget tracking, spend, revenue, CC optimization |

### Project-Level Agents
| Invoke | Alias | What They Handle |
|--------|-------|-----------------|
| `@orchestrator` | Vincent | Project lead — drives sessions, delegates to domain agents |
| `@architect` | Tony | Lead architect — designs before anyone codes |
| _(domain agents)_ | _(varies)_ | Created per-project via agent factory |

---

## Quick Reference

```
# Built-in
/help  /clear  /compact  /resume  /model  /fast  /plan  /mcp  /agents

# Most used skills
/verification-loop    # Pre-PR check
/code-reviewer        # Review code
/search-first         # Research before coding
/tdd-workflow         # Test-driven development
/find-skills          # Discover new skills

# Git workflow (plugins)
/commit               # Commit staged changes
/commit-push-pr       # Commit + push + PR
/review-pr            # Review a PR
```
