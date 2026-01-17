# Feature Database Dispatch Flow

Handles automatic parallelization of features from the feature database.

---

## When to Run

During `/implement-features` when feature database exists and dispatch is enabled.

**Prerequisites:**
- Feature database exists (`.claude/features/features.db`)
- `.claude/memories/.dispatch-config.json` has `dispatch.featureDatabase.enabled: true`
- At least 2 pending features in database

---

## Step 1: Load Configuration

Read dispatch config and extract:
- `dispatch.featureDatabase.enabled` - Skip if false
- `dispatch.featureDatabase.categoryMatrix` - default, strict, or permissive
- `dispatch.featureDatabase.regressionStrategy` - shared or independent
- `dispatch.featureDatabase.criticalCategories` - Categories that never parallelize (default: A, P)

---

## Step 2: Get Parallelizable Features

Call MCP tool:
```
feature_get_parallelizable(limit=dispatch.maxParallelAgents)
```

Returns:
- `primary` - Highest priority pending feature
- `parallelizable` - Features that can run alongside primary
- `deferred` - Features that cannot parallelize (with reasons)
- `analysis` - Summary of categorization decisions

---

## Step 3: Handle Critical Categories

If primary feature is in critical category (A: Security, P: Payment):
- **DO NOT parallelize** - Critical features require exclusive execution
- Work on primary alone
- Skip dispatch, proceed with single-threaded implementation

---

## Step 4: Validate Parallelization

Review the analysis results:
- Same-category features share files - cannot parallelize
- Different categories with matrix conflicts - cannot parallelize
- Check the deferred list for reasons

---

## Step 5: Execute Dispatch

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

---

## Step 6: Create Parallel Group

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

---

## Step 7: Spawn Sub-Agents

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

---

## Step 8: Monitor Progress

Periodically check group status:
```
feature_get_parallel_status(group_id={group.id})
```

This returns:
- Status of each feature (passing, in_progress)
- Completion summary
- Whether group is complete

---

## Step 9: Run Regression (if configured)

**If `dispatch.featureDatabase.regressionStrategy == "shared"`:**
- Run regression once after ALL features complete
- Main agent handles regression test

**If `dispatch.featureDatabase.regressionStrategy == "independent"`:**
- Each sub-agent runs regression for their own feature
- More safety checks but duplicates work

---

## Step 10: Complete Group

After all features pass and regression passes:
```
feature_complete_parallel_group(
    group_id={group.id},
    regression_passed=true
)
```

---

## Step 11: Continuous Feature Dispatch

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
