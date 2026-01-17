#!/usr/bin/env python3
"""
Analyze task registry for parallelizable work.

Usage:
    python scripts/dispatch_analysis.py
    python scripts/dispatch_analysis.py --max-agents 3
    python scripts/dispatch_analysis.py --generate-prompts
    python scripts/dispatch_analysis.py --json

Output:
    Analysis of which tasks can run in parallel, with scope conflict detection.
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Optional


def get_project_root() -> Path:
    """Find project root by looking for CLAUDE.md"""
    current = Path(__file__).resolve().parent
    while current != current.parent:
        if (current / "CLAUDE.md").exists():
            return current
        current = current.parent
    return Path(__file__).resolve().parent.parent


def load_registry(project_root: Path) -> dict:
    """Load the task registry"""
    registry_path = project_root / "docs" / "tasks" / "registry.json"
    if not registry_path.exists():
        print(f"Error: Registry not found at {registry_path}", file=sys.stderr)
        sys.exit(1)
    with open(registry_path) as f:
        return json.load(f)


def load_task_file(project_root: Path, task_data: dict, task_id: str, registry: dict) -> Optional[str]:
    """Load task file content"""
    task_path = task_data.get("path")
    if task_path:
        full_path = project_root / task_path
        if full_path.exists():
            return full_path.read_text()

    # Find epic
    epic_id = None
    for eid, edata in registry.get("epics", {}).items():
        if task_id in edata.get("tasks", []):
            epic_id = eid
            break

    if epic_id:
        epic_dirs = list((project_root / "docs" / "epics").glob(f"{epic_id}-*"))
        for epic_dir in epic_dirs:
            task_files = list(epic_dir.glob(f"tasks/{task_id}-*.md"))
            if task_files:
                return task_files[0].read_text()

    return None


def detect_agent(text: str) -> str:
    """Quick agent detection (duplicated to keep script standalone)"""
    text_lower = text.lower()

    security_keywords = [
        "auth", "login", "password", "token", "session", "security",
        "encrypt", "credential", "payment", "billing", "checkout"
    ]
    if any(kw in text_lower for kw in security_keywords):
        return "security-boss"

    qa_keywords = ["test", "verify", "qa", "acceptance", "coverage"]
    if any(kw in text_lower for kw in qa_keywords):
        return "quality-engineer"

    return "developer"


def get_ready_tasks(registry: dict) -> list:
    """Get all tasks with status 'ready' and no lock"""
    ready = []
    tasks = registry.get("tasks", {})

    for task_id, task_data in tasks.items():
        status = task_data.get("status", "pending")
        locked_by = task_data.get("lockedBy")

        if status == "ready" and not locked_by:
            ready.append({
                "id": task_id,
                "data": task_data
            })

    return ready


def get_task_scope(task_data: dict, task_content: str = None) -> dict:
    """Extract scope from task data or content"""
    scope = {
        "directories": task_data.get("scope", {}).get("directories", []),
        "files": task_data.get("scope", {}).get("files", [])
    }

    # Try to extract from content if not in registry
    if task_content and not scope["directories"] and not scope["files"]:
        import re
        # Look for scope section
        scope_match = re.search(r'##\s*Scope\s*\n+([\s\S]*?)(?=\n##|\Z)', task_content, re.IGNORECASE)
        if scope_match:
            scope_text = scope_match.group(1)
            dir_match = re.search(r'Directories?:\s*(.+)', scope_text, re.IGNORECASE)
            if dir_match:
                scope["directories"] = [d.strip() for d in dir_match.group(1).split(',')]
            file_match = re.search(r'Files?:\s*(.+)', scope_text, re.IGNORECASE)
            if file_match:
                scope["files"] = [f.strip() for f in file_match.group(1).split(',')]

    return scope


def scopes_conflict(scope1: dict, scope2: dict) -> tuple[bool, str]:
    """
    Check if two scopes conflict (overlap).

    Returns:
        (conflicts: bool, reason: str)
    """
    # Check directory conflicts
    for dir1 in scope1.get("directories", []):
        for dir2 in scope2.get("directories", []):
            # Normalize paths
            d1 = dir1.rstrip("/")
            d2 = dir2.rstrip("/")

            # Check if one is a prefix of the other
            if d1.startswith(d2) or d2.startswith(d1):
                return True, f"Directory overlap: {dir1} and {dir2}"

    # Check file conflicts
    for file1 in scope1.get("files", []):
        for file2 in scope2.get("files", []):
            if file1 == file2:
                return True, f"Same file: {file1}"

    # Check if files are in conflicting directories
    for file1 in scope1.get("files", []):
        for dir2 in scope2.get("directories", []):
            if file1.startswith(dir2.rstrip("/") + "/"):
                return True, f"File {file1} in directory {dir2}"

    for file2 in scope2.get("files", []):
        for dir1 in scope1.get("directories", []):
            if file2.startswith(dir1.rstrip("/") + "/"):
                return True, f"File {file2} in directory {dir1}"

    return False, ""


def tasks_have_dependency(task1_id: str, task2_id: str, registry: dict) -> bool:
    """Check if either task depends on the other"""
    tasks = registry.get("tasks", {})

    task1_deps = tasks.get(task1_id, {}).get("dependencies", [])
    task2_deps = tasks.get(task2_id, {}).get("dependencies", [])

    return task2_id in task1_deps or task1_id in task2_deps


def analyze_parallelization(project_root: Path, registry: dict, max_agents: int = 3) -> dict:
    """
    Analyze which tasks can run in parallel.

    Returns analysis with:
    - primary: task for main agent
    - parallelizable: tasks that can run alongside primary
    - deferred: tasks that cannot parallelize (with reasons)
    """
    ready_tasks = get_ready_tasks(registry)

    if not ready_tasks:
        return {
            "status": "no_ready_tasks",
            "message": "No tasks with status 'ready' found",
            "primary": None,
            "parallelizable": [],
            "deferred": []
        }

    # Enrich with content and agent detection
    enriched = []
    for task in ready_tasks:
        content = load_task_file(project_root, task["data"], task["id"], registry)
        agent = detect_agent(content or task["data"].get("name", ""))
        scope = get_task_scope(task["data"], content)
        priority = task["data"].get("priority", 999)

        enriched.append({
            "id": task["id"],
            "name": task["data"].get("name", task["id"]),
            "agent": agent,
            "scope": scope,
            "priority": priority,
            "is_security": agent == "security-boss",
            "content": content
        })

    # Sort by priority (lower = higher priority)
    enriched.sort(key=lambda t: t["priority"])

    # Primary task is highest priority
    primary = enriched[0]

    # If primary is security, nothing can parallelize
    if primary["is_security"]:
        return {
            "status": "security_serial",
            "message": "Primary task is security-related. Must execute serially.",
            "primary": {
                "id": primary["id"],
                "name": primary["name"],
                "agent": primary["agent"]
            },
            "parallelizable": [],
            "deferred": [
                {
                    "id": t["id"],
                    "name": t["name"],
                    "reason": "Security task running - no parallelization allowed"
                }
                for t in enriched[1:]
            ]
        }

    # Check which other tasks can parallelize
    parallelizable = []
    deferred = []

    for task in enriched[1:]:
        # Security tasks never parallelize
        if task["is_security"]:
            deferred.append({
                "id": task["id"],
                "name": task["name"],
                "reason": "Security task - must run alone"
            })
            continue

        # Check dependency
        if tasks_have_dependency(primary["id"], task["id"], registry):
            deferred.append({
                "id": task["id"],
                "name": task["name"],
                "reason": f"Has dependency relationship with {primary['id']}"
            })
            continue

        # Check scope conflict with primary
        conflicts, reason = scopes_conflict(primary["scope"], task["scope"])
        if conflicts:
            deferred.append({
                "id": task["id"],
                "name": task["name"],
                "reason": f"Scope conflict with primary: {reason}"
            })
            continue

        # Check scope conflict with already-selected parallel tasks
        has_conflict = False
        for p_task in parallelizable:
            conflicts, reason = scopes_conflict(p_task["scope"], task["scope"])
            if conflicts:
                deferred.append({
                    "id": task["id"],
                    "name": task["name"],
                    "reason": f"Scope conflict with {p_task['id']}: {reason}"
                })
                has_conflict = True
                break

        if has_conflict:
            continue

        # Can parallelize!
        if len(parallelizable) < max_agents - 1:  # -1 because primary takes one slot
            parallelizable.append({
                "id": task["id"],
                "name": task["name"],
                "agent": task["agent"],
                "scope": task["scope"]
            })
        else:
            deferred.append({
                "id": task["id"],
                "name": task["name"],
                "reason": f"Max agents ({max_agents}) reached"
            })

    return {
        "status": "analysis_complete",
        "total_ready": len(enriched),
        "can_parallelize": len(parallelizable) + 1,  # +1 for primary
        "primary": {
            "id": primary["id"],
            "name": primary["name"],
            "agent": primary["agent"],
            "scope": primary["scope"]
        },
        "parallelizable": parallelizable,
        "deferred": deferred
    }


def format_human_readable(analysis: dict) -> str:
    """Format analysis for human reading"""
    lines = []
    lines.append("=" * 60)
    lines.append("DISPATCH ANALYSIS")
    lines.append("=" * 60)
    lines.append("")

    if analysis["status"] == "no_ready_tasks":
        lines.append("No tasks ready for execution.")
        return "\n".join(lines)

    if analysis["status"] == "security_serial":
        lines.append("SECURITY MODE: Serial execution required")
        lines.append("")

    lines.append(f"Ready Tasks: {analysis.get('total_ready', 'N/A')}")
    lines.append(f"Can Parallelize: {analysis.get('can_parallelize', 1)}")
    lines.append("")

    # Primary
    primary = analysis["primary"]
    lines.append("PRIMARY (Main Agent):")
    lines.append(f"  {primary['id']}: {primary['name']}")
    lines.append(f"  Agent: @{primary['agent']}")
    if primary.get("scope", {}).get("directories"):
        lines.append(f"  Scope: {', '.join(primary['scope']['directories'])}")
    lines.append("")

    # Parallelizable
    if analysis["parallelizable"]:
        lines.append("PARALLELIZABLE (Subagents):")
        for i, task in enumerate(analysis["parallelizable"], 1):
            lines.append(f"  Sub-Agent {i}: {task['id']}: {task['name']}")
            lines.append(f"    Agent: @{task['agent']}")
            if task.get("scope", {}).get("directories"):
                lines.append(f"    Scope: {', '.join(task['scope']['directories'])}")
        lines.append("")

    # Deferred
    if analysis["deferred"]:
        lines.append("DEFERRED (Cannot parallelize):")
        for task in analysis["deferred"]:
            lines.append(f"  {task['id']}: {task['name']}")
            lines.append(f"    Reason: {task['reason']}")
        lines.append("")

    lines.append("=" * 60)

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Analyze task registry for parallelizable work"
    )
    parser.add_argument("--max-agents", type=int, default=3,
                       help="Maximum number of parallel agents (default: 3)")
    parser.add_argument("--json", action="store_true",
                       help="Output as JSON")
    parser.add_argument("--generate-prompts", action="store_true",
                       help="Generate Task tool prompts for parallelizable tasks")
    parser.add_argument("--parent-session",
                       help="Parent session ID for generated prompts")

    args = parser.parse_args()

    project_root = get_project_root()
    registry = load_registry(project_root)

    analysis = analyze_parallelization(project_root, registry, args.max_agents)

    if args.json:
        print(json.dumps(analysis, indent=2))
    elif args.generate_prompts:
        # Generate prompts for all parallelizable tasks
        print(format_human_readable(analysis))
        print("\n" + "=" * 60)
        print("GENERATED PROMPTS")
        print("=" * 60 + "\n")

        # Import prepare script functionality
        import subprocess

        all_tasks = [analysis["primary"]] + analysis.get("parallelizable", [])
        for i, task in enumerate(all_tasks):
            print(f"\n### Task {i+1}: {task['id']} ###\n")
            cmd = [
                sys.executable,
                str(project_root / "scripts" / "prepare_task_prompt.py"),
                task["id"],
                "--subagent-num", str(i + 1)
            ]
            if args.parent_session:
                cmd.extend(["--parent-session", args.parent_session])

            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print(result.stdout)
            else:
                print(f"Error generating prompt: {result.stderr}")
    else:
        print(format_human_readable(analysis))


if __name__ == "__main__":
    main()
