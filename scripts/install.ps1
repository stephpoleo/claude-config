# Claude Config Installation Script
# Installs skills, agents, and configuration for Claude Code projects

param(
    [string]$Preset = "",
    [switch]$Interactive = $true,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Colors for output
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
║   Claude Config - Installation Script                ║
║   Setting up your Claude Code environment            ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

"@

# Get script directory (where .claude-config is)
$ScriptDir = Split-Path -Parent $PSScriptRoot
$ProjectRoot = Get-Location

Write-Info "Script directory: $ScriptDir"
Write-Info "Project root: $ProjectRoot"
Write-Info ""

# Step 1: Validate environment
Write-Info "Step 1: Validating environment..."

if (-not (Test-Path "$ProjectRoot\.git")) {
    Write-Warning "Warning: Not a git repository. Consider running 'git init' first."
}

# Create .claude directory if it doesn't exist
if (-not (Test-Path "$ProjectRoot\.claude")) {
    Write-Info "Creating .claude directory..."
    New-Item -ItemType Directory -Path "$ProjectRoot\.claude" | Out-Null
    Write-Success "✓ Created .claude directory"
} else {
    Write-Success "✓ .claude directory exists"
}

# Create skills and agents directories
if (-not (Test-Path "$ProjectRoot\.claude\skills")) {
    New-Item -ItemType Directory -Path "$ProjectRoot\.claude\skills" | Out-Null
}
if (-not (Test-Path "$ProjectRoot\.claude\agents")) {
    New-Item -ItemType Directory -Path "$ProjectRoot\.claude\agents" | Out-Null
}

Write-Success "✓ Environment validated"
Write-Info ""

# Step 2: Select preset
Write-Info "Step 2: Select configuration preset..."

$AvailablePresets = @(
    @{ Name = "base"; Description = "Base configuration (minimal setup)" },
    @{ Name = "web-dev"; Description = "Web development (Angular, Django, TypeScript)" },
    @{ Name = "data-science"; Description = "Data science (ML, pandas, scikit-learn, visualization)" },
    @{ Name = "devops"; Description = "DevOps & Infrastructure (Docker, CI/CD, AWS, GCP)" },
    @{ Name = "testing"; Description = "Testing focused (pytest, unit/integration tests)" }
)

if ($Interactive -and -not $Preset) {
    Write-Info "Available presets:"
    for ($i = 0; $i -lt $AvailablePresets.Count; $i++) {
        $preset = $AvailablePresets[$i]
        Write-Info "  [$($i + 1)] $($preset.Name) - $($preset.Description)"
    }
    Write-Info ""

    do {
        $selection = Read-Host "Select preset [1-$($AvailablePresets.Count)]"
        $selectionNum = [int]$selection
    } while ($selectionNum -lt 1 -or $selectionNum -gt $AvailablePresets.Count)

    $Preset = $AvailablePresets[$selectionNum - 1].Name
}

if (-not $Preset) {
    $Preset = "base"
}

Write-Success "✓ Selected preset: $Preset"
Write-Info ""

# Step 3: Get skills for selected preset
Write-Info "Step 3: Selecting skills..."

$PresetSkills = @{
    "base" = @()
    "web-dev" = @("angular-component", "django-api", "api-design")
    "data-science" = @("data-pipeline", "sql-optimization", "data-visualization", "model-design")
    "devops" = @("docker-setup", "github-actions", "aws-setup", "gcp-setup")
    "testing" = @("test-suite", "clean-code-review")
}

$SelectedSkills = $PresetSkills[$Preset]

# Get all available skills
$AllSkills = Get-ChildItem -Path "$ScriptDir\skills" -Recurse -Filter "SKILL.md" | ForEach-Object {
    $skillPath = $_.DirectoryName
    $category = Split-Path (Split-Path $skillPath -Parent) -Leaf
    $skillName = Split-Path $skillPath -Leaf

    @{
        Name = $skillName
        Category = $category
        Path = $skillPath
        RelativePath = $skillPath.Replace("$ScriptDir\", "")
    }
}

if ($Interactive -and $AllSkills.Count -gt 0) {
    Write-Info "Skills included in preset:"
    foreach ($skill in $SelectedSkills) {
        Write-Info "  ✓ $skill"
    }
    Write-Info ""

    $addMore = Read-Host "Add more skills? (y/n)"
    if ($addMore -eq "y" -or $addMore -eq "Y") {
        Write-Info "Available skills:"
        $availableSkills = $AllSkills | Where-Object { $SelectedSkills -notcontains $_.Name }
        for ($i = 0; $i -lt $availableSkills.Count; $i++) {
            $skill = $availableSkills[$i]
            Write-Info "  [$($i + 1)] $($skill.Category)/$($skill.Name)"
        }
        Write-Info ""

        $selections = Read-Host "Enter skill numbers (comma-separated, or 'all')"
        if ($selections -eq "all") {
            $SelectedSkills += $availableSkills.Name
        } elseif ($selections) {
            $numbers = $selections.Split(",") | ForEach-Object { $_.Trim() }
            foreach ($num in $numbers) {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $availableSkills.Count) {
                    $SelectedSkills += $availableSkills[$idx].Name
                }
            }
        }
    }
}

Write-Success "✓ Skills selected: $($SelectedSkills.Count)"
Write-Info ""

# Step 4: Link skills
Write-Info "Step 4: Creating skill symlinks..."

# Check if we can create symlinks
$CanCreateSymlinks = $false
try {
    $testLink = "$ProjectRoot\.claude\.test-symlink"
    $testTarget = "$ScriptDir\README.md"
    New-Item -ItemType SymbolicLink -Path $testLink -Target $testTarget -ErrorAction Stop | Out-Null
    Remove-Item $testLink -Force
    $CanCreateSymlinks = $true
    Write-Success "✓ Symlinks are supported"
} catch {
    Write-Warning "⚠ Symlinks not supported (requires Developer Mode or Admin privileges)"
    Write-Info "  Will copy files instead of creating symlinks"
}

$LinkedSkills = 0
foreach ($skillName in $SelectedSkills) {
    $skill = $AllSkills | Where-Object { $_.Name -eq $skillName } | Select-Object -First 1
    if ($skill) {
        $targetPath = "$ProjectRoot\.claude\skills\$skillName"

        # Remove existing link/directory
        if (Test-Path $targetPath) {
            Remove-Item $targetPath -Recurse -Force
        }

        # Create parent directory
        $parentDir = Split-Path $targetPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir | Out-Null
        }

        # Create symlink or copy
        try {
            if ($CanCreateSymlinks) {
                # Calculate relative path from .claude/skills to skill location
                $relativePath = "..\..\$($skill.RelativePath)"
                New-Item -ItemType SymbolicLink -Path $targetPath -Target $relativePath | Out-Null
                if ($Verbose) { Write-Info "  → Linked $skillName (symlink)" }
            } else {
                # Copy directory
                Copy-Item -Path $skill.Path -Destination $targetPath -Recurse
                if ($Verbose) { Write-Info "  → Copied $skillName" }
            }
            $LinkedSkills++
        } catch {
            Write-Warning "  ⚠ Failed to link/copy $skillName : $_"
        }
    }
}

