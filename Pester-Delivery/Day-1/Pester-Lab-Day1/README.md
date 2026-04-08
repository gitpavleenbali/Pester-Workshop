# Pester Lab — Day 1 Setup Guide

Welcome to the **Pester Lab**. This hands-on environment lets you run 96 Pester tests, explore source code, and learn unit testing patterns — all without needing an Azure subscription.

> Every function that calls Azure, Active Directory, or external APIs is **mocked** in the tests. You'll never touch a real cloud resource.

---

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| PowerShell | 5.1 | 7.2+ |
| Pester | 5.0.0 | Latest 5.x |
| OS | Windows 10+ | Any (Windows/Linux/macOS) |
| Editor | Any | VS Code + PowerShell extension |

> **Why Pester 5?** Windows ships with Pester 3.x/4.x which is **incompatible** with this lab. Pester 5 introduced: `New-PesterConfiguration`, `Should -Invoke` (replaces `Assert-MockCalled`), Discovery/Run phase separation, and block-scoped mocking.

---

## Step 1 — Install Pester

```powershell
# Install latest Pester 5.x (overrides the built-in 3.x on Windows)
Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck
Import-Module Pester -PassThru   # Should show version 5.x
```

> `-SkipPublisherCheck` is needed because Windows ships a signed Pester 3.x. Without this flag, PowerShell refuses to overwrite it.

---

## Step 2 — Verify Environment

```powershell
cd Pester-Delivery/Day-1/Pester-Lab-Day1
.\Setup-Lab.ps1
```

This checks 4 things:
1. **PowerShell version** — 5.1+ required, 7+ recommended
2. **Pester installed** — auto-installs 5.x if missing
3. **Pester importable** — loads into the session
4. **Lab files present** — all 5 source + 9 test files exist

You should see:

```
======================================
  READY! You can start the lab.
======================================
```

---

## Step 3 — Run the Lab

### Option A: Terminal Mode (interactive menu)

```powershell
.\Start-Lab.ps1
```

You'll see:

```
╔══════════════════════════════════════════════════════════╗
║  Pester Lab — Day 1 · Pester v5.7.1                    ║
╚══════════════════════════════════════════════════════════╝

  -- PSCode Module Tests --
  [1] 01 Knowledge Refresh
  [2] 02 Advanced Functions
  ...
  [9] 09 Capstone

  [A] Run ALL     [C] Coverage     [S] Setup     [W] Web UI     [Q] Quit
```

| Command | Action |
|---|---|
| `1`–`9` | Run a module's tests step-by-step with colored output |
| `A` | Run all 96 tests at once |
| `C` | Code coverage report with visual progress bar (threshold: 75%) |
| `S` | Re-run environment check |
| `W` | Switch to browser mode |
| `Q` | Quit |

### Option B: Browser Mode (recommended for workshops)

```powershell
.\Start-Lab.ps1 -Web
```

Opens `http://localhost:8080` with a full web UI:

| Feature | Description |
|---|---|
| **Sidebar** | 9 modules with progress tracker (✓ turns green on pass) |
| **View Source** | Shows the test file with syntax-highlighted line numbers |
| **Expand test** | Click any test to see its code with Pester keyword highlighting |
| **Explain** | Identifies every Pester concept in the test (`Mock`, `Should -Be`, `-ParameterFilter`, etc.) |
| **Run one test** | Run a single test by clicking ▶ on any expanded test |
| **Run all** | Run the full module suite with ▶ Run All Tests button |
| **Terminal pane** | Colored output showing `[+]` pass / `[-]` fail with timing |
| **Dashboard** | Live pass/fail/total/coverage counters |
| **Test Execution Log** | Shows `Write-Host` output from inside the test functions |

> The comments you see in "View Source" and "Expand test" include **`# PESTER ▶`** annotations explaining every Pester construct — what it does, how it works, and why it's used.

### Option C: Direct Pester commands

```powershell
# Run a single module
Invoke-Pester ./tests/PSCode-01-KnowledgeRefresh.Tests.ps1 -Output Detailed

# Run all tests
Invoke-Pester ./tests -Output Detailed

# Run with code coverage (enterprise pattern)
$config = New-PesterConfiguration
$config.Run.Path            = './tests'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path   = './src'
$config.Output.Verbosity    = 'Detailed'
Invoke-Pester -Configuration $config
```

---

## File Structure

```
Pester-Lab-Day1/
├── README.md              ← You are here
├── Setup-Lab.ps1          ← Run first — checks prerequisites, installs Pester 5
├── Start-Lab.ps1          ← Main entry point (terminal menu or -Web browser)
├── lab-server.ps1         ← HTTP server for browser UI (REST API + Pester runner)
├── lab-ui/
│   └── index.html         ← Browser UI (sidebar, dashboard, terminal, explain)
├── src/                   ← Source functions (extracted from PSCode modules)
│   ├── AzureResourceHelpers.ps1     ← Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus
│   ├── CostMonitorHelpers.ps1       ← Invoke-SafeAzureCall (retry), Send-CostAlert (email)
│   ├── DataProcessing.ps1           ← Pure functions: validate, split, process, pipeline
│   ├── PSCodeModuleExtracts.ps1     ← Deploy-AzureResourceWithValidation, AzureResource/VM classes
│   └── PSCodeModulesAdditional.ps1  ← Get-AzureResourceInsights, Test-GitEnvironment, Invoke-ParallelWork
└── tests/                 ← Pester test files (one per PSCode module, 96 tests total)
    ├── PSCode-01-KnowledgeRefresh.Tests.ps1    ← 5 tests:  Mock, Should -Be, Should -Invoke
    ├── PSCode-02-AdvancedFunctions.Tests.ps1   ← 18 tests: -TestCases, -ParameterFilter, Should -Throw
    ├── PSCode-03-Parameters.Tests.ps1          ← 5 tests:  ValidateSet, Mandatory metadata
    ├── PSCode-04-Classes.Tests.ps1             ← 15 tests: Constructors, state transitions, inheritance
    ├── PSCode-05-ErrorHandling.Tests.ps1       ← 6 tests:  Should -Throw '*wildcard*', mock override
    ├── PSCode-06-Debugging.Tests.ps1           ← 16 tests: Pure functions, -TestCases, pipeline
    ├── PSCode-07-GitIntegration.Tests.ps1      ← 9 tests:  Mock native git, Should -Invoke -Times 0
    ├── PSCode-08-Runspaces.Tests.ps1           ← 8 tests:  Should -Match, edge cases, @() wrapping
    └── PSCode-09-Capstone.Tests.ps1            ← 14 tests: Boundary -TestCases, $script: scope, retry
```

