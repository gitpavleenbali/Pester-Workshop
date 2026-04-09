# ============================================================================
# PSCode Module 09 — Capstone: Azure Cost Monitor
# SOURCE: PSCode/09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1
# TESTS:  Invoke-SafeAzureCall (retry), Send-CostAlert (mock email), Get-VMStatus
#
# PESTER CONCEPTS: Retry logic, boundary testing, mocking dangerous commands
# ============================================================================

# PESTER ▶ BeforeAll {}
# Loads MULTIPLE source files — the capstone project combines helpers from different modules.
# You can dot-source multiple files in the same BeforeAll block.
BeforeAll {
    . $PSScriptRoot/../src/CostMonitorHelpers.ps1
    . $PSScriptRoot/../src/AzureResourceHelpers.ps1
}

# PESTER ▶ Testing retry logic without mocking
# Invoke-SafeAzureCall accepts a ScriptBlock parameter, so we pass test scriptblocks
# directly — no need to mock anything. This is a pattern called "dependency injection".
Describe 'Module 09 · Invoke-SafeAzureCall — Retry Pattern' {

    # PESTER ▶ Testing the happy path
    # Passes a scriptblock that succeeds immediately { 'data' }.
    # Verifies Success=$true, the returned Data, and that only 1 attempt was needed.
    It 'Succeeds on first try' {
        Write-Host "  → Running: Succeeds on first try" -ForegroundColor Gray
        $r = Invoke-SafeAzureCall -ScriptBlock { 'data' } -OperationName 'Test'
        $r.Success | Should -Be $true
        $r.Data | Should -Be 'data'
        $r.Attempts | Should -Be 1
    }

    # PESTER ▶ Testing failure after exhausting retries
    # Passes a scriptblock that ALWAYS throws { throw 'err' }.
    # Verifies the function gives up after MaxRetries attempts.
    # -WarningAction SilentlyContinue suppresses retry warning messages in test output.
    It 'Fails after max retries' {
        Write-Host "  → Running: Fails after max retries" -ForegroundColor Gray
        $r = Invoke-SafeAzureCall -ScriptBlock { throw 'err' } -MaxRetries 2 -OperationName 'Fail' -WarningAction SilentlyContinue
        $r.Success | Should -Be $false
        $r.Attempts | Should -Be 2
    }

    # PESTER ▶ $script: scope for stateful test scriptblocks
    # $script:n persists across multiple invocations of the scriptblock.
    # First call ($n=1) throws "transient", second call ($n=2) succeeds.
    # This simulates a real-world transient failure that resolves on retry.
    It 'Retries and recovers from transient error' {
        Write-Host "  → Running: Retries and recovers from transient error" -ForegroundColor Gray
        $script:n = 0
        $r = Invoke-SafeAzureCall -ScriptBlock {
            $script:n++
            if ($script:n -eq 1) { throw 'transient' }
            'recovered'
        } -MaxRetries 3 -OperationName 'Retry' -WarningAction SilentlyContinue
        $r.Success | Should -Be $true
        $r.Data | Should -Be 'recovered'
        $r.Attempts | Should -Be 2
    }
}

