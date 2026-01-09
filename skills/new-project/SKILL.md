# New Project Skill

## Purpose

The `/new-project` skill fully initializes a project with the Claude Forge framework, creating all required documentation for effective AI-assisted development. It runs a **continuous workflow** through all phases regardless of project type.

## Key Principle

**All projects get full documentation.** The framework's value comes from having PRD, architecture decisions, and feature planning in place. The `--autonomous` flag adds automated implementation tracking, but documentation is always created.

## Invocation

```
/new-project                                          # New project, full workflow
/new-project "project description"                    # New project with description
/new-project --current                                # Existing project, analyzes first
/new-project --autonomous                             # New + feature database for automation
/new-project --current --autonomous                   # Existing + feature database
/new-project --autonomous --mode=yolo                 # Fast autonomous mode
/new-project --minimal                                # Framework only, skip documentation
```

**Parameters:**
- `description` - Brief project description (optional, will prompt if not provided)
- `--current` - Existing project mode: analyze codebase, confirm findings with user
- `--autonomous` - Add feature database for `/implement-features` automation
- `--minimal` - Skip documentation phases (framework setup only)
- `--mode=standard` - Full browser testing (default, autonomous only)
- `--mode=yolo` - Lint only, no browser tests (autonomous only)
- `--mode=hybrid` - Browser tests for critical categories only (autonomous only)

## Mode Comparison

| Feature | Standard | --current | --autonomous | --minimal |
|---------|----------|-----------|--------------|-----------|
| Framework setup | Yes | Yes | Yes | Yes |
| Codebase analysis | No | Yes | If --current | No |
| PRD creation | Yes | Yes | Yes | No |
| Architecture docs | Yes | Yes | Yes | No |
| Feature planning | Yes (manual) | Yes (manual) | Yes (database) | No |
| Feature database | No | No | Yes | No |
| MCP server setup | No | No | Yes | No |

## Workflow Overview

The skill runs through phases **continuously**, guiding the user from start to finish:

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 0: Framework Setup                        (ALL)       │
│ - Initialize .claude/ structure                             │
│ - Create CLAUDE.md from template                            │
│ - Set up memories and references                            │
├─────────────────────────────────────────────────────────────┤
│ Phase 1: Requirements Discovery                 (ALL)       │
│ - @analyst gathers requirements                             │
│ - @project-manager creates PRD                              │
│ - Output: docs/prd.md                                       │
├─────────────────────────────────────────────────────────────┤
│ Phase 2: Architecture & Standards               (ALL)       │
│ - @architect creates ADRs                                   │
│ - Populate reference documents                              │
│ - Output: .claude/reference/06-architecture-decisions.md    │
├─────────────────────────────────────────────────────────────┤
│ Phase 3: Feature Planning                       (ALL)       │
│ - @scrum-master breaks PRD into features                    │
│ - Map to 20 feature categories                              │
│ - Output: docs/feature-breakdown.md (manual tracking)       │
│         OR features.db (if --autonomous)                    │
├─────────────────────────────────────────────────────────────┤
│ Phase 4: Implementation Readiness     (--autonomous only)   │
│ - Set up MCP servers                                        │
│ - Initialize security model                                 │
│ - Configure testing mode                                    │
├─────────────────────────────────────────────────────────────┤
│ Phase 5: Kickoff                      (--autonomous only)   │
│ - Display summary                                           │
│ - Invoke /implement-features                                │
└─────────────────────────────────────────────────────────────┘
```

## Standard Mode (Default)

Creates full documentation for manual development:
- PRD document for requirements
- Architecture decisions documented
- Feature breakdown for tracking progress
- Ready to use `/new-feature`, `/fix-bug`, etc.

## Existing Project Mode (--current)

Same as standard, but starts by analyzing the codebase:
- Detects tech stack, project structure, existing commands
- Presents findings to user for confirmation
- Customizes all documentation based on existing code
- PRD reflects current state + planned enhancements

## Autonomous Mode (--autonomous)

Adds automated implementation tracking:
- Feature database instead of markdown file
- MCP server for feature state management
- Ready for `/implement-features` automation

---

## Phase 0: Project Setup (ALL MODES)

This phase runs for ALL projects:

### 0.1 Gather Project Information

**New Project (no --current):**
- Prompt user for project name, description, tech stack
- Use AskUserQuestion tool with options for common stacks
- Parse description if provided to infer details

**Existing Project (--current):**
- Analyze codebase structure using Glob and Read tools
- Detect tech stack from dependency files
- Extract project name from config files or directory
- Discover existing commands (npm scripts, Makefile, etc.)
- **Present findings to user for confirmation**
- Allow corrections before proceeding

### 0.2 Check Prerequisites

- Verify we're in a valid project directory
- Check for existing `.claude/CLAUDE.md` (warn if overwriting)

### 0.3 Initialize CLAUDE.md

- Read `.claude/templates/CLAUDE.template.md`
- Customize with gathered information:
  - Replace `[Project Name]` placeholder
  - Replace `[brief description]` placeholder
  - Update tech stack section
- Write to `.claude/CLAUDE.md`

### 0.4 Initialize Memories Structure

```
.claude/memories/
├── sessions/
│   └── latest.md
├── general.md
└── progress-notes.md
```

### 0.5 Initialize Reference Documents

- Copy templates from `.claude/reference/` removing `.template` suffix
- **Delete the original `.template.md` files after copying**

```bash
# Example: For each template file
cp .claude/reference/01-system-overview.template.md .claude/reference/01-system-overview.md
rm .claude/reference/01-system-overview.template.md
```

This ensures only the active documents remain, avoiding confusion between templates and project-specific content.

### 0.6 Initialize Git (if not exists)

- `git init`
- Initial commit with framework files

### 0.7 Update Progress Notes

After Phase 0 completes, update `.claude/memories/progress-notes.md`:

```markdown
# Progress Notes: [Project Name]

