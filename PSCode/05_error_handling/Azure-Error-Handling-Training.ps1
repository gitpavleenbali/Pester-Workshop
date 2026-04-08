# ==============================================================================================
# 05. PowerShell Error Handling: Resilience Training
# Purpose: Demonstrate comprehensive error handling techniques using Azure automation scenarios
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\05_error_handling\Azure-Error-Handling-Training.ps1
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
Write-Host "[INFO] Starting PowerShell Error Handling Workshop..." -ForegroundColor Cyan
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
# CONCEPT 1: STREAMS AND PREFERENCE VARIABLES - Output control and redirection
# ============================================================================
# EXPLANATION: PowerShell has multiple output streams for different types of information
# - Output (1), Error (2), Warning (3), Verbose (4), Debug (5), Information (6)
# - Preference variables control behavior: $ErrorActionPreference, $WarningPreference, etc.
Write-Host "[CONCEPT 1] Streams and Preference Variables" -ForegroundColor White
Write-Host "Output streams, preference variables, and stream redirection" -ForegroundColor Gray

# Function demonstrating all output streams
function Test-AzureStreams {
    [CmdletBinding()]
    param(
        [string]$ResourceGroupName = "TestRG",
        [switch]$DemonstrateStreams
    )
    
    Write-Host "[STREAM DEMO] Demonstrating PowerShell output streams:" -ForegroundColor Yellow
    
    # Stream 1: Output (default stream)
    Write-Output "OUTPUT STREAM: Checking Azure resource group '$ResourceGroupName'"
    
    # Stream 2: Error (controlled demonstration)
    Write-Host "ERROR STREAM DEMO: This is a controlled error message for demonstration" -ForegroundColor Red
    
    # Stream 3: Warning
    Write-Warning "WARNING STREAM: Resource group '$ResourceGroupName' may not exist"
    
    # Stream 4: Verbose (hidden by default)
    Write-Verbose "VERBOSE STREAM: Detailed operation information"
    
    # Stream 5: Debug (hidden by default)
    Write-Debug "DEBUG STREAM: Debug information for troubleshooting"
    
    # Stream 6: Information
    Write-Information "INFORMATION STREAM: Additional context information" -InformationAction Continue
    
    # Demonstrate actual Write-Error when needed (optional - shows red error text)
    if ($DemonstrateStreams) {
        Write-Host "[ACTUAL ERROR DEMO] The next line will show red error text for educational purposes:" -ForegroundColor Yellow
        Write-Host "This demonstrates the Write-Error stream (Stream 2):" -ForegroundColor Gray
        Write-Error "EDUCATIONAL: This is Write-Error demonstration for Stream 2" -ErrorAction Continue
        Write-Host "Note: Write-Error displays in red and goes to the error stream" -ForegroundColor Gray
    }
    
    # Return an object to output stream
    return [PSCustomObject]@{
        StreamTest = "Completed"
        ResourceGroup = $ResourceGroupName
        Timestamp = Get-Date
    }
}

Write-Host "[DEMO] Testing streams with default preferences:" -ForegroundColor Cyan
Write-Host "Note: The following demonstrates controlled error messages for educational purposes" -ForegroundColor Yellow
$result1 = Test-AzureStreams -ResourceGroupName "Demo-RG"

Write-Host "`n[DEMO] Testing streams with verbose and debug enabled:" -ForegroundColor Cyan
Write-Host "Note: You'll see additional verbose and debug streams below" -ForegroundColor Yellow
$result2 = Test-AzureStreams -ResourceGroupName "Demo-RG" -Verbose -Debug

Write-Host "`n[INFO] Write-Error stream demo available (optional):" -ForegroundColor Cyan
Write-Host "  To see Write-Error stream demonstration (shows red text), use:" -ForegroundColor Gray
Write-Host "  Test-AzureStreams -ResourceGroupName 'Demo-RG' -DemonstrateStreams" -ForegroundColor Gray

# Demonstrate preference variables
Write-Host "`n[PREFERENCE DEMO] Current preference variables:" -ForegroundColor Yellow
Write-Host "  ErrorActionPreference: $ErrorActionPreference" -ForegroundColor Gray
Write-Host "  WarningPreference: $WarningPreference" -ForegroundColor Gray
Write-Host "  VerbosePreference: $VerbosePreference" -ForegroundColor Gray
Write-Host "  DebugPreference: $DebugPreference" -ForegroundColor Gray
Write-Host "  InformationPreference: $InformationPreference" -ForegroundColor Gray

# Demonstrate changing preferences
Write-Host "`n[PREFERENCE CHANGE] Temporarily changing warning preference:" -ForegroundColor Cyan
Write-Host "This demonstrates how preference variables control output visibility:" -ForegroundColor Yellow
$originalWarningPreference = $WarningPreference
$WarningPreference = "SilentlyContinue"
Write-Warning "This warning should be hidden (SilentlyContinue)"
Write-Host "↑ No warning appeared because WarningPreference = SilentlyContinue" -ForegroundColor Gray
$WarningPreference = $originalWarningPreference
Write-Warning "This warning should be visible (Continue)"
Write-Host "↑ Warning appeared because WarningPreference = Continue" -ForegroundColor Gray

