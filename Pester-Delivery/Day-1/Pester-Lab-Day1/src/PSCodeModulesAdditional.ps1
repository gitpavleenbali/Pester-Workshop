# ============================================================================
# Lab Source: Additional PSCode Module Extracts
# Covers: Module 01 (Knowledge Refresh), Module 07 (Git), Module 08 (Runspaces)
# ============================================================================

# ── Module 01: Knowledge Refresh ────────────────────────────────────────

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

function Get-AzureResourceCount {
    <#
    .SYNOPSIS
        Returns a resource count string for a given resource group.
        Simple function used to demo runspace injection.
    #>
    param([string]$ResourceGroup)
    "Found 42 resources in $ResourceGroup"
}

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
