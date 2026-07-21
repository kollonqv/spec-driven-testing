# Model → Azure DevOps Mapping

How the pipeline's data model maps onto ADO work items, test plans, and suites. The `ado-skill` implements these; this file is the reference contract.

## Object mapping

| Framework object | ADO representation |
|------------------|--------------------|
| Story | Work item type `User Story` |
| AcceptanceCriterion | Parsed from `Microsoft.VSTS.Common.AcceptanceCriteria` (HTML) on the story |
| Story's test container | **one Test Suite per story** (named after the story) under a Test Plan |
| TestCase | Work item type `Test Case` |
| Step | A `<step>` in the `Microsoft.VSTS.TCM.Steps` XML |
| Traceability (US ↔ TC) | `Microsoft.VSTS.Common.TestedBy` relation |

## Field mapping (Test Case)

| Model field | ADO field |
|-------------|-----------|
| `title` | `System.Title` |
| `priority` | `Microsoft.VSTS.Common.Priority` (high→1, medium→2, low→3) |
| `steps` | `Microsoft.VSTS.TCM.Steps` (XML of `{action, expected}`) |
| `type`, `tracesTo` | `System.Tags` → `type:<t>; traces:<AC-n>` |
| `state` | `System.State` (defaults to `Design` for new test cases) |

## Story state gate (automation phase)

The automation orchestrator reads `System.State`. Automation proceeds **only** when state ∈ { `Closed`, `Done`, `Resolved` } (configurable). Otherwise it refuses.

## Two modes

| | Offline (default) | Live |
|---|---|---|
| Story source | `examples/<story>/user-story.md` | `GET .../wit/workitems/{id}` |
| Test cases source | `examples/<story>/test-cases.csv` | `TestedBy` relations on the story |
| Suite creation | n/a (cases listed in CSV) | `POST .../testplan/plans/{id}/suites` (one per story) |
| Case creation | written to CSV / markdown | `PATCH .../wit/workitems/$Test Case` |
| State gate | reads `state:` in `user-story.md` | reads `System.State` |
| Requires `ADO_PAT` | no | yes |

Agents pick the mode from whether `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT` are set. Offline is the default and needs no credentials.

## Test Plans licensing note

Azure **Test Plans** (suites/runner) is a paid access level ("Basic + Test Plans"), separate from free Basic. Creating Test Case *work items* works on Basic; organizing them into a **Suite** needs a Test Plans license (free trial available). If unavailable, the fallback is to skip the suite and link the cases to the story via `TestedBy` only (free Basic), optionally tagging them for grouping. Offline mode sidesteps this entirely.

See also: `.claude/skills/ado-skill/SKILL.md`, [test-case-schema.md](test-case-schema.md).
