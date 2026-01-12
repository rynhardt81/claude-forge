# Implement Features Skill

## Purpose

The `/implement-features` skill orchestrates the incremental implementation of features from the feature database. It manages the implementation loop: get feature → regression test → implement → verify → mark passing → commit → repeat.

## Invocation

```
/implement-features
/implement-features --mode=<standard|yolo|hybrid>
/implement-features --resume
/implement-features --start-from=<feature-id>
/implement-features --parallel
/implement-features --parallel --max-agents=<n>
```

**Parameters:**
- `--mode=standard` - Full browser testing (default)
- `--mode=yolo` - Lint only, no browser tests (rapid prototyping)
- `--mode=hybrid` - Browser tests for critical categories only
- `--resume` - Resume from last in-progress feature
- `--start-from=<id>` - Start from specific feature ID
- `--parallel` - Enable parallel feature dispatch (uses dispatch config)
- `--max-agents=<n>` - Override max parallel agents (default: from config)

## Overview

This skill is invoked after `/new-project` has created a feature database. It implements features one at a time, ensuring:
1. Regression testing before each new feature
2. Proper routing to specialized agents
3. Quality verification before marking complete
4. Git commits after each successful feature
5. Checkpoints every 10 features

## Workflow Phases

### Phase 1: Session Initialization
- Query `feature_get_stats()` to understand current state
- Read progress notes for context from previous sessions
- Check for in-progress features (cleanup if needed)
- Display session summary

### Phase 1.5: Dispatch Analysis (if --parallel or dispatch.enabled)
- Load dispatch configuration from `.claude/memories/.dispatch-config.json`
- Call `feature_get_parallelizable(limit=maxAgents)` to find parallel work
- If parallelizable features found:
  - Confirm with user (if `dispatch.mode == "confirm"`)
  - Create parallel group via `feature_create_parallel_group()`
  - Spawn sub-agents for parallelizable features
  - Main agent continues with primary feature
- See "Parallel Execution Mode" section below for full details

### Phase 2: Feature Loop
For each feature:
1. Get next feature: `feature_get_next()`
2. Mark in-progress: `feature_mark_in_progress(id)`
3. Run regression tests on 1-2 passing features
4. Route to appropriate agent(s) by category
5. Implement feature
6. Verify feature (based on testing mode)
7. Mark passing: `feature_mark_passing(id)`
8. Git commit with feature ID
9. Check if checkpoint needed

### Phase 3: Checkpoint (Every 10 Features)
- Display progress summary
- Show last 5 completed features
- Show next 5 pending features
- Ask user: Continue / Pause / Adjust

### Phase 4: Session End
- Update progress notes
- Display session summary
- Commit progress notes
- Exit gracefully

## Execution Flow

```mermaid
graph TD
    A[/implement-features invoked] --> B[Phase 1: Session Init]
    B --> C[Query feature_get_stats]
    C --> D{Features remaining?}
    D -->|No| E[All features complete!]
    D -->|Yes| F[Phase 2: Feature Loop]

    F --> G[feature_get_next]
    G --> H[feature_mark_in_progress]
    H --> I[Run regression tests]
    I --> J{Regression pass?}
    J -->|No| K[Fix regression first]
    J -->|Yes| L[Route to agent by category]

    L --> M[@developer implements]
    M --> N{Testing mode?}
    N -->|Standard| O[@quality-engineer browser test]
    N -->|YOLO| P[Lint + type check only]
    N -->|Hybrid| Q{Critical category?}
    Q -->|Yes| O
    Q -->|No| P

    O --> R{Tests pass?}
    P --> R
    R -->|No| S[Fix and retry]
    R -->|Yes| T[feature_mark_passing]

    T --> U[Git commit]
    U --> V{Checkpoint?}
    V -->|Yes| W[Phase 3: Checkpoint]
    V -->|No| X{More features?}

    W --> Y{User choice}
    Y -->|Continue| X
    Y -->|Pause| Z[Phase 4: Session End]
    Y -->|Adjust| AA[Re-prioritize features]
    AA --> X

    X -->|Yes| G
    X -->|No| E

    K --> AB[Report to user]
    S --> M
```

## Phase Details

See companion files:
- `PHASES.md` - Detailed phase instructions
- `REGRESSION.md` - Regression testing protocol

## Agent Routing

Features are routed to agents based on their category code:

