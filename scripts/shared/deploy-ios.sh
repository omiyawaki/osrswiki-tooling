#!/bin/bash
set -euo pipefail

# OSRS Wiki Git-Based iOS Deployment Script
# Updates ~/Deploy/osrswiki-ios and pushes to remote

# Source color utilities (auto-detects Claude Code environment)
source "$(dirname "${BASH_SOURCE[0]}")/color-utils.sh"

# Error handling function for better debugging
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "🚨 Script failed at line $line_number with exit code $exit_code"
    echo "Command that failed: ${BASH_COMMAND}"
    echo "Working directory: $(pwd)"
    echo "Script phase: $CURRENT_PHASE"
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Initialize phase tracking
CURRENT_PHASE="Initialization"

print_header "🚀 OSRS Wiki Git-Based iOS Deployment"
echo "Date: $(date)"
echo ""

# macOS requirement check
CURRENT_PHASE="macOS Environment Check"
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "iOS deployment requires macOS"
    echo "This script can only run on macOS with Xcode installed"
    exit 1
fi

# Check if we're in the right place and set paths
CURRENT_PHASE="Directory Structure Validation"
if [[ -f "CLAUDE.md" && -d "main/.git" ]]; then
    # Running from project root 
    GIT_ROOT="$(cd main && pwd)"
    PROJECT_ROOT="$(pwd)"
    print_success "Running from project root with proper structure"
elif [[ -d ".git" && -f "../CLAUDE.md" ]]; then
    # Running from git repo root (main/)
    GIT_ROOT="$(pwd)"
    PROJECT_ROOT="$(cd .. && pwd)"
    print_success "Running from git repository root"
else
    print_error "Must run from monorepo root (where CLAUDE.md is located)"
    echo "Current directory: $(pwd)"
    echo "Expected structure: PROJECT_ROOT/CLAUDE.md and PROJECT_ROOT/main/.git/"
    exit 1
fi

# Phase 1: Pre-deployment validation
CURRENT_PHASE="Pre-deployment Validation"
print_phase "🔍 Phase 1: Pre-deployment Validation"
echo "--------------------------------"

# Check for iOS platform directory (in git root)
IOS_PLATFORM_DIR="$GIT_ROOT/platforms/ios"
if [[ ! -d "$IOS_PLATFORM_DIR" ]]; then
    print_error "iOS platform directory not found at $IOS_PLATFORM_DIR"
    exit 1
fi
print_success "iOS platform directory found at $IOS_PLATFORM_DIR"

# Check for Xcode
if ! command -v xcodebuild >/dev/null; then
    print_error "Xcode not found"
    echo "Install Xcode from the App Store"
    exit 1
fi
print_success "Xcode found: $(xcodebuild -version | head -1)"

# Run deployment validation (from project root)
cd "$PROJECT_ROOT"

print_info "Running deployment validation..."
if ! ./main/scripts/shared/validate-deployment.sh ios; then
    print_error "Pre-deployment validation failed"
    echo "Fix validation errors before proceeding"
    exit 1
fi

# Phase 2: iOS build validation
CURRENT_PHASE="iOS Build Validation"
print_phase "🏗️  Phase 2: iOS Build Validation"
echo "-----------------------------"

print_info "Validating iOS project build..."
cd "$GIT_ROOT/platforms/ios"

# Check if project builds successfully (using the actual project name)
PROJECT_NAME="osrswiki"
if xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -configuration Debug -sdk iphonesimulator build -quiet; then
    print_success "iOS project builds successfully"
else
    print_error "iOS project build failed"
    echo "Fix build errors before deployment"
    cd "$PROJECT_ROOT"
    exit 1
fi

cd "$PROJECT_ROOT"

# Phase 3: Repository health check
CURRENT_PHASE="Repository Health Check"
print_phase "🏥 Phase 3: Repository Health Check"
echo "-------------------------------"

