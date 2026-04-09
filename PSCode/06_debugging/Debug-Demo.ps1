# ============================================================================
# Lab Source: Data Processing Utilities
# Origin: Extracted from PSCode/06_debugging/Debug-Demo.ps1
# Purpose: Pure logic functions — perfect for unit testing (NO mocking needed)
#
# TESTING NOTES:
#   These are PURE FUNCTIONS: they take input, return output, have no side
#   effects, and don't call external services. This makes them the easiest
#   type of code to unit test — just call the function and assert the result.
#   They also demonstrate the data processing pipeline pattern where each
#   function does one thing and can be tested independently.
#   See: tests/PSCode-06-Debugging.Tests.ps1
# ============================================================================

# TESTABILITY: Pure validation function — no external dependencies.
# Returns a structured result object instead of throwing, which makes
# it easy to test: (Test-InputValidation -Data '' -Level 1).IsValid | Should -Be $false
# Tests check: empty strings, short strings, invalid levels, multiple errors.
# TESTED IN: PSCode-06-Debugging.Tests.ps1
function Test-InputValidation {
    <#
    .SYNOPSIS
        Validates input data and processing level.
    .PARAMETER Data
        The string data to validate.
    .PARAMETER Level
        Processing level (must be 1-5).
    .OUTPUTS
        PSCustomObject with IsValid, ErrorMessage, ErrorCount properties.
    #>
    param(
        [string]$Data,
        [int]$Level
    )

    $errors = @()

    if ([string]::IsNullOrWhiteSpace($Data)) {
        $errors += "Data cannot be null or empty"
    }

    if ($Data.Length -lt 5) {
        $errors += "Data must be at least 5 characters long"
    }

    if ($Level -lt 1 -or $Level -gt 5) {
        $errors += "Processing level must be between 1 and 5"
    }

    $isValid = $errors.Count -eq 0
    $errorMessage = if ($errors.Count -gt 0) { $errors -join "; " } else { "" }

    return [PSCustomObject]@{
        IsValid      = $isValid
        ErrorMessage = $errorMessage
        ErrorCount   = $errors.Count
    }
}

# TESTABILITY: Pure string manipulation — no dependencies.
# Tests verify: correct chunk count, first/last chunk content, edge cases
# (chunk larger than input, empty input).
# TESTED IN: PSCode-06-Debugging.Tests.ps1
function Split-DataIntoChunks {
    <#
    .SYNOPSIS
        Splits a string into chunks of a given size.
    .PARAMETER InputData
        The string to split.
    .PARAMETER ChunkSize
        Number of characters per chunk.
    #>
    param(
        [string]$InputData,
        [int]$ChunkSize
    )

    $chunks = @()
    $currentPosition = 0

    while ($currentPosition -lt $InputData.Length) {
        $remainingLength = $InputData.Length - $currentPosition
        $actualChunkSize = [Math]::Min($ChunkSize, $remainingLength)

        $chunk = $InputData.Substring($currentPosition, $actualChunkSize)
        $chunks += $chunk
        $currentPosition += $actualChunkSize
    }

    return $chunks
}

# TESTABILITY: Pure transformation — uses -TestCases in the Pester test
# to verify Level 1=upper, Level 2=lower, Level 3=replace-spaces.
# The same It block runs 4 times with different input/expected data.
# TESTED IN: PSCode-06-Debugging.Tests.ps1
function Process-DataChunk {
    <#
    .SYNOPSIS
        Processes a string chunk based on a processing level.
    .PARAMETER ChunkData
        The chunk string to process.
    .PARAMETER Level
        1 = uppercase, 2 = lowercase, 3 = replace spaces with underscores.
    #>
    param(
        [string]$ChunkData,
        [int]$Level
    )

    switch ($Level) {
        1 { $processed = $ChunkData.ToUpper() }
        2 { $processed = $ChunkData.ToLower() }
        3 { $processed = $ChunkData -replace '\s+', '_' }
        default { $processed = $ChunkData }
    }

    return [PSCustomObject]@{
        Original  = $ChunkData
        Processed = $processed
        Level     = $Level
    }
}

# TESTABILITY: Pipeline function — calls the three functions above in sequence.
# This tests the integration of validate → split → process.
# No mocking needed because all sub-functions are pure.
# Tests verify both valid input (returns result) and invalid (returns $null).
# TESTED IN: PSCode-06-Debugging.Tests.ps1
function Get-ProcessedData {
    <#
    .SYNOPSIS
        Full data processing pipeline: validate, split, process.
    .PARAMETER InputData
        The string to process.
    .PARAMETER ProcessingLevel
        Processing level 1-5.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InputData,

        [int]$ProcessingLevel = 1
    )

    $validationResult = Test-InputValidation -Data $InputData -Level $ProcessingLevel

    if (-not $validationResult.IsValid) {
        Write-Warning "Validation failed: $($validationResult.ErrorMessage)"
        return $null
    }

    $dataChunks = Split-DataIntoChunks -InputData $InputData -ChunkSize 3
    $processedItems = @()

    foreach ($chunk in $dataChunks) {
        $processedChunk = Process-DataChunk -ChunkData $chunk -Level $ProcessingLevel
        $processedItems += $processedChunk
    }

    return [PSCustomObject]@{
        OriginalData    = $InputData
        ProcessedItems  = $processedItems
        ProcessingLevel = $ProcessingLevel
        ItemsCount      = $processedItems.Count
    }
}

