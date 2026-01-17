#!/bin/bash
#
# Claude Forge Upgrade Script - Version 1.7
#
# This script upgrades an existing Claude Forge installation to v1.7.
# Run this if your project has an older version of Claude Forge installed.
#
# Usage:
#   ./scripts/install/upgrade-v1.7.sh                    # Interactive mode
#   ./scripts/install/upgrade-v1.7.sh /path/to/project   # Specify project path
#
# What's new in v1.7:
#   - Modularized reflect skill (SKILL.md split into flows/ and dispatch/)
#   - Agent summaries for token-efficient delegation (agents/summaries/)
#   - Python helper scripts integrated into skill flows (scripts/helpers/)
#   - Task delegation templates (reference/16-task-delegation-templates.md)
#   - Fixed task status transitions (in_progress on resume, completion steps)
#
# Note: Future versions will have their own upgrade scripts (e.g., upgrade-v1.8.sh)
#       Apply upgrade scripts sequentially if multiple versions behind.
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
UPGRADE_VERSION="1.7"

# Get the directory where this script is located (claude-forge root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Claude Forge Framework Upgrade Script                ║"
echo "║                      Version $UPGRADE_VERSION                              ║"
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

# Verify it's a Claude Forge installation
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -d "$CLAUDE_DIR/skills" ]; then
    echo -e "${YELLOW}Warning: This doesn't appear to be a standard Claude Forge installation.${NC}"
    read -r -p "Continue anyway? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Upgrade cancelled.${NC}"
        exit 0
    fi
fi

# Show what will be upgraded
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Upgrade Plan: ${YELLOW}$CURRENT_VERSION${NC} ${CYAN}→${NC} ${GREEN}$UPGRADE_VERSION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}New files to add:${NC}"
echo -e "  • ${GREEN}agents/summaries/${NC} - Agent summary files for token-efficient delegation"
echo -e "  • ${GREEN}scripts/helpers/${NC} - Python helper scripts for task analysis"
echo -e "  • ${GREEN}skills/reflect/flows/${NC} - Modular command flows (resume, status, config, etc.)"
echo -e "  • ${GREEN}skills/reflect/dispatch/${NC} - Parallel execution flows"
echo -e "  • ${GREEN}reference/16-task-delegation-templates.md${NC} - Task delegation templates"
echo ""
echo -e "${BLUE}Files to update:${NC}"
echo -e "  • ${YELLOW}skills/reflect/SKILL.md${NC} - Now a routing hub (~200 lines, was ~1750)"
echo -e "  • ${YELLOW}scripts/README.md${NC} - Updated documentation"
echo -e "  • ${YELLOW}CLAUDE.md${NC} - Updated framework instructions"
echo ""
echo -e "${BLUE}Preserved (not modified):${NC}"
echo -e "  • Your project's docs/tasks/ and docs/epics/"
echo -e "  • Your project's docs/project-memory/"
echo -e "  • Your session files in .claude/memories/"
echo -e "  • Any custom agents you've created"
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

