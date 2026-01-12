# 11-intelligent-dispatch.md

**Intelligent Dispatch System Reference**

> **Audience:** Claude Code, Developers
> **Authority:** Framework Core (Tier 1)
> **Persona:** Framework Engine
> **Purpose:** Define algorithms and patterns for automatic sub-agent dispatch and intent detection

---

## 1. Purpose of This Document

This document provides **detailed algorithms and patterns** for the Intelligent Dispatch System.

It answers:
* How does the dependency analysis algorithm work?
* What are the exact parallelization rules for features?
* How is intent detection confidence calculated?
* What patterns trigger which skills?

This document does NOT cover:
* Basic usage (see `CLAUDE.md`)
* Session management (see `10-parallel-sessions.md`)
* Security model (see `08-security-model.md`)

---

## 2. System Overview

The Intelligent Dispatch System has two components:

```
┌─────────────────────────────────────────────────────────────────┐
│               INTELLIGENT DISPATCH SYSTEM                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    │
│  │   SUB-AGENT DISPATCH    │    │   INTENT DETECTION      │    │
│  ├─────────────────────────┤    ├─────────────────────────┤    │
│  │ • Task dependency graph │    │ • Pattern matching      │    │
│  │ • Feature categories    │    │ • Confidence scoring    │    │
│  │ • Scope conflict check  │    │ • Skill suggestion      │    │
│  │ • Agent spawning        │    │ • Context boosters      │    │
│  └─────────────────────────┘    └─────────────────────────┘    │
│                                                                  │
│  Triggers:                       Triggers:                       │
│  • /reflect resume               • Every user message            │
│  • Task completion               • Before any other action       │
│  • Feature completion                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Task Dependency Analysis Algorithm

### 3.1 Input

```typescript
interface Task {
  id: string;              // e.g., "T005"
  status: "pending" | "ready" | "in_progress" | "continuation" | "completed";
  dependencies: string[];  // e.g., ["T001", "T003"]
  epic: string;            // e.g., "E01"
  priority: number;        // 1-5 (lower = higher priority)
  scope: {
    directories: string[];
    files: string[];
  };
  lockedBy?: string;       // session ID if locked
}

interface Registry {
  tasks: Record<string, Task>;
  epics: Record<string, Epic>;
}
```

### 3.2 Algorithm

```
FUNCTION analyzeTasksForDispatch(registry, currentSessionId, maxAgents):

    # Step 1: Get candidate tasks
    readyTasks = []
    FOR task IN registry.tasks:
        IF task.status == "ready" AND task.lockedBy IS NULL:
            readyTasks.append(task)

    IF len(readyTasks) < 2:
        RETURN []  # Not enough tasks to parallelize

    # Step 2: Build dependency graph
    graph = buildDependencyGraph(registry.tasks)

    # Step 3: Find independent clusters
    clusters = findIndependentClusters(graph, readyTasks)

    # Step 4: Check scope conflicts
    nonConflicting = []
    FOR cluster IN clusters:
        IF NOT hassScopeConflict(cluster, currentSessionScope):
            nonConflicting.append(cluster)

    # Step 5: Rank by priority
    ranked = sortByPriority(nonConflicting)

    # Step 6: Select up to maxAgents - 1 (main agent takes one)
    selected = ranked[0:maxAgents - 1]

    RETURN selected
```

### 3.3 Dependency Graph Construction

```
FUNCTION buildDependencyGraph(tasks):
    graph = new DirectedGraph()

    FOR task IN tasks:
        graph.addNode(task.id)
        FOR dep IN task.dependencies:
            graph.addEdge(dep, task.id)  # dep -> task

    RETURN graph
```

### 3.4 Independent Cluster Detection

Two tasks are independent if:
1. Neither depends on the other (directly or transitively)
2. They have no common incomplete ancestor

```
FUNCTION findIndependentClusters(graph, readyTasks):
    clusters = []
    visited = Set()

    FOR task IN readyTasks:
        IF task.id IN visited:
            CONTINUE

        # Find all tasks that must complete before this one
        ancestors = graph.getTransitiveAncestors(task.id)

        # Find all tasks that depend on this one
        descendants = graph.getTransitiveDescendants(task.id)

        # Task is independent if no other ready task is ancestor/descendant
        isIndependent = TRUE
        FOR other IN readyTasks:
            IF other.id == task.id:
                CONTINUE
            IF other.id IN ancestors OR other.id IN descendants:
                isIndependent = FALSE
                BREAK

        IF isIndependent:
            clusters.append(task)
            visited.add(task.id)

    RETURN clusters
