<#
.SYNOPSIS
    Fetch work items, test cases, and test plans from Azure DevOps.
.DESCRIPTION
    Example reference script for the ado-skill. Demonstrates authentication,
    fetching user stories and their linked test cases, parsing step XML, listing
    test plans/suites, and exporting steps to CSV.
.PARAMETER Operation
    FetchWorkItem   - fetch a single work item and its acceptance criteria
    FetchTestCases  - fetch all test cases linked to a user story
    ListPlans       - list all test plans in the project
    ListSuites      - list all suites in a test plan (requires -PlanId)
    ExportCsv       - export test case steps for a user story to a CSV file
.PARAMETER WorkItemId
    ADO work item ID (user story). Required for FetchWorkItem, FetchTestCases, ExportCsv.
.PARAMETER PlanId
    Test plan ID. Required for ListSuites.
.PARAMETER OutputPath
    Path for the exported CSV file. Defaults to reports\US{id}_testcases.csv.
.EXAMPLE
    .\ado-fetch-example.ps1 -Operation FetchWorkItem -WorkItemId 123
    .\ado-fetch-example.ps1 -Operation FetchTestCases -WorkItemId 123
    .\ado-fetch-example.ps1 -Operation ListPlans
    .\ado-fetch-example.ps1 -Operation ListSuites -PlanId 456
    .\ado-fetch-example.ps1 -Operation ExportCsv -WorkItemId 123
.NOTES
    Required environment variables:
      ADO_PAT      - Personal Access Token (Work Items + Test Management read scope)
      ADO_ORG_URL  - e.g. https://dev.azure.com/myorg
      ADO_PROJECT  - e.g. MyProject
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('FetchWorkItem', 'FetchTestCases', 'ListPlans', 'ListSuites', 'ExportCsv')]
    [string]$Operation,

    [Parameter(Mandatory = $false)]
    [int]$WorkItemId,

    [Parameter(Mandatory = $false)]
    [int]$PlanId,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

function Get-AdoHeaders {
    foreach ($var in @('ADO_PAT', 'ADO_ORG_URL', 'ADO_PROJECT')) {
        if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
            throw "Environment variable '$var' is not set. Set it before running this script."
        }
    }
    $base64Pat = [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes(":$env:ADO_PAT")
    )
    return @{
        'Authorization' = "Basic $base64Pat"
        'Content-Type'  = 'application/json'
    }
}

# ---------------------------------------------------------------------------
# Work item fetch
# ---------------------------------------------------------------------------

function Get-AdoWorkItem {
    param([int]$Id, [hashtable]$Headers)

    $url = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems/$($Id)?`$expand=all&api-version=7.1"
    return Invoke-RestMethod -Uri $url -Headers $Headers -Method GET
}

function Get-AdoWorkItemsById {
    param([int[]]$Ids, [hashtable]$Headers)

    $idList = $Ids -join ','
    $url    = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/wit/workitems?ids=$idList&`$expand=all&api-version=7.1"
    $result = Invoke-RestMethod -Uri $url -Headers $Headers -Method GET
    return $result.value
}

# ---------------------------------------------------------------------------
# Test case helpers
# ---------------------------------------------------------------------------

function Get-LinkedTestCaseIds {
    param([psobject]$WorkItem)

    if (-not $WorkItem.relations) { return @() }
    return $WorkItem.relations |
        Where-Object { $_.rel -eq 'Microsoft.VSTS.Common.TestedBy-Forward' } |
        ForEach-Object { [int]($_.url -split '/')[-1] }
}

function ConvertFrom-AdoStepsXml {
    param([string]$StepsXml)

    if ([string]::IsNullOrWhiteSpace($StepsXml)) { return @() }

    [xml]$doc   = $StepsXml
    $steps      = @()
    $stepNumber = 0

    foreach ($step in $doc.steps.step) {
        $stepNumber++
        $action   = $step.'parameterizedString'[0].'#text'
        $expected = $step.'parameterizedString'[1].'#text'
        $steps += [PSCustomObject]@{
            StepNumber = $stepNumber
            Action     = $action
            Expected   = $expected
        }
    }
    return $steps
}

function Get-PriorityLabel {
    param([int]$Priority)
    switch ($Priority) {
        1 { 'high' }
        2 { 'medium' }
        3 { 'low' }
        default { 'medium' }
    }
}

# ---------------------------------------------------------------------------
# Test plans / suites
# ---------------------------------------------------------------------------

function Get-AdoTestPlans {
    param([hashtable]$Headers)

    $url    = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/testplan/plans?api-version=7.1"
    $result = Invoke-RestMethod -Uri $url -Headers $Headers -Method GET
    return $result.value
}

function Get-AdoTestSuites {
    param([int]$PlanId, [hashtable]$Headers)

    $url    = "$env:ADO_ORG_URL/$env:ADO_PROJECT/_apis/testplan/plans/$PlanId/suites?api-version=7.1"
    $result = Invoke-RestMethod -Uri $url -Headers $Headers -Method GET
    return $result.value
}

