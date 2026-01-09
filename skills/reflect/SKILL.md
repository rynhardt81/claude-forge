---
name: reflect
description: Self-improving skill that extracts preferences and corrections to update skills, captures session context for continuity, and manages task/epic workflow. Use /reflect to manually trigger, /reflect resume to continue from last session, or /reflect status to see task progress.
---

# Reflect Skill

## Purpose

1. **Session Continuity:** Resume work seamlessly with context
2. **Task Management:** Track epics, tasks, and dependencies
3. **Skill Improvement:** Extract learnings to make skills better over time

## Commands Overview

| Command | Purpose |
|---------|---------|
| `/reflect` | Manual reflection on current session |
| `/reflect resume` | Load last session and continue |
| `/reflect resume E01` | Resume specific epic |
| `/reflect resume T002` | Resume specific task |
| `/reflect status` | Show task/epic status overview |
| `/reflect status --locked` | Show only locked tasks |
| `/reflect status --ready` | Show tasks ready to work on |
| `/reflect unlock T002` | Force unlock a stale task |
| `/reflect config` | Show current configuration |
| `/reflect config <key> <value>` | Update configuration |
| `/reflect on` | Enable auto-reflection at session end |
| `/reflect off` | Disable auto-reflection |

---

## Resume Commands

### `/reflect resume`

Resume from last session with full context.

**Flow:**

1. **Gather Context from All Sources**

```bash
# 1. Recent git history (last 20 commits)
git log --oneline -20

# 2. Uncommitted changes (work in progress)
git diff --stat

# 3. Modified but unstaged files
git status --short
```

2. **Read Memory Files**
   - `.claude/memories/sessions/latest.md` - Last session state
   - `.claude/memories/progress-notes.md` - Ongoing work summary
   - `.claude/memories/general.md` - Project preferences

3. **Read Task Registry**
   - `docs/tasks/registry.json` - Task/epic status and dependencies
   - Identify tasks with status `in_progress` or `continuation`

4. **Present Combined Context**

```markdown
## Session Resume

**Last Session:** [date from latest.md]

### Recent Git Activity (last 20 commits)
[output from git log --oneline -20]

### Uncommitted Changes
[output from git diff --stat, or "None" if clean]

### Task Status
- **In Progress:** [tasks with in_progress status]
- **Continuation:** [tasks needing resume]
- **Ready:** [tasks with all dependencies met]

### From Progress Notes
- **Last worked on:** [from progress-notes.md]
- **Completed:** [list]
- **Blockers:** [if any]

### From Session Memory
- **Context:** [from latest.md]
- **Decisions made:** [list]
- **Next steps:** [list]
```

5. **Confirm and Continue**
   - Ask: "Continue from here?"
   - If yes, load context and proceed with incomplete tasks

---

### `/reflect resume E01`

Resume a specific epic.

**Flow:**

1. **Load Epic File**
   - Read `docs/epics/E01-*/E01-*.md`
   - Check epic status (must be `in_progress` or has incomplete tasks)

2. **Load Minimal Context**
   - Epic summary and scope
   - Task list with status
   - Dependencies and blockers

3. **Identify Next Task**
   - Find first task with status `ready` or `continuation`
   - Load that task's context

4. **Present Epic Context**

```markdown
## Resuming Epic E01: [Epic Name]

**Status:** in_progress
**Progress:** 3/8 tasks completed

### Tasks
| ID | Name | Status |
|----|------|--------|
| T001 | [Name] | completed |
| T002 | [Name] | completed |
| T003 | [Name] | completed |
| T004 | [Name] | ready ← NEXT |
| T005 | [Name] | pending (depends: T004) |
...

### Recent Activity
[from epic progress log]

Continue with T004?
```

---

### `/reflect resume T002`

Resume a specific task.

**Flow:**

1. **Validate Task**
   - Read task file from registry path
   - Check status is `ready`, `in_progress`, or `continuation`
   - Verify dependencies are met

2. **Check Lock Status**
   - If locked by another session and not stale, warn user
   - If stale lock (> lockTimeout), offer to unlock

3. **Load Minimal Context**
   - Task objective and requirements
   - Continuation context (if status is `continuation`)
   - Files to modify
   - Acceptance criteria

4. **Acquire Lock**
   - Set task status to `in_progress`
   - Record session ID and timestamp in lock

5. **Present Task Context**

