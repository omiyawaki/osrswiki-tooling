#!/bin/bash
set -euo pipefail

echo "🧹 Cleaning up worktree session..."

# Clean up worktree (remove this session directory)
CURRENT_DIR=$(pwd)
SESSION_NAME=$(basename "$CURRENT_DIR")

if [[ "$SESSION_NAME" =~ ^claude-[0-9]{8}-[0-9]{6} ]]; then
    echo "🗑️ Removing worktree session: $SESSION_NAME"
    
    # Go to parent directory (project root) and remove this worktree
    cd ..
    git worktree remove "$SESSION_NAME" --force
    
    echo "✅ Worktree cleanup complete"
    echo "📁 Returned to: $(pwd)"
else
    echo "⚠️ Not in a Claude session directory, skipping worktree cleanup"
    echo "Current directory: $CURRENT_DIR"
fi

echo "🧹 Worktree cleanup finished!"