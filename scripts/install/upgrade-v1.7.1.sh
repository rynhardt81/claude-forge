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
    echo -e "${GREEN}Already at version $UPGRADE_VERSION. No upgrade needed.${NC}"
    exit 0
fi

# Warn if below minimum version
if [ "$CURRENT_VERSION" != "$MIN_VERSION" ] && [ "$CURRENT_VERSION" != "pre-1.7" ]; then
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

# Show what will be upgraded
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Upgrade Plan: ${YELLOW}$CURRENT_VERSION${NC} ${CYAN}→${NC} ${GREEN}$UPGRADE_VERSION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Files to update:${NC}"
echo -e "  • ${YELLOW}skills/reflect/flows/resume.md${NC} - Process enforcement + path fixes"
echo -e "  • ${YELLOW}skills/reflect/flows/config.md${NC} - New /reflect strict commands"
echo -e "  • ${YELLOW}templates/config.json${NC} - processExecution configuration"
echo -e "  • ${YELLOW}CLAUDE.md${NC} - Version bump"
echo ""
echo -e "${BLUE}New features:${NC}"
echo -e "  • ${GREEN}Process Execution Modes${NC} - normal, strict, paranoid"
echo -e "  • ${GREEN}Step Enforcement Markers${NC} - ⛔ CRITICAL, 🔒 REQUIRED, 📋 RECOMMENDED"
echo -e "  • ${GREEN}Pre-Presentation Checklist${NC} - Verify steps before task presentation"
echo -e "  • ${GREEN}/reflect strict${NC} - Commands to change enforcement mode"
echo ""
echo -e "${BLUE}Bug fixes:${NC}"
echo -e "  • ${GREEN}Path corrections${NC} - Scripts now reference .claude/scripts/helpers/"
echo -e "  • ${GREEN}Agent summaries path${NC} - Now correctly references .claude/agents/summaries/"
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
SKIPPED_COUNT=0

# Function to copy file with backup
copy_with_backup() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [ -f "$dest" ]; then
        # Create backup
        cp "$dest" "${dest}.bak"
        cp "$src" "$dest"
        echo -e "${GREEN}✓${NC} Updated: $desc (backup: ${dest}.bak)"
    else
        # Ensure parent directory exists
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo -e "${GREEN}✓${NC} Added: $desc"
    fi
    ((UPGRADED_COUNT++))
}

# Step 1: Update resume.md flow
echo -e "${BLUE}Step 1: Updating resume.md flow...${NC}"
if [ -f "$FRAMEWORK_DIR/skills/reflect/flows/resume.md" ]; then
    mkdir -p "$CLAUDE_DIR/skills/reflect/flows"
    copy_with_backup \
        "$FRAMEWORK_DIR/skills/reflect/flows/resume.md" \
        "$CLAUDE_DIR/skills/reflect/flows/resume.md" \
        "skills/reflect/flows/resume.md"
else
    echo -e "${YELLOW}⚠${NC} resume.md not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 2: Update config.md flow
echo ""
echo -e "${BLUE}Step 2: Updating config.md flow...${NC}"
if [ -f "$FRAMEWORK_DIR/skills/reflect/flows/config.md" ]; then
    mkdir -p "$CLAUDE_DIR/skills/reflect/flows"
    copy_with_backup \
        "$FRAMEWORK_DIR/skills/reflect/flows/config.md" \
        "$CLAUDE_DIR/skills/reflect/flows/config.md" \
        "skills/reflect/flows/config.md"
else
    echo -e "${YELLOW}⚠${NC} config.md not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 3: Update config.json template
echo ""
echo -e "${BLUE}Step 3: Updating config.json template...${NC}"
if [ -f "$FRAMEWORK_DIR/templates/config.json" ]; then
    mkdir -p "$CLAUDE_DIR/templates"
    copy_with_backup \
        "$FRAMEWORK_DIR/templates/config.json" \
        "$CLAUDE_DIR/templates/config.json" \
        "templates/config.json"

    # Also update docs/tasks/config.json if it exists (deployed project config)
    if [ -f "$PROJECT_DIR/docs/tasks/config.json" ]; then
        copy_with_backup \
            "$FRAMEWORK_DIR/templates/config.json" \
            "$PROJECT_DIR/docs/tasks/config.json" \
            "docs/tasks/config.json"
    fi
else
    echo -e "${YELLOW}⚠${NC} config.json template not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 4: Update CLAUDE.md
echo ""
echo -e "${BLUE}Step 4: Updating CLAUDE.md...${NC}"
if [ -f "$FRAMEWORK_DIR/CLAUDE.md" ]; then
    copy_with_backup \
        "$FRAMEWORK_DIR/CLAUDE.md" \
        "$CLAUDE_DIR/CLAUDE.md" \
        "CLAUDE.md"
else
    echo -e "${YELLOW}⚠${NC} CLAUDE.md not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 5: Sync install scripts (so future upgrades are available)
echo ""
echo -e "${BLUE}Step 5: Syncing install scripts...${NC}"
if [ -d "$FRAMEWORK_DIR/scripts/install" ]; then
    mkdir -p "$CLAUDE_DIR/scripts/install"
    for file in "$FRAMEWORK_DIR"/scripts/install/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$CLAUDE_DIR/scripts/install/$filename"
        fi
    done
    echo -e "${GREEN}✓${NC} Synced install scripts"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Install scripts not found in source"
    ((SKIPPED_COUNT++))
fi

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Upgrade Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Components upgraded: $UPGRADED_COUNT"
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} Components skipped: $SKIPPED_COUNT"
fi
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
echo -e "  ${GREEN}Pre-Presentation Checklist${NC}"
echo -e "    /reflect resume T### now has a checklist before task presentation:"
echo -e "    - [ ] Session file created"
echo -e "    - [ ] Task locked in registry"
echo -e "    - [ ] Project memory loaded"
echo -e "    - [ ] Agent summary loaded"
echo ""
echo -e "  ${GREEN}New Commands${NC}"
echo -e "    /reflect strict on       Enable strict mode"
echo -e "    /reflect strict off      Return to normal mode"
echo -e "    /reflect strict paranoid Enable maximum enforcement"
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
echo -e "  2. Try the new strict mode:"
echo -e "     ${GREEN}/reflect strict on${NC}"
echo ""
echo -e "  3. Resume a task to see the new checklist:"
echo -e "     ${GREEN}/reflect resume T###${NC}"
echo ""
echo -e "${CYAN}Backup Files:${NC}"
echo "  Updated files have .bak backups in their original locations."
echo "  You can remove these once you've verified the upgrade."
echo ""
echo -e "${GREEN}Happy coding with Claude Forge v$UPGRADE_VERSION!${NC}"
echo ""
