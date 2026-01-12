# Intelligent Dispatch System Design

**Date:** 2026-01-12
**Status:** Approved
**Session:** 20260112-133143-abe8

---

## Executive Summary

This design introduces two interconnected capabilities to the Claude Forge framework:

1. **Automatic Sub-Agent Dispatch** - Analyzes task dependencies and feature categories to automatically parallelize work across multiple sub-agents
2. **Natural Language Intent Detection** - Detects user intent from natural language and suggests appropriate skills without requiring explicit `/slash` commands

Both systems are configurable, defaulting to automatic dispatch with skill suggestions requiring user confirmation.

---

## 1. Architecture Overview

**Core Principle:** Intelligent dispatch is a framework behavior, not a skill to invoke. It runs automatically based on configuration.

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTELLIGENT DISPATCH SYSTEM                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐    │
│  │   CLAUDE.md │───▶│  Core Rules  │───▶│  Always Active  │    │
│  │  (minimal)  │    │  & Triggers  │    │  (no invocation)│    │
│  └─────────────┘    └──────────────┘    └─────────────────┘    │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              reference/11-intelligent-dispatch.md        │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  • Task dependency analysis algorithm                    │    │
│  │  • Feature parallelization rules                         │    │
│  │  • Natural language pattern definitions                  │    │
│  │  • Configuration schema                                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              .claude/memories/.dispatch-config.json      │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  • autoDispatch: "automatic" | "confirm"                 │    │
│  │  • maxParallelAgents: 3                                  │    │
│  │  • intentDetection: "suggest" | "auto" | "off"           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### File Locations

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Core dispatch rules (trigger points, basic flow) |
| `reference/11-intelligent-dispatch.md` | Detailed algorithms and patterns |
| `.claude/memories/.dispatch-config.json` | Runtime configuration |

---

## 2. Task Registry Dispatch

**Trigger Points:** At `/reflect resume` and after each task completion.

### 2.1 Analysis Algorithm

```
┌─────────────────────────────────────────────────────────────────┐
│                 TASK DEPENDENCY ANALYSIS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Input: registry.json + current session scope                    │
│                                                                  │
│  Step 1: Get all tasks with status "ready"                       │
│          (dependencies met, not locked)                          │
│                                                                  │
│  Step 2: Build dependency graph                                  │
│          T001 ──► T002 ──► T004                                  │
│                     │                                            │
│          T003 ──────┘      T005 (independent)                    │
│                            T006 (independent)                    │
│                                                                  │
│  Step 3: Identify independent clusters                           │
│          Cluster A: [T004] (depends on T002)                     │
│          Cluster B: [T005] (no deps on active work)              │
│          Cluster C: [T006] (no deps on active work)              │
│                                                                  │
│  Step 4: Filter by scope compatibility                           │
│          - Check directory overlap                               │
│          - Check file conflicts                                  │
│          - Exclude tasks that would conflict                     │
│                                                                  │
│  Step 5: Rank by priority and category                           │
│          - Higher priority first                                 │
│          - Group same-category for efficiency                    │
│                                                                  │
│  Output: Parallelizable task sets                                │
│          Set 1: [T005, T006] - can run together                  │
│          Set 2: [T004] - must wait for T002                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Dispatch Flow

```
User: /reflect resume E01
           │
           ▼
┌─────────────────────────┐
│ Session Protocol        │
│ (create session file)   │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Load registry.json      │
│ Analyze dependencies    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│ Found 3 parallelizable  │────▶│ Config: autoDispatch?   │
│ tasks: T005, T006, T008 │     └───────────┬─────────────┘
└─────────────────────────┘                 │
                              ┌─────────────┴─────────────┐
                              │                           │
                         "automatic"                  "confirm"
                              │                           │
                              ▼                           ▼
                    ┌─────────────────┐       ┌─────────────────────┐
                    │ Spawn agents    │       │ "I can parallelize: │
                    │ immediately     │       │  - T005: Auth tests │
                    └─────────────────┘       │  - T006: API docs   │
                                              │  - T008: Config     │
                                              │ Proceed?" [Y/n]     │
                                              └──────────┬──────────┘
                                                         │
                                                    User: Y
                                                         │
                                                         ▼
                                              ┌─────────────────┐
                                              │ Spawn agents    │
                                              └─────────────────┘
