# Example Automation Framework — Playwright / TypeScript

A demoable, **spec-driven** E2E test automation framework using Playwright and TypeScript, driven by Claude agents and integrated (offline for now) with Azure DevOps. It takes a user story all the way to running automation, with every artifact traceable to an acceptance criterion:

```
User Story → Test Cases → Test Steps → Playwright automation
```

**New here?** Start with [`CLAUDE.md`](CLAUDE.md) (orientation), then [`knowledge/pipeline.md`](knowledge/pipeline.md) (the flow), [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) (how it fits), and [`docs/demo-runbook.md`](docs/demo-runbook.md) (how to demo it).

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
CLAUDE.md                   Orientation for any Claude session in this repo
knowledge/                  KNOWLEDGE LAYER — what agents pull into context
  glossary · pipeline · testing-standards · test-case-schema · evaluation-rubric · ado-mapping   (methodology)
  code-guidelines.md        Code guidelines agents generate against (POM, Playwright, naming)
  domain/                   application & business knowledge (overview, business-rules, glossary, test-data)
docs/
  architecture/ARCHITECTURE.md + adr/    Architecture guidelines + decisions (the "why")
  demo-runbook.md           Step-by-step client demo script (two acts)
examples/
  reinvention-services-nav/ THE worked example (story → cases → coverage)
src/
  pages/                    Page Object Model classes
  tests/
    <feature>/
      US{id}_{name}.spec.ts   one spec file per user story
      US{id}_{name}.spec.md   its automation SPEC (written before the code)
.claude/
  skills/ado-skill/SKILL.md ADO REST skill — offline/live modes, no deletes
  agents/
    test-creator-agent.md                US + ACs → test cases → ADO (design)
    test-script-agent.md                 test cases → SPEC.md → Playwright (automation)
    test-automation-orchestrator-agent.md  Closed-story gate → drives automation
scripts/
  ado-fetch-example.ps1     Fetch/read helper (live)
  ado-seed-example.ps1      Seed the worked-example story into a live org (live)
playwright.config.ts · tsconfig.json · package.json
.github/                    GitHub Copilot mirror (earlier iteration; out of scope)
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

One agent pulls the story + ACs and generates the test cases with you, then pushes them to the story's ADO Test Suite:

```
Use the test-creator-agent for US200
```

### Phase B — Test Automation (Sprint + N, orchestrated)

One entry point; it refuses to automate a story that isn't Closed, then drives the spec-driven automation:

```
Use the test-automation-orchestrator-agent for US200
```

The orchestrator gates on story state, pulls the existing test cases, then hands to the `test-script-agent`, which **investigates the live app, writes `US{id}_{name}.spec.md`, waits for approval, and only then generates the Playwright test** — one case at a time.

### Supporting pieces

- **`ado-skill`** (`.claude/skills/ado-skill/`) — safe ADO REST access; offline/live modes; no deletes; bulk = one-by-one with confirmation.
- **`scripts/ado-fetch-example.ps1`** — standalone fetch/verify helper (live). Operations: `FetchWorkItem`, `FetchTestCases`, `ExportCsv`, `ListPlans`, `ListSuites`.
- **`scripts/ado-seed-example.ps1`** — seeds the worked-example story into a live org so the demo is reproducible.

---

## Worked example

Accenture Reinvention Services top-nav (`/ca-en/about/reinvention-services`): 3 ACs → 5 test cases → one spec, run against the live page.

```bash
npx playwright test src/tests/reinventionServices/ --workers=1
```

Artifacts: [`examples/reinvention-services-nav/`](examples/reinvention-services-nav/) (story, cases, coverage) and the automation SPEC at [`src/tests/reinventionServices/US200_reinventionServicesNav.spec.md`](src/tests/reinventionServices/US200_reinventionServicesNav.spec.md).

> **Investigation-driven accuracy:** the ACs were verified against the live page before writing assertions. AC-2 (click a nav item → the page scrolls its section to just below the sticky sub-nav; the URL hash does not change) and AC-3 (hover animates an `::after` underline) reflect the page's *actual* behaviour, captured with the Playwright CLI — not assumptions.

---

## CI

Set `CI=true` to enable retry logic (2 retries) and single-worker mode. The reporter outputs an HTML report to `playwright-report/`.