# Demonstrate stream redirection
Write-Host "`n[REDIRECTION DEMO] Redirecting error stream to output:" -ForegroundColor Cyan
Write-Host "Without redirection:" -ForegroundColor Gray
Write-Host "ERROR EXAMPLE: This would be an error message" -ForegroundColor Red

Write-Host "With redirection (2>&1) - capturing Write-Error output:" -ForegroundColor Gray
$redirectedOutput = Write-Error "This error is redirected to output stream" 2>&1
Write-Host "Captured error content: $($redirectedOutput.Exception.Message)" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Non-Terminating Errors..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: NON-TERMINATING ERROR HANDLING - Graceful error management
# ============================================================================
# EXPLANATION: Non-terminating errors display error messages but continue execution
# - Use -ErrorAction to control behavior, -ErrorVariable to capture errors
# - Check $?, $Error, and $LastExitCode for error status
Write-Host "[CONCEPT 2] Non-Terminating Error Handling" -ForegroundColor White
Write-Host "Handling errors that don't stop execution" -ForegroundColor Gray

# Function demonstrating non-terminating error handling
function Get-AzureResourcesWithErrorHandling {
    [CmdletBinding()]
    param(
        [string[]]$ResourceGroupNames,
        [string]$LogPath = "$env:TEMP\azure-errors.log"
    )
    
    Write-Host "[ERROR HANDLING DEMO] Processing resource groups with error handling" -ForegroundColor Yellow
    
    $allResources = @()
    $errorCount = 0
    
    foreach ($rgName in $ResourceGroupNames) {
        Write-Host "[PROCESSING] Resource Group: $rgName" -ForegroundColor Cyan
        
        # Clear previous errors for this iteration
        $Error.Clear()
        
        # Attempt to get resources with error suppression and capture
        $resources = Get-AzResource -ResourceGroupName $rgName -ErrorAction SilentlyContinue -ErrorVariable rgErrors
        
        # Check if the command succeeded using $?
        if ($?) {
            Write-Host "[SUCCESS] Found $($resources.Count) resources in '$rgName'" -ForegroundColor Green
            $allResources += $resources
        } else {
            $errorCount++
            Write-Host "[ERROR] Failed to access resource group '$rgName'" -ForegroundColor Red
            
            # Log error details using captured error variable
            if ($rgErrors.Count -gt 0) {
                $errorMessage = "$(Get-Date): Failed to access RG '$rgName' - $($rgErrors[0].Exception.Message)"
                Write-Host "[LOGGING] $errorMessage" -ForegroundColor Yellow
                Add-Content -Path $LogPath -Value $errorMessage
            }
            
            # Also check $Error automatic variable for additional context
            if ($Error.Count -gt 0) {
                $lastError = $Error[0]
                Write-Host "[ERROR DETAILS] Exception Type: $($lastError.Exception.GetType().Name)" -ForegroundColor Gray
                Write-Host "[ERROR DETAILS] Category: $($lastError.CategoryInfo.Category)" -ForegroundColor Gray
            }
        }
    }
    
    # Return summary results
    return [PSCustomObject]@{
        TotalResourceGroups = $ResourceGroupNames.Count
        SuccessfulQueries = $ResourceGroupNames.Count - $errorCount
        ErrorCount = $errorCount
        TotalResources = $allResources.Count
        Resources = $allResources
        LogFile = $LogPath
    }
}

# Demonstrate non-terminating error handling
Write-Host "[DEMO] Testing with mix of valid and invalid resource groups:" -ForegroundColor Cyan
Write-Host "Note: The following intentionally tries invalid resource groups to demonstrate error handling" -ForegroundColor Yellow
Write-Host "Expected: You'll see controlled error messages for non-existent resource groups" -ForegroundColor Gray

# Get some real resource groups and add some invalid ones
$realRGs = (Get-AzResourceGroup | Select-Object -First 2).ResourceGroupName
$testRGs = $realRGs + @("NonExistent-RG-1", "Invalid-RG-2")

$results = Get-AzureResourcesWithErrorHandling -ResourceGroupNames $testRGs

Write-Host "[RESULTS] Processing Summary:" -ForegroundColor Yellow
Write-Host "  Total RGs Processed: $($results.TotalResourceGroups)" -ForegroundColor Gray
Write-Host "  Successful Queries: $($results.SuccessfulQueries)" -ForegroundColor Gray
Write-Host "  Errors Encountered: $($results.ErrorCount)" -ForegroundColor Gray
Write-Host "  Total Resources Found: $($results.TotalResources)" -ForegroundColor Gray

# Demonstrate $LastExitCode with external commands
Write-Host "`n[EXTERNAL COMMAND DEMO] Using az CLI with error handling:" -ForegroundColor Cyan
try {
    # Try to run az command (may not be installed)
    $azOutput = az version 2>$null
    Write-Host "[AZ CLI] Exit code: $LastExitCode" -ForegroundColor Gray
    if ($LastExitCode -eq 0) {
        Write-Host "[AZ CLI] Command succeeded" -ForegroundColor Green
    } else {
        Write-Host "[AZ CLI] Command failed with exit code: $LastExitCode" -ForegroundColor Red
    }
} catch {
    Write-Host "[AZ CLI] Azure CLI not available or accessible" -ForegroundColor Yellow
}

