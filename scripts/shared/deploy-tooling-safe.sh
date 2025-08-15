#!/bin/bash
set -euo pipefail

# OSRS Wiki Safe Tooling Deployment Script
# Deploys tooling components (excluding platforms/) to private repository

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 OSRS Wiki Safe Tooling Deployment${NC}"
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

# Phase 3: Emergency backup
echo -e "${BLUE}💾 Phase 3: Pre-deployment Backup${NC}"
echo "-----------------------------"

BACKUP_NAME="pre-tooling-deploy"
echo -e "${YELLOW}Creating emergency backup...${NC}"
./scripts/shared/emergency-backup.sh "$BACKUP_NAME"
echo -e "${GREEN}✅ Emergency backup created${NC}"

# Phase 4: Prepare deployment environment
echo -e "${BLUE}🏗️  Phase 4: Deployment Environment Setup${NC}"
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

# Phase 5: Prepare tooling content for deployment (exclude platforms/)
echo -e "${BLUE}📦 Phase 5: Content Preparation${NC}"
echo "----------------------------"

echo -e "${YELLOW}Preparing tooling content (excluding platforms/)...${NC}"

# Create temporary staging area
TEMP_STAGING="/tmp/osrswiki-tooling-staging-$$"
mkdir -p "$TEMP_STAGING"

echo -e "${YELLOW}Copying tooling components to staging area...${NC}"

# Copy all directories except platforms/, preserving structure
for dir in */; do
    if [[ "$dir" != "platforms/" ]]; then
        echo "  → Copying $dir"
        # Use cp to preserve directory structure, handle symlinks carefully
        if cp -r "$dir" "$TEMP_STAGING/" 2>/dev/null; then
            # Remove any problematic symlinks that might cause cycles
            find "$TEMP_STAGING/${dir%/}" -type l -name "scripts" -delete 2>/dev/null || true
        else
            echo "    ⚠️  Warning: Could not copy $dir"
        fi
    else
        echo "  ⏭️  Skipping platforms/ (deployed separately)"
    fi
done

# Copy important root files
for file in .*; do
    if [[ -f "$file" && "$file" != ".git" && "$file" != ".." && "$file" != "." ]]; then
        echo "  → Copying $file"
        cp "$file" "$TEMP_STAGING/" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✅ Content preparation complete${NC}"

# Phase 6: Safe deployment to ~/Deploy directory
echo -e "${BLUE}🚀 Phase 6: Safe Deployment${NC}"
echo "------------------------"

cd "$DEPLOY_TOOLING"
echo -e "${YELLOW}Working in deployment repository: $DEPLOY_TOOLING${NC}"

# Fetch latest changes
echo -e "${YELLOW}Fetching latest remote changes...${NC}"
git fetch origin main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating deployment branch: $DEPLOY_BRANCH${NC}"
git checkout -b "$DEPLOY_BRANCH" origin/main

# Copy tooling content to deployment repo
echo -e "${YELLOW}Copying tooling content...${NC}"

# Remove all content except .git
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy staged content to deployment repo
cp -r "$TEMP_STAGING"/* .
cp -r "$TEMP_STAGING"/.[^.]* . 2>/dev/null || true

# Clean up staging area
rm -rf "$TEMP_STAGING"

# Stage all changes
git add -A

# Create deployment commit with detailed information
if ! git diff --cached --quiet; then
    DEPLOY_COMMIT_MSG="deploy: update tooling repository (platforms/ excluded)

Recent tooling-related changes:
$(cd "$MONOREPO_ROOT" && git log --oneline --no-merges --max-count=5 main --grep='tool\\|script\\|shared' | sed 's/^/- /' || echo "- No recent tooling-specific commits")

This deployment:
- Excludes platforms/ directory (deployed separately to platform repos)
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

# Phase 7: Push to remote with safety checks
echo -e "${BLUE}⬆️  Phase 7: Remote Push${NC}"
echo "-------------------"

# Final safety check - commit count validation (tooling repo has fewer commits than platform repos)
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 5 ]]; then
    echo -e "${RED}🚨 CRITICAL SAFETY CHECK FAILED${NC}"
    echo "Deployment repository has only $DEPLOY_COMMITS commits"
    echo "Expected: 5+ commits for tooling repository"
    echo ""
    echo "This suggests a serious error in deployment preparation."
    echo "DO NOT PROCEED - investigate immediately."
    echo ""
    echo "To investigate:"
    echo "  cd $DEPLOY_TOOLING"
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
    
    echo -e "${GREEN}🎉 Tooling deployment completed successfully!${NC}"
    
else
    echo -e "${RED}❌ Push failed - remote may have been updated${NC}"
    echo "Fix conflicts and try again, or use emergency restore"
    exit 1
fi

# Phase 8: Final validation
echo -e "${BLUE}✅ Phase 8: Post-deployment Validation${NC}"
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
echo -e "${GREEN}🎊 Tooling Safe Deployment Complete!${NC}"
echo "===================================="
echo "Deployment repository: $DEPLOY_TOOLING"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Backup created: Check ~/Backups/osrswiki/"
echo ""
echo -e "${BLUE}Deployed components:${NC}"
echo "- ✅ Development tools and scripts"
echo "- ✅ Shared cross-platform components"
echo "- ✅ Documentation and configuration"
echo "- ✅ Build automation and workflows"
echo "- ❌ Platform code (deployed separately)"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-tooling"
echo "- Check that platforms/ directory is removed from remote"
echo "- Monitor for any issues"
echo ""
echo -e "${YELLOW}If issues occur, restore from backup:${NC}"
echo "- Use: ./scripts/shared/emergency-backup.sh"
echo "- Check: ~/Backups/osrswiki/$BACKUP_NAME-*"

exit 0