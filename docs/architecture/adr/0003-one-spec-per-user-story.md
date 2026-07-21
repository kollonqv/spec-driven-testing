# ADR-0003: One Playwright spec file per User Story

## Status
Accepted

## Context
Automated tests need a file organization that maps cleanly back to ADO. Options: one file per test case, one per scenario, or one per user story.

## Decision
**One spec file per user story**, named `US{id}_{camelCaseStoryName}.spec.ts`. Each `test()` block is one ADO test case and its name starts with the ADO test case ID: `'{adoTestCaseId} - AC{n} - <condition>'`.

## Consequences
- A story's tests live together and are runnable as a unit (`npx playwright test .../US{id}_*`).
- Test results trace to ADO two ways: the file name → user story, the test name → test case ID and AC.
- A sibling `US{id}_{name}.spec.md` (the automation SPEC) documents the design before the code exists (see ADR paired with the spec-driven flow).
- All of a story's test cases live in one `test.describe` block, keeping the story self-contained.