# ---------------------------------------------------------------------------
# CSV export
# ---------------------------------------------------------------------------

function Export-TestCasesToCsv {
    param(
        [psobject[]]$TestCases,
        [int]$UserStoryId,
        [string]$Path
    )

    $rows = foreach ($tc in $TestCases) {
        $steps    = ConvertFrom-AdoStepsXml -StepsXml $tc.fields.'Microsoft.VSTS.TCM.Steps'
        $priority = Get-PriorityLabel -Priority ([int]$tc.fields.'Microsoft.VSTS.Common.Priority')
        $tags     = $tc.fields.'System.Tags'
        $isFirst  = $true

        foreach ($step in $steps) {
            [PSCustomObject]@{
                TestCaseId    = if ($isFirst) { $tc.id } else { '' }
                TestCaseTitle = if ($isFirst) { $tc.fields.'System.Title' } else { '' }
                Priority      = if ($isFirst) { $priority } else { '' }
                Tags          = if ($isFirst) { $tags } else { '' }
                StepNumber    = $step.StepNumber
                Action        = $step.Action
                Expected      = $step.Expected
            }
            $isFirst = $false
        }
    }

    $rows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    Write-Host "Exported $($TestCases.Count) test case(s) to: $Path"
}

# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------

$headers = Get-AdoHeaders

switch ($Operation) {

    'FetchWorkItem' {
        if (-not $WorkItemId) { throw '-WorkItemId is required for FetchWorkItem.' }

        $wi = Get-AdoWorkItem -Id $WorkItemId -Headers $headers

        Write-Host "`nWork Item $($wi.id): $($wi.fields.'System.Title')"
        Write-Host "Type  : $($wi.fields.'System.WorkItemType')"
        Write-Host "State : $($wi.fields.'System.State')"

        $ac = $wi.fields.'Microsoft.VSTS.Common.AcceptanceCriteria'
        if ($ac) {
            # Strip HTML tags for readable output
            $plainAc = $ac -replace '<[^>]+>', '' -replace '&nbsp;', ' ' -replace '&#160;', ' '
            Write-Host "`nAcceptance Criteria:`n$plainAc"
        } else {
            Write-Host "`n(No acceptance criteria found)"
        }
    }

    'FetchTestCases' {
        if (-not $WorkItemId) { throw '-WorkItemId is required for FetchTestCases.' }

        $wi  = Get-AdoWorkItem -Id $WorkItemId -Headers $headers
        $ids = Get-LinkedTestCaseIds -WorkItem $wi

        if ($ids.Count -eq 0) {
            Write-Host "No test cases linked to work item $WorkItemId."
            break
        }

        Write-Host "`nFound $($ids.Count) test case(s) linked to US$WorkItemId:`n"
        $tcs = Get-AdoWorkItemsById -Ids $ids -Headers $headers

        foreach ($tc in $tcs) {
            $priority = Get-PriorityLabel -Priority ([int]$tc.fields.'Microsoft.VSTS.Common.Priority')
            Write-Host "TC $($tc.id) [$priority] : $($tc.fields.'System.Title')"

            $steps = ConvertFrom-AdoStepsXml -StepsXml $tc.fields.'Microsoft.VSTS.TCM.Steps'
            foreach ($step in $steps) {
                Write-Host "  $($step.StepNumber). $($step.Action)"
                Write-Host "     Expected: $($step.Expected)"
            }
            Write-Host ''
        }
    }

    'ListPlans' {
        $plans = Get-AdoTestPlans -Headers $headers
        if ($plans.Count -eq 0) {
            Write-Host "No test plans found in project '$env:ADO_PROJECT'."
            break
        }
        Write-Host "`nTest Plans in '$env:ADO_PROJECT':`n"
        $plans | Select-Object id, name, @{n='state';e={$_.state}} |
            Format-Table -AutoSize
    }

    'ListSuites' {
        if (-not $PlanId) { throw '-PlanId is required for ListSuites.' }

        $suites = Get-AdoTestSuites -PlanId $PlanId -Headers $headers
        if ($suites.Count -eq 0) {
            Write-Host "No suites found in plan $PlanId."
            break
        }
        Write-Host "`nSuites in Plan $PlanId:`n"
        $suites | Select-Object id, name, suiteType | Format-Table -AutoSize
    }

    'ExportCsv' {
        if (-not $WorkItemId) { throw '-WorkItemId is required for ExportCsv.' }

        $wi  = Get-AdoWorkItem -Id $WorkItemId -Headers $headers
        $ids = Get-LinkedTestCaseIds -WorkItem $wi

        if ($ids.Count -eq 0) {
            Write-Host "No test cases linked to work item $WorkItemId — nothing to export."
            break
        }

        $tcs  = Get-AdoWorkItemsById -Ids $ids -Headers $headers
        $path = if ($OutputPath) { $OutputPath } else {
            Join-Path 'reports' "US${WorkItemId}_testcases.csv"
        }

        $dir = Split-Path $path -Parent
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

        Export-TestCasesToCsv -TestCases $tcs -UserStoryId $WorkItemId -Path $path
    }
}
