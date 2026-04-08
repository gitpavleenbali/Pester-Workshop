# ==============================================================================================
# 04. PowerShell Classes: Object-Oriented Programming Training
# Purpose: Demonstrate PowerShell class concepts using Azure resource management scenarios
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\04_powershell_classes\Azure-Classes-Training.ps1
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
Write-Host "[INFO] Starting PowerShell Classes Workshop..." -ForegroundColor Cyan
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
# CONCEPT 1: CLASS BASICS - Properties, methods, and instance creation
# ============================================================================
# EXPLANATION: PowerShell classes provide strongly-typed, reusable templates
# - Properties store state with explicit typing for better IntelliSense and validation
# - Methods contain business logic and can return typed values
# - Classes make objects self-describing and improve code maintainability
Write-Host "[CONCEPT 1] Class Basics" -ForegroundColor White
Write-Host "Properties, methods, and instance creation with Azure resource modeling" -ForegroundColor Gray

# Basic Azure resource class
class AzureResource {
    # Strongly-typed properties for better validation and IntelliSense
    [string] $Name
    [string] $ResourceGroupName
    [string] $Location
    [string] $ResourceType
    [hashtable] $Tags
    [datetime] $CreatedDate
    
    # Basic method - note: no param() block in class methods
    [string] GetResourceId() {
        return "/subscriptions/{subscription-id}/resourceGroups/$($this.ResourceGroupName)/providers/$($this.ResourceType)/$($this.Name)"
    }
    
    # Method that returns information about the resource
    [string] GetSummary() {
        return "Azure Resource: $($this.Name) ($($this.ResourceType)) in $($this.Location)"
    }
}

Write-Host "[CLASS DEMO] Creating AzureResource instances:" -ForegroundColor Yellow

# Instance creation using [ClassName]::new() - preferred method
$webApp = [AzureResource]::new()
$webApp.Name = "WebApp-Prod-001"
$webApp.ResourceGroupName = "WebApp-Production"
$webApp.Location = "eastus"
$webApp.ResourceType = "Microsoft.Web/sites"
$webApp.Tags = @{Environment="Production"; Team="WebDev"}
$webApp.CreatedDate = Get-Date

Write-Host "[INSTANCE] Created web app: $($webApp.GetSummary())" -ForegroundColor Yellow
Write-Host "[RESOURCE ID] $($webApp.GetResourceId())" -ForegroundColor Gray

# Create another instance for a storage account
$storage = [AzureResource]::new()
$storage.Name = "storageacct001"
$storage.ResourceGroupName = "Storage-Production"
$storage.Location = "westus"
$storage.ResourceType = "Microsoft.Storage/storageAccounts"
$storage.Tags = @{Environment="Production"; Purpose="DataLake"}
$storage.CreatedDate = (Get-Date).AddDays(-30)

Write-Host "[INSTANCE] Created storage: $($storage.GetSummary())" -ForegroundColor Yellow

# Show class type information
Write-Host "[TYPE INFO] Class provides type identity:" -ForegroundColor Cyan
Write-Host "  Type Name: $($webApp.GetType().Name)" -ForegroundColor Gray
Write-Host "  Full Name: $($webApp.GetType().FullName)" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Methods with Parameters..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: METHODS WITH PARAMETERS & OVERLOADS - Multiple method signatures
# ============================================================================
# EXPLANATION: Method overloads allow the same method name with different parameter lists
# - Use $this to call other overloads to avoid code duplication
# - Parameters are strongly typed and go directly in the method signature
Write-Host "[CONCEPT 2] Methods with Parameters & Overloads" -ForegroundColor White
Write-Host "Multiple method signatures and parameter handling" -ForegroundColor Gray

# Enhanced Azure resource class with method overloads
class AzureVirtualMachine {
    [string] $VMName
    [string] $ResourceGroup
    [string] $Location
    [string] $VMSize
    [string] $OSType
    [string] $Status
    [hashtable] $Tags
    
    # Method overload 1: No parameters - get basic status
    [string] GetStatus() {
        return $this.GetStatus("basic")
    }
    
    # Method overload 2: With detail level parameter
    [string] GetStatus([string] $DetailLevel) {
        $currentStatus = $this.Status
        if ($DetailLevel.ToLower() -eq "basic") {
            return "VM '$($this.VMName)' is $currentStatus"
        }
        elseif ($DetailLevel.ToLower() -eq "detailed") {
            return "VM '$($this.VMName)' ($($this.VMSize)) in $($this.Location) is $currentStatus"
        }
        elseif ($DetailLevel.ToLower() -eq "full") {
            return "VM '$($this.VMName)' ($($this.VMSize)) in $($this.ResourceGroup)/$($this.Location) is $currentStatus - OS: $($this.OSType)"
        }
        else {
            return "VM '$($this.VMName)' is $currentStatus"  # Default to basic
        }
    }
    
