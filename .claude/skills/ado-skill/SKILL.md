---
name: ado-skill
description: Interact with Azure DevOps via the REST API using the operator's PAT token. Provides safe read and write access to work items, test cases, test plans, and test suites. Supports an offline mode (read/write local example artifacts, no ADO calls). No destructive actions. No deleting work items. Bulk operations go one-by-one with operator confirmation.
---

# ADO Skill

## Overview

This skill provides structured, safe access to the Azure DevOps REST API (v7.1). It is designed to be composed into other agent workflows (test-creator-agent, test-script-agent, test-automation-orchestrator-agent).

## Run Modes

The skill operates in one of two modes, chosen automatically:

| | Offline (default) | Live |
|---|---|---|
| **Trigger** | `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT` are **not** all set | all three env vars set |
| **Story source** | `examples/<story>/user-story.md` | `GET .../wit/workitems/{id}` |
| **Test cases** | `examples/<story>/test-cases.csv` | `TestedBy` relations |
| **Suite (one per story)** | n/a (cases listed in CSV) | `POST .../testplan/.../suites` |
| **Case creation** | written to CSV / markdown | `PATCH .../wit/workitems/$Test Case` |
| **Story state gate** | reads `state:` in `user-story.md` | reads `System.State` |

**This project currently runs OFFLINE.** All REST snippets below are for the live path and are dormant until credentials are supplied. In offline mode, "fetch" means read the corresponding `examples/` file, and "create/push" means write/append the corresponding local artifact and report what *would* be sent to ADO. Never invent an ADO REST call while offline.

See `knowledge/ado-mapping.md` for the full model↔ADO contract.

## Reference Script

`scripts/ado-fetch-example.ps1` is a standalone PowerShell script that implements all fetch operations described in this skill. Run it directly to verify your credentials and explore ADO data before composing agents on top of it:

```powershell
.\scripts\ado-fetch-example.ps1 -Operation FetchWorkItem  -WorkItemId 123
.\scripts\ado-fetch-example.ps1 -Operation FetchTestCases -WorkItemId 123
.\scripts\ado-fetch-example.ps1 -Operation ExportCsv      -WorkItemId 123
.\scripts\ado-fetch-example.ps1 -Operation ListPlans
.\scripts\ado-fetch-example.ps1 -Operation ListSuites     -PlanId 456
```

## Prerequisites

These environment variables must be set before invoking any ADO operation:

| Variable | Description |
|----------|-------------|
| `ADO_PAT` | Personal Access Token with `Work Items (Read & Write)` and `Test Management (Read & Write)` scopes |
| `ADO_ORG_URL` | Organization URL, e.g. `https://dev.azure.com/myorg` |
| `ADO_PROJECT` | Project name, e.g. `MyProject` |

If any variable is missing, stop immediately and tell the operator which variable needs to be set.

## Authentication

All requests use HTTP Basic Auth with the PAT as the password and an empty username:

```powershell
$base64Pat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$env:ADO_PAT"))
$headers = @{
  "Authorization" = "Basic $base64Pat"
  "Content-Type"  = "application/json"
}
```

Never log, echo, or expose the raw PAT value in any output.

---

## Available Operations

### 1. Fetch a Work Item (User Story, Bug, etc.)

```powershell
$id  = 123   # work item ID
$url = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/${id}?`$expand=all&api-version=7.1"
$wi  = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
```

Key fields:
- `$wi.fields.'System.Title'` — title
- `$wi.fields.'System.State'` — workflow state (used by the automation gate)
- `$wi.fields.'System.Description'` — HTML description
- `$wi.fields.'Microsoft.VSTS.Common.AcceptanceCriteria'` — HTML acceptance criteria
- `$wi.relations` — linked items (test cases appear here with `rel = "Microsoft.VSTS.Common.TestedBy-Forward"`)

**Offline:** read `examples/<story>/user-story.md` — title, `state`, and the AC sections are in the YAML block and headings.

### 1b. Read Story State (automation gate)

The automation orchestrator must confirm a story is stable before automating it.

```powershell
$state = $wi.fields.'System.State'   # live
```

Offline: read the `state:` field from `examples/<story>/user-story.md`. Automation proceeds only when the state is one of `Closed`, `Done`, `Resolved`. Otherwise, **refuse** and tell the operator the story is not ready to automate.

### 2. Resolve a Work Item ID from a URL

Extract the numeric ID from the ADO URL. ADO work item URLs follow the pattern:
`https://dev.azure.com/{org}/{project}/_workitems/edit/{id}`

Parse the last path segment as the integer ID.

### 3. Fetch All Test Cases Linked to a User Story

```powershell
# work item already fetched above
$testCaseIds = $wi.relations |
  Where-Object { $_.rel -eq 'Microsoft.VSTS.Common.TestedBy-Forward' } |
  ForEach-Object { $_.url -split '/' | Select-Object -Last 1 }
```

Then fetch each test case:

