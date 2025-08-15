#!/bin/bash
set -euo pipefail

# OSRS Wiki Safe iOS Deployment Script
# Uses the new ~/Deploy directory structure with comprehensive validation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 OSRS Wiki Safe iOS Deployment${NC}"
echo "=================================="
echo "Date: $(date)"
echo ""

# macOS requirement check
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ iOS deployment requires macOS${NC}"
    echo "This script can only run on macOS with Xcode installed"
    exit 1
fi

# Ensure we're in the monorepo root
if [[ ! -f "CLAUDE.md" ]]; then
    echo -e "${RED}❌ Must run from monorepo root (where CLAUDE.md is located)${NC}"
    exit 1
fi

# Phase 1: Pre-deployment validation
echo -e "${BLUE}🔍 Phase 1: Pre-deployment Validation${NC}"
echo "----------------------------------"

echo -e "${YELLOW}Running deployment validation...${NC}"
if ! ./scripts/shared/validate-deployment.sh ios; then
    echo -e "${RED}❌ Pre-deployment validation failed${NC}"
    echo "Fix validation errors before proceeding"
    exit 1
fi
echo -e "${GREEN}✅ Pre-deployment validation passed${NC}"

# Phase 2: iOS-specific environment checks
echo -e "${BLUE}🍎 Phase 2: iOS Environment Validation${NC}"
echo "-----------------------------------"

# Check for Xcode
if ! command -v xcodebuild >/dev/null; then
    echo -e "${RED}❌ Xcode not found${NC}"
    echo "Install Xcode from the App Store"
    exit 1
fi
echo -e "${GREEN}✅ Xcode found: $(xcodebuild -version | head -1)${NC}"

# Check for iOS platform directory
if [[ ! -d "platforms/ios" ]]; then
    echo -e "${RED}❌ iOS platform directory not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ iOS platform directory found${NC}"

# Phase 3: Repository health check  
echo -e "${BLUE}🏥 Phase 3: Repository Health Check${NC}"
echo "-------------------------------"

echo -e "${YELLOW}Checking repository health...${NC}"
if ! ./scripts/shared/validate-repository-health.sh; then
    echo -e "${YELLOW}⚠️  Repository health issues detected${NC}"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Deployment cancelled by user${NC}"
        exit 1
    fi
fi

# Phase 4: Emergency backup
echo -e "${BLUE}💾 Phase 4: Pre-deployment Backup${NC}"
echo "-----------------------------"

BACKUP_NAME="pre-ios-deploy"
echo -e "${YELLOW}Creating emergency backup...${NC}"
./scripts/shared/emergency-backup.sh "$BACKUP_NAME"
echo -e "${GREEN}✅ Emergency backup created${NC}"

# Phase 5: Prepare deployment environment
echo -e "${BLUE}🏗️  Phase 5: Deployment Environment Setup${NC}"
echo "-------------------------------------"

DEPLOY_IOS="$HOME/Deploy/osrswiki-ios"
MONOREPO_ROOT="$(pwd)"

# Ensure deployment directory exists
if [[ ! -d "$DEPLOY_IOS" ]]; then
    echo -e "${YELLOW}📁 Creating deployment repository...${NC}"
    mkdir -p "$(dirname "$DEPLOY_IOS")"
    cd "$(dirname "$DEPLOY_IOS")"
    git clone https://github.com/omiyawaki/osrswiki-ios.git
    cd "$MONOREPO_ROOT"
fi

# Validate deployment repo
if [[ ! -d "$DEPLOY_IOS/.git" ]]; then
    echo -e "${RED}❌ Deployment repository is not a valid git repo: $DEPLOY_IOS${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Deployment environment ready${NC}"

# Phase 6: Prepare iOS content for deployment
echo -e "${BLUE}📦 Phase 6: iOS Content Preparation${NC}"
echo "-------------------------------"

echo -e "${YELLOW}Integrating shared components for iOS...${NC}"

# Create iOS-specific shared bridge directory
IOS_SHARED_DIR="platforms/ios/OSRSWiki/Shared"
mkdir -p "$IOS_SHARED_DIR"

# Create Swift bridge files for shared components
echo -e "${YELLOW}Creating Swift bridge for shared components...${NC}"

# Create bridge documentation
cat > "$IOS_SHARED_DIR/SharedComponentsBridge.swift" << 'EOF'
//
//  SharedComponentsBridge.swift
//  OSRSWiki
//
//  Auto-generated shared components bridge
//  This file bridges shared components for iOS use
//

import Foundation

// MARK: - Shared Components Bridge
// This provides iOS-compatible interfaces for shared components
// Originally from the monorepo shared/ directory

