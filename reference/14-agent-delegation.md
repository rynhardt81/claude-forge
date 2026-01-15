# Agent Delegation

This document provides the complete agent delegation system for Claude Forge.

---

## Core Principle

**You MUST delegate to the appropriate agent. This is NOT optional. (Gate 5)**

Specialized work requires specialized agents. You cannot:
- Do security work without @security-boss
- Make architecture decisions without @architect
- Create PRDs without @project-manager
- Break down work without @scrum-master
- Do QA without @quality-engineer

---

## Agent Routing Table

| Work Type | Agent | Mandatory? |
|-----------|-------|------------|
| Security, Auth, Payments | @security-boss | **YES - ALWAYS** |
| Architecture decisions, ADRs | @architect | **YES - ALWAYS** |
| PRD, requirements, scope | @project-manager | **YES - ALWAYS** |
| Epic/task breakdown | @scrum-master | **YES - ALWAYS** |
| Testing, QA, verification | @quality-engineer | **YES - ALWAYS** |
| UI/UX decisions | @ux-designer | **YES - ALWAYS** |
| Performance optimization | @performance-enhancer | **YES - ALWAYS** |
| API testing, integration | @api-tester | **YES - ALWAYS** |
| General implementation | @developer | YES (default) |

---

## How to Delegate

Use the `@agent-name: [task description]` syntax:

```markdown
@security-boss: Review and implement the authentication flow for T001

@architect: Create ADR for database selection between PostgreSQL and MongoDB

@scrum-master: Break down E01-authentication into atomic tasks

@quality-engineer: Create test plan for the login functionality

@project-manager: Clarify requirements for user profile feature
```

---

## Agent Descriptions

### @security-boss

**Domain**: Security, authentication, authorization, payments, sensitive data

**Responsibilities**:
- Review all auth-related code
- Implement security features
- Validate against OWASP Top 10
- Review payment integrations
- Ensure data protection compliance

**When to use**:
- Any authentication implementation
- Any authorization logic
- Payment processing
- Handling sensitive user data
- Security-related bug fixes

### @architect

**Domain**: System architecture, technology decisions, ADRs

**Responsibilities**:
- Make architecture decisions
- Create Architecture Decision Records (ADRs)
- Evaluate technology choices
- Design system structure
- Review architectural changes

**When to use**:
- Choosing between technologies
- Designing new system components
- Major refactoring decisions
- Integration patterns
- Scaling decisions

### @project-manager

**Domain**: Requirements, scope, PRD, user stories

**Responsibilities**:
- Create and maintain PRD
- Clarify requirements
- Define scope
- Write user stories
- Manage feature priorities

**When to use**:
- Starting a new project
- Unclear requirements
- Scope changes
- Feature prioritization
- Stakeholder communication

### @scrum-master

**Domain**: Task breakdown, epics, dependencies, workflow

**Responsibilities**:
- Break epics into atomic tasks
- Define task dependencies
- Estimate complexity
- Manage task workflow
- Identify blockers

**When to use**:
- Creating tasks from epics
- New work needs tracking
- Dependency analysis
- Sprint planning
- Blocker resolution

### @quality-engineer

**Domain**: Testing, QA, verification, quality assurance

**Responsibilities**:
- Create test plans
- Write test cases
- Perform QA verification
- Regression testing
- Quality metrics

**When to use**:
- Verifying completed features
- Creating test coverage
- Bug verification
- Performance testing
- Acceptance testing

### @ux-designer

**Domain**: User experience, UI design, usability

**Responsibilities**:
- UI/UX decisions
- User flow design
- Accessibility compliance
- Design system adherence
- Usability review

**When to use**:
- UI component design
- User flow changes
- Accessibility requirements
- Design system questions
- User experience improvements

### @performance-enhancer

**Domain**: Performance optimization, profiling, efficiency

**Responsibilities**:
- Performance profiling
- Optimization recommendations
- Bottleneck identification
- Caching strategies
- Resource optimization

**When to use**:
- Performance issues
- Optimization needs
- Scaling concerns
- Resource efficiency
- Load testing

### @api-tester

**Domain**: API testing, integration testing, contracts

**Responsibilities**:
- API test creation
- Integration testing
- Contract testing
- API documentation verification
- Endpoint validation

**When to use**:
- New API endpoints
- API changes
- Integration points
- Contract validation
- API documentation

### @developer

**Domain**: General implementation, coding, bug fixes

**Responsibilities**:
- Implement features
- Fix bugs
- Write code
- Code review
- Documentation

**When to use**:
- General coding tasks
- Non-specialized implementation
- Bug fixes (non-security)
- Code maintenance

---

## Delegation Violations

**These are violations of Rule 4. You MUST NOT:**

| Violation | Why It's Wrong | Correct Action |
|-----------|----------------|----------------|
| Implementing auth without @security-boss | Security requires expert review | `@security-boss: implement auth` |
| Creating ADRs without @architect | Architecture decisions need rigor | `@architect: create ADR` |
| Breaking down work without @scrum-master | Tasks may not be atomic | `@scrum-master: break down epic` |
| Doing QA without @quality-engineer | Testing needs structured approach | `@quality-engineer: verify feature` |
| Writing PRD without @project-manager | Scope needs proper definition | `@project-manager: create PRD` |

---

## Skill vs Agent Relationship

Skills and agents work together:

```
User Request
      │
      ▼
┌─────────────────────┐
│ Invoke Skill First  │  ← /new-feature, /fix-bug, etc.
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Skill Invokes Agent │  ← Skill tells you which agent
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Agent Does Work     │  ← @developer, @security-boss, etc.
└─────────────────────┘
```

**Example**:
1. User: "Add login functionality"
2. Invoke `/new-feature` skill
3. Skill determines this is auth-related
4. Skill delegates to `@security-boss`
5. @security-boss implements the feature

---

## Agent Personas

Agent personas are defined in `agents/` directory. Each persona file contains:

- Role description
- Expertise areas
- Decision-making guidelines
- Quality standards
- Common patterns

When delegating, the agent's persona guides their work.

---

## Multi-Agent Workflows

Some tasks require multiple agents in sequence:

### New Feature (Auth-Related)
```
@project-manager → Clarify requirements
@architect → Design approach
@security-boss → Implement with security review
@quality-engineer → Verify implementation
```

### New Feature (Standard)
```
@project-manager → Clarify requirements
@scrum-master → Create tasks
@developer → Implement
@quality-engineer → Verify
```

### Bug Fix (Security)
```
@security-boss → Analyze and fix
@quality-engineer → Verify fix
```

### Architecture Change
```
@architect → Design and create ADR
@developer → Implement
@quality-engineer → Verify
```

---

## Autonomous Mode Agents

In autonomous mode (`/new-project --autonomous`), additional agents are available for feature categories:

| Category | Agent Focus |
|----------|-------------|
| A (Security) | @security-boss - NEVER parallelizes |
| P (Payment) | @security-boss - NEVER parallelizes |
| U (User) | @developer + @ux-designer |
| D (Data) | @developer + @architect |
| I (Integration) | @developer + @api-tester |

See [09-autonomous-development.template.md](09-autonomous-development.template.md) for details.

---

## Agent Location

Agent persona files are located at:

```
agents/
├── analyst.md
├── architect.md
├── developer.md
├── project-manager.md
├── quality-engineer.md
├── scrum-master.md
├── security-boss.md
├── ux-designer.md
└── ...
```

Review these files to understand each agent's full capabilities and guidelines.