Write-Host "`n[PAUSE] Press Enter to continue to Terminating Errors..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: TERMINATING ERROR HANDLING - Stopping execution and recovery
# ============================================================================
# EXPLANATION: Terminating errors stop execution unless handled
# - Use throw to generate terminating errors
# - Handle with try/catch/finally or trap statements
Write-Host "[CONCEPT 3] Terminating Error Handling" -ForegroundColor White
Write-Host "Handling errors that stop execution with try/catch/finally" -ForegroundColor Gray

# Function demonstrating terminating error scenarios
function Deploy-AzureResourceWithValidation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory)]
        [string]$Location,
        
        [Parameter(Mandatory)]
        [string]$StorageAccountName,
        
        [string]$LogPath = "$env:TEMP\deployment.log"
    )
    
    Write-Host "[DEPLOYMENT DEMO] Starting Azure resource deployment with validation" -ForegroundColor Yellow
    
    try {
        Write-Host "[VALIDATION] Checking parameters..." -ForegroundColor Cyan
        
        # Validate storage account name (this could throw)
        if ($StorageAccountName.Length -lt 3 -or $StorageAccountName.Length -gt 24) {
            throw "Storage account name must be between 3 and 24 characters"
        }
        
        if ($StorageAccountName -notmatch '^[a-z0-9]+$') {
            throw "Storage account name can only contain lowercase letters and numbers"
        }
        
        Write-Host "[VALIDATION] Parameters are valid" -ForegroundColor Green
        
        # Check if resource group exists (convert non-terminating to terminating)
        Write-Host "[CHECKING] Resource group existence..." -ForegroundColor Cyan
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
        Write-Host "[SUCCESS] Resource group '$ResourceGroupName' exists" -ForegroundColor Green
        
        # Check if storage account already exists
        Write-Host "[CHECKING] Storage account availability..." -ForegroundColor Cyan
        $existingStorage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
        
        if ($existingStorage) {
            throw "Storage account '$StorageAccountName' already exists in resource group '$ResourceGroupName'"
        }
        
        Write-Host "[SUCCESS] Storage account name is available" -ForegroundColor Green
        
        # Simulate deployment (in real scenario, this would create the storage account)
        Write-Host "[DEPLOYING] Creating storage account..." -ForegroundColor Cyan
        Start-Sleep -Milliseconds 500  # Simulate deployment time
        
        # Simulate potential deployment failure
        $randomFailure = Get-Random -Minimum 1 -Maximum 10
        if ($randomFailure -le 2) {  # 20% chance of failure
            throw "Deployment failed due to Azure service unavailability"
        }
        
        Write-Host "[SUCCESS] Storage account deployment completed" -ForegroundColor Green
        
        # Log successful deployment
        $successMessage = "$(Get-Date): Successfully deployed storage account '$StorageAccountName' in '$ResourceGroupName'"
        Add-Content -Path $LogPath -Value $successMessage
        
        return [PSCustomObject]@{
            Status = "Success"
            ResourceGroup = $ResourceGroupName
            StorageAccount = $StorageAccountName
            Location = $Location
            DeployedAt = Get-Date
        }
        
        } catch {
        # Check if it's a resource not found exception
        if ($_.Exception.Message -like "*could not be found*" -or $_.Exception.Message -like "*does not exist*") {
            $errorMessage = "Resource group '$ResourceGroupName' does not exist"
            Write-Host "[SPECIFIC ERROR] $errorMessage" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): ERROR - $errorMessage"
            
            throw "Deployment failed: $errorMessage"
        } elseif ($_.Exception.GetType().Name -eq "ArgumentException") {
            # Handle parameter validation errors
            $errorMessage = "Invalid parameter: $($_.Exception.Message)"
            Write-Host "[PARAMETER ERROR] $errorMessage" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): PARAMETER ERROR - $errorMessage"
            
            throw "Deployment failed: $errorMessage"
        } else {
            # Handle all other exceptions
            $errorMessage = "Unexpected error: $($_.Exception.Message)"
            Write-Host "[GENERAL ERROR] $errorMessage" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): GENERAL ERROR - $errorMessage"
            
            # Re-throw to maintain error flow
            throw "Deployment failed: $errorMessage"
        }
        
    } finally {
        # Cleanup code that always runs
        Write-Host "[CLEANUP] Performing cleanup operations..." -ForegroundColor Yellow
        
        # In real scenario, this might clean up temporary files, close connections, etc.
        $cleanupMessage = "$(Get-Date): Cleanup completed for deployment attempt"
        Add-Content -Path $LogPath -Value $cleanupMessage
        
        Write-Host "[CLEANUP] Cleanup completed" -ForegroundColor Green
    }
}

