# Reference: codebase-to-course

**Repo:** https://github.com/zarazhangrui/codebase-to-course
**License:** Not specified
**Author:** Zara (@zarazhangrui)

## What It Does
Turns any codebase into a beautiful, interactive single-page HTML course. Generates scroll-based modules, code/plain-English side-by-side translations, animated visualizations, interactive quizzes, and glossary tooltips.

## How It's Integrated
- **Install:** `initial-setup.sh` — git clone to `~/.claude/skills/codebase-to-course/`
- **Scope:** System-wide (trigger phrase "turn this into a course" in any CC session)
- **Not in skills-library.json** — utility skill, not role/project specific

## Trigger Phrases
- "Turn this into a course"
- "Explain this codebase interactively"
- "Make a course from this project"
- "Teach me how this code works"

## Update
`update.sh` runs `git pull` in the cloned skill directory.
