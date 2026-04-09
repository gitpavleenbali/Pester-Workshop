# Pester Workshop

[![Deploy to GitHub Pages](https://github.com/gitpavleenbali/Pester-Workshop/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/gitpavleenbali/Pester-Workshop/actions/workflows/deploy-pages.yml)
[![Pester Tests](https://img.shields.io/badge/tests-106%20passed-brightgreen)](https://gitpavleenbali.github.io/Pester-Workshop/)
[![Pester](https://img.shields.io/badge/Pester-5.x-8b5cf6)](https://pester.dev/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue)](https://learn.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> **Workshop Website:** [**gitpavleenbali.github.io/Pester-Workshop**](https://gitpavleenbali.github.io/Pester-Workshop/)

A comprehensive 2-day workshop for PowerShell testing with [Pester](https://pester.dev/) — the ubiquitous test and mock framework for PowerShell.

## Why This Workshop?

PowerShell is no longer "just scripting" — in the enterprise it is **infrastructure as code**. Scripts manage Azure subscriptions, configure Active Directory, orchestrate CI/CD pipelines, and enforce compliance. A single untested script can cause outages, security gaps, or audit failures across environments.

This workshop teaches you to test PowerShell the way enterprises do — with **Pester 5**, the community-standard framework used by Microsoft, Azure, and thousands of production modules.

> *"A bug found in development costs 10x less to fix than a bug found in production."*

## What You'll Learn

| Concept | Description | Where |
|---|---|---|
| **Unit Testing Fundamentals** | Testing pyramid, FIRST principles, AAA pattern (Arrange/Act/Assert) | Module 01 |
| **Pester Test Structure** | `Describe`, `Context`, `It`, `Should` — the building blocks | Module 01 |
| **Assertions** | `Should -Be`, `-Throw`, `-Match`, `-BeNullOrEmpty`, `-HaveCount` | Modules 01–09 |
| **Mocking** | Replace real commands with fakes — never hit Azure/AD/APIs in tests | Module 03 |
| **ParameterFilter** | Return different mock data based on input parameters | Module 02 |
| **Data-Driven Testing** | `-TestCases` to run the same test with multiple datasets | Modules 04, 06, 09 |
| **Error Testing** | `Should -Throw '*pattern*'` with wildcard matching | Module 05 |
| **Boundary Testing** | Off-by-one checks with systematic test cases | Module 09 |
| **Code Coverage** | Measure tested vs untested lines with JaCoCo export | Lab |
| **Enterprise Positioning** | CI/CD integration, quality gates, governance, maturity model | Module 02 |
| **Legacy Code Strategy** | Modernize vs extract & wrap, the drift problem, decision framework | Module 02 |

## What's Inside

```
Pester-Workshop/
├── README.md                        ← You are here
├── PSCode/                          ← PowerShell source code (one .ps1 per module)
│   ├── 01_knowledge_refresh/Azure-Cloud-Analyzer.ps1
│   ├── 02_advanced_functions/Azure-Resource-Manager.ps1
│   ├── 03_mastering_parameters/Azure-Parameter-Mastery.ps1
│   ├── 04_powershell_classes/Azure-Classes.ps1
│   ├── 05_error_handling/Azure-Error-Handling.ps1
│   ├── 06_debugging/Debug-Demo.ps1
│   ├── 07_git_integration/Azure-Git-Training.ps1
│   ├── 08_runspaces/Azure-Runspaces.ps1
│   └── 09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1
└── Pester-Delivery/Day-1/
    ├── Modules/                     ← Presentation materials (enriched with references)
    │   ├── 01. Pester-Introduction.md       ← Testing fundamentals + Pester intro
    │   ├── 02. Enterprise-Positioning.md    ← Enterprise strategy, legacy code, governance
    │   └── 03. Mocking-and-Test-Isolation.md ← Mocking, TestDrive, scoping
    └── Pester-Lab-Day1/             ← Interactive lab environment
        ├── tests/                   ← 9 Pester test files (107 tests, fully annotated)
        ├── lab-ui/                  ← Browser-based lab UI with Explain feature
        ├── Start-Lab.ps1            ← Launch lab (terminal or browser)
        ├── Setup-Lab.ps1            ← Environment check & Pester install
        └── lab-server.ps1           ← HTTP server powering the web UI
```

## PSCode Modules

| # | Module | Source File | Pester Concepts Tested |
|---|---|---|---|
| 01 | Knowledge Refresh | `Azure-Cloud-Analyzer.ps1` | Mock, Should -Be, BeforeEach, Context, Should -Invoke |
| 02 | Advanced Functions | `Azure-Resource-Manager.ps1` | -TestCases, -ParameterFilter, Should -Throw, Should -BeNullOrEmpty |
| 03 | Mastering Parameters | `Azure-Parameter-Mastery.ps1` | Should -HaveParameter, Should -BeTrue/BeFalse, Get-Command metadata |
| 04 | PowerShell Classes | `Azure-Classes.ps1` | Class instantiation, state transitions, -TestCases, no mocking needed |
| 05 | Error Handling | `Azure-Error-Handling.ps1` | Should -Throw '*wildcard*', -Verifiable, Should -InvokeVerifiable |
| 06 | Debugging | `Debug-Demo.ps1` | Pure function testing, Should -Match, TestDrive:, -TestCases |
| 07 | Git Integration | `Azure-Git-Training.ps1` | Mocking native executables (git), Should -Invoke -Times 0 |
| 08 | Runspaces | `Azure-Runspaces.ps1` | Should -HaveCount, Should -Match, edge cases, @() wrapping |
| 09 | Capstone | `Azure-Cost-Monitor.ps1` | $script: scope, boundary -TestCases, -Skip, Set-ItResult, retry logic |

## Pester Lab — 107 Tests

Each PSCode module has a corresponding test file with **inline `# PESTER ▶` comments** explaining every concept. Tests dot-source the PSCode `.ps1` file directly — zero duplication.

| Test File | Tests | Pester Concepts |
|---|---|---|
| PSCode-01-KnowledgeRefresh | 5 | `Mock`, `Should -Be`, `BeforeEach`, `Should -Invoke`, Context override |
| PSCode-02-AdvancedFunctions | 18 | `-TestCases`, `-ParameterFilter`, `Should -Throw`, `Should -BeNullOrEmpty` |
| PSCode-03-Parameters | 10 | `Should -HaveParameter`, `Should -BeTrue/BeFalse`, `Get-Command` metadata |
| PSCode-04-Classes | 16 | Constructor testing, state lifecycle, inheritance, `-TestCases` |
| PSCode-05-ErrorHandling | 7 | `Should -Throw '*pattern*'`, `-Verifiable`, `Should -InvokeVerifiable` |
| PSCode-06-Debugging | 17 | `Should -Match`, `TestDrive:`, data-driven `-TestCases`, `AfterAll` |
| PSCode-07-GitIntegration | 9 | Mock native `git`, `Should -Invoke -Times 0`, branching logic |
| PSCode-08-Runspaces | 9 | `Should -HaveCount`, `Should -Match`, edge cases, `@()` wrapping |
| PSCode-09-Capstone | 16 | `$script:` scope, boundary testing, `-Skip`, `Set-ItResult` |

## Quick Start

```powershell
# 1. Clone the repository
git clone <repo-url>
cd Pester-Workshop

# 2. Check prerequisites (installs Pester 5 if needed)
cd Pester-Delivery/Day-1/Pester-Lab-Day1
.\Setup-Lab.ps1

# 3. Launch the lab
.\Start-Lab.ps1          # Terminal mode (interactive menu)
.\Start-Lab.ps1 -Web     # Browser mode (localhost:8080)

# 4. Or run all 107 tests directly with Pester
Invoke-Pester ./tests -Output Detailed
```

## Requirements

| Requirement | Minimum | Recommended |
|---|---|---|
| **PowerShell** | 5.1 | 7.2+ |
| **Pester** | 5.0.0 | Latest 5.x (`Install-Module Pester -Force`) |
| **OS** | Windows 10+ | Any (Windows/Linux/macOS) |
| **Editor** | Any terminal | VS Code + PowerShell extension |

## Presentation Materials

The `Modules/` folder contains three enriched markdown presentations:

| Module | Duration | Topics | External References |
|---|---|---|---|
| **01. Pester Introduction** | 60 min | Testing types, testing pyramid, FIRST principles, AAA pattern, Pester 5 structure, Discovery vs Execution phases | [pester.dev](https://pester.dev/), [Microsoft Shift-Left](https://learn.microsoft.com/en-us/devops/develop/shift-left-make-testing-fast-reliable), [Martin Fowler — Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html) |
| **02. Enterprise Positioning** | 30 min | Repo structure, legacy code strategy (modernize vs extract), drift problem, CI/CD integration, governance, quality gates, maturity model (Level 0–4), test metrics | [pester.dev/modules](https://pester.dev/docs/usage/modules), [pester.dev/code-coverage](https://pester.dev/docs/usage/code-coverage) |
| **03. Mocking & Test Isolation** | 30 min | Mock, Should -Invoke, ParameterFilter, Verifiable, TestDrive:\, mock scoping, when NOT to mock | [pester.dev/mocking](https://pester.dev/docs/usage/mocking), [Martin Fowler — Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html) |

## Lab Features

### Terminal Mode (`.\Start-Lab.ps1`)
- Interactive menu with modules 1–9
- Step-by-step test execution with colored output
- Code coverage report with visual progress bar
- Test execution log showing Write-Host output from inside tests

### Browser Mode (`.\Start-Lab.ps1 -Web`)
- Full web UI at `http://localhost:8080`
- Sidebar with module list and progress tracker
- **View Test File** button — shows test file with line numbers
- **View PSCode Source** button — shows the source code being tested
- **Expand test** — shows the test code with syntax highlighting
- **Explain** button — identifies Pester concepts used in each test
- **Run individual tests** — run a single test by name
- Dashboard with pass/fail/coverage stats
- Terminal pane with colored output

### Direct Pester Commands
```powershell
# Run one module
Invoke-Pester ./tests/PSCode-01-KnowledgeRefresh.Tests.ps1 -Output Detailed

# Run all with coverage
$config = New-PesterConfiguration
$config.Run.Path = './tests'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '../../../PSCode'
Invoke-Pester -Configuration $config
```

## Further Reading

| Resource | Link |
|---|---|
| Pester Documentation | [pester.dev](https://pester.dev/) |
| Pester Quick Start | [pester.dev/docs/quick-start](https://pester.dev/docs/quick-start) |
| Pester GitHub | [github.com/pester/Pester](https://github.com/pester/Pester) |
| Microsoft Shift-Left Testing | [learn.microsoft.com — shift-left](https://learn.microsoft.com/en-us/devops/develop/shift-left-make-testing-fast-reliable) |
| Martin Fowler — Mocks Aren't Stubs | [martinfowler.com](https://martinfowler.com/articles/mocksArentStubs.html) |
| Pester Community | [Discord #testing](https://discord.gg/powershell), [Stack Overflow](https://stackoverflow.com/questions/tagged/pester) |
