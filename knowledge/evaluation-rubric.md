# Evaluation Rubric

How to judge a generated test-case set before it goes to ADO (design phase) and before automation (automation phase). Adapted from the FDE-Cert-Project evaluation system prompt. Use it as a review gate.

## Score each criterion 0–5

| Criterion | What it measures | 5 = excellent | 0 = failing |
|-----------|------------------|---------------|-------------|
| **AC coverage** | Every AC has ≥ 1 positive test | All ACs covered | ACs with no test |
| **Type distribution** | Security-sensitive ACs have negatives; input-validation ACs have edges | Correctly targeted | Missing / misapplied |
| **Determinism** | Every expected result is observable/falsifiable | All observable | Vague expecteds |
| **Traceability** | Every test has a valid `tracesTo` | 100% traced | Untraced tests |

`overallScore` = average of the four.

## Coverage matrix (required output)

Map every AC to the test cases covering it. **Empty arrays flag gaps** and must be resolved (or explicitly waived) before proceeding.

| AC | Covered by | Status |
|----|-----------|--------|
| AC-1 | TC-001, TC-002 | ✅ covered |
| AC-2 | TC-003 | ✅ covered |
| AC-3 | TC-004, TC-005 | ✅ covered |

## Gaps

For each gap, state it specifically and actionably:

```
GAP: AC-2 has no test verifying color on keyboard focus.
  suggestedTestType: edge
  relatedAcId: AC-2
```

## Review gate

Do not advance a phase until:

- [ ] `overallScore` ≥ 4.0
- [ ] Coverage matrix has no unwaived empty rows
- [ ] No vague expected results remain
- [ ] Every test traces to an AC

See also: [testing-standards.md](testing-standards.md).
