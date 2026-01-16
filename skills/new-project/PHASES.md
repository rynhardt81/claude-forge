# New Project Phases

Detailed instructions for each phase of the `/new-project` skill.

---

## Phase 1: Requirements Discovery

**Goal:** Transform user's project idea into comprehensive Product Requirements Document

**Entry Conditions:**
- User has invoked `/new-project [description]`
- No existing `docs/prd.md` file
- No existing `features.db`

**Steps:**

### 1.1 Initial Analysis
```
If description provided:
  - Parse description for key entities, features, technologies
  - Identify project type (web app, API, mobile, CLI, etc.)
  - Infer complexity (simple/medium/complex)

If no description:
  - Prompt user: "What type of project would you like to create?"
  - Gather: purpose, target users, key features
```

### 1.2 Invoke @analyst
```
@analyst should:
  1. Ask clarifying questions about:
     - Target users and personas
     - Core value proposition
     - Must-have vs nice-to-have features
     - Technical constraints (existing systems, integrations, etc.)
     - Non-functional requirements (performance, security, compliance)

  2. Document findings in structured format

  3. Identify risks and assumptions

  4. Hand off to @project-manager with analysis report
```

### 1.3 Invoke @project-manager
```
@project-manager should:
  1. Read @analyst's findings

  2. Create PRD using template: ../../templates/prd.md
     - Executive Summary
     - Business Objectives
     - User Personas
     - Functional Requirements
     - Non-Functional Requirements
     - User Stories (high-level)
     - Success Metrics
     - Assumptions and Constraints
     - Risks and Mitigation
     - Out of Scope (important!)

  3. Save to: docs/prd.md

  4. Mark as Tier 2 master document in git commit
```

**Exit Conditions:**
- ✅ `docs/prd.md` exists and is comprehensive
- ✅ PRD includes functional and non-functional requirements
- ✅ User personas defined
- ✅ Success criteria clear

**Checkpoint:** Present PRD summary to user, ask for approval before Phase 2

---

## Phase 2: Feature Breakdown

**Goal:** Transform PRD into 50-400+ testable features organized by category

**Entry Conditions:**
- PRD exists in `docs/prd.md`
- User has approved PRD
- No existing `features.db`

**Steps:**

### 2.1 Invoke @scrum-master
```
@scrum-master should:
  1. Read docs/prd.md thoroughly

  2. Identify Epics (high-level themes):
     - Each major functional area becomes an epic
     - Examples: "User Authentication", "Product Catalog", "Payment Processing"
     - Aim for 3-7 epics for medium projects

  3. Break each epic into User Stories:
     - Format: "As a [persona], I want [action] so that [benefit]"
     - Each story should be independently testable
     - Each story should be completable in one feature implementation session

  4. Write acceptance criteria for each story:
     - Use Given/When/Then format where appropriate
     - Make criteria testable with browser automation
     - Include edge cases and error scenarios
```

### 2.2 Map Stories to Feature Categories
```
@scrum-master should map each user story to one of 20 categories:

A. Security & Access Control
   - Authentication, authorization, permissions, data protection

B. Navigation Integrity
   - Routing, links, breadcrumbs, page loads

C. Real Data Verification
   - CRUD operations, data persistence, data accuracy

D. Workflow Completeness
   - Multi-step processes, state transitions

E. Error Handling & Edge Cases
   - Validation, error messages, graceful degradation

F. Form Input & Validation
   - Form submission, field validation, feedback

G. Search & Filter
   - Search functionality, filtering, sorting

H. Responsive Design & Cross-Browser
   - Mobile, tablet, desktop, browser compatibility

I. Performance & Load Times
   - Page load speed, API response times, optimization

J. Integration & External Services
   - Third-party APIs, webhooks, external systems

K. Notifications & Alerts
   - User notifications, system alerts, emails

L. User Preferences & Settings
   - Configuration, customization, preferences

M. Help & Documentation
   - Tooltips, help text, documentation

N. Analytics & Tracking
   - User behavior tracking, metrics, logs

O. Accessibility & Internationalization
   - WCAG compliance, multi-language support

P. Payment & Financial Operations
   - Payment processing, transactions, invoicing

Q. Admin & Moderation
   - Admin panels, content moderation, user management

R. Collaboration & Sharing
   - Multi-user features, sharing, permissions

S. Data Export & Reporting
   - Reports, exports, data visualization

T. UI Polish & Aesthetics
   - Visual design, animations, micro-interactions
```

