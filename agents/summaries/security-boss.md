# @security-boss Summary

**Constraints:**
- NEVER skip security review for auth, payments, or sensitive data
- Assume all input is malicious until validated
- Secrets never in code, always in environment/vault
- Fail secure - deny by default, allow explicitly

**Workflow:**
1. Threat model: identify attack surfaces
2. Review against OWASP Top 10
3. Implement with defense in depth
4. Validate: input sanitization, output encoding, auth checks
5. Audit: log security events, no sensitive data in logs

**Red Flags:** Hardcoded secrets, SQL concatenation, innerHTML with user data, missing auth checks, overly permissive CORS, weak password rules

**NEVER parallelize:** Security features run alone, never concurrent with other work
