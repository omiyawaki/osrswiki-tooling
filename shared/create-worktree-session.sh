#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Must be run from project root directory (where CLAUDE.md is located)
if [[ ! -f CLAUDE.md ]]; then
    echo -e "${RED}❌ Must run from project root directory (where CLAUDE.md is located)${NC}"
    exit 1
fi

# Safety check: ensure we're not inside a worktree
if [[ -f ".git" ]] && grep -q "gitdir:" ".git" 2>/dev/null; then
    echo -e "${RED}❌ Cannot create worktree from inside another worktree${NC}"
    echo "Run this script from the main repository root"
    exit 1
fi

TOPIC="${1:-development}"
SESSION_NAME="claude-$(date +%Y%m%d-%H%M%S)-$TOPIC"
BRANCH_NAME="claude/$(date +%Y%m%d-%H%M%S)-$TOPIC"

# NEW: Use dedicated sessions directory outside main repo
SESSION_PARENT="$HOME/Develop/osrswiki-sessions"
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

# Create worktree with new branch (from current repo)
echo -e "${YELLOW}🔨 Creating git worktree...${NC}"
git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME"

# Set up shared scripts in worktree
cd "$WORKTREE_DIR"

# Verify platforms directory is present (should be included since it's tracked in git)
if [[ ! -d "platforms/android" || ! -d "platforms/ios" ]]; then
    echo -e "${RED}⚠️  Warning: platforms/ directory missing from worktree${NC}"
    echo "This may indicate an issue with git tracking. Platforms should be available for development."
else
    echo -e "${GREEN}✅ Platforms directory verified in worktree${NC}"
fi

# Create symlink to shared scripts directory 
# NOTE: Worktree is now in ~/Develop/osrswiki-sessions/, main repo is in ~/Develop/osrswiki/
MAIN_REPO_PATH="/Users/miyawaki/Develop/osrswiki"
echo -e "${YELLOW}🔗 Creating symlink to main repository scripts...${NC}"
ln -sf "$MAIN_REPO_PATH/scripts" scripts-shared

# Create simple wrapper scripts that call the originals with correct paths
# This avoids copying and path modification complexity

# Android wrapper scripts
echo -e "${YELLOW}📄 Creating wrapper scripts...${NC}"
cat > setup-session-device.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/setup-session-device.sh "$@"
EOF

cat > setup-container-device.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/setup-container-device.sh "$@"
EOF

cat > get-app-id.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/get-app-id.sh "$@"
EOF

cat > quick-test.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/quick-test.sh "$@"
EOF

cat > start-session.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/start-session.sh "$@"
EOF

cat > test-workflow.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/test-workflow.sh "$@"
EOF

# Shared wrapper scripts
cat > end-session.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/shared/end-session.sh "$@"
EOF

cat > run-with-env.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/shared/run-with-env.sh "$@"
EOF

# Create screenshots directory for organized screenshot management
mkdir -p screenshots
echo "# Screenshot session metadata" > screenshots/.gitkeep
echo "# Session: $SESSION_NAME" >> screenshots/.gitkeep
echo "# Created: $(date --iso-8601=seconds)" >> screenshots/.gitkeep

# Screenshot management wrapper scripts (Android)
cat > take-screenshot.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/take-screenshot.sh "$@"
EOF

cat > clean-screenshots.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/android/clean-screenshots.sh "$@"
EOF

# iOS wrapper scripts
cat > setup-session-simulator.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/setup-session-simulator.sh "$@"
EOF

cat > get-bundle-id.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/get-bundle-id.sh "$@"
EOF

cat > quick-test-ios.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/quick-test.sh "$@"
EOF

cat > take-screenshot-ios.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/take-screenshot.sh "$@"
EOF

cat > clean-screenshots-ios.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/clean-screenshots.sh "$@"
EOF

cat > cleanup-session-simulator.sh << 'EOF'
#!/bin/bash
exec ./scripts-shared/ios/cleanup-session-simulator.sh "$@"
EOF

# Make wrapper scripts executable
chmod +x *.sh

echo -e "${GREEN}✅ Worktree session ready!${NC}"
echo ""
echo -e "${BLUE}💡 To use this session:${NC}"
echo "   cd $WORKTREE_DIR"
echo ""
echo -e "${YELLOW}   # Android Development:${NC}"
echo "   ./setup-session-device.sh     # Start Android emulator (15s)"
echo "   ./setup-container-device.sh   # Container-optimized Android setup"
echo "   source .claude-env             # Load Android environment variables"
echo "   ./quick-test.sh               # Build and deploy Android app (5s each)"
echo "   ./take-screenshot.sh          # Take Android screenshot"
echo ""
echo -e "${YELLOW}   # iOS Development (macOS only):${NC}"
echo "   ./setup-session-simulator.sh  # Start iOS Simulator"
echo "   source .claude-env             # Load iOS environment variables"
echo "   ./quick-test-ios.sh           # Build and deploy iOS app"
echo "   ./take-screenshot-ios.sh      # Take iOS screenshot"
echo "   ./get-bundle-id.sh            # Get iOS bundle identifier"
echo ""
echo "   # ... develop ..."
echo "   ./end-session.sh             # Clean up session"
echo ""
echo -e "${BLUE}💡 To remove session from main repo:${NC}"
echo "   cd /Users/miyawaki/Developer/osrswiki"
echo "   git worktree remove $WORKTREE_DIR"
