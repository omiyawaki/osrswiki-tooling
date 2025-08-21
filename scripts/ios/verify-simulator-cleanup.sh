#!/bin/bash
set -euo pipefail

# iOS Simulator Cleanup Verification Script
# Verifies that session-specific simulator was properly cleaned up
# Returns exit code 0 if cleanup was successful, 1 if issues found

echo "🔍 Verifying iOS simulator cleanup..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_DIR="${SESSION_DIR:-$(pwd)}"

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "✅ iOS verification skipped - not on macOS"
    exit 0
fi

# Load session environment if available to check what should have been cleaned
CLAUDE_ENV_FILE="$SESSION_DIR/.claude-env"
EXPECTED_SIMULATOR_UDID=""
EXPECTED_SIMULATOR_NAME=""

if [[ -f "$CLAUDE_ENV_FILE" ]]; then
    # Check if IOS_SIMULATOR_UDID is still in .claude-env (bad)
    if grep -q "IOS_SIMULATOR_UDID" "$CLAUDE_ENV_FILE"; then
        EXPECTED_SIMULATOR_UDID=$(grep "IOS_SIMULATOR_UDID" "$CLAUDE_ENV_FILE" | cut -d= -f2 | tr -d '"' | tr -d "'" || true)
        echo "⚠️  Found simulator reference in .claude-env: $EXPECTED_SIMULATOR_UDID"
        
        # Check if this simulator still exists
        if xcrun simctl list devices | grep -q "$EXPECTED_SIMULATOR_UDID"; then
            SIMULATOR_INFO=$(xcrun simctl list devices | grep "$EXPECTED_SIMULATOR_UDID")
            echo "❌ CLEANUP FAILED: Simulator still exists"
            echo "   $SIMULATOR_INFO"
            echo ""
            echo "🛠️  To fix this issue:"
            echo "   xcrun simctl delete $EXPECTED_SIMULATOR_UDID"
            echo "   sed -i '' '/IOS_SIMULATOR_UDID/d' '$CLAUDE_ENV_FILE'"
            exit 1
        else
            echo "✅ Simulator was deleted but .claude-env not cleaned"
            echo "🛠️  Cleaning up .claude-env reference..."
            sed -i '' '/IOS_SIMULATOR_UDID/d' "$CLAUDE_ENV_FILE" || true
            echo "✅ Fixed .claude-env file"
        fi
    else
        echo "✅ No simulator references found in .claude-env"
    fi
elif [[ -f "$SESSION_DIR/.claude-session-simulator" ]]; then
    # Legacy format check
    SESSION_INFO=$(cat "$SESSION_DIR/.claude-session-simulator")
    EXPECTED_SIMULATOR_UDID=$(echo "$SESSION_INFO" | cut -d: -f2)
    echo "⚠️  Found legacy session file with simulator: $EXPECTED_SIMULATOR_UDID"
    
    if xcrun simctl list devices | grep -q "$EXPECTED_SIMULATOR_UDID"; then
        SIMULATOR_INFO=$(xcrun simctl list devices | grep "$EXPECTED_SIMULATOR_UDID")
        echo "❌ CLEANUP FAILED: Legacy simulator still exists"
        echo "   $SIMULATOR_INFO"
        echo ""
        echo "🛠️  To fix this issue:"
        echo "   xcrun simctl delete $EXPECTED_SIMULATOR_UDID"
        echo "   rm '$SESSION_DIR/.claude-session-simulator'"
        exit 1
    else
        echo "✅ Legacy simulator was deleted"
    fi
else
    echo "✅ No session simulator configuration found"
fi

# Check for any orphaned simulators with session naming pattern
echo "🔍 Checking for orphaned session simulators..."
ORPHANED_SIMS=$(xcrun simctl list devices | grep -E "osrswiki-claude-[0-9]{8}-[0-9]{6}-" || true)

if [[ -n "$ORPHANED_SIMS" ]]; then
    echo "⚠️  Found potential orphaned session simulators:"
    echo "$ORPHANED_SIMS"
    echo ""
    echo "💡 These may be from other active sessions or improperly cleaned sessions"
    echo "💡 Only clean up simulators you created in your current session"
    echo "💡 Run 'xcrun simctl list devices | grep osrswiki-claude' to see all session simulators"
else
    echo "✅ No orphaned session simulators found"
fi

# Verify session files were cleaned up
echo "🔍 Checking session file cleanup..."
SESSION_FILES_REMAINING=()

# List of files that should be cleaned up
session_files=(
    ".claude-session-simulator"
    ".claude-simulator-udid" 
    ".claude-simulator-name"
)

for file in "${session_files[@]}"; do
    if [[ -f "$SESSION_DIR/$file" ]]; then
        SESSION_FILES_REMAINING+=("$file")
    fi
done

if [[ ${#SESSION_FILES_REMAINING[@]} -gt 0 ]]; then
    echo "❌ Session files not cleaned up:"
    for file in "${SESSION_FILES_REMAINING[@]}"; do
        echo "   • $file"
    done
    echo ""
    echo "🛠️  To fix this issue:"
    for file in "${SESSION_FILES_REMAINING[@]}"; do
        echo "   rm '$SESSION_DIR/$file'"
    done
    exit 1
else
    echo "✅ Session files properly cleaned up"
fi

echo ""
echo "🎉 iOS simulator cleanup verification passed!"
echo "   • No session simulators found running"
echo "   • Session configuration files cleaned"
echo "   • Environment variables cleaned"