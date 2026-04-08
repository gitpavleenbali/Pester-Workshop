# ==============================================================================================
# 02. Advanced Functions: Azure Resource Manager
# Purpose: Demonstrate PowerShell advanced function concepts using Azure resource management
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\02_advanced_functions\Azure-Resource-Manager.ps1
#
# Prerequisites: PowerShell 5.1+, Az PowerShell module, AzCLI, Git, authenticated Azure session
# ==============================================================================================

# ==============================================================================================
# PREREQUISITE CHECK: PowerShell Version
# ==============================================================================================
Write-Host "[CHECK] Verifying PowerShell version..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
Write-Host "[INFO] PowerShell version detected: $($psVersion.ToString())" -ForegroundColor Gray

if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   POWERSHELL VERSION NOT SUPPORTED                            ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "This workshop requires PowerShell 5.1 or later." -ForegroundColor Yellow
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

# ==============================================================================================
# PREREQUISITE CHECK: Azure PowerShell Module
# ==============================================================================================
Write-Host "[CHECK] Verifying Azure PowerShell module..." -ForegroundColor Cyan

$azModule = Get-Module -Name Az.Accounts -ListAvailable -ErrorAction SilentlyContinue

if (-not $azModule) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      AZURE MODULE NOT INSTALLED                               ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "The Azure PowerShell module (Az) is required to run this workshop." -ForegroundColor Yellow
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
    Write-Host "Azure CLI is required for this workshop." -ForegroundColor Yellow
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
    Write-Host "Git is required for the hands-on exercises." -ForegroundColor Yellow
    Write-Host "Install it with: winget install Git.Git" -ForegroundColor Green
    Write-Host "More info: https://git-scm.com/downloads" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
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
Write-Host "[INFO] Starting PowerShell Advanced Functions Training..." -ForegroundColor Cyan
Write-Host "[INFO] Initializing Azure connection..." -ForegroundColor Gray

# Enhanced Azure connection with automatic login and subscription selection
function Initialize-AzureConnection {
    [CmdletBinding()]
    param(
        [string]$PreferredSubscriptionId = $null
    )

    try {
        $context = Get-AzContext -ErrorAction SilentlyContinue

        if (-not $context) {
            Write-Host "[CONNECT] Starting Azure authentication..." -ForegroundColor Yellow
            Connect-AzAccount -ErrorAction Stop | Out-Null
            Write-Host "[SUCCESS] Successfully logged in to Azure!" -ForegroundColor Green
        }
        else {
            Write-Host "[CONNECTED] Already logged in as: $($context.Account.Id)" -ForegroundColor Green
        }

        $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" } | Sort-Object Name
        if (-not $subscriptions) {
            throw "No enabled Azure subscriptions found."
        }

        $selectedSubscription = $null

        if ($PreferredSubscriptionId) {
            $selectedSubscription = $subscriptions | Where-Object {
                $_.Id -eq $PreferredSubscriptionId -or $_.SubscriptionId -eq $PreferredSubscriptionId
            } | Select-Object -First 1

            if ($selectedSubscription) {
                Write-Host "[PREFERRED] Using specified subscription: $($selectedSubscription.Name)" -ForegroundColor Cyan
            }
        }

        if (-not $selectedSubscription) {
            if ($subscriptions.Count -eq 1) {
                $selectedSubscription = $subscriptions[0]
                Write-Host "[AUTO] Using only available subscription: $($selectedSubscription.Name)" -ForegroundColor Cyan
            }
            else {
                Write-Host "[CHOICE] Multiple subscriptions available:" -ForegroundColor Yellow
                for ($i = 0; $i -lt $subscriptions.Count; $i++) {
                    $sub = $subscriptions[$i]
                    Write-Host "  [$($i + 1)] $($sub.Name) ($($sub.Id))" -ForegroundColor Gray
                }

                do {
                    $choice = Read-Host "Select subscription (1-$($subscriptions.Count)) or press Enter for default"
                    if ([string]::IsNullOrWhiteSpace($choice)) {
                        $selectedSubscription = $subscriptions[0]
                        Write-Host "[DEFAULT] Using first subscription: $($selectedSubscription.Name)" -ForegroundColor Cyan
                        break
                    }
                    elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $subscriptions.Count) {
                        $selectedSubscription = $subscriptions[[int]$choice - 1]
                        Write-Host "[SELECTED] Using subscription: $($selectedSubscription.Name)" -ForegroundColor Cyan
                        break
                    }
                    else {
                        Write-Host "[ERROR] Invalid choice. Please enter a number between 1 and $($subscriptions.Count)" -ForegroundColor Red
                    }
                } while ($true)
            }
        }

        Set-AzContext -SubscriptionId $selectedSubscription.Id -TenantId $selectedSubscription.TenantId | Out-Null
        Write-Host "[CONTEXT] Subscription context set successfully" -ForegroundColor Green

        return $selectedSubscription
    }
    catch {
        Write-Host "[ERROR] Azure connection failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[HELP] Ensure Azure PowerShell module is installed and you have active subscription access." -ForegroundColor Yellow
        exit 1
    }
}