```powershell
$ids = $testCaseIds -join ','
$url = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems?ids=$ids&`$expand=all&api-version=7.1"
$tcs = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
```

Test step XML is in `$tc.fields.'Microsoft.VSTS.TCM.Steps'`.

### 4. Parse Test Steps from ADO XML

ADO stores test steps as XML in `Microsoft.VSTS.TCM.Steps`. Parse it with:

```powershell
[xml]$stepsXml = $tc.fields.'Microsoft.VSTS.TCM.Steps'
$steps = $stepsXml.steps.step | ForEach-Object {
  [PSCustomObject]@{
    Action   = $_.'parameterizedString'[0].'#text'
    Expected = $_.'parameterizedString'[1].'#text'
  }
}
```

### 5. Create a Test Case Work Item

```powershell
$patchUrl     = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/`$Test%20Case?api-version=7.1"
$patchHeaders = $headers.Clone()
$patchHeaders['Content-Type'] = 'application/json-patch+json'

$body = @(
  @{ op = 'add'; path = '/fields/System.Title'; value = $testCase.title }
  @{ op = 'add'; path = '/fields/System.AreaPath'; value = $env:ADO_PROJECT }
  @{ op = 'add'; path = '/fields/Microsoft.VSTS.TCM.Steps'; value = $stepsXml }
  @{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.Priority'; value = $priority }
  @{ op = 'add'; path = '/fields/System.Tags'; value = "type:$($testCase.type); traces:$($testCase.tracesTo)" }
) | ConvertTo-Json -Depth 5

$created = Invoke-RestMethod -Uri $patchUrl -Method PATCH -Headers $patchHeaders -Body $body
```

Priority mapping: `high → 1`, `medium → 2`, `low → 3`.

#### Building the Steps XML

```powershell
function Build-AdoStepsXml([array]$steps) {
  $xml = '<steps id="0" last="{0}">' -f $steps.Count
  for ($i = 0; $i -lt $steps.Count; $i++) {
    $id     = $i + 1
    $action = [System.Security.SecurityElement]::Escape($steps[$i].action)
    $exp    = [System.Security.SecurityElement]::Escape($steps[$i].expected)
    $xml   += '<step id="{0}" type="ActionStep"><parameterizedString isformatted="true">{1}</parameterizedString><parameterizedString isformatted="true">{2}</parameterizedString><description/></step>' -f $id, $action, $exp
  }
  $xml += '</steps>'
  return $xml
}
```

### 6. Link a Test Case to a User Story ("Tested By")

```powershell
$linkUrl  = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/$($created.id)?api-version=7.1"
$linkBody = @(
  @{
    op    = 'add'
    path  = '/relations/-'
    value = @{
      rel = 'Microsoft.VSTS.Common.TestedBy-Reverse'
      url = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/$userStoryId"
    }
  }
) | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri $linkUrl -Method PATCH -Headers $patchHeaders -Body $linkBody
```

### 7. List Test Plans

```powershell
$url   = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/testplan/plans?api-version=7.1"
$plans = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
$plans.value | Select-Object id, name
```

### 8. List Suites in a Test Plan

```powershell
$url    = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/testplan/plans/$planId/suites?api-version=7.1"
$suites = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
$suites.value | Select-Object id, name
```

### 9. Add a Test Case to a Test Suite

```powershell
$url  = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/testplan/Plans/$planId/Suites/$suiteId/TestCase?api-version=7.1"
$body = @(@{ testCase = @{ id = "$($created.id)" } }) | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri $url -Method POST -Headers $patchHeaders -Body $body
```

**Suite fallback (no Test Plans license):** if creating the suite returns 401/403 for licensing, do **not** fail — instead link the test cases to the story via `TestedBy` only (free Basic), and tell the operator the suite was skipped. See `knowledge/ado-mapping.md`.

### 10. Seed the Worked-Example Story (setup, live only)

To reproduce the demo in a live org, `scripts/ado-seed-example.ps1` creates the `US200` user story (with its ACs and `state`) and prints the new work item ID. Seeding is a one-time demo-setup step, not part of the agent pipeline.

```powershell
.\scripts\ado-seed-example.ps1        # creates the story, prints its ID
```

---

## Safety Rules

### Absolute Prohibitions

- **Never issue a DELETE request** to any ADO endpoint.
- **Never delete, destroy, or permanently remove any work item** including test cases.
- **Never perform a force-overwrite** of existing test steps unless the operator explicitly confirmed the item to update.
- **Never expose the raw `ADO_PAT` value** in logs, responses, or file writes.

### Bulk Operation Protocol

When creating or modifying more than one work item:

1. Process the **first item only**.
2. **Show the operator the result** (title, ID, URL of the created/updated item).
3. **Wait for explicit confirmation** ("yes", "continue", "proceed") before processing the next item.
4. Repeat for each remaining item.

If the operator says "stop" or "cancel" at any point, halt all remaining items and summarize what was completed.

### Read-Only by Default

Prefer read operations. Only perform write operations when the calling agent or operator has explicitly requested a write.

---

## Error Handling

| HTTP Status | Meaning | Action |
|-------------|---------|--------|
| 401 | PAT invalid or expired | Stop; ask operator to rotate `ADO_PAT` |
| 403 | Insufficient scope | Stop; list the required PAT scopes |
| 404 | Work item not found | Stop; confirm the ID and project with operator |
| 429 | Rate limited | Wait 5 seconds; retry once |
| 5xx | ADO service error | Report error text to operator; do not retry automatically |
