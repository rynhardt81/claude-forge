#Requires -Version 5.1
<#
.SYNOPSIS
    Add Project Memory Feature to Existing Claude Forge Installation

.DESCRIPTION
    This script adds the project memory feature (bugs, decisions, patterns, key-facts)
    to a project that already has Claude Forge installed.

.PARAMETER ProjectPath
    Optional. The path to the project you want to add the feature to.

.EXAMPLE
    .\scripts\add-project-memory.ps1
    # Interactive mode - prompts for project path

.EXAMPLE
    .\scripts\add-project-memory.ps1 -ProjectPath "C:\Projects\my-app"
    # Add feature to specified project
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
Write-Info "║           Add Project Memory Feature                           ║"
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
    Write-Warning "(This should be a project that already has Claude Forge installed)"
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

Write-Success "Project directory: $ProjectPath"

# Verify Claude Forge is installed
$ClaudeDir = Join-Path $ProjectPath ".claude"
if (-not (Test-Path $ClaudeDir -PathType Container)) {
    Write-Error "Claude Forge not found in project."
    Write-Host "Run migrate.ps1 first to install Claude Forge."
    exit 1
}

Write-Success "Claude Forge installation found"
Write-Host ""

# Confirm
Write-Info "This will install the Project Memory feature:"
Write-Host "  - docs/project-memory/ with template files"
Write-Host "  - /remember skill for adding memories"
Write-Host "  - Updated /fix-bug with memory phases"
Write-Host "  - Updated /reflect with memory loading"
Write-Host "  - Reference documentation"
Write-Host ""

$response = Read-Host "Proceed? [Y/n]"
if ($response -match "^[Nn]$") {
    Write-Warning "Installation cancelled."
    exit 0
}

Write-Host ""
$changesMade = 0

# Step 1: Create docs/project-memory/ structure
Write-Step "Step 1: Creating project memory structure..."

$ProjectMemoryDir = Join-Path $ProjectPath "docs\project-memory"
$copyTemplates = $false

if (Test-Path $ProjectMemoryDir -PathType Container) {
    Write-Warning "docs/project-memory/ already exists"
    $overwrite = Read-Host "   Overwrite template files? [y/N]"
    if ($overwrite -match "^[Yy]$") {
        $copyTemplates = $true
    }
    else {
        Write-Success "Keeping existing project memory files"
    }
}
else {
    New-Item -Path $ProjectMemoryDir -ItemType Directory -Force | Out-Null
    $copyTemplates = $true
    Write-Success "Created docs/project-memory/"
}

if ($copyTemplates) {
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
        Write-Success "Copied template files"
        $changesMade++
    }
    else {
        Write-Error "Templates not found in framework"
    }
}

# Step 2: Copy /remember skill
Write-Host ""
Write-Step "Step 2: Installing /remember skill..."

$RememberSkillSrc = Join-Path $FrameworkDir "skills\remember"
$RememberSkillDest = Join-Path $ProjectPath ".claude\skills\remember"

if (Test-Path $RememberSkillSrc -PathType Container) {
    if (Test-Path $RememberSkillDest -PathType Container) {
        Write-Warning "/remember skill already exists, updating..."
    }
    New-Item -Path $RememberSkillDest -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$RememberSkillSrc\*" -Destination $RememberSkillDest -Recurse -Force
    Write-Success "Installed /remember skill"
    $changesMade++
}
else {
    Write-Warning "/remember skill not found in framework"
}

# Step 3: Update reference documentation
Write-Host ""
Write-Step "Step 3: Installing reference documentation..."

$RefDocSrc = Join-Path $FrameworkDir "reference\16-project-memory.md"
$RefDocDest = Join-Path $ProjectPath ".claude\reference"

if (Test-Path $RefDocSrc) {
    New-Item -Path $RefDocDest -ItemType Directory -Force | Out-Null
    Copy-Item -Path $RefDocSrc -Destination $RefDocDest -Force
    Write-Success "Installed reference/16-project-memory.md"
    $changesMade++
}
else {
    Write-Warning "Reference documentation not found"
}

# Step 4: Update /fix-bug skill
Write-Host ""
Write-Step "Step 4: Updating /fix-bug skill..."

$FixBugSrc = Join-Path $FrameworkDir "skills\fix-bug"
$FixBugDest = Join-Path $ProjectPath ".claude\skills\fix-bug"

if (Test-Path $FixBugSrc -PathType Container) {
    New-Item -Path $FixBugDest -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$FixBugSrc\*" -Destination $FixBugDest -Recurse -Force
    Write-Success "Updated /fix-bug skill with memory phases"
    $changesMade++
}

# Step 5: Update /reflect skill
Write-Host ""
Write-Step "Step 5: Updating /reflect skill..."

$ReflectSrc = Join-Path $FrameworkDir "skills\reflect"
$ReflectDest = Join-Path $ProjectPath ".claude\skills\reflect"

if (Test-Path $ReflectSrc -PathType Container) {
    New-Item -Path $ReflectDest -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$ReflectSrc\*" -Destination $ReflectDest -Recurse -Force
    Write-Success "Updated /reflect skill with memory loading"
    $changesMade++
}

# Step 6: Update agents
Write-Host ""
Write-Step "Step 6: Updating agent definitions..."

$agentsUpdated = 0
$AgentsDest = Join-Path $ProjectPath ".claude\agents"

foreach ($agent in @("architect", "dev", "tea")) {
    $agentSrc = Join-Path $FrameworkDir ".claude\agents\$agent.mdc"
    if ((Test-Path $agentSrc) -and (Test-Path $AgentsDest -PathType Container)) {
        Copy-Item -Path $agentSrc -Destination $AgentsDest -Force
        $agentsUpdated++
    }
}

if ($agentsUpdated -gt 0) {
    Write-Success "Updated $agentsUpdated agent definition(s)"
    $changesMade++
}
else {
    Write-Warning "No agents to update (agents directory not found)"
}

# Step 7: Check CLAUDE.md
Write-Host ""
Write-Step "Step 7: Checking CLAUDE.md..."

$ClaudeMdDest = Join-Path $ProjectPath ".claude\CLAUDE.md"
if (Test-Path $ClaudeMdDest) {
    $content = Get-Content $ClaudeMdDest -Raw
    if ($content -match "docs/project-memory/") {
        Write-Success "CLAUDE.md already references project memory"
    }
    else {
        Write-Warning "CLAUDE.md may need manual update"
        Write-Host "   Add 'docs/project-memory/' to Key Locations section"
        Write-Host "   Add '/remember' to Skill Routing section"
    }
}

# Summary
Write-Host ""
Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ($changesMade -gt 0) {
    Write-ColorOutput "Project Memory feature installed successfully!" -Color Green
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    Write-Info "Usage:"
    Write-Host '  /remember bug "Bug title"      - Record a bug pattern'
    Write-Host '  /remember decision "Title"     - Record a technical decision'
    Write-Host '  /remember fact "label: value"  - Record a key fact'
    Write-Host '  /remember pattern "Title"      - Record a code pattern'
    Write-Host '  /remember search "query"       - Search memories'
    Write-Host ""
    Write-Info "The system will:"
    Write-Host "  - Auto-load relevant memories during /reflect resume"
    Write-Host "  - Check bugs.md before fixing bugs (/fix-bug)"
    Write-Host "  - Offer to save bug patterns after fixes"
}
else {
    Write-Warning "No changes were made."
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

Write-Host ""
