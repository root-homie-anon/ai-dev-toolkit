# CLAUDE.md — Django REST API (DRF + Celery)

## Project Overview
<!-- Describe your API here -->

## Tech Stack
- **Language:** Python 3.12+
- **Framework:** Django 5+ with Django REST Framework
- **Database:** PostgreSQL with psycopg3
- **Async Tasks:** Celery + Redis
- **Auth:** JWT via djangorestframework-simplejwt
- **Deployment:** Docker, Gunicorn + Nginx

## Architecture
- App-based Django structure (each domain = one app)
- DRF ViewSets with router-based URL config
- Celery tasks for async work (email, webhooks, processing)
- Redis for Celery broker and caching
- Custom permissions per endpoint

## Key Conventions
- Type hints everywhere — mypy must pass
- Serializer validation for all input
- `pytest-django` for all tests, 80%+ coverage
- `black` + `ruff` for formatting and linting
- Environment config via `django-environ`

## Agent Hook
```
At session start, run: bash ~/.claude/hooks/orchestrator.sh "PROJECT_NAME" "$(pwd)"
```

## Source
Template from: https://github.com/affaan-m/everything-claude-code/blob/main/examples/django-api-CLAUDE.md
