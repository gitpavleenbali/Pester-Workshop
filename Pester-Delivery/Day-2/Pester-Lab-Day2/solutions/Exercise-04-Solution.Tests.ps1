# Solution for Exercise 04 — Negative Testing
BeforeAll {
    function Deploy-AzureResource {
        param(
            [Parameter(Mandatory)][ValidateLength(3, 50)][string]$Name,
            [string]$Location = 'eastus'
        )
        if ($Name -match '[^a-zA-Z0-9-]') {
            throw "Resource name '$Name' contains invalid characters. Use only letters, numbers, and hyphens."
        }
        $rg = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if (-not $rg) { throw "Resource group '$Name' does not exist." }
        New-AzResource -ResourceGroupName $Name -Location $Location
        return @{ Status = 'Deployed'; Name = $Name }
    }
}

Describe 'Exercise 04 · Negative Testing' {
    BeforeAll {
        Mock Get-AzResourceGroup { [PSCustomObject]@{ Name = 'rg-valid' } }
        Mock New-AzResource { @{ Id = '/sub/rg/resource' } }
    }

    It 'Rejects names shorter than 3 characters' {
        { Deploy-AzureResource -Name 'ab' } | Should -Throw
    }
    It 'Rejects names with special characters' {
        { Deploy-AzureResource -Name 'bad@name!' } | Should -Throw '*invalid characters*'
    }
    It 'Does NOT call New-AzResource when validation fails' {
        try { Deploy-AzureResource -Name 'x' } catch {}
        Should -Invoke New-AzResource -Times 0
    }

    Context 'When resource group does not exist' {
        BeforeAll {
            Mock Get-AzResourceGroup { $null }
        }
        It 'Throws "does not exist"' {
            { Deploy-AzureResource -Name 'rg-missing' } | Should -Throw '*does not exist*'
        }
    }
}
