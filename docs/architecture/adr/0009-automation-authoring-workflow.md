# ADR-0009: Automation authoring workflow — spec-first, run-before-review, single review

## Status
Accepted

## Context
How the `test-script-agent` produces Playwright code needs to be disciplined, reviewable, and honest. The review cadence went through several iterations in practice:
1. asking the operator *before generating* each test (annoying, and nothing to review yet);
2. per-test build → run → review → approve → next (verified, but too many approval stops);
3. the current model.

We also observed the agent (a) reviewing code *before* running it, and (b) inlining raw locators and emitting tests out of order.

## Decision
The automation phase authoring flow is:

1. **SPEC before code** — investigate the live app, write `US{id}_<name>.spec.md` (per-step tables), and get it approved. No code before this gate. (Spec-driven, per ADR-0003 lineage.)
2. **Build and run every test as you go** — each test is written *and run* and iterated to a confident result (green, or red-with-verified-defect per ADR-0007). **Run before review**, but **no per-test approval**.
3. **One end-of-phase review** — after all tests are built and run, a final full-suite run, then a **single** review of the complete result (all tests + run results + iteration log).
4. **Machine-enforced code discipline** — all locators in the POM and tests in ascending TC order, enforced by `npm run check` (`check:locators` + `check:order`), which fails the build.

Human gates in the automation phase: **SPEC review** + **single end-of-phase review**. The Closed-state quality gate and case pull are automatic (ADR-0005).

## Consequences
- The operator reviews *verified, complete* work once — no approval fatigue, and nothing is ever presented unrun.
- POM/ordering discipline is enforced by code, not just guidelines — the class of "raw locator in spec / TC3 between TC1 and TC2" defects fails the build.
- Ties to ADR-0007 (the verdict is honest, never forced green) and ADR-0008 (test data from domain knowledge; selectors discovered live).
