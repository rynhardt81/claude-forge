# Session Memory Extraction

## When Extraction Happens

| Trigger | Extraction? | Behavior |
|---------|-------------|----------|
| Real-time session updates | No | Just updating session file |
| Task completion | No | Continue to next task |
| Pre-compact hook | Optional | Quick prompt if learnings detected |
| Session end (explicit) | Yes | Full extraction prompts |
| Feature/Epic completion | Yes | Full extraction prompts |

**Key principle:** Extraction is intentional, not automatic. We want signal, not noise.

## Detection Patterns

When ending a session, scan conversation for these patterns:

### Bug Pattern Indicators
- "Fixed by", "The issue was", "Root cause was"
- Error messages followed by solutions
- "This happened because", "The problem was"
- Debugging sessions that concluded

### Decision Indicators
- "Chose X over Y", "Decided to use"
- "We went with", "Selected X because"
- Comparison discussions with conclusions
- Architecture or technology choices

### Fact Indicators
- Configuration values discovered
- Environment-specific details
- "Port is actually", "The URL is"
- Credentials or connection details

### Pattern Indicators
- "Always do X when", "The pattern is"
- Code examples that should be reused
- "Best practice", "Convention is"

## Extraction Flow

At session end:

```
1. Scan conversation for detection patterns
2. Group potential memories by category
3. Present to user:

## Session End - Memory Extraction

Before closing, I noticed some potential project memories:

**Possible Bug Pattern:**
> Fixed CORS error by adding explicit origin - turns out
> the proxy strips headers unless explicitly configured

Save to bugs.md? [Y/n]

**Possible Decision:**
> Chose React Query over SWR for data fetching due to
> better cache invalidation options

Save to decisions.md? [Y/n]

**Key Fact Detected:**
> API rate limit is 100 requests/minute per API key

Save to key-facts.md? [Y/n]

4. For each confirmed extraction:
   - Invoke /remember with pre-filled description
   - Prompt for remaining details
   - Save entry
```

## Pre-Compact Extraction

When context window is filling (pre-compact hook):

```
## Quick Memory Capture

Context is being compacted. Any learnings to save first?

- Bug pattern? [Y/n]
- Decision made? [Y/n]
- Important fact? [Y/n]
- Code pattern? [Y/n]

(Select any to capture before context is summarized)
```

This is lighter-weight than full session-end extraction.

## Integration with /fix-bug

### Before Investigation (Phase 0)

```
1. Read docs/project-memory/bugs.md ToC
2. Extract keywords from bug description
3. Match against ToC entries (title + tags)
4. If matches found:
   - Load matching entry content
   - Present: "Found similar past bugs:"
   - Show BUG-XXX: Title - brief summary
5. Proceed to Phase 1 with context
```

### After Fix (Phase 5.5 - New)

```
1. After verification passes
2. Check if this was a novel bug pattern
3. Prompt: "This bug might help future debugging. Save pattern?"
4. If yes: /remember bug with pre-filled details
```

## Integration with /reflect resume

When resuming, load memories based on task type:

### Detection Flow

```
/reflect resume T042
         ↓
1. Read task from registry
2. Determine task type from:
   - Task title keywords
   - Epic category
   - Task description
         ↓
3. Task type → Memory loading:
   - bug/fix → bugs.md primary, decisions.md secondary
   - feature → patterns.md primary, decisions.md secondary
   - architecture → decisions.md primary, patterns.md secondary
   - refactor → patterns.md primary, bugs.md secondary
         ↓
4. Always load key-facts.md (full file)
5. Load primary category (ToC + matching entries)
6. Load secondary category (ToC only)
7. Check cross-references, load if relevant
```

### Token Budget

| Component | Max Tokens |
|-----------|------------|
| key-facts.md | 300 |
| Primary (ToC + matches) | 500 |
| Secondary (ToC only) | 100 |
| Cross-references | 400 |
| **Total** | **~1300** |

## Smart Matching

When loading memories for a task, match using:

1. **Keywords from task** - Title, description words
2. **Tags** - Direct tag matching
3. **Cross-references** - If loaded entry references another

Example:
```
Task: "Fix auth timeout issue"
         ↓
Keywords: auth, timeout, issue, fix
         ↓
Match bugs.md ToC:
- BUG-002 "Auth Token Race Condition" (#auth #timing) ✓ match
- BUG-007 "Session Timeout Handling" (#auth #timeout) ✓ match
         ↓
Load BUG-002, BUG-007 full entries
```
