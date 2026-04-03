---
name: tdd-workflow
description: Test-driven development enforcement — RED/GREEN/REFACTOR cycle with git checkpoints. Write tests first, verify failure, implement minimal code, verify pass, then refactor.
owner: qa
origin: ECC (trimmed)
---

# Test-Driven Development Workflow

Enforces TDD discipline: every code change starts with a failing test.

## When to Activate

- Writing new features or functionality
- Fixing bugs (write the reproducer test first)
- Refactoring existing code (tests prove behavior is preserved)
- Adding API endpoints

## The Cycle

### 1. RED — Write the failing test
Write a test that describes the expected behavior. Run it. It must fail.

This is non-negotiable. The test must:
- Compile and execute successfully (not just be written)
- Fail because the behavior doesn't exist yet — not because of syntax errors or missing imports
- Target the specific behavior being implemented

```bash
npm test  # Must fail — we haven't implemented yet
```

If using git, checkpoint: `test: add reproducer for <feature or bug>`

### 2. GREEN — Write minimal code to pass
Implement the minimum code needed to make the test pass. No more.

```bash
npm test  # Must now pass
```

If using git, checkpoint: `fix: <feature or bug>` or `feat: <feature>`

### 3. REFACTOR — Clean up while green
Improve structure, naming, duplication — while keeping tests green. Run tests after every change.

If using git, checkpoint: `refactor: clean up <feature> implementation`

### 4. VERIFY — Check coverage
```bash
npm run test:coverage  # Target: 80% minimum
```

## Test Priority Order

1. **E2E** — full user flows end to end
2. **Integration** — API routes, database operations, service connections
3. **Unit** — complex logic, pure functions, edge cases

## Git Checkpoint Rules

- Create a checkpoint commit after each TDD stage (RED, GREEN, REFACTOR)
- Don't squash checkpoint commits until the workflow is complete
- Each checkpoint must be on the current active branch
- Compact form is fine: one commit for RED, one for GREEN, one optional for REFACTOR

## Test Standards

- **Deterministic** — no flaky tests. Fix or delete.
- **Isolated** — no shared state between runs
- **Named for behavior** — `"returns 401 when token is expired"` not `"test auth"`
- **Arrange-Act-Assert** — clear structure in every test
- **Test edge cases** — null, empty, boundary, error paths
- **Clean up** — no test data left behind

## Coverage Thresholds

```json
{
  "coverageThresholds": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  }
}
```

## Anti-Patterns

- Writing tests after implementation (that's verification, not TDD)
- Testing implementation details instead of behavior
- Skipping RED — if the test passes before you implement, the test is wrong
- Testing trivial getters/setters instead of meaningful logic
- Mocking everything — test real integrations where possible
