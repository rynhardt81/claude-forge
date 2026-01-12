"""
Database Models and Connection
==============================

SQLite database schema for feature storage using SQLAlchemy.

Database Location:
- Default: {PROJECT_DIR}/features.db
- Recommended: {project_root}/.claude/features/features.db

Version History:
- v1.0: Initial schema with Feature table
- v1.1: Added ParallelGroup table for dispatch coordination
"""

from datetime import datetime
from pathlib import Path
from typing import Optional

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session, relationship, sessionmaker
from sqlalchemy.types import JSON

Base = declarative_base()


# Category Parallelization Matrix
# Maps category pairs to parallelization safety
# True = safe to parallelize, False = not safe, None = check scope
CATEGORY_PARALLELIZATION_MATRIX = {
    # Critical categories - never parallelize
    "A": {},  # Security - never parallelize with anything
    "P": {},  # Payment - never parallelize with anything

    # Safe parallelization mappings (symmetric)
    # Format: category -> set of categories safe to parallelize with
    "B": {"H", "I", "K", "M", "Q", "S", "T"},
    "C": {"H", "I", "K", "Q", "S", "T"},
    "D": {"I", "K", "Q", "S", "T"},
    "E": {"H", "I", "K", "M", "Q", "S", "T"},
    "F": {"H", "I", "J", "K", "L", "M", "O", "Q", "S"},
    "G": {"H", "I", "J", "K", "L", "M", "O", "Q", "S", "T"},
    "H": {"B", "C", "E", "F", "G", "I", "J", "K", "L", "M", "N", "O", "Q", "R", "S", "T"},
    "I": {"B", "C", "D", "E", "F", "G", "H", "J", "K", "M", "N", "O", "Q", "R", "S", "T"},
    "J": {"F", "G", "H", "I", "K", "M", "N", "R", "S", "T"},
    "K": {"B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N", "O", "Q", "R", "S", "T"},
    "L": {"F", "G", "H", "K", "M", "N", "O", "Q", "R", "S", "T"},
    "M": {"B", "E", "F", "G", "H", "I", "J", "K", "L", "N", "O", "Q", "R", "S", "T"},
    "N": {"H", "I", "J", "K", "L", "M", "O", "Q", "S"},
    "O": {"F", "G", "H", "I", "K", "L", "M", "N", "Q", "R", "S", "T"},
    "Q": {"B", "C", "D", "E", "F", "G", "H", "I", "K", "L", "M", "N", "O", "R", "S", "T"},
    "R": {"H", "I", "J", "K", "L", "M", "O", "Q", "S", "T"},
    "S": {"B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "Q", "R", "T"},
    "T": {"B", "C", "D", "E", "G", "H", "I", "J", "K", "L", "M", "O", "Q", "R", "S"},
}

# Critical categories that should never be parallelized
CRITICAL_CATEGORIES = {"A", "P"}


class Feature(Base):
    """Feature model representing a testable feature to implement.

    Attributes:
        id: Primary key, auto-incrementing
        priority: Lower number = higher priority (1 is highest)
        category: Single letter A-T mapping to feature category
        name: Short descriptive name
        description: Detailed description of what the feature does
        steps: JSON array of test/implementation steps
        passes: True when feature is implemented and verified
        in_progress: True when an agent is actively working on this feature

    Categories (A-T):
        A: Security & Authentication
        B: Navigation & Routing
        C: Data Management (CRUD)
        D: Workflow & User Actions
        E: Forms & Input Validation
        F: Display & List Views
        G: Search & Filtering
        H: Notifications & Alerts
        I: Settings & Configuration
        J: Integration & APIs
        K: Analytics & Reporting
        L: Admin & Management
        M: Performance & Caching
        N: Accessibility (a11y)
        O: Error Handling
        P: Payment & Billing
        Q: Communication (Email/SMS)
        R: Media & File Handling
        S: Documentation & Help
        T: UI Polish & Animations
    """

    __tablename__ = "features"

    id = Column(Integer, primary_key=True, index=True)
    priority = Column(Integer, nullable=False, default=999, index=True)
    category = Column(String(100), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    steps = Column(JSON, nullable=False)  # Stored as JSON array
    passes = Column(Boolean, default=False, index=True)
    in_progress = Column(Boolean, default=False, index=True)

    # Dispatch tracking fields (added in v1.1)
    parallel_group_id = Column(Integer, ForeignKey("parallel_groups.id"), nullable=True)
    dispatched_by = Column(String(100), nullable=True)  # Session ID that dispatched this
    dispatched_at = Column(DateTime, nullable=True)

    # Relationship to parallel group
    parallel_group = relationship("ParallelGroup", back_populates="features")

    def to_dict(self) -> dict:
        """Convert feature to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "priority": self.priority,
            "category": self.category,
            "name": self.name,
            "description": self.description,
            "steps": self.steps,
            "passes": self.passes,
            "in_progress": self.in_progress,
            "parallel_group_id": self.parallel_group_id,
            "dispatched_by": self.dispatched_by,
            "dispatched_at": self.dispatched_at.isoformat() if self.dispatched_at else None,
        }


class ParallelGroup(Base):
    """ParallelGroup model for coordinating parallel feature execution.

    Attributes:
        id: Primary key, auto-incrementing
        parent_session: Session ID that created this group
        started_at: When the parallel execution started
        status: Group status (active, completed, aborted)
        regression_status: Status of regression testing (pending, running, passed, failed)
    """

    __tablename__ = "parallel_groups"

    id = Column(Integer, primary_key=True, index=True)
    parent_session = Column(String(100), nullable=False)
    started_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    status = Column(String(20), nullable=False, default="active")  # active, completed, aborted
    regression_status = Column(String(20), nullable=False, default="pending")  # pending, running, passed, failed

    # Relationship to features
    features = relationship("Feature", back_populates="parallel_group")

    def to_dict(self) -> dict:
        """Convert parallel group to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "parent_session": self.parent_session,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "status": self.status,
            "regression_status": self.regression_status,
            "feature_ids": [f.id for f in self.features] if self.features else [],
            "feature_count": len(self.features) if self.features else 0,
        }


def can_parallelize_categories(cat1: str, cat2: str) -> bool:
    """Check if two feature categories can be safely parallelized.

    Args:
        cat1: First category code (A-T)
        cat2: Second category code (A-T)

    Returns:
        True if the categories can be parallelized, False otherwise.
    """
    cat1, cat2 = cat1.upper(), cat2.upper()

    # Critical categories never parallelize
    if cat1 in CRITICAL_CATEGORIES or cat2 in CRITICAL_CATEGORIES:
        return False

    # Same category never parallelize (likely share files)
    if cat1 == cat2:
        return False

    # Check the matrix (symmetric check)
    safe_for_cat1 = CATEGORY_PARALLELIZATION_MATRIX.get(cat1, set())
    return cat2 in safe_for_cat1


def get_database_path(project_dir: Path) -> Path:
    """Return the path to the SQLite database for a project."""
    return project_dir / "features.db"


def get_database_url(project_dir: Path) -> str:
    """Return the SQLAlchemy database URL for a project.

    Uses POSIX-style paths (forward slashes) for cross-platform compatibility.
    """
    db_path = get_database_path(project_dir)
    return f"sqlite:///{db_path.as_posix()}"


def _migrate_database(engine) -> None:
    """Apply all database migrations for backward compatibility."""
    from sqlalchemy import text

    with engine.connect() as conn:
        # Get existing columns in features table
        result = conn.execute(text("PRAGMA table_info(features)"))
        feature_columns = [row[1] for row in result.fetchall()]

        # Migration v1.0 -> v1.1: Add in_progress column
        if "in_progress" not in feature_columns:
            conn.execute(text("ALTER TABLE features ADD COLUMN in_progress BOOLEAN DEFAULT 0"))
            conn.commit()

        # Migration v1.1: Add dispatch tracking columns to features
        if "parallel_group_id" not in feature_columns:
            conn.execute(text("ALTER TABLE features ADD COLUMN parallel_group_id INTEGER"))
            conn.commit()

        if "dispatched_by" not in feature_columns:
            conn.execute(text("ALTER TABLE features ADD COLUMN dispatched_by VARCHAR(100)"))
            conn.commit()

        if "dispatched_at" not in feature_columns:
            conn.execute(text("ALTER TABLE features ADD COLUMN dispatched_at DATETIME"))
            conn.commit()

        # Check if parallel_groups table exists
        result = conn.execute(text(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='parallel_groups'"
        ))
        if result.fetchone() is None:
            # Create parallel_groups table
            conn.execute(text("""
                CREATE TABLE parallel_groups (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    parent_session VARCHAR(100) NOT NULL,
                    started_at DATETIME NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'active',
                    regression_status VARCHAR(20) NOT NULL DEFAULT 'pending'
                )
            """))
            conn.commit()


def create_database(project_dir: Path) -> tuple:
    """
    Create database and return engine + session maker.

    Args:
        project_dir: Directory where features.db will be created

    Returns:
        Tuple of (engine, SessionLocal)
    """
    db_url = get_database_url(project_dir)
    engine = create_engine(db_url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)

    # Apply all migrations for backward compatibility
    _migrate_database(engine)

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return engine, SessionLocal


# Global session maker - will be set when server starts
_session_maker: Optional[sessionmaker] = None


def set_session_maker(session_maker: sessionmaker) -> None:
    """Set the global session maker."""
    global _session_maker
    _session_maker = session_maker


def get_db() -> Session:
    """
    Get a database session.

    Yields a database session and ensures it's closed after use.
    """
    if _session_maker is None:
        raise RuntimeError("Database not initialized. Call set_session_maker first.")

    db = _session_maker()
    try:
        yield db
    finally:
        db.close()
