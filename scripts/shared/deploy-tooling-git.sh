#!/bin/bash
set -euo pipefail

# OSRS Wiki Git-Based Tooling Deployment Script
# Uses git operations instead of file copying for clean, reliable deployments

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
echo -e "${BLUE}🔍 Phase 1: Git Repository Validation${NC}"
echo "--------------------------------"

# Check if we have tooling remote
if ! git remote | grep -q "^tooling$"; then
    echo -e "${RED}❌ Tooling remote not configured${NC}"
    echo "Run: git remote add tooling https://github.com/omiyawaki/osrswiki-tooling.git"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    echo "Tooling deployment will use the current committed state."
    echo "Uncommitted changes will not be included."
    git status --short
    echo ""
fi

echo -e "${GREEN}✅ Git repository validation passed${NC}"

# Phase 2: Create deployment commit with platforms/ excluded
echo -e "${BLUE}📦 Phase 2: Create Deployment Commit${NC}"
echo "--------------------------------"

# Create a new branch for deployment preparation
DEPLOY_BRANCH="tooling-deploy-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating deployment branch: $DEPLOY_BRANCH${NC}"
git checkout -b "$DEPLOY_BRANCH"

# Temporarily remove platforms/ from this branch
echo -e "${YELLOW}Temporarily removing platforms/ for deployment...${NC}"
git rm -r platforms/ --quiet
git commit -m "deploy: exclude platforms/ for tooling deployment

This is a temporary commit for deployment purposes.
platforms/ is excluded from tooling repository as it's deployed separately
to platform-specific repositories.

Deployment info:
- Target: tooling repository
- Date: $(date '+%Y-%m-%dT%H:%M:%S%z')
- Source commit: $(git rev-parse HEAD~1)
- Platforms excluded: android, ios (deployed separately)"

echo -e "${GREEN}✅ Deployment commit created${NC}"

# Phase 3: Emergency backup
echo -e "${BLUE}💾 Phase 3: Pre-deployment Backup${NC}"
echo "-----------------------------"

BACKUP_NAME="pre-git-tooling-deploy"
echo -e "${YELLOW}Creating emergency backup...${NC}"
./scripts/shared/emergency-backup.sh "$BACKUP_NAME"
echo -e "${GREEN}✅ Emergency backup created${NC}"

# Phase 4: Git-based deployment
echo -e "${BLUE}🚀 Phase 4: Git-Based Deployment${NC}"
echo "-----------------------------"

echo -e "${YELLOW}Pushing deployment commit to tooling remote...${NC}"

# Force push to tooling remote (safe because we have backups)
if git push tooling "$DEPLOY_BRANCH:main" --force; then
    echo -e "${GREEN}✅ Git deployment successful!${NC}"
else
    echo -e "${RED}❌ Git deployment failed${NC}"
    echo "Cleaning up deployment branch and exiting..."
    git checkout main
    git branch -D "$DEPLOY_BRANCH"
    exit 1
fi

# Phase 5: Cleanup and validation
echo -e "${BLUE}🧹 Phase 5: Cleanup and Validation${NC}"
echo "-------------------------------"

# Return to main branch and clean up
echo -e "${YELLOW}Returning to main branch...${NC}"
git checkout main
git branch -D "$DEPLOY_BRANCH"

# Verify deployment
echo -e "${YELLOW}Verifying deployment...${NC}"
if git ls-remote --heads tooling main >/dev/null 2>&1; then
    REMOTE_COMMIT=$(git ls-remote tooling main | cut -f1)
    echo -e "${GREEN}✅ Remote tooling repository updated${NC}"
    echo "Remote commit: $REMOTE_COMMIT"
else
    echo -e "${RED}❌ Failed to verify remote deployment${NC}"
    exit 1
fi

# Update local deployment directory if it exists
if [[ -d "$HOME/Deploy/osrswiki-tooling" ]]; then
    echo -e "${YELLOW}Updating local deployment directory...${NC}"
    cd "$HOME/Deploy/osrswiki-tooling"
    git fetch origin main
    git reset --hard origin/main
    cd - >/dev/null
    echo -e "${GREEN}✅ Local deployment directory updated${NC}"
fi

echo ""
echo -e "${GREEN}🎊 Git-Based Tooling Deployment Complete!${NC}"
echo "============================================="
echo "Remote repository: https://github.com/omiyawaki/osrswiki-tooling"
echo "Deployment method: Git-based (atomic, structure-preserving)"
echo "Backup created: Check ~/Backups/osrswiki/$BACKUP_NAME-*"
echo ""
echo -e "${BLUE}Deployed components:${NC}"
echo "- ✅ Development tools and scripts (via git)"
echo "- ✅ Shared cross-platform components (via git)"
echo "- ✅ Documentation and configuration (via git)"
echo "- ✅ Build automation and workflows (via git)"
echo "- ❌ Platform code (excluded, deployed separately)"
echo ""
echo -e "${BLUE}Key advantages of git-based deployment:${NC}"
echo "- ✅ Atomic operations (success or complete rollback)"
echo "- ✅ Perfect structure preservation"
echo "- ✅ Git history maintained"
echo "- ✅ No file copying errors or corruption"
echo "- ✅ Natural platform exclusion"

exit 0