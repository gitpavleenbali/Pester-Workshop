# ============================================================================
# Exercise 06 — Day 2: Idempotency & Code Coverage
# DIFFICULTY: Advanced
# GOAL: Test that a function is safe to run multiple times.
#       Then run coverage and identify untested lines.
#
# INSTRUCTIONS:
#   1. Replace ___BLANK___ with correct code.
#   2. Run: Invoke-Pester ./exercises/Exercise-06-Idempotency.Tests.ps1
#   3. BONUS: Run with coverage to see what's missed:
#      $c = New-PesterConfiguration
#      $c.Run.Path = './exercises/Exercise-06-Idempotency.Tests.ps1'
#      $c.CodeCoverage.Enabled = $true
#      $c.CodeCoverage.Path = './exercises/Exercise-06-Idempotency.Tests.ps1'
#      Invoke-Pester -Configuration $c
#
# HINTS:
#   - Mock returns $null → resource doesn't exist → should create
#   - Mock returns object → resource exists → should skip creation
#   - Should -Invoke -Times 0 proves a command was NOT called
# ============================================================================

BeforeAll {
    function Ensure-StorageAccount {
        param(
            [Parameter(Mandatory)]
            [string]$Name,
            [string]$ResourceGroup = 'rg-default',
            [string]$Location = 'eastus'
        )
        $existing = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if ($existing) {
            return @{ Status = 'AlreadyExists'; Name = $Name }
        }
        New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $Name -Location $Location -SkuName 'Standard_LRS'
        return @{ Status = 'Created'; Name = $Name }
    }
}

Describe 'Exercise 06 · Idempotency Testing' {

    Context 'When storage account does NOT exist' {
        BeforeAll {
            # EXERCISE: Mock Get-AzStorageAccount to return $null (doesn't exist)
            ___BLANK___
            Mock New-AzStorageAccount { @{ Id = '/sub/rg/sa' } }
        }

        It 'Creates the storage account' {
            $result = Ensure-StorageAccount -Name 'satest01'
            # EXERCISE: Assert Status is 'Created'
            $result.Status | Should ___BLANK___
        }

        It 'Calls New-AzStorageAccount exactly once' {
            Ensure-StorageAccount -Name 'satest01'
            # EXERCISE: Verify New-AzStorageAccount was called
            ___BLANK___
        }
    }

    Context 'When storage account ALREADY exists (idempotent)' {
        BeforeAll {
            # EXERCISE: Mock Get-AzStorageAccount to return an existing account
            Mock Get-AzStorageAccount { ___BLANK___ }
            Mock New-AzStorageAccount {}
        }

        It 'Returns AlreadyExists status' {
            $result = Ensure-StorageAccount -Name 'satest01'
            $result.Status | Should -Be 'AlreadyExists'
        }

        It 'Does NOT call New-AzStorageAccount (skips creation)' {
            Ensure-StorageAccount -Name 'satest01'
            # EXERCISE: Prove New-AzStorageAccount was never called
            ___BLANK___
        }
    }
}
