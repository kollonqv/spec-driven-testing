# GEMINI.md

Gemini CLI adapter. This project's guidance is **tool-neutral** and lives in:

- **[`AGENTS.md`](AGENTS.md)** — project context (read this first)
- **`agents/`** — the agent definitions (one source of truth, shared across Claude / Gemini / Copilot)
- **`knowledge/`** — the rules agents follow

Read `AGENTS.md`, then the relevant files under `knowledge/` and `agents/`. The agents are exposed as slash-commands in `.gemini/commands/` (`/test-creator`, `/test-script`, `/test-automation-orchestrator`), each of which just tells Gemini to follow the matching file in `agents/`.
