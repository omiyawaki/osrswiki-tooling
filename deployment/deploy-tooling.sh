#!/bin/bash
set -euo pipefail

echo "🔧 Deploying complete monorepo to private tooling repository..."

# Ensure we're in the monorepo root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify we're in the right place
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}❌ Error: Must run from monorepo root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-deployment checks...${NC}"

# Verify we have tooling remote
if ! git remote | grep -q "^tooling$"; then
    echo -e "${RED}❌ Error: Tooling remote not configured${NC}"
    echo "Run: git remote add tooling https://github.com/omiyawaki/osrswiki-tooling.git"
    exit 1
fi

# Check if we have any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes. Commit them first? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}📝 Please commit your changes and run this script again.${NC}"
        git status --short
        exit 1
    else
        echo -e "${YELLOW}⏭️  Proceeding with deployment (uncommitted changes will not be included)...${NC}"
    fi
fi

echo -e "${YELLOW}🚀 Pushing complete monorepo to private tooling repository...${NC}"

# Try normal push first, then force push if needed (for migration)
if git push tooling main; then
    echo -e "${GREEN}✅ Tooling deployment successful!${NC}"
    echo -e "${GREEN}🔒 Private repository updated: https://github.com/omiyawaki/osrswiki-tooling${NC}"
    echo ""
    echo -e "${GREEN}📦 Deployed components:${NC}"
    echo "  • Complete monorepo structure"
    echo "  • Shared cross-platform components" 
    echo "  • Development tools and scripts"
    echo "  • Build automation and asset generation"
    echo "  • DevContainer and Claude Code configuration"
    echo "  • Private development workflows"
elif git push tooling main --force; then
    echo -e "${GREEN}✅ Tooling deployment successful (forced update)!${NC}"
    echo -e "${GREEN}🔒 Private repository updated: https://github.com/omiyawaki/osrswiki-tooling${NC}"
    echo -e "${YELLOW}⚠️  Used force push to replace existing repository structure${NC}"
else
    echo -e "${RED}❌ Tooling deployment failed${NC}"
    echo -e "${YELLOW}💡 Check your authentication and network connection${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Tooling deployment completed successfully!${NC}"

# Show recent commit info
echo ""
echo -e "${YELLOW}📊 Deployed commit:${NC}"
git log --oneline -1
echo ""
echo -e "${YELLOW}📈 Repository status:${NC}"
echo "  • Local monorepo: $(pwd)"  
echo "  • Private tooling: https://github.com/omiyawaki/osrswiki-tooling"
echo "  • Public Android: https://github.com/omiyawaki/osrswiki-android" 
echo "  • Public iOS: https://github.com/omiyawaki/osrswiki-ios"