# Demonstrate try/catch/finally with various scenarios
Write-Host "[DEMO] Testing deployment with valid parameters:" -ForegroundColor Cyan
try {
    $realRG = (Get-AzResourceGroup | Select-Object -First 1).ResourceGroupName
    $result1 = Deploy-AzureResourceWithValidation -ResourceGroupName $realRG -Location "eastus" -StorageAccountName "teststore$(Get-Random -Min 100 -Max 999)"
    Write-Host "[DEMO RESULT] $($result1.Status): Storage account ready" -ForegroundColor Green
} catch {
    Write-Host "[DEMO ERROR] Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "[DEMO] Testing deployment with invalid resource group:" -ForegroundColor Cyan
Write-Host "Expected: This will demonstrate terminating error handling with a non-existent resource group" -ForegroundColor Yellow
try {
    $result2 = Deploy-AzureResourceWithValidation -ResourceGroupName "NonExistent-RG" -Location "westus" -StorageAccountName "validname123"
    Write-Host "[DEMO RESULT] Unexpected success" -ForegroundColor Yellow
} catch {
    Write-Host "[DEMO ERROR] Expected failure: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "↑ This error was expected and demonstrates proper try/catch error handling" -ForegroundColor Gray
}

Write-Host "`n[DEMO] Testing deployment with invalid storage account name:" -ForegroundColor Cyan
Write-Host "Expected: This will demonstrate validation error handling" -ForegroundColor Yellow
try {
    $result3 = Deploy-AzureResourceWithValidation -ResourceGroupName $realRG -Location "centralus" -StorageAccountName "Invalid-Name!"
    Write-Host "[DEMO RESULT] Unexpected success" -ForegroundColor Yellow
} catch {
    Write-Host "[DEMO ERROR] Expected validation failure: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "↑ This validation error was expected and demonstrates input validation" -ForegroundColor Gray
}

Write-Host "`n[PAUSE] Press Enter to continue to Exception Types..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: EXCEPTION TYPES - Understanding and handling specific exceptions
# ============================================================================
# EXPLANATION: Different exceptions require different handling strategies
# - Inspect exception types using $Error[0].Exception.GetType()
# - Handle specific exception types with targeted catch blocks
Write-Host "[CONCEPT 4] Exception Types and Specific Handling" -ForegroundColor White
Write-Host "Identifying and handling different exception types" -ForegroundColor Gray

# Function demonstrating exception type handling
function Test-AzureOperationsWithExceptionTypes {
    [CmdletBinding()]
    param(
        [string]$TestScenario = "All"
    )
    
    Write-Host "[EXCEPTION DEMO] Testing different Azure exception scenarios" -ForegroundColor Yellow
Write-Host "Note: The following tests will intentionally generate different exception types for educational purposes" -ForegroundColor Gray
Write-Host "Expected: You'll see various exception types being caught and handled properly" -ForegroundColor Yellow
    
    $results = @()
    
    # Test 1: Resource Not Found Exception
    if ($TestScenario -eq "All" -or $TestScenario -eq "NotFound") {
        Write-Host "[TEST 1] Resource Not Found Exception:" -ForegroundColor Cyan
        try {
            $nonExistentRG = Get-AzResourceGroup -Name "Absolutely-Does-Not-Exist-RG" -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -like "*could not be found*" -or $_.Exception.Message -like "*does not exist*") {
                Write-Host "  [CAUGHT] ResourceNotFound: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Host "  ↑ This exception was expected - demonstrating resource not found handling" -ForegroundColor Gray
                $results += [PSCustomObject]@{
                    Test = "Resource Not Found"
                    ExceptionType = $_.Exception.GetType().Name
                    Message = $_.Exception.Message
                    Handled = $true
                }
            } else {
                Write-Host "  [UNEXPECTED] $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "  ↑ This was an unexpected exception type" -ForegroundColor Gray
            }
        }
    }
    
    # Test 2: Argument Exception
    if ($TestScenario -eq "All" -or $TestScenario -eq "Argument") {
        Write-Host "[TEST 2] Argument Exception:" -ForegroundColor Cyan
        try {
            # This should cause an argument exception
            $invalidParam = Get-AzVM -ResourceGroupName "" -Name "TestVM" -ErrorAction Stop
        } catch [System.ArgumentException] {
            Write-Host "  [CAUGHT] ArgumentException: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "  ↑ This exception was expected - demonstrating argument validation" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Invalid Argument"
                ExceptionType = $_.Exception.GetType().Name
                Message = $_.Exception.Message
                Handled = $true
            }
        } catch {
            Write-Host "  [DIFFERENT EXCEPTION] $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor DarkYellow
            Write-Host "  ↑ Different exception type than expected, but still handled" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Invalid Argument"
                ExceptionType = $_.Exception.GetType().Name
                Message = $_.Exception.Message
                Handled = $false
            }
        }
    }
    
    # Test 3: Network/Connectivity Exception
    if ($TestScenario -eq "All" -or $TestScenario -eq "Network") {
        Write-Host "[TEST 3] Network Exception Simulation:" -ForegroundColor Cyan
        try {
            # Simulate network timeout by accessing invalid endpoint
            $invalidRequest = Invoke-RestMethod -Uri "https://nonexistent-azure-endpoint.invalid" -TimeoutSec 1 -ErrorAction Stop
        } catch [System.Net.WebException] {
            Write-Host "  [CAUGHT] WebException: Network connectivity issue" -ForegroundColor Yellow
            Write-Host "  ↑ This network exception was expected for demonstration" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Network Connectivity"
                ExceptionType = $_.Exception.GetType().Name
                Message = "Network connectivity issue"
                Handled = $true
            }
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            Write-Host "  [CAUGHT] HttpResponseException: HTTP request failed" -ForegroundColor Yellow
            Write-Host "  ↑ This HTTP exception was expected for demonstration" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Network Connectivity"
                ExceptionType = $_.Exception.GetType().Name
                Message = "HTTP request failed"
                Handled = $true
            }
        } catch {
            Write-Host "  [OTHER NETWORK ERROR] $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor DarkYellow
            Write-Host "  ↑ Different network exception type, but handled appropriately" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Network Connectivity"
                ExceptionType = $_.Exception.GetType().Name
                Message = $_.Exception.Message
                Handled = $false
            }
        }
    }
    
    # Test 4: Custom Exception with Throw
    if ($TestScenario -eq "All" -or $TestScenario -eq "Custom") {
        Write-Host "[TEST 4] Custom Exception:" -ForegroundColor Cyan
        try {
            # Simulate a business logic validation failure
            $subscriptionLimit = 10
            $currentResourceCount = 15
            
            if ($currentResourceCount -gt $subscriptionLimit) {
                throw [System.InvalidOperationException]::new("Subscription limit exceeded: $currentResourceCount resources (limit: $subscriptionLimit)")
            }
        } catch [System.InvalidOperationException] {
            Write-Host "  [CAUGHT] InvalidOperationException: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "  ↑ This business logic exception was expected for demonstration" -ForegroundColor Gray
            $results += [PSCustomObject]@{
                Test = "Business Logic Validation"
                ExceptionType = $_.Exception.GetType().Name
                Message = $_.Exception.Message
                Handled = $true
            }
        } catch {
            Write-Host "  [UNEXPECTED] $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  ↑ This was an unexpected exception type" -ForegroundColor Gray
        }
    }
    
    # Test 5: Inspect Error Object Properties
    Write-Host "[TEST 5] Error Object Inspection:" -ForegroundColor Cyan
    Write-Host "This will generate a controlled error to inspect its properties:" -ForegroundColor Yellow
    try {
        # Generate a known error
        $badStorageAccount = Get-AzStorageAccount -ResourceGroupName "FakeRG" -Name "FakeStorage" -ErrorAction Stop
    } catch {
        Write-Host "  [ERROR DETAILS] Exception inspection (this error was intentional):" -ForegroundColor Yellow
        Write-Host "    Full Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Gray
        Write-Host "    Exception Message: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host "    Category: $($_.CategoryInfo.Category)" -ForegroundColor Gray
        Write-Host "    Activity: $($_.CategoryInfo.Activity)" -ForegroundColor Gray
        Write-Host "    Target Object: $($_.TargetObject)" -ForegroundColor Gray
        
        if ($_.Exception.InnerException) {
            Write-Host "    Inner Exception: $($_.Exception.InnerException.GetType().Name)" -ForegroundColor Gray
        }
        
        $results += [PSCustomObject]@{
            Test = "Error Object Inspection"
            ExceptionType = $_.Exception.GetType().Name
            Message = $_.Exception.Message
            Handled = $true
        }
    }
    
    return $results
}

