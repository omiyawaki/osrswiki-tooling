#!/bin/bash

# Quantitative MapLibre Bridge Test Script
# Tests the bridge functionality without relying on screenshots

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧪 MapLibre Bridge Quantitative Test"
echo "=================================="
echo "📂 Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Source environment if available
if [[ -f ".claude-env" ]]; then
    source .claude-env
    echo "✅ Environment loaded"
else
    echo "⚠️  No .claude-env found, using defaults"
fi

# Check if we have the required files
echo ""
echo "🔍 Pre-flight checks:"
echo "=================================="

# Check if map_bridge.js exists
BRIDGE_FILE="platforms/ios/osrswiki/Assets/web/map_bridge.js"
if [[ -f "$BRIDGE_FILE" ]]; then
    echo "✅ map_bridge.js file exists"
    echo "   Size: $(wc -c < "$BRIDGE_FILE") bytes"
    echo "   Contains OsrsWikiBridge: $(grep -c "OsrsWikiBridge" "$BRIDGE_FILE" || echo "0")"
else
    echo "❌ map_bridge.js file missing at: $BRIDGE_FILE"
    exit 1
fi

# Check if native handler exists
NATIVE_HANDLER="platforms/ios/osrswiki/Services/osrsNativeMapHandler.swift"
if [[ -f "$NATIVE_HANDLER" ]]; then
    echo "✅ osrsNativeMapHandler.swift exists"
else
    echo "❌ Native map handler missing at: $NATIVE_HANDLER"
    exit 1
fi

# Check ArticleWebView configuration
ARTICLE_VIEW="platforms/ios/osrswiki/Views/ArticleWebView.swift"
if [[ -f "$ARTICLE_VIEW" ]]; then
    echo "✅ ArticleWebView.swift exists"
    
    # Check for key components
    if grep -q "mapBridge" "$ARTICLE_VIEW"; then
        echo "   ✅ mapBridge message handler registered"
    else
        echo "   ❌ mapBridge message handler not found"
    fi
    
    if grep -q "handleMapBridgeMessage" "$ARTICLE_VIEW"; then
        echo "   ✅ handleMapBridgeMessage function exists"
    else
        echo "   ❌ handleMapBridgeMessage function missing"
    fi
    
    if grep -q "setupMapHandler" "$ARTICLE_VIEW"; then
        echo "   ✅ setupMapHandler function exists"
    else
        echo "   ❌ setupMapHandler function missing"
    fi
    
    if grep -q "app-assets" "$ARTICLE_VIEW"; then
        echo "   ✅ WKURLSchemeHandler configured"
    else
        echo "   ❌ WKURLSchemeHandler not configured"
    fi
else
    echo "❌ ArticleWebView.swift missing"
    exit 1
fi

# Check HTML builder configuration
HTML_BUILDER="platforms/ios/osrswiki/Services/osrsPageHtmlBuilder.swift"
if [[ -f "$HTML_BUILDER" ]]; then
    echo "✅ osrsPageHtmlBuilder.swift exists"
    
    if grep -q "web/map_bridge.js" "$HTML_BUILDER"; then
        echo "   ✅ map_bridge.js referenced in HTML builder"
    else
        echo "   ⚠️  map_bridge.js not found in HTML builder (may use inline injection)"
    fi
else
    echo "❌ HTML builder missing"
    exit 1
fi

echo ""
echo "🔨 Building and running quantitative tests:"
echo "=================================="

# Build the project first
echo "Building iOS project..."
cd platforms/ios

if xcodebuild -project osrswiki.xcodeproj -scheme osrswiki -destination 'platform=iOS Simulator,name=iPhone 16' -quiet build; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Run the specific MapLibre bridge tests
echo ""
echo "Running MapLibre bridge tests..."

TEST_RESULTS=$(xcodebuild test \
    -project osrswiki.xcodeproj \
    -scheme osrswiki \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:osrswikiTests/MapLibreBridgeQuantitativeTest \
    2>&1 || true)

echo ""
echo "📊 Test Results:"
echo "=================================="

# Parse test results
if echo "$TEST_RESULTS" | grep -q "Test Suite 'MapLibreBridgeQuantitativeTest' passed"; then
    echo "🎉 Overall: PASSED"
    OVERALL_RESULT="PASS"
else
    echo "❌ Overall: FAILED"
    OVERALL_RESULT="FAIL"
fi

# Extract individual test results
echo ""
echo "Individual test results:"

# Test bridge initialization  
if echo "$TEST_RESULTS" | grep -q "testMapLibreBridgeInitialization.*passed"; then
    echo "✅ Bridge initialization: PASSED"
else
    echo "❌ Bridge initialization: FAILED"
fi

# Test asset loading
if echo "$TEST_RESULTS" | grep -q "testAssetLoading.*passed"; then
    echo "✅ Asset loading: PASSED"
else
    echo "❌ Asset loading: FAILED"
fi

# Test native handler
if echo "$TEST_RESULTS" | grep -q "testNativeMapHandlerInitialization.*passed"; then
    echo "✅ Native handler init: PASSED"
else
    echo "❌ Native handler init: FAILED"
fi

# Test end-to-end pipeline
if echo "$TEST_RESULTS" | grep -q "testEndToEndMapLibrePipeline.*passed"; then
    echo "✅ End-to-end pipeline: PASSED"
else
    echo "❌ End-to-end pipeline: FAILED"
fi

# Show any failure details
if [[ "$OVERALL_RESULT" == "FAIL" ]]; then
    echo ""
    echo "🔍 Failure details:"
    echo "=================================="
    echo "$TEST_RESULTS" | grep -A 5 -B 5 "failed\|error\|Error" | head -20
fi

echo ""
echo "🏁 Summary:"
echo "=================================="
if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    echo "✅ MapLibre bridge is working correctly"
    exit 0
else
    echo "❌ MapLibre bridge has issues - check test output above"
    exit 1
fi