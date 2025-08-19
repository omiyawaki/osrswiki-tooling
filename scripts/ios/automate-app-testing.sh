#!/bin/bash
# 
# Comprehensive iOS App Testing Automation
# Solves the navigation bottleneck for agent development
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SIMULATOR_UDID="${IOS_SIMULATOR_UDID}"
BUNDLE_ID="omiyawaki.osrswiki"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in a session and environment is loaded
check_environment() {
    if [[ -z "$SIMULATOR_UDID" ]]; then
        error "IOS_SIMULATOR_UDID not set. Run 'source .claude-env' first"
    fi
    
    if ! xcrun simctl list devices | grep -q "$SIMULATOR_UDID"; then
        error "Simulator $SIMULATOR_UDID not found"
    fi
    
    success "Environment checks passed"
}

# Build the app
build_app() {
    log "Building iOS app..."
    cd "$PROJECT_ROOT/platforms/ios"
    
    xcodebuild -project OSRSWiki.xcodeproj \
               -scheme osrswiki \
               -configuration Debug \
               -sdk iphonesimulator \
               build \
               -quiet
    
    success "App built successfully"
}

# Install and launch app
install_and_launch() {
    log "Installing and launching app..."
    
    local app_path="/Users/miyawaki/Library/Developer/Xcode/DerivedData/osrswiki-cskhdpsvlgbcldbdpvonzrfibmvb/Build/Products/Debug-iphonesimulator/osrswiki.app"
    
    # Install app
    xcrun simctl install "$SIMULATOR_UDID" "$app_path"
    
    # Launch app
    xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"
    
    # Wait for app to be ready
    sleep 5
    
    success "App installed and launched"
}

# Launch app directly to a specific tab
launch_to_tab() {
    local tab="$1"
    log "Launching app directly to $tab tab..."
    
    xcrun simctl terminate "$SIMULATOR_UDID" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID" -startTab "$tab"
    
    sleep 3
    success "App launched to $tab tab"
}

# Take screenshot with descriptive name
take_screenshot() {
    local name="$1"
    local description="${2:-}"
    
    "$SCRIPT_DIR/take-screenshot.sh" "$name"
    
    if [[ -n "$description" ]]; then
        log "📸 $description"
    fi
}

# Run UI tests for comprehensive navigation
run_ui_tests() {
    log "Running comprehensive UI navigation tests..."
    cd "$PROJECT_ROOT/platforms/ios"
    
    # Run our navigation automation tests
    xcodebuild test \
        -project OSRSWiki.xcodeproj \
        -scheme osrswiki \
        -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
        -only-testing:osrswikiUITests/NavigationAutomationTests/testNavigateAllTabsWithScreenshots \
        -quiet
    
    success "UI navigation tests completed"
}

# Quick map verification (most common agent need)
quick_map_test() {
    log "Running quick map verification..."
    
    launch_to_tab "map"
    take_screenshot "quick_map_verification" "Map tab with repositioned UI elements"
    
    success "Quick map test completed"
}

# Comprehensive testing of all tabs
full_app_test() {
    log "Running comprehensive app testing..."
    
    # Test each tab with launch arguments
    for tab in "news" "map" "search" "saved" "more"; do
        launch_to_tab "$tab"
        take_screenshot "comprehensive_${tab}_tab" "Full test of $tab tab"
    done
    
    success "Comprehensive app testing completed"
}

# Clean up screenshots older than specified hours
cleanup_screenshots() {
    local max_age_hours="${1:-24}"
    log "Cleaning up screenshots older than $max_age_hours hours..."
    
    find "$PROJECT_ROOT/screenshots" -name "*.png" -mtime "+${max_age_hours}h" -delete 2>/dev/null || true
    
    success "Screenshot cleanup completed"
}

# Show usage information
show_usage() {
    cat << EOF
🤖 iOS App Testing Automation

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    build           Build the iOS app
    quick-map       Quick map tab verification (most common)
    full-test       Test all tabs comprehensively  
    ui-tests        Run XCTest UI automation tests
    launch [TAB]    Launch directly to specific tab
    screenshot [NAME] Take a single screenshot
    cleanup [HOURS] Clean old screenshots (default: 24h)
    help            Show this help

TAB OPTIONS (for launch command):
    news, map, search, saved, more

EXAMPLES:
    $0 quick-map                    # Quick map verification
    $0 launch map                   # Launch directly to map tab
    $0 full-test                    # Test all tabs
    $0 screenshot "my-test"         # Take screenshot
    $0 cleanup 8                    # Clean screenshots older than 8h

AGENT WORKFLOW:
    1. source .claude-env           # Load session environment
    2. $0 build                     # Build app (if needed)
    3. $0 quick-map                 # Verify map changes
    4. $0 screenshot "description"  # Document findings
EOF
}

# Main execution
main() {
    case "${1:-help}" in
        "build")
            check_environment
            build_app
            ;;
        "quick-map")
            check_environment
            build_app
            install_and_launch
            quick_map_test
            ;;
        "full-test")
            check_environment
            build_app
            install_and_launch
            full_app_test
            ;;
        "ui-tests")
            check_environment
            build_app
            install_and_launch
            run_ui_tests
            ;;
        "launch")
            check_environment
            if [[ -z "$2" ]]; then
                error "Tab name required. Options: news, map, search, saved, more"
            fi
            install_and_launch
            launch_to_tab "$2"
            ;;
        "screenshot")
            if [[ -z "$2" ]]; then
                error "Screenshot name required"
            fi
            take_screenshot "$2" "$3"
            ;;
        "cleanup")
            cleanup_screenshots "$2"
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

main "$@"