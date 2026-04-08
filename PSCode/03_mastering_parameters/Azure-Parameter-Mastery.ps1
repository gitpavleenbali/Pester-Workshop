# ==============================================================================================
# 03. Mastering Parameters: Azure Parameter Management Training
# Purpose: Demonstrate advanced PowerShell parameter handling using Azure management scenarios
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\03_mastering_parameters\Azure-Parameter-Mastery.ps1
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
Write-Host "[INFO] Starting PowerShell Parameter Mastery Workshop..." -ForegroundColor Cyan
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
# CONCEPT 1: PARAMETER ATTRIBUTES - Mandatory, Position, HelpMessage
# ============================================================================
# EXPLANATION: Parameter attributes control how parameters behave and interact with users
# - Mandatory requires user input, Position sets order, HelpMessage provides guidance
# - ValueFromPipeline enables pipeline input, ParameterSetName groups related parameters
Write-Host "[CONCEPT 1] Parameter Attributes" -ForegroundColor White
Write-Host "Mandatory, Position, HelpMessage, and pipeline input parameters" -ForegroundColor Gray

# Function demonstrating basic parameter attributes
function New-AzureResourceDeployment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the deployment name (e.g., WebApp-Prod-001)")]
        [string]$DeploymentName,
        
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Select the target resource group for deployment")]
        [string]$ResourceGroupName,
        
        [Parameter(Position = 2, HelpMessage = "Choose deployment region (default: eastus)")]
        [ValidateSet("eastus", "westus", "westeurope", "eastus2", "centralus")]
        [string]$Location = "eastus",
        
        [Parameter(ValueFromPipeline = $true, HelpMessage = "Provide template parameters as hashtable or from pipeline")]
        [hashtable]$TemplateParameters = @{},
        
        [Parameter(HelpMessage = "Add custom tags for resource tracking")]
        [hashtable]$Tags = @{
            CreatedBy = "PowerShell Workshop"
            Workshop = "Parameter Mastery"
        }
    )
    
    begin {
        Write-Host "[PARAMETER DEMO] Demonstrating parameter attributes:" -ForegroundColor Yellow
        Write-Host "  - Mandatory parameters require user input" -ForegroundColor Gray
        Write-Host "  - Position allows calling without parameter names" -ForegroundColor Gray
        Write-Host "  - HelpMessage provides user guidance" -ForegroundColor Gray
        Write-Host "  - ValueFromPipeline accepts pipeline input" -ForegroundColor Gray
    }
    
    process {
        Write-Host "[PROCESSING] Deployment Configuration:" -ForegroundColor Yellow
        Write-Host "  Name: $DeploymentName (Position 0, Mandatory)" -ForegroundColor Gray
        Write-Host "  Resource Group: $ResourceGroupName (Position 1, Mandatory)" -ForegroundColor Gray
        Write-Host "  Location: $Location (Position 2, with default)" -ForegroundColor Gray
        Write-Host "  Parameters: $($TemplateParameters.Count) items (Pipeline input)" -ForegroundColor Gray
        Write-Host "  Tags: $($Tags.Count) items (Default values provided)" -ForegroundColor Gray
        
        # Simulate deployment validation
        $deployment = [PSCustomObject]@{
            DeploymentName = $DeploymentName
            ResourceGroup = $ResourceGroupName
            Location = $Location
            Status = "Validated"
            ParameterCount = $TemplateParameters.Count
            TagCount = $Tags.Count
            CreatedAt = Get-Date
        }
        
        Write-Host "[VALIDATED] Deployment configuration is ready" -ForegroundColor Green
        return $deployment
    }
}

# Demonstrate parameter attributes
Write-Host "[DEMO] Testing parameter attributes and help messages:" -ForegroundColor Yellow

# Example 1: Positional parameters
Write-Host "[DEMO 1] Calling with positional parameters" -ForegroundColor Cyan
$deployment1 = New-AzureResourceDeployment "WebApp-Demo" "Demo-RG" "westus"

# Example 2: Named parameters with pipeline input
Write-Host "[DEMO 2] Named parameters with pipeline input" -ForegroundColor Cyan
$templateParams = @{
    appServicePlanName = "ASP-Demo"
    webAppName = "WebApp-Demo-001"
    skuName = "S1"
}
$deployment2 = $templateParams | New-AzureResourceDeployment -DeploymentName "PipelineDemo" -ResourceGroupName "Demo-RG"

Write-Host "`n[PAUSE] Press Enter to continue to Positional Parameters..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: POSITIONAL PARAMETERS - Order and binding behavior
# ============================================================================
# EXPLANATION: Positional parameters allow calling functions without parameter names
# - Position = 0 is first, Position = 1 is second, etc.
# - PositionalBinding = $false disables positional binding globally
Write-Host "[CONCEPT 2] Positional Parameters" -ForegroundColor White
Write-Host "Parameter ordering and positional binding control" -ForegroundColor Gray

# Function with specific positional parameter design
function Set-AzureNetworkConfiguration {
    [CmdletBinding(PositionalBinding = $true)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$VirtualNetworkName,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$AddressPrefix,
        
        [Parameter(Position = 2)]
        [string]$SubnetName = "default",
        
        [Parameter(Position = 3)]
        [string]$SubnetPrefix = "10.0.1.0/24",
        
        # Named-only parameters (no position assigned)
        [string]$Location = "eastus",
        [string]$ResourceGroupName,
        [hashtable]$Tags = @{}
    )
    
    Write-Host "[POSITIONAL DEMO] Parameter binding analysis:" -ForegroundColor Yellow
    Write-Host "  Position 0: VirtualNetworkName = '$VirtualNetworkName'" -ForegroundColor Gray
    Write-Host "  Position 1: AddressPrefix = '$AddressPrefix'" -ForegroundColor Gray
    Write-Host "  Position 2: SubnetName = '$SubnetName'" -ForegroundColor Gray
    Write-Host "  Position 3: SubnetPrefix = '$SubnetPrefix'" -ForegroundColor Gray
    Write-Host "  Named-only: Location = '$Location'" -ForegroundColor Gray
    Write-Host "  Named-only: ResourceGroupName = '$ResourceGroupName'" -ForegroundColor Gray
    
    # Simulate network configuration
    $networkConfig = [PSCustomObject]@{
        VNetName = $VirtualNetworkName
        VNetAddressSpace = $AddressPrefix
        DefaultSubnet = @{
            Name = $SubnetName
            AddressPrefix = $SubnetPrefix
        }
        Location = $Location
        ResourceGroup = $ResourceGroupName
        ConfiguredAt = Get-Date
    }
    
    Write-Host "[CONFIGURED] Virtual network configuration created" -ForegroundColor Green
    return $networkConfig
}

