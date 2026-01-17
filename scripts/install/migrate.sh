#!/bin/bash
#
# Claude Forge Migration Script
#
# This script sets up the Claude Forge framework on an existing project.
# Run this from the claude-forge directory after cloning it.
#
# Usage:
#   ./scripts/migrate.sh                    # Interactive mode
#   ./scripts/migrate.sh /path/to/project   # Specify project path
#
# After running this script, start Claude Code in your project and run:
#   /migrate
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located (claude-forge root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Claude Forge Framework Migration Script              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verify we're in the claude-forge directory
if [ ! -f "$FRAMEWORK_DIR/CLAUDE.md" ] || [ ! -d "$FRAMEWORK_DIR/skills" ]; then
    echo -e "${RED}Error: This script must be run from the claude-forge directory.${NC}"
    echo "Expected to find CLAUDE.md and skills/ directory in: $FRAMEWORK_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Forge framework found at: $FRAMEWORK_DIR"
echo ""

# Get project directory
if [ -n "$1" ]; then
    PROJECT_DIR="$1"
else
    echo -e "${BLUE}Enter the path to your project directory:${NC}"
    echo -e "${YELLOW}(This is the project you want to migrate to Claude Forge)${NC}"
    read -r -p "> " PROJECT_DIR
fi

# Expand ~ to home directory
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

# Convert to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Directory does not exist: $PROJECT_DIR${NC}"
    exit 1
}

echo ""
echo -e "${GREEN}✓${NC} Project directory: $PROJECT_DIR"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory does not exist: $PROJECT_DIR${NC}"
    exit 1
fi

# Check for existing Claude configuration
EXISTING_CLAUDE=""
BACKUP_NAME=""

if [ -d "$PROJECT_DIR/.claude" ]; then
    EXISTING_CLAUDE="$PROJECT_DIR/.claude"
    BACKUP_NAME=".claude_old"
    echo ""
    echo -e "${YELLOW}Found existing .claude directory${NC}"
elif [ -d "$PROJECT_DIR/claude" ]; then
    EXISTING_CLAUDE="$PROJECT_DIR/claude"
    BACKUP_NAME="claude_old"
    echo ""
    echo -e "${YELLOW}Found existing claude directory${NC}"
fi

# Show what will happen
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Migration Plan${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -n "$EXISTING_CLAUDE" ]; then
    echo -e "  1. ${YELLOW}Backup${NC} existing configuration:"
    echo -e "     $EXISTING_CLAUDE → $PROJECT_DIR/$BACKUP_NAME"
    echo ""
    echo -e "  2. ${GREEN}Install${NC} Claude Forge framework:"
    echo -e "     $FRAMEWORK_DIR → $PROJECT_DIR/.claude"
    echo ""
    echo -e "  3. ${BLUE}Create${NC} restoration script:"
    echo -e "     $PROJECT_DIR/.claude_restore.sh"
    echo ""
    echo -e "${CYAN}After this script completes:${NC}"
    echo -e "  • Start Claude Code in your project"
    echo -e "  • Run ${GREEN}/migrate${NC} to merge your old configuration"
else
    echo -e "  1. ${GREEN}Install${NC} Claude Forge framework:"
    echo -e "     $FRAMEWORK_DIR → $PROJECT_DIR/.claude"
    echo ""
    echo -e "${CYAN}After this script completes:${NC}"
    echo -e "  • Start Claude Code in your project"
    echo -e "  • Run ${GREEN}/new-project --current${NC} to analyze your codebase"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Confirm
read -r -p "Proceed with migration? [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Migration cancelled.${NC}"
    exit 0
fi

echo ""

# Step 1: Backup existing configuration
if [ -n "$EXISTING_CLAUDE" ]; then
    echo -e "${BLUE}Step 1: Backing up existing configuration...${NC}"

    if [ -d "$PROJECT_DIR/$BACKUP_NAME" ]; then
        echo -e "${YELLOW}Warning: $BACKUP_NAME already exists.${NC}"
        read -r -p "Overwrite existing backup? [y/N] " overwrite
        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR/$BACKUP_NAME"
        else
            echo -e "${RED}Cannot proceed - backup directory exists.${NC}"
            exit 1
        fi
    fi

    mv "$EXISTING_CLAUDE" "$PROJECT_DIR/$BACKUP_NAME"
    echo -e "${GREEN}✓${NC} Backed up to: $PROJECT_DIR/$BACKUP_NAME"

    # Create restoration script
    cat > "$PROJECT_DIR/.claude_restore.sh" << 'RESTORE_EOF'