```

### 3.5 Scope Conflict Detection

```
FUNCTION hasScopeConflict(task, sessionScope):
    # Check directory overlap
    FOR taskDir IN task.scope.directories:
        FOR sessionDir IN sessionScope.directories:
            IF pathOverlaps(taskDir, sessionDir):
                RETURN TRUE

    # Check file conflicts
    FOR taskFile IN task.scope.files:
        FOR sessionFile IN sessionScope.files:
            IF taskFile == sessionFile:
                RETURN TRUE

    RETURN FALSE

FUNCTION pathOverlaps(path1, path2):
    # Returns true if one path contains the other
    RETURN path1.startsWith(path2) OR path2.startsWith(path1)
```

---

## 4. Feature Category Parallelization

### 4.1 Category Definitions

| Code | Category | Description | Typical Files |
|------|----------|-------------|---------------|
| A | Security & Auth | Login, permissions, tokens | auth/, middleware/ |
| B | Navigation | Routing, links, menus | routes/, nav/ |
| C | Data (CRUD) | Create, read, update, delete | api/, models/ |
| D | Workflow | Multi-step processes | workflows/, actions/ |
| E | Forms | Input, validation | forms/, components/form/ |
| F | Display | Lists, grids, views | components/display/ |
| G | Search | Search, filters | search/, filters/ |
| H | Notifications | Alerts, toasts, banners | notifications/ |
| I | Settings | Configuration, preferences | settings/, config/ |
| J | Integration | External APIs, webhooks | integrations/, api/external/ |
| K | Analytics | Tracking, metrics | analytics/, tracking/ |
| L | Admin | Admin panels, management | admin/ |
| M | Performance | Caching, optimization | cache/, perf/ |
| N | Accessibility | a11y, screen readers | a11y/, components/ |
| O | Error Handling | Error pages, boundaries | errors/, boundaries/ |
| P | Payment | Billing, transactions | payments/, billing/ |
| Q | Communication | Email, SMS, push | notifications/, email/ |
| R | Media | Images, video, audio | media/, uploads/ |
| S | Documentation | Help, docs, tooltips | docs/, help/ |
| T | UI Polish | Animations, transitions | animations/, styles/ |

### 4.2 Full Parallelization Matrix

```
Can two features from these categories run in parallel?

     │ A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T
─────┼────────────────────────────────────────────────────────────
  A  │ ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗
  B  │ ✗  ✗  ~  ~  ~  ~  ~  ✓  ✓  ~  ✓  ~  ✓  ~  ~  ✗  ✓  ~  ✓  ✓
  C  │ ✗  ~  ✗  ~  ~  ~  ~  ✓  ✓  ~  ✓  ~  ~  ~  ~  ✗  ✓  ~  ✓  ✓
  D  │ ✗  ~  ~  ✗  ~  ~  ~  ~  ✓  ~  ✓  ~  ~  ~  ~  ✗  ✓  ~  ✓  ✓
  E  │ ✗  ~  ~  ~  ✗  ~  ~  ✓  ✓  ~  ✓  ~  ✓  ~  ~  ✗  ✓  ~  ✓  ✓
  F  │ ✗  ~  ~  ~  ~  ✗  ~  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ~  ✓  ~
  G  │ ✗  ~  ~  ~  ~  ~  ✗  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ~  ✓  ✓
  H  │ ✗  ✓  ✓  ~  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ~  ✓  ✓  ✓
  I  │ ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ~  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
  J  │ ✗  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✗  ✓  ~  ✓  ✓  ~  ✗  ~  ✓  ✓  ✓
  K  │ ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
  L  │ ✗  ~  ~  ~  ~  ✓  ✓  ✓  ~  ~  ✓  ✗  ✓  ✓  ✓  ✗  ✓  ✓  ✓  ✓
  M  │ ✗  ✓  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✗  ✓  ✓  ✓  ✓
  N  │ ✗  ~  ~  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✗  ✓  ~  ✓  ~
  O  │ ✗  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ~  ✓  ✓  ✓  ✓  ✗  ✗  ✓  ✓  ✓  ✓
  P  │ ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗  ✗
  Q  │ ✗  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ~  ✓  ✓  ✓  ✓  ✓  ✗  ✗  ✓  ✓  ✓
  R  │ ✗  ~  ~  ~  ~  ~  ~  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ✗  ✓  ✓
  S  │ ✗  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ✗  ✓  ✓  ✗  ✓
  T  │ ✗  ✓  ✓  ✓  ✓  ~  ✓  ✓  ✓  ✓  ✓  ✓  ✓  ~  ✓  ✗  ✓  ✓  ✓  ✗

