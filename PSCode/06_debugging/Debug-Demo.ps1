# ==============================================================================================
# PowerShell Debugging Demo Script
# Purpose: Demonstrate debugging with breakpoints, variables, watch, and call stack
# ==============================================================================================

# Function to demonstrate debugging features
function Get-ProcessedData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InputData,
        
        [int]$ProcessingLevel = 1,
        [switch]$EnableLogging
    )
    
    # Variables to inspect during debugging
    $startTime = Get-Date
    $processedItems = @()
    $errorCount = 0
    
    Write-Host "[START] Processing data with level $ProcessingLevel" -ForegroundColor Cyan
    
    # Call nested function to demonstrate call stack
    $validationResult = Test-InputValidation -Data $InputData -Level $ProcessingLevel
    
    if (-not $validationResult.IsValid) {
        $errorCount++
        Write-Warning "Validation failed: $($validationResult.ErrorMessage)"
        return $null
    }
    
    # Process data in chunks to create debugging opportunities
    $dataChunks = Split-DataIntoChunks -InputData $InputData -ChunkSize 3
    
    foreach ($chunk in $dataChunks) {
        # Good place for a breakpoint - inspect $chunk variable
        $processedChunk = Process-DataChunk -ChunkData $chunk -Level $ProcessingLevel
        $processedItems += $processedChunk
        
        if ($EnableLogging) {
            Write-Host "Processed chunk: $($chunk.Length) characters" -ForegroundColor Gray
        }
    }
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    # Create result object for inspection
    $result = [PSCustomObject]@{
        OriginalData = $InputData
        ProcessedItems = $processedItems
        ProcessingLevel = $ProcessingLevel
        ErrorCount = $errorCount
        StartTime = $startTime
        EndTime = $endTime
        Duration = $duration
        ItemsCount = $processedItems.Count
    }
    
    Write-Host "[COMPLETE] Processing finished in $($duration.TotalMilliseconds) ms" -ForegroundColor Green
    return $result
}

function Test-InputValidation {
    param(
        [string]$Data,
        [int]$Level
    )
    
    $errors = @()
    
    # Validation rules
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
        IsValid = $isValid
        ErrorMessage = $errorMessage
        ErrorCount = $errors.Count
        ValidationTime = Get-Date
    }
}

function Split-DataIntoChunks {
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

function Process-DataChunk {
    param(
        [string]$ChunkData,
        [int]$Level
    )
    
    # Apply different processing based on level
    switch ($Level) {
        1 { $processed = $ChunkData.ToUpper() }
        2 { $processed = $ChunkData.ToLower() }
        3 { $processed = $ChunkData -replace '\s+', '_' }
        4 { $processed = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ChunkData)) }
        5 { $processed = $ChunkData.ToCharArray() | ForEach-Object { [int]$_ } }
        default { $processed = $ChunkData }
    }
    
    return [PSCustomObject]@{
        Original = $ChunkData
        Processed = $processed
        Level = $Level
        ProcessedAt = Get-Date
    }
}

# Main execution function
function Start-DebuggingDemo {
    Write-Host "=" * 60 -ForegroundColor DarkGray
    Write-Host "PowerShell Debugging Demo" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor DarkGray
    
    # Sample data for processing
    $sampleData = "Hello World! This is a debugging demonstration script for PowerShell."
    
    Write-Host "`n[DEMO] Starting data processing demo..." -ForegroundColor Cyan
    
    # This is where we'll set breakpoints for debugging
    $result = Get-ProcessedData -InputData $sampleData -ProcessingLevel 2 -EnableLogging
    
    if ($result) {
        Write-Host "`n[RESULTS] Processing Summary:" -ForegroundColor Yellow
        Write-Host "  Original Data Length: $($result.OriginalData.Length)" -ForegroundColor Gray
        Write-Host "  Processed Items: $($result.ItemsCount)" -ForegroundColor Gray
        Write-Host "  Processing Level: $($result.ProcessingLevel)" -ForegroundColor Gray
        Write-Host "  Duration: $($result.Duration.TotalMilliseconds) ms" -ForegroundColor Gray
        Write-Host "  Error Count: $($result.ErrorCount)" -ForegroundColor Gray
    }
    
    # Additional variable to watch
    $additionalInfo = @{
        ScriptName = $PSCommandPath
        ExecutionTime = Get-Date
        PSVersion = $PSVersionTable.PSVersion
        UserName = $env:USERNAME
    }
    
    Write-Host "`n[INFO] Demo completed successfully!" -ForegroundColor Green
    return $result
}

# Execute the demo
Start-DebuggingDemo