### 2.3 Create Feature Records
```
For each user story, create a feature record with:

{
  "priority": <integer>,        // Lower = higher priority (1-N)
  "category": <string>,          // One of A-T above
  "name": <string>,              // Concise feature name (50 chars max)
  "description": <string>,       // Detailed description with context
  "steps": [                     // Testable acceptance criteria
    "Step 1: Navigate to /page",
    "Step 2: Click button with text 'Submit'",
    "Step 3: Verify success message appears",
    ...
  ],
  "test_type": "browser",        // 'browser' | 'api' | 'unit' | 'manual'
  "test_url": "http://localhost:3000",
  "passes": false,
  "in_progress": false
}

Priority rules:
  - Dependencies first (auth before features requiring auth)
  - Security features early
  - Core features before nice-to-haves
  - Foundation before polish
```

### 2.4 Bulk Create Features
```
Use MCP tool: feature_create_bulk(features)

This writes all features to features.db in one transaction.

Complexity targets:
  - Simple project: 50-100 features
  - Medium project: 100-200 features
  - Complex project: 200-400+ features
```

### 2.5 Generate Feature Breakdown Report
```
Create: docs/feature-breakdown.md

Include:
  - Total features by category (bar chart or table)
  - Total features by epic
  - Priority distribution
  - Estimated implementation timeline (in features, not time)
  - Dependencies identified
  - Critical path features
```

**Exit Conditions:**
- ✅ `features.db` exists with 50-400+ features
- ✅ All features have testable steps
- ✅ Features prioritized correctly
- ✅ Categories balanced (no category >30% of total)

**Checkpoint:** Show user feature breakdown, ask for approval before Phase 3

---

## Phase 3: Technical Planning

**Goal:** Document technical architecture and decisions

**Entry Conditions:**
- PRD approved
- Features created in database
- User has approved feature breakdown

**Steps:**

### 3.1 Invoke @architect
```
@architect should:
  1. Read PRD and feature breakdown

  2. Create Architecture Decision Records (ADRs) for:
     - Tech stack selection (frontend, backend, database)
     - Architecture pattern (monolith, microservices, serverless, etc.)
     - Authentication/authorization approach
     - Data modeling approach
     - API design (REST, GraphQL, tRPC, etc.)
     - State management (if frontend)
     - Testing strategy
     - Deployment strategy
     - Security model

  3. Use ADR template: ../../templates/adr-template.md

  4. Save all ADRs to: .claude/reference/06-architecture-decisions.md

  5. Create high-level architecture diagram (if complex)

  6. Document data models and relationships
```

### 3.2 Conditional: UI Design
```
If project has UI (web app, mobile app):

  Invoke @ux-designer:
    1. Read PRD and feature breakdown

    2. Identify key user flows:
       - Onboarding flow
       - Core feature flows
       - Error/edge case flows

    3. Create wireframes for:
       - Key pages (homepage, dashboard, detail pages)
       - Forms (registration, checkout, etc.)
       - Navigation structure

    4. Define design system basics:
       - Color palette
       - Typography scale
       - Component patterns
       - Spacing system

    5. Save wireframes to: docs/wireframes/

    6. Create design system doc: docs/design-system.md

Else:
  Skip UI design phase
```

