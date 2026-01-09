# PR Description Templates

## Size Detection

| Size | Files Changed | Lines Changed |
|------|---------------|---------------|
| Small | 1-3 | <100 |
| Medium | 4-10 | 100-500 |
| Large | 10+ | 500+ |

If files and lines suggest different sizes, use the larger size.

---

## Small PR Template

```markdown
## Summary

[One sentence describing the change]

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Medium PR Template

```markdown
## Summary

[2-3 sentence overview of what this PR does]

## Changes

- [Change 1]
- [Change 2]
- [Change 3]

## Related Issues

[Linked issues or "None"]

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Large PR Template

```markdown
## Summary

[Paragraph explaining the purpose and scope of this PR]

## Changes

### [Category 1]
- [Change 1]
- [Change 2]

### [Category 2]
- [Change 3]
- [Change 4]

## Test Plan

- [ ] [How to verify change 1]
- [ ] [How to verify change 2]

## Related Issues

[Linked issues]

## Notes for Reviewers

[Any context reviewers should know]

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Draft Prefix

Prepend to any template when creating a draft PR:

```markdown
> ⚠️ **Draft PR** - Work in progress, not ready for merge.
> Looking for feedback on: [specific area or question]

```

---

## Content Generation Rules

**Summary:** Analyze commit messages and diff to describe the overall change.

**Changes list:** Group by:
- Feature/component affected
- Type of change (add, modify, remove)

**Test plan:** For each significant change, describe how to verify it works.

**Related issues:** Extract from branch name and commit messages.

**Notes for reviewers:** Include if:
- Breaking changes exist
- Migration required
- Specific areas need careful review
