# Reference: web-asset-generator

**Repo:** https://github.com/alonw0/web-asset-generator
**License:** MIT
**Author:** Alon Wolenitz (@alonw0)

## What It Does
Generates favicons, app icons, and social media images from logos, text, or emojis. Auto-detects frameworks (Next.js, Astro, etc.) and integrates HTML tags. Validates file sizes, dimensions, and WCAG contrast.

## How It's Integrated
- **Install:** `initial-setup.sh` — git clone to `~/.claude/skills/web-asset-generator/`, pip install deps
- **Scope:** Project-scoped via `skills-library.json`
- **Roles:** Added as base skill for `frontend`, `fullstack`, `mobile` roles
- **Keywords:** `favicon`, `app icon`, `og image`, `social image`, `open graph`, `pwa`, `manifest`
- **Dependencies:** Python 3, Pillow, pilmoji, emoji<2.0.0

## Update
`update.sh` runs `git pull` in the cloned skill directory.
