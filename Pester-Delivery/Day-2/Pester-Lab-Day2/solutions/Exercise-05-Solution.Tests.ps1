# Solution for Exercise 05 — Boundary Testing
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
    It 'Cost <Cost> vs Budget <Budget> → Alert=<Expected>' -TestCases @(
        @{ Cost = 50;     Budget = 100; Expected = $false }
        @{ Cost = 99;     Budget = 100; Expected = $false }
        @{ Cost = 100;    Budget = 100; Expected = $false }
        @{ Cost = 100.01; Budget = 100; Expected = $true }
        @{ Cost = 500;    Budget = 100; Expected = $true }
    ) {
        param($Cost, $Budget, $Expected)
        $result = Test-CostAlert -CurrentCost $Cost -Budget $Budget
        $result.Alert | Should -Be $Expected
    }
    It 'Message says "Over budget" when alert is true' {
        $result = Test-CostAlert -CurrentCost 150 -Budget 100
        $result.Message | Should -Match 'Over budget'
    }
    It 'Message says "Within budget" when no alert' {
        $result = Test-CostAlert -CurrentCost 50 -Budget 100
        $result.Message | Should -Be 'Within budget'
    }
}
