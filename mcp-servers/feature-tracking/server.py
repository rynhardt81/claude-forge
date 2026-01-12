#!/usr/bin/env python3
"""
MCP Server for Feature Management
==================================

Provides tools to manage features in the autonomous coding system.
Features are stored in a SQLite database and accessed via MCP tools.

Core Tools:
- feature_get_stats: Get progress statistics
- feature_get_next: Get next feature to implement
- feature_get_for_regression: Get random passing features for testing
- feature_mark_passing: Mark a feature as passing
- feature_skip: Skip a feature (move to end of queue)
- feature_mark_in_progress: Mark a feature as in-progress
- feature_clear_in_progress: Clear in-progress status
- feature_create_bulk: Create multiple features at once
- feature_get_by_category: Get features by category code

Dispatch Tools (v1.1):
- feature_get_parallelizable: Get features that can run in parallel
- feature_create_parallel_group: Create a parallel execution group
- feature_get_parallel_status: Check status of a parallel group
- feature_complete_parallel_group: Mark parallel group as complete
- feature_abort_parallel_group: Abort and release parallel group

Database Location:
- Default: {PROJECT_DIR}/features.db
- Recommended: {project_root}/.claude/features/features.db

Version History:
- v1.0: Initial release with core feature management
- v1.1: Added dispatch tools for parallel feature execution
"""

import json
import os
import sys
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path
from typing import Annotated

from mcp.server.fastmcp import FastMCP
from pydantic import Field
from sqlalchemy.sql.expression import func

# Import local modules
from database import (
    Feature,
    ParallelGroup,
    can_parallelize_categories,
    create_database,
    CRITICAL_CATEGORIES,
)
from migration import migrate_json_to_sqlite

# Configuration from environment
# Default to current directory, but should be set to .claude/features in production
PROJECT_DIR = Path(os.environ.get("PROJECT_DIR", ".")).resolve()


# Global database session maker (initialized on startup)
_session_maker = None
_engine = None


@asynccontextmanager
async def server_lifespan(server: FastMCP):
    """Initialize database on startup, cleanup on shutdown."""
    global _session_maker, _engine

    # Create project directory if it doesn't exist
    PROJECT_DIR.mkdir(parents=True, exist_ok=True)

    # Initialize database
    _engine, _session_maker = create_database(PROJECT_DIR)

    # Run migration if needed (converts legacy JSON to SQLite)
    migrate_json_to_sqlite(PROJECT_DIR, _session_maker)

    yield

    # Cleanup
    if _engine:
        _engine.dispose()


# Initialize the MCP server
mcp = FastMCP("features", lifespan=server_lifespan)


def get_session():
    """Get a new database session."""
    if _session_maker is None:
        raise RuntimeError("Database not initialized")
    return _session_maker()


@mcp.tool()
def feature_get_stats() -> str:
    """Get statistics about feature completion progress.

    Returns the number of passing features, in-progress features, total features,
    and completion percentage. Use this to track overall progress of the implementation.

    Returns:
        JSON with: passing (int), in_progress (int), total (int), percentage (float)
    """
    session = get_session()
    try:
        total = session.query(Feature).count()
        passing = session.query(Feature).filter(Feature.passes == True).count()
        in_progress = session.query(Feature).filter(Feature.in_progress == True).count()
        percentage = round((passing / total) * 100, 1) if total > 0 else 0.0

        return json.dumps({
            "passing": passing,
            "in_progress": in_progress,
            "total": total,
            "percentage": percentage
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_get_next() -> str:
    """Get the highest-priority pending feature to work on.

    Returns the feature with the lowest priority number that has passes=false.
    Use this at the start of each coding session to determine what to implement next.

    Returns:
        JSON with feature details (id, priority, category, name, description, steps, passes, in_progress)
        or error message if all features are passing.
    """
    session = get_session()
    try:
        feature = (
            session.query(Feature)
            .filter(Feature.passes == False)
            .order_by(Feature.priority.asc(), Feature.id.asc())
            .first()
        )

        if feature is None:
            return json.dumps({"error": "All features are passing! No more work to do."})

        return json.dumps(feature.to_dict(), indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_get_for_regression(
    limit: Annotated[int, Field(default=3, ge=1, le=10, description="Maximum number of passing features to return")] = 3
) -> str:
    """Get random passing features for regression testing.

    Returns a random selection of features that are currently passing.
    Use this to verify that previously implemented features still work
    after making changes.

    Args:
        limit: Maximum number of features to return (1-10, default 3)

    Returns:
        JSON with: features (list of feature objects), count (int)
    """
    session = get_session()
    try:
        features = (
            session.query(Feature)
            .filter(Feature.passes == True)
            .order_by(func.random())
            .limit(limit)
            .all()
        )

        return json.dumps({
            "features": [f.to_dict() for f in features],
            "count": len(features)
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_mark_passing(
    feature_id: Annotated[int, Field(description="The ID of the feature to mark as passing", ge=1)]
) -> str:
    """Mark a feature as passing after successful implementation.

    Updates the feature's passes field to true and clears the in_progress flag.
    Use this after you have implemented the feature and verified it works correctly.

    Args:
        feature_id: The ID of the feature to mark as passing

    Returns:
        JSON with the updated feature details, or error if not found.
    """
    session = get_session()
    try:
        feature = session.query(Feature).filter(Feature.id == feature_id).first()

        if feature is None:
            return json.dumps({"error": f"Feature with ID {feature_id} not found"})

        feature.passes = True
        feature.in_progress = False
        session.commit()
        session.refresh(feature)

        return json.dumps(feature.to_dict(), indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_skip(
    feature_id: Annotated[int, Field(description="The ID of the feature to skip", ge=1)]
) -> str:
    """Skip a feature by moving it to the end of the priority queue.

    Use this when a feature cannot be implemented yet due to:
    - Dependencies on other features that aren't implemented yet
    - External blockers (missing assets, unclear requirements)
    - Technical prerequisites that need to be addressed first

    The feature's priority is set to max_priority + 1, so it will be
    worked on after all other pending features. Also clears the in_progress
    flag so the feature returns to "pending" status.

    Args:
        feature_id: The ID of the feature to skip

    Returns:
        JSON with skip details: id, name, old_priority, new_priority, message
    """
    session = get_session()
    try:
        feature = session.query(Feature).filter(Feature.id == feature_id).first()

        if feature is None:
            return json.dumps({"error": f"Feature with ID {feature_id} not found"})

        if feature.passes:
            return json.dumps({"error": "Cannot skip a feature that is already passing"})

        old_priority = feature.priority

        # Get max priority and set this feature to max + 1
        max_priority_result = session.query(Feature.priority).order_by(Feature.priority.desc()).first()
        new_priority = (max_priority_result[0] + 1) if max_priority_result else 1

        feature.priority = new_priority
        feature.in_progress = False
        session.commit()
        session.refresh(feature)

        return json.dumps({
            "id": feature.id,
            "name": feature.name,
            "old_priority": old_priority,
            "new_priority": new_priority,
            "message": f"Feature '{feature.name}' moved to end of queue"
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_mark_in_progress(
    feature_id: Annotated[int, Field(description="The ID of the feature to mark as in-progress", ge=1)]
) -> str:
    """Mark a feature as in-progress. Call immediately after feature_get_next().

    This prevents other agent sessions from working on the same feature.
    Use this as soon as you retrieve a feature to work on.

    Args:
        feature_id: The ID of the feature to mark as in-progress

    Returns:
        JSON with the updated feature details, or error if not found or already in-progress.
    """
    session = get_session()
    try:
        feature = session.query(Feature).filter(Feature.id == feature_id).first()

        if feature is None:
            return json.dumps({"error": f"Feature with ID {feature_id} not found"})

        if feature.passes:
            return json.dumps({"error": f"Feature with ID {feature_id} is already passing"})

        if feature.in_progress:
            return json.dumps({"error": f"Feature with ID {feature_id} is already in-progress"})

        feature.in_progress = True
        session.commit()
        session.refresh(feature)

        return json.dumps(feature.to_dict(), indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_clear_in_progress(
    feature_id: Annotated[int, Field(description="The ID of the feature to clear in-progress status", ge=1)]
) -> str:
    """Clear in-progress status from a feature.

    Use this when abandoning a feature or manually unsticking a stuck feature.
    The feature will return to the pending queue.

    Args:
        feature_id: The ID of the feature to clear in-progress status

    Returns:
        JSON with the updated feature details, or error if not found.
    """
    session = get_session()
    try:
        feature = session.query(Feature).filter(Feature.id == feature_id).first()

        if feature is None:
            return json.dumps({"error": f"Feature with ID {feature_id} not found"})

        feature.in_progress = False
        session.commit()
        session.refresh(feature)

        return json.dumps(feature.to_dict(), indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_create_bulk(
    features: Annotated[list[dict], Field(description="List of features to create, each with category, name, description, and steps")]
) -> str:
    """Create multiple features in a single operation.

    Features are assigned sequential priorities based on their order.
    All features start with passes=false.

    This is typically used by the @scrum-master agent during /new-project
    Phase 2 to populate the feature database from the PRD breakdown.

    Args:
        features: List of features to create, each with:
            - category (str): Feature category (A-T)
            - name (str): Feature name
            - description (str): Detailed description
            - steps (list[str]): Implementation/test steps

    Returns:
        JSON with: created (int) - number of features created
    """
    session = get_session()
    try:
        # Get the starting priority
        max_priority_result = session.query(Feature.priority).order_by(Feature.priority.desc()).first()
        start_priority = (max_priority_result[0] + 1) if max_priority_result else 1

        created_count = 0
        for i, feature_data in enumerate(features):
            # Validate required fields
            if not all(key in feature_data for key in ["category", "name", "description", "steps"]):
                return json.dumps({
                    "error": f"Feature at index {i} missing required fields (category, name, description, steps)"
                })

            db_feature = Feature(
                priority=start_priority + i,
                category=feature_data["category"],
                name=feature_data["name"],
                description=feature_data["description"],
                steps=feature_data["steps"],
                passes=False,
            )
            session.add(db_feature)
            created_count += 1

        session.commit()

        return json.dumps({"created": created_count}, indent=2)
    except Exception as e:
        session.rollback()
        return json.dumps({"error": str(e)})
    finally:
        session.close()


@mcp.tool()
def feature_get_by_category(
    category: Annotated[str, Field(description="Category code (A-T) to filter by")]
) -> str:
    """Get all features in a specific category.

    Useful for understanding the scope of work in a particular area
    or for routing features to specialized agents.

    Args:
        category: Single letter category code (A-T)

    Returns:
        JSON with: features (list), count (int), passing (int), pending (int)
    """
    session = get_session()
    try:
        features = (
            session.query(Feature)
            .filter(Feature.category == category.upper())
            .order_by(Feature.priority.asc())
            .all()
        )

        passing = sum(1 for f in features if f.passes)
        pending = len(features) - passing

        return json.dumps({
            "category": category.upper(),
            "features": [f.to_dict() for f in features],
            "count": len(features),
            "passing": passing,
            "pending": pending
        }, indent=2)
    finally:
        session.close()


# ============================================================================
# Dispatch Tools (added in v1.1)
# ============================================================================


@mcp.tool()
def feature_get_parallelizable(
    limit: Annotated[int, Field(default=5, ge=1, le=10, description="Maximum number of parallelizable features to return")] = 5
) -> str:
    """Get pending features that can be safely parallelized.

    Analyzes pending features and returns a set that can be worked on
    in parallel based on category compatibility rules:
    - Critical categories (A: Security, P: Payment) never parallelize
    - Same-category features never parallelize (likely share files)
    - Different categories parallelize based on the compatibility matrix

    Use this at the start of /implement-features to identify parallel work.

    Args:
        limit: Maximum number of features to return (1-10, default 5)

    Returns:
        JSON with:
        - primary: Feature dict (highest priority pending feature)
        - parallelizable: List of features that can run with primary
        - deferred: List of features that cannot parallelize (with reason)
        - analysis: Summary of parallelization analysis
    """
    session = get_session()
    try:
        # Get all pending features ordered by priority
        pending = (
            session.query(Feature)
            .filter(Feature.passes == False, Feature.in_progress == False)
            .order_by(Feature.priority.asc(), Feature.id.asc())
            .all()
        )

        if len(pending) == 0:
            return json.dumps({
                "error": "No pending features found",
                "primary": None,
                "parallelizable": [],
                "deferred": []
            })

        # Primary feature is highest priority
        primary = pending[0]

        # Check if primary is in a critical category
        if primary.category.upper() in CRITICAL_CATEGORIES:
            return json.dumps({
                "primary": primary.to_dict(),
                "parallelizable": [],
                "deferred": [
                    {"feature": f.to_dict(), "reason": f"Primary feature is critical category ({primary.category})"}
                    for f in pending[1:]
                ],
                "analysis": {
                    "primary_category": primary.category,
                    "is_critical": True,
                    "message": f"Category {primary.category} (Security/Payment) requires exclusive execution"
                }
            }, indent=2)

        # Find features that can parallelize with primary
        parallelizable = []
        deferred = []

        for feature in pending[1:]:
            if len(parallelizable) >= limit - 1:
                deferred.append({
                    "feature": feature.to_dict(),
                    "reason": "Limit reached"
                })
                continue

            cat = feature.category.upper()

            # Critical categories never parallelize
            if cat in CRITICAL_CATEGORIES:
                deferred.append({
                    "feature": feature.to_dict(),
                    "reason": f"Critical category ({cat}) cannot parallelize"
                })
                continue

            # Check if can parallelize with primary
            if not can_parallelize_categories(primary.category, cat):
                deferred.append({
                    "feature": feature.to_dict(),
                    "reason": f"Category {cat} may conflict with primary category {primary.category}"
                })
                continue

            # Check if can parallelize with already selected features
            can_add = True
            for selected in parallelizable:
                if not can_parallelize_categories(selected.category, cat):
                    can_add = False
                    deferred.append({
                        "feature": feature.to_dict(),
                        "reason": f"Category {cat} may conflict with already selected category {selected.category}"
                    })
                    break

            if can_add:
                parallelizable.append(feature)

        return json.dumps({
            "primary": primary.to_dict(),
            "parallelizable": [f.to_dict() for f in parallelizable],
            "deferred": deferred,
            "analysis": {
                "primary_category": primary.category,
                "is_critical": False,
                "total_pending": len(pending),
                "can_parallelize": len(parallelizable),
                "deferred_count": len(deferred),
                "categories_selected": [primary.category] + [f.category for f in parallelizable]
            }
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_create_parallel_group(
    feature_ids: Annotated[list[int], Field(description="List of feature IDs to include in the parallel group")],
    session_id: Annotated[str, Field(description="Session ID of the parent session creating this group")]
) -> str:
    """Create a parallel execution group for multiple features.

    Groups features together for coordinated parallel execution.
    All features are marked as in_progress and assigned to the group.

    Use this after feature_get_parallelizable to create a dispatch group.

    Args:
        feature_ids: List of feature IDs to include (must all be pending)
        session_id: Parent session ID for tracking

    Returns:
        JSON with:
        - group: ParallelGroup dict with id and details
        - features: List of feature dicts that were assigned
        - error: Error message if any features couldn't be assigned
    """
    session = get_session()
    try:
        if not feature_ids:
            return json.dumps({"error": "No feature IDs provided"})

        # Verify all features exist and are pending
        features = []
        errors = []
        for fid in feature_ids:
            feature = session.query(Feature).filter(Feature.id == fid).first()
            if feature is None:
                errors.append(f"Feature {fid} not found")
            elif feature.passes:
                errors.append(f"Feature {fid} is already passing")
            elif feature.in_progress:
                errors.append(f"Feature {fid} is already in progress")
            elif feature.parallel_group_id is not None:
                errors.append(f"Feature {fid} is already in a parallel group")
            else:
                features.append(feature)

        if errors:
            return json.dumps({"error": "Some features could not be assigned", "details": errors})

        # Create the parallel group
        group = ParallelGroup(
            parent_session=session_id,
            started_at=datetime.utcnow(),
            status="active",
            regression_status="pending"
        )
        session.add(group)
        session.flush()  # Get the group ID

        # Assign features to the group
        for feature in features:
            feature.parallel_group_id = group.id
            feature.dispatched_by = session_id
            feature.dispatched_at = datetime.utcnow()
            feature.in_progress = True

        session.commit()

        # Refresh to get updated data
        session.refresh(group)
        for f in features:
            session.refresh(f)

        return json.dumps({
            "group": group.to_dict(),
            "features": [f.to_dict() for f in features]
        }, indent=2)
    except Exception as e:
        session.rollback()
        return json.dumps({"error": str(e)})
    finally:
        session.close()


@mcp.tool()
def feature_get_parallel_status(
    group_id: Annotated[int, Field(description="ID of the parallel group to check", ge=1)]
) -> str:
    """Get the status of a parallel execution group.

    Returns detailed status of all features in a parallel group,
    including completion status and regression test status.

    Use this to monitor progress of dispatched parallel work.

    Args:
        group_id: ID of the parallel group to check

    Returns:
        JSON with:
        - group: ParallelGroup dict
        - features: List of feature dicts with current status
        - summary: Completion summary (total, passing, in_progress, pending)
        - is_complete: True if all features are passing
    """
    session = get_session()
    try:
        group = session.query(ParallelGroup).filter(ParallelGroup.id == group_id).first()

        if group is None:
            return json.dumps({"error": f"Parallel group {group_id} not found"})

        features = (
            session.query(Feature)
            .filter(Feature.parallel_group_id == group_id)
            .order_by(Feature.priority.asc())
            .all()
        )

        passing = sum(1 for f in features if f.passes)
        in_progress = sum(1 for f in features if f.in_progress and not f.passes)
        total = len(features)
        is_complete = passing == total and total > 0

        # Update group status if complete
        if is_complete and group.status == "active":
            group.status = "completed"
            session.commit()
            session.refresh(group)

        return json.dumps({
            "group": group.to_dict(),
            "features": [f.to_dict() for f in features],
            "summary": {
                "total": total,
                "passing": passing,
                "in_progress": in_progress,
                "remaining": total - passing
            },
            "is_complete": is_complete
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_complete_parallel_group(
    group_id: Annotated[int, Field(description="ID of the parallel group to complete", ge=1)],
    regression_passed: Annotated[bool, Field(description="Whether regression tests passed")] = True
) -> str:
    """Mark a parallel group as completed after all features are done.

    Updates the group status and regression status. Should be called
    after all features in the group are passing and regression tests
    have been run.

    Args:
        group_id: ID of the parallel group
        regression_passed: Whether regression tests passed (default True)

    Returns:
        JSON with updated group details
    """
    session = get_session()
    try:
        group = session.query(ParallelGroup).filter(ParallelGroup.id == group_id).first()

        if group is None:
            return json.dumps({"error": f"Parallel group {group_id} not found"})

        # Update status
        group.status = "completed"
        group.regression_status = "passed" if regression_passed else "failed"
        session.commit()
        session.refresh(group)

        return json.dumps({
            "group": group.to_dict(),
            "message": f"Parallel group {group_id} marked as completed"
        }, indent=2)
    finally:
        session.close()


@mcp.tool()
def feature_abort_parallel_group(
    group_id: Annotated[int, Field(description="ID of the parallel group to abort", ge=1)]
) -> str:
    """Abort a parallel group and release all features.

    Marks the group as aborted and clears the in_progress status
    of all features, returning them to the pending queue.

    Use this when parallel execution needs to be cancelled.

    Args:
        group_id: ID of the parallel group to abort

    Returns:
        JSON with abort details and released features
    """
    session = get_session()
    try:
        group = session.query(ParallelGroup).filter(ParallelGroup.id == group_id).first()

        if group is None:
            return json.dumps({"error": f"Parallel group {group_id} not found"})

        if group.status != "active":
            return json.dumps({"error": f"Parallel group {group_id} is not active (status: {group.status})"})

        # Get all features in the group
        features = (
            session.query(Feature)
            .filter(Feature.parallel_group_id == group_id)
            .all()
        )

        # Release features that aren't passing
        released = []
        for feature in features:
            if not feature.passes:
                feature.in_progress = False
                feature.parallel_group_id = None
                feature.dispatched_by = None
                feature.dispatched_at = None
                released.append(feature.id)

        # Mark group as aborted
        group.status = "aborted"
        session.commit()
        session.refresh(group)

        return json.dumps({
            "group": group.to_dict(),
            "released_features": released,
            "message": f"Parallel group {group_id} aborted, {len(released)} features released"
        }, indent=2)
    finally:
        session.close()


if __name__ == "__main__":
    mcp.run()
