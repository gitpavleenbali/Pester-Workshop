# ============================================================================
# PSCode Module 03 — Mastering Parameters
# SOURCE: PSCode/03_mastering_parameters/Azure-Parameter-Mastery.ps1
# TESTS:  New-AzureResourceDeployment, New-AzureVirtualMachine validation
#
# PESTER CONCEPTS: Testing Mandatory, ValidateSet, ValidateRange, ValidatePattern
# ============================================================================

# PESTER ▶ BeforeAll {}
# Runs ONCE before all tests. Dot-sources the helper script so all functions are available.
BeforeAll {
    # PESTER ▶ Dot-sourcing — loads functions from source into the test scope.
    . $PSScriptRoot/../src/AzureResourceHelpers.ps1
}

# PESTER ▶ Describe '...'
# Groups all parameter-validation tests together as one logical test suite.
Describe 'Module 03 · Parameter Validation Patterns' {

    # PESTER ▶ Context '...'
    # Organizes tests by scenario. Here: testing ValidateSet enforcement.
    # Context blocks can have their own BeforeAll/BeforeEach for scenario-specific setup.
    Context 'ValidateSet enforcement' {
        # PESTER ▶ Testing ValidateSet
        # ValidateSet is a PowerShell attribute that restricts a parameter to specific values.
        # Pester tests both the "happy path" (valid value accepted) and the "sad path" (invalid rejected).
        It 'Accepts valid location from ValidateSet' {
            Write-Host "  → PROPERTY: Verifying property value — Accepts valid location from ValidateSet" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-param' -Location 'westeurope'
            $rg.Location | Should -Be 'westeurope'
        }

        # PESTER ▶ Should -Throw
        # Wrapping the call in { } and piping to Should -Throw asserts the code throws.
        # ValidateSet causes PowerShell to throw BEFORE the function body even runs.
        It 'Rejects value not in ValidateSet' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects value not in ValidateSet" -ForegroundColor Gray
            { New-AzureResourceGroup -Name 'rg-x' -Location 'antarctica' } | Should -Throw
        }
    }

    # PESTER ▶ Context for default parameter values
    # Tests that omitting optional parameters uses the correct defaults.
    Context 'Default parameter values' {
        It 'Uses default location when omitted' {
            Write-Host "  → PROPERTY: Verifying property value — Uses default location when omitted" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-default'
            $rg.Location | Should -Be 'eastus'
        }

        # PESTER ▶ Should -Not -BeNullOrEmpty
        # Negated assertion — asserts the value is NOT null or empty.
        # The -Not flag inverts ANY Should operator.
        It 'Uses default tags when omitted' {
            Write-Host "  → PROPERTY: Verifying property value — Uses default tags when omitted" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-tags'
            $rg.Tags | Should -Not -BeNullOrEmpty
        }
    }

    # PESTER ▶ Context for Mandatory parameters
    # Testing Mandatory is special — you can't just omit the parameter because
    # PowerShell will PROMPT for it instead of throwing. The correct approach
    # is to inspect parameter METADATA using Get-Command.
    Context 'Mandatory parameters' {
        # PESTER ▶ Testing parameter metadata via Get-Command
        # Instead of calling the function without -Name (which prompts),
        # we inspect the parameter's [Parameter(Mandatory=$true)] attribute.
        # This is a Pester best practice for testing Mandatory parameters.
        It 'Name is mandatory' {
            Write-Host "  → Running: Name is mandatory" -ForegroundColor Gray
            $cmd = Get-Command New-AzureResourceGroup
            $nameParam = $cmd.Parameters['Name']
            $nameParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }
    }
}
