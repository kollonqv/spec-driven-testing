# Automation SPEC — US200 Reinvention Services top navigation bar

> Spec-driven automation artifact produced by the `test-script-agent` **before** any test code. Written after live investigation of the target page. This is the review gate: the `.spec.ts` implements exactly what is agreed here.

- **Story:** US200 — Reinvention Services top navigation bar (state: Closed)
- **Target:** https://www.accenture.com/ca-en/about/reinvention-services
- **Spec file:** `src/tests/reinventionServices/US200_reinventionServicesNav.spec.ts`
- **POM:** `src/pages/ReinventionServicesPage.ts`

## 1. Objective
Automate the reviewed test cases for the Reinvention Services sub-navigation bar, tracing each test to an acceptance criterion, running against the live page.

## 2. Test cases in scope

| TC | ADO ID | AC | Intent | Outcome |
|----|--------|----|--------|---------|
| TC-001 | 20001 | AC-1 | Five items present & visible | pass |
| TC-002 | 20002 | AC-1 | Items in expected order | pass |
| TC-003 | 20003 | AC-2 | Click each item → scrolls to its section, shows its header | pass |
| TC-004 | 20004 | AC-3 | Hover underlines text | pass |
| TC-005 | 20005 | AC-3 | Not underlined at rest | pass |

## 3. Page Object design
`ReinventionServicesPage`:
- `nav` — the navigation landmark containing the sub-nav (filtered to contain "Reinvention Partners"; unique on the page).
- `navigate()` — goto relative path, dismiss consent if present, wait for nav.
- `navLink(name)` — accessible link, used to hover/click.
- `clickItem(name)` — clicks the item (scrolls to its section).
- `section(name)` / `sectionHeading(name)` — the target section and its expected `<h2>` header (AC-2).
- `itemLabel(name)` / `itemLabels()` — the visible `span.rad-subnav-bar__link-text` (carries the underline).
- `underlineWidthPx(name)` — reads `::after` width (the underline mechanism).

## 4. Discovered selectors & behaviour (live investigation)
- **Nav structure:** in-page sub-nav `div.rad-subnav > div.rad-subnav-bar > … > nav.rad-subnav-bar__links`. `getByRole('navigation')` filtered by the first item resolves to exactly **1** landmark with **5** links, texts in order: Reinvention Partners, Reinvention Engines, Client Success, Industries, Client Stories.
- **Item DOM:** `a.subnav-bar__link--anchor` (href `#block-…`) wrapping `span.rad-subnav-bar__link-text` (the visible label).
- **Click-to-scroll + header (AC-2):** each item's href points to a section `<div id="block-…">` whose heading is an `<h2>` with the expected text. Clicking scrolls that section into view (top ≈ 52px under the sticky sub-nav). The **URL hash does not change** (JS smooth scroll) — assert on section-in-viewport + header text, not URL. Item → section id → header:
  - Reinvention Partners → `block-reinvention-partners` → "Reinvention Partners"
  - Reinvention Engines → `block-reinvention-engines` → "Reinvention Engines"
  - Client Success → `block-client-success` → "Client Success"
  - Industries → `block-we-bring-deep-industry-expertise` → "We bring deep industry expertise"
  - Client Stories → `block-carousel-we-make-reinvention-real` → "We make reinvention real"
  - Note: the section container reliably snaps to the top; the `<h2>` sits below the section's hero content, so the assertion targets **section-in-viewport + header visible/text** rather than the header's exact pixel position (which varies with viewport/lazy-load).
- **Underline mechanism (AC-3):** an animated `::after` bar on the label span. At rest `width = 0px`; on hover `width → ~137px` (full text width). It is **not** `text-decoration` and **not** `border-bottom`.
- **Consent:** no OneTrust banner appeared on `ca-en` in a clean headless context; `dismissConsentIfPresent()` is a safe no-op guard.

## 5. Step → Playwright mapping
- Presence/visibility → `expect(itemLabel(name)).toBeVisible()`; count via `toHaveCount(5)`.
- Order → `expect(itemLabels()).toHaveText([...NAV_ITEMS])`.
- Click-to-scroll + header → for each item: `clickItem(name)` then `expect(section(name)).toBeInViewport()` and `expect(sectionHeading(name)).toBeVisible()` + `.toHaveText(header)`. No URL assertion (hash unchanged).
- Hover underline → `navLink(name).hover()` then `expect.poll(() => underlineWidthPx(name)).toBeGreaterThan(0)`; rest state asserts `=== 0`.

## 6. Success criteria
- `npx playwright test src/tests/reinventionServices/` exits 0 — **all 5 pass** against the live page.
- Every `test()` name carries its ADO test case ID and AC.

## 7. Risks
- **Live-site drift:** class/section ids (`rad-subnav-bar__link-text`, `block-…`) and the ::after mechanism may change; role/text locators reduce but don't eliminate this.
- **Scroll/layout variance:** the section's snapped top varies (≈52–365px seen across runs due to sticky offset + lazy-loaded hero content), and the `<h2>` can fall below the first fold on a slow load. The assertion therefore checks **section-in-viewport + header visible/text** (robust) rather than the header's exact pixel position. A single local retry (`retries: 1`) absorbs the occasional bad live-site load.
- **Geo/consent variance:** a consent banner may appear in other regions/sessions; guarded by `dismissConsentIfPresent()`.
- Underline width is viewport-dependent; assertions test `> 0` vs `0`, not an absolute width.
