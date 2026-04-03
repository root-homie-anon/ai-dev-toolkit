# [Project Name] — Master Project File

> **This project inherits global config from `~/.claude/CLAUDE.md`.**
> Do NOT duplicate these sections — they are already loaded globally:
> - Session modes (COLLAB/AUTO)
> - Agent routing (permanent team: Marcus, Tony, Doug, Ava, Nate, Linda, Omar, Elliot, Ray, Chris, Mark, Jared)
> - Git defaults (conventional commits, branch strategy)
> - Security defaults (.env in .gitignore, no hardcoded secrets)
> - KeyMaster (centralized key management)
> - Context management (10% save protocol)
> - Base code standards (TypeScript strict, functional, async/await)
> - Base automation assumptions (stateless agents, parallel execution, errors surface)

---

## System Overview
<!-- One paragraph: what this project does, who it's for, what problem it solves. Be specific — this is what Vincent reads first to understand the project. -->

---

## Orchestrator Behavior

This file is the root orchestrator. On session start:

1. Fire the session-start hook
2. Load state from `state/` if it exists
3. Ask the user: continue existing run, start a new one, or initialize a new sub-project
4. Spawn subagents scoped to their domain — they share no state unless explicitly passed
<!-- Add project-specific sequencing rules below, e.g.:
5. Research agents always run in parallel
6. @strategy-builder waits for all research agents to complete
-->

---

## Agent Team

All agents live in `.claude/agents/` and are shared across the project.

| Agent | Role |
|-------|------|
| `@orchestrator` (Vincent) | Drives the session, delegates tasks, manages state |
<!-- Add project-specific domain agents below, e.g.:
| `@researcher` | Scrapes market data, populates opportunity queue |
| `@designer` | Creates templates and visual assets |
| `@listing-agent` | Publishes to marketplace platform |
-->

---

## Core User Flow

<!-- Map the user journey through the system. Show agent handoffs.
Example:
```
User describes goal
    |
    v
Vincent kicks off research phase
    |  (parallel)
    v
@agent-a    @agent-b    @agent-c
    |  (all complete)
    v
@synthesizer -> produces output
    |
    v
USER REVIEWS  <- HUMAN DECISION POINT
    |
    v
@publisher -> ships it
```
-->

---

## Project Structure

```
project-name/
├── CLAUDE.md                        <- this file, root orchestrator
├── .env                             <- secrets, never committed
├── .env.example                     <- committed env template
├── .claude/
│   └── agents/                      <- project-specific agents
│       ├── orchestrator.md
│       └── ...
├── src/
│   └── ...
├── state/                           <- runtime agent state, gitignored
└── ...
```
<!-- Fill in the actual project structure -->

---

## Tech Stack

<!-- List the specific technologies for this project.
| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14 (App Router) |
| Backend | Node.js + Express |
| Database | PostgreSQL via Prisma |
| Auth | Clerk |
| ... | ... |
-->

---

## Project-Specific Standards

<!-- ONLY add rules that go BEYOND the global code standards.
Examples:
- All Meta API calls go through `lib/meta-client.ts` — never call the API directly
- All TTS calls go through the voice service — never call ElevenLabs directly
- Product state transitions must be atomic — never leave ambiguous state
If you have no project-specific additions, delete this section.
-->

---

## Project-Specific Automation

<!-- ONLY add rules that go BEYOND the global automation assumptions.
Examples:
- Research agents always run in parallel — never sequentially
- @monitor runs on a 6-hour cron schedule
- Marketing pipeline has a configurable buffer delay after listing goes live
If you have no project-specific additions, delete this section.
-->

---

## config.json Schema

<!-- Define the project's runtime configuration.
```json
{
  "project": {
    "name": "",
    "slug": "",
    "version": "0.1.0"
  },
  "pipeline": {
    ...
  },
  "features": {
    ...
  }
}
```
-->

---

## Shared Resources

### API Keys
<!-- List required keys. Use keymaster to manage them.
Run: keymaster require PROJECT_NAME KEY1 KEY2 KEY3
-->

### Shared Types
<!-- Where shared TypeScript types live, e.g.:
All types shared across agents/services live in `src/shared/types/`.
Never duplicate types — always import from shared.
-->

---

## Initialization Checklist

<!-- Steps to get this project running from scratch.
- [ ] Clone repo and install dependencies
- [ ] Copy `.env.example` -> `.env` and fill values (or `keymaster sync PROJECT`)
- [ ] Run database migrations
- [ ] Seed initial data
- [ ] Run dev server
- [ ] Verify all agents load
-->
