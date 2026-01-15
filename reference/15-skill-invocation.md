# Skill Invocation

This document provides the complete skill invocation system for Claude Forge.

---

## Core Principle

**You MUST invoke skills via the Skill tool. You CANNOT rely on memory. (Gate 4)**

Skills evolve over time. Your memory of a skill may be:
- Outdated
- Incomplete
- Incorrect

Always invoke the Skill tool to get the current skill definition.

---

## Skill Invocation Rules

1. **ALWAYS use the Skill tool** - Never paraphrase or summarize skills
2. **Skills must be invoked, not remembered** - Skills evolve, memory is stale
3. **Skill content guides execution** - Follow the skill exactly as invoked
4. **Even "simple" tasks need skills** - Don't skip workflow for perceived simplicity

---

## Skill Routing Table

| User Intent | Skill to Invoke |
|-------------|-----------------|
| "Add a feature", "implement", "build" | `/new-feature` |
| "Fix bug", "debug", "broken" | `/fix-bug` |
| "Refactor", "clean up", "restructure" | `/refactor` |
| "Create PR", "pull request" | `/create-pr` |
| "Release", "new version" | `/release` |
| "Resume", "continue work" | `/reflect resume` |
| "New project", "initialize" | `/new-project` |
| "Migrate project" | `/migrate` |
| "Implement features" (autonomous) | `/implement-features` |

---

## How to Invoke Skills

Use the Skill tool with the skill name:

```
Skill: new-feature
Skill: fix-bug
Skill: refactor
Skill: reflect
```

The skill content will be loaded and presented. Follow it exactly.

---

## Skill Descriptions

### /new-project

**Purpose**: Initialize a new project with full documentation

**Phases**:
1. Framework setup (`.claude/` structure)
2. Requirements discovery (PRD)
3. Architecture & standards (ADRs)
4. Task planning (Epics, Tasks)

**Variants**:
- `/new-project "idea"` - Standard mode
- `/new-project --current` - Analyze existing codebase first
- `/new-project --autonomous` - Add feature database
- `/new-project --minimal` - Framework setup only

### /migrate

**Purpose**: Migrate existing project to Claude Forge

**What it does**:
- Analyzes existing codebase
- Creates framework structure
- Preserves existing work
- Sets up task tracking

### /new-feature

**Purpose**: Feature development workflow

**Steps**:
1. Verify task exists
2. Lock task
3. Implement feature
4. Test
5. Commit with task ID

### /fix-bug

**Purpose**: Bug fixing workflow

**Steps**:
1. Create task if needed
2. Reproduce bug
3. Identify root cause
4. Implement fix
5. Verify fix
6. Regression test

### /refactor

**Purpose**: Code refactoring workflow

**Steps**:
1. Create task if needed
2. Document current state
3. Plan refactoring
4. Implement in stages
5. Test after each stage
6. Verify no regressions

### /create-pr

**Purpose**: Pull request creation

**Steps**:
1. Verify all tasks complete
2. Run all tests
3. Create PR with description
4. Link to tasks/issues

### /release

**Purpose**: Version release workflow

**Steps**:
1. Verify all tests pass
2. Update version numbers
3. Generate changelog
4. Create release tag
5. Publish

### /reflect

**Purpose**: Session management and continuity

**Commands**:
- `/reflect` - Capture learnings
- `/reflect resume` - Resume with context
- `/reflect resume T###` - Resume specific task
- `/reflect status` - Show overview
- `/reflect config` - Configuration

### /implement-features

**Purpose**: Autonomous feature implementation

**What it does**:
- Reads feature database
- Prioritizes by category
- Implements features in order
- Handles dependencies

---

## Skill Invocation Violations

**These are violations of Rule 3. You MUST NOT:**

| Violation | Why It's Wrong | Correct Action |
|-----------|----------------|----------------|
| "I know how /new-feature works" | Skills evolve. Memory is unreliable. | Invoke Skill tool |
| Implementing without invoking skill | Skill provides workflow | Invoke skill FIRST |
| Paraphrasing skill content | You may miss steps | Follow invoked skill exactly |
| Skipping skill "for simple tasks" | All tasks need workflow | Invoke skill regardless |

---

## Skill vs Agent Relationship

Skills orchestrate agents:

```
User Request
      │
      ▼
┌─────────────────────┐
│ Invoke Skill First  │  ← /new-feature, /fix-bug, etc.
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Skill Invokes Agent │  ← Skill tells you which agent
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Agent Does Work     │  ← @developer, @security-boss, etc.
└─────────────────────┘
```

### Skills and Their Agents

| Skill | Agents Used |
|-------|-------------|
| `/reflect` | - (session management) |
| `/new-project` | @analyst, @project-manager, @architect, @scrum-master |
| `/migrate` | @analyst |
| `/new-feature` | @developer, specialized agents as needed |
| `/fix-bug` | @developer, @quality-engineer |
| `/refactor` | @developer, @quality-engineer |
| `/create-pr` | @developer |
| `/release` | @developer |
| `/implement-features` | Multiple agents by category |

---

## Intent Detection

The framework can detect user intent and suggest skills.

### Detected Patterns

| Skill | Trigger Patterns |
|-------|------------------|
| `/new-feature` | "add feature", "implement", "build", "create new" |
| `/fix-bug` | "fix bug", "debug", "broken", "not working", "error in" |
| `/refactor` | "refactor", "clean up", "restructure", "improve code" |
| `/create-pr` | "create pr", "pull request", "ready for review" |
| `/release` | "release", "new version", "cut release", "publish" |
| `/reflect resume` | "continue", "resume", "pick up where", "last session" |

### How It Works

When confidence ≥ 0.7, the system suggests:

```
User: "Let's add dark mode to the app"
        │
        ▼
"This looks like a new feature request.
 Use `/new-feature` workflow? [Y/n]"
```

### Intent Detection Rules

- **Threshold**: Only suggest when confidence ≥ 0.7
- **Mode**: Always suggest, never auto-invoke
- **Explicit commands**: If user types `/skill`, honor it
- **Questions**: "How do I...?" is a question, not a request
- **Negation**: "Don't create a PR" - detect negation, don't suggest

---

## Skill Location

Skills are defined in `skills/` directory:

```
skills/
├── new-project/
│   └── SKILL.md
├── migrate/
│   └── SKILL.md
├── reflect/
│   └── SKILL.md
├── new-feature/
│   └── SKILL.md
├── fix-bug/
│   └── SKILL.md
├── refactor/
│   └── SKILL.md
└── ...
```

Each skill has a `SKILL.md` file that defines:
- Purpose
- Steps
- Agents used
- Outputs
- Examples

---

## Configuration

Intent detection can be configured:

| Setting | Options | Default |
|---------|---------|---------|
| `intentDetection.enabled` | true/false | true |
| `intentDetection.mode` | "suggest", "off" | "suggest" |
| `intentDetection.confidenceThreshold` | 0.5-1.0 | 0.7 |

Configure via `/reflect config` or `.claude/memories/.dispatch-config.json`.

---

## Best Practices

### Do

- Always invoke skills via Skill tool
- Follow skill steps in order
- Let skills guide agent delegation
- Trust skill definitions over memory

### Don't

- Assume you know what a skill does
- Skip skill invocation for "simple" tasks
- Paraphrase or summarize skills
- Override skill workflow without user approval
