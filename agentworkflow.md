# Agent Workflow Guide

This document defines the specialized agents available for Claude Code and the recommended workflows for using them effectively.

---

## Overview

Specialized agents live in `.claude/agents/`. Each agent has a specific focus area and set of capabilities. Agents can be invoked using the `@agent-name` syntax or through the orchestrator.

---

## Agent Catalog

### Workflow & Coordination

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@orchestrator` | Workflow coordination | Unsure which agent to use, need help coordinating overall workflow |

### Discovery & Planning

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@analyst` | Discovery & requirements | Understanding problems, gathering requirements, researching user needs |
| `@ceo` | Business strategy | Reality check on viability, deciding what NOT to build, strategic prioritization, go/no-go decisions |
| `@project-manager` | PRDs & scope | Defining what to build, creating PRDs, prioritizing features, scoping MVP |

### Design & Architecture

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@architect` | Architecture & ADRs | Tech stack decisions, system architecture, APIs, database schemas |
| `@ux-designer` | User experience | Designing user flows, wireframes, interface specifications |
| `@visual-mistro` | Visual communication | Diagrams, flowcharts, presentation slides, data visualizations |

### Implementation

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@developer` | Code implementation | Implementing features, writing code, fixing bugs, code review guidance |
| `@whimsy` | UI polish | Micro-interactions, animations, delightful touches for bland UIs |
| `@scrum-master` | Sprint management | Breaking work into user stories, planning sprints, managing backlog |