    # Method overload 3: With multiple parameters
    [string] GetStatus([string] $DetailLevel, [bool] $IncludeTags) {
        $statusText = $this.GetStatus($DetailLevel)  # Reuse existing overload
        
        if ($IncludeTags -and $this.Tags.Count -gt 0) {
            $tagInfo = ($this.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ", "
            $statusText += " [Tags: $tagInfo]"
        }
        
        return $statusText
    }
    
    # Method with different return type
    [hashtable] GetConfiguration() {
        return @{
            Name = $this.VMName
            ResourceGroup = $this.ResourceGroup
            Location = $this.Location
            Size = $this.VMSize
            OS = $this.OSType
            Status = $this.Status
            TagCount = $this.Tags.Count
        }
    }
}

Write-Host "[OVERLOAD DEMO] Creating VM instance and testing method overloads:" -ForegroundColor Yellow

$vm = [AzureVirtualMachine]::new()
$vm.VMName = "WebServer-VM-01"
$vm.ResourceGroup = "WebTier-Production"
$vm.Location = "eastus"
$vm.VMSize = "Standard_D2s_v3"
$vm.OSType = "Windows Server 2022"
$vm.Status = "Running"
$vm.Tags = @{Environment="Production"; Role="WebServer"; Owner="DevOps"}

# Demonstrate method overloads
Write-Host "[OVERLOAD 1] Basic status: $($vm.GetStatus())" -ForegroundColor Yellow
Write-Host "[OVERLOAD 2] Detailed status: $($vm.GetStatus('detailed'))" -ForegroundColor Yellow
Write-Host "[OVERLOAD 3] Full with tags: $($vm.GetStatus('full', $true))" -ForegroundColor Yellow

# Show overload information using Get-Member
Write-Host "[METHOD INFO] Available GetStatus overloads:" -ForegroundColor Cyan
$vm | Get-Member -Name GetStatus | ForEach-Object {
    Write-Host "  $($_.Definition)" -ForegroundColor Gray
}

Write-Host "`n[PAUSE] Press Enter to continue to Stateful Methods..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: STATEFUL METHODS ($this) - Modifying object state
# ============================================================================
# EXPLANATION: Use $this to access and modify properties within methods
# - $this refers to the current instance of the class
# - Methods can change object state and perform side effects
Write-Host "[CONCEPT 3] Stateful Methods" -ForegroundColor White
Write-Host "Using `$this to access and modify object state" -ForegroundColor Gray

# Azure resource with state management
class AzureStorageAccount {
    [string] $AccountName
    [string] $ResourceGroup
    [string] $Location
    [string] $SkuName
    [string] $Status
    [int] $UsedCapacityGB
    [int] $TotalCapacityGB
    [hashtable] $AccessPolicies
    [datetime] $LastUpdated
    
    # Constructor to initialize default values
    AzureStorageAccount() {
        $this.Status = "Created"
        $this.UsedCapacityGB = 0
        $this.TotalCapacityGB = 5120  # Default 5TB
        $this.AccessPolicies = @{}
        $this.LastUpdated = Get-Date
    }
    
    # Stateful method - changes object properties using $this
    [void] UpdateUsage([int] $NewUsedGB) {
        $this.UsedCapacityGB = $NewUsedGB
        $this.LastUpdated = Get-Date
        
        # Update status based on usage
        $usagePercent = ($this.UsedCapacityGB / $this.TotalCapacityGB) * 100
        if ($usagePercent -gt 90) {
            $this.Status = "Critical - Near Capacity"
        } elseif ($usagePercent -gt 70) {
            $this.Status = "Warning - High Usage"
        } else {
            $this.Status = "Healthy"
        }
    }
    
    # Method that modifies collections
    [void] AddAccessPolicy([string] $PolicyName, [string] $Permissions) {
        $this.AccessPolicies[$PolicyName] = $Permissions
        $this.LastUpdated = Get-Date
    }
    
    # Method that removes from collections
    [bool] RemoveAccessPolicy([string] $PolicyName) {
        if ($this.AccessPolicies.ContainsKey($PolicyName)) {
            $this.AccessPolicies.Remove($PolicyName)
            $this.LastUpdated = Get-Date
            return $true
        }
        return $false
    }
    
    # Method that scales capacity
    [void] ScaleUp([int] $AdditionalGB) {
        $this.TotalCapacityGB += $AdditionalGB
        $this.LastUpdated = Get-Date
        
        # Recalculate status after scaling
        $this.UpdateUsage($this.UsedCapacityGB)
    }
    
    # Method that returns calculated values
    [double] GetUsagePercentage() {
        if ($this.TotalCapacityGB -eq 0) { return 0 }
        return [math]::Round(($this.UsedCapacityGB / $this.TotalCapacityGB) * 100, 2)
    }
    
