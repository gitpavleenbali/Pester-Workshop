# ============================================================================
# Lab Source: Cost Monitor Helpers
# Origin: Extracted from PSCode/09_final_solution_apply_learnings
# Purpose: Functions with external dependencies — ideal for mocking exercises
#
# WHY THIS FILE EXISTS:
#   The capstone Azure-Cost-Monitor.ps1 calls real Azure REST APIs and
#   Send-MailMessage. Extracting these functions lets Pester mock the
#   external calls (Invoke-RestMethod, Send-MailMessage, Get-AzAccessToken)
#   so tests run safely without Azure credentials or SMTP servers.
#   This file is the SINGLE SOURCE OF TRUTH — change it here, tests verify.
#
# FUNCTIONS:
#   Invoke-SafeAzureCall   — retry wrapper (ScriptBlock + MaxRetries)
#   Get-ResourceActualCost — calls Azure Cost Management API (not tested)
#   Send-CostAlert         — sends email when cost > threshold (mocked)
#
# TESTED BY: PSCode-09-Capstone.Tests.ps1
# ============================================================================
# Purpose: Functions with external dependencies — ideal for mocking exercises
#
# TESTING NOTES:
#   Invoke-SafeAzureCall accepts a ScriptBlock, so tests pass fake blocks
#   directly — no mocking needed (dependency injection pattern).
#   Send-CostAlert calls Send-MailMessage which MUST be mocked to prevent
#   real emails. Tests use boundary -TestCases to catch off-by-one bugs.
#   See: tests/PSCode-09-Capstone.Tests.ps1
# ============================================================================

# TESTABILITY: Uses DEPENDENCY INJECTION via ScriptBlock parameter.
# Instead of hardcoding the Azure call, the caller passes what to execute.
# In tests, we pass { 'data' } or { throw 'error' } to simulate success/failure
# WITHOUT needing Mock at all. This is the cleanest testable pattern.
# TESTED IN: PSCode-09-Capstone.Tests.ps1
function Invoke-SafeAzureCall {
    <#
    .SYNOPSIS
        Wraps an Azure REST API call with error handling and retry.
    .PARAMETER ScriptBlock
        The script block containing the Azure call.
    .PARAMETER MaxRetries
        Maximum number of retry attempts.
    .PARAMETER OperationName
        Friendly name for logging.
    #>
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [int]$MaxRetries = 3,

        [string]$OperationName = "Azure Operation"
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            $result = & $ScriptBlock
            return [PSCustomObject]@{
                Success       = $true
                Data          = $result
                Attempts      = $attempt
                OperationName = $OperationName
                Error         = $null
            }
        }
        catch {
            $lastError = $_.Exception.Message
            Write-Warning "[$OperationName] Attempt $attempt failed: $lastError"
            if ($attempt -lt $MaxRetries) {
                # In real code this would sleep — we skip for testability
            }
        }
    }

    return [PSCustomObject]@{
        Success       = $false
        Data          = $null
        Attempts      = $attempt
        OperationName = $OperationName
        Error         = $lastError
    }
}

function Get-ResourceActualCost {
    <#
    .SYNOPSIS
        Calculates the actual cost for a given Azure resource.
    .PARAMETER ResourceId
        The Azure resource ID.
    .PARAMETER StartDate
        Start of the billing period.
    .PARAMETER EndDate
        End of the billing period.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ResourceId,

        [datetime]$StartDate = (Get-Date).AddDays(-30),
        [datetime]$EndDate   = (Get-Date)
    )

    if ($StartDate -ge $EndDate) {
        throw "StartDate must be before EndDate"
    }

    $days = ($EndDate - $StartDate).Days
    if ($days -le 0) { $days = 1 }

    # Call Azure Cost Management API (to be mocked in tests)
    $costData = Invoke-RestMethod -Uri "https://management.azure.com$ResourceId/costs?api-version=2023-03-01" `
                                  -Method Get `
                                  -Headers @{ Authorization = "Bearer $((Get-AzAccessToken).Token)" }

    $totalCost = ($costData.properties.rows | Measure-Object -Property Amount -Sum).Sum

    return [PSCustomObject]@{
        ResourceId  = $ResourceId
        TotalCost   = [math]::Round($totalCost, 2)
        DailyCost   = [math]::Round($totalCost / $days, 2)
        Currency    = "EUR"
        Period      = "$($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
        DaysInRange = $days
    }
}

# TESTABILITY: Calls Send-MailMessage which sends REAL emails.
# In tests, Mock Send-MailMessage {} prevents that.
# Tests use boundary -TestCases: Cost=100 vs Threshold=100 catches the
# off-by-one question: does equal-to trigger an alert? (Answer: no, only >).
# TESTED IN: PSCode-09-Capstone.Tests.ps1
function Send-CostAlert {
    <#
    .SYNOPSIS
        Sends a cost alert email when spending exceeds a threshold.
    .PARAMETER ResourceName
        Name of the resource.
    .PARAMETER CurrentCost
        Current cost amount.
    .PARAMETER Threshold
        Cost threshold that triggers the alert.
    .PARAMETER RecipientEmail
        Email address to notify.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ResourceName,

        [Parameter(Mandatory)]
        [decimal]$CurrentCost,

        [decimal]$Threshold = 100.00,

        [string]$RecipientEmail = "admin@company.com"
    )

    # BOUNDARY LOGIC: Note the -le (less-than-or-equal) comparison.
    # Cost=100 and Threshold=100 returns AlertSent=$false (no alert).
    # Cost=100.01 and Threshold=100 returns AlertSent=$true (alert sent).
    # This exact boundary is tested with -TestCases in the Pester tests.
    if ($CurrentCost -le $Threshold) {
        return [PSCustomObject]@{
            AlertSent = $false
            Reason    = "Cost ($CurrentCost) is within threshold ($Threshold)"
        }
    }

    # DANGEROUS: This sends a REAL email. Always mock in tests!
    # Mock Send-MailMessage {} — empty body means "do nothing".
    # Then use Should -Invoke Send-MailMessage -Times 1 to verify it was called.
    Send-MailMessage -To $RecipientEmail `
                     -From "azure-alerts@company.com" `
                     -Subject "Cost Alert: $ResourceName" `
                     -Body "Resource '$ResourceName' has exceeded the cost threshold. Current: $CurrentCost EUR, Threshold: $Threshold EUR." `
                     -SmtpServer "smtp.company.com"

    return [PSCustomObject]@{
        AlertSent = $true
        Reason    = "Cost ($CurrentCost) exceeded threshold ($Threshold)"
    }
}

