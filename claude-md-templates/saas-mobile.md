# CLAUDE.md — SaaS Mobile (React Native + Node.js + AWS)

## Project Overview
<!-- Describe your product here -->

## Tech Stack
- **Mobile:** React Native + Expo, TypeScript
- **State:** Redux Toolkit + RTK Query
- **Backend:** Node.js + Express
- **Database:** PostgreSQL + Redis
- **Infrastructure:** AWS (ECS, RDS, ElastiCache, S3, CloudFront)
- **Auth:** JWT + refresh tokens
- **Payments:** RevenueCat (subscriptions)

## Architecture
- Feature-based folder structure (not layer-based)
- RTK Query for all server state — no manual fetch calls
- Redux for global UI state only
- Expo managed workflow — no bare ejection unless required
- Backend: controllers → services → repositories

## Key Conventions
- TypeScript strict mode — no `any`
- All API calls through RTK Query endpoints
- Expo SecureStore for sensitive data (never AsyncStorage for tokens)
- Error boundaries on all screens
- Environment config via `expo-constants` + EAS secrets

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```
