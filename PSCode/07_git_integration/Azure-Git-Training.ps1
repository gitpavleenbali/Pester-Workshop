# ==============================================================================================
# 07. Git Integration: DevOps Training
# Purpose: Demonstrate comprehensive Git workflows integrated with PowerShell Azure automation
#
# RUN FROM PSCode ROOT:
#   cd path/to/PSCode
#   .\07_git_integration\Azure-Git-Training.ps1
#
# Prerequisites: PowerShell 5.1+, Az PowerShell module, AzCLI, Git, authenticated Azure session
# ==============================================================================================

# ==============================================================================================
# PREREQUISITE CHECK: PowerShell Version
# ==============================================================================================
$originalLocation = (Get-Location).Path

Write-Host "[CHECK] Verifying PowerShell version..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
Write-Host "[INFO] PowerShell version detected: $($psVersion.ToString())" -ForegroundColor Gray

if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   POWERSHELL VERSION NOT SUPPORTED                            ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "This workshop requires PowerShell 5.1 or later." -ForegroundColor Yellow
    Write-Host "Current version detected: PowerShell $($psVersion.ToString())" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install PowerShell 7 (recommended) with: winget install Microsoft.PowerShell" -ForegroundColor Green
    Write-Host ""
    exit 1
}
elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -eq 1) {
    Write-Host "[SUCCESS] PowerShell 5.1 detected - core features available" -ForegroundColor Green
    Write-Host "[INFO] PowerShell 7+ recommended for best experience" -ForegroundColor Cyan
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
    Write-Host "The Azure PowerShell module (Az) is required to run this workshop." -ForegroundColor Yellow
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
    Write-Host "Azure CLI is required for this workshop." -ForegroundColor Yellow
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
    Write-Host "Git is required for the DevOps exercises." -ForegroundColor Yellow
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
Write-Host "[INFO] Starting Git Integration & Source Control Workshop..." -ForegroundColor Cyan
Write-Host "[INFO] PowerShell DevOps with Azure Automation" -ForegroundColor Gray

# Enhanced Git environment verification and setup
function Initialize-GitEnvironment {
    Write-Host "[GIT SETUP] Verifying Git installation and configuration..." -ForegroundColor Yellow
    
    try {
        # Check if Git is installed
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-Host "[SUCCESS] Git installed: $gitVersion" -ForegroundColor Green
        } else {
            throw "Git is not installed or not in PATH"
        }
        
        # Check Git configuration
        $gitUser = git config user.name 2>$null
        $gitEmail = git config user.email 2>$null
        
        if (-not $gitUser -or -not $gitEmail) {
            Write-Host "[CONFIG] Git user configuration missing. Setting up..." -ForegroundColor Yellow
            
            if (-not $gitUser) {
                $userName = Read-Host "Enter your Git username"
                git config --global user.name "$userName"
                Write-Host "[SET] Git username configured: $userName" -ForegroundColor Green
            }
            
            if (-not $gitEmail) {
                $userEmail = Read-Host "Enter your Git email"
                git config --global user.email "$userEmail"
                Write-Host "[SET] Git email configured: $userEmail" -ForegroundColor Green
            }
        } else {
            Write-Host "[CONFIG] Git user: $gitUser <$gitEmail>" -ForegroundColor Green
        }
        
        # Check if we're in a Git repository
        $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
        if ($isGitRepo -eq "true") {
            Write-Host "[REPOSITORY] Currently in Git repository" -ForegroundColor Green
            $currentBranch = git branch --show-current 2>$null
            Write-Host "[BRANCH] Current branch: $currentBranch" -ForegroundColor Cyan
        } else {
            Write-Host "[REPOSITORY] Not in a Git repository (this is normal for the demo)" -ForegroundColor Yellow
        }
        
        return $true
        
    } catch {
        Write-Host "[ERROR] Git setup failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[INFO] Please install Git from: https://git-scm.com/downloads" -ForegroundColor Yellow
        return $false
    }
}

# Initialize Git environment
$gitReady = Initialize-GitEnvironment

$separator = "=" * 80
Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 1: SOURCE CONTROL FUNDAMENTALS AND DEVOPS MINDSET
# ============================================================================
# EXPLANATION: Understanding why source control is essential for Azure automation
# - Collaboration: Multiple developers working on Azure scripts
# - Version Management: Track changes to automation code
# - Rollback Capabilities: Quickly revert to working versions
# - DevOps Integration: Enable CI/CD for Azure deployments
Write-Host "[CONCEPT 1] Source Control Fundamentals and DevOps Mindset" -ForegroundColor White
Write-Host "Understanding Git's role in Azure automation and DevOps workflows" -ForegroundColor Gray

Write-Host "`n[SOURCE CONTROL BENEFITS] Why Git is essential for Azure automation:" -ForegroundColor Yellow
Write-Host "  1. Collaboration: Multiple developers working on Azure scripts" -ForegroundColor Gray
Write-Host "  2. Version Management: Track changes to automation code over time" -ForegroundColor Gray
Write-Host "  3. Rollback Capabilities: Quickly revert to working versions" -ForegroundColor Gray
Write-Host "  4. Branch Management: Parallel development of Azure features" -ForegroundColor Gray
Write-Host "  5. DevOps Integration: Enable CI/CD for Azure deployments" -ForegroundColor Gray
Write-Host "  6. Audit Trail: Track who changed what and when" -ForegroundColor Gray

Write-Host "`n[DEVOPS MINDSET] Continuous Integration/Continuous Delivery cycle:" -ForegroundColor Yellow
Write-Host "  Plan → Build → Deploy → Operate → Feedback → Plan (repeat)" -ForegroundColor Cyan

function Show-DevOpsCycle {
    Write-Host "`n[CI/CD PIPELINE] Azure automation DevOps workflow:" -ForegroundColor Cyan
    
    Write-Host "`n  [PLAN] Azure Infrastructure Requirements" -ForegroundColor Yellow
    Write-Host "    • Identify Azure resources needed" -ForegroundColor Gray
    Write-Host "    • Design automation scripts" -ForegroundColor Gray
    Write-Host "    • Create feature branches for development" -ForegroundColor Gray
    
    Write-Host "`n  [BUILD] Code Development & Testing" -ForegroundColor Yellow
    Write-Host "    • Write PowerShell Azure automation scripts" -ForegroundColor Gray
    Write-Host "    • Commit changes to feature branches" -ForegroundColor Gray
    Write-Host "    • Run automated tests (Pester, validation)" -ForegroundColor Gray
    
    Write-Host "`n  [DEPLOY] Azure Resource Provisioning" -ForegroundColor Yellow
    Write-Host "    • Merge to main branch triggers deployment" -ForegroundColor Gray
    Write-Host "    • Automated Azure resource provisioning" -ForegroundColor Gray
    Write-Host "    • Environment-specific configurations" -ForegroundColor Gray
    
    Write-Host "`n  [OPERATE] Monitoring & Maintenance" -ForegroundColor Yellow
    Write-Host "    • Azure Monitor integration" -ForegroundColor Gray
    Write-Host "    • Log Analytics for script execution" -ForegroundColor Gray
    Write-Host "    • Performance monitoring and alerting" -ForegroundColor Gray
    
    Write-Host "`n  [FEEDBACK] Continuous Improvement" -ForegroundColor Yellow
    Write-Host "    • Analyze deployment success/failures" -ForegroundColor Gray
    Write-Host "    • Collect user feedback on automation" -ForegroundColor Gray
    Write-Host "    • Plan improvements for next iteration" -ForegroundColor Gray
}