#!/bin/bash
#
# Claude Forge Restoration Script
# Run this to restore your original Claude configuration
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Claude Forge Restoration"
echo "========================"
echo ""

# Check for backup
if [ -d "$SCRIPT_DIR/.claude_old" ]; then
    BACKUP_DIR="$SCRIPT_DIR/.claude_old"
    TARGET_DIR="$SCRIPT_DIR/.claude"
elif [ -d "$SCRIPT_DIR/claude_old" ]; then
    BACKUP_DIR="$SCRIPT_DIR/claude_old"
    TARGET_DIR="$SCRIPT_DIR/claude"
else
    echo "Error: No backup directory found (.claude_old or claude_old)"
    exit 1
fi

echo "This will:"
echo "  1. Remove the current Claude Forge installation"
echo "  2. Restore your original configuration from backup"
echo ""
read -r -p "Proceed? [y/N] " response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Restoration cancelled."
    exit 0
fi

echo ""
echo "Restoring..."

if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
fi

mv "$BACKUP_DIR" "$TARGET_DIR"
rm -f "$SCRIPT_DIR/.claude_restore.sh"

echo ""
echo "✓ Restoration complete!"
echo "  Your original configuration has been restored."
RESTORE_EOF

    chmod +x "$PROJECT_DIR/.claude_restore.sh"
    echo -e "${GREEN}✓${NC} Created restoration script: $PROJECT_DIR/.claude_restore.sh"
else
    echo -e "${BLUE}Step 1: No existing configuration to backup${NC}"
fi

# Step 2: Copy Claude Forge framework
echo ""
echo -e "${BLUE}Step 2: Installing Claude Forge framework...${NC}"

# Create .claude directory
mkdir -p "$PROJECT_DIR/.claude"

# Copy framework files (excluding .git and scripts used for migration)
rsync -a --exclude='.git' --exclude='.github' --exclude='scripts/migrate.sh' --exclude='scripts/migrate.ps1' "$FRAMEWORK_DIR/" "$PROJECT_DIR/.claude/"

echo -e "${GREEN}✓${NC} Framework installed to: $PROJECT_DIR/.claude"

# Step 3: Initialize memories structure
echo ""
echo -e "${BLUE}Step 3: Initializing session directories...${NC}"

mkdir -p "$PROJECT_DIR/.claude/memories/sessions/active"
mkdir -p "$PROJECT_DIR/.claude/memories/sessions/completed"
touch "$PROJECT_DIR/.claude/memories/sessions/active/.gitkeep"
touch "$PROJECT_DIR/.claude/memories/sessions/completed/.gitkeep"

echo -e "${GREEN}✓${NC} Session directories created"

# Step 4: Initialize project memory
echo ""
echo -e "${BLUE}Step 4: Initializing project memory...${NC}"

mkdir -p "$PROJECT_DIR/docs/project-memory"

# Copy templates if they exist
if [ -d "$FRAMEWORK_DIR/templates/project-memory" ]; then
    cp "$FRAMEWORK_DIR/templates/project-memory/bugs.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
    cp "$FRAMEWORK_DIR/templates/project-memory/decisions.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
    cp "$FRAMEWORK_DIR/templates/project-memory/key-facts.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
    cp "$FRAMEWORK_DIR/templates/project-memory/patterns.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Project memory initialized at: $PROJECT_DIR/docs/project-memory/"
else
    echo -e "${YELLOW}⚠${NC} Templates not found, created empty directory"
fi

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Migration Setup Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -n "$EXISTING_CLAUDE" ]; then
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo -e "  1. Navigate to your project:"
    echo -e "     ${YELLOW}cd $PROJECT_DIR${NC}"
    echo ""
    echo -e "  2. Start Claude Code:"
    echo -e "     ${YELLOW}claude${NC}"
    echo ""
    echo -e "  3. Run the migration skill to merge your old config:"
    echo -e "     ${GREEN}/migrate${NC}"
    echo ""
    echo -e "${CYAN}Rollback:${NC}"
    echo -e "  If you need to restore your original configuration:"
    echo -e "  ${YELLOW}$PROJECT_DIR/.claude_restore.sh${NC}"
else
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo -e "  1. Navigate to your project:"
    echo -e "     ${YELLOW}cd $PROJECT_DIR${NC}"
    echo ""
    echo -e "  2. Start Claude Code:"
    echo -e "     ${YELLOW}claude${NC}"
    echo ""
    echo -e "  3. Initialize the framework for your project:"
    echo -e "     ${GREEN}/new-project --current${NC}"
fi

echo ""
echo -e "${GREEN}Happy coding with Claude Forge! 🚀${NC}"
echo ""
