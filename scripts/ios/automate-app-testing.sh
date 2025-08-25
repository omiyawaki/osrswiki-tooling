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
    
    xcodebuild -project osrswiki.xcodeproj \
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
    
    # Run UI automation tests with XCTest framework
    xcodebuild test \
        -project osrswiki.xcodeproj \
        -scheme osrswiki \
        -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
        -testPlan osrswikiUITests \
        -quiet
    
    success "UI navigation tests completed"
}

# Quick map verification (most common agent need)
quick_map_test() {
    log "Running quick map verification with XCTest..."
    
    cd "$PROJECT_ROOT/platforms/ios"
    
    # Run specific map-related UI tests
    xcodebuild test \
        -project osrswiki.xcodeproj \
        -scheme osrswiki \
        -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
        -only-testing:osrswikiUITests/MapLibreEmbedVerificationTest \
        -quiet
    
    success "Quick map test completed"
}

# Comprehensive testing of all tabs
full_app_test() {
    log "Running comprehensive app testing with XCTest..."
    
    cd "$PROJECT_ROOT/platforms/ios"
    
    # Run comprehensive UI test suite
    xcodebuild test \
        -project osrswiki.xcodeproj \
        -scheme osrswiki \
        -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
        -only-testing:osrswikiUITests \
        -quiet
    
    success "Comprehensive app testing completed"
}

# Run unit tests only
run_unit_tests() {
    log "Running unit tests with XCTest..."
    
    cd "$PROJECT_ROOT/platforms/ios"
    
    # Run unit tests (non-UI tests)
    xcodebuild test \
        -project osrswiki.xcodeproj \
        -scheme osrswiki \
        -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
        -only-testing:osrswikiTests \
        -quiet
    
    success "Unit tests completed"
}

# Create new XCTest file with proper template
write_test_file() {
    local test_type="$1"
    local test_name="$2"
    
    if [[ -z "$test_type" || -z "$test_name" ]]; then
        error "Test type and name required. Usage: write-test [ui|unit] TestName"
    fi
    
    log "Creating new $test_type test: $test_name"
    
    case "$test_type" in
        "ui")
            local test_dir="$PROJECT_ROOT/platforms/ios/osrswikiUITests"
            local test_file="$test_dir/${test_name}Test.swift"
            
            cat > "$test_file" << 'EOF'
import XCTest

class TESTNAME_Test: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testTESTNAME_Functionality() {
        // TODO: Implement your UI test here
        // Example:
        // let button = app.buttons["YourButton"]
        // XCTAssertTrue(button.exists, "Button should exist")
        // button.tap()
        // 
        // let result = app.staticTexts["ExpectedResult"]
        // XCTAssertTrue(result.exists, "Expected result should appear")
    }
    
    func testTESTNAME_EdgeCase() {
        // TODO: Test edge cases and error conditions
        // Add more test methods as needed
    }
}
EOF
            # Replace TESTNAME placeholder
            sed -i '' "s/TESTNAME/$test_name/g" "$test_file"
            success "UI test created: $test_file"
            ;;
            
        "unit")
            local test_dir="$PROJECT_ROOT/platforms/ios/osrswikiTests"
            local test_file="$test_dir/${test_name}Tests.swift"
            
            cat > "$test_file" << 'EOF'
import XCTest
@testable import osrswiki

class TESTNAME_Tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Setup code before each test method
    }
    
    override func tearDownWithError() throws {
        // Cleanup code after each test method
    }
    
    func testTESTNAME_BasicFunctionality() {
        // TODO: Implement your unit test here
        // Example:
        // let result = YourClass.yourMethod()
        // XCTAssertEqual(result, expectedValue, "Method should return expected value")
    }
    
    func testTESTNAME_EdgeCases() {
        // TODO: Test edge cases and error conditions
        // Example:
        // XCTAssertThrowsError(try YourClass.methodThatShouldThrow()) {
        //     error in
        //     XCTAssertEqual(error as? YourErrorType, .expectedError)
        // }
    }
    
    func testTESTNAME_Performance() {
        // TODO: Add performance tests if needed
        // self.measure {
        //     // Code to measure performance
        // }
    }
}
EOF
            # Replace TESTNAME placeholder
            sed -i '' "s/TESTNAME/$test_name/g" "$test_file"
            success "Unit test created: $test_file"
            ;;
            
        *)
            error "Invalid test type. Use 'ui' or 'unit'"
            ;;
    esac
    
    echo ""
    echo "📝 Next steps:"
    echo "1. Edit the test file to implement your specific test logic"
    echo "2. Build the app: $0 build"
    echo "3. Run tests: $0 ${test_type}-tests"
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
🤖 iOS App Testing Automation - XCTest Based

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    write-test [TYPE] [NAME] Create new XCTest file (REQUIRED before testing)
    build           Build the iOS app
    quick-map       Quick map tab verification using XCTest (most common)
    full-test       Test all tabs comprehensively using XCTest  
    ui-tests        Run XCTest UI automation tests
    unit-tests      Run XCTest unit tests
    launch [TAB]    Launch directly to specific tab
    screenshot [NAME] Take a single screenshot (for debugging only)
    cleanup [HOURS] Clean old screenshots (default: 24h)
    help            Show this help

TAB OPTIONS (for launch command):
    news, map, search, saved, more

TEST TYPES (for write-test command):
    ui          Create UI test (for user interactions)
    unit        Create unit test (for logic/functions)

EXAMPLES:
    $0 write-test ui MyFeature      # Create UI test FIRST (REQUIRED)
    $0 write-test unit MyLogic      # Create unit test FIRST (REQUIRED)
    $0 quick-map                    # Quick map verification with XCTest
    $0 full-test                    # Comprehensive XCTest suite
    $0 ui-tests                     # UI automation tests
    $0 unit-tests                   # Unit tests only
    $0 launch map                   # Launch to specific tab for debugging

RECOMMENDED AGENT WORKFLOW:
    1. source .claude-env           # Load session environment
    2. $0 write-test ui MyFeature   # FIRST: Write tests for your changes
    3. $0 build                     # Build app
    4. $0 quick-map                 # Verify changes with automated tests
    5. $0 full-test                 # Run comprehensive test suite
    
TESTING APPROACH:
    ⚠️  CRITICAL: ALWAYS write tests BEFORE running XCTest commands
    • Primary: Use XCTest for automated verification (after writing tests)
    • Secondary: Screenshots only for debugging issues
    • Manual: Launch specific tabs for detailed inspection
    
⚠️  WARNING: XCTest commands will fail if no tests exist for your feature!
EOF
}

# Main execution
main() {
    case "${1:-help}" in
        "write-test")
            write_test_file "$2" "$3"
            ;;
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
        "unit-tests")
            check_environment
            build_app
            run_unit_tests
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