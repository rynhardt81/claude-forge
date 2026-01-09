# Phase Execution Details

## Phase 1: Discovery

**Always runs**

**Invoke:** `Skill tool → brainstorming`

**Actions:**
1. Invoke brainstorming skill with the feature description
2. Follow brainstorming process (one question at a time)
3. Document understanding in `docs/plans/YYYY-MM-DD-<feature>-design.md`
4. Confirm scope assessment with user

**Output:** Design document created, scope confirmed

---

## Phase 2: Design

**Runs for:** Medium, Large

**Invoke:** `Task tool → @architect` (check `.claude/agents/architect.md` exists, else use built-in `architect`)

**Actions:**
1. Review the discovery output
2. Identify affected components, files, and dependencies
3. Make architecture decisions (document as ADRs if significant)
4. Add design section to the plan document

**Output:** Architecture documented, affected files listed

---

## Phase 3: Planning

**Always runs**

**Invoke:** `Skill tool → superpowers:writing-plans`

**Actions:**
1. Read the design document
2. Break into implementation steps (small: 3-5 steps, medium: 5-10, large: 10+)
3. Write plan to the design document
4. Populate TodoWrite with all steps

**Output:** Step-by-step plan, todos created

---

## Phase 4: Implementation

**Always runs**

**Invoke:** `Skill tool → superpowers:test-driven-development`

**Agent available:** `@developer` for complex code sections

**Actions:**
1. Work through TodoWrite items in order
2. For each item: write test → implement → verify test passes
3. Mark todos complete as you go
4. For complex sections, invoke developer agent

**Output:** Code complete, tests passing

---

## Phase 5: Verification

**Always runs**

**Invoke:** `Skill tool → superpowers:verification-before-completion`

**Actions:**
1. Run full test suite: `make test-unit` or project equivalent
2. Run type checks: `mypy` / `npm run type-check`
3. Run linting: project linter
4. Confirm all checks pass

**Output:** All checks green (or list of failures to address)

---

## Phase 6: Review

**Runs for:** Medium, Large

**Invoke:** `Skill tool → superpowers:requesting-code-review`

**Agent:** `@quality-engineer` (or built-in `quality-engineer`)

**Actions:**
1. Review all changes made
2. Check for security issues, edge cases, code quality
3. Address any findings
4. Document review outcome

**Output:** Review complete, adjustments made

---

## Phase 7: Commit

**Always runs**

**Actions:**
1. Run `git status` to see all changes
2. Run `git diff` to review changes
3. Stage relevant files (exclude unrelated changes)
4. Generate commit message following project conventions
5. Present commit message for approval
6. Commit on approval

**Output:** Changes committed