Legend:
  ✓ = Can parallelize (no shared files expected)
  ~ = Caution (may have shared files, check scope)
  ✗ = Cannot parallelize (shared files likely, or critical category)
```

### 4.3 Category Parallelization Rules

```
FUNCTION canParallelizeFeatures(feature1, feature2):
    cat1 = feature1.category
    cat2 = feature2.category

    # Rule 1: Critical categories never parallelize
    IF cat1 IN ["A", "P"] OR cat2 IN ["A", "P"]:
        RETURN FALSE

    # Rule 2: Same category never parallelize
    IF cat1 == cat2:
        RETURN FALSE

    # Rule 3: Check matrix
    result = PARALLELIZATION_MATRIX[cat1][cat2]

    IF result == "✓":
        RETURN TRUE
    ELIF result == "✗":
        RETURN FALSE
    ELSE:  # "~" - caution
        # Additional scope check required
        RETURN NOT hasScopeConflict(feature1.scope, feature2.scope)
```

### 4.4 Feature Dispatch Algorithm

```
FUNCTION analyzeFeaturesForDispatch(features, maxAgents):

    # Step 1: Get pending features by priority
    pending = features.filter(f => f.status == "pending")
    pending.sortBy(f => f.priority)

    # Step 2: Select primary feature (main agent)
    primary = pending[0]

    # Step 3: Find parallelizable features
    parallelizable = []
    FOR feature IN pending[1:]:
        IF canParallelizeFeatures(primary, feature):
            # Also check against already selected
            canAdd = TRUE
            FOR selected IN parallelizable:
                IF NOT canParallelizeFeatures(feature, selected):
                    canAdd = FALSE
                    BREAK
            IF canAdd:
                parallelizable.append(feature)

        IF len(parallelizable) >= maxAgents - 1:
            BREAK

    RETURN {
        primary: primary,
        parallel: parallelizable
    }
```

---

## 5. Intent Detection System

### 5.1 Pattern Definitions

```typescript
interface SkillPattern {
  skill: string;
  patterns: string[];           // Trigger phrases
  keywords: string[];           // Individual keywords
  contextBoosters: ContextBooster[];
  excludePatterns: string[];    // Don't trigger on these
}

interface ContextBooster {
  condition: string;            // What to check
  boost: number;                // Confidence boost (0.0-0.3)
}
```

### 5.2 Complete Pattern Definitions

#### Framework Skills

```yaml
/new-feature:
  patterns:
    - "add feature"
    - "add a feature"
    - "implement feature"
    - "new feature"
    - "create new"
    - "build a"
    - "add functionality"
    - "new capability"
    - "implement a"
    - "add support for"
  keywords:
    - "add"
    - "feature"
    - "implement"
    - "build"
    - "create"
    - "new"
    - "functionality"
  contextBoosters:
    - condition: "mentions specific component"
      boost: 0.2
    - condition: "describes user-facing behavior"
      boost: 0.1
    - condition: "no existing plan for this"
      boost: 0.1
  excludePatterns:
    - "how do I add"
    - "can you add"
    - "should I add"

/fix-bug:
  patterns:
    - "fix bug"
    - "fix the bug"
    - "fix issue"
    - "fix this"
    - "debug"
    - "broken"
    - "not working"
    - "error in"
    - "problem with"
    - "doesn't work"
    - "stopped working"
    - "bug in"
  keywords:
    - "fix"
    - "bug"
    - "broken"
    - "error"
    - "issue"
    - "problem"
    - "debug"
  contextBoosters:
    - condition: "error message present"
      boost: 0.2
    - condition: "stack trace present"
      boost: 0.2
    - condition: "specific file mentioned"
      boost: 0.1
  excludePatterns:
    - "how do I fix"
    - "what's causing"