# Function with positional binding disabled
function New-AzureSecurityGroup {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SecurityGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [string]$Location = "eastus"
    )
    
    Write-Host "[NO POSITIONAL] All parameters must be named explicitly" -ForegroundColor Yellow
    Write-Host "  SecurityGroupName: $SecurityGroupName" -ForegroundColor Gray
    Write-Host "  ResourceGroupName: $ResourceGroupName" -ForegroundColor Gray
    Write-Host "  Location: $Location" -ForegroundColor Gray
    
    return [PSCustomObject]@{
        NSGName = $SecurityGroupName
        ResourceGroup = $ResourceGroupName
        Location = $Location
        PositionalBinding = $false
        CreatedAt = Get-Date
    }
}

# Demonstrate positional parameters
Write-Host "[DEMO] Testing positional parameter behavior:" -ForegroundColor Yellow

# Example 1: Positional binding enabled
Write-Host "[DEMO 1] Positional binding enabled - parameters by position" -ForegroundColor Cyan
$vnetConfig1 = Set-AzureNetworkConfiguration "VNet-Demo" "10.0.0.0/16" "web-subnet" "10.0.2.0/24" -Location "westus"

# Example 2: Mixed positional and named parameters
Write-Host "[DEMO 2] Mixed positional and named parameters" -ForegroundColor Cyan
$vnetConfig2 = Set-AzureNetworkConfiguration "VNet-Mixed" "172.16.0.0/16" -ResourceGroupName "Network-RG" -Tags @{Environment="Demo"}

# Example 3: Positional binding disabled
Write-Host "[DEMO 3] Positional binding disabled - all parameters must be named" -ForegroundColor Cyan
$nsgConfig = New-AzureSecurityGroup -SecurityGroupName "NSG-Demo" -ResourceGroupName "Security-RG" -Location "eastus2"

Write-Host "`n[PAUSE] Press Enter to continue to Parameter Sets..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: PARAMETER SETS - Multiple function calling patterns
# ============================================================================
# EXPLANATION: Parameter sets define different ways to call the same function
# - ParameterSetName groups related parameters together
# - $PSCmdlet.ParameterSetName identifies which set is being used
Write-Host "[CONCEPT 3] Parameter Sets" -ForegroundColor White
Write-Host "Multiple calling patterns and parameter set identification" -ForegroundColor Gray

# Function with multiple parameter sets
function Get-AzureStorageInfo {
    [CmdletBinding(DefaultParameterSetName = "BySubscription")]
    param(
        # Parameter Set 1: By Storage Account Name
        [Parameter(ParameterSetName = "ByStorageAccount", Mandatory = $true, Position = 0)]
        [string]$StorageAccountName,
        
        [Parameter(ParameterSetName = "ByStorageAccount")]
        [string]$StorageResourceGroup,
        
        # Parameter Set 2: By Resource Group
        [Parameter(ParameterSetName = "ByResourceGroup", Mandatory = $true)]
        [string]$ResourceGroupName,
        
        # Parameter Set 3: By Subscription (default)
        [Parameter(ParameterSetName = "BySubscription")]
        [switch]$IncludeAllSubscriptions,
        
        # Parameter Set 4: By Location
        [Parameter(ParameterSetName = "ByLocation", Mandatory = $true)]
        [ValidateSet("eastus", "westus", "westeurope", "eastus2")]
        [string]$Location,
        
        # Common parameters across all sets
        [ValidateSet("Standard", "Premium", "All")]
        [string]$PerformanceTier = "All",
        
        [switch]$IncludeMetrics,
        [switch]$IncludeKeys
    )
    
    Write-Host "[PARAMETER SET] Active set: $($PSCmdlet.ParameterSetName)" -ForegroundColor Yellow
    Write-Host "[PARAMETER SET] Common parameters: PerformanceTier=$PerformanceTier, IncludeMetrics=$($IncludeMetrics.IsPresent)" -ForegroundColor Gray
    
    # Handle different parameter sets
    switch ($PSCmdlet.ParameterSetName) {
        "ByStorageAccount" {
            Write-Host "[SPECIFIC] Analyzing storage account: $StorageAccountName" -ForegroundColor Cyan
            if ($StorageResourceGroup) {
                $storageAccounts = Get-AzStorageAccount -ResourceGroupName $StorageResourceGroup -Name $StorageAccountName -ErrorAction SilentlyContinue
                $scope = "Storage Account: $StorageAccountName in $StorageResourceGroup"
            } else {
                $storageAccounts = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName }
                $scope = "Storage Account: $StorageAccountName (subscription-wide search)"
            }
        }
        "ByResourceGroup" {
            Write-Host "[GROUP] Analyzing resource group: $ResourceGroupName" -ForegroundColor Cyan
            $storageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName
            $scope = "Resource Group: $ResourceGroupName"
        }
        "BySubscription" {
            Write-Host "[SUBSCRIPTION] Analyzing current subscription" -ForegroundColor Cyan
            $storageAccounts = Get-AzStorageAccount
            $scope = "Current Subscription"
            if ($IncludeAllSubscriptions) {
                Write-Host "[INFO] Multi-subscription analysis not implemented in demo" -ForegroundColor Gray
            }
        }
        "ByLocation" {
            Write-Host "[LOCATION] Analyzing location: $Location" -ForegroundColor Cyan
            $storageAccounts = Get-AzStorageAccount | Where-Object { $_.Location -eq $Location }
            $scope = "Location: $Location"
        }
    }
    
    # Filter by performance tier
    if ($PerformanceTier -ne "All") {
        $storageAccounts = $storageAccounts | Where-Object { $_.Sku.Tier -eq $PerformanceTier }
    }
    
    # Generate analysis results
    $analysis = [PSCustomObject]@{
        ParameterSet = $PSCmdlet.ParameterSetName
        Scope = $scope
        StorageAccountCount = $storageAccounts.Count
        PerformanceTierFilter = $PerformanceTier
        IncludesMetrics = $IncludeMetrics.IsPresent
        IncludesKeys = $IncludeKeys.IsPresent
        StorageAccounts = $storageAccounts | Select-Object StorageAccountName, ResourceGroupName, Location, @{Name="SkuTier"; Expression={$_.Sku.Tier}}
        AnalyzedAt = Get-Date
    }
    
    Write-Host "[RESULTS] Found $($analysis.StorageAccountCount) storage accounts matching criteria" -ForegroundColor Yellow
    return $analysis
}

