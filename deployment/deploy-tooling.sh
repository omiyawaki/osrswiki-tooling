#!/bin/bash
set -euo pipefail

echo "🔧 Deploying tooling components to private repository (platforms/ excluded)..."

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

echo -e "${BLUE}🔄 Using safe deployment method...${NC}"
echo -e "${YELLOW}This will deploy tooling components while excluding platforms/${NC}"
echo -e "${YELLOW}Platforms are deployed separately to their own repositories.${NC}"
echo ""

# Execute the safe deployment script
if ./scripts/shared/deploy-tooling-safe.sh; then
    echo ""
    echo -e "${GREEN}🎉 Tooling deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📈 Repository status:${NC}"
    echo "  • Local monorepo: $(pwd)"
    echo "  • Private tooling: https://github.com/omiyawaki/osrswiki-tooling (platforms/ excluded)"
    echo "  • Public Android: https://github.com/omiyawaki/osrswiki-android"
    echo "  • Public iOS: https://github.com/omiyawaki/osrswiki-ios"
    echo ""
    echo -e "${GREEN}📦 Deployed to tooling repository:${NC}"
    echo "  ✅ Development tools and scripts"
    echo "  ✅ Shared cross-platform components"
    echo "  ✅ Documentation and configuration"
    echo "  ✅ Build automation and workflows"
    echo "  ✅ DevContainer and Claude Code configuration"
    echo "  ❌ Platform code (deployed separately to platform-specific repositories)"
else
    echo -e "${RED}❌ Tooling deployment failed${NC}"
    echo -e "${YELLOW}💡 Check the error messages above and try again${NC}"
    exit 1
fi