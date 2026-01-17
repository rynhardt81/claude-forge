#!/usr/bin/env python3
"""
Prepare a Task tool prompt for delegating work to a subagent.

Usage:
    python scripts/prepare_task_prompt.py T015
    python scripts/prepare_task_prompt.py T015 --background
    python scripts/prepare_task_prompt.py T015 --parent-session 20240117-143022-a7x9

Output:
    Ready-to-use prompt for the Task tool, including:
    - Agent summary (auto-detected from task content)
    - Task details and acceptance criteria
    - Scope declaration
    - Instructions and reporting format
"""

import argparse
import json
import re
import sys
from pathlib import Path


def get_project_root() -> Path:
    """Find project root by looking for CLAUDE.md"""
    current = Path(__file__).resolve().parent
    while current != current.parent:
        if (current / "CLAUDE.md").exists():
            return current
        current = current.parent
    # Fallback to script's parent's parent
    return Path(__file__).resolve().parent.parent


def load_registry(project_root: Path) -> dict:
    """Load the task registry"""
    registry_path = project_root / "docs" / "tasks" / "registry.json"
    if not registry_path.exists():
        print(f"Error: Registry not found at {registry_path}", file=sys.stderr)
        sys.exit(1)

    with open(registry_path) as f:
        return json.load(f)


def find_task(registry: dict, task_id: str) -> dict | None:
    """Find a task in the registry"""
    tasks = registry.get("tasks", {})
    return tasks.get(task_id)


def find_epic_for_task(registry: dict, task_id: str) -> str | None:
    """Find which epic a task belongs to"""
    epics = registry.get("epics", {})
    for epic_id, epic_data in epics.items():
        if task_id in epic_data.get("tasks", []):
            return epic_id
    return None


def load_task_file(project_root: Path, registry: dict, task_id: str) -> str | None:
    """Load the task markdown file"""
    task_data = find_task(registry, task_id)
    if not task_data:
        return None

    # Try to find task file path from registry
    task_path = task_data.get("path")
    if task_path:
        full_path = project_root / task_path
        if full_path.exists():
            return full_path.read_text()

    # Fallback: search for task file
    epic_id = find_epic_for_task(registry, task_id)
    if epic_id:
        epic_dirs = list((project_root / "docs" / "epics").glob(f"{epic_id}-*"))
        for epic_dir in epic_dirs:
            task_files = list(epic_dir.glob(f"tasks/{task_id}-*.md"))
            if task_files:
                return task_files[0].read_text()

    return None


def detect_agent(text: str) -> str:
    """
    Detect the appropriate agent based on task content.
    Security keywords take priority.
    """
    text_lower = text.lower()

    # Security keywords (highest priority - always check first)
    security_keywords = [
        "auth", "login", "password", "token", "session", "security",
        "encrypt", "credential", "oauth", "jwt", "permission", "role",
        "payment", "billing", "checkout", "stripe", "subscription",
        "credit card", "transaction"
    ]
    if any(kw in text_lower for kw in security_keywords):
        return "security-boss"

    # Testing/QA keywords
    qa_keywords = ["test", "verify", "qa", "acceptance", "coverage", "regression", "spec"]
    if any(kw in text_lower for kw in qa_keywords):
        return "quality-engineer"

    # Architecture keywords
    arch_keywords = ["architecture", "adr", "design system", "database design", "schema", "migration"]
    if any(kw in text_lower for kw in arch_keywords):
        return "architect"

    # UX/UI keywords
    ux_keywords = ["ui", "ux", "component", "layout", "style", "accessibility", "responsive", "design"]
    if any(kw in text_lower for kw in ux_keywords):
        return "ux-designer"

    # API keywords
    api_keywords = ["api", "endpoint", "integration", "rest", "graphql", "webhook"]
    if any(kw in text_lower for kw in api_keywords):
        return "api-tester"

    # Performance keywords
    perf_keywords = ["performance", "optimize", "slow", "latency", "cache", "memory", "profil"]
    if any(kw in text_lower for kw in perf_keywords):
        return "performance-enhancer"

    # DevOps keywords
    devops_keywords = ["deploy", "ci/cd", "pipeline", "docker", "kubernetes", "infrastructure", "terraform"]
    if any(kw in text_lower for kw in devops_keywords):
        return "devops"

    # Default to developer
    return "developer"


