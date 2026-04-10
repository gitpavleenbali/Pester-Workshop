# Solution for Exercise 03 — Data-Driven Tests
BeforeAll {
    function Get-VMStatus {
        param([string]$VMName)
        $vm = Get-AzVM -Name $VMName -Status
        if (-not $vm) { return $null }
        ($vm.Statuses | Where-Object { $_.Code -like 'PowerState*' }).DisplayStatus -replace 'VM ', ''
    }
}

Describe 'Exercise 03 · Data-Driven Tests (Day 1 Review)' {
    BeforeAll {
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } -ParameterFilter { $Name -eq 'vm-web' }

        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } -ParameterFilter { $Name -eq 'vm-db' }
    }

    It 'VM "<VMName>" returns "<Expected>"' -TestCases @(
        @{ VMName = 'vm-web'; Expected = 'Running' }
        @{ VMName = 'vm-db';  Expected = 'Deallocated' }
    ) {
        param($VMName, $Expected)
        Get-VMStatus -VMName $VMName | Should -Be $Expected
    }
}
