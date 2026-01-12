#!/bin/bash
# session-end.sh - Triggered when Claude stops
# Ensures all session work is properly tracked before ending

cat << 'EOF'
STOP: Before ending this session, you MUST complete the session end protocol:

## 1. Session File (if exists in active/)
Check `.claude/memories/sessions/active/` for your session file and update:
- Move completed tasks from "Working On" to "Completed" (with commit hashes)
- Add any NEW tasks discovered during the session
- Update "Handoff Notes" with context for resumption
- If session is complete, move file to `completed/`

## 2. Progress Notes (APPEND ONLY - never overwrite)
Append to `.claude/memories/progress-notes.md`:
```
---
### Session - YYYY-MM-DD HH:MM
**Branch**: {branch}
**Scope**: {directories worked on}
**Status**: completed | partial | blocked

**Completed**:
- {task/item} (commit: {hash})

**In Progress** (if stopping mid-task):
- {task} - stopped at: {description of where you stopped}

**New Tasks Identified**:
- {any new tasks discovered during work}

**Key Decisions**:
- {decision made and why}

**Blockers** (if any):
- {what's blocking progress}

**Handoff**:
- {next steps for resumption}
---
```

## 3. Task Registry (docs/tasks/registry.json)
Update task statuses:
- `in_progress` → `completed` (if finished)
- `in_progress` → `continuation` (if stopping mid-task)
- `ready` → `in_progress` (if you started but didn't finish)
- Add NEW tasks if discovered during work (with proper IDs)
- Clear any locks you held

## 4. Latest Session Pointer
Update `.claude/memories/sessions/latest.md`:
- Current state summary
- List of ready tasks
- Any tasks in `continuation` status
- Resume commands

## 5. Epic/Task Files (if applicable)
If you worked on specific tasks:
- Update task file with progress notes
- Update epic file if task completed
- Add continuation context if stopping mid-task

---
CRITICAL: Do NOT skip any of these steps.

If tasks were identified but not added to the registry, ADD THEM NOW.
If work was done but not logged, LOG IT NOW.
If decisions were made but not documented, DOCUMENT THEM NOW.

The next session depends on this information being complete.
EOF