def load_agent_summary(project_root: Path, agent_name: str) -> str:
    """Load the agent summary file"""
    summary_path = project_root / "agents" / "summaries" / f"{agent_name}.md"
    if summary_path.exists():
        return summary_path.read_text()

    # Fallback message if summary doesn't exist
    return f"# @{agent_name} Summary\n\nNo summary file found. Use general best practices."


def extract_task_info(task_content: str) -> dict:
    """Extract key information from task markdown"""
    info = {
        "title": "",
        "objective": "",
        "acceptance_criteria": [],
        "scope_directories": [],
        "scope_files": [],
    }

    # Extract title (first # heading)
    title_match = re.search(r'^#\s+(.+)$', task_content, re.MULTILINE)
    if title_match:
        info["title"] = title_match.group(1).strip()

    # Extract objective (look for Objective section)
    obj_match = re.search(r'##\s*Objective\s*\n+([\s\S]*?)(?=\n##|\Z)', task_content, re.IGNORECASE)
    if obj_match:
        info["objective"] = obj_match.group(1).strip()

    # Extract acceptance criteria
    ac_match = re.search(r'##\s*Acceptance Criteria\s*\n+([\s\S]*?)(?=\n##|\Z)', task_content, re.IGNORECASE)
    if ac_match:
        criteria = re.findall(r'[-*]\s*\[.\]\s*(.+)', ac_match.group(1))
        info["acceptance_criteria"] = criteria if criteria else []

    # Extract scope
    scope_match = re.search(r'##\s*Scope\s*\n+([\s\S]*?)(?=\n##|\Z)', task_content, re.IGNORECASE)
    if scope_match:
        scope_text = scope_match.group(1)
        # Look for directories
        dir_match = re.search(r'Directories?:\s*(.+)', scope_text, re.IGNORECASE)
        if dir_match:
            dirs = [d.strip() for d in dir_match.group(1).split(',')]
            info["scope_directories"] = dirs
        # Look for files
        file_match = re.search(r'Files?:\s*(.+)', scope_text, re.IGNORECASE)
        if file_match:
            files = [f.strip() for f in file_match.group(1).split(',')]
            info["scope_files"] = files

    return info