Write-Success "✓ Linked $LinkedSkills skills"
Write-Info ""

# Step 5: Link agents
Write-Info "Step 5: Selecting agents..."

$PresetAgents = @{
    "base" = @()
    "web-dev" = @("angular-specialist", "python-django-specialist")
    "data-science" = @("data-scientist-specialist")
    "devops" = @("docker-specialist", "cicd-specialist")
    "testing" = @()
}

$SelectedAgents = $PresetAgents[$Preset]

# Get all available agents
$AllAgents = Get-ChildItem -Path "$ScriptDir\agents" -Recurse -Filter "*.md" | ForEach-Object {
    $category = Split-Path (Split-Path $_.FullName -Parent) -Leaf
    $agentName = $_.BaseName

    @{
        Name = $agentName
        Category = $category
        Path = $_.FullName
        RelativePath = $_.FullName.Replace("$ScriptDir\", "")
    }
}

if ($Interactive -and $AllAgents.Count -gt 0) {
    Write-Info "Agents included in preset:"
    foreach ($agent in $SelectedAgents) {
        Write-Info "  ✓ $agent"
    }
    Write-Info ""

    $addMore = Read-Host "Add more agents? (y/n)"
    if ($addMore -eq "y" -or $addMore -eq "Y") {
        Write-Info "Available agents:"
        $availableAgents = $AllAgents | Where-Object { $SelectedAgents -notcontains $_.Name }
        for ($i = 0; $i -lt $availableAgents.Count; $i++) {
            $agent = $availableAgents[$i]
            Write-Info "  [$($i + 1)] $($agent.Category)/$($agent.Name)"
        }
        Write-Info ""

        $selections = Read-Host "Enter agent numbers (comma-separated, or 'all')"
        if ($selections -eq "all") {
            $SelectedAgents += $availableAgents.Name
        } elseif ($selections) {
            $numbers = $selections.Split(",") | ForEach-Object { $_.Trim() }
            foreach ($num in $numbers) {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $availableAgents.Count) {
                    $SelectedAgents += $availableAgents[$idx].Name
                }
            }
        }
    }
}

