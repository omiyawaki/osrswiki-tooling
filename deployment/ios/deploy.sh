#!/bin/bash
set -euo pipefail

echo "🍎 Deploying iOS app to public repository..."

# Ensure we're in the monorepo root
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify we're in the right place
if [ ! -f "CLAUDE.md" ] || [ ! -d "platforms/ios" ]; then
    echo -e "${RED}❌ Error: Must run from monorepo root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-deployment checks...${NC}"

# Check if iOS directory exists
if [ ! -d "platforms/ios" ]; then
    echo -e "${RED}❌ Error: iOS platform directory not found${NC}"
    exit 1
fi

# Check if shared directory exists
if [ ! -d "shared" ]; then
    echo -e "${RED}❌ Error: Shared components directory not found${NC}"
    exit 1
fi

# Verify we have ios remote
if ! git remote | grep -q "^ios$"; then
    echo -e "${RED}❌ Error: iOS remote not configured${NC}"
    echo "Run: git remote add ios https://github.com/omiyawaki/osrswiki-ios.git"
    exit 1
fi

echo -e "${YELLOW}📦 Creating shared components bridge for iOS...${NC}"

# Create shared directory in iOS if it doesn't exist
IOS_SHARED_DIR="platforms/ios/Shared"
mkdir -p "$IOS_SHARED_DIR"

# Create a Swift bridge file for shared components
# This will need manual conversion from Kotlin to Swift, but we'll document what needs to be ported
cat > "$IOS_SHARED_DIR/SharedComponents.swift" << 'EOF'
//
//  SharedComponents.swift
//  OSRS Wiki
//
//  Auto-generated bridge file for shared components
//  This file documents shared logic that should be implemented in Swift
//

import Foundation

// MARK: - Shared Models
// TODO: Implement Swift equivalents of shared/models/* files

// MARK: - Shared Network Layer  
// TODO: Implement Swift equivalents of shared/network/* files

// MARK: - Shared Utilities
// TODO: Implement Swift equivalents of shared/utils/* files

// MARK: - API Interfaces
// TODO: Implement Swift equivalents of shared/api/* files

/*
Kotlin files to port to Swift:

Models:
EOF

# List shared component files that need to be ported
if [ -d "shared/models" ]; then
    find shared/models -name "*.kt" | while read -r file; do
        echo "// - $file" >> "$IOS_SHARED_DIR/SharedComponents.swift"
    done
fi

cat >> "$IOS_SHARED_DIR/SharedComponents.swift" << 'EOF'

Network:
EOF

if [ -d "shared/network" ]; then
    find shared/network -name "*.kt" | while read -r file; do
        echo "// - $file" >> "$IOS_SHARED_DIR/SharedComponents.swift"
    done
fi

cat >> "$IOS_SHARED_DIR/SharedComponents.swift" << 'EOF'

Utilities:
EOF

if [ -d "shared/utils" ]; then
    find shared/utils -name "*.kt" | while read -r file; do
        echo "// - $file" >> "$IOS_SHARED_DIR/SharedComponents.swift"
    done
fi

cat >> "$IOS_SHARED_DIR/SharedComponents.swift" << 'EOF'

API:
EOF

if [ -d "shared/api" ]; then
    find shared/api -name "*.kt" | while read -r file; do
        echo "// - $file" >> "$IOS_SHARED_DIR/SharedComponents.swift"
    done
fi

cat >> "$IOS_SHARED_DIR/SharedComponents.swift" << 'EOF'

For each Kotlin file listed above, create a corresponding Swift implementation
that provides the same functionality for the iOS app.
*/
EOF

echo -e "${YELLOW}🔧 Creating iOS-specific .gitignore...${NC}"

# Create iOS-specific .gitignore
cat > platforms/ios/.gitignore << 'EOF'
# iOS-specific ignores for public repo

# Xcode
*.xcuserdata
*.xcworkspace/xcuserdata/
UserInterfaceState.xcuserstate
project.xcworkspace/xcuserdata/

# Build products
.build/
build/
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
.swiftpm/xcode/package.xcworkspace/xcuserdata/

# CocoaPods
Pods/
*.xcworkspace/!contents.xcworkspace

# Carthage
Carthage/Build/

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
iOSInjectionProject/

# General
.DS_Store
.AppleDouble
.LSOverride
*.log
*.tmp

# Development tools
npm-debug.log*
yarn-debug.log*
yarn-error.log*
node_modules/
EOF

echo -e "${YELLOW}📝 Committing iOS shared component bridge...${NC}"

# Add the changes to git
git add platforms/ios/Shared/
git add platforms/ios/.gitignore

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}⏭️  No changes to commit, proceeding with deployment...${NC}"
else
    git commit -m "chore(ios): create shared components bridge for public deployment

- Create SharedComponents.swift bridge file documenting Kotlin->Swift ports needed
- Add iOS-specific .gitignore for public repository  
- Prepare for subtree push to osrswiki-ios

This commit creates a development guide for porting shared Kotlin components
to Swift equivalents in the iOS app for cross-platform consistency."
fi

echo -e "${YELLOW}🚀 Pushing iOS platform to public repository...${NC}"

# Use git subtree to push only the iOS platform
if git subtree push --prefix=platforms/ios ios main; then
    echo -e "${GREEN}✅ iOS deployment successful!${NC}"
    echo -e "${GREEN}📱 Public repository updated: https://github.com/omiyawaki/osrswiki-ios${NC}"
else
    echo -e "${YELLOW}⚠️  Subtree push failed, using split and force push...${NC}"
    SPLIT_COMMIT=$(git subtree split --prefix=platforms/ios 2>/dev/null || echo "")
    if [ -n "$SPLIT_COMMIT" ]; then
        git push ios "$SPLIT_COMMIT:main" --force
        echo -e "${GREEN}✅ iOS deployment successful (force push)!${NC}"
        echo -e "${YELLOW}⚠️  Used force push - history may have been replaced${NC}"
    else
        echo -e "${YELLOW}⚠️  Subtree split failed, using manual copy deployment...${NC}"
        # Fallback: Manual copy to deployment directory
        if [ -d "$HOME/Deploy/osrswiki-ios" ]; then
            cd "$HOME/Deploy/osrswiki-ios"
            # Remove all content except .git
            find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
            # Copy platforms/ios content
            MONOREPO_ROOT="/Users/miyawaki/Develop/osrswiki"
            cp -r "$MONOREPO_ROOT/platforms/ios"/* .
            cp "$MONOREPO_ROOT/platforms/ios/.gitignore" . 2>/dev/null || true
            # Commit and push
            git add -A
            git commit -m "deploy: manual sync due to git history issues

- Updated from monorepo platforms/ios
- Includes latest changes and shared asset integration
- Manual deployment due to subtree corruption

Deployment date: $(date)"
            git push origin main --force
            echo -e "${GREEN}✅ iOS deployment successful (manual copy)!${NC}"
            cd - >/dev/null
        else
            echo -e "${RED}❌ All deployment methods failed${NC}"
            echo -e "${YELLOW}💡 If this is the first deployment, the remote repository might be empty.${NC}"
            echo -e "${YELLOW}   Try creating an initial commit in the iOS repository first.${NC}"
            exit 1
        fi
    fi
fi

echo -e "${GREEN}🎉 iOS deployment completed successfully!${NC}"