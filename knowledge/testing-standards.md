# Testing Standards

Rules for generating test cases from acceptance criteria. Adapted from the FDE-Cert-Project test-generation system prompt. The `test-creator-agent` follows these; reviewers check against them.

## Coverage rules

- **One positive per AC** — every AC gets exactly one positive ("happy path") case. The mandatory backbone.
- **Add a negative / control case when** either:
  - the AC is **security-sensitive** (authentication, authorization/permissions, data validation); **or**
  - the AC asserts a **state change caused by a trigger** (hover, click, focus, toggle, input) — add a *control* that verifies the **resting / pre-trigger state**, proving the trigger is what causes the change. (Without it, a test can pass even if the effect were always on — a false positive.)
- **Add an edge case when** either:
  - the AC involves **input validation or boundary conditions**; **or**
  - the AC defines an **order, count, or exact set** of elements — assert the specific ordering / count / membership, not merely presence.
- **Otherwise** (a simple static display or navigation AC with none of the above) a single positive is enough. **Don't pad.**
- **Target volume:** ~**1.0×–1.7×** the number of ACs. The heuristics above keep you in range; if you're higher, you're probably padding.

These are general heuristics — apply them from the AC's shape, not from any pre-supplied hint about a specific app.

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

- `high` — the primary positive for an AC that gates core functionality.
- `medium` — edges, control/negative cases, and positives for secondary behaviour.
- `low` — purely cosmetic checks that don't gate functionality.

Priority is a judgment call (not rubric-scored). When an AC's positive could read as either — e.g. a presence check that is also the core navigation — favour the **higher** priority for the primary behaviour and note your reasoning in the narration.

## Expected results must be observable

Every step's `expected` must be verifiable by a human tester or an automated assertion:

- **Good:** "The submit button becomes enabled and a success banner reading 'Saved' appears."
- **Bad:** "It works correctly." / "The page looks right." / "It loads."

If you cannot state an observable expected, the step is wrong — split it or rewrite it.

## Anti-patterns (reject these)

- Vague expected results ("works", "loads", "is fine").
- Steps a human tester could not verify.
- Multiple unrelated checks crammed into one test case.
- Missing `tracesTo`.
- Restating the AC verbatim instead of a concrete, executable step.

## Worked reference

For a fully worked example, see `examples/reinvention-services-nav/` — note its `test-cases.md` / `coverage-matrix.md` are generated output (git-ignored), so they may be absent on a fresh clone until an agent run regenerates them. The authoritative output **format** is defined inline in `agents/test-creator.md` (not by that folder).

See also: [test-case-schema.md](test-case-schema.md), [evaluation-rubric.md](evaluation-rubric.md).