Show-DevOpsCycle

Write-Host "`n[GIT vs GITHUB] Understanding the difference:" -ForegroundColor Yellow
Write-Host "  • Git: Distributed version control system (the tool)" -ForegroundColor Gray
Write-Host "  • GitHub: Cloud hosting service for Git repositories" -ForegroundColor Gray
Write-Host "  • Azure DevOps: Microsoft's alternative to GitHub" -ForegroundColor Gray
Write-Host "  • GitLab: Another Git hosting service option" -ForegroundColor Gray

Write-Host "`n[AZURE AUTOMATION BENEFITS] Git integration advantages:" -ForegroundColor Yellow
Write-Host "  • Infrastructure as Code (IaC) version control" -ForegroundColor Gray
Write-Host "  • Automated deployment pipelines" -ForegroundColor Gray
Write-Host "  • Environment-specific configurations" -ForegroundColor Gray
Write-Host "  • Rollback capabilities for failed deployments" -ForegroundColor Gray
Write-Host "  • Collaborative development of Azure solutions" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Git Basics..." -ForegroundColor Magenta
$pause1 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 2: GIT BASICS AND CORE CONCEPTS
# ============================================================================
# EXPLANATION: Understanding Git's core concepts for Azure automation
# - Repository: Main project folder tracking all Azure automation scripts
# - Staging: Area for Azure scripts ready to be committed
# - Commit: Snapshot of Azure automation changes
# - Working Directory: Where you edit Azure automation scripts
Write-Host "[CONCEPT 2] Git Basics and Core Concepts" -ForegroundColor White
Write-Host "Essential Git concepts for Azure automation projects" -ForegroundColor Gray

# Create a temporary demo directory for Git demonstrations
$demoPath = "$env:TEMP\AzureAutomationDemo"
if (Test-Path $demoPath) {
    Remove-Item $demoPath -Recurse -Force
}
New-Item -ItemType Directory -Path $demoPath -Force | Out-Null

function Initialize-DemoRepository {
    param([string]$Path)
    
    Write-Host "[DEMO SETUP] Creating Azure automation repository structure:" -ForegroundColor Cyan
    
    # Change to demo directory
    Set-Location $Path
    
    # Initialize Git repository
    Write-Host "`n[INIT] Initializing Git repository..." -ForegroundColor Yellow
    Write-Host "Command: git init" -ForegroundColor Gray
    git init | Out-Null
    Write-Host "[SUCCESS] Repository initialized" -ForegroundColor Green
    
    # Create Azure automation project structure
    Write-Host "`n[STRUCTURE] Creating Azure automation project structure:" -ForegroundColor Yellow
    
    $directories = @(
        "scripts\azure-resources",
        "scripts\monitoring",
        "templates\arm",
        "templates\bicep",
        "configs\environments",
        "tests",
        "docs"
    )
    
    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
    
    # Create sample Azure automation files
    Write-Host "`n[FILES] Creating sample Azure automation files:" -ForegroundColor Yellow
    
    $readmeContent = @"
# Azure Automation Project

This repository contains PowerShell scripts for Azure resource automation.

## Structure
- scripts/azure-resources/ - Resource management scripts
- scripts/monitoring/ - Monitoring and alerting scripts
- templates/ - ARM and Bicep templates
- configs/ - Environment-specific configurations
- tests/ - Pester tests for validation
- docs/ - Documentation

## Getting Started
1. Configure Azure PowerShell: Connect-AzAccount
2. Review environment configs in configs/environments/
3. Run scripts from scripts/ directory
4. Test with Pester tests in tests/ directory
"@
    $readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
    
    $resourceScript = @"
# Azure Resource Management Script
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]`$ResourceGroupName,
    
    [Parameter(Mandatory)]
    [string]`$Location,
    
    [hashtable]`$Tags = @{}
)

# Create or update Azure resource group
function Deploy-ResourceGroup {
    param(
        [string]`$Name,
        [string]`$Location,
        [hashtable]`$Tags
    )
    
    Write-Host "Deploying resource group: `$Name" -ForegroundColor Cyan
    
    `$rg = Get-AzResourceGroup -Name `$Name -ErrorAction SilentlyContinue
    if (-not `$rg) {
        New-AzResourceGroup -Name `$Name -Location `$Location -Tag `$Tags
        Write-Host "Resource group created successfully" -ForegroundColor Green
    } else {
        Write-Host "Resource group already exists" -ForegroundColor Yellow
    }
}

# Execute deployment
Deploy-ResourceGroup -Name `$ResourceGroupName -Location `$Location -Tags `$Tags
"@
    $resourceScript | Out-File -FilePath "scripts/azure-resources/Deploy-ResourceGroup.ps1" -Encoding UTF8
    
    $configContent = @"
# Development Environment Configuration
@{
    SubscriptionId = "your-dev-subscription-id"
    ResourceGroupName = "rg-azure-automation-dev"
    Location = "East US"
    Tags = @{
        Environment = "Development"
        Project = "Azure Automation"
        Owner = "DevOps Team"
    }
}
"@
    $configContent | Out-File -FilePath "configs/environments/dev.psd1" -Encoding UTF8
    
    $gitignoreContent = @"
# PowerShell
*.ps1~
*.log

# Azure
.azure/
*.publishsettings

# VS Code
.vscode/settings.json

# Temporary files
*.tmp
temp/

# Secrets (never commit these!)
secrets.json
*.key
*.pfx
"@
    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    
    Write-Host "  Created: README.md" -ForegroundColor Gray
    Write-Host "  Created: scripts/azure-resources/Deploy-ResourceGroup.ps1" -ForegroundColor Gray
    Write-Host "  Created: configs/environments/dev.psd1" -ForegroundColor Gray
    Write-Host "  Created: .gitignore" -ForegroundColor Gray
    
    Write-Host "`n[SUCCESS] Azure automation repository structure created" -ForegroundColor Green
}

