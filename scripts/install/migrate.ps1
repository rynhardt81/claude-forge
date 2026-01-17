#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Forge Migration Script for Windows

.DESCRIPTION
    This script sets up the Claude Forge framework on an existing project.
    Run this from the claude-forge directory after cloning it.

.PARAMETER ProjectPath
    Optional. The path to the project you want to migrate.
    If not provided, the script will prompt for it.

.EXAMPLE
    .\scripts\migrate.ps1
    # Interactive mode - prompts for project path

.EXAMPLE
    .\scripts\migrate.ps1 -ProjectPath "C:\Projects\my-app"
    # Specify project path directly

.NOTES
    After running this script, start Claude Code in your project and run:
    /migrate
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get the directory where this script is located (claude-forge root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FrameworkDir = Split-Path -Parent $ScriptDir

# Colors
function Write-ColorOutput {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Write-Success { param([string]$Message) Write-ColorOutput "✓ $Message" -Color Green }
function Write-Warning { param([string]$Message) Write-ColorOutput "⚠ $Message" -Color Yellow }
function Write-Error { param([string]$Message) Write-ColorOutput "✗ $Message" -Color Red }
function Write-Info { param([string]$Message) Write-ColorOutput $Message -Color Cyan }
function Write-Step { param([string]$Message) Write-ColorOutput $Message -Color Blue }

# Header
Write-Host ""
Write-Info "╔═══════════════════════════════════════════════════════════════╗"
Write-Info "║           Claude Forge Framework Migration Script              ║"
Write-Info "╚═══════════════════════════════════════════════════════════════╝"
Write-Host ""

# Verify we're in the claude-forge directory
$ClaudeMdPath = Join-Path $FrameworkDir "CLAUDE.md"
$SkillsPath = Join-Path $FrameworkDir "skills"

if (-not (Test-Path $ClaudeMdPath) -or -not (Test-Path $SkillsPath)) {
    Write-Error "This script must be run from the claude-forge directory."
    Write-Host "Expected to find CLAUDE.md and skills/ directory in: $FrameworkDir"
    exit 1
}

Write-Success "Claude Forge framework found at: $FrameworkDir"
Write-Host ""

# Get project directory
if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    Write-Step "Enter the path to your project directory:"
    Write-Warning "(This is the project you want to migrate to Claude Forge)"
    $ProjectPath = Read-Host "> "
}

# Resolve to absolute path
try {
    $ProjectPath = Resolve-Path $ProjectPath -ErrorAction Stop | Select-Object -ExpandProperty Path
}
catch {
    Write-Error "Directory does not exist: $ProjectPath"
    exit 1
}

Write-Host ""
Write-Success "Project directory: $ProjectPath"

# Check if project directory exists
if (-not (Test-Path $ProjectPath -PathType Container)) {
    Write-Error "Project directory does not exist: $ProjectPath"
    exit 1
}

# Check for existing Claude configuration
$ExistingClaude = $null
$BackupName = $null

$DotClaudePath = Join-Path $ProjectPath ".claude"
$ClaudePath = Join-Path $ProjectPath "claude"

if (Test-Path $DotClaudePath -PathType Container) {
    $ExistingClaude = $DotClaudePath
    $BackupName = ".claude_old"
    Write-Host ""
    Write-Warning "Found existing .claude directory"
}
elseif (Test-Path $ClaudePath -PathType Container) {
    $ExistingClaude = $ClaudePath
    $BackupName = "claude_old"
    Write-Host ""
    Write-Warning "Found existing claude directory"
}

# Show what will happen
Write-Host ""
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Info "Migration Plan"
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

if ($ExistingClaude) {
    $BackupPath = Join-Path $ProjectPath $BackupName
    Write-Host "  1. " -NoNewline
    Write-ColorOutput "Backup" -Color Yellow
    Write-Host " existing configuration:"
    Write-Host "     $ExistingClaude → $BackupPath"
    Write-Host ""
    Write-Host "  2. " -NoNewline
    Write-ColorOutput "Install" -Color Green
    Write-Host " Claude Forge framework:"
    Write-Host "     $FrameworkDir → $DotClaudePath"
    Write-Host ""
    Write-Host "  3. " -NoNewline
    Write-ColorOutput "Create" -Color Blue
    Write-Host " restoration script:"
    Write-Host "     $(Join-Path $ProjectPath 'claude_restore.ps1')"
    Write-Host ""
    Write-Info "After this script completes:"
    Write-Host "  • Start Claude Code in your project"
    Write-Host "  • Run " -NoNewline
    Write-ColorOutput "/migrate" -Color Green
    Write-Host " to merge your old configuration"
}
else {
    Write-Host "  1. " -NoNewline
    Write-ColorOutput "Install" -Color Green
    Write-Host " Claude Forge framework:"
    Write-Host "     $FrameworkDir → $DotClaudePath"
    Write-Host ""
    Write-Info "After this script completes:"
    Write-Host "  • Start Claude Code in your project"
    Write-Host "  • Run " -NoNewline
    Write-ColorOutput "/new-project --current" -Color Green
    Write-Host " to analyze your codebase"
}

Write-Host ""
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

# Confirm
$response = Read-Host "Proceed with migration? [y/N]"
if ($response -notmatch "^[Yy]$") {
    Write-Warning "Migration cancelled."
    exit 0
}

Write-Host ""

# Step 1: Backup existing configuration
if ($ExistingClaude) {
    Write-Step "Step 1: Backing up existing configuration..."

    $BackupPath = Join-Path $ProjectPath $BackupName

    if (Test-Path $BackupPath) {
        Write-Warning "$BackupName already exists."
        $overwrite = Read-Host "Overwrite existing backup? [y/N]"
        if ($overwrite -match "^[Yy]$") {
            Remove-Item -Path $BackupPath -Recurse -Force
        }
        else {
            Write-Error "Cannot proceed - backup directory exists."
            exit 1
        }
    }

    Move-Item -Path $ExistingClaude -Destination $BackupPath
    Write-Success "Backed up to: $BackupPath"

    # Create restoration script
    $RestoreScriptPath = Join-Path $ProjectPath "claude_restore.ps1"
    $RestoreScript = @'
#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Forge Restoration Script

.DESCRIPTION
    Run this to restore your original Claude configuration.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "Claude Forge Restoration"
Write-Host "========================"
Write-Host ""

# Check for backup
$BackupDir = $null
$TargetDir = $null

$DotClaudeOld = Join-Path $ScriptDir ".claude_old"
$ClaudeOld = Join-Path $ScriptDir "claude_old"

if (Test-Path $DotClaudeOld -PathType Container) {
    $BackupDir = $DotClaudeOld
    $TargetDir = Join-Path $ScriptDir ".claude"
}
elseif (Test-Path $ClaudeOld -PathType Container) {
    $BackupDir = $ClaudeOld
    $TargetDir = Join-Path $ScriptDir "claude"
}
else {
    Write-Host "Error: No backup directory found (.claude_old or claude_old)" -ForegroundColor Red
    exit 1
}

Write-Host "This will:"
Write-Host "  1. Remove the current Claude Forge installation"
Write-Host "  2. Restore your original configuration from backup"
Write-Host ""

$response = Read-Host "Proceed? [y/N]"
if ($response -notmatch "^[Yy]$") {
    Write-Host "Restoration cancelled."
    exit 0
}

Write-Host ""
Write-Host "Restoring..."

if (Test-Path $TargetDir) {
    Remove-Item -Path $TargetDir -Recurse -Force
}

Move-Item -Path $BackupDir -Destination $TargetDir
Remove-Item -Path $MyInvocation.MyCommand.Path -Force

Write-Host ""
Write-Host "✓ Restoration complete!" -ForegroundColor Green
Write-Host "  Your original configuration has been restored."
'@

    Set-Content -Path $RestoreScriptPath -Value $RestoreScript -Encoding UTF8
    Write-Success "Created restoration script: $RestoreScriptPath"
}
else {
    Write-Step "Step 1: No existing configuration to backup"
}

# Step 2: Copy Claude Forge framework
Write-Host ""
Write-Step "Step 2: Installing Claude Forge framework..."

$TargetClaudeDir = Join-Path $ProjectPath ".claude"

# Create target directory
New-Item -Path $TargetClaudeDir -ItemType Directory -Force | Out-Null

# Get items to copy (excluding .git, .github, and migration scripts)
$ExcludeItems = @(".git", ".github")
$ExcludeFiles = @("migrate.sh", "migrate.ps1")

Get-ChildItem -Path $FrameworkDir -Force | Where-Object {
    $_.Name -notin $ExcludeItems
} | ForEach-Object {
    $DestPath = Join-Path $TargetClaudeDir $_.Name
    if ($_.PSIsContainer) {
        # Directory - copy recursively
        Copy-Item -Path $_.FullName -Destination $DestPath -Recurse -Force
    }
    else {
        # File - copy directly
        Copy-Item -Path $_.FullName -Destination $DestPath -Force
    }
}

# Remove migration scripts from copied framework
$ScriptsDir = Join-Path $TargetClaudeDir "scripts"
if (Test-Path $ScriptsDir) {
    $MigrateShPath = Join-Path $ScriptsDir "migrate.sh"
    $MigratePs1Path = Join-Path $ScriptsDir "migrate.ps1"
    if (Test-Path $MigrateShPath) { Remove-Item $MigrateShPath -Force }
    if (Test-Path $MigratePs1Path) { Remove-Item $MigratePs1Path -Force }
}

Write-Success "Framework installed to: $TargetClaudeDir"

# Step 3: Initialize memories structure
Write-Host ""
Write-Step "Step 3: Initializing session directories..."

$SessionsActive = Join-Path $TargetClaudeDir "memories\sessions\active"
$SessionsCompleted = Join-Path $TargetClaudeDir "memories\sessions\completed"

New-Item -Path $SessionsActive -ItemType Directory -Force | Out-Null
New-Item -Path $SessionsCompleted -ItemType Directory -Force | Out-Null

# Create .gitkeep files
New-Item -Path (Join-Path $SessionsActive ".gitkeep") -ItemType File -Force | Out-Null
New-Item -Path (Join-Path $SessionsCompleted ".gitkeep") -ItemType File -Force | Out-Null

Write-Success "Session directories created"

# Step 4: Initialize project memory
Write-Host ""
Write-Step "Step 4: Initializing project memory..."

$ProjectMemoryDir = Join-Path $ProjectPath "docs\project-memory"
New-Item -Path $ProjectMemoryDir -ItemType Directory -Force | Out-Null

# Copy templates if they exist
$TemplatesDir = Join-Path $FrameworkDir "templates\project-memory"
if (Test-Path $TemplatesDir -PathType Container) {
    $templateFiles = @("bugs.md", "decisions.md", "key-facts.md", "patterns.md")
    foreach ($file in $templateFiles) {
        $sourcePath = Join-Path $TemplatesDir $file
        $destPath = Join-Path $ProjectMemoryDir $file
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
        }
    }
    Write-Success "Project memory initialized at: $ProjectMemoryDir"
}
else {
    Write-Warning "Templates not found, created empty directory"
}

