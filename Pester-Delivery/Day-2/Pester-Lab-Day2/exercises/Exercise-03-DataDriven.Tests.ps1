# ============================================================================
# Exercise 03 — Day 1 Review: ParameterFilter & TestCases
# DIFFICULTY: Intermediate
# GOAL: Use -ParameterFilter for conditional mocks and -TestCases for data-driven tests.
#
# INSTRUCTIONS:
#   1. Replace ___BLANK___ with correct Pester code.
#   2. Run: Invoke-Pester ./exercises/Exercise-03-DataDriven.Tests.ps1
#
# HINTS:
#   - -ParameterFilter { $ParamName -eq 'value' }
#   - -TestCases @( @{ Key = Value }, @{ Key = Value } )
#   - param($Key) inside the It body to receive test case data
# ============================================================================

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
        # EXERCISE: Create a mock for Get-AzVM that returns 'Running' ONLY when Name is 'vm-web'
        # HINT: Mock Get-AzVM { ... } -ParameterFilter { $Name -eq '...' }
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } ___BLANK___

        # EXERCISE: Create a second mock for 'vm-db' that returns 'deallocated'
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } ___BLANK___
    }

    It 'VM "<VMName>" returns "<Expected>"' -TestCases @(
        @{ VMName = 'vm-web'; Expected = 'Running' }
        @{ VMName = 'vm-db';  Expected = 'Deallocated' }
    ) {
        # EXERCISE: Add the param() block to receive test case variables
        ___BLANK___
        Get-VMStatus -VMName $VMName | Should -Be $Expected
    }
}