# Initialize Azure connection
$subscription = Initialize-AzureConnection

$separator = "=" * 80
Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 1: BASIC FUNCTIONS - Function declaration and basic parameters
# ============================================================================
# EXPLANATION: Functions are named code blocks that accept input parameters and return output
# - Basic syntax: function Name { param() code block }
# - Parameters make functions flexible and reusable across different scenarios
Write-Host "[CONCEPT 1] Basic Functions" -ForegroundColor White
Write-Host "Creating simple Azure resource functions with basic parameters" -ForegroundColor Gray

# Basic function definition
function Get-AzureResourceSummary {
    param(
        $ResourceGroupName,
        $ResourceType
    )
    
    if ($ResourceGroupName) {
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        $scope = "Resource Group: $ResourceGroupName"
    } else {
        $resources = Get-AzResource
        $scope = "Subscription-wide"
    }
    
    if ($ResourceType) {
        $resources = $resources | Where-Object { $_.ResourceType -like "*$ResourceType*" }
        $scope += " (Type: $ResourceType)"
    }
    
    return [PSCustomObject]@{
        Scope = $scope
        TotalResources = $resources.Count
        ResourceTypes = ($resources | Group-Object ResourceType).Count
        FirstResource = if ($resources) { $resources[0].Name } else { "None" }
    }
}

# Function execution and demonstration
Write-Host "[FUNCTION] Executing Get-AzureResourceSummary (no parameters)" -ForegroundColor Yellow
$basicSummary = Get-AzureResourceSummary
Write-Host "[RESULT] $($basicSummary.Scope): $($basicSummary.TotalResources) resources" -ForegroundColor Yellow

Write-Host "[FUNCTION] Executing Get-AzureResourceSummary with ResourceType parameter" -ForegroundColor Yellow
$storageSummary = Get-AzureResourceSummary -ResourceType "Storage"
Write-Host "[RESULT] $($storageSummary.Scope): $($storageSummary.TotalResources) resources" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Parameter Handling..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: PARAMETER HANDLING - Strong typing, defaults, validation
# ============================================================================
# EXPLANATION: Advanced parameter handling includes type constraints, default values, and validation
# - [string] enforces type safety, [ValidateSet] restricts allowed values
# - Default values provide fallbacks, mandatory parameters ensure required input
Write-Host "[CONCEPT 2] Parameter Handling" -ForegroundColor White
Write-Host "Advanced parameter features: typing, defaults, validation, mandatory" -ForegroundColor Gray