if ($gitReady) {
    Initialize-DemoRepository -Path $demoPath
    
    Write-Host "`n[GIT STATUS] Checking repository status:" -ForegroundColor Yellow
    Write-Host "Command: git status" -ForegroundColor Gray
    git status
    
    Write-Host "`n[CORE CONCEPTS] Git workflow explanation:" -ForegroundColor Yellow
    Write-Host "  1. Working Directory: Where you edit Azure automation scripts" -ForegroundColor Gray
    Write-Host "  2. Staging Area: Files ready to be committed to repository" -ForegroundColor Gray
    Write-Host "  3. Repository: Permanent storage of Azure automation history" -ForegroundColor Gray
    Write-Host "  4. Remote Repository: Shared repository (GitHub, Azure DevOps)" -ForegroundColor Gray
    
    Write-Host "`n[STAGING] Adding files to staging area:" -ForegroundColor Cyan
    Write-Host "Command: git add ." -ForegroundColor Gray
    git add .
    Write-Host "[SUCCESS] Files staged for commit" -ForegroundColor Green
    
    Write-Host "`n[STATUS AFTER STAGING] Repository status:" -ForegroundColor Yellow
    git status
    
    Write-Host "`n[COMMIT] Creating first commit:" -ForegroundColor Cyan
    Write-Host "Command: git commit -m 'Initial Azure automation project setup'" -ForegroundColor Gray
    git commit -m "Initial Azure automation project setup" | Out-Null
    Write-Host "[SUCCESS] Initial commit created" -ForegroundColor Green
    
    Write-Host "`n[LOG] Viewing commit history:" -ForegroundColor Yellow
    Write-Host "Command: git log --oneline" -ForegroundColor Gray
    git log --oneline
    
} else {
    Write-Host "[SKIP] Git not available - showing conceptual examples" -ForegroundColor Yellow
    Write-Host "`nExample Git commands for Azure automation projects:" -ForegroundColor Cyan
    Write-Host "  git init                              # Initialize repository" -ForegroundColor Gray
    Write-Host "  git add scripts/Deploy-Resources.ps1  # Stage specific file" -ForegroundColor Gray
    Write-Host "  git add .                             # Stage all changes" -ForegroundColor Gray
    Write-Host "  git status                            # Check repository status" -ForegroundColor Gray
    Write-Host "  git commit -m 'Add resource deployment script'  # Commit changes" -ForegroundColor Gray
    Write-Host "  git log --oneline                     # View commit history" -ForegroundColor Gray
}

Write-Host "`n[BEST PRACTICES] Git commit messages for Azure automation:" -ForegroundColor Yellow
Write-Host "  • Use clear, descriptive messages" -ForegroundColor Gray
Write-Host "  • Include Azure resource types affected" -ForegroundColor Gray
Write-Host "  • Reference work items or issues" -ForegroundColor Gray
Write-Host "  • Example: 'Add storage account deployment script for dev environment'" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Working with Remote Repositories..." -ForegroundColor Magenta
$pause2 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 3: WORKING WITH REMOTE REPOSITORIES
# ============================================================================
# EXPLANATION: Collaborating on Azure automation projects using remote repositories
# - Clone: Download existing Azure automation projects
# - Push: Share your Azure automation changes
# - Pull: Get latest Azure automation updates
# - Fetch: Check for remote changes without merging
Write-Host "[CONCEPT 3] Working with Remote Repositories" -ForegroundColor White
Write-Host "Collaborating on Azure automation projects with remote Git repositories" -ForegroundColor Gray

function Show-RemoteWorkflow {
    Write-Host "`n[REMOTE WORKFLOW] Common scenarios for Azure automation teams:" -ForegroundColor Cyan
    
    Write-Host "`n[SCENARIO 1] Cloning existing Azure automation project:" -ForegroundColor Yellow
    Write-Host "Command: git clone https://github.com/company/azure-automation.git" -ForegroundColor Gray
    Write-Host "  • Downloads complete Azure automation repository" -ForegroundColor Gray
    Write-Host "  • Includes all scripts, templates, and configuration files" -ForegroundColor Gray
    Write-Host "  • Sets up local working directory automatically" -ForegroundColor Gray
    
    Write-Host "`n[SCENARIO 2] Pushing Azure automation changes:" -ForegroundColor Yellow
    Write-Host "Commands:" -ForegroundColor Gray
    Write-Host "  git add scripts/new-vm-deployment.ps1" -ForegroundColor Gray
    Write-Host "  git commit -m 'Add VM deployment automation script'" -ForegroundColor Gray
    Write-Host "  git push origin main" -ForegroundColor Gray
    Write-Host "  • Shares your Azure automation improvements with the team" -ForegroundColor Gray
    Write-Host "  • Triggers CI/CD pipelines for automated testing" -ForegroundColor Gray
    
    Write-Host "`n[SCENARIO 3] Getting latest Azure automation updates:" -ForegroundColor Yellow
    Write-Host "Command: git pull origin main" -ForegroundColor Gray
    Write-Host "  • Downloads latest Azure automation scripts" -ForegroundColor Gray
    Write-Host "  • Merges changes into your local branch" -ForegroundColor Gray
    Write-Host "  • Keeps your environment synchronized with team" -ForegroundColor Gray
    
    Write-Host "`n[SCENARIO 4] Checking for remote changes:" -ForegroundColor Yellow
    Write-Host "Commands:" -ForegroundColor Gray
    Write-Host "  git fetch origin" -ForegroundColor Gray
    Write-Host "  git status" -ForegroundColor Gray
    Write-Host "  git log --oneline origin/main..HEAD" -ForegroundColor Gray
    Write-Host "  • Checks for new Azure automation updates" -ForegroundColor Gray
    Write-Host "  • Shows commits you haven't pulled yet" -ForegroundColor Gray
    Write-Host "  • Allows you to review changes before merging" -ForegroundColor Gray
}

Show-RemoteWorkflow

function Simulate-ConflictResolution {
    Write-Host "`n[CONFLICT RESOLUTION] Handling Azure automation conflicts:" -ForegroundColor Cyan
    
    Write-Host "`n[CONFLICT SCENARIO] Multiple developers modify the same Azure script:" -ForegroundColor Yellow
    Write-Host "  1. Developer A modifies Deploy-StorageAccount.ps1" -ForegroundColor Gray
    Write-Host "  2. Developer B also modifies Deploy-StorageAccount.ps1" -ForegroundColor Gray
    Write-Host "  3. Developer A pushes changes first" -ForegroundColor Gray
    Write-Host "  4. Developer B tries to push - conflict occurs!" -ForegroundColor Gray
    
    Write-Host "`n[CONFLICT RESOLUTION STEPS]:" -ForegroundColor Yellow
    Write-Host "  1. git pull origin main  # Get latest changes" -ForegroundColor Gray
    Write-Host "  2. Git shows conflict markers in file:" -ForegroundColor Gray
    
    $conflictExample = @"
<<<<<<< HEAD (Your changes)
`$storageAccountName = "storage`$env:USERNAME`$((Get-Date).ToString('yyyyMMdd'))"
=======
`$storageAccountName = "azurestorage`$((Get-Random -Minimum 1000 -Maximum 9999))"
>>>>>>> origin/main (Remote changes)
"@
    Write-Host $conflictExample -ForegroundColor Red
    
    Write-Host "`n  3. Manually resolve conflicts by choosing/combining changes" -ForegroundColor Gray
    Write-Host "  4. Remove conflict markers (<<<<<<, ======, >>>>>>)" -ForegroundColor Gray
    Write-Host "  5. git add Deploy-StorageAccount.ps1" -ForegroundColor Gray
    Write-Host "  6. git commit -m 'Resolve storage account naming conflict'" -ForegroundColor Gray
    Write-Host "  7. git push origin main" -ForegroundColor Gray
    
    Write-Host "`n[CONFLICT PREVENTION] Best practices for Azure automation teams:" -ForegroundColor Yellow
    Write-Host "  • Pull latest changes before starting work" -ForegroundColor Gray
    Write-Host "  • Use feature branches for major Azure automation changes" -ForegroundColor Gray
    Write-Host "  • Communicate with team about shared Azure scripts" -ForegroundColor Gray
    Write-Host "  • Use modular design to minimize overlap" -ForegroundColor Gray
    Write-Host "  • Regular integration to catch conflicts early" -ForegroundColor Gray
}

