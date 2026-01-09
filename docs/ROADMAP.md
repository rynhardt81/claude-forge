# Claude Forge Roadmap

**Created:** 2026-01-09
**Status:** Planning Complete - Ready for Implementation

---

## Overview

This roadmap captures planned enhancements to the Claude Forge framework, following the **Hybrid Model** approach where:
- **Skills** = User-facing workflows (keep focused, avoid proliferation)
- **Agents** = Expertise workers that skills orchestrate

---

## Completed in This Session

- [x] Epic/Task dependency system with parallel work support
- [x] Task registry schema (`templates/task-registry.json`)
- [x] Task template with continuation context (`templates/task.md`)
- [x] Epic template (`templates/epic-minimal.md`)
- [x] Project config template (`templates/config.json`)
- [x] `/reflect` skill updates (resume E01/T002, status, unlock, config)
- [x] `/reflect` command definition
- [x] Phase 3 updated to generate epic/task structure
- [x] CLAUDE.md updated with task management docs
- [x] README.md comprehensive update
- [x] Template cleanup (epic.md renamed to epic-full.md)

---

## Phase 1: `/help` Skill (HIGH PRIORITY)

**Purpose:** Framework discoverability for new users

### Files to Create
```
skills/help/
├── SKILL.md           # Main skill definition
├── COMMANDS.md        # All available commands
├── AGENTS.md          # Agent catalog with usage examples
├── FAQ.md             # Common questions
└── QUICKSTART.md      # Getting started guide

commands/help.md       # Command definition
```

### Skill Behavior
```
/help                  → Overview + quick reference
/help commands         → All available commands
/help agents           → Agent catalog
/help <topic>          → Specific topic (e.g., /help tasks, /help resume)
/help faq              → Frequently asked questions
```

### Content to Include
- Index of all commands with descriptions
- Agent catalog with "when to use" guidance
- Template reference
- Common workflows (new project → tasks → implementation)
- Troubleshooting quick reference

---

## Phase 2: Enhance `/fix-bug` with Troubleshooting

**Purpose:** Better error recovery and debugging guidance

### Files to Create/Modify
```
skills/fix-bug/
├── SKILL.md           # Existing - enhance
├── TROUBLESHOOTING.md # NEW - error patterns & recovery
├── COMMON-ERRORS.md   # NEW - known issues by tech stack
└── ROLLBACK.md        # NEW - how to undo changes
```

### Content to Add
- Common error patterns by category
- Recovery procedures for failed implementations
- Rollback guidance (git reset, revert, etc.)
- Link to `/reflect unlock` for stuck tasks
- Debug checklist by error type

---

## Phase 3: Code Templates by Tech Stack

**Purpose:** Give @developer starter patterns for common code

### Directory Structure
```
templates/code/
├── react/
│   ├── component.tsx
│   ├── hook.ts
│   ├── context.tsx
│   └── test.tsx
├── nextjs/
│   ├── page.tsx
│   ├── api-route.ts
│   ├── middleware.ts
│   └── server-action.ts
├── express/
│   ├── route.ts
│   ├── middleware.ts
│   ├── controller.ts
│   └── model.ts
├── fastapi/
│   ├── route.py
│   ├── model.py
│   ├── schema.py
│   └── service.py
├── prisma/
│   └── model.prisma
├── tests/
│   ├── unit.ts
│   ├── integration.ts
│   └── e2e.ts
└── README.md          # How agents use these templates
```

### Agent Integration
- Update `@developer` agent to reference code templates
- Templates selected based on project tech stack (from CLAUDE.md or config)
- Agents should adapt templates, not copy verbatim

---

## Phase 4: Multi-Agent Coordination Documentation

**Purpose:** Ensure agents respect task dependencies and don't conflict

### Files to Create/Modify
```
docs/PARALLEL-WORK.md           # NEW - coordination protocol
agents/developer.md             # Update with task awareness
agents/quality-engineer.md      # Update with task awareness
reference/10-multi-agent.md     # NEW - detailed coordination guide
```

### Protocol to Document

```markdown
## Before Starting Any Task

1. **Check task status:** Run `/reflect status T00X`
   - Must be `ready` or `continuation`
   - NOT `pending` (dependencies not met)
   - NOT `in_progress` (locked by another agent)

2. **Acquire lock:** Automatic when starting via `/reflect resume T00X`

3. **Check dependencies:** What tasks depend on yours?
   - Complete fully before moving on
   - Don't leave partial work without continuation context

4. **If stopping mid-task:**
   - Update continuation context in task file
   - Status becomes `continuation`
   - Lock released for future resume

5. **On completion:**
   - Mark task as `completed`
   - Registry automatically updates dependent tasks to `ready`
   - Commit changes with task ID in message
```

### Conflict Prevention
- Only one agent can lock a task at a time
- Lock timeout (default 1 hour) prevents permanent blocks
- `/reflect status --locked` shows all active locks
- `/reflect unlock T00X` for manual intervention

---

## Future Considerations (Lower Priority)

### Progress Visualization
- Dashboard view of project status
- Dependency graph visualization
- Burndown tracking

### Changelog Automation
- Generate changelog from git commits
- Version bump automation
- Release notes from task descriptions

### Deployment Workflow
- `/deploy` skill for common platforms
- Environment management
- CI/CD templates

---

## Implementation Order

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 1 | `/help` skill | Medium | High - discoverability |
| 2 | Multi-agent protocol docs | Low | High - prevents conflicts |
| 3 | `/fix-bug` troubleshooting | Low | Medium - error recovery |
| 4 | Code templates | Medium | Medium - faster development |

---

## How to Resume This Work

```bash
# In a new session:
/reflect resume

# Or read this roadmap directly:
# Read docs/ROADMAP.md for planned enhancements
```

### Key Files for Context
- `docs/ROADMAP.md` - This file (implementation plan)
- `skills/reflect/SKILL.md` - Task management commands
- `skills/new-project/SKILL.md` - Phase 3 task generation
- `templates/task.md` - Task file format
- `templates/epic-minimal.md` - Epic file format
- `CLAUDE.md` - Framework overview

---

## Design Principles (Remember These)

1. **Skills are workflows, agents are expertise**
   - Don't create narrow skills for single tasks
   - Use agents directly for focused work

2. **Dependency-aware everything**
   - Tasks respect dependencies
   - Agents check before starting
   - System prevents conflicts

3. **Minimal context loading**
   - Resume operations stay under 8k tokens
   - Load only what's needed for the task

4. **Atomic tasks**
   - Each task completable in one session
   - Prevents context window exhaustion

5. **Documentation-first**
   - Every project gets PRD, ADRs, task breakdown
   - This is what makes AI-assisted dev effective

---

*This roadmap was created during session 2026-01-09 to preserve planning context for future implementation.*