# Demonstrate exception type handling
$exceptionResults = Test-AzureOperationsWithExceptionTypes
Write-Host "[EXCEPTION RESULTS] Summary of exception handling tests:" -ForegroundColor Yellow
$exceptionResults | Format-Table -AutoSize

Write-Host "`n[PAUSE] Press Enter to continue to Error Handling Patterns..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: ERROR HANDLING PATTERNS - Trap vs Try/Catch and best practices
# ============================================================================
# EXPLANATION: Different error handling patterns for different scenarios
# - Trap: Script-wide error handling, good for generic error management
# - Try/Catch: Block-specific error handling, good for targeted scenarios
Write-Host "[CONCEPT 5] Error Handling Patterns" -ForegroundColor White
Write-Host "Comparing trap vs try/catch patterns and best practices" -ForegroundColor Gray

# Demonstrate Trap-based error handling
Write-Host "[TRAP DEMO] Script-wide error handling with trap:" -ForegroundColor Cyan
Write-Host "Note: The following will demonstrate trap-based error handling" -ForegroundColor Yellow
Write-Host "Expected: You'll see trap intercepting errors and allowing continued execution" -ForegroundColor Gray

# Set up trap for demonstration (will handle all terminating errors in this scope)
trap {
    Write-Host "[TRAP CAUGHT] Terminating error intercepted by trap:" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Command: $($_.InvocationInfo.MyCommand.Name)" -ForegroundColor Red
    
    # Log the error
    $trapError = "$(Get-Date): TRAP - $($_.Exception.Message)"
    Add-Content -Path "$env:TEMP\trap-errors.log" -Value $trapError
    
    Write-Host "  [TRAP] Continuing execution after error handling..." -ForegroundColor Yellow
    # Continue execution (instead of stopping)
    Continue
}

# Function that will trigger trap
function Test-TrapErrorHandling {
    Write-Host "[TRAP TEST] Testing trap-based error handling" -ForegroundColor Yellow
    
    Write-Host "  [STEP 1] Normal operation" -ForegroundColor Green
    $normalResult = Get-Date
    
    Write-Host "  [STEP 2] This will trigger a trap" -ForegroundColor Yellow
    # Force a terminating error
    Get-AzResourceGroup -Name "NonExistent-RG-For-Trap-Test" -ErrorAction Stop
    
    Write-Host "  [STEP 3] This runs after trap (if Continue is used)" -ForegroundColor Green
    
    return "Trap test completed"
}

$trapResult = Test-TrapErrorHandling