# Demonstrate parameter sets
Write-Host "[DEMO] Testing different parameter sets:" -ForegroundColor Yellow

Write-Host "[DEMO 1] BySubscription (default parameter set)" -ForegroundColor Cyan
$storageInfo1 = Get-AzureStorageInfo -PerformanceTier "Standard" -IncludeMetrics

# Get sample data for demos
$sampleRG = Get-AzResourceGroup | Select-Object -First 1
$sampleStorage = Get-AzStorageAccount | Select-Object -First 1

if ($sampleRG) {
    Write-Host "[DEMO 2] ByResourceGroup parameter set" -ForegroundColor Cyan
    $storageInfo2 = Get-AzureStorageInfo -ResourceGroupName $sampleRG.ResourceGroupName
}

if ($sampleStorage) {
    Write-Host "[DEMO 3] ByStorageAccount parameter set" -ForegroundColor Cyan
    $storageInfo3 = Get-AzureStorageInfo -StorageAccountName $sampleStorage.StorageAccountName -StorageResourceGroup $sampleStorage.ResourceGroupName -IncludeKeys
}

Write-Host "[DEMO 4] ByLocation parameter set" -ForegroundColor Cyan
$storageInfo4 = Get-AzureStorageInfo -Location "eastus" -PerformanceTier "Premium"

Write-Host "`n[PAUSE] Press Enter to continue to Pipeline Input..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: PIPELINE INPUT - ValueFromPipeline and ValueFromPipelineByPropertyName
# ============================================================================
# EXPLANATION: Pipeline input allows functions to process objects from the pipeline
# - ValueFromPipeline accepts entire objects, ValueFromPipelineByPropertyName binds by property names
# - begin/process/end blocks handle pipeline processing efficiently
Write-Host "[CONCEPT 4] Pipeline Input" -ForegroundColor White
Write-Host "ValueFromPipeline and ValueFromPipelineByPropertyName demonstrations" -ForegroundColor Gray

# Function demonstrating pipeline input methods
function Set-AzureResourceOwnership {
    [CmdletBinding()]
    param(
        # Direct pipeline input - accepts entire objects
        [Parameter(ValueFromPipeline = $true, ParameterSetName = "DirectPipeline")]
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResource]$ResourceObject,
        
        # Pipeline by property name - binds to matching property names
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByPropertyName")]
        [Alias("ResourceName")]
        [string]$Name,
        
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByPropertyName")]
        [string]$ResourceGroupName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByPropertyName")]
        [string]$ResourceType,
        
        # Common parameters
        [Parameter(Mandatory = $true)]
        [string]$OwnerEmail,
        
        [string]$Department = "IT Operations",
        [string]$CostCenter = "CC-001"
    )
    
    begin {
        Write-Host "[PIPELINE DEMO] Starting resource ownership assignment" -ForegroundColor Yellow
        Write-Host "[PIPELINE DEMO] Parameter set: $($PSCmdlet.ParameterSetName)" -ForegroundColor Gray
        $processedCount = 0
    }
    
    process {
        $processedCount++
        
        # Handle different input methods
        if ($PSCmdlet.ParameterSetName -eq "DirectPipeline") {
            $resourceName = $ResourceObject.Name
            $resourceGroup = $ResourceObject.ResourceGroupName
            $resourceType = $ResourceObject.ResourceType
            $inputMethod = "Direct object from pipeline"
        } else {
            $resourceName = $Name
            $resourceGroup = $ResourceGroupName
            $resourceType = $ResourceType
            $inputMethod = "Properties bound by name"
        }
        
        Write-Host "[PROCESSING #$processedCount] Resource: $resourceName" -ForegroundColor Yellow
        Write-Verbose "Input method: $inputMethod"
        Write-Verbose "Resource Group: $resourceGroup"
        Write-Verbose "Resource Type: $resourceType"
        Write-Verbose "Owner: $OwnerEmail"
        
        # Simulate ownership tag assignment
        $ownershipTags = @{
            Owner = $OwnerEmail
            Department = $Department
            CostCenter = $CostCenter
            AssignedDate = (Get-Date).ToString("yyyy-MM-dd")
            AssignedBy = "PowerShell Workshop"
        }
        
        # Return processed resource info
        [PSCustomObject]@{
            ResourceName = $resourceName
            ResourceGroup = $resourceGroup
            ResourceType = $resourceType
            InputMethod = $inputMethod
            OwnerEmail = $OwnerEmail
            Department = $Department
            CostCenter = $CostCenter
            TagsAssigned = $ownershipTags.Count
            ProcessedAt = Get-Date
        }
    }
    
    end {
        Write-Host "[PIPELINE COMPLETE] Processed $processedCount resources" -ForegroundColor Green
    }
}

