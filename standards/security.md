# Security Standards

Applied on every PR and before every release.

---

## Always

- No secrets, API keys, or credentials in source code
- All secrets via process.env — documented in .env.example
- .env in .gitignore — verified before first push
- All user inputs validated and sanitized before use
- SQL queries use parameterized statements — no string interpolation
- Auth middleware on all protected routes
- Error messages do not expose internal details to clients

---

## Authentication

- JWT secrets are strong (64+ chars, generated with openssl rand -base64 64)
- Access tokens short-lived (15 min)
- Refresh tokens rotated on use
- Passwords hashed with bcrypt (12+ rounds)
- Rate limiting on auth endpoints
- Account lockout after N failed attempts

---

## API

- Rate limiting per tier on all endpoints
- Request size limits enforced
- CORS configured explicitly — no wildcard in production
- HTTPS only in production
- Security headers set (helmet.js or equivalent)

---

## Dependencies

- npm audit run — no high or critical vulnerabilities unaddressed
- Dependencies pinned or range-locked in package.json
- No unused dependencies

---

## Tier Enforcement (SaaS)

- All subscription tier checks are server-side
- Daily usage counters reset correctly at midnight
- Premium features cannot be accessed by downgrading client
- RevenueCat webhook validated before processing

---

## Before Production Deploy

- All environment variables set in production
- Database backups verified
- Rollback plan documented
- Error monitoring active (CloudWatch or equivalent)
