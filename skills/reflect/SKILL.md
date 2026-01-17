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
5. **Intelligent Dispatch:** Configure automatic sub-agent parallelization and intent detection

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
| `/reflect status --dispatch` | Show dispatch analysis for ready tasks |
| `/reflect unlock T002` | Force unlock a stale task |
| `/reflect cleanup` | Clean up stale sessions |
| `/reflect config` | Show current configuration |
| `/reflect config <key> <value>` | Update configuration |
| `/reflect config dispatch` | Show dispatch configuration |
| `/reflect config intent` | Show intent detection configuration |
| `/reflect config --preset <name>` | Apply preset (careful/balanced/aggressive) |
| `/reflect dispatch on` | Enable automatic sub-agent dispatch |
| `/reflect dispatch off` | Disable automatic sub-agent dispatch |
| `/reflect intent on` | Enable intent detection |
| `/reflect intent off` | Disable intent detection |
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

4. **Load Project Memory (if exists)**
   - Check if `docs/project-memory/` exists
   - If yes:
     a. Always load `key-facts.md` (full file, ~300 tokens)
     b. Determine task type from registry/context:
        - Keywords in task title: "fix", "bug" → bug fix
        - Keywords: "add", "implement", "feature" → feature
        - Keywords: "refactor", "clean" → refactor
        - Keywords: "architecture", "design" → architecture
     c. Load relevant memories per loading strategy:

        | Task Type | Primary | Secondary |
        |-----------|---------|-----------|
        | bug/fix | bugs.md | decisions.md |
        | feature | patterns.md | decisions.md |
        | architecture | decisions.md | patterns.md |
        | refactor | patterns.md | bugs.md |

     d. Load primary category (ToC scan + keyword matches)
     e. Load secondary category (ToC only)
   - Present: "Project context: X facts, Y relevant [category] entries"

5. **Read Task Registry**
   - `docs/tasks/registry.json` - Task/epic status and dependencies
   - Identify tasks with status `in_progress` or `continuation`

6. **Present Combined Context**

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

7. **Confirm and Continue**
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

5. **Load Relevant Project Memory**
   - Determine task type from:
     - Task title keywords ("fix", "add", "refactor", "implement")
     - Task description content
   - Load memories per strategy above
   - Include in task context presentation:

```markdown
### Project Memory
**Loaded:** 3 key facts, 2 relevant bugs
- [BUG-012] Auth Token Race Condition
- [BUG-015] Connection Pool Exhaustion
```

6. **Acquire Lock**
   - Set task status to `in_progress`
   - Record session ID and timestamp in lock

7. **Present Task Context**

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

### Intelligent Dispatch
| Setting | Value | Description |
|---------|-------|-------------|
| dispatch.enabled | true | Automatic sub-agent dispatch |
| dispatch.mode | automatic | Spawns without confirmation |
| dispatch.maxParallelAgents | 3 | Max concurrent sub-agents |
| intentDetection.enabled | true | Natural language intent detection |
| intentDetection.mode | suggest | Suggests skills, waits for confirm |
| intentDetection.confidenceThreshold | 0.7 | Min confidence to suggest |

### Auto-Reflection
| Setting | Value |
|---------|-------|
| enabled | off |
| approvalMode | batch |

Use `/reflect config dispatch` or `/reflect config intent` for detailed settings.
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

## Intelligent Dispatch Commands

The Intelligent Dispatch System automatically parallelizes work and detects user intent. These commands configure its behavior.

### `/reflect config dispatch`

Show dispatch configuration.

**Output:**

```markdown
## Dispatch Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| enabled | true | Automatic dispatch active |
| mode | automatic | Spawns agents without confirmation |
| maxParallelAgents | 3 | Max concurrent sub-agents |

### Trigger Points
| Trigger | Enabled |
|---------|---------|
| onResume | true |
| onTaskComplete | true |
| onFeatureComplete | true |

### Task Registry Settings
| Setting | Value |
|---------|-------|
| enabled | true |
| minReadyTasks | 2 |
| respectPriority | true |
| scopeConflictBehavior | skip |

### Feature Database Settings
| Setting | Value |
|---------|-------|
| enabled | true |
| categoryMatrix | default |
| regressionStrategy | shared |
| criticalCategories | A, P |
```

---

### `/reflect config intent`

Show intent detection configuration.

**Output:**