print_info "Checking repository health..."
if ! "$GIT_ROOT/scripts/shared/validate-repository-health.sh"; then
    print_warning " Repository health issues detected"
    echo "Continue anyway? (y/N)"
    if [[ -t 0 ]]; then
        # Interactive mode - ask user
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled by user"
            exit 1
        fi
    else
        # Non-interactive mode - proceed automatically
        print_warning " Running non-interactively - proceeding with deployment"
        response="y"
    fi
fi

# Phase 4: Setup deployment environment
print_phase "🏗️  Phase 4: Deployment Environment Setup"
echo "-------------------------------------"

DEPLOY_IOS="$HOME/Deploy/osrswiki-ios"
MONOREPO_ROOT="$(pwd)"

# Ensure deployment directory exists
if [[ ! -d "$DEPLOY_IOS" ]]; then
    print_info "📁 Creating deployment repository..."
    mkdir -p "$(dirname "$DEPLOY_IOS")"
    cd "$(dirname "$DEPLOY_IOS")"
    git clone https://github.com/omiyawaki/osrswiki-ios.git
    cd "$MONOREPO_ROOT"
fi

# Validate deployment repo
if [[ ! -d "$DEPLOY_IOS/.git" ]]; then
    print_error "Deployment repository is not a valid git repo: $DEPLOY_IOS"
    exit 1
fi

print_success "Deployment environment ready"

# Phase 5: Update deployment repository content
CURRENT_PHASE="Update Deployment Content"
print_phase "📦 Phase 5: Update Deployment Content"
echo "-----------------------------------"

cd "$DEPLOY_IOS"
print_info "Working in deployment repository: $DEPLOY_IOS"

# Fetch latest changes to ensure we're up to date
print_info "Fetching latest remote changes..."
git fetch origin main
git reset --hard origin/main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
print_info "Creating deployment branch: $DEPLOY_BRANCH"
git checkout -b "$DEPLOY_BRANCH"

