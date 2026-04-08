# ============================================================================
# PSCode Module 04 — PowerShell Classes
# SOURCE: PSCode/04_powershell_classes/Azure-Classes-Training.ps1
# TESTS:  AzureResource, AzureVirtualMachine (constructor, methods, inheritance)
#
# PESTER CONCEPTS: Class instantiation, method testing, state transitions, -TestCases
# All classes are 100% testable — no Azure calls, pure OOP logic.
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/PSCodeModuleExtracts.ps1
}

Describe 'Module 04 · AzureResource Base Class' {

    BeforeAll {
        $r = [AzureResource]::new('my-storage', 'StorageAccount', 'westeurope')
    }

    # PESTER: Test constructor sets properties correctly
    It 'Constructor sets Name' {
        Write-Host "  → Checking Name = 'my-storage'" -ForegroundColor Gray
        $r.Name | Should -Be 'my-storage'
    }
    It 'Constructor sets Type' {
        Write-Host "  → Checking Type = 'StorageAccount'" -ForegroundColor Gray
        $r.Type | Should -Be 'StorageAccount'
    }
    It 'Constructor sets Location' {
        Write-Host "  → Checking Location = 'westeurope'" -ForegroundColor Gray
        $r.Location | Should -Be 'westeurope'
    }
    It 'Status defaults to Created' {
        Write-Host "  → Checking Status defaults to 'Created'" -ForegroundColor Gray
        $r.Status | Should -Be 'Created'
    }

    # PESTER: Test methods return expected values
    It 'GetDisplayName() returns Type/Name format' {
        Write-Host "  → ASSERT: Checking return value — GetDisplayName() returns Type/Name format" -ForegroundColor Gray
        $r.GetDisplayName() | Should -Be 'StorageAccount/my-storage'
    }

    It 'IsInRegion() returns true for matching region' {
        Write-Host "  → ASSERT: Checking return value — IsInRegion() returns true for matching region" -ForegroundColor Gray
        $r.IsInRegion('westeurope') | Should -Be $true
    }

    It 'IsInRegion() returns false for non-matching' {
        Write-Host "  → ASSERT: Checking return value — IsInRegion() returns false for non-matching" -ForegroundColor Gray
        $r.IsInRegion('eastus') | Should -Be $false
    }

    # PESTER: Test method side effects (mutation)
    It 'AddTag() adds to Tags hashtable' {
        Write-Host "  → Running: AddTag() adds to Tags hashtable" -ForegroundColor Gray
        $r.AddTag('Env', 'Prod')
        $r.Tags['Env'] | Should -Be 'Prod'
    }
}

Describe 'Module 04 · AzureVirtualMachine Inheritance' {

    # PESTER: -TestCases tests the constructor VM size mapping
    It 'Maps <Size> to <Cores> cores, <Mem> GB' -TestCases @(
        @{ Size = 'Standard_B1s'; Cores = 1; Mem = 1 }
        @{ Size = 'Standard_B2s'; Cores = 2; Mem = 4 }
        @{ Size = 'Standard_D4s'; Cores = 4; Mem = 16 }
        @{ Size = 'Standard_E8s'; Cores = 2; Mem = 8 }
    ) {
        param($Size, $Cores, $Mem)
        Write-Host "  → Testing VM size $Size → expecting $Cores cores, $Mem GB" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('test', 'westeurope', $Size)
        $vm.CpuCores | Should -Be $Cores
        $vm.MemoryGB | Should -Be $Mem
    }

    # PESTER: Test state transitions — Start/Stop change Status
    It 'State lifecycle: Created -> Running -> Stopped' {
        Write-Host "  → Running: State lifecycle: Created -> Running -> Stopped" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-life', 'westeurope', 'Standard_D4s')
        $vm.Status | Should -Be 'Created'

        $vm.Start()
        $vm.Status | Should -Be 'Running'

        $vm.Stop()
        $vm.Status | Should -Be 'Stopped'
    }

    # PESTER: Test calculated property
    It 'EstimateMonthlyCost = CpuCores x 35.50' {
        Write-Host "  → Running: EstimateMonthlyCost = CpuCores x 35.50" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-cost', 'westeurope', 'Standard_D4s')
        $vm.EstimateMonthlyCost() | Should -Be 142.00  # 4 x 35.50
    }

    # PESTER: Test inheritance — base class methods work on derived class
    It 'Inherits GetDisplayName() from AzureResource' {
        Write-Host "  → Running: Inherits GetDisplayName() from AzureResource" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-01', 'westeurope', 'Standard_B1s')
        $vm.GetDisplayName() | Should -Be 'VirtualMachine/vm-01'
    }
}

