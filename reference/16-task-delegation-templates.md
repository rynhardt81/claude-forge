# Task Delegation Templates

Templates for delegating work to subagents using the Task tool.

---

## Overview

The Task tool spawns **subagents** - separate Claude instances with isolated context. This is useful for:
- Parallel task execution
- Isolating large tasks from main context
- Background work

**Key principle:** Subagents don't see your conversation or CLAUDE.md. You must provide everything they need in the prompt.

---

## When to Use Task Tool vs In-Session Agent

| Scenario | Approach | Reason |
|----------|----------|--------|
| Single task, sequential work | In-session (load summary) | Keeps context together |
| Multiple independent tasks | Task tool (parallel) | Isolated contexts, parallel execution |
| Large task that would consume context | Task tool | Preserves main session capacity |
| Security-critical work | In-session ONLY | Never parallelize security work |

---

## Template: General Task Delegation

Use `subagent_type: "general-purpose"` for implementation work.

```markdown
## Task Assignment: {task_id} - {task_name}

**Session ID:** {parent_session_id}-sub-{n}
**Parent Session:** {parent_session_id}

### Agent: @{agent_name}

{Paste content from agents/summaries/{agent_name}.md}

### Task Details

**Objective:** {task_objective}

**Scope (STRICT - do NOT modify files outside):**
- Directories: {task_scope_directories}
- Files: {task_scope_files}

**Acceptance Criteria:**
{list acceptance criteria}

### Instructions

1. Read and understand the requirements
2. Plan your approach
3. Implement within declared scope ONLY
4. Run tests, lint, type-check
5. Commit with message: `feat({epic_id}): {task_name} [Task-ID: {task_id}]`

### On Completion

Report back with:
- status: "completed" | "blocked" | "partial"
- commits: [list of commit hashes]
- blockers: [if not completed, explain why]
- files_modified: [list of files changed]
```

---

## Template: Developer Task

For general implementation work.

```markdown
## Task Assignment: {task_id} - {task_name}

**Session ID:** {parent_session_id}-dev-{n}

### Agent: @developer

**Constraints:**
- No code without understanding requirements first
- Tests alongside implementation, not after
- Errors explicit, never silent
- Clarity over cleverness

**Workflow:** Understand → Plan → Implement → Verify → Complete

### Task

**Objective:** {task_objective}

**Scope:**
- Directories: {directories}
- Files: {files}

**Acceptance Criteria:**
{criteria}

### Instructions

1. Read existing code in scope to understand patterns
2. Plan implementation approach
3. Write tests and implementation together
4. Run: lint, type-check, tests
5. Self-review for clarity and edge cases
6. Commit: `feat({epic}): {name} [Task-ID: {task_id}]`

### Report

Return:
- status: completed | blocked | partial
- commit: {hash}
- notes: {any issues or decisions made}
```

---

## Template: Quality Engineer Task

For testing and verification work.

```markdown
## Task Assignment: {task_id} - {task_name}

**Session ID:** {parent_session_id}-qa-{n}

### Agent: @quality-engineer

**Constraints:**
- Test behavior, not implementation
- Every bug fix needs a regression test
- Coverage is a metric, not a goal
- If you can't test it, the design is wrong

**Test Pyramid:** Many unit, fewer integration, minimal e2e

### Task

**Objective:** {test_objective}

**Scope:**
- Code to test: {code_paths}
- Test files: {test_paths}

**Acceptance Criteria:**
{criteria}

### Instructions

1. Review code to understand behavior
2. Plan test strategy (unit/integration/e2e balance)
3. Write tests that document expected behavior
4. Include edge cases and error paths
5. Verify: all tests pass, no flaky tests
6. Commit: `test({epic}): {name} [Task-ID: {task_id}]`

### Report

Return:
- status: completed | blocked | partial
- commit: {hash}
- coverage: {coverage change if applicable}
- gaps: {any untested paths}
```

---

## Template: Parallel Batch Delegation

For spawning multiple tasks at once.

```markdown
## Parallel Dispatch: {parallel_group_id}

Spawning {n} tasks in parallel:

### Task 1: {task_id_1}
{Use appropriate template above}

### Task 2: {task_id_2}
{Use appropriate template above}

### Coordination Notes
- Tasks have non-overlapping scopes
- No dependencies between these tasks
- Each commits independently
- Report back when all complete
```

---

## Task Tool Invocation Examples

### Single Task

```
Task tool:
  subagent_type: "general-purpose"
  description: "T015: Add chart component"
  prompt: [Developer template with task details]
  run_in_background: false
```

### Parallel Tasks (Multiple Invocations)

```
Task tool 1:
  subagent_type: "general-purpose"
  description: "T015: Add chart component"
  prompt: [Developer template]
  run_in_background: true

Task tool 2:
  subagent_type: "general-purpose"
  description: "T016: Implement filters"
  prompt: [Developer template]
  run_in_background: true
```

### Exploration Task

```
Task tool:
  subagent_type: "Explore"
  description: "Find auth patterns in codebase"
  prompt: "Search for authentication patterns, middleware, and session handling in this codebase. Report file locations and patterns used."
  run_in_background: false
```

---

## Scope Enforcement

**Critical:** Subagents must not modify files outside their declared scope.

Include this in every prompt:

```markdown
**Scope (STRICT - do NOT modify files outside):**
- Directories: src/components/charts/
- Files: src/types/chart.ts

If you need to modify files outside this scope:
1. STOP
2. Report the need in your response
3. Do NOT make the modification
```

---

## Handling Subagent Results

When a subagent returns:

1. **Check status:**
   - `completed`: Update registry, mark task done
   - `blocked`: Note blocker, potentially reassign
   - `partial`: Set to `continuation`, capture progress

2. **Verify commits:**
   - Check commit exists: `git log --oneline -1 {hash}`
   - Verify commit message format

3. **Update registry:**
   ```json
   {
     "status": "completed",
     "completedAt": "{timestamp}",
     "completedBy": "{subagent_session_id}"
   }
   ```

4. **Check for newly unblocked tasks:**
   - Dependencies may now be met
   - Consider spawning next parallel batch

---

## Security Work: NEVER Delegate in Parallel

Tasks involving security, auth, or payments:
- Must use in-session execution
- Load @security-boss summary
- NEVER run concurrently with other tasks
- Requires focused attention

```markdown
## Security Task - SERIAL EXECUTION ONLY

This task involves {auth/security/payments}.
Execute in main session with full attention.
Do NOT spawn as background task.
Do NOT run other tasks in parallel.
```
