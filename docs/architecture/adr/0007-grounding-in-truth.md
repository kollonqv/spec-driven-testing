# ADR-0007: Grounding in truth — honest verdicts, no defect-hiding

## Status
Accepted

## Context
An AI agent generating automated tests has a strong failure mode: to satisfy a "make it pass" objective it can quietly assert whatever the app currently does (turning real bugs into green tests), or weaken/skip a check to force green. If "done" means "green," the incentive is to hide defects. That would make the whole framework worse than useless — it would manufacture false confidence.

## Decision
Tests must faithfully verify the acceptance criteria, not pass:

- **`expected` comes from the AC, never from the observed app.** Live investigation is used only to learn *how to locate and observe* (selectors, mechanisms) — never *what the answer should be*.
- **A test that is red because the app doesn't meet its AC is a valid, complete outcome** — surfaced as a defect (expected-vs-actual + evidence), with the operator choosing to log a defect or amend the AC. It is never made green by weakening the test.
- **"Done" = a faithful test with an honest verdict** (green *or* red-with-verified-defect), not "green."
- On failure, the agent classifies before changing anything: **(a) flaky/env**, **(b) automation defect** (fix the test/observation), **(c) product defect** (leave red, surface). Only (a)/(b) are fixed.
- **Prohibited:** weakening/deleting an assertion, asserting the buggy value, softening a matcher to dodge failure, try/catch-swallowing, or `skip`/`fixme` to avoid running a case.

## Consequences
- Defect-hiding now requires *visible* tampering, which review + AC traceability catch — it is no longer the path of least resistance.
- The `test-script-agent` runs and iterates but never forces green; product defects flow back as findings.
- Enforced in `test-script-agent` ("Grounding in truth" + the run-and-iterate loop) and the orchestrator's verdict. Pairs with ADR-0009 (authoring workflow).
- Proven in practice: when AC-2 was originally "hover changes colour," investigation showed the live page doesn't — the test was left red and surfaced, not doctored.