### Source ↔ Test Mapping

Each source file is dot-sourced in `BeforeAll` of its test file. This follows the enterprise pattern: **production code in `src/`, test code in `tests/`, linked via dot-sourcing**.

| Source File | Functions | Tested By | Mocking Required? |
|---|---|---|---|
| `AzureResourceHelpers.ps1` | Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus | PSCode-02, PSCode-03 | Yes — Mock Get-AzResource, Get-AzVM |
| `CostMonitorHelpers.ps1` | Invoke-SafeAzureCall, Send-CostAlert | PSCode-09 | Partial — Send-CostAlert needs Mock; Invoke-SafeAzureCall uses dependency injection |
| `DataProcessing.ps1` | Test-InputValidation, Split-DataIntoChunks, Process-DataChunk, Get-ProcessedData | PSCode-06 | **No** — pure functions |
| `PSCodeModuleExtracts.ps1` | Deploy-AzureResourceWithValidation, AzureResource class, AzureVirtualMachine class | PSCode-04, PSCode-05 | Partial — Deploy needs Mock; classes are pure OOP |
| `PSCodeModulesAdditional.ps1` | Get-AzureResourceInsights, Test-GitEnvironment, Deploy-ResourceGroup, Get-AzureResourceCount, Invoke-ParallelWork | PSCode-01, PSCode-07, PSCode-08 | Partial — Azure and git calls mocked; pure functions not |

---

## Pester Concepts Covered

This lab covers the following Pester 5 concepts (all annotated with `# PESTER ▶` comments in the test files):

### Test Structure
- `Describe` — top-level test suite grouping
- `Context` — sub-grouping by scenario (with independent mock scopes)
- `It` — individual test case
- `BeforeAll` / `BeforeEach` — setup (once vs per-test)
- `AfterAll` / `AfterEach` — teardown

### Assertions (`Should` operators)
- `Should -Be` — equality (case-insensitive)
- `Should -BeExactly` — equality (case-sensitive)
- `Should -BeNullOrEmpty` — null/empty check
- `Should -Not -BeNullOrEmpty` — must have a value
- `Should -Throw '*pattern*'` — exception with wildcard matching
- `Should -Match` — regex match
- `Should -BeGreaterThan` — numeric comparison
- `Should -Invoke` — mock call verification

### Mocking
- `Mock <Command> { <FakeBody> }` — replace a command
- `-ParameterFilter { $Name -eq 'x' }` — conditional mocks
- `-Verifiable` + `Should -InvokeVerifiable` — prove critical mocks ran
- `-ModuleName` — inject mocks into module scope
- Context-scoped mock overrides — different mocks per scenario
- Mocking native executables (e.g., `git`)

### Advanced Patterns
- `-TestCases @( @{...} )` — data-driven testing
- `$script:` scope — persist state across scriptblock invocations
- `TestDrive:\` — temporary file system for test isolation
- Discovery vs Execution phases — why code placement matters
- Boundary testing — systematic off-by-one detection

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `Pester not found` | `Install-Module Pester -Force -Scope CurrentUser -SkipPublisherCheck` |
| `Port 8080 in use` | `.\Start-Lab.ps1 -Web -Port 9090` |
| Old Pester version loaded | Start a **new** PowerShell session — old versions cache |
| Tests prompt for input | All tests run automatically. If any prompt, report it as a bug |
| VS Code terminal freezes | Stop the lab server (Ctrl+C) and restart, or use terminal mode |
| `Module 'Pester' version '5.0.0' was not found` | Run `.\Setup-Lab.ps1` first to install Pester |
| Coverage shows 0% | Ensure `src/` files exist — run `.\Setup-Lab.ps1` to verify |

---

## Further Reading

| Resource | Link |
|---|---|
| Pester Quick Start | [pester.dev/docs/quick-start](https://pester.dev/docs/quick-start) |
| Pester Mocking | [pester.dev/docs/usage/mocking](https://pester.dev/docs/usage/mocking) |
| Pester Code Coverage | [pester.dev/docs/usage/code-coverage](https://pester.dev/docs/usage/code-coverage) |
| Pester Module Testing | [pester.dev/docs/usage/modules](https://pester.dev/docs/usage/modules) |
| Microsoft Shift-Left Testing | [learn.microsoft.com — shift-left](https://learn.microsoft.com/en-us/devops/develop/shift-left-make-testing-fast-reliable) |
| Martin Fowler — Mocks vs Stubs | [martinfowler.com](https://martinfowler.com/articles/mocksArentStubs.html) |
