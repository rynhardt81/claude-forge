---
name: remember
description: Manage project memories - bugs, decisions, facts, and patterns that persist across sessions. Use /remember to add, search, or archive project knowledge.
---

# Remember Skill

## Purpose

Capture and retrieve project knowledge that persists across sessions:
- **Bug patterns** - Root causes and solutions for future reference
- **Decisions** - Technical and architectural choices with rationale
- **Key facts** - Project configuration, conventions, environment details
- **Patterns** - Code patterns and preferred approaches

## Commands Overview

| Command | Purpose |
|---------|---------|
| `/remember bug "description"` | Add a bug pattern |
| `/remember decision "description"` | Add a technical decision |
| `/remember fact "description"` | Add a key fact |
| `/remember pattern "description"` | Add a code pattern |
| `/remember search "query"` | Search memories (prompts for archive) |
| `/remember search "query" --archive` | Include archive automatically |
| `/remember search "query" --active-only` | Skip archive prompt |
| `/remember show bugs` | Show bugs.md ToC |
| `/remember show decisions` | Show decisions.md ToC |
| `/remember show facts` | Show key-facts.md |
| `/remember show patterns` | Show patterns.md ToC |
| `/remember archive` | Archive old entries (prompts for date) |
| `/remember archive --before YYYY-MM-DD` | Archive with specified date |
| `/remember archive --dry-run` | Preview what would be archived |
| `/remember init-archive` | Initialize archive database |

---

## Adding Memories

### `/remember bug "description"`

Add a bug pattern to project memory.

**Flow:**

1. Parse the description
2. Generate next ID (BUG-XXX)
3. Prompt for additional details:
   - Symptoms (what did you observe?)
   - Root cause (why did it happen?)
   - Solution (how did you fix it?)
   - Prevention (how to avoid in future?)
   - Tags (for categorization)
   - Related task ID (if any)
4. Check for duplicates in ToC
5. Format entry using template from CATEGORIES.md
6. Append to `docs/project-memory/bugs.md`
7. If `archive.db` exists, INSERT into database
8. Regenerate ToC
9. Confirm to user

**Output:**

```markdown
## Added Bug Pattern

**ID:** BUG-003
**Title:** Connection refused means VPN is down
**Tags:** #networking #vpn

Entry added to `docs/project-memory/bugs.md`
```

---

### `/remember decision "description"`

Add a technical decision to project memory.

**Flow:**

1. Parse the description
2. Generate next ID (DEC-XXX)
3. Prompt for additional details:
   - Context (what prompted this decision?)
   - Options considered (what alternatives existed?)
   - Decision (what did you choose?)
   - Rationale (why this choice?)
   - Consequences (what are the trade-offs?)
   - Tags (for categorization)
4. Check for duplicates
5. Format and append to `docs/project-memory/decisions.md`
6. Sync to archive.db if exists
7. Regenerate ToC
8. Confirm to user

---

### `/remember fact "description"`

Add a key fact to project memory.

**Flow:**

1. Parse the description
2. Determine category (Environment, Conventions, Dependencies)
3. Format as bullet point
4. Append to appropriate section in `docs/project-memory/key-facts.md`
5. Confirm to user

**Note:** key-facts.md does not use IDs or ToC - it's a simple reference file.

---

### `/remember pattern "description"`

Add a code pattern to project memory.

**Flow:**

1. Parse the description
2. Generate next ID (PAT-XXX)
3. Prompt for additional details:
   - Code example
   - Why this pattern?
   - Tags
4. Format and append to `docs/project-memory/patterns.md`
5. Sync to archive.db if exists
6. Regenerate ToC
7. Confirm to user

---

## Searching Memories

### `/remember search "query"`

Search across project memories.

**Flow:**

1. Read ToC from all memory files:
   - `docs/project-memory/bugs.md`
   - `docs/project-memory/decisions.md`
   - `docs/project-memory/patterns.md`
2. Match query against:
   - Entry titles
   - Tags
   - Keywords
3. Present active matches with file and ID
4. Ask: "Also search archived memories? [Y/n]"
5. If yes and `archive.db` exists:
   - Query `memories_fts` table
   - Present archived matches marked [ARCHIVED]
6. Offer to load full entries: "Load any entry? [Enter ID or 'n']"

**Output:**

```markdown
## Search Results: "authentication"

### Active Memories
- [BUG-012] Auth Token Race Condition - #auth #timing
- [DEC-004] JWT with Refresh Tokens - #auth #security

Also search archived memories? [Y/n]
```

---

## Archiving

### `/remember archive`

Archive old entries to database.

**Flow:**

1. Prompt for cutoff date:
   ```
   Archive entries older than which date?

   1. 6 months ago (YYYY-MM-DD)
   2. 12 months ago (YYYY-MM-DD)
   3. Custom date
   4. Cancel
   ```
2. Scan all .md files for entries older than cutoff
3. Show count by category
4. Confirm with user
5. Create `archive.db` if missing (see ARCHIVE.md)
6. For each entry:
   - INSERT into memories table
   - Remove from .md file
7. Regenerate ToCs
8. Report results

---

### `/remember init-archive`

Initialize archive database without moving entries.

**Flow:**

1. Confirm action with user
2. Create `docs/project-memory/archive.db`
3. Create schema (see ARCHIVE.md)
4. Index ALL current entries (without removing from .md)
5. Report count indexed

**Use case:** Enable full-text search from day one.

---

## File Locations

```
docs/project-memory/
├── bugs.md          # Active bug patterns
├── decisions.md     # Active technical decisions
├── key-facts.md     # Project configuration (always active)
├── patterns.md      # Active code patterns
└── archive.db       # SQLite archive (created on first use)
```

---

## Integration

This skill integrates with:

- `/fix-bug` - Searches bugs.md before investigating, prompts to save after
- `/reflect resume` - Loads relevant memories based on task type
- Session end - Prompts to extract learnings

See EXTRACTION.md for session integration details.
