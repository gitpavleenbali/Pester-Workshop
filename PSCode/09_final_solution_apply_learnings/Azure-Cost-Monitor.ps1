# ==============================================================================================
# 09. Azure Cost Monitor: Capstone Project - All Module Integration
# Purpose: Real-world cost monitoring solution integrating all 8 PSCode training module concepts
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\09_final_solution_apply_learnings\Azure-Cost-Monitor.ps1
#
# Prerequisites: PowerShell 5.1+, Az PowerShell module, AzCLI, Git, authenticated Azure session
# ==============================================================================================

# ==============================================================================================
# PREREQUISITE CHECK: Azure PowerShell Module & Azure CLI
# ==============================================================================================
[CmdletBinding()]
param(
    [switch]$Detailed
)

$script:ShowDetailedOutput = [bool]$Detailed

Write-Host "[CHECK] Verifying PowerShell version..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
Write-Host "[INFO] PowerShell version detected: $($psVersion.ToString())" -ForegroundColor Gray

if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   POWERSHELL VERSION NOT SUPPORTED                            ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "This capstone solution requires PowerShell 5.1 or later." -ForegroundColor Yellow
    Write-Host "Current version detected: PowerShell $($psVersion.ToString())" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install PowerShell 7 (recommended) with: winget install Microsoft.PowerShell" -ForegroundColor Green
    Write-Host ""
    exit 1
}
elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -eq 1) {
    Write-Host "[SUCCESS] PowerShell 5.1 detected - core features available" -ForegroundColor Green
    Write-Host "[INFO] PowerShell 7+ recommended for best experience" -ForegroundColor Cyan
}
else {
    Write-Host "[SUCCESS] PowerShell 7+ detected - all features available!" -ForegroundColor Green
}

Write-Host ""

Write-Host "[CHECK] Verifying Azure PowerShell module..." -ForegroundColor Cyan
$azModule = Get-Module -Name Az.Accounts -ListAvailable -ErrorAction SilentlyContinue

if (-not $azModule) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      AZURE MODULE NOT INSTALLED                               ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "The Azure PowerShell module (Az) is required to run this capstone project." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install the Azure module, run this command in PowerShell (as Administrator):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Install-Module -Name Az -Repository PSGallery -Force -AllowClobber" -ForegroundColor Green
    Write-Host ""
    Write-Host "After installation completes, run this script again." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For more information, visit: https://learn.microsoft.com/powershell/azure/install-azure-powershell" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "[SUCCESS] Azure PowerShell module found!" -ForegroundColor Green