| Category | Code | Primary Agent | Testing |
|----------|------|---------------|---------|
| Security & Authentication | A | @security-boss + @developer | Browser (all modes) |
| Navigation & Routing | B | @developer | Browser (standard) |
| Data Management (CRUD) | C | @developer + @api-tester | Browser (standard/hybrid) |
| Workflow & User Actions | D | @developer + @quality-engineer | Browser (standard/hybrid) |
| Forms & Input Validation | E | @developer | Browser (standard) |
| Display & List Views | F | @developer | Browser (standard) |
| Search & Filtering | G | @developer | Browser (standard) |
| Notifications & Alerts | H | @developer | Browser (standard) |
| Settings & Configuration | I | @developer | Lint only |
| Integration & APIs | J | @developer + @api-tester | Browser (standard) |
| Analytics & Reporting | K | @developer | Lint only |
| Admin & Management | L | @developer + @security-boss | Browser (standard) |
| Performance & Caching | M | @performance-enhancer | Lint only |
| Accessibility (a11y) | N | @developer | Browser (standard) |
| Error Handling | O | @developer | Browser (standard) |
| Payment & Billing | P | @security-boss + @developer | Browser (all modes) |
| Communication (Email/SMS) | Q | @developer | Lint only |
| Media & File Handling | R | @developer | Browser (standard) |
| Documentation & Help | S | @developer | Lint only |
| UI Polish & Animations | T | @whimsy + @developer | Lint only |

## MCP Tool Usage

### Session Start
```python
# Get current progress
stats = feature_get_stats()
# Returns: { passing: 45, in_progress: 0, total: 92, percentage: 48.9 }
```

### Feature Cycle
```python
# Get next feature
feature = feature_get_next()
# Returns: { id, priority, category, name, description, steps, passes, in_progress }

# Lock feature
feature_mark_in_progress(feature['id'])

# Get regression features
regression = feature_get_for_regression(limit=2)
# Returns: { features: [...], count: 2 }

# After implementation
feature_mark_passing(feature['id'])
```

### Handling Issues
```python
# Skip blocked feature
feature_skip(feature['id'])
# Moves to end of queue

# Clear stuck feature
feature_clear_in_progress(feature['id'])
```

## Testing Modes

### Standard Mode
- Full browser automation for ALL features
- Regression tests before EVERY feature
- Screenshots saved for each test
- Highest quality, slowest speed
- ~5-10 minutes per feature

### YOLO Mode
- Lint + type-check only
- NO regression tests
- NO browser automation
- Fastest speed, manual testing required
- ~1-2 minutes per feature

### Hybrid Mode
Browser testing for critical categories only:
- **Always Browser Test:** A (Security), C (Data), D (Workflow), P (Payment)
- **Lint Only:** B, E-O, Q-T

## Parallel Execution Mode

When `--parallel` is specified or `dispatch.featureDatabase.enabled` is true, features can be implemented in parallel using sub-agents.

### How It Works

1. **Analysis Phase**: Call `feature_get_parallelizable()` to find features that can safely run in parallel based on category compatibility
2. **Group Creation**: Create a parallel group with `feature_create_parallel_group()`
3. **Agent Dispatch**: Spawn sub-agents for parallelizable features
4. **Monitoring**: Track progress with `feature_get_parallel_status()`
5. **Completion**: Mark group complete with `feature_complete_parallel_group()`

### Category Parallelization Rules

| Rule | Description |
|------|-------------|
| Critical Categories | A (Security) and P (Payment) **never** parallelize |
| Same Category | Features in same category run sequentially (shared files) |
| Different Categories | Checked against compatibility matrix |

### Parallel Workflow

```
/implement-features --parallel

Session Init:
├─ Progress: 45/92 features (48.9%)
└─ Dispatch Analysis...

Dispatch Proposal:
├─ Primary (main agent): F-46 Product grid (Category F)
├─ Sub-agent 1: F-48 User preferences (Category I)
├─ Sub-agent 2: F-49 Help docs (Category S)
└─ Deferred: F-47 Product list (Category F - same as primary)

[Creating parallel group...]
├─ Group ID: 5
├─ Spawning 2 sub-agents...
└─ Main agent continuing with F-46

[Parallel execution in progress...]
├─ Main: F-46 implementing...
├─ Agent 1: F-48 implementing...
└─ Agent 2: F-49 implementing...

[Group complete - running shared regression...]
└─ All features passing ✓
```

### MCP Tools for Parallel Execution

```python
# Find parallelizable features
result = feature_get_parallelizable(limit=3)
# Returns: { primary, parallelizable, deferred, analysis }

# Create parallel group
group = feature_create_parallel_group(
    feature_ids=[46, 48, 49],
    session_id="session-20260112-abc"
)
# Returns: { group, features }

# Monitor progress
status = feature_get_parallel_status(group_id=5)
# Returns: { group, features, summary, is_complete }

# Complete group after regression
feature_complete_parallel_group(group_id=5, regression_passed=True)

# Abort if needed
feature_abort_parallel_group(group_id=5)
```

### Regression Strategy

Configured via `dispatch.featureDatabase.regressionStrategy`:

- **shared** (default): Run regression once after ALL parallel features complete
- **independent**: Each sub-agent runs regression for their own feature

### Continuous Dispatch

After completing a parallel group:
1. Call `feature_get_parallelizable()` again
2. If more parallelizable features found, spawn new group
3. Continue until all features are done or only serial work remains

## Checkpoint Protocol

Every 10 features:

