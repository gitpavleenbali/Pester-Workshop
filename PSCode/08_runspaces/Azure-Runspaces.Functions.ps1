# ============================================================================
# PSCode Module 08 — Runspaces: Testable Functions
# SINGLE SOURCE OF TRUTH — tests dot-source this file directly.
# Contains: Get-AzureResourceCount, Invoke-ParallelWork
# Tested by: PSCode-08-Runspaces.Tests.ps1
# ============================================================================

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
