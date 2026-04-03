# CLAUDE.md — API Only (Pure Backend Service)

## Project Overview
<!-- Describe your service here -->

## Tech Stack
- **Runtime:** Node.js + TypeScript
- **Framework:** Express or Fastify
- **Database:** PostgreSQL + Redis
- **Queue:** Bull (Redis-backed)
- **Auth:** JWT (stateless)
- **Deployment:** Docker + AWS ECS

## Architecture
- controllers → services → repositories
- No business logic in controllers
- Repository pattern for all DB access
- Queue for async/long-running work
- Health check endpoint at `/health`

## Key Conventions
- TypeScript strict mode — no `any`
- Zod for all request validation
- All errors follow `{ error: string, code: string }` shape
- Structured JSON logging (no console.log)
- Environment config via `dotenv` + validation on startup — fail fast if missing

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```
