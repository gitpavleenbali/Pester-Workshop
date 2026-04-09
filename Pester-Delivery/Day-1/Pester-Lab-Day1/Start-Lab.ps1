# ============================================================================
# Start-Lab.ps1 — Pester Lab Day 1 Launcher
#
# Two modes:
#   .\Start-Lab.ps1         Terminal mode (interactive menu in console)
#   .\Start-Lab.ps1 -Web    Browser mode (launches HTTP server + web UI)
#
# Terminal mode features:
#   - Run individual test modules (1-9) with step-by-step output
#   - Run ALL tests at once
#   - Code coverage report with visual progress bar
#   - Environment setup check
#   - Launch web UI from the menu
#
# The -Web switch starts lab-server.ps1 (HTTP API) and opens the browser.
# ============================================================================
param([switch]$Web, [int]$Port = 8080)

$labRoot = $PSScriptRoot
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$pv = (Get-Module Pester).Version

function Write-Box ($t) { $w=58; Write-Host "`n  ╔$('═'*$w)╗" -ForegroundColor Cyan; Write-Host "  ║  $($t.PadRight($w-2))║" -ForegroundColor Cyan; Write-Host "  ╚$('═'*$w)╝" -ForegroundColor Cyan }
function Write-Info ($l) { foreach ($x in $l) { Write-Host "  $x" -ForegroundColor Gray }; Write-Host "" }
function Pause-Lab { Write-Host ""; Read-Host "  Press Enter to continue" }

function Kill-OldServer {
    # Check if port is in use
    $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if (-not $conns) { return }

    # Try to kill user processes holding the port (not System PID 4)
    $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique | Where-Object { $_ -ne 4 -and $_ -ne $PID }
    foreach ($p in $pids) { try { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue } catch {} }
    if ($pids) { Start-Sleep -Milliseconds 500 }

    # Re-check: if still held by System (PID 4 = orphaned HttpListener), bump port
    $still = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($still) {
        Write-Host "  Port $Port in use (orphaned listener). Using port $(($Port+1))..." -ForegroundColor Yellow
        $script:Port = $Port + 1
    }
}

$items = [ordered]@{
    '1' = @{ Name='01 Knowledge Refresh';  File='tests/PSCode-01-KnowledgeRefresh.Tests.ps1';  Desc=@("Get-AzureResourceInsights — mocked Azure resource analysis","PSCode/01_knowledge_refresh/") }
    '2' = @{ Name='02 Advanced Functions'; File='tests/PSCode-02-AdvancedFunctions.Tests.ps1'; Desc=@("Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus","PSCode/02_advanced_functions/") }
    '3' = @{ Name='03 Parameters';         File='tests/PSCode-03-Parameters.Tests.ps1';        Desc=@("ValidateSet, Mandatory metadata, default values","PSCode/03_mastering_parameters/") }
    '4' = @{ Name='04 Classes';            File='tests/PSCode-04-Classes.Tests.ps1';           Desc=@("AzureResource, AzureVirtualMachine — constructors, inheritance","PSCode/04_powershell_classes/") }
    '5' = @{ Name='05 Error Handling';     File='tests/PSCode-05-ErrorHandling.Tests.ps1';     Desc=@("Deploy-AzureResourceWithValidation — Should -Throw","PSCode/05_error_handling/") }
    '6' = @{ Name='06 Debugging';          File='tests/PSCode-06-Debugging.Tests.ps1';         Desc=@("Test-InputValidation, Split-DataIntoChunks, Get-ProcessedData","PSCode/06_debugging/") }
    '7' = @{ Name='07 Git Integration';    File='tests/PSCode-07-GitIntegration.Tests.ps1';    Desc=@("Test-GitEnvironment (mock git), Deploy-ResourceGroup","PSCode/07_git_integration/") }
    '8' = @{ Name='08 Runspaces';          File='tests/PSCode-08-Runspaces.Tests.ps1';         Desc=@("Get-AzureResourceCount, Invoke-ParallelWork","PSCode/08_runspaces/") }
    '9' = @{ Name='09 Capstone';           File='tests/PSCode-09-Capstone.Tests.ps1';          Desc=@("Invoke-SafeAzureCall (retry), Send-CostAlert (boundary)","PSCode/09_final_solution/") }
}
$srcFiles = @(
    '../../../PSCode/01_knowledge_refresh/Azure-Cloud-Analyzer.ps1',
    '../../../PSCode/02_advanced_functions/Azure-Resource-Manager.ps1',
    '../../../PSCode/04_powershell_classes/Azure-Classes.ps1',
    '../../../PSCode/06_debugging/Debug-Demo.ps1',
    '../../../PSCode/07_git_integration/Azure-Git-Training.ps1',
    '../../../PSCode/08_runspaces/Azure-Runspaces.ps1',
    '../../../PSCode/09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1'
)