```

### 2.3 Sub-Agent Spawn Template

Each spawned agent receives:

```markdown
## Task Assignment: T005 - Write Authentication Tests

**Session ID:** {parent-session-id}-agent-1
**Parent Session:** {parent-session-id}
**Scope:** src/tests/auth/

### Task Details
[Loaded from T005 task file]

### Context
- Epic: E01 - Authentication
- Dependencies: T001 (completed), T003 (completed)
- Acceptance Criteria: [from task file]

### Constraints
- Only modify files in declared scope
- Commit after completion with task ID
- Report back: success | blocked | partial

### On Completion
1. Mark T005 as completed in registry
2. Notify parent session
3. Trigger continuous dispatch check
```

### 2.4 Continuous Dispatch

After task completion, re-analyze for newly unblocked tasks:

```
Agent completes T005
        │
        ▼
┌─────────────────────────┐
│ Update registry:        │
│ T005.status = completed │
└───────────┬─────────────┘
        │
        ▼
┌─────────────────────────┐
│ Re-analyze dependencies │
│ Did T005 unblock others?│
└───────────┬─────────────┘
        │
        ▼
┌─────────────────────────┐
│ T009 now ready          │────▶ Apply dispatch flow again
│ (was waiting on T005)   │      (automatic or confirm)
└─────────────────────────┘
```

---

## 3. Feature Database Dispatch

**Trigger Points:** At `/implement-features` start and after each feature completion.

### 3.1 Feature Parallelization Rules

Unlike task registry (explicit dependencies), feature database uses implicit parallelization rules:

```
┌─────────────────────────────────────────────────────────────────┐
│              FEATURE PARALLELIZATION ANALYSIS                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Rule 1: Category Independence                                   │
│  ─────────────────────────────                                   │
│  Features in DIFFERENT categories can often parallelize:         │
│                                                                  │
│    Category I (Settings)  ──┬──▶  Can run in parallel           │
│    Category S (Docs)      ──┤     (no shared files)             │
│    Category K (Analytics) ──┘                                    │
│                                                                  │
│  Rule 2: Same-Category Serialization                             │
│  ───────────────────────────────────                             │
│  Features in SAME category usually share files:                  │
│                                                                  │
│    F-42: Product grid     ──┬──▶  Must serialize                │
│    F-43: Product list     ──┘     (both touch ProductView.tsx)  │
│                                                                  │
│  Rule 3: Priority Constraints                                    │
│  ───────────────────────────                                     │
│  Higher priority features should complete first:                 │
│                                                                  │
│    Priority 1 (Security)  ──▶  Always sequential, never parallel│
│    Priority 2-3           ──▶  Parallelize within rules         │
│    Priority 4-5           ──▶  Aggressive parallelization OK    │
│                                                                  │
│  Rule 4: Critical Category Lock                                  │
│  ─────────────────────────────                                   │
│  Categories A (Security) and P (Payment):                        │
│    - Never parallelize with other work                          │
│    - Require full attention and testing                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Category Parallelization Matrix

