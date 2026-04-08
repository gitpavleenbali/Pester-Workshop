# ==============================================================================================
# 06. PowerShell Debugging: Advanced Debugging Lab
# Purpose: Demonstrate comprehensive PowerShell debugging techniques using Azure automation scenarios
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\06_debugging\Azure-Debugging-Lab.ps1
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
Write-Host "[INFO] Starting PowerShell Debugging Workshop..." -ForegroundColor Cyan
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
# CONCEPT 1: DEBUGGING INTRODUCTION AND BREAKPOINT FUNDAMENTALS
# ============================================================================
# EXPLANATION: Debugging vs Error Handling - Understanding the difference
# - Debugging: Interactive investigation during execution to find WHY errors occur
# - Error Handling: Reacting to errors when they happen
Write-Host "[CONCEPT 1] Debugging Introduction and Breakpoint Fundamentals" -ForegroundColor White
Write-Host "Setting and managing breakpoints for Azure automation debugging" -ForegroundColor Gray

Write-Host "`n[DEBUGGING OVERVIEW] Debugging vs Error Handling:" -ForegroundColor Yellow
Write-Host "  • Error Handling: Reacts to errors when they occur (try/catch/finally)" -ForegroundColor Gray
Write-Host "  • Debugging: Investigates WHY errors occur by suspending execution" -ForegroundColor Gray
Write-Host "  • Breakpoints: Suspend script execution for interactive investigation" -ForegroundColor Gray

# Sample function with Azure operations for debugging demonstration
function Get-AzureResourceInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$ResourceGroupNames,
        
        [string]$ResourceType = "All",
        [switch]$IncludeDetails,
        [string]$LogPath = "$env:TEMP\azure-inventory.log"
    )
    
    Write-Debug "Starting Azure resource inventory process"
    Write-Verbose "Processing $($ResourceGroupNames.Count) resource groups"
    
    $inventoryResults = @()
    $processedCount = 0
    
    foreach ($rgName in $ResourceGroupNames) {
        $processedCount++
        Write-Host "[PROCESSING] Resource Group $processedCount/$($ResourceGroupNames.Count): $rgName" -ForegroundColor Cyan
        
        # This line would be a good place for a breakpoint
        $resourceGroup = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
        
        if ($resourceGroup) {
            Write-Debug "Found resource group: $rgName"
            
            # Another good breakpoint location - before getting resources
            $resources = Get-AzResource -ResourceGroupName $rgName -ErrorAction SilentlyContinue
            
            if ($ResourceType -ne "All") {
                $resources = $resources | Where-Object { $_.ResourceType -like "*$ResourceType*" }
            }
            
            foreach ($resource in $resources) {
                # Breakpoint here to inspect individual resources
                $resourceInfo = [PSCustomObject]@{
                    ResourceGroup = $rgName
                    ResourceName = $resource.Name
                    ResourceType = $resource.ResourceType
                    Location = $resource.Location
                    Tags = $resource.Tags
                    Id = $resource.ResourceId
                }
                
                if ($IncludeDetails) {
                    # This could be slow - good place to debug performance
                    $resourceInfo | Add-Member -MemberType NoteProperty -Name "Details" -Value (Get-AzResource -ResourceId $resource.ResourceId)
                }
                
                $inventoryResults += $resourceInfo
            }
            
            Write-Verbose "Found $($resources.Count) resources in $rgName"
        } else {
            Write-Warning "Resource group '$rgName' not found"
        }
    }
    
    # Log results
    $logEntry = "$(Get-Date): Inventory completed - $($inventoryResults.Count) resources found"
    Add-Content -Path $LogPath -Value $logEntry
    
    return $inventoryResults
}

Write-Host "`n[BREAKPOINT DEMO] Setting and Managing Breakpoints:" -ForegroundColor Cyan
Write-Host "The following demonstrates different types of breakpoints you can set:" -ForegroundColor Yellow

# Demonstrate breakpoint management commands
Write-Host "`n[BREAKPOINT COMMANDS] Available breakpoint management cmdlets:" -ForegroundColor Yellow
Write-Host "1. Set-PSBreakpoint    - Create new breakpoints" -ForegroundColor Gray
Write-Host "2. Get-PSBreakpoint    - List existing breakpoints" -ForegroundColor Gray
Write-Host "3. Remove-PSBreakpoint - Delete breakpoints" -ForegroundColor Gray
Write-Host "4. Enable-PSBreakpoint - Activate disabled breakpoints" -ForegroundColor Gray
Write-Host "5. Disable-PSBreakpoint- Temporarily disable breakpoints" -ForegroundColor Gray

# Example: Setting different types of breakpoints
Write-Host "`n[EXAMPLE] Setting line breakpoints (for demonstration - not active):" -ForegroundColor Cyan
Write-Host "  Set-PSBreakpoint -Script 'script.ps1' -Line 25" -ForegroundColor Gray
Write-Host "  Set-PSBreakpoint -Script 'script.ps1' -Line 45,67,89" -ForegroundColor Gray

Write-Host "`n[EXAMPLE] Setting command breakpoints:" -ForegroundColor Cyan
Write-Host "  Set-PSBreakpoint -Command 'Get-AzResource'" -ForegroundColor Gray
Write-Host "  Set-PSBreakpoint -Command 'Get-AzResourceGroup'" -ForegroundColor Gray

Write-Host "`n[EXAMPLE] Setting variable breakpoints:" -ForegroundColor Cyan
Write-Host "  Set-PSBreakpoint -Variable 'resourceGroup' -Mode Read" -ForegroundColor Gray
Write-Host "  Set-PSBreakpoint -Variable 'inventoryResults' -Mode Write" -ForegroundColor Gray

# Show current breakpoints (if any)
$currentBreakpoints = Get-PSBreakpoint
if ($currentBreakpoints.Count -gt 0) {
    Write-Host "`n[CURRENT BREAKPOINTS] Active breakpoints in session:" -ForegroundColor Yellow
    $currentBreakpoints | Format-Table -AutoSize
} else {
    Write-Host "`n[NO BREAKPOINTS] No active breakpoints in current session" -ForegroundColor Gray
}

Write-Host "`n[INTERACTIVE DEMO] Test the inventory function:" -ForegroundColor Cyan
Write-Host "You can test breakpoints with this command:" -ForegroundColor Yellow
Write-Host "  Get-AzureResourceInventory -ResourceGroupNames @('TestRG') -Verbose -Debug" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Debugger Actions..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: DEBUGGER ACTIONS AND NAVIGATION
# ============================================================================
# EXPLANATION: Understanding debugger navigation commands
# - Continue (F5): Run until next breakpoint
# - Step Over (F10): Execute current line without entering functions
# - Step Into (F11): Enter function calls for detailed debugging
# - Step Out (Shift+F11): Exit current function and return to caller
Write-Host "[CONCEPT 2] Debugger Actions and Navigation" -ForegroundColor White
Write-Host "Mastering debugger commands for effective Azure script debugging" -ForegroundColor Gray