# Now demonstrate Try/Catch pattern for comparison
Write-Host "`n[TRY/CATCH DEMO] Block-specific error handling:" -ForegroundColor Cyan

function Deploy-MultipleAzureResources {
    [CmdletBinding()]
    param(
        [string]$ResourceGroupName,
        [string[]]$ResourceNames,
        [string]$LogPath = "$env:TEMP\deployment-pattern.log"
    )
    
    Write-Host "[PATTERN DEMO] Deploying multiple resources with structured error handling" -ForegroundColor Yellow
    
    $deploymentResults = @()
    $totalErrors = 0
    
    # Resource group validation with specific error handling
    try {
        Write-Host "[VALIDATION] Checking resource group..." -ForegroundColor Cyan
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
        Write-Host "[SUCCESS] Resource group validated" -ForegroundColor Green
    } catch {
        $errorMsg = "Resource group validation failed: $($_.Exception.Message)"
        Write-Host "[CRITICAL ERROR] $errorMsg" -ForegroundColor Red
        Add-Content -Path $LogPath -Value "$(Get-Date): CRITICAL - $errorMsg"
        
        # Return early - can't proceed without valid RG
        return [PSCustomObject]@{
            Status = "Failed"
            Reason = "Resource group validation failed"
            DeployedResources = @()
            TotalErrors = 1
        }
    }
    
    # Deploy each resource with individual error handling
    foreach ($resourceName in $ResourceNames) {
        try {
            Write-Host "[DEPLOYING] Resource: $resourceName" -ForegroundColor Cyan
            
            # Simulate resource deployment
            $deploymentSuccess = $true
            
            # Validation: Check name format
            if ($resourceName -notmatch '^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$') {
                throw [System.ArgumentException]::new("Invalid resource name format: $resourceName")
            }
            
            # Simulation: Random deployment failures
            $randomOutcome = Get-Random -Minimum 1 -Maximum 10
            if ($randomOutcome -le 1) {  # 10% failure rate
                throw [System.InvalidOperationException]::new("Azure service temporarily unavailable for resource: $resourceName")
            }
            
            # Simulate deployment time
            Start-Sleep -Milliseconds 200
            
            Write-Host "[SUCCESS] Resource '$resourceName' deployed" -ForegroundColor Green
            
            $deploymentResults += [PSCustomObject]@{
                ResourceName = $resourceName
                Status = "Success"
                DeployedAt = Get-Date
                Error = $null
            }
            
        } catch [System.ArgumentException] {
            # Handle validation errors
            $totalErrors++
            $errorMsg = "Validation error for '$resourceName': $($_.Exception.Message)"
            Write-Host "[VALIDATION ERROR] $errorMsg" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): VALIDATION - $errorMsg"
            
            $deploymentResults += [PSCustomObject]@{
                ResourceName = $resourceName
                Status = "Failed"
                DeployedAt = $null
                Error = "Validation Error"
            }
            
        } catch [System.InvalidOperationException] {
            # Handle service availability errors
            $totalErrors++
            $errorMsg = "Service error for '$resourceName': $($_.Exception.Message)"
            Write-Host "[SERVICE ERROR] $errorMsg" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): SERVICE - $errorMsg"
            
            $deploymentResults += [PSCustomObject]@{
                ResourceName = $resourceName
                Status = "Failed"
                DeployedAt = $null
                Error = "Service Unavailable"
            }
            
        } catch {
            # Handle unexpected errors
            $totalErrors++
            $errorMsg = "Unexpected error for '$resourceName': $($_.Exception.Message)"
            Write-Host "[UNEXPECTED ERROR] $errorMsg" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "$(Get-Date): UNEXPECTED - $errorMsg"
            
            $deploymentResults += [PSCustomObject]@{
                ResourceName = $resourceName
                Status = "Failed"
                DeployedAt = $null
                Error = "Unexpected Error"
            }
        } finally {
            # Cleanup for each resource deployment attempt
            Write-Host "[CLEANUP] Cleaning up deployment context for '$resourceName'" -ForegroundColor Yellow
        }
    }
    
    # Return comprehensive results
    $successCount = ($deploymentResults | Where-Object { $_.Status -eq "Success" }).Count
    
    return [PSCustomObject]@{
        Status = if ($totalErrors -eq 0) { "Success" } elseif ($successCount -gt 0) { "Partial Success" } else { "Failed" }
        ResourceGroup = $ResourceGroupName
        TotalResources = $ResourceNames.Count
        SuccessfulDeployments = $successCount
        FailedDeployments = $totalErrors
        Results = $deploymentResults
        LogFile = $LogPath
    }
}

# Test pattern with multiple resources
$testResourceNames = @("WebApp-001", "Invalid-Name!", "StorageAcct-002", "Database-003", "API-Gateway-004")
$patternResults = Deploy-MultipleAzureResources -ResourceGroupName $realRG -ResourceNames $testResourceNames

Write-Host "[PATTERN RESULTS] Deployment Summary:" -ForegroundColor Yellow
Write-Host "  Status: $($patternResults.Status)" -ForegroundColor Gray
Write-Host "  Successful: $($patternResults.SuccessfulDeployments)" -ForegroundColor Gray
Write-Host "  Failed: $($patternResults.FailedDeployments)" -ForegroundColor Gray