```
Can parallelize together? (✓ = yes, ✗ = no, ~ = with caution)

     A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T
A    ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗
B    ✗  ✗  ~  ~  ~  ~  ~  ✓  ✓  ~  ✓  ~  ✓  ~  ~  ✗  ✓  ~  ✓  ✓
C    ✗  ~  ✗  ~  ~  ~  ~  ✓  ✓  ~  ✓  ~  ~  ~  ~  ✗  ✓  ~  ✓  ✓
D    ✗  ~  ~  ✗  ~  ~  ~  ~  ✓  ~  ✓  ~  ~  ~  ~  ✗  ✓  ~  ✓  ✓
E    ✗  ~  ~  ~  ✗  ~  ~  ✓  ✓  ~  ✓  ~  ✓  ~  ~  ✗  ✓  ~  ✓  ✓
F    ✗  ~  ~  ~  ~  ✗  ~  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ~  ✓  ~
G    ✗  ~  ~  ~  ~  ~  ✗  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ~  ✓  ✓
H    ✗  ✓  ✓  ~  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ~  ✓  ✓  ✓
I    ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ~  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
J    ✗  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✗  ✓  ~  ✓  ✓  ~  ✗  ~  ✓  ✓  ✓
K    ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
L    ✗  ~  ~  ~  ~  ✓  ✓  ✓  ~  ~  ✓  ✗  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
M    ✗  ✓  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✗  ✓  ✓  ✓  ✓
N    ✗  ~  ~  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✗  ✓  ~  ✓  ~
O    ✗  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ~  ✓  ✓  ✓  ✓  ✗  ✗  ✓  ✓  ✓  ✓
P    ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗
Q    ✗  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ~  ✓  ✓  ✓  ✓  ✓  ✗  ✗  ✓  ✓  ✓
R    ✗  ~  ~  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ✗  ✓  ✓
S    ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✗  ✓
T    ✗  ✓  ✓  ✓  ✓  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ✓  ✓  ✗

Legend:
A=Security, B=Navigation, C=CRUD, D=Workflow, E=Forms, F=Display,
G=Search, H=Notifications, I=Settings, J=Integration, K=Analytics,
L=Admin, M=Performance, N=A11y, O=Errors, P=Payment, Q=Communication,
R=Media, S=Docs, T=UI Polish
```

### 3.3 Dispatch Flow for Features

```
User: /implement-features
           │
           ▼
┌─────────────────────────┐
│ feature_get_stats()     │
│ Get pending features    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Group by category       │
│ Apply parallelization   │
│ matrix                  │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────────────────┐
│ Pending: F-42(F), F-43(F), F-44(I), F-45(S) │
│                                              │
│ Analysis:                                    │
│ • F-42, F-43: Same category (F) → serialize  │
│ • F-44 (I): Independent → can parallelize    │
│ • F-45 (S): Independent → can parallelize    │
│                                              │
│ Proposed:                                    │
│ • Main agent: F-42 (Display - primary)       │
│ • Sub-agent 1: F-44 (Settings)               │
│ • Sub-agent 2: F-45 (Docs)                   │
└───────────────────┬─────────────────────────┘
                    │
                    ▼
          [Dispatch flow as per config]
```

### 3.4 Regression Test Coordination