### 3.3 Technical Debt Prevention
```
@architect should document:
  1. Code quality standards:
     - Linting rules
     - Code formatting
     - Type safety approach

  2. Testing standards:
     - Test coverage targets
     - Testing pyramid (unit/integration/e2e ratios)
     - Browser test standards

  3. Documentation standards:
     - Code comments policy
     - API documentation approach
     - README requirements

  4. Git workflow:
     - Branch naming
     - Commit message format
     - PR requirements

Save to: .claude/reference/04-development-standards-and-structure.md
```

**Exit Conditions:**
- ✅ ADRs created for all major decisions
- ✅ Tech stack documented
- ✅ Architecture documented
- ✅ UI design completed (if applicable)
- ✅ Standards documented

**Checkpoint:** Review ADRs with user, confirm tech stack approval

---

## Phase 4: Implementation Readiness

**Goal:** Set up development environment and tooling

**Entry Conditions:**
- PRD, features, and ADRs all approved
- Ready to begin implementation

**Steps:**

### 4.1 Initialize Project Structure
```
If project directory empty:
  1. Scaffold based on tech stack (from ADRs)
     - Run: npx create-next-app (for Next.js)
     - Run: npm create vite@latest (for React/Vue)
     - Run: dotnet new (for .NET)
     - Etc.

  2. Install dependencies from ADRs

  3. Set up linting and formatting

  4. Initialize git repository

Else:
  1. Verify existing structure matches ADRs
  2. Install any missing dependencies
```

### 4.2 Set Up MCP Servers
```
Create: .claude/mcp-servers/config.json

{
  "mcpServers": {
    "feature-tracking": {
      "command": "python",
      "args": ["-m", "mcp_server.feature_mcp"],
      "env": {
        "PROJECT_DIR": "{project_root}"
      }
    },
    "browser-automation": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "enabled": true  // false if YOLO mode
    }
  }
}

If browser automation enabled:
  - Install: npx playwright install chromium
  - Test: Verify browser launches
```

### 4.3 Initialize Security Model
```
1. Copy security templates:
   - .claude/security/allowed-commands.md
   - .claude/security/command-validators.md
   - .claude/security/security-hooks.md

2. Customize allowed commands based on tech stack:
   - Node.js project: npm, npx, node, pnpm
   - Python project: python, pip, poetry, pytest
   - .NET project: dotnet
   - Always: git, ls, cat, grep, ps, lsof

3. Install enforcement hooks (CRITICAL for gate enforcement):
   - Make hooks executable: chmod +x .claude/hooks/*.sh
   - Copy settings template: cp .claude/hooks/settings.example.json .claude/settings.json
   - Hooks enforce: session requirement, task registry requirement
   - See hooks/README.md for details

4. Test hook installation:
   - Test gate-check: Should block code writes without session
   - Test validate-edit: Should block .env edits
   - Test session-context: Should output status on session start

5. Test security validation:
   - Try allowed command: Should pass
   - Try blocked command: Should fail with clear message
```

### 4.4 Create Development Server Script
```
Create: init.sh (or init.bat for Windows)

Based on tech stack:
  - Next.js: npm run dev
  - Vite: npm run dev
  - Django: python manage.py runserver
  - .NET: dotnet run
  - etc.

Script should:
  1. Check dependencies installed
  2. Check database running (if applicable)
  3. Run migrations (if applicable)
  4. Start development server
  5. Print URL for testing

Make executable: chmod +x init.sh
```

### 4.5 Configure Testing Mode
```
Based on --mode parameter:

Standard mode:
  - Browser automation: ENABLED
  - All features: Full browser testing
  - Regression tests: Every feature
  - Speed: Slower, thorough

YOLO mode:
  - Browser automation: DISABLED
  - All features: Lint + type-check only
  - Regression tests: Skipped
  - Speed: ~5x faster

Hybrid mode:
  - Browser automation: ENABLED
  - Critical categories: Full browser testing
    - Security & Access Control
    - Payment & Financial Operations
    - Data Integrity & CRUD
  - Non-critical categories: Lint only
  - Speed: ~2x faster

Save mode to: .claude/memories/testing-mode.txt
```

