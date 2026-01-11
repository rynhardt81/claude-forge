---
name: migrate
description: Migrate an existing project to the Claude Forge framework, preserving and merging existing .claude content
---

# Migrate Skill

## Purpose

The `/migrate` skill completes the migration of an existing project to the Claude Forge framework. It handles:

1. Analyzing and merging content from `.claude_old/`
2. Running brownfield project analysis to create missing documentation
3. Ensuring the framework is fully operational with existing project context

## Pre-Migration Setup

**Use the migration scripts** to set up the framework before running `/migrate`.

### Option 1: Using Migration Scripts (Recommended)

The framework includes scripts that handle all setup steps automatically:

**macOS/Linux:**
```bash
# 1. Clone Claude Forge to any location
git clone https://github.com/[org]/claude-forge.git
cd claude-forge

# 2. Run the migration script
./scripts/migrate.sh

# 3. Follow the prompts - enter your project path
# The script will:
#   - Backup your existing .claude/ to .claude_old/
#   - Copy the framework to your project's .claude/
#   - Create a restoration script

# 4. Start Claude Code in your project and run /migrate
```

**Windows (PowerShell):**
```powershell
# 1. Clone Claude Forge to any location
git clone https://github.com/[org]/claude-forge.git
cd claude-forge

# 2. Run the migration script
.\scripts\migrate.ps1

# 3. Follow the prompts - enter your project path
# 4. Start Claude Code in your project and run /migrate
```

### Option 2: Manual Setup

If you prefer manual control:

```bash
# 1. Navigate to the existing project
cd /path/to/my-project

# 2. Rename existing .claude to .claude_old
mv .claude .claude_old

# 3. Clone Claude Forge framework as .claude
git clone https://github.com/[org]/claude-forge.git .claude

# 4. Remove the framework's git history (important!)
rm -rf .claude/.git

# 5. Now start Claude Code and run /migrate
```

The `/migrate` skill then handles the content migration automatically.

## Invocation

```
/migrate                              # Standard migration with prompts
/migrate --skip-analysis              # Skip brownfield analysis (merge only)
/migrate --dry-run                    # Preview changes without executing
```

**Parameters:**
- `--skip-analysis` - Skip the `/new-project --current` analysis phase
- `--dry-run` - Show what would happen without making changes

## Prerequisites

Before running this skill:
- `.claude_old/` directory must exist (your previous Claude configuration)
- `.claude/` directory must contain the Claude Forge framework
- Must be in the project root directory

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ PRE-REQUISITE: Run migration script first!                       │
│ - ./scripts/migrate.sh (macOS/Linux)                             │
│ - .\scripts\migrate.ps1 (Windows)                                │
│ This handles backup, framework installation, and restoration     │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0: Pre-Migration Check                                     │
│ - Verify .claude_old/ exists (backup from script)                │
│ - Verify .claude/ has framework installed                        │
│ - Analyze what content exists in backup                          │
│ - Create migration plan                                          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 1: Content Migration                                       │
│ - Merge memories from .claude_old/                               │
│ - Migrate custom settings                                        │
│ - Preserve project-specific content                              │
│ - Apply merge rules for conflicts                                │
├─────────────────────────────────────────────────────────────────┤
│ Phase 2: Project Analysis (unless --skip-analysis)               │
│ - Invoke /new-project --current workflow                         │
│ - Create PRD from existing codebase                              │
│ - Generate ADRs for current architecture                         │
│ - Build task registry for outstanding work                       │
├─────────────────────────────────────────────────────────────────┤
│ Phase 3: Verification & Cleanup                                  │
│ - Verify framework is operational                                │
│ - Confirm all content migrated                                   │
│ - Optionally remove .claude_old/                                 │
│ - Create migration report                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Pre-Migration Check

### 0.1 Verify Prerequisites

The migration script should have already run. Verify the setup:

```bash
# Check .claude_old/ exists (your backup)
ls -la .claude_old/

# Check .claude/ has framework (CLAUDE.md, skills/, etc.)
ls -la .claude/
ls .claude/skills/
```

