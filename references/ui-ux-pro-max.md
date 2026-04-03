# Reference: ui-ux-pro-max

**Source:** https://www.npmjs.com/package/uipro-cli
**License:** MIT
**Author:** viettranx

## What It Does
UI/UX design skill for AI coding assistants. Provides design system generation, component styling patterns, color palettes, typography, and responsive layout guidance.

## How It's Integrated
- Bundled in `skills/ui-ux-pro-max/` — installed to `~/.claude/skills/` by `initial-setup.sh`
- Mapped to `frontend` agent in `skills-library.json`
- Activated by task keywords: ui, ux, design system, landing page, dashboard, glassmorphism, dark mode

## Contents
- `scripts/` — Python scripts for design system generation, search, and core logic
- `data/` — CSV datasets for typography, colors, icons, styles, UI reasoning, and framework-specific patterns (React, Next.js, Svelte, Vue, Flutter, SwiftUI, etc.)
- `templates/` — Skill content and quick reference templates
