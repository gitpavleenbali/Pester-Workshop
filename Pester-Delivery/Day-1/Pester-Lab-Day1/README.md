# Pester Lab — Day 1 Setup Guide

Welcome to the **Pester Lab**. This hands-on environment lets you run 107 Pester tests, explore source code, and learn unit testing patterns — all without needing an Azure subscription.

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
4. **Lab files present** — all 9 PSCode source + 9 test files exist

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
| `A` | Run all 107 tests at once |
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
| **View Test File** | Shows the test file with syntax-highlighted line numbers |
| **View PSCode Source** | Shows the source code being tested |
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
$config.CodeCoverage.Path   = '../../../PSCode'
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
└── tests/                 ← Pester test files (one per PSCode module, 107 tests total)
    ├── PSCode-01-KnowledgeRefresh.Tests.ps1    ←  5 tests: Mock, Should -Be, Should -Invoke
    ├── PSCode-02-AdvancedFunctions.Tests.ps1   ← 18 tests: -TestCases, -ParameterFilter, Should -Throw
    ├── PSCode-03-Parameters.Tests.ps1          ← 10 tests: Should -HaveParameter, BeTrue/BeFalse
    ├── PSCode-04-Classes.Tests.ps1             ← 16 tests: Constructors, state transitions, inheritance
    ├── PSCode-05-ErrorHandling.Tests.ps1       ←  7 tests: Should -Throw '*wildcard*', -Verifiable
    ├── PSCode-06-Debugging.Tests.ps1           ← 17 tests: Pure functions, -TestCases, TestDrive:
    ├── PSCode-07-GitIntegration.Tests.ps1      ←  9 tests: Mock native git, Should -Invoke -Times 0
    ├── PSCode-08-Runspaces.Tests.ps1           ←  9 tests: Should -HaveCount, edge cases, @() wrapping
    └── PSCode-09-Capstone.Tests.ps1            ← 16 tests: Boundary -TestCases, $script: scope, -Skip
```

### Source ↔ Test Mapping

Each test file dot-sources its PSCode module directly — **one source file, one test file, zero duplication**.

| PSCode Source | Functions | Tested By | Mocking? |
|---|---|---|---|
| `PSCode-Source/01_knowledge_refresh/Azure-Cloud-Analyzer.ps1` | Get-AzureResourceInsights | PSCode-01 | Yes — Mock Get-AzResource |
| `PSCode-Source/02_advanced_functions/Azure-Resource-Manager.ps1` | Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus | PSCode-02, PSCode-03 | Yes — Mock Get-AzResource, Get-AzVM |
| `PSCode-Source/03_mastering_parameters/Azure-Parameter-Mastery.ps1` | (dot-sources Module 02) | PSCode-03 | — |
| `PSCode-Source/04_powershell_classes/Azure-Classes.ps1` | AzureResource, AzureVirtualMachine, Deploy-AzureResourceWithValidation | PSCode-04, PSCode-05 | Partial — Deploy needs Mock; classes are pure OOP |
| `PSCode-Source/05_error_handling/Azure-Error-Handling.ps1` | (dot-sources Module 04) | PSCode-05 | — |
| `PSCode-Source/06_debugging/Debug-Demo.ps1` | Test-InputValidation, Split-DataIntoChunks, Process-DataChunk, Get-ProcessedData | PSCode-06 | **No** — pure functions |
| `PSCode-Source/07_git_integration/Azure-Git-Training.ps1` | Test-GitEnvironment, Deploy-ResourceGroup | PSCode-07 | Yes — Mock git, Get-AzResourceGroup |
| `PSCode-Source/08_runspaces/Azure-Runspaces.ps1` | Get-AzureResourceCount, Invoke-ParallelWork | PSCode-08 | **No** — pure functions |
| `PSCode-Source/09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1` | Invoke-SafeAzureCall, Send-CostAlert, Get-ResourceActualCost | PSCode-09 | Partial — Send-CostAlert mocks Send-MailMessage |

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
