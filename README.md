# Example Automation Framework — Playwright / TypeScript

A demoable, **spec-driven** E2E test automation framework using Playwright and TypeScript, driven by AI agents and integrated (offline for now) with Azure DevOps. It's **platform-agnostic** — the same agents run under **Claude Code**, **Gemini CLI**, or **GitHub Copilot CLI**. It takes a user story all the way to running automation, with every artifact traceable to an acceptance criterion:

```
User Story → Test Cases → Test Steps → Playwright automation
```

**New here?** Start with [`AGENTS.md`](AGENTS.md) (canonical, tool-neutral orientation), then [`knowledge/pipeline.md`](knowledge/pipeline.md) (the flow), [`agents/README.md`](agents/README.md) (how the agents are shared across tools), and [`docs/demo-runbook.md`](docs/demo-runbook.md) (how to demo it).

---

## Tech Stack

| Tool | Version |
|------|---------|
| Playwright | ^1.45 |
| TypeScript | ^5.5 |
| Node.js | 20+ |
| ADO API | v7.1 |

---

## Project Structure

```
AGENTS.md                   CANONICAL, tool-neutral project context (read first)
agents/                     SINGLE SOURCE OF TRUTH for agent behaviour (platform-neutral)
  ado-skill.md · test-creator.md · test-script.md · test-automation-orchestrator.md · README.md
knowledge/                  KNOWLEDGE LAYER — what agents pull into context
  glossary · pipeline · testing-standards · test-case-schema · evaluation-rubric · ado-mapping   (methodology)
  code-guidelines.md        Code guidelines agents generate against (POM, Playwright, naming)
  domain/                   application & business knowledge (overview, business-rules, glossary, test-data)
docs/
  architecture/ARCHITECTURE.md + adr/    Architecture guidelines + decisions (the "why")
  demo-runbook.md           Step-by-step client demo script (two acts)
examples/reinvention-services-nav/   THE worked example (story → cases → coverage)
src/pages/ · src/tests/<feature>/    POM classes · specs (US{id}_{name}.spec.ts + .spec.md)
scripts/                    ado-fetch-example.ps1 · ado-seed-example.ps1 · check-*.mjs (guards)
playwright.config.ts · tsconfig.json · package.json

--- thin per-tool adapters (all point to agents/ + AGENTS.md) ---
CLAUDE.md                   Claude context → AGENTS.md
.claude/agents/*.md · .claude/skills/ado-skill/SKILL.md   Claude wrappers → agents/
GEMINI.md                   Gemini context → AGENTS.md
.gemini/commands/*.toml     Gemini slash-commands → agents/
.github/copilot-instructions.md · prompts/ · instructions/   Copilot wrappers → agents/
```

---

## Setup

```bash
npm install
npx playwright install        # download browser binaries
```

Set environment variables:

| Variable | Purpose |
|----------|---------|
| `BASE_URL` | Target application URL (default: `https://www.accenture.com`) |
| `ADO_PAT` | Azure DevOps PAT — **omit to run agents in offline mode** (the default) |
| `ADO_ORG_URL` | ADO organization URL, e.g. `https://dev.azure.com/myorg` (live mode) |
| `ADO_PROJECT` | ADO project name (live mode) |

> **Run mode:** if `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT` are not all set, agents run **offline** — reading the worked example from `examples/` and writing artifacts locally. This project currently runs offline; live ADO is wired but dormant. See [`knowledge/ado-mapping.md`](knowledge/ado-mapping.md).

---

## Running Tests

```bash
npx playwright test                        # all tests, headless
npx playwright test --headed               # browser visible
npx playwright test --debug                # Playwright Inspector
npx playwright test src/tests/exampleFeature/  # single feature
npx playwright show-report                 # open last HTML report
```

---

## Naming Conventions

### Spec files

One spec file per ADO user story, named:

```
US{id}_{camelCaseStoryName}.spec.ts
```

Examples:

```
US123_exampleStory.spec.ts
US456_userLogin.spec.ts
US789_checkoutFlow.spec.ts
```

### Test names

Each `test()` block corresponds to one ADO test case. The name starts with the **ADO test case work item ID**, then the AC id:

```typescript
test('{adoTcId} - AC{n} - <brief condition statement>', async () => { ... });
```

Examples:

```typescript
test('10001 - AC1 - user is redirected to dashboard after valid login', async () => { ... });
test('10002 - AC1 - invalid password shows error message', async () => { ... });
test('10003 - AC2 - session expires after inactivity', async () => { ... });
```