    # Method that returns formatted status
    [string] GetStatusReport() {
        return "Storage Account '$($this.AccountName)': $($this.GetUsagePercentage())% used ($($this.UsedCapacityGB)GB / $($this.TotalCapacityGB)GB) - Status: $($this.Status)"
    }
}

Write-Host "[STATEFUL DEMO] Creating storage account and modifying state:" -ForegroundColor Yellow

$storageAcct = [AzureStorageAccount]::new()
$storageAcct.AccountName = "prodstorageacct001"
$storageAcct.ResourceGroup = "Storage-Production"
$storageAcct.Location = "westus"
$storageAcct.SkuName = "Standard_LRS"

# Show initial state
Write-Host "[INITIAL STATE] $($storageAcct.GetStatusReport())" -ForegroundColor Yellow

# Modify state through methods
Write-Host "[STATE CHANGE] Adding usage and access policies..." -ForegroundColor Cyan
$storageAcct.UpdateUsage(1024)  # 1TB used
$storageAcct.AddAccessPolicy("WebAppAccess", "rwdl")
$storageAcct.AddAccessPolicy("BackupAccess", "r")

Write-Host "[AFTER UPDATES] $($storageAcct.GetStatusReport())" -ForegroundColor Yellow
Write-Host "[ACCESS POLICIES] $($storageAcct.AccessPolicies.Count) policies configured" -ForegroundColor Gray

# Scale up and test status changes
Write-Host "[SCALING] Increasing usage to test status changes..." -ForegroundColor Cyan
$storageAcct.UpdateUsage(3584)  # 70% usage
Write-Host "[70% USAGE] $($storageAcct.GetStatusReport())" -ForegroundColor Yellow

$storageAcct.UpdateUsage(4608)  # 90% usage
Write-Host "[90% USAGE] $($storageAcct.GetStatusReport())" -ForegroundColor Yellow

# Scale up capacity
$storageAcct.ScaleUp(5120)  # Double capacity
Write-Host "[AFTER SCALING] $($storageAcct.GetStatusReport())" -ForegroundColor Yellow

Write-Host "`n[PAUSE] Press Enter to continue to Constructors..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: CONSTRUCTORS (default & overloads) - Object initialization
# ============================================================================
# EXPLANATION: Constructors are special methods named the same as the class
# - Called automatically when creating instances with ::new()
# - Support multiple overloads for different initialization scenarios
Write-Host "[CONCEPT 4] Constructors" -ForegroundColor White
Write-Host "Default and overloaded constructors for flexible object initialization" -ForegroundColor Gray

# Azure App Service class with multiple constructors
class AzureAppService {
    [string] $AppName
    [string] $ResourceGroup
    [string] $Location
    [string] $PricingTier
    [string] $Runtime
    [hashtable] $AppSettings
    [hashtable] $ConnectionStrings
    [datetime] $CreatedDate
    [string] $Status
    
    # Default constructor - sets sensible defaults
    AzureAppService() {
        $this.AppName = "default-app-$(Get-Random -Min 100 -Max 999)"
        $this.ResourceGroup = "Default-RG"
        $this.Location = "eastus"
        $this.PricingTier = "F1"  # Free tier
        $this.Runtime = "dotnet"
        $this.AppSettings = @{
            "WEBSITE_NODE_DEFAULT_VERSION" = "14.15.1"
            "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
        }
        $this.ConnectionStrings = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
    }
    
    # Constructor with basic parameters
    AzureAppService([string] $Name, [string] $ResourceGroup) {
        # Initialize defaults
        $this.AppName = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = "eastus"
        $this.PricingTier = "F1"  # Free tier
        $this.Runtime = "dotnet"
        $this.AppSettings = @{
            "WEBSITE_NODE_DEFAULT_VERSION" = "14.15.1"
            "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
        }
        $this.ConnectionStrings = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
    }
    
    # Constructor with location and pricing
    AzureAppService([string] $Name, [string] $ResourceGroup, [string] $Location, [string] $PricingTier) {
        # Initialize all properties
        $this.AppName = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = $Location
        $this.PricingTier = $PricingTier
        $this.Runtime = "dotnet"
        $this.AppSettings = @{
            "WEBSITE_NODE_DEFAULT_VERSION" = "14.15.1"
            "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
        }
        $this.ConnectionStrings = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
    }
    
    # Full constructor with all parameters
    AzureAppService([string] $Name, [string] $ResourceGroup, [string] $Location, [string] $PricingTier, [string] $Runtime, [hashtable] $AppSettings) {
        $this.AppName = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = $Location
        $this.PricingTier = $PricingTier
        $this.Runtime = $Runtime
        $this.AppSettings = $AppSettings
        $this.ConnectionStrings = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
    }
    
    # Method to display configuration
    [string] GetConfiguration() {
        $config = @"
App Service Configuration:
  Name: $($this.AppName)
  Resource Group: $($this.ResourceGroup)
  Location: $($this.Location)
  Pricing Tier: $($this.PricingTier)
  Runtime: $($this.Runtime)
  App Settings: $($this.AppSettings.Count) configured
  Connection Strings: $($this.ConnectionStrings.Count) configured
  Status: $($this.Status)
  Created: $($this.CreatedDate.ToString('yyyy-MM-dd HH:mm'))
"@
        return $config
    }
    
    # Method to add app settings
    [void] AddAppSetting([string] $Key, [string] $Value) {
        $this.AppSettings[$Key] = $Value
    }
    
