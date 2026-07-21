---
applyTo: "src/pages/**/*.ts"
---

# Page Object Model Conventions

## Class structure
```typescript
import { Page, Locator } from '@playwright/test';

export class MyPage {
  readonly someLocator: Locator;    // readonly, declared in constructor

  constructor(readonly page: Page) {
    this.someLocator = page.getByRole('button', { name: /submit/i });
  }

  async navigate() { await this.page.goto('/my-path'); }

  async doAction(value: string) {   // one method per user action
    await this.someLocator.fill(value);
  }
}
```

## Locator selection priority
1. `page.getByTestId('...')` — most stable; use `data-testid` attributes
2. `page.getByRole('button', { name: '...' })` — interactive elements
3. `page.getByLabel('...')` — form inputs
4. `page.getByText('...')` — text content
5. CSS selector — only as last resort

## Hard rules
- All locators are `readonly` and set in the constructor — never create locators in methods
- Methods are `async` and return `Promise<void>`
- No `expect()` assertions inside POM files — assertions belong in spec files
- No `waitForTimeout` — Playwright auto-waits on all action methods
