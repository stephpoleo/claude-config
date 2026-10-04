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

# Relative path from directory $From to $To (PowerShell 5.1 has no GetRelativePath)
function Get-RelativePath($From, $To) {
    $fromUri = [Uri]($From.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar)
    $relative = [Uri]::UnescapeDataString($fromUri.MakeRelativeUri([Uri]$To).ToString())
    return $relative.Replace('/', [IO.Path]::DirectorySeparatorChar)
}

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

# Step 1.5: Configure .gitignore (optional)
if ($Interactive -and (Test-Path "$ProjectRoot\.git")) {
    Write-Info "Step 1.5: Git configuration..."
    $addToGitignore = Read-Host "Add .claude-config/ to .gitignore? (y/n) [Recommended: y]"

    if ($addToGitignore -eq "y" -or $addToGitignore -eq "Y" -or $addToGitignore -eq "") {
        $gitignorePath = "$ProjectRoot\.gitignore"
        $ignoreEntry = ".claude-config/"

        # Check if .gitignore exists
        if (-not (Test-Path $gitignorePath)) {
            Write-Info "Creating .gitignore..."
            New-Item -ItemType File -Path $gitignorePath | Out-Null
        }

        # Check if entry already exists
        $gitignoreContent = Get-Content $gitignorePath -ErrorAction SilentlyContinue
        if ($gitignoreContent -notcontains $ignoreEntry) {
            # Add entry to .gitignore
            Add-Content -Path $gitignorePath -Value "`n# Claude Config (submodule - opcional)"
            Add-Content -Path $gitignorePath -Value $ignoreEntry
            Write-Success "✓ Added .claude-config/ to .gitignore"
        } else {
            Write-Success "✓ .claude-config/ already in .gitignore"
        }
    } else {
        Write-Info "Skipped .gitignore configuration"
        Write-Warning "Note: .claude-config/ will be tracked by git (submodule)"
    }
    Write-Info ""
}

# Step 2: Select preset
Write-Info "Step 2: Select configuration preset..."

# Define presets with Name and Description
$PresetDefinitions = @{
    "base" = "Base configuration (minimal setup)"
    "web-dev" = "Web development (Angular, Django, TypeScript)"
    "data-science" = "Data science (ML, pandas, scikit-learn, visualization)"
    "devops" = "DevOps & Infrastructure (Docker, CI/CD, AWS, GCP)"
    "testing" = "Testing focused (pytest, unit/integration tests)"
    "smart-print" = "3D printing business (NFC, ESP32, pricing, social media)"
}

# Create ordered list for display
$PresetNames = @("base", "web-dev", "data-science", "devops", "testing", "smart-print")

if ($Interactive -and -not $Preset) {
    Write-Info "Available presets:"
    for ($i = 0; $i -lt $PresetNames.Count; $i++) {
        $presetName = $PresetNames[$i]
        $presetDesc = $PresetDefinitions[$presetName]
        Write-Info "  [$($i + 1)] $presetName - $presetDesc"
    }
    Write-Info ""

    do {
        $selection = Read-Host "Select preset [1-$($PresetNames.Count)]"
        $selectionNum = $selection -as [int]
    } while ($selectionNum -lt 1 -or $selectionNum -gt $PresetNames.Count)

    $Preset = $PresetNames[$selectionNum - 1]
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
    "smart-print" = @("print-quote", "print-design-brief", "nfc-hub", "iot-firmware", "social-content", "client-pitch")
}

$SelectedSkills = $PresetSkills[$Preset]

# Get all available skills
$AllSkills = Get-ChildItem -Path "$ScriptDir\skills" -Recurse -Filter "SKILL.md" | ForEach-Object {
    $skillPath = $_.DirectoryName
    $category = Split-Path (Split-Path $skillPath -Parent) -Leaf
    $skillName = Split-Path $skillPath -Leaf

    [PSCustomObject]@{
        Name = $skillName
        Category = $category
        Path = $skillPath
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
                # Relative path from .claude/skills to the skill inside .claude-config
                $relativePath = Get-RelativePath (Split-Path $targetPath -Parent) $skill.Path
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
    "smart-print" = @("product-designer-3d", "iot-engineer", "business-strategist-mx", "social-media-manager")
}

$SelectedAgents = $PresetAgents[$Preset]

# Get all available agents
$AllAgents = Get-ChildItem -Path "$ScriptDir\agents" -Recurse -Filter "*.md" | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
    $category = Split-Path (Split-Path $_.FullName -Parent) -Leaf
    $agentName = $_.BaseName

    [PSCustomObject]@{
        Name = $agentName
        Category = $category
        Path = $_.FullName
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
                $relativePath = Get-RelativePath (Split-Path $targetPath -Parent) $agent.Path
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
  "`$schema": "https://json.schemastore.org/claude-code-settings.json",
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

# Step 8.5: Optional external tools - graphify (knowledge-graph skill)
# graphify is NOT a vended skill: it is a Python package (graphifyy) that installs
# and self-updates its own skill globally (~/.claude/skills/graphify). We only offer
# to install it here so teammates cloning this repo get it too. Never copy its
# SKILL.md into this repo - it would drift and does nothing without the package.
Write-Info "Step 8.5: Optional external tools (graphify)..."

$installGraphify = "n"
if ($Interactive) {
    $installGraphify = Read-Host "Install graphify? (knowledge-graph skill '/graphify', requires uv) (y/n) [n]"
}

if ($installGraphify -eq "y" -or $installGraphify -eq "Y") {
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Write-Info "  Installing graphifyy via uv..."
        uv tool install --upgrade graphifyy

        # Resolve the graphify executable - it may not be on PATH in this session yet
        $graphifyCmd = (Get-Command graphify -ErrorAction SilentlyContinue).Source
        if (-not $graphifyCmd) {
            $candidate = Join-Path $env:USERPROFILE ".local\bin\graphify.exe"
            if (Test-Path $candidate) { $graphifyCmd = $candidate }
        }

        if ($graphifyCmd) {
            & $graphifyCmd install
            uv tool update-shell 2>$null | Out-Null
            Write-Success "✓ graphify installed (global skill - use /graphify in any project)"
            Write-Warning "  Restart your terminal so 'graphify' is on PATH."
        } else {
            Write-Warning "  ⚠ graphifyy installed but 'graphify' not found on PATH."
            Write-Warning "    Run 'uv tool update-shell', reopen your terminal, then 'graphify install'."
        }
    } else {
        Write-Warning "  ⚠ uv not found. Install uv first: https://docs.astral.sh/uv/"
        Write-Warning "    Alternative: pip install graphifyy; graphify install"
    }
} else {
    Write-Info "  Skipped graphify installation"
}

Write-Info ""

# Step 8.6: Optional external tools - caveman (skill pack)
# caveman is NOT vended: the 'skills' CLI installs it globally into ~/.agents/skills
# and links each skill into ~/.claude/skills. Never copy its SKILL.md files into
# this repo - re-running the install command is how it gets updated.
Write-Info "Step 8.6: Optional external tools (caveman)..."

$installCaveman = "n"
if ($Interactive) {
    $installCaveman = Read-Host "Install caveman? (skill pack '/caveman', requires npx) (y/n) [n]"
}

if ($installCaveman -eq "y" -or $installCaveman -eq "Y") {
    if (Get-Command npx -ErrorAction SilentlyContinue) {
        Write-Info "  Installing caveman via skills CLI..."
        npx -y skills add JuliusBrussee/caveman -g -y
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ caveman installed (global skills - use /caveman in any project)"
            Write-Warning "  Restart Claude Code so the new skills are loaded."
        } else {
            Write-Warning "  ⚠ caveman installation failed."
            Write-Warning "    Retry manually: npx skills add JuliusBrussee/caveman -g"
        }
    } else {
        Write-Warning "  ⚠ npx not found. Install Node.js first: https://nodejs.org/"
    }
} else {
    Write-Info "  Skipped caveman installation"
}

