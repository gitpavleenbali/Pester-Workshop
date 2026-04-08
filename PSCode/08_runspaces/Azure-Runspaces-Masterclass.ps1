# ==============================================================================================
# 08. Runspaces and Parallelism: Advanced Performance Masterclass
# Purpose: Master PowerShell runspaces for concurrent execution, thread safety, and Azure automation at scale
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\08_runspaces\Azure-Runspaces-Masterclass.ps1
#
# Prerequisites: PowerShell 5.1+, Az PowerShell module, AzCLI, Git, authenticated Azure session
# ==============================================================================================

# ==============================================================================================
# PREREQUISITE CHECK: PowerShell Version
# ==============================================================================================
Write-Host "[CHECK] Verifying PowerShell version..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
Write-Host "[INFO] PowerShell version detected: $($psVersion.ToString())" -ForegroundColor Gray

if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   POWERSHELL VERSION NOT SUPPORTED                            ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "This masterclass requires PowerShell 5.1 or later." -ForegroundColor Yellow
    Write-Host "Current version detected: PowerShell $($psVersion.ToString())" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install PowerShell 7 (recommended) with: winget install Microsoft.PowerShell" -ForegroundColor Green
    Write-Host ""
    exit 1
}
elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -eq 1) {
    Write-Host "[SUCCESS] PowerShell 5.1 detected - core features available" -ForegroundColor Green
    Write-Host "[INFO] Some demonstrations (ThreadJob, ForEach-Object -Parallel) require PowerShell 7+" -ForegroundColor Cyan
}
else {
    Write-Host "[SUCCESS] PowerShell 7+ detected - all features available!" -ForegroundColor Green
}

Write-Host ""

# ==============================================================================================
# PREREQUISITE CHECK: Azure PowerShell Module
# ==============================================================================================
Write-Host "[CHECK] Verifying Azure PowerShell module..." -ForegroundColor Cyan
$azModule = Get-Module -Name Az.Accounts -ListAvailable -ErrorAction SilentlyContinue

if (-not $azModule) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      AZURE MODULE NOT INSTALLED                               ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "The Azure PowerShell module (Az) is required to run the Azure-integrated demonstrations." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install the Azure module, run this command in PowerShell (as Administrator):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Install-Module -Name Az -Repository PSGallery -Force -AllowClobber" -ForegroundColor Green
    Write-Host ""
    Write-Host "After installation completes, run this script again." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For more information, visit: https://learn.microsoft.com/powershell/azure/install-azure-powershell" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "[SUCCESS] Azure PowerShell module found!" -ForegroundColor Green

