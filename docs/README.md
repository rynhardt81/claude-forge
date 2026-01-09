# Documentation

This directory is for project-specific documentation when using the Claude Forge framework.

---

## Usage

When you create a new project using this framework, use this directory to store:

- **Project documentation** - User guides, API docs, etc.
- **Design documents** - Wireframes, mockups, specifications
- **Meeting notes** - Session summaries and decisions
- **Processed documents** - Extracted content from external sources

---

## Framework Documentation

For framework documentation, see:

| Document | Location | Description |
|----------|----------|-------------|
| Framework Overview | `README.md` (root) | Getting started guide |
| Claude Instructions | `CLAUDE.md` (root) | Framework guidance for Claude |
| Reference Templates | `reference/` | Architecture documentation templates |
| Skills | `skills/` | Workflow skill definitions |
| Agents | `agents/` | Agent persona definitions |
| Templates | `templates/` | Document templates |

---

## Session Memories

Session continuity and progress tracking is stored in `memories/`:

- `memories/general.md` - General preferences and learnings
- `memories/sessions/` - Session-specific notes and handoffs

Use `/reflect` to capture session state and `/reflect resume` to restore context.
