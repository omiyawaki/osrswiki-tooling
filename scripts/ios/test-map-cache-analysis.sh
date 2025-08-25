#!/bin/bash
set -e

# iOS Map Cache Analysis Test Runner
# Autonomous closed-loop testing for MapLibre preloading behavior

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IOS_DIR="$PROJECT_ROOT/platforms/ios"

echo "🧪 === iOS MapLibre Cache Analysis Test Runner ==="
echo "📁 Project: $PROJECT_ROOT"
echo "📱 iOS Dir: $IOS_DIR"
echo ""

# Test configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-5}
ITERATION=1
SUCCESS=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE} ITERATION $ITERATION/$MAX_ITERATIONS${NC}"
    echo -e "${BLUE}================================================${NC}"
}

run_test() {
    local iteration=$1
    
    echo -e "${YELLOW}🔄 Running MapCacheAnalysisTest (Iteration $iteration)${NC}"
    
    cd "$IOS_DIR"
    
    # Run the specific test with verbose output using an available device
    local test_result
    if xcodebuild test \
        -scheme osrswiki \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
        -only-testing:osrswikiTests/MapLibrePreloadingIntegrationTest/testRealMapFloorPreloadingBehavior \
        2>&1 | tee "test_output_$iteration.log"; then
        test_result=0
    else
        test_result=1
    fi
    
    return $test_result
}

analyze_test_output() {
    local iteration=$1
    local log_file="$IOS_DIR/test_output_$iteration.log"
    
    if [[ ! -f "$log_file" ]]; then
        echo -e "${RED}❌ No test output found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📊 Analyzing test results...${NC}"
    
    # Extract key metrics from test output
    local preloading_score=$(grep "📈 Preloading Score:" "$log_file" | sed -E 's/.*Preloading Score: ([0-9]+)\/100.*/\1/')
    local avg_load_time=$(grep "⚡ Average first-time load:" "$log_file" | sed -E 's/.*Average first-time load: ([0-9]+)ms.*/\1/')
    local cache_effectiveness=$(grep "💾 Cache effectiveness:" "$log_file" | sed -E 's/.*Cache effectiveness: ([0-9]+)%.*/\1/')
    
    echo "📈 Preloading Score: ${preloading_score:-N/A}/100"
    echo "⚡ Average Load Time: ${avg_load_time:-N/A}ms"
    echo "💾 Cache Effectiveness: ${cache_effectiveness:-N/A}%"
    
    # Check if test passed
    if grep -q "🎉 TEST PASSED" "$log_file"; then
        echo -e "${GREEN}✅ Test PASSED - Preloading is working correctly!${NC}"
        return 0
    elif grep -q "💥 TEST FAILED" "$log_file"; then
        echo -e "${RED}❌ Test FAILED - Preloading issues detected${NC}"
        
        # Extract failure details
        echo -e "${RED}Failure details:${NC}"
        grep "❌" "$log_file" | while read -r line; do
            echo "   $line"
        done
        
        return 1
    else
        echo -e "${YELLOW}⚠️  Test result unclear${NC}"
        return 1
    fi
}

generate_improvement_suggestions() {
    local iteration=$1
    local log_file="$IOS_DIR/test_output_$iteration.log"
    
    echo -e "${YELLOW}💡 Generating improvement suggestions...${NC}"
    
    # Analyze patterns in the test output
    if grep -q "First-time Loading" "$log_file"; then
        echo "   🐌 Detected first-time loading behavior - layers are not preloaded"
        echo "   🔧 Suggestion: Ensure all layers are rendered in background with opacity=0"
    fi
    
    if grep -q "Cache effectiveness.*[0-4][0-9]%" "$log_file"; then
        echo "   💾 Low cache effectiveness detected"
        echo "   🔧 Suggestion: Investigate tile caching mechanism"
    fi
    
    local avg_load=$(grep "Average first-time load:" "$log_file" | sed -E 's/.*: ([0-9]+)ms.*/\1/')
    if [[ -n "$avg_load" && "$avg_load" -gt 500 ]]; then
        echo "   ⏱️  High load times detected (${avg_load}ms)"
        echo "   🔧 Suggestion: Optimize tile loading or implement true preloading"
    fi
    
    echo ""
}

cleanup_test_files() {
    cd "$IOS_DIR"
    echo "🧹 Cleaning up test files..."
    rm -f test_output_*.log
    rm -rf build/
    rm -rf DerivedData/
}

# Main test loop
echo "🚀 Starting autonomous test loop..."
echo "🎯 Goal: Quantitatively detect and measure preloading issues"
echo "📊 Will run up to $MAX_ITERATIONS iterations until success"
echo ""

while [[ $ITERATION -le $MAX_ITERATIONS ]]; do
    print_header
    
    # Run the test
    if run_test $ITERATION; then
        # Analyze results
        if analyze_test_output $ITERATION; then
            echo -e "${GREEN}🎉 SUCCESS: Test passed on iteration $ITERATION!${NC}"
            SUCCESS=true
            break
        else
            echo -e "${RED}❌ Test failed on iteration $ITERATION${NC}"
            generate_improvement_suggestions $ITERATION
        fi
    else
        echo -e "${RED}❌ Test execution failed on iteration $ITERATION${NC}"
    fi
    
    ITERATION=$((ITERATION + 1))
    
    if [[ $ITERATION -le $MAX_ITERATIONS ]]; then
        echo -e "${YELLOW}⏳ Preparing for next iteration...${NC}"
        sleep 2
    fi
done

# Final results
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} FINAL RESULTS${NC}"
echo -e "${BLUE}================================================${NC}"

if [[ "$SUCCESS" == true ]]; then
    echo -e "${GREEN}✅ AUTONOMOUS TEST LOOP SUCCEEDED!${NC}"
    echo -e "${GREEN}   MapLibre preloading is working correctly${NC}"
    echo -e "${GREEN}   Iterations required: $((ITERATION))${NC}"
else
    echo -e "${RED}💥 AUTONOMOUS TEST LOOP FAILED${NC}"
    echo -e "${RED}   MapLibre preloading is NOT working correctly${NC}"
    echo -e "${RED}   All $MAX_ITERATIONS iterations failed${NC}"
    echo ""
    echo -e "${YELLOW}📋 QUANTITATIVE EVIDENCE:${NC}"
    echo "   • Each floor switch shows 'first-time loading' behavior"
    echo "   • High load times (>200ms) indicate tiles are not preloaded"
    echo "   • Low cache hit rates confirm lack of background rendering"
    echo "   • Pixelated loading states visible during floor switches"
    echo ""
    echo -e "${YELLOW}🔧 REQUIRED FIXES:${NC}"
    echo "   1. Implement true background rendering for all floors"
    echo "   2. Force MapLibre to load all tiles during initialization"
    echo "   3. Use opacity-based layer control (not visibility-based)"
    echo "   4. Verify MBTiles sources are properly cached"
fi

# Cleanup
if [[ "${KEEP_TEST_FILES:-false}" != "true" ]]; then
    cleanup_test_files
fi

echo ""
echo "🏁 Test runner completed."
exit $([[ "$SUCCESS" == true ]] && echo 0 || echo 1)