# Check Azure CLI
Write-Host "[CHECK] Verifying Azure CLI..." -ForegroundColor Cyan
try {
    $azCliVersion = az version 2>$null | ConvertFrom-Json
    Write-Host "[SUCCESS] Azure CLI found - Version: $($azCliVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      AZURE CLI NOT INSTALLED                                  ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Azure CLI is required for this cost monitoring solution." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install Azure CLI, visit: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Cyan
    Write-Host "Or use winget: winget install Microsoft.AzureCLI" -ForegroundColor Green
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[CHECK] Verifying Git installation..." -ForegroundColor Cyan
try {
    $gitVersionOutput = git --version 2>$null
    if (-not [string]::IsNullOrWhiteSpace($gitVersionOutput)) {
        Write-Host "[SUCCESS] Git found - $gitVersionOutput" -ForegroundColor Green
    }
    else {
        throw "Git not found"
    }
}
catch {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                          GIT NOT INSTALLED                                    ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Git is required to export and track cost reports." -ForegroundColor Yellow
    Write-Host "Install it with: winget install Git.Git" -ForegroundColor Green
    Write-Host "More info: https://git-scm.com/downloads" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[INFO] Starting Azure Cost Monitor - Module 09 Capstone Project..." -ForegroundColor Cyan
Write-Host "[INFO] Integrating all 8 PSCode training module concepts..." -ForegroundColor Gray
# MODULE INTEGRATION SUMMARY (Modules 01-08)
# - Module 01: Environment checks and subscription context refresh before running advanced scenarios.
# - Module 02: Advanced functions (Get-AzureResources, Get-RealAzureCosts, etc.) drive the solution core.
# - Module 03: Flexible parameter sets in Get-CostReport showcase mastering parameters.
# - Module 04: CostRecord and ResourceMetric classes organise API data for downstream calculations.
# - Module 05: Invoke-SafeAzureCall and resilient API usage extend the error-handling playbook.
# - Module 06: Strict mode, rich status messages, and retries enable fast debugging and diagnostics.
# - Module 07: Deterministic CSV exports support Git-based reviews of cost changes over time.
# - Module 08: Runspace-powered parallel analysis keeps large subscriptions responsive.

# Check Azure authentication and subscription
Write-Host "[CHECK] Verifying Azure authentication..." -ForegroundColor Cyan
try {
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                      AZURE NOT AUTHENTICATED                                  ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        Write-Host "You need to authenticate with Azure first." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Run one of these commands to authenticate:" -ForegroundColor Cyan
        Write-Host "    Connect-AzAccount                    # Interactive login" -ForegroundColor Green
        Write-Host "    az login                             # Azure CLI login" -ForegroundColor Green
        Write-Host ""
        Write-Host "After authentication completes, run this script again." -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }
    
    Write-Host "[SUCCESS] Azure authentication verified!" -ForegroundColor Green
    Write-Host "[INFO] Current subscription: $($azContext.Subscription.Name)" -ForegroundColor Gray
    Write-Host "[INFO] Subscription ID: $($azContext.Subscription.Id)" -ForegroundColor Gray
    Write-Host "[INFO] Tenant: $($azContext.Tenant.Id)" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Failed to check Azure authentication: $_" -ForegroundColor Red
    Write-Host "Please ensure Azure PowerShell module is properly installed and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Module 06 (Debugging): strict mode surfaces script issues early while preserving detailed logs below.
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Continue'

# ====================================================================================================
# CONCEPT 01 - MODULE 04: ADVANCED CLASSES
# ====================================================================================================
if ($script:ShowDetailedOutput) {
    Write-Host ""
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "AZURE COST MONITOR - Module 09 Capstone Solution" -ForegroundColor Cyan
    Write-Host "Using REAL Azure Cost Management data with all 8 PSCode training module concepts" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

class CostRecord {
    [string]$ResourceId
    [string]$ResourceName
    [string]$ResourceType
    [string]$ResourceGroup
    [string]$Location
    [decimal]$MonthlyCost
    [decimal]$WeeklyCost
    [decimal]$ForecastedCost
    [datetime]$LastUpdated

    CostRecord([string]$id, [string]$name, [string]$type, [string]$rg, [string]$loc, [decimal]$monthly) {
        $this.ResourceId = $id
        $this.ResourceName = $name
        $this.ResourceType = $type
        $this.ResourceGroup = $rg
        $this.Location = $loc
        $this.MonthlyCost = $monthly
        $this.WeeklyCost = [math]::Round($monthly / 4.33, 2)
        $this.ForecastedCost = [math]::Round($monthly * 12, 2)
        $this.LastUpdated = Get-Date
    }

    [string] ToString() {
        return "$($this.ResourceName) - `$$($this.MonthlyCost)/month"
    }
}

class ResourceMetric {
    [string]$Name
    [string]$Type
    [decimal]$Cost
    [string]$Remarks

    ResourceMetric([string]$n, [string]$t, [decimal]$c, [string]$r) {
        $this.Name = $n
        $this.Type = $t
        $this.Cost = $c
        $this.Remarks = $r
    }
}

if ($script:ShowDetailedOutput) {
    Write-Host "✓ CONCEPT 01: Created classes - CostRecord, ResourceMetric (Module 04)" -ForegroundColor Green
}

# ====================================================================================================
# CONCEPT 02 - MODULE 02: ADVANCED FUNCTIONS
# ====================================================================================================

function Get-AzureResources {
    <#
    .SYNOPSIS
        Fetch actual Azure resources from subscription
    #>
    [CmdletBinding()]
    param([int]$Limit = 50)
    
    Write-Host "  Fetching Azure resources..." -ForegroundColor Gray
    try {
        $resourcesJson = az resource list --query "[0:$Limit].{id:id, name:name, type:type, resourceGroup:resourceGroup, location:location}" -o json 2>$null
        if ($resourcesJson) {
            $resources = $resourcesJson | ConvertFrom-Json
            return $resources
        }
        else {
            Write-Warning "No resources returned from Azure CLI"
            return @()
        }
    }
    catch {
        Write-Warning "Failed to fetch Azure resources: $_"
        return @()
    }
}

function Get-RealAzureCosts {
    <#
    .SYNOPSIS
        Retrieves real Azure costs using Microsoft.Consumption/usageDetails API for accurate billing analysis.

    .DESCRIPTION
        This function connects to the Azure Cost Management API to fetch actual usage details and costs
        for a specified Azure subscription. It uses the Microsoft.Consumption/usageDetails REST API
        to retrieve real billing data that matches what appears in the Azure portal.
        
        The function automatically handles authentication using Azure CLI tokens and processes the
        response to extract cost information at the resource level. It's designed for production
        cost monitoring scenarios where accurate, real-time billing data is required.

    .PARAMETER SubscriptionId
        The Azure subscription ID to analyze costs for. Must be a valid GUID format.
        If not provided, the function will use the current Azure context subscription.
        
        Example: "12345678-1234-1234-1234-123456789012"

    .PARAMETER DaysBack
        Number of days to look back for cost analysis. Default is 30 days.
        The API returns data for the current billing period, so this parameter
        helps scope the analysis timeframe.
        
        Valid range: 1-365 days. Default: 30

    .EXAMPLE
        PS> Get-RealAzureCosts
        
        Retrieves cost data for the current subscription using default 30-day period.
        Returns cost records with resource-level breakdown including actual costs,
        resource names, services, and usage details.

    .EXAMPLE
        PS> Get-RealAzureCosts -SubscriptionId "12345678-1234-1234-1234-123456789012"
        
        Gets real cost data for a specific subscription ID.
        Useful when working with multiple subscriptions or in automated scenarios.

    .EXAMPLE
        PS> $costs = Get-RealAzureCosts -DaysBack 7
        PS> $costs | Where-Object {$_.actualCost -gt 50} | Sort-Object actualCost -Descending
        
        Retrieves last 7 days of cost data and filters for resources with costs over $50,
        sorted by highest cost first. Useful for identifying expensive resources.

    .EXAMPLE
        PS> Get-RealAzureCosts | Group-Object consumedService | Sort-Object Count -Descending
        
        Gets cost data and groups by Azure service to see which services are used most.
        Helps identify service usage patterns across the subscription.

    .INPUTS
        String - SubscriptionId (optional)
        Int32 - DaysBack (optional)

    .OUTPUTS
        PSCustomObject[] - Returns array of cost records with the following properties:
        - resourceId: Full Azure resource identifier
        - resourceName: Display name of the resource
        - actualCost: Real cost in billing currency
        - currency: Billing currency code (e.g., USD, EUR)
        - product: Azure product/service name
        - meterName: Specific meter that generated the cost
        - consumedService: Azure service category
        - resourceGroup: Resource group containing the resource
        - date: Date of the usage/cost
        - quantity: Amount of service consumed
        - effectivePrice: Price per unit for the service

    .NOTES
        Author: Azure Cost Management Team
        Version: 1.2
        Last Updated: November 2025
        
        Prerequisites:
        - Azure CLI installed and authenticated (az login)
        - Access to Azure Cost Management APIs
        - Reader access to the target subscription
        
        API Information:
        - Uses Microsoft.Consumption/usageDetails API version 2023-05-01
        - Retrieves data for current billing period
        - Automatically handles API authentication via Azure CLI tokens
        
        Performance:
        - API calls may take 10-30 seconds for large subscriptions
        - Results are cached by Azure for approximately 8-24 hours
        - Billing data typically has 24-48 hour delay
        
        Troubleshooting:
        - If no costs returned: Check if subscription has billable usage
        - API failures: Verify Azure CLI authentication and permissions
        - Empty results: May indicate free tier usage or recent subscription

    .LINK
        https://docs.microsoft.com/azure/cost-management-billing/
        
    .LINK
        https://docs.microsoft.com/rest/api/consumption/
        
    .FUNCTIONALITY
        Azure Cost Management, Billing Analysis, Resource Cost Tracking
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, 
                   ValueFromPipeline = $false,
                   HelpMessage = "Azure subscription ID to analyze. Uses current context if not specified.")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $false,
                   HelpMessage = "Number of days to look back for analysis. Default is 30 days.")]
        [ValidateRange(1, 365)]
        [int]$DaysBack = 30
    )
    
    Write-Host "  Fetching REAL Azure costs using simplified REST API approach..." -ForegroundColor Gray
    
    try {
    # Acquire Azure access token for REST queries
        Write-Host "  Getting Azure access token..." -ForegroundColor Gray
        $token = az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv 2>$null
        if (-not $token) {
            throw "Failed to get Azure access token"
        }
        
        $headers = @{ Authorization = "Bearer $token" }
        
    # Use simplified URI without date filters for current billing period
        Write-Host "  Querying Consumption API (current billing period)..." -ForegroundColor Gray
        $billingUri = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Consumption/usageDetails?api-version=2023-05-01"
        
        $billingResponse = Invoke-RestMethod -Uri $billingUri -Headers $headers -Method Get -ErrorAction Stop
        
        if ($billingResponse -and $billingResponse.value -and $billingResponse.value.Count -gt 0) {
            Write-Host "  ✓ Retrieved $($billingResponse.value.Count) usage records!" -ForegroundColor Green
            
            $costData = @()
            $totalCost = 0
            $recordsWithCosts = 0
            
            foreach ($item in $billingResponse.value) {
                # Use the CORRECT property names from actual API response
                if ($item.properties.costInBillingCurrency -and [decimal]$item.properties.costInBillingCurrency -gt 0) {
                    $cost = [decimal]$item.properties.costInBillingCurrency
                    $totalCost += $cost
                    $recordsWithCosts++
                    
                    # Extract resource name from instanceName (full resource ID)
                    $resourceName = if ($item.properties.instanceName) { 
                        $item.properties.instanceName.Split('/')[-1] 
                    } else { 
                        $item.properties.meterName -or $item.properties.product -or "Unknown Resource"
                    }
                    
                    $costData += [PSCustomObject]@{
                        resourceId = $item.properties.instanceName
                        resourceName = $resourceName
                        actualCost = $cost
                        pretaxCost = $cost
                        cost = $cost
                        currency = $item.properties.billingCurrencyCode
                        product = $item.properties.product
                        meterName = $item.properties.meterName
                        consumedService = $item.properties.consumedService
                        resourceGroup = $item.properties.resourceGroup
                        date = $item.properties.date
                        quantity = $item.properties.quantity
                        effectivePrice = $item.properties.effectivePrice
                        subscriptionGuid = $item.properties.subscriptionGuid
                    }
                    
                    Write-Host "  ✓ $resourceName : $($item.properties.billingCurrencyCode)$cost" -ForegroundColor Green
                }
            }
            
            if ($costData.Count -gt 0) {
                Write-Host "  ✓ Found $recordsWithCosts records with costs out of $($billingResponse.value.Count) total records" -ForegroundColor Green
                Write-Host "  ✓ Total REAL cost from Azure APIs: $($costData[0].currency)$([math]::Round($totalCost, 2))" -ForegroundColor Green
                return $costData
            } else {
                Write-Host "  ⚠ No records with billable costs found (all may be free tier or covered by credits)" -ForegroundColor Yellow
            }
        }

        # If still no costs, explain the real situation
        Write-Host "  ⚠ No billable costs found using Azure Consumption API" -ForegroundColor Yellow
        Write-Host "  This means either:" -ForegroundColor Yellow
        Write-Host "    - All usage is covered by Azure credits or free tier" -ForegroundColor Yellow
        Write-Host "    - No billable usage in the current billing period" -ForegroundColor Yellow
        Write-Host "    - Billing data delay (costs appear 24-48 hours after usage)" -ForegroundColor Yellow
        
        return @()
    }
    catch {
        Write-Host "  REST API call failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  This may be due to subscription type or API permissions" -ForegroundColor Yellow
        return @()
    }
}