# Advanced parameter function
function New-AzureResourceGroup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [ValidateSet("eastus", "westus", "westeurope", "eastus2")]
        [string]$Location = "eastus",
        
        [hashtable]$Tags = @{
            CreatedBy = "PowerShell Workshop"
            Purpose = "Advanced Functions Demo"
        },
        
        [int]$TimeoutMinutes = 5
    )
    
    Write-Host "[PARAMETER] Name: $Name (Mandatory string)" -ForegroundColor Yellow
    Write-Host "[PARAMETER] Location: $Location (ValidateSet with default)" -ForegroundColor Yellow
    Write-Host "[PARAMETER] Tags: $($Tags.Keys -join ', ') (Hashtable with defaults)" -ForegroundColor Yellow
    Write-Host "[PARAMETER] Timeout: $TimeoutMinutes minutes (Integer with default)" -ForegroundColor Yellow
    
    # Simulate resource group creation (safe for workshop)
    $simulatedRG = [PSCustomObject]@{
        ResourceGroupName = $Name
        Location = $Location
        ProvisioningState = "Succeeded"
        Tags = $Tags
        CreatedAt = Get-Date
    }
    
    Write-Host "[SIMULATED] Resource Group '$Name' would be created in $Location" -ForegroundColor Green
    return $simulatedRG
}

# Demonstrate parameter features
Write-Host "[DEMO] Calling function with mandatory parameter prompt..." -ForegroundColor Yellow
try {
    # This will prompt for the mandatory Name parameter
    $newRG = New-AzureResourceGroup -Location "westeurope" -Tags @{Environment="Demo"}
    Write-Host "[SUCCESS] Function completed with user input" -ForegroundColor Green
} catch {
    Write-Host "[DEMO] User cancelled mandatory parameter prompt" -ForegroundColor Gray
}

Write-Host "`n[PAUSE] Press Enter to continue to Comment-Based Help..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: COMMENT-BASED HELP - Documentation for discoverability
# ============================================================================
# EXPLANATION: Comment-based help makes functions discoverable via Get-Help
# - .SYNOPSIS provides one-line description, .DESCRIPTION gives detailed explanation
# - .PARAMETER documents each parameter, .EXAMPLE shows usage patterns
Write-Host "[CONCEPT 3] Comment-Based Help" -ForegroundColor White
Write-Host "Documenting functions with built-in help system" -ForegroundColor Gray

# Function with comprehensive help
function Get-AzureStorageAnalysis {
    <#
    .SYNOPSIS
    Analyzes Azure Storage accounts and their usage patterns.
    
    .DESCRIPTION
    This function provides detailed analysis of Azure Storage accounts including
    blob containers, file shares, and storage metrics. It can analyze specific
    storage accounts or all storage accounts in a subscription/resource group.
    
    .PARAMETER StorageAccountName
    The name of a specific storage account to analyze. If not provided,
    all storage accounts in the scope will be analyzed.
    
    .PARAMETER ResourceGroupName
    Limits the analysis to storage accounts in a specific resource group.
    If not provided, analyzes storage accounts across the entire subscription.
    
    .PARAMETER IncludeMetrics
    Switch parameter to include storage metrics and usage statistics
    in the analysis output.
    
    .EXAMPLE
    Get-AzureStorageAnalysis
    Analyzes all storage accounts in the current subscription.
    
    .EXAMPLE
    Get-AzureStorageAnalysis -ResourceGroupName "production-rg"
    Analyzes storage accounts only in the "production-rg" resource group.
    
    .EXAMPLE
    Get-AzureStorageAnalysis -StorageAccountName "mystorageacct" -IncludeMetrics
    Analyzes a specific storage account and includes detailed metrics.
    
    .NOTES
    This function requires Azure PowerShell module and appropriate permissions
    to read storage account information.
    
    .LINK
    https://docs.microsoft.com/en-us/azure/storage/
    #>
    
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [switch]$IncludeMetrics
    )
    
    Write-Host "[HELP DEMO] This function has comprehensive comment-based help" -ForegroundColor Yellow
    Write-Host "[HELP DEMO] Try: Get-Help Get-AzureStorageAnalysis -Full" -ForegroundColor Yellow
    
    # Get storage accounts based on parameters
    if ($StorageAccountName) {
        $storageAccounts = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName }
        $scope = "Storage Account: $StorageAccountName"
    } elseif ($ResourceGroupName) {
        $storageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName
        $scope = "Resource Group: $ResourceGroupName"
    } else {
        $storageAccounts = Get-AzStorageAccount
        $scope = "Subscription-wide"
    }
    
    $analysis = [PSCustomObject]@{
        Scope = $scope
        StorageAccountCount = $storageAccounts.Count
        Locations = ($storageAccounts | Group-Object Location | Select-Object Name, Count)
        SkuTypes = ($storageAccounts | Group-Object Sku | Select-Object Name, Count)
        IncludesMetrics = $IncludeMetrics.IsPresent
        AnalyzedAt = Get-Date
    }
    
    Write-Host "[ANALYSIS] $($analysis.Scope): Found $($analysis.StorageAccountCount) storage accounts" -ForegroundColor Yellow
    return $analysis
}

