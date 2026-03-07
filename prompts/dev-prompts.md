# Prompt Library

Reusable prompts for recurring tasks. Copy, fill in the brackets, paste into CC.

---

## Architecture Review

Review the current architecture in ARCHITECTURE.md against what is actually implemented.
Identify:
1. Any deviations from the planned design
2. Technical debt introduced so far
3. Top 3 scalability risks at [TARGET_USER_COUNT] users
4. Anything that will become a problem before launch

Be direct — flag real issues, not theoretical ones.

---

## Feature Spec

Write a technical spec for: [FEATURE_NAME]

Include:
- What it does (user-facing)
- Data model changes needed
- API endpoints required (method, path, request, response)
- Business logic and edge cases
- Tier restrictions (free/standard/premium)
- Acceptance criteria

Keep it tight — this is for implementation, not a pitch deck.

---

## Bug Analysis

Diagnose this bug: [DESCRIBE THE BUG]

Error output:
[PASTE ERROR]

Relevant code:
[PASTE CODE OR FILE PATH]

Find the root cause, not just the symptom. Then give me the fix.

---

## PR Description

Write a PR description for these changes:
[PASTE git diff --stat or summary of changes]

Format:
## What
[what changed]

## Why
[why it was needed]

## How
[brief technical approach]

## Testing
[how to verify it works]

---

## Endpoint Implementation

Implement the [METHOD] [/path] endpoint from API_SPEC.yaml.

Requirements:
- Follow the request/response schema exactly as specified
- Add input validation (Zod)
- Add auth middleware if required
- Implement the service layer logic
- Handle errors with the project custom error types
- Add JSDoc

Check existing endpoints in src/api/routes/ for patterns to follow.

---

## Database Query Optimization

Optimize this query: [PASTE QUERY]

Current execution context: [tables involved, approximate row counts]

I need:
1. Analysis of what is slow
2. Index recommendations
3. Rewritten query if needed
4. Migration to add the indexes

---

## Test Suite

Write tests for: [FILE OR FUNCTION]

Coverage needed:
- Happy path
- Edge cases: [LIST ANY SPECIFIC ONES]
- Error cases
- Auth/tier boundary cases (if applicable)

Use the existing test patterns in tests/ — match the style exactly.

---

## Sprint Standup

Generate a dev standup for today based on:
- Recent commits: run git log --oneline -5
- Open issues: [paste or reference]
- Current phase: [phase name and target]

Format:
Yesterday: [what was completed]
Today: [what is being worked on]
Blockers: [anything blocking, or none]

---

## Refactor Plan

Plan a refactor for: [FILE OR MODULE]

Current problems:
[describe what is wrong — too long, mixed concerns, hard to test, etc.]

Constraints:
- Cannot break existing API contracts
- Must keep tests passing
- Should be done in [N] commits max

Give me a step-by-step plan before touching any code.
