# Code Guidelines

Conventions for the Playwright / TypeScript automation. Agents that generate code follow these; reviewers enforce them.

## Naming

| Thing | Convention | Example |
|-------|-----------|---------|
| Spec file | `US{id}_{camelCaseStory}.spec.ts` | `US200_reinventionServicesNav.spec.ts` |
| Automation SPEC | `US{id}_{camelCaseStory}.spec.md` (beside the test) | `US200_reinventionServicesNav.spec.md` |
| POM class | `PascalCase` + `Page` | `ReinventionServicesPage` |
| Test name | `'{adoTcId} - AC{n} - <condition>'` | `'20003 - AC2 - clicking each nav item scrolls to its section'` |
| Feature folder | `camelCase` | `reinventionServices` |

## Page Object Model

- **All locators live in the POM.** Use `readonly` locator properties for fixed elements, and **methods that return `Locator`** for parameterized ones (e.g. `navLink(name: string): Locator`). Locators are never constructed in a spec.
- Prefer semantic locators: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS (last resort).
- One `async` method per user action; action methods return `Promise<void>`.
- **No assertions inside POM classes** — assertions live in the spec.

### Locators-in-POM is enforced (no raw locators in specs)

A spec file may contain only **POM method calls and `expect(...)`** — never a raw locator (`page.getBy*`, `page.locator(`, `.locator(`, `page.$`). If a spec needs an element the POM doesn't expose, add a method/getter to the POM.

```bash
npm run check:locators   # fails the build if any spec constructs a locator directly
```

```typescript
// ✗ raw locator in the spec
await expect(page.getByRole('link', { name: 'Reinvention Partners' })).toBeVisible();

// ✓ via the POM
await expect(rsp.navLink('Reinvention Partners')).toBeVisible();
```

### Tests in ascending TC order (enforced)

`test()` blocks must appear in the spec in ascending order by their leading ADO test-case id (`'20001 - …'`, then `'20002 - …'`, …) — insert each test at its correct position, never out of order (e.g. TC-003 between TC-001 and TC-002).

```bash
npm run check          # runs both: no raw locators + tests in order
npm run check:order    # just the ordering check
```

```typescript
import { Page, Locator } from '@playwright/test';

export class ReinventionServicesPage {
  readonly nav: Locator;

  constructor(readonly page: Page) {
    this.nav = page.getByRole('navigation');
  }

  async navigate() {
    await this.page.goto('/ca-en/about/reinvention-services');
  }

  navLink(name: string): Locator {
    return this.nav.getByRole('link', { name });
  }
}
```

## Playwright rules

**Do**
- Rely on auto-waiting; call actions/assertions directly.
- Use web-first assertions: `expect(locator).toBeVisible()`, `.toHaveText()`, `.toHaveCSS()`.
- Set `baseURL` in `playwright.config.ts`; use relative paths in `goto()`.
- For hover/visual state: `await locator.hover()` then assert with `toHaveCSS` on the **actual observed** property (verify during investigation — underline may be `text-decoration-line`, `border-bottom`, or a `::after` pseudo-element).

**Don't**
- `page.waitForTimeout()` / `sleep` — remove them; they mask real waits.
- Raw `.isVisible()` boolean checks in place of `expect().toBeVisible()`.
- Hardcode absolute URLs — use `baseURL` + relative path.
- Assert CSS values you guessed — capture the real value during the investigate step.

## Assertions cheat-sheet

```typescript
await expect(page.getByRole('navigation')).toBeVisible();
await expect(link).toHaveText('Reinvention Partners');
await expect(link).toHaveCSS('text-decoration-line', 'underline');   // after hover()
await expect(page).toHaveURL(/reinvention-services/);
await expect(nav.getByRole('link')).toHaveCount(5);
```

## Traceability in code

Every `test()` name begins with the ADO test case ID so CI results link back to ADO. The `describe` title carries the user story ID. A header comment lists the ACs.

See also: `knowledge/testing-standards.md`, `CLAUDE.md`.