**If `.claude_old/` doesn't exist:**
```
⚠️  No .claude_old/ directory found.

Did you run the migration script first?
  macOS/Linux: ./scripts/migrate.sh
  Windows:     .\scripts\migrate.ps1

The script backs up your existing .claude/ to .claude_old/
and installs the framework to .claude/

Run the migration script first, then come back and run /migrate
```

**If `.claude/` doesn't have the framework:**
```
⚠️  Claude Forge framework not found in .claude/

The migration script should have installed the framework.
Please run the migration script again:
  macOS/Linux: ./scripts/migrate.sh
  Windows:     .\scripts\migrate.ps1
```

### 0.2 Analyze Existing Structure

Scan `.claude/` to understand what exists:

**Content Categories:**

| Category | Path Pattern | Migration Action |
|----------|--------------|------------------|
| Memories | `memories/`, `*.md` (progress, sessions) | **MERGE** - Append to new structure |
| Settings | `settings.json`, `settings.local.json` | **MERGE** - Preserve user settings |
| Custom Skills | `skills/` (if exists) | **PRESERVE** - Keep custom skills |
| Reference Docs | `reference/` | **ANALYZE** - Merge with templates |
| Templates | `templates/` | **REPLACE** - Use framework templates |
| Agents | `agents/` | **REPLACE** - Use framework agents |
| Security | `security/` | **MERGE** - Preserve custom rules |
| Project Docs | `docs/`, `prd.md`, ADRs | **PRESERVE** - Keep project docs |
| Task Registry | `tasks/registry.json` | **PRESERVE** - Keep task state |
| Unknown | Everything else | **ASK** - User decides |

### 0.3 Create Migration Plan

Generate a migration plan showing:
- Files to be preserved
- Files to be merged
- Files to be replaced
- Files requiring user decision

```markdown
## Migration Plan

### Will Preserve (keep as-is)
- .claude_old/docs/prd.md
- .claude_old/tasks/registry.json
- .claude_old/memories/progress-notes.md

### Will Merge (combine content)
- .claude_old/memories/general.md → .claude/memories/general.md
- .claude_old/settings.local.json → .claude/settings.local.json

### Will Replace (use framework version)
- .claude_old/templates/* → .claude/templates/* (framework)
- .claude_old/agents/* → .claude/agents/* (framework)

### Requires Decision
- .claude_old/custom-workflow.md (unknown file type)
```

### 0.4 Checkpoint: Approve Migration Plan

```
## Phase 0 Complete: Migration Plan Ready

📋 Analysis complete:
- [X] files to preserve
- [Y] files to merge
- [Z] files to replace
- [W] files need your decision

Review the plan above. Proceed with migration?

⚠️  This will:
1. Rename .claude/ to .claude_old/
2. Clone fresh Claude Forge framework
3. Migrate content according to plan

A restoration script will be created if you need to rollback.
```

---

## Phase 1: Backup

### 1.1 Create Restoration Script

Before any changes, create a rollback script:

```bash
# Create restoration script
cat > .claude_restore.sh << 'EOF'
#!/bin/bash
# Claude Forge Migration Restoration Script
# Generated: [TIMESTAMP]
#
# Run this script to restore the original .claude/ directory

if [ -d ".claude_old" ]; then
    echo "Restoring original .claude/ directory..."
    rm -rf .claude/
    mv .claude_old/ .claude/
    rm .claude_restore.sh
    echo "✅ Restoration complete"
else
    echo "❌ .claude_old/ not found - cannot restore"
    exit 1
fi
EOF
chmod +x .claude_restore.sh
```

### 1.2 Rename Existing Directory

```bash
mv .claude/ .claude_old/
```

### 1.3 Verify Backup

```bash
# Confirm .claude_old exists and has content
ls -la .claude_old/
```

---

## Phase 2: Framework Installation

### 2.1 Clone Claude Forge

**Option A: From GitHub (default)**
```bash
git clone https://github.com/[org]/claude-forge.git .claude/
```

**Option B: From local path (for development)**
```bash
cp -r /path/to/claude-forge/ .claude/
```

**Option C: From specified URL**
```bash
git clone [--repo URL] .claude/
```

### 2.2 Remove Framework Git History