**Last Updated:** [current date/time]
**Current Phase:** Phase 0 Complete

## Session Summary

Framework initialized for [PROJECT_NAME].

## Completed

- [x] Phase 0: Framework Setup
  - .claude/ structure created
  - CLAUDE.md customized with project details
  - Memories structure initialized
  - Reference document templates ready

## In Progress

- [ ] Phase 1: Requirements Discovery (next)

## Next Steps

1. Gather requirements via @analyst
2. Create PRD via @project-manager
3. Continue to architecture and feature planning
```

### 0.8 Phase 0 Checkpoint

Display checkpoint:
```
## Phase 0 Complete: Framework Initialized

✅ .claude/ structure created
✅ CLAUDE.md customized
✅ Memories initialized
✅ Reference templates ready
✅ Progress notes updated

**Next: Phase 1 - Requirements Discovery**

The framework is set up. Now let's create the documentation
that makes AI-assisted development effective.

Continue to create PRD and architecture documentation?
```

**If `--minimal` flag: STOP HERE.** Otherwise continue to Phase 1.

---

## Phase 1: Requirements Discovery (ALL MODES)

This phase creates the Product Requirements Document.

### 1.1 Invoke @analyst

- For **new projects**: Interview user about requirements
- For **existing projects (--current)**: Analyze codebase + ask about planned enhancements

Questions to gather:
- Core functionality and user goals
- Target users and use cases
- Key features and priorities
- Non-functional requirements (performance, security)
- Constraints and limitations

### 1.2 Invoke @project-manager

- Transform gathered requirements into structured PRD
- Use template: `.claude/templates/prd.md`
- Include: vision, goals, user stories, success criteria

### 1.3 Output

- Save PRD to: `docs/prd.md`
- This becomes a **Tier 2 master document**

### 1.4 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 1 Complete: [current date/time]

- [x] Phase 1: Requirements Discovery
  - @analyst gathered requirements
  - @project-manager created PRD
  - PRD saved to docs/prd.md
  - [X] user stories identified
  - [Key features listed]

## In Progress

- [ ] Phase 2: Architecture & Standards (next)

## Next Steps

1. Create ADRs via @architect
2. Populate reference documents
3. Continue to feature planning
```

### 1.5 Checkpoint

```
## Phase 1 Complete: PRD Created

📄 docs/prd.md created
✅ Progress notes updated

**Summary:**
- [X user stories identified]
- [Key features listed]
- [Success criteria defined]

Review the PRD and confirm to continue to Architecture phase?
```

---

## Phase 2: Architecture & Standards (ALL MODES)

This phase documents technical decisions and fills reference docs.

### 2.1 Invoke @architect

Based on PRD and tech stack, create Architecture Decision Records:
- ADR-001: Frontend framework choice
- ADR-002: Backend/API approach
- ADR-003: Database selection
- ADR-004: Authentication strategy
- ADR-005: Deployment approach

### 2.2 Populate Reference Documents