if ($Web) {
    Kill-OldServer
    $srv = Join-Path $labRoot 'lab-server.ps1'
    if (-not (Test-Path $srv)) { Write-Host "[ERROR] lab-server.ps1 not found." -ForegroundColor Red; exit 1 }
    Write-Host ""
    Write-Host "  Starting fresh server on port $Port..." -ForegroundColor Green
    Write-Host "  Pester Lab — http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "  Logs below. Ctrl+C to stop.`n" -ForegroundColor Gray
    Start-Process "http://localhost:$Port"
    & $srv -Port $Port -LabRoot $labRoot
    exit 0
}

# PESTER INTEGRATION: Run-StepByStep uses New-PesterConfiguration to:
#   - Run.PassThru = $true: returns result object for programmatic inspection
#   - Output.Verbosity = 'None': we format our own output instead of Pester's
#   - 6>&1 redirect: captures Write-Host output from inside test files
# This is the same pattern used in CI pipelines to parse test results.
function Run-StepByStep ($testFile) {
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = $testFile; $cfg.Run.PassThru = $true; $cfg.Output.Verbosity = 'None'
    # Capture Write-Host output via stream 6
    $allOut = Invoke-Pester -Configuration $cfg 6>&1
    $r = $allOut | Where-Object { $_ -isnot [System.Management.Automation.InformationRecord] }
    $infoRecs = $allOut | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }
    $infoMsgs = @()
    foreach ($ir in $infoRecs) {
        $msg = if ($ir.MessageData -is [System.Management.Automation.HostInformationMessage]) { $ir.MessageData.Message } else { "$ir" }
        if ($msg) { $infoMsgs += $msg.Trim() }
    }
    foreach ($c in $r.Containers) { foreach ($b in $c.Blocks) {
        Write-Host "`n  Describing $($b.Name)" -ForegroundColor Cyan
        foreach ($t in $b.Tests) {
            $i = if ($t.Result -eq 'Passed') { '[+]' } else { '[-]' }
            $cl = if ($t.Result -eq 'Passed') { 'Green' } else { 'Red' }
            $nm = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
            Write-Host "    $i $nm  ($([int]$t.Duration.TotalMilliseconds)ms)" -ForegroundColor $cl
            if ($t.Result -eq 'Failed') { Write-Host "       $($t.ErrorRecord.Exception.Message)" -ForegroundColor Red }
        }
        foreach ($ctx in $b.Blocks) {
            Write-Host "   Context $($ctx.Name)" -ForegroundColor DarkCyan
            foreach ($t in $ctx.Tests) {
                $i = if ($t.Result -eq 'Passed') { '[+]' } else { '[-]' }
                $cl = if ($t.Result -eq 'Passed') { 'Green' } else { 'Red' }
                $nm = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
                Write-Host "      $i $nm  ($([int]$t.Duration.TotalMilliseconds)ms)" -ForegroundColor $cl
                if ($t.Result -eq 'Failed') { Write-Host "         $($t.ErrorRecord.Exception.Message)" -ForegroundColor Red }
            }
        }
        Read-Host "`n  [Enter to continue]"
    }}
    # Show test execution log
    if ($infoMsgs.Count -gt 0) {
        Write-Host ""
        Write-Host "  ── Test Execution Log ──" -ForegroundColor Yellow
        foreach ($msg in $infoMsgs) { Write-Host "  $msg" -ForegroundColor Gray }
    }
    $pc = if ($r.FailedCount -eq 0) { 'Green' } else { 'Red' }
    Write-Host "`n  Summary: Passed $($r.PassedCount) | Failed $($r.FailedCount) | Total $($r.TotalCount)" -ForegroundColor $pc
}