# Function to copy directory
copy_directory() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -r "$src"/* "$dest"/ 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Synced: $desc"
        ((UPGRADED_COUNT++))
    else
        echo -e "${YELLOW}⚠${NC} Source not found: $src"
        ((SKIPPED_COUNT++))
    fi
}

# Step 1: Add agent summaries
echo -e "${BLUE}Step 1: Adding agent summaries...${NC}"
if [ -d "$FRAMEWORK_DIR/agents/summaries" ]; then
    mkdir -p "$CLAUDE_DIR/agents/summaries"
    for file in "$FRAMEWORK_DIR"/agents/summaries/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$CLAUDE_DIR/agents/summaries/$filename"
        fi
    done
    echo -e "${GREEN}✓${NC} Added agent summaries ($(ls -1 "$FRAMEWORK_DIR/agents/summaries"/*.md 2>/dev/null | wc -l | tr -d ' ') files)"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Agent summaries not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 2: Add helper scripts
echo ""
echo -e "${BLUE}Step 2: Adding helper scripts...${NC}"
if [ -d "$FRAMEWORK_DIR/scripts/helpers" ]; then
    mkdir -p "$CLAUDE_DIR/scripts/helpers"
    for file in "$FRAMEWORK_DIR"/scripts/helpers/*.py; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$CLAUDE_DIR/scripts/helpers/$filename"
        fi
    done
    echo -e "${GREEN}✓${NC} Added helper scripts ($(ls -1 "$FRAMEWORK_DIR/scripts/helpers"/*.py 2>/dev/null | wc -l | tr -d ' ') files)"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Helper scripts not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 3: Add task delegation templates
echo ""
echo -e "${BLUE}Step 3: Adding task delegation templates...${NC}"
if [ -f "$FRAMEWORK_DIR/reference/16-task-delegation-templates.md" ]; then
    mkdir -p "$CLAUDE_DIR/reference"
    copy_with_backup \
        "$FRAMEWORK_DIR/reference/16-task-delegation-templates.md" \
        "$CLAUDE_DIR/reference/16-task-delegation-templates.md" \
        "reference/16-task-delegation-templates.md"
else
    echo -e "${YELLOW}⚠${NC} Task delegation templates not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 4: Update reflect skill (routing hub)
echo ""
echo -e "${BLUE}Step 4: Updating reflect skill (routing hub)...${NC}"
if [ -f "$FRAMEWORK_DIR/skills/reflect/SKILL.md" ]; then
    mkdir -p "$CLAUDE_DIR/skills/reflect"
    copy_with_backup \
        "$FRAMEWORK_DIR/skills/reflect/SKILL.md" \
        "$CLAUDE_DIR/skills/reflect/SKILL.md" \
        "skills/reflect/SKILL.md"
else
    echo -e "${YELLOW}⚠${NC} Reflect skill not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 5: Add reflect flows
echo ""
echo -e "${BLUE}Step 5: Adding reflect flow files...${NC}"
if [ -d "$FRAMEWORK_DIR/skills/reflect/flows" ]; then
    mkdir -p "$CLAUDE_DIR/skills/reflect/flows"
    for file in "$FRAMEWORK_DIR"/skills/reflect/flows/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$CLAUDE_DIR/skills/reflect/flows/$filename"
        fi
    done
    echo -e "${GREEN}✓${NC} Added reflect flows ($(ls -1 "$FRAMEWORK_DIR/skills/reflect/flows"/*.md 2>/dev/null | wc -l | tr -d ' ') files)"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Reflect flows not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 6: Add reflect dispatch files
echo ""
echo -e "${BLUE}Step 6: Adding reflect dispatch files...${NC}"
if [ -d "$FRAMEWORK_DIR/skills/reflect/dispatch" ]; then
    mkdir -p "$CLAUDE_DIR/skills/reflect/dispatch"
    for file in "$FRAMEWORK_DIR"/skills/reflect/dispatch/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$CLAUDE_DIR/skills/reflect/dispatch/$filename"
        fi
    done
    echo -e "${GREEN}✓${NC} Added reflect dispatch files ($(ls -1 "$FRAMEWORK_DIR/skills/reflect/dispatch"/*.md 2>/dev/null | wc -l | tr -d ' ') files)"
    ((UPGRADED_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Reflect dispatch files not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 7: Update scripts README
echo ""
echo -e "${BLUE}Step 7: Updating scripts documentation...${NC}"
if [ -f "$FRAMEWORK_DIR/scripts/README.md" ]; then
    mkdir -p "$CLAUDE_DIR/scripts"
    copy_with_backup \
        "$FRAMEWORK_DIR/scripts/README.md" \
        "$CLAUDE_DIR/scripts/README.md" \
        "scripts/README.md"
else
    echo -e "${YELLOW}⚠${NC} Scripts README not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 8: Update CLAUDE.md
echo ""
echo -e "${BLUE}Step 8: Updating CLAUDE.md...${NC}"
if [ -f "$FRAMEWORK_DIR/CLAUDE.md" ]; then
    copy_with_backup \
        "$FRAMEWORK_DIR/CLAUDE.md" \
        "$CLAUDE_DIR/CLAUDE.md" \
        "CLAUDE.md"
else
    echo -e "${YELLOW}⚠${NC} CLAUDE.md not found in source"
    ((SKIPPED_COUNT++))
fi

# Step 9: Sync install scripts
echo ""
echo -e "${BLUE}Step 9: Syncing install scripts...${NC}"
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
echo -e "  ${GREEN}Modularized Reflect Skill${NC}"
echo -e "    SKILL.md refactored from ~1750 lines to ~200 line routing hub."
echo -e "    Command-specific flows loaded on-demand for token efficiency."
echo -e "    - flows/resume.md      - Session resume logic"
echo -e "    - flows/status.md      - Task/epic status display"
echo -e "    - flows/config.md      - Dispatch/intent configuration"
echo -e "    - dispatch/*.md        - Parallel execution flows"
echo -e "    Location: $CLAUDE_DIR/skills/reflect/"
echo ""
echo -e "  ${GREEN}Agent Summaries${NC}"
echo -e "    Token-efficient agent summaries for delegation decisions."
echo -e "    Location: $CLAUDE_DIR/agents/summaries/"
echo ""
echo -e "  ${GREEN}Helper Scripts${NC}"
echo -e "    Python scripts for automated task analysis and agent detection."
echo -e "    - detect_agent.py    - Recommends appropriate agent for a task"
echo -e "    - dispatch_analysis.py - Analyzes tasks for parallel execution"
echo -e "    - prepare_task_prompt.py - Prepares context-rich prompts"
echo -e "    Location: $CLAUDE_DIR/scripts/helpers/"
echo ""
echo -e "  ${GREEN}Task Status Fixes${NC}"
echo -e "    - Tasks now marked in_progress immediately on resume"
echo -e "    - Explicit completion steps ensure tasks are marked completed"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo ""
echo -e "  1. Navigate to your project:"
echo -e "     ${YELLOW}cd $PROJECT_DIR${NC}"
echo ""
echo -e "  2. Start Claude Code and use the enhanced features:"
echo -e "     ${GREEN}/reflect resume${NC} - Now shows agent recommendations"
echo ""
echo -e "${CYAN}Backup Files:${NC}"
echo "  Updated files have .bak backups in their original locations."
echo "  You can remove these once you've verified the upgrade."
echo ""
echo -e "${GREEN}Happy coding with Claude Forge v$UPGRADE_VERSION!${NC}"
echo ""