    # Method to add connection string
    [void] AddConnectionString([string] $Name, [string] $ConnectionString, [string] $Type) {
        $this.ConnectionStrings[$Name] = @{
            Value = $ConnectionString
            Type = $Type
        }
    }
}

Write-Host "[CONSTRUCTOR DEMO] Testing different constructor overloads:" -ForegroundColor Yellow

# Constructor 1: Default constructor
Write-Host "[CONSTRUCTOR 1] Default constructor:" -ForegroundColor Cyan
$app1 = [AzureAppService]::new()
Write-Host $app1.GetConfiguration() -ForegroundColor Gray

# Constructor 2: Name and resource group
Write-Host "[CONSTRUCTOR 2] Name and resource group constructor:" -ForegroundColor Cyan
$app2 = [AzureAppService]::new("WebApp-API", "WebAPI-Production")
Write-Host $app2.GetConfiguration() -ForegroundColor Gray

# Constructor 3: With location and pricing
Write-Host "[CONSTRUCTOR 3] With location and pricing tier:" -ForegroundColor Cyan
$app3 = [AzureAppService]::new("WebApp-Premium", "Premium-Apps", "westus", "P1V2")
Write-Host $app3.GetConfiguration() -ForegroundColor Gray

# Constructor 4: Full constructor with app settings
Write-Host "[CONSTRUCTOR 4] Full constructor with custom settings:" -ForegroundColor Cyan
$customSettings = @{
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "DATABASE_PROVIDER" = "SqlServer"
    "ENABLE_LOGGING" = "true"
    "MAX_POOL_SIZE" = "100"
}
$app4 = [AzureAppService]::new("WebApp-Full", "Enterprise-Apps", "eastus2", "S1", "dotnet", $customSettings)

# Add connection string to demonstrate method usage
$app4.AddConnectionString("DefaultConnection", "Server=prod-sql.database.windows.net;Database=ProdDB;", "SQLAzure")
$app4.AddConnectionString("Redis", "prod-redis.redis.cache.windows.net:6380", "Custom")

Write-Host $app4.GetConfiguration() -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Enums & Validation..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: ENUMS & VALIDATION BY TYPE - Strongly-typed constants
# ============================================================================
# EXPLANATION: Enums provide strongly-typed sets of named constants
# - Great for user-friendly, validated values and IntelliSense support
# - Can be used in function parameters and class properties
Write-Host "[CONCEPT 5] Enums & Validation by Type" -ForegroundColor White
Write-Host "Strongly-typed constants for Azure regions and SKUs" -ForegroundColor Gray

# Azure region enum for validation
enum AzureRegion {
    EastUS
    WestUS
    WestUS2
    EastUS2
    CentralUS
    NorthCentralUS
    SouthCentralUS
    WestCentralUS
    WestEurope
    NorthEurope
    EastAsia
    SoutheastAsia
    JapanEast
    JapanWest
    AustraliaEast
    AustraliaSoutheast
    BrazilSouth
    CanadaCentral
    CanadaEast
    UKSouth
    UKWest
}

# Azure VM size enum
enum AzureVMSize {
    Standard_B1s
    Standard_B1ms
    Standard_B2s
    Standard_B2ms
    Standard_B4ms
    Standard_D2s_v3
    Standard_D4s_v3
    Standard_D8s_v3
    Standard_E2s_v3
    Standard_E4s_v3
    Standard_E8s_v3
    Standard_F2s_v2
    Standard_F4s_v2
    Standard_F8s_v2
}

# Azure storage SKU enum
enum AzureStorageSku {
    Standard_LRS
    Standard_GRS
    Standard_RAGRS
    Standard_ZRS
    Premium_LRS
    Premium_ZRS
}

# Function demonstrating enum validation
function New-AzureVMConfiguration {
    param(
        [string] $VMName,
        [AzureRegion] $Region,
        [AzureVMSize] $Size,
        [string] $ResourceGroup = "Default-VMs"
    )
    
    Write-Host "[ENUM VALIDATION] Creating VM configuration with validated enums:" -ForegroundColor Yellow
    Write-Host "  VM Name: $VMName" -ForegroundColor Gray
    Write-Host "  Region: $Region (validated enum)" -ForegroundColor Gray
    Write-Host "  Size: $Size (validated enum)" -ForegroundColor Gray
    Write-Host "  Resource Group: $ResourceGroup" -ForegroundColor Gray
    
    # Convert enum to string for Azure API calls
    $regionString = $Region.ToString().ToLower()
    $sizeString = $Size.ToString()
    
    return [PSCustomObject]@{
        VMName = $VMName
        Region = $regionString
        Size = $sizeString
        ResourceGroup = $ResourceGroup
        EnumTypes = @{
            RegionEnum = $Region
            SizeEnum = $Size
        }
        ConfiguredAt = Get-Date
    }
}

# Class using enums as properties
class AzureResourceTemplate {
    [string] $Name
    [AzureRegion] $Region
    [AzureStorageSku] $StorageSku
    [hashtable] $Parameters
    
    # Constructor with enum parameters
    AzureResourceTemplate([string] $Name, [AzureRegion] $Region, [AzureStorageSku] $StorageSku) {
        $this.Name = $Name
        $this.Region = $Region
        $this.StorageSku = $StorageSku
        $this.Parameters = @{}
    }
    
    # Method that works with enum values
    [string] GetDeploymentCommand() {
        $regionStr = $this.Region.ToString().ToLower()
        $skuStr = $this.StorageSku.ToString()
        
        return "az deployment group create --resource-group 'rg-$($this.Name)' --template-file template.json --parameters location='$regionStr' storageSku='$skuStr'"
    }
    
