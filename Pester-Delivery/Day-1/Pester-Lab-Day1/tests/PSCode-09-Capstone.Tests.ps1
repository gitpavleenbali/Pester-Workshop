# ============================================================================
# PSCode Module 09 — Capstone: Azure Cost Monitor
# SOURCE: PSCode/09_final_solution_apply_learnings/Azure-Cost-Monitor.ps1
# TESTS:  Invoke-SafeAzureCall (retry), Send-CostAlert (mock email), Get-VMStatus
#
# PESTER CONCEPTS: Retry logic, boundary testing, mocking dangerous commands
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/CostMonitorHelpers.ps1
    . $PSScriptRoot/../src/AzureResourceHelpers.ps1
}

# PESTER: Testing retry logic — no mocking needed, pass scriptblocks directly
Describe 'Module 09 · Invoke-SafeAzureCall — Retry Pattern' {

    It 'Succeeds on first try' {
        Write-Host "  → Running: Succeeds on first try" -ForegroundColor Gray
        $r = Invoke-SafeAzureCall -ScriptBlock { 'data' } -OperationName 'Test'
        $r.Success | Should -Be $true
        $r.Data | Should -Be 'data'
        $r.Attempts | Should -Be 1
    }

    It 'Fails after max retries' {
        Write-Host "  → Running: Fails after max retries" -ForegroundColor Gray
        $r = Invoke-SafeAzureCall -ScriptBlock { throw 'err' } -MaxRetries 2 -OperationName 'Fail' -WarningAction SilentlyContinue
        $r.Success | Should -Be $false
        $r.Attempts | Should -Be 2
    }

    # PESTER: $script: scope tracks state across scriptblock calls
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

# PESTER: Mocking Send-MailMessage — CRITICAL to prevent real emails
Describe 'Module 09 · Send-CostAlert — Boundary Testing' {

    BeforeAll {
        Mock Send-MailMessage {}
    }

    # PESTER: -TestCases for systematic boundary testing
    # Testing the exact boundary: 100 vs 100 catches off-by-one bugs
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

    It 'Does NOT call Send-MailMessage when below threshold' {
        Write-Host "  → Running: Does NOT call Send-MailMessage when below threshold" -ForegroundColor Gray
        Send-CostAlert -ResourceName 'vm' -CurrentCost 50 -Threshold 100 | Out-Null
        Should -Invoke Send-MailMessage -Times 0
    }

    It 'Calls Send-MailMessage when above threshold' {
        Write-Host "  → Running: Calls Send-MailMessage when above threshold" -ForegroundColor Gray
        Send-CostAlert -ResourceName 'vm' -CurrentCost 200 -Threshold 100 | Out-Null
        Should -Invoke Send-MailMessage -Times 1 -Exactly
    }
}

# PESTER: ParameterFilter — different VMs return different states
Describe 'Module 09 · Get-VMStatus — Mocked Azure' {

    BeforeAll {
        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/running'; DisplayStatus = 'VM running' }) }
        } -ParameterFilter { $Name -eq 'vm-web' }

        Mock Get-AzVM {
            [PSCustomObject]@{ Statuses = @([PSCustomObject]@{ Code = 'PowerState/deallocated'; DisplayStatus = 'VM deallocated' }) }
        } -ParameterFilter { $Name -eq 'vm-db' }

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
}

