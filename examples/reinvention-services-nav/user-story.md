# US200 — Reinvention Services: top navigation bar

> This is the framework's worked example. In **offline mode** the agents read this file in place of an ADO fetch. The `state` field drives the automation orchestrator's Closed-story gate.

```yaml
id: US200
type: User Story
title: Reinvention Services — top navigation bar
state: Closed          # ← automation is allowed only because this is Closed
areaPath: DemoProject
targetUrl: https://www.accenture.com/ca-en/about/reinvention-services
```

## Description

As a visitor to the Reinvention Services page, I want a persistent top navigation bar with links to the key sections, with clear hover feedback, so I can orient myself and move between sections easily.

## Acceptance Criteria

### AC-1 — Navigation items present
- **Given** I am on the Reinvention Services page
- **When** the page has loaded
- **Then** the top navigation bar displays these five items, in order: **Reinvention Partners, Reinvention Engines, Client Success, Industries, Client Stories**

### AC-2 — Click scrolls to the corresponding section and shows its header
- **Given** I am on the Reinvention Services page
- **When** I click any item in the top navigation bar
- **Then** the page scrolls so that item's corresponding section is shown, displaying the expected header:
  - Reinvention Partners → **Reinvention Partners**
  - Reinvention Engines → **Reinvention Engines**
  - Client Success → **Client Success**
  - Industries → **We bring deep industry expertise**
  - Client Stories → **We make reinvention real**

### AC-3 — Hover underlines
- **Given** I am on the Reinvention Services page
- **When** I hover the pointer over any top-nav item
- **Then** that item's text becomes underlined (and is **not** underlined by default)

## Notes for automation
- **AC-2 (click-to-scroll + header):** each nav item is an anchor to a section `<div id="block-…">` whose heading is an `<h2>` with the expected text. Clicking scrolls the section into view (top ~52px under the sticky sub-nav). The **URL hash does not change** (JS smooth scroll) — assert on section-in-viewport + the header text, not the URL. Section ids: `block-reinvention-partners`, `block-reinvention-engines`, `block-client-success`, `block-we-bring-deep-industry-expertise`, `block-carousel-we-make-reinvention-real`.
- **AC-3 (hover underline):** the underline is an animated `::after` bar on the label span (width 0 → text width); not `text-decoration`/`border-bottom`. Captured on the live page.
- Prefer role/text locators (`getByRole('link', { name })`) for resilience against class churn on the live site.
