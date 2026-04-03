---
name: search-first
description: Research-before-coding workflow — search for existing tools, libraries, patterns, and MCP servers before writing custom code. Prevents reinventing the wheel.
owner: architect
origin: ECC
---

# Search First — Research Before You Code

Systematizes the "search for existing solutions before implementing" workflow.

## When to Activate

- Starting a new feature that likely has existing solutions
- Adding a dependency or integration
- Before creating a new utility, helper, or abstraction
- The user asks "add X functionality" and you're about to write code

## Workflow

```
1. NEED ANALYSIS    — Define what's needed, language/framework constraints
2. PARALLEL SEARCH  — npm/PyPI, MCP servers, skills, GitHub
3. EVALUATE         — Score candidates (functionality, maintenance, docs, license)
4. DECIDE           — Adopt / Extend / Build
5. IMPLEMENT        — Install package / Configure MCP / Write minimal custom code
```

## Decision Matrix

| Signal | Action |
|--------|--------|
| Exact match, well-maintained, MIT/Apache | **Adopt** — install and use directly |
| Partial match, good foundation | **Extend** — install + write thin wrapper |
| Multiple weak matches | **Compose** — combine 2-3 small packages |
| Nothing suitable found | **Build** — write custom, informed by research |

## Search Checklist

Before writing any utility or adding functionality:

0. **Does this already exist in the repo?** → grep through relevant modules first
1. **Is this a common problem?** → Search npm/PyPI for established packages
2. **Is there an MCP server for this?** → Check `~/.claude/settings.json`
3. **Is there a skill for this?** → Check `~/.claude/skills/`
4. **Is there a maintained OSS implementation?** → GitHub code search

## Quick Reference by Category

| Need | Look For |
|------|----------|
| HTTP client | `httpx` (Python), `ky`/`got` (Node) |
| Validation | `zod` (TS), `pydantic` (Python) |
| Linting | `eslint`, `ruff`, `biome` |
| Testing | `jest`/`vitest`, `pytest`, `playwright` |
| Image processing | `sharp`, `Pillow` |
| Markdown | `remark`, `unified`, `markdown-it` |
| Database | Check for MCP servers first |
| AI/LLM | Check Anthropic SDK docs, Context7 |

## Integration Points

- **architect** should invoke search-first before design decisions
- **sr-dev** should check before writing utilities
- **planner** should research available tools before Phase 1

## Anti-Patterns

- Jumping straight to code without checking if a solution exists
- Ignoring MCP servers that already provide the capability
- Over-wrapping a library until it loses its benefits
- Installing a massive package for one small feature
