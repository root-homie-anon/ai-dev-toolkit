# Git Commit Standards

Conventional Commits format — enforced across all projects.

---

## Format

type(scope): short description

[optional body]

[optional footer]

---

## Types

| Type       | When to Use                                          |
|------------|------------------------------------------------------|
| feat       | New feature or capability                            |
| fix        | Bug fix                                              |
| chore      | Maintenance, dependency updates, tooling             |
| docs       | Documentation only                                   |
| refactor   | Code change that neither fixes a bug nor adds a feature |
| test       | Adding or updating tests                             |
| perf       | Performance improvement                              |
| ci         | CI/CD pipeline changes                               |
| revert     | Reverting a previous commit                          |

---

## Rules

- Subject line max 72 characters
- Use imperative mood: "add feature" not "added feature"
- No period at end of subject line
- Scope is optional but recommended for larger projects
- Breaking changes: add ! after type or BREAKING CHANGE: in footer

---

## Examples

feat(auth): add JWT refresh token rotation
fix(generation): handle FFmpeg timeout on long audio files
chore(deps): update axios to 1.6.0
docs(api): add examples to generate endpoint
refactor(cache): extract Redis TTL logic into constants
test(auth): add coverage for token expiry edge cases
feat!: redesign subscription tier enforcement (breaking)

---

## Branch Naming

feature/short-description
fix/issue-description
chore/what-youre-doing
release/v1.2.0
