# ============================================================================
# PSCode Module 01 — Knowledge Refresh: Azure Cloud Analyzer
# SOURCE: PSCode/01_knowledge_refresh/Azure-Cloud-Analyzer.ps1
# TESTS:  Get-AzureResourceInsights (mocked Get-AzResource)
#
# PESTER CONCEPTS: Mock, Should -Be, BeforeEach, Context
# ============================================================================

# PESTER ▶ BeforeAll {}
# Runs ONCE before all tests in this file (or Describe/Context block).
# Ideal for one-time setup: dot-sourcing scripts, importing modules, creating shared test data.
# Code here runs during Pester's RUN phase (after discovery).
BeforeAll {
    # PESTER ▶ Dot-sourcing (. operator)
    # Loads functions from the source file into the current scope so they can be tested.
    # $PSScriptRoot = directory of THIS test file; we navigate to ../src/ for the source code.
    . $PSScriptRoot/../src/PSCodeModulesAdditional.ps1
}

# PESTER ▶ Describe '...'
# The top-level grouping block — represents a test suite for one feature or function.
# All related tests, Contexts, and setup/teardown blocks live inside Describe.
Describe 'Module 01 · Get-AzureResourceInsights' {

    # PESTER ▶ BeforeEach {}
    # Runs BEFORE EVERY individual It block inside this Describe.
    # Ensures each test starts with a clean, identical state — no test can "pollute" the next.
    # Here we re-create the Mock before every test so each It gets a fresh fake.
    BeforeEach {
        # PESTER ▶ Mock <CommandName> { <FakeBody> }
        # Replaces the real Get-AzResource cmdlet with a fake that returns controlled data.
        # This means tests NEVER call Azure — they are fast, offline, and deterministic.
        # The scriptblock { ... } is what runs instead of the real command.
        Mock Get-AzResource {
            return @(
                [PSCustomObject]@{ Name = 'vm-web-01';  ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'vm-db-01';   ResourceType = 'Microsoft.Compute/virtualMachines' }
                [PSCustomObject]@{ Name = 'sa-logs';    ResourceType = 'Microsoft.Storage/storageAccounts' }
                [PSCustomObject]@{ Name = 'kv-secrets'; ResourceType = 'Microsoft.KeyVault/vaults' }
            )
        }
    }

    # PESTER ▶ Context '...'
    # A sub-group inside Describe — organizes tests into logical scenarios.
    # Each Context can have its own BeforeAll/BeforeEach to set up scenario-specific state.
    # Think of it as "When [this scenario], then [these expectations]".
    Context 'Subscription-wide analysis (no ResourceGroupName)' {

        # PESTER ▶ It '...' { }
        # A single test case — the smallest unit of testing in Pester.
        # The string describes WHAT the test verifies. The scriptblock contains the test logic.
        # If any assertion (Should) fails inside It, the test is marked as FAILED.
        It 'Sets scope to Subscription-wide' {
            Write-Host "  → Calling Get-AzureResourceInsights without -ResourceGroupName" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → Scope returned: '$($result.Scope)' — expecting 'Subscription-wide'" -ForegroundColor Gray
            # PESTER ▶ Should -Be <ExpectedValue>
            # The core assertion — compares actual output (left side of pipe) to the expected value.
            # If they don't match, the test FAILS with a clear message showing actual vs expected.
            # -Be is case-INSENSITIVE. Use -BeExactly for case-sensitive comparison.
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

        # PESTER ▶ Should -Invoke <MockedCommand> -Times <N>
        # Verifies that a mocked command was actually called during the test.
        # -Times 1 means "exactly 1 call". Without -Exactly, it means "at least 1".
        # This proves our function used the mock (not a real Azure call).
        It 'Called Get-AzResource (not real Azure)' {
            Write-Host "  → Running function and verifying the mock was invoked" -ForegroundColor Gray
            Get-AzureResourceInsights | Out-Null
            Write-Host "  → Should -Invoke confirms Get-AzResource was called 1 time" -ForegroundColor Gray
            Should -Invoke Get-AzResource -Times 1
        }
    }

    # PESTER ▶ Context-scoped Mock Override
    # This inner Context defines its OWN Mock for Get-AzResource, overriding the parent's.
    # Pester uses the most specific (innermost) mock — so tests HERE get an empty array
    # while tests in the sibling Context above still get the 4-resource dataset.
    Context 'With empty subscription' {
        BeforeEach {
            # PESTER ▶ Mock override — returns empty array to simulate an empty subscription.
            Mock Get-AzResource { return @() }
        }

        It 'Returns TotalResources = 0' {
            Write-Host "  → Mock returns empty array — simulating empty subscription" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            Write-Host "  → TotalResources: $($result.TotalResources) — expecting 0" -ForegroundColor Gray
            $result.TotalResources | Should -Be 0
        }
    }

    # PESTER ▶ Additional Should operators demonstrated
    Context 'Additional assertion operators' {
        BeforeEach {
            Mock Get-AzResource {
                return @(
                    [PSCustomObject]@{ Name = 'vm-Web-01'; ResourceType = 'Microsoft.Compute/virtualMachines' }
                    [PSCustomObject]@{ Name = 'sa-Logs';   ResourceType = 'Microsoft.Storage/storageAccounts' }
                )
            }
        }

        # PESTER ▶ Should -BeExactly — case-SENSITIVE equality
        # Unlike -Be (case-insensitive), -BeExactly fails if casing differs.
        It 'Scope is exactly "Subscription-wide" (case-sensitive)' {
            Write-Host "  → Using Should -BeExactly for case-sensitive check" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            $result.Scope | Should -BeExactly 'Subscription-wide'
        }

        # PESTER ▶ Should -BeLike — wildcard match (like PowerShell's -like)
        It 'Scope starts with "Subscription" (wildcard match)' {
            Write-Host "  → Using Should -BeLike for wildcard pattern" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            $result.Scope | Should -BeLike 'Subscription*'
        }

        # PESTER ▶ Should -Contain — asserts a collection contains a specific value
        It 'Resource names contain "vm-Web-01"' {
            Write-Host "  → Using Should -Contain to check collection membership" -ForegroundColor Gray
            $resources = (Get-AzResource).Name
            $resources | Should -Contain 'vm-Web-01'
        }

        # PESTER ▶ Should -BeIn — asserts a value is in a collection (reverse of -Contain)
        It 'Scope value is in allowed scopes list' {
            Write-Host "  → Using Should -BeIn to check value exists in allowed list" -ForegroundColor Gray
            $result = Get-AzureResourceInsights
            $result.Scope | Should -BeIn @('Subscription-wide', 'Resource Group: rg-prod')
        }
    }
}

