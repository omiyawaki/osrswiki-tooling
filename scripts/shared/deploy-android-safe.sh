#!/bin/bash
set -euo pipefail

# OSRS Wiki Safe Android Deployment Script
# Uses the new ~/Deploy directory structure with comprehensive validation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 OSRS Wiki Safe Android Deployment${NC}"
echo "====================================="
echo "Date: $(date)"
echo ""

# Ensure we're in the monorepo root
if [[ ! -f "CLAUDE.md" ]]; then
    echo -e "${RED}❌ Must run from monorepo root (where CLAUDE.md is located)${NC}"
    exit 1
fi

# Phase 1: Pre-deployment validation
echo -e "${BLUE}🔍 Phase 1: Pre-deployment Validation${NC}"
echo "----------------------------------"

echo -e "${YELLOW}Running deployment validation...${NC}"
if ! ./scripts/shared/validate-deployment.sh android; then
    echo -e "${RED}❌ Pre-deployment validation failed${NC}"
    echo "Fix validation errors before proceeding"
    exit 1
fi
echo -e "${GREEN}✅ Pre-deployment validation passed${NC}"

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

# Phase 3: Emergency backup
echo -e "${BLUE}💾 Phase 3: Pre-deployment Backup${NC}"
echo "-----------------------------"

BACKUP_NAME="pre-android-deploy"
echo -e "${YELLOW}Creating emergency backup...${NC}"
./scripts/shared/emergency-backup.sh "$BACKUP_NAME"
echo -e "${GREEN}✅ Emergency backup created${NC}"

# Phase 4: Prepare deployment environment
echo -e "${BLUE}🏗️  Phase 4: Deployment Environment Setup${NC}"
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

# Phase 5: Prepare Android content for deployment
echo -e "${BLUE}📦 Phase 5: Content Preparation${NC}"
echo "----------------------------"

echo -e "${YELLOW}Integrating shared components into Android platform...${NC}"

# Create shared directory in Android if it doesn't exist
ANDROID_SHARED_DIR="platforms/android/app/src/main/java/com/omiyawaki/osrswiki/shared"
mkdir -p "$ANDROID_SHARED_DIR"

# Copy shared components with error checking
for component in api models network utils; do
    if [[ -d "shared/$component" ]]; then
        echo "  → Copying shared/$component"
        cp -r "shared/$component"/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "    (no files to copy)"
    else
        echo "  ⚠️  shared/$component not found"
    fi
done

# Create Android-specific .gitignore
echo -e "${YELLOW}Creating Android-specific .gitignore...${NC}"
cat > "platforms/android/.gitignore" << 'EOF'
# Android-specific ignores for public repo
.gradle/
build/
app/build/
local.properties
.idea/
*.iml
.DS_Store
captures/
.externalNativeBuild/
.cxx/

# Session files (development only)
.claude-env
.claude-device-*
.claude-app-id
.claude-emulator-name
**/emulator.err
**/emulator.out

# Build artifacts
*.apk
*.ap_
*.aab

# Development logs
css_sync.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
node_modules/

# Temporary files
*.tmp
*.log
EOF

echo -e "${GREEN}✅ Content preparation complete${NC}"

# Phase 6: Commit preparation changes
echo -e "${BLUE}📝 Phase 6: Commit Preparation${NC}"
echo "----------------------------"

# Add the changes to git
git add "platforms/android/app/src/main/java/com/omiyawaki/osrswiki/shared/"
git add "platforms/android/.gitignore"

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}ℹ️  No preparation changes to commit${NC}"
else
    PREP_COMMIT_MSG="chore(android): integrate shared components for safe deployment

- Copy shared API, models, network, and utils into Android app
- Add Android-specific .gitignore for public repository
- Prepare for safe deployment to ~/Deploy/osrswiki-android

This commit integrates cross-platform shared components directly into the Android
app structure for safe deployment to the public repository."
    
    git commit -m "$PREP_COMMIT_MSG"
    echo -e "${GREEN}✅ Preparation changes committed${NC}"
fi

# Phase 7: Safe deployment to ~/Deploy directory
echo -e "${BLUE}🚀 Phase 7: Safe Deployment${NC}"
echo "------------------------"

cd "$DEPLOY_ANDROID"
echo -e "${YELLOW}Working in deployment repository: $DEPLOY_ANDROID${NC}"

# Fetch latest changes
echo -e "${YELLOW}Fetching latest remote changes...${NC}"
git fetch origin main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating deployment branch: $DEPLOY_BRANCH${NC}"
git checkout -b "$DEPLOY_BRANCH" origin/main

# Copy Android platform content to deployment repo
echo -e "${YELLOW}Copying Android platform content...${NC}"

# Remove all content except .git
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy platforms/android content to root of deployment repo
cp -r "$MONOREPO_ROOT/platforms/android"/* .
cp "$MONOREPO_ROOT/platforms/android/.gitignore" . 2>/dev/null || true

# Stage all changes
git add -A

# Create deployment commit with detailed information
if ! git diff --cached --quiet; then
    DEPLOY_COMMIT_MSG="deploy: integrate monorepo Android changes with shared components

Recent Android-related changes:
$(cd "$MONOREPO_ROOT" && git log --oneline --no-merges --max-count=5 main --grep='android\\|Android' | sed 's/^/- /' || echo "- No recent Android-specific commits")

This deployment:
- Preserves complete Android repository history
- Integrates latest changes from monorepo  
- Includes shared components (API, models, network, utils)
- Maintains proper .gitignore for public repository

Deployment info:
- Source: $MONOREPO_ROOT
- Target: $DEPLOY_ANDROID  
- Branch: $DEPLOY_BRANCH
- Date: $(date --iso-8601=seconds)"

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

# Phase 8: Push to remote with safety checks
echo -e "${BLUE}⬆️  Phase 8: Remote Push${NC}"
echo "-------------------"

# Final safety check - commit count validation
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 500 ]]; then
    echo -e "${RED}🚨 CRITICAL SAFETY CHECK FAILED${NC}"
    echo "Deployment repository has only $DEPLOY_COMMITS commits"
    echo "Expected: 500+ commits for Android repository"
    echo ""
    echo "This suggests a serious error in deployment preparation."
    echo "DO NOT PROCEED - investigate immediately."
    echo ""
    echo "To investigate:"
    echo "  cd $DEPLOY_ANDROID"
    echo "  git log --oneline | head -20"
    echo "  git branch -a"
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
    
    echo -e "${GREEN}🎉 Android deployment completed successfully!${NC}"
    
else
    echo -e "${RED}❌ Push failed - remote may have been updated${NC}"
    echo "Fix conflicts and try again, or use emergency restore"
    exit 1
fi

# Phase 9: Final validation
echo -e "${BLUE}✅ Phase 9: Post-deployment Validation${NC}"
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
echo -e "${GREEN}🎊 Android Safe Deployment Complete!${NC}"
echo "===================================="
echo "Deployment repository: $DEPLOY_ANDROID"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Backup created: Check ~/Backups/osrswiki/"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-android"
echo "- Test the deployed app"
echo "- Monitor for any issues"
echo ""
echo -e "${YELLOW}If issues occur, restore from backup:${NC}"
echo "- Use: ./scripts/shared/emergency-backup.sh"
echo "- Check: ~/Backups/osrswiki/$BACKUP_NAME-*"

exit 0