The framework should not maintain its own git history in the target project:

```bash
rm -rf .claude/.git
rm -f .claude/.gitignore  # Project may have its own
```

### 2.3 Verify Framework Structure

Confirm critical framework files exist:

```bash
# Required files
ls .claude/CLAUDE.md
ls .claude/skills/
ls .claude/templates/
ls .claude/agents/
ls .claude/reference/
ls .claude/memories/
```

### 2.4 Checkpoint: Framework Installed

```
## Phase 2 Complete: Framework Installed

✅ Claude Forge framework cloned
✅ Git history removed
✅ Framework structure verified

Framework version: [version from CLAUDE.md or git tag]

Proceed to content migration?
```

---

## Phase 3: Content Migration

### 3.1 Initialize Memories Structure

Ensure the new memories structure exists:

```bash
mkdir -p .claude/memories/sessions/active
mkdir -p .claude/memories/sessions/completed
```

### 3.2 Migrate Memories

**Progress Notes (Append-Only):**
```bash
# If old progress notes exist, prepend to new file
if [ -f ".claude_old/memories/progress-notes.md" ]; then
    echo "---" >> .claude/memories/progress-notes.md
    echo "## Migrated from Previous Framework" >> .claude/memories/progress-notes.md
    echo "" >> .claude/memories/progress-notes.md
    cat .claude_old/memories/progress-notes.md >> .claude/memories/progress-notes.md
fi
```

**General Preferences:**
- Read `.claude_old/memories/general.md`
- Merge into `.claude/memories/general.md`
- Preserve project-specific preferences

**Session Files:**
- Move completed sessions to `.claude/memories/sessions/completed/`
- Preserve session history for context

### 3.3 Migrate Settings

```bash
# Preserve local settings
if [ -f ".claude_old/settings.local.json" ]; then
    cp .claude_old/settings.local.json .claude/settings.local.json
fi
```

### 3.4 Migrate Project Documentation

If existing project docs are found, preserve them:

```bash
# PRD
if [ -f ".claude_old/docs/prd.md" ]; then
    mkdir -p docs/
    cp .claude_old/docs/prd.md docs/prd.md
fi

# Task Registry
if [ -f ".claude_old/tasks/registry.json" ] || [ -f ".claude_old/docs/tasks/registry.json" ]; then
    mkdir -p docs/tasks/
    cp .claude_old/*/registry.json docs/tasks/registry.json 2>/dev/null || true
fi

# Epic/Task files
if [ -d ".claude_old/docs/epics" ]; then
    cp -r .claude_old/docs/epics/ docs/epics/
fi
```

### 3.5 Migrate Reference Documents

For each reference document:

1. **If old doc has substantial content** (>100 lines of non-template content):
   - Preserve old content
   - Note: May need manual reconciliation with new template

2. **If old doc is mostly template**:
   - Replace with new framework template

3. **If ADRs exist**:
   - Preserve all ADRs (these are project-specific decisions)

### 3.6 Handle Custom Content

For files in the "Requires Decision" category:

```
## Custom Content Found

The following files from your old configuration weren't recognized:

1. .claude_old/custom-workflow.md
   - Size: 2.5KB
   - Preview: [first 5 lines]

   What should we do?
   [ ] Keep in .claude/custom/
   [ ] Discard
   [ ] Show me the full content

2. .claude_old/my-agent.md
   ...
```

### 3.7 Checkpoint: Content Migrated

```
## Phase 3 Complete: Content Migrated

📁 Migrated content:
- ✅ Progress notes preserved (append-only)
- ✅ General preferences merged
- ✅ [X] session files preserved
- ✅ Local settings preserved
- ✅ PRD preserved (if existed)
- ✅ Task registry preserved (if existed)
- ✅ [Y] custom files handled

The framework now has your project context.

Continue to project analysis?
(This will run /new-project --current to fill in any gaps)
```

---

## Phase 4: Project Analysis

**Skip this phase if `--skip-analysis` flag is set.**

### 4.1 Determine Analysis Scope

Check what documentation already exists:

