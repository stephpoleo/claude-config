# Claude Config Update Script
# Updates the claude-config submodule to the latest version

param(
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Cyan $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# Banner
Write-Info @"

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Claude Config - Update Script                      ║
║   Updating to latest configuration                   ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

"@

$ProjectRoot = Get-Location
$SubmodulePath = "$ProjectRoot\.claude-config"

Write-Info "Project root: $ProjectRoot"
Write-Info ""

# Step 1: Verify submodule exists
Write-Info "Step 1: Verifying submodule..."

if (-not (Test-Path $SubmodulePath)) {
    Write-Error "✗ .claude-config directory not found"
    Write-Info "  This script should be run from a project that has claude-config as a submodule"
    exit 1
}

if (-not (Test-Path "$SubmodulePath\.git")) {
    Write-Error "✗ .claude-config is not a git submodule"
    Write-Info "  This script only works with git submodules"
    exit 1
}

Write-Success "✓ Submodule found"
Write-Info ""

# Step 2: Get current version
Write-Info "Step 2: Checking current version..."

Push-Location $SubmodulePath
try {
    $CurrentCommit = git rev-parse --short HEAD
    $CurrentBranch = git rev-parse --abbrev-ref HEAD
    Write-Info "  Current commit: $CurrentCommit"
    Write-Info "  Current branch: $CurrentBranch"
} finally {
    Pop-Location
}

Write-Info ""

# Step 3: Update submodule
Write-Info "Step 3: Updating submodule..."

Push-Location $SubmodulePath
try {
    Write-Info "  Fetching latest changes..."
    git fetch origin

    Write-Info "  Pulling updates..."
    git pull origin $CurrentBranch

    $NewCommit = git rev-parse --short HEAD

    if ($CurrentCommit -eq $NewCommit) {
        Write-Success "✓ Already up to date"
    } else {
        Write-Success "✓ Updated to commit $NewCommit"

        # Show what changed
        Write-Info ""
        Write-Info "Changes:"
        git log --oneline "$CurrentCommit..$NewCommit"
    }
} catch {
    Write-Error "✗ Failed to update submodule: $_"
    exit 1
} finally {
    Pop-Location
}

Write-Info ""

# Step 4: Check for new skills/agents
Write-Info "Step 4: Checking for new skills and agents..."

$NewSkills = @()
$NewAgents = @()

# Get all available skills
$AllSkills = Get-ChildItem -Path "$SubmodulePath\skills" -Recurse -Filter "SKILL.md" | ForEach-Object {
    $skillName = Split-Path (Split-Path $_.FullName -Parent) -Leaf
    $skillName
}

# Get all available agents
$AllAgents = Get-ChildItem -Path "$SubmodulePath\agents" -Recurse -Filter "*.md" | ForEach-Object {
    $_.BaseName
}

# Get currently linked skills
$LinkedSkills = @()
if (Test-Path "$ProjectRoot\.claude\skills") {
    $LinkedSkills = Get-ChildItem -Path "$ProjectRoot\.claude\skills" -Directory | ForEach-Object {
        $_.Name
    }
}

# Get currently linked agents
$LinkedAgents = @()
if (Test-Path "$ProjectRoot\.claude\agents") {
    $LinkedAgents = Get-ChildItem -Path "$ProjectRoot\.claude\agents" -Filter "*.md" | ForEach-Object {
        $_.BaseName
    }
}

# Find new skills
foreach ($skill in $AllSkills) {
    if ($skill -notin $LinkedSkills) {
        $NewSkills += $skill
    }
}

# Find new agents
foreach ($agent in $AllAgents) {
    if ($agent -notin $LinkedAgents) {
        $NewAgents += $agent
    }
}

if ($NewSkills.Count -gt 0) {
    Write-Info "  New skills available:"
    foreach ($skill in $NewSkills) {
        Write-Info "    → $skill"
    }
} else {
    Write-Info "  No new skills available"
}

if ($NewAgents.Count -gt 0) {
    Write-Info "  New agents available:"
    foreach ($agent in $NewAgents) {
        Write-Info "    → $agent"
    }
} else {
    Write-Info "  No new agents available"
}

Write-Info ""

# Step 5: Update parent repository
Write-Info "Step 5: Updating parent repository..."

if (Test-Path "$ProjectRoot\.git") {
    Write-Info "  This will stage the submodule update in your project"
    Write-Warning "  Remember to commit the change: git commit -m 'Update claude-config submodule'"

    git add .claude-config

    Write-Success "✓ Submodule update staged"
} else {
    Write-Warning "⚠ Not a git repository, skipping git add"
}

Write-Info ""

# Summary
Write-Success @"

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Update Complete! ✓                                 ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

"@

Write-Info "Summary:"
Write-Info "  → Updated from: $CurrentCommit"
Write-Info "  → Updated to: $NewCommit"
Write-Info "  → New skills available: $($NewSkills.Count)"
Write-Info "  → New agents available: $($NewAgents.Count)"
Write-Info ""

if ($NewSkills.Count -gt 0 -or $NewAgents.Count -gt 0) {
    Write-Info "To install new skills/agents, run:"
    Write-Info "  .\.claude-config\scripts\install.ps1"
    Write-Info ""
}

Write-Info "Next steps:"
Write-Info "  1. Review changes in .claude-config/"
Write-Info "  2. Test your project with updated configuration"
Write-Info "  3. Commit the submodule update: git commit -m 'Update claude-config'"
Write-Info ""
Write-Success "Done! 🚀"
Write-Info ""
