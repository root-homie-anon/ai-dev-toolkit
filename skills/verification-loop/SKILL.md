---
name: verification-loop
description: Pre-PR verification system — build, types, lint, tests, security scan, diff review. Run after completing features or before creating PRs. Produces a structured pass/fail report.
owner: sr-dev
origin: ECC (rewritten)
---

# Verification Loop

Comprehensive verification system that runs after feature completion and before PRs. Catches issues before they leave your machine.

## When to Run

- After completing a feature or significant code change
- Before creating a PR
- After refactoring
- Every 30 minutes during long implementation sessions

## Verification Phases

Run all phases in order. Stop on critical failures.

### Phase 1: Build
```bash
npm run build 2>&1 | tail -20
```
If build fails, **STOP**. Nothing else matters until the build is green.

### Phase 2: Type Check
```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -30

# Python
pyright . 2>&1 | head -30
```
Report all type errors. Fix critical ones (any, missing types, wrong shapes) before continuing.

### Phase 3: Lint
```bash
# JavaScript/TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30
```
Auto-fix what's safe (`--fix`). Report remaining issues.

### Phase 4: Test Suite
```bash
npm run test -- --coverage 2>&1 | tail -50
```
Report: total, passed, failed, coverage percentage. Target: 80% minimum.

If tests fail, categorize:
- **New failures from this change** — must fix before PR
- **Pre-existing failures** — note but don't block
- **Flaky tests** — flag for QA

### Phase 5: Security Scan
```bash
# Secrets in code
grep -rn "sk-\|api_key\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" src/ 2>/dev/null

# .env in gitignore
grep -q "\.env" .gitignore && echo "PASS" || echo "FAIL: .env not in .gitignore"

# Console.log in production code
grep -rn "console\.log" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | grep -v "// debug" | head -10
```

### Phase 6: Diff Review
```bash
git diff --stat
git diff HEAD~1 --name-only
```
Review each changed file for:
- Unintended changes (files you didn't mean to touch)
- Missing error handling on new code paths
- Hardcoded values that belong in config or .env
- TODO/FIXME comments that should be resolved before PR

## Report Format

```
VERIFICATION REPORT
==================
Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings, Y auto-fixed)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      X files changed, Y insertions, Z deletions

Overall:   [READY/NOT READY] for PR

Blockers:
1. [critical issue that must be fixed]

Warnings:
1. [non-blocking issue worth noting]
```

## Gate Rules

**PR-ready** requires ALL of:
- Build passes
- No new type errors
- No new lint errors (warnings acceptable)
- All new tests pass
- No secrets in code
- .env in .gitignore
- Coverage >= 80% on changed files

**NOT PR-ready** if ANY of:
- Build fails
- New type errors introduced
- Tests fail on code you changed
- Secrets detected in source
- Coverage dropped below threshold

## Integration

- **sr-dev** runs this before handoff to QA
- **qa** can run this as a pre-check before deeper testing
- **code-reviewer** references the report during review
- **devops** can wire this into a pre-commit hook