### 4.6 Initialize Dispatch Configuration
```
Copy template: templates/.dispatch-config.json
To: .claude/memories/.dispatch-config.json

This configures the Intelligent Dispatch System:
- Sub-agent parallelization (task registry + feature database)
- Intent detection for natural language skill suggestions
- See reference/11-intelligent-dispatch.md for details

Default settings:
- dispatch.enabled: true
- dispatch.mode: "automatic"
- dispatch.maxParallelAgents: 3
- intentDetection.enabled: true
- intentDetection.mode: "suggest"
```

### 4.7 Initialize Progress Tracking
```
Create: .claude/memories/progress-notes.md

Template:
  # Project Progress Notes

  ## Project: [name]

  ## Current Status
  - Phase: Implementation Readiness
  - Features Total: [N]
  - Features Complete: 0
  - Current Session: 1

  ## Session History
  [Will be populated by /reflect skill]

  ## Blockers
  [None yet]

  ## Decisions Log
  [Will be populated during implementation]
```

### 4.8 Create Project Memory Structure

Initialize the project memory system for capturing bugs, decisions, and patterns.

**Actions:**

1. Create directory:
   ```bash
   mkdir -p docs/project-memory
   ```

2. Copy templates:
   ```bash
   cp templates/project-memory/bugs.md docs/project-memory/
   cp templates/project-memory/decisions.md docs/project-memory/
   cp templates/project-memory/key-facts.md docs/project-memory/
   cp templates/project-memory/patterns.md docs/project-memory/
   ```

3. Optionally populate key-facts.md with discovered project information:
   - Environment URLs
   - Detected conventions from existing code
   - Key dependencies

**Note:** The archive.db is NOT created here - it's created on first use via `/remember archive` or `/remember init-archive`.

**Exit Conditions:**
- ✅ Project scaffolded
- ✅ Dependencies installed
- ✅ MCP servers configured
- ✅ Security model initialized
- ✅ init.sh created and tested
- ✅ Testing mode configured
- ✅ Dispatch config initialized
- ✅ Project memory structure created

---

## Phase 5: Kickoff

**Goal:** Present summary and begin implementation

**Entry Conditions:**
- All previous phases complete
- Development environment ready

**Steps:**

### 5.1 Generate Project Summary
```
Query feature database:
  - Total features: feature_get_stats()
  - Features by category
  - Features by priority tier (P1, P2, P3)
  - Estimated complexity

Create summary:
  PROJECT: [name]
  ================

  Features: [N] total
  Categories: [M] active
  Complexity: [Simple/Medium/Complex]
  Testing Mode: [Standard/YOLO/Hybrid]

  Tech Stack:
  - Frontend: [tech]
  - Backend: [tech]
  - Database: [tech]
  - Hosting: [tech]

  Estimated Sessions: [N]
  (Based on ~5-10 features per session)

  Critical Path Features:
  1. [Feature name] (Security)
  2. [Feature name] (Navigation)
  3. [Feature name] (Data)
  ...
```

### 5.2 Show Next Features
```
Query: feature_get_next() (repeat 5 times)

Display first 5 features:

  NEXT 5 FEATURES:

  1. [Category] Feature name
     - Priority: [N]
     - Steps: [M] acceptance criteria
     - Estimated time: [quick/medium/long]

  2. [Category] Feature name
     ...
```

### 5.3 User Approval
```
Present to user:

  "Ready to begin incremental implementation?

   This will:
   - Implement features one-by-one
   - Run regression tests before each feature
   - Commit after each successful feature
   - Pause every 10 features for your review

   You can pause at any time with Ctrl+C and resume later.

   Continue? [Yes/No/Adjust]"

Options:
  - Yes: Proceed to /implement-features
  - No: Save state, exit (user can resume later)
  - Adjust: Allow user to:
    - Re-prioritize features
    - Skip certain features
    - Change testing mode
    - Modify ADRs
```

