---
applyTo: "src/tests/**/*.spec.ts"
---

Follow `knowledge/code-guidelines.md`. In spec files specifically:
- **No raw locators** — call POM methods + `expect(...)` only (enforced by `npm run check`).
- `describe` titled with the story; each `test()` named `'{adoTcId} - AC{n} - <condition>'`.
- Tests in **ascending TC/adoTcId order**.
- Web-first assertions only; never `page.waitForTimeout()`; use `baseURL` + relative paths.
