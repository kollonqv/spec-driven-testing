# Domain / Application Knowledge Layer

Curated **functional knowledge about the application under test** that the agents pull into context. Where `knowledge/*.md` describes *how this framework tests* (methodology), this folder describes *what the product is* — so the generated ACs, test cases, and edges are grounded in the real domain, not guessed.

## What agents use it for
- **`test-creator-agent` (design):** interpret the story's ACs in context, choose meaningful negatives/edges, use correct product terminology, and reference real test data / environments.
- **`test-script-agent` (automation):** functional context + test data (URLs, locale, accounts). **Not** for locators.

## Boundary (non-negotiable — keeps tests honest)
This layer is **functional/business only**. It must **NOT** contain:
- element selectors, `data-testid`s, CSS classes, DOM structure, element ids
- exact pixel values, computed styles, or other technical/implementation detail

Those are **discovered live** during the automation phase (see the "no cheating" principle — the automation agent investigates the real app rather than being pre-fed the answers). If you find selector/DOM detail in here, it's in the wrong place.

## Contents
| File | Holds |
|------|-------|
| `application-overview.md` | what the app is, the area under test, its parts, user goals, environment risks |
| `business-rules.md` | domain rules that govern expected behaviour (justify ACs, suggest edges/negatives) |
| `glossary.md` | product/domain terminology (distinct from the framework glossary) |
| `test-data-and-environments.md` | URLs, locales, accounts, inputs, viewport, consent handling |

## For a real project
Replace the Reinvention Services content with your product's knowledge; keep the structure and the functional-only boundary. This is where domain SMEs contribute — richer domain knowledge here directly improves the quality of generated tests.
