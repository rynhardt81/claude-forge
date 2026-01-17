#!/bin/bash
# pre-compact.sh - Triggered before context compaction
# Ensures session state is saved before context window is compressed
#
# Input: JSON via stdin with compaction details
# Output: Instructions to Claude (stdout)
# Exit: 0 = continue, 2 = block compaction

# Read input (contains trigger: "manual" or "auto")
INPUT=$(cat)
TRIGGER=$(echo "$INPUT" | grep -o '"trigger":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "unknown")

# Check for Phase 3 in-progress
PHASE3_FILE=".claude/memories/phase3-progress.json"
PHASE3_STATUS=""
PHASE3_PROGRESS=""

if [ -f "$PHASE3_FILE" ]; then
    PHASE3_STATUS=$(grep '"status"' "$PHASE3_FILE" | head -1 | grep -o '"in_progress"' || echo "")
    if [ -n "$PHASE3_STATUS" ]; then
        EPICS_PLANNED=$(grep '"epicsPlanned"' "$PHASE3_FILE" | grep -o '[0-9]*' | head -1 || echo "0")
        EPICS_CREATED=$(grep '"epicsCreated"' "$PHASE3_FILE" | grep -o '[0-9]*' | head -1 || echo "0")
        TASKS_PLANNED=$(grep '"tasksPlanned"' "$PHASE3_FILE" | grep -o '[0-9]*' | head -1 || echo "0")
        TASKS_CREATED=$(grep '"tasksCreated"' "$PHASE3_FILE" | grep -o '[0-9]*' | head -1 || echo "0")
        PHASE3_PROGRESS="Epics: ${EPICS_CREATED}/${EPICS_PLANNED}, Tasks: ${TASKS_CREATED}/${TASKS_PLANNED}"
    fi
fi

cat << 'EOF'
PRE-COMPACT: Before context is compacted, you MUST save critical state.

## IMMEDIATE ACTIONS (Do these NOW before compaction):
EOF

# Special handling for Phase 3 in-progress
if [ -n "$PHASE3_STATUS" ]; then
    cat << EOF

### PHASE 3 IN PROGRESS - CRITICAL
**Epic/Task creation is incomplete!**
Progress: ${PHASE3_PROGRESS}

The file \`.claude/memories/phase3-progress.json\` tracks your progress.
After compaction:
1. Read \`.claude/memories/phase3-progress.json\`
2. Compare \`createdEpics\` vs \`plannedEpics\`
3. Compare \`createdTasks\` vs \`plannedTasks\`
4. Resume creating from first uncreated epic/task
5. DO NOT re-invoke @scrum-master - plan already exists

Before compaction NOW:
1. Update \`lastUpdatedAt\` timestamp
2. Ensure \`currentEpic\` and \`currentTask\` reflect current state
3. Add checkpoint entry with current progress

EOF
fi

cat << 'EOF'

### 1. Session File - Update with Current State
If working on a session, update `.claude/memories/sessions/active/session-*.md`:
```
## Pre-Compact Snapshot
**Timestamp**: [current time]
**Context**: About to compact - saving state

### Current Work State
- **Active Task**: [task ID and description]
- **Progress**: [what's done, what remains]
- **Current File**: [file being edited, if any]
- **Uncommitted Changes**: [list any uncommitted work]

### Critical Context to Preserve
- [Key decision made this session]
- [Important finding or insight]
- [Dependency or blocker discovered]

### Resume Instructions
After compaction, resume with:
1. [First step to take]
2. [Second step]
3. [Files to re-read]
```

### 2. Progress Notes - Append Pre-Compact Entry
Append to `.claude/memories/progress-notes.md`:
```
---
### Pre-Compact Snapshot - [timestamp]
**Trigger**: [manual/auto]
**Task**: [current task ID]
**State**: [brief description of current work]
**Resume**: [how to continue after compaction]
---
```

### 3. Task Registry - Save In-Progress State
If task is `in_progress`, add continuation context to `docs/tasks/registry.json`:
```json
{
  "continuation": {
    "lastAction": "[what you just did]",
    "nextAction": "[what to do next]",
    "context": "[critical context]"
  }
}
```

### 4. Commit Any Safe-to-Commit Changes
If there are changes that form a logical unit:
- Stage and commit with message: "WIP: [task] - pre-compact checkpoint"
- This preserves work in git history

## WHAT WILL BE LOST
After compaction, you will NOT remember:
- Detailed conversation history
- File contents you read (must re-read)
- Decisions made without documentation
- Context not saved to files

## WHAT WILL BE PRESERVED
- All files in `.claude/memories/`
- Git history and commits
- Task registry state
- Progress notes
- Phase 3 progress file (if exists)

---
EOF

# Output trigger type for context
if [ "$TRIGGER" = "auto" ]; then
    echo "COMPACT-TRIGGER: AUTO (context window full)"
    echo "ACTION: Save state immediately - compaction is imminent"
elif [ "$TRIGGER" = "manual" ]; then
    echo "COMPACT-TRIGGER: MANUAL (user requested /compact)"
    echo "ACTION: Save state before proceeding"
else
    echo "COMPACT-TRIGGER: UNKNOWN"
fi

# Always allow compaction to proceed (exit 0)
# We just want to remind Claude to save state first
exit 0