    # Method that returns enum information
    [hashtable] GetEnumInfo() {
        return @{
            RegionValue = [int]$this.Region
            RegionName = $this.Region.ToString()
            StorageSkuValue = [int]$this.StorageSku
            StorageSkuName = $this.StorageSku.ToString()
        }
    }
}

Write-Host "[ENUM DEMO] Testing enum validation and usage:" -ForegroundColor Yellow

# Test valid enum values
Write-Host "[VALID ENUM] Creating VM with valid enum values:" -ForegroundColor Cyan
$vmConfig1 = New-AzureVMConfiguration -VMName "TestVM-001" -Region ([AzureRegion]::EastUS) -Size ([AzureVMSize]::Standard_B2s)
Write-Host "[SUCCESS] VM configured for region: $($vmConfig1.Region)" -ForegroundColor Green

# Test enum assignment by name
Write-Host "[ENUM BY NAME] Using enum values by name:" -ForegroundColor Cyan
$vmConfig2 = New-AzureVMConfiguration -VMName "TestVM-002" -Region "WestEurope" -Size "Standard_D2s_v3"
Write-Host "[SUCCESS] VM configured for region: $($vmConfig2.Region)" -ForegroundColor Green

# Test enum in class
Write-Host "[ENUM IN CLASS] Using enums as class properties:" -ForegroundColor Cyan
$template = [AzureResourceTemplate]::new("WebAppTemplate", [AzureRegion]::WestUS2, [AzureStorageSku]::Standard_GRS)
Write-Host "[TEMPLATE] $($template.GetDeploymentCommand())" -ForegroundColor Gray
$enumInfo = $template.GetEnumInfo()
Write-Host "[ENUM VALUES] Region: $($enumInfo.RegionName) (value: $($enumInfo.RegionValue)), Storage: $($enumInfo.StorageSkuName) (value: $($enumInfo.StorageSkuValue))" -ForegroundColor Gray

# Demonstrate enum validation failure (commented to prevent actual error)
Write-Host "[VALIDATION] These would fail enum validation:" -ForegroundColor Red
Write-Host "  New-AzureVMConfiguration -Region 'InvalidRegion' # Would throw validation error" -ForegroundColor Red
Write-Host "  New-AzureVMConfiguration -Size 'InvalidSize' # Would throw validation error" -ForegroundColor Red

Write-Host "`n[PAUSE] Press Enter to continue to Static & Hidden Members..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: STATIC & HIDDEN MEMBERS - Class-level and hidden functionality
# ============================================================================
# EXPLANATION: Static members belong to the class, not instances
# - Hidden members are suppressed in IntelliSense but still accessible
# - Use static for utility methods and shared data, hidden for internal implementation
Write-Host "[CONCEPT 6] Static & Hidden Members" -ForegroundColor White
Write-Host "Class-level static members and hidden implementation details" -ForegroundColor Gray

# Azure utility class with static and hidden members
class AzureUtilities {
    # Static properties - shared across all instances
    static [string] $DefaultSubscriptionId = "00000000-0000-0000-0000-000000000000"
    static [hashtable] $RegionMappings = @{
        "eastus" = "East US"
        "westus" = "West US"
        "westeurope" = "West Europe"
        "eastus2" = "East US 2"
    }
    static [int] $TotalResourcesCreated = 0
    
    # Hidden properties - not shown in default Get-Member
    hidden [string] $InternalId
    hidden [datetime] $LastOperationTime
    hidden [hashtable] $DebugInfo
    
    # Instance properties
    [string] $OperationName
    [string] $Status
    
    # Constructor
    AzureUtilities([string] $OperationName) {
        $this.OperationName = $OperationName
        $this.Status = "Initialized"
        $this.InternalId = [System.Guid]::NewGuid().ToString()
        $this.LastOperationTime = Get-Date
        $this.DebugInfo = @{
            ThreadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            ProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id
        }
        
        # Update static counter
        [AzureUtilities]::TotalResourcesCreated++
    }
    
    # Static method - belongs to the class, not instance
    static [string] GetFriendlyRegionName([string] $RegionCode) {
        if ([AzureUtilities]::RegionMappings.ContainsKey($RegionCode.ToLower())) {
            return [AzureUtilities]::RegionMappings[$RegionCode.ToLower()]
        }
        return $RegionCode
    }
    
    # Static method for validation
    static [bool] IsValidRegion([string] $RegionCode) {
        return [AzureUtilities]::RegionMappings.ContainsKey($RegionCode.ToLower())
    }
    
    # Static method to reset counters
    static [void] ResetCounters() {
        [AzureUtilities]::TotalResourcesCreated = 0
    }
    
    # Instance method that uses hidden members
    [hashtable] GetOperationDetails() {
        $this.LastOperationTime = Get-Date  # Update hidden member
        
        return @{
            OperationName = $this.OperationName
            Status = $this.Status
            InternalId = $this.InternalId  # Access hidden member
            LastOperation = $this.LastOperationTime
            DebugInfo = $this.DebugInfo
        }
    }
    
    # Hidden method - not shown in default Get-Member
    hidden [void] LogDebugInfo([string] $Message) {
        $this.DebugInfo["LastMessage"] = $Message
        $this.DebugInfo["LastMessageTime"] = Get-Date
        $this.LastOperationTime = Get-Date
    }
    
