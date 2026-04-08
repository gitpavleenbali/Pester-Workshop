# ============================================================================
# PSCode Module 01 — Knowledge Refresh: Azure Cloud Analyzer
# SOURCE: PSCode/01_knowledge_refresh/Azure-Cloud-Analyzer.ps1
# TESTS:  Get-AzureResourceInsights (mocked Get-AzResource)
#
# PESTER CONCEPTS: Mock, Should -Be, BeforeEach, Context
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/PSCodeModulesAdditional.ps1
}

# PESTER: Mock Get-AzResource to avoid calling real Azure.
# The function groups resources by type and counts them.
Describe 'Module 01 · Get-AzureResourceInsights' {

    # PESTER: BeforeEach creates fresh mock data for every test
    BeforeEach {
        Mock Get-AzResource {
            return @(
                [PSCustomObject]@{ Name = 'vm-web-01';  ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'vm-db-01';   ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'sa-logs';    ResourceType = 'Microsoft.Storage/storageAccounts' }
                [PSCustomObject]@{ Name = 'kv-secrets'; ResourceType = 'Microsoft.KeyVault/vaults' }
            )
        }
    }

    Context 'Subscription-wide analysis (no ResourceGroupName)' {

        # PESTER: Should -Be checks the Scope property value
        It 'Sets scope to Subscription-wide' {
            Write-Host "  → Calling Get-AzureResourceInsights without -ResourceGroupName" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → Scope returned: '$($result.Scope)' — expecting 'Subscription-wide'" -ForegroundColor Gray
            $result.Scope | Should -Be 'Subscription-wide'
        }

        It 'Counts all 4 resources' {
            Write-Host "  → Mock returns 4 fake resources (2 VMs, 1 Storage, 1 KeyVault)" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → TotalResources: $($result.TotalResources) — expecting 4" -ForegroundColor Gray
            $result.TotalResources | Should -Be 4
        }

        # PESTER: Group-Object produces unique type groups
        It 'Identifies 3 unique resource types' {
            Write-Host "  → 4 resources across 3 types: Compute, Storage, KeyVault" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → UniqueTypes: $($result.UniqueTypes) — expecting 3" -ForegroundColor Gray
            $result.UniqueTypes | Should -Be 3
        }

        # PESTER: Should -Invoke proves the mock was used (not real Azure)
        It 'Called Get-AzResource (not real Azure)' {
            Write-Host "  → Running function and verifying the mock was invoked" -ForegroundColor Gray
            Get-AzureResourceInsights | Out-Null
            Write-Host "  → Should -Invoke confirms Get-AzResource was called 1 time" -ForegroundColor Gray
            Should -Invoke Get-AzResource -Times 1
        }
    }

    Context 'With empty subscription' {
        BeforeEach {
            Mock Get-AzResource { return @() }
        }

        It 'Returns TotalResources = 0' {
            Write-Host "  → Mock returns empty array — simulating empty subscription" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → TotalResources: $($result.TotalResources) — expecting 0" -ForegroundColor Gray
            $result.TotalResources | Should -Be 0
        }
    }
}
