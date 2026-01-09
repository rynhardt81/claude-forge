# CLAUDE.md - Base Claude Framework Instructions

This file provides Claude Code with context about this framework and how to use it effectively.

---

## Framework Overview

**Base Claude** is a framework for AI-assisted software development. It provides:

- **Agent Personas** - Specialized agents for different roles (developer, architect, PM, etc.)
- **Skills** - Reusable workflows for common tasks
- **Templates** - Standardized document formats
- **Security Model** - Safe autonomous operation boundaries
- **Autonomous Development** - Full project implementation from idea to code

---

## Quick Reference

### Key Commands

| Command | Description |
|---------|-------------|
| `/new-project "idea"` | Full workflow: framework + PRD + ADRs + features |
| `/new-project --current` | Same, but analyzes existing codebase first |
| `/new-project --autonomous` | Add feature database for automated implementation |
| `/new-project --minimal` | Framework setup only (skip documentation) |
| `/implement-features` | Implement features from database one at a time |
| `/implement-features --mode=yolo` | Fast mode (lint only, no browser tests) |
| `/implement-features --resume` | Resume from last session |
| `/reflect` | Capture session learnings and context |
| `/reflect resume` | Resume from last session with context |
| `/pdf <command>` | PDF processing (extract, merge, split, fill, ocr, create) |

### Key Locations

| Location | Purpose |
|----------|---------|
| `agents/` | Agent persona definitions |
| `skills/` | Workflow skill definitions |
| `templates/` | Document templates |
| `reference/` | Architecture documentation |
| `security/` | Security model and allowlist |
| `mcp-servers/` | MCP server implementations |
| `.claude/features/features.db` | Feature tracking database |
| `.claude/memories/progress-notes.md` | Session continuity notes |

---

## Project Initialization

### Key Principle

**All projects get full documentation.** The `/new-project` skill runs a continuous workflow that creates PRD, architecture decisions, and feature planning. This documentation is what makes AI-assisted development effective.

### Standard Mode (Default)

Use `/new-project` to run the full workflow:

```
/new-project "My project description"
```

This runs through all phases:

| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Feature planning | `docs/feature-breakdown.md` |

After Phase 3, your project is ready for manual development using `/new-feature`, `/fix-bug`, etc.

### Existing Project Mode

Use `--current` to analyze an existing codebase first:

```
/new-project --current
```

This analyzes your project:
- Detects tech stack from package.json, requirements.txt, etc.
- Identifies project structure and existing commands
- Presents findings for confirmation
- Runs the same Phases 0-3 with discovered details

### Autonomous Mode

Add `--autonomous` for automated implementation tracking:

```
/new-project "E-commerce app" --autonomous
/new-project --current --autonomous
```

This adds Phases 4-5:
- Feature database (`features.db`) instead of markdown
- MCP server setup for automation
- Ready for `/implement-features`

### Minimal Mode

Use `--minimal` if you only want framework setup without documentation:

```
/new-project --minimal
```

This only runs Phase 0 (framework setup) and stops.

### Implementing Features

Use `/implement-features` to implement the feature database:

```
/implement-features              # Standard mode (full testing)
/implement-features --mode=yolo  # Fast mode (lint only)
/implement-features --mode=hybrid # Critical features tested only
/implement-features --resume     # Resume from last session
```

The implementation loop:
1. Get next feature from database
2. Run regression tests (1-2 passing features)
3. Implement the feature
4. Verify with tests
5. Mark as passing
6. Git commit
7. Repeat (checkpoint every 10 features)

### Testing Modes

| Mode | Testing | Speed | Use Case |
|------|---------|-------|----------|
| Standard | Full browser automation | ~5-10 min/feature | Production |
| YOLO | Lint + type-check only | ~1-2 min/feature | Prototyping |
| Hybrid | Critical features only | ~3-5 min/feature | Internal tools |

---

## Feature Categories

Features are organized into 20 categories (A-T):