def generate_prompt(
    task_id: str,
    task_content: str,
    agent_name: str,
    agent_summary: str,
    epic_id: str | None,
    parent_session: str | None,
    subagent_num: int = 1
) -> str:
    """Generate the complete Task tool prompt"""

    task_info = extract_task_info(task_content)

    # Build session ID
    session_id = f"{parent_session}-sub-{subagent_num}" if parent_session else f"subagent-{subagent_num}"

    # Build scope section
    scope_lines = []
    if task_info["scope_directories"]:
        scope_lines.append(f"- Directories: {', '.join(task_info['scope_directories'])}")
    if task_info["scope_files"]:
        scope_lines.append(f"- Files: {', '.join(task_info['scope_files'])}")
    scope_section = "\n".join(scope_lines) if scope_lines else "- See task file for scope details"

    # Build acceptance criteria section
    if task_info["acceptance_criteria"]:
        ac_lines = [f"- [ ] {c}" for c in task_info["acceptance_criteria"]]
        ac_section = "\n".join(ac_lines)
    else:
        ac_section = "- [ ] See task file for acceptance criteria"

    # Build commit prefix
    commit_prefix = f"feat({epic_id})" if epic_id else "feat"

    # Check if security agent (warn about parallelization)
    security_warning = ""
    if agent_name == "security-boss":
        security_warning = """
### SECURITY NOTICE

This task involves security-sensitive work.
- Do NOT run in parallel with other tasks
- Requires focused, sequential execution
- Review OWASP Top 10 before implementation
"""

    prompt = f"""## Task Assignment: {task_id} - {task_info['title'] or 'Task'}

**Session ID:** {session_id}
{f"**Parent Session:** {parent_session}" if parent_session else ""}
{f"**Epic:** {epic_id}" if epic_id else ""}

### Agent: @{agent_name}

{agent_summary}
{security_warning}
### Task Details

**Objective:** {task_info['objective'] or 'See task file for objective'}

**Scope (STRICT - do NOT modify files outside):**
{scope_section}

**Acceptance Criteria:**
{ac_section}

### Instructions

1. Read and understand the requirements fully
2. Plan your approach before coding
3. Implement within declared scope ONLY
4. Run tests, lint, type-check
5. Commit with message: `{commit_prefix}: {task_info['title'] or task_id} [Task-ID: {task_id}]`

If you need to modify files outside the declared scope:
1. STOP
2. Report the need in your response
3. Do NOT make the modification

### On Completion

Report back with:
```json
{{
  "task_id": "{task_id}",
  "status": "completed | blocked | partial",
  "commits": ["<commit-hash>"],
  "files_modified": ["<list of files>"],
  "blockers": "<if not completed, explain why>",
  "notes": "<any decisions or issues encountered>"
}}
```
"""

    return prompt.strip()


def main():
    parser = argparse.ArgumentParser(
        description="Prepare a Task tool prompt for delegating work to a subagent"
    )
    parser.add_argument("task_id", help="Task ID (e.g., T015)")
    parser.add_argument("--parent-session", help="Parent session ID for tracking")
    parser.add_argument("--subagent-num", type=int, default=1, help="Subagent number for parallel tasks")
    parser.add_argument("--background", action="store_true", help="Note that this will run in background")
    parser.add_argument("--json", action="store_true", help="Output as JSON with metadata")

    args = parser.parse_args()

    project_root = get_project_root()
    registry = load_registry(project_root)

    # Find task
    task_data = find_task(registry, args.task_id)
    if not task_data:
        print(f"Error: Task {args.task_id} not found in registry", file=sys.stderr)
        sys.exit(1)

    # Load task file
    task_content = load_task_file(project_root, registry, args.task_id)
    if not task_content:
        print(f"Error: Could not load task file for {args.task_id}", file=sys.stderr)
        sys.exit(1)

    # Detect agent
    agent_name = detect_agent(task_content)

    # Load agent summary
    agent_summary = load_agent_summary(project_root, agent_name)

    # Find epic
    epic_id = find_epic_for_task(registry, args.task_id)

    # Generate prompt
    prompt = generate_prompt(
        task_id=args.task_id,
        task_content=task_content,
        agent_name=agent_name,
        agent_summary=agent_summary,
        epic_id=epic_id,
        parent_session=args.parent_session,
        subagent_num=args.subagent_num
    )

    if args.json:
        output = {
            "task_id": args.task_id,
            "agent": agent_name,
            "epic_id": epic_id,
            "is_security": agent_name == "security-boss",
            "run_in_background": args.background,
            "subagent_type": "general-purpose",
            "description": f"{args.task_id}: {extract_task_info(task_content).get('title', 'Task')}",
            "prompt": prompt
        }
        print(json.dumps(output, indent=2))
    else:
        # Print metadata as comments
        print(f"# Agent: @{agent_name}")
        print(f"# Epic: {epic_id or 'None'}")
        print(f"# Background: {args.background}")
        if agent_name == "security-boss":
            print("# WARNING: Security task - do NOT parallelize")
        print("#" + "-" * 60)
        print()
        print(prompt)


if __name__ == "__main__":
    main()
