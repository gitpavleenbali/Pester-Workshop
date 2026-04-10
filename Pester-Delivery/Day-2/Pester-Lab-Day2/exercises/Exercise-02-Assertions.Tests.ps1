# ============================================================================
# Exercise 02 — Day 1 Review: Should Assertions
# DIFFICULTY: Beginner
# GOAL: Practice different Should operators.
#
# INSTRUCTIONS:
#   1. Replace ___BLANK___ with the correct Should operator or value.
#   2. Run: Invoke-Pester ./exercises/Exercise-02-Assertions.Tests.ps1
#
# HINTS:
#   - Should -Be (case-insensitive), Should -BeExactly (case-sensitive)
#   - Should -BeNullOrEmpty, Should -Not -BeNullOrEmpty
#   - Should -Throw '*pattern*'
#   - Should -BeGreaterThan, Should -BeOfType
# ============================================================================

Describe 'Exercise 02 · Should Assertions (Day 1 Review)' {

    It 'String comparison is case-insensitive with -Be' {
        # EXERCISE: What operator makes 'Hello' equal 'hello'?
        'Hello' | Should ___BLANK___ 'hello'
    }

    It 'String comparison is case-sensitive with -BeExactly' {
        # EXERCISE: 'Hello' should NOT be exactly 'hello' (different case)
        'Hello' | Should -Not ___BLANK___ 'hello'
    }

    It 'Null check' {
        $value = $null
        # EXERCISE: Assert the value is null or empty
        $value | Should ___BLANK___
    }

    It 'Type check' {
        $number = 42
        # EXERCISE: Assert $number is of type [int]
        $number | Should ___BLANK___ [int]
    }

    It 'Numeric comparison' {
        $count = 15
        # EXERCISE: Assert $count is greater than 10
        $count | Should ___BLANK___ 10
    }

    It 'Exception test' {
        # EXERCISE: Assert this throws an error containing "divide"
        # HINT: { <code> } | Should -Throw '*pattern*'
        { 1/0 } | Should ___BLANK___
    }
}
