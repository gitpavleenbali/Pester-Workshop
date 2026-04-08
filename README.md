# Pester Workshop

A comprehensive 2-day workshop for PowerShell testing with [Pester](https://pester.dev/) — the ubiquitous test and mock framework for PowerShell.

## What's Inside

```
PSCode/                          ← PowerShell source code (9 modules)
Pester-Delivery/Day-1/
├── Modules/                     ← Presentation materials
│   ├── 01. Pester-Introduction.md
│   ├── 02. Enterprise-Positioning.md
│   └── 03. Mocking-and-Test-Isolation.md
└── Pester-Lab-Day1/             ← Interactive lab environment
    ├── src/                     ← Testable functions (extracted from PSCode)
    ├── tests/                   ← 9 Pester test files (96 tests)
    ├── lab-ui/                  ← Browser-based lab UI
    ├── Start-Lab.ps1            ← Launch lab (terminal or browser)
    ├── Setup-Lab.ps1            ← Environment check
    └── lab-server.ps1           ← HTTP server for web UI
```

## PSCode Modules

| # | Module | Topics |
|---|---|---|
| 01 | Knowledge Refresh | Cmdlets, arrays, pipeline, objects, functions |
| 02 | Advanced Functions | Function design, parameters, help, output objects |
| 03 | Mastering Parameters | ValidateSet, Mandatory, parameter sets, binding |
| 04 | PowerShell Classes | OOP, constructors, methods, inheritance |
| 05 | Error Handling | Try/catch, streams, error recovery, resilience |
| 06 | Debugging | Breakpoints, call stacks, tracing, strict mode |
| 07 | Git Integration | Version control, branching, CI/CD workflows |
| 08 | Runspaces | Parallel execution, thread safety, performance |
| 09 | Capstone | Real-world Azure cost monitor (all modules combined) |

## Pester Lab

96 Pester tests across 9 modules — each PSCode module has a corresponding test file:

| Test File | Tests | What's Covered |
|---|---|---|
| PSCode-01-KnowledgeRefresh | 5 | Mock Get-AzResource, property assertions |
| PSCode-02-AdvancedFunctions | 18 | Mock, ValidateSet, ParameterFilter |
| PSCode-03-Parameters | 5 | Mandatory metadata, defaults |
| PSCode-04-Classes | 15 | Constructors, methods, inheritance, -TestCases |
| PSCode-05-ErrorHandling | 6 | Should -Throw, wildcard patterns |
| PSCode-06-Debugging | 16 | Pipeline testing, data-driven tests |
| PSCode-07-GitIntegration | 9 | Mock native commands (git), Context |
| PSCode-08-Runspaces | 8 | Pure functions, edge cases |
| PSCode-09-Capstone | 14 | Retry logic, boundary -TestCases |

## Quick Start

```powershell
# 1. Clone
git clone <repo-url>
cd Pester-Workshop

# 2. Install Pester
Install-Module -Name Pester -Force -Scope CurrentUser

# 3. Run the lab
cd Pester-Delivery/Day-1/Pester-Lab-Day1
.\Start-Lab.ps1          # Terminal mode
.\Start-Lab.ps1 -Web     # Browser mode (localhost:8080)
```

## Requirements

- PowerShell 5.1 or 7.2+
- Pester 5.x (`Install-Module Pester -Force`)
- VS Code (recommended)