    # Public method that uses hidden method
    [void] SetStatus([string] $NewStatus) {
        $this.Status = $NewStatus
        $this.LogDebugInfo("Status changed to: $NewStatus")  # Call hidden method
    }
}

Write-Host "[STATIC DEMO] Testing static members:" -ForegroundColor Yellow

# Access static properties directly from class
Write-Host "[STATIC ACCESS] Default Subscription: $([AzureUtilities]::DefaultSubscriptionId)" -ForegroundColor Cyan
Write-Host "[STATIC ACCESS] Total Resources Created: $([AzureUtilities]::TotalResourcesCreated)" -ForegroundColor Cyan

# Use static methods
Write-Host "[STATIC METHOD] Region mapping: eastus -> $([AzureUtilities]::GetFriendlyRegionName('eastus'))" -ForegroundColor Cyan
Write-Host "[STATIC METHOD] Is 'invalidregion' valid? $([AzureUtilities]::IsValidRegion('invalidregion'))" -ForegroundColor Cyan

# Create instances and show static counter increment
Write-Host "[INSTANCES] Creating instances to demonstrate static counter:" -ForegroundColor Yellow
$util1 = [AzureUtilities]::new("CreateVM")
$util2 = [AzureUtilities]::new("CreateStorage")
$util3 = [AzureUtilities]::new("CreateNetwork")

Write-Host "[STATIC COUNTER] After creating 3 instances: $([AzureUtilities]::TotalResourcesCreated)" -ForegroundColor Cyan

# Show static members using Get-Member
Write-Host "[STATIC MEMBERS] Class static members:" -ForegroundColor Yellow
[AzureUtilities] | Get-Member -Static | Where-Object { $_.MemberType -eq "Property" -or $_.MemberType -eq "Method" } | ForEach-Object {
    Write-Host "  Static $($_.MemberType): $($_.Name)" -ForegroundColor Gray
}

Write-Host "[HIDDEN DEMO] Testing hidden members:" -ForegroundColor Yellow

# Show default Get-Member (hidden members not shown)
Write-Host "[DEFAULT GET-MEMBER] Standard member view (hidden members not shown):" -ForegroundColor Cyan
$util1 | Get-Member -MemberType Property | ForEach-Object {
    Write-Host "  Property: $($_.Name)" -ForegroundColor Gray
}

# Show hidden members with -Force
Write-Host "[FORCE GET-MEMBER] With -Force flag (hidden members shown):" -ForegroundColor Cyan
$util1 | Get-Member -MemberType Property -Force | ForEach-Object {
    $visibility = if ($_.Definition -like "*hidden*") { "Hidden" } else { "Public" }
    Write-Host "  Property: $($_.Name) [$visibility]" -ForegroundColor Gray
}

# Access hidden members directly (they still work)
Write-Host "[HIDDEN ACCESS] Accessing hidden members directly:" -ForegroundColor Yellow
$util1.SetStatus("Running")
$details = $util1.GetOperationDetails()
Write-Host "  Internal ID: $($details.InternalId)" -ForegroundColor Gray
Write-Host "  Last Operation: $($details.LastOperation)" -ForegroundColor Gray
Write-Host "  Debug Info: $($details.DebugInfo.Keys -join ', ')" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Inheritance..." -ForegroundColor Magenta
$pause6 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 7: INHERITANCE - Base classes and derived classes
# ============================================================================
# EXPLANATION: Inheritance allows classes to extend and reuse base class functionality
# - Use : BaseClass syntax to inherit from a base class
# - Derived classes get all base class members and can add their own
Write-Host "[CONCEPT 7] Inheritance" -ForegroundColor White
Write-Host "Base classes and inheritance for Azure resource hierarchies" -ForegroundColor Gray

# Base class for all Azure resources
class AzureBaseResource {
    [string] $Name
    [string] $ResourceGroup
    [string] $Location
    [hashtable] $Tags
    [datetime] $CreatedDate
    [string] $Status
    
    # Base constructor
    AzureBaseResource() {
        $this.Tags = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
    }
    
    # Constructor with basic parameters
    AzureBaseResource([string] $Name, [string] $ResourceGroup, [string] $Location) {
        $this.AzureBaseResource()  # Call default constructor
        $this.Name = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = $Location
    }
    
    # Base methods available to all derived classes
    [string] GetResourceId() {
        return "/subscriptions/{subscription}/resourceGroups/$($this.ResourceGroup)/providers/{provider}/$($this.Name)"
    }
    
    [void] AddTag([string] $Key, [string] $Value) {
        $this.Tags[$Key] = $Value
    }
    
    [void] SetStatus([string] $NewStatus) {
        $this.Status = $NewStatus
    }
    
    # Virtual method that can be overridden
    [string] GetSummary() {
        return "Azure Resource: $($this.Name) in $($this.Location)"
    }
}

# Derived class for Azure Virtual Machines
class AzureVirtualMachineEx : AzureBaseResource {
    [string] $VMSize
    [string] $OSType
    [int] $DataDiskCount
    [bool] $IsRunning
    
    # Derived class constructor - calls base constructor
    AzureVirtualMachineEx() {
        # Initialize base properties
        $this.Name = ""
        $this.ResourceGroup = ""
        $this.Location = ""
        $this.Tags = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
        
        # Initialize derived properties
        $this.VMSize = "Standard_B1s"
        $this.OSType = "Windows"
        $this.DataDiskCount = 0
        $this.IsRunning = $false
    }
    
