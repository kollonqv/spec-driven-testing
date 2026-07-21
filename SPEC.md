# Spec: Spec-Driven E2E Test Automation Framework

## Objective

A demoable reference framework showing **spec-driven testing end to end**, driven by Claude agents and integrated (offline for now) with Azure DevOps:

```
User Story → Test Cases → Test Steps → Playwright automation
```

Every artifact traces back to an acceptance criterion; every phase has a human review gate. Audience: QA/dev teams and client stakeholders evaluating an AI-assisted, governed testing pipeline. It demonstrates the four things clients ask to see: a **knowledge layer**, **architecture guidelines**, **code guidelines**, and a runnable **framework** — plus **agents managing work at each phase**.

## Tech Stack

- TypeScript 5.x · Playwright 1.45+ · Node.js 20+
- Azure DevOps REST API v7.1 (live path, currently dormant)
- Claude Code agents & skills

## Commands

```bash
npm install && npx playwright install         # setup
npx playwright test src/tests/reinventionServices/ --workers=1   # worked example (live app)
npx playwright test                            # all
npx playwright show-report                      # HTML report
```

## Project Structure

```
CLAUDE.md            orientation
knowledge/           knowledge layer (glossary, pipeline, standards, schema, rubric, ado-mapping)
docs/architecture/   ARCHITECTURE.md + ADRs
docs/code-guidelines.md · docs/demo-runbook.md
examples/reinvention-services-nav/   worked-example artifacts
src/pages/ · src/tests/<feature>/    POM + specs (US{id}_{name}.spec.ts + .spec.md)
.claude/skills/ado-skill · .claude/agents/*   the agent layer
scripts/             ado-fetch-example.ps1, ado-seed-example.ps1
```

## Code Style

See `docs/code-guidelines.md`. POM with `readonly` locators in the constructor, semantic locators first, no assertions in POM; test names `'{adoTcId} - AC{n} - <condition>'`; web-first assertions; no `waitForTimeout`.

## Testing Strategy

- `@playwright/test`; specs under `src/tests/<feature>/`, one spec file per user story.
- Each `test()` = one ADO test case, named with its ADO ID + AC.
- Test cases generated per `knowledge/testing-standards.md`, reviewed per `knowledge/evaluation-rubric.md`.
- Automation is spec-driven: a per-story `SPEC.md` is written and approved before code.

## Two-phase pipeline

- **Design (in-sprint, manual):** `test-creator-agent` (US + ACs → test cases → story's ADO suite).
- **Automation (Sprint+N, orchestrated):** `test-automation-orchestrator-agent` gates on story **Closed**, then drives `test-script-agent` (investigate → SPEC → generate → run).

## Run modes

Offline (default, no creds — reads `examples/`, writes locally) vs live (ADO env vars set). Target app is always live. This project runs **offline**; live is wired and documented.

## Boundaries

- **Always:** trace every test to an AC; SPEC before automation code; human gate between phases; POM pattern.
- **Ask first:** switching to live ADO; adding dependencies; changing `playwright.config.ts` projects/browsers.
- **Never:** delete ADO work items; commit `ADO_PAT`/secrets; `waitForTimeout`; skip the Closed-story gate; fake a passing test.

## Success Criteria

- [x] `npm install && npx playwright install` succeeds
- [x] Worked example runs against the live Accenture page and exits 0 (all 5 pass)
- [x] Knowledge layer, architecture guidelines (+ ADRs), and code guidelines exist as first-class artifacts
- [x] Four agents cover design + automation phases; automation is spec-driven and gated on Closed
- [x] `ado-skill` supports offline/live with no destructive ops; worked example artifacts are AC-traceable
- [x] Demo runbook walks the two acts end to end

## Open Questions

None. All ACs were verified against the live page; AC-2 is defined as click-to-scroll (matching the page's actual behaviour) and all five test cases pass.
