# ============================================================================
# PSCode Module 02 — Advanced Functions: Azure Resource Manager
# SOURCE: PSCode/02_advanced_functions/Azure-Resource-Manager.ps1
# TESTS:  Get-AzureResourceSummary (mocked), New-AzureResourceGroup (simulated)
#
# PESTER CONCEPTS: Mock, ValidateSet, default parameters, PSCustomObject
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/AzureResourceHelpers.ps1
}

Describe 'Module 02 · Get-AzureResourceSummary' {

    BeforeEach {
        # PESTER: Mock returns controlled fake data
        Mock Get-AzResource {
            return @(
                [PSCustomObject]@{ Name = 'vm-01'; ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'sa-01'; ResourceType = 'Microsoft.Storage/storageAccounts' }
            )
        }
    }

    It 'Returns correct resource count' {
        Write-Host "  → ASSERT: Checking return value — Returns correct resource count" -ForegroundColor Gray
        $result = Get-AzureResourceSummary
        $result.TotalResources | Should -Be 2
    }

    It 'Returns correct number of unique types' {
        Write-Host "  → ASSERT: Checking return value — Returns correct number of unique types" -ForegroundColor Gray
        $result = Get-AzureResourceSummary
        $result.ResourceTypes | Should -Be 2
    }

    It 'Returns first resource name' {
        Write-Host "  → ASSERT: Checking return value — Returns first resource name" -ForegroundColor Gray
        $result = Get-AzureResourceSummary
        $result.FirstResource | Should -Be 'vm-01'
    }

    It 'Sets scope to Subscription-wide when no RG specified' {
        Write-Host "  → PROPERTY: Verifying property value — Sets scope to Subscription-wide when no RG specified" -ForegroundColor Gray
        $result = Get-AzureResourceSummary
        $result.Scope | Should -Be 'Subscription-wide'
    }
}

# PESTER: New-AzureResourceGroup is a SIMULATED function — no Azure calls.
# Perfect for testing parameter validation, defaults, and return objects.
Describe 'Module 02 · New-AzureResourceGroup' {

    It 'Creates RG with correct name' {
        Write-Host "  → Running: Creates RG with correct name" -ForegroundColor Gray
        $rg = New-AzureResourceGroup -Name 'rg-test' -Location 'westeurope'
        $rg.ResourceGroupName | Should -Be 'rg-test'
    }

    It 'Uses default location (eastus) when not specified' {
        Write-Host "  → PROPERTY: Verifying property value — Uses default location (eastus) when not specified" -ForegroundColor Gray
        $rg = New-AzureResourceGroup -Name 'rg-default'
        $rg.Location | Should -Be 'eastus'
    }

    It 'Sets ProvisioningState to Succeeded' {
        Write-Host "  → PROPERTY: Verifying property value — Sets ProvisioningState to Succeeded" -ForegroundColor Gray
        $rg = New-AzureResourceGroup -Name 'rg-state'
        $rg.ProvisioningState | Should -Be 'Succeeded'
    }

    # PESTER: -TestCases tests ALL valid locations from ValidateSet
    It 'Accepts valid location <Location>' -TestCases @(
        Write-Host "  → Running: Accepts valid location <Location>" -ForegroundColor Gray
        @{ Location = 'eastus' }
        @{ Location = 'westus' }
        @{ Location = 'westeurope' }
        @{ Location = 'eastus2' }
    ) {
        param($Location)
        $rg = New-AzureResourceGroup -Name 'rg-loc' -Location $Location
        $rg.Location | Should -Be $Location
    }

    # PESTER: Should -Throw verifies ValidateSet rejects invalid values
    It 'Rejects invalid location' {
        Write-Host "  → ERROR TEST: Expecting exception — Rejects invalid location" -ForegroundColor Gray
        { New-AzureResourceGroup -Name 'rg-x' -Location 'mars' } | Should -Throw
    }

    It 'Preserves custom tags' {
        Write-Host "  → Running: Preserves custom tags" -ForegroundColor Gray
        $tags = @{ Team = 'Platform'; Env = 'Dev' }
        $rg = New-AzureResourceGroup -Name 'rg-tags' -Tags $tags
        $rg.Tags.Team | Should -Be 'Platform'
        $rg.Tags.Env | Should -Be 'Dev'
    }
}

# PESTER: Get-VMStatus calls Get-AzVM which MUST be mocked.
# Uses ParameterFilter to return different results per VM name.
Describe 'Module 02 · Get-VMStatus' {

    BeforeAll {
        # PESTER: Three mocks for the same command — different ParameterFilter each
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } -ParameterFilter { $Name -eq 'vm-web' }

        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } -ParameterFilter { $Name -eq 'vm-db' }

        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/stopped'; DisplayStatus = 'VM stopped' }) }
        } -ParameterFilter { $Name -eq 'vm-batch' }

        Mock Get-AzVM { return $null } -ParameterFilter { $Name -eq 'vm-ghost' }
    }

    It 'Returns Running for a running VM' {
        Write-Host "  → ASSERT: Checking return value — Returns Running for a running VM" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-web' | Should -Be 'Running'
    }

    It 'Returns Deallocated for a deallocated VM' {
        Write-Host "  → ASSERT: Checking return value — Returns Deallocated for a deallocated VM" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-db' | Should -Be 'Deallocated'
    }

    It 'Returns Stopped for a stopped VM' {
        Write-Host "  → ASSERT: Checking return value — Returns Stopped for a stopped VM" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-batch' | Should -Be 'Stopped'
    }

    It 'Returns null for a non-existent VM' {
        Write-Host "  → ASSERT: Checking return value — Returns null for a non-existent VM" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-ghost' | Should -BeNullOrEmpty
    }

    It 'Calls Get-AzVM with the correct VM name' {
        Write-Host "  → Running: Calls Get-AzVM with the correct VM name" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-web' | Out-Null
        Should -Invoke Get-AzVM -ParameterFilter { $Name -eq 'vm-web' }
    }
}
