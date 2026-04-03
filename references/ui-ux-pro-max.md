# Reference: ui-ux-pro-max-skill

**Repo:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
**License:** MIT
**Author:** nextlevelbuilder

## What It Does
Design intelligence skill for building professional UI/UX. Ships 67 UI styles, 161 industry-specific reasoning rules, 57 font pairings, and a design system generator. Auto-activates on UI/UX requests.

## How It's Integrated
- **Install:** `initial-setup.sh` — `npm install -g uipro-cli && uipro init --ai claude --global`
- **Scope:** Project-scoped via `skills-library.json`
- **Roles:** Added as base skill for `frontend`, `fullstack`, `mobile` roles
- **Keywords:** `ui`, `ux`, `design system`, `landing page`, `dashboard`, `glassmorphism`, `dark mode`
- **Dependency:** Python 3 (for search.py engine)

## Update
`update.sh` runs `uipro update` to pull latest version.