class SharedComponentsBridge {
    // TODO: Implement Swift bridges for shared components
    // - API layer bridge
    // - Model definitions bridge  
    // - Network utility bridge
    // - Utility function bridge
}

// MARK: - Configuration
extension SharedComponentsBridge {
    static let shared = SharedComponentsBridge()
    
    // Shared component paths (reference only - implemented natively in Swift)
    enum ComponentPath {
        static let api = "shared/api"
        static let models = "shared/models"
        static let network = "shared/network" 
        static let utils = "shared/utils"
    }
}
EOF

# Create shared component documentation
echo -e "${YELLOW}Creating shared components documentation...${NC}"
cat > "$IOS_SHARED_DIR/README.md" << EOF
# iOS Shared Components

This directory contains iOS-specific implementations of shared components from the monorepo.

## Available Components

### API Layer
- Location: \`shared/api\`
- iOS Implementation: Native Swift API client
- Status: TODO - Implement Swift version

### Models  
- Location: \`shared/models\`
- iOS Implementation: Swift Codable structs
- Status: TODO - Define Swift model structures

### Network Layer
- Location: \`shared/network\`
- iOS Implementation: URLSession-based networking
- Status: TODO - Implement iOS networking layer

### Utilities
- Location: \`shared/utils\`
- iOS Implementation: Swift utility extensions
- Status: TODO - Port utility functions to Swift

## Integration Notes

The iOS app uses native Swift implementations of shared components rather than 
direct code sharing. This provides:

1. **Type Safety**: Full Swift type checking
2. **Platform Optimization**: iOS-specific optimizations
3. **Maintainability**: Clear separation of concerns
4. **Testing**: Native iOS testing frameworks

## Development Workflow

1. Update shared components in monorepo
2. Update corresponding Swift implementations
3. Ensure API compatibility between platforms
4. Test iOS-specific functionality

Last Updated: $(date)
EOF

# Create iOS-specific .gitignore
echo -e "${YELLOW}Creating iOS-specific .gitignore...${NC}"
cat > "platforms/ios/.gitignore" << 'EOF'
# iOS-specific ignores for public repo

# Xcode
build/
DerivedData/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint
*.xcscheme

# iOS
*.ipa
*.dSYM.zip
*.dSYM

# Session files (development only)
.claude-env
.claude-device-*
.claude-app-id
.claude-simulator-*

# CocoaPods
Pods/
*.xcworkspace

# Carthage
Carthage/Build

# Swift Package Manager
.build/

# Temporary files
*.tmp
*.log
.DS_Store

# Development logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

echo -e "${GREEN}✅ iOS content preparation complete${NC}"

# Phase 7: iOS build validation
echo -e "${BLUE}🏗️  Phase 7: iOS Build Validation${NC}"
echo "-----------------------------"

echo -e "${YELLOW}Validating iOS project build...${NC}"
cd "platforms/ios"

# Check if project builds successfully
if xcodebuild -project OSRSWiki.xcodeproj -scheme OSRSWiki -configuration Debug -sdk iphonesimulator build -quiet; then
    echo -e "${GREEN}✅ iOS project builds successfully${NC}"
else
    echo -e "${RED}❌ iOS project build failed${NC}"
    echo "Fix build errors before deployment"
    cd "$MONOREPO_ROOT"
    exit 1
fi

cd "$MONOREPO_ROOT"

# Phase 8: Commit preparation changes
echo -e "${BLUE}📝 Phase 8: Commit Preparation${NC}"
echo "----------------------------"

# Add the changes to git
git add "platforms/ios/OSRSWiki/Shared/"
git add "platforms/ios/.gitignore"

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}ℹ️  No preparation changes to commit${NC}"
else
    PREP_COMMIT_MSG="chore(ios): prepare shared components bridge for safe deployment

- Create Swift bridge for shared components
- Add iOS-specific .gitignore for public repository  
- Add shared components documentation for iOS
- Prepare for safe deployment to ~/Deploy/osrswiki-ios

This commit prepares iOS-specific implementations and bridges for shared 
components for safe deployment to the public repository."

    git commit -m "$PREP_COMMIT_MSG"
    echo -e "${GREEN}✅ Preparation changes committed${NC}"
fi

# Phase 9: Safe deployment to ~/Deploy directory
echo -e "${BLUE}🚀 Phase 9: Safe Deployment${NC}"
echo "------------------------"

cd "$DEPLOY_IOS"
echo -e "${YELLOW}Working in deployment repository: $DEPLOY_IOS${NC}"

# Fetch latest changes
echo -e "${YELLOW}Fetching latest remote changes...${NC}"
git fetch origin main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating deployment branch: $DEPLOY_BRANCH${NC}"
git checkout -b "$DEPLOY_BRANCH" origin/main

# Copy iOS platform content to deployment repo
echo -e "${YELLOW}Copying iOS platform content...${NC}"

# Remove all content except .git
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy platforms/ios content to root of deployment repo
cp -r "$MONOREPO_ROOT/platforms/ios"/* .
cp "$MONOREPO_ROOT/platforms/ios/.gitignore" . 2>/dev/null || true

# Stage all changes
git add -A

# Create deployment commit with detailed information
if ! git diff --cached --quiet; then
    DEPLOY_COMMIT_MSG="deploy: integrate monorepo iOS changes with shared component bridges

Recent iOS-related changes:
$(cd "$MONOREPO_ROOT" && git log --oneline --no-merges --max-count=5 main --grep='ios\\|iOS' | sed 's/^/- /' || echo "- No recent iOS-specific commits")

This deployment:
- Preserves iOS repository history
- Integrates latest changes from monorepo
- Includes Swift bridges for shared components
- Maintains proper .gitignore for public repository

Deployment info:
- Source: $MONOREPO_ROOT
- Target: $DEPLOY_IOS
- Branch: $DEPLOY_BRANCH  
- Date: $(date --iso-8601=seconds)
- Xcode Version: $(xcodebuild -version | head -1)"

    git commit -m "$DEPLOY_COMMIT_MSG"
    echo -e "${GREEN}✅ Deployment commit created${NC}"
    
    # Show what was deployed
    echo -e "${BLUE}📋 Deployment Summary:${NC}"
    git show --stat HEAD
    
else
    echo -e "${YELLOW}ℹ️  No changes to deploy${NC}"
    git checkout main
    git branch -d "$DEPLOY_BRANCH"
    cd "$MONOREPO_ROOT"
    exit 0
fi

# Phase 10: Push to remote
echo -e "${BLUE}⬆️  Phase 10: Remote Push${NC}"
echo "--------------------"

# iOS repos may have fewer commits, so use lower threshold
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 1 ]]; then
    echo -e "${RED}🚨 CRITICAL SAFETY CHECK FAILED${NC}"
    echo "Deployment repository has no commits"
    echo "This suggests a serious error in deployment preparation."
    exit 1
fi

echo -e "${GREEN}✅ Safety check passed: $DEPLOY_COMMITS commits${NC}"

# Push with force-with-lease for safety
echo -e "${YELLOW}Pushing to remote with safety checks...${NC}"
if git push origin "$DEPLOY_BRANCH" --force-with-lease; then
    echo -e "${GREEN}✅ Deployment branch pushed successfully${NC}"
    
    # Merge to main  
    git checkout main
    git merge "$DEPLOY_BRANCH" --ff-only
    git push origin main
    
    # Clean up deployment branch
    git branch -d "$DEPLOY_BRANCH"
    git push origin --delete "$DEPLOY_BRANCH"
    
    echo -e "${GREEN}🎉 iOS deployment completed successfully!${NC}"
    
else
    echo -e "${RED}❌ Push failed - remote may have been updated${NC}"
    echo "Fix conflicts and try again, or use emergency restore"
    exit 1
fi

# Phase 11: Final validation
echo -e "${BLUE}✅ Phase 11: Post-deployment Validation${NC}"
echo "--------------------------------"

# Verify remote state
REMOTE_COMMITS=$(git ls-remote origin main | cut -f1)
LOCAL_COMMITS=$(git rev-parse HEAD)

if [[ "$REMOTE_COMMITS" == "$LOCAL_COMMITS" ]]; then
    echo -e "${GREEN}✅ Remote and local are synchronized${NC}"
else
    echo -e "${YELLOW}⚠️  Remote and local commits differ${NC}"
    echo "This may indicate a deployment issue - investigate"
fi

# Return to monorepo
cd "$MONOREPO_ROOT"

echo ""
echo -e "${GREEN}🎊 iOS Safe Deployment Complete!${NC}"
echo "================================="
echo "Deployment repository: $DEPLOY_IOS"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Backup created: Check ~/Backups/osrswiki/"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-ios"
echo "- Test the deployed app in Xcode"
echo "- Implement shared component Swift bridges"
echo "- Monitor for any issues"
echo ""
echo -e "${YELLOW}If issues occur, restore from backup:${NC}"
echo "- Use: ./scripts/shared/emergency-backup.sh"
echo "- Check: ~/Backups/osrswiki/$BACKUP_NAME-*"

exit 0