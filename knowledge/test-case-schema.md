# Data Model & Schema

The canonical objects that flow through the pipeline. Adapted from the FDE-Cert-Project schemas. Agents produce and consume these shapes; `ado-mapping.md` maps them to ADO fields.

## Story

```yaml
id: US200                      # ADO work item ID
title: string
description: string
state: New | Active | Resolved | Closed | Done
acs: [AcceptanceCriterion]     # ordered
```

## AcceptanceCriterion

```yaml
id: AC-1                       # stable, sequential
given: string                 # precondition
when: string                  # trigger
then: string                  # observable outcome
```

## TestCase

```yaml
id: TC-001                     # stable, sequential, zero-padded
adoTestCaseId: number | null   # ADO work item ID once created (e.g. 20001)
title: string                  # verb-first, <= 80 chars
tracesTo: AC-1                 # MANDATORY
type: positive | negative | edge | ui
priority: high | medium | low
preconditions: [string]
steps: [Step]
```

Test cases are **flat** — a story's cases live directly in one ADO Test Suite named after the story. There is no separate scenario grouping (ADR-0006).

## Step

```yaml
action: string                 # what the tester/automation does
expected: string               # observable result — never vague
```

## Invariants

1. Every `TestCase.tracesTo` references a real `AcceptanceCriterion.id`.
2. Every `Step.expected` is observable (see [testing-standards.md](testing-standards.md)).
3. `id` values are stable: never renumber on edit; removals leave a gap; additions take the next free number.
4. The automated test name encodes traceability: `'{adoTestCaseId} - {tracesTo} - {short title}'`.

See also: [ado-mapping.md](ado-mapping.md), [evaluation-rubric.md](evaluation-rubric.md).