Write-Host "[CHECK] Verifying Azure CLI..." -ForegroundColor Cyan
try {
    $azCliVersion = az version 2>$null | ConvertFrom-Json
    Write-Host "[SUCCESS] Azure CLI found - Version: $($azCliVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      AZURE CLI NOT INSTALLED                                  ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Azure CLI is required for Azure-integrated demonstrations." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install Azure CLI, visit: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Cyan
    Write-Host "Or use winget: winget install Microsoft.AzureCLI" -ForegroundColor Green
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[CHECK] Verifying Git installation..." -ForegroundColor Cyan
try {
    $gitVersionOutput = git --version 2>$null
    if (-not [string]::IsNullOrWhiteSpace($gitVersionOutput)) {
        Write-Host "[SUCCESS] Git found - $gitVersionOutput" -ForegroundColor Green
    }
    else {
        throw "Git not found"
    }
}
catch {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                          GIT NOT INSTALLED                                    ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Git is required for source control demonstrations." -ForegroundColor Yellow
    Write-Host "Install it with: winget install Git.Git" -ForegroundColor Green
    Write-Host "More info: https://git-scm.com/downloads" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[CHECK] Verifying Azure authentication..." -ForegroundColor Cyan
try {
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                      AZURE NOT AUTHENTICATED                                  ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        Write-Host "You need to authenticate with Azure first." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Run one of these commands to authenticate:" -ForegroundColor Cyan
        Write-Host "    Connect-AzAccount                    # Interactive login" -ForegroundColor Green
        Write-Host "    az login                             # Azure CLI login" -ForegroundColor Green
        Write-Host ""
        Write-Host "After authentication completes, run this script again." -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }

    Write-Host "[SUCCESS] Azure authentication verified!" -ForegroundColor Green
    Write-Host "[INFO] Current subscription: $($azContext.Subscription.Name)" -ForegroundColor Gray
    Write-Host "[INFO] Subscription ID: $($azContext.Subscription.Id)" -ForegroundColor Gray
    Write-Host "[INFO] Tenant: $($azContext.Tenant.Id)" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Failed to check Azure authentication: $_" -ForegroundColor Red
    Write-Host "Please ensure Azure PowerShell module is properly installed and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[AZURE] Azure module available for advanced scenarios" -ForegroundColor Cyan
$useAzure = Read-Host "Enable Azure-integrated demonstrations? (y/N)"

if ($useAzure -match '^[Yy]') {
    $global:AzureEnabled = $true
    Write-Host "[INFO] Azure-integrated runspace demos enabled" -ForegroundColor Green
} else {
    $global:AzureEnabled = $false
    Write-Host "[INFO] Continuing with local demonstrations only" -ForegroundColor Gray
}
Write-Host ""

Write-Host "[INFO] Starting PowerShell Runspaces and Parallelism Workshop..." -ForegroundColor Cyan
Write-Host "[INFO] Initializing concurrent execution environment..." -ForegroundColor Gray

$separator = "=" * 80
Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 1: RUNSPACE FUNDAMENTALS - What is a runspace and why it matters
# ============================================================================
# EXPLANATION: A runspace is a PowerShell execution thread owned by a host (console, ISE, VS Code)
# - Default: You use the host's single runspace sequentially
# - Advanced: Create additional runspaces to execute commands asynchronously in parallel
# - [PowerShell] class represents commands that a runspace will execute
# - Key benefit: Lightweight threads in the same process vs. separate process (jobs)
Write-Host "[CONCEPT 1] Runspace Fundamentals" -ForegroundColor White
Write-Host "Hello Runspace: Synchronous vs. Asynchronous execution" -ForegroundColor Gray

Write-Host "[DEMO 1A] Synchronous Runspace Execution" -ForegroundColor Yellow
Write-Host "Pattern: Create to AddScript to Invoke to Dispose (blocks until complete)" -ForegroundColor Gray

$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $ps = [PowerShell]::Create()
    $ps.AddScript({ 'Hello from synchronous runspace!' }) | Out-Null
    $result = $ps.Invoke()
    Write-Host "[RESULT] $result" -ForegroundColor Cyan
    Write-Host "[TIMING] Elapsed: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Gray
}
finally {
    $ps.Dispose()
}

Write-Host "[DEMO 1B] Asynchronous Runspace Execution" -ForegroundColor Yellow
Write-Host "Pattern: Create to AddScript to BeginInvoke to work continues to EndInvoke" -ForegroundColor Gray

$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $ps = [PowerShell]::Create()
    $ps.AddScript({
        Start-Sleep -Seconds 2
        'Hello from asynchronous runspace (after 2s sleep)!'
    }) | Out-Null
    
    $asyncResult = $ps.BeginInvoke()
    
    for ($i = 1; $i -le 6; $i++) {
        Write-Host "  [FOREGROUND] Doing work in main thread, iteration $i" -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
    }
    
    $result = $ps.EndInvoke($asyncResult)
    Write-Host "[RESULT] $result" -ForegroundColor Cyan
    Write-Host "[TIMING] Total: $($sw.ElapsedMilliseconds) ms (runspace worked during main loop)" -ForegroundColor Green
}
finally {
    $ps.Dispose()
}

Write-Host "[SUCCESS] Synchronous vs asynchronous runspace execution demonstrated" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to Runspaces vs Jobs comparison..." -ForegroundColor Magenta
$pause1 = Read-Host


# ============================================================================
# CONCEPT 2: RUNSPACES VS JOBS - Performance and scalability comparison
# ============================================================================
# EXPLANATION: Both enable parallelism but with tradeoffs:
# - Jobs: Start separate PowerShell processes (200+ MB per job, high overhead, but fully isolated)
# - Runspaces: Create threads in same process (lightweight, fast startup, shared memory scope)
# - Use Jobs: Complex work, long-running, isolation needed
# - Use Runspaces: Tight loops, minimal data, performance-critical
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 2] Runspaces vs Jobs - Parallelism Architectures" -ForegroundColor White
Write-Host "Benchmark: Create 5 parallel tasks, measure resource usage and timing" -ForegroundColor Gray

Write-Host "`n[DEMO 2A] Using PowerShell Jobs (separate process per task)" -ForegroundColor Yellow

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$jobs = @()