/refactor:
  patterns:
    - "refactor"
    - "clean up"
    - "restructure"
    - "improve code"
    - "reorganize"
    - "simplify"
    - "modernize"
    - "optimize code"
    - "make cleaner"
  keywords:
    - "refactor"
    - "clean"
    - "restructure"
    - "simplify"
    - "reorganize"
    - "improve"
  contextBoosters:
    - condition: "mentions specific pattern"
      boost: 0.1
    - condition: "mentions code smell"
      boost: 0.15
  excludePatterns:
    - "should I refactor"
    - "worth refactoring"

/create-pr:
  patterns:
    - "create pr"
    - "create a pr"
    - "pull request"
    - "open pr"
    - "make pr"
    - "ready for review"
    - "merge request"
    - "submit for review"
  keywords:
    - "pr"
    - "pull"
    - "request"
    - "review"
    - "merge"
  contextBoosters:
    - condition: "on feature branch"
      boost: 0.3
    - condition: "has uncommitted changes"
      boost: 0.1
    - condition: "recent commits exist"
      boost: 0.1
  excludePatterns:
    - "don't create"
    - "not ready for"

/release:
  patterns:
    - "release"
    - "new version"
    - "cut release"
    - "publish"
    - "deploy version"
    - "ship it"
    - "tag release"
    - "version bump"
  keywords:
    - "release"
    - "version"
    - "publish"
    - "deploy"
    - "ship"
    - "tag"
  contextBoosters:
    - condition: "on main/master branch"
      boost: 0.2
    - condition: "changelog exists"
      boost: 0.1
    - condition: "recent merges"
      boost: 0.1
  excludePatterns:
    - "don't release"
    - "not ready to release"

/reflect resume:
  patterns:
    - "continue"
    - "continue where"
    - "pick up where"
    - "resume"
    - "what was I working on"
    - "last session"
    - "where did we leave off"
    - "get back to"
  keywords:
    - "continue"
    - "resume"
    - "previous"
    - "last"
    - "session"
  contextBoosters:
    - condition: "session files exist"
      boost: 0.3
    - condition: "in_progress tasks exist"
      boost: 0.2
    - condition: "recent progress notes"
      boost: 0.1
  excludePatterns:
    - "don't continue"
    - "start fresh"
```

#### Superpowers Skills

```yaml
brainstorming:
  patterns:
    - "design"
    - "think through"
    - "explore options"
    - "what approach"
    - "how should we"
    - "plan out"
    - "let's think about"
    - "consider options"
    - "brainstorm"
  keywords:
    - "design"
    - "approach"
    - "options"
    - "think"
    - "plan"
    - "consider"
    - "explore"
  contextBoosters:
    - condition: "no existing plan"
      boost: 0.2
    - condition: "complex feature mentioned"
      boost: 0.1
  excludePatterns:
    - "explain the design"
    - "show me the design"

systematic-debugging:
  patterns:
    - "why is this"
    - "investigate"
    - "figure out why"
    - "root cause"
    - "diagnose"
    - "what's causing"
    - "trace the issue"
    - "understand why"
  keywords:
    - "why"
    - "investigate"
    - "cause"
    - "diagnose"
    - "trace"
    - "understand"
  contextBoosters:
    - condition: "error context present"
      boost: 0.2
    - condition: "reproduction steps given"
      boost: 0.15
  excludePatterns:
    - "explain why"

writing-plans:
  patterns:
    - "write plan"
    - "implementation plan"
    - "step by step"
    - "break down into steps"
    - "create a plan"
    - "plan the implementation"
    - "outline steps"
  keywords:
    - "plan"
    - "steps"
    - "implementation"
    - "outline"
    - "breakdown"
  contextBoosters:
    - condition: "spec or requirements present"
      boost: 0.1
    - condition: "complex task"
      boost: 0.1
  excludePatterns:
    - "show the plan"
    - "review the plan"

test-driven-development:
  patterns:
    - "write tests first"
    - "tdd"
    - "test driven"
    - "red green refactor"
    - "test first"
    - "start with tests"
  keywords:
    - "tdd"
    - "test"
    - "first"
    - "driven"
  contextBoosters:
    - condition: "test files exist"
      boost: 0.1
    - condition: "jest/vitest configured"
      boost: 0.1
  excludePatterns:
    - "don't use tdd"
    - "skip tests"