| Document | Exists? | Action |
|----------|---------|--------|
| PRD | Yes | Skip PRD creation, offer to update |
| PRD | No | Run full requirements discovery |
| ADRs | Yes | Preserve, offer to add new ones |
| ADRs | No | Run architecture analysis |
| Task Registry | Yes | Validate and update statuses |
| Task Registry | No | Create from PRD or codebase |

### 4.2 Invoke Brownfield Analysis

For missing documentation, invoke `/new-project --current` phases:

```
Running brownfield project analysis...

This will:
1. Analyze your existing codebase
2. Create/update PRD based on current functionality
3. Document architecture decisions
4. Build/update task registry for remaining work

The analysis will respect existing documentation and only fill gaps.
```

**Phase 1 (if no PRD):** Requirements discovery from codebase
**Phase 2 (if no ADRs):** Architecture analysis from codebase
**Phase 3 (if no tasks):** Task breakdown from PRD or codebase analysis

### 4.3 Handle Unknown State

If project state is unclear:

```
## Project State Analysis

I found existing code but unclear documentation about:
- What's completed vs planned
- Current project status
- Outstanding tasks

Would you like me to:
[ ] Analyze codebase and infer completed features
[ ] Start fresh with new task breakdown
[ ] Keep existing task registry as-is
[ ] Show me what exists and I'll clarify
```

### 4.4 Checkpoint: Analysis Complete

```
## Phase 4 Complete: Project Analyzed

📊 Documentation status:
- PRD: [Created | Updated | Preserved]
- ADRs: [X] decisions documented
- Tasks: [Y] tasks in registry
  - [A] completed
  - [B] in progress
  - [C] ready to start
  - [D] pending dependencies

The framework now fully understands your project.

Proceed to verification?
```

---

## Phase 5: Verification & Cleanup

### 5.1 Verify Framework Operation

Run verification checks:

```bash
# Check CLAUDE.md is readable
head -50 .claude/CLAUDE.md

# Check memories structure
ls -la .claude/memories/
ls -la .claude/memories/sessions/

# Check skills are available
ls .claude/skills/

# Check templates exist
ls .claude/templates/
```

### 5.2 Create Migration Report

Generate `migration-report.md` in project root:

```markdown
# Claude Forge Migration Report

**Migration Date:** [TIMESTAMP]
**Framework Version:** [version]
**Previous Framework:** [detected version or "unknown"]

## Migration Summary

### Preserved Content
- [List of preserved files]

### Merged Content
- [List of merged files with notes]

### Replaced Content
- [List of replaced files]

### New Framework Features
- Session protocol with conflict detection
- Parallel session support
- Epic/task dependency tracking
- Enhanced security model
- [Other new features]

## Post-Migration Checklist

- [ ] Review .claude/memories/progress-notes.md for context
- [ ] Check docs/prd.md reflects current project state
- [ ] Verify docs/tasks/registry.json has correct task statuses
- [ ] Run /reflect status to see available tasks
- [ ] Remove .claude_old/ when confident migration is complete

## Rollback Instructions

If you need to restore the previous configuration:
```bash
./claude_restore.sh
```

## Next Steps

1. Start a new session: The framework will initialize properly
2. Check task status: /reflect status
3. Resume work: /reflect resume [task-id]
```

### 5.3 Cleanup Options

```
## Phase 5 Complete: Migration Verified

✅ Framework operational
✅ All content migrated
✅ Migration report created

## Cleanup Options

The old .claude_old/ directory is still available for reference.

What would you like to do?
[ ] Keep .claude_old/ for now (recommended for first week)
[ ] Delete .claude_old/ now (saves space, no rollback)
[ ] Archive .claude_old/ to .claude_old.tar.gz
```

### 5.4 Final Summary

```
## Migration Complete!

🎉 Your project is now running Claude Forge framework.

**Quick Reference:**
- /reflect status      - See task overview
- /reflect resume      - Continue from last session
- /new-feature         - Start a new feature
- /fix-bug             - Debug and fix issues

**Important Files:**
- .claude/CLAUDE.md    - Framework instructions (READ THIS)
- docs/prd.md          - Product requirements
- docs/tasks/          - Task registry and epics

**Restoration:**
- Run ./claude_restore.sh to rollback if needed
- Delete .claude_old/ when confident

Happy coding with Claude Forge! 🚀
```