# Demonstrate help system
Write-Host "[DEMO] Function with comprehensive help is now available" -ForegroundColor Yellow
Write-Host "[DEMO] You can run: Get-Help Get-AzureStorageAnalysis -Examples" -ForegroundColor Yellow

# Execute the function
$storageAnalysis = Get-AzureStorageAnalysis -IncludeMetrics
Write-Host "[RESULT] Storage analysis completed for: $($storageAnalysis.Scope)" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to CmdletBinding..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: CMDLETBINDING ATTRIBUTE - Advanced function behavior
# ============================================================================
# EXPLANATION: [CmdletBinding()] transforms a function into an advanced function
# - Enables common parameters like -Verbose, -ErrorAction, -WarningAction
# - Provides access to $PSCmdlet for advanced cmdlet operations and pipeline handling
Write-Host "[CONCEPT 4] CmdletBinding Attribute" -ForegroundColor White
Write-Host "Enabling advanced function features with [CmdletBinding()]" -ForegroundColor Gray

# Advanced function with CmdletBinding
function Set-AzureResourceTags {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ResourceId,
        
        [hashtable]$Tags = @{},
        
        [switch]$AppendTags
    )
    
    begin {
        Write-Host "[CMDLETBINDING] Function supports common parameters" -ForegroundColor Yellow
        Write-Host "[CMDLETBINDING] Available: -Verbose, -ErrorAction, -WarningAction, etc." -ForegroundColor Yellow
        $processedCount = 0
    }
    
    process {
        $processedCount++
        
        # Simulate getting current resource
        Write-Verbose "Processing resource: $ResourceId"
        
        # Simulate tag operations
        if ($AppendTags) {
            Write-Verbose "Appending tags to existing resource tags"
            $operation = "Append"
        } else {
            Write-Verbose "Replacing all resource tags"
            $operation = "Replace"
        }
        
        # Simulate the tagging operation
        Write-Host "[TAGGING] $operation tags on resource #$processedCount" -ForegroundColor Yellow
        
        foreach ($key in $Tags.Keys) {
            Write-Verbose "Setting tag: $key = $($Tags[$key])"
        }
        
        # Return result object
        [PSCustomObject]@{
            ResourceId = $ResourceId
            Operation = $operation
            TagsApplied = $Tags.Count
            ProcessedAt = Get-Date
        }
    }
    
    end {
        Write-Verbose "Completed processing $processedCount resources"
        Write-Host "[COMPLETE] Processed $processedCount resources with CmdletBinding features" -ForegroundColor Green
    }
}

# Demonstrate CmdletBinding features
Write-Host "[DEMO] Testing CmdletBinding function with -Verbose parameter" -ForegroundColor Yellow

# Get a sample resource ID for demonstration
$sampleResources = Get-AzResource | Select-Object -First 2
if ($sampleResources) {
    $sampleResources | ForEach-Object { $_.ResourceId } | 
        Set-AzureResourceTags -Tags @{Workshop="Advanced Functions"; Demo="CmdletBinding"} -Verbose
} else {
    Write-Host "[DEMO] No resources available for demonstration" -ForegroundColor Gray
}

