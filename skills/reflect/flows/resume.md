# Resume Flow

Handles `/reflect resume`, `/reflect resume E##`, and `/reflect resume T###` commands.

---

## `/reflect resume`

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

## `/reflect resume E##`

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
| T004 | [Name] | ready <- NEXT |
| T005 | [Name] | pending (depends: T004) |
...

### Recent Activity
[from epic progress log]

Continue with T004?
```

---

## `/reflect resume T###`

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

4. **Acquire Lock (IMMEDIATELY)**
   - Set task status to `in_progress` in registry
   - Record session ID and timestamp in lock
   - This happens BEFORE loading context or presenting anything
   - The task is now yours - no other session can take it

5. **Load Minimal Context**
   - Task objective and requirements
   - Continuation context (if status is `continuation`)
   - Files to modify
   - Acceptance criteria

6. **Load Relevant Project Memory**
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

7. **Detect Agent and Load Summary**

   Use the helper script to detect the appropriate agent:

   ```bash
   python3 scripts/helpers/detect_agent.py {task.id}
   ```

   **Example output:**
   ```
   Agent: @security-boss
   Summary: agents/summaries/security-boss.md
   Confidence: high
   Matched: auth, token, session
   ```

   **Then load the summary file** returned by the script (~80-100 tokens).
   This becomes the behavioral guidance for task execution.

   **Fallback (if script unavailable):** Default to `@developer` with `agents/summaries/developer.md`

8. **Present Task Context**

```markdown
## Resuming Task T002: [Task Name]

**Session ID:** {your-session-id}
**Epic:** E01 - [Epic Name]
**Status:** continuation -> in_progress (locked)

### Agent: @developer
**Constraints:** No code without requirements, tests alongside implementation, errors explicit
**Workflow:** Understand -> Plan -> Implement -> Verify -> Complete

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

**Note:** The Agent section shows a condensed version. The full summary was loaded and should guide your execution. Key constraints and workflow from the summary apply throughout this task.

---

## Task Completion (MANDATORY)

**When you finish a task, you MUST complete these steps before moving on:**

1. **Verify Acceptance Criteria**
   - All acceptance criteria must be checked off (- [x])
   - If any criterion cannot be met, document why and set status to `continuation`

2. **Update Task File** (`docs/epics/{epic}/tasks/{task.id}-*.md`)
   - Set `status: completed` in frontmatter
   - Check off all acceptance criteria
   - Check off all requirements
   - Add completion notes under "Implementation Notes"
   - Clear any continuation context

3. **Update Registry** (`docs/tasks/registry.json`)
   - Set task status to `completed`
   - Clear the `lockedBy` field
   - Clear the `lockedAt` field
   - Record completion timestamp

4. **Commit Changes**
   - Commit with message: `feat({epic}): {task.name} [Task-ID: {task.id}]`
   - Or `fix({epic}):` for bug fixes, `refactor({epic}):` for refactors

5. **Update Session File**
   - Add task to completed list
   - Note any handoff information for dependent tasks

**Example Registry Update:**

```json
{
  "tasks": {
    "T002": {
      "status": "completed",
      "lockedBy": null,
      "lockedAt": null,
      "completedAt": "2024-01-15T16:45:00Z",
      "completedBy": "{session-id}"
    }
  }
}
```

**If Task Cannot Be Completed:**

If you encounter blockers that prevent completion:
1. Set status to `continuation` (not `completed`)
2. Document the blocker in the task file under "Continuation Context"
3. Keep the lock OR release it if you won't continue
4. Add blocker to session file for handoff

---

## Context Budget

| Operation | Target | Max |
|-----------|--------|-----|
| Resume (general) | 8k tokens | 15k |
| Resume (epic) | 5k tokens | 10k |
| Resume (task) | 3k tokens | 6k |

This leaves 185k+ tokens for actual work.
