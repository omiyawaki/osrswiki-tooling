#!/bin/bash
set -euo pipefail

echo "🔧 Deploying tooling components using git-based approach (platforms/ excluded)..."

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

echo -e "${BLUE}🔄 Using git-based deployment method...${NC}"
echo -e "${YELLOW}This approach uses git operations for atomic, structure-preserving deployment${NC}"
echo -e "${YELLOW}Platforms are excluded naturally via git operations.${NC}"
echo ""

# Execute the git-based deployment script
if ./scripts/shared/deploy-tooling-git.sh; then
    echo ""
    echo -e "${GREEN}🎉 Git-based tooling deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📈 Repository status:${NC}"
    echo "  • Local monorepo: $(pwd)"
    echo "  • Private tooling: https://github.com/omiyawaki/osrswiki-tooling (platforms/ excluded via git)"
    echo "  • Public Android: https://github.com/omiyawaki/osrswiki-android"
    echo "  • Public iOS: https://github.com/omiyawaki/osrswiki-ios"
    echo ""
    echo -e "${GREEN}📦 Git-deployed to tooling repository:${NC}"
    echo "  ✅ Development tools and scripts (atomic git deployment)"
    echo "  ✅ Shared cross-platform components (structure preserved)"
    echo "  ✅ Documentation and configuration (git history maintained)"
    echo "  ✅ Build automation and workflows (no file corruption)"
    echo "  ✅ DevContainer and Claude Code configuration (reliable)"
    echo "  ❌ Platform code (cleanly excluded via git operations)"
else
    echo -e "${RED}❌ Git-based tooling deployment failed${NC}"
    echo -e "${YELLOW}💡 Check the error messages above and try again${NC}"
    echo -e "${YELLOW}💡 Git-based deployment is more reliable than file copying${NC}"
    exit 1
fi