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

---

## Integration Test Scenarios

### 1. Task Registry Dispatch Tests

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| No ready tasks | All tasks pending/completed | Skip dispatch, proceed normally |
| Single ready task | 1 ready task | Skip dispatch (minReadyTasks=2) |
| Multiple independent | 3+ ready, no conflicts | Propose dispatch with N-1 sub-agents |
| Scope conflict | Tasks with overlapping directories | Defer conflicting tasks |
| Priority ordering | Mixed priorities | Highest priority as main agent |
| Dispatch disabled | config.dispatch.enabled=false | Skip dispatch entirely |
| Confirm mode | config.dispatch.mode="confirm" | Show proposal, wait for approval |
| Automatic mode | config.dispatch.mode="automatic" | Spawn immediately, notify user |

### 2. Feature Database Dispatch Tests

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| Critical category | Primary feature is Category A | No parallelization, work alone |
| Same category | Multiple Category F features | Serialize, defer non-primary |
| Different categories | F, I, S features | Parallelize per matrix |
| Category matrix | B + C features | Check matrix, may parallelize |
| Shared regression | regressionStrategy="shared" | One regression at end |
| Independent regression | regressionStrategy="independent" | Each agent runs regression |

**Category Matrix Test Cases:**
```
A + anything = No (Critical)
P + anything = No (Critical)
F + F = No (Same category)
F + I = Yes (Different, compatible)
F + S = Yes (Different, compatible)
I + S = Yes (Both low-risk)
```

### 3. Intent Detection Tests

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| Exact phrase | "fix bug in login" | /fix-bug (0.9 confidence) |
| Keywords only | "broken authentication" | /fix-bug (0.7+ confidence) |
| Question pattern | "How do I add a feature?" | No suggestion (question) |
| Explicit command | "/fix-bug the login" | Skip detection (explicit) |
| Negation | "don't create a PR yet" | No suggestion (negation) |
| Multiple matches | "add feature to fix bug" | Ambiguous, present options |
| Below threshold | "help with this" | No suggestion (low confidence) |
| Context boost | Error + "investigate" | +0.2 boost for debugging |

**Pattern Matching Test Cases:**
```
"Let's add dark mode to the app"
  → /new-feature (0.85+ confidence)

"The login form is broken"
  → /fix-bug (0.82+ confidence)

"Continue where we left off"
  → /reflect resume (0.9+ confidence with session files)

"Think through the architecture"
  → brainstorming (0.8+ confidence)
```

### 4. End-to-End Integration Tests

| Scenario | Steps | Expected Behavior |
|----------|-------|-------------------|
| Session start with dispatch | 1. Start session<br>2. Registry has ready tasks<br>3. Dispatch enabled | Dispatch proposal shown after step 6 |
| Feature implementation | 1. /implement-features<br>2. Multiple pending features | Feature dispatch analysis, parallel group created |
| Intent + dispatch | 1. "Add new dashboard feature"<br>2. Task registry has ready tasks | Intent suggestion first, then dispatch on approval |
| Continuous dispatch | 1. Complete task<br>2. New task becomes ready | Re-analyze, spawn if applicable |

---

## Running Tests

### Manual Verification

1. **Setup test project:**
   ```bash
   mkdir test-dispatch && cd test-dispatch
   cp ../tests/dispatch/sample-registry.json docs/tasks/registry.json
   cp ../templates/.dispatch-config.json .claude/memories/
   ```

2. **Test Task Dispatch:**
   ```
   /reflect resume
   # Verify: Dispatch analysis shown
   # Verify: Correct tasks proposed
   ```

3. **Test Feature Dispatch:**
   ```
   /implement-features --parallel
   # Verify: Category analysis correct
   # Verify: Parallel group created
   ```

4. **Test Intent Detection:**
   - Send: "Let's add a search feature"
   - Verify: `/new-feature` suggested
   - Send: "How do I add tests?"
   - Verify: No suggestion (question pattern)

### Automated Checks

For the MCP server tools, use the test script:
```bash
cd mcp-servers/feature-tracking
python -m pytest tests/  # When tests are added
```

---

## Verification Checklist

Before marking Phase 5 complete:

- [ ] CLAUDE.md has Step 7 (Dispatch Analysis) in session protocol
- [ ] Session template has dispatch analysis section
- [ ] Reference doc has complete algorithms
- [ ] Reflect skill has all three flows (task, feature, intent)
- [ ] MCP server has all dispatch tools working
- [ ] Config file schema is complete
- [ ] Quick toggle commands work (/reflect dispatch on/off)
- [ ] Preset configurations apply correctly
