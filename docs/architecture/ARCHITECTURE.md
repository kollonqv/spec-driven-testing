# Architecture

How the spec-driven testing framework is put together: the layers, the agents, the two run modes, and the gates.

## Layers

```
┌───────────────────────────────────────────────────────────────────────┐
│  KNOWLEDGE LAYER  (knowledge/)                                          │
│  glossary · pipeline · testing-standards · schema · rubric · ado-map    │
│  → the rules agents pull into context; the single source of truth       │
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
│  user story · test cases (CSV) · coverage · SPEC.md · specs             │
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
user-story.md ─▶ test-creator-agent ─▶ test-cases.csv + coverage-matrix.md
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

1. **Test-case review** — evaluate against the rubric (score ≥ 4.0, no coverage gaps) before push.
2. **State gate** — orchestrator refuses to automate a non-Closed story.
3. **SPEC review** — the automation SPEC.md is approved before any Playwright code is written.
4. **Per-case confirmation** — each generated `test()` is shown before moving to the next.

## Decisions

- ADR-0001 — Start at User Stories (not raw requirements)
- ADR-0002 — Test Scenario = ADO Test Suite *(superseded by ADR-0006)*
- ADR-0003 — One spec file per user story
- ADR-0004 — Offline and live modes
- ADR-0005 — Design vs automation sprint split (Closed-only gate)
- ADR-0006 — Flat test cases (one suite per story); single design agent
