# ============================================================================
# Exercise 04 — Day 2: Negative Testing
# DIFFICULTY: Intermediate
# GOAL: Write tests that verify ERRORS are handled correctly.
#
# INSTRUCTIONS:
#   1. Replace ___BLANK___ with correct code.
#   2. Run: Invoke-Pester ./exercises/Exercise-04-NegativeTesting.Tests.ps1
#
# HINTS:
#   - { <code> } | Should -Throw '*pattern*'
#   - Should -Invoke <Command> -Times 0  (proves it was NOT called)
#   - Mock <Command> { throw 'simulated error' }
# ============================================================================

BeforeAll {
    function Deploy-AzureResource {
        param(
            [Parameter(Mandatory)]
            [ValidateLength(3, 50)]
            [string]$Name,

            [string]$Location = 'eastus'
        )
        if ($Name -match '[^a-zA-Z0-9-]') {
            throw "Resource name '$Name' contains invalid characters. Use only letters, numbers, and hyphens."
        }
        $rg = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if (-not $rg) {
            throw "Resource group '$Name' does not exist."
        }
        New-AzResource -ResourceGroupName $Name -Location $Location
        return @{ Status = 'Deployed'; Name = $Name }
    }
}

Describe 'Exercise 04 · Negative Testing' {

    BeforeAll {
        Mock Get-AzResourceGroup { [PSCustomObject]@{ Name = 'rg-valid' } }
        Mock New-AzResource { @{ Id = '/sub/rg/resource' } }
    }

    It 'Rejects names shorter than 3 characters' {
        # EXERCISE: Assert that a 2-char name throws an error
        # HINT: { Deploy-AzureResource -Name 'ab' } | Should -Throw
        ___BLANK___
    }

    It 'Rejects names with special characters' {
        # EXERCISE: Assert the error message contains "invalid characters"
        { Deploy-AzureResource -Name 'bad@name!' } | Should ___BLANK___
    }

    It 'Does NOT call New-AzResource when validation fails' {
        try { Deploy-AzureResource -Name 'x' } catch {}

        # EXERCISE: Verify New-AzResource was NEVER called
        # HINT: Should -Invoke <Command> -Times 0
        ___BLANK___
    }

    Context 'When resource group does not exist' {
        BeforeAll {
            # EXERCISE: Override the mock so Get-AzResourceGroup returns $null
            ___BLANK___
        }

        It 'Throws "does not exist"' {
            { Deploy-AzureResource -Name 'rg-missing' } | Should -Throw '*does not exist*'
        }
    }
}
