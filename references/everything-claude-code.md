# Reference: everything-claude-code (ECC)

**Repo:** https://github.com/affaan-m/everything-claude-code
**License:** MIT
**Author:** Affaan Mustafa (@affaan-m)

## What It Does
Agent harness performance optimization system. Ships 28+ pre-built agents, 125+ skills, rules, hooks, and MCP configs evolved over months of production use.

## How It Influenced This Toolkit
ECC's architecture patterns influenced the design of this toolkit:
- Agent specialization model (permanent team of domain experts)
- Skill resolution via keyword matching
- Hook orchestration (chaining multiple hooks through a single entrypoint)
- Session-start agent factory pattern

This toolkit does **not** clone or depend on ECC at runtime. The 12 production agents and 18 skills are maintained independently.
