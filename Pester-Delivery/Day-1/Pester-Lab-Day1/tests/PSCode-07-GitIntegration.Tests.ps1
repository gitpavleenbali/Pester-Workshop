# ============================================================================
# PSCode Module 07 — Git Integration
# SOURCE: PSCode/07_git_integration/Azure-Git-Training.ps1
# TESTS:  Test-GitEnvironment (mocked git), Deploy-ResourceGroup (mocked Azure)
#
# PESTER CONCEPTS: Mocking native commands (git), Context-scoped mock overrides
# ============================================================================

# PESTER ▶ BeforeAll {}
# Loads all functions for this test file once before any tests run.
BeforeAll {
    . $PSScriptRoot/../src/PSCodeModulesAdditional.ps1
}

# PESTER ▶ Mocking native executables
# Pester can mock ANY command — including native executables like git.exe!
# The mock replaces the real git command, so tests run WITHOUT needing git installed.
# Uses $args[0] inside the mock to detect which git subcommand was called.
Describe 'Module 07 · Test-GitEnvironment' {

    # PESTER ▶ BeforeAll with a complex Mock
    # This single mock handles multiple git subcommands (--version, config, rev-parse)
    # by using a switch statement on $args[0] (the first argument passed to git).
    BeforeAll {
        # PESTER ▶ Mock git { switch($args[0]) { ... } }
        # A multi-behavior mock: returns different values depending on the subcommand.
        # This pattern avoids needing multiple separate mocks for the same command.
        Mock git {
            switch ($args[0]) {
                '--version' { return 'git version 2.44.0' }
                'config'    {
                    if ($args[1] -eq 'user.name') { return 'Workshop User' }
                    if ($args[1] -eq 'user.email') { return 'user@workshop.com' }
                }
                'rev-parse' { return 'true' }
            }
        }
    }

    It 'Detects Git is installed' {
        Write-Host "  → Running: Detects Git is installed" -ForegroundColor Gray
        (Test-GitEnvironment).GitInstalled | Should -Be $true
    }

    # PESTER ▶ Should -Match 'regex'
    # Regex-based assertion — checks if the value matches a regex pattern.
    # '2\.44' matches "2.44" anywhere in the string (dot escaped in regex).
    It 'Reads Git version' {
        Write-Host "  → Running: Reads Git version" -ForegroundColor Gray
        (Test-GitEnvironment).GitVersion | Should -Match '2\.44'
    }

    It 'Reads user name' {
        Write-Host "  → Running: Reads user name" -ForegroundColor Gray
        (Test-GitEnvironment).UserName | Should -Be 'Workshop User'
    }

    It 'Reads user email' {
        Write-Host "  → Running: Reads user email" -ForegroundColor Gray
        (Test-GitEnvironment).UserEmail | Should -Be 'user@workshop.com'
    }

    It 'Detects repo context' {
        Write-Host "  → Running: Detects repo context" -ForegroundColor Gray
        (Test-GitEnvironment).InRepo | Should -Be $true
    }
}

# PESTER ▶ Testing branching logic with Context-scoped mocks
# Deploy-ResourceGroup creates RG if not found, skips if exists.
# Two Contexts test BOTH paths by providing different mock returns.
Describe 'Module 07 · Deploy-ResourceGroup' {

    # PESTER ▶ Context for the "create" path
    # Mock returns $null for Get-AzResourceGroup → RG doesn't exist → function creates it.
    Context 'RG does not exist — creates it' {
        # PESTER ▶ BeforeAll inside Context
        # These mocks ONLY apply to It blocks inside THIS Context.
        BeforeAll {
            # PESTER ▶ Mock returns $null — simulates "resource group not found".
            Mock Get-AzResourceGroup { return $null }
            # PESTER ▶ Mock New-AzResourceGroup — simulates successful creation.
            Mock New-AzResourceGroup { return @{ ResourceGroupName = $Name } }
        }

        It 'Returns Status = Created' {
            Write-Host "  → ASSERT: Checking return value — Returns Status = Created" -ForegroundColor Gray
            (Deploy-ResourceGroup -Name 'rg-new').Status | Should -Be 'Created'
        }

        # PESTER ▶ Should -Invoke <Command> -Times 1
        # Verifies the mock was called exactly 1 time.
        # Proves the function actually attempted to create the RG.
        It 'Calls New-AzResourceGroup' {
            Write-Host "  → Running: Calls New-AzResourceGroup" -ForegroundColor Gray
            Deploy-ResourceGroup -Name 'rg-new' | Out-Null
            Should -Invoke New-AzResourceGroup -Times 1
        }
    }

    # PESTER ▶ Context for the "skip" path
    # Mock returns a valid RG object → RG already exists → function skips creation.
    Context 'RG already exists — skips creation' {
        BeforeAll {
            # PESTER ▶ Mock returns existing RG object — simulates "already exists".
            Mock Get-AzResourceGroup { return @{ ResourceGroupName = 'rg-old'; Location = 'westeurope' } }
            # PESTER ▶ Empty mock body {} — command exists but does nothing.
            # We only need it registered so Should -Invoke can count calls.
            Mock New-AzResourceGroup {}
        }

        It 'Returns Status = Exists' {
            Write-Host "  → ASSERT: Checking return value — Returns Status = Exists" -ForegroundColor Gray
            (Deploy-ResourceGroup -Name 'rg-old').Status | Should -Be 'Exists'
        }

        # PESTER ▶ Should -Invoke -Times 0
        # Proves the command was NOT called at all.
        # -Times 0 is how you assert "this should never have been called".
        # This confirms the function correctly skipped creation for an existing RG.
        It 'Does NOT call New-AzResourceGroup' {
            Write-Host "  → Running: Does NOT call New-AzResourceGroup" -ForegroundColor Gray
            Deploy-ResourceGroup -Name 'rg-old' | Out-Null
            Should -Invoke New-AzResourceGroup -Times 0
        }
    }
}
