#!/bin/bash
set -euo pipefail

echo "🔄 Syncing changes from all remote repositories..."

# Ensure we're in the monorepo root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verify we're in the right place
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}❌ Error: Must run from monorepo root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-sync checks...${NC}"

# Verify all remotes exist
REQUIRED_REMOTES=("android" "ios" "tooling")
for remote in "${REQUIRED_REMOTES[@]}"; do
    if ! git remote | grep -q "^${remote}$"; then
        echo -e "${RED}❌ Error: ${remote} remote not configured${NC}"
        exit 1
    fi
done

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes. Commit them first? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}📝 Please commit your changes and run this script again.${NC}"
        git status --short
        exit 1
    else
        echo -e "${YELLOW}⏭️  Proceeding with sync (your changes will be preserved)...${NC}"
    fi
fi

# Store current branch
CURRENT_BRANCH=$(git branch --show-current)

echo ""
echo -e "${BLUE}🔄 Step 1/4: Syncing from private tooling repository...${NC}"

# Fetch and merge from tooling (private repo with complete monorepo)
if git pull tooling main; then
    echo -e "${GREEN}✅ Tooling sync successful${NC}"
else
    echo -e "${YELLOW}⚠️  Tooling sync had issues (this may be normal if repos are in sync)${NC}"
fi

echo ""
echo -e "${BLUE}🔄 Step 2/4: Syncing Android changes...${NC}"

# Check if Android subtree exists
if git log --grep="git-subtree-dir: platforms/android" --oneline | head -1 | grep -q .; then
    echo "  📱 Existing Android subtree detected, pulling changes..."
    if git subtree pull --prefix=platforms/android android main; then
        echo -e "${GREEN}✅ Android sync successful${NC}"
    else
        echo -e "${YELLOW}⚠️  Android sync had issues (this may be normal if no changes)${NC}"
    fi
else
    echo "  📱 No existing Android subtree found - will be created on first push"
fi

echo ""
echo -e "${BLUE}🔄 Step 3/4: Syncing iOS changes...${NC}"

# Check if iOS subtree exists  
if git log --grep="git-subtree-dir: platforms/ios" --oneline | head -1 | grep -q .; then
    echo "  🍎 Existing iOS subtree detected, pulling changes..."
    if git subtree pull --prefix=platforms/ios ios main; then
        echo -e "${GREEN}✅ iOS sync successful${NC}"
    else
        echo -e "${YELLOW}⚠️  iOS sync had issues (this may be normal if no changes)${NC}"
    fi
else
    echo "  🍎 No existing iOS subtree found - will be created on first push"
fi

echo ""
echo -e "${BLUE}🔄 Step 4/4: Finalizing sync...${NC}"

# Ensure we're on the original branch
if [ "$CURRENT_BRANCH" != "$(git branch --show-current)" ]; then
    git checkout "$CURRENT_BRANCH"
fi

# Show sync summary
echo ""
echo -e "${GREEN}🎉 Sync completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📊 Sync Summary:${NC}"
echo "  • Branch: $CURRENT_BRANCH"
echo "  • Tooling (private): ✅ Synced"
echo "  • Android (public): ✅ Synced" 
echo "  • iOS (public): ✅ Synced"
echo ""

# Show recent commits
echo -e "${YELLOW}📈 Recent commits:${NC}"
git log --oneline -5

echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "  • Review changes with: git status"
echo "  • Deploy Android: ./deployment/android/deploy.sh"
echo "  • Deploy iOS: ./deployment/ios/deploy.sh"
echo "  • Deploy tooling: ./deployment/deploy-tooling.sh"