# Function demonstrating complex pipeline property binding
function New-AzureResourceReport {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ResourceName", "Name")]
        [string]$ResourceDisplayName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("RG", "ResourceGroup")]
        [string]$ResourceGroupName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Location,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Type")]
        [string]$ResourceType,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Tags")]
        [hashtable]$ResourceTags = @{},
        
        [string]$ReportTemplate = "Standard"
    )
    
    begin {
        Write-Host "[REPORT PIPELINE] Starting resource report generation" -ForegroundColor Yellow
        $reportData = @()
    }
    
    process {
        Write-Verbose "Processing resource: $ResourceDisplayName"
        
        # Generate report entry
        $reportEntry = [PSCustomObject]@{
            ResourceName = $ResourceDisplayName
            ResourceGroup = $ResourceGroupName
            Location = $Location
            Type = $ResourceType
            TagCount = $ResourceTags.Count
            HasOwnerTag = $ResourceTags.ContainsKey("Owner")
            HasEnvironmentTag = $ResourceTags.ContainsKey("Environment")
            ComplianceScore = if ($ResourceTags.Count -ge 3) { "High" } elseif ($ResourceTags.Count -ge 1) { "Medium" } else { "Low" }
            ReportTemplate = $ReportTemplate
            GeneratedAt = Get-Date
        }
        
        $reportData += $reportEntry
        Write-Host "[REPORT ENTRY] Added: $ResourceDisplayName ($($reportEntry.ComplianceScore) compliance)" -ForegroundColor Gray
    }
    
    end {
        Write-Host "[REPORT COMPLETE] Generated report for $($reportData.Count) resources" -ForegroundColor Green
        return $reportData
    }
}

# Demonstrate pipeline input
Write-Host "[DEMO] Testing pipeline input methods:" -ForegroundColor Yellow

# Example 1: Direct pipeline input
Write-Host "[DEMO 1] Direct pipeline input (ValueFromPipeline)" -ForegroundColor Cyan
$resources = Get-AzResource | Select-Object -First 3
if ($resources) {
    $ownershipResults1 = $resources | Set-AzureResourceOwnership -OwnerEmail "admin@company.com" -Department "Cloud Operations" -Verbose
    Write-Host "[RESULT] Processed $($ownershipResults1.Count) resources via direct pipeline" -ForegroundColor Yellow
}

# Example 2: Pipeline by property name with custom objects
Write-Host "[DEMO 2] Pipeline by property name (ValueFromPipelineByPropertyName)" -ForegroundColor Cyan
$customResources = @(
    [PSCustomObject]@{Name="WebApp-001"; ResourceGroupName="Web-RG"; ResourceType="Microsoft.Web/sites"}
    [PSCustomObject]@{Name="SQL-001"; ResourceGroupName="Data-RG"; ResourceType="Microsoft.Sql/servers"}
    [PSCustomObject]@{Name="Storage-001"; ResourceGroupName="Storage-RG"; ResourceType="Microsoft.Storage/storageAccounts"}
)

$ownershipResults2 = $customResources | Set-AzureResourceOwnership -OwnerEmail "dev@company.com" -Department "Development"
Write-Host "[RESULT] Processed $($ownershipResults2.Count) resources via property name binding" -ForegroundColor Yellow

# Example 3: Complex property binding with aliases
Write-Host "[DEMO 3] Complex property binding with aliases" -ForegroundColor Cyan
$csvStyleData = @(
    [PSCustomObject]@{ResourceDisplayName="VM-Web-01"; RG="Production-RG"; Location="eastus"; Type="VirtualMachine"; Tags=@{Environment="Prod"; Owner="WebTeam"}}
    [PSCustomObject]@{ResourceDisplayName="DB-Main-01"; RG="Database-RG"; Location="westus"; Type="SqlDatabase"; Tags=@{Environment="Prod"; CriticalData="Yes"}}
)

$reportResults = $csvStyleData | New-AzureResourceReport -ReportTemplate "Compliance" -Verbose
Write-Host "[RESULT] Generated compliance report for $($reportResults.Count) resources" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Aliases..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: ALIAS ATTRIBUTE - Function and parameter aliases
# ============================================================================
# EXPLANATION: Aliases provide alternative names for functions and parameters
# - Function aliases allow shorter or alternative names for commands
# - Parameter aliases support different naming conventions (e.g., CSV columns)
Write-Host "[CONCEPT 5] Alias Attribute" -ForegroundColor White
Write-Host "Function aliases and parameter aliases for flexible input" -ForegroundColor Gray