```
┌─────────────────────────────────────────────────────────────────┐
│              PARALLEL REGRESSION STRATEGY                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Option A: Shared regression (recommended for speed)             │
│  ────────────────────────────────────────────────                │
│  Main agent runs regression ONCE before dispatching              │
│  Sub-agents skip regression (already verified)                   │
│  Main agent runs regression AFTER all complete                   │
│                                                                  │
│  Option B: Independent regression (safer but slower)             │
│  ─────────────────────────────────────────────────               │
│  Each agent runs own regression before starting                  │
│  Catches conflicts earlier but duplicates work                   │
│                                                                  │
│  Config: regressionStrategy: "shared" | "independent"            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Natural Language Intent Detection

**Trigger Point:** Every user message, before any other action.

### 4.1 Detection Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                 INTENT DETECTION PIPELINE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Message                                                    │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Step 1: Pattern Matching                                 │    │
│  │         Check against defined trigger patterns           │    │
│  └────────────────────────┬────────────────────────────────┘    │
│                           │                                      │
│            ┌──────────────┴──────────────┐                      │
│            │                             │                      │
│       No Match                      Match Found                 │
│            │                             │                      │
│            ▼                             ▼                      │
│   ┌─────────────────┐          ┌─────────────────────────┐     │
│   │ Proceed with    │          │ Step 2: Confidence Score│     │
│   │ normal response │          │ How strong is the match?│     │
│   └─────────────────┘          └───────────┬─────────────┘     │
│                                            │                    │
│                              ┌─────────────┴─────────────┐      │
│                              │                           │      │
│                         High (>0.8)                 Medium/Low  │
│                              │                           │      │
│                              ▼                           ▼      │
│                    ┌─────────────────┐       ┌─────────────────┐│
│                    │ Suggest skill   │       │ Proceed normal, ││
│                    │ with confidence │       │ no suggestion   ││
│                    └─────────────────┘       └─────────────────┘│
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Pattern Definitions

#### Framework Skills

| Skill | Trigger Patterns | Confidence Boost |
|-------|------------------|------------------|
| `/new-feature` | "add feature", "implement feature", "build", "create new", "add functionality", "new capability" | +0.2 if mentions specific component |
| `/fix-bug` | "fix bug", "fix issue", "debug", "broken", "not working", "error in", "problem with" | +0.2 if references error message |
| `/refactor` | "refactor", "clean up", "restructure", "improve code", "reorganize", "simplify" | +0.1 if mentions specific pattern |
| `/create-pr` | "create pr", "pull request", "ready for review", "merge request", "open pr" | +0.3 if branch exists |
| `/release` | "release", "new version", "cut release", "publish", "deploy version" | +0.2 if on main branch |
| `/reflect resume` | "continue", "pick up where", "resume", "what was I working on", "last session" | +0.3 if session files exist |
| `/implement-features` | "implement all", "build features", "autonomous mode", "implement from database" | +0.3 if feature db exists |

#### Superpowers Skills

| Skill | Trigger Patterns | Confidence Boost |
|-------|------------------|------------------|
| `brainstorming` | "design", "think through", "explore options", "what approach", "how should we", "plan out" | +0.2 if no existing plan |
| `writing-plans` | "write plan", "implementation plan", "step by step", "break down into steps" | +0.1 if has spec/requirements |
| `systematic-debugging` | "why is this", "investigate", "figure out why", "root cause", "diagnose" | +0.2 if error context present |
| `test-driven-development` | "write tests first", "tdd", "test driven", "red green refactor" | +0.1 if test files exist |
| `dispatching-parallel-agents` | "in parallel", "simultaneously", "at the same time", "multiple tasks" | +0.2 if multiple items listed |
| `verification-before-completion` | "is it done", "verify", "check if complete", "make sure it works" | +0.2 if recent code changes |

### 4.3 Confidence Scoring

```
Base Score Calculation:
─────────────────────
• Exact phrase match:     0.9
• All keywords present:   0.7
• Most keywords present:  0.5
• Some keywords present:  0.3

Context Boosters:
────────────────
• Relevant files exist:           +0.1 to +0.3
• Recent related git activity:    +0.1
• Mentioned specific component:   +0.1 to +0.2
• Error/stack trace in message:   +0.2 (for debug skills)

Threshold for Suggestion: 0.7
─────────────────────────────
Below 0.7: No suggestion (too uncertain)
0.7 - 0.85: Suggest with "might be helpful"
Above 0.85: Suggest with confidence
```

### 4.4 Suggestion Format

**When Confidence 0.7 - 0.85:**

```
This sounds like you want to add a new feature.
The `/new-feature` workflow might help - it handles
discovery, planning, and implementation phases.

Use `/new-feature add user preferences to settings`? [Y/n]
```

**When Confidence > 0.85:**

```
This is a new feature request. I'll use the `/new-feature`
workflow which includes:
• Discovery phase - understand requirements
• Planning phase - design approach
• Implementation - build with checkpoints

Proceed with `/new-feature`? [Y/n]
```

### 4.5 Edge Cases

| Case | Example | Action |
|------|---------|--------|
| Multiple Skills Match | "Add a feature to fix the login bug" | Suggest both, ask user to clarify |
| Explicit Slash Command | "Add a feature /fix-bug for login" | Honor explicit command, skip detection |
| Question vs Request | "How do I add a feature?" | Answer question, don't suggest workflow |
| Already In Workflow | Mid-/new-feature, says "also fix this bug" | Note for later, don't interrupt |
| Negation | "Don't create a PR yet" | Detect negation, don't suggest |

---

## 5. Configuration System

**Location:** `.claude/memories/.dispatch-config.json`

### 5.1 Full Configuration Schema

```json
{
  "$schema": "dispatch-config-schema.json",
  "version": "1.0",

  "dispatch": {
    "enabled": true,
    "mode": "automatic",
    "maxParallelAgents": 3,
    "triggerPoints": {
      "onResume": true,
      "onTaskComplete": true,
      "onFeatureComplete": true
    },
    "taskRegistry": {
      "enabled": true,
      "minReadyTasks": 2,
      "respectPriority": true,
      "scopeConflictBehavior": "skip"
    },
    "featureDatabase": {
      "enabled": true,
      "categoryMatrix": "default",
      "regressionStrategy": "shared",
      "criticalCategories": ["A", "P"]
    }
  },

  "intentDetection": {
    "enabled": true,
    "mode": "suggest",
    "confidenceThreshold": 0.7,
    "skills": {
      "framework": true,
      "superpowers": true
    },
    "excludePatterns": [
      "how do I",
      "what is",
      "explain",
      "show me"
    ]
  },

  "notifications": {
    "onAgentSpawn": true,
    "onAgentComplete": true,
    "onConflictDetected": true,
    "verbosity": "normal"
  }
}
```

### 5.2 Configuration Commands

```
View Configuration:
  /reflect config dispatch
  /reflect config intent
  /reflect config --all

