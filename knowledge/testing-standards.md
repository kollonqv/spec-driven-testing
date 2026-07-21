# Testing Standards

Rules for generating test cases from acceptance criteria. Adapted from the FDE-Cert-Project test-generation system prompt. The `test-creator-agent` follows these; reviewers check against them.

## Coverage rules

- **Target volume:** between **1.0× and 1.7×** the number of ACs in total test cases. Do not pad.
- **One positive per AC:** every AC gets exactly one positive ("happy path") test case. This is the mandatory backbone.
- **Negative tests:** add one **only** for ACs that are security-sensitive — authentication, authorization/permissions, or data validation.
- **Edge tests:** add one **only** for ACs that involve input validation or boundary conditions.
- **Skip extras** for simple navigation or read-only display ACs — a single positive is enough.

## Test case fields

Every test case must have:

| Field | Rule |
|-------|------|
| `id` | `TC-001`, `TC-002`, … zero-padded, sequential, never reused. |
| `title` | Verb-first, ≤ 80 chars. E.g. "Verify all nav items are visible". |
| `type` | `positive` \| `negative` \| `edge` \| `ui` |
| `priority` | `high` \| `medium` \| `low` (see below) |
| `tracesTo` | An AC id (`AC-1`). **Mandatory** — a test with no AC trace is invalid. |
| `preconditions` | List of setup conditions true before step 1. |
| `steps` | Ordered `{ action, expected }` pairs. |

## Priority rules

- `high` — positive tests tracing to a primary AC.
- `medium` — negative and edge tests.
- `low` — UI presence / visibility checks.

## Expected results must be observable

Every step's `expected` must be verifiable by a human tester or an automated assertion:

- **Good:** "The 'Reinvention Partners' link is underlined and its color changes to the brand accent."
- **Bad:** "The nav works correctly." / "The page looks right." / "It loads."

If you cannot state an observable expected, the step is wrong — split it or rewrite it.

## Anti-patterns (reject these)

- Vague expected results ("works", "loads", "is fine").
- Steps a human tester could not verify.
- Multiple unrelated checks crammed into one test case.
- Missing `tracesTo`.
- Restating the AC verbatim instead of a concrete, executable step.

## Worked reference

For the Reinvention Services nav story (3 ACs → 5 cases), see `examples/reinvention-services-nav/`. Note how AC-1 (a display AC) gets a positive **and** an order edge case, while AC-3 gets a positive **and** a "not underlined by default" negative to prove the hover is the cause.

See also: [test-case-schema.md](test-case-schema.md), [evaluation-rubric.md](evaluation-rubric.md).
