# Migration Checkpoints

This document defines the user confirmation points during the `/migrate` skill execution.

---

## Checkpoint Philosophy

Migration is a **high-impact operation** that modifies the project's Claude configuration. Each checkpoint:
- Requires explicit user confirmation
- Provides clear rollback options
- Shows what will happen next
- Cannot be skipped

---

## Checkpoint 0: Migration Plan Approval

**When:** After Phase 0 analysis, before any changes

**Purpose:** Ensure user understands and approves the migration plan

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    CHECKPOINT 0: Migration Plan                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Migration Plan Summary                                       │
│                                                                  │
│  Analyzed: .claude/ directory                                    │
│  Framework: Claude Forge v[VERSION]                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Content Actions                                             │ │
│  │                                                             │ │
│  │ PRESERVE (keep as-is):                                      │ │
│  │   • docs/prd.md (15KB)                                      │ │
│  │   • docs/tasks/registry.json (8KB)                          │ │
│  │   • docs/epics/* (12 files)                                 │ │
│  │                                                             │ │
│  │ MERGE (combine content):                                    │ │
│  │   • memories/progress-notes.md (append history)             │ │
│  │   • memories/general.md (merge preferences)                 │ │
│  │   • settings.local.json (preserve settings)                 │ │
│  │                                                             │ │
│  │ REPLACE (use framework):                                    │ │
│  │   • CLAUDE.md                                               │ │
│  │   • templates/* (14 files)                                  │ │
│  │   • agents/* (17 files)                                     │ │
│  │   • skills/* (9 skills)                                     │ │
│  │                                                             │ │
│  │ REQUIRES DECISION:                                          │ │
│  │   • custom-workflow.md (unknown type)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ⚠️  This operation will:                                        │
│     1. Rename .claude/ to .claude_old/                          │
│     2. Clone fresh Claude Forge framework                       │
│     3. Migrate content per plan above                           │
│                                                                  │
│  ✅ A restoration script will be created for rollback           │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Proceed with migration?                                         │
│                                                                  │
│  [Approve] [Show Details] [Cancel]                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Options:**
- **Approve**: Proceed to Phase 1 (Backup)
- **Show Details**: Display full file list with sizes
- **Cancel**: Exit with no changes

**Required Response:** Explicit approval or cancellation

---

## Checkpoint 1: Backup Complete

**When:** After Phase 1, before cloning framework

**Purpose:** Confirm backup succeeded and restoration script is ready

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                   CHECKPOINT 1: Backup Complete                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ Backup created successfully                                  │
│                                                                  │
│  📁 .claude/ → .claude_old/                                      │
│     Files: [X] files, [Y] KB                                    │
│                                                                  │
│  🔄 Restoration script: ./claude_restore.sh                      │
│     Run this at any time to restore original configuration      │
│                                                                  │
│  Next step: Clone Claude Forge framework                         │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Continue to framework installation?                             │
│                                                                  │
│  [Continue] [Rollback Now]                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Options:**
- **Continue**: Proceed to Phase 2 (Installation)
- **Rollback Now**: Restore backup immediately

---

## Checkpoint 2: Framework Installed

**When:** After Phase 2, before content migration

**Purpose:** Verify framework is properly installed

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                 CHECKPOINT 2: Framework Installed                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ Claude Forge framework installed                             │
│                                                                  │
│  📦 Framework Version: [VERSION]                                 │
│  📁 Location: .claude/                                           │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Installed Components                                        │ │
│  │                                                             │ │
│  │ ✅ skills/        9 workflow skills                         │ │
│  │ ✅ templates/    14 document templates                      │ │
│  │ ✅ agents/       17 agent personas                          │ │
│  │ ✅ reference/    10 reference documents                     │ │
│  │ ✅ security/      3 security configurations                 │ │
│  │ ✅ memories/      Session tracking ready                    │ │
│  │ ✅ CLAUDE.md      Framework instructions                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Next step: Migrate your content from backup                     │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Continue to content migration?                                  │
│                                                                  │
│  [Continue] [Rollback]                                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Checkpoint 2.5: Custom Content Decisions

**When:** During Phase 3, when unknown files are encountered

**Purpose:** Get user decision on files that don't fit standard categories

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│               CHECKPOINT 2.5: Custom Content Found               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📄 Unknown file: .claude_old/custom-workflow.md                 │
│                                                                  │
│  Size: 2.5 KB                                                    │
│  Last modified: 2024-01-10                                       │
│                                                                  │
│  Preview:                                                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ # Custom Workflow                                           │ │
│  │                                                             │ │
│  │ This document describes our team's custom workflow for...   │ │
│  │ [content continues...]                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  What should I do with this file?                                │
│                                                                  │
│  [Keep in .claude/custom/]                                      │
│  [Discard]                                                      │
│  [Show Full Content]                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Repeat for each unknown file.**

---

## Checkpoint 3: Content Migrated

**When:** After Phase 3, before project analysis

**Purpose:** Confirm all content has been migrated correctly

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                  CHECKPOINT 3: Content Migrated                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ Content migration complete                                   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Migration Summary                                           │ │
│  │                                                             │ │
│  │ Preserved:                                                  │ │
│  │   ✅ docs/prd.md                                            │ │
│  │   ✅ docs/tasks/registry.json                               │ │
│  │   ✅ docs/epics/ (12 files)                                 │ │
│  │                                                             │ │
│  │ Merged:                                                     │ │
│  │   ✅ memories/progress-notes.md (history appended)          │ │
│  │   ✅ memories/general.md (preferences merged)               │ │
│  │   ✅ settings.local.json (settings preserved)               │ │
│  │                                                             │ │
│  │ Custom:                                                     │ │
│  │   ✅ custom-workflow.md → .claude/custom/                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  📊 Documentation Status:                                        │
│     PRD: ✅ Exists (15KB)                                        │
│     ADRs: ⚠️ None found                                          │
│     Tasks: ✅ 45 tasks in registry                               │
│                                                                  │
│  Next step: Analyze project to fill documentation gaps           │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Continue to project analysis?                                   │
│  (This will create missing ADRs and update task states)         │
│                                                                  │
│  [Analyze Project] [Skip Analysis] [Rollback]                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Options:**
- **Analyze Project**: Run brownfield analysis (Phase 4)
- **Skip Analysis**: Skip to verification (Phase 5)
- **Rollback**: Restore original configuration

---

## Checkpoint 3.5: Unknown Project State

**When:** During Phase 4, if task state is unclear

**Purpose:** Determine how to handle unclear task/feature state

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│              CHECKPOINT 3.5: Project State Unclear               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ⚠️ I found existing code but unclear documentation about:       │
│                                                                  │
│  • Which features are complete vs planned                        │
│  • Current project status                                        │
│  • Outstanding tasks                                             │
│                                                                  │
│  Task Registry Status:                                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Total tasks: 45                                             │ │
│  │ Status breakdown unknown - all marked "pending"             │ │
│  │ Last update: 3 weeks ago                                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  How should I handle this?                                       │
│                                                                  │
│  [Analyze Codebase]                                             │
│    I'll examine the code and infer what's been completed        │
│                                                                  │
│  [Fresh Task Breakdown]                                         │
│    Create new task registry from PRD (existing tasks archived)  │
│                                                                  │
│  [Keep As-Is]                                                   │
│    Don't modify task registry, proceed with current state       │
│                                                                  │
│  [Manual Review]                                                │
│    Show me existing tasks so I can update statuses              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Checkpoint 4: Analysis Complete

**When:** After Phase 4 (if not skipped)

**Purpose:** Review analysis results

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                 CHECKPOINT 4: Analysis Complete                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ Project analysis complete                                    │
│                                                                  │
│  📊 Documentation Status (Updated):                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Document          │ Status    │ Action                     │ │
│  │───────────────────│───────────│────────────────────────────│ │
│  │ PRD               │ ✅ Exists  │ Preserved (updated scope)  │ │
│  │ ADRs              │ ✅ Created │ 5 decisions documented     │ │
│  │ Task Registry     │ ✅ Updated │ 45 tasks, 12 ready         │ │
│  │ Reference Docs    │ ✅ Ready   │ Templates populated        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  📋 Task Summary:                                                │
│     • Completed: 18                                              │
│     • In Progress: 3                                             │
│     • Ready: 12                                                  │
│     • Pending: 12                                                │
│                                                                  │
│  Architecture Decisions Created:                                 │
│     • ADR-001: React + TypeScript frontend                       │
│     • ADR-002: Express.js API backend                            │
│     • ADR-003: PostgreSQL database                               │
│     • ADR-004: JWT authentication                                │
│     • ADR-005: Vercel deployment                                 │
│                                                                  │
│  Next step: Verify and finalize migration                        │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Continue to verification?                                       │
│                                                                  │
│  [Continue] [Review ADRs] [Rollback]                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Checkpoint 5: Migration Complete

**When:** After Phase 5 verification

**Purpose:** Confirm success and handle cleanup

**Display:**

```
┌─────────────────────────────────────────────────────────────────┐
│                 CHECKPOINT 5: Migration Complete                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🎉 Migration Successful!                                        │
│                                                                  │
│  ✅ Framework installed and verified                             │
│  ✅ All content migrated                                         │
│  ✅ Project analyzed and documented                              │
│  ✅ Migration report created                                     │
│                                                                  │
│  📁 Backup available: .claude_old/                               │
│  📄 Restoration: ./claude_restore.sh                             │
│  📋 Report: migration-report.md                                  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Quick Start                                                 │ │
│  │                                                             │ │
│  │ /reflect status      - See task overview                    │ │
│  │ /reflect resume      - Continue from last session           │ │
│  │ /new-feature         - Start a new feature                  │ │
│  │ /fix-bug             - Debug and fix issues                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Cleanup Options:                                                │
│                                                                  │
│  [Keep .claude_old/]                                            │
│    Recommended for first week - easy rollback                   │
│                                                                  │
│  [Archive .claude_old/]                                         │
│    Compress to .claude_old.tar.gz - saves space                 │
│                                                                  │
│  [Delete .claude_old/]                                          │
│    Remove backup entirely - no rollback possible                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Checkpoint Behavior

### On Timeout
If user doesn't respond within 5 minutes:
- Display reminder
- After 10 minutes: Pause migration
- State is saved; can resume

### On Rollback Request
Any checkpoint can trigger rollback:
```
Rolling back migration...

1. Removing new .claude/ directory
2. Restoring .claude_old/ to .claude/
3. Cleaning up restoration script

✅ Rollback complete
   Your original configuration has been restored.
```

### On Error
If an error occurs:
```
⚠️ Error during migration

Phase: [current phase]
Error: [error message]

Options:
[Retry] - Attempt this step again
[Skip]  - Skip this step (may cause issues)
[Rollback] - Restore original configuration
[Debug] - Show detailed error information
```

---

## Non-Checkpoint Confirmations

Some actions require quick confirmation but aren't full checkpoints:

### File Overwrite
```
File already exists: docs/prd.md
Overwrite with migrated version? [y/N]
```

### Large File Warning
```
Large file detected: memories/progress-notes.md (500KB)
This may take a moment to process. Continue? [Y/n]
```

### Stale Lock Warning
```
Task T005 has a stale lock (locked 48 hours ago)
Clear the lock? [Y/n]
```
