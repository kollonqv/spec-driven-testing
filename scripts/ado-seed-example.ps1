<#
.SYNOPSIS
    Seed the worked-example user story (US200 — Reinvention Services top nav) into a live ADO project.
.DESCRIPTION
    Demo-setup helper (LIVE mode only). Creates a User Story work item with the
    three acceptance criteria and sets its state, so the automation phase demo
    has a real, Closed story to run against. Prints the new work item ID.

    This is NOT part of the agent pipeline — it just reproduces the offline
    example (examples/reinvention-services-nav/user-story.md) in a live org.
.PARAMETER State
    Workflow state to set after creation. Default 'Closed' so the automation
    orchestrator's state gate passes. Use 'Active' to demo the gate refusing.
.EXAMPLE
    .\ado-seed-example.ps1
    .\ado-seed-example.ps1 -State Active
.NOTES
    Required environment variables:
      ADO_PAT      - PAT with Work Items (Read & Write)
      ADO_ORG_URL  - e.g. https://dev.azure.com/myorg
      ADO_PROJECT  - e.g. DemoProject
#>
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('New', 'Active', 'Resolved', 'Closed')]
    [string]$State = 'Closed'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($var in @('ADO_PAT', 'ADO_ORG_URL', 'ADO_PROJECT')) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        throw "Environment variable '$var' is not set. This script requires LIVE mode."
    }
}

$base64Pat    = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$env:ADO_PAT"))
$patchHeaders = @{
    Authorization  = "Basic $base64Pat"
    'Content-Type' = 'application/json-patch+json'
}

$title = 'Reinvention Services — top navigation bar'

# Acceptance criteria as HTML (ADO stores this field as HTML).
$acHtml = @'
<div><b>AC-1 — Navigation items present</b><br/>
Given I am on the Reinvention Services page, when the page has loaded, then the top navigation bar displays these five items in order: Reinvention Partners, Reinvention Engines, Client Success, Industries, Client Stories.</div>
<div><br/><b>AC-2 — Click scrolls to the corresponding section and shows its header</b><br/>
Given I am on the page, when I click any top-nav item, then the page scrolls to that item's section and shows its header (Reinvention Partners->Reinvention Partners; Reinvention Engines->Reinvention Engines; Client Success->Client Success; Industries->We bring deep industry expertise; Client Stories->We make reinvention real).</div>
<div><br/><b>AC-3 — Hover underlines</b><br/>
Given I am on the page, when I hover over any top-nav item, then that item's text becomes underlined (and is not underlined by default).</div>
'@

$description = 'As a visitor to the Reinvention Services page, I want a persistent top navigation bar with links to the key sections, with clear hover feedback, so I can orient myself and move between sections.'

$createBody = @(
    @{ op = 'add'; path = '/fields/System.Title'; value = $title }
    @{ op = 'add'; path = '/fields/System.Description'; value = $description }
    @{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.AcceptanceCriteria'; value = $acHtml }
    @{ op = 'add'; path = '/fields/System.Tags'; value = 'demo; spec-driven-testing' }
) | ConvertTo-Json -Depth 5

$createUrl = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/`$User%20Story?api-version=7.1"
$created   = Invoke-RestMethod -Uri $createUrl -Method PATCH -Headers $patchHeaders -Body $createBody

Write-Host "Created User Story $($created.id): $title"

# Set the state in a second call (state transitions can require the item to exist first).
if ($State -ne 'New') {
    $stateBody = @(@{ op = 'add'; path = '/fields/System.State'; value = $State }) | ConvertTo-Json -Depth 5
    $stateUrl  = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/$($created.id)?api-version=7.1"
    $updated   = Invoke-RestMethod -Uri $stateUrl -Method PATCH -Headers $patchHeaders -Body $stateBody
    Write-Host "State set to: $($updated.fields.'System.State')"
}

Write-Host ""
Write-Host "Story ID $($created.id) — use it with the agents, e.g.:"
Write-Host "  design:     Use the test-creator-agent for $($created.id)"
Write-Host "  automation: Use the test-automation-orchestrator-agent for $($created.id)"