```markdown
## Resuming Task T002: [Task Name]

**Epic:** E01 - [Epic Name]
**Status:** continuation → in_progress (locked)

### Continuation Context
**Last Session:** 2024-01-15
**Progress:** 60% complete
**Stopped At:** Implementing validation logic

### Resume Point
- **File:** `src/components/Form.tsx`
- **Line:** 142
- **Next Action:** Add email validation regex

### Remaining Work
- [ ] Add email validation regex
- [ ] Add error message display
- [ ] Write unit test

### Acceptance Criteria
- [ ] Form validates email format
- [ ] Error shown below input on invalid
- [ ] Submit disabled until valid

Ready to continue?
```

---

## Status Commands

### `/reflect status`

Show overview of all epics and tasks.

**Output:**

```markdown
## Project Status

**Epics:** 4 total (1 completed, 2 in_progress, 1 pending)
**Tasks:** 32 total (12 completed, 2 in_progress, 8 ready, 10 pending)

### Epic Overview
| ID | Name | Status | Progress |
|----|------|--------|----------|
| E01 | Authentication | completed | 8/8 |
| E02 | Dashboard | in_progress | 5/10 |
| E03 | Reports | in_progress | 2/8 |
| E04 | Admin Panel | pending | 0/6 |

### Ready Tasks (available to work on)
| ID | Epic | Name | Priority |
|----|------|------|----------|
| T015 | E02 | Add chart component | 1 |
| T016 | E02 | Implement filters | 2 |
| T021 | E03 | Create report template | 1 |

### In Progress
| ID | Name | Locked By | Since |
|----|------|-----------|-------|
| T014 | Dashboard layout | session-abc | 2h ago |
```

---

### `/reflect status --locked`

Show only locked tasks.

**Output:**

```markdown
## Locked Tasks

| ID | Name | Locked By | Since | Stale? |
|----|------|-----------|-------|--------|
| T014 | Dashboard layout | session-abc | 2h ago | No |
| T022 | Report export | session-xyz | 5h ago | YES |

**Stale locks** (> 1h) can be unlocked with `/reflect unlock <id>`
```

---

### `/reflect status --ready`

Show tasks ready to work on (all dependencies met, not locked).

**Output:**

```markdown
## Ready Tasks

| ID | Epic | Name | Priority | Category |
|----|------|------|----------|----------|
| T015 | E02 | Add chart component | 1 | F-Display |
| T016 | E02 | Implement filters | 2 | G-Search |
| T021 | E03 | Create report template | 1 | F-Display |

Use `/reflect resume T015` to start working on a task.
```

---

## Unlock Commands

### `/reflect unlock T002`

Force unlock a stale task.

**Flow:**

1. **Read Task Registry**
   - Find task T002
   - Check if locked

2. **Validate Unlock**
   - If not locked: "Task T002 is not locked."
   - If locked by current session: "You already have this task locked."
   - If locked and not stale: Warn user

```markdown
## Unlock Task T002?

**Task:** T002 - [Task Name]
**Locked by:** session-xyz
**Since:** 45 minutes ago
**Stale:** No (timeout is 60 minutes)

This task is actively locked. Force unlock?
- [Yes, unlock anyway] - May cause conflicts
- [No, cancel] - Wait for lock to expire
```

3. **If Stale or User Confirms**
   - Clear lock from task
   - Set status to `continuation` (preserves any partial work)
   - Add to lock history

4. **Update Task File**

```markdown
## Lock History

| Action | Time | Session | Reason |
|--------|------|---------|--------|
| created | 2024-01-15 10:00 | - | Initial creation |
| locked | 2024-01-15 14:00 | session-xyz | Started work |
| unlocked | 2024-01-15 15:30 | session-abc | Stale lock (manual) |
```

5. **Confirm**

```markdown
## Task T002 Unlocked

**Previous Status:** in_progress (locked)
**New Status:** continuation

The task is now available. Resume with `/reflect resume T002`.
```

---

## Config Commands

### `/reflect config`

Show current configuration.

**Output:**

```markdown
## Reflect Configuration

### Task Management
| Setting | Value | Description |
|---------|-------|-------------|
| lockTimeout | 3600 | Seconds before lock is stale |
| allowManualUnlock | true | Allow /reflect unlock |
| maxParallelAgents | 3 | Max concurrent task locks |
| autoAssignNextTask | true | Auto-suggest next task |

### Session Management
| Setting | Value | Description |
|---------|-------|-------------|
| maxContextTokens | 200000 | Total context budget |
| targetResumeTokens | 8000 | Target for resume context |
| warningThreshold | 150000 | Warn when context exceeds |

### Auto-Reflection
| Setting | Value |
|---------|-------|
| enabled | off |
| approvalMode | batch |
```

---

