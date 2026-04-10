# ============================================================================
# Start-Lab-Day2.ps1 — Pester Lab Day 2 Launcher
#
# Runs exercises in the terminal. Users fill in ___BLANK___ placeholders
# in the exercise files, then run this to check their answers.
# Solutions are in the solutions/ folder for reference.
# ============================================================================
param([switch]$Solutions)

$labRoot = $PSScriptRoot
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$pv = (Get-Module Pester).Version

function Write-Box ($t) { $w=58; Write-Host "`n  ╔$('═'*$w)╗" -ForegroundColor Cyan; Write-Host "  ║  $($t.PadRight($w-2))║" -ForegroundColor Cyan; Write-Host "  ╚$('═'*$w)╝" -ForegroundColor Cyan }

Write-Box "Pester Lab — Day 2 · Exercises · Pester v$pv"
Write-Host ""

$folder = if ($Solutions) { 'solutions' } else { 'exercises' }
$files = Get-ChildItem (Join-Path $labRoot $folder) -Filter '*.Tests.ps1' | Sort-Object Name

if ($Solutions) {
    Write-Host "  Running SOLUTIONS (answer key)..." -ForegroundColor Yellow
} else {
    Write-Host "  Running EXERCISES (your answers)..." -ForegroundColor Green
    Write-Host "  Fill in ___BLANK___ placeholders in exercises/*.Tests.ps1" -ForegroundColor Gray
    Write-Host "  Then re-run this script to check your work." -ForegroundColor Gray
}
Write-Host ""

$exercises = @{
    '1' = 'Exercise 01 — Mocking Basics (Day 1 Review)'
    '2' = 'Exercise 02 — Should Assertions (Day 1 Review)'
    '3' = 'Exercise 03 — Data-Driven Tests (Day 1 Review)'
    '4' = 'Exercise 04 — Negative Testing (Day 2)'
    '5' = 'Exercise 05 — Boundary Testing (Day 2)'
    '6' = 'Exercise 06 — Idempotency & Coverage (Day 2)'
}

while ($true) {
    Write-Host "  ── Exercises ──" -ForegroundColor Cyan
    foreach ($k in ($exercises.Keys | Sort-Object)) {
        Write-Host "  [$k] $($exercises[$k])" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  [A] Run ALL exercises    [S] Switch to Solutions    [Q] Quit" -ForegroundColor Gray
    Write-Host ""

    $choice = Read-Host "  Select (1-6, A, S, Q)"

    if ($choice -eq 'Q' -or $choice -eq 'q') { Write-Host "`n  Goodbye!`n" -ForegroundColor Cyan; break }
    if ($choice -eq 'S' -or $choice -eq 's') {
        if ($Solutions) {
            Write-Host "  Switching to EXERCISES..." -ForegroundColor Yellow
            & $PSCommandPath
        } else {
            Write-Host "  Switching to SOLUTIONS..." -ForegroundColor Yellow
            & $PSCommandPath -Solutions
        }
        break
    }

    if ($choice -eq 'A' -or $choice -eq 'a') {
        Write-Host "`n  Running all $($files.Count) exercises...`n" -ForegroundColor Cyan
        Invoke-Pester $files.FullName -Output Detailed
    }
    elseif ($exercises.ContainsKey($choice)) {
        $file = $files | Where-Object { $_.Name -like "*$($choice.PadLeft(2,'0'))*" }
        if ($file) {
            Write-Host "`n  Running: $($exercises[$choice])`n" -ForegroundColor Cyan
            Invoke-Pester $file.FullName -Output Detailed
        } else {
            Write-Host "  File not found for exercise $choice" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  Invalid choice. Enter 1-6, A, S, or Q." -ForegroundColor Yellow
    }
    Write-Host ""
}
