#!/bin/bash
#
# Quick Map Tab Testing - Solves Navigation Bottleneck
# One-command solution for agents to test map changes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load environment if not already loaded
if [[ -z "$IOS_SIMULATOR_UDID" ]] && [[ -f "$PROJECT_ROOT/.claude-env" ]]; then
    echo "🔧 Loading session environment..."
    source "$PROJECT_ROOT/.claude-env"
fi

if [[ -z "$IOS_SIMULATOR_UDID" ]]; then
    echo "❌ IOS_SIMULATOR_UDID not set. Run 'source .claude-env' first"
    exit 1
fi

echo "🚀 Quick Map Tab Test - One Command Solution"
echo "=================================================="

# Step 1: Build app (only if needed)
echo "📦 Building app..."
cd "$PROJECT_ROOT/platforms/ios"
xcodebuild -project OSRSWiki.xcodeproj -scheme osrswiki -configuration Debug -sdk iphonesimulator build -quiet

# Step 2: Install app
echo "📱 Installing app..."
APP_PATH="/Users/miyawaki/Library/Developer/Xcode/DerivedData/osrswiki-cskhdpsvlgbcldbdpvonzrfibmvb/Build/Products/Debug-iphonesimulator/osrswiki.app"
xcrun simctl install "$IOS_SIMULATOR_UDID" "$APP_PATH"

# Step 3: Launch directly to map tab using our new launch arguments
echo "🗺️  Launching directly to Map tab..."
xcrun simctl terminate "$IOS_SIMULATOR_UDID" "omiyawaki.osrswiki" 2>/dev/null || true
xcrun simctl launch "$IOS_SIMULATOR_UDID" "omiyawaki.osrswiki" -startTab map

# Step 4: Wait for app to be ready
sleep 4

# Step 5: Take screenshot
echo "📸 Taking screenshot of map tab..."
cd "$PROJECT_ROOT"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
"$SCRIPT_DIR/take-screenshot.sh" "map-tab-auto-${TIMESTAMP}"

echo ""
echo "✅ SUCCESS! Map tab is now open and screenshot taken."
echo ""
echo "🎯 What to verify:"
echo "   • No 'OSRS Map' title at the top"
echo "   • Floor selector positioned at top-left" 
echo "   • Compass positioned at top-right"
echo "   • Both controls aligned where title used to be"
echo ""
echo "📁 Screenshot saved in: screenshots/"
echo ""
echo "🤖 Agent Note: You can now visually inspect the map changes!"