# PESTER ▶ Mocking dangerous commands
# Send-MailMessage sends REAL emails — mocking prevents that during tests.
# This is why mocking exists: to test code that has side effects
# (emails, API calls, database writes) without actually performing them.
Describe 'Module 09 · Send-CostAlert — Boundary Testing' {

    # PESTER ▶ Mock Send-MailMessage {}
    # Empty body {} — the mock does nothing. We just need to prevent the real
    # Send-MailMessage from firing. We'll use Should -Invoke to verify call count.
    BeforeAll {
        Mock Send-MailMessage {}
    }

    # PESTER ▶ -TestCases for boundary testing
    # Boundary testing checks values at, just below, and just above the threshold.
    # This catches off-by-one bugs (e.g., should 100 == 100 trigger an alert?).
    # Each hashtable is a test case with Cost, Threshold, and Expected result.
    It 'Cost <Cost> vs Threshold <Threshold> -> AlertSent=<Expected>' -TestCases @(
        @{ Cost = 10;     Threshold = 100; Expected = $false }
        @{ Cost = 99;     Threshold = 100; Expected = $false }
        @{ Cost = 100;    Threshold = 100; Expected = $false }   # boundary: equal = no alert
        @{ Cost = 100.01; Threshold = 100; Expected = $true }    # just over
        @{ Cost = 101;    Threshold = 100; Expected = $true }
        @{ Cost = 500;    Threshold = 200; Expected = $true }
    ) {
        param($Cost, $Threshold, $Expected)
        Write-Host "  → Testing Cost=$Cost vs Threshold=$Threshold → expecting AlertSent=$Expected" -ForegroundColor Gray
        $r = Send-CostAlert -ResourceName 'vm-test' -CurrentCost $Cost -Threshold $Threshold
        $r.AlertSent | Should -Be $Expected
    }

    # PESTER ▶ Should -Invoke -Times 0
    # Proves Send-MailMessage was NOT called when cost is below threshold.
    # This is a safety check — no unnecessary emails sent.
    It 'Does NOT call Send-MailMessage when below threshold' {
        Write-Host "  → Running: Does NOT call Send-MailMessage when below threshold" -ForegroundColor Gray
        Send-CostAlert -ResourceName 'vm' -CurrentCost 50 -Threshold 100 | Out-Null
        Should -Invoke Send-MailMessage -Times 0
    }

    # PESTER ▶ Should -Invoke -Times 1 -Exactly
    # Proves Send-MailMessage was called EXACTLY 1 time (not 0, not 2).
    # -Exactly makes -Times an exact count instead of "at least".
    It 'Calls Send-MailMessage when above threshold' {
        Write-Host "  → Running: Calls Send-MailMessage when above threshold" -ForegroundColor Gray
        Send-CostAlert -ResourceName 'vm' -CurrentCost 200 -Threshold 100 | Out-Null
        Should -Invoke Send-MailMessage -Times 1 -Exactly
    }
}

# PESTER ▶ ParameterFilter — different mock results per parameter value
# Multiple mocks for Get-AzVM, each activating only for a specific -Name value.
# This simulates an Azure environment with VMs in different power states.
Describe 'Module 09 · Get-VMStatus — Mocked Azure' {

    # PESTER ▶ BeforeAll with multiple -ParameterFilter mocks
    # Pester evaluates filters in order and uses the FIRST match.
    BeforeAll {
        # PESTER ▶ Mock for 'vm-web' — returns running state.
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } -ParameterFilter { $Name -eq 'vm-web' }

        # PESTER ▶ Mock for 'vm-db' — returns deallocated state.
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } -ParameterFilter { $Name -eq 'vm-db' }

        # PESTER ▶ Mock for 'vm-gone' — returns $null (VM doesn't exist).
        Mock Get-AzVM { $null } -ParameterFilter { $Name -eq 'vm-gone' }
    }

    It 'Running VM returns Running' {
        Write-Host "  → Mocked Get-AzVM('vm-web') → PowerState/running → expecting 'Running'" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-web' | Should -Be 'Running'
    }
    It 'Stopped VM returns Deallocated' {
        Write-Host "  → Mocked Get-AzVM('vm-db') → PowerState/deallocated → expecting 'Deallocated'" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-db' | Should -Be 'Deallocated'
    }
    It 'Missing VM returns null' {
        Write-Host "  → Mocked Get-AzVM('vm-gone') → returns null → expecting null" -ForegroundColor Gray
        Get-VMStatus -VMName 'vm-gone' | Should -BeNullOrEmpty
    }

    # PESTER ▶ -Skip — marks a test as skipped (appears in report but doesn't run)
    # Use -Skip for tests that are planned but not yet implemented,
    # or tests that depend on an unavailable resource. Better than commenting out.
    It 'Integration test: real Azure VM status check' -Skip {
        # This would need real Azure credentials — skipped in workshop environment
        $status = Get-VMStatus -VMName 'real-production-vm'
        $status | Should -Not -BeNullOrEmpty
    }
}

