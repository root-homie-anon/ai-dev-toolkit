# CLAUDE.md — Go Microservice (gRPC + PostgreSQL)

## Project Overview
<!-- Describe your service here -->

## Tech Stack
- **Language:** Go 1.22+
- **API:** gRPC + Protocol Buffers
- **Database:** PostgreSQL with pgx driver
- **Migrations:** golang-migrate
- **Observability:** OpenTelemetry, Prometheus
- **Deployment:** Docker, Kubernetes

## Architecture
- Clean architecture: handler → service → repository
- gRPC interceptors for auth, logging, tracing
- Repository pattern for all DB access
- Context propagation throughout
- Graceful shutdown on SIGTERM

## Key Conventions
- Errors wrapped with `fmt.Errorf("context: %w", err)`
- No global state — dependency injection
- Table-driven tests for all business logic
- `golangci-lint` must pass before commit
- Structured logging with `slog`

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```

## Source
Template from: https://github.com/affaan-m/everything-claude-code/blob/main/examples/go-microservice-CLAUDE.md
