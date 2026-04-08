# lab-server.ps1 — Pester Lab HTTP Server
param([int]$Port = 8080, [string]$LabRoot)
if (-not $LabRoot) { $LabRoot = $PSScriptRoot }

Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$pv = (Get-Module Pester).Version
Write-Host "[OK] Pester $pv" -ForegroundColor Green

$testFiles = @{
    '1'='tests/PSCode-01-KnowledgeRefresh.Tests.ps1'
    '2'='tests/PSCode-02-AdvancedFunctions.Tests.ps1'
    '3'='tests/PSCode-03-Parameters.Tests.ps1'
    '4'='tests/PSCode-04-Classes.Tests.ps1'
    '5'='tests/PSCode-05-ErrorHandling.Tests.ps1'
    '6'='tests/PSCode-06-Debugging.Tests.ps1'
    '7'='tests/PSCode-07-GitIntegration.Tests.ps1'
    '8'='tests/PSCode-08-Runspaces.Tests.ps1'
    '9'='tests/PSCode-09-Capstone.Tests.ps1'
}
$srcPaths = @('src/DataProcessing.ps1','src/AzureResourceHelpers.ps1','src/CostMonitorHelpers.ps1','src/PSCodeModuleExtracts.ps1','src/PSCodeModulesAdditional.ps1')

function Invoke-Lab {
    param([string[]]$Path, [switch]$Coverage)
    $cfg = New-PesterConfiguration
    $cfg.Run.Path = $Path
    $cfg.Run.PassThru = $true
    $cfg.Output.Verbosity = 'None'
    if ($Coverage) {
        $cfg.CodeCoverage.Enabled = $true
        $cfg.CodeCoverage.Path = $srcPaths | ForEach-Object { Join-Path $LabRoot $_ }
    }
    # Capture Write-Host output via stream 6 redirect
    $allOutput = Invoke-Pester -Configuration $cfg 6>&1
    $r = $allOutput | Where-Object { $_ -isnot [System.Management.Automation.InformationRecord] }
    $infoRecords = $allOutput | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }
    # Build a map of info messages (they come in order)
    $infoMessages = @()
    foreach ($ir in $infoRecords) {
        $msg = if ($ir.MessageData -is [System.Management.Automation.HostInformationMessage]) { $ir.MessageData.Message } else { "$ir" }
        if ($msg) { $infoMessages += $msg.Trim() }
    }

    # Build output lines
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("Pester v$pv")
    $lines.Add("")
    $infoIdx = 0
    foreach ($con in $r.Containers) {
        foreach ($blk in $con.Blocks) {
            $lines.Add("Describing $($blk.Name)")
            foreach ($t in $blk.Tests) {
                $ico = if ($t.Result -eq 'Passed') { '[+]' } else { '[-]' }
                $tName = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
                $lines.Add("  $ico $tName  ($([int]$t.Duration.TotalMilliseconds)ms)")
                if ($t.Result -eq 'Failed' -and $t.ErrorRecord) { $lines.Add("     $($t.ErrorRecord.Exception.Message)") }
            }
            foreach ($ctx in $blk.Blocks) {
                $lines.Add(" Context $($ctx.Name)")
                foreach ($t in $ctx.Tests) {
                    $ico = if ($t.Result -eq 'Passed') { '[+]' } else { '[-]' }
                    $tName = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
                    $lines.Add("    $ico $tName  ($([int]$t.Duration.TotalMilliseconds)ms)")
                    if ($t.Result -eq 'Failed' -and $t.ErrorRecord) { $lines.Add("       $($t.ErrorRecord.Exception.Message)") }
                }
            }
            $lines.Add("")
        }
    }
    $lines.Add("Tests Passed: $($r.PassedCount), Failed: $($r.FailedCount), Total: $($r.TotalCount)")

    # Add test execution log (Write-Host output from tests)
    if ($infoMessages.Count -gt 0) {
        $lines.Add("")
        $lines.Add("── Test Execution Log ──")
        foreach ($msg in $infoMessages) { $lines.Add($msg) }
    }

    $cov = '-'
    $covPct = 0
    $covAnalyzed = 0; $covExecuted = 0; $covMissed = 0; $covFiles = 0
    $missedFuncs = @()
    if ($Coverage -and $r.CodeCoverage -and $r.CodeCoverage.CommandsAnalyzedCount -gt 0) {
        $cc = $r.CodeCoverage
        $covPct = [math]::Round($cc.CoveragePercent, 1)
        $cov = "$covPct%"
        $covAnalyzed = $cc.CommandsAnalyzedCount
        $covExecuted = $cc.CommandsExecutedCount
        $covMissed = $cc.CommandsMissedCount
        $covFiles = $cc.FilesAnalyzedCount
        $lines.Add("Coverage: $cov (threshold: 75%)")
        $missedFuncs = $cc.CommandsMissed | Group-Object Function | Sort-Object Count -Descending | Select-Object -First 8 | ForEach-Object {
            @{ name = if ($_.Name) { $_.Name } else { '(script)' }; lines = $_.Count }
        }
    }

    return @{
        passed = [int]$r.PassedCount
        failed = [int]$r.FailedCount
        total = [int]$r.TotalCount
        coverage = $cov
        coveragePct = $covPct
        covAnalyzed = $covAnalyzed
        covExecuted = $covExecuted
        covMissed = $covMissed
        covFiles = $covFiles
        missedFuncs = $missedFuncs
        output = ($lines -join "`n")
    }
}

