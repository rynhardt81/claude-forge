# Archive Database

## Overview

The archive database (`docs/project-memory/archive.db`) provides:
- Searchable history of all memories
- Full-text search across archived entries
- Category and tag filtering
- Supersession tracking

## Lazy Initialization

The database is created on first use:
- `/remember archive` - Creates DB, then archives
- `/remember search --archive` - Creates empty DB if missing
- `/remember init-archive` - Creates DB and indexes all current entries

## Schema

```sql
-- Core memories table
CREATE TABLE memories (
    id TEXT PRIMARY KEY,           -- BUG-001, DEC-002, PAT-003
    category TEXT NOT NULL,        -- 'bug', 'decision', 'fact', 'pattern'
    title TEXT NOT NULL,
    content TEXT NOT NULL,         -- Full markdown content
    tags TEXT,                     -- JSON array: ["#auth", "#api"]
    created_date DATE NOT NULL,
    archived_date DATE,            -- NULL if still active
    task_id TEXT,                  -- T042 (optional)
    status TEXT DEFAULT 'active',  -- 'active', 'archived', 'superseded'
    superseded_by TEXT,            -- ID of newer entry
    FOREIGN KEY (superseded_by) REFERENCES memories(id)
);

-- Cross-references between memories
CREATE TABLE memory_references (
    from_id TEXT NOT NULL,
    to_id TEXT NOT NULL,
    PRIMARY KEY (from_id, to_id),
    FOREIGN KEY (from_id) REFERENCES memories(id),
    FOREIGN KEY (to_id) REFERENCES memories(id)
);

-- Full-text search index
CREATE VIRTUAL TABLE memories_fts USING fts5(
    id,
    title,
    content,
    tags,
    content='memories',
    content_rowid='rowid'
);

-- Triggers to keep FTS in sync
CREATE TRIGGER memories_ai AFTER INSERT ON memories BEGIN
    INSERT INTO memories_fts(rowid, id, title, content, tags)
    VALUES (NEW.rowid, NEW.id, NEW.title, NEW.content, NEW.tags);
END;

CREATE TRIGGER memories_ad AFTER DELETE ON memories BEGIN
    INSERT INTO memories_fts(memories_fts, rowid, id, title, content, tags)
    VALUES('delete', OLD.rowid, OLD.id, OLD.title, OLD.content, OLD.tags);
END;

CREATE TRIGGER memories_au AFTER UPDATE ON memories BEGIN
    INSERT INTO memories_fts(memories_fts, rowid, id, title, content, tags)
    VALUES('delete', OLD.rowid, OLD.id, OLD.title, OLD.content, OLD.tags);
    INSERT INTO memories_fts(rowid, id, title, content, tags)
    VALUES (NEW.rowid, NEW.id, NEW.title, NEW.content, NEW.tags);
END;

-- Indexes
CREATE INDEX idx_memories_category ON memories(category);
CREATE INDEX idx_memories_status ON memories(status);
CREATE INDEX idx_memories_created ON memories(created_date);
```

## Operations

### Create Database

```sql
-- Run schema above to initialize
```

### Insert Memory

```sql
INSERT INTO memories (id, category, title, content, tags, created_date, status)
VALUES (?, ?, ?, ?, ?, ?, 'active');
```

### Archive Memory

```sql
UPDATE memories
SET status = 'archived', archived_date = ?
WHERE id = ?;
```

### Search Memories

```sql
SELECT m.*,
       highlight(memories_fts, 2, '<mark>', '</mark>') as snippet
FROM memories_fts
JOIN memories m ON memories_fts.id = m.id
WHERE memories_fts MATCH ?
ORDER BY rank;
```

### Search by Category

```sql
SELECT * FROM memories
WHERE category = ?
  AND status = 'active'
ORDER BY created_date DESC;
```

### Mark Superseded

```sql
UPDATE memories
SET status = 'superseded', superseded_by = ?
WHERE id = ?;
```

### Get Cross-References

```sql
SELECT to_id FROM memory_references
WHERE from_id = ?;
```

## Sync on Add

When adding a new entry via `/remember bug`, etc.:

1. Append to .md file (always)
2. Check if `archive.db` exists
3. If yes, INSERT into memories table

This keeps active entries in both locations.

## Archive Flow

When running `/remember archive`:

1. Query cutoff date from user
2. Scan .md files for entries older than cutoff
3. For each entry:
   a. Parse entry content
   b. INSERT/UPDATE in database with `archived_date`
   c. Remove entry from .md file
4. Regenerate ToCs
5. Report results

## Searching with Archive

```
/remember search "query"
         ↓
1. Scan active .md ToCs
2. Match and display active results
3. Ask: "Also search archived? [Y/n]"
         ↓ (yes)
4. Query: SELECT * FROM memories_fts WHERE MATCH ?
5. Display archived results marked [ARCHIVED]
6. Offer to load full entries
```
