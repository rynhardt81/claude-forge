#!/bin/bash
#
# Claude Forge Feature Add-on Script
#
# This script adds new features to an existing Claude Forge installation.
# Run this from the claude-forge directory to add features to a migrated project.
#
# Usage:
#   ./scripts/add-feature.sh                     # Interactive mode - show available features
#   ./scripts/add-feature.sh /path/to/project    # Specify project, then choose feature
#   ./scripts/add-feature.sh /path/to/project project-memory  # Add specific feature
#
# Available features:
#   project-memory  - Categorical memory system (bugs, decisions, patterns, key-facts)
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
echo "║           Claude Forge Feature Add-on Script                   ║"
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

# Available features
declare -A FEATURES
FEATURES["project-memory"]="Categorical memory system (bugs, decisions, patterns, key-facts)"

show_features() {
    echo -e "${CYAN}Available Features:${NC}"
    echo ""
    local i=1
    for feature in "${!FEATURES[@]}"; do
        echo -e "  ${GREEN}$i.${NC} ${YELLOW}$feature${NC}"
        echo -e "     ${FEATURES[$feature]}"
        echo ""
        ((i++))
    done
}

# Get project directory
PROJECT_DIR=""
FEATURE=""

if [ -n "$1" ]; then
    PROJECT_DIR="$1"
fi

if [ -n "$2" ]; then
    FEATURE="$2"
fi

# If no project directory, prompt for it
if [ -z "$PROJECT_DIR" ]; then
    echo -e "${BLUE}Enter the path to your project directory:${NC}"
    echo -e "${YELLOW}(This should be a project that already has Claude Forge installed)${NC}"
    read -r -p "> " PROJECT_DIR
fi

# Expand ~ to home directory
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

# Convert to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Directory does not exist: $PROJECT_DIR${NC}"
    exit 1
}

echo -e "${GREEN}✓${NC} Project directory: $PROJECT_DIR"

# Verify Claude Forge is installed
if [ ! -d "$PROJECT_DIR/.claude" ]; then
    echo -e "${RED}Error: Claude Forge not found in project.${NC}"
    echo "Run migrate.sh first to install Claude Forge."
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Forge installation found"
echo ""

# If no feature specified, show menu
if [ -z "$FEATURE" ]; then
    show_features
    echo -e "${BLUE}Enter feature name or number:${NC}"
    read -r -p "> " selection

    # Handle numeric selection
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        i=1
        for feature in "${!FEATURES[@]}"; do
            if [ "$i" -eq "$selection" ]; then
                FEATURE="$feature"
                break
            fi
            ((i++))
        done
    else
        FEATURE="$selection"
    fi
fi

# Validate feature
if [ -z "${FEATURES[$FEATURE]}" ]; then
    echo -e "${RED}Error: Unknown feature '$FEATURE'${NC}"
    echo ""
    show_features
    exit 1
fi

echo -e "${GREEN}✓${NC} Selected feature: ${YELLOW}$FEATURE${NC}"
echo ""