    # Constructor with VM-specific parameters
    AzureVirtualMachineEx([string] $Name, [string] $ResourceGroup, [string] $Location, [string] $VMSize) {
        # Initialize base properties
        $this.Name = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = $Location
        $this.Tags = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
        
        # Initialize derived properties
        $this.VMSize = $VMSize
        $this.OSType = "Windows"
        $this.DataDiskCount = 0
        $this.IsRunning = $false
    }
    
    # VM-specific methods
    [void] Start() {
        $this.IsRunning = $true
        $this.SetStatus("Running")
    }
    
    [void] Stop() {
        $this.IsRunning = $false
        $this.SetStatus("Stopped")
    }
    
    [void] AttachDataDisk([int] $SizeGB) {
        $this.DataDiskCount++
        Write-Host "Attached $($SizeGB)GB data disk. Total disks: $($this.DataDiskCount)" -ForegroundColor Green
    }
    
    # Override base class method
    [string] GetSummary() {
        return "Azure VM: $($this.Name) in $($this.Location) - VM Size: $($this.VMSize), OS: $($this.OSType), Running: $($this.IsRunning)"
    }
    
    # Override GetResourceId with VM-specific provider
    [string] GetResourceId() {
        return "/subscriptions/{subscription}/resourceGroups/$($this.ResourceGroup)/providers/Microsoft.Compute/virtualMachines/$($this.Name)"
    }
}

# Another derived class for Azure Storage Accounts
class AzureStorageAccountEx : AzureBaseResource {
    [string] $SkuName
    [bool] $HTTPSOnly
    [string] $AccessTier
    [hashtable] $BlobContainers
    
    # Storage-specific constructor
    AzureStorageAccountEx() {
        # Initialize base properties
        $this.Name = ""
        $this.ResourceGroup = ""
        $this.Location = ""
        $this.Tags = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
        
        # Initialize derived properties
        $this.SkuName = "Standard_LRS"
        $this.HTTPSOnly = $true
        $this.AccessTier = "Hot"
        $this.BlobContainers = @{}
    }
    
    # Constructor with storage-specific parameters
    AzureStorageAccountEx([string] $Name, [string] $ResourceGroup, [string] $Location, [string] $SkuName) {
        # Initialize base properties
        $this.Name = $Name
        $this.ResourceGroup = $ResourceGroup
        $this.Location = $Location
        $this.Tags = @{}
        $this.CreatedDate = Get-Date
        $this.Status = "Created"
        
        # Initialize derived properties
        $this.SkuName = $SkuName
        $this.HTTPSOnly = $true
        $this.AccessTier = "Hot"
        $this.BlobContainers = @{}
    }
    
    # Storage-specific methods
    [void] CreateContainer([string] $ContainerName, [string] $AccessLevel) {
        $this.BlobContainers[$ContainerName] = @{
            AccessLevel = $AccessLevel
            CreatedDate = Get-Date
        }
        Write-Host "Created blob container: $ContainerName with $AccessLevel access" -ForegroundColor Green
    }
    
    [void] SetAccessTier([string] $Tier) {
        $this.AccessTier = $Tier
        Write-Host "Changed access tier to: $Tier" -ForegroundColor Yellow
    }
    
    # Override base class method
    [string] GetSummary() {
        return "Azure Storage: $($this.Name) in $($this.Location) - SKU: $($this.SkuName), Access Tier: $($this.AccessTier), Containers: $($this.BlobContainers.Count)"
    }
    
