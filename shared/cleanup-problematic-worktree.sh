#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

WORKTREE_PATH="${1:-}"

if [[ -z "$WORKTREE_PATH" ]]; then
    echo -e "${RED}❌ Usage: $0 <worktree-path>${NC}"
    echo "Example: $0 ~/Develop/osrswiki-sessions/claude-20250815-093906-bottom-bar-spacing-fix"
    exit 1
fi

if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo -e "${RED}❌ Worktree directory does not exist: $WORKTREE_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}🧹 Cleaning up problematic worktree: $WORKTREE_PATH${NC}"

cd "$WORKTREE_PATH"

echo -e "${YELLOW}📋 Current problematic files:${NC}"
git status --porcelain | grep "^??" | head -10

echo -e "${YELLOW}🗑️  Removing wrapper scripts...${NC}"
rm -f setup-session-device.sh setup-container-device.sh get-app-id.sh
rm -f quick-test.sh start-session.sh test-workflow.sh
rm -f end-session.sh run-with-env.sh
rm -f take-screenshot.sh clean-screenshots.sh
rm -f setup-session-simulator.sh get-bundle-id.sh quick-test-ios.sh
rm -f take-screenshot-ios.sh clean-screenshots-ios.sh cleanup-session-simulator.sh
echo -e "${GREEN}✅ Removed wrapper scripts${NC}"

echo -e "${YELLOW}🔗 Removing scripts-shared symlink...${NC}"
rm -f scripts-shared
echo -e "${GREEN}✅ Removed scripts-shared symlink${NC}"

echo -e "${YELLOW}📁 Copying missing essential files...${NC}"

# Copy Android local.properties if it exists
MAIN_REPO_PATH="/Users/miyawaki/Develop/osrswiki"
if [[ -f "$MAIN_REPO_PATH/platforms/android/local.properties" ]]; then
    cp "$MAIN_REPO_PATH/platforms/android/local.properties" platforms/android/
    echo -e "${GREEN}✅ Copied platforms/android/local.properties${NC}"
fi

# Copy asset-mapping.json if it exists
if [[ -f "$MAIN_REPO_PATH/shared/asset-mapping.json" ]]; then
    cp "$MAIN_REPO_PATH/shared/asset-mapping.json" shared/
    echo -e "${GREEN}✅ Copied shared/asset-mapping.json${NC}"
fi

# Create required empty directories
echo -e "${YELLOW}📁 Creating required empty directories...${NC}"
mkdir -p platforms/android/app/src/main/assets
echo -e "${GREEN}✅ Created platforms/android/app/src/main/assets${NC}"

echo -e "${YELLOW}📋 Final status:${NC}"
git status --porcelain | head -5

echo -e "${GREEN}✅ Worktree cleanup completed!${NC}"
echo ""
echo -e "${BLUE}💡 Usage in cleaned worktree:${NC}"
echo "   ./scripts/android/setup-session-device.sh     # Start Android emulator"
echo "   ./scripts/android/quick-test.sh               # Build and deploy Android app"  
echo "   ./scripts/ios/setup-session-simulator.sh      # Start iOS Simulator (macOS)"
echo "   ./scripts/shared/end-session.sh               # Clean up session"