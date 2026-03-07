# CLAUDE.md — SaaS Mobile Project Template
# Copy this file to your project root as CLAUDE.md
# Replace all PLACEHOLDER values before first use

## Agent Factory Hook

At the start of every session, before doing anything else, run:

bash ~/.claude/hooks/session-start.sh "PROJECT_NAME" "$(pwd)"

Wait for agent setup to complete, then proceed.

---

## Project Overview

**Name:** PROJECT_NAME
**Type:** Cross-platform mobile SaaS
**Stack:** React Native + Expo + Node.js + TypeScript + PostgreSQL + Redis + AWS
**Status:** CURRENT_PHASE
**Repo:** https://github.com/YOUR_USERNAME/PROJECT_NAME

---

## Architecture

**Backend:** Node.js + Express + TypeScript
**Database:** PostgreSQL (AWS RDS) + Redis (cache layer)
**Queue:** Bull (background jobs)
**Mobile:** React Native + Expo + Redux Toolkit
**Infrastructure:** AWS (S3, CloudFront, ECS/Fargate, RDS)
**Payments:** RevenueCat (iOS + Android)
**Monitoring:** CloudWatch

Key files:
- ARCHITECTURE.md — full system design
- API_SPEC.yaml — OpenAPI 3.0 endpoint spec
- DATABASE_SCHEMA.sql — PostgreSQL schema
- CODE_STANDARDS.md — TypeScript and formatting rules

---

## Subscription Tiers

| Tier     | Limits         | Price        |
|----------|----------------|--------------|
| Free     | DEFINE_LIMITS  | Free         |
| Standard | DEFINE_LIMITS  | $X.XX/month  |
| Premium  | DEFINE_LIMITS  | $X.XX/month  |

CRITICAL: Tier enforcement is always server-side. Never trust the client.

---

## Coding Standards

- TypeScript strict mode everywhere — no any
- Async/await over callbacks and raw Promises
- All errors handled explicitly — no silent failures
- Server-side validation on every API endpoint
- Input sanitized before any DB write
- Secrets only via process.env — never hardcoded
- Functions under 50 lines — split if larger
- Every public function has JSDoc
- Conventional commits: feat: fix: chore: docs: refactor:

---

## Project Structure

src/
  api/          Express routes
  services/     Business logic
  models/       DB models
  middleware/   Auth, validation, rate limiting
  utils/        Shared utilities
  types/        TypeScript types
mobile/         React Native app
migrations/     DB migrations
tests/          Unit + integration tests
infrastructure/ Terraform + Docker
.claude/
  agents/       CC agent files

---

## Active Agents

Agents for this project live in .claude/agents/
Invoke with @agent-name in your prompts.

---

## Current Sprint

**Phase:** CURRENT_PHASE
**Target:** TARGET_DATE
**Focus:** CURRENT_FOCUS

Check GitHub issues for active tasks and blockers.

---

## Environment

- Dev: .env in project root (never committed)
- Secrets template: TODO_API_ENV.docx in project docs
- VM: Ubuntu, Node.js v22, PostgreSQL, Redis running locally

---

## Key Rules for CC

1. Read ARCHITECTURE.md before making structural changes
2. Check API_SPEC.yaml before adding or modifying endpoints
3. Run migrations through the migration framework — never alter tables directly
4. All tier checks server-side — no client-side gating
5. Commit and push daily — no large uncommitted diffs
6. Flag blockers immediately — do not work around them silently