Write-Info ""

# Step 8.7: Optional external tools - rtk (token-saving CLI proxy)
# rtk is installed with winget on Windows (Homebrew if available, e.g. pwsh on macOS);
# 'rtk init -g' then installs its global Claude Code hook + RTK.md.
Write-Info "Step 8.7: Optional external tools (rtk)..."

$installRtk = "n"
if ($Interactive) {
    $installRtk = Read-Host "Install rtk? (token-saving CLI proxy, requires winget) (y/n) [n]"
}

if ($installRtk -eq "y" -or $installRtk -eq "Y") {
    $rtkInstalled = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "  Installing rtk via winget..."
        winget install --id rtk-ai.rtk -e --accept-source-agreements --accept-package-agreements
        $rtkInstalled = ($LASTEXITCODE -eq 0)
    } elseif (Get-Command brew -ErrorAction SilentlyContinue) {
        Write-Info "  Installing rtk via Homebrew..."
        brew install rtk
        $rtkInstalled = ($LASTEXITCODE -eq 0)
    } else {
        Write-Warning "  ⚠ winget not found. Download rtk.exe from https://github.com/rtk-ai/rtk/releases"
        Write-Warning "    and put it on your PATH (e.g. C:\Users\<you>\.local\bin), then run: rtk init -g"
    }

    if ($rtkInstalled) {
        # winget updates PATH for new terminals only; resolve rtk for this session
        $rtkCmd = (Get-Command rtk -ErrorAction SilentlyContinue).Source
        if ($rtkCmd) {
            & $rtkCmd init -g
            Write-Success "✓ rtk installed and hooked into Claude Code (global)"
            Write-Warning "  Restart Claude Code so the hook is loaded."
        } else {
            Write-Success "✓ rtk installed"
            Write-Warning "  Open a new terminal and run: rtk init -g"
        }
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Warning "  ⚠ rtk installation failed. Retry manually: winget install rtk-ai.rtk; rtk init -g"
    }
} else {
    Write-Info "  Skipped rtk installation"
}

Write-Info ""

# Step 8.8: Optional external tools - ponytail (Claude Code plugin)
# ponytail is a Claude Code plugin, not a vended skill. The '/plugin' commands only
# exist inside Claude Code, so we use the equivalent 'claude plugin' CLI.
# Its lifecycle hooks need node on PATH for always-on activation.
Write-Info "Step 8.8: Optional external tools (ponytail)..."

$installPonytail = "n"
if ($Interactive) {
    $installPonytail = Read-Host "Install ponytail? (Claude Code plugin, requires claude CLI) (y/n) [n]"
}

if ($installPonytail -eq "y" -or $installPonytail -eq "Y") {
    $ponytailOk = $false
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Info "  Installing ponytail plugin..."
        claude plugin marketplace add DietrichGebert/ponytail
        if ($LASTEXITCODE -eq 0) {
            claude plugin install ponytail@ponytail
            $ponytailOk = ($LASTEXITCODE -eq 0)
        }
    } else {
        Write-Warning "  ⚠ claude CLI not found."
    }

    if ($ponytailOk) {
        Write-Success "✓ ponytail installed (Claude Code plugin)"
        Write-Warning "  Restart Claude Code so the plugin is loaded."
    } else {
        Write-Warning "  ⚠ ponytail not installed. Inside Claude Code run:"
        Write-Warning "    /plugin marketplace add DietrichGebert/ponytail"
        Write-Warning "    /plugin install ponytail@ponytail"
    }
} else {
    Write-Info "  Skipped ponytail installation"
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