### 5.4 Invoke Implementation Skill
```
If user approves:

  Invoke: /implement-features

  This skill will:
    1. Get next feature from DB
    2. Route to appropriate agent(s)
    3. Implement feature
    4. Test feature
    5. Mark as passing
    6. Repeat until all features complete

See: ../implement-features/SKILL.md
```

**Exit Conditions:**
- ✅ User has reviewed summary
- ✅ User has approved (or requested adjustments)
- ✅ Implementation skill invoked (or state saved for later)

---

## Error Recovery

### If Phase 1 Fails (PRD Creation)
```
Symptom: @project-manager unable to create PRD

Recovery:
  1. Save @analyst findings to docs/analysis.md
  2. Ask user to manually create PRD using template
  3. Once PRD exists, resume at Phase 2
```

### If Phase 2 Fails (Feature Breakdown)
```
Symptom: @scrum-master unable to break down features

Recovery:
  1. Save epics to docs/epics.md
  2. Ask @scrum-master to break ONE epic at a time
  3. Manually combine into full feature list
  4. Resume feature creation
```

### If Phase 3 Fails (Technical Planning)
```
Symptom: @architect unable to make decisions

Recovery:
  1. Use AskUserQuestion to clarify technical preferences
  2. Document decisions in ADRs manually
  3. Continue to Phase 4
```

### If Phase 4 Fails (Setup)
```
Symptom: MCP servers won't start, dependencies fail

Recovery:
  1. Document error in progress notes
  2. Continue in degraded mode:
     - Features in JSON instead of DB
     - Manual testing instead of browser automation
  3. User can fix environment later and upgrade
```

### If User Cancels Mid-Flow
```
At any checkpoint, user can cancel:

  Save state to: .claude/memories/new-project-state.json

  {
    "phase": "2-feature-breakdown",
    "completed": ["phase-1"],
    "artifacts": {
      "prd": "docs/prd.md",
      "features_created": 45,
      "features_total": 120
    },
    "next_step": "Complete feature breakdown, then continue to Phase 3"
  }

User can resume with: /new-project --resume
```

---

## Phase Transitions

### Transition: Phase 1 → Phase 2
```
Handoff artifacts:
  - docs/prd.md
  - docs/analysis.md (from @analyst)

Agents involved:
  - @project-manager → @scrum-master
```

### Transition: Phase 2 → Phase 3
```
Handoff artifacts:
  - features.db (50-400+ features)
  - docs/feature-breakdown.md

Agents involved:
  - @scrum-master → @architect
```

### Transition: Phase 3 → Phase 4
```
Handoff artifacts:
  - .claude/reference/06-architecture-decisions.md
  - docs/wireframes/ (if UI project)
  - docs/design-system.md (if UI project)

Agents involved:
  - @architect → @orchestrator
  - @ux-designer → @orchestrator
```

### Transition: Phase 4 → Phase 5
```
Handoff artifacts:
  - .claude/mcp-servers/config.json
  - .claude/security/ (all files)
  - init.sh
  - .claude/memories/testing-mode.txt

Agents involved:
  - @orchestrator → @orchestrator (same, different mode)
```

### Transition: Phase 5 → Implementation
```
Handoff artifacts:
  - ALL previous artifacts
  - User approval

Agents involved:
  - @orchestrator → @developer (and others)

Next skill: /implement-features
```

---

## Notes

- Each phase should take 5-15 minutes depending on project complexity
- User can pause at any checkpoint
- All artifacts are committed to git for traceability
- Feature database is the single source of truth for implementation scope
- Phases are sequential but can be partially repeated if needed (e.g., adding more features later)
