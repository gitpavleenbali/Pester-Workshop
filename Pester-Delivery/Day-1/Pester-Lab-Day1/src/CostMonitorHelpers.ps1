# ============================================================================
# Lab Source: Cost Monitor Helpers
# Origin: Extracted from PSCode/09_final_solution_apply_learnings
# Purpose: Functions with external dependencies — ideal for mocking exercises
# ============================================================================

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

    if ($CurrentCost -le $Threshold) {
        return [PSCustomObject]@{
            AlertSent = $false
            Reason    = "Cost ($CurrentCost) is within threshold ($Threshold)"
        }
    }

    # Send email alert (to be mocked in tests!)
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