verification-before-completion:
  patterns:
    - "is it done"
    - "verify"
    - "check if complete"
    - "make sure it works"
    - "confirm it's working"
    - "test that it works"
    - "did it work"
  keywords:
    - "verify"
    - "check"
    - "complete"
    - "works"
    - "confirm"
    - "done"
  contextBoosters:
    - condition: "recent code changes"
      boost: 0.2
    - condition: "task marked in_progress"
      boost: 0.15
  excludePatterns:
    - "how do I verify"
```

### 5.3 Confidence Scoring Algorithm

```
FUNCTION calculateConfidence(message, pattern):
    score = 0.0

    # Base score from pattern matching
    FOR phrase IN pattern.patterns:
        IF message.toLowerCase().contains(phrase):
            score = max(score, 0.9)  # Exact phrase match
            BREAK

    IF score < 0.9:
        # Keyword matching
        matchedKeywords = 0
        FOR keyword IN pattern.keywords:
            IF message.toLowerCase().contains(keyword):
                matchedKeywords++

        keywordRatio = matchedKeywords / len(pattern.keywords)
        IF keywordRatio >= 0.8:
            score = 0.7
        ELIF keywordRatio >= 0.5:
            score = 0.5
        ELIF keywordRatio >= 0.3:
            score = 0.3

    # Apply context boosters
    FOR booster IN pattern.contextBoosters:
        IF checkCondition(booster.condition):
            score = min(1.0, score + booster.boost)

    # Check exclusions
    FOR exclusion IN pattern.excludePatterns:
        IF message.toLowerCase().contains(exclusion):
            score = 0.0  # Excluded
            BREAK

    RETURN score
```

### 5.4 Intent Detection Flow

```
FUNCTION detectIntent(userMessage):

    # Step 1: Check for explicit slash command
    IF userMessage.startsWith("/"):
        RETURN NULL  # User explicitly chose, skip detection

    # Step 2: Check for question patterns
    IF isQuestion(userMessage):
        RETURN NULL  # Questions get answered directly

    # Step 3: Check for negation
    IF hasNegation(userMessage):
        RETURN NULL  # User explicitly doesn't want this

    # Step 4: Calculate confidence for each skill
    candidates = []
    FOR pattern IN ALL_PATTERNS:
        confidence = calculateConfidence(userMessage, pattern)
        IF confidence >= CONFIDENCE_THRESHOLD:
            candidates.append({
                skill: pattern.skill,
                confidence: confidence
            })

    # Step 5: Handle results
    IF len(candidates) == 0:
        RETURN NULL
    ELIF len(candidates) == 1:
        RETURN candidates[0]
    ELSE:
        # Multiple matches - return highest or ask for clarification
        candidates.sortBy(c => c.confidence, DESC)
        IF candidates[0].confidence - candidates[1].confidence > 0.1:
            RETURN candidates[0]  # Clear winner
        ELSE:
            RETURN {
                type: "ambiguous",
                candidates: candidates[0:2]
            }

FUNCTION isQuestion(message):
    questionStarters = ["how do I", "what is", "can you", "should I",
                        "is there", "what's the", "where is", "why does"]
    FOR starter IN questionStarters:
        IF message.toLowerCase().startsWith(starter):
            RETURN TRUE
    IF message.trim().endsWith("?"):
        RETURN TRUE
    RETURN FALSE

FUNCTION hasNegation(message):
    negations = ["don't", "do not", "never", "stop", "cancel",
                 "not yet", "wait", "hold off", "skip"]
    FOR negation IN negations:
        IF message.toLowerCase().contains(negation):
            RETURN TRUE
    RETURN FALSE