Write-Host "`n[DEBUGGER COMMANDS] Available navigation actions:" -ForegroundColor Yellow

# Create a function with nested calls to demonstrate debugger navigation
function Deploy-AzureResourceGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory)]
        [string]$Location,
        
        [hashtable]$Tags = @{},
        [switch]$WhatIf
    )
    
    Write-Debug "Starting resource group deployment process"
    
    # Step 1: Validate parameters (good place for Step Over)
    $validationResult = Test-AzureResourceGroupParameters -Name $ResourceGroupName -Location $Location
    
    if (-not $validationResult.IsValid) {
        throw "Validation failed: $($validationResult.Errors -join ', ')"
    }
    
    # Step 2: Check if resource group exists (good place for Step Into)
    $existingRG = Get-ExistingResourceGroup -Name $ResourceGroupName
    
    if ($existingRG) {
        Write-Warning "Resource group '$ResourceGroupName' already exists"
        return $existingRG
    }
    
    # Step 3: Create the resource group (good place for Step Out after entering)
    if (-not $WhatIf) {
        $newRG = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags
        Write-Host "[CREATED] Resource group '$ResourceGroupName' created successfully" -ForegroundColor Green
        return $newRG
    } else {
        Write-Host "[WHATIF] Would create resource group '$ResourceGroupName' in '$Location'" -ForegroundColor Yellow
        return $null
    }
}

function Test-AzureResourceGroupParameters {
    param(
        [string]$Name,
        [string]$Location
    )
    
    Write-Debug "Validating resource group parameters"
    
    $errors = @()
    
    # Validate name format
    if ($Name -notmatch '^[a-zA-Z0-9._()-]+$') {
        $errors += "Invalid resource group name format"
    }
    
    if ($Name.Length -gt 90) {
        $errors += "Resource group name too long (max 90 characters)"
    }
    
    # Validate location
    $validLocations = @("eastus", "westus", "centralus", "westeurope", "northeurope")
    if ($Location -notin $validLocations) {
        $errors += "Invalid location. Valid options: $($validLocations -join ', ')"
    }
    
    return [PSCustomObject]@{
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

function Get-ExistingResourceGroup {
    param([string]$Name)
    
    Write-Debug "Checking if resource group '$Name' exists"
    
    try {
        $rg = Get-AzResourceGroup -Name $Name -ErrorAction Stop
        Write-Debug "Resource group found: $($rg.ResourceGroupName)"
        return $rg
    } catch {
        Write-Debug "Resource group '$Name' does not exist"
        return $null
    }
}

Write-Host "`n[DEBUGGER ACTIONS] GUI and Command Line Options:" -ForegroundColor Yellow

Write-Host "`n  GUI Actions (Visual Studio Code / PowerShell ISE):" -ForegroundColor Cyan
Write-Host "    F5 (Continue)     - Run code until the next breakpoint" -ForegroundColor Gray
Write-Host "    F10 (Step Over)   - Execute current line, don't enter functions" -ForegroundColor Gray
Write-Host "    F11 (Step Into)   - Enter function calls for detailed debugging" -ForegroundColor Gray
Write-Host "    Shift+F11 (Step Out) - Exit current function back to caller" -ForegroundColor Gray

Write-Host "`n  Command Line Shortcuts (when in debugger):" -ForegroundColor Cyan
Write-Host "    s or stepInto     - Same as F11, enter function calls" -ForegroundColor Gray
Write-Host "    v or stepOver     - Same as F10, execute without entering functions" -ForegroundColor Gray
Write-Host "    o or stepOut      - Same as Shift+F11, exit current function" -ForegroundColor Gray
Write-Host "    c or continue     - Same as F5, run until next breakpoint" -ForegroundColor Gray
Write-Host "    q or quit         - Exit the debugger" -ForegroundColor Gray
Write-Host "    k or Get-PSCallStack - Show the call stack" -ForegroundColor Gray
Write-Host "    l or list         - List source code around current line" -ForegroundColor Gray

Write-Host "`n[DEBUGGING SCENARIO] Azure Resource Group Deployment:" -ForegroundColor Cyan
Write-Host "To debug the deployment function, you could set breakpoints at:" -ForegroundColor Yellow
Write-Host "  1. Parameter validation (Test-AzureResourceGroupParameters)" -ForegroundColor Gray
Write-Host "  2. Existence check (Get-ExistingResourceGroup)" -ForegroundColor Gray
Write-Host "  3. Resource group creation (New-AzResourceGroup)" -ForegroundColor Gray

Write-Host "`n[STEP-BY-STEP EXAMPLE] Debugging workflow:" -ForegroundColor Yellow
Write-Host "  1. Set breakpoint: Set-PSBreakpoint -Command 'Deploy-AzureResourceGroup'" -ForegroundColor Gray
Write-Host "  2. Run function: Deploy-AzureResourceGroup -ResourceGroupName 'TestRG' -Location 'eastus'" -ForegroundColor Gray
Write-Host "  3. When debugger activates:" -ForegroundColor Gray
Write-Host "     • Use 's' to Step Into parameter validation" -ForegroundColor Gray
Write-Host "     • Use 'v' to Step Over the existence check" -ForegroundColor Gray
Write-Host "     • Use 'k' to view the call stack" -ForegroundColor Gray
Write-Host "     • Use 'c' to continue execution" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Call Stack Inspection..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: CALL STACK INSPECTION AND DEBUGGING CONTEXT
# ============================================================================
# EXPLANATION: Understanding the call stack for debugging complex Azure automation
# - Call stack shows the chain of function calls that led to current execution point
# - Get-PSCallStack reveals function names, parameters, and line numbers
# - Essential for debugging nested Azure operations and understanding execution flow
Write-Host "[CONCEPT 3] Call Stack Inspection and Debugging Context" -ForegroundColor White
Write-Host "Using call stack to understand execution flow in Azure automation" -ForegroundColor Gray

# Function to demonstrate call stack with nested Azure operations
function Start-AzureResourceDeployment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory)]
        [string]$TemplateFile,
        
        [hashtable]$Parameters = @{},
        [switch]$ValidateOnly
    )
    
    Write-Host "[DEPLOY] Starting Azure resource deployment" -ForegroundColor Cyan
    Write-Debug "Call stack depth: $((Get-PSCallStack).Count)"
    
    # Level 1: Main deployment function
    $deploymentName = "Deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    # Call validation function (adds to call stack)
    $validationResult = Invoke-TemplateValidation -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -Parameters $Parameters
    
    if (-not $validationResult.IsValid) {
        throw "Template validation failed: $($validationResult.Errors -join '; ')"
    }
    
    if ($ValidateOnly) {
        Write-Host "[VALIDATION] Template validation completed successfully" -ForegroundColor Green
        return $validationResult
    }
    
    # Call deployment function (adds to call stack)
    $deploymentResult = Start-ActualDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -Parameters $Parameters -DeploymentName $deploymentName
    
    return $deploymentResult
}

