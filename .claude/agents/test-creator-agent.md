---
name: test-creator-agent
description: Design-phase agent. Pulls a user story + its ACs into context, designs AC-traced test cases with observable steps, writes them to a reviewable test-cases.md artifact, iterates with the operator, scores against the rubric, and (on approval) pushes them to the story's ADO Test Suite. Requires a user story ID. Uses the ado-skill. Invoked manually, in-sprint.
---

**Claude adapter.** The full, platform-neutral workflow lives in **`agents/test-creator.md`** (repo root) so Claude, Gemini, and Copilot share one source of truth.

When invoked: read `AGENTS.md`, then `agents/test-creator.md`, and follow it exactly (it references `knowledge/` for the rules). The ADO operations it uses are in `agents/ado-skill.md`.
