# TypeScript Standards

Source: personal standards informed by patterns from
alirezarezvani/claude-skills (MIT) https://github.com/alirezarezvani/claude-skills

---

## Core Rules

- Strict mode always: "strict": true in tsconfig
- No any — use unknown and narrow, or define a proper type
- No non-null assertions (!) unless you have a comment explaining why it is safe
- Explicit return types on all exported functions
- Prefer interface for object shapes, type for unions and aliases

---

## Naming

- PascalCase — classes, interfaces, types, enums
- camelCase — variables, functions, methods
- SCREAMING_SNAKE_CASE — constants and env var references
- kebab-case — file names
- Boolean variables: is, has, can, should prefixes

---

## Functions

- Max 50 lines per function — split if larger
- Single responsibility — one function does one thing
- Pure functions preferred — minimize side effects
- Early returns over deeply nested conditionals
- Async functions always return Promise<T> — never mix sync and async

---

## Error Handling

Good — explicit typed error:

  class ValidationError extends Error {
    constructor(public field: string, message: string) {
      super(message);
      this.name = 'ValidationError';
    }
  }

Bad — throwing strings:

  throw 'something went wrong';

Good — handle at boundaries:

  try {
    await riskyOperation();
  } catch (error) {
    if (error instanceof ValidationError) {
      return res.status(400).json({ error: error.message, field: error.field });
    }
    logger.error('Unexpected error', { error });
    return res.status(500).json({ error: 'Internal server error' });
  }

---

## Types

Good — narrow unknown properly:

  function processInput(input: unknown): string {
    if (typeof input !== 'string') {
      throw new ValidationError('input', 'Must be a string');
    }
    return input.trim();
  }

Good — discriminated unions over booleans:

  type Result<T> =
    | { success: true; data: T }
    | { success: false; error: string };

Good — const assertions for literal types:

  const TIERS = ['free', 'standard', 'premium'] as const;
  type Tier = typeof TIERS[number];

---

## Imports

- Absolute imports over relative for cross-module imports
- Group: external packages, then internal modules, then types
- No default exports from modules that export multiple things

---

## Comments

- JSDoc on all exported functions and types
- Inline comments explain why, not what
- TODO format: TODO(your-name): description — ticket #123
- No commented-out code in commits
