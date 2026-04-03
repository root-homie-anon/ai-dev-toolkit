# CLAUDE.md — SaaS Web (Next.js + Supabase + Stripe)

## Project Overview
<!-- Describe your product here -->

## Tech Stack
- **Frontend:** Next.js 14+ (App Router), TypeScript, Tailwind CSS, shadcn/ui
- **Backend:** Next.js API Routes / Server Actions
- **Database:** Supabase (PostgreSQL + Auth + Storage)
- **Payments:** Stripe (subscriptions, webhooks)
- **Deployment:** Vercel

## Architecture
- App Router with server components by default
- Client components only when needed (interactivity, hooks)
- Server Actions for mutations
- Supabase RLS for row-level security
- Stripe webhooks for subscription state sync

## Key Conventions
- TypeScript strict mode — no `any`
- Zod for all input validation
- Error boundaries on all page segments
- Loading states on all async operations
- Environment variables via `.env.local`, never hardcoded

## Agent Hook
<!-- Add to your project root CLAUDE.md after setup -->
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```

## Source
Template from: https://github.com/affaan-m/everything-claude-code/blob/main/examples/saas-nextjs-CLAUDE.md
