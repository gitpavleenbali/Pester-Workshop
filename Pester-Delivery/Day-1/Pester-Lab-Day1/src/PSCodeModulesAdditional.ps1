# ============================================================================
# Lab Source: Additional PSCode Module Extracts
# Covers: Module 01 (Knowledge Refresh), Module 07 (Git), Module 08 (Runspaces)
#
# TESTING NOTES:
#   Get-AzureResourceInsights calls Get-AzResource → must be mocked.
#   Test-GitEnvironment calls native 'git' executable → mocked with Mock git {}.
#   Deploy-ResourceGroup calls Get-AzResourceGroup + New-AzResourceGroup → mocked.
#   Get-AzureResourceCount and Invoke-ParallelWork are pure → no mocking needed.
#   See: tests/PSCode-01, PSCode-07, PSCode-08
# ============================================================================

# ── Module 01: Knowledge Refresh ────────────────────────────────────────

# TESTABILITY: Calls Get-AzResource → must be mocked.
# Mock returns controlled fake resources so we can verify the grouping logic.
# Tests check: Scope string, TotalResources count, UniqueTypes count.
# Uses BeforeEach to reset mock data before each It block.
# TESTED IN: PSCode-01-KnowledgeRefresh.Tests.ps1
function Get-AzureResourceInsights {
    <#
    .SYNOPSIS
        Analyzes Azure resources and returns insight summary.
    #>
    param(
        [string]$ResourceGroupName = $null,
        [switch]$ShowDetails
    )

    if ($ResourceGroupName) {
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        $scope = "Resource Group: $ResourceGroupName"
    } else {
        $resources = Get-AzResource
        $scope = "Subscription-wide"
    }

    return [PSCustomObject]@{
        Scope            = $scope
        TotalResources   = $resources.Count
        UniqueTypes      = ($resources | Group-Object ResourceType).Count
        TopResourceTypes = ($resources | Group-Object ResourceType | Sort-Object Count -Descending | Select-Object -First 3)
    }
}

# ── Module 07: Git Integration ──────────────────────────────────────────

# TESTABILITY: Calls the native 'git' executable → mocked with Mock git {}.
# Pester can mock ANY command, including native executables like git.exe.
# The mock uses switch($args[0]) to return different values for
# --version, config, and rev-parse subcommands.
# TESTED IN: PSCode-07-GitIntegration.Tests.ps1
function Test-GitEnvironment {
    <#
    .SYNOPSIS
        Checks if Git is installed and configured (safe version for testing).
    #>
    $result = @{
        GitInstalled = $false
        GitVersion   = $null
        UserName     = $null
        UserEmail    = $null
        InRepo       = $false
    }

    try {
        $ver = git --version 2>$null
        if ($ver) {
            $result.GitInstalled = $true
            $result.GitVersion   = $ver -replace 'git version ',''
        }
    } catch { }

    try {
        $result.UserName = git config user.name 2>$null
        $result.UserEmail = git config user.email 2>$null
    } catch { }

    try {
        $isRepo = git rev-parse --is-inside-work-tree 2>$null
        $result.InRepo = ($isRepo -eq 'true')
    } catch { }

    return [PSCustomObject]$result
}

# TESTABILITY: Calls Get-AzResourceGroup + New-AzResourceGroup → both mocked.
# Two Context blocks test the branching logic:
#   Context 1: Mock returns $null → RG doesn't exist → creates it (Status='Created')
#   Context 2: Mock returns object → RG exists → skips (Status='Exists')
# Should -Invoke -Times 0 verifies New-AzResourceGroup was NOT called in Context 2.
# TESTED IN: PSCode-07-GitIntegration.Tests.ps1
function Deploy-ResourceGroup {
    <#
    .SYNOPSIS
        Deploys an Azure resource group (creates or skips if exists).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Location = 'westeurope',

        [hashtable]$Tags = @{}
    )

    $rg = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue

    if (-not $rg) {
        $rg = New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags
        return [PSCustomObject]@{ Name = $Name; Status = 'Created'; Location = $Location }
    } else {
        return [PSCustomObject]@{ Name = $Name; Status = 'Exists'; Location = $rg.Location }
    }
}

# ── Module 08: Runspaces / Parallel ─────────────────────────────────────

# TESTABILITY: Pure function — no mocking needed.
# Returns a formatted string. Tests use Should -Be for exact match
# and Should -Match for substring/regex checks.
# TESTED IN: PSCode-08-Runspaces.Tests.ps1
function Get-AzureResourceCount {
    <#
    .SYNOPSIS
        Returns a resource count string for a given resource group.
        Simple function used to demo runspace injection.
    #>
    param([string]$ResourceGroup)
    "Found 42 resources in $ResourceGroup"
}

# TESTABILITY: Pure function that processes an array — no mocking needed.
# Tests verify: correct count, each item marked Processed=$true, item values.
# Edge cases tested: empty array input (PowerShell array unrolling gotcha),
# single item input. Note [AllowEmptyCollection()] attribute — without it,
# PowerShell's Mandatory validation would reject @() as empty.
# TESTED IN: PSCode-08-Runspaces.Tests.ps1
function Invoke-ParallelWork {
    <#
    .SYNOPSIS
        Simulates parallel processing of items (safe for testing).
    .PARAMETER Items
        Array of items to process.
    .PARAMETER ThrottleLimit
        Max concurrent operations.
    #>
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array]$Items,

        [int]$ThrottleLimit = 4
    )

    if ($Items.Count -eq 0) {
        return @()
    }

    $results = @()
    foreach ($item in $Items) {
        $results += [PSCustomObject]@{
            Item      = $item
            Processed = $true
            ThreadId  = [System.Threading.Thread]::CurrentThread.ManagedThreadId
        }
    }

    return $results
}
