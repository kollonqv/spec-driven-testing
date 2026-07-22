# ADR-0008: Domain knowledge layer (functional-only)

## Status
Accepted

## Context
The knowledge layer originally held only **methodology** knowledge (how we test — standards, schema, rubric, ADO mapping). The agents had no curated knowledge of the **application/domain** under test, so generated ACs and test cases couldn't be grounded in product reality (business rules, terminology, test data). Separately, ADR/agent rules forbid pre-feeding the automation agent with selectors ("no cheating" — selectors are discovered live).

## Decision
Add **`knowledge/domain/`** — curated *functional/business* knowledge about the app under test:
`application-overview.md`, `business-rules.md`, `glossary.md`, `test-data-and-environments.md`.

**Boundary (non-negotiable):** functional/business content only — **no selectors, DOM, CSS, element ids, or pixel/computed values.** Those are discovered live during the automation phase.

- `test-creator-agent` (design) reads it to interpret ACs in context and design better cases; a business rule can justify an additional edge or negative.
- `test-script-agent` (automation) reads it for **test data / environment only**; selectors still come from live investigation.

## Consequences
- Test design is grounded in the product, not guessed — richer negatives/edges, correct terminology.
- Clear SME contribution point: domain experts enrich `knowledge/domain/` to raise generated-test quality.
- The functional-only boundary preserves the honest-investigation principle (ADR-0007) — domain knowledge can't smuggle in the technical answers.
- The knowledge layer now has two parts: **methodology** (how we test) and **domain** (what the app is).
