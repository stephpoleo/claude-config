#!/bin/bash

# Claude Config Installation Script
# Installs skills, agents, and configuration for Claude Code projects

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}$1${NC}"; }
log_warning() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }

# Relative path from $2 (directory) to $1. Uses Perl (ships with macOS and Git Bash)
# because 'realpath --relative-to' is GNU-only. Falls back to the absolute path.
rel_path() {
    perl -MFile::Spec -e 'print File::Spec->abs2rel($ARGV[0], $ARGV[1])' "$1" "$2" 2>/dev/null || echo "$1"
}

# Banner
log_info "
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Claude Config - Installation Script                ║
║   Setting up your Claude Code environment            ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(pwd)"

log_info "Script directory: $SCRIPT_DIR"
log_info "Project root: $PROJECT_ROOT"
echo ""

# Parse arguments
PRESET=""
INTERACTIVE=true
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --preset)
            PRESET="$2"
            shift 2
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Step 1: Validate environment
log_info "Step 1: Validating environment..."

if [ ! -d "$PROJECT_ROOT/.git" ]; then
    log_warning "Warning: Not a git repository. Consider running 'git init' first."
fi

# Create .claude directory
if [ ! -d "$PROJECT_ROOT/.claude" ]; then
    log_info "Creating .claude directory..."
    mkdir -p "$PROJECT_ROOT/.claude"
    log_success "✓ Created .claude directory"
else
    log_success "✓ .claude directory exists"
fi

# Create skills and agents directories
mkdir -p "$PROJECT_ROOT/.claude/skills"
mkdir -p "$PROJECT_ROOT/.claude/agents"

log_success "✓ Environment validated"
echo ""

# Step 1.5: Configure .gitignore (optional)
if [ "$INTERACTIVE" = true ] && [ -d "$PROJECT_ROOT/.git" ]; then
    log_info "Step 1.5: Git configuration..."
    read -p "Add .claude-config/ to .gitignore? (y/n) [Recommended: y]: " add_to_gitignore

    if [ "$add_to_gitignore" = "y" ] || [ "$add_to_gitignore" = "Y" ] || [ -z "$add_to_gitignore" ]; then
        gitignore_path="$PROJECT_ROOT/.gitignore"
        ignore_entry=".claude-config/"

        # Check if .gitignore exists
        if [ ! -f "$gitignore_path" ]; then
            log_info "Creating .gitignore..."
            touch "$gitignore_path"
        fi

        # Check if entry already exists
        if ! grep -qxF "$ignore_entry" "$gitignore_path"; then
            # Add entry to .gitignore
            echo "" >> "$gitignore_path"
            echo "# Claude Config (submodule - opcional)" >> "$gitignore_path"
            echo "$ignore_entry" >> "$gitignore_path"
            log_success "✓ Added .claude-config/ to .gitignore"
        else
            log_success "✓ .claude-config/ already in .gitignore"
        fi
    else
        log_info "Skipped .gitignore configuration"
        log_warning "Note: .claude-config/ will be tracked by git (submodule)"
    fi
    echo ""
fi

# Step 2: Select preset
log_info "Step 2: Select configuration preset..."

# Indexed arrays and 'case' only: macOS ships bash 3.2 (no 'declare -A')
PRESETS=(
    "base:Base configuration (minimal setup)"
    "web-dev:Web development (Angular, Django, TypeScript)"
    "data-science:Data science (ML, pandas, scikit-learn, visualization)"
    "devops:DevOps & Infrastructure (Docker, CI/CD, AWS, GCP)"
    "testing:Testing focused (pytest, unit/integration tests)"
    "smart-print:3D printing business (NFC, ESP32, pricing, social media)"
)

if [ "$INTERACTIVE" = true ] && [ -z "$PRESET" ]; then
    log_info "Available presets:"
    for idx in "${!PRESETS[@]}"; do
        IFS=':' read -r name desc <<< "${PRESETS[$idx]}"
        log_info "  [$((idx + 1))] $name - $desc"
    done
    echo ""

    while true; do
        read -p "Select preset [1-${#PRESETS[@]}]: " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#PRESETS[@]} ]; then
            IFS=':' read -r PRESET _ <<< "${PRESETS[$((selection - 1))]}"
            break
        fi
    done
fi

if [ -z "$PRESET" ]; then
    PRESET="base"
fi

log_success "✓ Selected preset: $PRESET"
echo ""

# Step 3: Get skills for selected preset
log_info "Step 3: Selecting skills..."

preset_skills() {
    case "$1" in
        web-dev)      echo "angular-component,django-api,api-design" ;;
        data-science) echo "data-pipeline,sql-optimization,data-visualization,model-design" ;;
        devops)       echo "docker-setup,github-actions,aws-setup,gcp-setup" ;;
        testing)      echo "test-suite,clean-code-review" ;;
        smart-print)  echo "print-quote,print-design-brief,nfc-hub,iot-firmware,social-content,client-pitch" ;;
        *)            echo "" ;;
    esac
}

IFS=',' read -r -a SELECTED_SKILLS <<< "$(preset_skills "$PRESET")"

# Get all available skills
ALL_SKILLS=()
while IFS= read -r -d '' skill_file; do
    skill_dir=$(dirname "$skill_file")
    category=$(basename "$(dirname "$skill_dir")")
    skill_name=$(basename "$skill_dir")
    ALL_SKILLS+=("$category/$skill_name:$skill_dir")
done < <(find "$SCRIPT_DIR/skills" -name "SKILL.md" -print0)

if [ "$INTERACTIVE" = true ] && [ ${#ALL_SKILLS[@]} -gt 0 ]; then
    log_info "Skills included in preset:"
    for skill in "${SELECTED_SKILLS[@]}"; do
        [ -n "$skill" ] && log_info "  ✓ $skill"
    done
    echo ""

    read -p "Add more skills? (y/n): " add_more
    if [ "$add_more" = "y" ] || [ "$add_more" = "Y" ]; then
        log_info "Available skills:"
        i=1
        for skill_info in "${ALL_SKILLS[@]}"; do
            IFS=':' read -r skill_path _ <<< "$skill_info"
            skill_name=$(basename "$(dirname "$(echo "$skill_path" | cut -d: -f2)")")
            if [[ ! " ${SELECTED_SKILLS[@]} " =~ " ${skill_name} " ]]; then
                log_info "  [$i] $skill_path"
                i=$((i + 1))
            fi
        done
        echo ""

        read -p "Enter skill numbers (comma-separated, or 'all'): " selections
        if [ "$selections" = "all" ]; then
            for skill_info in "${ALL_SKILLS[@]}"; do
                IFS=':' read -r _ skill_dir <<< "$skill_info"
                skill_name=$(basename "$skill_dir")
                SELECTED_SKILLS+=("$skill_name")
            done
        elif [ -n "$selections" ]; then
            IFS=',' read -r -a numbers <<< "$selections"
            for num in "${numbers[@]}"; do
                num=$(echo "$num" | xargs)  # trim
                if [ "$num" -gt 0 ] && [ "$num" -le ${#ALL_SKILLS[@]} ]; then
                    idx=$((num - 1))
                    IFS=':' read -r _ skill_dir <<< "${ALL_SKILLS[$idx]}"
                    skill_name=$(basename "$skill_dir")
                    SELECTED_SKILLS+=("$skill_name")
                fi
            done
        fi
    fi
fi

log_success "✓ Skills selected: ${#SELECTED_SKILLS[@]}"
echo ""

# Step 4: Link skills
log_info "Step 4: Creating skill symlinks..."

LINKED_SKILLS=0
for skill_name in "${SELECTED_SKILLS[@]}"; do
    [ -z "$skill_name" ] && continue

    # Find skill directory
    skill_dir=""
    for skill_info in "${ALL_SKILLS[@]}"; do
        IFS=':' read -r _ dir <<< "$skill_info"
        if [ "$(basename "$dir")" = "$skill_name" ]; then
            skill_dir="$dir"
            break
        fi
    done

    if [ -n "$skill_dir" ]; then
        target_path="$PROJECT_ROOT/.claude/skills/$skill_name"

        # Remove existing link/directory
        [ -e "$target_path" ] && rm -rf "$target_path"

        # Create relative symlink
        relative_path="$(rel_path "$skill_dir" "$(dirname "$target_path")")"
        ln -s "$relative_path" "$target_path"

        [ "$VERBOSE" = true ] && log_info "  → Linked $skill_name"
        LINKED_SKILLS=$((LINKED_SKILLS + 1))
    fi
done

log_success "✓ Linked $LINKED_SKILLS skills"
echo ""

# Step 5: Link agents
log_info "Step 5: Selecting agents..."

preset_agents() {
    case "$1" in
        web-dev)      echo "angular-specialist,python-django-specialist" ;;
        data-science) echo "data-scientist-specialist" ;;
        devops)       echo "docker-specialist,cicd-specialist" ;;
        smart-print)  echo "product-designer-3d,iot-engineer,business-strategist-mx,social-media-manager" ;;
        *)            echo "" ;;
    esac
}

