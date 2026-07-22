# ADR-0005: Split test design from test automation across sprints

## Status
Accepted

## Context
In real delivery, test cases are designed and reviewed **while the story is being built** (so they inform development and are ready for manual testing). Automation, however, is done **later** — only once a story is Closed/stable — because automating a story still in flux causes constant rework as ACs and UI change.

A single end-to-end orchestrator that runs create → review → pull → automate in one pass would violate this: it automates cases the moment they are created.

## Decision
Split the pipeline into two workflows:

- **Design phase (in-sprint):** the `test-creator-agent`, invoked **manually** by a human. Collaborative refinement work.
- **Automation phase (Sprint + N):** a single `test-automation-orchestrator-agent` that first checks the story is **Closed/Done** and **refuses otherwise**, then pulls the existing reviewed cases and drives `test-script-agent` to automate them.

## Consequences
- Matches real QA cadence; prevents automating unstable stories.
- The Closed-only **state gate** is enforced in code (reads `System.State` live, or `state:` in `user-story.md` offline).
- The gate doubles as a compelling demo beat: run it on an in-progress story and it stops; run it on the Closed story and it flies.
- The "wow"/orchestration lands on the automation side; design stays deliberately human-driven.
- **Refinement:** the state gate is an *automatic* quality gate — on a Closed/Done/Resolved story it passes and proceeds without stopping (it is not a human checkpoint); it stops only to **refuse** a non-Closed story. The human gates are the SPEC review and the single end-of-phase review (ADR-0009).