| Code | Category | Description |
|------|----------|-------------|
| A | Security & Auth | Login, registration, permissions |
| B | Navigation | Routes, menus, breadcrumbs |
| C | Data (CRUD) | Create, read, update, delete |
| D | Workflow | User actions, multi-step processes |
| E | Forms | Input validation, form handling |
| F | Display | Lists, grids, detail views |
| G | Search | Search, filtering, sorting |
| H | Notifications | Toasts, alerts, badges |
| I | Settings | Configuration, preferences |
| J | Integration | External APIs, webhooks |
| K | Analytics | Tracking, reporting |
| L | Admin | Admin panels, management |
| M | Performance | Caching, optimization |
| N | Accessibility | a11y compliance |
| O | Error Handling | Error pages, recovery |
| P | Payment | Checkout, billing |
| Q | Communication | Email, SMS, notifications |
| R | Media | Images, video, files |
| S | Documentation | Help, guides |
| T | UI Polish | Animations, micro-interactions |

---

## Security Model

### Allowlist Approach

All bash commands are validated against an allowlist before execution:

- **Allowed:** npm, yarn, node, git, vite, jest, eslint, etc.
- **Blocked:** Commands not in the allowlist
- **Special Validators:** Extra checks for pkill, chmod, rm, curl, git

### What You Cannot Do

- Delete files recursively (`rm -rf`)
- Kill non-dev processes (`pkill postgres`)
- Force push to main/master
- Change file permissions (except `+x`)
- Access local files via curl (`file://`)

### Security Documentation

See `security/` directory for:
- `README.md` - Security overview
- `allowed-commands.md` - Full command allowlist
- `command-validators.md` - Special validator rules
- `python/security.py` - Reference implementation

---

## Session Continuity

### State Persistence

State is preserved across sessions via three bridges:

1. **Feature Database** - `.claude/features/features.db`
   - Which features are complete
   - Priority and ordering
   - Test steps

2. **Git Commits** - Source control
   - All code changes
   - Feature IDs in commit messages

3. **Progress Notes** - `.claude/memories/progress-notes.md`
   - Session summaries
   - Decisions made
   - Blockers encountered
   - Human-readable context

### Resuming Work

After a session ends, resume with:

```
/implement-features --resume
```

Or use the reflect skill:

```
/reflect resume
```

This will:
1. Read progress notes for context
2. Query database for current state
3. Review recent git commits
4. Continue from where you left off

---

## Agent Personas

### Primary Agents

| Agent | Description | When to Use |
|-------|-------------|-------------|
| @developer | Implementation, coding | Feature development |
| @architect | System design, ADRs | Technical decisions |
| @project-manager | PRD, scope, priorities | Project planning |
| @scrum-master | Feature breakdown, tracking | Sprint planning |
| @quality-engineer | Testing, browser automation | Verification |
| @security-boss | Security features, audits | Auth, payments |

### Invoking Agents

Use `@agent-name` to invoke a specific persona:

```
@developer implement the login form
@architect review this design decision
@security-boss audit the authentication flow
```

---

## MCP Servers

### Feature Tracking MCP

Provides tools for feature database operations:

```python
feature_get_stats()           # Get completion statistics
feature_get_next()            # Get next feature to implement
feature_mark_passing(id)      # Mark feature as complete
feature_get_for_regression(n) # Get features for regression testing
```

### Browser Automation MCP

Uses Playwright for browser testing:

```python
navigate(url)           # Go to URL
click(selector)         # Click element
type(selector, text)    # Type into input
screenshot(path)        # Capture screenshot
```

### Starting MCP Servers

MCP servers start on-demand when skills invoke them. The feature tracking server requires:

```bash
cd mcp-servers/feature-tracking
pip install -r requirements.txt
python server.py
```

---

## Templates

### Available Templates

| Template | Purpose |
|----------|---------|
| `prd.md` | Product Requirements Document |
| `epic.md` | Epic breakdown |
| `user-story.md` | User story with acceptance criteria |
| `progress-notes.md` | Session handoff notes |
| `feature-breakdown-report.md` | Feature summary |
| `adr-template.md` | Architecture Decision Record |

