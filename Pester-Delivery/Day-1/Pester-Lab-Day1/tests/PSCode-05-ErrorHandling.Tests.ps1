# ============================================================================
# PSCode Module 05 — Error Handling
# SOURCE: PSCode/05_error_handling/Azure-Error-Handling-Training.ps1
# TESTS:  Deploy-AzureResourceWithValidation (input validation + mocked Azure)
#
# PESTER CONCEPTS: Should -Throw with wildcards, Mock override per Context
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/PSCodeModuleExtracts.ps1
}

Describe 'Module 05 · Deploy-AzureResourceWithValidation' {

    # PESTER: Mock Azure cmdlets — function validates THEN calls Azure
    BeforeAll {
        Mock Get-AzResourceGroup { return @{ ResourceGroupName = 'rg-prod' } }
        Mock New-AzResource { return @{ ProvisioningState = 'Succeeded' } }
    }

    Context 'Valid deployment' {
        It 'Returns Deployed status' {
            Write-Host "  → ASSERT: Checking return value — Returns Deployed status" -ForegroundColor Gray
            $r = Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-prod' -ResourceName 'storage01'
            $r.Status | Should -Be 'Deployed'
        }

        # PESTER: Should -Invoke verifies the function checked the RG first
        It 'Validates RG exists before deploying' {
            Write-Host "  → Running: Validates RG exists before deploying" -ForegroundColor Gray
            Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-prod' -ResourceName 'myres' | Out-Null
            Should -Invoke Get-AzResourceGroup
        }
    }

    Context 'Input validation failures' {
        # PESTER: Should -Throw '*pattern*' — wildcard matches error message
        It 'Rejects name < 3 chars' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects name < 3 chars" -ForegroundColor Gray
            { Deploy-AzureResourceWithValidation -ResourceGroupName 'rg' -ResourceName 'ab' } |
                Should -Throw '*3 characters*'
        }

        It 'Rejects special characters in name' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects special characters in name" -ForegroundColor Gray
            { Deploy-AzureResourceWithValidation -ResourceGroupName 'rg' -ResourceName 'my@vm!' } |
                Should -Throw '*invalid characters*'
        }

        It 'Rejects names with spaces' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects names with spaces" -ForegroundColor Gray
            { Deploy-AzureResourceWithValidation -ResourceGroupName 'rg' -ResourceName 'my resource' } |
                Should -Throw '*invalid characters*'
        }
    }

    Context 'Resource group not found' {
        BeforeAll {
            # PESTER: Override mock for this Context — RG not found
            Mock Get-AzResourceGroup { return $null }
        }

        It 'Throws when RG does not exist' {
            Write-Host "  → ERROR TEST: Expecting exception — Throws when RG does not exist" -ForegroundColor Gray
            { Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-gone' -ResourceName 'storage01' } |
                Should -Throw '*does not exist*'
        }
    }
}
