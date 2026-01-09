# Skill Update Rules

## Where Learnings Go

### Decision Tree

```
Is a skill identified for this learning?
├── Yes → Does the skill have a SKILL.md?
│   ├── Yes → Append to "Learned Preferences" section in SKILL.md
│   └── No → Create section, then append
└── No → Does learning relate to existing skill by keywords?
    ├── Yes → Propose update to that skill, confirm with user
    └── No → Add to .claude/memories/general.md
```

---

## Updating Skill Files

### Section Format

Add or update this section at the end of SKILL.md:

```markdown
---

## Learned Preferences

<!-- Auto-managed by /reflect - Manual edits above this line only -->

### High Confidence
- [Learning] (learned: YYYY-MM-DD)

### Medium Confidence
- [Learning] (learned: YYYY-MM-DD)

### Observations
- [Learning] (learned: YYYY-MM-DD) - [flag/note if any]

<!-- Last updated: YYYY-MM-DD -->
```

### Update Rules

| Rule | Description |
|------|-------------|
| **Append only** | Never delete or modify existing learnings automatically |
| **Preserve order** | New learnings go at bottom of their confidence section |
| **Date stamp** | Always include learn date for tracking |
| **Deduplicate** | Check for semantic duplicates before adding |
| **Conflict flag** | If new contradicts existing, flag don't replace |

---

## Updating General Memories

**Location:** `.claude/memories/general.md`

**Format:**

```markdown
# General Preferences

Last updated: YYYY-MM-DD

## Code Style
- [Preference]

## Tools & Frameworks
- [Preference]

## Workflow
- [Preference]

## Communication
- [Preference]

## Uncategorized
- [Preference] (learned: YYYY-MM-DD)
```

### Categorization

Attempt to categorize learnings:
- Code patterns → Code Style
- Library/tool choices → Tools & Frameworks
- Process preferences → Workflow
- Response format preferences → Communication
- Unknown → Uncategorized

---

## Conflict Handling

When new learning contradicts existing:

**Add to conflicts section:**
```markdown
### Conflicts (Require Resolution)

**Conflict detected:** YYYY-MM-DD
- Existing: "Always use X"
- New: "Never use X"
- Context: [where this came up]
- Action needed: User must resolve
```

**Present in review:**
```
⚠️ Conflict Detected

Existing learning (2025-01-01):
  "Always use semicolons in JavaScript"

New learning (2025-01-06):
  "Don't use semicolons, rely on ASI"

Options:
1. Keep existing, discard new
2. Replace existing with new
3. Make contextual (use X when Y, use Z when W)
4. Skip for now
```

---

## Git Commits

**Single learning:**
```
reflect: add preference to [skill-name]

Learning: [description]
Confidence: [High/Medium/Low]
Source: Session YYYY-MM-DD
```

**Multiple learnings:**
```
reflect: update [N] skills with session learnings

Skills updated:
- [skill-1]: [N] learnings
- [skill-2]: [N] learnings
- general.md: [N] learnings

Source: Session YYYY-MM-DD
```

**Session journal only:**
```
reflect: capture session YYYY-MM-DD

Summary: [brief description]
Tasks: [N] completed, [M] in progress
Skills used: [list]
```

**Combined (learnings + session):**
```
reflect: session YYYY-MM-DD with [N] learnings

Session summary: [brief]
Learnings applied:
- [skill-1]: [N] preferences
- general.md: [N] preferences
```

---

## Deduplication Logic

Before adding a learning, check:

1. **Exact match:** Same text already exists → Skip
2. **Semantic match:** Similar meaning exists → Skip, note "Already covered by: [existing]"
3. **Superset:** New learning is more specific than existing → Add as refinement
4. **Subset:** New learning is less specific than existing → Skip
5. **Contradiction:** New learning contradicts existing → Flag as conflict

---

## Retention and Cleanup

**Session journals:**
- Keep for `retention.session_days` (default: 30)
- Maximum `retention.max_sessions` (default: 50)
- Oldest sessions auto-deleted when limits exceeded

**Learnings:**
- Never auto-delete learnings
- User can manually remove via editing files
- Conflicts remain until manually resolved
