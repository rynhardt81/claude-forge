---
name: new-project
description: Initialize a new project with Claude Forge framework (--current for existing projects, --autonomous for full workflow)
argument-hint: "project description" [--current] [--autonomous]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite, AskUserQuestion
---

# /new-project Skill

You are initializing a new project using the Claude Forge framework.

## Arguments Received

**Raw Arguments:** $ARGUMENTS

## Step 1: Parse Arguments and Determine Project Type

### 1.1 Parse Flags

Extract from arguments:
- `--current` flag → **Existing Project Mode** (analyze codebase first)
- `--autonomous` flag → **Autonomous Mode** (full PRD, features.db, ADRs)
- `--mode=yolo|standard|hybrid` → Testing mode (autonomous only)
- Everything else → Project description

### 1.2 Determine Project Type

| Flags | Mode | Description |
|-------|------|-------------|
| (none) | New Project | Ask for project details |
| `--current` | Existing Project | Analyze codebase, confirm findings |
| `--autonomous` | New + Autonomous | Ask details, then full workflow |
| `--current --autonomous` | Existing + Autonomous | Analyze, then full workflow |

---

## Step 2: Gather Project Information

### 2A: For NEW Projects (no --current flag)

**If no project description was provided (or it's empty/just flags):**

Use the AskUserQuestion tool to gather essential project information:

```
Question 1: "What is your project name?"
  - Header: "Project"
  - Options: [Free text input via "Other"]

Question 2: "Briefly describe what this project does"
  - Header: "Description"
  - Options: [Free text input via "Other"]

Question 3: "What is the primary tech stack?"
  - Header: "Tech Stack"
  - Options:
    - "Next.js + React (Recommended)" - Full-stack React framework
    - "Node.js + Express" - Backend API server
    - "Python + FastAPI" - Modern Python web framework
    - "Other" - Specify custom stack
```

**If project description WAS provided:**

Parse the description to extract:
- Project name (infer from description or ask)
- Brief description (use provided text)
- Tech stack (infer from keywords like "React", "Python", "Node", etc., or ask)

---

### 2B: For EXISTING Projects (--current flag)

**Analyze the existing codebase to discover project details:**

#### 2B.1 Discover Project Structure

Use Glob and Read tools to analyze:

```
1. Check for package.json, requirements.txt, go.mod, Cargo.toml, etc.
2. Identify project structure (src/, app/, lib/, etc.)
3. Look for existing README.md or documentation
4. Check for existing tests (tests/, __tests__/, spec/)
5. Identify frameworks from dependencies
```

#### 2B.2 Detect Tech Stack

Analyze dependency files to determine:

| File | Indicates |
|------|-----------|
| `package.json` | Node.js project - check for React, Next.js, Express, etc. |
| `requirements.txt` / `pyproject.toml` | Python - check for FastAPI, Django, Flask |
| `go.mod` | Go project |
| `Cargo.toml` | Rust project |
| `pom.xml` / `build.gradle` | Java project |
| `*.csproj` | .NET project |

#### 2B.3 Extract Project Name

Look for project name in:
1. `package.json` → `name` field
2. `pyproject.toml` → `[project] name`
3. Directory name as fallback
4. Existing README.md title

#### 2B.4 Present Findings for Confirmation

Display discovered information to user:

```markdown
## Existing Project Analysis

I've analyzed your codebase and found:

**Project Name:** [discovered name]
**Description:** [from README or inferred]

**Tech Stack:**
- **Frontend:** [React/Vue/Angular/None detected]
- **Backend:** [Express/FastAPI/Django/None detected]
- **Database:** [PostgreSQL/MongoDB/SQLite/None detected]
- **Testing:** [Jest/Pytest/None detected]

**Project Structure:**
```
[show directory tree]
```

**Key Files Found:**
- [list important files]

**Existing Commands:** (from package.json scripts or Makefile)
- `npm run dev` - Start development
- `npm test` - Run tests
- ...
```

#### 2B.5 User Confirmation

Use AskUserQuestion to confirm or correct:

```
Question 1: "Is this analysis correct?"
  - Header: "Confirm"
  - Options:
    - "Yes, proceed with these details" - Continue with discovered info
    - "Partially correct" - Let me make corrections
    - "No, let me provide details manually" - Fall back to manual input

Question 2 (if "Partially correct"): "What needs correction?"
  - Header: "Corrections"
  - Options: [Free text via "Other"]
```

---

## Step 3: Store Project Information

After gathering (new project) or confirming (existing project):

- `PROJECT_NAME` - The project name
- `PROJECT_DESCRIPTION` - What the project does
- `TECH_STACK` - Primary technologies (frontend, backend, database)
- `PROJECT_TYPE` - "new" or "existing"
- `EXISTING_COMMANDS` - (existing only) Commands found in project

---

## Phase 0: Project Setup (ALL MODES)

This phase runs for ALL projects. Complete these steps:

### 0.1 Check Prerequisites

```
- Verify we're in a project directory (not the framework itself)
- Check if .claude/CLAUDE.md already exists (warn if overwriting)
- Verify .claude/ directory exists (should exist from clone)
```

### 0.2 Initialize CLAUDE.md

1. Read the template: `.claude/templates/CLAUDE.template.md`
2. Customize the template using gathered/discovered information:
   - Replace `[Project Name]` with `PROJECT_NAME`
   - Replace `[brief description of what the project does]` with `PROJECT_DESCRIPTION`
   - Update Section 3 (Project Overview) with tech stack:
     - Backend: (from TECH_STACK)
     - Frontend: (from TECH_STACK)
     - Database: (from TECH_STACK or infer)
   - **For existing projects (--current):**
     - Update Section 4 (Essential Commands) with `EXISTING_COMMANDS`
     - Update Section 5 (Architecture Summary) with discovered structure
3. Write customized content to: `.claude/CLAUDE.md`

### 0.3 Initialize Memories Structure

Create the following files if they don't exist:

```
.claude/memories/
├── sessions/
│   └── latest.md       # "No previous session recorded."
├── general.md          # "# General Memories\n\nProject-wide learnings."
└── progress-notes.md   # "# Progress Notes\n\n## Current Status\nProject initialized."
```

### 0.4 Initialize Reference Documents

Copy reference templates (remove .template suffix):

```
.claude/reference/
├── 01-system-overview.md
├── 02-architecture-and-tech-stack.md
├── 03-security-auth-and-access.md
├── 04-development-standards-and-structure.md
├── 05-operational-and-lifecycle.md
├── 06-architecture-decisions.md
└── 07-non-functional-requirements.md
```

### 0.5 Initialize Git (if needed)

```bash
# Only if .git doesn't exist
git init
git add CLAUDE.md .claude/
git commit -m "chore: Initialize Claude Forge framework

- Add CLAUDE.md project instructions
- Initialize .claude/ framework structure
- Set up memories and reference docs

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 0.6 Standard Mode Complete

If NOT autonomous mode, display completion message:

```
## Project Initialized

Your project is now set up with Claude Forge framework.

### What's Ready:
- CLAUDE.md - Your project instructions (customize this!)
- .claude/memories/ - Session continuity
- .claude/reference/ - Architecture documentation templates

### Next Steps:
1. Customize CLAUDE.md with your project details
2. Fill in reference docs as you make decisions
3. Start developing with `/reflect resume` at each session start

### Available Commands:
| Command | Purpose |
|---------|---------|
| /reflect resume | Start a new session |
| /reflect | End session, capture learnings |
| /new-feature | Develop a new feature |
| /fix-bug | Fix a bug |
| /create-pr | Create a pull request |

Happy coding!
```

**STOP HERE if Standard Mode.**

---

## Autonomous Mode Only (Phases 1-5)

If `--autonomous` flag was provided, continue with the full autonomous workflow:

### Phase 1: Requirements Discovery

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 1 section)

1. Invoke @analyst agent to gather requirements
2. Invoke @project-manager agent to create PRD
3. Save PRD to `docs/prd.md`
4. **CHECKPOINT**: Present PRD summary, ask user for approval

### Phase 2: Feature Breakdown

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 2 section)

1. Invoke @scrum-master agent
2. Break PRD into epics and user stories
3. Map to 20 feature categories (see FEATURE-CATEGORIES.md)
4. Create features in database (50-400+ features)
5. Generate feature-breakdown.md
6. **CHECKPOINT**: Show feature breakdown, ask for approval

### Phase 3: Technical Planning

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 3 section)

1. Invoke @architect agent
2. Create Architecture Decision Records (ADRs)
3. Update `.claude/reference/06-architecture-decisions.md`
4. If UI project: Invoke @ux-designer for wireframes
5. **CHECKPOINT**: Review ADRs, confirm tech stack

### Phase 4: Implementation Readiness

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 4 section)

1. Scaffold project based on tech stack
2. Set up MCP servers (feature-tracking, browser-automation)
3. Initialize security model
4. Create `init.sh` for dev server
5. Configure testing mode

### Phase 5: Kickoff

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 5 section)

1. Generate project summary
2. Show first 5 features to implement
3. Ask user: "Ready to begin implementation?"
4. If approved: Invoke `/implement-features`

---

## Reference Documents

For detailed phase instructions, read:
- `.claude/skills/new-project/PHASES.md`
- `.claude/skills/new-project/FEATURE-CATEGORIES.md`
- `.claude/skills/new-project/TESTING-MODES.md`

For templates, use:
- `.claude/templates/prd.md`
- `.claude/templates/adr-template.md`
- `.claude/templates/feature-spec.md`
