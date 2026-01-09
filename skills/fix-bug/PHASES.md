# Phase Execution Details

## Critical Bugs: Fast Triage

### Phase 1: Understand

**Goal:** Quickly grasp what's broken and impact

**Actions:**
1. Parse error message/stack trace
2. Identify affected component
3. Determine blast radius (all users? some? one?)
4. Check: can we rollback or feature-flag as quick mitigation?

**Update debug doc:** Error section, initial findings in "What We Know"

**Checkpoint:** "Critical bug in [component]. Impact: [X]. Quick mitigation available: [Y/N]. Proceed to locate?"

---

### Phase 2: Locate

**Goal:** Find the exact code causing the issue

**Actions:**
1. Trace from error/stack trace to source code
2. Identify file(s) and line(s)
3. Understand the code path that triggers the bug

**Update debug doc:** Add location to "What We Know"

**Checkpoint:** "Bug located at [file:line]. Cause appears to be [X]. Proceed to fix?"

---

### Phase 3: Fix

**Goal:** Minimal change to resolve the issue

**Actions:**
1. Make smallest possible fix - no refactoring
2. Write regression test that fails without fix, passes with fix
3. Run the new test to confirm fix works

**Update debug doc:** Fill in "Root Cause" and "Fix" sections

**Checkpoint:** "Fix applied. Test added: [test_name]. Proceed to verification?"

---

### Phase 4: Verify

**Invoke:** `Skill tool → superpowers:verification-before-completion`

**Actions:**
1. Run failing test - confirm it passes
2. Run related test suite - no regressions
3. If production: coordinate deployment and monitor

**Update debug doc:** Check off verification items, set Status to Resolved

**Checkpoint:** "All checks pass. Ready to commit?"

---

## Normal Bugs: Scientific Method

### Phase 1: Reproduce

**Invoke:** `Skill tool → superpowers:systematic-debugging`

**Goal:** Confirm the bug and document reproduction steps

**Actions:**
1. Run failing test or trigger error manually
2. Document exact steps to reproduce
3. Note: consistent or intermittent?
4. Capture exact error output

**Update debug doc:** Fill in "Error" and "Reproduction" sections

**Checkpoint:** "Bug reproduced. Triggers when [X]. Consistent: [Y/N]. Proceed to hypothesize?"

---

### Phase 2: Hypothesize

**Goal:** Form theories about root cause before touching code

**Actions:**
1. Analyze error message and code path
2. Generate 2-3 hypotheses ranked by likelihood
3. For each hypothesis, identify how to test it
4. Do NOT start fixing yet

**Update debug doc:** Fill in "Hypotheses" section

**Checkpoint:** "Hypotheses: 1) [most likely], 2) [possible], 3) [unlikely]. Test #1 first?"

---

### Phase 3: Test Hypothesis

**Goal:** Prove or disprove each hypothesis systematically

**Actions:**
1. Design minimal test for current hypothesis
2. Execute: add logging, use debugger, write test
3. Analyze result: confirmed or ruled out?
4. If ruled out: document and move to next hypothesis
5. If confirmed: proceed to fix

**Update debug doc:** Update "What We Tried" table, mark hypothesis confirmed/ruled out

**Checkpoint (ruled out):** "Hypothesis [X] ruled out because [Y]. Test hypothesis #[N] next?"
**Checkpoint (confirmed):** "Root cause confirmed: [X]. Proceed to fix?"

---

### Phase 4: Fix

**Goal:** Fix the confirmed root cause

**Actions:**
1. Implement fix targeting the root cause
2. Write regression test
3. No scope creep - only fix this bug

**Update debug doc:** Fill in "Root Cause" and "Fix" sections

**Checkpoint:** "Fix applied. Test added: [test_name]. Proceed to verification?"

---

### Phase 5: Verify

**Invoke:** `Skill tool → superpowers:verification-before-completion`

Same as Critical Phase 4.

---

## Minor Bugs: Scientific Method (Lighter)

Same as Normal but **skip Phase 2 (Hypothesize)**.

Flow: Reproduce → Fix → Verify

For simple, obvious bugs where root cause is apparent from the error.
