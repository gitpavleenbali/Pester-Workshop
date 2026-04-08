# ============================================================================
# Lab Source: PSCode Module Correlation — Error Handling & Classes
# Origin: PSCode/05_error_handling + PSCode/04_powershell_classes
# Purpose: Enterprise patterns for testing error handling and OOP
#
# TESTING NOTES:
#   Deploy-AzureResourceWithValidation calls Azure cmdlets → must be mocked.
#   AzureResource/AzureVirtualMachine are pure classes → no mocking needed.
#   Classes are loaded via dot-sourcing in BeforeAll and tested by creating
#   instances and asserting property values and method results.
#   See: tests/PSCode-04-Classes.Tests.ps1
#        tests/PSCode-05-ErrorHandling.Tests.ps1
# ============================================================================

# ── From Module 05: Error Handling ──────────────────────────────────────

# TESTABILITY: This function validates input THEN calls Azure cmdlets.
# Tests cover three scenarios using separate Context blocks:
#   1. Valid deployment (mocks return success) → Should -Be 'Deployed'
#   2. Invalid input (short name, special chars) → Should -Throw '*pattern*'
#   3. Missing RG (mock returns $null) → Should -Throw '*does not exist*'
# The mock for Get-AzResourceGroup is OVERRIDDEN in Context 3 to return $null.
# TESTED IN: PSCode-05-ErrorHandling.Tests.ps1
function Deploy-AzureResourceWithValidation {
    <#
    .SYNOPSIS
        Deploys an Azure resource with pre-validation and error handling.
    .PARAMETER ResourceGroupName
        Target resource group.
    .PARAMETER ResourceName
        Name of the resource to deploy.
    .PARAMETER Location
        Azure region.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$ResourceName,

        [ValidateSet("eastus", "westus", "westeurope", "eastus2")]
        [string]$Location = "westeurope"
    )

    # Step 1: Validate inputs
    if ($ResourceName.Length -lt 3) {
        throw "Resource name must be at least 3 characters long."
    }

    if ($ResourceName -match '[^a-zA-Z0-9\-]') {
        throw "Resource name contains invalid characters. Use only letters, numbers, and hyphens."
    }

    # Step 2: Check if resource group exists (calls Azure — to be mocked)
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

    if (-not $rg) {
        throw "Resource group '$ResourceGroupName' does not exist."
    }

    # Step 3: Deploy (calls Azure — to be mocked)
    $deployment = New-AzResource -ResourceGroupName $ResourceGroupName `
                                 -ResourceName $ResourceName `
                                 -Location $Location `
                                 -ResourceType "Microsoft.Storage/storageAccounts" `
                                 -Force

    return [PSCustomObject]@{
        Status       = "Deployed"
        ResourceName = $ResourceName
        Location     = $Location
        ResourceGroup = $ResourceGroupName
    }
}

# ── From Module 04: PowerShell Classes ──────────────────────────────────

class AzureResource {
    [string]$Name
    [string]$Type
    [string]$Location
    [string]$Status
    [hashtable]$Tags

    AzureResource([string]$name, [string]$type, [string]$location) {
        $this.Name     = $name
        $this.Type     = $type
        $this.Location = $location
        $this.Status   = 'Created'
        $this.Tags     = @{}
    }

    [void] AddTag([string]$key, [string]$value) {
        $this.Tags[$key] = $value
    }

    [string] GetDisplayName() {
        return "$($this.Type)/$($this.Name)"
    }

    [bool] IsInRegion([string]$region) {
        return $this.Location -eq $region
    }
}

# DERIVED CLASS: Inherits from AzureResource, adds VM-specific behavior.
# The constructor maps VM size strings to CPU/memory specs using switch.
# Start()/Stop() change the Status property (state transition pattern).
# EstimateMonthlyCost() is a calculated property: CpuCores * 35.50.
class AzureVirtualMachine : AzureResource {
    [string]$VMSize
    [int]$CpuCores
    [int]$MemoryGB

    AzureVirtualMachine([string]$name, [string]$location, [string]$vmSize) : base($name, 'VirtualMachine', $location) {
        $this.VMSize = $vmSize
        switch -Wildcard ($vmSize) {
            'Standard_B1*' { $this.CpuCores = 1; $this.MemoryGB = 1 }
            'Standard_B2*' { $this.CpuCores = 2; $this.MemoryGB = 4 }
            'Standard_D4*' { $this.CpuCores = 4; $this.MemoryGB = 16 }
            default        { $this.CpuCores = 2; $this.MemoryGB = 8 }
        }
    }

    [string] Start() {
        $this.Status = 'Running'
        return "VM '$($this.Name)' started."
    }

    [string] Stop() {
        $this.Status = 'Stopped'
        return "VM '$($this.Name)' stopped."
    }

    [decimal] EstimateMonthlyCost() {
        # Simplified cost estimate: EUR per core per month
        return [decimal]($this.CpuCores * 35.50)
    }
}