# Summary
Write-Host ""
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-ColorOutput "Migration Setup Complete!" -Color Green
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

if ($ExistingClaude) {
    Write-Info "Next Steps:"
    Write-Host ""
    Write-Host "  1. Navigate to your project:"
    Write-ColorOutput "     cd $ProjectPath" -Color Yellow
    Write-Host ""
    Write-Host "  2. Start Claude Code:"
    Write-ColorOutput "     claude" -Color Yellow
    Write-Host ""
    Write-Host "  3. Run the migration skill to merge your old config:"
    Write-ColorOutput "     /migrate" -Color Green
    Write-Host ""
    Write-Info "Rollback:"
    Write-Host "  If you need to restore your original configuration:"
    Write-ColorOutput "  $(Join-Path $ProjectPath 'claude_restore.ps1')" -Color Yellow
}
else {
    Write-Info "Next Steps:"
    Write-Host ""
    Write-Host "  1. Navigate to your project:"
    Write-ColorOutput "     cd $ProjectPath" -Color Yellow
    Write-Host ""
    Write-Host "  2. Start Claude Code:"
    Write-ColorOutput "     claude" -Color Yellow
    Write-Host ""
    Write-Host "  3. Initialize the framework for your project:"
    Write-ColorOutput "     /new-project --current" -Color Green
}

Write-Host ""
Write-ColorOutput "Happy coding with Claude Forge! 🚀" -Color Green
Write-Host ""