# CODE COVERAGE: Uses New-PesterConfiguration with CodeCoverage enabled.
# Pester instruments the source files and tracks which lines were executed.
# The visual bar shows coverage % vs the 75% threshold.
# Enterprise teams typically set 80% — we use 75% for the workshop.
function Run-Coverage {
    $ap = $items.Values | ForEach-Object { Join-Path $labRoot $_.File }
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = $ap; $cfg.Run.PassThru = $true; $cfg.CodeCoverage.Enabled = $true
    $cfg.CodeCoverage.Path = $srcFiles | ForEach-Object { Join-Path $labRoot $_ }; $cfg.Output.Verbosity = 'Detailed'
    $r = Invoke-Pester -Configuration $cfg
    Write-Box "CODE COVERAGE REPORT"
    Write-Host ""
    $cc = $r.CodeCoverage
    if ($cc -and $cc.CommandsAnalyzedCount -gt 0) {
        $pct = [math]::Round($cc.CoveragePercent, 1); $th = 75; $bw = 40
        $fl = [math]::Floor($pct / 100 * $bw); $bar = ("█" * $fl) + ("░" * ($bw - $fl))
        Write-Host "  Coverage:  $bar  $pct%" -ForegroundColor $(if ($pct -ge $th) {'Green'} else {'Red'})
        Write-Host "  Threshold: $("─" * [math]::Floor($th / 100 * $bw))┤ $th%" -ForegroundColor Yellow
        Write-Host "`n  Analyzed: $($cc.CommandsAnalyzedCount)  Executed: $($cc.CommandsExecutedCount)  Missed: $($cc.CommandsMissedCount)  Files: $($cc.FilesAnalyzedCount)" -ForegroundColor Gray
        Write-Host ""
        if ($pct -ge $th) { Write-Host "  ✓ PASSED — $pct% ≥ $th%" -ForegroundColor Green } else { Write-Host "  ✗ FAILED — $pct% < $th%" -ForegroundColor Red }
        if ($cc.CommandsMissed.Count -gt 0) {
            Write-Host "`n  ── Top Uncovered ──" -ForegroundColor Yellow
            $cc.CommandsMissed | Group-Object Function | Sort-Object Count -Descending | Select-Object -First 6 | ForEach-Object {
                Write-Host "  $(if($_.Name){$_.Name}else{'(script)'}) — $($_.Count) lines" -ForegroundColor Yellow
            }
        }
    } else { Write-Host "  No coverage data." -ForegroundColor Red }
    Write-Host "`n  Tests: P=$($r.PassedCount) F=$($r.FailedCount)" -ForegroundColor $(if ($r.FailedCount -eq 0) {'Green'} else {'Red'})
}

function Show-Menu {
    Write-Box "Pester Lab — Day 1 · Pester v$pv"
    Write-Host ""
    Write-Host "  ── PSCode Module Tests ──" -ForegroundColor DarkGray
    foreach ($k in @('1','2','3','4','5','6','7','8','9')) { Write-Host "  [$k] $($items[$k].Name)" -ForegroundColor White }
    Write-Host ""
    Write-Host "  [A] Run ALL     [C] Coverage     [S] Setup     [W] Web UI     [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
}

while ($true) {
    Show-Menu
    $ch = Read-Host "  Select"
    switch ($ch.ToUpper()) {
        { $_ -in @('1','2','3','4','5','6','7','8','9') } {
            $it = $items[$ch]; Write-Box $it.Name; Write-Info $it.Desc
            Run-StepByStep (Join-Path $labRoot $it.File); Pause-Lab
        }
        'A' { Write-Box "Running ALL"; $ap = $items.Values | ForEach-Object {Join-Path $labRoot $_.File}; Invoke-Pester $ap -Output Detailed; Pause-Lab }
        'C' { Write-Box "Code Coverage"; Write-Info @("Threshold: 75%"); Run-Coverage; Pause-Lab }
        'S' { Write-Box "Environment Check"; & (Join-Path $labRoot 'Setup-Lab.ps1'); Pause-Lab }
        'W' {
            Kill-OldServer
            $srv = Join-Path $labRoot 'lab-server.ps1'
            if (-not (Test-Path $srv)) { Write-Host "  lab-server.ps1 not found" -ForegroundColor Red; continue }
            Write-Host "`n  Starting fresh server on port $Port..." -ForegroundColor Cyan
            Start-Process "http://localhost:$Port"
            & $srv -Port $Port -LabRoot $labRoot
        }
        'Q' { Write-Host "`n  Goodbye!`n" -ForegroundColor Green; exit 0 }
        default { Write-Host "  Invalid. Enter 1-9, A, C, S, W, or Q." -ForegroundColor Red }
    }
}