    # Override GetResourceId with Storage-specific provider
    [string] GetResourceId() {
        return "/subscriptions/{subscription}/resourceGroups/$($this.ResourceGroup)/providers/Microsoft.Storage/storageAccounts/$($this.Name)"
    }
}

Write-Host "[INHERITANCE DEMO] Creating derived class instances:" -ForegroundColor Yellow

# Create VM instance
Write-Host "[VM CREATION] Creating Azure Virtual Machine:" -ForegroundColor Cyan
$vm = [AzureVirtualMachineEx]::new("WebServer-VM-01", "Production-VMs", "eastus", "Standard_D2s_v3")
$vm.OSType = "Ubuntu 20.04"
$vm.AddTag("Environment", "Production")
$vm.AddTag("Role", "WebServer")

# Test VM-specific methods
$vm.Start()
$vm.AttachDataDisk(128)
$vm.AttachDataDisk(256)

Write-Host "[VM INFO] $($vm.GetSummary())" -ForegroundColor Yellow
Write-Host "[VM RESOURCE ID] $($vm.GetResourceId())" -ForegroundColor Gray

# Create Storage Account instance
Write-Host "[STORAGE CREATION] Creating Azure Storage Account:" -ForegroundColor Cyan
$storage = [AzureStorageAccountEx]::new("prodstorageacct001", "Production-Storage", "westus", "Premium_LRS")
$storage.AddTag("Environment", "Production")
$storage.AddTag("Purpose", "ApplicationData")

# Test Storage-specific methods
$storage.CreateContainer("webapp-assets", "Blob")
$storage.CreateContainer("backups", "Private")
$storage.SetAccessTier("Cool")

Write-Host "[STORAGE INFO] $($storage.GetSummary())" -ForegroundColor Yellow
Write-Host "[STORAGE RESOURCE ID] $($storage.GetResourceId())" -ForegroundColor Gray

# Show inheritance hierarchy
Write-Host "[INHERITANCE] Class hierarchy and member inheritance:" -ForegroundColor Yellow
Write-Host "  Base Class: AzureBaseResource" -ForegroundColor Gray
Write-Host "    - Properties: Name, ResourceGroup, Location, Tags, CreatedDate, Status" -ForegroundColor Gray
Write-Host "    - Methods: GetResourceId(), AddTag(), SetStatus(), GetSummary()" -ForegroundColor Gray
Write-Host "  Derived Class: AzureVirtualMachineEx" -ForegroundColor Gray
Write-Host "    - Additional Properties: VMSize, OSType, DataDiskCount, IsRunning" -ForegroundColor Gray
Write-Host "    - Additional Methods: Start(), Stop(), AttachDataDisk()" -ForegroundColor Gray
Write-Host "    - Overridden Methods: GetSummary(), GetResourceId()" -ForegroundColor Gray
Write-Host "  Derived Class: AzureStorageAccountEx" -ForegroundColor Gray
Write-Host "    - Additional Properties: SkuName, HTTPSOnly, AccessTier, BlobContainers" -ForegroundColor Gray
Write-Host "    - Additional Methods: CreateContainer(), SetAccessTier()" -ForegroundColor Gray
Write-Host "    - Overridden Methods: GetSummary(), GetResourceId()" -ForegroundColor Gray

# Show that derived classes can use base class methods
Write-Host "[BASE METHODS] Using inherited base class methods:" -ForegroundColor Cyan
$vm.AddTag("Owner", "DevOps Team")
$storage.AddTag("CostCenter", "IT-001")
Write-Host "  VM Tags: $($vm.Tags.Keys -join ', ')" -ForegroundColor Gray
Write-Host "  Storage Tags: $($storage.Tags.Keys -join ', ')" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause7 = Read-Host

# ============================================================================
# WORKSHOP SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[WORKSHOP COMPLETE] PowerShell Classes - Azure Resource Management with OOP" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[POWERSHELL CLASS CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Class Basics: Properties, methods, instance creation with [ClassName]::new()" -ForegroundColor Gray
Write-Host "2. Methods with Parameters: Overloads, parameter typing, return types" -ForegroundColor Gray
Write-Host "3. Stateful Methods: Using `$this to access and modify object state" -ForegroundColor Gray
Write-Host "4. Constructors: Default and overloaded constructors for flexible initialization" -ForegroundColor Gray
Write-Host "5. Enums & Validation: Strongly-typed constants for Azure regions and SKUs" -ForegroundColor Gray
Write-Host "6. Static & Hidden Members: Class-level data and hidden implementation details" -ForegroundColor Gray
Write-Host "7. Inheritance: Base classes and derived classes for code reuse" -ForegroundColor Gray

Write-Host "`n[AZURE SCENARIOS COVERED]" -ForegroundColor White
Write-Host "Azure resource modeling, VM configuration, storage account management" -ForegroundColor Gray
Write-Host "App Service deployment, resource templates, utility classes" -ForegroundColor Gray
Write-Host "Region validation, SKU management, resource hierarchies" -ForegroundColor Gray

Write-Host "`n[OBJECT-ORIENTED BENEFITS DEMONSTRATED]" -ForegroundColor White
Write-Host "Strongly-typed properties for better IntelliSense and validation" -ForegroundColor Gray
Write-Host "Method overloads for flexible API design" -ForegroundColor Gray
Write-Host "State encapsulation and behavior coupling" -ForegroundColor Gray
Write-Host "Code reuse through inheritance and composition" -ForegroundColor Gray
Write-Host "Type safety with enums and parameter validation" -ForegroundColor Gray

Write-Host "`n[CLASS DESIGN PATTERNS SHOWN]" -ForegroundColor White
Write-Host "Constructor chaining and overloading for flexible initialization" -ForegroundColor Gray
Write-Host "Static utility methods and shared data" -ForegroundColor Gray
Write-Host "Hidden members for internal implementation details" -ForegroundColor Gray
Write-Host "Method overriding and base class method calling" -ForegroundColor Gray
Write-Host "Enum-based validation and type safety" -ForegroundColor Gray

Write-Host "`n[LIVE CLASSES AVAILABLE]" -ForegroundColor White
Write-Host "Try: `$vm = [AzureVirtualMachineEx]::new('TestVM', 'TestRG', 'eastus', 'Standard_B2s')" -ForegroundColor Gray
Write-Host "Try: `$storage = [AzureStorageAccountEx]::new('teststorage', 'TestRG', 'westus', 'Standard_LRS')" -ForegroundColor Gray
Write-Host "Try: [AzureUtilities]::GetFriendlyRegionName('eastus')" -ForegroundColor Gray
Write-Host "Try: New-AzureVMConfiguration -VMName 'Test' -Region 'EastUS' -Size 'Standard_B2s'" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These class concepts enable you to:" -ForegroundColor Gray
Write-Host "- Create strongly-typed, reusable Azure resource models" -ForegroundColor Gray
Write-Host "- Build consistent APIs with method overloads and validation" -ForegroundColor Gray
Write-Host "- Implement complex business logic with state management" -ForegroundColor Gray
Write-Host "- Design extensible systems using inheritance and composition" -ForegroundColor Gray

Write-Host "`nSubscription: $($subscription.Name)" -ForegroundColor Gray
Write-Host "Workshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray