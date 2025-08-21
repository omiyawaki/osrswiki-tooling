#!/bin/bash
set -euo pipefail

# iOS Simulator session cleanup - equivalent to Android cleanup-session-device.sh
# Safely cleans up ONLY the simulator created by the current session
# CRITICAL: Only deletes simulators with session naming pattern for safety

echo "🧹 Cleaning up iOS Simulator session..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_DIR="${SESSION_DIR:-$(pwd)}"

# Load session environment if available
if [[ -f .claude-env ]]; then
    source .claude-env
    echo "📱 Loaded session environment"
    echo "   • Simulator: ${SIMULATOR_NAME:-unknown}"
    echo "   • UDID: ${IOS_SIMULATOR_UDID:-unknown}"
elif [[ -f .claude-session-simulator ]]; then
    echo "📱 Found legacy session format"
    SESSION_INFO=$(cat .claude-session-simulator)
    SIMULATOR_NAME=$(echo "$SESSION_INFO" | cut -d: -f1)
    IOS_SIMULATOR_UDID=$(echo "$SESSION_INFO" | cut -d: -f2)
    echo "   • Simulator: $SIMULATOR_NAME"
    echo "   • UDID: $IOS_SIMULATOR_UDID"
else
    echo "⚠️  No session information found"
    echo "💡 Specify simulator name and UDID manually:"
    echo "   $0 <simulator-name> <udid>"
    
    if [[ $# -eq 2 ]]; then
        SIMULATOR_NAME="$1"
        IOS_SIMULATOR_UDID="$2"
        echo "📱 Using provided parameters:"
        echo "   • Simulator: $SIMULATOR_NAME"
        echo "   • UDID: $IOS_SIMULATOR_UDID"
    else
        echo "❌ No session or parameters provided"
        echo "✅ This is normal if no iOS simulator was created for this session"
        exit 0
    fi
fi

# Ensure we're on macOS (required for iOS development)
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ iOS development requires macOS. Current platform: $(uname)"
    exit 1
fi

# Skip cleanup if no simulator was set
if [[ -z "${IOS_SIMULATOR_UDID:-}" ]]; then
    echo "✅ No session simulator found (IOS_SIMULATOR_UDID not set)"
    echo "   This is normal if no iOS simulator was created for this session"
    echo "   Proceeding with session file cleanup only..."
else
    # Verify the simulator exists and get its info
    SIMULATOR_INFO=$(xcrun simctl list devices | grep "$IOS_SIMULATOR_UDID" || true)
    if [[ -z "$SIMULATOR_INFO" ]]; then
        echo "✅ Simulator already cleaned up (not found in device list)"
        echo "   UDID: $IOS_SIMULATOR_UDID"
    else
        echo "📱 Found simulator: $SIMULATOR_INFO"
        
        # CRITICAL SAFETY CHECK: Only delete simulators with session naming pattern
        ACTUAL_SIMULATOR_NAME=$(echo "$SIMULATOR_INFO" | sed -n 's/.*\(osrswiki-claude-[0-9]\{8\}-[0-9]\{6\}-.*\).*/\1/p')
        if [[ -z "$ACTUAL_SIMULATOR_NAME" ]]; then
            echo "🚨 SAFETY VIOLATION: Simulator does not match session naming pattern"
            echo "   Expected pattern: osrswiki-claude-YYYYMMDD-HHMMSS-*"
            echo "   Found: $SIMULATOR_INFO"
            echo "   Refusing to delete - this may be a system or shared simulator"
            echo "⚠️  Manual cleanup required if this simulator was actually created by this session"
        else
            echo "✅ Safety check passed - simulator matches session pattern: $ACTUAL_SIMULATOR_NAME"
            
            # Shutdown simulator if running
            echo "🛑 Shutting down simulator..."
            xcrun simctl shutdown "$IOS_SIMULATOR_UDID" 2>/dev/null || true
            
            # Delete the session-specific simulator
            echo "🗑️  Deleting session simulator: $ACTUAL_SIMULATOR_NAME"
            if xcrun simctl delete "$IOS_SIMULATOR_UDID"; then
                echo "✅ Session simulator deleted successfully"
                echo "   UDID: $IOS_SIMULATOR_UDID"
                echo "   Name: $ACTUAL_SIMULATOR_NAME"
            else
                echo "❌ Failed to delete simulator"
                echo "💡 Try manually: xcrun simctl delete $IOS_SIMULATOR_UDID"
            fi
        fi
    fi
fi

# Clean up session files
echo "🧹 Cleaning session files..."

# Remove session files
files_to_remove=(
    ".claude-session-simulator"
    ".claude-simulator-udid" 
    ".claude-simulator-name"
    ".claude-bundle-id"
    ".claude-env"
)

for file in "${files_to_remove[@]}"; do
    if [[ -f "$file" ]]; then
        rm "$file"
        echo "   • Removed $file"
    fi
done

# Clean up screenshots directory (optional, with confirmation)
if [[ -d "screenshots" ]] && [[ -n "$(ls -A screenshots 2>/dev/null)" ]]; then
    echo ""
    echo "📸 Screenshots directory contains files:"
    ls -la screenshots/ | head -5
    
    if [[ "${AUTO_CLEAN_SCREENSHOTS:-}" == "true" ]]; then
        echo "🧹 Auto-cleaning screenshots..."
        rm -rf screenshots/
        echo "   • Screenshots directory removed"
    else
        echo "💡 To clean screenshots: rm -rf screenshots/"
        echo "💡 Or set AUTO_CLEAN_SCREENSHOTS=true for automatic cleanup"
    fi
fi

# Clean up any derived data or build artifacts
echo "🧹 Cleaning iOS build artifacts..."
if [[ -d "platforms/ios/build" ]]; then
    rm -rf "platforms/ios/build"
    echo "   • Removed iOS build directory"
fi

if [[ -d "platforms/ios/DerivedData" ]]; then
    rm -rf "platforms/ios/DerivedData"
    echo "   • Removed DerivedData directory"
fi

echo ""
echo "✅ iOS Simulator session cleanup complete!"
echo ""
echo "💡 The simulator has been deleted and session files cleaned up."
echo "💡 To start a new session: ./scripts/ios/setup-session-simulator.sh"