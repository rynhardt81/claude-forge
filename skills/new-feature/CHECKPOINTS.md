# Checkpoint Prompts

Standard prompts for pausing between phases. Always wait for explicit user response.

---

## After Scope Analysis

```
**Feature:** [clear restatement]
**Inferred scope:** [Small/Medium/Large]
**Recommended phases:**
1. Discovery
2. [Design - if medium/large]
3. Planning
4. Implementation (TDD)
5. Verification
6. [Review - if medium/large]
7. Commit

Proceed with this plan? (yes / adjust scope / customize phases)
```

---

## After Discovery

```
**Discovery complete.**

Summary: [2-3 sentence summary of what we're building]

Design document: `docs/plans/YYYY-MM-DD-<feature>-design.md`

Proceed to [Design/Planning]? (yes / revise understanding / abort)
```

---

## After Design

```
**Design complete.**

Key decisions:
- [Decision 1]
- [Decision 2]

Files affected: [list]

Proceed to Planning? (yes / revise design / abort)
```

---

## After Planning

```
**Plan ready.**

[N] implementation steps created. View: `docs/plans/...`

Todos populated. Proceed to Implementation? (yes / adjust plan / abort)
```

---

## After Implementation

```
**Implementation complete.**

- Files changed: [N]
- Tests added: [N]
- Tests passing: [Yes/No]

Proceed to Verification? (yes / fix issues first / abort)
```

---

## After Verification

```
**Verification complete.**

- Unit tests: [pass/fail]
- Type checks: [pass/fail]
- Linting: [pass/fail]

[If all pass] Proceed to [Review/Commit]?
[If failures] Fix these issues before continuing?
```

---

## After Review

```
**Review complete.**

Findings addressed: [N]
Code quality: [Good/Acceptable/Needs work]

Proceed to Commit? (yes / address more findings / abort)
```

---

## Before Commit

```
**Ready to commit.**

Files staged: [list]
Commit message:
> [proposed message]

Commit? (yes / edit message / stage different files / abort)
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y / continue / proceed | Move to next phase |
| revise / adjust / change | Re-run current phase with feedback |
| skip | Skip to next phase (warn if skipping verification) |
| abort / stop / cancel | End workflow, preserve work done so far |