Write-Host "`n[PAUSE] Press Enter to continue to Common Parameters..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: COMMON PARAMETERS - Using -Verbose, -ErrorAction, etc.
# ============================================================================
# EXPLANATION: Common parameters provide standardized control over function behavior
# - Write-Verbose displays detailed information when -Verbose is used
# - Write-Warning shows warnings, Write-Progress displays progress bars
Write-Host "[CONCEPT 5] Common Parameters" -ForegroundColor White
Write-Host "Implementing -Verbose, -ErrorAction, and progress reporting" -ForegroundColor Gray

# Function demonstrating common parameters
function Remove-AzureOrphanedResources {
    [CmdletBinding()]
    param(
        [string]$ResourceGroupName,
        
        [ValidateSet("NetworkSecurityGroup", "PublicIpAddress", "NetworkInterface")]
        [string]$ResourceType = "NetworkInterface",
        
        [int]$MaxResources = 10
    )
    
    Write-Verbose "Starting orphaned resource detection"
    Write-Verbose "Resource Type: $ResourceType"
    Write-Verbose "Max Resources to Process: $MaxResources"
    
    # Get resources for analysis
    if ($ResourceGroupName) {
        Write-Verbose "Limiting search to Resource Group: $ResourceGroupName"
        $allResources = Get-AzResource -ResourceGroupName $ResourceGroupName
    } else {
        Write-Verbose "Searching entire subscription"
        $allResources = Get-AzResource
    }
    
    # Filter by resource type
    $targetResources = $allResources | Where-Object { $_.ResourceType -like "*$ResourceType*" } | Select-Object -First $MaxResources
    
    Write-Host "[ANALYSIS] Found $($targetResources.Count) $ResourceType resources to analyze" -ForegroundColor Yellow
    
    $orphanedResources = @()
    $processedCount = 0
    
    foreach ($resource in $targetResources) {
        $processedCount++
        
        # Update progress
        $percentComplete = ($processedCount / $targetResources.Count) * 100
        Write-Progress -Activity "Analyzing Resources" -Status "Processing $($resource.Name)" -PercentComplete $percentComplete
        
        Write-Verbose "Analyzing resource: $($resource.Name)"
        
        # Simulate orphaned resource detection logic
        $isOrphaned = (Get-Random -Minimum 1 -Maximum 10) -gt 7  # 30% chance of being "orphaned"
        
        if ($isOrphaned) {
            Write-Warning "Found potentially orphaned resource: $($resource.Name)"
            $orphanedResources += [PSCustomObject]@{
                Name = $resource.Name
                ResourceType = $resource.ResourceType
                ResourceGroup = $resource.ResourceGroupName
                Location = $resource.Location
                DetectedAt = Get-Date
            }
        } else {
            Write-Verbose "Resource $($resource.Name) appears to be in use"
        }
        
        # Simulate processing time
        Start-Sleep -Milliseconds 100
    }
    
    Write-Progress -Activity "Analyzing Resources" -Completed
    Write-Verbose "Analysis completed. Found $($orphanedResources.Count) orphaned resources"
    
    # Return results
    [PSCustomObject]@{
        ResourceType = $ResourceType
        TotalAnalyzed = $processedCount
        OrphanedFound = $orphanedResources.Count
        OrphanedResources = $orphanedResources
        AnalysisScope = if ($ResourceGroupName) { "Resource Group: $ResourceGroupName" } else { "Subscription-wide" }
    }
}

# Demonstrate common parameters
Write-Host "[DEMO] Running orphaned resource analysis with -Verbose" -ForegroundColor Yellow
$orphanAnalysis = Remove-AzureOrphanedResources -ResourceType "NetworkInterface" -MaxResources 5 -Verbose

Write-Host "[RESULT] Analysis complete: $($orphanAnalysis.OrphanedFound) orphaned resources found" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Risk Mitigation..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: RISK MITIGATION - SupportsShouldProcess and confirmation
# ============================================================================
# EXPLANATION: Risk mitigation prevents accidental destructive operations
# - SupportsShouldProcess enables -WhatIf and -Confirm parameters
# - $PSCmdlet.ShouldProcess() asks for confirmation before dangerous operations
Write-Host "[CONCEPT 6] Risk Mitigation" -ForegroundColor White
Write-Host "Implementing -WhatIf and -Confirm for destructive operations" -ForegroundColor Gray

