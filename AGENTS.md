# AGENTS.md — Project Context (tool-neutral)

Spec-driven E2E test automation framework: TypeScript + Playwright, driven by AI agents, integrated (offline for now) with Azure DevOps. This is the canonical context file — it orients **any** agent tool (Claude Code, Gemini CLI, GitHub Copilot CLI) working in this repo. The tool-specific config files are thin adapters that point here.

## What this is

A demoable reference framework that takes a user story all the way to running automation:

```
User Story → Test Cases → Test Steps → Playwright automation
```

…with every artifact traceable back to an acceptance criterion, and a human review gate at each phase. See `knowledge/pipeline.md` for the full flow and `docs/architecture/ARCHITECTURE.md` for how it fits together.

## Read these first (the knowledge layer)

Agents pull from `knowledge/` — the source of truth. Two parts:

**Methodology** (how we test): `knowledge/glossary.md`, `pipeline.md`, `testing-standards.md`, `test-case-schema.md`, `evaluation-rubric.md`, `ado-mapping.md`, `code-guidelines.md`.

**Domain** (what the app under test is) — `knowledge/domain/`: `application-overview.md`, `business-rules.md`, `glossary.md`, `test-data-and-environments.md`. Functional-only (no selectors — discovered live). See `knowledge/domain/README.md`.

## Agents (defined once in `agents/`, adapted per tool)

The agent instructions live **once** in `agents/` and are shared by every platform:

| Agent (neutral def) | Phase | Role |
|---------------------|-------|------|
| `agents/ado-skill.md` | both | Safe ADO REST access; offline/live modes; no deletes; bulk = one-by-one |
| `agents/test-creator.md` | design | US + ACs → test cases + steps (AC-traced) → story's ADO Test Suite |
| `agents/test-script.md` | automation | test cases → **SPEC.md** → Playwright (spec-driven) |
| `agents/test-automation-orchestrator.md` | automation | Closed-story gate → pull cases → drive the script agent → run |

**Design is manual** (one agent, operator-driven). **Automation is orchestrated** (one command; the Closed-story gate auto-passes; human gates are the SPEC review + the single end-of-phase review). Test cases are flat — one Test Suite per story (ADR-0006).

## Platform adapters (thin — they point to `agents/` + this file)

| Tool | Context file | Agent/command wrappers |
|------|--------------|------------------------|
| **Claude Code** | `CLAUDE.md` → this file | `.claude/agents/*.md`, `.claude/skills/ado-skill/SKILL.md` |
| **Gemini CLI** | `GEMINI.md` → this file | `.gemini/commands/*.toml` |
| **GitHub Copilot CLI** | `.github/copilot-instructions.md` → this file (also reads `AGENTS.md` natively) | `.github/prompts/*.prompt.md`, `.github/instructions/*.instructions.md` |

Editing an agent's behaviour = edit the one file in `agents/`. See `agents/README.md`.

## Current mode: OFFLINE

No ADO credentials are used right now. Agents read the worked example from `examples/reinvention-services-nav/` and write outputs locally. Live ADO is wired and documented (`scripts/`, `agents/ado-skill.md`) but dormant until `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT` are set.

## Code conventions

Full rules in `knowledge/code-guidelines.md`. Highlights:
- Spec: `US{id}_{camelCaseStory}.spec.ts`; SPEC beside it: `…​.spec.md`
- Test name: `'{adoTcId} - AC{n} - <condition>'`
- POM: all locators in the POM (`readonly` props or `Locator`-returning methods), no assertions in POM
- No `waitForTimeout`; web-first assertions. Enforced by `npm run check` (no raw locators + tests in TC order).

## Commands

```bash
npm install && npx playwright install    # setup
npm run check                             # no raw locators + tests in order
npx playwright test src/tests/reinventionServices/   # the worked example
npx playwright show-report                # HTML report
```

## Boundaries

- **Always:** trace every test to an AC; SPEC before automation code; discover selectors live; keep locators in the POM.
- **Ask first:** switching to live ADO; adding dependencies; changing `playwright.config.ts` projects.
- **Never:** delete ADO work items; commit `ADO_PAT`/secrets; `waitForTimeout`; skip the Closed-story gate; make a test pass by weakening it (see ADR-0007).
