# CLAUDE.md — Laravel API (PostgreSQL + Redis)

## Project Overview
<!-- Describe your API here -->

## Tech Stack
- **Language:** PHP 8.3+
- **Framework:** Laravel 11+
- **Database:** PostgreSQL with Eloquent ORM
- **Cache/Queue:** Redis
- **Auth:** Laravel Sanctum (API tokens)
- **Deployment:** Docker, Laravel Octane

## Architecture
- Service layer between controllers and models
- Repository pattern for complex queries
- Form Requests for input validation
- API Resources for response shaping
- Queued jobs for async processing

## Key Conventions
- Strict types declaration in all files
- PHPStan level 8 must pass
- `php-cs-fixer` for formatting
- Feature tests for all endpoints
- Never use `DB::statement` raw queries

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```

## Source
Template from: https://github.com/affaan-m/everything-claude-code/blob/main/examples/laravel-api-CLAUDE.md
