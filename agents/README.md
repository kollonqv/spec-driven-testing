# agents/ — platform-neutral agent definitions

These files are the **single source of truth** for what each agent does. They're plain markdown, referenced identically by every supported tool, so an agent's behaviour is edited in **one** place.

| File | Phase | Role |
|------|-------|------|
| `ado-skill.md` | both | Safe Azure DevOps access (offline/live); no deletes; bulk one-by-one |
| `test-creator.md` | design | US + ACs → `test-cases.md` (AC-traced) → story's ADO Test Suite |
| `test-script.md` | automation | test cases → SPEC.md → Playwright (spec-driven; grounded-in-truth) |
| `test-automation-orchestrator.md` | automation | Closed-story gate → pull cases → drive the script agent → verdict |

They reference the rules in `knowledge/` and the context in `AGENTS.md`.

## How each tool adapts them (thin wrappers)

| Tool | Wrapper | What it does |
|------|---------|--------------|
| **Claude Code** | `.claude/agents/*.md` (frontmatter + pointer), `.claude/skills/ado-skill/SKILL.md` | registers the subagent/skill; body says "follow `agents/<name>.md`" |
| **Gemini CLI** | `.gemini/commands/*.toml` | a `/slash-command` whose `prompt` says "follow `agents/<name>.md`", takes `{{args}}` = story id |
| **GitHub Copilot CLI** | `.github/prompts/*.prompt.md` + `.github/copilot-instructions.md` | prompt files + repo instructions that point to `agents/<name>.md` (Copilot also reads `AGENTS.md` natively) |

## To change an agent
Edit the file here. All three tools pick up the change — no per-platform copies to keep in sync.

## To add a tool
Add a thin wrapper in that tool's convention that (a) loads `AGENTS.md` as context and (b) tells the tool to follow the relevant `agents/<name>.md`. Nothing in `agents/`, `knowledge/`, `scripts/`, or `src/` changes.
