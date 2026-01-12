# Claude Forge Skills

Skills are reusable workflows that automate common development tasks. Each skill follows the Claude Forge framework's session protocol, conflict detection, and parallel session support.

---

## Quick Reference

| Skill | Command | Purpose |
|-------|---------|---------|
| [reflect](#reflect) | `/reflect` | Session management, task tracking, parallel coordination |
| [new-project](#new-project) | `/new-project` | Initialize new or existing projects |
| [migrate](#migrate) | `/migrate` | Migrate existing Claude config to Claude Forge |
| [new-feature](#new-feature) | `/new-feature` | Full feature development workflow |
| [fix-bug](#fix-bug) | `/fix-bug` | Disciplined bug diagnosis and fixing |
| [refactor](#refactor) | `/refactor` | Code improvement with scope boundaries |
| [create-pr](#create-pr) | `/create-pr` | Pull request creation with smart defaults |
| [release](#release) | `/release` | Version releases with changelog |
| [implement-features](#implement-features) | `/implement-features` | Autonomous feature implementation |
| [pdf](#pdf) | `/pdf` | PDF processing and manipulation |

---

## Skill Details

### reflect

**Purpose:** Session management, task tracking, parallel session coordination, and intelligent dispatch configuration.

**Invocation:**
```
/reflect                      # Capture session learnings
/reflect resume               # Resume from last session with full context
/reflect resume E01           # Resume specific epic
/reflect resume T002          # Resume specific task
/reflect status               # Show task/epic overview
/reflect status --ready       # Show tasks available to work on
/reflect status --locked      # Show currently locked tasks
/reflect status --sessions    # Show active parallel sessions
/reflect status --dispatch    # Show dispatch analysis for ready tasks
/reflect unlock T002          # Force unlock a stale task
/reflect cleanup              # Clean up stale sessions
/reflect config               # Show configuration
/reflect config dispatch      # Show dispatch configuration
/reflect config intent        # Show intent detection configuration
/reflect config <key> <value> # Update setting
/reflect config --preset <name> # Apply preset (careful, balanced, aggressive)
/reflect dispatch on          # Enable automatic sub-agent dispatch
/reflect dispatch off         # Disable automatic sub-agent dispatch
/reflect intent on            # Enable intent detection
/reflect intent off           # Disable intent detection
/reflect on                   # Enable auto-reflection
/reflect off                  # Disable auto-reflection
```

**Flags:**
| Flag | Description |
|------|-------------|
| `--ready` | Filter to tasks ready to start |
| `--locked` | Filter to locked tasks |
| `--sessions` | Show active parallel sessions |
| `--dispatch` | Show dispatch analysis for parallelizable tasks |

**When to Use:**
- Starting a new session (automatic context loading)
- Resuming work after a break
- Checking what tasks are available
- Managing parallel sessions
- Configuring dispatch and intent detection
- Toggling automatic sub-agent dispatch

**Prerequisites:**
- Project initialized with Claude Forge framework
- `.claude/memories/` directory exists

**Configuration Options:**
| Setting | Default | Description |
|---------|---------|-------------|
| `lockTimeout` | 3600 | Seconds before lock is stale |
| `allowManualUnlock` | true | Allow `/reflect unlock` |
| `maxParallelAgents` | 3 | Max concurrent task locks |
| `autoAssignNextTask` | true | Auto-suggest next task |
| `dispatch.enabled` | true | Enable automatic sub-agent dispatch |
| `dispatch.mode` | "automatic" | "automatic" or "confirm" before spawning |
| `intentDetection.enabled` | true | Enable natural language skill detection |
| `intentDetection.mode` | "suggest" | "suggest" (always) or "off" |
| `intentDetection.confidenceThreshold` | 0.7 | Minimum confidence to suggest skill |

**Presets:**
| Preset | Description | Settings |
|--------|-------------|----------|
| `careful` | New projects | confirm mode, 2 agents, 0.8 threshold |
| `balanced` | Normal use | automatic mode, 3 agents, 0.7 threshold |
| `aggressive` | Large projects | automatic mode, 5 agents, 0.6 threshold |

---

### new-project

**Purpose:** Complete project initialization with PRD, architecture decisions, and task planning.

**Invocation:**
```
/new-project                              # Interactive mode
/new-project "project description"        # With inline description
/new-project --current                    # Analyze existing codebase first
/new-project --autonomous                 # Add feature database for automation
/new-project --current --autonomous       # Existing codebase + automation
/new-project --autonomous --mode=yolo     # Fast mode (lint only)
/new-project --minimal                    # Framework setup only
```

**Flags:**
| Flag | Description |
|------|-------------|
| `--current` | Analyze existing codebase before creating docs |
| `--autonomous` | Create feature database for `/implement-features` |
| `--minimal` | Skip documentation phases (framework setup only) |
| `--mode=standard` | Full browser testing (default, autonomous only) |
| `--mode=yolo` | Lint only, no browser tests (autonomous only) |
| `--mode=hybrid` | Browser tests for critical categories only (autonomous only) |

**Phases:**
| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Task planning | `docs/epics/`, `docs/tasks/registry.json` |
| 4 | Implementation readiness | MCP servers, security model (autonomous only) |
| 5 | Kickoff | Start `/implement-features` (autonomous only) |

**When to Use:**
- Starting a brand new project
- Adding Claude Forge to an existing codebase
- Setting up autonomous development

**Prerequisites:**
- Valid project directory
- Git installed

---

### migrate

**Purpose:** Migrate existing Claude configuration to Claude Forge framework while preserving project context.

**Invocation:**
```
/migrate                      # Standard migration with prompts
/migrate --skip-analysis      # Skip brownfield analysis (merge only)
/migrate --dry-run            # Preview changes without executing
```

**Flags:**
| Flag | Description |
|------|-------------|
| `--skip-analysis` | Skip `/new-project --current` phase |
| `--dry-run` | Show what would happen without making changes |

**Before Running:**
You must run the migration script first:
```bash
# macOS/Linux
./scripts/migrate.sh

# Windows PowerShell
.\scripts\migrate.ps1
```

**Phases:**
| Phase | What Happens |
|-------|--------------|
| 0 | Verify prerequisites, analyze backup content |
| 1 | Merge memories, settings, project docs from backup |
| 2 | Run brownfield analysis (unless `--skip-analysis`) |
| 3 | Verify framework is operational, cleanup |

**When to Use:**
- Project has existing `.claude/` directory
- Upgrading from previous Claude configuration
- Preserving existing progress notes and documentation

**Prerequisites:**
- Migration script has run (creates `.claude_old/` backup)
- `.claude/` contains Claude Forge framework

---

### new-feature

**Purpose:** Full feature development workflow from discovery through commit.

**Invocation:**
```
/new-feature <description>
```

**Examples:**
```
/new-feature add user preference settings to the portal
/new-feature implement dark mode toggle
/new-feature add CSV export to reports page
```

**Workflow:**
1. **Scope Inference** - Analyze description to determine feature size
2. **Discovery** - Gather requirements if needed
3. **Planning** - Break into tasks if large
4. **Implementation** - Write code
5. **Testing** - Verify functionality
6. **Commit** - Create commit with feature ID

**When to Use:**
- Adding any new feature (small or large)
- The skill adapts based on inferred scope

**Prerequisites:**
- Project initialized with Claude Forge
- TodoWrite tool available for progress tracking

---

### fix-bug

**Purpose:** Disciplined bug fixing with diagnosis, context tracking, and regression prevention.

**Invocation:**
```
/fix-bug <description>
```

**Examples:**
```
/fix-bug test_webhook_delivery failing with ConnectionResetError
/fix-bug 500 error on /api/users endpoint in production
/fix-bug TypeError: Cannot read property 'id' of undefined
/fix-bug login form not validating email format
```

**Workflow:**
1. **Severity Assessment** - Infer severity from description
2. **Context Gathering** - Find related code and logs
3. **Hypothesis Formation** - Scientific method for diagnosis
4. **Fix Implementation** - Apply targeted fix
5. **Regression Testing** - Ensure no new issues
6. **Documentation** - Record root cause and solution

**Severity Modes:**
| Severity | Approach |
|----------|----------|
| Critical | Fast triage, immediate fix |
| High | Quick diagnosis, careful fix |
| Normal | Scientific method, thorough analysis |
| Low | Standard debugging process |

**When to Use:**
- Fixing any bug, error, or test failure
- Investigating unexpected behavior

**Prerequisites:**
- Project structure in place
- Test infrastructure available

---

### refactor

**Purpose:** Code improvement with scope boundaries and behavior verification.

**Invocation:**
```
/refactor <description>
```

**Examples:**
```
/refactor extract validation logic from UserController into ValidationService
/refactor move webhook handlers to dedicated module
/refactor optimize database queries in ReportService
/refactor rename userMgr to userManager across codebase
```

**Workflow:**
1. **Type Detection** - Infer refactor type from description
2. **Scope Definition** - Set clear boundaries
3. **Baseline Tests** - Capture current behavior
4. **Refactoring** - Make structural changes
5. **Verification** - Confirm behavior unchanged
6. **Commit** - Record refactoring scope

**Refactor Types:**
| Type | Description |
|------|-------------|
| Extract | Pull code into new function/class/module |
| Move | Relocate code to better location |
| Rename | Change names across codebase |
| Optimize | Improve performance without changing API |
| Simplify | Reduce complexity |

**When to Use:**
- Improving code without changing functionality
- Extracting shared logic
- Reorganizing modules
- Performance optimization

**Prerequisites:**
- Existing test coverage (critical for verification)
- Clear scope definition

---

### create-pr

**Purpose:** Create pull requests with smart defaults and appropriate verification.

**Invocation:**
```
/create-pr               # Standard PR
/create-pr --draft       # Draft PR for early feedback
```

**Flags:**
| Flag | Description |
|------|-------------|
| `--draft` | Create draft PR (skips final checks) |

**Workflow:**
1. **Target Detection** - Infer target branch from naming
2. **Diff Analysis** - Assess PR size and complexity
3. **Checks** - Run tests and linting
4. **Description Generation** - Create appropriate detail level
5. **PR Creation** - Open PR with labels

**Branch Naming Conventions:**
| Pattern | Target Branch |
|---------|---------------|
| `feature/*` | `develop` or `main` |
| `fix/*`, `bugfix/*` | `develop` or `main` |
| `hotfix/*` | `main` |
| `release/*` | `main` |

**When to Use:**
- Ready to open a PR for review
- Want early feedback on work in progress (use `--draft`)

**Prerequisites:**
- Commits made on feature branch
- GitHub CLI (`gh`) available
- Tests configured

---

### release

**Purpose:** Semantic versioning with changelog, GitHub releases, and optional deployment.

**Invocation:**
```
/release                  # Auto-detect version bump from commits
/release patch            # Force patch version bump (x.x.X)
/release minor            # Force minor version bump (x.X.0)
/release major            # Force major version bump (X.0.0)
/release --pre beta       # Create beta pre-release
/release --pre rc         # Create release candidate
/release --pre alpha      # Create alpha pre-release
```

**Flags:**
| Flag | Description |
|------|-------------|
| `patch` | Force patch bump |
| `minor` | Force minor bump |
| `major` | Force major bump |
| `--pre <type>` | Create pre-release (alpha, beta, rc) |

**Workflow:**
1. **Version Detection** - Find current version in files
2. **Commit Analysis** - Parse conventional commits for bump type
3. **Changelog Generation** - Generate from commit history
4. **Version Bump** - Update version files
5. **Git Operations** - Tag and push
6. **GitHub Release** - Create release with notes
7. **Deployment** - Optional deployment trigger

**Conventional Commits:**
| Prefix | Bump Type |
|--------|-----------|
| `feat:` | minor |
| `fix:` | patch |
| `BREAKING CHANGE:` | major |
| `docs:`, `chore:`, `style:` | patch |

**When to Use:**
- Ready to publish a new version
- Creating pre-releases for testing

**Prerequisites:**
- Git tags configured
- Version files detected (package.json, pyproject.toml, etc.)
- Tests passing
- Clean working tree

---

### implement-features

**Purpose:** Autonomous feature implementation with regression testing, quality verification, and parallel dispatch.

**Invocation:**
```
/implement-features                      # Start implementation loop
/implement-features --mode=standard      # Full browser testing (default)
/implement-features --mode=yolo          # Lint only, no browser tests
/implement-features --mode=hybrid        # Browser tests for critical only
/implement-features --resume             # Resume from last in-progress
/implement-features --start-from=F042    # Start from specific feature
/implement-features --parallel           # Enable parallel feature dispatch
/implement-features --parallel --max-agents=5  # Override max parallel agents
```

**Flags:**
| Flag | Description |
|------|-------------|
| `--mode=standard` | Full browser testing (default) |
| `--mode=yolo` | Lint only, skip browser tests |
| `--mode=hybrid` | Browser tests for critical categories |
| `--resume` | Resume from last in-progress feature |
| `--start-from=<id>` | Start from specific feature ID |
| `--parallel` | Enable parallel feature dispatch (uses dispatch config) |
| `--max-agents=<n>` | Override max parallel agents (default: from config) |

**Implementation Loop:**
```
┌─────────────────────────────────────────────┐
│ 1. Get next pending feature from database   │
│ 2. Dispatch analysis (if --parallel)        │
│ 3. Run regression tests on passing features │
│ 4. Implement the feature                    │
│ 5. Verify implementation                    │
│ 6. Mark feature as passing                  │
│ 7. Commit with feature ID                   │
│ 8. Checkpoint (user can pause)              │
│ 9. Repeat until all features done           │
└─────────────────────────────────────────────┘
```

**Testing Modes:**
| Mode | Description | Speed | Coverage |
|------|-------------|-------|----------|
| `standard` | Full browser automation | Slow | Complete |
| `yolo` | Lint and type-check only | Fast | Minimal |
| `hybrid` | Browser for critical categories | Medium | Selective |

**Parallel Execution:**
When `--parallel` is enabled, features can be implemented in parallel:
- Different categories (F, I, S, etc.) can run simultaneously
- Same-category features run sequentially (shared files)
- Critical categories (A: Security, P: Payment) never parallelize
- Uses MCP tools: `feature_get_parallelizable`, `feature_create_parallel_group`

**When to Use:**
- After running `/new-project --autonomous`
- Incremental feature delivery
- Automated development workflows
- Parallel feature implementation for faster delivery

**Prerequisites:**
- Feature database created by `/new-project --autonomous`
- MCP servers configured
- Testing infrastructure in place
- Dispatch config at `.claude/memories/.dispatch-config.json` (for parallel mode)

---

### pdf

**Purpose:** PDF processing including extraction, merging, form filling, and creation.

**Invocation:**
```
/pdf extract <file>       # Extract text or tables
/pdf merge <files>        # Merge multiple PDFs
/pdf split <file>         # Split into pages
/pdf fill <form>          # Fill PDF form
/pdf create               # Create new PDF
/pdf ocr <file>           # OCR scanned PDF
/pdf info <file>          # Show metadata
```

**Commands:**
| Command | Description | Example |
|---------|-------------|---------|
| `extract` | Extract text or tables | `/pdf extract report.pdf` |
| `merge` | Combine PDFs | `/pdf merge doc1.pdf doc2.pdf` |
| `split` | Split into pages | `/pdf split book.pdf` |
| `fill` | Fill form fields | `/pdf fill application.pdf` |
| `create` | Create new PDF | `/pdf create` |
| `ocr` | OCR scanned document | `/pdf ocr scan.pdf` |
| `info` | Show metadata | `/pdf info document.pdf` |

**When to Use:**
- Extracting data from PDF documents
- Combining or splitting PDFs
- Filling PDF forms programmatically
- Processing scanned documents

**Prerequisites:**
- Valid file paths
- Python or Node.js environment
- Appropriate PDF libraries installed

---

## Skill Development

### Directory Structure

Each skill follows this structure:

```
skills/
└── skill-name/
    ├── SKILL.md           # Main skill definition (required)
    ├── PHASES.md          # Detailed phase instructions (optional)
    ├── CHECKPOINTS.md     # User confirmation points (optional)
    └── *-RULES.md         # Domain-specific rules (optional)
```

### SKILL.md Format

```markdown
---
name: skill-name
description: Brief description of the skill
---

# Skill Name

## Purpose
What this skill does...

## Invocation
How to call the skill...

## Workflow
Steps the skill follows...
```

### Creating New Skills

1. Create directory under `skills/`
2. Add `SKILL.md` with YAML frontmatter
3. Define phases and checkpoints if needed
4. Add to CLAUDE.md quick reference

---

## Integration with Framework

All skills integrate with the Claude Forge framework:

- **Session Protocol** - Skills respect session boundaries and scope
- **Conflict Detection** - Parallel session coordination
- **Task Management** - Integration with epic/task registry
- **Progress Tracking** - Updates to progress-notes.md
- **Checkpoints** - User confirmation at key points

---

## Recommended Plugins (For Full Functionality)

The following plugins are **recommended for full Claude Forge functionality**. Some framework skills directly invoke these plugins:

### Superpowers Plugin (Recommended)

**Used by:** `/new-feature`, `/fix-bug` skills

The Superpowers plugin provides workflow skills that Claude Forge skills invoke directly:

| Skill | Command | Used By |
|-------|---------|---------|
| brainstorming | `/brainstorming` | `/new-feature` (discovery phase) |
| writing-plans | `/writing-plans` | `/new-feature` (planning phase) |
| test-driven-development | `/test-driven-development` | `/new-feature` (implementation) |
| systematic-debugging | `/systematic-debugging` | `/fix-bug` (diagnosis) |
| verification-before-completion | `/verification-before-completion` | `/new-feature`, `/fix-bug` |
| requesting-code-review | `/requesting-code-review` | `/new-feature` (completion) |
| using-git-worktrees | `/using-git-worktrees` | Isolated feature work |
| dispatching-parallel-agents | `/dispatching-parallel-agents` | Run independent tasks in parallel |
| executing-plans | `/executing-plans` | Execute plans with review checkpoints |
| code-reviewer | Agent | Review completed work against plans |

**Without this plugin:** `/new-feature` and `/fix-bug` skills will have reduced functionality. The skills will still work but won't invoke the specialized workflow phases.

### Playwright Plugin (Recommended for Autonomous Mode)

**Used by:** `/implement-features`, Quality Engineer agent, Standard/Hybrid testing modes

Browser automation capabilities via MCP server for feature verification:

- Browser navigation and interaction
- Screenshot capture
- Form filling and validation
- Element inspection
- End-to-end testing

**Without this plugin:** Autonomous development (`--autonomous` flag) and Standard/Hybrid testing modes will not have browser-based verification. YOLO mode (`--mode=yolo`) works without Playwright.

---

## Optional Plugins

The following plugins are **fully optional** and can enhance your development workflow if desired:

### Frontend Design Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| frontend-design | `/frontend-design` | Create production-grade UI components |

### Backend Development Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| backend-architect | Agent | API design and microservices |
| temporal-python-pro | Agent | Temporal workflow orchestration |
| tdd-orchestrator | Agent | Test-driven development governance |
| graphql-architect | Agent | GraphQL schema and performance |
| api-design-principles | `/api-design-principles` | REST/GraphQL API design |
| microservices-patterns | `/microservices-patterns` | Distributed systems design |
| workflow-orchestration-patterns | `/workflow-orchestration-patterns` | Durable workflow design |

### Database Design Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| database-architect | Agent | Data layer and schema design |
| sql-pro | Agent | SQL optimization and modeling |
| postgresql | `/postgresql` | PostgreSQL-specific schema design |

### LLM Application Development Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| prompt-engineer | Agent | Advanced prompting techniques |
| ai-engineer | Agent | Production LLM applications |
| rag-implementation | `/rag-implementation` | Retrieval-augmented generation |
| embedding-strategies | `/embedding-strategies` | Embedding model selection |
| langchain-architecture | `/langchain-architecture` | LangChain application design |

### Ralph Loop Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| ralph-loop | `/ralph-loop` | Start Ralph Loop in session |
| cancel-ralph | `/cancel-ralph` | Cancel active Ralph Loop |

### Context7 Plugin (MCP)

Documentation lookup via MCP server. Provides:
- Library documentation retrieval
- Up-to-date code examples
- Framework-specific guidance

---

## Installing Plugins

These plugins are installed separately from Claude Forge. Check each plugin's documentation for installation instructions.

**Summary:**
- **Superpowers** - Recommended for `/new-feature` and `/fix-bug` full functionality
- **Playwright** - Recommended for autonomous development and browser testing
- **All others** - Fully optional, install based on your development needs

---

## See Also

- [CLAUDE.md](../CLAUDE.md) - Framework instructions
- [agents/](../agents/) - Agent personas
- [templates/](../templates/) - Document templates
- [reference/](../reference/) - Architecture documentation
