#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Use find-git-repo.sh for robust repository discovery
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/find-git-repo.sh"

# Discover repository locations
if ! REPO_CONTEXT=$(validate_repo_context); then
    echo -e "${RED}❌ Repository discovery failed${NC}"
    echo "$REPO_CONTEXT"
    echo "Run this script from within the osrswiki project structure"
    exit 1
fi

# Parse repository context
eval "$REPO_CONTEXT"
GIT_ROOT="$REPO_ROOT"
PROJECT_ROOT="$PARENT_DIR"

echo -e "${GREEN}✅ Repository discovered:${NC}"
echo "   Git root: $GIT_ROOT"
echo "   Project root: $PROJECT_ROOT"

# Safety check: ensure we're not inside a worktree
if [[ -f ".git" ]] && grep -q "gitdir:" ".git" 2>/dev/null; then
    echo -e "${RED}❌ Cannot create worktree from inside another worktree${NC}"
    echo "Run this script from the main repository root"
    exit 1
fi

TOPIC="${1:-development}"
SESSION_NAME="claude-$(date +%Y%m%d-%H%M%S)-$TOPIC"
BRANCH_NAME="claude/$(date +%Y%m%d-%H%M%S)-$TOPIC"

# NEW: Use dedicated sessions directory within project
SESSION_PARENT="$PROJECT_ROOT/sessions"
WORKTREE_DIR="$SESSION_PARENT/$SESSION_NAME"

# Ensure sessions directory exists
if [[ ! -d "$SESSION_PARENT" ]]; then
    echo -e "${YELLOW}📁 Creating sessions directory: $SESSION_PARENT${NC}"
    mkdir -p "$SESSION_PARENT"
fi

echo -e "${BLUE}🌿 Creating worktree session: $SESSION_NAME${NC}"
echo -e "${BLUE}📁 Directory: $WORKTREE_DIR${NC}" 
echo -e "${BLUE}🌿 Branch: $BRANCH_NAME${NC}"

# Safety check: ensure directory doesn't already exist
if [[ -d "$WORKTREE_DIR" ]]; then
    echo -e "${RED}❌ Session directory already exists: $WORKTREE_DIR${NC}"
    echo "Choose a different topic name or remove the existing directory"
    exit 1
fi

# Create worktree with new branch (from git repo)
echo -e "${YELLOW}🔨 Creating git worktree...${NC}"
cd "$GIT_ROOT" && git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME"

# Set up shared scripts in worktree
cd "$WORKTREE_DIR"

# Verify platforms directory is present (should be included since it's tracked in git)
if [[ ! -d "platforms/android" || ! -d "platforms/ios" ]]; then
    echo -e "${RED}⚠️  Warning: platforms/ directory missing from worktree${NC}"
    echo "This may indicate an issue with git tracking. Platforms should be available for development."
else
    echo -e "${GREEN}✅ Platforms directory verified in worktree${NC}"
fi

# Copy essential untracked files from main repo
MAIN_REPO_PATH="$GIT_ROOT"
CACHE_BASE="$PROJECT_ROOT/cache"
echo -e "${YELLOW}📁 Copying essential untracked files...${NC}"

# Copy Android local.properties if it exists (contains SDK path)
if [[ -f "$MAIN_REPO_PATH/platforms/android/local.properties" ]]; then
    cp "$MAIN_REPO_PATH/platforms/android/local.properties" platforms/android/
    echo -e "${GREEN}✅ Copied platforms/android/local.properties${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: local.properties not found in main repo${NC}"
fi

# Copy asset-mapping.json if it exists (for asset management)
if [[ -f "$MAIN_REPO_PATH/shared/asset-mapping.json" ]]; then
    cp "$MAIN_REPO_PATH/shared/asset-mapping.json" shared/
    echo -e "${GREEN}✅ Copied shared/asset-mapping.json${NC}"
else
    echo -e "${YELLOW}⚠️  asset-mapping.json not found in main repo${NC}"
fi

# Check centralized cache availability
echo -e "${YELLOW}📦 Checking centralized asset cache...${NC}"
if [[ -d "$CACHE_BASE" ]]; then
    # Count available cache assets
    mbtiles_count=$(find "$CACHE_BASE/binary-assets/mbtiles" -name "*.mbtiles" 2>/dev/null | wc -l)
    cache_size=$(du -sh "$CACHE_BASE" 2>/dev/null | cut -f1 || echo "unknown")
    
    echo -e "${GREEN}✅ Centralized cache found: $CACHE_BASE${NC}"
    echo -e "${GREEN}   • Binary assets: $mbtiles_count .mbtiles files${NC}"
    echo -e "${GREEN}   • Cache size: $cache_size${NC}"
    echo -e "${GREEN}   • Build system will auto-discover cache assets${NC}"
else
    echo -e "${YELLOW}⚠️  Centralized cache not found at $CACHE_BASE${NC}"
    echo -e "${YELLOW}   • Binary assets (.mbtiles) may be missing${NC}"
    echo -e "${YELLOW}   • Run asset generator if map functionality needed${NC}"
fi

# Create required empty directories that git doesn't track
echo -e "${YELLOW}📁 Creating required empty directories...${NC}"
mkdir -p platforms/android/app/src/main/assets
echo -e "${GREEN}✅ Created platforms/android/app/src/main/assets${NC}"

# Create screenshots directory for organized screenshot management
mkdir -p screenshots
echo "# Screenshot session metadata" > screenshots/.gitkeep
echo "# Session: $SESSION_NAME" >> screenshots/.gitkeep
echo "# Created: $(date '+%Y-%m-%dT%H:%M:%S%z')" >> screenshots/.gitkeep

echo -e "${GREEN}✅ Worktree session ready!${NC}"
echo ""
echo -e "${BLUE}💡 To use this session:${NC}"
echo "   cd $WORKTREE_DIR"
echo ""
echo -e "${YELLOW}   # Android Development:${NC}"
echo "   ./scripts/android/setup-session-device.sh     # Start Android emulator (15s)"
echo "   ./scripts/android/setup-container-device.sh   # Container-optimized Android setup"
echo "   source .claude-env                             # Load Android environment variables"
echo "   ./scripts/android/quick-test.sh               # Build and deploy Android app (5s)"
echo "   ./scripts/android/take-screenshot.sh          # Take Android screenshot"
echo ""
echo -e "${YELLOW}   # iOS Development (macOS only):${NC}"
echo "   📖 REQUIRED: Read ./scripts/ios/XCTest-GUIDE.md first!"
echo "   ./scripts/ios/setup-session-simulator.sh      # Start iOS Simulator"
echo "   source .claude-env                             # Load iOS environment variables"
echo "   ./scripts/ios/quick-test.sh                   # Build and deploy iOS app"
echo "   ./scripts/ios/automate-app-testing.sh write-test ui MyFeature # WRITE tests first"
echo "   ./scripts/ios/automate-app-testing.sh quick-map # Test with XCTest framework"
echo "   ./scripts/ios/get-bundle-id.sh                # Get iOS bundle identifier"
echo ""
echo "   # ... develop ..."
echo "   ./scripts/shared/end-session.sh               # Clean up session"
echo ""
echo -e "${BLUE}💡 To remove session from main repo:${NC}"
echo "   cd $PROJECT_ROOT"
echo "   git worktree remove $WORKTREE_DIR"
