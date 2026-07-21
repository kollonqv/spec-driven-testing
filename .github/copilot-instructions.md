# Copilot Instructions — Playwright / TypeScript E2E Framework

This workspace is a TypeScript Playwright E2E test automation framework integrated with Azure DevOps.

---

## Project Layout

```
src/pages/          Page Object Model classes
src/tests/
  <feature>/
    US{id}_{name}.spec.ts   one file per ADO user story
playwright.config.ts
```

---

## Naming Conventions

- Spec files: `US{id}_{camelCaseStoryName}.spec.ts` — one per ADO user story, never per test case
- POM classes: `PascalCase` (e.g., `LoginPage`, `CheckoutPage`)
- Test names: `'{adoTcId} - AC{n} - <condition>'` — ADO test case work item ID first, then AC id
- Feature folders: `camelCase`, matching the ADO feature/epic name

---

## Test File Structure

Every spec file follows this exact structure:

```typescript
import { test, expect } from '@playwright/test';
import { SomePage } from '../../pages/SomePage';

// US{id} - Story title
// AC1: ...
// AC2: ...

test.describe('US{id} - Story title', () => {
  let somePage: SomePage;

  test.beforeEach(async ({ page }) => {
    somePage = new SomePage(page);
    await somePage.navigate();
  });

  test('10001 - AC1 - <brief condition>', async () => {
    // arrange
    // act
    // assert
  });

  test('10002 - AC2 - <brief condition>', async () => {
    // arrange
    // act
    // assert
  });
});
```

---

## Page Object Model Rules

- Locators are **readonly properties** declared in the constructor
- Use `getByRole`, `getByLabel`, `getByTestId` — prefer ARIA over CSS selectors
- One method per user action; methods are `async` and return `Promise<void>`
- Never put assertions inside POM classes — assertions belong in the spec

```typescript
export class LoginPage {
  readonly emailInput: Locator;
  readonly submitButton: Locator;

  constructor(readonly page: Page) {
    this.emailInput   = page.getByLabel('Email');
    this.submitButton = page.getByRole('button', { name: /sign in/i });
  }

  async navigate() { await this.page.goto('/login'); }

  async submitLogin(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.submitButton.click();
  }
}
```

---

## Playwright Best Practices

**Do:**
- Use Playwright's built-in auto-waiting — just call actions and assertions directly
- Use `expect(locator).toBeVisible()`, `.toHaveText()`, `.toBeEnabled()`, etc.
- Use `data-testid` attributes when semantic selectors are insufficient
- Set `baseURL` in `playwright.config.ts`; use relative paths in `goto()`
- Use `page.getByRole()` for interactive elements — it tests accessibility too

**Do not:**
- `page.waitForTimeout()` — signals a missing proper wait; remove it
- Raw `page.locator('div.something > span')` when a semantic selector exists
- `page.evaluate()` to assert state — use Playwright assertions instead
- Hardcode absolute URLs — always use `baseURL` + relative path
- Share `Page` instances across tests — each `test()` gets its own `page` fixture

---

## Assertions

```typescript
// Visibility
await expect(page.getByRole('heading')).toBeVisible();

// Text content
await expect(page.getByTestId('status')).toHaveText('Success');

// URL after navigation
await expect(page).toHaveURL('/dashboard');

// Count
await expect(page.getByRole('listitem')).toHaveCount(3);

// Enabled / disabled
await expect(page.getByRole('button', { name: 'Submit' })).toBeEnabled();
```

---

## ADO Traceability

Each `test()` name must start with the **ADO test case work item ID**, followed by the AC id:

```typescript
// {adoTcId} is the numeric work item ID of the ADO Test Case (e.g. 10001)
test('10001 - AC1 - user sees welcome message after login', async () => { ... });
```

This allows test results in CI to be traced directly back to ADO test cases by ID.

The `describe` block title must include the ADO user story ID:

```typescript
test.describe('US456 - User Login', () => { ... });
```

---

## Environment Variables

Never hardcode credentials or URLs. Use:

| Variable | Purpose |
|----------|---------|
| `BASE_URL` | Application under test |
| `ADO_PAT` | ADO Personal Access Token (agent skills only) |
| `ADO_ORG_URL` | ADO organization URL |
| `ADO_PROJECT` | ADO project name |

Store these in `.env` (gitignored) locally; inject via CI secrets in pipelines.

---

## What NOT to Generate

- Do not create `.spec.ts` files outside `src/tests/`
- Do not place test logic inside POM classes
- Do not generate one spec file per test case — one spec per user story
- Do not suggest `page.waitForTimeout()` as a fix for flaky tests
- Do not commit `.env` files or PAT tokens
