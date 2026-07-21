# ADR-0002: Represent a Test Scenario as an ADO Test Suite

## Status
**Superseded by [ADR-0006](0006-flat-test-cases-single-design-agent.md).** The separate scenario layer was removed for simplicity; a story's cases now live in a single Test Suite named after the story.

## Context
We introduced a "Test Scenario" layer between User Story and Test Case to group related test cases (e.g. "hover feedback"). ADO offers several ways to represent grouping: Test Suites, tags, or area paths.

## Decision
A **Test Scenario maps to a Test Suite** under a Test Plan. Test cases live inside their scenario's suite.

## Consequences
- Native ADO traceability and reporting: suites roll up pass/fail per scenario.
- Requires Azure **Test Plans** licensing (paid access level) for the live path.
- **Fallback:** when Test Plans is unavailable, represent the scenario as a `scenario:<SC-n>` tag / area path on the Test Case work items (free Basic). Documented in `knowledge/ado-mapping.md`.
- Offline mode records scenarios in `test-scenarios.md`, sidestepping licensing for demos.
