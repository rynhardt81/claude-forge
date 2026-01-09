# Checkpoint Prompts

## After Analysis

```
**Branch:** [current branch]
**PR Type:** [Final/Draft]
**Size:** [Small/Medium/Large]
**Stats:** [N] commits, [M] files changed, +[A]/-[D] lines

Proceed with PR creation? (yes / change to draft / abort)
```

---

## After Target Branch Inference

```
**Target branch:** [inferred branch]
**Reasoning:** [why this target was chosen]

Create PR to [branch]? (yes / change target / abort)
```

---

## After Checks - All Pass

```
**Checks complete.**

- Tests: ✓ [N] passing
- Type check: ✓ No errors
- Lint: ✓ No issues

Proceed to generate description? (yes / run more checks / abort)
```

---

## After Checks - Failures (Final PR)

```
**Checks failed.**

- Tests: ✗ [N] failures
- Type check: ✗ [M] errors
- Lint: [status]

Cannot create final PR with failing checks.

Options:
1. Fix issues and retry
2. Create as draft instead
3. Abort

Choice? (fix / draft / abort)
```

---

## After Checks - Failures (Draft PR)

```
**Checks have issues (acceptable for draft).**

- Tests: [status]
- Type check: skipped
- Lint: skipped

Proceeding with draft PR. Note: fix before marking ready.

Continue? (yes / fix first / abort)
```

---

## After Description Generation

```
**PR Ready**

**Title:** [generated title]

**Description preview:**
---
[first 10-15 lines of description]
---

Review and create? (yes / edit title / edit description / abort)
```

---

## After PR Created

```
**PR Created Successfully**

🔗 [PR URL]

## Post-PR Checklist

**Required:**
- [ ] Verify CI checks are running
- [ ] Review description for accuracy

**Recommended:**
- [ ] Assign reviewers
- [ ] Add labels: [suggestions based on content]
- [ ] Link to project board

**If Draft:**
- [ ] Add specific questions for reviewers
- [ ] Mark ready for review when complete

**Before Merge:**
- [ ] All checks passing
- [ ] At least one approval
- [ ] No unresolved conversations

Done? (done / open in browser)
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y / continue | Move to next phase |
| draft | Switch to draft PR mode |
| edit title | Prompt for new title |
| edit description | Open description for editing |
| change target | Prompt for new target branch |
| fix | Exit workflow to fix issues |
| open / open in browser | Open PR URL in default browser |
| done | Complete workflow |
| abort / stop | Cancel PR creation |