Simulate-ConflictResolution

if ($gitReady -and (Test-Path $demoPath)) {
    Set-Location $demoPath
    
    Write-Host "`n[DEMO] Adding remote repository configuration:" -ForegroundColor Cyan
    Write-Host "Command: git remote add origin https://github.com/user/azure-automation.git" -ForegroundColor Gray
    # Note: We won't actually add a remote in this demo
    Write-Host "[INFO] In practice, this would connect to your Azure DevOps or GitHub repository" -ForegroundColor Yellow
    
    Write-Host "`n[REMOTE COMMANDS] Essential remote repository commands:" -ForegroundColor Yellow
    Write-Host "  git remote -v                    # List configured remotes" -ForegroundColor Gray
    Write-Host "  git remote add origin <url>      # Add remote repository" -ForegroundColor Gray
    Write-Host "  git fetch origin                 # Get remote changes (no merge)" -ForegroundColor Gray
    Write-Host "  git pull origin main             # Get and merge remote changes" -ForegroundColor Gray
    Write-Host "  git push origin main             # Send local changes to remote" -ForegroundColor Gray
    Write-Host "  git push -u origin feature-branch  # Push new branch to remote" -ForegroundColor Gray
}

Write-Host "`n[AZURE DEVOPS INTEGRATION] Benefits for Azure automation:" -ForegroundColor Yellow
Write-Host "  • Azure Pipelines for automated deployment" -ForegroundColor Gray
Write-Host "  • Azure Repos for Git repository hosting" -ForegroundColor Gray
Write-Host "  • Work item tracking for Azure projects" -ForegroundColor Gray
Write-Host "  • Integration with Azure Resource Manager" -ForegroundColor Gray
Write-Host "  • Built-in Azure authentication and authorization" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Branching and Merging..." -ForegroundColor Magenta
$pause3 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 4: BRANCHING AND MERGING STRATEGIES
# ============================================================================
# EXPLANATION: Using Git branches for Azure automation development
# - Feature branches: Develop new Azure automation features
# - Release branches: Prepare Azure deployments for production
# - Hotfix branches: Quick fixes for production Azure issues
Write-Host "[CONCEPT 4] Branching and Merging Strategies" -ForegroundColor White
Write-Host "Managing Azure automation development with Git branches" -ForegroundColor Gray

function Show-BranchingStrategies {
    Write-Host "`n[BRANCHING STRATEGIES] Common approaches for Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[STRATEGY 1] GitFlow for Azure Automation:" -ForegroundColor Yellow
    Write-Host "  • main: Production-ready Azure automation scripts" -ForegroundColor Gray
    Write-Host "  • develop: Integration branch for Azure features" -ForegroundColor Gray
    Write-Host "  • feature/*: Individual Azure automation features" -ForegroundColor Gray
    Write-Host "  • release/*: Prepare Azure deployments for production" -ForegroundColor Gray
    Write-Host "  • hotfix/*: Critical fixes for production Azure issues" -ForegroundColor Gray
    
    Write-Host "`n[STRATEGY 2] GitHub Flow (Simplified):" -ForegroundColor Yellow
    Write-Host "  • main: Always deployable Azure automation code" -ForegroundColor Gray
    Write-Host "  • feature branches: All Azure automation development" -ForegroundColor Gray
    Write-Host "  • Pull requests: Code review and testing" -ForegroundColor Gray
    Write-Host "  • Continuous deployment from main branch" -ForegroundColor Gray
    
    Write-Host "`n[STRATEGY 3] Environment-Based Branching:" -ForegroundColor Yellow
    Write-Host "  • main: Production Azure environment" -ForegroundColor Gray
    Write-Host "  • staging: Pre-production Azure testing" -ForegroundColor Gray
    Write-Host "  • development: Development Azure environment" -ForegroundColor Gray
    Write-Host "  • feature/*: Individual Azure features" -ForegroundColor Gray
}

Show-BranchingStrategies

if ($gitReady -and (Test-Path $demoPath)) {
    Set-Location $demoPath
    
    Write-Host "`n[BRANCHING DEMO] Creating Azure automation feature branches:" -ForegroundColor Cyan
    
    # Show current branch
    Write-Host "`n[CURRENT] Checking current branch:" -ForegroundColor Yellow
    Write-Host "Command: git branch" -ForegroundColor Gray
    git branch
    
    # Create feature branch for new Azure monitoring script
    Write-Host "`n[CREATE] Creating feature branch for Azure monitoring:" -ForegroundColor Yellow
    Write-Host "Command: git checkout -b feature/azure-monitoring" -ForegroundColor Gray
    git checkout -b feature/azure-monitoring
    Write-Host "[SUCCESS] Feature branch created and checked out" -ForegroundColor Green
    
    # Create new monitoring script
    Write-Host "`n[DEVELOPMENT] Adding Azure monitoring script:" -ForegroundColor Yellow
    $monitoringScript = @"
# Azure Resource Monitoring Script
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]`$ResourceGroupName,
    
    [string]`$AlertEmail = "admin@company.com"
)

