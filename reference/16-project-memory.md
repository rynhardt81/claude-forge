# Project Memory System

## Overview

The Project Memory System solves "AI Project Amnesia" - the problem where AI assistants forget bug patterns, architectural decisions, and project-specific knowledge between sessions.

Unlike session memories (`.claude/memories/`), project memories live in `docs/project-memory/` and are committed to git, making them:
- Persistent across all sessions
- Shared with team members
- Available to any AI assistant working on the codebase

## Directory Structure

```
docs/project-memory/
├── bugs.md          # Bug patterns, fixes, gotchas
├── decisions.md     # Technical & architectural decisions
├── key-facts.md     # Project config, ports, conventions
├── patterns.md      # Code patterns & preferred approaches
└── archive.db       # SQLite archive (created on first use)
```

## Memory Categories

### bugs.md

Captures bug patterns, root causes, and solutions.

**When to add:**
- After fixing a non-trivial bug
- When a bug has a non-obvious root cause
- When a solution might help future debugging

**What to capture:**
- Symptoms (what was observed)
- Root cause (why it happened)
- Solution (how to fix)
- Prevention (how to avoid)

### decisions.md

Captures technical and architectural decisions.

**When to add:**
- After choosing between technologies
- When making architectural decisions
- When establishing conventions
- When trade-offs were considered

**What to capture:**
- Context (what prompted the decision)
- Options considered
- Decision made
- Rationale (why this choice)
- Consequences (trade-offs)

### key-facts.md

Captures project configuration and conventions.

**When to add:**
- Environment-specific configuration (ports, URLs)
- Naming conventions
- Tool configurations
- Dependency choices

**Format:** Simple bullet points, no IDs.

### patterns.md

Captures code patterns and conventions.

**When to add:**
- Preferred way to do common tasks
- Code examples that should be reused
- Patterns that differ from defaults

## Commands

See `/remember` skill for full command reference.

| Command | Purpose |
|---------|---------|
| `/remember bug "desc"` | Add bug pattern |
| `/remember decision "desc"` | Add decision |
| `/remember fact "desc"` | Add key fact |
| `/remember pattern "desc"` | Add code pattern |
| `/remember search "query"` | Search memories |
| `/remember archive` | Archive old entries |

## Smart Loading

When resuming work, memories are loaded based on task type:

| Task Type | Primary | Secondary | Always |
|-----------|---------|-----------|--------|
| Bug fix | bugs.md | decisions.md | key-facts.md |
| Feature | patterns.md | decisions.md | key-facts.md |
| Architecture | decisions.md | patterns.md | key-facts.md |
| Refactor | patterns.md | bugs.md | key-facts.md |

**Loading strategy:**
1. Load key-facts.md fully (~300 tokens)
2. Load primary ToC, match entries by keywords
3. Load secondary ToC only (awareness)
4. Check cross-references, load if relevant

**Token budget:** ~1,300 tokens max for memory loading.

## Archive Database

The `archive.db` SQLite database is created on first use:
- `/remember archive` - Creates and populates
- `/remember init-archive` - Creates and indexes without archiving

**Features:**
- Full-text search (FTS5)
- Category filtering
- Supersession tracking
- Cross-reference storage

**When to archive:**
- When active files grow too large (>20 entries)
- For entries older than 6-12 months
- To improve ToC scanning performance

## Integration Points

### /fix-bug

- **Before:** Searches bugs.md for similar issues
- **After:** Prompts to save bug pattern

### /reflect resume

- Loads relevant memories based on task type
- Presents: "Project context loaded: 3 relevant bugs, 2 decisions"

### Session End

- Scans conversation for learnings
- Prompts to extract to appropriate category

### Agents

| Agent | Loads |
|-------|-------|
| @architect | decisions.md |
| @developer | patterns.md |
| @quality-engineer | bugs.md |

## Best Practices

1. **Add memories as you learn** - Don't wait until later
2. **Use tags consistently** - Helps with matching
3. **Keep key-facts.md small** - It's always fully loaded
4. **Cross-reference** - Link related entries
5. **Archive periodically** - Keep active files lean
6. **Be specific** - Vague entries aren't useful

## Comparison: Session vs Project Memory

| Aspect | Session Memory | Project Memory |
|--------|----------------|----------------|
| Location | `.claude/memories/` | `docs/project-memory/` |
| Committed to git | Optional | Yes |
| Scope | Work done | Knowledge learned |
| Lifespan | Session | Permanent |
| Shared | No | Yes (via git) |