# Function with risk mitigation
function Stop-AzureVirtualMachines {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [string]$ResourceGroupName,
        
        [string[]]$VMNames,
        
        [switch]$Force
    )
    
    Write-Verbose "Starting VM stop operation"
    
    # Get VMs based on parameters
    if ($VMNames) {
        $vms = @()
        foreach ($vmName in $VMNames) {
            if ($ResourceGroupName) {
                $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -ErrorAction SilentlyContinue
            } else {
                $vm = Get-AzVM -Name $vmName -ErrorAction SilentlyContinue
            }
            if ($vm) { $vms += $vm }
        }
    } elseif ($ResourceGroupName) {
        $vms = Get-AzVM -ResourceGroupName $ResourceGroupName
    } else {
        $vms = Get-AzVM
    }
    
    Write-Host "[DISCOVERED] Found $($vms.Count) virtual machines to stop" -ForegroundColor Yellow
    
    $stoppedVMs = @()
    
    foreach ($vm in $vms) {
        $vmInfo = "$($vm.Name) in $($vm.ResourceGroupName)"
        
        # Risk mitigation check
        if ($PSCmdlet.ShouldProcess($vmInfo, "Stop Virtual Machine")) {
            Write-Host "[STOPPING] VM: $vmInfo" -ForegroundColor Yellow
            Write-Verbose "Executing stop operation for $vmInfo"
            
            # Simulate VM stop operation (safe for workshop)
            Start-Sleep -Milliseconds 500
            
            $stoppedVMs += [PSCustomObject]@{
                VMName = $vm.Name
                ResourceGroup = $vm.ResourceGroupName
                Location = $vm.Location
                StoppedAt = Get-Date
                Status = "Simulated Stop"
            }
            
            Write-Host "[SUCCESS] VM stopped: $vmInfo" -ForegroundColor Green
        } else {
            Write-Host "[SKIPPED] VM stop cancelled by user: $vmInfo" -ForegroundColor Gray
        }
    }
    
    return [PSCustomObject]@{
        TotalVMs = $vms.Count
        StoppedVMs = $stoppedVMs.Count
        StoppedVMList = $stoppedVMs
        Operation = "Stop Virtual Machines"
    }
}

# Demonstrate risk mitigation
Write-Host "[DEMO] Testing risk mitigation with -WhatIf parameter" -ForegroundColor Yellow
$whatIfResult = Stop-AzureVirtualMachines -WhatIf

Write-Host "[DEMO] The function supports -WhatIf to preview operations safely" -ForegroundColor Yellow
Write-Host "[DEMO] It also supports -Confirm parameter for interactive confirmation" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Parameter Sets..." -ForegroundColor Magenta
$pause6 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 7: PARAMETER SETS & PAGING - Multiple ways to call functions
# ============================================================================
# EXPLANATION: Parameter sets define different ways to call the same function
# - DefaultParameterSetName specifies which set to use when ambiguous
# - SupportsPaging enables -First, -Skip, -IncludeTotalCount for large datasets
Write-Host "[CONCEPT 7] Parameter Sets & Paging" -ForegroundColor White
Write-Host "Multiple function calling patterns and paging support" -ForegroundColor Gray

