# Checkpoint Prompts

Standard prompts for pausing between phases. Always wait for explicit user response.

---

## After Analysis

```
**Refactor:** [clear restatement]
**Type:** [Simple/Structural/Performance]
**Risk:** [Low/Medium/High]
**Verification approach:** [Tests only / Tests + manual / Tests + benchmarks]

Proceed to define scope? (yes / adjust type / abort)
```

---

## After Scope Definition

```
**Scope defined.**

**In scope ([N] files):**
- [file1] - [change]
- [file2] - [change]

**Out of scope:**
- [file] - [reason]

**Success criteria:**
1. [criteria]

Approve this boundary? (yes / adjust scope / abort)
```

---

## After Coverage Check - Adequate

```
**Test coverage adequate for [risk level] risk.**

Baseline established:
- Tests: [N] passing
- Coverage: [X]%

Proceed to refactor? (yes / add more tests first / abort)
```

---

## After Coverage Check - Gaps

```
**Test coverage gaps detected.**

Missing coverage:
- [file/function] - no tests

Risk: [High/Medium] refactor without tests.

Options:
1. Write tests first (recommended)
2. Proceed with caution
3. Abort

Choice? (write tests / proceed / abort)
```

---

## Scope Creep Warning

```
**Scope boundary alert.**

About to modify: `[file]`
This file is marked OUT OF SCOPE.

Reason it was excluded: [reason]

Options:
1. Expand scope to include this file
2. Skip this change, stay in scope
3. Log for later and continue

Choice? (expand / skip / defer)
```

---

## Deferred Improvement Notice

```
**Improvement noticed but deferring.**

Found: [description of improvement]
File: [file]

Logged to "Deferred Improvements" in scope document.
Continuing with original scope.
```

---

## After Refactor Complete

```
**Refactor complete.**

Files changed: [N]
Tests: [all passing / N failures]
Stayed in scope: [yes / expanded to include X]

Deferred for later:
- [item 1]
- [item 2]

Proceed to verification? (yes / review changes / abort)
```

---

## After Verification - Simple

```
**Verification complete.**

Test suite: [N] tests passing
Behavior: unchanged

Ready to commit? (yes / review more / abort)
```

---

## After Verification - Structural

```
**Verification complete.**

Test suite: [N] tests passing
Import paths: updated
Structure changes:
- [change 1]
- [change 2]

Please confirm behavior is preserved: (confirmed / need to check / abort)
```

---

## After Verification - Performance

```
**Verification complete.**

Test suite: [N] tests passing

Performance comparison:
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| [metric] | [X] | [Y] | [+/-]% |

Ready to commit? (yes / investigate regression / abort)
```

---

## Before Commit

```
**Ready to commit.**

Files staged: [list]
Commit message:
> refactor: [description]

Scope document: `docs/refactors/YYYY-MM-DD-<refactor>.md`

Commit? (yes / edit message / abort)
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y / continue | Move to next phase |
| adjust / change | Modify current assessment |
| expand | Add file to scope, continue |
| skip / defer | Log for later, stay in scope |
| write tests | Pause to write tests before refactoring |
| abort / stop | End workflow, preserve scope document |