function Set-AzureResourceAlert {
    param(
        [string]`$ResourceGroup,
        [string]`$Email
    )
    
    Write-Host "Setting up monitoring for resource group: `$ResourceGroup" -ForegroundColor Cyan
    
    # Get all resources in the resource group
    `$resources = Get-AzResource -ResourceGroupName `$ResourceGroup
    
    foreach (`$resource in `$resources) {
        Write-Host "Configuring alerts for: `$(`$resource.Name)" -ForegroundColor Gray
        
        # Configure monitoring alerts (implementation would use Azure Monitor)
        # This is a placeholder for actual Azure Monitor configuration
        `$alertConfig = @{
            ResourceId = `$resource.ResourceId
            MetricName = "CPU_Percentage"
            Threshold = 80
            Email = `$Email
        }
        
        Write-Host "Alert configured for `$(`$resource.ResourceType)" -ForegroundColor Green
    }
}

# Execute monitoring setup
Set-AzureResourceAlert -ResourceGroup `$ResourceGroupName -Email `$AlertEmail
"@
    $monitoringScript | Out-File -FilePath "scripts/monitoring/Set-ResourceAlerts.ps1" -Encoding UTF8
    Write-Host "  Created: scripts/monitoring/Set-ResourceAlerts.ps1" -ForegroundColor Gray
    
    # Stage and commit the new feature
    Write-Host "`n[COMMIT] Committing Azure monitoring feature:" -ForegroundColor Yellow
    Write-Host "Commands:" -ForegroundColor Gray
    Write-Host "  git add scripts/monitoring/Set-ResourceAlerts.ps1" -ForegroundColor Gray
    Write-Host "  git commit -m 'Add Azure resource monitoring and alerting script'" -ForegroundColor Gray
    
    git add scripts/monitoring/Set-ResourceAlerts.ps1
    git commit -m "Add Azure resource monitoring and alerting script" | Out-Null
    Write-Host "[SUCCESS] Feature committed to branch" -ForegroundColor Green
    
    # Show branch structure
    Write-Host "`n[BRANCHES] Current branch structure:" -ForegroundColor Yellow
    Write-Host "Command: git branch -v" -ForegroundColor Gray
    git branch -v
    
    # Switch back to main branch
    Write-Host "`n[SWITCH] Switching back to main branch:" -ForegroundColor Yellow
    Write-Host "Command: git checkout main" -ForegroundColor Gray
    git checkout main
    
    # Merge feature branch
    Write-Host "`n[MERGE] Merging Azure monitoring feature:" -ForegroundColor Yellow
    Write-Host "Command: git merge feature/azure-monitoring" -ForegroundColor Gray
    git merge feature/azure-monitoring
    Write-Host "[SUCCESS] Feature merged successfully" -ForegroundColor Green
    
    # Clean up feature branch
    Write-Host "`n[CLEANUP] Removing feature branch:" -ForegroundColor Yellow
    Write-Host "Command: git branch -d feature/azure-monitoring" -ForegroundColor Gray
    git branch -d feature/azure-monitoring
    Write-Host "[SUCCESS] Feature branch cleaned up" -ForegroundColor Green
    
    # Show final commit log
    Write-Host "`n[HISTORY] Updated commit history:" -ForegroundColor Yellow
    Write-Host "Command: git log --oneline" -ForegroundColor Gray
    git log --oneline
    
} else {
    Write-Host "`n[EXAMPLES] Branching commands for Azure automation:" -ForegroundColor Cyan
    Write-Host "  git branch                                    # List branches" -ForegroundColor Gray
    Write-Host "  git branch feature/azure-storage             # Create branch" -ForegroundColor Gray
    Write-Host "  git checkout feature/azure-storage           # Switch to branch" -ForegroundColor Gray
    Write-Host "  git checkout -b feature/azure-networking     # Create and switch" -ForegroundColor Gray
    Write-Host "  git merge feature/azure-storage              # Merge branch" -ForegroundColor Gray
    Write-Host "  git branch -d feature/azure-storage          # Delete branch" -ForegroundColor Gray
}

Write-Host "`n[BRANCH NAMING] Conventions for Azure automation projects:" -ForegroundColor Yellow
Write-Host "  • feature/azure-storage-automation     # New Azure storage features" -ForegroundColor Gray
Write-Host "  • bugfix/vm-deployment-timeout        # Bug fixes" -ForegroundColor Gray
Write-Host "  • hotfix/production-network-issue     # Critical production fixes" -ForegroundColor Gray
Write-Host "  • release/v2.1.0                      # Release preparation" -ForegroundColor Gray
Write-Host "  • experiment/serverless-migration     # Experimental changes" -ForegroundColor Gray

Write-Host "`n[MERGE STRATEGIES] Options for Azure automation teams:" -ForegroundColor Yellow
Write-Host "  • Merge commits: Preserves branch history, shows feature development" -ForegroundColor Gray
Write-Host "  • Squash merging: Clean linear history, combines feature commits" -ForegroundColor Gray
Write-Host "  • Rebase merging: Linear history without merge commits" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Feature Flags..." -ForegroundColor Magenta
$pause4 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 5: FEATURE FLAGS AND ADVANCED GIT COMMANDS
# ============================================================================
# EXPLANATION: Alternative approaches to branching and advanced Git operations
# - Feature flags: Runtime control of Azure automation features
# - Git revert: Safe rollback of Azure automation changes
# - Git reset: Local history management
# - Git rebase: Clean commit history for Azure projects
Write-Host "[CONCEPT 5] Feature Flags and Advanced Git Commands" -ForegroundColor White
Write-Host "Alternative development approaches and advanced Git operations for Azure automation" -ForegroundColor Gray

function Show-FeatureFlags {
    Write-Host "`n[FEATURE FLAGS] Alternative to branching for Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[CONCEPT] Runtime control of Azure automation features:" -ForegroundColor Yellow
    Write-Host "  • Toggle Azure features on/off without code deployment" -ForegroundColor Gray
    Write-Host "  • A/B testing of different Azure automation approaches" -ForegroundColor Gray
    Write-Host "  • Gradual rollout of new Azure features" -ForegroundColor Gray
    Write-Host "  • Quick disable of problematic Azure automation" -ForegroundColor Gray
    
    # Create feature flag configuration example
    $featureFlagConfig = @"
# Azure Automation Feature Flags Configuration
@{
    # Storage automation features
    EnableAdvancedStorageConfig = `$true
    UseStorageAccountV2 = `$false
    EnableStorageAnalytics = `$true
    
    # Virtual machine features
    EnableAutoScaling = `$false
    UseSpotInstances = `$true
    EnableVMBackup = `$true
    
    # Networking features
    EnableVNetPeering = `$true
    UsePrivateEndpoints = `$false
    EnableNetworkWatcher = `$true
    
    # Monitoring and alerting
    EnableDetailedMonitoring = `$true
    SendSlackNotifications = `$false
    UseCustomDashboards = `$true
}
"@
    
    Write-Host "`n[EXAMPLE] Feature flag configuration file (feature-flags.psd1):" -ForegroundColor Yellow
    Write-Host $featureFlagConfig -ForegroundColor Gray
    
    # Create example script using feature flags
    $featureFlagScript = @"
# Azure Storage Deployment with Feature Flags
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]`$ResourceGroupName,
    
    [string]`$ConfigPath = "configs/feature-flags.psd1"
)

# Load feature flags
`$featureFlags = Import-PowerShellDataFile -Path `$ConfigPath

function Deploy-StorageAccount {
    param(
        [string]`$ResourceGroup,
        [hashtable]`$Features
    )
    
    Write-Host "Deploying storage account to: `$ResourceGroup" -ForegroundColor Cyan
    
    # Base storage account parameters
    `$storageParams = @{
        ResourceGroupName = `$ResourceGroup
        Name = "storage`$((Get-Date).ToString('yyyyMMdd'))"
        Location = "East US"
        SkuName = "Standard_LRS"
    }
    
    # Feature flag: Use Storage Account V2
    if (`$Features.UseStorageAccountV2) {
        Write-Host "[FEATURE] Using Storage Account V2" -ForegroundColor Green
        `$storageParams.Kind = "StorageV2"
    } else {
        Write-Host "[DEFAULT] Using standard storage account" -ForegroundColor Yellow
        `$storageParams.Kind = "Storage"
    }
    
    # Feature flag: Enable storage analytics
    if (`$Features.EnableStorageAnalytics) {
        Write-Host "[FEATURE] Enabling storage analytics" -ForegroundColor Green
        # Configure storage analytics (implementation details)
    }
    
    # Feature flag: Advanced storage configuration
    if (`$Features.EnableAdvancedStorageConfig) {
        Write-Host "[FEATURE] Applying advanced storage configuration" -ForegroundColor Green
        `$storageParams.EnableHttpsTrafficOnly = `$true
        `$storageParams.MinimumTlsVersion = "TLS1_2"
    }
    
    # Create storage account (simulated)
    Write-Host "Storage account configured with enabled features" -ForegroundColor Green
    return `$storageParams
}

# Execute with feature flags
`$result = Deploy-StorageAccount -ResourceGroup `$ResourceGroupName -Features `$featureFlags
Write-Host "Deployment completed with feature flags: `$(`$featureFlags.Keys -join ', ')" -ForegroundColor Cyan
"@
    
    Write-Host "`n[EXAMPLE] PowerShell script using feature flags:" -ForegroundColor Yellow
    Write-Host $featureFlagScript -ForegroundColor Gray
}

