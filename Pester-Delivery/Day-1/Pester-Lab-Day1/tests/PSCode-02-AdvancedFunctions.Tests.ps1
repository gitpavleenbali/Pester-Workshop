# ============================================================================
# PSCode Module 02 — Advanced Functions: Azure Resource Manager
# SOURCE: PSCode/02_advanced_functions/Azure-Resource-Manager.ps1
# TESTS:  Get-AzureResourceSummary (mocked), New-AzureResourceGroup (simulated)
#
# PESTER CONCEPTS: Mock, ValidateSet, default parameters, PSCustomObject
# ============================================================================

# PESTER ▶ BeforeDiscovery {}
# Runs during the DISCOVERY phase (before any tests execute).
# Use it to dynamically generate test data that feeds into -ForEach or -TestCases.
# Code here runs BEFORE BeforeAll — it's for building the test plan, not for test setup.
BeforeDiscovery {
    $ValidLocations = @('eastus', 'westus', 'westeurope', 'eastus2')
}

# PESTER ▶ BeforeAll {}
# Runs ONCE before all tests in this file. Used here to dot-source the helper functions
# so every Describe/It block can call them. This is the Pester 5 way to load dependencies.
BeforeAll {
    # PESTER ▶ Dot-sourcing loads all functions from the file into the test's scope.
    . $PSScriptRoot/../../../../PSCode/02_advanced_functions/Azure-Resource-Manager.ps1
}

# PESTER ▶ Describe '...'
# Groups all tests for the Get-AzureResourceSummary function.
# Each Describe is an independent test suite with its own setup/teardown lifecycle.
Describe 'Module 02 · Get-AzureResourceSummary' {

    # PESTER ▶ BeforeEach + Mock
    # BeforeEach runs before EVERY It block, giving each test fresh mock data.
    # Mock replaces Get-AzResource with a fake that returns 2 controlled objects.
    BeforeEach {
        # PESTER ▶ Mock <Command> { <FakeBody> }
        # Intercepts calls to Get-AzResource and returns predictable fake data instead.
        Mock Get-AzResource {
            return @(
                [PSCustomObject]@{ Name = 'vm-01'; ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'sa-01'; ResourceType = 'Microsoft.Storage/storageAccounts' }
            )
        }
    }

    # PESTER ▶ AfterEach — runs after EVERY It block
    # Used for cleanup: reset variables, remove temp files, etc.
    # Here we demonstrate the pattern even though no cleanup is strictly needed.
    AfterEach {
        # Cleanup would go here, e.g.: Remove-Variable result -ErrorAction SilentlyContinue
    }

    # PESTER ▶ It '...' { <TestLogic> }
    # Each It is one test case. The string is the test name shown in results.
    # Should -Be asserts that the actual value equals the expected value (case-insensitive).
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

# PESTER ▶ Second Describe block — testing a DIFFERENT function in the same test file.
# New-AzureResourceGroup is a SIMULATED function — no Azure calls, no mocks needed.
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

    # PESTER ▶ -TestCases @( @{...}, @{...} )
    # Data-driven testing — runs the SAME It block multiple times with different input.
    # Each hashtable becomes one test run. <Location> in the test name gets replaced
    # with the actual value from the hashtable, so test output reads clearly.
    # The param() block inside It receives the hashtable keys as variables.
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

    # PESTER ▶ Should -Throw
    # Wrapping a call in { } (a scriptblock) and piping to Should -Throw
    # asserts that the code THROWS an exception. Here it verifies that
    # PowerShell's ValidateSet rejects 'mars' because it's not in the allowed list.
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

# PESTER ▶ Mocking with -ParameterFilter
# Get-VMStatus calls Get-AzVM internally, which MUST be mocked.
# Multiple mocks for the SAME command with -ParameterFilter let you return
# DIFFERENT results depending on which parameters the function passes.
Describe 'Module 02 · Get-VMStatus' {

    # PESTER ▶ BeforeAll with multiple Mock definitions
    # Each mock targets the same command (Get-AzVM) but with a different -ParameterFilter.
    # Pester checks filters top-to-bottom and uses the FIRST match.
    BeforeAll {
        # PESTER ▶ -ParameterFilter { $Name -eq 'vm-web' }
        # This mock only activates when the caller passes -Name 'vm-web'.
        # Other -Name values fall through to the next matching mock.
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } -ParameterFilter { $Name -eq 'vm-web' }

        # PESTER ▶ -ParameterFilter for 'vm-db' — returns deallocated state.
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } -ParameterFilter { $Name -eq 'vm-db' }

        # PESTER ▶ -ParameterFilter for 'vm-batch' — returns stopped state.
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/stopped'; DisplayStatus = 'VM stopped' }) }
        } -ParameterFilter { $Name -eq 'vm-batch' }

        # PESTER ▶ Catch-all mock — returns $null for any VM name not matched above.
        # This simulates a VM that doesn't exist in Azure.
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

    # PESTER ▶ Should -BeNullOrEmpty
    # Asserts the result is either $null, an empty string, or an empty collection.
    # Perfect for testing "not found" scenarios.
    It 'Returns null for a non-existent VM' {
        Write-Host "  → ASSERT: Checking return value — Returns null for a non-existent VM" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-ghost' | Should -BeNullOrEmpty
    }

    # PESTER ▶ Should -Invoke with -ParameterFilter
    # Proves that Get-AzVM was called with the EXACT parameter we specified.
    # Combines mock verification with parameter checking — ensures the function
    # passes the right arguments to the underlying command.
    It 'Calls Get-AzVM with the correct VM name' {
        Write-Host "  → Running: Calls Get-AzVM with the correct VM name" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-web' | Out-Null
        Should -Invoke Get-AzVM -ParameterFilter { $Name -eq 'vm-web' }
    }
}



