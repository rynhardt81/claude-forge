#!/bin/bash
#
# Add Project Memory Feature to Existing Claude Forge Installation
#
# This script adds the project memory feature (bugs, decisions, patterns, key-facts)
# to a project that already has Claude Forge installed.
#
# Usage:
#   ./scripts/add-project-memory.sh                    # Interactive mode
#   ./scripts/add-project-memory.sh /path/to/project   # Specify project path
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

# Backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Add Project Memory Feature                           ║"
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

# Backup function
backup_if_exists() {
    local src="$1"
    local backup_dir="$PROJECT_DIR/.claude/backups/$BACKUP_TIMESTAMP"

    if [ -e "$src" ]; then
        mkdir -p "$backup_dir"
        local relative_path="${src#$PROJECT_DIR/}"
        local backup_path="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        cp -r "$src" "$backup_path"
        return 0  # backup was created
    fi
    return 1  # nothing to backup
}

# Confirm
echo -e "${CYAN}This will install the Project Memory feature:${NC}"
echo "  - docs/project-memory/ with template files"
echo "  - /remember skill for adding memories"
echo "  - Updated /fix-bug with memory phases"
echo "  - Updated /reflect with memory loading"
echo "  - Reference documentation"
echo ""
echo -e "${YELLOW}Existing files will be backed up to .claude/backups/${NC}"
echo ""
read -r -p "Proceed? [Y/n] " response
if [[ "$response" =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

echo ""
changes_made=0
backups_created=0

# Step 1: Create docs/project-memory/ structure
echo -e "${BLUE}Step 1: Creating project memory structure...${NC}"

copy_templates=false
if [ -d "$PROJECT_DIR/docs/project-memory" ]; then
    echo -e "${YELLOW}⚠${NC} docs/project-memory/ already exists"
    read -r -p "   Overwrite template files? [y/N] " overwrite
    if [[ "$overwrite" =~ ^[Yy]$ ]]; then
        if backup_if_exists "$PROJECT_DIR/docs/project-memory"; then
            echo -e "${GREEN}✓${NC} Backed up existing project-memory/"
            ((backups_created++))
        fi
        copy_templates=true
    else
        echo -e "${GREEN}✓${NC} Keeping existing project memory files"
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
        if backup_if_exists "$PROJECT_DIR/.claude/skills/remember"; then
            echo -e "${GREEN}✓${NC} Backed up existing /remember skill"
            ((backups_created++))
        fi
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
    if backup_if_exists "$PROJECT_DIR/.claude/reference/16-project-memory.md"; then
        echo -e "${GREEN}✓${NC} Backed up existing reference doc"
        ((backups_created++))
    fi
    mkdir -p "$PROJECT_DIR/.claude/reference"
    cp "$FRAMEWORK_DIR/reference/16-project-memory.md" "$PROJECT_DIR/.claude/reference/"
    echo -e "${GREEN}✓${NC} Installed reference/16-project-memory.md"
    changes_made=1
else
    echo -e "${YELLOW}⚠${NC} Reference documentation not found"
fi

# Step 4: Update /fix-bug skill
echo ""
echo -e "${BLUE}Step 4: Updating /fix-bug skill...${NC}"

if [ -d "$FRAMEWORK_DIR/skills/fix-bug" ]; then
    if [ -d "$PROJECT_DIR/.claude/skills/fix-bug" ]; then
        if backup_if_exists "$PROJECT_DIR/.claude/skills/fix-bug"; then
            echo -e "${GREEN}✓${NC} Backed up existing /fix-bug skill"
            ((backups_created++))
        fi
    fi
    mkdir -p "$PROJECT_DIR/.claude/skills/fix-bug"
    cp -r "$FRAMEWORK_DIR/skills/fix-bug/"* "$PROJECT_DIR/.claude/skills/fix-bug/"
    echo -e "${GREEN}✓${NC} Updated /fix-bug skill with memory phases"
    changes_made=1
fi

# Step 5: Update /reflect skill
echo ""
echo -e "${BLUE}Step 5: Updating /reflect skill...${NC}"

if [ -d "$FRAMEWORK_DIR/skills/reflect" ]; then
    if [ -d "$PROJECT_DIR/.claude/skills/reflect" ]; then
        if backup_if_exists "$PROJECT_DIR/.claude/skills/reflect"; then
            echo -e "${GREEN}✓${NC} Backed up existing /reflect skill"
            ((backups_created++))
        fi
    fi
    mkdir -p "$PROJECT_DIR/.claude/skills/reflect"
    cp -r "$FRAMEWORK_DIR/skills/reflect/"* "$PROJECT_DIR/.claude/skills/reflect/"
    echo -e "${GREEN}✓${NC} Updated /reflect skill with memory loading"
    changes_made=1
fi

# Step 6: Update agents
echo ""
echo -e "${BLUE}Step 6: Updating agent definitions...${NC}"

agents_updated=0
for agent in architect dev tea; do
    if [ -f "$FRAMEWORK_DIR/.claude/agents/$agent.mdc" ]; then
        if [ -d "$PROJECT_DIR/.claude/agents" ]; then
            if [ -f "$PROJECT_DIR/.claude/agents/$agent.mdc" ]; then
                if backup_if_exists "$PROJECT_DIR/.claude/agents/$agent.mdc"; then
                    ((backups_created++))
                fi
            fi
            cp "$FRAMEWORK_DIR/.claude/agents/$agent.mdc" "$PROJECT_DIR/.claude/agents/"
            ((agents_updated++))
        fi
    fi
done

if [ $agents_updated -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Updated $agents_updated agent definition(s)"
    if [ $backups_created -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Backed up existing agents"
    fi
    changes_made=1
else
    echo -e "${YELLOW}⚠${NC} No agents to update (agents directory not found)"
fi

# Step 7: Check CLAUDE.md
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

    if [ $backups_created -gt 0 ]; then
        echo -e "${CYAN}Backups:${NC}"
        echo "  Location: .claude/backups/$BACKUP_TIMESTAMP/"
        echo "  Files backed up: $backups_created"
        echo ""
    fi

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

echo ""
