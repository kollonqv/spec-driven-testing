---
applyTo: "src/tests/**/*.spec.ts"
---

# Playwright Test File Conventions

## File naming
One spec file per ADO user story: `US{id}_{camelCaseStoryName}.spec.ts`

## Required structure
```typescript
import { test, expect } from '@playwright/test';
import { SomePage } from '../../pages/SomePage';

// US{id} - Story title
// AC-1: ...

test.describe('US{id} - Story title', () => {
  let somePage: SomePage;

  test.beforeEach(async ({ page }) => {
    somePage = new SomePage(page);
    await somePage.navigate();
  });

  test('{adoTcId} - AC1 - <condition>', async () => { ... });
});
```

## Test naming
Every `test()` name must start with the ADO test case work item ID, then the AC id:
`'{adoTcId} - AC{n} - <brief condition>'`

Example: `'10001 - AC1 - user is redirected to dashboard after valid login'`

The `{adoTcId}` is the numeric work item ID of the ADO Test Case (not the user story ID).

## Assertions
- Use `expect(locator).toBeVisible()` — never `.isVisible()` in a raw boolean check
- Use `expect(page).toHaveURL(...)` for navigation assertions
- Use `expect(locator).toHaveText(...)` for text content

## Hard rules
- No `page.waitForTimeout()` — Playwright auto-waits
- No assertions inside Page Object classes — keep them in the spec
- No hardcoded absolute URLs — use relative paths; `baseURL` is set in `playwright.config.ts`
- Import POM classes from `../../pages/`, never duplicate locator logic inline
