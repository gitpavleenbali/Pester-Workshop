# ============================================================================
# PSCode Module 01 — Knowledge Refresh: Testable Functions
# SINGLE SOURCE OF TRUTH — tests dot-source this file directly.
# Contains: Get-AzureResourceInsights
# Tested by: PSCode-01-KnowledgeRefresh.Tests.ps1
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
