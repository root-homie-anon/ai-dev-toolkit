# Reference: web-asset-generator

**Repo:** https://github.com/alonw0/web-asset-generator
**License:** MIT
**Author:** alonw0

## What It Does
Generates web assets: favicons (multi-size ICO + PNG), PWA app icons (manifest-ready), and social media meta images (Open Graph for Facebook, Twitter, WhatsApp, LinkedIn).

## How It's Integrated
- Bundled in `skills/web-asset-generator/` — installed to `~/.claude/skills/` by `initial-setup.sh`
- Mapped to `frontend` agent in `skills-library.json`
- Activated by task keywords: favicon, app icon, og image, pwa, social image, open graph

## Contents
- `SKILL.md` — Skill definition and usage instructions
- `scripts/` — Asset generation scripts
- `references/` — Format specs and size requirements
