# Application Overview — Accenture Reinvention Services

> Functional knowledge only. No selectors/DOM (discovered live). See this folder's README for the boundary.

## The application
Accenture's public corporate website (`accenture.com`), Canada/English locale (`ca-en`). Marketing/content site — no authentication for the area in scope.

## Area under test
The **Reinvention Services** page (`/ca-en/about/reinvention-services`) — presents Accenture's reinvention offerings and success stories.

## Key parts (functional)
- **Top section sub-navigation ("sub-nav"):** a persistent in-page navigation bar linking to the page's major sections.
- **Sections:** the content blocks the sub-nav links to, each introduced by a heading.
- **Hero/banner:** the page's opening headline area (not in current test scope).

## The five sections (functional content)
| Sub-nav item | Section heading shown |
|--------------|----------------------|
| Reinvention Partners | Reinvention Partners |
| Reinvention Engines | Reinvention Engines |
| Client Success | Client Success |
| Industries | We bring deep industry expertise |
| Client Stories | We make reinvention real |

## Primary user goals
- Orient within a long page; jump straight to a section of interest.
- Understand the offerings and see proof (client stories).

## Environment risks to be aware of (behavioural, not technical)
- **Heavy page:** many assets and lazy-loaded content → slower loads and occasional flakiness; allow generous timeouts.
- **Locale/region variance:** content and behaviour can differ by locale (`ca-en`) and region.
- **Consent banner:** a cookie/consent prompt may appear depending on region/session; expect to dismiss it.