```markdown
## Checkpoint Report

**Progress:** 40/92 features (43.5%)
**Session:** 10 features completed

### Last 5 Completed
1. [ID-36] User profile update - Category D ✓
2. [ID-37] Password reset flow - Category A ✓
3. [ID-38] Email notifications - Category H ✓
4. [ID-39] Search results page - Category G ✓
5. [ID-40] Filter by category - Category G ✓

### Next 5 Pending
1. [ID-41] Sort by date - Category G
2. [ID-42] Pagination controls - Category F
3. [ID-43] Loading states - Category F
4. [ID-44] Error boundaries - Category O
5. [ID-45] 404 page - Category O

### Options
1. **Continue** - Resume implementation
2. **Pause** - Save state and exit
3. **Adjust** - Re-prioritize features
4. **Review** - Deep-dive specific features
```

## Git Commit Strategy

Each feature gets its own commit:

```bash
git commit -m "feat(category): feature name

- Implementation detail 1
- Implementation detail 2

Feature-ID: 45
Testing: Standard mode - browser verified"
```

### Commit Message Format
```
feat(<category>): <short description>

<bullet points of changes>

Feature-ID: <id>
Testing: <mode> - <verification method>
```

## Session Continuity

### Progress Tracking
1. **Feature Database** - Source of truth for feature status
2. **Git Commits** - Code persistence
3. **Progress Notes** - Human-readable session summaries

### Resume Protocol
When resuming:
1. Read progress notes
2. Query `feature_get_stats()`
3. Check for in-progress features (may need cleanup)
4. Review last 3 git commits
5. Continue with next feature

### Progress Notes Location
`.claude/memories/progress-notes.md`

## Error Handling

### Regression Failure
1. STOP implementation
2. Report failing feature and step
3. Show recent commits
4. Options: Fix regression, Revert commit, Skip

### Implementation Failure
1. Attempt up to 3 times
2. If still failing: Skip feature
3. Log blocker in progress notes
4. Continue with next feature

### Session Crash
On unexpected termination:
1. Check for in-progress features
2. Clear stale locks: `feature_clear_in_progress(id)`
3. Review last commit
4. Resume normally

## Success Criteria

A feature is marked passing when:
- ✅ Code compiles without errors
- ✅ Lint passes with no errors
- ✅ Type check passes
- ✅ All feature steps verified (mode-dependent)
- ✅ No regressions introduced
- ✅ Git commit successful

## Integration Points

### With `/new-project`
- Expects feature database to exist
- Uses same testing mode configuration
- Continues from Phase 5 of new-project

### With Progress Notes
- Reads context from previous sessions
- Writes summary after each session
- Tracks blockers and decisions

### With Security Model
- All bash commands validated against allowlist
- Uses pre-tool-use hook

## Examples

### Example 1: Standard Implementation Session
```
User: /implement-features

Session Initialization:
├─ Progress: 45/92 features (48.9%)
├─ Last session: 8 features completed
├─ No in-progress features
└─ Ready to continue

Feature Loop:
├─ Feature 46: [D] Add item to shopping cart
│  ├─ Regression: ID-23 (login) ✓, ID-31 (products) ✓
│  ├─ @developer implements
│  ├─ @quality-engineer browser test ✓
│  ├─ Commit: feat(workflow): add item to shopping cart
│  └─ Marked passing ✓
├─ Feature 47: [D] Remove item from cart
│  └─ ... (similar process)
├─ ... (8 more features)
└─ Feature 55: [F] Cart summary display

Checkpoint (50/92):
├─ Session: 10 features completed
├─ User choice: Continue
└─ Resuming...
```

### Example 2: YOLO Mode Session
```
User: /implement-features --mode=yolo

Session Initialization:
├─ Mode: YOLO (lint only)
├─ Progress: 0/35 features (0%)
└─ Ready to start

Feature Loop (fast):
├─ Feature 1: [A] User registration
│  ├─ @developer implements
│  ├─ npm run lint ✓
│  ├─ npm run typecheck ✓
│  ├─ Commit: feat(auth): user registration
│  └─ Marked passing ✓
├─ ... (rapid implementation)
└─ Feature 35: [T] Loading animations

Session Complete:
├─ All 35 features implemented
├─ Time: ~1.5 hours
└─ Manual testing recommended
```

### Example 3: Handling Blocked Feature
```
Feature 67: [J] Stripe webhook integration

Issue: Stripe API credentials not configured

Action:
├─ feature_skip(67) - moved to end of queue
├─ Blocker logged in progress notes
├─ Continue with Feature 68
└─ Flag for manual review at checkpoint
```

## Notes

- This skill is designed for projects initialized with `/new-project`
- For manual feature tracking, use the orchestrator commands directly
- The skill will pause at checkpoints for user approval
- Progress is always saved - sessions can be resumed anytime
- Maximum recommended session: 20-30 features

## See Also

- `../new-project/SKILL.md` - Project initialization (prerequisite)
- `../../agents/orchestrator.md` - Workflow coordination
- `../../agents/developer.md` - Implementation details
- `../../mcp-servers/feature-tracking/README.md` - MCP tool reference
