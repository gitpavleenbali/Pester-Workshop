# ============================================================================
# PSCode Module 04 — PowerShell Classes
# SOURCE: PSCode/04_powershell_classes/Azure-Classes-Training.ps1
# TESTS:  AzureResource, AzureVirtualMachine (constructor, methods, inheritance)
#
# PESTER CONCEPTS: Class instantiation, method testing, state transitions, -TestCases
# All classes are 100% testable — no Azure calls, pure OOP logic.
# ============================================================================

# PESTER ▶ BeforeAll {}
# Dot-sources the class definitions so they're available to all tests.
# Classes MUST be loaded at file scope (not inside Describe) in Pester 5.
BeforeAll {
    . $PSScriptRoot/../../../../PSCode/04_powershell_classes/Azure-Classes.Functions.ps1
}

# PESTER ▶ Describe for class testing
# Testing classes follows the same Describe/It pattern as functions.
# No mocking needed here — classes are pure OOP logic.
Describe 'Module 04 · AzureResource Base Class' {

    # PESTER ▶ BeforeAll inside Describe
    # Creates a SHARED instance for all It blocks in this Describe.
    # Use BeforeAll (not BeforeEach) when the instance doesn't change between tests,
    # or when creating objects is expensive.
    BeforeAll {
        $r = [AzureResource]::new('my-storage', 'StorageAccount', 'westeurope')
    }

    # PESTER ▶ Testing constructors with Should -Be
    # Verifies the class constructor correctly initialized each property.
    # Each property gets its own It block — one assertion per test is a best practice.
    It 'Constructor sets Name' {
        Write-Host "  → Checking Name = 'my-storage'" -ForegroundColor Gray
        $r.Name | Should -Be 'my-storage'
    }
    # PESTER ▶ Should -BeOfType — verifies the .NET type of the object
    It 'Is of type AzureResource' {
        Write-Host "  → Checking object type is AzureResource" -ForegroundColor Gray
        $r | Should -BeOfType ([AzureResource])
    }
    It 'Constructor sets Type' {
        Write-Host "  → Checking Type = 'StorageAccount'" -ForegroundColor Gray
        $r.Type | Should -Be 'StorageAccount'
    }
    It 'Constructor sets Location' {
        Write-Host "  → Checking Location = 'westeurope'" -ForegroundColor Gray
        $r.Location | Should -Be 'westeurope'
    }
    # PESTER ▶ Testing default property values
    # Properties not set by the constructor should have sensible defaults.
    It 'Status defaults to Created' {
        Write-Host "  → Checking Status defaults to 'Created'" -ForegroundColor Gray
        $r.Status | Should -Be 'Created'
    }

    # PESTER ▶ Testing method return values
    # Call the method and pipe result to Should -Be to verify the return.
    It 'GetDisplayName() returns Type/Name format' {
        Write-Host "  → ASSERT: Checking return value — GetDisplayName() returns Type/Name format" -ForegroundColor Gray
        $r.GetDisplayName() | Should -Be 'StorageAccount/my-storage'
    }

    # PESTER ▶ Testing boolean return values
    # Should -Be $true / $false works for boolean assertions.
    It 'IsInRegion() returns true for matching region' {
        Write-Host "  → ASSERT: Checking return value — IsInRegion() returns true for matching region" -ForegroundColor Gray
        $r.IsInRegion('westeurope') | Should -Be $true
    }

    It 'IsInRegion() returns false for non-matching' {
        Write-Host "  → ASSERT: Checking return value — IsInRegion() returns false for non-matching" -ForegroundColor Gray
        $r.IsInRegion('eastus') | Should -Be $false
    }

    # PESTER ▶ Testing method side effects (mutation)
    # Some methods change the object's state rather than returning a value.
    # We call the method, then assert the object's property changed.
    It 'AddTag() adds to Tags hashtable' {
        Write-Host "  → Running: AddTag() adds to Tags hashtable" -ForegroundColor Gray
        $r.AddTag('Env', 'Prod')
        $r.Tags['Env'] | Should -Be 'Prod'
    }
}

# PESTER ▶ Testing inheritance
# AzureVirtualMachine inherits from AzureResource.
# Tests verify both the derived class behavior AND inherited methods.
Describe 'Module 04 · AzureVirtualMachine Inheritance' {

    # PESTER ▶ -TestCases for data-driven testing
    # Each hashtable = one test execution. The param() block receives the values.
    # <Size>, <Cores>, <Mem> in the test name get substituted with actual values,
    # so the test output reads like: "Maps Standard_B1s to 1 cores, 1 GB".
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

    # PESTER ▶ Testing state transitions
    # Verifies that calling methods changes the object's Status property
    # through its expected lifecycle: Created → Running → Stopped.
    # Multiple assertions in one It block are OK when testing a SEQUENCE.
    It 'State lifecycle: Created -> Running -> Stopped' {
        Write-Host "  → Running: State lifecycle: Created -> Running -> Stopped" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-life', 'westeurope', 'Standard_D4s')
        $vm.Status | Should -Be 'Created'

        $vm.Start()
        $vm.Status | Should -Be 'Running'

        $vm.Stop()
        $vm.Status | Should -Be 'Stopped'
    }

    # PESTER ▶ Testing calculated properties / computed values
    # Verifies the method performs the correct math: CpuCores × 35.50.
    It 'EstimateMonthlyCost = CpuCores x 35.50' {
        Write-Host "  → Running: EstimateMonthlyCost = CpuCores x 35.50" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-cost', 'westeurope', 'Standard_D4s')
        $vm.EstimateMonthlyCost() | Should -Be 142.00  # 4 x 35.50
    }

    # PESTER ▶ Testing inheritance
    # Calling a BASE CLASS method on a DERIVED CLASS object.
    # Proves that AzureVirtualMachine correctly inherits AzureResource's methods.
    It 'Inherits GetDisplayName() from AzureResource' {
        Write-Host "  → Running: Inherits GetDisplayName() from AzureResource" -ForegroundColor Gray
        $vm = [AzureVirtualMachine]::new('vm-01', 'westeurope', 'Standard_B1s')
        $vm.GetDisplayName() | Should -Be 'VirtualMachine/vm-01'
    }
}



