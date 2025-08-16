#!/bin/bash
set -euo pipefail

# Session simulator cleanup wrapper script
# This script wraps the actual iOS simulator cleanup for consistency with session workflow

echo "🔄 Redirecting to iOS simulator cleanup script..."

# Check if we're in a worktree session directory
if [[ ! -f .claude-session-simulator ]] && [[ ! -f .claude-env ]]; then
    echo "❌ Error: This doesn't appear to be a session directory"
    echo "Expected to find .claude-session-simulator or .claude-env file"
    exit 1
fi

# Call the actual iOS cleanup script with any passed arguments
exec ../ios/cleanup-session-simulator.sh "$@"