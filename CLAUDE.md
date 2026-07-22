# CLAUDE.md

Claude Code adapter. This project's guidance is **tool-neutral** and lives in:

- **[`AGENTS.md`](AGENTS.md)** — project context (read this first)
- **`agents/`** — the agent definitions (one source of truth, shared across Claude / Gemini / Copilot)
- **`knowledge/`** — the rules agents follow

Read `AGENTS.md`, then the relevant files under `knowledge/` and `agents/`. The Claude subagents in `.claude/agents/` and the skill in `.claude/skills/` are thin wrappers that point into `agents/`.
