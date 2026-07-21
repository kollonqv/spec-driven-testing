# Coverage Matrix — US200

Output of the `test-creator-agent` review step, scored against `knowledge/evaluation-rubric.md`.

## AC → Test case coverage

| AC | Description | Covered by | Status |
|----|-------------|-----------|--------|
| AC-1 | Nav items present (and in order) | TC-001 (positive), TC-002 (edge) | ✅ covered |
| AC-2 | Click scrolls to section & shows its header | TC-003 (positive) | ✅ covered |
| AC-3 | Hover underlines (not by default) | TC-004 (positive), TC-005 (negative) | ✅ covered |

No empty rows → no coverage gaps.

## Rubric scores

| Criterion | Score | Note |
|-----------|:-----:|------|
| AC coverage | 5 | every AC has ≥ 1 positive |
| Type distribution | 5 | AC-1 gets an order edge; AC-3 gets a "not by default" negative to prove causality |
| Determinism | 5 | every expected is observable (section scrolled to top, underline present/absent, exact item set/order) |
| Traceability | 5 | all 5 cases carry a `tracesTo` |
| **Overall** | **5.0** | ≥ 4.0 gate passed |

## Volume check

3 ACs → 5 test cases = 1.67× → within the 1.0×–1.7× target.

## Notes
- TC-003 clicks each item and asserts the corresponding section is in the viewport and shows its expected `<h2>` header. The URL hash does not change, so the assertion is on section-in-viewport + header text, not the URL.
- TC-005 (negative) guards against a false positive in TC-004: it confirms the underline is caused by hover, not always present.
