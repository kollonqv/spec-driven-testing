# The Spec-Driven Testing Pipeline

End-to-end flow from business need to running automation. This framework automates the shaded segment; the front of the chain is human/BA-owned.

```
Requirements ──▶ User Stories ──▶ Test Cases ──▶ Test Steps ──▶ Automation
  (human/BA)       (human/BA)    │◀──────── framework agents ────────▶│
                        ▲        │                                     │
                    ENTRY POINT  │                                     ▼
                                 └── Design phase (in-sprint) ──┐  ┌── Automation phase (Sprint+N)
```

Test cases are **flat**: a story's cases live directly in one ADO Test Suite named after the story. (There is no separate "test scenario" grouping layer — see ADR-0006.)

## Two phases, separated by story state

The pipeline is deliberately split into two workflows that happen in **different sprints** and are triggered by **different conditions**. This mirrors how QA actually works: test cases are designed while the story is being built, but automation waits until the story is stable to avoid rework.

### Phase A — Test Design (in-sprint, human-driven)

| | |
|---|---|
| **When** | The story's own sprint (refinement / build) |
| **Trigger** | A user story with acceptance criteria exists in ADO |
| **Agent** | `test-creator-agent` |
| **How run** | Manually, with the operator, reviewing before push |
| **Output** | Test Cases (with steps, AC-traced) in the story's ADO Test Suite |

Flow: the `test-creator-agent` pulls the story + ACs into context, generates test cases with the operator (see [testing-standards.md](testing-standards.md)) — each step with an observable expected, each case tracing to an AC — scores them against the [evaluation-rubric.md](evaluation-rubric.md), and on approval pushes them into the story's suite, one at a time.

### Phase B — Test Automation (Sprint + N, orchestrated)

| | |
|---|---|
| **When** | A later sprint, once the story is **Closed / Done** |
| **Trigger** | Story state = `Closed` (or `Done`) — enforced by the orchestrator |
| **Agents** | `test-automation-orchestrator-agent` → `test-script-agent` |
| **How run** | One command; gated at each step |
| **Output** | A per-story `SPEC.md` + a Playwright `US{id}_{name}.spec.ts`, run green |

Steps:
1. **State gate.** The orchestrator reads the story state. If it is not Closed/Done, it **refuses** to automate (avoids automating an unstable story).
2. **Pull cases.** Fetch the story's existing, reviewed test cases from ADO.
3. **SPEC before code.** `test-script-agent` runs a spec-driven flow: it investigates the live target app, then writes a per-story `SPEC.md` beside the test, and **stops for review**.
4. **Automate — build & run all, then one review.** After the SPEC is approved, it writes each test (all locators in the POM) and **runs + iterates each to a confident result as it goes**, without stopping between tests. Once all are built and run, it does a final full-suite run and presents the **complete result for a single review** — nothing is presented unrun, but the operator approves once, not per test.
5. **Run & iterate (honest verdict).** Within each test's loop it diagnoses failures: *automation* problems (flaky/selector/observation) are fixed and re-run in a bounded loop; a genuine **product defect** leaves the test **red** and is surfaced (never hidden by weakening the test). Assertions encode the ACs, not the app's current behaviour. Optionally publish results back to ADO.

## Why the split matters

- **Avoids rework**: automating a story still in flux wastes effort; the Closed gate prevents it.
- **Right tool, right phase**: design is collaborative (manual); automation is repeatable (orchestrated).
- **Governance is visible**: every phase has a human gate and every artifact traces to an AC.

See also: [testing-standards.md](testing-standards.md), [evaluation-rubric.md](evaluation-rubric.md), and `docs/architecture/ARCHITECTURE.md`.