function Invoke-TemplateValidation {
    param(
        [string]$ResourceGroupName,
        [string]$TemplateFile,
        [hashtable]$Parameters
    )
    
    Write-Debug "Validating template: $TemplateFile"
    Write-Host "[VALIDATION] Checking template and parameters..." -ForegroundColor Yellow
    
    # Level 2: Template validation function
    # This would be a good place to examine the call stack
    Show-CallStackInfo -Context "Template Validation"
    
    # Call parameter validation (adds to call stack)
    $paramValidation = Test-TemplateParameters -Parameters $Parameters -TemplateFile $TemplateFile
    
    # Simulate template validation
    $errors = @()
    
    if (-not (Test-Path $TemplateFile)) {
        $errors += "Template file not found: $TemplateFile"
    }
    
    if ($paramValidation.MissingRequired.Count -gt 0) {
        $errors += "Missing required parameters: $($paramValidation.MissingRequired -join ', ')"
    }
    
    return [PSCustomObject]@{
        IsValid = $errors.Count -eq 0
        Errors = $errors
        ValidationTime = Get-Date
    }
}

function Test-TemplateParameters {
    param(
        [hashtable]$Parameters,
        [string]$TemplateFile
    )
    
    Write-Debug "Testing template parameters"
    
    # Level 3: Parameter testing function
    # Show call stack at deepest level
    Show-CallStackInfo -Context "Parameter Testing"
    
    # Simulate parameter validation
    $requiredParams = @("storageAccountName", "location", "sku")
    $providedParams = $Parameters.Keys
    $missingRequired = $requiredParams | Where-Object { $_ -notin $providedParams }
    
    return [PSCustomObject]@{
        MissingRequired = $missingRequired
        ProvidedCount = $providedParams.Count
        RequiredCount = $requiredParams.Count
    }
}

function Start-ActualDeployment {
    param(
        [string]$ResourceGroupName,
        [string]$TemplateFile,
        [hashtable]$Parameters,
        [string]$DeploymentName
    )
    
    Write-Host "[DEPLOY] Starting actual resource deployment..." -ForegroundColor Cyan
    
    # Level 2: Actual deployment function
    Show-CallStackInfo -Context "Actual Deployment"
    
    # Simulate deployment process
    Start-Sleep -Milliseconds 500
    
    # Call monitoring function (adds to call stack)
    $monitoringResult = Monitor-DeploymentProgress -ResourceGroupName $ResourceGroupName -DeploymentName $DeploymentName
    
    return [PSCustomObject]@{
        DeploymentName = $DeploymentName
        Status = "Succeeded"
        ResourceGroup = $ResourceGroupName
        StartTime = Get-Date
        MonitoringResult = $monitoringResult
    }
}

function Monitor-DeploymentProgress {
    param(
        [string]$ResourceGroupName,
        [string]$DeploymentName
    )
    
    Write-Debug "Monitoring deployment progress"
    
    # Level 3: Monitoring function
    Show-CallStackInfo -Context "Deployment Monitoring"
    
    # Simulate monitoring
    $progress = @(
        "Validating template and parameters",
        "Creating storage account",
        "Configuring access policies",
        "Deployment completed"
    )
    
    foreach ($step in $progress) {
        Write-Host "  [MONITOR] $step" -ForegroundColor Gray
        Start-Sleep -Milliseconds 100
    }
    
    return [PSCustomObject]@{
        Steps = $progress.Count
        Duration = "0:00:02"
        Status = "Completed"
    }
}