# Function with parameter sets and paging
function Get-AzureResourceMetrics {
    [CmdletBinding(DefaultParameterSetName = "BySubscription", SupportsPaging)]
    param(
        # Parameter Set 1: By Subscription
        [Parameter(ParameterSetName = "BySubscription")]
        [switch]$IncludeAllSubscriptions,
        
        # Parameter Set 2: By Resource Group
        [Parameter(ParameterSetName = "ByResourceGroup", Mandatory = $true)]
        [string]$ResourceGroupName,
        
        # Parameter Set 3: By Resource Type
        [Parameter(ParameterSetName = "ByResourceType", Mandatory = $true)]
        [ValidateSet("Microsoft.Compute/virtualMachines", "Microsoft.Storage/storageAccounts", "Microsoft.Network/virtualNetworks")]
        [string]$ResourceType,
        
        # Common parameters across all sets
        [ValidateSet("Summary", "Detailed", "Extended")]
        [string]$MetricLevel = "Summary",
        
        [datetime]$StartTime = (Get-Date).AddDays(-7),
        [datetime]$EndTime = (Get-Date)
    )
    
    Write-Host "[PARAMETER SET] Using parameter set: $($PSCmdlet.ParameterSetName)" -ForegroundColor Yellow
    Write-Verbose "Metric Level: $MetricLevel"
    Write-Verbose "Time Range: $StartTime to $EndTime"
    
    # Get resources based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        "BySubscription" {
            $scope = "Subscription-wide"
            $resources = Get-AzResource
            if ($IncludeAllSubscriptions) {
                Write-Host "[INFO] Multi-subscription analysis not implemented in demo" -ForegroundColor Gray
            }
        }
        "ByResourceGroup" {
            $scope = "Resource Group: $ResourceGroupName"
            $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
            Write-Verbose "Filtering by Resource Group: $ResourceGroupName"
        }
        "ByResourceType" {
            $scope = "Resource Type: $ResourceType"
            $resources = Get-AzResource | Where-Object { $_.ResourceType -eq $ResourceType }
            Write-Verbose "Filtering by Resource Type: $ResourceType"
        }
    }
    
    Write-Host "[SCOPE] Analyzing: $scope" -ForegroundColor Yellow
    Write-Host "[RESOURCES] Found $($resources.Count) resources to analyze" -ForegroundColor Yellow
    
    # Handle paging parameters
    $totalCount = $resources.Count
    $skip = if ($PSCmdlet.PagingParameters.Skip) { [int]$PSCmdlet.PagingParameters.Skip } else { 0 }
    
    # Handle First parameter properly - if it's the default max value, use totalCount instead
    if ($PSCmdlet.PagingParameters.First -and $PSCmdlet.PagingParameters.First -lt [uint64]::MaxValue) {
        $first = [int]$PSCmdlet.PagingParameters.First
    } else {
        $first = $totalCount
    }
    
    # Ensure we don't try to take more than available
    $actualFirst = [Math]::Min($first, $totalCount - $skip)
    if ($actualFirst -lt 0) { $actualFirst = 0 }
    
    $pagedResources = $resources | Select-Object -Skip $skip -First $actualFirst
    
    Write-Host "[PAGING] Showing $($pagedResources.Count) of $totalCount resources (Skip: $skip, Take: $actualFirst)" -ForegroundColor Yellow
    
    # Generate metrics for each resource
    $metrics = @()
    foreach ($resource in $pagedResources) {
        $metrics += [PSCustomObject]@{
            ResourceName = $resource.Name
            ResourceType = $resource.ResourceType
            ResourceGroup = $resource.ResourceGroupName
            Location = $resource.Location
            MetricLevel = $MetricLevel
            AvailabilityScore = (Get-Random -Minimum 85 -Maximum 100)
            PerformanceScore = (Get-Random -Minimum 70 -Maximum 95)
            CostScore = (Get-Random -Minimum 60 -Maximum 90)
            LastUpdated = Get-Date
        }
    }
    
    # Return results with paging information
    $result = [PSCustomObject]@{
        ParameterSet = $PSCmdlet.ParameterSetName
        Scope = $scope
        MetricLevel = $MetricLevel
        TotalResources = $totalCount
        ReturnedResources = $pagedResources.Count
        PagingInfo = @{
            Skip = $skip
            First = $actualFirst
            HasMore = ($skip + $actualFirst) -lt $totalCount
        }
        Metrics = $metrics
        GeneratedAt = Get-Date
    }
    
    # Include total count if requested
    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $accuracy = 1.0  # 100% accuracy for our demo
        $PSCmdlet.PagingParameters.NewTotalCount($totalCount, $accuracy)
    }
    
    return $result
}

