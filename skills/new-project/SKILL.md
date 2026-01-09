# New Project Skill

## Purpose

The `/new-project` skill initializes a new project with the Claude Forge framework. It supports two modes:

1. **Standard Mode** - Quick framework setup for human-directed development
2. **Autonomous Mode** - Full PRD, feature database, and ADRs for autonomous development

## Invocation

```
/new-project "project description"                    # Standard mode
/new-project "project description" --autonomous       # Autonomous mode
/new-project "project description" --autonomous --mode=yolo  # Fast autonomous
```

**Parameters:**
- `description` - Brief project description (optional, will prompt if not provided)
- `--autonomous` - Enable full autonomous development workflow (Phases 1-5)
- `--mode=standard` - Full browser testing (default, autonomous only)
- `--mode=yolo` - Lint only, no browser tests (autonomous only)
- `--mode=hybrid` - Browser tests for critical categories only (autonomous only)

## Mode Comparison

| Feature | Standard Mode | Autonomous Mode |
|---------|---------------|-----------------|
| CLAUDE.md | Yes | Yes |
| Memories structure | Yes | Yes |
| Reference docs | Yes | Yes |
| Git initialization | Yes | Yes |
| PRD creation | No | Yes |
| Feature database | No | Yes |
| ADRs | No | Yes |
| MCP servers | No | Yes |
| Auto-implementation | No | Yes |

## Overview

### Standard Mode

Quick setup for existing projects or human-directed development:
- Initializes CLAUDE.md from template
- Sets up session continuity (memories)
- Copies reference document templates
- Ready to use `/reflect`, `/new-feature`, etc.

### Autonomous Mode

Full autonomous development workflow:
1. Product Requirements Document (PRD)
2. Feature database with 50-400+ testable features
3. Architecture decisions documented
4. Ready for incremental autonomous implementation via `/implement-features`

---

## Phase 0: Project Setup (BOTH MODES)

This phase runs for ALL projects:

1. **Check Prerequisites**
   - Verify we're in a valid project directory
   - Check for existing CLAUDE.md (warn if overwriting)

2. **Initialize CLAUDE.md**
   - Copy from `.claude/templates/CLAUDE.template.md`
   - Customize with project name and description
   - Update tech stack if identifiable

3. **Initialize Memories Structure**
   ```
   .claude/memories/
   ├── sessions/
   │   └── latest.md
   ├── general.md
   └── progress-notes.md
   ```

4. **Initialize Reference Documents**
   - Copy templates from `.claude/reference/`
   - Remove `.template` suffix

5. **Initialize Git** (if not exists)
   - `git init`
   - Initial commit with framework files

**Standard Mode stops here.**

---

## Autonomous Mode Phases (1-5)

### Phase 1: Requirements Discovery
- Invoke `@analyst` to gather requirements
- Invoke `@project-manager` to create PRD
- Output: `docs/prd.md` (Tier 2 master document)

### Phase 2: Feature Breakdown
- Invoke `@scrum-master` to break PRD into epics/stories
- Map stories to 20 feature categories
- Create features in database via MCP
- Output: `features.db` with all features marked `passes: false`

### Phase 3: Technical Planning
- Invoke `@architect` to create ADRs
- Invoke `@ux-designer` for wireframes (if UI project)
- Output: `.claude/reference/06-architecture-decisions.md`

### Phase 4: Implementation Readiness
- Set up MCP servers (feature tracking, browser automation)
- Initialize security model (command allowlist)
- Configure testing mode (standard/yolo/hybrid)
- Create `init.sh` for development server startup

### Phase 5: Kickoff
- Display project summary (features count, categories, estimated complexity)
- Show first 5 features to be implemented
- Ask user: "Ready to begin incremental implementation?"
- If approved: Start incremental feature loop

## Execution Flow

```mermaid
graph TD
    A[/new-project invoked] --> B{Project exists?}
    B -->|No| C[Phase 1: Requirements Discovery]
    B -->|Yes| D[Error: Project already initialized]

    C --> E[@analyst: Gather requirements]
    E --> F[@project-manager: Create PRD]
    F --> G[Save docs/prd.md]

    G --> H[Phase 2: Feature Breakdown]
    H --> I[@scrum-master: Break into epics/stories]
    I --> J[Map to 20 categories]
    J --> K[Create feature records]
    K --> L[Save to features.db]

    L --> M[Phase 3: Technical Planning]
    M --> N[@architect: Create ADRs]
    N --> O{UI project?}
    O -->|Yes| P[@ux-designer: Wireframes]
    O -->|No| Q[Skip UX]
    P --> Q

    Q --> R[Phase 4: Implementation Readiness]
    R --> S[Set up MCP servers]
    S --> T[Initialize security model]
    T --> U[Create init.sh]

    U --> V[Phase 5: Kickoff]
    V --> W[Display summary]
    W --> X{User approves?}
    X -->|Yes| Y[Start /implement-features]
    X -->|No| Z[Save state, exit]
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

- This skill is designed for NEW projects only
- For existing projects, use `/implement-features` directly
- The feature breakdown process can take 5-15 minutes depending on complexity
- The skill will create multiple commits as it progresses
- User can pause at any checkpoint and resume later

## See Also

- `../implement-features/SKILL.md` - Incremental implementation workflow
- `../../agents/orchestrator.md` - Overall workflow coordination
- `../../reference/09-autonomous-development.md` - Long-running agent patterns
