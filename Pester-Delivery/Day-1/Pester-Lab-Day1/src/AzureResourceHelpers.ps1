# ============================================================================
# Lab Source: Azure Resource Helpers
# Origin: Extracted from PSCode/02_advanced_functions & 03_mastering_parameters
# Purpose: Testable utility functions for the Pester lab
#
# TESTING NOTES:
#   These functions call Azure cmdlets (Get-AzResource, Get-AzVM) which
#   MUST be mocked in Pester tests to avoid real Azure API calls.
#   See: tests/PSCode-02-AdvancedFunctions.Tests.ps1
#        tests/PSCode-03-Parameters.Tests.ps1
# ============================================================================

# TESTABILITY: This function calls Get-AzResource which is an Azure cmdlet.
# In Pester tests, we Mock Get-AzResource to return fake data, so this function
# can be tested without an Azure subscription. The mock controls exactly what
# resources "exist", making assertions deterministic.
# TESTED IN: PSCode-02-AdvancedFunctions.Tests.ps1
function Get-AzureResourceSummary {
    <#
    .SYNOPSIS
        Summarizes Azure resources in a subscription or resource group.
    .PARAMETER ResourceGroupName
        Optional. Scope to a specific resource group.
    .PARAMETER ResourceType
        Optional. Filter by resource type (supports wildcards).
    #>
    param(
        [string]$ResourceGroupName,
        [string]$ResourceType
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
        Scope          = $scope
        TotalResources = $resources.Count
        ResourceTypes  = ($resources | Group-Object ResourceType).Count
        FirstResource  = if ($resources) { $resources[0].Name } else { "None" }
    }
}

# TESTABILITY: This is a SIMULATED function — it never calls Azure.
# It uses PowerShell validation attributes (ValidateSet, Mandatory) which
# can be tested by Pester. ValidateSet throws before the function body runs,
# so { New-AzureResourceGroup -Location 'mars' } | Should -Throw works.
# TESTED IN: PSCode-02-AdvancedFunctions.Tests.ps1, PSCode-03-Parameters.Tests.ps1
function New-AzureResourceGroup {
    <#
    .SYNOPSIS
        Creates a simulated Azure resource group (safe for workshops).
    .PARAMETER Name
        Mandatory. Name of the resource group.
    .PARAMETER Location
        Azure region. Must be one of: eastus, westus, westeurope, eastus2.
    .PARAMETER Tags
        Hashtable of tags to apply.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [ValidateSet("eastus", "westus", "westeurope", "eastus2")]
        [string]$Location = "eastus",

        [hashtable]$Tags = @{
            CreatedBy = "Pester Workshop"
            Purpose   = "Lab Exercise"
        }
    )

        # SIMULATION: Returns a PSCustomObject instead of calling Azure.
        # This makes the function safe for workshops while still testing
        # parameter validation, defaults, and return object structure.
        return [PSCustomObject]@{
        ResourceGroupName = $Name
        Location          = $Location
        ProvisioningState = "Succeeded"
        Tags              = $Tags
        CreatedAt         = Get-Date
    }
}

# TESTABILITY: Calls Get-AzVM which MUST be mocked.
# In tests, we use -ParameterFilter on Mock to return different VM states
# (Running, Stopped, Deallocated) based on the -Name parameter.
# This demonstrates multi-behavior mocking — same command, different results.
# TESTED IN: PSCode-02-AdvancedFunctions.Tests.ps1
function Get-VMStatus {
    <#
    .SYNOPSIS
        Returns a simplified VM status string.
    .PARAMETER VMName
        Name of the virtual machine to check.
    .PARAMETER ResourceGroupName
        Resource group containing the VM.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$VMName,

        [string]$ResourceGroupName = "default-rg"
    )

    $vm = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Status -ErrorAction SilentlyContinue

    if (-not $vm) {
        return $null
    }

    $powerState = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' }).DisplayStatus

    switch -Wildcard ($powerState) {
        '*running*'      { return 'Running' }
        '*deallocated*'  { return 'Deallocated' }
        '*stopped*'      { return 'Stopped' }
        default          { return 'Unknown' }
    }
}