`{adoTcId}` is the numeric work item ID of the ADO **Test Case** item (not the user story). This lets CI results link directly back to ADO.

### Page Object classes

`PascalCase`, one class per page or major component:

```
ExamplePage.ts
LoginPage.ts
CheckoutPage.ts
```

---

## Page Object Model

All page interactions live in `src/pages/`. Locators are constructor properties; methods represent user actions.

```typescript
// src/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly usernameInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(readonly page: Page) {
    this.usernameInput = page.getByLabel('Username');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton  = page.getByRole('button', { name: /sign in/i });
  }

  async navigate() { await this.page.goto('/login'); }

  async login(username: string, password: string) {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

---

## Writing a New Test

1. Create a POM class in `src/pages/` if a new page is involved.
2. Create a folder under `src/tests/<feature>/` matching the epic/feature name.
3. Create `US{id}_{storyName}.spec.ts` with this structure:

```typescript
import { test, expect } from '@playwright/test';
import { MyPage } from '../../pages/MyPage';

// US{id} - Story title
// AC1: ...
// AC2: ...

test.describe('US{id} - Story title', () => {
  let myPage: MyPage;

  test.beforeEach(async ({ page }) => {
    myPage = new MyPage(page);
    await myPage.navigate();
  });

  // {adoTcId} = numeric work item ID of the ADO Test Case
  test('{adoTcId} - AC1 - <condition>', async () => {
    // arrange, act, assert
  });

  test('{adoTcId} - AC2 - <condition>', async () => {
    // arrange, act, assert
  });
});
```

---

## Agents & the two-phase pipeline

The pipeline is split into two phases across sprints (see [`knowledge/pipeline.md`](knowledge/pipeline.md) and ADR-0005): test **design** happens in-sprint (manual), automation happens later (orchestrated) and **only for Closed stories**, to avoid rework.

### Phase A — Test Design (in-sprint, manual)
One agent pulls the story + ACs, generates the test cases with you (into `test-cases.md`), then pushes them to the story's ADO Test Suite.

### Phase B — Test Automation (Sprint + N, orchestrated)
One entry point; the Closed-story gate auto-passes (refuses a non-Closed story), then it drives the spec-driven automation — investigate live → `SPEC.md` → build & run every test → **single end-of-phase review**.

### How you invoke them (same agents, three tools)

| Tool | Design phase | Automation phase |
|------|--------------|------------------|
| **Claude Code** | `Use the test-creator-agent for US200` | `Use the test-automation-orchestrator-agent for US200` |
| **Gemini CLI** | `/test-creator US200` | `/test-automation-orchestrator US200` |
| **GitHub Copilot CLI** | `Act as the test-creator agent for US200` (or the `test-creator` prompt) | `Act as the test-automation-orchestrator for US200` |

All three follow the **same** definitions in `agents/` — see [`agents/README.md`](agents/README.md).

### Supporting pieces

- **`agents/ado-skill.md`** — safe ADO REST access; offline/live modes; no deletes; bulk = one-by-one with confirmation.
- **`scripts/ado-fetch-example.ps1`** — standalone fetch/verify helper (live). Operations: `FetchWorkItem`, `FetchTestCases`, `ExportCsv`, `ListPlans`, `ListSuites`.
- **`scripts/ado-seed-example.ps1`** — seeds the worked-example story into a live org so the demo is reproducible.

---

## Worked example

Accenture Reinvention Services top-nav (`/ca-en/about/reinvention-services`): 3 ACs → 5 test cases → one spec, run against the live page.

```bash
npx playwright test src/tests/reinventionServices/ --workers=1
```

Artifacts: [`examples/reinvention-services-nav/`](examples/reinvention-services-nav/) (story, cases, coverage) and the automation SPEC at [`src/tests/reinventionServices/US200_reinventionServicesNav.spec.md`](src/tests/reinventionServices/US200_reinventionServicesNav.spec.md).

> **Investigation-driven accuracy:** ACs are verified against the live page before any assertions are written — selectors and interaction mechanics are **discovered live** by the automation agent, not assumed. That's what keeps the generated tests honest (and the domain/knowledge layer deliberately holds no selectors, so nothing is pre-fed).

---

## CI

Set `CI=true` to enable retry logic (2 retries) and single-worker mode. The reporter outputs an HTML report to `playwright-report/`.