Update the reference templates with project-specific content:
- `01-system-overview.md` - From PRD summary
- `02-architecture-and-tech-stack.md` - From ADRs
- `03-security-auth-and-access.md` - Security decisions
- `04-development-standards-and-structure.md` - Coding standards

### 2.3 UX Planning (if UI project)

- Invoke @ux-designer for key user flows
- Create wireframe descriptions or diagrams
- Document in `docs/ux/` or reference docs

### 2.4 Output

- ADRs in: `.claude/reference/06-architecture-decisions.md`
- Reference docs populated with project specifics

### 2.5 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 2 Complete: [current date/time]

- [x] Phase 2: Architecture & Standards
  - @architect created ADRs
  - Reference documents populated
  - ADRs saved to .claude/reference/06-architecture-decisions.md
  - Key decisions:
    - ADR-001: [decision]
    - ADR-002: [decision]
    - ...

## In Progress

- [ ] Phase 3: Feature Planning (next)

## Next Steps

1. Break PRD into features via @scrum-master
2. Map features to 20 categories
3. Create feature tracking (markdown or database)
```

### 2.6 Checkpoint

```
## Phase 2 Complete: Architecture Documented

📐 ADRs created:
- ADR-001: [decision]
- ADR-002: [decision]
- ...

📚 Reference docs updated
✅ Progress notes updated

Review architecture decisions and continue to Feature Planning?
```

---

## Phase 3: Feature Planning (ALL MODES)

This phase breaks down the PRD into implementable features.

### 3.1 Invoke @scrum-master

- Break PRD into epics (major feature areas)
- Break epics into user stories
- Break stories into features with acceptance criteria

### 3.2 Map to Categories

Map each feature to one of 20 categories (see `FEATURE-CATEGORIES.md`):
- A: Security & Auth
- B: Navigation
- C: Data (CRUD)
- ... through T: UI Polish

### 3.3 Output (varies by mode)

**Standard Mode (no --autonomous):**
- Create `docs/feature-breakdown.md` with full feature list
- Features tracked manually via markdown checkboxes
- Use with `/new-feature` skill for implementation

**Autonomous Mode (--autonomous):**
- Create `features.db` with all features
- Each feature marked `passes: false`
- Ready for `/implement-features` automation

### 3.4 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 3 Complete: [current date/time]

- [x] Phase 3: Feature Planning
  - @scrum-master broke PRD into features
  - [X] epics identified
  - [Y] user stories created
  - [Z] individual features mapped
  - Features mapped to [N] categories
  - Output: [docs/feature-breakdown.md | features.db]

## Project Status

**Initialization Complete** (Phases 0-3)

- PRD: docs/prd.md
- ADRs: .claude/reference/06-architecture-decisions.md
- Features: [docs/feature-breakdown.md | features.db]

## Ready For

[If not autonomous]:
- Manual development using /new-feature, /fix-bug, etc.
- Use /reflect resume to continue in future sessions

[If autonomous]:
- Phase 4: Implementation Readiness
- Phase 5: Kickoff with /implement-features
```

### 3.5 Update Latest Session

Also update `.claude/memories/sessions/latest.md` with current state:

```markdown
# Latest Session

**Date:** [current date/time]
**Phase Completed:** Phase 3 - Feature Planning

## What Was Done

- Initialized Claude Forge framework
- Created PRD with [X] user stories
- Documented [Y] architecture decisions
- Broke down into [Z] implementable features

## Current State

Project initialization complete. Ready for [manual development | autonomous implementation].

## Key Documents

- PRD: docs/prd.md
- ADRs: .claude/reference/06-architecture-decisions.md
- Features: [docs/feature-breakdown.md | features.db]

## Next Steps

[If manual]: Use /new-feature to start implementing features
[If autonomous]: Continue to Phase 4-5 for MCP setup and kickoff
```

### 3.6 Checkpoint

```
## Phase 3 Complete: Features Planned

📋 Feature breakdown complete:
- [X] epics identified
- [Y] user stories
- [Z] individual features
- Mapped to [N] categories

**Feature tracking:** [manual via markdown | automated via database]
✅ Progress notes updated
✅ Session state saved

[If not autonomous]: Project ready for development!
Use /new-feature to implement features one at a time.

[If autonomous]: Continue to Implementation Readiness?
```

**If NOT `--autonomous`: STOP HERE.** Project is ready for manual development.

---

## Phase 4: Implementation Readiness (--autonomous only)

This phase sets up automated implementation infrastructure.

### 4.1 Set up MCP Servers

