#!/usr/bin/env python3
"""
Detect the appropriate agent for a task based on its content.

Usage:
    python scripts/detect_agent.py T015
    python scripts/detect_agent.py T015 --verbose
    python scripts/detect_agent.py --text "implement user authentication with JWT"

Output:
    Agent name (e.g., "developer", "security-boss")
    With --verbose: includes matched keywords and confidence
"""

import argparse
import json
import re
import sys
from pathlib import Path


# Agent detection rules with keywords and priority
AGENT_RULES = [
    {
        "agent": "security-boss",
        "priority": 1,  # Highest priority - always check first
        "keywords": [
            "auth", "login", "password", "token", "session", "security",
            "encrypt", "credential", "oauth", "jwt", "permission", "role",
            "payment", "billing", "checkout", "stripe", "subscription",
            "credit card", "transaction", "secret", "api key", "hash",
            "sanitize", "xss", "csrf", "injection", "vulnerability"
        ],
        "description": "Security, authentication, authorization, payments"
    },
    {
        "agent": "quality-engineer",
        "priority": 2,
        "keywords": [
            "test", "verify", "qa", "acceptance", "coverage", "regression",
            "spec", "assert", "mock", "stub", "fixture", "e2e", "unit test",
            "integration test", "test plan", "test case"
        ],
        "description": "Testing, QA, verification"
    },
    {
        "agent": "architect",
        "priority": 3,
        "keywords": [
            "architecture", "adr", "design system", "database design", "schema",
            "migration", "scalability", "microservice", "monolith", "pattern",
            "trade-off", "technology choice", "system design"
        ],
        "description": "Architecture decisions, ADRs, system design"
    },
    {
        "agent": "ux-designer",
        "priority": 4,
        "keywords": [
            "ui", "ux", "component", "layout", "style", "accessibility",
            "responsive", "design", "wcag", "aria", "user flow", "wireframe",
            "prototype", "usability", "mobile-first"
        ],
        "description": "UI/UX, accessibility, design"
    },
    {
        "agent": "api-tester",
        "priority": 5,
        "keywords": [
            "api", "endpoint", "integration", "rest", "graphql", "webhook",
            "request", "response", "status code", "contract", "openapi",
            "swagger", "postman"
        ],
        "description": "API testing, integration, contracts"
    },
    {
        "agent": "performance-enhancer",
        "priority": 6,
        "keywords": [
            "performance", "optimize", "slow", "latency", "cache", "memory",
            "profil", "benchmark", "bottleneck", "throughput", "load test",
            "response time"
        ],
        "description": "Performance optimization, profiling"
    },
    {
        "agent": "devops",
        "priority": 7,
        "keywords": [
            "deploy", "ci/cd", "pipeline", "docker", "kubernetes", "infrastructure",
            "terraform", "aws", "gcp", "azure", "helm", "github actions",
            "jenkins", "monitoring", "alerting"
        ],
        "description": "CI/CD, infrastructure, deployment"
    },
    {
        "agent": "scrum-master",
        "priority": 8,
        "keywords": [
            "break down", "task breakdown", "epic", "story points", "sprint",
            "dependency", "prioritize", "backlog"
        ],
        "description": "Task breakdown, workflow management"
    },
    {
        "agent": "project-manager",
        "priority": 9,
        "keywords": [
            "requirements", "prd", "scope", "stakeholder", "user story",
            "acceptance criteria", "roadmap", "milestone"
        ],
        "description": "Requirements, PRD, scope definition"
    },
]


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
        return {}
    with open(registry_path) as f:
        return json.load(f)


def find_task(registry: dict, task_id: str) -> dict | None:
    """Find a task in the registry"""
    return registry.get("tasks", {}).get(task_id)


def find_epic_for_task(registry: dict, task_id: str) -> str | None:
    """Find which epic a task belongs to"""
    for epic_id, epic_data in registry.get("epics", {}).items():
        if task_id in epic_data.get("tasks", []):
            return epic_id
    return None


def load_task_content(project_root: Path, registry: dict, task_id: str) -> str | None:
    """Load task file content"""
    task_data = find_task(registry, task_id)
    if not task_data:
        return None

    task_path = task_data.get("path")
    if task_path:
        full_path = project_root / task_path
        if full_path.exists():
            return full_path.read_text()

    epic_id = find_epic_for_task(registry, task_id)
    if epic_id:
        epic_dirs = list((project_root / "docs" / "epics").glob(f"{epic_id}-*"))
        for epic_dir in epic_dirs:
            task_files = list(epic_dir.glob(f"tasks/{task_id}-*.md"))
            if task_files:
                return task_files[0].read_text()

    return None


def detect_agent(text: str, verbose: bool = False) -> dict:
    """
    Detect the appropriate agent based on text content.

    Returns:
        dict with 'agent', 'matched_keywords', 'confidence', 'description'
    """
    text_lower = text.lower()

    for rule in sorted(AGENT_RULES, key=lambda r: r["priority"]):
        matched = [kw for kw in rule["keywords"] if kw in text_lower]
        if matched:
            # Calculate confidence based on number of matches
            confidence = min(1.0, len(matched) / 3)  # 3+ matches = full confidence

            return {
                "agent": rule["agent"],
                "matched_keywords": matched,
                "confidence": round(confidence, 2),
                "description": rule["description"],
                "is_security": rule["agent"] == "security-boss"
            }

    # Default to developer
    return {
        "agent": "developer",
        "matched_keywords": [],
        "confidence": 1.0,  # Default is always confident
        "description": "General implementation",
        "is_security": False
    }


def main():
    parser = argparse.ArgumentParser(
        description="Detect the appropriate agent for a task"
    )
    parser.add_argument("task_id", nargs="?", help="Task ID (e.g., T015)")
    parser.add_argument("--text", help="Direct text to analyze (instead of task ID)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show detailed output")
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()

    if not args.task_id and not args.text:
        parser.error("Either task_id or --text is required")

    # Get text to analyze
    if args.text:
        text = args.text
        task_id = None
    else:
        project_root = get_project_root()
        registry = load_registry(project_root)

        if not registry:
            print(f"Error: Could not load registry", file=sys.stderr)
            sys.exit(1)

        text = load_task_content(project_root, registry, args.task_id)
        if not text:
            print(f"Error: Could not load task {args.task_id}", file=sys.stderr)
            sys.exit(1)
        task_id = args.task_id

    # Detect agent
    result = detect_agent(text, args.verbose)
    if task_id:
        result["task_id"] = task_id

    # Output
    if args.json:
        print(json.dumps(result, indent=2))
    elif args.verbose:
        print(f"Agent: @{result['agent']}")
        print(f"Description: {result['description']}")
        print(f"Confidence: {result['confidence']}")
        if result['matched_keywords']:
            print(f"Matched keywords: {', '.join(result['matched_keywords'])}")
        if result['is_security']:
            print("WARNING: Security task - do NOT parallelize")
    else:
        print(result['agent'])


if __name__ == "__main__":
    main()
