---
applyTo: "src/pages/**/*.ts"
---

Follow `knowledge/code-guidelines.md`. In Page Objects specifically:
- **All locators live here** — `readonly` properties for fixed elements, methods returning `Locator` for parameterized ones.
- Prefer semantic locators: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS (last resort).
- One `async` method per user action; **no assertions inside the POM** (assertions belong in the spec).
