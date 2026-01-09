# Learning Signal Detection

## Signal Types

### High Confidence Signals

**Direct Corrections:**
- Pattern: "No, always...", "Don't do...", "That's wrong...", "Never..."
- Extract: The correction and what should be done instead
- Example: "No, always use `async/await` instead of `.then()`"

**Explicit Preferences:**
- Pattern: "I prefer...", "Always use...", "Never use...", "I want..."
- Extract: The stated preference
- Example: "I prefer TypeScript over JavaScript for new files"

**Conditional Rules:**
- Pattern: "When X, always Y", "If X, then Y", "For X, use Y"
- Extract: The condition and the rule
- Example: "When writing tests, always use describe/it blocks"

### Medium Confidence Signals

**Approval Patterns:**
- Pattern: "Yes", "Perfect", "That's correct", "Keep doing this", "This works"
- Extract: What was approved (requires context of what Claude just did)
- Example: User says "Perfect" after Claude used a specific component

**Repeated Choices:**
- Pattern: User selects same option 3+ times across sessions
- Extract: The preferred option and context
- Example: User always chooses "yes" when asked about running tests

**Successful Patterns:**
- Pattern: Solution accepted without modification
- Extract: The approach that worked
- Example: Error handling pattern that user approved

### Low Confidence Signals

**Observations:**
- Pattern: Patterns noticed but not explicitly confirmed
- Extract: The observation, flagged for review
- Example: User seems to prefer shorter variable names

**Implied Context:**
- Pattern: Information revealed during conversation
- Extract: Contextual knowledge that might be useful
- Example: "We use PostgreSQL" mentioned in passing

---

## Extraction Process

1. Scan conversation turn by turn
2. Identify signal patterns using keywords and context
3. Extract the learning in actionable form
4. Assign confidence level
5. Match to skill or general memories
6. Deduplicate against existing learnings

---

## Signal Keywords

### High Confidence Keywords
- never, always, don't, do not, wrong, correct way, must, required
- I prefer, I want, I need, use X instead, stop doing, start doing

### Medium Confidence Keywords
- yes, perfect, correct, good, works, approved, like this
- that's right, exactly, keep, continue, this is better

### Low Confidence Keywords
- seems, appears, might be, could be, noticed that
- interesting, okay, fine

### Negative Signals (Exclude)
- "maybe", "sometimes", "could", "might" (too uncertain)
- Questions from user (not directives)
- Hypotheticals or examples ("for example...", "hypothetically...")
- Quoted text being discussed (not user's preference)

---

## Confidence-Based Handling

| Confidence | Default (Batch) | Auto Mode |
|------------|-----------------|-----------|
| High | Show in review, recommend apply | Auto-apply |
| Medium | Show in review, neutral | Show, require approval |
| Low | Show in review, flag as tentative | Skip or show separately |

---

## Extraction Examples

**Example 1: Direct Correction (High)**
```
User: "No, don't use useState for this. Always use useReducer for complex state."

Extracted:
- Signal: Direct correction
- Confidence: High
- Learning: "Use useReducer instead of useState for complex state"
- Target: frontend skills or memories/general.md
```

**Example 2: Approval Pattern (Medium)**
```
Claude: [Uses a specific testing pattern]
User: "Yes, that's the pattern I want"

Extracted:
- Signal: Approval pattern
- Confidence: Medium
- Learning: "Testing pattern approved: [describe pattern]"
- Target: Skill that was active (/fix-bug or /new-feature)
```

**Example 3: Observation (Low)**
```
User: [Consistently chooses shorter function names across 3 sessions]

Extracted:
- Signal: Repeated pattern
- Confidence: Low
- Learning: "User may prefer shorter function names"
- Target: Flag for review, don't auto-apply
```