### Using Templates

Templates are in `templates/` directory. Reference them when creating documents:

```
Create a PRD using templates/prd.md as the format
```

---

## PDF Processing

The `/pdf` skill handles PDF manipulation tasks. It serves as both an invocable command and reference documentation.

### PDF Commands

| Command | Description |
|---------|-------------|
| `/pdf extract <file>` | Extract text or tables from PDF |
| `/pdf merge <files>` | Merge multiple PDFs into one |
| `/pdf split <file>` | Split PDF into individual pages |
| `/pdf fill <form>` | Fill a PDF form |
| `/pdf create` | Create a new PDF |
| `/pdf ocr <file>` | OCR a scanned PDF |
| `/pdf info <file>` | Show PDF metadata |

### PDF Documentation

| Document | Purpose |
|----------|---------|
| `skills/pdf/SKILL.md` | Main workflow and quick examples |
| `skills/pdf/FORMS.md` | Form filling (pypdf, PyPDFForm, pdf-lib) |
| `skills/pdf/REFERENCE.md` | Advanced features, JS libraries |
| `skills/pdf/TOOLS.md` | Tool selection guide |
| `skills/pdf/OCR.md` | Scanned PDF handling |

### Recommended Tools

| Task | Python | JavaScript | CLI |
|------|--------|------------|-----|
| Extract text | pdfplumber | - | pdftotext |
| Merge/split | pypdf | pdf-lib | qpdf |
| Create PDF | reportlab | PDFKit | - |
| Fill forms | pypdf | pdf-lib | - |
| OCR | pytesseract | - | tesseract |

---

## Checkpoint Protocol

During implementation, checkpoints occur every 10 features:

```markdown
## Checkpoint: 50/92 Features

Options:
1. Continue - Resume implementation
2. Pause - Save and exit
3. Adjust - Change priorities
4. Review - Inspect features
```

Always respect checkpoints - they're for human oversight.

---

## Git Commit Standards

### Commit Message Format

```
feat(<scope>): <description>

<bullet points>

Feature-ID: <id>
Testing: <mode> - <verification>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Scope by Category

| Category | Commit Scope |
|----------|--------------|
| A | auth, security |
| B | nav, routing |
| C | data, crud |
| D | workflow |
| E | forms |
| F | display, ui |
| G | search |
| P | payment, billing |

---

## Error Handling

### Implementation Failure

If a feature fails after 3 attempts:
1. Skip the feature (`feature_skip(id)`)
2. Log the blocker in progress notes
3. Continue with next feature

### Regression Failure

If regression tests fail:
1. STOP implementation immediately
2. Identify the regression
3. Fix before continuing
4. Never proceed with failing regressions

### Session Crash

On unexpected termination:
1. Check for uncommitted changes
2. Clear stale in_progress locks
3. Resume with `/implement-features --resume`

---

## Best Practices

### Do

- Complete features atomically (one at a time)
- Commit after each feature
- Run regression tests
- Update progress notes at session end
- Respect checkpoint pauses

### Don't

- Skip regression testing
- Leave features in_progress at session end
- Force through blockers
- Ignore test failures
- Batch multiple feature commits

---

## Documentation Reference

For detailed documentation, see:

| Document | Location |
|----------|----------|
| System Overview | `reference/01-system-overview.template.md` |
| Architecture | `reference/02-architecture-and-tech-stack.template.md` |
| Security (App) | `reference/03-security-auth-and-access.template.md` |
| Development Standards | `reference/04-development-standards-and-structure.template.md` |
| Security Model | `reference/08-security-model.template.md` |
| Autonomous Dev | `reference/09-autonomous-development.template.md` |

---

## Getting Help

- `/help` - Show available commands

---

*This framework enables structured, safe, autonomous development with human oversight at key checkpoints.*
