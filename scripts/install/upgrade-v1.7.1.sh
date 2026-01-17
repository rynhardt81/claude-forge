#!/bin/bash
#
# Claude Forge Upgrade Script - Version 1.7.1
#
# This script upgrades an existing Claude Forge installation to v1.7.1.
# Run this if your project has v1.7 or earlier of Claude Forge installed.
#
# Usage:
#   ./scripts/install/upgrade-v1.7.1.sh                    # Interactive mode
#   ./scripts/install/upgrade-v1.7.1.sh /path/to/project   # Specify project path
#
# What's new in v1.7.1:
#   - Process Execution Modes (normal, strict, paranoid)
#   - Tiered step enforcement with markers (⛔ CRITICAL, 🔒 REQUIRED, 📋 RECOMMENDED)
#   - Pre-presentation checklist for /reflect resume T###
#   - Fixed file paths for deployed projects (.claude/agents/summaries/, .claude/scripts/helpers/)
#   - New /reflect strict on|off|paranoid commands
#   - Enhanced CLAUDE.md with enforcement markers on all gates and rules
#
# IMPORTANT: This script backs up existing files before replacing them.
#            Backups are stored in .claude/backups/v1.7.1-{timestamp}/
#
# Note: Apply upgrade scripts sequentially if multiple versions behind.
#       e.g., v1.6 → v1.7 → v1.7.1
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Version info
UPGRADE_VERSION="1.7.1"
MIN_VERSION="1.7"

