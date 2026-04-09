# ============================================================================
# PSCode Module 07 — Git Integration: Testable Functions
# SINGLE SOURCE OF TRUTH — tests dot-source this file directly.
# Contains: Test-GitEnvironment, Deploy-ResourceGroup
# Tested by: PSCode-07-GitIntegration.Tests.ps1
# ============================================================================

# ── Module 07: Git Integration ──────────────────────────────────────────

# TESTABILITY: Calls the native 'git' executable → mocked with Mock git {}.
# Pester can mock ANY command, including native executables like git.exe.
# The mock uses switch($args[0]) to return different values for
# --version, config, and rev-parse subcommands.
# TESTED IN: PSCode-07-GitIntegration.Tests.ps1
function Test-GitEnvironment {
    <#
    .SYNOPSIS
        Checks if Git is installed and configured (safe version for testing).
    #>
    $result = @{
        GitInstalled = $false
        GitVersion   = $null
        UserName     = $null
        UserEmail    = $null
        InRepo       = $false
    }

    try {
        $ver = git --version 2>$null
        if ($ver) {
            $result.GitInstalled = $true
            $result.GitVersion   = $ver -replace 'git version ',''
        }
    } catch { }

    try {
        $result.UserName = git config user.name 2>$null
        $result.UserEmail = git config user.email 2>$null
    } catch { }

    try {
        $isRepo = git rev-parse --is-inside-work-tree 2>$null
        $result.InRepo = ($isRepo -eq 'true')
    } catch { }

    return [PSCustomObject]$result
}

# TESTABILITY: Calls Get-AzResourceGroup + New-AzResourceGroup → both mocked.
# Two Context blocks test the branching logic:
#   Context 1: Mock returns $null → RG doesn't exist → creates it (Status='Created')
#   Context 2: Mock returns object → RG exists → skips (Status='Exists')
# Should -Invoke -Times 0 verifies New-AzResourceGroup was NOT called in Context 2.
# TESTED IN: PSCode-07-GitIntegration.Tests.ps1
function Deploy-ResourceGroup {
    <#
    .SYNOPSIS
        Deploys an Azure resource group (creates or skips if exists).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Location = 'westeurope',

        [hashtable]$Tags = @{}
    )

    $rg = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue

    if (-not $rg) {
        $rg = New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags
        return [PSCustomObject]@{ Name = $Name; Status = 'Created'; Location = $Location }
    } else {
        return [PSCustomObject]@{ Name = $Name; Status = 'Exists'; Location = $rg.Location }
    }
}