# Demonstrate parameter sets and paging
Write-Host "[DEMO] Testing different parameter sets:" -ForegroundColor Yellow

Write-Host "[DEMO 1] Default parameter set (BySubscription)" -ForegroundColor Cyan
$metrics1 = Get-AzureResourceMetrics -MetricLevel "Summary" -First 3
Write-Host "[RESULT] $($metrics1.ParameterSet): $($metrics1.ReturnedResources) of $($metrics1.TotalResources) resources" -ForegroundColor Yellow

# Get a sample resource group for demo
$sampleRG = Get-AzResourceGroup | Select-Object -First 1
if ($sampleRG) {
    Write-Host "[DEMO 2] ByResourceGroup parameter set" -ForegroundColor Cyan
    $metrics2 = Get-AzureResourceMetrics -ResourceGroupName $sampleRG.ResourceGroupName -MetricLevel "Detailed"
    Write-Host "[RESULT] $($metrics2.ParameterSet): $($metrics2.ReturnedResources) resources in $($sampleRG.ResourceGroupName)" -ForegroundColor Yellow
}

Write-Host "[DEMO 3] ByResourceType parameter set with paging" -ForegroundColor Cyan
$metrics3 = Get-AzureResourceMetrics -ResourceType "Microsoft.Storage/storageAccounts" -First 2 -IncludeTotalCount
Write-Host "[RESULT] $($metrics3.ParameterSet): $($metrics3.ReturnedResources) of $($metrics3.TotalResources) storage accounts" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause7 = Read-Host

# ============================================================================
# WORKSHOP SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[WORKSHOP COMPLETE] PowerShell Advanced Functions - Azure Resource Manager" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[ADVANCED FUNCTION CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Basic Functions: Get-AzureResourceSummary with simple parameters" -ForegroundColor Gray
Write-Host "2. Parameter Handling: Strong typing, validation, defaults, mandatory parameters" -ForegroundColor Gray
Write-Host "3. Comment-Based Help: Full documentation with .SYNOPSIS, .EXAMPLE, .NOTES" -ForegroundColor Gray
Write-Host "4. CmdletBinding: [CmdletBinding()] enabling common parameters and pipeline support" -ForegroundColor Gray
Write-Host "5. Common Parameters: -Verbose, -ErrorAction, Write-Progress, Write-Warning" -ForegroundColor Gray
Write-Host "6. Risk Mitigation: SupportsShouldProcess, -WhatIf, -Confirm, ConfirmImpact" -ForegroundColor Gray
Write-Host "7. Parameter Sets: Multiple calling patterns, SupportsPaging, -First, -Skip" -ForegroundColor Gray

Write-Host "`n[AZURE SCENARIOS COVERED]" -ForegroundColor White
Write-Host "Resource summarization, resource group creation, storage analysis" -ForegroundColor Gray
Write-Host "Resource tagging, orphaned resource detection, VM management" -ForegroundColor Gray
Write-Host "Resource metrics with flexible querying and paging" -ForegroundColor Gray

Write-Host "`n[LIVE FUNCTIONS AVAILABLE]" -ForegroundColor White
Write-Host "Try: Get-Help Get-AzureStorageAnalysis -Examples" -ForegroundColor Gray
Write-Host "Try: Get-AzureResourceMetrics -ResourceType 'Microsoft.Storage/storageAccounts' -First 1" -ForegroundColor Gray
Write-Host "Try: Stop-AzureVirtualMachines -WhatIf" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These advanced function concepts prepare you for:" -ForegroundColor Gray
Write-Host "- Building professional PowerShell modules" -ForegroundColor Gray
Write-Host "- Creating enterprise automation scripts" -ForegroundColor Gray
Write-Host "- Implementing robust error handling and user experience" -ForegroundColor Gray

Write-Host "`nSubscription: $($subscription.Name)" -ForegroundColor Gray
Write-Host "Workshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray