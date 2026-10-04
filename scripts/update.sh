#!/bin/bash

# Claude Config Update Script
# Updates the claude-config submodule to the latest version
# Bash 3.2 compatible (macOS default shell) - keep in sync with update.ps1

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}$1${NC}"; }
log_warning() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }

# Banner
log_info "
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Claude Config - Update Script                      ║
║   Updating to latest configuration                   ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"

PROJECT_ROOT="$(pwd)"
SUBMODULE_PATH="$PROJECT_ROOT/.claude-config"

log_info "Project root: $PROJECT_ROOT"
echo ""

# Step 1: Verify submodule exists
log_info "Step 1: Verifying submodule..."

if [ ! -d "$SUBMODULE_PATH" ]; then
    log_error "✗ .claude-config directory not found"
    log_info "  This script should be run from a project that has claude-config as a submodule"
    exit 1
fi

# In a submodule '.git' is a file, so test for existence rather than directory
if [ ! -e "$SUBMODULE_PATH/.git" ]; then
    log_error "✗ .claude-config is not a git submodule"
    log_info "  This script only works with git submodules"
    exit 1
fi

log_success "✓ Submodule found"
echo ""

# Step 2: Get current version
log_info "Step 2: Checking current version..."

CURRENT_COMMIT="$(git -C "$SUBMODULE_PATH" rev-parse --short HEAD)"
CURRENT_BRANCH="$(git -C "$SUBMODULE_PATH" rev-parse --abbrev-ref HEAD)"
log_info "  Current commit: $CURRENT_COMMIT"
log_info "  Current branch: $CURRENT_BRANCH"
echo ""

# Step 3: Update submodule
log_info "Step 3: Updating submodule..."

log_info "  Fetching latest changes..."
if ! git -C "$SUBMODULE_PATH" fetch origin; then
    log_error "✗ Failed to fetch updates"
    exit 1
fi

log_info "  Pulling updates..."
if ! git -C "$SUBMODULE_PATH" pull origin "$CURRENT_BRANCH"; then
    log_error "✗ Failed to update submodule"
    exit 1
fi

NEW_COMMIT="$(git -C "$SUBMODULE_PATH" rev-parse --short HEAD)"

if [ "$CURRENT_COMMIT" = "$NEW_COMMIT" ]; then
    log_success "✓ Already up to date"
else
    log_success "✓ Updated to commit $NEW_COMMIT"
    echo ""
    log_info "Changes:"
    git -C "$SUBMODULE_PATH" log --oneline "$CURRENT_COMMIT..$NEW_COMMIT"
fi

echo ""

# Step 4: Check for new skills/agents
log_info "Step 4: Checking for new skills and agents..."

NEW_SKILLS=()
NEW_AGENTS=()

while IFS= read -r -d '' skill_file; do
    skill_name="$(basename "$(dirname "$skill_file")")"
    [ -e "$PROJECT_ROOT/.claude/skills/$skill_name" ] || NEW_SKILLS+=("$skill_name")
done < <(find "$SUBMODULE_PATH/skills" -name "SKILL.md" -print0)

while IFS= read -r -d '' agent_file; do
    agent_name="$(basename "$agent_file" .md)"
    [ -e "$PROJECT_ROOT/.claude/agents/$agent_name.md" ] || NEW_AGENTS+=("$agent_name")
done < <(find "$SUBMODULE_PATH/agents" -name "*.md" ! -name "README.md" -print0)

if [ ${#NEW_SKILLS[@]} -gt 0 ]; then
    log_info "  New skills available:"
    for skill in "${NEW_SKILLS[@]}"; do
        log_info "    → $skill"
    done
else
    log_info "  No new skills available"
fi

if [ ${#NEW_AGENTS[@]} -gt 0 ]; then
    log_info "  New agents available:"
    for agent in "${NEW_AGENTS[@]}"; do
        log_info "    → $agent"
    done
else
    log_info "  No new agents available"
fi

echo ""

# Step 5: Update parent repository
log_info "Step 5: Updating parent repository..."

if [ -d "$PROJECT_ROOT/.git" ]; then
    log_info "  This will stage the submodule update in your project"
    log_warning "  Remember to commit the change: git commit -m 'Update claude-config submodule'"
    git add .claude-config
    log_success "✓ Submodule update staged"
else
    log_warning "⚠ Not a git repository, skipping git add"
fi

echo ""

# Summary
log_success "
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   Update Complete! ✓                                 ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"

log_info "Summary:"
log_info "  → Updated from: $CURRENT_COMMIT"
log_info "  → Updated to: $NEW_COMMIT"
log_info "  → New skills available: ${#NEW_SKILLS[@]}"
log_info "  → New agents available: ${#NEW_AGENTS[@]}"
echo ""

if [ ${#NEW_SKILLS[@]} -gt 0 ] || [ ${#NEW_AGENTS[@]} -gt 0 ]; then
    log_info "To install new skills/agents, run:"
    log_info "  ./.claude-config/scripts/install.sh"
    echo ""
fi

log_info "Next steps:"
log_info "  1. Review changes in .claude-config/"
log_info "  2. Test your project with updated configuration"
log_info "  3. Commit the submodule update: git commit -m 'Update claude-config'"
echo ""
log_success "Done! 🚀"
echo ""