Write-Host "`n[DETAILED RESULTS] Individual resource status:" -ForegroundColor Cyan
$patternResults.Results | Format-Table -AutoSize

Write-Host "`n[PAUSE] Press Enter to continue to Best Practices..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: ERROR HANDLING BEST PRACTICES - Production-ready patterns
# ============================================================================
# EXPLANATION: Enterprise-grade error handling strategies
# - Retry logic with exponential backoff for transient failures
# - Comprehensive logging and monitoring
# - Circuit breaker patterns and resource cleanup
Write-Host "[CONCEPT 6] Error Handling Best Practices" -ForegroundColor White
Write-Host "Production-ready error handling with retry logic and monitoring" -ForegroundColor Gray

# Advanced error handling class with retry logic
class AzureOperationManager {
    [string] $OperationName
    [int] $MaxRetries
    [int] $InitialDelayMs
    [string] $LogPath
    [hashtable] $Metrics
    
    AzureOperationManager([string] $OperationName, [int] $MaxRetries, [int] $InitialDelayMs, [string] $LogPath) {
        $this.OperationName = $OperationName
        $this.MaxRetries = $MaxRetries
        $this.InitialDelayMs = $InitialDelayMs
        $this.LogPath = $LogPath
        $this.Metrics = @{
            TotalAttempts = 0
            SuccessCount = 0
            RetryCount = 0
            LastExecutionTime = $null
        }
    }
    
    # Execute operation with retry logic and exponential backoff
    [PSCustomObject] ExecuteWithRetry([scriptblock] $Operation, [scriptblock] $ValidationCheck) {
        $attempt = 0
        $delay = $this.InitialDelayMs
        $lastException = $null
        
        do {
            $attempt++
            $this.Metrics.TotalAttempts++
            
            try {
                $this.LogInfo("Attempt $attempt of $($this.MaxRetries + 1) for operation: $($this.OperationName)")
                
                # Execute the operation
                $startTime = Get-Date
                $result = & $Operation
                $executionTime = (Get-Date) - $startTime
                
                # Validate the result if validation check is provided
                if ($ValidationCheck) {
                    $isValid = & $ValidationCheck $result
                    if (-not $isValid) {
                        throw [System.InvalidOperationException]::new("Operation result validation failed")
                    }
                }
                
                # Success
                $this.Metrics.SuccessCount++
                $this.Metrics.LastExecutionTime = $executionTime.TotalMilliseconds
                $this.LogInfo("Operation '$($this.OperationName)' succeeded on attempt $attempt (${executionTime}ms)")
                
                return [PSCustomObject]@{
                    Status = "Success"
                    Result = $result
                    Attempts = $attempt
                    ExecutionTime = $executionTime
                    TotalRetries = $attempt - 1
                }
                
            } catch {
                $lastException = $_
                $this.LogError("Attempt $attempt failed: $($_.Exception.Message)")
                
                if ($attempt -le $this.MaxRetries) {
                    $this.Metrics.RetryCount++
                    $this.LogInfo("Retrying in ${delay}ms...")
                    Start-Sleep -Milliseconds $delay
                    
                    # Exponential backoff with jitter
                    $delay = $delay * 2 + (Get-Random -Minimum 100 -Maximum 500)
                } else {
                    $this.LogError("All retry attempts exhausted for operation: $($this.OperationName)")
                }
            }
        } while ($attempt -le $this.MaxRetries)
        
        # All attempts failed
        return [PSCustomObject]@{
            Status = "Failed"
            Result = $null
            Attempts = $attempt
            ExecutionTime = $null
            TotalRetries = $this.MaxRetries
            LastError = $lastException.Exception.Message
        }
    }
    
    # Check if operation should be retried based on exception type
    [bool] IsRetryableException([System.Exception] $Exception) {
        $retryableTypes = @(
            "System.Net.WebException",
            "Microsoft.Azure.Commands.Common.Exceptions.AzPSCloudException",
            "System.TimeoutException"
        )
        
        return $retryableTypes -contains $Exception.GetType().FullName
    }
    
    # Logging methods
    [void] LogInfo([string] $Message) {
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [INFO] $Message"
        Write-Host "[INFO] $Message" -ForegroundColor Green
        Add-Content -Path $this.LogPath -Value $logEntry
    }
    
    [void] LogError([string] $Message) {
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [ERROR] $Message"
        Write-Host "[ERROR] $Message" -ForegroundColor Red
        Add-Content -Path $this.LogPath -Value $logEntry
    }
    
    # Get operation metrics
    [hashtable] GetMetrics() {
        return $this.Metrics
    }
}

# Demonstrate best practices with retry logic
Write-Host "[BEST PRACTICES DEMO] Azure Storage Account Creation with Retry Logic:" -ForegroundColor Cyan

$opManager = [AzureOperationManager]::new("CreateStorageAccount", 3, 1000, "$env:TEMP\azure-best-practices.log")

# Define operation that might fail
$createStorageOperation = {
    $storageAccountName = "teststore$(Get-Random -Min 1000 -Max 9999)"
    
    # Simulate transient failures
    $random = Get-Random -Minimum 1 -Maximum 10
    if ($random -le 3) {  # 30% failure rate for demo
        throw [System.Net.WebException]::new("Simulated transient network error")
    }
    
    # Simulate successful operation
    Write-Host "  [OPERATION] Creating storage account: $storageAccountName" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 500
    
    return [PSCustomObject]@{
        StorageAccountName = $storageAccountName
        ResourceGroup = $realRG
        Status = "Created"
        CreatedAt = Get-Date
    }
}