# Feature installation functions
install_project_memory() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Installing: Project Memory${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local changes_made=0

    # Step 1: Create docs/project-memory/ structure
    echo -e "${BLUE}Step 1: Creating project memory structure...${NC}"

    if [ -d "$PROJECT_DIR/docs/project-memory" ]; then
        echo -e "${YELLOW}⚠${NC} docs/project-memory/ already exists"
        read -r -p "   Overwrite template files? [y/N] " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}✓${NC} Keeping existing project memory files"
        else
            copy_templates=true
        fi
    else
        mkdir -p "$PROJECT_DIR/docs/project-memory"
        copy_templates=true
        echo -e "${GREEN}✓${NC} Created docs/project-memory/"
    fi

    if [ "$copy_templates" = true ]; then
        if [ -d "$FRAMEWORK_DIR/templates/project-memory" ]; then
            cp "$FRAMEWORK_DIR/templates/project-memory/bugs.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
            cp "$FRAMEWORK_DIR/templates/project-memory/decisions.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
            cp "$FRAMEWORK_DIR/templates/project-memory/key-facts.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
            cp "$FRAMEWORK_DIR/templates/project-memory/patterns.md" "$PROJECT_DIR/docs/project-memory/" 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Copied template files"
            changes_made=1
        else
            echo -e "${RED}✗${NC} Templates not found in framework"
        fi
    fi

    # Step 2: Copy /remember skill
    echo ""
    echo -e "${BLUE}Step 2: Installing /remember skill...${NC}"

    if [ -d "$FRAMEWORK_DIR/skills/remember" ]; then
        if [ -d "$PROJECT_DIR/.claude/skills/remember" ]; then
            echo -e "${YELLOW}⚠${NC} /remember skill already exists, updating..."
        fi
        mkdir -p "$PROJECT_DIR/.claude/skills/remember"
        cp -r "$FRAMEWORK_DIR/skills/remember/"* "$PROJECT_DIR/.claude/skills/remember/"
        echo -e "${GREEN}✓${NC} Installed /remember skill"
        changes_made=1
    else
        echo -e "${YELLOW}⚠${NC} /remember skill not found in framework"
    fi

    # Step 3: Update reference documentation
    echo ""
    echo -e "${BLUE}Step 3: Installing reference documentation...${NC}"

    if [ -f "$FRAMEWORK_DIR/reference/16-project-memory.md" ]; then
        mkdir -p "$PROJECT_DIR/.claude/reference"
        cp "$FRAMEWORK_DIR/reference/16-project-memory.md" "$PROJECT_DIR/.claude/reference/"
        echo -e "${GREEN}✓${NC} Installed reference/16-project-memory.md"
        changes_made=1
    else
        echo -e "${YELLOW}⚠${NC} Reference documentation not found"
    fi

    # Step 4: Update /fix-bug skill (if exists)
    echo ""
    echo -e "${BLUE}Step 4: Updating /fix-bug skill...${NC}"

    if [ -d "$FRAMEWORK_DIR/skills/fix-bug" ]; then
        if [ -d "$PROJECT_DIR/.claude/skills/fix-bug" ]; then
            cp -r "$FRAMEWORK_DIR/skills/fix-bug/"* "$PROJECT_DIR/.claude/skills/fix-bug/"
            echo -e "${GREEN}✓${NC} Updated /fix-bug skill with memory phases"
            changes_made=1
        else
            mkdir -p "$PROJECT_DIR/.claude/skills/fix-bug"
            cp -r "$FRAMEWORK_DIR/skills/fix-bug/"* "$PROJECT_DIR/.claude/skills/fix-bug/"
            echo -e "${GREEN}✓${NC} Installed /fix-bug skill"
            changes_made=1
        fi
    fi

    # Step 5: Update /reflect skill (if exists)
    echo ""
    echo -e "${BLUE}Step 5: Updating /reflect skill...${NC}"

    if [ -d "$FRAMEWORK_DIR/skills/reflect" ]; then
        if [ -d "$PROJECT_DIR/.claude/skills/reflect" ]; then
            cp -r "$FRAMEWORK_DIR/skills/reflect/"* "$PROJECT_DIR/.claude/skills/reflect/"
            echo -e "${GREEN}✓${NC} Updated /reflect skill with memory loading"
            changes_made=1
        else
            mkdir -p "$PROJECT_DIR/.claude/skills/reflect"
            cp -r "$FRAMEWORK_DIR/skills/reflect/"* "$PROJECT_DIR/.claude/skills/reflect/"
            echo -e "${GREEN}✓${NC} Installed /reflect skill"
            changes_made=1
        fi
    fi

    # Step 6: Update agents (if they exist)
    echo ""
    echo -e "${BLUE}Step 6: Updating agent definitions...${NC}"

    local agents_updated=0
    for agent in architect dev tea; do
        if [ -f "$FRAMEWORK_DIR/.claude/agents/$agent.mdc" ]; then
            if [ -d "$PROJECT_DIR/.claude/agents" ]; then
                cp "$FRAMEWORK_DIR/.claude/agents/$agent.mdc" "$PROJECT_DIR/.claude/agents/"
                ((agents_updated++))
            fi
        fi
    done

    if [ $agents_updated -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Updated $agents_updated agent definition(s)"
        changes_made=1
    else
        echo -e "${YELLOW}⚠${NC} No agents to update (agents directory not found)"
    fi

    # Step 7: Update CLAUDE.md hint
    echo ""
    echo -e "${BLUE}Step 7: Checking CLAUDE.md...${NC}"

    if [ -f "$PROJECT_DIR/.claude/CLAUDE.md" ]; then
        if grep -q "docs/project-memory/" "$PROJECT_DIR/.claude/CLAUDE.md"; then
            echo -e "${GREEN}✓${NC} CLAUDE.md already references project memory"
        else
            echo -e "${YELLOW}⚠${NC} CLAUDE.md may need manual update"
            echo "   Add 'docs/project-memory/' to Key Locations section"
            echo "   Add '/remember' to Skill Routing section"
        fi
    fi

    # Summary
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ $changes_made -gt 0 ]; then
        echo -e "${GREEN}Project Memory feature installed successfully!${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}What was installed:${NC}"
        echo "  - docs/project-memory/ with template files"
        echo "  - /remember skill for adding memories"
        echo "  - Updated /fix-bug with memory phases"
        echo "  - Updated /reflect with memory loading"
        echo "  - Reference documentation"
        echo ""
        echo -e "${CYAN}Usage:${NC}"
        echo "  /remember bug \"Bug title\"      - Record a bug pattern"
        echo "  /remember decision \"Title\"     - Record a technical decision"
        echo "  /remember fact \"label: value\"  - Record a key fact"
        echo "  /remember pattern \"Title\"      - Record a code pattern"
        echo "  /remember search \"query\"       - Search memories"
        echo ""
        echo -e "${CYAN}The system will:${NC}"
        echo "  - Auto-load relevant memories during /reflect resume"
        echo "  - Check bugs.md before fixing bugs (/fix-bug)"
        echo "  - Offer to save bug patterns after fixes"
    else
        echo -e "${YELLOW}No changes were made.${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

# Execute feature installation
case "$FEATURE" in
    "project-memory")
        install_project_memory
        ;;
    *)
        echo -e "${RED}Error: Feature '$FEATURE' installation not implemented${NC}"
        exit 1
        ;;
esac

echo ""
