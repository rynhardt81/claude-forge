# Task Dispatch Flow

Handles automatic parallelization of tasks from the task registry.

---

## When to Run

After context loading in session protocol, BEFORE starting work.

**Prerequisites:**
- `docs/tasks/registry.json` exists
- `.claude/memories/.dispatch-config.json` has `dispatch.enabled: true`
- At least 2 tasks with status `ready` in registry

---

## Step 1: Run Dispatch Analysis

Use the helper script to analyze parallelizable tasks:

```bash
python3 scripts/helpers/dispatch_analysis.py --json
```

**Example output:**
```json
{
  "dispatch_enabled": true,
  "mode": "automatic",
  "max_agents": 3,
  "primary": {
    "id": "T015",
    "name": "Add chart component",
    "priority": 1,
    "scope": ["src/components/charts/"]
  },
  "parallelizable": [
    {
      "id": "T016",
      "name": "Implement filters",
      "priority": 2,
      "scope": ["src/components/filters/"]
    },
    {
      "id": "T021",
      "name": "Create report template",
      "priority": 1,
      "scope": ["src/reports/"]
    }
  ],
  "deferred": [
    {
      "id": "T017",
      "name": "Update chart styles",
      "reason": "scope_conflict",
      "conflicts_with": "T015"
    }
  ]
}
```

**If `dispatch_enabled` is false or no parallelizable tasks:** Skip dispatch, proceed normally.

---

## Step 2: Execute Dispatch

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

---

## Step 3: Spawn Sub-Agents

For each parallelizable task, generate the prompt using the helper script:

```bash
python3 scripts/helpers/prepare_task_prompt.py {task.id} --parent-session {session-id} --subagent-num {n}
```

**Example:**
```bash
python3 scripts/helpers/prepare_task_prompt.py T016 --parent-session 20240117-143022-a7x9 --subagent-num 1
```

The script outputs a complete prompt including:
- Task details and scope
- Agent summary (auto-detected)
- Session protocol instructions
- Completion requirements

**Then invoke the Task tool:**

```
Task tool invocation:
- subagent_type: "general-purpose"
- description: "Task {task.id}: {task.name}"
- prompt: [output from prepare_task_prompt.py]
- run_in_background: true
```

---

## Step 4: Update Registry

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

---

## Step 5: Monitor and Continue

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
   - Run `python3 scripts/helpers/dispatch_analysis.py --json` again
   - Spawn new sub-agents for parallelizable work

This creates a continuous flow where completing one task can unlock others for parallel execution.
