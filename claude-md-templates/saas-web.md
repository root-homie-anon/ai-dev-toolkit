# CLAUDE.md — SaaS Web (React/Next.js + Node.js + AWS)

## Project Overview
<!-- Describe your product here -->

## Tech Stack
- **Frontend:** React + Next.js (Pages Router), TypeScript, Tailwind CSS
- **Backend:** Node.js + Express API
- **Database:** PostgreSQL + Redis
- **Infrastructure:** AWS (ECS, RDS, ElastiCache, S3, CloudFront)
- **Auth:** NextAuth.js
- **Payments:** Stripe (subscriptions + webhooks)

## Architecture
- Next.js frontend consuming Express REST API
- Feature-based folder structure
- React Query for all server state
- Redis for session cache and rate limiting
- S3 + CloudFront for static assets

## Key Conventions
- TypeScript strict mode — no `any`
- Zod for all API input validation
- All secrets via AWS Secrets Manager — never hardcoded
- React Query for data fetching — no raw useEffect fetches
- Conventional commits enforced via commitlint

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```