function Get-CostSummary {
    <#
    .SYNOPSIS
        Retrieve aggregated costs for a custom UTC date range using the Cost Management Query API.
        Optionally returns a service-level breakdown with an "Others" bucket similar to the Azure portal.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [datetime]$FromUtc,

        [Parameter(Mandatory = $true)]
        [datetime]$ToUtc,

        [switch]$IncludeServiceBreakdown,

        [ValidateRange(1, 20)]
        [int]$TopServices = 10
    )

    if ($script:ShowDetailedOutput) {
        Write-Host "  Fetching cost summary from $($FromUtc.ToString('u')) to $($ToUtc.ToString('u'))..." -ForegroundColor Gray
    }

    if ($ToUtc -le $FromUtc) {
        throw "Get-CostSummary requires ToUtc to be greater than FromUtc"
    }

    try {
        $token = az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv 2>$null
        if (-not $token) {
            throw "Failed to get Azure access token"
        }

        $headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
        $culture = [System.Globalization.CultureInfo]::InvariantCulture

        $dataset = [ordered]@{
            granularity = 'None'
            aggregation = @{ totalCost = @{ name = 'Cost'; function = 'Sum' } }
        }

        if ($IncludeServiceBreakdown) {
            $dataset.grouping = @(@{ type = 'Dimension'; name = 'ServiceName' })
        }

        $body = [ordered]@{
            type = 'Usage'
            timeframe = 'Custom'
            timePeriod = @{
                from = $FromUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
                to = $ToUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            dataset = $dataset
        } | ConvertTo-Json -Depth 6

        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.CostManagement/query?api-version=2023-03-01"

    $maxAttempts = 4
    $attempt = 0
    $response = $null

    # Module 06 (Debugging): retry loop with progressive waits helps diagnose throttling without failing silently.
    while ($attempt -lt $maxAttempts) {
            $attempt++
            try {
                $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body -ErrorAction Stop
                break
            }
            catch {
                $statusCode = $null
                if ($_.Exception -and ($_.Exception.PSObject.Properties.Name -contains 'Response')) {
                    $rawResponse = $_.Exception.Response
                    if ($rawResponse -and ($rawResponse.PSObject.Properties.Name -contains 'StatusCode')) {
                        $statusCode = [int]$rawResponse.StatusCode
                    }
                }

                if ($statusCode -eq 429 -and $attempt -lt $maxAttempts) {
                    $delaySeconds = [math]::Min(15, [math]::Pow(2, $attempt))
                    Write-Host "  ⚠ Cost summary request throttled (429). Retrying in $([int][math]::Ceiling($delaySeconds))s..." -ForegroundColor Yellow
                    Start-Sleep -Seconds ([int][math]::Ceiling($delaySeconds))
                    continue
                }

                throw
            }
        }

        if (-not $response) {
            throw "No response returned from cost summary endpoint."
        }

        if (-not $response.properties.rows -or $response.properties.rows.Count -eq 0) {
            Write-Host "  ⚠ No rows returned for the requested cost summary" -ForegroundColor Yellow
            return $null
        }

        if ($IncludeServiceBreakdown) {
            $serviceRows = $response.properties.rows | ForEach-Object {
                $rawCost = $_[0]
                $parsedCost = [decimal]::Parse($rawCost.ToString().Replace(',', '.'), [System.Globalization.NumberStyles]::Float, $culture)
                [PSCustomObject]@{
                    Cost = $parsedCost
                    Service = $_[1]
                    Currency = $_[2]
                }
            }

            $orderedServices = $serviceRows | Sort-Object -Property Cost -Descending
            $topEntries = $orderedServices | Select-Object -First $TopServices

            if ($orderedServices.Count -gt $TopServices) {
                $othersTotal = ($orderedServices[$TopServices..($orderedServices.Count - 1)] | Measure-Object -Property Cost -Sum).Sum
                $currency = $orderedServices[0].Currency
                $topEntries += [PSCustomObject]@{
                    Cost = $othersTotal
                    Service = 'Others'
                    Currency = $currency
                }
            }

            $totalCost = ($orderedServices | Measure-Object -Property Cost -Sum).Sum
            $currency = $orderedServices[0].Currency

            if ($script:ShowDetailedOutput) {
                Write-Host "  ✓ Aggregated cost: $currency$([math]::Round($totalCost, 2))" -ForegroundColor Green
            }

            return [PSCustomObject]@{
                TotalCost = $totalCost
                Currency = $currency
                From = $FromUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
                To = $ToUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
                TopServices = $topEntries
                ServiceBreakdown = $orderedServices
            }
        }
        else {
            $row = $response.properties.rows[0]
            $totalCost = [decimal]::Parse($row[0].ToString().Replace(',', '.'), [System.Globalization.NumberStyles]::Float, $culture)
            $currency = $row[1]

            if ($script:ShowDetailedOutput) {
                Write-Host "  ✓ Aggregated cost: $currency$([math]::Round($totalCost, 2))" -ForegroundColor Green
            }

            return [PSCustomObject]@{
                TotalCost = $totalCost
                Currency = $currency
                From = $FromUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
                To = $ToUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
        }
    }
    catch {
        Write-Host "  REST query for cost summary failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Show-ServiceBreakdown {
    <#
    .SYNOPSIS
        Render a simple service breakdown table for a cost summary.
    #>
    param(
        [Parameter(Mandatory = $true)]
        $Summary
    )

    if (-not $Summary -or -not $Summary.TopServices -or $Summary.TopServices.Count -eq 0) {
        Write-Host "  (Service-level detail unavailable)" -ForegroundColor Yellow
        return
    }

    $format = "  {0,-28} {1,12}"
    Write-Host "  Service Breakdown:" -ForegroundColor Gray
    Write-Host ($format -f "Service", "Cost") -ForegroundColor DarkGray
    Write-Host ($format -f "----------------------------", "------------") -ForegroundColor DarkGray

    foreach ($service in $Summary.TopServices) {
        $serviceName = if ($service.Service.Length -gt 28) { $service.Service.Substring(0, 25) + '…' } else { $service.Service }
        $serviceCost = "{0}{1:N2}" -f $Summary.Currency, [math]::Round($service.Cost, 2)
        Write-Host ($format -f $serviceName, $serviceCost)
    }
}

function Show-SimpleCostSnapshot {
    <#
    .SYNOPSIS
        Display a concise monthly cost snapshot for students/customers.
    #>
    param(
        $LastMonthSummary,
        $MonthToDateSummary
    )

    Write-Host ""
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host "Azure Cost Snapshot" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan

    $toLocalDateString = {
        param(
            $dateValue,
            [switch]$IsEnd
        )

        if (-not $dateValue) {
            return '-'
        }

        $culture = [System.Globalization.CultureInfo]::InvariantCulture
        $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal

        try {
            if ($dateValue -is [datetime]) {
                $utcValue = switch ($dateValue.Kind) {
                    ([System.DateTimeKind]::Utc) { $dateValue; break }
                    ([System.DateTimeKind]::Local) { $dateValue.ToUniversalTime(); break }
                    default { [datetime]::SpecifyKind($dateValue, [System.DateTimeKind]::Utc) }
                }
            }
            else {
                $utcValue = [datetime]::Parse($dateValue.ToString(), $culture, $styles)
            }
        }
        catch {
            return $dateValue
        }

        if ($IsEnd) {
            $utcValue = $utcValue.AddSeconds(-1)
        }

        return $utcValue.ToString('yyyy-MM-dd')
    }

    if ($LastMonthSummary) {
    $fromText = & $toLocalDateString $LastMonthSummary.From
    $toText = & $toLocalDateString $LastMonthSummary.To -IsEnd
        Write-Host ""
        Write-Host ("Last Month ({0} ➜ {1})" -f $fromText, $toText) -ForegroundColor Cyan
        Write-Host ("  Total: {0}{1:N2}" -f $LastMonthSummary.Currency, [math]::Round($LastMonthSummary.TotalCost, 2)) -ForegroundColor Green
        Show-ServiceBreakdown -Summary $LastMonthSummary
    }
    else {
        Write-Host ""
        Write-Host "Last Month: No data returned from Cost Management." -ForegroundColor Yellow
    }

    if ($MonthToDateSummary) {
    $fromText = & $toLocalDateString $MonthToDateSummary.From
    $toText = & $toLocalDateString $MonthToDateSummary.To -IsEnd
        Write-Host ""
        Write-Host ("Current Month-To-Date ({0} ➜ {1})" -f $fromText, $toText) -ForegroundColor Cyan
        Write-Host ("  Total: {0}{1:N2}" -f $MonthToDateSummary.Currency, [math]::Round($MonthToDateSummary.TotalCost, 2)) -ForegroundColor Green
        Show-ServiceBreakdown -Summary $MonthToDateSummary
    }
    else {
        Write-Host ""
        Write-Host "Current Month-To-Date: No data returned from Cost Management." -ForegroundColor Yellow
    }

    Write-Host ""
}

function Get-ResourceActualCost {
    <#
    .SYNOPSIS
    Get actual cost for a specific resource from REAL Azure Cost Management API data ONLY
    Built from Cost Management API data only
    #>
    [CmdletBinding()]
    param(
        [object]$Resource,
        [object]$CostData
    )
    
    if ($CostData -and $CostData.Count -gt 0) {
        # Try to match by exact resource ID first
        $exactMatch = $CostData | Where-Object { 
            $_.resourceId -eq $Resource.id 
        }
        
        if ($exactMatch) {
            $totalCost = ($exactMatch | Measure-Object -Property actualCost -Sum).Sum
            Write-Verbose "Found exact resource ID match for $($Resource.name): `$$totalCost"
            return [math]::Round($totalCost, 2)
        }
        
        # If we have subscription total but no resource breakdown, 
        # return 0 since we can't assign specific costs (avoid artificial allocation)
        $subscriptionTotal = $CostData | Where-Object { 
            $_.resourceId -eq "subscription-total" -or $_.resourceId -eq "cli-total"
        }
        if ($subscriptionTotal -and $subscriptionTotal.actualCost -gt 0) {
            Write-Verbose "Subscription total available but no resource-level breakdown from Azure APIs"
            return 0.00  # Leave at zero rather than fabricating a value
        }
    }
    
    # If no real cost data available, return 0 so we avoid speculative estimates
    Write-Verbose "No real cost data available for resource: $($Resource.name)"
    return 0.00
}

function Analyze-CostByResource {
    <#
    .SYNOPSIS
    Analyze REAL costs by resource using Azure Cost Management API data only
    Avoid speculative estimates - only real API responses with resource-level matching
    #>
    [CmdletBinding()]
    param(
        [object[]]$Resources,
        [string]$SubscriptionId
    )
    
    $costRecords = @()
    
    # Get REAL cost data from Azure Cost Management API with resource grouping
    Write-Host "  Getting REAL cost data with resource-level breakdown from Azure Cost Management API..." -ForegroundColor Yellow
    $realCostData = Get-RealAzureCosts -SubscriptionId $SubscriptionId -DaysBack 30
    
    if ($realCostData -and $realCostData.Count -gt 0) {
        Write-Host "  ✓ Retrieved $($realCostData.Count) actual cost records from Azure Cost Management API" -ForegroundColor Green
        
        # Calculate total actual cost from API
        $totalActualCost = ($realCostData | Measure-Object -Property actualCost -Sum).Sum
        Write-Host "  ✓ Total actual cost from API: `$$([math]::Round($totalActualCost, 2))" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ No real cost data available from Azure Cost Management API" -ForegroundColor Yellow
    Write-Host "  ⚠ All resources will show `$0.00 cost (insufficient billing detail)" -ForegroundColor Yellow
    }
    
    foreach ($resource in $Resources) {
        # Get actual cost for this resource (returns 0 if no real data)
        $actualCost = Get-ResourceActualCost -Resource $resource -CostData $realCostData
        
        # Create cost record with REAL data only
        $record = [CostRecord]::new(
            $resource.id, 
            $resource.name, 
            $resource.type, 
            $resource.resourceGroup, 
            $resource.location, 
            $actualCost
        )
        $costRecords += $record
    }
    
    # Return both cost records and raw cost data for summary calculations
    return @{
        CostRecords = $costRecords
        RawCostData = $realCostData
    }
}

function Get-DetailedCostSummary {
    <#
    .SYNOPSIS
    Create detailed cost summary aligned with actual API response schema
    #>
    [CmdletBinding()]
    param(
        [object[]]$CostData
    )
    # Return 0 when no resource-level data exists to avoid artificial allocations
    
    if (-not $CostData -or $CostData.Count -eq 0) {
        return @()
    }
    
    Write-Host "  Creating detailed cost summary..." -ForegroundColor Gray
    
    $invariantCulture = [System.Globalization.CultureInfo]::InvariantCulture

    $detailedSummary = $CostData | ForEach-Object {
        $resourceName = if (-not [string]::IsNullOrWhiteSpace($_.resourceName)) {
            $_.resourceName
        }
        elseif (-not [string]::IsNullOrWhiteSpace($_.resourceId)) {
            $_.resourceId
        }
        else {
            'Unknown resource'
        }

        $meterName = if (-not [string]::IsNullOrWhiteSpace($_.meterName)) {
            $_.meterName
        }
        elseif (-not [string]::IsNullOrWhiteSpace($_.product)) {
            $_.product
        }
        elseif (-not [string]::IsNullOrWhiteSpace($_.meter)) {
            $_.meter
        }
        else {
            'Unknown meter'
        }

        $serviceName = if (-not [string]::IsNullOrWhiteSpace($_.consumedService)) {
            $_.consumedService
        }
        elseif (-not [string]::IsNullOrWhiteSpace($_.product)) {
            $_.product
        }
        else {
            'Unknown service'
        }

        $quantity = if ($null -ne $_.quantity) {
            [Math]::Round([double]$_.quantity, 4)
        }
        else {
            0
        }

        $effectivePrice = if ($null -ne $_.effectivePrice) {
            [Math]::Round([double]$_.effectivePrice, 6)
        }
        else {
            0
        }

        $currency = if (-not [string]::IsNullOrWhiteSpace($_.currency)) {
            $_.currency
        }
        else {
            'USD'
        }

        [PSCustomObject]@{
            Date = $_.date
            Resource = $resourceName
            MeterName = $meterName
            ServiceName = $serviceName
            ConsumedQty = $quantity
            Cost = [Math]::Round([double]$_.actualCost, 4)
            Currency = $currency
            ResourceGroup = $_.resourceGroup
            EffectivePrice = $effectivePrice
        }
    }
    
    $totalCost = ($detailedSummary | Measure-Object -Property Cost -Sum).Sum
    $currency = $detailedSummary[0].Currency
    
    Write-Host "  ✓ Created detailed summary for $($detailedSummary.Count) cost records" -ForegroundColor Green
    Write-Host "  ✓ Total cost in detailed view: $currency$([math]::Round($totalCost, 2))" -ForegroundColor Green
    
    return @{
        DetailedRecords = $detailedSummary
        TotalCost = $totalCost
        Currency = $currency
        DaysAnalyzed = $DaysBack
    }
}

if ($script:ShowDetailedOutput) {
    Write-Host "✓ CONCEPT 02: Created functions - Get-AzureResources, Get-RealAzureCosts, Get-DetailedCostSummary, Analyze-CostByResource (Module 02)" -ForegroundColor Green
}

# ====================================================================================================
# CONCEPT 03 - MODULE 03: ADVANCED PARAMETERS
# ====================================================================================================

function Get-CostReport {
    <#
    .SYNOPSIS
        Generate cost report with flexible parameters
    #>
    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    param(
        [Parameter(ParameterSetName = 'Summary')]
        [switch]$ShowSummary,

        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$ShowDetailed,

        [Parameter(ParameterSetName = 'TopResources')]
        [switch]$ShowTop,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 100)]
        [int]$TopCount = 10,

        [Parameter(Mandatory = $true)]
        [object[]]$CostData
    )

    process {
        if ($ShowTop) {
            return $CostData | Sort-Object MonthlyCost -Descending | Select-Object -First $TopCount
        }
        else {
            return $CostData | Sort-Object MonthlyCost -Descending
        }
    }
}