function Show-CallStackInfo {
    param([string]$Context = "Debug")
    
    Write-Host "`n[CALL STACK] $Context - Current execution context:" -ForegroundColor Yellow
    
    # Get the current call stack
    $callStack = Get-PSCallStack
    
    Write-Host "  Stack Depth: $($callStack.Count) levels" -ForegroundColor Gray
    
    for ($i = 0; $i -lt $callStack.Count; $i++) {
        $frame = $callStack[$i]
        $indent = "  " + ("  " * $i)
        
        if ($frame.FunctionName -eq "<ScriptBlock>") {
            Write-Host "$indent[$i] Script Block (Line: $($frame.ScriptLineNumber))" -ForegroundColor Cyan
        } else {
            Write-Host "$indent[$i] Function: $($frame.FunctionName) (Line: $($frame.ScriptLineNumber))" -ForegroundColor Cyan
            
            # Show arguments if available
            if ($frame.Arguments) {
                Write-Host "$indent    Arguments: $($frame.Arguments -join ', ')" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
}

Write-Host "`n[CALL STACK DEMO] Understanding execution flow:" -ForegroundColor Cyan
Write-Host "The following demonstration shows how call stack inspection helps debug complex Azure operations" -ForegroundColor Yellow

Write-Host "`n[DEMO] Simulated Azure deployment with call stack tracking:" -ForegroundColor Cyan

# Demonstrate call stack with a simulated deployment
try {
    $testParams = @{
        storageAccountName = "teststorage001"
        location = "eastus"
        sku = "Standard_LRS"
    }
    
    $result = Start-AzureResourceDeployment -ResourceGroupName "TestRG" -TemplateFile "storage.json" -Parameters $testParams -ValidateOnly
    Write-Host "[SUCCESS] Deployment validation completed" -ForegroundColor Green
    
} catch {
    Write-Host "[ERROR] Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[CALL STACK] Error occurred at:" -ForegroundColor Yellow
    Show-CallStackInfo -Context "Error Analysis"
}

Write-Host "`n[DEBUGGING TIPS] Using call stack effectively:" -ForegroundColor Yellow
Write-Host "  1. Use Get-PSCallStack to see the execution path" -ForegroundColor Gray
Write-Host "  2. Check function parameters at each stack level" -ForegroundColor Gray
Write-Host "  3. Identify where errors originate in nested functions" -ForegroundColor Gray
Write-Host "  4. Understand the flow of Azure operations" -ForegroundColor Gray
Write-Host "  5. Use stack depth to control debug output verbosity" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Debug Output and Logging..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: DEBUG OUTPUT AND LOGGING TECHNIQUES
# ============================================================================
# EXPLANATION: Using Write-Debug, Write-Verbose, and Write-Host for debugging
# - Write-Debug: Controlled by $DebugPreference, for detailed troubleshooting
# - Write-Verbose: Controlled by $VerbosePreference, for operational details
# - Write-Host: Always visible, for critical debugging information
# - Strategic placement helps understand execution flow without breakpoints
Write-Host "[CONCEPT 4] Debug Output and Logging Techniques" -ForegroundColor White
Write-Host "Strategic logging for Azure automation debugging and monitoring" -ForegroundColor Gray

# Function demonstrating comprehensive debug logging
function Sync-AzureStorageData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourceStorageAccount,
        
        [Parameter(Mandatory)]
        [string]$DestinationStorageAccount,
        
        [string]$ContainerName = "data",
        [int]$MaxRetries = 3,
        [switch]$DryRun
    )
    
    # Always visible - critical operation start
    Write-Host "[SYNC START] Azure Storage Data Synchronization" -ForegroundColor Cyan
    Write-Host "  Source: $SourceStorageAccount" -ForegroundColor Gray
    Write-Host "  Destination: $DestinationStorageAccount" -ForegroundColor Gray
    Write-Host "  Container: $ContainerName" -ForegroundColor Gray
    
    # Debug output - detailed troubleshooting info
    Write-Debug "Sync operation parameters:"
    Write-Debug "  SourceStorageAccount: $SourceStorageAccount"
    Write-Debug "  DestinationStorageAccount: $DestinationStorageAccount"
    Write-Debug "  ContainerName: $ContainerName"
    Write-Debug "  MaxRetries: $MaxRetries"
    Write-Debug "  DryRun: $DryRun"
    Write-Debug "  Current user: $($env:USERNAME)"
    Write-Debug "  PowerShell version: $($PSVersionTable.PSVersion)"
    
    # Verbose output - operational details
    Write-Verbose "Starting storage account validation phase"
    
    $syncResults = @{
        FilesProcessed = 0
        FilesSkipped = 0
        Errors = @()
        StartTime = Get-Date
    }
    
    try {
        # Phase 1: Validate source storage account
        Write-Verbose "Validating source storage account: $SourceStorageAccount"
        Write-Debug "Attempting to get source storage account context"
        
        $sourceContext = Get-StorageAccountContext -StorageAccountName $SourceStorageAccount
        if (-not $sourceContext) {
            throw "Cannot access source storage account: $SourceStorageAccount"
        }
        
        Write-Debug "Source storage context obtained successfully"
        Write-Verbose "Source storage account validated"
        
        # Phase 2: Validate destination storage account
        Write-Verbose "Validating destination storage account: $DestinationStorageAccount"
        Write-Debug "Attempting to get destination storage account context"
        
        $destContext = Get-StorageAccountContext -StorageAccountName $DestinationStorageAccount
        if (-not $destContext) {
            throw "Cannot access destination storage account: $DestinationStorageAccount"
        }
        
        Write-Debug "Destination storage context obtained successfully"
        Write-Verbose "Destination storage account validated"
        
        # Phase 3: List source files
        Write-Verbose "Enumerating files in source container: $ContainerName"
        Write-Debug "Calling Get-ContainerFiles with source context"
        
        $sourceFiles = Get-ContainerFiles -Context $sourceContext -ContainerName $ContainerName
        
        Write-Host "[DISCOVERY] Found $($sourceFiles.Count) files in source container" -ForegroundColor Green
        Write-Debug "Source files enumeration completed. Files found: $($sourceFiles.Count)"
        Write-Verbose "File enumeration completed for source container"
        
        # Phase 4: Process each file
        Write-Verbose "Starting file-by-file synchronization process"
        
        foreach ($file in $sourceFiles) {
            Write-Debug "Processing file: $($file.Name)"
            Write-Verbose "Syncing file: $($file.Name) (Size: $($file.Size) bytes)"
            
            try {
                if ($DryRun) {
                    Write-Host "  [DRY RUN] Would sync: $($file.Name)" -ForegroundColor Yellow
                    Write-Debug "Dry run mode - skipping actual copy operation"
                } else {
                    # Simulate file copy with retry logic
                    $copyResult = Copy-FileWithRetry -SourceFile $file -DestinationContext $destContext -ContainerName $ContainerName -MaxRetries $MaxRetries
                    
                    if ($copyResult.Success) {
                        Write-Host "  [SUCCESS] Synced: $($file.Name)" -ForegroundColor Green
                        Write-Debug "File copied successfully: $($file.Name)"
                        $syncResults.FilesProcessed++
                    } else {
                        Write-Host "  [FAILED] Could not sync: $($file.Name)" -ForegroundColor Red
                        Write-Debug "File copy failed: $($file.Name). Error: $($copyResult.Error)"
                        $syncResults.Errors += "Failed to copy $($file.Name): $($copyResult.Error)"
                        $syncResults.FilesSkipped++
                    }
                }
                
                Write-Verbose "Completed processing file: $($file.Name)"
                
            } catch {
                Write-Host "  [ERROR] Exception processing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
                Write-Debug "Exception during file processing: $($_.Exception.Message)"
                Write-Debug "Exception stack trace: $($_.ScriptStackTrace)"
                $syncResults.Errors += "Exception processing $($file.Name): $($_.Exception.Message)"
                $syncResults.FilesSkipped++
            }
        }
        
    } catch {
        Write-Host "[CRITICAL ERROR] Synchronization failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Debug "Critical error in sync operation: $($_.Exception.Message)"
        Write-Debug "Critical error stack trace: $($_.ScriptStackTrace)"
        $syncResults.Errors += "Critical error: $($_.Exception.Message)"
        throw
    }
    
    # Phase 5: Summary and cleanup
    $syncResults.EndTime = Get-Date
    $duration = $syncResults.EndTime - $syncResults.StartTime
    
    Write-Host "`n[SYNC COMPLETE] Operation summary:" -ForegroundColor Cyan
    Write-Host "  Files processed: $($syncResults.FilesProcessed)" -ForegroundColor Green
    Write-Host "  Files skipped: $($syncResults.FilesSkipped)" -ForegroundColor Yellow
    Write-Host "  Errors: $($syncResults.Errors.Count)" -ForegroundColor Red
    Write-Host "  Duration: $($duration.TotalSeconds) seconds" -ForegroundColor Gray
    
    Write-Debug "Sync operation completed. Total duration: $($duration.TotalMilliseconds) ms"
    Write-Verbose "Storage synchronization operation completed"
    
    if ($syncResults.Errors.Count -gt 0) {
        Write-Host "`n[ERRORS] The following errors occurred:" -ForegroundColor Red
        foreach ($error in $syncResults.Errors) {
            Write-Host "  • $error" -ForegroundColor Red
        }
    }
    
    return $syncResults
}

# Helper functions for storage operations
function Get-StorageAccountContext {
    param([string]$StorageAccountName)
    
    Write-Debug "Getting storage context for: $StorageAccountName"
    
    # Simulate getting storage account context
    if ($StorageAccountName -like "*invalid*") {
        Write-Debug "Storage account name contains 'invalid' - simulating failure"
        return $null
    }
    
    Write-Debug "Storage context created successfully for: $StorageAccountName"
    return [PSCustomObject]@{
        StorageAccountName = $StorageAccountName
        ConnectionString = "simulated-connection-string"
        Created = Get-Date
    }
}

function Get-ContainerFiles {
    param(
        $Context,
        [string]$ContainerName
    )
    
    Write-Debug "Enumerating files in container: $ContainerName"
    
    # Simulate file listing
    $simulatedFiles = @(
        [PSCustomObject]@{ Name = "data1.csv"; Size = 1024 },
        [PSCustomObject]@{ Name = "data2.json"; Size = 2048 },
        [PSCustomObject]@{ Name = "config.xml"; Size = 512 },
        [PSCustomObject]@{ Name = "archive.zip"; Size = 10240 }
    )
    
    Write-Debug "Found $($simulatedFiles.Count) files in container"
    return $simulatedFiles
}

function Copy-FileWithRetry {
    param(
        $SourceFile,
        $DestinationContext,
        [string]$ContainerName,
        [int]$MaxRetries
    )
    
    Write-Debug "Starting copy operation for: $($SourceFile.Name)"
    
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        Write-Debug "Copy attempt $attempt of $MaxRetries for: $($SourceFile.Name)"
        
        # Simulate copy operation with occasional failures
        $success = (Get-Random -Minimum 1 -Maximum 10) -gt 2  # 80% success rate
        
        if ($success) {
            Write-Debug "Copy successful on attempt $attempt"
            return [PSCustomObject]@{ Success = $true; Attempt = $attempt }
        } else {
            Write-Debug "Copy failed on attempt $attempt"
            if ($attempt -eq $MaxRetries) {
                return [PSCustomObject]@{ Success = $false; Error = "Max retries exceeded"; Attempt = $attempt }
            }
            Start-Sleep -Milliseconds 100
        }
    }
}

