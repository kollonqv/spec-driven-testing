# Test Data & Environments — Reinvention Services

> What the agents need to run against the app. No credentials/secrets in the repo.

## Environment
| Item | Value |
|------|-------|
| Base URL | `https://www.accenture.com` (override with `BASE_URL`) |
| Page path | `/ca-en/about/reinvention-services` |
| Locale / region | `ca-en` (Canada / English) — content & behaviour can vary by locale |
| Viewport | 1920×1080 (see `playwright.config.ts`) |

## Authentication
None — the page is public. No login, no accounts.

## Test data / inputs
None — this is a read-only navigation/content page. No forms, no data entry in scope.

## Consent / interstitials
A cookie/consent banner may appear depending on region/session. The Page Object dismisses it if present; expect it to be a no-op when absent.

## Notes
- Because the target is a **live public site**, expect occasional slow loads; the config allows generous timeouts.
- Secrets (e.g. `ADO_PAT` for live ADO) come from environment variables, never this file — see `knowledge/ado-mapping.md`.
