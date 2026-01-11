---
name: reflect
description: Self-improving skill that extracts preferences and corrections to update skills, captures session context for continuity, manages task/epic workflow, and coordinates parallel sessions. Use /reflect to manually trigger, /reflect resume to continue from last session, or /reflect status to see task progress.
---

# Reflect Skill

## Purpose

1. **Session Continuity:** Resume work seamlessly with context
2. **Task Management:** Track epics, tasks, and dependencies
3. **Parallel Session Coordination:** Prevent conflicts between concurrent sessions
4. **Skill Improvement:** Extract learnings to make skills better over time

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
| `/reflect status --sessions` | Show active parallel sessions |
| `/reflect unlock T002` | Force unlock a stale task |
| `/reflect cleanup` | Clean up stale sessions |
| `/reflect config` | Show current configuration |
| `/reflect config <key> <value>` | Update configuration |
| `/reflect on` | Enable auto-reflection at session end |
| `/reflect off` | Disable auto-reflection |

---

## CRITICAL: Session Start Protocol

**Before doing ANY work, you MUST complete the session start protocol.**

This is not optional. This is not negotiable. See CLAUDE.md for full details.

### Quick Reference

```
1. Generate Session ID: {YYYYMMDD-HHMMSS}-{4-random}
2. Create Session File: .claude/memories/sessions/active/session-{id}.md
3. Declare Scope: branch, directories, features
4. Scan for Conflicts: read all files in active/
5. Load Context: progress-notes.md, completed sessions, registry
6. Proceed (only if no blocking conflicts)
```

### Conflict Resolution

| Conflict | Action |
|----------|--------|
| Same branch | **BLOCK** - Cannot proceed |
| Same directory | **WARN** - User must confirm |
| Same file | **ASK** - User decides priority |
| Merge/PR | **QUEUE** - Wait for first to complete |

---

## Resume Commands

### `/reflect resume`

Resume from last session with full context.

**Flow:**

1. **Complete Session Start Protocol First**
   - Generate session ID
   - Create session file
   - Declare scope based on what you'll be resuming
   - Scan for conflicts
   - Only then proceed to gather context

2. **Gather Context from All Sources**

```bash
# 1. Recent git history (last 20 commits)
git log --oneline -20

# 2. Uncommitted changes (work in progress)
git diff --stat

# 3. Modified but unstaged files
git status --short
```

3. **Read Memory Files**
   - `.claude/memories/sessions/latest.md` - Last session state
   - `.claude/memories/progress-notes.md` - Ongoing work summary (append-only)
   - `.claude/memories/general.md` - Project preferences
   - `.claude/memories/sessions/completed/` - Recent completed sessions

4. **Read Task Registry**
   - `docs/tasks/registry.json` - Task/epic status and dependencies
   - Identify tasks with status `in_progress` or `continuation`

5. **Present Combined Context**

```markdown
## Session Resume

**Session ID:** {your-new-session-id}
**Last Session:** [date from latest.md]

### Active Sessions
[List any other active sessions from active/]

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

6. **Confirm and Continue**
   - Ask: "Continue from here?"
   - If yes, load context and proceed with incomplete tasks

---

### `/reflect resume E01`

Resume a specific epic.

**Flow:**

1. **Complete Session Start Protocol**
   - Declare scope to include the epic's directories

2. **Load Epic File**
   - Read `docs/epics/E01-*/E01-*.md`
   - Check epic status (must be `in_progress` or has incomplete tasks)

3. **Load Minimal Context**
   - Epic summary and scope
   - Task list with status
   - Dependencies and blockers

4. **Identify Next Task**
   - Find first task with status `ready` or `continuation`
   - Load that task's context

5. **Present Epic Context**

```markdown
## Resuming Epic E01: [Epic Name]

**Session ID:** {your-session-id}
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

1. **Complete Session Start Protocol**
   - Declare scope to include the task's files

2. **Validate Task**
   - Read task file from registry path
   - Check status is `ready`, `in_progress`, or `continuation`
   - Verify dependencies are met

3. **Check Lock Status**
   - If locked by another session and not stale, warn user
   - If stale lock (> lockTimeout), offer to unlock

4. **Load Minimal Context**
   - Task objective and requirements
   - Continuation context (if status is `continuation`)
   - Files to modify
   - Acceptance criteria

5. **Acquire Lock**
   - Set task status to `in_progress`
   - Record session ID and timestamp in lock

6. **Present Task Context**

```markdown
## Resuming Task T002: [Task Name]

**Session ID:** {your-session-id}
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

Show overview of all epics, tasks, and active sessions.

**Output:**

```markdown
## Project Status

**Epics:** 4 total (1 completed, 2 in_progress, 1 pending)
**Tasks:** 32 total (12 completed, 2 in_progress, 8 ready, 10 pending)
**Active Sessions:** 2

### Active Sessions
| Session ID | Branch | Scope | Started |
|------------|--------|-------|---------|
| 20240115-143022-a7x9 | feature/auth | src/auth/ | 2h ago |
| 20240115-150045-k2m3 | feature/dashboard | src/dashboard/ | 30m ago |

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

### `/reflect status --sessions`