Modify Dispatch Settings:
  /reflect config dispatch.mode automatic
  /reflect config dispatch.mode confirm
  /reflect config dispatch.maxParallelAgents 5
  /reflect config dispatch.enabled false

Modify Intent Detection:
  /reflect config intent.mode suggest
  /reflect config intent.mode off
  /reflect config intent.confidenceThreshold 0.8

Quick Toggles:
  /reflect dispatch on
  /reflect dispatch off
  /reflect intent on
  /reflect intent off
```

### 5.3 Preset Configurations

| Preset | Use Case | Settings |
|--------|----------|----------|
| `careful` | New projects (default) | confirm mode, 2 agents, threshold 0.8 |
| `balanced` | After initial setup | automatic mode, 3 agents, threshold 0.7 |
| `aggressive` | Large projects, experienced users | automatic mode, 5 agents, threshold 0.6 |

Apply with: `/reflect config --preset balanced`

### 5.4 Validation Rules

| Setting | Constraints | Warnings |
|---------|-------------|----------|
| `maxParallelAgents` | Min: 1, Max: 10 | Warn if > 5 |
| `confidenceThreshold` | Min: 0.5, Max: 1.0 | Warn if < 0.6 |
| `criticalCategories` | Valid codes A-T | Must include A, P |

---

## 6. Integration Points

### 6.1 Session Protocol Integration

The dispatch analysis step is added after the existing session protocol:

```
CURRENT PROTOCOL              ENHANCED PROTOCOL
──────────────────            ─────────────────

1. Generate Session ID   →    1. Generate Session ID
2. Create Session File   →    2. Create Session File
3. Declare Scope         →    3. Declare Scope
4. Scan for Conflicts    →    4. Scan for Conflicts
5. Load Context          →    5. Load Context
6. Confirm Ready         →    6. Confirm Ready
                              7. ★ DISPATCH ANALYSIS ★
7. Proceed with work     →    8. Proceed with work
```

### 6.2 Task Registry Integration

New fields added to `registry.json`:

```json
{
  "tasks": {
    "T005": {
      "status": "in_progress",
      "dependencies": ["T001", "T003"],
      "lockedBy": "session-20260112-133143-abe8",
      "parallelGroup": "pg-001",
      "canParallelizeWith": ["T006", "T008"],
      "dispatchedAt": "2026-01-12T13:45:00Z"
    }
  },
  "parallelGroups": {
    "pg-001": {
      "tasks": ["T005", "T006", "T008"],
      "startedAt": "2026-01-12T13:45:00Z",
      "parentSession": "session-20260112-133143-abe8",
      "status": "active"
    }
  }
}
```

### 6.3 Feature Database Integration

New MCP tools for dispatch:

| Tool | Purpose |
|------|---------|
| `feature_get_parallelizable(limit)` | Returns features that can run in parallel |
| `feature_create_parallel_group(ids)` | Groups features for coordinated execution |
| `feature_get_parallel_status(group_id)` | Returns status of all features in group |

### 6.4 Sub-Agent System Integration

Agent selection by task type:

| Task Category | Agent Type | Model |
|---------------|------------|-------|
| Security (A) | general-purpose | opus |
| CRUD (C) | general-purpose | sonnet |
| Docs (S) | general-purpose | haiku |
| UI Polish (T) | general-purpose | haiku |
| Complex arch | Plan | sonnet |
| Code search | Explore | haiku |

Sub-agent session naming:
- Parent: `session-20260112-133143-abe8.md`
- Agent 1: `session-20260112-133143-abe8-agent-1.md`
- Agent 2: `session-20260112-133143-abe8-agent-2.md`

### 6.5 Skills System Integration

Intent detection suggests, then uses standard Skill tool:

```
User: "Let's add dark mode to the app"
        │
        ▼