### Quality & Testing

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@quality-engineer` | Testing & QA | Test plans, code reviews, bug reports, verifying acceptance criteria |
| `@api-tester` | API validation | Load testing endpoints, validating API contracts, checking security vulnerabilities |
| `@security-boss` | Security | Identifying vulnerabilities, auditing auth flows, reviewing code for security flaws |
| `@performance-enhancer` | Optimization | Profiling, benchmarking, optimizing slow applications |

### Operations

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `@devops` | CI/CD & deployment | CI/CD pipelines, deployment configs, infrastructure setup, runbooks |

---

## Agent Details

### @orchestrator

**Color**: Cyan
**Purpose**: Workflow coordination and agent routing

Use when you're unsure which agent to use next or need help coordinating the overall workflow. The orchestrator maintains project state awareness and provides clear next steps.

**Key Commands**:
- `*init-project` - Initialize new project with CLAD structure
- `*status` - Show current project status and phase
- `*next` - Recommend next action or agent
- `*handoff [agent]` - Orchestrate handoff to another agent
- `*agents` - List all available agents

---

### @analyst

**Color**: Blue
**Purpose**: Discovery & requirements gathering

Use at the start of any project or feature to understand the problem space, gather requirements, and research user needs before building anything.

**Key Commands**:
- `*discover` - Start discovery process
- `*persona` - Create user persona
- `*journey-map` - Create user journey map
- `*requirements` - Gather and document requirements

---

### @ceo

**Color**: Purple
**Purpose**: Business viability and strategic decisions

Use when you need a reality check on business viability, help deciding what NOT to build, strategic prioritization, or go/no-go decisions.

**Key Commands**:
- `*viability` - Assess business viability of idea
- `*go-no-go` - Make ship/kill decision
- `*prioritize` - Ruthless feature prioritization
- `*cut` - What to kill/descope
- `*focus` - Identify the ONE thing that matters

**Decision Frameworks**:
- Go/No-Go Matrix (Confidence vs Impact)
- ICE Score (Impact x Confidence x Ease)
- Unit Economics Analysis

---

### @project-manager

**Color**: Orange
**Purpose**: Product definition and scope management

Use when you're ready to define what to build, create a PRD, prioritize features, or scope an MVP.

**Key Commands**:
- `*create-prd` - Start creating a new PRD
- `*define-mvp` - Define MVP scope
- `*create-epic` - Create a new epic
- `*prioritize` - Prioritize features using framework
- `*roadmap` - Create high-level roadmap

**Prioritization Frameworks**:
- MoSCoW Method (Must/Should/Could/Won't)
- RICE Scoring (Reach x Impact x Confidence / Effort)
- Value vs Effort Matrix

---

### @architect

**Color**: Yellow
**Purpose**: Technical architecture and design decisions

Use when you need to decide on tech stack, design system architecture, APIs, or database schemas.

**Key Commands**:
- `*design` - Create architecture design
- `*adr` - Create Architecture Decision Record
- `*review` - Review proposed architecture
- `*tradeoffs` - Analyze technical tradeoffs

---

### @ux-designer

**Color**: Pink
**Purpose**: User experience design

Use when you need to design user flows, wireframes, or specify how the interface should look and behave.

**Key Commands**:
- `*wireframe [screen]` - Create wireframe description
- `*flow [name]` - Design user flow
- `*interaction [feature]` - Define interaction patterns
- `*component [name]` - Define UI component
- `*persona` - Create/update user persona
- `*journey-map` - Create user journey map

**Design Artifacts**:
- User personas
- Journey maps
- Wireframes
- Design specifications
- Accessibility checklists

---

### @visual-mistro

**Color**: Cyan
**Purpose**: Visual communication and diagrams

Use when you need diagrams, flowcharts, presentation slides, or data visualizations.

**Key Commands**:
- `*diagram [type]` - Create technical diagram
- `*flowchart` - Design process flow
- `*architecture` - Visualize system architecture
- `*chart [type]` - Create chart specification
- `*deck [type]` - Structure presentation
- `*pitch` - Create investor pitch visuals

**Tools Used**:
- Mermaid for code-based diagrams
- Excalidraw for sketches
- Figma for polished designs
- D3.js/Recharts for data visualization

---

### @developer

**Color**: Green
**Purpose**: Code implementation

Use when you're implementing features, writing code, fixing bugs, or need code review guidance.

**Key Commands**:
- `*implement [story]` - Implement a user story
- `*feature [name]` - Create new feature
- `*fix [issue]` - Fix a bug or issue
- `*refactor [target]` - Refactor code
- `*test [target]` - Write tests for code
- `*component [name]` - Create component
- `*api [endpoint]` - Create API endpoint

**Coding Standards**:
- Write code that is easy to delete
- Prefer explicit over implicit
- Make invalid states unrepresentable
- Fail fast, fail loud

---

### @whimsy

**Color**: Orange
**Purpose**: UI delight and polish

Use when the UI works but feels bland and needs micro-interactions, animations, or delightful touches.

**Key Commands**:
- `*audit [screen]` - Find delight opportunities
- `*enhance [component]` - Add whimsy to component
- `*celebrate [action]` - Design celebration moment
- `*micro [interaction]` - Design micro-interaction
- `*empty-state [screen]` - Create engaging empty state
- `*easter-egg [trigger]` - Create hidden surprise

**Animation Timing**:
- Micro-interactions: 150ms
- Standard transitions: 250ms
- Page transitions: 400ms
- Celebrations: 600ms

---

### @scrum-master

**Color**: Red
**Purpose**: Agile process and sprint management

Use when you're ready to break work into user stories, plan a sprint, or manage the backlog.

**Key Commands**:
- `*create-story` - Create a new user story
- `*refine [story]` - Refine story with acceptance criteria
- `*split [story]` - Split large story into smaller ones
- `*plan-sprint` - Plan upcoming sprint
- `*breakdown [epic]` - Break epic into stories
- `*blockers` - List current blockers
- `*velocity` - Calculate team velocity

**Story Points Reference**:
| Points | Complexity | Time Estimate |
|--------|------------|---------------|
| 1 | Trivial | < 2 hours |
| 2 | Simple | 2-4 hours |
| 3 | Moderate | 4-8 hours |
| 5 | Complex | 1-2 days |
| 8 | Very Complex | 2-3 days |
| 13 | Epic-sized | Should split |

---

### @quality-engineer

**Color**: Orange
**Purpose**: Testing and quality assurance

Use when you need test plans, code reviews, bug reports, or verification of acceptance criteria.

**Key Commands**:
- `*test-plan [story]` - Create test plan for story
- `*test-cases [feature]` - Generate test cases
- `*review [code/pr]` - Perform code review
- `*security-review` - Security-focused review
- `*bug [title]` - Report a bug
- `*coverage` - Check test coverage

**Test Pyramid**:
```
        ┌─────┐
        │ E2E │  ← Fewer, Slower
        ├─────┤
     ┌──┴─────┴──┐
     │Integration │
     ├───────────┤
  ┌──┴───────────┴──┐
  │   Unit Tests    │  ← Many, Fast
  └─────────────────┘
