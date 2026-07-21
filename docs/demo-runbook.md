# Demo Runbook

A step-by-step script for demonstrating the framework to a client. Two acts, separated by the sprint gate. Runs **offline** today; the live-ADO variant is noted at each step for when credentials are supplied.

> **Narrative:** "Test cases are designed while the story is being built. Automation happens a sprint or two later, once the story is Closed and stable — so we never waste effort automating a moving target. Watch the framework enforce exactly that."

---

## Setup (once)

```bash
npm install
npx playwright install chromium
```

Offline mode needs no credentials. The worked example lives in `examples/reinvention-services-nav/`.

*(Live variant: set `ADO_PAT`, `ADO_ORG_URL`, `ADO_PROJECT`, then run `scripts/ado-seed-example.ps1` to create the story in ADO and note the returned ID.)*

---

## Act 1 — Test Design (the "previous sprint")

Story `US200` — *Reinvention Services top navigation bar* — is in refinement with three ACs.

**Step 1 — Generate test cases.** Invoke the design agent:
```
Use the test-creator-agent for US200
```
It pulls the story + ACs into context and generates 5 test cases with observable steps, each tracing to an AC, plus the coverage matrix. **Pause at the review gate** — walk through `test-cases.md` (one steps table per case) and `coverage-matrix.md`; show every AC is covered and every step has an expected. *(Live: it would push each case into the story's Test Suite, one at a time with confirmation.)*

> **Talking point:** point at the coverage matrix. "Every acceptance criterion has at least one test; the security/validation-sensitive ones get negatives and edges. This is governance you can audit."

**End of Act 1:** reviewed test cases exist in ADO. The story continues through development and is eventually **Closed**.

---

## Act 2 — Test Automation (Sprint + N)

Now `US200` is `Closed`. Time to automate.

**Step 2 — Run the orchestrator:**
```
Use the test-automation-orchestrator-agent for US200
```

Watch it:
1. **State gate.** It checks the story is Closed. *(Optional wow: first point it at an in-progress story and show it refuse.)*
2. **Pull cases.** It loads the 5 existing test cases.
3. **SPEC before code.** `test-script-agent` opens the **live** Accenture page and discovers the ground truth — the nav selectors, the click-to-scroll section targets (and that the URL hash does *not* change), and the hover-underline mechanism (`::after` bar) — then writes `src/tests/reinventionServices/US200_reinventionServicesNav.spec.md`. **Pause at the SPEC review gate.**

> **Talking point:** "It didn't guess. It inspected the live app first, wrote the automation spec, and is waiting for sign-off before writing a line of test code. Spec-driven, applied to the tests themselves."

4. **Generate.** After approval, it writes the POM and the spec — one `test()` at a time, each shown for confirmation.
5. **Run:**
```bash
npx playwright test src/tests/reinventionServices/
npx playwright show-report
```
Green. *(Live: optionally publish the run back to ADO.)*

---

## What to emphasize

- **Traceability:** file name → user story; test name (`20003 - AC2 - …`) → test case + AC.
- **Gates:** five human checkpoints; nothing auto-ships.
- **The sprint split:** design ≠ automation; only Closed stories get automated.
- **Offline → live:** identical agents; only the ALM boundary changes. Flip three env vars to go live.

## Reset between demos

```bash
git checkout -- src/tests/reinventionServices/ 2>/dev/null || true
# regenerated artifacts (SPEC.md, spec.ts) can be recreated by re-running Act 2
```
