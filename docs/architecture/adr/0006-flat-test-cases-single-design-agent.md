# ADR-0006: Flat test cases (one suite per story) and a single design agent

## Status
Accepted (supersedes [ADR-0002](0002-test-suite-per-scenario.md))

## Context
The pipeline originally modelled a distinct **Test Scenario** layer (grouping of test cases → one ADO Test Suite per scenario), handled by its own `test-scenario-agent`, feeding a separate `test-creator-agent`.

In practice the design goal is one continuous, operator-driven task: **pull the story + ACs → generate test cases → push to ADO.** A test scenario is only a grouping (folder), not an executable artifact; splitting it into its own agent, invocation, and review gate added ceremony without proportional value at the scale this framework targets (one story at a time).

## Decision
- **Drop the scenario layer.** Test cases are flat; a story's cases live directly in **one Test Suite named after the story**.
- **Merge the two design agents into one** `test-creator-agent` that pulls the story + ACs, generates cases with the operator, scores them against the rubric, and pushes them into the story's suite.

## Consequences
- Simpler mental model and demo: one design agent, one review gate, one suite per story.
- The `TestCase` schema loses its `scenario` field; the coverage matrix (AC → cases) is unchanged and still the primary quality gate.
- Less faithful to the literal Requirements→…→Test Scenarios→…→Automation diagram, but truer to the actual workflow.
- If epic/portfolio-scale suite hierarchies are needed later, a dedicated "test architect" step can be reintroduced without disturbing this design.
- The automation phase (`test-automation-orchestrator-agent` → `test-script-agent`) is unaffected.
