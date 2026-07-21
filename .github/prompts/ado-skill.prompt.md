---
mode: agent
description: Interact with Azure DevOps via the REST API using your PAT token. Generates ready-to-run PowerShell commands for fetching work items, test cases, test plans, and creating/linking test cases. No destructive operations.
---

# ADO Skill — GitHub Copilot

Use this prompt to get ready-to-run PowerShell commands for Azure DevOps REST API operations.

## Before we start

Confirm these environment variables are set in your shell:

```powershell
$env:ADO_PAT       # your Personal Access Token
$env:ADO_ORG_URL   # e.g. https://dev.azure.com/myorg
$env:ADO_PROJECT   # e.g. MyProject
```

Tell me which operation you need and provide any IDs or URLs:

---

## Available Operations

Tell Copilot what you want to do — it will generate the exact PowerShell to run.

### Fetch a work item
> "Fetch work item 123"

### Fetch all test cases linked to a user story
> "Get all test cases for user story 456"

### List test plans
> "List all test plans in my project"

### List suites in a plan
> "List suites in test plan 789"

### Create a test case and link it to a user story
> "Create a test case titled 'Verify login' with these steps: [step1, step2] and link it to US 123"

### Add a test case to a suite
> "Add test case 321 to suite 654 in plan 789"

---

## Safety Rules (enforced in all generated commands)

- Commands use `Invoke-RestMethod` — never `Invoke-WebRequest -Method DELETE`
- PAT is read from `$env:ADO_PAT` and base64-encoded; it is never printed or stored in plain text
- Bulk operations: Copilot generates one command at a time — run it, verify the result, then ask for the next
- No work item deletions — if you ask for a delete, Copilot will suggest an alternative (e.g. change state to Removed)

## Auth snippet (included in all generated commands)

```powershell
$base64Pat = [Convert]::ToBase64String(
  [Text.Encoding]::ASCII.GetBytes(":$env:ADO_PAT")
)
$headers = @{
  Authorization = "Basic $base64Pat"
  'Content-Type' = 'application/json'
}
```
