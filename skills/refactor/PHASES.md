# Phase Execution Details

## Phase 1: Analyze

**Always runs**

**Actions:**
1. Parse refactor description
2. Infer type using TYPE-RULES.md
3. Identify affected files/components
4. Assess risk level

**Output:** Type and risk determined

**Checkpoint:** "Refactor: [description]. Type: [X]. Risk: [Y]. Proceed to define scope?"

---

## Phase 2: Define Scope

**Always runs**

**Actions:**
1. Create scope document from SCOPE-TEMPLATE.md at `docs/refactors/YYYY-MM-DD-<refactor>.md`
2. List all files in scope with intended changes
3. Explicitly list out-of-scope items
4. Define success criteria
5. Present boundary for approval

**Output:** Scope document created

**Checkpoint:** "Scope defined: [N] files in scope. Out of scope: [list]. Approve boundary?"

---

## Phase 3: Verify Test Coverage

**Always runs**

**Actions:**
1. Identify tests covering in-scope code
2. Assess coverage against risk level (see risk matrix in TYPE-RULES.md)
3. If gaps exist: checkpoint to write tests or proceed
4. Run full test suite - establish green baseline
5. For performance refactors: run benchmarks, record baseline

**Output:** Green baseline, coverage adequate

**Checkpoint (adequate):** "Coverage adequate. Baseline: [N] tests passing. Proceed to refactor?"
**Checkpoint (gaps):** "Coverage gaps in [files]. Write tests first or proceed with caution?"

---

## Phase 4: Refactor

**Always runs**

**Actions:**
1. Work through in-scope files systematically
2. Make incremental changes
3. Run tests after each significant change
4. If tempted to touch out-of-scope file → stop and checkpoint
5. Log any deferred improvements discovered
6. Update scope document with changes made

**Output:** Refactored code, tests still passing

**Checkpoint:** "Refactor complete. [N] files changed. Tests passing. Proceed to verify?"

**Scope Creep Checkpoint:** "About to modify [file] which is out of scope. Expand scope? (yes/no/defer)"

---

## Phase 5: Verify

**Based on type:**

### Simple Refactor
1. Run full test suite
2. Confirm all tests pass

### Structural Refactor
1. Run full test suite
2. Verify import paths updated correctly
3. Manual checkpoint: "Review these structural changes: [list]. Behavior preserved?"

### Performance Refactor
1. Run full test suite
2. Run benchmarks
3. Compare against baseline
4. Present results: "Before: [X]. After: [Y]. Improvement: [Z%]"

**Checkpoint:** "Verification complete. [Results]. Ready to commit?"

---

## Phase 6: Commit

**Always runs**

**Actions:**
1. Stage refactored files
2. Generate commit message: `refactor: <description>`
3. Reference scope document in commit

**Checkpoint:** "Ready to commit. Message: [X]. Commit?"