IFS=',' read -r -a SELECTED_AGENTS <<< "$(preset_agents "$PRESET")"

# Get all available agents
ALL_AGENTS=()
while IFS= read -r -d '' agent_file; do
    category=$(basename "$(dirname "$agent_file")")
    agent_name=$(basename "$agent_file" .md)
    ALL_AGENTS+=("$category/$agent_name:$agent_file")
done < <(find "$SCRIPT_DIR/agents" -name "*.md" ! -name "README.md" -print0)

if [ "$INTERACTIVE" = true ] && [ ${#ALL_AGENTS[@]} -gt 0 ]; then
    log_info "Agents included in preset:"
    for agent in "${SELECTED_AGENTS[@]}"; do
        [ -n "$agent" ] && log_info "  ✓ $agent"
    done
    echo ""

    read -p "Add more agents? (y/n): " add_more
    if [ "$add_more" = "y" ] || [ "$add_more" = "Y" ]; then
        log_info "Available agents:"
        i=1
        for agent_info in "${ALL_AGENTS[@]}"; do
            IFS=':' read -r agent_path _ <<< "$agent_info"
            agent_name=$(basename "$(echo "$agent_path" | cut -d: -f2)" .md)
            if [[ ! " ${SELECTED_AGENTS[@]} " =~ " ${agent_name} " ]]; then
                log_info "  [$i] $agent_path"
                i=$((i + 1))
            fi
        done
        echo ""

        read -p "Enter agent numbers (comma-separated, or 'all'): " selections
        if [ "$selections" = "all" ]; then
            for agent_info in "${ALL_AGENTS[@]}"; do
                IFS=':' read -r _ agent_file <<< "$agent_info"
                agent_name=$(basename "$agent_file" .md)
                SELECTED_AGENTS+=("$agent_name")
            done
        elif [ -n "$selections" ]; then
            IFS=',' read -r -a numbers <<< "$selections"
            for num in "${numbers[@]}"; do
                num=$(echo "$num" | xargs)
                if [ "$num" -gt 0 ] && [ "$num" -le ${#ALL_AGENTS[@]} ]; then
                    idx=$((num - 1))
                    IFS=':' read -r _ agent_file <<< "${ALL_AGENTS[$idx]}"
                    agent_name=$(basename "$agent_file" .md)
                    SELECTED_AGENTS+=("$agent_name")
                fi
            done
        fi
    fi
fi

# Link agents
LINKED_AGENTS=0
for agent_name in "${SELECTED_AGENTS[@]}"; do
    [ -z "$agent_name" ] && continue

    # Find agent file
    agent_file=""
    for agent_info in "${ALL_AGENTS[@]}"; do
        IFS=':' read -r _ file <<< "$agent_info"
        if [ "$(basename "$file" .md)" = "$agent_name" ]; then
            agent_file="$file"
            break
        fi
    done

    if [ -n "$agent_file" ]; then
        target_path="$PROJECT_ROOT/.claude/agents/$agent_name.md"

        # Remove existing link/file
        [ -e "$target_path" ] && rm -f "$target_path"

        # Create relative symlink
        relative_path="$(rel_path "$agent_file" "$(dirname "$target_path")")"
        ln -s "$relative_path" "$target_path"

        [ "$VERBOSE" = true ] && log_info "  → Linked $agent_name"
        LINKED_AGENTS=$((LINKED_AGENTS + 1))
    fi
done

log_success "✓ Linked $LINKED_AGENTS agents"
echo ""

# Step 6: Create settings file
log_info "Step 6: Creating settings file..."

settings_file="$PROJECT_ROOT/.claude/settings.local.json"

if [ -f "$settings_file" ]; then
    log_warning "⚠ settings.local.json already exists"
    if [ "$INTERACTIVE" = true ]; then
        read -p "Overwrite? (y/n): " overwrite
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
            log_info "  Skipping settings creation"
            settings_file=""
        fi
    else
        settings_file=""
    fi
fi

if [ -n "$settings_file" ]; then
    project_name=$(basename "$PROJECT_ROOT")
    created_at=$(date +%Y-%m-%d)

    cat > "$settings_file" << EOF
{
  "\$schema": "https://json.schemastore.org/claude-code-settings.json",
  "extends": "../.claude-config/settings/$PRESET.json",
  "model": "sonnet",
  "customSettings": {
    "projectName": "$project_name",
    "createdAt": "$created_at"
  }
}
EOF

    log_success "✓ Created settings.local.json"
fi

echo ""

# Step 7: Create CLAUDE.md
log_info "Step 7: Creating CLAUDE.md template..."

claude_md_file="$PROJECT_ROOT/.claude/CLAUDE.md"

if [ ! -f "$claude_md_file" ]; then
    cat > "$claude_md_file" << 'EOF'
# Project Context for Claude

## Project Overview

[Describe your project here]

## Tech Stack

- **Language**:
- **Framework**:
- **Database**:
- **Tools**:

## Project Structure

```
project/
├── src/
├── tests/
└── docs/
```

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
EOF

    log_success "✓ Created CLAUDE.md template"
else
    log_info "  CLAUDE.md already exists, skipping"
fi

echo ""

# Step 8: Update .gitignore
log_info "Step 8: Updating .gitignore..."

gitignore_file="$PROJECT_ROOT/.gitignore"
gitignore_entries="
# Claude Code local settings
.claude/settings.local.json
.claude/*.local.json"

if [ -f "$gitignore_file" ]; then
    if ! grep -q ".claude/settings.local.json" "$gitignore_file"; then
        echo "$gitignore_entries" >> "$gitignore_file"
        log_success "✓ Updated .gitignore"
    else
        log_info "  .gitignore already configured"
    fi
else
    echo "$gitignore_entries" > "$gitignore_file"
    log_success "✓ Created .gitignore"
fi

echo ""

# Step 8.5: Optional external tools - graphify (knowledge-graph skill)
# graphify is NOT a vended skill: it is a Python package (graphifyy) that installs
# and self-updates its own skill globally (~/.claude/skills/graphify). We only offer
# to install it here so teammates cloning this repo get it too. Never copy its
# SKILL.md into this repo - it would drift and does nothing without the package.
log_info "Step 8.5: Optional external tools (graphify)..."

install_graphify="n"
if [ "$INTERACTIVE" = true ]; then
    read -p "Install graphify? (knowledge-graph skill '/graphify', requires uv) (y/n) [n]: " install_graphify
fi

if [ "$install_graphify" = "y" ] || [ "$install_graphify" = "Y" ]; then
    if command -v uv >/dev/null 2>&1; then
        log_info "  Installing graphifyy via uv..."
        uv tool install --upgrade graphifyy

        # Resolve the graphify executable - it may not be on PATH in this session yet
        graphify_cmd="$(command -v graphify 2>/dev/null || true)"
        if [ -z "$graphify_cmd" ] && [ -x "$HOME/.local/bin/graphify" ]; then
            graphify_cmd="$HOME/.local/bin/graphify"
        fi

        if [ -n "$graphify_cmd" ]; then
            "$graphify_cmd" install
            uv tool update-shell >/dev/null 2>&1 || true
            log_success "✓ graphify installed (global skill - use /graphify in any project)"
            log_warning "  Restart your terminal so 'graphify' is on PATH."
        else
            log_warning "  ⚠ graphifyy installed but 'graphify' not found on PATH."
            log_warning "    Run 'uv tool update-shell', reopen your terminal, then 'graphify install'."
        fi
    else
        log_warning "  ⚠ uv not found. Install uv first: https://docs.astral.sh/uv/"
        log_warning "    Alternative: pip install graphifyy && graphify install"
    fi
else
    log_info "  Skipped graphify installation"
fi

echo ""

# Step 8.6: Optional external tools - caveman (skill pack)
# caveman is NOT vended: the 'skills' CLI installs it globally into ~/.agents/skills
# and symlinks each skill into ~/.claude/skills. Never copy its SKILL.md files into
# this repo - re-running the install command is how it gets updated.
log_info "Step 8.6: Optional external tools (caveman)..."

install_caveman="n"
if [ "$INTERACTIVE" = true ]; then
    read -p "Install caveman? (skill pack '/caveman', requires npx) (y/n) [n]: " install_caveman
fi

if [ "$install_caveman" = "y" ] || [ "$install_caveman" = "Y" ]; then
    if command -v npx >/dev/null 2>&1; then
        log_info "  Installing caveman via skills CLI..."
        if npx -y skills add JuliusBrussee/caveman -g -y; then
            log_success "✓ caveman installed (global skills - use /caveman in any project)"
            log_warning "  Restart Claude Code so the new skills are loaded."
        else
            log_warning "  ⚠ caveman installation failed."
            log_warning "    Retry manually: npx skills add JuliusBrussee/caveman -g"
        fi
    else
        log_warning "  ⚠ npx not found. Install Node.js first: https://nodejs.org/"
    fi
else
    log_info "  Skipped caveman installation"
fi

echo ""

# Step 8.7: Optional external tools - rtk (token-saving CLI proxy)
# rtk is installed with Homebrew on macOS; 'rtk init -g' then installs its global
# Claude Code hook + RTK.md. On Windows install.ps1 uses winget instead.
log_info "Step 8.7: Optional external tools (rtk)..."

install_rtk="n"
if [ "$INTERACTIVE" = true ]; then
    read -p "Install rtk? (token-saving CLI proxy, requires Homebrew) (y/n) [n]: " install_rtk
fi

if [ "$install_rtk" = "y" ] || [ "$install_rtk" = "Y" ]; then
    if command -v brew >/dev/null 2>&1; then
        log_info "  Installing rtk via Homebrew..."
        if brew install rtk && rtk init -g; then
            log_success "✓ rtk installed and hooked into Claude Code (global)"
            log_warning "  Restart Claude Code so the hook is loaded."
        else
            log_warning "  ⚠ rtk installation failed. Retry manually: brew install rtk && rtk init -g"
        fi
    else
        log_warning "  ⚠ brew not found. Install Homebrew (https://brew.sh/) or use:"
        log_warning "    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
        log_warning "    then run: rtk init -g"
    fi
else
    log_info "  Skipped rtk installation"
fi

echo ""

# Step 8.8: Optional external tools - ponytail (Claude Code plugin)
# ponytail is a Claude Code plugin, not a vended skill. The '/plugin' commands only
# exist inside Claude Code, so we use the equivalent 'claude plugin' CLI.
# Its lifecycle hooks need node on PATH for always-on activation.
log_info "Step 8.8: Optional external tools (ponytail)..."

install_ponytail="n"
if [ "$INTERACTIVE" = true ]; then
    read -p "Install ponytail? (Claude Code plugin, requires claude CLI) (y/n) [n]: " install_ponytail
fi

if [ "$install_ponytail" = "y" ] || [ "$install_ponytail" = "Y" ]; then
    if command -v claude >/dev/null 2>&1; then
        log_info "  Installing ponytail plugin..."
        if claude plugin marketplace add DietrichGebert/ponytail && claude plugin install ponytail@ponytail; then
            log_success "✓ ponytail installed (Claude Code plugin)"
            log_warning "  Restart Claude Code so the plugin is loaded."
        else
            log_warning "  ⚠ ponytail installation failed. Inside Claude Code run:"
            log_warning "    /plugin marketplace add DietrichGebert/ponytail"
            log_warning "    /plugin install ponytail@ponytail"
        fi
    else
        log_warning "  ⚠ claude CLI not found. Inside Claude Code run:"
        log_warning "    /plugin marketplace add DietrichGebert/ponytail"
        log_warning "    /plugin install ponytail@ponytail"
    fi
else
    log_info "  Skipped ponytail installation"
fi

echo ""

# Summary
log_success "
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Installation Complete! ✓                           ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"

log_info "Summary:"
log_info "  → Preset: $PRESET"
log_info "  → Skills linked: $LINKED_SKILLS"
log_info "  → Agents linked: $LINKED_AGENTS"
log_info "  → Settings: .claude/settings.local.json"
log_info "  → Context: .claude/CLAUDE.md"
echo ""
log_info "Next steps:"
log_info "  1. Edit .claude/CLAUDE.md with your project context"
log_info "  2. Customize .claude/settings.local.json if needed"
log_info "  3. Start using Claude Code with your configured skills!"
echo ""
log_info "Available skills:"
for skill in "${SELECTED_SKILLS[@]}"; do
    [ -n "$skill" ] && log_info "  → /$skill"
done
echo ""
log_success "Happy coding! 🚀"
echo ""
