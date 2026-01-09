# Claude Code Base Template

This is a portable Claude Code configuration template that can be copied to any new project.

## Quick Start

1. **Copy to new project:**
   ```bash
   cp -R base-claude/ /path/to/new-project/.claude/
   ```

2. **Rename template files:**
   ```bash
   cd /path/to/new-project/.claude/reference/
   for f in *.template.md; do mv "$f" "${f%.template.md}.md"; done
   ```

3. **Customize CLAUDE.md:**
   - Update project overview
   - Add project-specific commands
   - Configure architecture references

4. **Fill in reference docs:**
   - Replace `<!-- CUSTOMIZE -->` sections with project details
   - Remove `.template` suffix from filenames

## Directory Structure

```
.claude/
├── CLAUDE.md                    # Main execution guidance
├── agentworkflow.md            # Agent system documentation
│
├── reference/                   # Master documentation (Tier 2)
│   ├── 00-documentation-governance.md
│   ├── 01-system-overview.md
│   ├── 02-architecture-and-tech-stack.md
│   ├── 03-security-auth-and-access.md
│   ├── 04-development-standards-and-structure.md
│   ├── 05-operational-and-lifecycle.md
│   ├── 06-architecture-decisions.md
│   └── 07-non-functional-requirements.md
│
├── features/                    # Feature specifications
│
├── skills/                      # Workflow skills
│   ├── reflect/                 # Session continuity
│   ├── new-feature/             # Feature development
│   ├── fix-bug/                 # Bug fixing
│   ├── refactor/                # Code refactoring
│   ├── create-pr/               # Pull request creation
│   ├── release/                 # Version releases
│   └── pdf/                     # PDF processing & manipulation
│
├── agents/                      # Full agent personas
│   ├── orchestrator.md
│   ├── analyst.md
│   ├── architect.md
│   ├── developer.md
│   └── ...
│
├── sub-agents/                  # Focused specialists
│   ├── codebase-analyzer.md
│   ├── pattern-detector.md
│   ├── requirements-analyst.md
│   ├── tech-debt-auditor.md
│   ├── api-documenter.md
│   ├── test-coverage-analyzer.md
│   └── document-reviewer.md
│
├── standards/                   # Shared standards
│   └── documentation-style.md
│
├── templates/                   # Document templates
│   ├── feature-spec.md
│   ├── adr-template.md
│   ├── session-summary.md
│   └── review-report.md
│
├── memories/                    # Session continuity
│   ├── general.md
│   └── sessions/
│       └── latest.md
│
└── hooks/                       # Hook definitions
```

## What's Included

### Skills (9)
Universal workflow skills for common development tasks:
- **reflect** - Session continuity and context handoff
- **new-feature** - Feature development workflow
- **fix-bug** - Bug fixing with diagnosis phases
- **refactor** - Code refactoring workflow
- **create-pr** - Pull request creation
- **release** - Version releases and changelog
- **new-project** - Initialize new projects with PRD
- **implement-features** - Feature implementation loop
- **pdf** - PDF processing (extract, merge, split, fill forms, OCR)

### Agents (15)
Full personas for different roles (architect, developer, security, etc.).

### Sub-Agents (7)
Focused specialists for specific analysis tasks.

### Standards (1)
Documentation writing standards (CommonMark, Mermaid, style guide).

### Templates (4)
- Feature specification
- Architecture Decision Record (ADR)
- Session summary
- Code review report

### Reference Docs (8)
Template versions of master documentation for project architecture.

## Customization Guide

### Must Customize
- `CLAUDE.md` - Project overview, commands, structure
- `reference/01-07` - Fill with actual project details

### May Customize
- `standards/` - Add project-specific standards
- `agents/` - Add project-specific agent capabilities
- `skills/` - Add project-specific skills

### Don't Modify
- `reference/00-documentation-governance.md` - Universal governance
- `sub-agents/` - These are generic specialists
- `templates/` - Keep as reusable templates

## Version

Template Version: 1.1.0
Last Updated: 2025-01-09