Write-Host "`n[LOGGING DEMO] Different types of debug output:" -ForegroundColor Cyan

Write-Host "`n[CURRENT PREFERENCES] Debug and verbose settings:" -ForegroundColor Yellow
Write-Host "  DebugPreference: $DebugPreference" -ForegroundColor Gray
Write-Host "  VerbosePreference: $VerbosePreference" -ForegroundColor Gray

Write-Host "`n[DEMO] Storage sync with default preferences (minimal output):" -ForegroundColor Cyan
$syncResult1 = Sync-AzureStorageData -SourceStorageAccount "sourcestorage" -DestinationStorageAccount "deststorage" -DryRun

Write-Host "`n[DEMO] Storage sync with verbose output:" -ForegroundColor Cyan
$syncResult2 = Sync-AzureStorageData -SourceStorageAccount "sourcestorage" -DestinationStorageAccount "deststorage" -Verbose -DryRun

Write-Host "`n[DEMO] Storage sync with debug output:" -ForegroundColor Cyan
$syncResult3 = Sync-AzureStorageData -SourceStorageAccount "sourcestorage" -DestinationStorageAccount "deststorage" -Debug -DryRun

Write-Host "`n[LOGGING BEST PRACTICES] Strategic debug output guidelines:" -ForegroundColor Yellow
Write-Host "  1. Write-Host: Always visible critical information and status" -ForegroundColor Gray
Write-Host "  2. Write-Verbose: Operational details, controlled by -Verbose" -ForegroundColor Gray
Write-Host "  3. Write-Debug: Detailed troubleshooting, controlled by -Debug" -ForegroundColor Gray
Write-Host "  4. Include timestamps, parameters, and execution context" -ForegroundColor Gray
Write-Host "  5. Log both successes and failures for complete visibility" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Strict Mode and Tracing..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: STRICT MODE AND ADVANCED TRACING
# ============================================================================
# EXPLANATION: Advanced debugging tools for catching subtle errors
# - Set-StrictMode: Enforces best practices and catches common mistakes
# - Trace-Command: Traces parameter binding and cmdlet execution
# - Set-PSDebug: Controls script-level debugging features
Write-Host "[CONCEPT 5] Strict Mode and Advanced Tracing" -ForegroundColor White
Write-Host "Advanced debugging tools for catching subtle Azure automation errors" -ForegroundColor Gray

Write-Host "`n[STRICT MODE] Enforcing PowerShell best practices:" -ForegroundColor Yellow