# Function with multiple aliases
function Get-AzureResourceCostAnalysis {
    [CmdletBinding()]
    [Alias("Get-AzCostAnalysis", "Get-CostReport", "azcostreport")]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("RG", "ResourceGroup", "Group")]
        [string]$ResourceGroupName,
        
        [Parameter()]
        [Alias("Days", "Period", "TimeSpan")]
        [int]$DaysBack = 30,
        
        [Parameter()]
        [Alias("Currency", "CurrencyCode")]
        [ValidateSet("USD", "EUR", "GBP")]
        [string]$CurrencyType = "USD",
        
        [Parameter()]
        [Alias("Detailed", "Detail", "FullReport")]
        [switch]$IncludeDetails,
        
        [Parameter()]
        [Alias("Export", "SaveTo", "OutputPath")]
        [string]$ExportPath
    )
    
    Write-Host "[ALIAS DEMO] Function called with aliases:" -ForegroundColor Yellow
    Write-Host "  Available function aliases: Get-AzCostAnalysis, Get-CostReport, azcostreport" -ForegroundColor Gray
    Write-Host "  ResourceGroupName (aliases: RG, ResourceGroup, Group): $ResourceGroupName" -ForegroundColor Gray
    Write-Host "  DaysBack (aliases: Days, Period, TimeSpan): $DaysBack" -ForegroundColor Gray
    Write-Host "  CurrencyType (aliases: Currency, CurrencyCode): $CurrencyType" -ForegroundColor Gray
    Write-Host "  IncludeDetails (aliases: Detailed, Detail, FullReport): $($IncludeDetails.IsPresent)" -ForegroundColor Gray
    Write-Host "  ExportPath (aliases: Export, SaveTo, OutputPath): $ExportPath" -ForegroundColor Gray
    
    # Simulate cost analysis
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-$DaysBack)
    
    # Get resources for cost simulation
    $resources = Get-AzResource -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $resources) {
        Write-Warning "Resource group '$ResourceGroupName' not found or empty"
        $resources = @()
    }
    
    # Generate simulated cost data
    $costData = @()
    foreach ($resource in $resources) {
        $dailyCost = Get-Random -Minimum 0.50 -Maximum 25.00
        $totalCost = $dailyCost * $DaysBack
        
        $costEntry = [PSCustomObject]@{
            ResourceName = $resource.Name
            ResourceType = $resource.ResourceType
            Location = $resource.Location
            DailyCost = [math]::Round($dailyCost, 2)
            TotalCost = [math]::Round($totalCost, 2)
            Currency = $CurrencyType
            Period = "$DaysBack days"
            AnalysisDate = Get-Date
        }
        
        $costData += $costEntry
    }
    
    $totalCost = ($costData | Measure-Object -Property TotalCost -Sum).Sum
    
    $analysis = [PSCustomObject]@{
        ResourceGroup = $ResourceGroupName
        AnalysisPeriod = "$DaysBack days ($($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd')))"
        Currency = $CurrencyType
        TotalResources = $resources.Count
        TotalCost = [math]::Round($totalCost, 2)
        AverageDailyCost = if ($DaysBack -gt 0) { [math]::Round($totalCost / $DaysBack, 2) } else { 0 }
        IncludesDetails = $IncludeDetails.IsPresent
        DetailedCosts = if ($IncludeDetails) { $costData } else { @() }
        ExportRequested = -not [string]::IsNullOrEmpty($ExportPath)
        GeneratedAt = Get-Date
    }
    
    Write-Host "[COST ANALYSIS] $($analysis.ResourceGroup): $($analysis.TotalCost) $CurrencyType over $DaysBack days" -ForegroundColor Yellow
    
    # Handle export if requested
    if ($ExportPath) {
        Write-Host "[EXPORT] Would export to: $ExportPath" -ForegroundColor Gray
    }
    
    return $analysis
}

# Function with CSV-friendly parameter aliases
function Import-AzureResourcesFromCSV {
    [CmdletBinding()]
    [Alias("Import-AzResources", "azimport")]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ResourceName", "Name", "VM_Name", "ServerName")]
        [string]$DisplayName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ResourceGroup", "RG", "Resource_Group", "GroupName")]
        [string]$TargetResourceGroup,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Region", "DataCenter", "AzureRegion", "DC")]
        [string]$Location,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Size", "VMSize", "InstanceSize", "SKU")]
        [string]$ResourceSize,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Environment", "Env", "Stage")]
        [string]$EnvironmentType,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Owner", "ResponsiblePerson", "Contact")]
        [string]$ResourceOwner
    )
    
    begin {
        Write-Host "[CSV IMPORT DEMO] Processing CSV-style data with flexible aliases" -ForegroundColor Yellow
        $importedResources = @()
    }
    
    process {
        Write-Host "[IMPORTING] Resource: $DisplayName" -ForegroundColor Gray
        Write-Verbose "Target Group: $TargetResourceGroup"
        Write-Verbose "Location: $Location"
        Write-Verbose "Size: $ResourceSize"
        Write-Verbose "Environment: $EnvironmentType"
        Write-Verbose "Owner: $ResourceOwner"
        
        $importEntry = [PSCustomObject]@{
            ResourceName = $DisplayName
            ResourceGroup = $TargetResourceGroup
            Location = $Location
            Size = $ResourceSize
            Environment = $EnvironmentType
            Owner = $ResourceOwner
            ImportStatus = "Validated"
            ImportedAt = Get-Date
        }
        
        $importedResources += $importEntry
    }
    
    end {
        Write-Host "[CSV IMPORT COMPLETE] Processed $($importedResources.Count) resources" -ForegroundColor Green
        return $importedResources
    }
}

# Demonstrate aliases
Write-Host "[DEMO] Testing function and parameter aliases:" -ForegroundColor Yellow

# Example 1: Function alias usage
Write-Host "[DEMO 1] Using function aliases" -ForegroundColor Cyan
if ($sampleRG) {
    # Call using original name
    $costAnalysis1 = Get-AzureResourceCostAnalysis -ResourceGroupName $sampleRG.ResourceGroupName -Days 7 -Currency "USD"
    
    # Call using short alias
    $costAnalysis2 = azcostreport -RG $sampleRG.ResourceGroupName -Period 14 -Detailed
    
    Write-Host "[RESULT] Both calls work: Original=$($costAnalysis1.TotalCost) USD, Alias=$($costAnalysis2.TotalCost) USD" -ForegroundColor Yellow
}

# Example 2: CSV-style data with various column naming conventions
Write-Host "[DEMO 2] CSV-style data with flexible parameter aliases" -ForegroundColor Cyan
$csvData = @(
    [PSCustomObject]@{VM_Name="WebServer01"; Resource_Group="Web-Prod"; DataCenter="eastus"; InstanceSize="Standard_B2s"; Stage="Production"; ResponsiblePerson="webadmin@company.com"}
    [PSCustomObject]@{ServerName="DBServer01"; GroupName="Database-Prod"; AzureRegion="westus"; SKU="Standard_D4s_v3"; Env="Prod"; Contact="dbadmin@company.com"}
    [PSCustomObject]@{Name="AppServer01"; RG="App-Test"; Region="centralus"; Size="Standard_B1s"; Environment="Test"; Owner="testteam@company.com"}
)

