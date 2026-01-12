# Dispatch Testing

This directory contains sample data for testing the Intelligent Dispatch System.

## Sample Registry

The `sample-registry.json` demonstrates various dispatch scenarios:

### Task Status Distribution

| Task | Status | Dependencies | Scope | Dispatch Status |
|------|--------|--------------|-------|-----------------|
| T001 | completed | - | src/auth/ | - |
| T002 | completed | T001 | src/components/auth/ | - |
| T003 | completed | T001 | src/auth/session/ | - |
| T004 | **ready** | T001, T003 | src/tests/auth/ | Independent |
| T005 | pending | T002, T003, T004 | src/auth/, src/components/auth/ | Blocked |
| T006 | **ready** | - | src/components/dashboard/ | Independent |
| T007 | **ready** | - | src/components/charts/ | Independent |
| T008 | **ready** | T006 | src/components/dashboard/filters/ | Scope conflict with T006 |

### Expected Dispatch Analysis

When running dispatch analysis on this registry with `maxParallelAgents: 3`:

1. **Ready tasks found:** T004, T006, T007, T008

2. **Dependency check:**
   - T004: Independent (deps T001, T003 completed)
   - T006: Independent (no deps)
   - T007: Independent (no deps)
   - T008: Depends on T006 (T006 in ready pool, so NOT independent)

3. **Scope conflict check:**
   - T008 scope `src/components/dashboard/filters/` is inside T006 scope `src/components/dashboard/`
   - If T006 is selected, T008 must be deferred

4. **Proposed dispatch:**
   - Main agent: T006 (Priority 1, Display category)
   - Sub-agent 1: T004 (Priority 2, Auth tests)
   - Sub-agent 2: T007 (Priority 2, Analytics charts)
   - Deferred: T008 (scope conflict with T006)

### How to Test

1. Copy `sample-registry.json` to `docs/tasks/registry.json` in a test project
2. Run `/reflect resume`
3. Verify the dispatch analysis matches expected results
4. Confirm/deny sub-agent spawn based on dispatch.mode setting

### Scenarios Demonstrated

1. **Independent tasks** - T004, T006, T007 have no dependencies on each other
2. **Scope conflicts** - T008 conflicts with T006 due to overlapping directories
3. **Priority ranking** - T006 (Priority 1) selected as main agent
4. **Pending tasks** - T005 not eligible (dependencies not met)
5. **Category independence** - Tasks from different categories (A, F, K) can parallelize