### `/reflect config <key> <value>`

Update a configuration setting.

**Examples:**

```
/reflect config lockTimeout 1800        # 30 minute lock timeout
/reflect config maxParallelAgents 5     # Allow 5 concurrent workers
/reflect config autoAssignNextTask false
```

**Flow:**

1. **Validate Key**
   - Must be a known configuration key
   - Unknown keys: "Unknown config key: [key]"

2. **Validate Value**
   - Type check (number, boolean, string)
   - Range check where applicable
   - Invalid: "Invalid value for [key]: [reason]"

3. **Update Config**
   - Update `docs/tasks/config.json`
   - Also update registry settings if applicable

4. **Confirm**

```markdown
## Configuration Updated

**Setting:** lockTimeout
**Old Value:** 3600
**New Value:** 1800

Configuration saved to docs/tasks/config.json
```

---

## Manual Reflection Flow

When `/reflect` is called without arguments:

1. Scan current conversation for learning signals (see [SIGNALS.md](SIGNALS.md))
2. Identify skills used during session
3. Categorize findings by confidence (High/Medium/Low)
4. Match learnings to relevant skills or general memories
5. Capture session context using [SESSION-TEMPLATE.md](SESSION-TEMPLATE.md)
6. Present batch review of proposed changes (see [CHECKPOINTS.md](CHECKPOINTS.md))
7. On approval, update files per [UPDATE-RULES.md](UPDATE-RULES.md)
8. Commit changes with descriptive message

---

## Auto-Reflection Flow

When enabled (`/reflect on`) and session ends:

1. Hook checks if skills were used this session
2. If yes, triggers reflection automatically
3. Same flow as manual, respects approval mode in config
4. Batch mode: presents review before applying
5. Auto mode: applies high confidence, queues others for review

---

## Storage Locations

```
.claude/
├── memories/
│   ├── general.md              # General preferences
│   ├── progress-notes.md       # Session summaries
│   ├── sessions/
│   │   ├── latest.md           # Most recent session
│   │   └── YYYY-MM-DD.md       # Date-stamped sessions
│   ├── .reflect-status         # on/off toggle
│   ├── .reflect-config.json    # Reflection config
│   └── .session-skills         # Skills used (temp)
└── skills/
    └── [skill-name]/
        └── SKILL.md            # Learned preferences here

docs/
├── tasks/
│   ├── registry.json           # Master task/epic registry
│   └── config.json             # Project configuration
└── epics/
    └── E01-epic-name/
        ├── E01-epic-name.md    # Epic file
        └── tasks/
            ├── T001-task.md    # Task files
            └── T002-task.md
```

---

## Task State Machine

```
                    ┌─────────────────────┐
                    │      pending        │
                    │  (deps not met)     │
                    └──────────┬──────────┘
                               │ dependencies complete
                               ▼
                    ┌─────────────────────┐
                    │       ready         │
                    │  (can be started)   │
                    └──────────┬──────────┘
                               │ /reflect resume T00X
                               ▼
                    ┌─────────────────────┐
         ┌─────────│    in_progress      │─────────┐
         │         │     (locked)        │         │
         │         └──────────┬──────────┘         │
         │                    │                    │
    session ends         completed            session crash
    (incomplete)              │               or timeout
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  continuation   │  │    completed    │  │  continuation   │
│ (needs resume)  │  │     (done)      │  │ (stale lock)    │
└────────┬────────┘  └─────────────────┘  └────────┬────────┘
         │                                         │
         └─────────────────────────────────────────┘
                               │
                    /reflect resume T00X
                               │
                               ▼
                    ┌─────────────────────┐
                    │    in_progress      │
                    │     (locked)        │
                    └─────────────────────┘
```

---

## Key Rules

- **Minimal Context Loading:** Only load what's needed for the specific task/epic
- **Lock Management:** Always acquire lock before starting, release on completion
- **Continuation Context:** When stopping mid-task, populate continuation section
- **Never Overwrite:** Append to existing skill content, don't replace
- **Always Commit:** Commit updates with clear messages
- **Deduplicate:** Check for existing learnings before adding
- **Flag Conflicts:** Surface conflicts for manual review
- **Track Skills:** Use .session-skills to track what was used

---

## Context Budget

Target context usage for resume operations:

| Operation | Target | Max |
|-----------|--------|-----|
| Resume (general) | 8k tokens | 15k |
| Resume (epic) | 5k tokens | 10k |
| Resume (task) | 3k tokens | 6k |
| Status | 2k tokens | 4k |

This leaves 185k+ tokens for actual work.