```markdown
## Intent Detection Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| enabled | true | Pattern matching active |
| mode | suggest | Asks before invoking skill |
| confidenceThreshold | 0.7 | Minimum confidence to suggest |

### Skill Detection
| Category | Enabled |
|----------|---------|
| framework | true |
| superpowers | true |

### Excluded Patterns
- "how do I"
- "what is"
- "explain"
- "show me"

### Statistics (this session)
| Metric | Value |
|--------|-------|
| Suggestions shown | 3 |
| Suggestions accepted | 2 |
| Acceptance rate | 66.7% |
```

---

### `/reflect config --preset <name>`

Apply a preset configuration.

**Available Presets:**

| Preset | Description | Dispatch Mode | Max Agents | Confidence |
|--------|-------------|---------------|------------|------------|
| `careful` | New projects | confirm | 2 | 0.8 |
| `balanced` | Normal use | automatic | 3 | 0.7 |
| `aggressive` | Large projects | automatic | 5 | 0.6 |

**Example:**

```
/reflect config --preset balanced
```

**Output:**

```markdown
## Applied Preset: balanced

Updated settings:
- dispatch.mode: automatic
- dispatch.maxParallelAgents: 3
- intentDetection.confidenceThreshold: 0.7

Configuration saved to `.claude/memories/.dispatch-config.json`
```

---

### `/reflect dispatch on`

Enable automatic sub-agent dispatch.

**Flow:**

1. Set `dispatch.enabled = true` in config
2. Confirm change

**Output:**

```markdown
## Dispatch Enabled

Automatic sub-agent dispatch is now **enabled**.

When you resume tasks or complete work, the system will:
- Analyze task dependencies for parallelizable work
- Spawn sub-agents based on dispatch.mode setting
- Current mode: automatic (will spawn without confirmation)

Use `/reflect dispatch off` to disable.
```

---

### `/reflect dispatch off`

Disable automatic sub-agent dispatch.

**Output:**

```markdown
## Dispatch Disabled

Automatic sub-agent dispatch is now **disabled**.

Tasks will be executed sequentially by the main agent.
Use `/reflect dispatch on` to re-enable.
```

---

### `/reflect intent on`

Enable intent detection.

**Output:**

```markdown
## Intent Detection Enabled

Natural language intent detection is now **enabled**.

When you send a message, the system will:
- Check for patterns matching known skills
- Suggest appropriate skill if confidence >= 0.7
- Wait for your confirmation before invoking

Use `/reflect intent off` to disable.
```

---

### `/reflect intent off`

Disable intent detection.

**Output:**

```markdown
## Intent Detection Disabled

Natural language intent detection is now **disabled**.

To invoke skills, use explicit commands:
- `/new-feature <description>`
- `/fix-bug <description>`
- `/refactor <description>`
- etc.

Use `/reflect intent on` to re-enable.
```

---

### `/reflect status --dispatch`

Show dispatch analysis for currently ready tasks.

**Output:**

```markdown
## Dispatch Analysis

### Ready Tasks
| ID | Name | Priority | Scope | Can Parallelize |
|----|------|----------|-------|-----------------|
| T015 | Add chart component | 1 | src/components/charts/ | Yes |
| T016 | Implement filters | 2 | src/components/filters/ | Yes |
| T021 | Create report template | 1 | src/reports/ | Yes |
| T017 | Update chart styles | 3 | src/components/charts/ | No (scope conflict with T015) |

### Parallelization Proposal
Based on dependency analysis and scope checking:

**Main Agent:**
- T015: Add chart component (Priority 1)

**Sub-Agent 1:**
- T016: Implement filters (no scope overlap)

**Sub-Agent 2:**
- T021: Create report template (no scope overlap)

**Deferred (scope conflict):**
- T017: Update chart styles (shares scope with T015)

### Configuration
- Mode: automatic
- Max agents: 3
- Would spawn: 2 sub-agents

Start with this plan? [Y/n]
```

---

### Dispatch Configuration Settings

Update dispatch settings with `/reflect config <key> <value>`:

```
# Enable/disable dispatch
/reflect config dispatch.enabled true
/reflect config dispatch.enabled false

# Set dispatch mode
/reflect config dispatch.mode automatic    # Spawn without asking
/reflect config dispatch.mode confirm      # Ask before spawning

# Set max parallel agents
/reflect config dispatch.maxParallelAgents 5

# Configure trigger points
/reflect config dispatch.triggerPoints.onResume true
/reflect config dispatch.triggerPoints.onTaskComplete true
/reflect config dispatch.triggerPoints.onFeatureComplete false

# Task registry settings
/reflect config dispatch.taskRegistry.enabled true
/reflect config dispatch.taskRegistry.minReadyTasks 3

# Feature database settings
/reflect config dispatch.featureDatabase.regressionStrategy independent
/reflect config dispatch.featureDatabase.criticalCategories ["A", "P", "L"]
```

