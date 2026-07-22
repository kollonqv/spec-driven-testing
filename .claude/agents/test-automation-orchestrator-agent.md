---
name: test-automation-orchestrator-agent
description: Automation-phase conductor. Given a user story ID, auto-passes the Closed-story quality gate, pulls the story's existing test cases, then drives the test-script agent through its spec-driven flow (SPEC review + single end-of-phase review gates), and optionally publishes results. Human approval only at the SPEC and final review.
---

**Claude adapter.** The full, platform-neutral workflow lives in **`agents/test-automation-orchestrator.md`** (repo root) so Claude, Gemini, and Copilot share one source of truth.

When invoked: read `AGENTS.md`, then `agents/test-automation-orchestrator.md`, and follow it exactly. It delegates to the test-script agent (`agents/test-script.md`) and uses `agents/ado-skill.md`.