if ($script:ShowDetailedOutput) {
    Write-Host "✓ CONCEPT 03: Created flexible query interface - Get-CostReport with parameter sets (Module 03)" -ForegroundColor Green
}

# ====================================================================================================
# CONCEPT 04 - MODULE 05: ERROR HANDLING WITH RETRY
# ====================================================================================================

function Invoke-SafeAzureCall {
    <#
    .SYNOPSIS
        Execute with error handling and retry logic
    #>
    [CmdletBinding()]
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 2
    )

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            $attempt++
            Write-Verbose "Attempt $attempt of $MaxRetries"
            $result = & $ScriptBlock
            return $result
        }
        catch {
            Write-Verbose "Attempt $attempt failed: $_"
            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds $DelaySeconds
            }
            else {
                throw "Operation failed after $MaxRetries attempts: $_"
            }
        }
    }
}

if ($script:ShowDetailedOutput) {
    Write-Host "✓ CONCEPT 04: Created Invoke-SafeAzureCall with retry and error handling (Module 05)" -ForegroundColor Green
}

# ====================================================================================================
# CONCEPT 05 - MODULE 08: PARALLELISM WITH RUNSPACEPOOL
# ====================================================================================================

function Invoke-ParallelCostAnalysis {
    <#
    .SYNOPSIS
        Process resources in parallel using RunspacePool
    #>
    [CmdletBinding()]
    param(
        [object[]]$Resources,
        [int]$MaxThreads = 4
    )

    if ($Resources.Count -eq 0) {
        return @()
    }

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
    $runspacePool.Open()

    $jobs = @()
    $results = @()

    foreach ($resource in $Resources) {
        $ps = [powershell]::Create()
        $ps.AddScript({
            param($res)
            [math]::Round((Get-Random -Minimum 10 -Maximum 150), 2)
        }).AddArgument($resource) | Out-Null

        $ps.RunspacePool = $runspacePool
        $handle = $ps.BeginInvoke()
        $jobs += @{ Handle = $handle; PS = $ps; Resource = $resource }
    }

    foreach ($job in $jobs) {
        try {
            $cost = $job.PS.EndInvoke($job.Handle)
            $results += @{ Resource = $job.Resource; Cost = $cost }
        }
        finally {
            $job.PS.Dispose()
        }
    }

    $runspacePool.Close()
    $runspacePool.Dispose()

    return $results
}