# Link agents
$LinkedAgents = 0
foreach ($agentName in $SelectedAgents) {
    $agent = $AllAgents | Where-Object { $_.Name -eq $agentName } | Select-Object -First 1
    if ($agent) {
        $targetPath = "$ProjectRoot\.claude\agents\$agentName.md"

        # Remove existing link/file
        if (Test-Path $targetPath) {
            Remove-Item $targetPath -Force
        }

        # Create symlink or copy
        try {
            if ($CanCreateSymlinks) {
                $relativePath = "..\..\$($agent.RelativePath)"
                New-Item -ItemType SymbolicLink -Path $targetPath -Target $relativePath | Out-Null
                if ($Verbose) { Write-Info "  → Linked $agentName (symlink)" }
            } else {
                Copy-Item -Path $agent.Path -Destination $targetPath
                if ($Verbose) { Write-Info "  → Copied $agentName" }
            }
            $LinkedAgents++
        } catch {
            Write-Warning "  ⚠ Failed to link/copy $agentName : $_"
        }
    }
}

Write-Success "✓ Linked $LinkedAgents agents"
Write-Info ""

# Step 6: Create settings file
Write-Info "Step 6: Creating settings file..."

$settingsFile = "$ProjectRoot\.claude\settings.local.json"

if (Test-Path $settingsFile) {
    Write-Warning "⚠ settings.local.json already exists"
    if ($Interactive) {
        $overwrite = Read-Host "Overwrite? (y/n)"
        if ($overwrite -ne "y" -and $overwrite -ne "Y") {
            Write-Info "  Skipping settings creation"
            $settingsFile = $null
        }
    } else {
        $settingsFile = $null
    }
}

if ($settingsFile) {
    $settingsTemplate = @"
{
  "`$schema": "https://json-schema.org/draft-07/schema#",
  "extends": "../.claude-config/settings/$Preset.json",
  "model": "sonnet",
  "customSettings": {
    "projectName": "$(Split-Path $ProjectRoot -Leaf)",
    "createdAt": "$(Get-Date -Format 'yyyy-MM-dd')"
  }
}
"@

    Set-Content -Path $settingsFile -Value $settingsTemplate
    Write-Success "✓ Created settings.local.json"
}

Write-Info ""

# Step 7: Create CLAUDE.md if it doesn't exist
Write-Info "Step 7: Creating CLAUDE.md template..."

$claudeMdFile = "$ProjectRoot\.claude\CLAUDE.md"

if (-not (Test-Path $claudeMdFile)) {
    $claudeMdTemplate = @"
# Project Context for Claude

## Project Overview

[Describe your project here]

## Tech Stack

- **Language**:
- **Framework**:
- **Database**:
- **Tools**:

## Project Structure

\`\`\`
project/
├── src/
├── tests/
└── docs/
\`\`\`

## Development Workflow

1.
2.
3.

## Important Notes

-
-

## Coding Standards

Follow standards defined in:
- TypeScript: See `.claude-config/memory/coding-standards/typescript.md`
- [Add more as needed]

## Current Focus

[What you're currently working on]
"@

    Set-Content -Path $claudeMdFile -Value $claudeMdTemplate
    Write-Success "✓ Created CLAUDE.md template"
} else {
    Write-Info "  CLAUDE.md already exists, skipping"
}

Write-Info ""

# Step 8: Update .gitignore
Write-Info "Step 8: Updating .gitignore..."

$gitignoreFile = "$ProjectRoot\.gitignore"
$gitignoreEntries = @(
    "",
    "# Claude Code local settings",
    ".claude/settings.local.json",
    ".claude/*.local.json"
)

if (Test-Path $gitignoreFile) {
    $gitignoreContent = Get-Content $gitignoreFile -Raw
    $needsUpdate = $false

    foreach ($entry in $gitignoreEntries) {
        if ($entry -and -not $gitignoreContent.Contains($entry)) {
            $needsUpdate = $true
            break
        }
    }

    if ($needsUpdate) {
        Add-Content -Path $gitignoreFile -Value ($gitignoreEntries -join "`n")
        Write-Success "✓ Updated .gitignore"
    } else {
        Write-Info "  .gitignore already configured"
    }
} else {
    Set-Content -Path $gitignoreFile -Value ($gitignoreEntries -join "`n")
    Write-Success "✓ Created .gitignore"
}

Write-Info ""

# Summary
Write-Success @"

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Installation Complete! ✓                           ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

"@

Write-Info "Summary:"
Write-Info "  → Preset: $Preset"
Write-Info "  → Skills linked: $LinkedSkills"
Write-Info "  → Agents linked: $LinkedAgents"
Write-Info "  → Settings: .claude/settings.local.json"
Write-Info "  → Context: .claude/CLAUDE.md"
Write-Info ""
Write-Info "Next steps:"
Write-Info "  1. Edit .claude/CLAUDE.md with your project context"
Write-Info "  2. Customize .claude/settings.local.json if needed"
Write-Info "  3. Start using Claude Code with your configured skills!"
Write-Info ""
Write-Info "Available skills:"
foreach ($skill in $SelectedSkills) {
    Write-Info "  → /$skill"
}
Write-Info ""
Write-Success "Happy coding! 🚀"
Write-Info ""
