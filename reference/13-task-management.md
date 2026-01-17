# Task Management

This document provides the complete task and epic management system for Claude Forge.

---

## Core Principle

**NO CODE without epics and tasks. This is a HARD GATE (Gate 2).**

Before ANY development work, you MUST have:

1. `docs/prd.md` - Product requirements document
2. `docs/tasks/registry.json` - Task registry with epics and tasks
3. `docs/epics/E##-*/` - Epic directories with task files

If these don't exist → Run `/new-project --current` FIRST.

---

## The Rule

```
YOU CANNOT:
- "Just add a quick feature" without a task
- "Fix this small bug" without a task
- "Make this change" without a task

ALL work must be tracked. No exceptions.
```

---

## Directory Structure

```
docs/
├── prd.md                      # Product requirements document
├── tasks/
│   └── registry.json           # Central task/epic registry
└── epics/
    ├── E01-authentication/
    │   ├── E01-authentication.md      # Epic file
    │   └── tasks/
    │       ├── T001-setup-auth.md     # Task files
    │       ├── T002-login-form.md
    │       └── T003-session-mgmt.md
    ├── E02-dashboard/
    │   ├── E02-dashboard.md
    │   └── tasks/
    │       └── ...
    └── ...
```

---

## Registry Format

The `docs/tasks/registry.json` contains:

```json
{
  "epics": [
    {
      "id": "E01",
      "name": "Authentication",
      "status": "in_progress",
      "tasks": ["T001", "T002", "T003"]
    }
  ],
  "tasks": [
    {
      "id": "T001",
      "epic": "E01",
      "name": "Setup authentication infrastructure",
      "status": "completed",
      "dependencies": [],
      "priority": 1
    },
    {
      "id": "T002",
      "epic": "E01",
      "name": "Implement login form",
      "status": "ready",
      "dependencies": ["T001"],
      "priority": 2
    }
  ]
}
```

---

## Task States

| Status | Description | Can Work On? |
|--------|-------------|--------------|
| `pending` | Dependencies not met yet | No |
| `ready` | All dependencies complete, can be started | **Yes** |
| `in_progress` | Currently being worked on (locked) | Only by lock holder |
| `continuation` | Partially complete, needs resume | **Yes** |
| `completed` | Done | No |

### State Transitions

```
pending → ready (when dependencies complete)
ready → in_progress (when locked by session)
in_progress → completed (when work done)
in_progress → continuation (when blocked/paused)
continuation → in_progress (when resumed)
```

---

## Dependencies

### Epic-Level Dependencies

E02 depends on E01 completing first:
```json
{
  "id": "E02",
  "dependencies": ["E01"]
}
```

### Task-Level Dependencies

T002 depends on T001 within same epic:
```json
{
  "id": "T002",
  "dependencies": ["T001"]
}
```

### Cross-Epic Dependencies

T010 may depend on T003 from different epic:
```json
{
  "id": "T010",
  "epic": "E02",
  "dependencies": ["T003"]  // T003 is in E01
}
```

---

## Task Locking

### How Locking Works

When you run `/reflect resume T###`:
1. Task status changes to `in_progress`
2. Lock is recorded with session ID
3. Other sessions cannot work on this task

### Lock Information

```json
{
  "id": "T002",
  "status": "in_progress",
  "lock": {
    "session": "20240115-143022-a7x9",
    "since": "2024-01-15T14:30:22Z"
  }
}
```

### Stale Locks

A lock is considered stale if:
- `lockTimeout` (default 1 hour) has passed
- The locking session is no longer active

Stale locks can be forcibly unlocked with `/reflect unlock T###`.

---

## Parallel Work

Multiple sessions can work on independent tasks simultaneously:

```
Session 1: /reflect resume T001  # Works on authentication setup
Session 2: /reflect resume T010  # Works on dashboard (if no deps on T001)
```

The registry and session files prevent conflicts.

### What CAN Parallelize

- Tasks in different epics with no cross-dependencies
- Tasks in same epic with no mutual dependencies
- Tasks with non-overlapping file scopes

### What CANNOT Parallelize

