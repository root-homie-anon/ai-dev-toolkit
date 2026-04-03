# Prompt: New Project Planning (for use in claude.ai)

Paste this into claude.ai when planning a new project. It tells Claude to generate a CLAUDE.md that works with your existing global config and agent team.

---

## The Prompt

```
I need you to generate a CLAUDE.md file for a new project. This file will be the root orchestrator — it's what my Project Lead agent (Vincent) reads first to understand the project and coordinate the team.

IMPORTANT: This project runs inside a Claude Code environment that already has a global config loaded from ~/.claude/CLAUDE.md. The global config handles:
- Session modes (COLLAB/AUTO)
- A permanent 12-agent team with aliases (Marcus/COO, Tony/Architect, Doug/Sr Dev, Ava/Frontend, Nate/Bug Hunter, Linda/Code Reviewer, Omar/DB Engineer, Elliot/Security, Ray/DevOps, Chris/QA, Mark/Refactoring, Jared/Claude Specialist)
- Git defaults (conventional commits, main -> dev -> feature/ branching)
- Security defaults (.env in .gitignore, KeyMaster for secrets)
- Context management (save protocol at 10% context)
- Base code standards (TypeScript strict, functional, async/await, no any)
- Base automation assumptions (stateless agents, parallel execution, errors surface)

DO NOT include any of those sections in the output. They are already loaded globally and duplicating them causes drift.

The CLAUDE.md you generate should ONLY contain:
1. System Overview — what this project does, who it's for, the core problem
2. Orchestrator Behavior — session start protocol, sequencing rules
3. Agent Team — Vincent (@orchestrator) + project-specific domain agents with roles
4. Core User Flow — the journey through the system with agent handoffs and human decision points
5. Project Structure — directory layout
6. Tech Stack — specific technologies
7. Project-Specific Standards — ONLY rules beyond the global base (e.g. "all X API calls go through wrapper Y")
8. Project-Specific Automation — ONLY rules beyond the global base (e.g. "research agents run in parallel")
9. config.json Schema — runtime configuration
10. Shared Resources — API keys needed, shared types location
11. Initialization Checklist — steps to get it running

Start the file with this header:
# [Project Name] — Master Project File

And include this note at the top:
> This project inherits global config from ~/.claude/CLAUDE.md.
> Do not duplicate: session modes, agent routing, git/security defaults, KeyMaster, context management, base code standards, base automation assumptions.

Here's my project:

[DESCRIBE YOUR PROJECT HERE]
```
