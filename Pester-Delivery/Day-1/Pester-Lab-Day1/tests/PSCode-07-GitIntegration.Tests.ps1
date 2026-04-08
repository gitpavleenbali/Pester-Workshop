# ============================================================================
# PSCode Module 07 — Git Integration
# SOURCE: PSCode/07_git_integration/Azure-Git-Training.ps1
# TESTS:  Test-GitEnvironment (mocked git), Deploy-ResourceGroup (mocked Azure)
#
# PESTER CONCEPTS: Mocking native commands (git), Context-scoped mock overrides
# ============================================================================

BeforeAll {
    . $PSScriptRoot/../src/PSCodeModulesAdditional.ps1
}

# PESTER: You can mock native executables like git.exe!
# Same Mock syntax — uses $args[0] to detect the subcommand.
Describe 'Module 07 · Test-GitEnvironment' {

    BeforeAll {
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

# PESTER: Deploy-ResourceGroup creates RG if not found, skips if exists.
# Two Contexts with different mocks test both paths.
Describe 'Module 07 · Deploy-ResourceGroup' {

    Context 'RG does not exist — creates it' {
        BeforeAll {
            Mock Get-AzResourceGroup { return $null }
            Mock New-AzResourceGroup { return @{ ResourceGroupName = $Name } }
        }

        It 'Returns Status = Created' {
            Write-Host "  → ASSERT: Checking return value — Returns Status = Created" -ForegroundColor Gray
            (Deploy-ResourceGroup -Name 'rg-new').Status | Should -Be 'Created'
        }

        It 'Calls New-AzResourceGroup' {
            Write-Host "  → Running: Calls New-AzResourceGroup" -ForegroundColor Gray
            Deploy-ResourceGroup -Name 'rg-new' | Out-Null
            Should -Invoke New-AzResourceGroup -Times 1
        }
    }

    Context 'RG already exists — skips creation' {
        BeforeAll {
            Mock Get-AzResourceGroup { return @{ ResourceGroupName = 'rg-old'; Location = 'westeurope' } }
            Mock New-AzResourceGroup {}
        }

        It 'Returns Status = Exists' {
            Write-Host "  → ASSERT: Checking return value — Returns Status = Exists" -ForegroundColor Gray
            (Deploy-ResourceGroup -Name 'rg-old').Status | Should -Be 'Exists'
        }

        # PESTER: -Times 0 proves the command was NOT called
        It 'Does NOT call New-AzResourceGroup' {
            Write-Host "  → Running: Does NOT call New-AzResourceGroup" -ForegroundColor Gray
            Deploy-ResourceGroup -Name 'rg-old' | Out-Null
            Should -Invoke New-AzResourceGroup -Times 0
        }
    }
}
