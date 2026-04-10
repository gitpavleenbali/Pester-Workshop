# ============================================================================
# PSCode Module 08 — Runspaces & Parallel Processing
# SOURCE: PSCode/08_runspaces/Azure-Runspaces-Masterclass.ps1
# TESTS:  Get-AzureResourceCount, Invoke-ParallelWork
#
# PESTER CONCEPTS: Pure functions, array handling, edge cases
# ============================================================================

# PESTER ▶ BeforeAll {}
# Loads all functions once before tests. No mocking needed — these are pure functions.
BeforeAll {
    . $PSScriptRoot/../../../PSCode-Source/08_runspaces/Azure-Runspaces.ps1
}

# PESTER ▶ Testing pure functions — no mocking required
# Simple functions that transform input to output are the easiest to test.
Describe 'Module 08 · Get-AzureResourceCount' {

    # PESTER ▶ Should -Be for exact string comparison
    # Compares the entire string output against the expected value.
    It 'Returns formatted message with RG name' {
        Write-Host "  → ASSERT: Checking return value — Returns formatted message with RG name" -ForegroundColor Gray
        Get-AzureResourceCount -ResourceGroup 'rg-prod' |
            Should -Be 'Found 42 resources in rg-prod'
    }

    # PESTER ▶ Should -Match for substring/regex matching
    # Unlike -Be (exact match), -Match checks if the value CONTAINS the pattern.
    # Useful when you don't care about the full string, just a key part.
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

# PESTER ▶ Testing parallel/collection processing
# Verifies that the function correctly processes arrays of items.
Describe 'Module 08 · Invoke-ParallelWork' {

    # PESTER ▶ Testing collection output
    # .Count asserts the correct number of items were processed.
    It 'Processes all items' {
        Write-Host "  → Running: Processes all items" -ForegroundColor Gray
        $r = Invoke-ParallelWork -Items @('A', 'B', 'C')
        $r.Count | Should -Be 3
    }

    # PESTER ▶ Should -HaveCount — cleaner way to assert collection size
    It 'Returns exactly 5 results for 5 inputs' {
        Write-Host "  → Running: HaveCount assertion for 5 items" -ForegroundColor Gray
        $r = Invoke-ParallelWork -Items @('a','b','c','d','e')
        $r | Should -HaveCount 5
    }

    # PESTER ▶ ForEach-Object with Should inside
    # You can loop through a collection and assert EACH item.
    # If any single assertion fails, the entire test fails.
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

    # PESTER ▶ Testing edge cases
    # Empty input is a critical edge case in PowerShell because of array unrolling.
    # @() wrapping forces the result to always be an array, even if empty or single item.
    # Without @(), a single-item result would be unwrapped to a scalar.
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