Intent Detection → Match: /new-feature (0.82)
        │
        ▼
Suggestion: "Use /new-feature workflow? [Y/n]"
        │
   User: Y
        │
        ▼
Skill("new-feature", args="add dark mode to app")
```

Key: Intent detection does not bypass the skill system.

---

## 7. Event Flow Summary

```
1. USER MESSAGE RECEIVED
   └─→ Intent Detection (before anything else)
       └─→ If match: Suggest skill

2. /REFLECT RESUME or SESSION START
   └─→ Session Protocol (steps 1-6)
       └─→ Dispatch Analysis
           └─→ If parallelizable: Suggest/spawn agents

3. TASK COMPLETED (by main or sub-agent)
   └─→ Update registry
       └─→ Continuous Dispatch Check
           └─→ If new tasks ready: Suggest/spawn agents

4. FEATURE COMPLETED
   └─→ Update feature database
       └─→ Continuous Dispatch Check
           └─→ If parallelizable features: Suggest/spawn

5. ALL PARALLEL TASKS COMPLETE
   └─→ Merge results
       └─→ Run shared regression (if configured)
           └─→ Continue with next batch or complete
```

---

## 8. Implementation Plan

### Phase 1: Core Infrastructure
1. Create `.dispatch-config.json` schema and defaults
2. Add dispatch configuration to `/reflect config`
3. Create `reference/11-intelligent-dispatch.md`

### Phase 2: Task Registry Dispatch
1. Implement dependency graph analysis
2. Add parallelGroup tracking to registry
3. Implement dispatch flow with confirmation
4. Add continuous dispatch on task completion

### Phase 3: Feature Database Dispatch
1. Implement category matrix
2. Add new MCP tools for parallel features
3. Implement regression coordination
4. Add continuous dispatch on feature completion

### Phase 4: Intent Detection
1. Implement pattern matching engine
2. Add confidence scoring with context boosters
3. Implement suggestion UI
4. Handle edge cases (negation, questions, etc.)

### Phase 5: Integration
1. Update CLAUDE.md with core rules
2. Update session protocol with dispatch step
3. Add sub-agent session coordination
4. Testing and refinement

---

## 9. Success Criteria

| Metric | Target |
|--------|--------|
| Parallel task detection accuracy | > 95% |
| Intent detection precision | > 85% |
| False positive rate (intent) | < 10% |
| Dispatch overhead (time) | < 2s |
| User acceptance of suggestions | > 70% |

---

## Appendix A: Default Configuration File

```json
{
  "$schema": "dispatch-config-schema.json",
  "version": "1.0",
  "dispatch": {
    "enabled": true,
    "mode": "automatic",
    "maxParallelAgents": 3,
    "triggerPoints": {
      "onResume": true,
      "onTaskComplete": true,
      "onFeatureComplete": true
    },
    "taskRegistry": {
      "enabled": true,
      "minReadyTasks": 2,
      "respectPriority": true,
      "scopeConflictBehavior": "skip"
    },
    "featureDatabase": {
      "enabled": true,
      "categoryMatrix": "default",
      "regressionStrategy": "shared",
      "criticalCategories": ["A", "P"]
    }
  },
  "intentDetection": {
    "enabled": true,
    "mode": "suggest",
    "confidenceThreshold": 0.7,
    "skills": {
      "framework": true,
      "superpowers": true
    },
    "excludePatterns": [
      "how do I",
      "what is",
      "explain",
      "show me"
    ]
  },
  "notifications": {
    "onAgentSpawn": true,
    "onAgentComplete": true,
    "onConflictDetected": true,
    "verbosity": "normal"
  }
}
```

---

*Design approved and ready for implementation.*
