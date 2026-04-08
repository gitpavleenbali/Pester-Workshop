# ============================================================================
# Setup-Lab.ps1 — Pester Lab Environment Bootstrap
# Run this FIRST before starting any exercises.
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

# ── STEP 2: Install / Update Pester ─────────────────────────────────────
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

# ── STEP 4: Verify Lab Files ───────────────────────────────────────────
Write-Host "[4/4] Verifying lab files..." -ForegroundColor White
$labRoot = $PSScriptRoot
$requiredFiles = @(
    "src/DataProcessing.ps1",
    "src/AzureResourceHelpers.ps1",
    "src/CostMonitorHelpers.ps1",
    "src/PSCodeModuleExtracts.ps1",
    "src/PSCodeModulesAdditional.ps1",
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
