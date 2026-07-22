# GitHub Copilot — repository instructions

This repository's guidance is **tool-neutral**. Follow it exactly:

- **`AGENTS.md`** — project context (Copilot CLI reads this natively; read it first).
- **`agents/`** — the agent definitions, one source of truth shared across Claude / Gemini / Copilot:
  - `agents/test-creator.md` — design phase (US + ACs → `test-cases.md`)
  - `agents/test-script.md` — automation phase (spec-driven Playwright)
  - `agents/test-automation-orchestrator.md` — orchestrates the automation phase
  - `agents/ado-skill.md` — safe Azure DevOps access (offline/live)
- **`knowledge/`** — the rules (testing standards, schema, rubric, ado-mapping, code-guidelines, and `domain/`).

To run an agent, tell Copilot e.g. *"Act as the test-creator agent for US200"* and it will follow `agents/test-creator.md`. Reusable prompt files are in `.github/prompts/`; path-scoped code rules are in `.github/instructions/`.

@AGENTS.md
