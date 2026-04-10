# ============================================================================
# PSCode Module 06 — Debugging: Data Processing Pipeline
# SOURCE: PSCode/06_debugging/Debug-Demo.ps1
# TESTS:  Test-InputValidation, Split-DataIntoChunks, Process-DataChunk, Get-ProcessedData
#
# PESTER CONCEPTS: 100% testable pure functions, no mocking needed
# ============================================================================

# PESTER ▶ BeforeAll {}
# Loads pure functions (no Azure dependency). No mocks needed — these functions
# are self-contained, making them ideal candidates for unit testing.
BeforeAll {
    . $PSScriptRoot/../../../PSCode-Source/06_debugging/Debug-Demo.ps1
}

# PESTER ▶ Testing pure functions (no mocking needed)
# Pure functions take input and return output without side effects.
# They are the easiest to test — just call them and assert the result.
Describe 'Module 06 · Test-InputValidation' {

    # PESTER ▶ Context separates "happy path" from "error path"
    # This makes test output readable: you can see at a glance which
    # scenario passed and which failed.
    Context 'Valid input' {
        It 'Returns IsValid=$true for good data' {
            Write-Host "  → ASSERT: Checking return value — Returns IsValid=$true for good data" -ForegroundColor Gray
            $r = Test-InputValidation -Data 'Hello World' -Level 3
            $r.IsValid | Should -Be $true
            $r.ErrorCount | Should -Be 0
        }
    }

    # PESTER ▶ Context for invalid/error scenarios
    # Groups all the negative tests together — "what should FAIL".
    Context 'Invalid input' {
        It 'Rejects empty string' {
            Write-Host "  → ERROR TEST: Expecting exception — Rejects empty string" -ForegroundColor Gray
            (Test-InputValidation -Data '' -Level 1).IsValid | Should -Be $false
        }

        # PESTER ▶ Should -Match 'pattern'
        # Regex-based assertion — checks if the string CONTAINS the pattern.
        # More flexible than -Be when you only care about a substring.
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

        # PESTER ▶ Should -BeGreaterThan <N>
        # Numeric comparison assertion — asserts the value is strictly greater than N.
        # Also available: -BeLessThan, -BeGreaterOrEqual, -BeLessOrEqual.
        It 'Reports multiple errors at once' {
            Write-Host "  → Running: Reports multiple errors at once" -ForegroundColor Gray
            $r = Test-InputValidation -Data '' -Level 0
            $r.ErrorCount | Should -BeGreaterThan 1
        }
    }
}

# PESTER ▶ Testing chunking/splitting logic
# Pure functions with clear inputs and outputs — perfect for unit tests.
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

# PESTER ▶ -TestCases for data-driven testing
# Runs the SAME test logic with DIFFERENT inputs/expected outputs.
# Each @{} hashtable = one test execution. Variables from the hashtable
# are passed via param() to the It scriptblock.
Describe 'Module 06 · Process-DataChunk — Data-Driven' {

    # PESTER ▶ <Level>, <InputText>, <Expected> are template variables
    # They get replaced in the test name with actual values from -TestCases.
    It "Level <Level>: '<InputText>' -> '<Expected>'" -TestCases @(
        @{ InputText = 'hello';    Level = 1; Expected = 'HELLO' }
        @{ InputText = 'WORLD';    Level = 2; Expected = 'world' }
        @{ InputText = 'hi there'; Level = 3; Expected = 'hi_there' }
        @{ InputText = 'keep';     Level = 0; Expected = 'keep' }
    ) {
        param($InputText, $Level, $Expected)
        Write-Host "  → Processing '$InputText' at Level $Level → expecting '$Expected'" -ForegroundColor Gray
        $r = Process-DataChunk -ChunkData $InputText -Level $Level
        $r.Processed | Should -Be $Expected
        $r.Original | Should -Be $InputText
    }
}

# PESTER ▶ Testing a pipeline (integration-style test)
# Get-ProcessedData calls multiple internal functions in sequence.
# This tests the FULL pipeline end-to-end, not individual steps.
Describe 'Module 06 · Get-ProcessedData Pipeline' {

    # PESTER ▶ Should -Not -BeNullOrEmpty
    # Negated assertion — proves the function returned something.
    It 'Returns result for valid input' {
        Write-Host "  → ASSERT: Checking return value — Returns result for valid input" -ForegroundColor Gray
        $r = Get-ProcessedData -InputData 'Hello World' -ProcessingLevel 1
        $r | Should -Not -BeNullOrEmpty
        $r.ItemsCount | Should -BeGreaterThan 0
    }

    # PESTER ▶ Should -BeNullOrEmpty
    # Asserts the result IS null or empty — tests the failure/rejection path.
    # -WarningAction SilentlyContinue suppresses warnings so test output is clean.
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

# PESTER ▶ TestDrive: — Pester's temporary file system
# TestDrive:\ is a temp folder that Pester auto-creates and auto-cleans per Describe.
# Use it to test file operations without polluting the real file system.
Describe 'Module 06 · TestDrive Demo' {
    It 'Can write and read from TestDrive' {
        Write-Host "  → Writing to TestDrive:\test.txt and reading back" -ForegroundColor Gray
        Set-Content -Path TestDrive:\test.txt -Value 'Pester TestDrive works!'
        'TestDrive:\test.txt' | Should -Exist                     # File exists in temp
        Get-Content TestDrive:\test.txt | Should -Be 'Pester TestDrive works!'
    }

    # PESTER ▶ AfterAll — runs once after all tests in this Describe complete
    # TestDrive is auto-cleaned, but this shows the AfterAll pattern.
    AfterAll {
        Write-Host "  → AfterAll: TestDrive auto-cleaned by Pester" -ForegroundColor Gray
    }
}



