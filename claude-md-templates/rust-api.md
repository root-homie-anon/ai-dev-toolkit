# CLAUDE.md — Rust API (Axum + SQLx + PostgreSQL)

## Project Overview
<!-- Describe your API here -->

## Tech Stack
- **Language:** Rust (stable)
- **Framework:** Axum
- **Database:** PostgreSQL with SQLx (compile-time checked queries)
- **Async Runtime:** Tokio
- **Auth:** JWT with `jsonwebtoken`
- **Deployment:** Docker (scratch image)

## Architecture
- Router → Handler → Service → Repository layers
- Axum extractors for auth, validation, state
- SQLx migrations for schema management
- `thiserror` for typed error enums
- Tower middleware for logging, tracing, CORS

## Key Conventions
- No `unwrap()` or `expect()` in production paths
- All errors implement `std::error::Error`
- `clippy` must pass with no warnings
- Integration tests against real PostgreSQL
- `sqlx::query!` macros for compile-time query validation

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```

## Source
Template from: https://github.com/affaan-m/everything-claude-code/blob/main/examples/rust-api-CLAUDE.md
