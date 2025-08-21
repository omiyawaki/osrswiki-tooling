#!/bin/bash

# Autonomous MapLibre Test Runner
# Runs comprehensive MapLibre functionality test without requiring manual intervention

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🤖 Autonomous MapLibre Test Runner"
echo "=================================="
echo "📂 Project: $PROJECT_ROOT"
echo ""

cd "$PROJECT_ROOT/platforms/ios"

# Build the project
echo "🔨 Building iOS project..."
if xcodebuild -project osrswiki.xcodeproj -scheme osrswiki -destination 'platform=iOS Simulator,name=iPhone 16' -quiet build; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🤖 Running autonomous MapLibre test..."
echo "======================================"

# Run the autonomous test
TEST_OUTPUT=$(xcodebuild test \
    -project osrswiki.xcodeproj \
    -scheme osrswiki \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:osrswikiTests/AutonomousMapLibreTest/testMapLibreEndToEndAutonomous \
    2>&1)

echo ""
echo "📊 Autonomous Test Results:"
echo "============================"

# Extract the test results section
if echo "$TEST_OUTPUT" | grep -q "AUTONOMOUS MAPLIBRE TEST RESULTS"; then
    echo "$TEST_OUTPUT" | awk '/AUTONOMOUS MAPLIBRE TEST RESULTS/,/======================================$/'
else
    echo "No autonomous test results found in output"
fi

echo ""
echo "🎯 Final Assessment:"
echo "===================="

# Check if test passed
if echo "$TEST_OUTPUT" | grep -q "Test Case.*testMapLibreEndToEndAutonomous.*passed"; then
    echo "🎉 AUTONOMOUS TEST: PASSED"
    
    # Check if MapLibre functionality is working
    if echo "$TEST_OUTPUT" | grep -q "AUTONOMOUS_TEST: OVERALL: PASS"; then
        echo "🗺️ MAPLIBRE STATUS: WORKING"
        echo ""
        echo "✅ MapLibre bridge is functioning correctly"
        echo "   - External JS file loads successfully"
        echo "   - Bridge object is created"
        echo "   - All required methods are available"
        echo "   - JavaScript-to-Swift communication works"
        exit 0
    else
        echo "🗺️ MAPLIBRE STATUS: NOT WORKING"
        echo ""
        echo "❌ MapLibre bridge has issues:"
        # Extract specific failure reasons
        echo "$TEST_OUTPUT" | grep "AUTONOMOUS_TEST:" | grep -E "(❌|missing|failed|not available)" || echo "   - Check test output for details"
        exit 1
    fi
else
    echo "❌ AUTONOMOUS TEST: FAILED"
    echo ""
    echo "Test execution failed. Error details:"
    echo "$TEST_OUTPUT" | grep -E "error:|failed:|Error" | head -10
    exit 1
fi