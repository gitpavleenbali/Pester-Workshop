# PSCode — PowerShell Source Modules

Source code for the Pester Workshop. Each folder contains **one `.ps1` file** with testable functions. The corresponding Pester tests live in `Pester-Delivery/Day-1/Pester-Lab-Day1/tests/`.

## Structure

```
PSCode/
├── 01_knowledge_refresh/Azure-Cloud-Analyzer.ps1
├── 02_advanced_functions/Azure-Resource-Manager.ps1
├── 03_mastering_parameters/Azure-Parameter-Mastery.ps1   → dot-sources Module 02
├── 04_powershell_classes/Azure-Classes.ps1
├── 05_error_handling/Azure-Error-Handling.ps1             → dot-sources Module 04
├── 06_debugging/Debug-Demo.ps1
├── 07_git_integration/Azure-Git-Training.ps1
├── 08_runspaces/Azure-Runspaces.ps1
└── 09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1
```

## Modules

| # | Module | Source File | Key Functions / Classes |
|---|---|---|---|
| 01 | Knowledge Refresh | `Azure-Cloud-Analyzer.ps1` | `Get-AzureResourceInsights` |
| 02 | Advanced Functions | `Azure-Resource-Manager.ps1` | `Get-AzureResourceSummary`, `New-AzureResourceGroup`, `Get-VMStatus` |
| 03 | Mastering Parameters | `Azure-Parameter-Mastery.ps1` | *(dot-sources Module 02 — tests parameter validation)* |
| 04 | PowerShell Classes | `Azure-Classes.ps1` | `AzureResource` class, `AzureVirtualMachine` class, `Deploy-AzureResourceWithValidation` |
| 05 | Error Handling | `Azure-Error-Handling.ps1` | *(dot-sources Module 04 — tests error handling patterns)* |
| 06 | Debugging | `Debug-Demo.ps1` | `Test-InputValidation`, `Split-DataIntoChunks`, `Process-DataChunk`, `Get-ProcessedData` |
| 07 | Git Integration | `Azure-Git-Training.ps1` | `Test-GitEnvironment`, `Deploy-ResourceGroup` |
| 08 | Runspaces | `Azure-Runspaces.ps1` | `Get-AzureResourceCount`, `Invoke-ParallelWork` |
| 09 | Capstone | `Azure-Cost-Monitor.ps1` | `Invoke-SafeAzureCall`, `Send-CostAlert`, `Get-ResourceActualCost` |

## How Tests Use These Files

Each test file dot-sources its module directly in `BeforeAll`:

```powershell
BeforeAll {
    . $PSScriptRoot/../../../../PSCode/02_advanced_functions/Azure-Resource-Manager.ps1
}
```

**One source file → one test file → zero duplication.**

All Azure, AD, and API calls are mocked in the tests — no real cloud resources are ever touched.

## Running Tests

```powershell
cd Pester-Delivery/Day-1/Pester-Lab-Day1
Invoke-Pester ./tests -Output Detailed    # 107 tests (106 passed, 1 skipped)
```