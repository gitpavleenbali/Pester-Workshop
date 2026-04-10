# Solution for Exercise 06 — Idempotency Testing
BeforeAll {
    function Ensure-StorageAccount {
        param(
            [Parameter(Mandatory)][string]$Name,
            [string]$ResourceGroup = 'rg-default',
            [string]$Location = 'eastus'
        )
        $existing = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if ($existing) { return @{ Status = 'AlreadyExists'; Name = $Name } }
        New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $Name -Location $Location -SkuName 'Standard_LRS'
        return @{ Status = 'Created'; Name = $Name }
    }
}

Describe 'Exercise 06 · Idempotency Testing' {
    Context 'When storage account does NOT exist' {
        BeforeAll {
            Mock Get-AzStorageAccount { $null }
            Mock New-AzStorageAccount { @{ Id = '/sub/rg/sa' } }
        }
        It 'Creates the storage account' {
            $result = Ensure-StorageAccount -Name 'satest01'
            $result.Status | Should -Be 'Created'
        }
        It 'Calls New-AzStorageAccount exactly once' {
            Ensure-StorageAccount -Name 'satest01'
            Should -Invoke New-AzStorageAccount -Times 1 -Exactly
        }
    }

    Context 'When storage account ALREADY exists (idempotent)' {
        BeforeAll {
            Mock Get-AzStorageAccount { [PSCustomObject]@{ Name = 'satest01' } }
            Mock New-AzStorageAccount {}
        }
        It 'Returns AlreadyExists status' {
            $result = Ensure-StorageAccount -Name 'satest01'
            $result.Status | Should -Be 'AlreadyExists'
        }
        It 'Does NOT call New-AzStorageAccount (skips creation)' {
            Ensure-StorageAccount -Name 'satest01'
            Should -Invoke New-AzStorageAccount -Times 0
        }
    }
}
