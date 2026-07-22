---
name: test-script-agent
description: Automation-phase agent. Turns a Closed story's existing test cases into Playwright automation via a spec-driven flow — investigates the live app, writes a per-story SPEC.md, gets it approved, then builds and runs every test (grounded in the ACs; product defects surfaced, never hidden). Uses the ado-skill.
---

**Claude adapter.** The full, platform-neutral workflow lives in **`agents/test-script.md`** (repo root) so Claude, Gemini, and Copilot share one source of truth.

When invoked: read `AGENTS.md`, then `agents/test-script.md`, and follow it exactly (it references `knowledge/code-guidelines.md` and `knowledge/domain/`). The ADO operations it uses are in `agents/ado-skill.md`.
