# Lab Setup Guide

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| PowerShell | 5.1 | 7.2+ |
| Pester | 5.0.0 | 5.7.1 |
| OS | Windows 10+ | Any (Windows/Linux/macOS) |
| Editor | Any | VS Code + PowerShell extension |

## Step 1 — Install Pester

```powershell
Install-Module -Name Pester -Force -Scope CurrentUser
Import-Module Pester -PassThru   # Should show version 5.x
```

## Step 2 — Verify Environment

```powershell
cd Pester-Delivery/Day-1/Pester-Lab-Day1
.\Setup-Lab.ps1
```

This checks:
- PowerShell version
- Pester installation and import
- All lab files present (5 source + 9 test files)

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

- Type `1` through `9` to run a module's tests step-by-step
- Type `A` to run all 96 tests
- Type `C` for code coverage report (threshold: 75%)
- Type `W` to switch to browser mode

### Option B: Browser Mode (localhost UI)

```powershell
.\Start-Lab.ps1 -Web
```

- Opens `http://localhost:8080` in your browser
- Sidebar: 9 PSCode modules + Environment Check / Run All / Coverage
- Each module shows: description, individual tests (expandable with code), Run and Explain buttons
- Terminal pane: colored test output with execution log
- Dashboard: pass/fail/total/coverage stats
- Progress tracker: 0/9 → fills as you complete modules

### Option C: Direct Pester commands

```powershell
# Run a single module
Invoke-Pester ./tests/PSCode-01-KnowledgeRefresh.Tests.ps1 -Output Detailed

# Run all tests
Invoke-Pester ./tests -Output Detailed

# Run with code coverage
$config = New-PesterConfiguration
$config.Run.Path = './tests'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = './src'
$config.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $config
```

## File Structure

```
Pester-Lab-Day1/
├── Setup-Lab.ps1          ← Run first — checks prerequisites
├── Start-Lab.ps1          ← Main entry point (terminal or -Web)
├── lab-server.ps1         ← HTTP server for browser UI
├── lab-ui/
│   └── index.html         ← Browser-based lab interface
├── src/                   ← Source functions (extracted from PSCode)
│   ├── DataProcessing.ps1
│   ├── AzureResourceHelpers.ps1
│   ├── CostMonitorHelpers.ps1
│   ├── PSCodeModuleExtracts.ps1
│   └── PSCodeModulesAdditional.ps1
└── tests/                 ← Pester test files (one per PSCode module)
    ├── PSCode-01-KnowledgeRefresh.Tests.ps1
    ├── PSCode-02-AdvancedFunctions.Tests.ps1
    ├── PSCode-03-Parameters.Tests.ps1
    ├── PSCode-04-Classes.Tests.ps1
    ├── PSCode-05-ErrorHandling.Tests.ps1
    ├── PSCode-06-Debugging.Tests.ps1
    ├── PSCode-07-GitIntegration.Tests.ps1
    ├── PSCode-08-Runspaces.Tests.ps1
    └── PSCode-09-Capstone.Tests.ps1
```

## Troubleshooting

| Issue | Fix |
|---|---|
| `Pester not found` | `Install-Module Pester -Force -Scope CurrentUser` |
| `Port 8080 in use` | `.\Start-Lab.ps1 -Web -Port 9090` |
| Tests prompt for input | All tests should run automatically — report if any prompt |
| VS Code freezes | Stop the browser lab server (Ctrl+C), use terminal mode instead |
