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

cat << 'EOF'
PRE-COMPACT: Before context is compacted, you MUST save critical state.

## IMMEDIATE ACTIONS (Do these NOW before compaction):

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