for ($i = 1; $i -le 5; $i++) {
    $job = Start-Job -ScriptBlock {
        Start-Sleep -Seconds 1
        "Job $_"
    } -ArgumentList $i
    $jobs += $job
}

Write-Host "  Created 5 jobs (each is separate PowerShell process)" -ForegroundColor Gray
$results = $jobs | Wait-Job | Receive-Job
Write-Host "[TIMING] Jobs completed in $($sw.ElapsedMilliseconds) ms" -ForegroundColor Green
foreach ($result in $results) {
    Write-Host "  [RESULT] $result" -ForegroundColor Cyan
}
$jobs | Remove-Job

Write-Host "`n[DEMO 2B] Using PowerShell Runspaces (lightweight threads in same process)" -ForegroundColor Yellow

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$psInstances = @()
$asyncResults = @()

for ($i = 1; $i -le 5; $i++) {
    $ps = [PowerShell]::Create()
    $ps.AddScript([scriptblock]::Create("Start-Sleep -Seconds 1; 'Runspace {0}'" -f $i)) | Out-Null
    $asyncResults += @{
        PowerShell = $ps
        AsyncResult = $ps.BeginInvoke()
        TaskId = $i
    }
    $psInstances += $ps
}

Write-Host "  Created 5 runspaces (all in same process)" -ForegroundColor Gray
Start-Sleep -Seconds 2

foreach ($item in $asyncResults) {
    $result = $item.PowerShell.EndInvoke($item.AsyncResult)
    Write-Host "  [RESULT] Task $($item.TaskId): $result" -ForegroundColor Cyan
}
Write-Host "[TIMING] Runspaces completed in $($sw.ElapsedMilliseconds) ms (faster, less overhead)" -ForegroundColor Green

foreach ($ps in $psInstances) { $ps.Dispose() }

Write-Host "[SUCCESS] True parallelism demonstrated" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to Thread-Safe Logging..." -ForegroundColor Magenta
$pause2 = Read-Host


# ============================================================================
# CONCEPT 3: THREAD-SAFE LOGGING WITH MUTEX AND BUFFERING
# ============================================================================
# EXPLANATION: When multiple runspaces access shared resources (files, databases), race conditions occur
# - Unsafe: Multiple threads writing to same file means data corruption, interleaving
# - Safe: Use Mutex to serialize critical section access (WaitOne and ReleaseMutex)
# - Alternative: Buffer results in memory per runspace, aggregate, write once at end
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 3] Thread-Safe Logging with Mutex and Buffering" -ForegroundColor White
Write-Host "Concurrent file access: unsafe, mutex-protected, and buffered patterns" -ForegroundColor Gray

Write-Host "`n[DEMO 3A] UNSAFE Concurrent File Writes (Anti-pattern)" -ForegroundColor Red
Write-Host "[WARNING] This demonstrates why you should NOT write concurrently without synchronization!" -ForegroundColor Yellow

$logFileUnsafe = "$PSScriptRoot\log_unsafe.txt"
Remove-Item $logFileUnsafe -ErrorAction Ignore
$psUnsafe = @()

