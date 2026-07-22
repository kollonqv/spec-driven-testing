# CLAUDE.md — Project Context

Spec-driven E2E test automation framework: TypeScript + Playwright, driven by Claude agents, integrated (offline for now) with Azure DevOps. This file orients any Claude session working in this repo.

## What this is

A demoable reference framework that takes a user story all the way to running automation:

```
User Story → Test Cases → Test Steps → Playwright automation
```

…with every artifact traceable back to an acceptance criterion, and a human review gate at each phase. See `knowledge/pipeline.md` for the full flow and `docs/architecture/ARCHITECTURE.md` for how it fits together.

## Read these first (the knowledge layer)

Agents pull from `knowledge/` — treat it as the source of truth. It has two parts:

**Methodology** (how we test):
- `knowledge/glossary.md` — vocabulary
- `knowledge/pipeline.md` — the two-phase flow (design in-sprint, automation Sprint+N)
- `knowledge/testing-standards.md` — how test cases are generated
- `knowledge/test-case-schema.md` — the data model
- `knowledge/evaluation-rubric.md` — the review gate
- `knowledge/ado-mapping.md` — model → ADO, offline vs live

**Domain** (what the app under test is) — `knowledge/domain/`:
- `application-overview.md`, `business-rules.md`, `glossary.md`, `test-data-and-environments.md`
- Functional-only (no selectors — discovered live). Feeds design (smarter ACs/edges) + automation (test data). See `knowledge/domain/README.md`.

## Agents (`.claude/`)

| Agent / skill | Phase | Role |
|---------------|-------|------|
| `ado-skill` | both | Safe ADO REST access; offline/live modes; no deletes; bulk = one-by-one |
| `test-creator-agent` | design | US + ACs → test cases + steps (AC-traced) → story's ADO Test Suite |
| `test-script-agent` | automation | test cases → **SPEC.md** → Playwright (spec-driven) |
| `test-automation-orchestrator-agent` | automation | Closed-story gate → pull cases → drive script-agent → run |

**Design is manual** (one agent, operator-driven). **Automation is orchestrated** (one command, gated on story Closed). Test cases are flat — one Test Suite per story, no scenario layer (ADR-0006). See ADR-0005.

## Current mode: OFFLINE

No ADO credentials are used right now. Agents read the worked example from `examples/reinvention-services-nav/` and write outputs locally. Live ADO is wired and documented (`scripts/`, `ado-skill`) but dormant until `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT` are set.

## Code conventions

Full rules in `knowledge/code-guidelines.md`. Highlights:
- Spec: `US{id}_{camelCaseStory}.spec.ts`; SPEC beside it: `…​.spec.md`
- Test name: `'{adoTcId} - AC{n} - <condition>'`
- POM: `readonly` locators in constructor, no assertions in POM, semantic locators first
- No `waitForTimeout`; use web-first assertions (`toBeVisible`, `toHaveCSS`, …)

## Commands

```bash
npm install && npx playwright install    # setup
npx playwright test                       # run all
npx playwright test src/tests/reinventionServices/   # the worked example
npx playwright show-report                # HTML report
```

## Worked example

Accenture Reinvention Services top-nav (`/ca-en/about/reinvention-services`): 3 ACs → 5 test cases → one spec. Artifacts in `examples/reinvention-services-nav/`; automation in `src/tests/reinventionServices/`.

## Boundaries

- **Always:** trace every test to an AC; SPEC before automation code; human gate between phases.
- **Ask first:** switching to live ADO; adding dependencies; changing `playwright.config.ts` projects.
- **Never:** delete ADO work items; commit `ADO_PAT`/secrets; `waitForTimeout`; skip the Closed-story gate.

## Out of scope for now

GitHub Copilot mirror files exist under `.github/` from an earlier iteration but are **not** part of this demo — leave them untouched; focus is Claude agents + skills.