$importResults = $csvData | Import-AzureResourcesFromCSV -Verbose
Write-Host "[RESULT] Successfully imported $($importResults.Count) resources with various CSV column formats" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to ValueFromRemainingArguments..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: VALUEFROMREMAININGARGUMENTS - Overflow parameter handling
# ============================================================================
# EXPLANATION: ValueFromRemainingArguments captures extra parameters into an array
# - Useful for flexible functions that accept variable numbers of arguments
# - Commonly used for tag operations or configuration settings
Write-Host "[CONCEPT 6] ValueFromRemainingArguments" -ForegroundColor White
Write-Host "Capturing overflow arguments for flexible parameter handling" -ForegroundColor Gray

# Function demonstrating ValueFromRemainingArguments
function Set-AzureResourceTags {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ResourceId,
        
        [Parameter(Position = 1)]
        [ValidateSet("Replace", "Merge", "Remove")]
        [string]$TagOperation = "Merge",
        
        # Capture any additional arguments as tag key-value pairs
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$TagArguments
    )
    
    Write-Host "[OVERFLOW DEMO] Processing resource tags with flexible arguments" -ForegroundColor Yellow
    Write-Host "  ResourceId: $ResourceId" -ForegroundColor Gray
    Write-Host "  TagOperation: $TagOperation" -ForegroundColor Gray
    Write-Host "  Overflow Arguments Count: $($TagArguments.Count)" -ForegroundColor Gray
    
    # Process overflow arguments as key-value pairs
    $tags = @{}
    if ($TagArguments.Count -gt 0) {
        Write-Host "  Processing overflow arguments:" -ForegroundColor Gray
        
        for ($i = 0; $i -lt $TagArguments.Count; $i += 2) {
            if ($i + 1 -lt $TagArguments.Count) {
                $key = $TagArguments[$i]
                $value = $TagArguments[$i + 1]
                $tags[$key] = $value
                Write-Host "    Tag: $key = $value" -ForegroundColor Gray
            } else {
                Write-Warning "Unpaired tag argument: $($TagArguments[$i])"
            }
        }
    }
    
    # Simulate tag operation
    $result = [PSCustomObject]@{
        ResourceId = $ResourceId
        Operation = $TagOperation
        TagsProcessed = $tags.Count
        Tags = $tags
        OverflowArgs = $TagArguments
        ProcessedAt = Get-Date
    }
    
    Write-Host "[TAGS PROCESSED] Applied $($tags.Count) tags using $TagOperation operation" -ForegroundColor Green
    return $result
}

# Function with multiple overflow scenarios
function New-AzureDeploymentScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [string]$Location = "eastus",
        
        # Capture environment variables
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$EnvironmentVariables
    )
    
    Write-Host "[SCRIPT DEMO] Creating deployment script with environment variables" -ForegroundColor Yellow
    Write-Host "  Script: $ScriptName" -ForegroundColor Gray
    Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor Gray
    Write-Host "  Location: $Location" -ForegroundColor Gray
    
    # Process environment variables from remaining arguments
    $envVars = @{}
    if ($EnvironmentVariables.Count -gt 0) {
        Write-Host "  Environment Variables:" -ForegroundColor Gray
        
        foreach ($envVar in $EnvironmentVariables) {
            if ($envVar -contains "=") {
                $parts = $envVar -split "=", 2
                $envVars[$parts[0]] = $parts[1]
                Write-Host "    $($parts[0]) = $($parts[1])" -ForegroundColor Gray
            } else {
                Write-Host "    $envVar (flag/boolean)" -ForegroundColor Gray
                $envVars[$envVar] = $true
            }
        }
    }
    
    # Generate deployment script configuration
    $scriptConfig = [PSCustomObject]@{
        ScriptName = $ScriptName
        ResourceGroup = $ResourceGroupName
        Location = $Location
        EnvironmentVariables = $envVars
        RemainingArguments = $EnvironmentVariables
        CreatedAt = Get-Date
    }
    
    Write-Host "[SCRIPT CONFIGURED] Deployment script ready with $($envVars.Count) environment variables" -ForegroundColor Green
    return $scriptConfig
}

# Demonstrate ValueFromRemainingArguments
Write-Host "[DEMO] Testing ValueFromRemainingArguments:" -ForegroundColor Yellow

# Example 1: Tag assignment with overflow arguments
Write-Host "[DEMO 1] Tag assignment with key-value pairs as overflow arguments" -ForegroundColor Cyan
$sampleResourceId = "/subscriptions/12345/resourceGroups/demo/providers/Microsoft.Storage/storageAccounts/demo"
$tagResult1 = Set-AzureResourceTags $sampleResourceId "Merge" "Environment" "Production" "Owner" "DevOps Team" "CostCenter" "CC-001" "Criticality" "High"

# Example 2: Different tag operation
Write-Host "[DEMO 2] Replace operation with different tags" -ForegroundColor Cyan
$tagResult2 = Set-AzureResourceTags $sampleResourceId "Replace" "Project" "WebApp" "Phase" "Testing" "Backup" "Daily"

# Example 3: Deployment script with environment variables
Write-Host "[DEMO 3] Deployment script with environment variables" -ForegroundColor Cyan
$scriptResult = New-AzureDeploymentScript -ScriptName "WebApp-Deploy" -ResourceGroupName "WebApp-RG" -Location "westus" "DATABASE_URL=server.database.windows.net" "API_KEY=secret123" "DEBUG_MODE=true" "ENVIRONMENT=staging"

