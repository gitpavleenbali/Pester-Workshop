# ============================================================================
# PSCode Module 03 — Mastering Parameters
# SOURCE: PSCode/03_mastering_parameters/Azure-Parameter-Mastery.ps1
# TESTS:  New-AzureResourceDeployment, New-AzureVirtualMachine validation
#
# PESTER CONCEPTS: Testing Mandatory, ValidateSet, ValidateRange, ValidatePattern
# ============================================================================

BeforeAll {
    # Functions extracted into src that test parameter patterns
    . $PSScriptRoot/../src/AzureResourceHelpers.ps1
}

# PESTER: Testing parameter validation — these functions SIMULATE deployments
# so we can test the parameter attributes without hitting Azure.
Describe 'Module 03 · Parameter Validation Patterns' {

    Context 'ValidateSet enforcement' {
        # PESTER: ValidateSet restricts allowed values at the PowerShell engine level
        It 'Accepts valid location from ValidateSet' {
            Write-Host "  → PROPERTY: Verifying property value — Accepts valid location from ValidateSet" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-param' -Location 'westeurope'
            $rg.Location | Should -Be 'westeurope'
        }

        It 'Rejects value not in ValidateSet' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects value not in ValidateSet" -ForegroundColor Gray
            { New-AzureResourceGroup -Name 'rg-x' -Location 'antarctica' } | Should -Throw
        }
    }

    Context 'Default parameter values' {
        It 'Uses default location when omitted' {
            Write-Host "  → PROPERTY: Verifying property value — Uses default location when omitted" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-default'
            $rg.Location | Should -Be 'eastus'
        }

        It 'Uses default tags when omitted' {
            Write-Host "  → PROPERTY: Verifying property value — Uses default tags when omitted" -ForegroundColor Gray
            $rg = New-AzureResourceGroup -Name 'rg-tags'
            $rg.Tags | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Mandatory parameters' {
        # PESTER: Mandatory parameters PROMPT instead of throwing in interactive mode.
        # The correct way to test Mandatory is to check the parameter metadata.
        It 'Name is mandatory' {
            Write-Host "  → Running: Name is mandatory" -ForegroundColor Gray
            $cmd = Get-Command New-AzureResourceGroup
            $nameParam = $cmd.Parameters['Name']
            $nameParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                ForEach-Object { $_.Mandatory | Should -Be $true }
        }
    }
}