function Send-Response ($res, $data, $type) {
    $bytes = if ($data -is [byte[]]) { $data } else { [System.Text.Encoding]::UTF8.GetBytes($data) }
    $res.ContentType = $type
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
try { $listener.Start() } catch { Write-Host "[ERROR] Port $Port in use" -ForegroundColor Red; exit 1 }
Write-Host "  http://localhost:$Port" -ForegroundColor Green
Write-Host "  Ctrl+C to stop`n" -ForegroundColor Gray

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $res = $ctx.Response
        $path = $ctx.Request.Url.LocalPath
        try {
            if ($path -eq '/') {
                Send-Response $res ([System.IO.File]::ReadAllBytes((Join-Path $LabRoot 'lab-ui/index.html'))) 'text/html; charset=utf-8'
            }
            elseif ($path -eq '/api/setup') {
                Write-Host "[SETUP]" -ForegroundColor Yellow
                $setupScript = Join-Path $LabRoot 'Setup-Lab.ps1'
                # Use PowerShell to capture ALL output including Write-Host
                $out = & pwsh -NoProfile -Command "& '$setupScript'" 2>&1 | Out-String
                if (-not $out) { $out = "Setup completed (no output captured)" }
                Send-Response $res (@{output=$out;passed=0;failed=0;total=0;coverage='-';coveragePct=0} | ConvertTo-Json -Compress) 'application/json'
                Write-Host " Done" -ForegroundColor Green
            }
            elseif ($path -match '^/api/run/(\d)$') {
                $n = $Matches[1]
                Write-Host "[RUN] $n " -ForegroundColor Yellow -NoNewline
                $r = Invoke-Lab -Path (Join-Path $LabRoot $testFiles[$n])
                Send-Response $res ($r | ConvertTo-Json -Compress -Depth 5) 'application/json'
                Write-Host "P:$($r.passed) F:$($r.failed)" -ForegroundColor $(if($r.failed -eq 0){'Green'}else{'Red'})
            }
            elseif ($path -match '^/api/tests/(\d)$') {
                $n = $Matches[1]
                $tf = Join-Path $LabRoot $testFiles[$n]
                $cfg = New-PesterConfiguration
                $cfg.Run.Path = $tf; $cfg.Run.PassThru = $true; $cfg.Run.SkipRun = $true; $cfg.Output.Verbosity = 'None'
                $disc = Invoke-Pester -Configuration $cfg
                # Read the source file for code extraction
                $srcLines = @()
                try { $srcLines = Get-Content $tf } catch {}
                $testList = @()
                foreach ($con in $disc.Containers) { foreach ($blk in $con.Blocks) {
                    foreach ($t in $blk.Tests) {
                        $startLine = $t.ScriptBlock.StartPosition.StartLine
                        $code = ''
                        if ($srcLines.Count -gt 0 -and $startLine -gt 0) {
                            # Extract just the It block by tracking brace depth
                            $depth = 0; $end = $startLine - 1
                            for ($i = $startLine - 1; $i -lt $srcLines.Count; $i++) {
                                $depth += ($srcLines[$i].ToCharArray() | Where-Object { $_ -eq '{' }).Count
                                $depth -= ($srcLines[$i].ToCharArray() | Where-Object { $_ -eq '}' }).Count
                                $end = $i
                                if ($depth -le 0 -and $i -gt $startLine - 1) { break }
                            }
                            # Also grab 2 comment lines above the It
                            $commentStart = $startLine - 1
                            for ($j = $startLine - 2; $j -ge [math]::Max(0, $startLine - 4); $j--) {
                                if ($srcLines[$j].Trim() -match '^\s*#') { $commentStart = $j } else { break }
                            }
                            $code = ($srcLines[$commentStart..$end] -join "`n").TrimEnd()
                        }
                        $testList += @{ name = $t.ExpandedName; block = $blk.Name; startLine = $commentStart + 1; code = $code }
                    }
                    foreach ($ctx in $blk.Blocks) { foreach ($t in $ctx.Tests) {
                        $startLine = $t.ScriptBlock.StartPosition.StartLine
                        $code = ''
                        if ($srcLines.Count -gt 0 -and $startLine -gt 0) {
                            $depth = 0; $end = $startLine - 1
                            for ($i = $startLine - 1; $i -lt $srcLines.Count; $i++) {
                                $depth += ($srcLines[$i].ToCharArray() | Where-Object { $_ -eq '{' }).Count
                                $depth -= ($srcLines[$i].ToCharArray() | Where-Object { $_ -eq '}' }).Count
                                $end = $i
                                if ($depth -le 0 -and $i -gt $startLine - 1) { break }
                            }
                            $commentStart = $startLine - 1
                            for ($j = $startLine - 2; $j -ge [math]::Max(0, $startLine - 4); $j--) {
                                if ($srcLines[$j].Trim() -match '^\s*#') { $commentStart = $j } else { break }
                            }
                            $code = ($srcLines[$commentStart..$end] -join "`n").TrimEnd()
                        }
                        $testList += @{ name = $t.ExpandedName; block = $blk.Name; context = $ctx.Name; startLine = $commentStart + 1; code = $code }
                    }}
                }}
                Send-Response $res (@{tests=$testList;count=$testList.Count;file=$testFiles[$n]} | ConvertTo-Json -Compress -Depth 5) 'application/json'
            }
            elseif ($path -match '^/api/run/(\d)/(.+)$') {
                # Run a single test by name filter
                $n = $Matches[1]; $filter = [System.Web.HttpUtility]::UrlDecode($Matches[2])
                Write-Host "[RUN] $n/$filter " -ForegroundColor Yellow -NoNewline
                $cfg = New-PesterConfiguration
                $cfg.Run.Path = Join-Path $LabRoot $testFiles[$n]
                $cfg.Run.PassThru = $true; $cfg.Output.Verbosity = 'None'
                $cfg.Filter.FullName = "*$filter*"
                # Capture Write-Host via stream 6
                $allOut = Invoke-Pester -Configuration $cfg 6>&1
                $r2 = $allOut | Where-Object { $_ -isnot [System.Management.Automation.InformationRecord] }
                $infoRecs = $allOut | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }
                $infoMsgs = @()
                foreach ($ir in $infoRecs) {
                    $msg = if ($ir.MessageData -is [System.Management.Automation.HostInformationMessage]) { $ir.MessageData.Message } else { "$ir" }
                    if ($msg) { $infoMsgs += $msg.Trim() }
                }
                $lines = [System.Collections.Generic.List[string]]::new()
                foreach ($con in $r2.Containers) { foreach ($blk in $con.Blocks) {
                    foreach ($t in $blk.Tests) {
                        $nm = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
                        if ($t.Result -eq 'Passed') { $lines.Add("[+] $nm ($([int]$t.Duration.TotalMilliseconds)ms)") }
                        elseif ($t.Result -eq 'Failed') { $lines.Add("[-] $nm ($([int]$t.Duration.TotalMilliseconds)ms)"); $lines.Add("   $($t.ErrorRecord.Exception.Message)") }
                        else { $lines.Add("[.] $nm (skipped)") }
                    }
                    foreach ($ctx in $blk.Blocks) { foreach ($t in $ctx.Tests) {
                        $nm = if ($t.ExpandedName) { $t.ExpandedName } else { $t.Name }
                        if ($t.Result -eq 'Passed') { $lines.Add("[+] $nm ($([int]$t.Duration.TotalMilliseconds)ms)") }
                        elseif ($t.Result -eq 'Failed') { $lines.Add("[-] $nm ($([int]$t.Duration.TotalMilliseconds)ms)"); $lines.Add("   $($t.ErrorRecord.Exception.Message)") }
                        else { $lines.Add("[.] $nm (skipped)") }
                    }}
                }}
                $lines.Add(""); $lines.Add("Passed: $($r2.PassedCount), Failed: $($r2.FailedCount)")
                # Add test execution log
                if ($infoMsgs.Count -gt 0) {
                    $lines.Add("")
                    $lines.Add("── Test Execution Log ──")
                    foreach ($msg in $infoMsgs) { $lines.Add($msg) }
                }
                $result = @{passed=[int]$r2.PassedCount;failed=[int]$r2.FailedCount;total=[int]$r2.TotalCount;coverage='-';coveragePct=0;output=($lines -join "`n")}
                Send-Response $res ($result | ConvertTo-Json -Compress -Depth 5) 'application/json'
                Write-Host "P:$($r2.PassedCount) F:$($r2.FailedCount)" -ForegroundColor $(if($r2.FailedCount -eq 0){'Green'}else{'Red'})
            }
            elseif ($path -match '^/api/file/(.+)$') {
                $fileName = [System.Web.HttpUtility]::UrlDecode($Matches[1])
                $filePath = Join-Path $LabRoot $fileName
                if (Test-Path $filePath) {
                    $content = [System.IO.File]::ReadAllText($filePath)
                    Send-Response $res (@{content=$content;file=$fileName} | ConvertTo-Json -Compress -Depth 3) 'application/json'
                } else {
                    $res.StatusCode = 404
                    Send-Response $res '{"error":"file not found"}' 'application/json'
                }
            }
            elseif ($path -eq '/api/all') {
                Write-Host "[ALL] " -ForegroundColor Yellow -NoNewline
                $ap = $testFiles.Values | ForEach-Object { Join-Path $LabRoot $_ }
                $r = Invoke-Lab -Path $ap
                Send-Response $res ($r | ConvertTo-Json -Compress -Depth 5) 'application/json'
                Write-Host "P:$($r.passed) F:$($r.failed)" -ForegroundColor $(if($r.failed -eq 0){'Green'}else{'Red'})
            }
            elseif ($path -eq '/api/cov') {
                Write-Host "[COV] " -ForegroundColor Yellow -NoNewline
                $ap = $testFiles.Values | ForEach-Object { Join-Path $LabRoot $_ }
                $r = Invoke-Lab -Path $ap -Coverage
                Send-Response $res ($r | ConvertTo-Json -Compress -Depth 5) 'application/json'
                Write-Host "$($r.coverage)" -ForegroundColor Cyan
            }
            elseif ($path -eq '/api/exit') {
                Write-Host "[EXIT] Shutting down server..." -ForegroundColor Red
                Send-Response $res '{"status":"stopped"}' 'application/json'
                $res.Close()
                $listener.Stop()
                break
            }
            else {
                $res.StatusCode = 404
                Send-Response $res '{"error":"not found"}' 'application/json'
            }
        } catch {
            Write-Host " [ERR] $($_.Exception.Message)" -ForegroundColor Red
            try { Send-Response $res (@{output="Error: $($_.Exception.Message)";passed=0;failed=0;total=0;coverage='-';coveragePct=0} | ConvertTo-Json -Compress) 'application/json' } catch {}
        } finally {
            try { $res.Close() } catch {}
        }
    }
} finally {
    $listener.Stop(); $listener.Dispose()
    Write-Host "`n[STOPPED]" -ForegroundColor Yellow
}
