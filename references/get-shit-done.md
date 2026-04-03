# Reference: get-shit-done (GSD)

**Repo:** https://github.com/gsd-build/get-shit-done
**License:** MIT
**Author:** TÂCHES (@glittercowboy)

## What It Does
Meta-prompting, context engineering, and spec-driven development system. Solves context rot via structured workflows: new-project → discuss-phase → plan-phase → execute-phase → verify-work → ship. Uses parallel subagents, fresh context windows per plan, atomic git commits.

## How It's Integrated
- **Install:** `initial-setup.sh` — `npx get-shit-done-cc --claude --global`
- **Scope:** System-wide workflow (not project-scoped)
- **Hooks:** GSD registers its own hooks via npx install — documented in `hooks/orchestrator.sh`
- **Not in skills-library.json** — workflow system, not a role skill

## Core Commands (available after install)
- `/gsd:new-project` — Initialize project with research, requirements, roadmap
- `/gsd:plan-phase N` — Research + plan a phase
- `/gsd:execute-phase N` — Parallel subagent execution
- `/gsd:verify-work N` — User acceptance testing
- `/gsd:quick` — Ad-hoc tasks with GSD guarantees
- `/gsd:next` — Auto-detect and run next step

## Update
`update.sh` runs `npx get-shit-done-cc@latest --claude --global` to pull latest.
