# ============================================================================
# Lab Source: Azure Resource Helpers
# Origin: Extracted from PSCode/02_advanced_functions & 03_mastering_parameters
# Purpose: Testable utility functions for the Pester lab
# ============================================================================

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

    # Simulate creation — never hits real Azure
    return [PSCustomObject]@{
        ResourceGroupName = $Name
        Location          = $Location
        ProvisioningState = "Succeeded"
        Tags              = $Tags
        CreatedAt         = Get-Date
    }
}

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