try {
    for ($i = 1; $i -le 3; $i++) {
        $ps = [PowerShell]::Create()
        $ps.AddScript([scriptblock]::Create(@"
            `$logFile = '$logFileUnsafe'
            for (`$j = 1; `$j -le 5; `$j++) {
                "Task $i - Line `$j" | Out-File -FilePath `$logFile -Append
                Start-Sleep -Milliseconds 50
            }
"@)) | Out-Null
        
        $ps.BeginInvoke() | Out-Null
        $psUnsafe += $ps
    }
    
    Start-Sleep -Seconds 2
    Write-Host "[DEMO 3A] Log file contents (lines may be interleaved, corrupted):" -ForegroundColor Red
    Get-Content $logFileUnsafe | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}
finally {
    foreach ($ps in $psUnsafe) { $ps.Dispose() }
}

Write-Host "`n[DEMO 3B] SAFE Concurrent Writes with Mutex" -ForegroundColor Green
Write-Host "Pattern: Create Mutex to WaitOne() to write to ReleaseMutex()" -ForegroundColor Gray

$logFileSafe = "$PSScriptRoot\log_safe_mutex.txt"
Remove-Item $logFileSafe -ErrorAction Ignore

$mutex = [System.Threading.Mutex]::new($false, 'AzureLogMutex')

$psSafe = @()
try {
    for ($i = 1; $i -le 3; $i++) {
        $ps = [PowerShell]::Create()
        
        $ps.AddScript({
            param($LogFile, $Mutex, $TaskId)
            for ($j = 1; $j -le 5; $j++) {
                $Mutex.WaitOne() | Out-Null
                try {
                    "[$TaskId-$j] $(Get-Date -Format 'HH:mm:ss.fff')" | Out-File -FilePath $LogFile -Append
                }
                finally {
                    $Mutex.ReleaseMutex()
                }
                Start-Sleep -Milliseconds 50
            }
        }) | Out-Null
        
        $ps.AddParameter('LogFile', $logFileSafe)
        $ps.AddParameter('Mutex', $mutex)
        $ps.AddParameter('TaskId', $i)
        
        $ps.BeginInvoke() | Out-Null
        $psSafe += $ps
    }
    
    Start-Sleep -Seconds 3
    
    Write-Host "[DEMO 3B] Log file contents (properly sequenced thanks to mutex):" -ForegroundColor Green
    Get-Content $logFileSafe | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}
finally {
    foreach ($ps in $psSafe) { $ps.Dispose() }
    $mutex.Dispose()
}

Write-Host "`n[DEMO 3C] ALTERNATIVE Pattern - Buffer Results and Write Once" -ForegroundColor Cyan
Write-Host "Pattern: Each runspace buffers results to collect to write all at end (thread-safe)" -ForegroundColor Gray

$results = @()
$psBuffer = @()
$asyncResultsBuffer = @()

try {
    for ($i = 1; $i -le 3; $i++) {
        $ps = [PowerShell]::Create()
        $ps.AddScript([scriptblock]::Create(@"
            `$output = @()
            for (`$j = 1; `$j -le 5; `$j++) {
                `$output += "Task $i - Line `$j at `$(Get-Date -Format 'HH:mm:ss.fff')"
                Start-Sleep -Milliseconds 50
            }
            `$output
"@)) | Out-Null
        
        $asyncResultsBuffer += @{
            PowerShell = $ps
            AsyncResult = $ps.BeginInvoke()
            TaskId = $i
        }
        $psBuffer += $ps
    }
    
    foreach ($item in $asyncResultsBuffer) {
        $taskResults = $item.PowerShell.EndInvoke($item.AsyncResult)
        $results += $taskResults
    }
    
    Write-Host "[DEMO 3C] Buffered results (written once, in order):" -ForegroundColor Cyan
    $results | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
}
finally {
    foreach ($ps in $psBuffer) { $ps.Dispose() }
}

Write-Host "`n[SUCCESS] Thread-safety patterns: Mutex for concurrent access, Buffering for aggregation" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to InitialSessionState..." -ForegroundColor Magenta
$pause3 = Read-Host


# ============================================================================
# CONCEPT 4: INITIAL SESSION STATE - Variable and Function Injection
# ============================================================================
# EXPLANATION: Runspaces start with empty state. Pass context using InitialSessionState:
# - Variables: Inject $variables, connection strings, configuration
# - Functions: Pre-load custom functions for reuse across runspaces
# - Modules: Load specific modules into each runspace
# - Scripts: Execute setup scripts before main work
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 4] PowerShell Class Essentials and InitialSessionState" -ForegroundColor White
Write-Host "Passing context to runspaces: variables, functions, modules" -ForegroundColor Gray

Write-Host "[DEMO 4A] Inject Variables into Runspace" -ForegroundColor Yellow

$azureContext = @{ SubscriptionId = 'sub-12345'; TenantId = 'tenant-67890' }
$companyName = 'Contoso'

$iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$iss.Variables.Add([System.Management.Automation.Runspaces.SessionStateVariableEntry]::new('azureContext', $azureContext, 'Azure connection info'))
$iss.Variables.Add([System.Management.Automation.Runspaces.SessionStateVariableEntry]::new('companyName', $companyName, 'Company name'))

$ps = [PowerShell]::Create($iss)
$ps.AddScript({
    Write-Host "    [RESULT] Company: $companyName, Subscription: $($azureContext.SubscriptionId)" -ForegroundColor Cyan
}) | Out-Null

$ps.Invoke()
$ps.Dispose()

Write-Host "[DEMO 4B] Inject Functions into Runspace" -ForegroundColor Yellow

function Get-AzureResourceCount {
    param([string]$ResourceGroup)
    "Found 42 resources in $ResourceGroup"
}

$iss2 = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$scriptFunctionEntry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Get-AzureResourceCount', (Get-Content function:\Get-AzureResourceCount)
$iss2.Commands.Add($scriptFunctionEntry)

$ps = [PowerShell]::Create($iss2)
$ps.AddScript({
    $output = Get-AzureResourceCount -ResourceGroup 'Prod-RG'
    Write-Host "    [RESULT] $output" -ForegroundColor Cyan
}) | Out-Null

$ps.Invoke()
$ps.Dispose()

Write-Host "`n[SUCCESS] Variables and functions injected into runspace context" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to RunspacePool pattern..." -ForegroundColor Magenta
$pause4 = Read-Host


# ============================================================================
# CONCEPT 5: ASYNCHRONOUS PATTERNS AND RUNSPACEPOOL
# ============================================================================
# EXPLANATION: RunspacePool manages a pool of reusable runspaces (thread pooling)
# - Instead of creating one runspace per task, reuse a pool of threads
# - Dramatically reduces overhead for high-volume parallel work (hundreds of tasks)
# - Key methods: CreateRunspacePool(min, max) for configuration
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 5] Asynchronous Patterns and RunspacePool" -ForegroundColor White
Write-Host "Queue management with thread pooling for scalable concurrent work" -ForegroundColor Gray

Write-Host "`n[DEMO 5] RunspacePool Pattern (Queue and Concurrency Control)" -ForegroundColor Yellow

$sw = [System.Diagnostics.Stopwatch]::StartNew()

$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(2, 5)
$pool.Open()

Write-Host "  Created pool with min 2, max 5 concurrent runspaces" -ForegroundColor Gray
$asyncTasks = @()

for ($i = 1; $i -le 10; $i++) {
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    
    $ps.AddScript([scriptblock]::Create("
        Start-Sleep -Seconds 1
        Write-Host '[POOL] Task $i completed'
    ")) | Out-Null
    
    $asyncTasks += @{
        PowerShell = $ps
        AsyncResult = $ps.BeginInvoke()
        TaskId = $i
    }
}

Write-Host "  Queued 10 tasks to pool" -ForegroundColor Gray
Start-Sleep -Seconds 3

foreach ($task in $asyncTasks) {
    try {
        $result = $task.PowerShell.EndInvoke($task.AsyncResult)
        Write-Host "  [RESULT] Task $($task.TaskId) finished" -ForegroundColor Cyan
    }
    catch {
        Write-Host "  [ERROR] Task $($task.TaskId) failed: $_" -ForegroundColor Red
    }
    finally {
        $task.PowerShell.Dispose()
    }
}

$pool.Close()
Write-Host "[TIMING] Pool execution complete in $($sw.ElapsedMilliseconds) ms" -ForegroundColor Green
Write-Host "[SUCCESS] RunspacePool demonstrated: concurrent execution with thread cap and reuse" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to Debugging Runspaces..." -ForegroundColor Magenta
$pause5 = Read-Host


# ============================================================================
# CONCEPT 6: DEBUGGING RUNSPACES AND STREAM INSPECTION
# ============================================================================
# EXPLANATION: Runspaces have isolated streams (Verbose, Warning, Error, Debug)
# - Get-Runspace for enumeration and inspection
# - $PowerShell.Streams.Verbose, Warning, Error for output collection
# - Useful for troubleshooting async tasks
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 6] Debugging Runspaces and Stream Inspection" -ForegroundColor White
Write-Host "Monitoring and troubleshooting concurrent runspace execution" -ForegroundColor Gray

Write-Host "`n[DEMO 6A] Inspect Runspaces and Streams" -ForegroundColor Yellow

$ps = [PowerShell]::Create()
$ps.AddScript({
    Write-Verbose "Verbose message from runspace"
    Write-Warning "Warning from runspace"
    Write-Host "Regular output"
    1 + 1
}) | Out-Null

$asyncResult = $ps.BeginInvoke()
Start-Sleep -Milliseconds 500
$result = $ps.EndInvoke($asyncResult)

Write-Host "  [RESULT] Output: $result" -ForegroundColor Cyan
Write-Host "  [VERBOSE] $($ps.Streams.Verbose)" -ForegroundColor Gray
Write-Host "  [WARNING] $($ps.Streams.Warning)" -ForegroundColor Yellow
$ps.Dispose()

Write-Host "`n[DEMO 6B] Get-Runspace for Active Runspace Enumeration" -ForegroundColor Yellow

$totalRunspaces = (Get-Runspace).Count
Write-Host "  [INFO] Total runspaces in session: $totalRunspaces" -ForegroundColor Cyan

Get-Runspace | Select-Object -Property Id, RunspaceState | ForEach-Object {
    Write-Host "  [RUNSPACE] ID: $($_.Id), State: $($_.RunspaceState)" -ForegroundColor Gray
}

Write-Host "[SUCCESS] Runspace debugging: Stream inspection and enumeration enabled" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to PowerShell 7 alternatives..." -ForegroundColor Magenta
$pause6 = Read-Host


# ============================================================================
# CONCEPT 7: POWERSHELL 7 ALTERNATIVES - Modern Parallelism Approaches
# ============================================================================
# EXPLANATION: PowerShell 7 introduced lighter alternatives to traditional runspaces:
# - Start-ThreadJob: Ultra-lightweight threading (not process-based like Start-Job)
# - ForEach-Object -Parallel: Built-in parallel iteration (simplifies runspace patterns)
# - Use for: Simpler code, when runspace mastery not required
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[CONCEPT 7] PowerShell 7 Alternatives - Modern Parallelism" -ForegroundColor White
Write-Host "Simplified parallelism with Start-ThreadJob and ForEach-Object -Parallel" -ForegroundColor Gray

Write-Host "`n[DEMO 7A] Modern Alternative - Start-ThreadJob (PS 7 only)" -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -ge 7) {
    $jobs = @()
    for ($i = 1; $i -le 3; $i++) {
        $job = Start-ThreadJob -ScriptBlock {
            Start-Sleep -Milliseconds 500
            "ThreadJob $_"
        } -ArgumentList $i
        $jobs += $job
    }
    
    $results = $jobs | Wait-Job | Receive-Job
    Write-Host "  [RESULT] ThreadJob results:" -ForegroundColor Cyan
    $results | ForEach-Object { Write-Host "    $_" -ForegroundColor Cyan }
    $jobs | Remove-Job
}
else {
    Write-Host "  [INFO] Start-ThreadJob requires PowerShell 7 or later (this is PS $($PSVersionTable.PSVersion.Major))" -ForegroundColor Gray
}

Write-Host "`n[DEMO 7B] Modern Alternative - ForEach-Object with Parallel (PS 7 only)" -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "  Running parallel ForEach-Object loop..." -ForegroundColor Gray
    1..5 | ForEach-Object -Parallel {
        Start-Sleep -Milliseconds 300
        "Parallel iteration $_"
    } -ThrottleLimit 3 | ForEach-Object {
        Write-Host "    [RESULT] $_" -ForegroundColor Cyan
    }
}
else {
    Write-Host "  [INFO] ForEach-Object -Parallel requires PowerShell 7 or later (this is PS $($PSVersionTable.PSVersion.Major))" -ForegroundColor Gray
}

Write-Host "`n[DEMO 7C] Real-World Azure Scenario - Ordered Parallel Resource Group Processing" -ForegroundColor Yellow
Write-Host "Pattern: Maintain original order despite parallel execution times using hashtables" -ForegroundColor Gray

if ($PSVersionTable.PSVersion.Major -ge 7 -and $global:AzureEnabled) {
    try {
        Write-Host "  [STEP 1] Getting all Resource Groups from your Azure subscription..." -ForegroundColor Gray
        $resourceGroups = Get-AzResourceGroup | Select-Object ResourceGroupName, Location | Sort-Object ResourceGroupName
        
        if ($resourceGroups.Count -eq 0) {
            Write-Host "    [INFO] No resource groups found in current subscription" -ForegroundColor Yellow
            Write-Host "    [SUGGESTION] Create some resource groups to see this demo in action" -ForegroundColor Yellow
            Write-Host "    [COMMAND] az group create --name 'rg-demo-test' --location 'East US'" -ForegroundColor Gray
            return
        }
        
        Write-Host "    [SUCCESS] Found $($resourceGroups.Count) resource groups in subscription" -ForegroundColor Green
        
        Write-Host "  [BASELINE] Original Resource Groups (in order):" -ForegroundColor White
        $resourceGroups | ForEach-Object { $index = 0 } { 
            $index++
            Write-Host "    $index. $($_.ResourceGroupName) ($($_.Location))" -ForegroundColor Gray 
        }
        
        Write-Host "`n  [STEP 2] Parallel Resource Count with Order Preservation..." -ForegroundColor Gray
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Create ordered results using hashtable with index tracking
        $parallelResults = $resourceGroups | ForEach-Object { $index = 0 } {
            $index++
            [PSCustomObject]@{
                Index = $index
                ResourceGroupName = $_.ResourceGroupName
                Location = $_.Location
            }
        } | ForEach-Object -Parallel {
            Write-Host "      [PARALLEL] Processing $($_.ResourceGroupName)..." -ForegroundColor DarkGray
            
            # Real Azure API call to get resource count
            try {
                $startTime = Get-Date
                $actualCount = (Get-AzResource -ResourceGroupName $_.ResourceGroupName -ErrorAction Stop).Count
                $endTime = Get-Date
                $executionTime = ($endTime - $startTime).TotalMilliseconds
                
                Write-Host "      [COMPLETED] $($_.ResourceGroupName): $actualCount resources ($([math]::Round($executionTime))ms)" -ForegroundColor Green
                
                # Return structured result with original index for ordering
                [PSCustomObject]@{
                    Index = $_.Index
                    ResourceGroupName = $_.ResourceGroupName
                    Location = $_.Location
                    ResourceCount = $actualCount
                    ProcessedAt = Get-Date -Format "HH:mm:ss.fff"
                    ExecutionTime = [math]::Round($executionTime)
                    Status = "Success"
                }
            }
            catch {
                Write-Host "      [ERROR] Failed to process $($_.ResourceGroupName): $($_.Exception.Message)" -ForegroundColor Red
                
                [PSCustomObject]@{
                    Index = $_.Index
                    ResourceGroupName = $_.ResourceGroupName
                    Location = $_.Location
                    ResourceCount = -1
                    Error = $_.Exception.Message
                    ProcessedAt = Get-Date -Format "HH:mm:ss.fff"
                    ExecutionTime = 0
                    Status = "Error"
                }
            }
        } -ThrottleLimit 5
        
        $sw.Stop()
        
        Write-Host "`n  [STEP 3] Results Processing and Order Restoration..." -ForegroundColor Gray
        
        # Create hashtable for fast lookup by index
        $resultLookup = @{}
        foreach ($result in $parallelResults) {
            $resultLookup[$result.Index] = $result
        }
        
        Write-Host "`n  [RESULTS] Ordered Resource Group Analysis (maintained original sequence):" -ForegroundColor White
        Write-Host "  " -NoNewline
        Write-Host "Index".PadRight(7) -ForegroundColor Cyan -NoNewline
        Write-Host "ResourceGroup".PadRight(35) -ForegroundColor Cyan -NoNewline
        Write-Host "Location".PadRight(18) -ForegroundColor Cyan -NoNewline
        Write-Host "Count".PadRight(8) -ForegroundColor Cyan -NoNewline
        Write-Host "Time".PadRight(15) -ForegroundColor Cyan -NoNewline
        Write-Host "ExecTime(ms)" -ForegroundColor Cyan
        Write-Host "  " + ("-" * 100) -ForegroundColor DarkGray
        
        # Display results in original order using index
        1..$resourceGroups.Count | ForEach-Object {
            $result = $resultLookup[$_]
            if ($result.Status -eq "Error") {
                $countColor = "Red"
                $displayCount = "ERROR"
            } else {
                $countColor = if ($result.ResourceCount -gt 10) { "Red" } elseif ($result.ResourceCount -gt 5) { "Yellow" } else { "Green" }
                $displayCount = $result.ResourceCount.ToString()
            }
            
            # Truncate long RG names for better formatting
            $displayName = if ($result.ResourceGroupName.Length -gt 32) { 
                $result.ResourceGroupName.Substring(0, 29) + "..." 
            } else { 
                $result.ResourceGroupName 
            }
            
            Write-Host "  " -NoNewline
            Write-Host "$($_)".PadRight(7) -ForegroundColor White -NoNewline
            Write-Host "$displayName".PadRight(35) -ForegroundColor Gray -NoNewline
            Write-Host "$($result.Location)".PadRight(18) -ForegroundColor Gray -NoNewline
            Write-Host "$displayCount".PadRight(8) -ForegroundColor $countColor -NoNewline
            Write-Host "$($result.ProcessedAt)".PadRight(15) -ForegroundColor Gray -NoNewline
            Write-Host "$($result.ExecutionTime)" -ForegroundColor Gray
        }
        
        Write-Host "`n  [PERFORMANCE] Total parallel execution time: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Green
        
        $successfulResults = $parallelResults | Where-Object { $_.Status -eq "Success" }
        if ($successfulResults.Count -gt 0) {
            $sequentialTime = ($successfulResults | Measure-Object ExecutionTime -Sum).Sum
            Write-Host "  [COMPARISON] Sequential execution would have taken: $sequentialTime ms" -ForegroundColor Yellow
            
            if ($sequentialTime -gt 0) {
                $speedup = [math]::Round(($sequentialTime / $sw.ElapsedMilliseconds), 2)
                Write-Host "  [SPEEDUP] Parallel processing was ${speedup}x faster!" -ForegroundColor Green
            }
        }
        
        $totalResources = ($successfulResults | Measure-Object ResourceCount -Sum).Sum
        Write-Host "  [SUMMARY] Total resources across all RGs: $totalResources" -ForegroundColor Cyan
        
        Write-Host "`n  [KEY TECHNIQUE] Hashtable lookup preserves order despite async completion times" -ForegroundColor Cyan
        Write-Host "  [PATTERN] Index tracking + result lookup = ordered parallel processing" -ForegroundColor Cyan
        
    }
    catch {
        Write-Host "  [ERROR] Azure Resource Group enumeration failed: $_" -ForegroundColor Red
        Write-Host "  [INFO] Ensure you're authenticated with Connect-AzAccount" -ForegroundColor Yellow
    }
}
elseif ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "  [INFO] This demo requires PowerShell 7+ for ForEach-Object -Parallel" -ForegroundColor Yellow
}
else {
    Write-Host "  [INFO] Azure demos disabled - enable with Azure integration option" -ForegroundColor Yellow
}

Write-Host "[SUCCESS] PowerShell 7 modern alternatives demonstrated" -ForegroundColor Green

Write-Host "`n[PAUSE] Press Enter to continue to best practices summary..." -ForegroundColor Magenta
$pause7 = Read-Host


# ============================================================================
# SUMMARY AND BEST PRACTICES
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[SUMMARY] PowerShell Runspaces and Parallelism Workshop" -ForegroundColor Cyan
Write-Host "Key Takeaways for Azure Automation and Concurrent Execution" -ForegroundColor Gray

Write-Host "`nConcept Recap:" -ForegroundColor White
Write-Host "  1. Runspace Fundamentals: Create, AddScript, Invoke or BeginInvoke, Dispose" -ForegroundColor Yellow
Write-Host "  2. Runspaces vs Jobs: Lightweight in-process threads vs heavy separate processes" -ForegroundColor Yellow
Write-Host "  3. Thread Safety: Use Mutex for resource access, buffering for aggregation" -ForegroundColor Yellow
Write-Host "  4. InitialSessionState: Inject variables and functions into runspaces" -ForegroundColor Yellow
Write-Host "  5. RunspacePool: Reusable thread pool for high-volume parallel work" -ForegroundColor Yellow
Write-Host "  6. Debugging: Stream inspection (Verbose, Warning, Error) and Get-Runspace" -ForegroundColor Yellow
Write-Host "  7. Modern PS 7: ThreadJob and ForEach-Object -Parallel for simpler code" -ForegroundColor Yellow

Write-Host "`nBest Practices:" -ForegroundColor White
Write-Host "  - ALWAYS dispose runspaces: Use try/finally blocks" -ForegroundColor Cyan
Write-Host "  - Use RunspacePool for 10plus tasks: Better resource management" -ForegroundColor Cyan
Write-Host "  - Thread-safe logging: Use Mutex or buffering, never direct concurrent writes" -ForegroundColor Cyan
Write-Host "  - Error handling: Check streams after EndInvoke for captured errors" -ForegroundColor Cyan
Write-Host "  - Azure scenarios: Inject credentials via InitialSessionState, avoid global state" -ForegroundColor Cyan

Write-Host "`nRealworld Azure Scenarios:" -ForegroundColor White
Write-Host "  - Scan 100 subscriptions concurrently: RunspacePool + Azure CLI" -ForegroundColor Cyan
Write-Host "  - Provision VMs across regions: Parallel runspaces with resource tracking" -ForegroundColor Cyan
Write-Host "  - SQL bulk operations: Runspaces for connection pooling and parallel queries" -ForegroundColor Cyan
Write-Host "  - Log aggregation: Thread-safe collection with Mutex protection" -ForegroundColor Cyan

Write-Host "`n$separator" -ForegroundColor DarkGray
Write-Host "[COMPLETE] PowerShell Runspaces and Parallelism Workshop Finished!" -ForegroundColor Green
Write-Host "[NEXT STEP] Apply these patterns to your Azure automation workflows!" -ForegroundColor Cyan
