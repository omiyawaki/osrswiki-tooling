#!/bin/bash
set -euo pipefail

# iOS quick build and test - equivalent to Android quick-test.sh
# Builds the app and deploys to iOS Simulator for rapid development iterations

# Auto-source session environment to avoid command substitution and permission issues
if [[ -f .claude-env ]]; then
    source .claude-env
elif [[ -f .claude-session-simulator ]]; then
    echo "❌ Old session format. Please recreate session to use improved environment handling."
    exit 1
else
    echo "❌ No active iOS session. Run ./scripts/ios/setup-session-simulator.sh first"
    exit 1
fi

# Verify required environment variables
if [[ -z "${IOS_SIMULATOR_UDID:-}" ]]; then
    echo "❌ IOS_SIMULATOR_UDID not set. Please run: source .claude-env"
    exit 1
fi

if [[ -z "${BUNDLE_ID:-}" ]]; then
    echo "❌ BUNDLE_ID not set. Please run: source .claude-env"
    exit 1
fi

echo "🔨 Quick iOS build and test on simulator: $SIMULATOR_NAME"
echo "📱 Device UDID: $IOS_SIMULATOR_UDID"
echo ""
echo "💡 For UI testing and navigation, see:"
echo "   Apple XCTest Documentation: https://developer.apple.com/documentation/xctest"
echo "   UI Testing Guide: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html"
echo ""

# Ensure we're on macOS (required for iOS development)
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ iOS development requires macOS. Current platform: $(uname)"
    exit 1
fi

# Check if simulator is still running
SIMULATOR_STATUS=$(xcrun simctl list devices | grep "$IOS_SIMULATOR_UDID" | grep -o "Booted\|Shutdown" || echo "Unknown")
if [[ "$SIMULATOR_STATUS" != "Booted" ]]; then
    echo "⚠️  Simulator not booted. Attempting to boot..."
    xcrun simctl boot "$IOS_SIMULATOR_UDID" >/dev/null 2>&1 || true
    sleep 3
    
    # Check again
    SIMULATOR_STATUS=$(xcrun simctl list devices | grep "$IOS_SIMULATOR_UDID" | grep -o "Booted\|Shutdown" || echo "Unknown")
    if [[ "$SIMULATOR_STATUS" != "Booted" ]]; then
        echo "❌ Could not boot simulator. Status: $SIMULATOR_STATUS"
        echo "💡 Try running: xcrun simctl boot $IOS_SIMULATOR_UDID"
        exit 1
    fi
fi

# Change to iOS project directory
cd platforms/ios

# Create controlled build directory
DERIVED_DATA_PATH="$(pwd)/build/DerivedData"
echo "🧹 Cleaning previous build..."
rm -rf build/ || true
mkdir -p build/

# Build the iOS app for simulator with controlled build path
echo "⚙️  Building iOS app to controlled location..."
echo "📁 Build path: $DERIVED_DATA_PATH"
xcodebuild \
    -project "osrswiki.xcodeproj" \
    -scheme "osrswiki" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,arch=arm64,id=$IOS_SIMULATOR_UDID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    build \
    -quiet

if [[ $? -ne 0 ]]; then
    echo "❌ Build failed!"
    echo "💡 Try opening Xcode and building manually to see detailed errors:"
    echo "   open 'platforms/ios/osrswiki.xcodeproj'"
    exit 1
fi

echo "✅ Build successful!"

# Use the exact app we just built (no search needed)
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/osrswiki.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "❌ Could not find built app at expected location: $APP_PATH"
    echo "💡 Build may have failed. Check Xcode for errors."
    exit 1
fi

echo "📦 Using app at: $APP_PATH"

# Install the app on simulator
echo "📲 Installing app on simulator..."
xcrun simctl install "$IOS_SIMULATOR_UDID" "$APP_PATH"

if [[ $? -ne 0 ]]; then
    echo "❌ Installation failed!"
    echo "💡 Check simulator status and try again"
    exit 1
fi

echo "✅ Installation successful!"

# Launch the app
echo "🚀 Launching app..."
xcrun simctl launch "$IOS_SIMULATOR_UDID" "$BUNDLE_ID"

if [[ $? -ne 0 ]]; then
    echo "⚠️  Launch may have failed, but app is installed"
    echo "💡 Try launching manually from simulator home screen"
else
    echo "✅ App launched successfully!"
fi

# Return to original directory
cd - > /dev/null

# Show simulator if not already visible
echo "📱 Bringing simulator to front..."
open -a Simulator > /dev/null 2>&1 || true

echo ""
echo "🎉 Quick test completed!"
echo "📱 App should now be running on $SIMULATOR_NAME"
echo ""
echo "💡 Tips:"
echo "   • Use Simulator menu for device controls"
echo "   • Cmd+Shift+H for home screen"  
echo "   • Take screenshot with: ./scripts/ios/take-screenshot.sh"
echo "   • Check logs with: xcrun simctl spawn $IOS_SIMULATOR_UDID log stream"