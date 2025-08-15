#!/bin/bash
set -euo pipefail

echo "🚀 Deploying OSRS Wiki to all repositories..."

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

echo -e "${YELLOW}📋 Pre-deployment validation...${NC}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Error: You have uncommitted changes. Please commit all changes before deployment.${NC}"
    echo ""
    echo -e "${YELLOW}Uncommitted changes:${NC}"
    git status --short
    exit 1
fi

# Verify all deployment scripts exist and are executable
SCRIPTS=(
    "deployment/deploy-tooling.sh"
    "deployment/android/deploy.sh" 
    "deployment/ios/deploy.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ] || [ ! -x "$script" ]; then
        echo -e "${RED}❌ Error: $script not found or not executable${NC}"
        exit 1
    fi
done

# Verify all remotes are configured
REQUIRED_REMOTES=("android" "ios" "tooling")
for remote in "${REQUIRED_REMOTES[@]}"; do
    if ! git remote | grep -q "^${remote}$"; then
        echo -e "${RED}❌ Error: ${remote} remote not configured${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ All validations passed${NC}"
echo ""

# Ask for confirmation
echo -e "${YELLOW}🔍 About to deploy to:${NC}"
echo "  • 🔒 Private tooling: https://github.com/omiyawaki/osrswiki-tooling"
echo "  • 📱 Public Android: https://github.com/omiyawaki/osrswiki-android"  
echo "  • 🍎 Public iOS: https://github.com/omiyawaki/osrswiki-ios"
echo ""
echo -e "${YELLOW}Current commit to be deployed:${NC}"
git log --oneline -1
echo ""
echo -e "${YELLOW}Continue with deployment? (y/N)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Starting multi-repository deployment...${NC}"

# Step 1: Deploy to private tooling repository (complete monorepo)
echo ""
echo -e "${BLUE}Step 1/3: Deploying to private tooling repository...${NC}"
if ./deployment/deploy-tooling.sh; then
    echo -e "${GREEN}✅ Tooling deployment successful${NC}"
else
    echo -e "${RED}❌ Tooling deployment failed - stopping deployment${NC}"
    exit 1
fi

# Step 2: Deploy Android to public repository
echo ""
echo -e "${BLUE}Step 2/3: Deploying Android to public repository...${NC}" 
if ./deployment/android/deploy.sh; then
    echo -e "${GREEN}✅ Android deployment successful${NC}"
else
    echo -e "${RED}❌ Android deployment failed - stopping deployment${NC}"
    exit 1
fi

# Step 3: Deploy iOS to public repository
echo ""
echo -e "${BLUE}Step 3/3: Deploying iOS to public repository...${NC}"
if ./deployment/ios/deploy.sh; then
    echo -e "${GREEN}✅ iOS deployment successful${NC}"
else
    echo -e "${RED}❌ iOS deployment failed - stopping deployment${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 ALL DEPLOYMENTS COMPLETED SUCCESSFULLY! 🎉${NC}"
echo ""
echo -e "${YELLOW}📊 Deployment Summary:${NC}"
echo "  • 🔒 Private tooling: ✅ Updated with complete monorepo"
echo "  • 📱 Public Android: ✅ Updated with integrated shared components"  
echo "  • 🍎 Public iOS: ✅ Updated with Swift component bridge"
echo ""
echo -e "${YELLOW}🔗 Repository Links:${NC}"
echo "  • Tooling: https://github.com/omiyawaki/osrswiki-tooling"
echo "  • Android: https://github.com/omiyawaki/osrswiki-android"
echo "  • iOS: https://github.com/omiyawaki/osrswiki-ios"
echo ""
echo -e "${YELLOW}📈 Deployed Commit:${NC}"
git log --oneline -1