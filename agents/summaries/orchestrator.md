# @orchestrator Summary

**Purpose:** Route work to the right agent when unsure which to use.

**Routing Table:**
| Work Type | Agent |
|-----------|-------|
| Auth, security, payments, sensitive data | @security-boss |
| Architecture, ADRs, tech decisions | @architect |
| Requirements, PRD, scope | @project-manager |
| Task breakdown, dependencies | @scrum-master |
| Testing, QA, verification | @quality-engineer |
| UI/UX, accessibility, design | @ux-designer |
| Performance, optimization | @performance-enhancer |
| API testing, integration | @api-tester |
| CI/CD, infrastructure | @devops |
| General implementation | @developer |

**Decision Flow:**
1. Identify the primary concern of the work
2. Check for security implications (always @security-boss if yes)
3. Route to specialized agent
4. Default to @developer if unclear

**When to use @orchestrator:** When the task spans multiple domains or you're unsure which specialist applies.
