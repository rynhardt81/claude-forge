# Memory Category Definitions

## ID Generation

Each category uses a unique prefix:

| Category | Prefix | Example |
|----------|--------|---------|
| Bug | BUG- | BUG-001 |
| Decision | DEC- | DEC-001 |
| Pattern | PAT- | PAT-001 |
| Fact | (none) | (no IDs) |

To generate next ID:
1. Read ToC from relevant .md file
2. Find highest existing number
3. Increment by 1
4. Pad to 3 digits

---

## Bug Entry Format

```markdown
## [BUG-XXX] Title Here
**Date:** YYYY-MM-DD
**Task:** TXXX (optional)
**Tags:** #tag1 #tag2

**Symptoms:** What was observed

**Root Cause:** Why it happened

**Solution:**
1. Step one
2. Step two

**Prevention:** How to avoid in future (optional)

**See Also:**
- `KEY-FACT:xxx` - Related fact (optional)
- `DEC-XXX` - Related decision (optional)

---
```

### Required Fields
- Title
- Date
- Tags (at least one)
- Symptoms
- Root Cause
- Solution

### Optional Fields
- Task
- Prevention
- See Also

---

## Decision Entry Format

```markdown
## [DEC-XXX] Title: Option A over Option B
**Date:** YYYY-MM-DD
**Context:** What prompted this decision
**Tags:** #tag1 #tag2

**Options Considered:**
1. Option A - brief description
2. Option B - brief description
3. Option C - brief description (optional)

**Decision:** Option A

**Rationale:**
- Reason one
- Reason two
- Reason three

**Consequences:**
- Trade-off one
- Trade-off two

**See Also:**
- `KEY-FACT:xxx` - Related fact (optional)
- `PAT-XXX` - Related pattern (optional)

---
```

### Required Fields
- Title (format: "Choice: X over Y")
- Date
- Context
- Tags
- Options Considered (at least 2)
- Decision
- Rationale

### Optional Fields
- Consequences
- See Also

---

## Pattern Entry Format

```markdown
## [PAT-XXX] Pattern Name
**Date:** YYYY-MM-DD
**Tags:** #tag1 #tag2

**Pattern:**
\`\`\`language
// Code example here
\`\`\`

**Why:** Explanation of why this pattern is preferred

**See Also:**
- `DEC-XXX` - Decision that led to this pattern (optional)

---
```

### Required Fields
- Title
- Date
- Tags
- Pattern (code block)
- Why

### Optional Fields
- See Also

---

## Key Facts Format

Key facts use a simpler format - no IDs, just categorized bullet points:

```markdown
## Section Name
- **Label:** Value
- **Another Label:** Another value (see DEC-XXX)
```

### Sections
- **Environment** - Ports, URLs, credentials locations
- **Conventions** - Naming, formatting, code style
- **Dependencies** - Key libraries and why chosen

### Cross-References
Use `(see DEC-XXX)` or `(see PAT-XXX)` inline for references.

---

## ToC Regeneration

After adding/removing entries, regenerate the ToC:

1. Find `## Table of Contents` section
2. Clear existing table rows (keep header)
3. Scan file for all `## [XXX-NNN]` headers
4. Extract: ID, Title, Tags, Date
5. Sort by ID (ascending)
6. Rebuild table

**Example ToC:**

```markdown
## Table of Contents
<!-- Auto-generated: Do not edit manually -->
| ID | Title | Tags | Date |
|----|-------|------|------|
| BUG-001 | Connection Refused in Staging | #networking #vpn | 2026-01-10 |
| BUG-002 | Auth Token Race Condition | #auth #timing | 2026-01-12 |
```

---

## Cross-Reference Syntax

Use these patterns for cross-references:

| Reference | Syntax | Example |
|-----------|--------|---------|
| Bug | `BUG-XXX` | See BUG-012 |
| Decision | `DEC-XXX` | See DEC-004 |
| Pattern | `PAT-XXX` | See PAT-001 |
| Fact | `KEY-FACT:label` | See KEY-FACT:staging-db |

When loading entries, parse See Also sections and load referenced entries.