---

## Error Handling

### No .claude/ Directory Found

```
❌ No .claude/ directory found in current location.

This skill migrates existing Claude configurations.
For new projects, use: /new-project --current

Alternatively, if you have a .claude/ elsewhere:
  cd /path/to/project
  /migrate
```

### Git Clone Fails

```
❌ Failed to clone Claude Forge framework.

Possible causes:
- No internet connection
- Invalid repository URL
- Git not installed

Try:
1. Check internet connection
2. Verify git is installed: git --version
3. Try manual clone: git clone [url] .claude/
4. Use local copy: /migrate --repo=/local/path/to/claude-forge
```

### Merge Conflict in Content

```
⚠️  Merge conflict detected in: general.md

Your version:
---
[old content snippet]
---

Framework version:
---
[new content snippet]
---

How should I resolve this?
[ ] Keep my version
[ ] Use framework version
[ ] Merge both (show me combined)
[ ] Let me edit manually
```

### Restoration Needed

```
## Restoration Instructions

If something went wrong, restore your original configuration:

Option 1: Automatic
  ./claude_restore.sh

Option 2: Manual
  rm -rf .claude/
  mv .claude_old/ .claude/
  rm .claude_restore.sh

Your original configuration will be fully restored.
```

---

## Integration Points

### With /new-project

Phase 4 invokes `/new-project --current` for brownfield analysis. This creates:
- PRD from codebase analysis
- ADRs for current architecture
- Task registry for planned work

### With /reflect

After migration, `/reflect` commands work normally:
- `/reflect status` - Shows task overview
- `/reflect resume` - Continues from session context
- Migrated progress notes provide historical context

### With Session Protocol

The session protocol activates after migration:
- New sessions create session files
- Conflict detection is active
- Progress notes continue appending

---

## Examples

### Example 1: Simple Migration

```
User: /migrate

Phase 0: Analyzing .claude/ directory...
Found: memories/, settings.local.json, CLAUDE.md

Migration Plan:
- Preserve: memories/progress-notes.md
- Merge: settings.local.json
- Replace: CLAUDE.md (with framework version)

Proceed? [Yes]

Phase 1: Creating backup...
✅ .claude/ renamed to .claude_old/
✅ Restoration script created

Phase 2: Installing framework...
✅ Claude Forge cloned
✅ Framework verified

Phase 3: Migrating content...
✅ Progress notes migrated
✅ Settings preserved

Phase 4: Analyzing project...
Running /new-project --current...
[PRD and ADRs created from codebase]

Phase 5: Verification...
✅ Framework operational
✅ Migration complete!
```

### Example 2: Migration with Existing PRD

```
User: /migrate

Phase 0: Analyzing .claude/ directory...
Found: docs/prd.md, memories/, tasks/registry.json

Migration Plan:
- Preserve: docs/prd.md (project requirements)
- Preserve: tasks/registry.json (task state)
- Merge: memories/

Phase 4: Project analysis...
PRD already exists - skipping requirements discovery
Task registry found with 45 tasks (12 complete, 5 in progress)
Creating ADRs from codebase architecture...

Migration complete! Your existing documentation was preserved.
```

### Example 3: Dry Run

```
User: /migrate --dry-run

## Dry Run: Migration Preview

Would rename: .claude/ → .claude_old/
Would clone: Claude Forge framework → .claude/

Would preserve:
- memories/progress-notes.md (2.3KB)
- docs/prd.md (15KB)
- tasks/registry.json (8KB)

Would merge:
- settings.local.json (0.5KB)
- memories/general.md (1.2KB)

Would replace:
- CLAUDE.md (framework version)
- templates/* (framework versions)
- agents/* (framework versions)

No changes made. Run without --dry-run to execute.
```

---

## See Also

- `/new-project` - Full project initialization (for new projects)
- `/new-project --current` - Brownfield analysis (used in Phase 4)
- `/reflect` - Session management (works after migration)
- `MERGE-RULES.md` - Detailed content migration rules
- `PHASES.md` - Step-by-step phase instructions