# Timestamp for backups
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Get the directory where this script is located (claude-forge root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Claude Forge Framework Upgrade Script                ║"
echo "║                      Version $UPGRADE_VERSION                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verify we're in the claude-forge directory
if [ ! -f "$FRAMEWORK_DIR/CLAUDE.md" ] || [ ! -d "$FRAMEWORK_DIR/skills" ]; then
    echo -e "${RED}Error: This script must be run from the claude-forge directory.${NC}"
    echo "Expected to find CLAUDE.md and skills/ directory in: $FRAMEWORK_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Forge framework source found at: $FRAMEWORK_DIR"
echo ""

# Get project directory
if [ -n "$1" ]; then
    PROJECT_DIR="$1"
else
    echo -e "${BLUE}Enter the path to your project directory:${NC}"
    echo -e "${YELLOW}(This is the project with an existing Claude Forge installation)${NC}"
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

# Find Claude Forge installation
CLAUDE_DIR=""
if [ -d "$PROJECT_DIR/.claude" ]; then
    CLAUDE_DIR="$PROJECT_DIR/.claude"
elif [ -d "$PROJECT_DIR/claude" ]; then
    CLAUDE_DIR="$PROJECT_DIR/claude"
fi

if [ -z "$CLAUDE_DIR" ]; then
    echo -e "${RED}Error: No Claude Forge installation found in project.${NC}"
    echo "Expected to find .claude/ or claude/ directory."
    echo ""
    echo -e "To install Claude Forge for the first time, use:"
    echo -e "  ${YELLOW}./scripts/install/migrate.sh $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found Claude Forge installation at: $CLAUDE_DIR"

# Detect current version from CLAUDE.md
CURRENT_VERSION="unknown"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    # Extract version from "Framework Version: X.X" line
    CURRENT_VERSION=$(grep -oP '(?<=Framework Version: )[0-9.]+' "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null || echo "pre-1.7")
fi
echo -e "${GREEN}✓${NC} Current installed version: ${YELLOW}$CURRENT_VERSION${NC}"

# Check if already at or above target version
if [ "$CURRENT_VERSION" = "$UPGRADE_VERSION" ]; then
    echo ""
    echo -e "${YELLOW}Already at version $UPGRADE_VERSION.${NC}"
    read -r -p "Force re-upgrade anyway? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}No upgrade needed.${NC}"
        exit 0
    fi
fi

# Warn if below minimum version
if [ "$CURRENT_VERSION" != "$MIN_VERSION" ] && [ "$CURRENT_VERSION" != "pre-1.7" ] && [ "$CURRENT_VERSION" != "$UPGRADE_VERSION" ]; then
    # Simple version comparison - this is a minor upgrade
    if [[ "$CURRENT_VERSION" < "$MIN_VERSION" ]]; then
        echo ""
        echo -e "${YELLOW}Warning: Your version ($CURRENT_VERSION) is below the minimum for this upgrade ($MIN_VERSION).${NC}"
        echo -e "Please run ${CYAN}upgrade-v1.7.sh${NC} first."
        read -r -p "Continue anyway? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Upgrade cancelled.${NC}"
            exit 0
        fi
    fi
fi

# Create backup directory
BACKUP_DIR="$CLAUDE_DIR/backups/v$UPGRADE_VERSION-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✓${NC} Backup directory: $BACKUP_DIR"

# Show what will be upgraded
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Upgrade Plan: ${YELLOW}$CURRENT_VERSION${NC} ${CYAN}→${NC} ${GREEN}$UPGRADE_VERSION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Directories to sync (backup + replace):${NC}"
echo -e "  • ${YELLOW}skills/${NC} - All skill files"
echo -e "  • ${YELLOW}templates/${NC} - Configuration templates"
echo -e "  • ${YELLOW}reference/${NC} - Reference documentation"
echo -e "  • ${YELLOW}agents/${NC} - Agent definitions and summaries"
echo -e "  • ${YELLOW}scripts/${NC} - Helper and install scripts"
echo -e "  • ${YELLOW}hooks/${NC} - Git hooks"
echo ""
echo -e "${BLUE}Files to sync (backup + replace):${NC}"
echo -e "  • ${YELLOW}CLAUDE.md${NC} - Main framework instructions"
echo ""
echo -e "${BLUE}Project config to update:${NC}"
echo -e "  • ${YELLOW}docs/tasks/config.json${NC} - Project configuration (if exists)"
echo ""
echo -e "${BLUE}What will be preserved:${NC}"
echo -e "  • ${GREEN}memories/${NC} - Session files, progress notes (never touched)"
echo -e "  • ${GREEN}docs/tasks/registry.json${NC} - Task registry (never touched)"
echo -e "  • ${GREEN}docs/epics/${NC} - Epic definitions (never touched)"
echo -e "  • ${GREEN}docs/project-memory/${NC} - Project knowledge (never touched)"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Confirm
read -r -p "Proceed with upgrade? [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Upgrade cancelled.${NC}"
    exit 0
fi

echo ""

# Track what was upgraded
UPGRADED_COUNT=0
BACKED_UP_COUNT=0

# Function to backup a file or directory if it exists
backup_if_exists() {
    local path="$1"
    local backup_subdir="$2"

    if [ -e "$path" ]; then
        local basename=$(basename "$path")
        local backup_path="$BACKUP_DIR/$backup_subdir"
        mkdir -p "$backup_path"
        cp -r "$path" "$backup_path/$basename"
        ((BACKED_UP_COUNT++))
        return 0
    fi
    return 1
}

# Function to sync a directory from framework to project
sync_directory() {
    local src_dir="$1"
    local dest_dir="$2"
    local desc="$3"

    if [ -d "$src_dir" ]; then
        # Backup existing if present
        if [ -d "$dest_dir" ]; then
            backup_if_exists "$dest_dir" "$(dirname "${dest_dir#$CLAUDE_DIR/}")" && \
                echo -e "  ${YELLOW}↳${NC} Backed up existing $desc"
            rm -rf "$dest_dir"
        fi

        # Create parent directory and copy
        mkdir -p "$(dirname "$dest_dir")"
        cp -r "$src_dir" "$dest_dir"
        echo -e "${GREEN}✓${NC} Synced: $desc"
        ((UPGRADED_COUNT++))
    else
        echo -e "${YELLOW}⚠${NC} Source not found: $desc"
    fi
}

# Function to sync a single file from framework to project
sync_file() {
    local src_file="$1"
    local dest_file="$2"
    local desc="$3"

    if [ -f "$src_file" ]; then
        # Backup existing if present
        if [ -f "$dest_file" ]; then
            backup_if_exists "$dest_file" "$(dirname "${dest_file#$CLAUDE_DIR/}")" && \
                echo -e "  ${YELLOW}↳${NC} Backed up existing $desc"
        fi

        # Create parent directory and copy
        mkdir -p "$(dirname "$dest_file")"
        cp "$src_file" "$dest_file"
        echo -e "${GREEN}✓${NC} Synced: $desc"
        ((UPGRADED_COUNT++))
    else
        echo -e "${YELLOW}⚠${NC} Source not found: $desc"
    fi
}

# Step 1: Sync all framework directories
echo -e "${BLUE}Step 1: Syncing framework directories...${NC}"
echo ""

sync_directory "$FRAMEWORK_DIR/skills" "$CLAUDE_DIR/skills" "skills/"
sync_directory "$FRAMEWORK_DIR/templates" "$CLAUDE_DIR/templates" "templates/"
sync_directory "$FRAMEWORK_DIR/reference" "$CLAUDE_DIR/reference" "reference/"
sync_directory "$FRAMEWORK_DIR/agents" "$CLAUDE_DIR/agents" "agents/"
sync_directory "$FRAMEWORK_DIR/scripts" "$CLAUDE_DIR/scripts" "scripts/"
sync_directory "$FRAMEWORK_DIR/hooks" "$CLAUDE_DIR/hooks" "hooks/"

# Step 2: Sync CLAUDE.md
echo ""
echo -e "${BLUE}Step 2: Syncing CLAUDE.md...${NC}"
sync_file "$FRAMEWORK_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"

# Step 3: Update project config if it exists
echo ""
echo -e "${BLUE}Step 3: Updating project configuration...${NC}"
if [ -f "$PROJECT_DIR/docs/tasks/config.json" ]; then
    backup_if_exists "$PROJECT_DIR/docs/tasks/config.json" "docs/tasks" && \
        echo -e "  ${YELLOW}↳${NC} Backed up existing docs/tasks/config.json"
    cp "$FRAMEWORK_DIR/templates/config.json" "$PROJECT_DIR/docs/tasks/config.json"
    echo -e "${GREEN}✓${NC} Updated: docs/tasks/config.json"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} No docs/tasks/config.json found (will be created on first use)"
fi

# Step 4: Make scripts executable
echo ""
echo -e "${BLUE}Step 4: Setting permissions...${NC}"
find "$CLAUDE_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$CLAUDE_DIR/hooks" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
echo -e "${GREEN}✓${NC} Made scripts executable"

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Upgrade Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Components upgraded: $UPGRADED_COUNT"
echo -e "  ${YELLOW}↳${NC} Files backed up: $BACKED_UP_COUNT"
echo ""
echo -e "${CYAN}Backup Location:${NC}"
echo "  $BACKUP_DIR"
echo ""
echo -e "${CYAN}What's New in v$UPGRADE_VERSION:${NC}"
echo ""
echo -e "  ${GREEN}Process Execution Modes${NC}"
echo -e "    Control how strictly flow steps are enforced."
echo -e "    - normal:   Only ⛔ CRITICAL steps enforced (default)"
echo -e "    - strict:   ⛔ CRITICAL + 🔒 REQUIRED steps enforced"
echo -e "    - paranoid: All marked steps enforced"
echo ""
echo -e "  ${GREEN}Step Enforcement Markers${NC}"
echo -e "    Flow files now tag steps with enforcement levels:"
echo -e "    - ⛔ CRITICAL:    Always enforced, cannot be skipped"
echo -e "    - 🔒 REQUIRED:    Enforced in strict/paranoid modes"
echo -e "    - 📋 RECOMMENDED: Enforced only in paranoid mode"
echo ""
echo -e "  ${GREEN}Pre-Work Checklist (CLAUDE.md)${NC}"
echo -e "    New checklist in CLAUDE.md ensures all gates pass before code:"
echo -e "    - [ ] Session file exists"
echo -e "    - [ ] Task ID assigned"
echo -e "    - [ ] Task locked"
echo -e "    - [ ] Skill invoked"
echo -e "    - [ ] Agent summary loaded"
echo ""
echo -e "  ${GREEN}New Commands${NC}"
echo -e "    /reflect strict on       Enable strict mode"
echo -e "    /reflect strict off      Return to normal mode"
echo -e "    /reflect strict paranoid Enable maximum enforcement"
echo -e "    /reflect config          Now shows enforcement levels"
echo ""
echo -e "  ${GREEN}Path Fixes${NC}"
echo -e "    - Scripts now reference .claude/scripts/helpers/"
echo -e "    - Agent summaries now reference .claude/agents/summaries/"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo ""
echo -e "  1. Navigate to your project:"
echo -e "     ${YELLOW}cd $PROJECT_DIR${NC}"
echo ""
echo -e "  2. Check configuration:"
echo -e "     ${GREEN}/reflect config${NC}"
echo ""
echo -e "  3. Try the new strict mode:"
echo -e "     ${GREEN}/reflect strict on${NC}"
echo ""
echo -e "  4. Resume a task to see the new enforcement:"
echo -e "     ${GREEN}/reflect resume T###${NC}"
echo ""
echo -e "${CYAN}To Restore from Backup:${NC}"
echo "  If something went wrong, restore from:"
echo "  $BACKUP_DIR"
echo ""
echo -e "${GREEN}Happy coding with Claude Forge v$UPGRADE_VERSION!${NC}"
echo ""