---

### Intent Detection Configuration Settings

Update intent detection settings with `/reflect config <key> <value>`:

```
# Enable/disable intent detection
/reflect config intentDetection.enabled true
/reflect config intentDetection.enabled false

# Set mode
/reflect config intentDetection.mode suggest   # Suggest and confirm
/reflect config intentDetection.mode off       # Disable completely

# Set confidence threshold
/reflect config intentDetection.confidenceThreshold 0.8   # More conservative
/reflect config intentDetection.confidenceThreshold 0.6   # More suggestions

# Enable/disable skill categories
/reflect config intentDetection.skills.framework true
/reflect config intentDetection.skills.superpowers false

# Add exclusion pattern
/reflect config intentDetection.excludePatterns.add "tell me about"
```

---

## Dispatch Analysis Flow

**When to run:** After context loading in session protocol, BEFORE starting work.

**Prerequisites:**
- `docs/tasks/registry.json` exists
- `.claude/memories/.dispatch-config.json` has `dispatch.enabled: true`
- At least 2 tasks with status `ready` in registry

### Step 1: Load Configuration

```bash
# Read dispatch config
cat .claude/memories/.dispatch-config.json
```

Extract these values:
- `dispatch.enabled` - Skip if false
- `dispatch.mode` - "automatic" or "confirm"
- `dispatch.maxParallelAgents` - Max concurrent agents
- `dispatch.taskRegistry.minReadyTasks` - Min tasks needed

### Step 2: Identify Ready Tasks

From `registry.json`, find all tasks where:
- `status == "ready"`
- `lockedBy` is null or empty

List them with their properties:
- ID, name, priority
- dependencies (all must be `completed`)
- scope.directories and scope.files

**If fewer than `minReadyTasks` ready:** Skip dispatch, proceed normally.

### Step 3: Build Dependency Graph

For each ready task, check:
1. Does it depend on any other ready task? (directly or transitively)
2. Does any other ready task depend on it?

Tasks are **independent** if neither depends on the other.

```
Example:
- T005: deps [T001✓, T003✓] - ready, independent
- T006: deps [T002✓] - ready, independent
- T007: deps [T005] - NOT independent (T005 must complete first)
```

### Step 4: Check Scope Conflicts

For each independent task pair, check if scopes overlap:

```
hasScopeConflict(task1, task2):
  FOR dir1 IN task1.scope.directories:
    FOR dir2 IN task2.scope.directories:
      IF dir1 starts with dir2 OR dir2 starts with dir1:
        RETURN true  # Conflict
  FOR file1 IN task1.scope.files:
    FOR file2 IN task2.scope.files:
      IF file1 == file2:
        RETURN true  # Conflict
  RETURN false
```

Also check against YOUR declared session scope.

### Step 5: Rank and Select

From non-conflicting independent tasks:
1. Sort by priority (lower number = higher priority)
2. Select up to `maxParallelAgents - 1` tasks for sub-agents
3. Main agent takes the highest priority task

### Step 6: Execute Dispatch

**If `dispatch.mode == "confirm"`:**

```markdown
## Dispatch Proposal

I found {N} independent tasks that can run in parallel:

**Main Agent (you):**
- T015: Add chart component (Priority 1, scope: src/components/charts/)

**Sub-Agent 1:**
- T016: Implement filters (Priority 2, scope: src/components/filters/)

**Sub-Agent 2:**
- T021: Create report template (Priority 1, scope: src/reports/)

Spawn sub-agents to work in parallel? [Y/n]
```

Wait for user confirmation before spawning.

**If `dispatch.mode == "automatic"`:**

Spawn immediately, notify user:

```markdown
## Dispatch Initiated

Spawning 2 sub-agents for parallel work:
- Agent 1: T016 - Implement filters
- Agent 2: T021 - Create report template

Main agent continuing with: T015 - Add chart component
```

### Step 7: Spawn Sub-Agents

For each task to dispatch, use the Task tool:

```
Task tool invocation:
- subagent_type: "general-purpose"
- description: "Task {task.id}: {task.name}"
- prompt: [Use template below]
- run_in_background: true
```

**Sub-Agent Prompt Template:**

```markdown
## Task Assignment: {task.id} - {task.name}

**Session ID:** {parent-session-id}-agent-{n}
**Parent Session:** {parent-session-id}

### Scope (STRICT - do NOT modify files outside)
Directories: {task.scope.directories}
Files: {task.scope.files}

### Task Details
{Load from task file: docs/epics/{epic}/tasks/{task.id}-*.md}

### Instructions
1. Complete the session start protocol (create session file)
2. Implement the task within declared scope ONLY
3. Run relevant tests
4. Commit with message: `feat({epic}): {task.name} [Task-ID: {task.id}]`
5. **Update task file** (docs/epics/{epic}/tasks/{task.id}-*.md):
   - Set `status: completed` in frontmatter
   - Check off all acceptance criteria (- [x])
   - Check off all requirements (- [x])
   - Add completion notes under "Implementation Notes"
   - Clear any continuation context
6. Update registry: set task status to "completed", clear lock
7. Update your session file, move to completed/

### On Completion
Report back:
- status: "completed" | "blocked" | "partial"
- commits: [list of commit hashes]
- blockers: [if not completed]
```

### Step 8: Update Registry

After spawning, update `registry.json`:

```json
{
  "tasks": {
    "T016": {
      "status": "in_progress",
      "lockedBy": "{parent-session-id}-agent-1",
      "lockedAt": "{timestamp}",
      "parallelGroup": "pg-{timestamp}",
      "dispatchedBy": "{parent-session-id}"
    }
  },
  "parallelGroups": {
    "pg-{timestamp}": {
      "id": "pg-{timestamp}",
      "tasks": ["T016", "T021"],
      "parentSession": "{parent-session-id}",
      "startedAt": "{timestamp}",
      "status": "active"
    }
  }
}
```

### Step 9: Monitor and Continue

After dispatch:
1. Main agent proceeds with its assigned task
2. When sub-agents complete, check for newly unblocked tasks
3. Trigger continuous dispatch if new tasks became ready

---

## Continuous Dispatch

After completing a task (main or sub-agent):

1. **Update registry** - Mark task completed
2. **Check if tasks became ready** - Dependencies now met?
3. **If new ready tasks AND dispatch enabled:**
   - Run dispatch analysis again (Steps 2-8)
   - Spawn new sub-agents for parallelizable work

This creates a continuous flow where completing one task can unlock others for parallel execution.

---

## Feature Database Dispatch Flow

**When to run:** During `/implement-features` when feature database exists and dispatch is enabled.

**Prerequisites:**
- Feature database exists (`.claude/features/features.db`)
- `.claude/memories/.dispatch-config.json` has `dispatch.featureDatabase.enabled: true`
- At least 2 pending features in database

### Step 1: Load Configuration

Read dispatch config and extract:
- `dispatch.featureDatabase.enabled` - Skip if false
- `dispatch.featureDatabase.categoryMatrix` - default, strict, or permissive
- `dispatch.featureDatabase.regressionStrategy` - shared or independent
- `dispatch.featureDatabase.criticalCategories` - Categories that never parallelize (default: A, P)

### Step 2: Get Parallelizable Features

Call MCP tool:
```
feature_get_parallelizable(limit=dispatch.maxParallelAgents)
```

Returns:
- `primary` - Highest priority pending feature
- `parallelizable` - Features that can run alongside primary
- `deferred` - Features that cannot parallelize (with reasons)
- `analysis` - Summary of categorization decisions

### Step 3: Handle Critical Categories

If primary feature is in critical category (A: Security, P: Payment):
- **DO NOT parallelize** - Critical features require exclusive execution
- Work on primary alone
- Skip dispatch, proceed with single-threaded implementation

### Step 4: Validate Parallelization

Review the analysis results:
- Same-category features share files - cannot parallelize
- Different categories with matrix conflicts - cannot parallelize
- Check the deferred list for reasons

### Step 5: Execute Dispatch

**If `dispatch.mode == "confirm"`:**

```markdown
## Feature Dispatch Proposal

I found {N} features that can run in parallel:

**Main Agent:**
- F-42: Product grid display (Category F, Priority 1)

**Sub-Agent 1:**
- F-44: User preferences panel (Category I, Priority 2)

**Sub-Agent 2:**
- F-45: Help documentation (Category S, Priority 3)

**Deferred (cannot parallelize):**
- F-43: Product list view (Category F - same as primary)

Spawn sub-agents? [Y/n]
```