- Tasks with dependency relationship
- Tasks modifying same files
- Security (A) or Payment (P) category tasks (in autonomous mode)

---

## Creating Tasks

### At Project Start

Use `/new-project` which invokes @scrum-master to:
1. Read the PRD
2. Create epics for major features
3. Break epics into atomic tasks
4. Set dependencies

### Mid-Project (New Work)

When new work arises that doesn't fit existing tasks:

1. **DO NOT** just start coding
2. **DO** invoke @scrum-master:
   ```
   @scrum-master: Create new task for [description] in [epic]
   ```
3. **THEN** use `/reflect resume T###` to work on it

### Task Requirements

Every task MUST have:
- Unique ID (T###)
- Epic association
- Clear name/description
- Status
- Dependencies (may be empty)
- Priority

---

## Epics

### Epic Requirements

**Every epic MUST have tasks. Epics without tasks are invalid.**

```
VALID:
docs/epics/E01-authentication/
├── E01-authentication.md
└── tasks/
    ├── T001-setup-auth.md      ← At least one task
    ├── T002-login-form.md
    └── T003-session-mgmt.md

INVALID:
docs/epics/E01-authentication/
└── E01-authentication.md       ← No tasks directory = INVALID
```

### Epic Creation

When creating an epic, @scrum-master MUST:
1. Create the epic file
2. Create the tasks directory
3. Create at least one task
4. Register in registry.json

---

## Task File Format

```markdown
# T001 - Setup Authentication Infrastructure

**Epic**: E01 - Authentication
**Status**: ready
**Priority**: 1
**Dependencies**: none

## Description

Set up the core authentication infrastructure including...

## Acceptance Criteria

- [ ] JWT token generation works
- [ ] Token validation middleware implemented
- [ ] Session storage configured

## Technical Notes

- Use library X for JWT
- Store sessions in Redis

## Files to Modify

- `src/lib/auth/`
- `src/middleware/`
```

---

## Working with Tasks

### View Status

```
/reflect status           # Show all epics and tasks
/reflect status --ready   # Show only ready tasks
/reflect status --locked  # Show locked tasks
```

### Resume Task

```
/reflect resume T002      # Lock and start working on T002
```

### Complete Task

After finishing work:
1. Ensure all acceptance criteria met
2. Commit with task ID: `git commit -m "T002: Implement login form"`
3. **Update the task file** (`docs/epics/E##-*/tasks/T###-*.md`):
   - Set `status: completed` in frontmatter
   - Check off all acceptance criteria (change `- [ ]` to `- [x]`)
   - Check off all requirements
   - Add notes under "Implementation Notes" if needed
   - Clear any continuation context
4. **Update the registry** (`docs/tasks/registry.json`):
   - Set task `status` to `"completed"`
   - Clear the `lock` field

**BOTH files must be updated.** The registry is the source of truth for status, but the task file provides documentation and audit trail.

### Handle Blocked Task

If a task cannot be completed:
1. Document the blocker in the task file
2. Set status to `continuation`
3. Move to next ready task: `/reflect resume T###`

---

## Task Failure Handling

### After 3 Failed Attempts

1. Set status to `continuation`
2. Document blocker in task file
3. Move to next ready task
4. The blocked task can be resumed later

### Regression Failure

If regression tests fail:
1. **STOP implementation immediately**
2. Identify the regression
3. Fix before continuing
4. Never proceed with failing regressions

---

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `lockTimeout` | 3600 | Seconds before lock is stale (1 hour) |
| `allowManualUnlock` | true | Allow `/reflect unlock` command |
| `maxParallelAgents` | 3 | Max concurrent task locks |
| `autoAssignNextTask` | true | Auto-suggest next task after completion |

Configure via `/reflect config`.

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `/reflect status` | Show task/epic overview |
| `/reflect status --ready` | Show tasks available to work on |
| `/reflect status --locked` | Show locked tasks |
| `/reflect resume T###` | Resume specific task |
| `/reflect resume E##` | Resume epic, suggests next task |
| `/reflect unlock T###` | Force unlock a stale task |