- Feature tracking MCP server
- Browser automation MCP (if standard/hybrid testing mode)

### 4.2 Initialize Security Model

- Create/verify `.claude/security/allowed-commands.md`
- Configure command validators for project type

### 4.3 Configure Testing Mode

Based on `--mode` flag:
- `standard`: Full browser automation testing
- `yolo`: Lint and type-check only
- `hybrid`: Browser tests for critical categories only

### 4.4 Create init.sh

Development server startup script based on tech stack.

---

## Phase 5: Kickoff (--autonomous only)

### 5.1 Display Summary

```
## Project Ready for Autonomous Implementation

📊 Summary:
- Total features: [X]
- Categories: [Y]
- Testing mode: [standard/yolo/hybrid]

📋 First 5 features to implement:
1. [Feature name] (Category)
2. [Feature name] (Category)
3. ...

Ready to begin implementation with /implement-features?
```

### 5.2 Start Implementation

If user approves, invoke `/implement-features` to begin the automated loop.

## Execution Flow

```mermaid
graph TD
    A[/new-project invoked] --> B{--current flag?}
    B -->|Yes| C[Analyze existing codebase]
    B -->|No| D[Prompt for project details]
    C --> E[Present findings for confirmation]
    D --> F[Phase 0: Framework Setup]
    E --> F

    F --> G[Initialize .claude/ structure]
    G --> H[Create CLAUDE.md]
    H --> I[Set up memories & references]
    I --> J[Git init if needed]
    J --> K{--minimal flag?}
    K -->|Yes| L[STOP: Framework only]
    K -->|No| M[Phase 1: Requirements Discovery]

    M --> N[@analyst: Gather requirements]
    N --> O[@project-manager: Create PRD]
    O --> P[Save docs/prd.md]
    P --> Q[Checkpoint: Review PRD]

    Q --> R[Phase 2: Architecture & Standards]
    R --> S[@architect: Create ADRs]
    S --> T[Populate reference docs]
    T --> U{UI project?}
    U -->|Yes| V[@ux-designer: UX planning]
    U -->|No| W[Skip UX]
    V --> W
    W --> X[Checkpoint: Review architecture]

    X --> Y[Phase 3: Feature Planning]
    Y --> Z[@scrum-master: Break into features]
    Z --> AA[Map to 20 categories]
    AA --> AB{--autonomous flag?}
    AB -->|No| AC[Create feature-breakdown.md]
    AC --> AD[STOP: Ready for manual dev]
    AB -->|Yes| AE[Create features.db]

    AE --> AF[Phase 4: Implementation Readiness]
    AF --> AG[Set up MCP servers]
    AG --> AH[Initialize security model]
    AH --> AI[Configure testing mode]

    AI --> AJ[Phase 5: Kickoff]
    AJ --> AK[Display summary]
    AK --> AL{User approves?}
    AL -->|Yes| AM[Invoke /implement-features]
    AL -->|No| AN[Save state, exit]
```

## Phase Details

See companion files:
- `PHASES.md` - Detailed phase instructions
- `PRD-TEMPLATE.md` - PRD structure
- `FEATURE-CATEGORIES.md` - 20 category definitions
- `CHECKPOINTS.md` - User approval points
- `TESTING-MODES.md` - Standard vs YOLO vs Hybrid
- `MCP-SETUP.md` - MCP server configuration

## Integration Points

### Feature Database
- Uses `feature_create_bulk(features)` MCP tool
- Schema: id, priority, category, name, description, steps, passes, in_progress
- Persistence: `{project_root}/features.db`

### Security Model
- Reads: `.claude/security/allowed-commands.md`
- Validates all bash commands before execution
- Configurable per-project

### Documentation Hierarchy
- PRD becomes Tier 2 master document
- ADRs in `.claude/reference/06-architecture-decisions.md`
- Feature DB is source of truth for implementation scope

### Session Continuity
- Progress tracked in feature DB
- Git commits for code persistence
- Progress notes in `.claude/memories/progress-notes.md`

## Success Criteria

By the end of this skill:
- ✅ PRD document exists and is comprehensive
- ✅ Feature database contains 50-400+ features
- ✅ All features have testable acceptance criteria
- ✅ Architecture decisions documented
- ✅ Security model initialized
- ✅ MCP servers configured
- ✅ Ready for `/implement-features` skill

## Error Handling

### If project already initialized
- Check for existing `features.db`
- If exists: Error message, suggest `/implement-features` instead
- If PRD exists but no DB: Resume from Phase 2