Show-FeatureFlags

function Show-AdvancedGitCommands {
    Write-Host "`n[ADVANCED GIT COMMANDS] Essential operations for Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[GIT REVERT] Safe rollback of Azure automation changes:" -ForegroundColor Yellow
    Write-Host "  Scenario: New Azure VM deployment script causes issues" -ForegroundColor Gray
    Write-Host "  Command: git revert <commit-hash>" -ForegroundColor Gray
    Write-Host "  • Creates new commit that undoes problematic changes" -ForegroundColor Gray
    Write-Host "  • Preserves history - safe for shared repositories" -ForegroundColor Gray
    Write-Host "  • Allows quick rollback while maintaining audit trail" -ForegroundColor Gray
    
    Write-Host "`n[GIT RESET] Local history management (use with caution):" -ForegroundColor Yellow
    Write-Host "  Scenario: Multiple local commits before pushing to remote" -ForegroundColor Gray
    Write-Host "  Commands:" -ForegroundColor Gray
    Write-Host "    git reset --soft HEAD~2    # Keep changes, undo 2 commits" -ForegroundColor Gray
    Write-Host "    git reset --mixed HEAD~1   # Unstage changes, undo 1 commit" -ForegroundColor Gray
    Write-Host "    git reset --hard HEAD~1    # Delete changes, undo 1 commit" -ForegroundColor Gray
    Write-Host "  ⚠️  WARNING: --hard deletes work, only use locally!" -ForegroundColor Red
    
    Write-Host "`n[GIT REBASE] Clean commit history for Azure projects:" -ForegroundColor Yellow
    Write-Host "  Scenario: Clean up feature branch before merging" -ForegroundColor Gray
    Write-Host "  Commands:" -ForegroundColor Gray
    Write-Host "    git rebase -i HEAD~3       # Interactive rebase last 3 commits" -ForegroundColor Gray
    Write-Host "    git rebase main            # Rebase feature branch onto main" -ForegroundColor Gray
    Write-Host "  • Combines related Azure automation commits" -ForegroundColor Gray
    Write-Host "  • Creates linear project history" -ForegroundColor Gray
    Write-Host "  ⚠️  WARNING: Don't rebase public/shared branches!" -ForegroundColor Red
    
    Write-Host "`n[GIT CHERRY-PICK] Apply specific Azure fixes across branches:" -ForegroundColor Yellow
    Write-Host "  Scenario: Critical Azure fix needed in multiple environments" -ForegroundColor Gray
    Write-Host "  Commands:" -ForegroundColor Gray
    Write-Host "    git checkout production" -ForegroundColor Gray
    Write-Host "    git cherry-pick <commit-from-dev>" -ForegroundColor Gray
    Write-Host "  • Applies specific Azure automation fixes" -ForegroundColor Gray
    Write-Host "  • Maintains separate branch histories" -ForegroundColor Gray
    Write-Host "  • Useful for hotfixes and backporting" -ForegroundColor Gray
}

Show-AdvancedGitCommands

