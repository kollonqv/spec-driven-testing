# Glossary

Shared vocabulary for the spec-driven testing framework. Agents and humans use these terms with exactly these meanings.

| Term | Definition |
|------|------------|
| **Requirement** | A business need, upstream of any story. Lives in ADO as an Epic/Feature or a requirements doc. Out of scope for the agents (we start at User Stories). |
| **User Story (US)** | A unit of deliverable value with acceptance criteria. ADO work item type `User Story`. The entry point of this framework. |
| **Acceptance Criterion (AC)** | A single, testable condition on a user story, ideally Given/When/Then. Stable ID: `AC-1`, `AC-2`, … Everything downstream traces back to an AC. |
| **Test Case (TC)** | An end-to-end verification with a title, preconditions, and ordered steps. ADO work item type `Test Case`. Stable ID: `TC-001`, … plus an ADO work-item ID once created. Traces to an AC. |
| **Test Step** | One `{ action, expected }` pair inside a test case. Every step has an observable expected result. |
| **Test Suite** | An ADO container that holds a story's test cases (one suite per story) and rolls up their pass/fail. |
| **Traceability** | The unbroken chain Requirement → US → AC → Test Case → Test Step → Automated test. The `tracesTo` field carries the AC id on each test case. |
| **Automation** | The Playwright TypeScript implementation of a test case, named `US{id}_{name}.spec.ts` with each `test()` prefixed by the ADO test case ID. |
| **Coverage Matrix** | A table mapping each AC to the test cases that cover it. Empty rows flag gaps. |
| **Offline mode** | Agents read the story/cases from local `examples/` artifacts and write outputs locally. No ADO calls. Default for demos. |
| **Live mode** | Agents read/write the real ADO org via the `ado-skill` (requires `ADO_PAT`). |
| **Design phase** | In-sprint: US + ACs → Test Cases into ADO. Human-driven, collaborative. |
| **Automation phase** | Sprint + N: automate the test cases of a **Closed** story. Orchestrated. |

See also: [pipeline.md](pipeline.md), [test-case-schema.md](test-case-schema.md), [ado-mapping.md](ado-mapping.md).
