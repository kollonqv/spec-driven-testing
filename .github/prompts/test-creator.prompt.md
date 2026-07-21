---
mode: agent
description: Generate structured ADO test cases from a user story's acceptance criteria. Paste in a user story ID or its title+ACs and receive a complete, AC-traced test case set ready to paste into ADO or export as CSV.
---

# Test-Creator — GitHub Copilot

This prompt guides you through generating a complete, traceable test case set for an ADO user story.

## What you need to provide

Either:
- **Option A:** An ADO user story ID — Copilot will generate the PowerShell to fetch it (uses `#ado-skill` pattern)
- **Option B:** Paste the user story title and acceptance criteria directly into this chat

---

## Step 1 — Provide the User Story

Paste your user story content, or tell Copilot the ID:

> "Here is US123: [title]. Acceptance criteria: AC1: Given… When… Then…"

---

## Step 2 — Copilot Parses the ACs

Copilot will extract and number each acceptance criterion:

```
AC-1
  Given: <precondition>
  When:  <trigger>
  Then:  <observable outcome>
```

Review the list and confirm or correct it before test generation.

---

## Step 3 — Test Case Generation Rules

Copilot follows these rules when generating test cases:

**Coverage:**
- One **positive** test per AC (mandatory)
- One **negative** test only for security-sensitive ACs (auth, permissions, data validation)
- One **edge** test only for input-validation or boundary ACs
- No negative/edge tests for simple navigation or display ACs

**Each test case includes:**

| Field | Description |
|-------|-------------|
| `id` | TC-001, TC-002, … |
| `title` | Verb-first, ≤ 80 chars |
| `type` | positive / negative / edge / ui |
| `priority` | high (primary positive) / medium (negative/edge) / low (UI checks) |
| `tracesTo` | AC-{n} — every test must trace to an AC |
| `preconditions` | List of setup conditions |
| `steps` | `{ action, expected }` pairs — expected must be observable |

---

## Step 4 — Output Formats

Ask Copilot for the format you need:

### Markdown (for review)
> "Give me the test cases as a Markdown table"

### ADO CSV (for Grid import)
> "Give me the test cases as ADO-compatible CSV"

CSV format matches ADO Grid view import:
```
ID,Work Item Type,Title,Test Step,Step Action,Step Expected,Priority,State,Tags
,Test Case,Verify login,1,Navigate to /login,Login page is displayed,1,Design,type:positive; traces:AC-1
,,,2,Enter valid credentials,User is redirected to dashboard,,,
```

### PowerShell (to push directly to ADO)
> "Give me PowerShell to create these test cases in ADO and link them to US123"

Copilot will generate one `Invoke-RestMethod` block per test case. Run them one at a time — verify each result before running the next.

---

## Anti-patterns Copilot will avoid

- Vague expected results ("page loads", "works correctly")
- Missing `tracesTo` — every test must reference an AC
- Multiple unrelated scenarios in one test case
- Test cases that can't be verified by a human tester
