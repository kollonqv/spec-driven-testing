# Architecture

How the spec-driven testing framework is put together: the layers, the agents, the two run modes, and the gates.

## Layers

```
┌───────────────────────────────────────────────────────────────────────┐
│  KNOWLEDGE LAYER  (knowledge/)                                          │
│  • Methodology:  glossary · pipeline · testing-standards · schema ·     │
│                  evaluation-rubric · ado-mapping · code-guidelines       │
│                  (how we test + how we write the code)                   │
│  • Domain:       knowledge/domain/  application-overview · business-     │
│                  rules · glossary · test-data   (what the app IS)        │
│  → the knowledge agents pull into context; the single source of truth    │
└───────────────────────────────────────────────────────────────────────┘
                                   │ referenced by
┌───────────────────────────────────────────────────────────────────────┐
│  AGENT LAYER  (.claude/agents, .claude/skills)                          │
│  ado-skill · creator-agent · script-agent · orchestrator-agent          │
│  → the workers; each phase is an agent, all compose over the ado-skill   │
└───────────────────────────────────────────────────────────────────────┘
                                   │ produce / consume
┌───────────────────────────────────────────────────────────────────────┐
│  ARTIFACT LAYER  (examples/, src/, reports/)                            │
│  user story · test cases (md) · coverage · SPEC.md · specs             │
│  → the tangible outputs, all traceable back to an AC                     │
└───────────────────────────────────────────────────────────────────────┘
```

## Agent topology

```
DESIGN PHASE (in-sprint, manual)              AUTOMATION PHASE (Sprint+N, orchestrated)
─────────────────────────────────            ──────────────────────────────────────────
 test-creator-agent US200                     test-automation-orchestrator US200
        │  pull US + ACs                            │
        │  generate cases (with operator)           ├─▶ 1. STATE GATE: story Closed? ──no──▶ refuse
        ▼                                           ├─▶ 2. pull existing test cases
 [rubric review gate]                               ├─▶ 3. test-script-agent:
        │                                           │        investigate live app
        ▼                                           │        write SPEC.md  ──▶ [review gate]
   push cases → story's ADO Test Suite             │        generate test (one case at a time)
   (one suite per story)                            ├─▶ 4. npx playwright test
        │                                           └─▶ 5. (optional) publish results to ADO
        ▼
   Test cases live in ADO
   (previous sprint)
                                     ┌──────────────────┐
   both phases compose over ────────▶│    ado-skill     │◀──── offline | live
                                     └──────────────────┘
```

Design is **manual** because it is collaborative refinement work. Automation is **orchestrated** because it is a repeatable pipeline — and it is gated on story state so only stable (Closed) stories get automated, avoiding rework. See ADR-0005.

## Two run modes

Every agent runs in one of two modes, chosen automatically from whether the ADO env vars are present:

- **Offline (default):** reads the story and cases from `examples/`, writes artifacts locally. No credentials, no network to ADO. This is the demo default.
- **Live:** reads/writes a real ADO org via the `ado-skill` (`ADO_PAT` etc.). The *target application* (e.g. accenture.com) is always live in both modes — only the ALM changes.

See ADR-0004.

## Data flow (one story, end to end)

```
user-story.md ─▶ test-creator-agent ─▶ test-cases.md + coverage-matrix.md
                                                       │
                                                       ▼
                                       (later sprint, story Closed)  orchestrator
                                                                              │
                                          script-agent ─▶ US{id}_{name}.spec.md (SPEC gate)
                                                        ─▶ ReinventionServicesPage.ts (POM)
                                                        ─▶ US{id}_{name}.spec.ts (test)
                                                        ─▶ playwright run (live app)
```

## Gates (non-negotiable)

1. **Test-case review** *(human)* — evaluate against the rubric (score ≥ 4.0, no coverage gaps) before push.
2. **State gate** *(automatic)* — passes automatically when the story is Closed/Done/Resolved and flows straight into automation; **refuses (stops) only** for a non-Closed story. Not a human checkpoint.
3. **SPEC review** *(human)* — the automation SPEC.md is approved before any Playwright code is written.
4. **Build-and-run all, then one review** *(human)* — every test is written (all locators in the POM, tests in ascending TC order; `npm run check` passes) and **run + iterated to a confident result** as it's built, with **no per-test approval**; once all are built and run, the operator reviews the complete result **once** (all tests + their run results). Nothing is presented unrun.
5. **Run & honest verdict** *(automatic)* — the script-agent iterates only on *automation* problems (flaky waits, wrong selector/observation method) in a bounded loop (≤ 5 iterations per test), then does a final full-suite run. Assertions encode the **acceptance criteria**, not whatever the live app currently does — so a test that goes red because the app doesn't meet its AC is a **valid, complete outcome**: it is surfaced as a defect, never made green by weakening the test. "Done" = a faithful test that has been run, with the result reported honestly (green, or red-with-defect).

## Decisions

- ADR-0001 — Start at User Stories (not raw requirements)
- ADR-0002 — Test Scenario = ADO Test Suite *(superseded by ADR-0006)*
- ADR-0003 — One spec file per user story
- ADR-0004 — Offline and live modes
- ADR-0005 — Design vs automation sprint split (Closed-only gate; the gate auto-passes)
- ADR-0006 — Flat test cases (one suite per story); single design agent
- ADR-0007 — Grounding in truth (honest verdicts, no defect-hiding)
- ADR-0008 — Domain knowledge layer (functional-only)
- ADR-0009 — Automation authoring workflow (spec-first, run-before-review, single review)
