# Checkpoint Prompts

## After Signal Extraction

```
**Reflection Complete**

Session: YYYY-MM-DD
Duration: [X hours]
Skills used: [list]

## Learnings Detected

### High Confidence ([N])
1. [Learning] → target: [skill-name]
2. [Learning] → target: [skill-name]

### Medium Confidence ([N])
3. [Learning] → target: general.md
4. [Learning] → target: [skill-name]

### Low Confidence ([N])
5. [Learning] → flagged for review

## Session Summary

[Brief summary of what was done]

Review and apply? (yes / review individually / edit / skip learnings)
```

---

## Individual Learning Review

```
**Learning [N] of [Total]**

Signal: [Direct correction / Explicit preference / etc.]
Confidence: [High/Medium/Low]

Learning:
> [The extracted learning]

Context:
> [Conversation excerpt where this was found]

Target: [skill-name / general.md]

Apply? (yes / no / edit / change target)
```

---

## Conflict Resolution

```
⚠️ **Conflict Detected**

Existing ([date]):
> [Existing learning]

New ([date]):
> [New learning]

Context:
> [Where new learning came from]

Resolution:
1. Keep existing
2. Replace with new
3. Make contextual (both apply in different situations)
4. Skip for now

Choice?
```

---

## Session Capture Review

```
**Session Journal Preview**

## Summary
[Generated summary]

## Tasks
- [x] [Completed tasks]
- [ ] [Incomplete tasks]

## Next Steps
1. [Generated next steps]

## Files Modified
[List of files]

Save session journal? (yes / edit / skip)
```

---

## Resume Prompt

```
**Resume from Previous Session**

Last session: YYYY-MM-DD ([X hours ago])

**You were working on:**
[Summary]

**Completed:**
- [Tasks done]

**In progress:**
- [Unfinished tasks]

**Next steps identified:**
1. [Step 1]
2. [Step 2]

**Blockers noted:**
- [Any blockers]

Continue from here? (yes / show full journal / start fresh)
```

---

## Status Display

```
**Reflect Status**

Enabled: [on/off]
Approval mode: [batch/auto]
Auto-apply threshold: [high confidence only]

**Recent Learnings (last 7 days):**
- [N] high confidence applied
- [N] medium confidence applied
- [N] low confidence pending review

**Skills improved:**
- /new-feature: [N] learnings
- /fix-bug: [N] learnings
- general.md: [N] learnings

**Session Stats:**
- [N] sessions captured
- Oldest: YYYY-MM-DD
- Storage: [N] files

**Pending Reviews:**
- [N] low confidence learnings
- [N] conflicts to resolve

Manage? (config / review pending / clear old sessions)
```

---

## Toggle Confirmations

**Enabling:**
```
**Auto-reflect enabled**

When a session ends after using skills:
- Learnings will be extracted automatically
- Approval mode: [batch/auto]
- Session journal will be captured

Disable anytime with `/reflect off`
```

**Disabling:**
```
**Auto-reflect disabled**

Automatic reflection is now off.
You can still use `/reflect` manually.

Re-enable with `/reflect on`
```

---

## Config Changes

```
**Configuration Updated**

Changed: [setting] → [new value]

Current settings:
- Approval mode: [batch/auto]
- Auto-apply: [high confidence only / high+medium]
- Signals: [corrections, preferences, approvals, patterns]
- Session retention: [N days]
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y / apply | Apply all/current learning |
| no / n / skip | Skip current, continue to next |
| edit | Allow editing learning text |
| change target | Select different skill/memories target |
| review individually | Switch from batch to one-by-one review |
| show full journal | Display complete session journal |
| show context | Show more conversation context |
| config | Open configuration |
| start fresh | Ignore previous session, start new |
| clear old sessions | Remove sessions older than retention |
| review pending | Show pending low-confidence learnings |
