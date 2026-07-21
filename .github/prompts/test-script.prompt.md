---
mode: agent
description: Generate Playwright TypeScript spec files from ADO test cases. Provide a user story ID and target app URL — Copilot generates the POM class and spec file following project conventions, one test case at a time.
---

# Test-Script — GitHub Copilot

This prompt guides you through converting ADO test cases into a production-quality Playwright spec file.

## What you need to provide

1. **User story ID** (e.g. `123`) or paste the test cases directly
2. **Target application URL** (or confirm `BASE_URL` env var)
3. *(Optional)* The HTML/DOM of relevant pages if you want accurate selectors

---

## Step 1 — Gather Test Cases

Either:
- Fetch from ADO: use `#ado-skill` → "Get all test cases for user story 123"
- Paste them directly with their steps

Copilot will list all test cases and confirm before proceeding:
```
US123: Story title
  TC-001: Verify login succeeds (AC-1, positive)
  TC-002: Reject invalid password (AC-1, negative)
```

---

## Step 2 — Identify Selectors

For accurate locators, open the application in your browser and paste relevant HTML snippets here, or describe the page elements. Copilot will choose the best selector strategy:

| Priority | Selector type | When to use |
|----------|--------------|-------------|
| 1st | `getByTestId('...')` | `data-testid` attribute present |
| 2nd | `getByRole('button', { name: '...' })` | interactive elements |
| 3rd | `getByLabel('...')` | form inputs |
| 4th | `getByText('...')` | static text |
| Last | CSS/XPath | only if nothing else works — add `// TODO: verify selector` |

---

## Step 3 — Generate the POM Class

Copilot generates a POM class for any new page, following project conventions:

```typescript
// src/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly submitButton: Locator;

  constructor(readonly page: Page) {
    this.emailInput   = page.getByLabel('Email');
    this.submitButton = page.getByRole('button', { name: /sign in/i });
  }

  async navigate() { await this.page.goto('/login'); }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.submitButton.click();
  }
}
```

Rules:
- Locators are `readonly` constructor properties
- Methods are `async` — one method per user action
- No assertions inside POM classes

---

## Step 4 — Generate Test Cases One by One

Ask Copilot to generate one test at a time:

> "Generate TC-001 (ADO TC ID 10001)"

Copilot produces the `test()` block with the ADO TC ID as the first token in the test name:
```typescript
test('10001 - AC-1 - <condition>', async () => { ... });
```

Review it, then ask for the next:

> "Looks good. Generate TC-002 (ADO TC ID 10002)."

**ADO step → Playwright mapping:**

| ADO step action | Playwright code |
|----------------|----------------|
| Navigate to {url} | `await page.goto('{url}')` |
| Click {element} | `await locator.click()` |
| Fill {field} with {value} | `await locator.fill('{value}')` |
| Verify {element} is visible | `await expect(locator).toBeVisible()` |
| Verify {element} shows {text} | `await expect(locator).toHaveText('{text}')` |
| Verify URL is {path} | `await expect(page).toHaveURL('{path}')` |

**Never generated:**
- `page.waitForTimeout()` — Playwright auto-waits; remove any that appear
- Raw `.isVisible()` in assertions — always use `expect(locator).toBeVisible()`

---

## Step 5 — Assembled Spec File

Once all test cases are confirmed, ask Copilot to assemble the full file:

> "Assemble the complete spec file for US123"

Output file path:
```
src/tests/{featureName}/US123_{storyNameCamelCase}.spec.ts
```

Structure:
```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/LoginPage';

// US123 - Story title
// AC-1: ...
// AC-2: ...

test.describe('US123 - Story title', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.navigate();
  });

  // {adoTcId} = ADO work item ID of the Test Case (e.g. 10001)
  test('10001 - AC-1 - user is redirected to dashboard after valid login', async () => {
    await loginPage.login('user@example.com', 'ValidPass1!');
    await expect(page).toHaveURL('/dashboard');
  });

  test('10002 - AC-1 - invalid password shows error message', async () => {
    await loginPage.login('user@example.com', 'wrong');
    await expect(loginPage.errorMessage).toBeVisible();
    await expect(loginPage.errorMessage).toHaveText('Invalid credentials');
  });
});
```

---

## Verify

After saving the file, run:

```bash
npx playwright test src/tests/{featureName}/US123_{name}.spec.ts --headed
```

Paste any errors back here and Copilot will help diagnose selector or assertion issues.