# Function to demonstrate strict mode effects
function Test-StrictModeEffects {
    param([string]$TestCase = "All")
    
    Write-Host "[STRICT MODE DEMO] Testing different scenarios:" -ForegroundColor Cyan
    
    if ($TestCase -eq "All" -or $TestCase -eq "UninitializedVariable") {
        Write-Host "`n[TEST 1] Uninitialized Variable Access:" -ForegroundColor Yellow
        try {
            # This will cause an error in strict mode
            $undefinedVar = $SomeUndefinedVariable + 10
            Write-Host "  Result: $undefinedVar (no strict mode)" -ForegroundColor Green
        } catch {
            Write-Host "  [STRICT MODE ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($TestCase -eq "All" -or $TestCase -eq "NonExistentProperty") {
        Write-Host "`n[TEST 2] Non-existent Property Access:" -ForegroundColor Yellow
        try {
            $obj = [PSCustomObject]@{ Name = "Test"; Value = 123 }
            # This will cause an error in strict mode
            $property = $obj.NonExistentProperty
            Write-Host "  Property value: $property (no strict mode)" -ForegroundColor Green
        } catch {
            Write-Host "  [STRICT MODE ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($TestCase -eq "All" -or $TestCase -eq "OutOfBounds") {
        Write-Host "`n[TEST 3] Array Index Out of Bounds:" -ForegroundColor Yellow
        try {
            $array = @("item1", "item2", "item3")
            # This will cause an error in strict mode
            $item = $array[10]
            Write-Host "  Array item: $item (no strict mode)" -ForegroundColor Green
        } catch {
            Write-Host "  [STRICT MODE ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n[DEMO] Testing without strict mode:" -ForegroundColor Cyan
Set-StrictMode -Off
Test-StrictModeEffects

Write-Host "`n[DEMO] Testing with strict mode (Version 1.0):" -ForegroundColor Cyan
Set-StrictMode -Version 1.0
Test-StrictModeEffects

Write-Host "`n[DEMO] Testing with strict mode (Version 2.0):" -ForegroundColor Cyan
Set-StrictMode -Version 2.0
Test-StrictModeEffects

Write-Host "`n[DEMO] Testing with strict mode (Latest):" -ForegroundColor Cyan
Set-StrictMode -Version Latest
Test-StrictModeEffects

# Reset strict mode
Set-StrictMode -Off

Write-Host "`n[TRACE-COMMAND] Tracing Azure cmdlet execution:" -ForegroundColor Yellow

# Function to demonstrate parameter binding tracing
function Get-AzureResourceWithTracing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,
        
        [string]$ResourceName,
        [string]$ResourceType
    )
    
    Write-Host "[TRACING DEMO] Demonstrating parameter binding trace" -ForegroundColor Cyan
    
    # Simulate getting Azure resources with parameter tracing
    Write-Host "Simulating: Get-AzResource -ResourceGroupName '$ResourceGroupName'" -ForegroundColor Gray
    
    if ($ResourceName) {
        Write-Host "Additional parameter: -Name '$ResourceName'" -ForegroundColor Gray
    }
    
    if ($ResourceType) {
        Write-Host "Additional parameter: -ResourceType '$ResourceType'" -ForegroundColor Gray
    }
    
    # Return simulated results
    return @(
        [PSCustomObject]@{
            ResourceGroupName = $ResourceGroupName
            Name = "StorageAccount001"
            ResourceType = "Microsoft.Storage/storageAccounts"
            Location = "East US"
        },
        [PSCustomObject]@{
            ResourceGroupName = $ResourceGroupName
            Name = "WebApp001"
            ResourceType = "Microsoft.Web/sites"
            Location = "East US"
        }
    )
}

Write-Host "`n[TRACE DEMO] Parameter binding trace example:" -ForegroundColor Cyan
Write-Host "Note: In production, you would use:" -ForegroundColor Yellow
Write-Host "  Trace-Command -Name ParameterBinding -Expression { Get-AzResource -ResourceGroupName 'TestRG' } -PSHost" -ForegroundColor Gray

# Demonstrate the function call that would be traced
$resources = Get-AzureResourceWithTracing -ResourceGroupName "TestResourceGroup" -ResourceName "MyStorage" -ResourceType "Microsoft.Storage/storageAccounts"

Write-Host "[TRACE RESULTS] Function executed with parameter binding" -ForegroundColor Green
Write-Host "Found $($resources.Count) resources" -ForegroundColor Gray

Write-Host "`n[SET-PSDEBUG] Script debugging features:" -ForegroundColor Yellow

Write-Host "`n[DEMO] Set-PSDebug options:" -ForegroundColor Cyan
Write-Host "  Set-PSDebug -Trace 1   # Enable line-by-line tracing" -ForegroundColor Gray
Write-Host "  Set-PSDebug -Trace 2   # Enable line and function call tracing" -ForegroundColor Gray
Write-Host "  Set-PSDebug -Step      # Enable step mode (prompt for each line)" -ForegroundColor Gray
Write-Host "  Set-PSDebug -Strict    # Enable strict mode checking" -ForegroundColor Gray
Write-Host "  Set-PSDebug -Off       # Disable all debugging features" -ForegroundColor Gray

# Demonstrate trace levels (briefly)
Write-Host "`n[TRACE LEVEL DEMO] Demonstrating trace output:" -ForegroundColor Cyan

Write-Host "`nEnabling trace level 1 (line tracing):" -ForegroundColor Yellow
Set-PSDebug -Trace 1

# Simple commands to show tracing
$testVar = "Hello"
$testVar2 = "World"
$combined = "$testVar $testVar2"

Write-Host "Disabling trace mode" -ForegroundColor Yellow
Set-PSDebug -Off

Write-Host "`n[DEBUGGING CONTEXT] Using `$PSDebugContext:" -ForegroundColor Yellow

function Show-DebugContext {
    Write-Host "[DEBUG CONTEXT] Checking if debugger is active:" -ForegroundColor Cyan
    
    if ($PSDebugContext) {
        Write-Host "  Debugger is ACTIVE" -ForegroundColor Green
        Write-Host "  Invocation Info: $($PSDebugContext.InvocationInfo)" -ForegroundColor Gray
    } else {
        Write-Host "  Debugger is NOT active" -ForegroundColor Yellow
        Write-Host "  Running in normal execution mode" -ForegroundColor Gray
    }
}

Show-DebugContext

Write-Host "`n[ADVANCED DEBUGGING SUMMARY] Key tools for Azure automation:" -ForegroundColor Yellow
Write-Host "  1. Set-StrictMode: Catch uninitialized variables and bad practices" -ForegroundColor Gray
Write-Host "  2. Trace-Command: Monitor parameter binding and cmdlet execution" -ForegroundColor Gray
Write-Host "  3. Set-PSDebug: Enable line-by-line tracing and step mode" -ForegroundColor Gray
Write-Host "  4. `$PSDebugContext: Detect debugger state for conditional logic" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Remote Debugging..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: REMOTE DEBUGGING AND PRODUCTION TECHNIQUES
# ============================================================================
# EXPLANATION: Debugging Azure automation scripts on remote machines
# - Enter-PSSession: Connect to remote machines for debugging
# - Remote breakpoints: Set breakpoints on remote scripts
# - Production debugging: Safe techniques for live environments
Write-Host "[CONCEPT 6] Remote Debugging and Production Techniques" -ForegroundColor White
Write-Host "Debugging Azure automation scripts on remote machines and in production" -ForegroundColor Gray

Write-Host "`n[REMOTE DEBUGGING] Techniques for distributed Azure automation:" -ForegroundColor Yellow

# Function to simulate remote debugging scenarios
function Test-RemoteDebuggingSetup {
    Write-Host "[REMOTE DEBUG SETUP] Configuring remote debugging environment:" -ForegroundColor Cyan
    
    Write-Host "`n[STEP 1] Enable PowerShell Remoting (run on remote machine):" -ForegroundColor Yellow
    Write-Host "  Enable-PSRemoting -Force" -ForegroundColor Gray
    Write-Host "  Set-WSManQuickConfig -Force" -ForegroundColor Gray
    
    Write-Host "`n[STEP 2] Configure trusted hosts (if needed):" -ForegroundColor Yellow
    Write-Host "  Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'remote-server'" -ForegroundColor Gray
    
    Write-Host "`n[STEP 3] Establish remote session:" -ForegroundColor Yellow
    Write-Host "  `$session = New-PSSession -ComputerName 'remote-server' -Credential `$cred" -ForegroundColor Gray
    Write-Host "  Enter-PSSession -Session `$session" -ForegroundColor Gray
    
    Write-Host "`n[STEP 4] Set remote breakpoints:" -ForegroundColor Yellow
    Write-Host "  Set-PSBreakpoint -Script 'C:\Scripts\AzureScript.ps1' -Line 25" -ForegroundColor Gray
    Write-Host "  Set-PSBreakpoint -Command 'Get-AzVM'" -ForegroundColor Gray
    
    Write-Host "`n[STEP 5] Execute and debug:" -ForegroundColor Yellow
    Write-Host "  & 'C:\Scripts\AzureScript.ps1' -Parameter 'value'" -ForegroundColor Gray
    Write-Host "  # Use debugger commands: s, v, o, c, k, l" -ForegroundColor Gray
}

# Simulate remote debugging workflow
function Invoke-RemoteAzureScript {
    [CmdletBinding()]
    param(
        [string]$ComputerName = "RemoteServer",
        [string]$ScriptPath = "C:\AzureAutomation\DeployResources.ps1",
        [hashtable]$Parameters = @{}
    )
    
    Write-Host "[REMOTE EXECUTION] Simulating remote Azure script execution:" -ForegroundColor Cyan
    Write-Host "  Target: $ComputerName" -ForegroundColor Gray
    Write-Host "  Script: $ScriptPath" -ForegroundColor Gray
    Write-Host "  Parameters: $($Parameters.Count) provided" -ForegroundColor Gray
    
    Write-Host "`n[SIMULATION] Remote session workflow:" -ForegroundColor Yellow
    
    # Simulate connecting to remote machine
    Write-Host "  [CONNECT] Establishing remote session to $ComputerName..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 200
    Write-Host "  [SUCCESS] Remote session established" -ForegroundColor Green
    
    # Simulate setting breakpoints
    Write-Host "  [BREAKPOINT] Setting breakpoints on remote script..." -ForegroundColor Cyan
    Write-Host "    • Line 15: Parameter validation" -ForegroundColor Gray
    Write-Host "    • Line 32: Azure connection" -ForegroundColor Gray
    Write-Host "    • Line 45: Resource deployment" -ForegroundColor Gray
    
    # Simulate script execution with breakpoint hits
    Write-Host "  [EXECUTE] Running remote script with debugging..." -ForegroundColor Cyan
    Write-Host "    [HIT] Breakpoint at line 15 - Parameter validation" -ForegroundColor Yellow
    Write-Host "    [DEBUG] Inspecting parameters: ResourceGroupName, Location, Tags" -ForegroundColor Gray
    Write-Host "    [CONTINUE] Resuming execution..." -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 300
    
    Write-Host "    [HIT] Breakpoint at line 32 - Azure connection" -ForegroundColor Yellow
    Write-Host "    [DEBUG] Checking Azure context and subscription" -ForegroundColor Gray
    Write-Host "    [STEP INTO] Entering Connect-AzAccount function..." -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 300
    
    Write-Host "    [HIT] Breakpoint at line 45 - Resource deployment" -ForegroundColor Yellow
    Write-Host "    [DEBUG] Inspecting deployment template and parameters" -ForegroundColor Gray
    Write-Host "    [CONTINUE] Completing deployment..." -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 200
    
    Write-Host "  [COMPLETE] Remote script execution finished" -ForegroundColor Green
    Write-Host "  [DISCONNECT] Closing remote session" -ForegroundColor Cyan
    
    return [PSCustomObject]@{
        ComputerName = $ComputerName
        ScriptPath = $ScriptPath
        ExecutionTime = "00:02:15"
        BreakpointsHit = 3
        Status = "Success"
        RemoteSession = "Closed"
    }
}

Test-RemoteDebuggingSetup

Write-Host "`n[DEMO] Simulated remote debugging session:" -ForegroundColor Cyan
$remoteResult = Invoke-RemoteAzureScript -ComputerName "AzureVM-001" -ScriptPath "C:\Automation\DeployStorage.ps1" -Parameters @{ResourceGroup="TestRG"; Location="EastUS"}

Write-Host "`n[PRODUCTION DEBUGGING] Safe techniques for live environments:" -ForegroundColor Yellow

function Show-ProductionDebuggingBestPractices {
    Write-Host "[PRODUCTION SAFETY] Guidelines for debugging live Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[LOGGING STRATEGY] Production-safe debugging:" -ForegroundColor Yellow
    Write-Host "  1. Use Write-Verbose and Write-Debug instead of breakpoints" -ForegroundColor Gray
    Write-Host "  2. Implement comprehensive logging to files" -ForegroundColor Gray
    Write-Host "  3. Use try/catch with detailed error logging" -ForegroundColor Gray
    Write-Host "  4. Monitor Azure Activity Log for API call tracing" -ForegroundColor Gray
    
    Write-Host "`n[BREAKPOINT SAFETY] When breakpoints are necessary:" -ForegroundColor Yellow
    Write-Host "  1. Use only in development/staging environments" -ForegroundColor Gray
    Write-Host "  2. Set conditional breakpoints to avoid stopping on every iteration" -ForegroundColor Gray
    Write-Host "  3. Remove all breakpoints before production deployment" -ForegroundColor Gray
    Write-Host "  4. Use variable breakpoints sparingly (performance impact)" -ForegroundColor Gray
    
    Write-Host "`n[MONITORING INTEGRATION] Azure-native debugging tools:" -ForegroundColor Yellow
    Write-Host "  1. Azure Monitor: Track script execution and performance" -ForegroundColor Gray
    Write-Host "  2. Log Analytics: Centralized logging for distributed scripts" -ForegroundColor Gray
    Write-Host "  3. Application Insights: Detailed telemetry and dependency tracking" -ForegroundColor Gray
    Write-Host "  4. Azure Automation: Built-in logging and error tracking" -ForegroundColor Gray
    
    Write-Host "`n[REMOTE DEBUGGING SECURITY] Best practices:" -ForegroundColor Yellow
    Write-Host "  1. Use Windows Authentication when possible" -ForegroundColor Gray
    Write-Host "  2. Limit remote debugging to specific users/groups" -ForegroundColor Gray
    Write-Host "  3. Configure firewall rules for PowerShell remoting ports" -ForegroundColor Gray
    Write-Host "  4. Use Just-In-Time access for debugging sessions" -ForegroundColor Gray
    Write-Host "  5. Monitor and log all remote debugging activities" -ForegroundColor Gray
}

Show-ProductionDebuggingBestPractices

Write-Host "`n[DEBUGGING WORKFLOW] Recommended debugging approach:" -ForegroundColor Yellow

function Show-DebuggingWorkflow {
    Write-Host "[DEBUGGING PROCESS] Systematic approach to Azure automation debugging:" -ForegroundColor Cyan
    
    Write-Host "`n[PHASE 1] Local Development:" -ForegroundColor Yellow
    Write-Host "  1. Use breakpoints liberally during development" -ForegroundColor Gray
    Write-Host "  2. Test with both -Verbose and -Debug parameters" -ForegroundColor Gray
    Write-Host "  3. Enable Set-StrictMode to catch common errors" -ForegroundColor Gray
    Write-Host "  4. Use Trace-Command for parameter binding issues" -ForegroundColor Gray
    
    Write-Host "`n[PHASE 2] Testing Environment:" -ForegroundColor Yellow
    Write-Host "  1. Remove breakpoints, rely on logging" -ForegroundColor Gray
    Write-Host "  2. Test remote execution scenarios" -ForegroundColor Gray
    Write-Host "  3. Validate error handling paths" -ForegroundColor Gray
    Write-Host "  4. Performance testing with monitoring" -ForegroundColor Gray
    
    Write-Host "`n[PHASE 3] Production Deployment:" -ForegroundColor Yellow
    Write-Host "  1. Comprehensive logging enabled" -ForegroundColor Gray
    Write-Host "  2. Azure Monitor integration configured" -ForegroundColor Gray
    Write-Host "  3. Error reporting and alerting in place" -ForegroundColor Gray
    Write-Host "  4. Rollback procedures tested and documented" -ForegroundColor Gray
    
    Write-Host "`n[PHASE 4] Production Issues:" -ForegroundColor Yellow
    Write-Host "  1. Analyze logs and Azure Activity Log first" -ForegroundColor Gray
    Write-Host "  2. Reproduce issues in staging environment" -ForegroundColor Gray
    Write-Host "  3. Use remote debugging only if absolutely necessary" -ForegroundColor Gray
    Write-Host "  4. Implement fixes in development, test, then deploy" -ForegroundColor Gray
}

Show-DebuggingWorkflow

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause6 = Read-Host

# ============================================================================
# WORKSHOP SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[WORKSHOP COMPLETE] PowerShell Debugging - Azure Automation with Advanced Debugging Techniques" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[DEBUGGING CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Debugging Fundamentals: Breakpoint types, management cmdlets, debugging vs error handling" -ForegroundColor Gray
Write-Host "2. Debugger Navigation: Continue, step over, step into, step out actions and shortcuts" -ForegroundColor Gray
Write-Host "3. Call Stack Inspection: Understanding execution flow, tracking parameters, nested calls" -ForegroundColor Gray
Write-Host "4. Debug Output: Strategic use of Write-Debug, Write-Verbose, Write-Host for troubleshooting" -ForegroundColor Gray
Write-Host "5. Advanced Techniques: Strict mode, parameter tracing, script debugging features" -ForegroundColor Gray
Write-Host "6. Remote Debugging: Production-safe techniques, remote sessions, security considerations" -ForegroundColor Gray

Write-Host "`n[AZURE DEBUGGING SCENARIOS COVERED]" -ForegroundColor White
Write-Host "Resource inventory automation, template deployment validation, storage synchronization" -ForegroundColor Gray
Write-Host "Parameter validation, authentication flows, resource group management" -ForegroundColor Gray
Write-Host "Nested function calls, error propagation, retry logic debugging" -ForegroundColor Gray

Write-Host "`n[PRODUCTION-READY DEBUGGING PATTERNS]" -ForegroundColor White
Write-Host "Comprehensive logging strategies for Azure automation environments" -ForegroundColor Gray
Write-Host "Safe remote debugging techniques with security considerations" -ForegroundColor Gray
Write-Host "Integration with Azure Monitor, Log Analytics, and Application Insights" -ForegroundColor Gray
Write-Host "Systematic debugging workflow from development to production" -ForegroundColor Gray

Write-Host "`n[DEBUGGING TECHNIQUES LEARNED]" -ForegroundColor White
Write-Host "Line, command, and variable breakpoint management" -ForegroundColor Gray
Write-Host "Interactive debugger navigation and call stack inspection" -ForegroundColor Gray
Write-Host "Strategic debug output placement and preference management" -ForegroundColor Gray
Write-Host "Advanced tracing with parameter binding and execution flow analysis" -ForegroundColor Gray
Write-Host "Production debugging with minimal service disruption" -ForegroundColor Gray

Write-Host "`n[LIVE DEBUGGING COMMANDS AVAILABLE]" -ForegroundColor White
Write-Host "Try: Get-AzureResourceInventory -ResourceGroupNames @('TestRG') -Verbose -Debug" -ForegroundColor Gray
Write-Host "Try: Sync-AzureStorageData -SourceStorageAccount 'source' -DestinationStorageAccount 'dest' -Debug" -ForegroundColor Gray
Write-Host "Try: Start-AzureResourceDeployment -ResourceGroupName 'TestRG' -TemplateFile 'template.json' -ValidateOnly" -ForegroundColor Gray

Write-Host "`n[BREAKPOINT EXAMPLES]" -ForegroundColor White
Write-Host "Set-PSBreakpoint -Command 'Get-AzResource'  # Break on any Azure resource call" -ForegroundColor Gray
Write-Host "Set-PSBreakpoint -Variable 'resourceGroup' -Mode Read  # Break on variable access" -ForegroundColor Gray
Write-Host "Get-PSBreakpoint | Remove-PSBreakpoint  # Clean up all breakpoints" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These debugging concepts enable you to:" -ForegroundColor Gray
Write-Host "- Efficiently troubleshoot complex Azure automation scripts" -ForegroundColor Gray
Write-Host "- Implement production-safe debugging strategies" -ForegroundColor Gray
Write-Host "- Use advanced PowerShell debugging tools effectively" -ForegroundColor Gray
Write-Host "- Debug remote Azure automation scenarios securely" -ForegroundColor Gray
Write-Host "- Integrate debugging with Azure monitoring and logging services" -ForegroundColor Gray

Write-Host "`nSubscription: $($subscription.Name)" -ForegroundColor Gray
Write-Host "Workshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray