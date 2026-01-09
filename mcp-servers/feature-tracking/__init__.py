"""
Feature Tracking MCP Server
===========================

MCP server for managing features in the autonomous development workflow.
"""

from .database import Feature, create_database, get_database_path
from .server import mcp

__all__ = ["mcp", "Feature", "create_database", "get_database_path"]
