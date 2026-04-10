# ============================================================================
# PSCode Module 05 — Error Handling
# SOURCE: PSCode/05_error_handling/Azure-Error-Handling.ps1
# TESTS:  Deploy-AzureResourceWithValidation (input validation + mocked Azure)
#
# PESTER CONCEPTS: Should -Throw with wildcards, Mock override per Context
# ============================================================================

# PESTER ▶ BeforeAll {}
# Loads the source functions once before all tests in this file.
BeforeAll {
    . $PSScriptRoot/../../../PSCode-Source/05_error_handling/Azure-Error-Handling.ps1
}

# PESTER ▶ Describe '...'
# Test suite for the Deploy-AzureResourceWithValidation function.
# This function validates input THEN calls Azure — mocks prevent real API calls.
Describe 'Module 05 · Deploy-AzureResourceWithValidation' {

    # PESTER ▶ BeforeAll with Mocks at Describe level
    # These mocks apply to ALL Contexts/It blocks inside this Describe.
    # Inner Contexts can OVERRIDE these with their own mocks (see below).
    BeforeAll {
        # PESTER ▶ Mock Get-AzResourceGroup — simulates finding an existing RG.
        Mock Get-AzResourceGroup { return @{ ResourceGroupName = 'rg-prod' } }
        # PESTER ▶ Mock with -Verifiable — marks this mock as REQUIRED to be called.
        # At the end, Should -InvokeVerifiable checks all -Verifiable mocks were used.
        Mock New-AzResource { return @{ ProvisioningState = 'Succeeded' } } -Verifiable
    }

    # PESTER ▶ Context — "happy path" scenario
    # Tests what happens when inputs are valid and Azure resources exist.
    Context 'Valid deployment' {
        It 'Returns Deployed status' {
            Write-Host "  → ASSERT: Checking return value — Returns Deployed status" -ForegroundColor Gray
            $r = Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-prod' -ResourceName 'storage01'
            $r.Status | Should -Be 'Deployed'
        }

        # PESTER ▶ Should -Invoke <MockedCommand>
        # Verifies the function internally called Get-AzResourceGroup.
        # This proves the function checks the RG exists BEFORE attempting deployment.
        It 'Validates RG exists before deploying' {
            Write-Host "  → Running: Validates RG exists before deploying" -ForegroundColor Gray
            Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-prod' -ResourceName 'myres' | Out-Null
            Should -Invoke Get-AzResourceGroup
        }

        # PESTER ▶ Should -InvokeVerifiable — checks ALL -Verifiable mocks were called
        # New-AzResource was marked -Verifiable in BeforeAll above.
        # This asserts it was actually invoked during the valid deployment test.
        It 'All verifiable mocks were called' {
            Write-Host "  → Using Should -InvokeVerifiable — all -Verifiable mocks must have been called" -ForegroundColor Gray
            Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-prod' -ResourceName 'deploy01' | Out-Null
            Should -InvokeVerifiable
        }
    }

    # PESTER ▶ Context — "sad path" for input validation
    # Tests that the function rejects bad input BEFORE calling Azure.
    Context 'Input validation failures' {
        # PESTER ▶ Should -Throw '*pattern*'
        # The wildcard '*3 characters*' matches any error message containing that text.
        # This is more resilient than matching the exact error string, which can change.
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

    # PESTER ▶ Context-scoped Mock Override
    # This Context redefines Get-AzResourceGroup to return $null.
    # The OVERRIDE only applies within this Context — sibling Contexts
    # still use the parent Describe's mock that returns a valid RG.
    # This is how you test different scenarios without duplicate test files.
    Context 'Resource group not found' {
        BeforeAll {
            # PESTER ▶ Mock override — RG not found (returns $null).
            # This replaces the parent's mock ONLY for tests inside this Context.
            Mock Get-AzResourceGroup { return $null }
        }

        It 'Throws when RG does not exist' {
            Write-Host "  → ERROR TEST: Expecting exception — Throws when RG does not exist" -ForegroundColor Gray
            { Deploy-AzureResourceWithValidation -ResourceGroupName 'rg-gone' -ResourceName 'storage01' } |
                Should -Throw '*does not exist*'
        }
    }
}




