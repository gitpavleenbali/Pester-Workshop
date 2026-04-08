# ============================================================================
# PSCode Module 06 — Debugging: Data Processing Pipeline
# SOURCE: PSCode/06_debugging/Debug-Demo.ps1
# TESTS:  Test-InputValidation, Split-DataIntoChunks, Process-DataChunk, Get-ProcessedData
#
# PESTER CONCEPTS: 100% testable pure functions, no mocking needed
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/DataProcessing.ps1
}

Describe 'Module 06 · Test-InputValidation' {

    # PESTER: Context separates valid from invalid scenarios
    Context 'Valid input' {
        It 'Returns IsValid=$true for good data' {
            Write-Host "  → ASSERT: Checking return value — Returns IsValid=$true for good data" -ForegroundColor Gray
            $r = Test-InputValidation -Data 'Hello World' -Level 3
            $r.IsValid | Should -Be $true
            $r.ErrorCount | Should -Be 0
        }
    }

    Context 'Invalid input' {
        It 'Rejects empty string' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects empty string" -ForegroundColor Gray
            (Test-InputValidation -Data '' -Level 1).IsValid | Should -Be $false
        }

        It 'Rejects short strings (< 5 chars)' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects short strings (< 5 chars)" -ForegroundColor Gray
            $r = Test-InputValidation -Data 'Hi' -Level 1
            $r.IsValid | Should -Be $false
            $r.ErrorMessage | Should -Match '5 characters'
        }

        It 'Rejects level outside 1-5' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects level outside 1-5" -ForegroundColor Gray
            (Test-InputValidation -Data 'Valid' -Level 99).IsValid | Should -Be $false
        }

        # PESTER: Should -BeGreaterThan for multiple errors
        It 'Reports multiple errors at once' {
            Write-Host "  → Running: Reports multiple errors at once" -ForegroundColor Gray
            $r = Test-InputValidation -Data '' -Level 0
            $r.ErrorCount | Should -BeGreaterThan 1
        }
    }
}

Describe 'Module 06 · Split-DataIntoChunks' {

    It 'Splits 10-char string into 4 chunks of size 3' {
        Write-Host "  → Running: Splits 10-char string into 4 chunks of size 3" -ForegroundColor Gray
        $r = Split-DataIntoChunks -InputData 'HelloWorld' -ChunkSize 3
        $r.Count | Should -Be 4
    }

    It 'First chunk = first N characters' {
        Write-Host "  → Running: First chunk = first N characters" -ForegroundColor Gray
        $r = Split-DataIntoChunks -InputData 'ABCDEF' -ChunkSize 3
        $r[0] | Should -Be 'ABC'
    }

    It 'Last chunk = remainder' {
        Write-Host "  → Running: Last chunk = remainder" -ForegroundColor Gray
        $r = Split-DataIntoChunks -InputData 'ABCDEFG' -ChunkSize 3
        $r[-1] | Should -Be 'G'
    }

    It 'Handles chunk > input length' {
        Write-Host "  → Running: Handles chunk > input length" -ForegroundColor Gray
        $r = @(Split-DataIntoChunks -InputData 'Hi' -ChunkSize 100)
        $r.Count | Should -Be 1
        $r[0] | Should -Be 'Hi'
    }
}

Describe 'Module 06 · Process-DataChunk — Data-Driven' {

    # PESTER: -TestCases runs the same test with different transformation levels
    It "Level <Level>: '<InputText>' -> '<Expected>'" -TestCases @(
        Write-Host "  → Running: Level <Level>: '<InputText>' -> '<Expected>'" -ForegroundColor Gray
        @{ InputText = 'hello';    Level = 1; Expected = 'HELLO' }
        @{ InputText = 'WORLD';    Level = 2; Expected = 'world' }
        @{ InputText = 'hi there'; Level = 3; Expected = 'hi_there' }
        @{ InputText = 'keep';     Level = 0; Expected = 'keep' }
    ) {
        param($InputText, $Level, $Expected)
        $r = Process-DataChunk -ChunkData $InputText -Level $Level
        $r.Processed | Should -Be $Expected
        $r.Original | Should -Be $InputText
    }
}

Describe 'Module 06 · Get-ProcessedData Pipeline' {

    It 'Returns result for valid input' {
        Write-Host "  → ASSERT: Checking return value — Returns result for valid input" -ForegroundColor Gray
        $r = Get-ProcessedData -InputData 'Hello World' -ProcessingLevel 1
        $r | Should -Not -BeNullOrEmpty
        $r.ItemsCount | Should -BeGreaterThan 0
    }

    It 'Returns null for invalid input' {
        Write-Host "  → ERROR TEST: Expecting exception — Returns null for invalid input" -ForegroundColor Gray
        $r = Get-ProcessedData -InputData 'Hi' -ProcessingLevel 1 -WarningAction SilentlyContinue
        $r | Should -BeNullOrEmpty
    }

    It 'Preserves original data' {
        Write-Host "  → Running: Preserves original data" -ForegroundColor Gray
        $r = Get-ProcessedData -InputData 'TestData' -ProcessingLevel 1
        $r.OriginalData | Should -Be 'TestData'
    }
}