Write-Host "[RESULT] Tag operation 1: $($tagResult1.TagsProcessed) tags, Operation 2: $($tagResult2.TagsProcessed) tags" -ForegroundColor Yellow
Write-Host "[RESULT] Script configured with $($scriptResult.EnvironmentVariables.Count) environment variables" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Parameter Validation..." -ForegroundColor Magenta
$pause6 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 7: PARAMETER VALIDATION ATTRIBUTES - Input validation and constraints
# ============================================================================
# EXPLANATION: Validation attributes ensure parameter values meet specific criteria
# - ValidateSet, ValidateRange, ValidatePattern provide built-in validation
# - ValidateScript allows custom validation logic with detailed error messages
Write-Host "[CONCEPT 7] Parameter Validation Attributes" -ForegroundColor White
Write-Host "ValidateSet, ValidateRange, ValidatePattern, ValidateScript, and null handling" -ForegroundColor Gray

# Function demonstrating comprehensive parameter validation
function New-AzureVirtualMachine {
    [CmdletBinding()]
    param(
        # ValidatePattern for naming convention
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-zA-Z][a-zA-Z0-9-]{1,14}$', ErrorMessage = "VM name must start with letter, 2-15 chars, letters/numbers/hyphens only")]
        [string]$VMName,
        
        # ValidateSet for allowed VM sizes
        [Parameter(Mandatory = $true)]
        [ValidateSet("Standard_B1s", "Standard_B2s", "Standard_B4ms", "Standard_D2s_v3", "Standard_D4s_v3", "Standard_E2s_v3")]
        [string]$VMSize,
        
        # ValidateRange for port numbers
        [Parameter()]
        [ValidateRange(1, 65535)]
        [int[]]$OpenPorts = @(80, 443),
        
        # ValidateCount for disk configuration
        [Parameter()]
        [ValidateCount(1, 16)]
        [string[]]$DataDisks = @(),
        
        # ValidateLength for description
        [Parameter()]
        [ValidateLength(0, 256)]
        [string]$Description = "",
        
        # ValidateScript for complex business logic
        [Parameter()]
        [ValidateScript({
            if ($_ -match '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$') {
                $true
            } else {
                throw "Password must be 12+ characters with uppercase, lowercase, number, and special character"
            }
        })]
        [string]$AdminPassword,
        
        # Null and empty validation examples
        [Parameter()]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string]$Environment = "",
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName = "Default-VM-RG",
        
        [Parameter()]
        [AllowNull()]
        [hashtable]$Tags = $null,
        
        [Parameter()]
        [AllowEmptyCollection()]
        [string[]]$SecurityGroups = @()
    )
    
    Write-Host "[VALIDATION DEMO] Creating VM with comprehensive parameter validation" -ForegroundColor Yellow
    Write-Host "  VM Name: $VMName (Pattern: letter start, 2-15 chars, alphanumeric+hyphens)" -ForegroundColor Gray
    Write-Host "  VM Size: $VMSize (ValidateSet: predefined sizes only)" -ForegroundColor Gray
    Write-Host "  Open Ports: $($OpenPorts -join ', ') (ValidateRange: 1-65535)" -ForegroundColor Gray
    Write-Host "  Data Disks: $($DataDisks.Count) disks (ValidateCount: 1-16)" -ForegroundColor Gray
    Write-Host "  Description: '$Description' (ValidateLength: 0-256 chars)" -ForegroundColor Gray
    Write-Host "  Password Provided: $(-not [string]::IsNullOrEmpty($AdminPassword)) (ValidateScript: complexity rules)" -ForegroundColor Gray
    Write-Host "  Environment: '$Environment' (ValidateNotNull + AllowEmptyString)" -ForegroundColor Gray
    Write-Host "  Resource Group: $ResourceGroupName (ValidateNotNullOrEmpty)" -ForegroundColor Gray
    Write-Host "  Tags: $(if ($Tags) { "$($Tags.Count) tags" } else { "null allowed" }) (AllowNull)" -ForegroundColor Gray
    Write-Host "  Security Groups: $($SecurityGroups.Count) groups (AllowEmptyCollection)" -ForegroundColor Gray
    
    # Simulate VM creation
    $vmConfig = [PSCustomObject]@{
        VMName = $VMName
        Size = $VMSize
        OpenPorts = $OpenPorts
        DataDiskCount = $DataDisks.Count
        Description = $Description
        HasPassword = -not [string]::IsNullOrEmpty($AdminPassword)
        Environment = $Environment
        ResourceGroup = $ResourceGroupName
        TagCount = if ($Tags) { $Tags.Count } else { 0 }
        SecurityGroupCount = $SecurityGroups.Count
        ValidationPassed = $true
        CreatedAt = Get-Date
    }
    
    Write-Host "[VM VALIDATED] All parameters passed validation checks" -ForegroundColor Green
    return $vmConfig
}