# Define validation check
$validateStorageResult = {
    param($result)
    return $result -and $result.StorageAccountName -and $result.Status -eq "Created"
}

# Execute with retry logic
$retryResult = $opManager.ExecuteWithRetry($createStorageOperation, $validateStorageResult)

Write-Host "[RETRY RESULTS] Operation outcome:" -ForegroundColor Yellow
Write-Host "  Status: $($retryResult.Status)" -ForegroundColor Gray
Write-Host "  Total Attempts: $($retryResult.Attempts)" -ForegroundColor Gray
Write-Host "  Retries Used: $($retryResult.TotalRetries)" -ForegroundColor Gray

if ($retryResult.Status -eq "Success") {
    Write-Host "  Storage Account: $($retryResult.Result.StorageAccountName)" -ForegroundColor Gray
    Write-Host "  Execution Time: $($retryResult.ExecutionTime.TotalMilliseconds)ms" -ForegroundColor Gray
} else {
    Write-Host "  Last Error: $($retryResult.LastError)" -ForegroundColor Red
}

# Show operation metrics
$metrics = $opManager.GetMetrics()
Write-Host "[METRICS] Operation statistics:" -ForegroundColor Cyan
Write-Host "  Total Attempts: $($metrics.TotalAttempts)" -ForegroundColor Gray
Write-Host "  Success Count: $($metrics.SuccessCount)" -ForegroundColor Gray
Write-Host "  Retry Count: $($metrics.RetryCount)" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause6 = Read-Host

# ============================================================================
# WORKSHOP SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[WORKSHOP COMPLETE] PowerShell Error Handling - Azure Automation with Robust Error Management" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[ERROR HANDLING CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Streams and Preferences: Output streams, preference variables, stream redirection" -ForegroundColor Gray
Write-Host "2. Non-Terminating Errors: -ErrorAction, -ErrorVariable, `$?, `$Error, `$LastExitCode" -ForegroundColor Gray
Write-Host "3. Terminating Errors: try/catch/finally blocks, throw statements, error recovery" -ForegroundColor Gray
Write-Host "4. Exception Types: Specific exception handling, error object inspection" -ForegroundColor Gray
Write-Host "5. Error Patterns: Trap vs try/catch, script-wide vs block-specific handling" -ForegroundColor Gray
Write-Host "6. Best Practices: Retry logic, exponential backoff, comprehensive logging" -ForegroundColor Gray

Write-Host "`n[AZURE SCENARIOS COVERED]" -ForegroundColor White
Write-Host "Resource group validation, storage account creation, deployment automation" -ForegroundColor Gray
Write-Host "Network connectivity issues, service availability checks" -ForegroundColor Gray
Write-Host "Multi-resource deployments, validation failures, cleanup operations" -ForegroundColor Gray

Write-Host "`n[PRODUCTION-READY PATTERNS DEMONSTRATED]" -ForegroundColor White
Write-Host "Retry logic with exponential backoff for transient failures" -ForegroundColor Gray
Write-Host "Comprehensive error logging and metrics collection" -ForegroundColor Gray
Write-Host "Specific exception type handling for different error scenarios" -ForegroundColor Gray
Write-Host "Resource cleanup in finally blocks and error recovery strategies" -ForegroundColor Gray
Write-Host "Validation patterns and business logic error handling" -ForegroundColor Gray

Write-Host "`n[ERROR HANDLING TECHNIQUES LEARNED]" -ForegroundColor White
Write-Host "Stream redirection and preference variable management" -ForegroundColor Gray
Write-Host "Non-terminating error capture and conditional processing" -ForegroundColor Gray
Write-Host "Terminating error recovery with try/catch/finally" -ForegroundColor Gray
Write-Host "Exception type inspection and targeted handling" -ForegroundColor Gray
Write-Host "Enterprise-grade retry mechanisms and failure resilience" -ForegroundColor Gray

Write-Host "`n[LIVE ERROR HANDLING AVAILABLE]" -ForegroundColor White
Write-Host "Try: Test-AzureStreams -Verbose -Debug" -ForegroundColor Gray
Write-Host "Try: Get-AzureResourcesWithErrorHandling -ResourceGroupNames @('ValidRG', 'InvalidRG')" -ForegroundColor Gray
Write-Host "Try: Deploy-AzureResourceWithValidation -ResourceGroupName 'TestRG' -Location 'eastus' -StorageAccountName 'validname123'" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These error handling concepts enable you to:" -ForegroundColor Gray
Write-Host "- Build resilient Azure automation scripts with proper error recovery" -ForegroundColor Gray
Write-Host "- Implement enterprise-grade logging and monitoring for production systems" -ForegroundColor Gray
Write-Host "- Handle transient failures gracefully with retry logic and backoff strategies" -ForegroundColor Gray
Write-Host "- Create robust deployment pipelines with comprehensive error management" -ForegroundColor Gray

Write-Host "`nSubscription: $($subscription.Name)" -ForegroundColor Gray
Write-Host "Workshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray