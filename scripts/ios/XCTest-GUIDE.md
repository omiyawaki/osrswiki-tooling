# iOS Testing with XCTest - Claude Agent Guide

## Overview
This guide ensures Claude agents use proper XCTest framework for iOS testing instead of screenshot-based manual testing.

## Testing Hierarchy (Use in this order)

### 1. **PRIMARY: Automated XCTest Testing**
- **When to use**: Always start here for verification and validation
- **Tools**: XCTest framework, xcodebuild command
- **Benefits**: Reliable, repeatable, programmatic validation

#### Quick Commands:
```bash
# Quick map verification (most common)
./scripts/ios/automate-app-testing.sh quick-map

# Unit tests only
./scripts/ios/automate-app-testing.sh unit-tests

# Full UI test suite
./scripts/ios/automate-app-testing.sh full-test
```

#### Direct XCTest Commands:
```bash
# Run all tests
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID"

# Run specific test class
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiUITests/MapLibreEmbedVerificationTest

# Run unit tests only
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiTests
```

### 2. **SECONDARY: App Launch for Debugging**
- **When to use**: When tests fail and you need to investigate
- **Tools**: xcrun simctl launch, automate-app-testing.sh launch
- **Purpose**: Manual inspection of specific issues

```bash
# Launch to specific tab for debugging
./scripts/ios/automate-app-testing.sh launch map
./scripts/ios/automate-app-testing.sh launch search
```

### 3. **TERTIARY: Screenshots for Documentation Only**
- **When to use**: ONLY for documenting bugs or final verification
- **NOT for**: Primary testing or validation
- **Purpose**: Visual evidence for bug reports

```bash
# Only use for bug documentation
./scripts/ios/take-screenshot.sh "bug-description-here"
```

## Available Test Suites

### UI Tests (osrswikiUITests)
Located in: `platforms/ios/osrswikiUITests/`

Key test classes:
- `MapLibreEmbedVerificationTest` - Map functionality
- `NavigationAutomationTests` - Tab navigation
- `SearchHighlightingUITests` - Search functionality
- `BottomBarNavigationTimingUITests` - Navigation timing
- `TabBarThemingTest` - UI theming

### Unit Tests (osrswikiTests)
Located in: `platforms/ios/osrswikiTests/`

Key test classes:
- `MapLibreBridgeTests` - Map integration
- `SearchHighlightingTests` - Search logic
- `RuneScapeFontTests` - Font handling
- `ThemeCachingTest` - Theme management

## Agent Workflow

### For New Feature Development:
1. Build app: `./scripts/ios/quick-test.sh`
2. **FIRST: Write XCTests for new functionality** (REQUIRED before testing)
   - Create test files in `platforms/ios/osrswikiUITests/` for UI tests
   - Create test files in `platforms/ios/osrswikiTests/` for unit tests
   - Follow existing test patterns and naming conventions
3. Run tests: `./scripts/ios/automate-app-testing.sh quick-map`
4. Debug failures with targeted launch if needed
5. Document with screenshots only if reporting bugs

### **CRITICAL: You must write tests before running XCTest commands**
- XCTest framework requires actual test methods to execute
- Running tests without writing them will result in "No tests found" errors
- Always create test files first, then execute them

### For Bug Fixes:
1. **FIRST: Write failing test that reproduces bug** (REQUIRED)
2. Implement fix
3. Verify with: `./scripts/ios/automate-app-testing.sh unit-tests`
4. Run full suite: `./scripts/ios/automate-app-testing.sh full-test`

### For Verification Tasks:
1. **FIRST: Check if relevant tests exist, if not CREATE THEM**
2. Run relevant test suite only after tests are written
3. Only use manual verification if tests are insufficient
4. Update tests to cover gaps found during manual testing

## Common Mistakes to Avoid

❌ **DON'T**: Run XCTest commands without writing tests first
❌ **DON'T**: Start with screenshots for testing
❌ **DON'T**: Use manual navigation as primary verification  
❌ **DON'T**: Rely on visual inspection for functional validation
❌ **DON'T**: Assume tests exist - always check first

✅ **DO**: Write tests BEFORE running XCTest commands
✅ **DO**: Start with automated XCTest execution (after writing tests)
✅ **DO**: Write tests for new functionality
✅ **DO**: Use manual steps only for debugging test failures
✅ **DO**: Update test coverage when gaps are found

## Writing XCTests - REQUIRED FIRST STEP

### Before running any XCTest commands, you must write test files:

#### UI Test Example (platforms/ios/osrswikiUITests/):
```swift
import XCTest

class MyFeatureUITest: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testMyNewFeature() {
        // Test the specific functionality you implemented
        let button = app.buttons["MyButton"]
        XCTAssertTrue(button.exists)
        button.tap()
        
        let result = app.staticTexts["ExpectedResult"]
        XCTAssertTrue(result.exists)
    }
}
```

#### Unit Test Example (platforms/ios/osrswikiTests/):
```swift
import XCTest
@testable import osrswiki

class MyFeatureTests: XCTestCase {
    
    func testMyFunctionality() {
        // Test your implementation
        let result = MyClass.myMethod()
        XCTAssertEqual(result, expectedValue)
    }
    
    func testEdgeCases() {
        // Test edge cases and error conditions
        XCTAssertThrowsError(try MyClass.methodThatShouldThrow())
    }
}
```

### Test Writing Workflow:
1. **Identify what to test** - specific functionality you're implementing/fixing
2. **Choose test type** - UI test for user interactions, unit test for logic
3. **Create test file** - follow naming conventions (FeatureNameTest.swift)
4. **Write test methods** - start with `test` prefix, use descriptive names
5. **Run tests** - only after writing them

## Test Execution Examples

### Testing UI Changes:
```bash
# Test bottom bar navigation changes
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiUITests/BottomBarNavigationTimingUITests

# Test search functionality
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiUITests/SearchHighlightingUITests
```

### Testing Backend Changes:
```bash
# Test map integration
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiTests/MapLibreBridgeTests

# Test theme handling
xcodebuild test -project platforms/ios/osrswiki.xcodeproj -scheme osrswiki -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_UDID" -only-testing:osrswikiTests/ThemeCachingTest
```

## Environment Setup

Always ensure environment is loaded before testing:
```bash
source .claude-env
echo "Simulator: $IOS_SIMULATOR_UDID"
echo "Bundle ID: $BUNDLE_ID"
```

## Integration with Session Workflow

The `/start` command now emphasizes XCTest workflow:
1. Session setup creates simulator
2. Environment variables are loaded
3. XCTest becomes the primary testing method
4. Screenshots are demoted to debugging-only role

This approach ensures reliable, automated verification while maintaining the ability to debug issues when tests fail.