# Solution for Exercise 02 — Should Assertions
Describe 'Exercise 02 · Should Assertions (Day 1 Review)' {
    It 'String comparison is case-insensitive with -Be' {
        'Hello' | Should -Be 'hello'
    }
    It 'String comparison is case-sensitive with -BeExactly' {
        'Hello' | Should -Not -BeExactly 'hello'
    }
    It 'Null check' {
        $value = $null
        $value | Should -BeNullOrEmpty
    }
    It 'Type check' {
        $number = 42
        $number | Should -BeOfType [int]
    }
    It 'Numeric comparison' {
        $count = 15
        $count | Should -BeGreaterThan 10
    }
    It 'Exception test' {
        { 1/0 } | Should -Throw
    }
}