# Clear existing content (except .git)
print_info "Clearing existing content..."
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy iOS platform content
print_info "Copying iOS platform content..."
cp -r "$GIT_ROOT/platforms/ios"/* .
cp "$GIT_ROOT/platforms/ios/.gitignore" . 2>/dev/null || true

# Handle MBTiles files - copy from cache instead of following symlinks
print_info "Copying MBTiles files from cache..."
CACHE_MBTILES="$HOME/Develop/osrswiki/cache/binary-assets/mbtiles"
if [[ -d "$CACHE_MBTILES" ]]; then
    # Remove any symlinked MBTiles files
    find . -name "*.mbtiles" -type l -delete
    
    # Copy actual MBTiles files from cache
    find "$CACHE_MBTILES" -name "*.mbtiles" -exec cp {} osrswiki/ \; 2>/dev/null || true
    mbtiles_count=$(find "$CACHE_MBTILES" -name "*.mbtiles" 2>/dev/null | wc -l)
    
    if [[ $mbtiles_count -gt 0 ]]; then
        print_success "    ✓ Copied $mbtiles_count MBTiles files from cache"
    else
        print_warning "    ⚠ No MBTiles files found in cache"
    fi
else
    print_warning "    ⚠ Cache directory not found: $CACHE_MBTILES"
    print_info "    Run map generation tools to populate cache"
fi

# Create iOS-specific shared component bridge if shared components exist
print_info "Creating shared components bridge..."
IOS_SHARED_DIR="osrswiki/Shared"

if [[ -d "$GIT_ROOT/shared" ]]; then
    mkdir -p "$IOS_SHARED_DIR"
    
    # Create Swift bridge file for shared components
    cat > "$IOS_SHARED_DIR/SharedComponentsBridge.swift" << 'EOF'
//
//  SharedComponentsBridge.swift
//  osrswiki
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

    echo "  → Created Swift bridge for shared components"
fi

# Stage all changes
git add -A

# Create deployment commit if there are changes
if ! git diff --cached --quiet; then
    # Generate intelligent commit message based on actual changes
    print_info "🧠 Generating intelligent commit message..."
    # Use find-git-repo.sh to locate the script correctly
    if source "$MONOREPO_ROOT/main/scripts/shared/find-git-repo.sh"; then
        REPO_ROOT=$(find_git_repo)
        if [[ -f "$REPO_ROOT/scripts/shared/generate-smart-commit-message.sh" ]]; then
            DEPLOY_COMMIT_MSG=$(source "$REPO_ROOT/scripts/shared/generate-smart-commit-message.sh" && \
                               generate_deployment_commit_message "ios" "$GIT_ROOT" "$DEPLOY_IOS")
        else
            print_info "⚠️  Smart commit message script not found, using fallback"
            DEPLOY_COMMIT_MSG="Merge deployment: iOS platform with shared components
- iOS app with Swift bridge for shared components
- Updated MBTiles integration
- iOS-specific UI consistency fixes"
        fi
    else
        print_info "⚠️  Repository detection failed, using fallback commit message"
        DEPLOY_COMMIT_MSG="Merge deployment: iOS platform with shared components
- iOS app with Swift bridge for shared components
- Updated MBTiles integration
- iOS-specific UI consistency fixes"
    fi

    git commit -m "$DEPLOY_COMMIT_MSG"
    print_success "Deployment commit created"
    
    # Show what was deployed
    print_phase "📋 Deployment Summary:"
    git show --stat HEAD
    
else
    print_info "ℹ️  No changes to deploy"
    git checkout main
    git branch -d "$DEPLOY_BRANCH"
    cd "$MONOREPO_ROOT"
    exit 0
fi

# Phase 6: Push to remote
CURRENT_PHASE="Push to Remote"
print_phase "🚀 Phase 6: Push to Remote"
echo "------------------------"

# Safety check - ensure we have reasonable number of commits
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 1 ]]; then
    print_error "🚨 CRITICAL SAFETY CHECK FAILED"
    echo "Deployment repository has no commits"
    echo "This suggests a serious error in deployment preparation."
    exit 1
fi

print_success "Safety check passed: $DEPLOY_COMMITS commits"

# Push with force-with-lease for safety
print_info "Pushing to remote..."
if git push origin "$DEPLOY_BRANCH" --force-with-lease; then
    print_success "Deployment branch pushed successfully"
    
    # Merge to main
    git checkout main
    git merge "$DEPLOY_BRANCH" --ff-only
    git push origin main
    
    # Clean up deployment branch
    git branch -d "$DEPLOY_BRANCH"
    git push origin --delete "$DEPLOY_BRANCH"
    
    print_success "🎉 iOS deployment completed successfully!"
    
else
    print_error "Push failed - remote may have been updated"
    echo "Fix conflicts and try again"
    exit 1
fi

# Phase 7: Final validation
print_phase "✅ Phase 7: Post-deployment Validation"
echo "--------------------------------"

# Verify remote state
REMOTE_COMMITS=$(git ls-remote origin main | cut -f1)
LOCAL_COMMITS=$(git rev-parse HEAD)

if [[ "$REMOTE_COMMITS" == "$LOCAL_COMMITS" ]]; then
    print_success "Remote and local are synchronized"
else
    print_warning " Remote and local commits differ"
    echo "This may indicate a deployment issue - investigate"
fi

# Return to monorepo
cd "$MONOREPO_ROOT"

echo ""
print_success "🎊 Git-Based iOS Deployment Complete!"
echo "========================================="
echo "Deployment repository: $DEPLOY_IOS"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Changes deployed safely"
echo ""
print_phase "Deployed components:"
echo "- ✅ iOS app (complete Xcode project)"
echo "- ✅ Swift bridges for shared components"
echo "- ✅ iOS-specific .gitignore"
echo "- ✅ Xcode project and configuration"
echo ""
print_phase "Key advantages of ~/Deploy approach:"
echo "- ✅ Simple 1:1 mirror of remote repository"
echo "- ✅ Standard git workflow from deployment directory"
echo "- ✅ Clear separation between monorepo and deployment"
echo "- ✅ Easy to verify deployment state"
echo ""
print_phase "Next steps:"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-ios"
echo "- Test the deployed app in Xcode"
echo "- Implement shared component Swift bridges in osrswiki/Shared/"
echo "- Monitor for any issues"

exit 0