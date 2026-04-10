# ============================================================================
# Exercise 05 — Day 2: Boundary Testing
# DIFFICULTY: Intermediate+
# GOAL: Test values at, below, and above a threshold using -TestCases.
#
# INSTRUCTIONS:
#   1. Replace ___BLANK___ with correct code.
#   2. Run: Invoke-Pester ./exercises/Exercise-05-BoundaryTesting.Tests.ps1
#
# HINTS:
#   - @{ Key = Value } hashtables in -TestCases
#   - param($Key1, $Key2) in the It body
#   - Think: what happens at exactly the threshold?
# ============================================================================

BeforeAll {
    function Test-CostAlert {
        param([double]$CurrentCost, [double]$Budget)
        if ($CurrentCost -gt $Budget) {
            return @{ Alert = $true; Message = "Over budget by $($CurrentCost - $Budget)" }
        }
        return @{ Alert = $false; Message = 'Within budget' }
    }
}

Describe 'Exercise 05 · Boundary Testing' {

    # EXERCISE: Complete the -TestCases with boundary values.
    # You need: below, at, just above, and well above the threshold.
    It 'Cost <Cost> vs Budget <Budget> → Alert=<Expected>' -TestCases @(
        @{ Cost = 50;     Budget = 100; Expected = $false }    # well below
        ___BLANK___                                             # just below (99)
        ___BLANK___                                             # at boundary (100 = no alert)
        ___BLANK___                                             # just above (100.01)
        @{ Cost = 500;    Budget = 100; Expected = $true }     # well above
    ) {
        param($Cost, $Budget, $Expected)
        $result = Test-CostAlert -CurrentCost $Cost -Budget $Budget
        $result.Alert | Should -Be $Expected
    }

    It 'Message says "Over budget" when alert is true' {
        $result = Test-CostAlert -CurrentCost 150 -Budget 100
        # EXERCISE: Assert the message contains "Over budget"
        $result.Message | Should ___BLANK___
    }

    It 'Message says "Within budget" when no alert' {
        $result = Test-CostAlert -CurrentCost 50 -Budget 100
        # EXERCISE: Assert the exact message
        $result.Message | Should ___BLANK___
    }
}