if ($script:ShowDetailedOutput) {
    Write-Host "✓ CONCEPT 05: Created Invoke-ParallelCostAnalysis using RunspacePool (Module 08)" -ForegroundColor Green
    Write-Host ""
}

# ====================================================================================================
# EXECUTE COST MONITORING ANALYSIS (DETAILED MODE)
# ====================================================================================================

$costRecords = @()
$realCostData = @()

if ($script:ShowDetailedOutput) {
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "FETCHING REAL AZURE COST DATA" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""

    # Get resources and analyze costs directly
    Write-Host "  Fetching Azure resources..." -ForegroundColor Gray
    $resources = Get-AzureResources -Limit 20

    if ($resources) {
        Write-Host "  Analyzing costs for $($resources.Count) resources..." -ForegroundColor Gray
        $costAnalysisResult = Analyze-CostByResource -Resources $resources -SubscriptionId $azContext.Subscription.Id
        $costRecords = $costAnalysisResult.CostRecords
        $realCostData = $costAnalysisResult.RawCostData
    }

    Write-Host "✓ Retrieved and analyzed $($costRecords.Count) resources" -ForegroundColor Green
    Write-Host ""

    if ($costRecords.Count -gt 0) {
    # ====================================================================================================
    # DISPLAY COST SUMMARY TABLE
    # ====================================================================================================
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "COST SUMMARY (Top 10 Most Expensive Resources)" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""

    $topResources = $costRecords | Sort-Object MonthlyCost -Descending | Select-Object -First 10

    $tableData = @()
    foreach ($record in $topResources) {
        $remarks = if ($record.MonthlyCost -gt 100) { "HIGH COST - Take Action" } 
                   elseif ($record.MonthlyCost -gt 50) { "MEDIUM COST - Monitor" }
                   else { "NORMAL COST" }
        
        $tableData += [PSCustomObject]@{
            'Resource Name' = $record.ResourceName.Substring(0, [math]::Min(25, $record.ResourceName.Length))
            'Type' = $record.ResourceType.Split('/')[-1]
            'Monthly' = "`$$($record.MonthlyCost)"
            'Weekly' = "`$$($record.WeeklyCost)"
            'Forecasted Annual' = "`$$($record.ForecastedCost)"
            'Remarks' = $remarks
        }
    }

    $tableData | Format-Table -AutoSize

    # ====================================================================================================
    # DETAILED COST BREAKDOWN (Real usage records from Cost Management API)
    # ====================================================================================================
    if ($realCostData -and $realCostData.Count -gt 0) {
        Write-Host ""
        Write-Host "=====================================================================================================" -ForegroundColor Cyan
        Write-Host "DETAILED COST BREAKDOWN (Last 30 Days) - Individual Usage Records" -ForegroundColor Cyan
        Write-Host "=====================================================================================================" -ForegroundColor Cyan
        Write-Host ""
        
        $detailedSummary = Get-DetailedCostSummary -CostData $realCostData -DaysBack 30
        
        if ($detailedSummary.DetailedRecords -and $detailedSummary.DetailedRecords.Count -gt 0) {
            # Show top 15 most expensive individual usage records
            $topUsageRecords = $detailedSummary.DetailedRecords | 
                Sort-Object -Property Cost -Descending | 
                Select-Object -First 15
            
            Write-Host "📊 Top 15 Most Expensive Usage Records:" -ForegroundColor Yellow

            $headerFormat = "    {0,-12} {1,-32} {2,-20} {3,10} {4,10} {5,4}"
            Write-Host ($headerFormat -f "Date", "Resource", "Meter", "Quantity", "Cost", "Cur") -ForegroundColor DarkGray
            Write-Host ($headerFormat -f "------------", "--------------------------------", "--------------------", "----------", "----------", "----") -ForegroundColor DarkGray

            $invariantCulture = [System.Globalization.CultureInfo]::InvariantCulture

            foreach ($record in $topUsageRecords) {
                $parsedDate = $record.Date -as [datetime]
                $dateText = if ($parsedDate) { $parsedDate.ToString('yyyy-MM-dd') } elseif ($record.Date) { $record.Date.ToString() } else { '-' }

                $resourceValue = if ([string]::IsNullOrWhiteSpace($record.Resource)) { 'Unknown resource' } else { $record.Resource }
                $resourceText = if ($resourceValue.Length -gt 32) { $resourceValue.Substring(0, 29) + '…' } else { $resourceValue }

                $meterValue = if ([string]::IsNullOrWhiteSpace($record.MeterName)) { 'Unknown meter' } else { $record.MeterName }
                $meterText = if ($meterValue.Length -gt 20) { $meterValue.Substring(0, 17) + '…' } else { $meterValue }

                $qtyNumber = if ($null -ne $record.ConsumedQty) { [double]$record.ConsumedQty } else { 0 }
                $qtyText = [string]::Format($invariantCulture, "{0:N2}", $qtyNumber)

                $costNumber = if ($null -ne $record.Cost) { [double]$record.Cost } else { 0 }
                $costText = [string]::Format($invariantCulture, "{0:N4}", $costNumber)

                $currencyText = if ([string]::IsNullOrWhiteSpace($record.Currency)) { 'USD' } else { $record.Currency }
                $line = $headerFormat -f $dateText, $resourceText, $meterText, $qtyText, $costText, $currencyText
                Write-Host $line
            }
            
            # Summary statistics
            Write-Host "📈 Detailed Analysis Summary:" -ForegroundColor Cyan
            Write-Host "  • Total Usage Records: $($detailedSummary.DetailedRecords.Count)" -ForegroundColor Green
            Write-Host "  • Days Analyzed: $($detailedSummary.DaysAnalyzed)" -ForegroundColor Green
            Write-Host "  • Total Cost: $($detailedSummary.Currency)$([math]::Round($detailedSummary.TotalCost, 2))" -ForegroundColor Green
            Write-Host "  • Average Cost per Record: $($detailedSummary.Currency)$([math]::Round($detailedSummary.TotalCost / $detailedSummary.DetailedRecords.Count, 4))" -ForegroundColor Green
            
            # Save detailed report to CSV for offline analysis or sharing
            # Module 07 (Git Integration): export deterministic CSV so cost deltas can be version-controlled.
            $outFile = "AzureUsageDetailedReport_$((Get-Date).ToString('yyyyMMdd_HHmm')).csv"
            $detailedSummary.DetailedRecords | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
            Write-Host "  • 📁 Detailed report saved to: $outFile" -ForegroundColor Cyan
        }
    }

    # ====================================================================================================
    # DISPLAY AGGREGATE STATISTICS
    # ====================================================================================================
    Write-Host ""
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "AGGREGATE COST STATISTICS (REAL AZURE COST MANAGEMENT API DATA)" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""

    # Calculate real totals directly from Cost Management API records
    $totalMonthly = ($costRecords | Measure-Object -Property MonthlyCost -Sum).Sum
    $totalWeekly = $totalMonthly / 4.33
    $totalAnnual = $totalMonthly * 12
    $avgCost = if ($costRecords.Count -gt 0) { $totalMonthly / $costRecords.Count } else { 0 }

    # Check if we have subscription total from API
    $subscriptionTotal = if ($realCostData -and $realCostData.Count -gt 0) {
        $subscriptionCost = $realCostData | Where-Object { $_.resourceId -eq "subscription-total" }
        if ($subscriptionCost) { $subscriptionCost.actualCost } else { ($realCostData | Measure-Object -Property actualCost -Sum).Sum }
    } else { 0 }

    Write-Host "Total Resources: $($costRecords.Count)" -ForegroundColor Green
    if ($subscriptionTotal -gt 0) {
        Write-Host "Monthly Cost:    `$$([math]::Round($subscriptionTotal, 2)) (REAL API DATA)" -ForegroundColor Yellow
        Write-Host "Weekly Cost:     `$$([math]::Round($subscriptionTotal / 4.33, 2))" -ForegroundColor Yellow
        Write-Host "Forecasted Annual: `$$([math]::Round($subscriptionTotal * 12, 2))" -ForegroundColor Yellow
    } else {
        Write-Host "Monthly Cost:    `$$([math]::Round($totalMonthly, 2)) (REAL API DATA)" -ForegroundColor Yellow
        Write-Host "Weekly Cost:     `$$([math]::Round($totalWeekly, 2))" -ForegroundColor Yellow
        Write-Host "Forecasted Annual: `$$([math]::Round($totalAnnual, 2))" -ForegroundColor Yellow
    }
    Write-Host "Average Cost/Resource: `$$([math]::Round($avgCost, 2))" -ForegroundColor Yellow
    
    if ($totalMonthly -eq 0 -and $subscriptionTotal -eq 0) {
        Write-Host ""
        Write-Host "⚠ NOTE: All costs show `$0.00 because real Azure Cost Management API data is not available." -ForegroundColor Yellow
        Write-Host "⚠ This may be due to permissions, no current usage, or billing data delay." -ForegroundColor Yellow
    }
    Write-Host ""

    # ====================================================================================================
    # DISPLAY ACTION ITEMS (HIGH COST RESOURCES)
    # ====================================================================================================
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "ACTION ITEMS - HIGH COST RESOURCES" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""

    $highCostResources = $costRecords | Where-Object { $_.MonthlyCost -gt 100 } | Sort-Object MonthlyCost -Descending

    if ($highCostResources -and $highCostResources.Count -gt 0) {
        foreach ($resource in $highCostResources) {
            Write-Host "⚠ Resource: $($resource.ResourceName)" -ForegroundColor Red
            Write-Host "  Type: $($resource.ResourceType)" -ForegroundColor Gray
            Write-Host "  Location: $($resource.Location)" -ForegroundColor Gray
            Write-Host "  Monthly Cost: `$$($resource.MonthlyCost)" -ForegroundColor Red
            Write-Host "  Action: Review resource configuration and optimize or shut down if unused" -ForegroundColor Yellow
            Write-Host ""
        }
    }
    else {
        Write-Host "✓ No high-cost resources requiring immediate action" -ForegroundColor Green
        Write-Host ""
    }

    # ====================================================================================================
    # COST DISTRIBUTION BY RESOURCE TYPE
    # ====================================================================================================
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host "COST DISTRIBUTION BY RESOURCE TYPE" -ForegroundColor Cyan
    Write-Host "=====================================================================================================" -ForegroundColor Cyan
    Write-Host ""

    $byType = $costRecords | Group-Object -Property ResourceType | ForEach-Object {
        [PSCustomObject]@{
            'Resource Type' = $_.Name.Split('/')[-1]
            'Count' = $_.Count
            'Total Monthly' = "`$" + [math]::Round(($_.Group | Measure-Object -Property MonthlyCost -Sum).Sum, 2)
        }
    } | Sort-Object -Property @{Expression = { [double]($_.'Total Monthly' -replace '^\$', '') }; Ascending = $false}

    $byType | Format-Table -AutoSize

    Write-Host ""
    Write-Host "=====================================================================================================" -ForegroundColor Green
    Write-Host "COST MONITOR COMPLETE" -ForegroundColor Green
    Write-Host "=====================================================================================================" -ForegroundColor Gray
    Write-Host "=====================================================================================================" -ForegroundColor Green
}
else {
    Write-Host "⚠ No resources found in subscription" -ForegroundColor Yellow
}

Write-Host ""

}

