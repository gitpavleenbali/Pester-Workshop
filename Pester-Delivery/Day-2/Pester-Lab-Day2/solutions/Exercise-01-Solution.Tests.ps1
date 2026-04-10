# Solution for Exercise 01 — Mocking Basics
BeforeAll {
    function Get-ResourceCount {
        param([string]$ResourceGroupName)
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        return @{ Count = $resources.Count; Group = $ResourceGroupName }
    }
}

Describe 'Exercise 01 · Mocking Basics (Day 1 Review)' {
    It 'Returns the correct resource count from mocked data' {
        Mock Get-AzResource {
            return @(
                [PSCustomObject]@{ Name = 'vm-01' }
                [PSCustomObject]@{ Name = 'vm-02' }
                [PSCustomObject]@{ Name = 'sa-01' }
            )
        }
        $result = Get-ResourceCount -ResourceGroupName 'rg-test'
        $result.Count | Should -Be 3
    }

    It 'Verifies Get-AzResource was called exactly once' {
        Mock Get-AzResource { return @([PSCustomObject]@{ Name = 'vm-01' }) }
        Get-ResourceCount -ResourceGroupName 'rg-prod'
        Should -Invoke Get-AzResource -Times 1 -Exactly
    }
}
