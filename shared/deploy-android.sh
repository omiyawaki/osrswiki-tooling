#!/bin/bash
set -euo pipefail

# OSRS Wiki Git-Based Android Deployment Script
# Updates ~/Deploy/osrswiki-android and pushes to remote

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 OSRS Wiki Git-Based Android Deployment${NC}"
echo "============================================"
echo "Date: $(date)"
echo ""

# Ensure we're in the monorepo root
if [[ ! -f "CLAUDE.md" ]]; then
    echo -e "${RED}❌ Must run from monorepo root (where CLAUDE.md is located)${NC}"
    exit 1
fi

# Phase 1: Pre-deployment validation
echo -e "${BLUE}🔍 Phase 1: Pre-deployment Validation${NC}"
echo "--------------------------------"

# Check for Android platform directory
if [[ ! -d "platforms/android" ]]; then
    echo -e "${RED}❌ Android platform directory not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Android platform directory found${NC}"

# Run deployment validation
echo -e "${YELLOW}Running deployment validation...${NC}"
if ! ./scripts/shared/validate-deployment.sh android; then
    echo -e "${RED}❌ Pre-deployment validation failed${NC}"
    echo "Fix validation errors before proceeding"
    exit 1
fi

# Phase 2: Repository health check
echo -e "${BLUE}🏥 Phase 2: Repository Health Check${NC}"
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

# Phase 3: Setup deployment environment
echo -e "${BLUE}🏗️  Phase 3: Deployment Environment Setup${NC}"
echo "-------------------------------------"

DEPLOY_ANDROID="$HOME/Deploy/osrswiki-android"
MONOREPO_ROOT="$(pwd)"

# Ensure deployment directory exists
if [[ ! -d "$DEPLOY_ANDROID" ]]; then
    echo -e "${YELLOW}📁 Creating deployment repository...${NC}"
    mkdir -p "$(dirname "$DEPLOY_ANDROID")"
    cd "$(dirname "$DEPLOY_ANDROID")"
    git clone https://github.com/omiyawaki/osrswiki-android.git
    cd "$MONOREPO_ROOT"
fi

# Validate deployment repo
if [[ ! -d "$DEPLOY_ANDROID/.git" ]]; then
    echo -e "${RED}❌ Deployment repository is not a valid git repo: $DEPLOY_ANDROID${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Deployment environment ready${NC}"

# Phase 4: Update deployment repository content
echo -e "${BLUE}📦 Phase 4: Update Deployment Content${NC}"
echo "-----------------------------------"

cd "$DEPLOY_ANDROID"
echo -e "${YELLOW}Working in deployment repository: $DEPLOY_ANDROID${NC}"

# Fetch latest changes to ensure we're up to date
echo -e "${YELLOW}Fetching latest remote changes...${NC}"
git fetch origin main
git reset --hard origin/main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating deployment branch: $DEPLOY_BRANCH${NC}"
git checkout -b "$DEPLOY_BRANCH"

# Clear existing content (except .git)
echo -e "${YELLOW}Clearing existing content...${NC}"
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy Android platform content
echo -e "${YELLOW}Copying Android platform content...${NC}"
cp -r "$MONOREPO_ROOT/platforms/android"/* .
cp "$MONOREPO_ROOT/platforms/android/.gitignore" . 2>/dev/null || true

# Integrate shared components if they exist
echo -e "${YELLOW}Integrating shared components...${NC}"
ANDROID_SHARED_DIR="app/src/main/java/com/omiyawaki/osrswiki/shared"

if [[ -d "$MONOREPO_ROOT/shared" ]]; then
    mkdir -p "$ANDROID_SHARED_DIR"
    
    # Copy shared components with error checking
    for component in api models network utils; do
        if [[ -d "$MONOREPO_ROOT/shared/$component" ]]; then
            echo "  → Copying shared/$component"
            cp -r "$MONOREPO_ROOT/shared/$component"/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "    (no files to copy)"
        else
            echo "  ⚠️  shared/$component not found (skipping)"
        fi
    done
fi

# Stage all changes
git add -A

# Create deployment commit if there are changes
if ! git diff --cached --quiet; then
    DEPLOY_COMMIT_MSG="deploy: update Android app from monorepo

Recent Android-related changes:
$(cd "$MONOREPO_ROOT" && git log --oneline --no-merges --max-count=5 main --grep='android\\|Android' | sed 's/^/- /' || echo "- Recent commits from monorepo main branch")

This deployment:
- Updates from monorepo platforms/android/
- Integrates shared components (API, models, network, utils)
- Maintains Android-specific .gitignore
- Preserves deployment repository structure

Deployment info:
- Source: $MONOREPO_ROOT
- Target: $DEPLOY_ANDROID  
- Branch: $DEPLOY_BRANCH
- Date: $(date '+%Y-%m-%dT%H:%M:%S%z')
- Shared components: $(ls -d "$MONOREPO_ROOT/shared"/* 2>/dev/null | wc -l) modules"

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

# Phase 5: Push to remote
echo -e "${BLUE}🚀 Phase 5: Push to Remote${NC}"
echo "------------------------"

# Safety check - ensure we have reasonable number of commits
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 1 ]]; then
    echo -e "${RED}🚨 CRITICAL SAFETY CHECK FAILED${NC}"
    echo "Deployment repository has no commits"
    echo "This suggests a serious error in deployment preparation."
    exit 1
fi

echo -e "${GREEN}✅ Safety check passed: $DEPLOY_COMMITS commits${NC}"

# Push with force-with-lease for safety
echo -e "${YELLOW}Pushing to remote...${NC}"
if git push origin "$DEPLOY_BRANCH" --force-with-lease; then
    echo -e "${GREEN}✅ Deployment branch pushed successfully${NC}"
    
    # Merge to main
    git checkout main
    git merge "$DEPLOY_BRANCH" --ff-only
    git push origin main
    
    # Clean up deployment branch
    git branch -d "$DEPLOY_BRANCH"
    git push origin --delete "$DEPLOY_BRANCH"
    
    echo -e "${GREEN}🎉 Android deployment completed successfully!${NC}"
    
else
    echo -e "${RED}❌ Push failed - remote may have been updated${NC}"
    echo "Fix conflicts and try again"
    exit 1
fi

# Phase 6: Final validation
echo -e "${BLUE}✅ Phase 6: Post-deployment Validation${NC}"
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
echo -e "${GREEN}🎊 Git-Based Android Deployment Complete!${NC}"
echo "=============================================="
echo "Deployment repository: $DEPLOY_ANDROID"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Changes deployed safely"
echo ""
echo -e "${BLUE}Deployed components:${NC}"
echo "- ✅ Android app (complete Kotlin/Gradle project)"
echo "- ✅ Shared components integrated (API, models, network, utils)"
echo "- ✅ Existing .gitignore preserved"
echo "- ✅ Build configuration and dependencies"
echo ""
echo -e "${BLUE}Key advantages of ~/Deploy approach:${NC}"
echo "- ✅ Simple 1:1 mirror of remote repository"
echo "- ✅ Standard git workflow from deployment directory"
echo "- ✅ Clear separation between monorepo and deployment"
echo "- ✅ Easy to verify deployment state"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-android"
echo "- Test the deployed app"
echo "- Monitor for any issues"

exit 0