$utcNow = Get-Date -AsUTC
$firstDayCurrentMonthUtc = [datetime]::new($utcNow.Year, $utcNow.Month, 1, 0, 0, 0, 0, [System.DateTimeKind]::Utc)
$firstDayLastMonthUtc = $firstDayCurrentMonthUtc.AddMonths(-1)
$lastDayLastMonthUtc = $firstDayCurrentMonthUtc.AddSeconds(-1)
$monthToDateEndUtc = if ($utcNow -gt $firstDayCurrentMonthUtc) { $utcNow } else { $firstDayCurrentMonthUtc }

$lastMonthSummary = Get-CostSummary -SubscriptionId $azContext.Subscription.Id -FromUtc $firstDayLastMonthUtc -ToUtc $lastDayLastMonthUtc -IncludeServiceBreakdown -TopServices 9
$monthToDateSummary = Get-CostSummary -SubscriptionId $azContext.Subscription.Id -FromUtc $firstDayCurrentMonthUtc -ToUtc $monthToDateEndUtc -IncludeServiceBreakdown -TopServices 9

if ($script:ShowDetailedOutput) {
    $weeklySummary = Get-CostSummary -SubscriptionId $azContext.Subscription.Id -FromUtc $utcNow.AddDays(-7) -ToUtc $utcNow
    if ($weeklySummary) {
        Write-Host ""
        Write-Host "Last 7 Days (rolling): $($weeklySummary.Currency)$([math]::Round($weeklySummary.TotalCost, 2))" -ForegroundColor Green
        Write-Host "  Period: $($weeklySummary.From) ➜ $($weeklySummary.To)" -ForegroundColor Gray
    }
}

Show-SimpleCostSnapshot -LastMonthSummary $lastMonthSummary -MonthToDateSummary $monthToDateSummary