### If user cancels mid-workflow
- Save current phase state
- Document in progress notes
- User can resume with `/new-project --resume`

### If MCP server setup fails
- Continue without MCP (degraded mode)
- Features tracked in JSON file instead of DB
- Warn user: "Manual verification required"

## Related Skills

- `/implement-features` - Incremental feature implementation (invoked after this skill)
- `/reflect` - Session continuity (used throughout)
- `/create-pr` - PR creation (used after feature batches)

## Examples

### Example 1: Standard Mode (Full Testing)
```
User: /new-project "E-commerce platform with user auth and Stripe payments"

Phase 1: Requirements Discovery
├─ @analyst interviews user about requirements
├─ @project-manager creates PRD
└─ PRD saved to docs/prd.md (15 pages)

Phase 2: Feature Breakdown
├─ @scrum-master breaks into 5 epics:
│  ├─ Epic 1: User Authentication (18 stories)
│  ├─ Epic 2: Product Catalog (25 stories)
│  ├─ Epic 3: Shopping Cart (15 stories)
│  ├─ Epic 4: Stripe Payments (22 stories)
│  └─ Epic 5: Admin Dashboard (12 stories)
├─ Maps 92 stories to 20 categories
├─ Creates 92 features in database
└─ Feature database initialized with 92 features

Phase 3: Technical Planning
├─ @architect creates ADRs:
│  ├─ ADR-001: Next.js + React for frontend
│  ├─ ADR-002: PostgreSQL for database
│  ├─ ADR-003: Stripe SDK for payments
│  ├─ ADR-004: NextAuth.js for authentication
│  └─ ADR-005: Vercel for deployment
└─ @ux-designer creates wireframes (12 screens)

Phase 4: Implementation Readiness
├─ Set up feature-tracking MCP server
├─ Set up Playwright MCP server
├─ Initialize security model (Node.js + Git + npm allowed)
└─ Create init.sh: npm run dev

Phase 5: Kickoff
├─ Project Summary:
│  ├─ Total features: 92
│  ├─ Categories: 20
│  ├─ Estimated complexity: Medium-High
│  ├─ Testing mode: Standard (full browser tests)
│  └─ Estimated sessions: 15-20
├─ First 5 features:
│  1. [Security] User can register with email/password
│  2. [Security] User can login with email/password
│  3. [Security] User session persists across page refreshes
│  4. [Navigation] User can view homepage with product grid
│  5. [Navigation] User can navigate to product detail page
└─ User approves ✓

Invoking /implement-features...
```

### Example 2: YOLO Mode (Rapid Prototyping)
```
User: /new-project "Simple blog with markdown posts" --mode=yolo

Phase 1-3: [Same as above, but simpler project]
├─ PRD created (5 pages)
├─ 35 features across 12 categories
└─ ADRs: Next.js, Markdown, SQLite

Phase 4: Implementation Readiness
├─ Set up feature-tracking MCP server
├─ SKIP Playwright MCP (YOLO mode)
├─ Initialize security model
└─ Create init.sh: npm run dev

Phase 5: Kickoff
├─ Testing mode: YOLO (lint only, no browser tests)
├─ Implementation will be ~5x faster
├─ Manual testing recommended after completion
└─ User approves ✓

Invoking /implement-features --mode=yolo...
```

### Example 3: Hybrid Mode (Critical Features Only)
```
User: /new-project "Internal admin dashboard" --mode=hybrid

Phase 4: Implementation Readiness
├─ Browser tests ONLY for categories:
│  ├─ Security & Access Control (full testing)
│  ├─ Payment & Financial Operations (full testing)
│  └─ Data Integrity (full testing)
├─ Lint only for categories:
│  ├─ UI Polish & Aesthetics
│  ├─ Help & Documentation
│  └─ Settings & Preferences

Balances speed and quality for internal tools
```

## Notes

- This skill works for **both new and existing projects**
- Use `--current` flag to analyze existing codebase first
- Use `--minimal` to skip documentation phases (framework setup only)
- Use `--autonomous` to add feature database for automated implementation
- The full workflow (Phases 0-3) takes 15-30 minutes depending on complexity
- Each phase has a checkpoint for user review and approval
- User can pause at any checkpoint and resume later
- Template files are deleted after reference docs are created

## See Also

- `../implement-features/SKILL.md` - Incremental implementation workflow
- `../../agents/orchestrator.md` - Overall workflow coordination
- `../../reference/09-autonomous-development.md` - Long-running agent patterns
