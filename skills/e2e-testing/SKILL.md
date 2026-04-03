---
name: e2e-testing
description: Playwright E2E testing patterns — Page Object Model, configuration, CI/CD integration, artifact management, and flaky test strategies.
owner: qa
origin: ECC (trimmed)
---

# E2E Testing Patterns

Comprehensive Playwright patterns for stable, fast, maintainable E2E test suites.

## Test File Organization

```
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   └── register.spec.ts
│   ├── features/
│   │   ├── search.spec.ts
│   │   └── create.spec.ts
│   └── api/
│       └── endpoints.spec.ts
├── fixtures/
│   ├── auth.ts
│   └── data.ts
├── pages/
│   ├── ItemsPage.ts
│   └── LoginPage.ts
└── playwright.config.ts
```

## Page Object Model

```typescript
import { Page, Locator } from '@playwright/test'

export class ItemsPage {
  readonly page: Page
  readonly searchInput: Locator
  readonly itemCards: Locator

  constructor(page: Page) {
    this.page = page
    this.searchInput = page.locator('[data-testid="search-input"]')
    this.itemCards = page.locator('[data-testid="item-card"]')
  }

  async goto() {
    await this.page.goto('/items')
    await this.page.waitForLoadState('networkidle')
  }

  async search(query: string) {
    await this.searchInput.fill(query)
    await this.page.waitForResponse(resp => resp.url().includes('/api/search'))
  }

  async getItemCount() {
    return await this.itemCards.count()
  }
}
```

## Configuration

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'playwright-results.json' }]
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
})
```

## Flaky Test Patterns

### Common Causes and Fixes

**Race conditions:**
```typescript
// Bad: assumes element is ready
await page.click('[data-testid="button"]')

// Good: auto-wait locator
await page.locator('[data-testid="button"]').click()
```

**Network timing:**
```typescript
// Bad: arbitrary timeout
await page.waitForTimeout(5000)

// Good: wait for specific condition
await page.waitForResponse(resp => resp.url().includes('/api/data'))
```

**Animation timing:**
```typescript
// Good: wait for stability before interacting
await page.locator('[data-testid="menu"]').waitFor({ state: 'visible' })
await page.waitForLoadState('networkidle')
await page.locator('[data-testid="menu"]').click()
```

### Quarantine
```typescript
test('known flaky test', async ({ page }) => {
  test.fixme(true, 'Flaky — tracking in Issue #123')
})
```

### Identify Flakiness
```bash
npx playwright test tests/search.spec.ts --repeat-each=10
```

## Selector Strategy

Prefer resilient selectors in this order:
1. `[data-testid="..."]` — explicit test hooks
2. `role` selectors — `page.getByRole('button', { name: 'Submit' })`
3. `text` selectors — `page.getByText('Submit')`
4. Never use CSS class selectors — they break on style changes

## Artifact Management

```typescript
// Screenshots
await page.screenshot({ path: 'artifacts/after-login.png' })
await page.locator('[data-testid="chart"]').screenshot({ path: 'artifacts/chart.png' })

// Config-level (playwright.config.ts)
use: {
  video: 'retain-on-failure',
  trace: 'on-first-retry',
  screenshot: 'only-on-failure',
}
```

## CI/CD Integration

```yaml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## Test Standards

- Every critical user flow has at least one E2E test
- Auth flows always covered (login, logout, token expiry, unauthorized)
- Every form with external submission covered
- Tests are independent — no shared state between runs
- Tests clean up after themselves
- No `waitForTimeout` — always wait for a specific condition
