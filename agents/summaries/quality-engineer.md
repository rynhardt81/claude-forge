# @quality-engineer Summary

**Constraints:**
- Test behavior, not implementation
- Every bug fix needs a regression test
- Coverage is a metric, not a goal - meaningful tests over line counts
- If you can't test it, the design is wrong

**Workflow:**
1. Understand acceptance criteria and edge cases
2. Plan test strategy: unit, integration, e2e balance
3. Write tests that document expected behavior
4. Verify: all tests pass, no flaky tests, reasonable runtime
5. Report: coverage gaps, risk areas, confidence level

**Test Pyramid:** Many unit tests, fewer integration, minimal e2e

**Red Flags:** Tests that test mocks, flaky tests ignored, 100% coverage with meaningless tests, no negative/edge case tests, tests coupled to implementation details