```

---

## 6. Registry Schema Extensions

### 6.1 Task Extensions

```json
{
  "tasks": {
    "T005": {
      "id": "T005",
      "name": "Write authentication tests",
      "status": "in_progress",
      "dependencies": ["T001", "T003"],
      "epic": "E01",
      "priority": 2,
      "scope": {
        "directories": ["src/tests/auth/"],
        "files": []
      },
      "lockedBy": "session-20260112-133143-abe8",
      "lockedAt": "2026-01-12T13:45:00Z",

      "parallelGroup": "pg-001",
      "canParallelizeWith": ["T006", "T008"],
      "dispatchedAt": "2026-01-12T13:45:00Z",
      "dispatchedBy": "session-20260112-133143-abe8"
    }
  }
}
```

### 6.2 Parallel Group Schema

```json
{
  "parallelGroups": {
    "pg-001": {
      "id": "pg-001",
      "tasks": ["T005", "T006", "T008"],
      "parentSession": "session-20260112-133143-abe8",
      "startedAt": "2026-01-12T13:45:00Z",
      "status": "active",
      "completedTasks": [],
      "regressionStatus": "pending"
    }
  }
}
```

### 6.3 Feature Extensions

For feature database, add to MCP tool responses:

```json
{
  "id": 42,
  "category": "F",
  "name": "Product grid display",
  "priority": 3,
  "status": "pending",

  "parallelGroup": "fg-001",
  "canParallelizeWith": [44, 45],
  "dispatchedAt": null
}
```

---

## 7. Sub-Agent Spawn Templates

### 7.1 Task Agent Template

```markdown
## Task Assignment: {task.id} - {task.name}

**Session ID:** {parentSessionId}-agent-{n}
**Parent Session:** {parentSessionId}
**Mode:** Sub-agent (independent task execution)

---

### Task Details

**ID:** {task.id}
**Epic:** {task.epic} - {epicName}
**Priority:** {task.priority}
**Status:** in_progress (locked by this agent)

### Scope Declaration

**Directories:**
{for dir in task.scope.directories}
- `{dir}`
{endfor}

**Files:**
{for file in task.scope.files}
- `{file}`
{endfor}

**IMPORTANT:** You may ONLY modify files within this scope.

### Dependencies (Completed)

{for dep in task.dependencies}
- {dep}: {depStatus} {if depStatus == "completed"}✓{endif}
{endfor}

### Task Requirements

{task.description}

### Acceptance Criteria

{for criterion in task.acceptanceCriteria}
- [ ] {criterion}
{endfor}

### Instructions

1. Read and understand the task requirements
2. Implement the solution within declared scope
3. Run relevant tests
4. Commit with message: `feat({epic}): {task.name} [Task-ID: {task.id}]`
5. Mark task complete in registry

### On Completion

Report back with:
- status: "completed" | "blocked" | "partial"
- commits: [list of commit hashes]
- notes: any important context
- blockers: [if status != completed]

### Constraints

- Do NOT modify files outside your scope
- Do NOT start work on other tasks
- Do NOT merge or create PRs
- Commit after completing (not before)
```

### 7.2 Feature Agent Template

```markdown
## Feature Assignment: F-{feature.id} - {feature.name}

**Session ID:** {parentSessionId}-agent-{n}
**Parent Session:** {parentSessionId}
**Category:** {feature.category} - {categoryName}

---

### Feature Details

**ID:** F-{feature.id}
**Category:** {feature.category}
**Priority:** {feature.priority}
**Testing Mode:** {testingMode}

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
4. {if testingMode == "standard"}Run browser tests{endif}
5. Commit with feature ID
6. Mark feature as passing

### On Completion

Call: `feature_mark_passing({feature.id})`

