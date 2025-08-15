#!/bin/bash
set -euo pipefail

# OSRS Wiki Git-Based Tooling Deployment Script
# Updates ~/Deploy/osrswiki-tooling and pushes to remote

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 OSRS Wiki Git-Based Tooling Deployment${NC}"
echo "==========================================="
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

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    echo "Tooling deployment will use the current committed state."
    echo "Uncommitted changes will not be included."
    git status --short
    echo ""
fi

# Run deployment validation
echo -e "${YELLOW}Running deployment validation...${NC}"
if ! ./scripts/shared/validate-deployment.sh tooling; then
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

# Phase 3: Setup deployment environment
echo -e "${BLUE}🏗️  Phase 3: Deployment Environment Setup${NC}"
echo "-------------------------------------"

DEPLOY_TOOLING="$HOME/Deploy/osrswiki-tooling"
MONOREPO_ROOT="$(pwd)"

# Ensure deployment directory exists
if [[ ! -d "$DEPLOY_TOOLING" ]]; then
    echo -e "${YELLOW}📁 Creating deployment repository...${NC}"
    mkdir -p "$(dirname "$DEPLOY_TOOLING")"
    cd "$(dirname "$DEPLOY_TOOLING")"
    git clone https://github.com/omiyawaki/osrswiki-tooling.git
    cd "$MONOREPO_ROOT"
fi

# Validate deployment repo
if [[ ! -d "$DEPLOY_TOOLING/.git" ]]; then
    echo -e "${RED}❌ Deployment repository is not a valid git repo: $DEPLOY_TOOLING${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Deployment environment ready${NC}"

# Phase 4: Update deployment repository content
echo -e "${BLUE}📦 Phase 4: Update Deployment Content${NC}"
echo "-----------------------------------"

cd "$DEPLOY_TOOLING"
echo -e "${YELLOW}Working in deployment repository: $DEPLOY_TOOLING${NC}"

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

# Copy all directories except platforms/, preserving structure
echo -e "${YELLOW}Copying tooling components (excluding platforms/)...${NC}"
for dir in "$MONOREPO_ROOT"/*/; do
    dirname=$(basename "$dir")
    if [[ "$dirname" != "platforms" ]]; then
        echo "  → Copying $dirname/"
        cp -r "$dir" .
    else
        echo "  ⏭️  Skipping platforms/ (deployed separately)"
    fi
done

# Copy important root files
echo -e "${YELLOW}Copying root files...${NC}"
for file in "$MONOREPO_ROOT"/.*; do
    if [[ -f "$file" && "$(basename "$file")" != ".git" && "$(basename "$file")" != ".." && "$(basename "$file")" != "." ]]; then
        echo "  → Copying $(basename "$file")"
        cp "$file" . 2>/dev/null || true
    fi
done

# Stage all changes
git add -A

# Create deployment commit if there are changes
if ! git diff --cached --quiet; then
    DEPLOY_COMMIT_MSG="deploy: update tooling repository from monorepo

Recent tooling-related changes:
$(cd "$MONOREPO_ROOT" && git log --oneline --no-merges --max-count=5 main --grep='tool\\|script\\|shared' | sed 's/^/- /' || echo "- Recent commits from monorepo main branch")

This deployment:
- Updates from monorepo (excludes platforms/ directory)
- Includes all development tools and scripts
- Includes shared cross-platform components
- Includes documentation and configuration
- Maintains proper tooling repository structure

Deployment info:
- Source: $MONOREPO_ROOT
- Target: $DEPLOY_TOOLING  
- Branch: $DEPLOY_BRANCH
- Date: $(date '+%Y-%m-%dT%H:%M:%S%z')
- Platforms excluded: android, ios (deployed to separate repositories)"

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
if [[ "$DEPLOY_COMMITS" -lt 5 ]]; then
    echo -e "${RED}🚨 CRITICAL SAFETY CHECK FAILED${NC}"
    echo "Deployment repository has only $DEPLOY_COMMITS commits"
    echo "Expected: 5+ commits for tooling repository"
    echo ""
    echo "This suggests a serious error in deployment preparation."
    echo "DO NOT PROCEED - investigate immediately."
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
    
    echo -e "${GREEN}🎉 Tooling deployment completed successfully!${NC}"
    
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
echo -e "${GREEN}🎊 Git-Based Tooling Deployment Complete!${NC}"
echo "============================================="
echo "Deployment repository: $DEPLOY_TOOLING"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Changes deployed safely"
echo ""
echo -e "${BLUE}Deployed components:${NC}"
echo "- ✅ Development tools and scripts"
echo "- ✅ Shared cross-platform components"
echo "- ✅ Documentation and configuration"
echo "- ✅ Build automation and workflows"
echo "- ❌ Platform code (excluded, deployed separately)"
echo ""
echo -e "${BLUE}Key advantages of ~/Deploy approach:${NC}"
echo "- ✅ Simple 1:1 mirror of remote repository"
echo "- ✅ Standard git workflow from deployment directory"
echo "- ✅ Clear separation between monorepo and deployment"
echo "- ✅ Easy to verify deployment state"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-tooling"
echo "- Check that platforms/ directory is excluded from remote"
echo "- Monitor for any issues"

exit 0