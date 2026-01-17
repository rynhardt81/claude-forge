# Intent Detection Flow

Handles automatic detection of user intent to suggest appropriate skills.

---

## When to Run

On EVERY user message, BEFORE any other action or response.

**Prerequisites:**
- `.claude/memories/.dispatch-config.json` has `intentDetection.enabled: true`
- User message does NOT start with `/` (explicit command)

---

## Step 1: Check Exclusions

Before pattern matching, check if message should be excluded:

1. **Explicit Command:** If message starts with `/`, skip detection (user chose explicitly)
2. **Question Pattern:** Check if message is a question:
   - Starts with: "how do I", "what is", "can you", "should I", "is there", "what's the", "where is", "why does"
   - Ends with `?`
   - If question -> answer directly, skip suggestion
3. **Exclusion Patterns:** Check against configured exclusions:
   ```json
   "excludePatterns": ["how do I", "what is", "explain", "show me"]
   ```
4. **Negation Detection:** Check for negation words:
   - "don't", "do not", "never", "stop", "cancel", "not yet", "wait", "hold off", "skip"
   - If negation present -> skip suggestion

---

## Step 2: Pattern Matching

For each skill pattern in the detection library:

**Framework Skills:**
| Skill | Trigger Patterns |
|-------|------------------|
| `/new-feature` | "add feature", "implement feature", "build a", "create new", "add functionality" |
| `/fix-bug` | "fix bug", "debug", "broken", "not working", "error in", "problem with" |
| `/refactor` | "refactor", "clean up", "restructure", "improve code", "reorganize" |
| `/create-pr` | "create pr", "pull request", "ready for review", "merge request" |
| `/release` | "release", "new version", "cut release", "publish", "deploy version" |
| `/reflect resume` | "continue", "pick up where", "resume", "last session", "where did we leave off" |

**Superpowers Skills:**
| Skill | Trigger Patterns |
|-------|------------------|
| `brainstorming` | "design", "think through", "explore options", "how should we", "plan out" |
| `systematic-debugging` | "why is this", "investigate", "root cause", "diagnose" |
| `writing-plans` | "write plan", "implementation plan", "step by step", "break down" |
| `test-driven-development` | "write tests first", "tdd", "test driven" |
| `verification-before-completion` | "is it done", "verify", "check if complete", "make sure it works" |

---

## Step 3: Calculate Confidence Score

```
Base Score Calculation:
---------------------
- Exact phrase match:     0.9
- All keywords present:   0.7
- Most keywords (>=50%):  0.5
- Some keywords (>=30%):  0.3
```

---

## Step 4: Apply Context Boosters

Add to base score based on context:

| Condition | Boost | Applies To |
|-----------|-------|------------|
| Error message/stack trace present | +0.2 | /fix-bug, systematic-debugging |
| Specific file mentioned | +0.1 | /fix-bug, /refactor |
| On feature branch | +0.3 | /create-pr |
| Session files exist | +0.3 | /reflect resume |
| No existing plan | +0.2 | brainstorming |
| Recent code changes | +0.2 | verification-before-completion |
| Test files exist | +0.1 | test-driven-development |

---

## Step 5: Check Threshold

```
confidenceThreshold = config.intentDetection.confidenceThreshold  # default: 0.7

IF confidence < confidenceThreshold:
    RETURN null  # No suggestion
```

---

## Step 6: Handle Multiple Matches

If multiple skills match above threshold:
1. Sort by confidence (highest first)
2. If top score exceeds second by > 0.1: suggest top skill
3. Otherwise: present ambiguous match to user

```markdown
## Multiple Skills Match

Your request matches multiple workflows:
1. `/new-feature` (confidence: 0.82) - For adding new functionality
2. `/fix-bug` (confidence: 0.78) - For fixing existing issues

Which would you like to use?
```

---

## Step 7: Present Suggestion

**Confidence 0.7 - 0.85 (moderate):**

```markdown
This sounds like you want to [detected intent].
The `[skill]` workflow might help - it handles [brief description].

Use `[skill] [extracted args]`? [Y/n]
```

**Confidence > 0.85 (high):**

```markdown
This is a [detected intent] request. I'll use the `[skill]`
workflow which includes:
- [Phase 1]
- [Phase 2]
- [Phase 3]

Proceed with `[skill]`? [Y/n]
```

---

## Step 8: Handle Response

**User confirms (Y, yes, proceed):**
- Invoke the Skill tool with detected skill
- Extract arguments from original message

**User declines (N, no, skip):**
- Proceed with normal response
- Do not suggest again for this message

**User provides alternative:**
- Honor their explicit choice
- Use their specified skill/approach

---

## Step 9: Track Statistics

Update session stats (for `/reflect config intent` display):

```json
{
  "session": {
    "suggestionsShown": 5,
    "suggestionsAccepted": 4,
    "suggestionsDenied": 1,
    "averageConfidence": 0.81
  }
}
```

---

## Edge Cases

| Case | Example | Action |
|------|---------|--------|
| **Question vs Request** | "How do I add a feature?" | Answer question, don't suggest workflow |
| **Already In Workflow** | Mid-/new-feature: "also fix this bug" | Note for later, don't interrupt current workflow |
| **Negation** | "Don't create a PR yet" | Detect negation, skip suggestion |
| **Multiple Intent** | "Add feature and fix login bug" | Suggest primary (first mentioned), queue secondary |
| **Vague Request** | "Help with this" | Below threshold, no suggestion |
| **Mixed Signals** | "Should I add a feature?" | Question pattern -> answer, don't suggest |