Show detailed information about active parallel sessions.

**Output:**

```markdown
## Active Sessions

| Session ID | Branch | Scope | Started | Status |
|------------|--------|-------|---------|--------|
| 20240115-143022-a7x9 | feature/auth | src/auth/, src/middleware/ | 2h ago | active |
| 20240115-150045-k2m3 | feature/dashboard | src/dashboard/ | 30m ago | active |

### Session Details

#### 20240115-143022-a7x9
**Branch:** feature/auth
**Directories:** src/auth/, src/middleware/
**Working On:** Implement JWT validation
**Commits:** 3

#### 20240115-150045-k2m3
**Branch:** feature/dashboard
**Directories:** src/dashboard/
**Working On:** Dashboard layout component
**Commits:** 1

### Potential Conflicts
None detected.
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

## Cleanup Commands

### `/reflect cleanup`

Clean up stale sessions from the active directory.

**Flow:**

1. **Scan Active Sessions**
   - List all files in `.claude/memories/sessions/active/`
   - Parse timestamps from session IDs

2. **Identify Stale Sessions**
   - Sessions older than `sessionStaleTimeout` (default: 24h)

3. **Present Stale Sessions**

```markdown
## Stale Sessions Found

| Session ID | Started | Age | Branch |
|------------|---------|-----|--------|
| 20240114-093022-b2k4 | 2024-01-14 09:30 | 29h | feature/old |

Clean up these sessions?
- Move to completed/ with status "abandoned"
- Append summary to progress-notes.md
```

4. **On Confirmation**
   - Update each session file's status to `abandoned`
   - Move from `active/` to `completed/`
   - Append summary to `progress-notes.md`

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

## Session End Protocol

When ending a session (either `/reflect` or natural completion):

### 1. Update Session File

```markdown
# Session {id}

**Started**: 2024-01-15 14:30
**Ended**: 2024-01-15 16:45
**Branch**: feature/auth
**Scope**: src/auth/, src/middleware/
**Status**: completed
**Duration**: 2h 15m

## Completed
- [x] Implement login endpoint (commit: abc123)
- [x] Add JWT validation (commit: def456)
- [x] Write auth tests (commit: ghi789)

## Handoff Notes
- Registration endpoint ready to implement next
- Rate limiting should be added to auth routes
```

### 2. Move Session File

```bash
mv .claude/memories/sessions/active/session-{id}.md \
   .claude/memories/sessions/completed/session-{id}.md
```

### 3. Append to Progress Notes

**CRITICAL: APPEND ONLY. Never overwrite existing content.**

```markdown
---
### Session {id} - 2024-01-15 14:30
**Branch**: feature/auth
**Scope**: src/auth/, src/middleware/
**Status**: completed
**Duration**: 2h 15m

**Completed**:
- Implement login endpoint (commit: abc123)
- Add JWT validation (commit: def456)
- Write auth tests (commit: ghi789)

**Key Decisions**:
- Chose JWT over sessions for statelessness

**Handoff**:
- Registration endpoint ready to implement
- Add rate limiting to auth routes
---
```

### 4. Update latest.md

**Only if no other active sessions exist:**

```markdown
# Latest Session

**Session ID**: {id}
**Completed**: 2024-01-15 16:45

See `completed/session-{id}.md` for full details.

## Quick Summary
- Branch: feature/auth
- Completed 3 tasks
- Ready for: registration endpoint
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
| lockTimeout | 3600 | Seconds before task lock is stale |
| allowManualUnlock | true | Allow /reflect unlock |
| maxParallelAgents | 3 | Max concurrent task locks |
| autoAssignNextTask | true | Auto-suggest next task |

### Session Management
| Setting | Value | Description |
|---------|-------|-------------|
| sessionStaleTimeout | 86400 | Seconds before session is stale (24h) |
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
/reflect config lockTimeout 1800           # 30 minute lock timeout
/reflect config sessionStaleTimeout 43200  # 12 hour session timeout
/reflect config maxParallelAgents 5        # Allow 5 concurrent workers
/reflect config autoAssignNextTask false
```

---

## Manual Reflection Flow

When `/reflect` is called without arguments:

1. **Complete Session End Protocol** (see above)
2. Scan current conversation for learning signals (see [SIGNALS.md](SIGNALS.md))
3. Identify skills used during session
4. Categorize findings by confidence (High/Medium/Low)
5. Match learnings to relevant skills or general memories
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
│   ├── progress-notes.md       # Append-only session log
│   ├── sessions/
│   │   ├── active/             # Currently running sessions
│   │   │   ├── .gitkeep
│   │   │   └── session-{id}.md
│   │   ├── completed/          # Archived sessions
│   │   │   ├── .gitkeep
│   │   │   └── session-{id}.md
│   │   ├── latest.md           # Most recent completed
│   │   └── README.md
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

- **Session Protocol First:** Never skip the session start protocol
- **Minimal Context Loading:** Only load what's needed for the specific task/epic
- **Lock Management:** Always acquire lock before starting, release on completion
- **Continuation Context:** When stopping mid-task, populate continuation section
- **Append Only:** Never overwrite progress-notes.md, always append
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