**If `dispatch.mode == "automatic"`:**

```markdown
## Feature Dispatch Initiated

Creating parallel group for 3 features:
- F-42: Product grid display (main agent)
- F-44: User preferences panel (sub-agent 1)
- F-45: Help documentation (sub-agent 2)
```

### Step 6: Create Parallel Group

Call MCP tool:
```
feature_create_parallel_group(
    feature_ids=[42, 44, 45],
    session_id="{current-session-id}"
)
```

This:
- Creates a ParallelGroup record
- Marks all features as in_progress
- Records dispatch metadata

### Step 7: Spawn Sub-Agents

For each parallelizable feature, use the Task tool:

```
Task tool invocation:
- subagent_type: "general-purpose"
- description: "Feature F-{id}: {name}"
- prompt: [Use template below]
- run_in_background: true
```

**Sub-Agent Prompt Template:**

```markdown
## Feature Assignment: F-{feature.id} - {feature.name}

**Session ID:** {parent-session-id}-agent-{n}
**Parent Session:** {parent-session-id}
**Category:** {feature.category}
**Parallel Group:** {group.id}

### Feature Details
**ID:** F-{feature.id}
**Category:** {feature.category} - {category_name}
**Priority:** {feature.priority}

### Description
{feature.description}

### Test Steps
{for step in feature.steps}
{step.number}. {step.description}
   Expected: {step.expected}
{endfor}

### Instructions
1. Implement the feature
2. Verify all test steps pass
3. Run lint and type check
4. Commit with message: `feat({category}): {feature.name} [Feature-ID: F-{feature.id}]`
5. Call `feature_mark_passing({feature.id})`

### On Completion
Report back:
- status: "passing" | "blocked" | "failing"
- commits: [list of commit hashes]
```

### Step 8: Monitor Progress

Periodically check group status:
```
feature_get_parallel_status(group_id={group.id})
```

This returns:
- Status of each feature (passing, in_progress)
- Completion summary
- Whether group is complete

### Step 9: Run Regression (if configured)

**If `dispatch.featureDatabase.regressionStrategy == "shared"`:**
- Run regression once after ALL features complete
- Main agent handles regression test

**If `dispatch.featureDatabase.regressionStrategy == "independent"`:**
- Each sub-agent runs regression for their own feature
- More safety checks but duplicates work

### Step 10: Complete Group

After all features pass and regression passes:
```
feature_complete_parallel_group(
    group_id={group.id},
    regression_passed=true
)
```

### Step 11: Continuous Feature Dispatch

After completing features:
1. Call `feature_get_parallelizable()` again
2. If more parallelizable features found, repeat dispatch flow
3. Continue until all features are passing or only serial work remains

---

## Feature Dispatch Rules Summary

| Rule | Description |
|------|-------------|
| Critical Never Parallel | Categories A (Security) and P (Payment) always run alone |
| Same Category Serial | Features in same category likely share files - run sequentially |
| Category Matrix | Different categories checked against compatibility matrix |
| Priority First | Higher priority features take precedence as primary |
| Regression Strategy | Shared (once at end) or Independent (each agent) |

---

## Intent Detection Analysis Flow

**When to run:** On EVERY user message, BEFORE any other action or response.

**Prerequisites:**
- `.claude/memories/.dispatch-config.json` has `intentDetection.enabled: true`
- User message does NOT start with `/` (explicit command)

### Step 1: Check Exclusions

Before pattern matching, check if message should be excluded:

1. **Explicit Command:** If message starts with `/`, skip detection (user chose explicitly)
2. **Question Pattern:** Check if message is a question:
   - Starts with: "how do I", "what is", "can you", "should I", "is there", "what's the", "where is", "why does"
   - Ends with `?`
   - If question → answer directly, skip suggestion
3. **Exclusion Patterns:** Check against configured exclusions:
   ```json
   "excludePatterns": ["how do I", "what is", "explain", "show me"]
   ```
4. **Negation Detection:** Check for negation words:
   - "don't", "do not", "never", "stop", "cancel", "not yet", "wait", "hold off", "skip"
   - If negation present → skip suggestion

### Step 2: Pattern Matching

For each skill pattern in the detection library:

