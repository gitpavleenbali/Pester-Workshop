# ============================================================================
# PSCode Module 08 — Runspaces & Parallel Processing
# SOURCE: PSCode/08_runspaces/Azure-Runspaces-Masterclass.ps1
# TESTS:  Get-AzureResourceCount, Invoke-ParallelWork
#
# PESTER CONCEPTS: Pure functions, array handling, edge cases
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/PSCodeModulesAdditional.ps1
}

# PESTER: Simple pure function — returns a formatted string
Describe 'Module 08 · Get-AzureResourceCount' {

    It 'Returns formatted message with RG name' {
        Write-Host "  → ASSERT: Checking return value — Returns formatted message with RG name" -ForegroundColor Gray
        Get-AzureResourceCount -ResourceGroup 'rg-prod' |
            Should -Be 'Found 42 resources in rg-prod'
    }

    # PESTER: Should -Match for substring check
    It 'Includes the resource group name' {
        Write-Host "  → Running: Includes the resource group name" -ForegroundColor Gray
        Get-AzureResourceCount -ResourceGroup 'rg-test' |
            Should -Match 'rg-test'
    }

    It 'Works with hyphenated RG names' {
        Write-Host "  → Running: Works with hyphenated RG names" -ForegroundColor Gray
        Get-AzureResourceCount -ResourceGroup 'rg-my-special-group' |
            Should -Match 'rg-my-special-group'
    }
}

# PESTER: Testing parallel execution simulation
Describe 'Module 08 · Invoke-ParallelWork' {

    It 'Processes all items' {
        Write-Host "  → Running: Processes all items" -ForegroundColor Gray
        $r = Invoke-ParallelWork -Items @('A', 'B', 'C')
        $r.Count | Should -Be 3
    }

    It 'Marks each item as Processed' {
        Write-Host "  → Running: Marks each item as Processed" -ForegroundColor Gray
        $r = Invoke-ParallelWork -Items @('X', 'Y')
        $r | ForEach-Object { $_.Processed | Should -Be $true }
    }

    It 'Preserves item values' {
        Write-Host "  → Running: Preserves item values" -ForegroundColor Gray
        $r = Invoke-ParallelWork -Items @('Alpha', 'Beta')
        $r[0].Item | Should -Be 'Alpha'
        $r[1].Item | Should -Be 'Beta'
    }

    # PESTER: Edge case — empty input is tricky in PowerShell (array unrolling)
    It 'Returns empty for empty input' {
        Write-Host "  → ASSERT: Checking return value — Returns empty for empty input" -ForegroundColor Gray
        $r = @(Invoke-ParallelWork -Items @())
        $r.Count | Should -Be 0
    }

    It 'Handles single item' {
        Write-Host "  → Running: Handles single item" -ForegroundColor Gray
        $r = @(Invoke-ParallelWork -Items @('Solo'))
        $r.Count | Should -Be 1
        $r[0].Item | Should -Be 'Solo'
    }
}
