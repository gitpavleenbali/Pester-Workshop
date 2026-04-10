# ============================================================================
# Exercise 01 — Day 1 Review: Mocking Basics
# DIFFICULTY: Beginner
# GOAL: Write a mock for Get-AzResource and verify it was called.
#
# INSTRUCTIONS:
#   1. Replace the ___BLANK___ placeholders with the correct Pester code.
#   2. Run this file: Invoke-Pester ./exercises/Exercise-01-MockBasics.Tests.ps1
#   3. All tests should pass when blanks are filled correctly.
#
# HINTS:
#   - Mock <Command> { <FakeBody> } replaces a real command
#   - Should -Invoke <Command> -Times <N> verifies it was called
#   - Should -Be compares actual to expected
# ============================================================================

BeforeAll {
    # A simple function that wraps an Azure call
    function Get-ResourceCount {
        param([string]$ResourceGroupName)
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        return @{ Count = $resources.Count; Group = $ResourceGroupName }
    }
}

Describe 'Exercise 01 · Mocking Basics (Day 1 Review)' {

    It 'Returns the correct resource count from mocked data' {
        # EXERCISE: Create a mock for Get-AzResource that returns 3 fake resources
        # HINT: Mock <CommandName> { return @(...) }
        ___BLANK___ {
            return @(
                [PSCustomObject]@{ Name = 'vm-01' }
                [PSCustomObject]@{ Name = 'vm-02' }
                [PSCustomObject]@{ Name = 'sa-01' }
            )
        }

        $result = Get-ResourceCount -ResourceGroupName 'rg-test'

        # EXERCISE: Assert the count is 3
        $result.Count | ___BLANK___
    }

    It 'Verifies Get-AzResource was called exactly once' {
        Mock Get-AzResource { return @([PSCustomObject]@{ Name = 'vm-01' }) }

        Get-ResourceCount -ResourceGroupName 'rg-prod'

        # EXERCISE: Verify the mock was called exactly 1 time
        # HINT: Should -Invoke <Command> -Times <N> -Exactly
        ___BLANK___
    }
}