**Framework Skills:**
| Skill | Trigger Patterns |
|-------|------------------|
| `/new-feature` | "add feature", "implement feature", "build a", "create new", "add functionality" |
| `/fix-bug` | "fix bug", "debug", "broken", "not working", "error in", "problem with" |
| `/refactor` | "refactor", "clean up", "restructure", "improve code", "reorganize" |
| `/create-pr` | "create pr", "pull request", "ready for review", "merge request" |
| `/release` | "release", "new version", "cut release", "publish", "deploy version" |
| `/reflect resume` | "continue", "pick up where", "resume", "last session", "where did we leave off" |

**Superpowers Skills:**
| Skill | Trigger Patterns |
|-------|------------------|
| `brainstorming` | "design", "think through", "explore options", "how should we", "plan out" |
| `systematic-debugging` | "why is this", "investigate", "root cause", "diagnose" |
| `writing-plans` | "write plan", "implementation plan", "step by step", "break down" |
| `test-driven-development` | "write tests first", "tdd", "test driven" |
| `verification-before-completion` | "is it done", "verify", "check if complete", "make sure it works" |

### Step 3: Calculate Confidence Score

```
Base Score Calculation:
─────────────────────
• Exact phrase match:     0.9
• All keywords present:   0.7
• Most keywords (≥50%):   0.5
• Some keywords (≥30%):   0.3
```

### Step 4: Apply Context Boosters

Add to base score based on context:

| Condition | Boost | Applies To |
|-----------|-------|------------|
| Error message/stack trace present | +0.2 | /fix-bug, systematic-debugging |
| Specific file mentioned | +0.1 | /fix-bug, /refactor |
| On feature branch | +0.3 | /create-pr |
| Session files exist | +0.3 | /reflect resume |
| No existing plan | +0.2 | brainstorming |
| Recent code changes | +0.2 | verification-before-completion |
| Test files exist | +0.1 | test-driven-development |

### Step 5: Check Threshold

```
confidenceThreshold = config.intentDetection.confidenceThreshold  # default: 0.7

IF confidence < confidenceThreshold:
    RETURN null  # No suggestion
```

### Step 6: Handle Multiple Matches

If multiple skills match above threshold:
1. Sort by confidence (highest first)
2. If top score exceeds second by > 0.1: suggest top skill
3. Otherwise: present ambiguous match to user

```markdown
## Multiple Skills Match

Your request matches multiple workflows:
1. `/new-feature` (confidence: 0.82) - For adding new functionality
2. `/fix-bug` (confidence: 0.78) - For fixing existing issues

Which would you like to use?
```

### Step 7: Present Suggestion

**Confidence 0.7 - 0.85 (moderate):**

```markdown
This sounds like you want to [detected intent].
The `[skill]` workflow might help - it handles [brief description].

Use `[skill] [extracted args]`? [Y/n]
```

**Confidence > 0.85 (high):**

```markdown
This is a [detected intent] request. I'll use the `[skill]`
workflow which includes:
• [Phase 1]
• [Phase 2]
• [Phase 3]

Proceed with `[skill]`? [Y/n]
```

### Step 8: Handle Response

**User confirms (Y, yes, proceed):**
- Invoke the Skill tool with detected skill
- Extract arguments from original message

**User declines (N, no, skip):**
- Proceed with normal response
- Do not suggest again for this message

**User provides alternative:**
- Honor their explicit choice
- Use their specified skill/approach

### Step 9: Track Statistics

Update session stats (for `/reflect config intent` display):

```json
{
  "session": {
    "suggestionsShown": 5,
    "suggestionsAccepted": 4,
    "suggestionsDenied": 1,
    "averageConfidence": 0.81
  }
}
```

---

## Intent Detection Edge Cases

| Case | Example | Action |
|------|---------|--------|
| **Question vs Request** | "How do I add a feature?" | Answer question, don't suggest workflow |
| **Already In Workflow** | Mid-/new-feature: "also fix this bug" | Note for later, don't interrupt current workflow |
| **Negation** | "Don't create a PR yet" | Detect negation, skip suggestion |
| **Multiple Intent** | "Add feature and fix login bug" | Suggest primary (first mentioned), queue secondary |
| **Vague Request** | "Help with this" | Below threshold, no suggestion |
| **Mixed Signals** | "Should I add a feature?" | Question pattern → answer, don't suggest |

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
│   ├── .dispatch-config.json   # Intelligent dispatch config
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