Report back with:
- status: "passing" | "blocked" | "failing"
- commits: [list of commit hashes]
- testResults: {summary of test results}
```

---

## 8. Configuration Schema

### 8.1 Full Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "version": {
      "type": "string",
      "const": "1.0"
    },
    "dispatch": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean",
          "default": true
        },
        "mode": {
          "type": "string",
          "enum": ["automatic", "confirm"],
          "default": "automatic"
        },
        "maxParallelAgents": {
          "type": "integer",
          "minimum": 1,
          "maximum": 10,
          "default": 3
        },
        "triggerPoints": {
          "type": "object",
          "properties": {
            "onResume": { "type": "boolean", "default": true },
            "onTaskComplete": { "type": "boolean", "default": true },
            "onFeatureComplete": { "type": "boolean", "default": true }
          }
        },
        "taskRegistry": {
          "type": "object",
          "properties": {
            "enabled": { "type": "boolean", "default": true },
            "minReadyTasks": { "type": "integer", "default": 2 },
            "respectPriority": { "type": "boolean", "default": true },
            "scopeConflictBehavior": {
              "type": "string",
              "enum": ["skip", "warn", "block"],
              "default": "skip"
            }
          }
        },
        "featureDatabase": {
          "type": "object",
          "properties": {
            "enabled": { "type": "boolean", "default": true },
            "categoryMatrix": {
              "type": "string",
              "enum": ["default", "strict", "permissive"],
              "default": "default"
            },
            "regressionStrategy": {
              "type": "string",
              "enum": ["shared", "independent"],
              "default": "shared"
            },
            "criticalCategories": {
              "type": "array",
              "items": { "type": "string" },
              "default": ["A", "P"]
            }
          }
        }
      }
    },
    "intentDetection": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean",
          "default": true
        },
        "mode": {
          "type": "string",
          "enum": ["suggest", "off"],
          "default": "suggest"
        },
        "confidenceThreshold": {
          "type": "number",
          "minimum": 0.5,
          "maximum": 1.0,
          "default": 0.7
        },
        "skills": {
          "type": "object",
          "properties": {
            "framework": { "type": "boolean", "default": true },
            "superpowers": { "type": "boolean", "default": true }
          }
        },
        "excludePatterns": {
          "type": "array",
          "items": { "type": "string" },
          "default": ["how do I", "what is", "explain", "show me"]
        }
      }
    },
    "notifications": {
      "type": "object",
      "properties": {
        "onAgentSpawn": { "type": "boolean", "default": true },
        "onAgentComplete": { "type": "boolean", "default": true },
        "onConflictDetected": { "type": "boolean", "default": true },
        "verbosity": {
          "type": "string",
          "enum": ["quiet", "normal", "verbose"],
          "default": "normal"
        }
      }
    }
  }
}
```

### 8.2 Preset Definitions

```json
{
  "presets": {
    "careful": {
      "dispatch": {
        "mode": "confirm",
        "maxParallelAgents": 2
      },
      "intentDetection": {
        "confidenceThreshold": 0.8
      }
    },
    "balanced": {
      "dispatch": {
        "mode": "automatic",
        "maxParallelAgents": 3
      },
      "intentDetection": {
        "confidenceThreshold": 0.7
      }
    },
    "aggressive": {
      "dispatch": {
        "mode": "automatic",
        "maxParallelAgents": 5
      },
      "intentDetection": {
        "confidenceThreshold": 0.6
      }
    }
  }
}
```

---

## 9. Error Handling

### 9.1 Dispatch Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `NO_READY_TASKS` | No tasks with status "ready" | Continue with main agent only |
| `SCOPE_CONFLICT` | All ready tasks conflict with session | Log warning, skip dispatch |
| `MAX_AGENTS_REACHED` | Already at maxParallelAgents | Wait for completion |
| `REGISTRY_LOCKED` | Another process updating registry | Retry after delay |
| `AGENT_SPAWN_FAILED` | Task tool error | Log error, continue without agent |

### 9.2 Intent Detection Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `AMBIGUOUS_INTENT` | Multiple skills match equally | Present options to user |
| `LOW_CONFIDENCE` | No pattern meets threshold | Proceed without suggestion |
| `EXCLUDED_PATTERN` | User message matches exclusion | Proceed without suggestion |
| `IN_WORKFLOW` | Already executing a skill | Queue for later or ignore |

---

## 10. Monitoring and Metrics

### 10.1 Dispatch Metrics

Track these metrics for optimization:

```json
{
  "metrics": {
    "dispatch": {
      "totalAnalyses": 150,
      "successfulDispatches": 45,
      "tasksParallelized": 120,
      "averageAgentsPerDispatch": 2.7,
      "scopeConflicts": 12,
      "completionRate": 0.95
    }
  }
}
```

### 10.2 Intent Detection Metrics

```json
{
  "metrics": {
    "intentDetection": {
      "totalDetections": 200,
      "suggestionsShown": 85,
      "suggestionsAccepted": 72,
      "suggestionsDenied": 13,
      "acceptanceRate": 0.847,
      "averageConfidence": 0.82,
      "falsePositives": 3
    }
  }
}
```

---

## 11. See Also

- `CLAUDE.md` - Core dispatch rules and quick reference
- `10-parallel-sessions.md` - Session coordination
- `09-autonomous-development.md` - Feature database workflow
- `skills/reflect/SKILL.md` - Reflect skill with config commands
- `framework-docs/plans/2026-01-12-intelligent-dispatch-design.md` - Original design document

---

*This reference provides detailed algorithms for the Intelligent Dispatch System.*
