#!/bin/bash

# Measure appearance settings image loading latency
# This script quantifies the performance impact of appearance settings preloading

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared/color-utils.sh"

# Auto-source environment
if [[ -f .claude-env ]]; then
    source .claude-env
elif [[ -f "${SCRIPT_DIR}/../../.claude-env" ]]; then
    source "${SCRIPT_DIR}/../../.claude-env"
fi

if [[ -z "$ANDROID_SERIAL" ]]; then
    echo "❌ ANDROID_SERIAL not set. Run: source .claude-env"
    exit 1
fi

echo "🔬 Measuring appearance settings image loading latency"
echo "📱 Device: $ANDROID_SERIAL"
echo ""

# Function to measure time between navigation and image display
measure_appearance_load_time() {
    local test_name="$1"
    local theme_change="$2"
    
    echo "📊 Test: $test_name"
    
    # Clear logcat to get clean timing
    adb -s "$ANDROID_SERIAL" logcat -c
    
    # Start timing (use python for millisecond precision)
    local start_time=$(python3 -c "import time; print(int(time.time() * 1000))")
    
    # Navigate to appearance settings
    if [[ "$theme_change" == "true" ]]; then
        echo "  🔄 Testing with theme change scenario"
        # Go back to home first to simulate fresh navigation
        adb -s "$ANDROID_SERIAL" shell input keyevent 4  # Back button
        sleep 0.5
        adb -s "$ANDROID_SERIAL" shell input keyevent 4  # Back button
        sleep 0.5
        
        # Navigate to More tab
        "$SCRIPT_DIR/ui-click.sh" --text "More" >/dev/null 2>&1
        sleep 0.2
    fi
    
    # Click Appearance
    "$SCRIPT_DIR/ui-click.sh" --text "Appearance" >/dev/null 2>&1
    
    # Wait for images to load and measure timing
    local navigation_time=$(python3 -c "import time; print(int(time.time() * 1000))")
    local nav_duration=$((navigation_time - start_time))
    
    # Check for preview loading completion in logs
    local timeout=5000  # 5 seconds max wait
    local check_interval=50  # Check every 50ms
    local elapsed=0
    local images_loaded=false
    
    while [[ $elapsed -lt $timeout ]]; do
        # Check if preview images are loaded by looking for UI elements
        local ui_ready=$(adb -s "$ANDROID_SERIAL" shell uiautomator dump /dev/stdout 2>/dev/null | grep -c "Clean and bright interface\|Easy on the eyes in low light" || echo "0")
        
        if [[ $ui_ready -ge 2 ]]; then
            images_loaded=true
            break
        fi
        
        sleep 0.05  # 50ms
        elapsed=$((elapsed + check_interval))
    done
    
    local end_time=$(python3 -c "import time; print(int(time.time() * 1000))")
    local total_duration=$((end_time - start_time))
    local load_duration=$((end_time - navigation_time))
    
    # Check for cache hits in logs
    local cache_hit=$(adb -s "$ANDROID_SERIAL" logcat -d | grep -c "Valid cache found, skipping generation" || echo "0")
    local cache_status="MISS"
    if [[ $cache_hit -gt 0 ]]; then
        cache_status="HIT"
    fi
    
    echo "  ⏱️  Navigation time: ${nav_duration}ms"
    echo "  ⏱️  Image load time: ${load_duration}ms"
    echo "  ⏱️  Total time: ${total_duration}ms"
    echo "  💾 Cache status: $cache_status"
    echo "  ✅ Images loaded: $images_loaded"
    echo ""
    
    # Return the load duration for comparison
    echo "$load_duration"
}

# Test 1: First navigation (cold start)
echo "🧪 Test 1: Cold start navigation"
load_time_1=$(measure_appearance_load_time "Cold start" "false")

# Test 2: Return navigation (cache should be warm)
echo "🧪 Test 2: Warm cache navigation"
load_time_2=$(measure_appearance_load_time "Warm cache" "true")

# Test 3: Repeated navigation (optimal cache performance)
echo "🧪 Test 3: Repeated navigation"
load_time_3=$(measure_appearance_load_time "Repeated access" "false")

# Analysis
echo "📈 Performance Analysis:"
echo "  Cold start:      ${load_time_1}ms"
echo "  Warm cache:      ${load_time_2}ms"
echo "  Repeated access: ${load_time_3}ms"
echo ""

# Calculate improvement
if [[ $load_time_1 -gt 0 ]]; then
    local improvement_pct=$(( (load_time_1 - load_time_3) * 100 / load_time_1 ))
    echo "📊 Cache improvement: ${improvement_pct}% faster"
fi

# Check for performance targets
local target_load_time=500  # 500ms target for good UX
echo ""
echo "🎯 Performance targets (< ${target_load_time}ms for good UX):"
for i in 1 2 3; do
    local load_time_var="load_time_$i"
    local load_time=${!load_time_var}
    local test_names=("Cold start" "Warm cache" "Repeated access")
    local test_name="${test_names[$((i-1))]}"
    
    if [[ $load_time -lt $target_load_time ]]; then
        echo "  ✅ $test_name: ${load_time}ms (GOOD)"
    else
        echo "  ⚠️  $test_name: ${load_time}ms (SLOW)"
    fi
done

echo ""
echo "✅ Appearance settings latency measurement complete"