if ($gitReady -and (Test-Path $demoPath)) {
    Set-Location $demoPath
    
    # Create feature flag configuration file
    Write-Host "`n[DEMO] Creating feature flag configuration:" -ForegroundColor Cyan
    $featureFlagContent = @"
# Azure Automation Feature Flags
@{
    EnableAdvancedStorageConfig = `$true
    UseStorageAccountV2 = `$false
    EnableStorageAnalytics = `$true
    EnableAutoScaling = `$false
    UseSpotInstances = `$true
    EnableVMBackup = `$true
}
"@
    $featureFlagContent | Out-File -FilePath "configs/feature-flags.psd1" -Encoding UTF8
    
    # Create script that uses feature flags
    $flagScript = @"
# Feature Flag Demo Script
`$flags = Import-PowerShellDataFile -Path "configs/feature-flags.psd1"

Write-Host "Azure Automation Feature Status:" -ForegroundColor Cyan
foreach (`$feature in `$flags.GetEnumerator()) {
    `$status = if (`$feature.Value) { "ENABLED" } else { "DISABLED" }
    `$color = if (`$feature.Value) { "Green" } else { "Yellow" }
    Write-Host "  `$(`$feature.Key): `$status" -ForegroundColor `$color
}
"@
    $flagScript | Out-File -FilePath "scripts/Show-FeatureFlags.ps1" -Encoding UTF8
    
    Write-Host "  Created: configs/feature-flags.psd1" -ForegroundColor Gray
    Write-Host "  Created: scripts/Show-FeatureFlags.ps1" -ForegroundColor Gray
    
    # Commit the feature flag changes
    Write-Host "`n[COMMIT] Adding feature flag configuration:" -ForegroundColor Yellow
    git add configs/feature-flags.psd1 scripts/Show-FeatureFlags.ps1
    git commit -m "Add feature flag configuration for Azure automation" | Out-Null
    Write-Host "[SUCCESS] Feature flags committed" -ForegroundColor Green
    
    # Demonstrate git log with formatting
    Write-Host "`n[HISTORY] Formatted commit history:" -ForegroundColor Yellow
    Write-Host "Command: git log --oneline --graph --decorate" -ForegroundColor Gray
    git log --oneline --graph --decorate
}

Write-Host "`n[BEST PRACTICES] Advanced Git usage for Azure automation:" -ForegroundColor Yellow
Write-Host "  • Use revert for shared repository rollbacks" -ForegroundColor Gray
Write-Host "  • Use reset only for local, unpushed commits" -ForegroundColor Gray
Write-Host "  • Use rebase to clean up feature branch history" -ForegroundColor Gray
Write-Host "  • Use cherry-pick for selective fixes across environments" -ForegroundColor Gray
Write-Host "  • Combine branching with feature flags for flexible deployment" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to continue to Visual Studio Code Integration..." -ForegroundColor Magenta
$pause5 = Read-Host

Write-Host "`n$separator" -ForegroundColor DarkGray

# ============================================================================
# CONCEPT 6: VISUAL STUDIO CODE INTEGRATION AND BEST PRACTICES
# ============================================================================
# EXPLANATION: Using VS Code for Azure automation development with Git
# - Integrated source control for Azure projects
# - Extensions for PowerShell and Azure development
# - Collaborative features for Azure automation teams
Write-Host "[CONCEPT 6] Visual Studio Code Integration and Best Practices" -ForegroundColor White
Write-Host "Optimizing VS Code for Azure automation development with Git integration" -ForegroundColor Gray

function Show-VSCodeGitIntegration {
    Write-Host "`n[VS CODE GIT FEATURES] Built-in source control for Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[SOURCE CONTROL PANEL] Git operations in VS Code:" -ForegroundColor Yellow
    Write-Host "  • Visual file diff for Azure script changes" -ForegroundColor Gray
    Write-Host "  • Stage/unstage files with single clicks" -ForegroundColor Gray
    Write-Host "  • Commit with integrated message editor" -ForegroundColor Gray
    Write-Host "  • Branch switching and merging through UI" -ForegroundColor Gray
    Write-Host "  • Conflict resolution with visual merge tool" -ForegroundColor Gray
    
    Write-Host "`n[INTEGRATED TERMINAL] PowerShell and Git commands:" -ForegroundColor Yellow
    Write-Host "  • PowerShell terminal for Azure script testing" -ForegroundColor Gray
    Write-Host "  • Git commands directly in VS Code terminal" -ForegroundColor Gray
    Write-Host "  • Multiple terminals for different environments" -ForegroundColor Gray
    
    Write-Host "`n[TIMELINE VIEW] File history and changes:" -ForegroundColor Yellow
    Write-Host "  • Visual timeline of Azure script modifications" -ForegroundColor Gray
    Write-Host "  • Compare file versions side by side" -ForegroundColor Gray
    Write-Host "  • Restore previous versions of Azure automation scripts" -ForegroundColor Gray
}

Show-VSCodeGitIntegration

function Show-RecommendedExtensions {
    Write-Host "`n[RECOMMENDED EXTENSIONS] Essential VS Code extensions for Azure automation:" -ForegroundColor Cyan
    
    Write-Host "`n[POWERSHELL DEVELOPMENT]:" -ForegroundColor Yellow
    Write-Host "  • PowerShell - Official PowerShell language support" -ForegroundColor Gray
    Write-Host "  • Azure PowerShell - Azure cmdlet IntelliSense and snippets" -ForegroundColor Gray
    Write-Host "  • PowerShell Pro Tools - Advanced PowerShell debugging and profiling" -ForegroundColor Gray
    
    Write-Host "`n[GIT AND SOURCE CONTROL]:" -ForegroundColor Yellow
    Write-Host "  • GitLens - Supercharged Git capabilities in VS Code" -ForegroundColor Gray
    Write-Host "  • Git File History - Visual file history and diff" -ForegroundColor Gray
    Write-Host "  • GitHub Pull Requests - Integrate with GitHub workflows" -ForegroundColor Gray
    Write-Host "  • Azure DevOps - Integration with Azure DevOps services" -ForegroundColor Gray
    
    Write-Host "`n[AZURE DEVELOPMENT]:" -ForegroundColor Yellow
    Write-Host "  • Azure Tools - Complete Azure development toolkit" -ForegroundColor Gray
    Write-Host "  • Azure Resource Manager (ARM) Tools - ARM template support" -ForegroundColor Gray
    Write-Host "  • Bicep - Azure Bicep language support" -ForegroundColor Gray
    Write-Host "  • Azure Functions - Develop and deploy Azure Functions" -ForegroundColor Gray
    
    Write-Host "`n[CODE QUALITY]:" -ForegroundColor Yellow
    Write-Host "  • Code Spell Checker - Catch typos in Azure automation scripts" -ForegroundColor Gray
    Write-Host "  • TODO Tree - Track TODO items in Azure projects" -ForegroundColor Gray
    Write-Host "  • Bracket Pair Colorizer 2 - Visual bracket matching" -ForegroundColor Gray
    Write-Host "  • Indent Rainbow - Visual indentation guides" -ForegroundColor Gray
    
    Write-Host "`n[COLLABORATION]:" -ForegroundColor Yellow
    Write-Host "  • Live Share - Real-time collaborative Azure automation development" -ForegroundColor Gray
    Write-Host "  • Live Share Audio - Voice chat during collaboration" -ForegroundColor Gray
    Write-Host "  • Comments - Code review and collaboration" -ForegroundColor Gray
    
    Write-Host "`n[DOCUMENTATION]:" -ForegroundColor Yellow
    Write-Host "  • Markdown All in One - Documentation for Azure projects" -ForegroundColor Gray
    Write-Host "  • Docs Authoring Pack - Microsoft documentation tools" -ForegroundColor Gray
    Write-Host "  • Excel Viewer - View CSV data in Azure automation projects" -ForegroundColor Gray
}

Show-RecommendedExtensions

function Show-VSCodeWorkflows {
    Write-Host "`n[VS CODE WORKFLOWS] Efficient Azure automation development:" -ForegroundColor Cyan
    
    Write-Host "`n[WORKFLOW 1] Azure script development cycle:" -ForegroundColor Yellow
    Write-Host "  1. Open Azure automation project in VS Code" -ForegroundColor Gray
    Write-Host "  2. Create feature branch using Source Control panel" -ForegroundColor Gray
    Write-Host "  3. Develop PowerShell scripts with IntelliSense" -ForegroundColor Gray
    Write-Host "  4. Test scripts in integrated PowerShell terminal" -ForegroundColor Gray
    Write-Host "  5. Stage and commit changes using Source Control" -ForegroundColor Gray
    Write-Host "  6. Push to remote repository" -ForegroundColor Gray
    Write-Host "  7. Create pull request for code review" -ForegroundColor Gray
    
    Write-Host "`n[WORKFLOW 2] Collaborative Azure project development:" -ForegroundColor Yellow
    Write-Host "  1. Start Live Share session for pair programming" -ForegroundColor Gray
    Write-Host "  2. Share Azure automation workspace with team" -ForegroundColor Gray
    Write-Host "  3. Collaboratively develop Azure scripts" -ForegroundColor Gray
    Write-Host "  4. Test in shared terminal sessions" -ForegroundColor Gray
    Write-Host "  5. Review changes using GitLens annotations" -ForegroundColor Gray
    Write-Host "  6. Commit and push collaborative changes" -ForegroundColor Gray
    
    Write-Host "`n[WORKFLOW 3] Conflict resolution in Azure projects:" -ForegroundColor Yellow
    Write-Host "  1. VS Code detects merge conflicts in Azure scripts" -ForegroundColor Gray
    Write-Host "  2. Use visual merge editor to resolve conflicts" -ForegroundColor Gray
    Write-Host "  3. Compare 'Current Change' vs 'Incoming Change'" -ForegroundColor Gray
    Write-Host "  4. Accept, reject, or combine Azure automation logic" -ForegroundColor Gray
    Write-Host "  5. Test resolved Azure script in terminal" -ForegroundColor Gray
    Write-Host "  6. Commit resolution with descriptive message" -ForegroundColor Gray
}

Show-VSCodeWorkflows

function Show-VSCodeGitSettings {
    Write-Host "`n[VS CODE CONFIGURATION] Optimize Git settings for Azure automation:" -ForegroundColor Cyan
    
    $settingsJson = @"
{
    // Git configuration for Azure automation projects
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,
    "git.suggestSmartCommit": true,
    
    // PowerShell configuration
    "powershell.integratedConsole.showOnStartup": false,
    "powershell.developer.editorServicesLogLevel": "Warning",
    
    // Azure extension settings
    "azure.resourceFilter": [],
    "azure.showSignedInEmail": true,
    
    // Editor settings for Azure automation
    "editor.rulers": [80, 120],
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.defaultLanguage": "powershell",
    
    // GitLens settings
    "gitlens.currentLine.enabled": true,
    "gitlens.hovers.currentLine.over": "line",
    "gitlens.blame.format": "${author|10} ${date|14-relative}",
    
    // File associations for Azure
    "files.associations": {
        "*.psd1": "powershell",
        "*.psm1": "powershell",
        "*.bicep": "bicep",
        "*.json": "jsonc"
    }
}
"@
    
    Write-Host "`n[SETTINGS] VS Code settings.json for Azure automation:" -ForegroundColor Yellow
    Write-Host $settingsJson -ForegroundColor Gray
    
    Write-Host "`n[KEYBOARD SHORTCUTS] Useful Git shortcuts in VS Code:" -ForegroundColor Yellow
    Write-Host "  Ctrl+Shift+G G     # Open Source Control panel" -ForegroundColor Gray
    Write-Host "  Ctrl+K Ctrl+S      # Stage selected changes" -ForegroundColor Gray
    Write-Host "  Ctrl+Enter         # Commit staged changes" -ForegroundColor Gray
    Write-Host "  Ctrl+Shift+P       # Open command palette for Git commands" -ForegroundColor Gray
    Write-Host "  F1                 # Quick access to Git operations" -ForegroundColor Gray
}

Show-VSCodeGitSettings

Write-Host "`n[BEST PRACTICES] VS Code with Git for Azure automation teams:" -ForegroundColor Yellow
Write-Host "  • Use workspace settings for team consistency" -ForegroundColor Gray
Write-Host "  • Configure GitLens for enhanced Git visualization" -ForegroundColor Gray
Write-Host "  • Set up Azure extension for integrated cloud development" -ForegroundColor Gray
Write-Host "  • Use Live Share for collaborative Azure automation development" -ForegroundColor Gray
Write-Host "  • Configure PowerShell extension for optimal Azure script editing" -ForegroundColor Gray
Write-Host "  • Use integrated terminal for testing Azure scripts immediately" -ForegroundColor Gray

Write-Host "`n[PAUSE] Press Enter to see workshop summary..." -ForegroundColor Magenta
$pause6 = Read-Host

# ============================================================================
# WORKSHOP CLEANUP AND SUMMARY
# ============================================================================
Write-Host "`n$separator" -ForegroundColor DarkGray

# Clean up demo directory
if (Test-Path $demoPath) {
    try {
    $currentPath = (Get-Location).Path
    $demoResolvedPath = (Resolve-Path $demoPath).Path

        if ($currentPath.StartsWith($demoResolvedPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            Set-Location -Path (Split-Path -Path $demoResolvedPath -Parent)
        }

        Remove-Item -LiteralPath $demoResolvedPath -Recurse -Force
    Write-Host "[CLEANUP] Demo repository removed: $demoResolvedPath" -ForegroundColor Gray
    } catch {
        Write-Host "[CLEANUP] Note: Demo files may remain at: $demoPath" -ForegroundColor Yellow
    }
}

try {
    if ($originalLocation) {
    Set-Location -Path $originalLocation
    Write-Host "[CLEANUP] Restored working directory: $originalLocation" -ForegroundColor Gray
    }
} catch {
    Write-Host "[CLEANUP] Unable to restore working directory: $originalLocation" -ForegroundColor Yellow
}

Write-Host "[WORKSHOP COMPLETE] Git Integration & Source Control - PowerShell DevOps with Azure Automation" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor DarkGray

Write-Host "`n[GIT CONCEPTS DEMONSTRATED]" -ForegroundColor White
Write-Host "1. Source Control Fundamentals: DevOps mindset, collaboration, version management" -ForegroundColor Gray
Write-Host "2. Git Basics: Repository initialization, staging, commits, status checking" -ForegroundColor Gray
Write-Host "3. Remote Repositories: Clone, push, pull, fetch, conflict resolution" -ForegroundColor Gray
Write-Host "4. Branching & Merging: Feature branches, GitFlow, environment-based strategies" -ForegroundColor Gray
Write-Host "5. Feature Flags: Runtime configuration, alternative to branching" -ForegroundColor Gray
Write-Host "6. Advanced Commands: Revert, reset, rebase, cherry-pick operations" -ForegroundColor Gray
Write-Host "7. VS Code Integration: Source control panel, extensions, collaborative development" -ForegroundColor Gray

Write-Host "`n[AZURE AUTOMATION INTEGRATION]" -ForegroundColor White
Write-Host "Repository structure for Azure automation projects" -ForegroundColor Gray
Write-Host "PowerShell script version control and collaboration" -ForegroundColor Gray
Write-Host "Feature flag implementation for Azure automation features" -ForegroundColor Gray
Write-Host "DevOps pipeline integration with Azure deployments" -ForegroundColor Gray
Write-Host "Environment-specific configuration management" -ForegroundColor Gray

Write-Host "`n[PRODUCTION-READY PATTERNS]" -ForegroundColor White
Write-Host "GitFlow and GitHub Flow strategies for Azure projects" -ForegroundColor Gray
Write-Host "Branch naming conventions for Azure automation features" -ForegroundColor Gray
Write-Host "Conflict resolution for collaborative Azure script development" -ForegroundColor Gray
Write-Host "VS Code configuration for optimal Azure automation development" -ForegroundColor Gray

Write-Host "`n[DEVOPS CAPABILITIES LEARNED]" -ForegroundColor White
Write-Host "Continuous Integration/Continuous Delivery understanding" -ForegroundColor Gray
Write-Host "Collaborative development workflows for Azure automation" -ForegroundColor Gray
Write-Host "Version control best practices for Infrastructure as Code" -ForegroundColor Gray
Write-Host "Advanced Git operations for complex Azure projects" -ForegroundColor Gray
Write-Host "Visual Studio Code mastery for Azure PowerShell development" -ForegroundColor Gray

Write-Host "`n[PRACTICAL GIT COMMANDS COVERED]" -ForegroundColor White
Write-Host "Repository: git init, git clone, git status, git log" -ForegroundColor Gray
Write-Host "Changes: git add, git commit, git push, git pull, git fetch" -ForegroundColor Gray
Write-Host "Branching: git branch, git checkout, git merge, git rebase" -ForegroundColor Gray
Write-Host "Advanced: git revert, git reset, git cherry-pick, git stash" -ForegroundColor Gray

Write-Host "`n[VS CODE EXTENSIONS RECOMMENDED]" -ForegroundColor White
Write-Host "PowerShell, Azure Tools, GitLens, Live Share for collaborative development" -ForegroundColor Gray
Write-Host "ARM Tools, Bicep, Azure Functions for comprehensive Azure development" -ForegroundColor Gray
Write-Host "Code quality tools: Spell Checker, TODO Tree, Bracket Colorizer" -ForegroundColor Gray

Write-Host "`n[NEXT STEPS]" -ForegroundColor White
Write-Host "These Git and DevOps concepts enable you to:" -ForegroundColor Gray
Write-Host "- Implement professional source control for Azure automation projects" -ForegroundColor Gray
Write-Host "- Collaborate effectively on Azure automation development teams" -ForegroundColor Gray
Write-Host "- Use advanced Git operations for complex Azure project management" -ForegroundColor Gray
Write-Host "- Optimize Visual Studio Code for Azure PowerShell development" -ForegroundColor Gray
Write-Host "- Implement CI/CD workflows for Azure infrastructure deployment" -ForegroundColor Gray

Write-Host "`nWorkshop completed at: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray