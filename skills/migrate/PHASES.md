# Migration Phases - Detailed Instructions

This document provides step-by-step instructions for each phase of the `/migrate` skill.

**IMPORTANT:** Before running `/migrate`, the user must run the migration script:
- macOS/Linux: `./scripts/migrate.sh`
- Windows: `.\scripts\migrate.ps1`

The script handles backup and framework installation. The `/migrate` skill then handles content merging.

---

## Phase 0: Pre-Migration Check

### Purpose
Verify the migration script ran successfully and analyze the backup content.

### Steps

#### Step 0.1: Verify Prerequisites

```bash
# 1. Verify .claude_old/ exists (backup created by script)
if [ -d ".claude_old" ]; then
    echo "✅ .claude_old/ backup found"
else
    echo "❌ No .claude_old/ directory"
    echo "   Run the migration script first:"
    echo "   ./scripts/migrate.sh (macOS/Linux)"
    echo "   .\\scripts\\migrate.ps1 (Windows)"
    exit 1
fi

# 2. Verify .claude/ has framework installed
if [ -f ".claude/CLAUDE.md" ] && [ -d ".claude/skills" ]; then
    echo "✅ Claude Forge framework installed"
else
    echo "❌ Framework not found in .claude/"
    echo "   Run the migration script again"
    exit 1
fi
```

#### Step 0.2: Scan Directory Structure

Use these tools to understand existing content:

```
# Get full directory tree
Glob: .claude/**/*

# Check for key files
Read: .claude/CLAUDE.md (if exists)
Read: .claude/settings.local.json (if exists)
Read: .claude/memories/progress-notes.md (if exists)
```

#### Step 0.3: Categorize Content

For each file/directory found, assign a category:

| Pattern | Category | Action |
|---------|----------|--------|
| `memories/progress-notes.md` | Critical Memory | MERGE (append) |
| `memories/general.md` | Preferences | MERGE |
| `memories/sessions/**` | Session History | PRESERVE |
| `settings*.json` | Settings | MERGE |
| `docs/prd.md` | Project Doc | PRESERVE |
| `docs/tasks/registry.json` | Task State | PRESERVE |
| `docs/epics/**` | Task Files | PRESERVE |
| `reference/*.md` (with content) | Decisions | ANALYZE |
| `reference/*.template.md` | Template | REPLACE |
| `templates/**` | Templates | REPLACE |
| `agents/**` | Agents | REPLACE |
| `skills/**` (custom) | Custom Skills | PRESERVE |
| `security/**` | Security | MERGE |
| `CLAUDE.md` | Instructions | REPLACE |
| `*` (unknown) | Unknown | ASK USER |

#### Step 0.4: Generate Migration Plan

Create a structured plan:

```markdown
## Migration Plan for [Project Name]

### Critical: Will Preserve (no changes)
These files contain project-specific state that must not be lost:
- .claude/docs/prd.md
- .claude/docs/tasks/registry.json
- .claude/docs/epics/**

### Important: Will Merge (combine content)
These files have both old content and new framework content:
- .claude/memories/progress-notes.md
  - Action: Prepend marker, append old content to new
- .claude/memories/general.md
  - Action: Merge preferences, prefer old values
- .claude/settings.local.json
  - Action: Deep merge, prefer old values

### Standard: Will Replace (use framework)
These are framework files that should use current versions:
- .claude/CLAUDE.md
- .claude/templates/*
- .claude/agents/*

### Custom: Requires Decision
Unknown files that need user input:
- .claude/my-custom-file.md
```

#### Step 0.5: User Approval

Present plan and wait for confirmation before proceeding.

---

## Note: Backup and Installation Handled by Scripts

**Phases 1 (Backup) and 2 (Framework Installation) are handled by the migration scripts:**

- `scripts/migrate.sh` (macOS/Linux)
- `scripts/migrate.ps1` (Windows)

The scripts handle:
- Backing up `.claude/` to `.claude_old/`
- Copying the framework to `.claude/`
- Creating a restoration script
- Initializing session directories

**The `/migrate` skill starts at Phase 1: Content Migration** (after the scripts have run).

---

## Phase 1: Content Migration

### Purpose
Transfer and merge content from the backup into the new framework.

### Steps

#### Step 3.1: Migrate Progress Notes (Critical)

Progress notes are append-only and must be preserved completely.

```bash
if [ -f ".claude_old/memories/progress-notes.md" ]; then
    # Read old content
    OLD_CONTENT=$(cat .claude_old/memories/progress-notes.md)

    # Create migration marker
    MARKER="
---

## Pre-Migration History

> The following content was migrated from a previous Claude configuration
> Migration date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

"

    # Append to new file
    echo "$MARKER" >> .claude/memories/progress-notes.md
    echo "$OLD_CONTENT" >> .claude/memories/progress-notes.md

    echo "✅ Progress notes migrated"
fi
```

#### Step 3.2: Migrate General Preferences

```bash
if [ -f ".claude_old/memories/general.md" ]; then
    # Check if new file has content
    if [ -s ".claude/memories/general.md" ]; then
        # Merge: append old preferences with separator
        echo "" >> .claude/memories/general.md
        echo "---" >> .claude/memories/general.md
        echo "" >> .claude/memories/general.md
        echo "## Migrated Preferences" >> .claude/memories/general.md
        echo "" >> .claude/memories/general.md
        cat .claude_old/memories/general.md >> .claude/memories/general.md
    else
        # Copy directly if new file is empty
        cp .claude_old/memories/general.md .claude/memories/general.md
    fi

    echo "✅ General preferences migrated"
fi
```

#### Step 3.3: Migrate Session History

```bash
# Move completed sessions
if [ -d ".claude_old/memories/sessions/completed" ]; then
    cp -r .claude_old/memories/sessions/completed/* \
          .claude/memories/sessions/completed/ 2>/dev/null || true
    echo "✅ Session history migrated"
fi

# Move latest.md if exists
if [ -f ".claude_old/memories/sessions/latest.md" ]; then
    cp .claude_old/memories/sessions/latest.md \
       .claude/memories/sessions/latest.md
fi
```

#### Step 3.4: Migrate Settings

```bash
if [ -f ".claude_old/settings.local.json" ]; then
    # For JSON, we need to merge carefully
    # Simple approach: copy old file (user settings take priority)
    cp .claude_old/settings.local.json .claude/settings.local.json
    echo "✅ Local settings preserved"
fi
```

#### Step 3.5: Migrate Project Documentation

```bash
# Create docs directory in project root if needed
mkdir -p docs/tasks
mkdir -p docs/epics

# PRD
if [ -f ".claude_old/docs/prd.md" ]; then
    cp .claude_old/docs/prd.md docs/prd.md
    echo "✅ PRD preserved"
fi

# Task Registry
if [ -f ".claude_old/docs/tasks/registry.json" ]; then
    cp .claude_old/docs/tasks/registry.json docs/tasks/registry.json
    echo "✅ Task registry preserved"
elif [ -f ".claude_old/tasks/registry.json" ]; then
    cp .claude_old/tasks/registry.json docs/tasks/registry.json
    echo "✅ Task registry preserved (from alternate location)"
fi

# Epic/Task files
if [ -d ".claude_old/docs/epics" ]; then
    cp -r .claude_old/docs/epics/* docs/epics/ 2>/dev/null || true
    echo "✅ Epic/task files preserved"
fi
```

#### Step 3.6: Migrate Reference Documents

For each reference document with substantial content:

```python
# Pseudo-code for reference doc migration
for old_ref in glob(".claude_old/reference/*.md"):
    new_ref = corresponding_new_file(old_ref)

    old_content = read(old_ref)
    old_lines = count_non_template_lines(old_content)

    if old_lines > 100:
        # Substantial content - preserve it
        copy(old_ref, new_ref)
        log(f"Preserved {old_ref} (substantial content)")
    else:
        # Mostly template - use new version
        log(f"Using framework version for {new_ref}")
```

#### Step 3.7: Migrate Security Configuration

```bash
if [ -d ".claude_old/security" ]; then
    # Check for custom allowed commands
    if [ -f ".claude_old/security/allowed-commands.md" ]; then
        # Merge custom commands with framework defaults
        # Append custom section to framework file
        echo "" >> .claude/security/allowed-commands.md
        echo "## Project-Specific Commands (Migrated)" >> .claude/security/allowed-commands.md
        echo "" >> .claude/security/allowed-commands.md
        grep -v "^#" .claude_old/security/allowed-commands.md >> \
             .claude/security/allowed-commands.md 2>/dev/null || true
    fi
fi
```

#### Step 3.8: Handle Custom Skills

```bash
if [ -d ".claude_old/skills" ]; then
    # Check for custom skills (not in framework)
    for skill_dir in .claude_old/skills/*/; do
        skill_name=$(basename "$skill_dir")
        if [ ! -d ".claude/skills/$skill_name" ]; then
            # This is a custom skill - preserve it
            mkdir -p .claude/skills/custom
            cp -r "$skill_dir" .claude/skills/custom/
            echo "✅ Custom skill preserved: $skill_name"
        fi
    done
fi
```

---

## Phase 2: Project Analysis

### Purpose
Fill in gaps in documentation using brownfield analysis.

### Steps

#### Step 4.1: Assess Documentation State

```python
# Check what exists
has_prd = file_exists("docs/prd.md") and file_size("docs/prd.md") > 1000
has_adrs = count_files("docs/adr-*.md") > 0 or \
           file_size(".claude/reference/06-architecture-decisions.md") > 2000
has_tasks = file_exists("docs/tasks/registry.json") and \
            json_field_count("docs/tasks/registry.json", "tasks") > 0

# Determine what to create
needs_prd = not has_prd
needs_adrs = not has_adrs
needs_tasks = not has_tasks
```

#### Step 4.2: Invoke Selective Analysis

Based on what's missing, invoke appropriate phases from `/new-project --current`:

```
IF needs_prd:
    # Phase 1: Requirements Discovery
    - Analyze codebase structure
    - Identify existing features
    - Create PRD reflecting current state
    - Ask user about planned enhancements

IF needs_adrs:
    # Phase 2: Architecture Analysis
    - Detect tech stack from dependencies
    - Analyze code patterns
    - Create ADRs for key decisions

IF needs_tasks:
    # Phase 3: Task Planning
    - If PRD exists: Break into tasks
    - If no PRD: Analyze codebase for TODOs, FIXMEs
    - Create task registry
```

#### Step 4.3: Handle Unknown Project State

If task state is unclear:

```markdown
## Project State Unclear

I found code but couldn't determine:
- Which features are complete
- What's currently in progress
- What's planned vs done

Options:
1. **Analyze codebase** - I'll examine the code and infer what's done
2. **Fresh start** - Create new task breakdown from PRD
3. **Manual review** - Show me existing tasks, I'll update statuses
4. **Skip** - Keep whatever exists, don't change task state
```

#### Step 4.4: Validate Task Registry

If task registry exists, validate it:

```python
registry = load_json("docs/tasks/registry.json")

# Check for stale locks
for task in registry["tasks"]:
    if task["status"] == "in_progress":
        if task["locked_since"] and is_stale(task["locked_since"]):
            warn(f"Stale lock on {task['id']}")

# Check for orphaned dependencies
for task in registry["tasks"]:
    for dep in task.get("dependencies", []):
        if not task_exists(registry, dep):
            warn(f"Orphaned dependency: {task['id']} -> {dep}")

# Recalculate ready tasks
update_ready_statuses(registry)
```

---

## Phase 3: Verification & Cleanup

### Purpose
Confirm migration success and clean up.

### Steps

#### Step 5.1: Verify Framework Operation

```bash
# Test that key paths work
echo "Verifying framework structure..."

# Check CLAUDE.md is valid
if head -1 .claude/CLAUDE.md | grep -q "CLAUDE.md"; then
    echo "✅ CLAUDE.md valid"
else
    echo "⚠️ CLAUDE.md may have issues"
fi

# Check skills are accessible
SKILL_COUNT=$(ls -1 .claude/skills/*/SKILL.md 2>/dev/null | wc -l)
echo "✅ $SKILL_COUNT skills available"

# Check templates exist
TEMPLATE_COUNT=$(ls -1 .claude/templates/*.md 2>/dev/null | wc -l)
echo "✅ $TEMPLATE_COUNT templates available"

# Check memories structure
if [ -d ".claude/memories/sessions/active" ]; then
    echo "✅ Session directories ready"
fi
```

#### Step 5.2: Verify Content Migration

```bash
echo "Verifying content migration..."

# Check progress notes were migrated
if [ -f ".claude/memories/progress-notes.md" ]; then
    if grep -q "Pre-Migration History" .claude/memories/progress-notes.md; then
        echo "✅ Progress notes include migration history"
    fi
fi

# Check PRD if it should exist
if [ -f ".claude_old/docs/prd.md" ]; then
    if [ -f "docs/prd.md" ]; then
        echo "✅ PRD preserved"
    else
        echo "⚠️ PRD may not have migrated"
    fi
fi

# Check task registry
if [ -f ".claude_old/docs/tasks/registry.json" ] || \
   [ -f ".claude_old/tasks/registry.json" ]; then
    if [ -f "docs/tasks/registry.json" ]; then
        echo "✅ Task registry preserved"
    else
        echo "⚠️ Task registry may not have migrated"
    fi
fi
```

#### Step 5.3: Create Migration Report

Generate comprehensive report in project root.

#### Step 5.4: Cleanup Options

Present user with cleanup choices:
1. Keep `.claude_old/` (recommended initially)
2. Delete `.claude_old/`
3. Archive to `.claude_old.tar.gz`

```bash
# If user chooses to archive
if [ "$CLEANUP_CHOICE" == "archive" ]; then
    tar -czf .claude_old.tar.gz .claude_old/
    rm -rf .claude_old/
    echo "✅ Archived to .claude_old.tar.gz"
fi

# If user chooses to delete
if [ "$CLEANUP_CHOICE" == "delete" ]; then
    rm -rf .claude_old/
    rm -f .claude_restore.sh
    echo "✅ Cleanup complete"
fi
```

---

## Error Recovery

### Backup Failed

If backup fails at Phase 1:
```bash
# Nothing has changed yet
echo "Backup failed. No changes made."
echo "Check disk space and permissions."
exit 1
```

### Clone Failed

If clone fails at Phase 2:
```bash
# Restore from backup
mv .claude_old/ .claude/
rm -f .claude_restore.sh
echo "Clone failed. Original configuration restored."
exit 1
```

### Migration Failed

If migration fails at Phase 3:
```bash
# Offer restoration
echo "Migration encountered errors."
echo "Run ./claude_restore.sh to restore original configuration."
```

### Analysis Failed

If analysis fails at Phase 4:
```bash
# Framework is installed, just missing docs
echo "Analysis phase failed, but framework is installed."
echo "You can run /new-project --current manually later."
# Don't rollback - partial success is acceptable
```