```

---

### @api-tester

**Color**: Red
**Purpose**: API testing and validation

Use when you need to load test endpoints, validate API contracts, or check for security vulnerabilities.

**Key Commands**:
- `*test [endpoint]` - Test specific endpoint
- `*contract` - Validate against OpenAPI spec
- `*load [endpoint]` - Run load test
- `*stress` - Find breaking point
- `*security` - Run security checks
- `*benchmark` - Compare performance metrics

**Performance Targets**:
| Metric | Target |
|--------|--------|
| p95 Latency | < 500ms |
| Error Rate (5xx) | < 0.1% |
| Read-heavy RPS | > 1000/instance |
| Write-heavy RPS | > 100/instance |

---

### @security-boss

**Color**: Red
**Purpose**: Security assessment and hardening

Use when you need to identify vulnerabilities, audit authentication flows, review code for security flaws, or ensure your app won't get hacked.

**Key Commands**:
- `*audit [area]` - Security audit of specific area
- `*full-audit` - Comprehensive security review
- `*threat-model` - Create threat model
- `*owasp` - Check against OWASP Top 10
- `*secrets` - Scan for exposed secrets
- `*auth-review` - Review authentication implementation

**OWASP Top 10 Checklist**:
- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Auth Failures
- A08: Data Integrity Failures
- A09: Logging Failures
- A10: SSRF

---

### @performance-enhancer

**Color**: Pink
**Purpose**: Performance optimization

Use when your app feels slow and you need to profile, benchmark, or optimize performance.

**Key Commands**:
- `*audit` - Full performance audit
- `*profile [area]` - Deep profile specific area
- `*bottlenecks` - Identify top performance issues
- `*bundle` - Analyze bundle size
- `*quick-wins` - List easy performance wins
- `*budget` - Create performance budget

**Core Web Vitals Targets**:
| Metric | Good | Poor |
|--------|------|------|
| LCP | < 2.5s | > 4s |
| FID | < 100ms | > 300ms |
| CLS | < 0.1 | > 0.25 |

---

### @devops

**Color**: Blue
**Purpose**: Infrastructure and deployment

Use when you need CI/CD pipelines, deployment configs, infrastructure setup, or runbooks.

**Key Commands**:
- `*pipeline` - Create CI/CD pipeline
- `*deploy` - Deployment configuration
- `*infra` - Infrastructure setup
- `*monitor` - Monitoring configuration
- `*runbook` - Create operational runbook

---

## Recommended Workflows

### New Feature Development

```
@analyst → @project-manager → @architect → @ux-designer → @developer → @quality-engineer → @devops
```

1. **@analyst**: Understand the problem and gather requirements
2. **@project-manager**: Create PRD and define scope
3. **@architect**: Design technical solution
4. **@ux-designer**: Design user experience
5. **@developer**: Implement the feature
6. **@quality-engineer**: Test and review
7. **@devops**: Deploy to production

### Bug Fix

```
@quality-engineer → @developer → @quality-engineer
```

1. **@quality-engineer**: Document bug with reproduction steps
2. **@developer**: Fix the issue
3. **@quality-engineer**: Verify the fix

### Performance Issue

```
@performance-enhancer → @developer → @api-tester
```

1. **@performance-enhancer**: Profile and identify bottlenecks
2. **@developer**: Implement optimizations
3. **@api-tester**: Validate improvements with load tests

### Security Audit

```
@security-boss → @developer → @security-boss
```

1. **@security-boss**: Identify vulnerabilities
2. **@developer**: Implement fixes
3. **@security-boss**: Verify remediation

### MVP Launch

```
@ceo → @analyst → @project-manager → @architect → @scrum-master → @developer → @quality-engineer → @devops
```

1. **@ceo**: Validate business viability
2. **@analyst**: Deep dive on core user needs
3. **@project-manager**: Scope ruthlessly to MVP
4. **@architect**: Design scalable foundation
5. **@scrum-master**: Break into sprints
6. **@developer**: Build incrementally
7. **@quality-engineer**: Ensure quality
8. **@devops**: Ship it

---

## Agent Handoff Protocol

When transitioning between agents:

1. **Summarize completed work** - What was accomplished
2. **Document artifacts** - Where outputs are saved
3. **Note open questions** - What needs clarification
4. **Specify next steps** - Clear action items for receiving agent

### Handoff Template

```markdown
## Handoff: @[from-agent] → @[to-agent]

### Completed Work
- [Summary of what was done]

### Artifacts Created
- [Path to artifact 1]
- [Path to artifact 2]

### Open Questions
- [Question 1]
- [Question 2]

### Next Steps for @[to-agent]
1. [Action item 1]
2. [Action item 2]
```

---

## Using the Orchestrator

When in doubt about which agent to use, invoke `@orchestrator` with:

```
@orchestrator *status
```

The orchestrator will:
1. Assess current project state
2. Review completed artifacts
3. Recommend the appropriate next agent
4. Facilitate the handoff

---

*"A well-orchestrated team is greater than the sum of its parts."*
