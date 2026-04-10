# ============================================================================
# Setup-Lab.ps1 — Pester Lab Environment Bootstrap
# Run this FIRST before starting any exercises.
#
# This script checks 4 prerequisites:
#   1. PowerShell version (5.1+ required, 7+ recommended)
#   2. Pester framework installed (auto-installs 5.x if missing)
#   3. Pester module can be imported into the session
#   4. All 14 lab files exist (5 source + 9 test files)
#
# WHY THIS MATTERS:
#   Pester 5.x has breaking changes from 4.x (shipped with Windows).
#   This script ensures the correct version is installed and working
#   before attendees start the workshop, preventing setup issues.
#
# Usage: .\Setup-Lab.ps1
# ============================================================================

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Pester Lab — Environment Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# ── STEP 1: PowerShell Version ──────────────────────────────────────────
Write-Host "[1/4] Checking PowerShell version..." -ForegroundColor White
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -ge 7) {
    Write-Host "  OK  PowerShell $($psVer) — all features available" -ForegroundColor Green
} elseif ($psVer.Major -eq 5 -and $psVer.Minor -ge 1) {
    Write-Host "  OK  PowerShell $($psVer) — compatible (7+ recommended)" -ForegroundColor Yellow
} else {
    Write-Host "  FAIL  PowerShell $($psVer) — version 5.1+ required" -ForegroundColor Red
    Write-Host "        Install: winget install Microsoft.PowerShell" -ForegroundColor Gray
    $allGood = $false
}

# STEP 2: Install / Update Pester ─────────────────────────────────────────
# Windows ships with Pester 3.x/4.x which is INCOMPATIBLE with this lab.
# We need Pester 5.x for: New-PesterConfiguration, Should -Invoke,
# Discovery/Run phase separation, and modern mock scoping.
# -SkipPublisherCheck bypasses the signature check for the bundled 3.x version.
Write-Host "[2/4] Checking Pester framework..." -ForegroundColor White
$pester = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if (-not $pester -or $pester.Version -lt [version]'5.0.0') {
    Write-Host "  ...  Installing Pester 5.x (this may take a moment)" -ForegroundColor Yellow
    try {
        # Ensure NuGet provider is available (prevents blocking prompt)
        $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue
        Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber -ErrorAction Stop
        $pester = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        Write-Host "  OK  Pester $($pester.Version) installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  FAIL  Could not install Pester: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "        Try: Install-Module -Name Pester -Force -Scope CurrentUser" -ForegroundColor Gray
        $allGood = $false
    }
} else {
    Write-Host "  OK  Pester $($pester.Version) already installed" -ForegroundColor Green
}

# ── STEP 3: Import Pester ───────────────────────────────────────────────
Write-Host "[3/4] Importing Pester module..." -ForegroundColor White
try {
    Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
    $loaded = Get-Module Pester
    Write-Host "  OK  Pester $($loaded.Version) loaded into session" -ForegroundColor Green
} catch {
    Write-Host "  FAIL  Could not import Pester: $($_.Exception.Message)" -ForegroundColor Red
    $allGood = $false
}

# STEP 4: Verify Lab Files ───────────────────────────────────────────
# Checks that all PSCode source files and 9 test files are present.
# Source functions live directly in PSCode/ modules — one file per module.
# Tests dot-source PSCode/*.ps1 files — single source of truth.
Write-Host "[4/4] Verifying lab files..." -ForegroundColor White
$labRoot = $PSScriptRoot
$requiredFiles = @(
    "../../PSCode-Source/01_knowledge_refresh/Azure-Cloud-Analyzer.ps1",
    "../../PSCode-Source/02_advanced_functions/Azure-Resource-Manager.ps1",
    "../../PSCode-Source/04_powershell_classes/Azure-Classes.ps1",
    "../../PSCode-Source/06_debugging/Debug-Demo.ps1",
    "../../PSCode-Source/07_git_integration/Azure-Git-Training.ps1",
    "../../PSCode-Source/08_runspaces/Azure-Runspaces.ps1",
    "../../PSCode-Source/09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1",
    "tests/PSCode-01-KnowledgeRefresh.Tests.ps1",
    "tests/PSCode-02-AdvancedFunctions.Tests.ps1",
    "tests/PSCode-03-Parameters.Tests.ps1",
    "tests/PSCode-04-Classes.Tests.ps1",
    "tests/PSCode-05-ErrorHandling.Tests.ps1",
    "tests/PSCode-06-Debugging.Tests.ps1",
    "tests/PSCode-07-GitIntegration.Tests.ps1",
    "tests/PSCode-08-Runspaces.Tests.ps1",
    "tests/PSCode-09-Capstone.Tests.ps1"
)

$missing = @()
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $labRoot $file
    if (-not (Test-Path $fullPath)) {
        $missing += $file
    }
}

if ($missing.Count -eq 0) {
    Write-Host "  OK  All $($requiredFiles.Count) lab files found" -ForegroundColor Green
} else {
    Write-Host "  FAIL  Missing files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "        - $_" -ForegroundColor Gray }
    $allGood = $false
}

# ── Summary ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "  READY! You can start the lab." -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  cd $labRoot" -ForegroundColor Gray
    Write-Host "  Invoke-Pester ./tests -Output Detailed" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or launch the interactive lab:" -ForegroundColor White
    Write-Host "  .\Start-Lab.ps1" -ForegroundColor Gray
} else {
    Write-Host "  ISSUES FOUND — fix them above." -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Cyan
}
Write-Host ""
