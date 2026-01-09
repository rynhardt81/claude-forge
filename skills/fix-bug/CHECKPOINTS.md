# Checkpoint Prompts

Standard prompts for pausing between phases. Always wait for explicit user response.

---

## After Severity Analysis

```
**Bug:** [clear restatement of the issue]
**Severity:** [Critical/Normal/Minor]
**Approach:** [Fast Triage/Scientific Method]
**Phases:** [list based on severity]

Debug doc created: `docs/debug/YYYY-MM-DD-<issue>.md`

Proceed with this approach? (yes / adjust severity / abort)
```

---

## After Reproduce (Normal/Minor)

```
**What we know so far:**
- Bug triggers when: [conditions]
- Reproducible: [Yes/No/Intermittent]
- Error: [summary]

Proceed to [Hypothesize/Fix]? (yes / need more reproduction info / abort)
```

---

## After Understand (Critical)

```
**What we know so far:**
- Component affected: [X]
- Impact: [who/what is affected]
- Quick mitigation: [available/not available]

Proceed to Locate? (yes / attempt mitigation first / abort)
```

---

## After Hypothesize (Normal)

```
**What we know so far:**
[running summary]

**Hypotheses ranked:**
1. [Most likely] - Test by: [method]
2. [Possible] - Test by: [method]
3. [Less likely] - Test by: [method]

Test hypothesis #1? (yes / reorder / add hypothesis / abort)
```

---

## After Test Hypothesis - Ruled Out

```
**What we know so far:**
[updated summary]

**Ruled out:** [hypothesis] because [evidence]

Test hypothesis #[N] next? (yes / form new hypothesis / abort)
```

---

## After Test Hypothesis - Confirmed

```
**What we know so far:**
[updated summary]

**Root cause confirmed:** [description]
**Evidence:** [what proved it]

Proceed to Fix? (yes / investigate further / abort)
```

---

## After Locate (Critical)

```
**What we know so far:**
[summary]

**Bug location:** [file:line]
**Cause:** [brief description]

Proceed to Fix? (yes / investigate more / abort)
```

---

## After Fix

```
**What we know so far:**
[complete summary]

**Fix applied:**
- File(s): [list]
- Change: [summary]
- Test added: [test name]

Proceed to Verification? (yes / adjust fix / abort)
```

---

## After Verification

```
**Verification complete:**
- Original error: [resolved/still failing]
- Regression test: [pass/fail]
- Related tests: [pass/fail]

[If all pass] Ready to commit?
[If failures] Address failures first?
```

---

## Before Commit

```
**Bug fixed and verified.**

Files staged: [list]
Commit message:
> fix: [proposed message]

Debug doc: `docs/debug/YYYY-MM-DD-<issue>.md`

Commit? (yes / edit message / abort)
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y / continue | Move to next phase |
| adjust / change | Modify current assessment |
| more info / investigate | Continue current phase |
| next hypothesis | Move to next hypothesis |
| abort / stop | End workflow, preserve debug doc |