# Function demonstrating validation error scenarios
function Test-AzureValidationScenarios {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet("Test1", "Test2", "Test3")]
        [string]$TestScenario = "Test1"
    )
    
    Write-Host "[VALIDATION TESTING] Demonstrating validation scenarios" -ForegroundColor Yellow
    
    # Test 1: Valid VM creation
    if ($TestScenario -eq "Test1" -or $TestScenario -eq "All") {
        Write-Host "[TEST 1] Valid VM creation" -ForegroundColor Cyan
        try {
            $vm1 = New-AzureVirtualMachine -VMName "WebServer01" -VMSize "Standard_B2s" -OpenPorts @(80, 443, 3389) -Description "Production web server" -Environment "Production" -ResourceGroupName "Web-Prod-RG" -Tags @{Owner="WebTeam"}
            Write-Host "[SUCCESS] VM validation passed" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Test 2: Demonstrate validation failures (commented to prevent actual errors)
    if ($TestScenario -eq "Test2" -or $TestScenario -eq "All") {
        Write-Host "[TEST 2] Validation failure examples (simulated)" -ForegroundColor Cyan
        Write-Host "[DEMO] These would fail validation:" -ForegroundColor Gray
        Write-Host "  VMName '1InvalidName' - Pattern validation (must start with letter)" -ForegroundColor Red
        Write-Host "  VMSize 'Invalid_Size' - ValidateSet (not in allowed list)" -ForegroundColor Red
        Write-Host "  OpenPorts 99999 - ValidateRange (exceeds 65535)" -ForegroundColor Red
        Write-Host "  DataDisks with 20 items - ValidateCount (exceeds 16)" -ForegroundColor Red
        Write-Host "  Description with 300 chars - ValidateLength (exceeds 256)" -ForegroundColor Red
        Write-Host "  AdminPassword 'weak' - ValidateScript (complexity requirements)" -ForegroundColor Red
    }
    
    # Test 3: Edge cases and null handling
    if ($TestScenario -eq "Test3" -or $TestScenario -eq "All") {
        Write-Host "[TEST 3] Null and empty value handling" -ForegroundColor Cyan
        try {
            $vm3 = New-AzureVirtualMachine -VMName "TestVM" -VMSize "Standard_B1s" -Environment "" -Tags $null -SecurityGroups @()
            Write-Host "[SUCCESS] Null and empty values handled correctly" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Demonstrate parameter validation
Write-Host "[DEMO] Testing parameter validation attributes:" -ForegroundColor Yellow

# Run validation tests
Test-AzureValidationScenarios -TestScenario "Test1"
Test-AzureValidationScenarios -TestScenario "Test2"
Test-AzureValidationScenarios -TestScenario "Test3"

# Advanced validation example with custom script
Write-Host "[DEMO] Advanced ValidateScript example:" -ForegroundColor Cyan
function Test-CustomValidation {
    param(
        [ValidateScript({
            $resourceGroup = Get-AzResourceGroup -Name $_ -ErrorAction SilentlyContinue
            if ($resourceGroup) {
                $true
            } else {
                throw "Resource Group '$_' does not exist in the current subscription"
            }
        })]
        [string]$ExistingResourceGroup
    )
    
    Write-Host "[CUSTOM VALIDATION] Resource Group '$ExistingResourceGroup' exists and is accessible" -ForegroundColor Green
    return $ExistingResourceGroup
}

# Test with existing resource group
if ($sampleRG) {
    Write-Host "[DEMO] Testing custom validation with existing resource group" -ForegroundColor Cyan
    try {
        $validRG = Test-CustomValidation -ExistingResourceGroup $sampleRG.ResourceGroupName
        Write-Host "[SUCCESS] Custom validation passed for: $validRG" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause7 = Read-Host

# ============================================================================
# WORKSHOP SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[WORKSHOP COMPLETE] PowerShell Parameter Mastery - Azure Parameter Management" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[PARAMETER MASTERY CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Parameter Attributes: Mandatory, Position, HelpMessage, ValueFromPipeline" -ForegroundColor Gray
Write-Host "2. Positional Parameters: Position control and PositionalBinding management" -ForegroundColor Gray
Write-Host "3. Parameter Sets: Multiple calling patterns with ParameterSetName and defaults" -ForegroundColor Gray
Write-Host "4. Pipeline Input: ValueFromPipeline and ValueFromPipelineByPropertyName" -ForegroundColor Gray
Write-Host "5. Alias Attribute: Function aliases and parameter aliases for flexibility" -ForegroundColor Gray
Write-Host "6. ValueFromRemainingArguments: Overflow parameter capture for flexible input" -ForegroundColor Gray
Write-Host "7. Parameter Validation: ValidateSet, ValidateRange, ValidatePattern, ValidateScript" -ForegroundColor Gray

Write-Host "`n[AZURE SCENARIOS COVERED]" -ForegroundColor White
Write-Host "Resource deployment, storage analysis, network configuration" -ForegroundColor Gray
Write-Host "Cost analysis, resource ownership, CSV import/export" -ForegroundColor Gray
Write-Host "VM creation with validation, tag management, deployment scripts" -ForegroundColor Gray

Write-Host "`n[VALIDATION FEATURES DEMONSTRATED]" -ForegroundColor White
Write-Host "Pattern validation, set validation, range validation, custom scripts" -ForegroundColor Gray
Write-Host "Null handling, empty value control, collection validation" -ForegroundColor Gray
Write-Host "Business logic validation, existence checking, error messaging" -ForegroundColor Gray

Write-Host "`n[PIPELINE PROCESSING DEMONSTRATED]" -ForegroundColor White
Write-Host "Direct object processing, property name binding, CSV-style input" -ForegroundColor Gray
Write-Host "Alias support for varied column names, begin/process/end blocks" -ForegroundColor Gray
Write-Host "Mixed parameter sources, flexible data import scenarios" -ForegroundColor Gray

Write-Host "`n[LIVE FUNCTIONS AVAILABLE]" -ForegroundColor White
Write-Host "Try: Get-Help New-AzureVirtualMachine -Full" -ForegroundColor Gray
Write-Host "Try: azcostreport -RG 'YourResourceGroup' -Days 30" -ForegroundColor Gray
Write-Host "Try: Set-AzureResourceTags '/resource/path' 'Merge' 'Environment' 'Test'" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These parameter concepts enable you to:" -ForegroundColor Gray
Write-Host "- Create professional, user-friendly PowerShell functions" -ForegroundColor Gray
Write-Host "- Handle diverse input scenarios and data sources" -ForegroundColor Gray
Write-Host "- Implement robust validation and error handling" -ForegroundColor Gray
Write-Host "- Build flexible automation tools for Azure management" -ForegroundColor Gray

Write-Host "`nSubscription: $($subscription.Name)" -ForegroundColor Gray
Write-Host "Workshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray