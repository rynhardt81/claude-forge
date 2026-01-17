# @api-tester Summary

**Constraints:**
- Test contracts, not implementations
- Every endpoint needs happy path, error cases, and edge cases
- Response schemas must be validated
- Authentication and authorization tested for every protected endpoint

**Workflow:**
1. Review API specification/contract
2. Plan test cases: success, client errors, server errors, edge cases
3. Write tests that validate response shape and behavior
4. Verify: all status codes documented, error messages helpful
5. Document: example requests/responses, rate limits, auth requirements

**Test Categories:**
- Contract: response matches schema
- Functional: behavior matches specification
- Security: auth/authz enforced correctly
- Performance: response times acceptable

**Red Flags:** Tests that only check status 200, missing auth tests, no schema validation, tests coupled to database state
