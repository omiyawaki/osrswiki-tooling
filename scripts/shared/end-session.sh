#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Ending Claude Code session...${NC}"

# Force cleanup flag
FORCE_CLEANUP=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE_CLEANUP=true
    echo -e "${YELLOW}⚡ Force cleanup mode enabled${NC}"
fi

# Detect session type and clean up appropriately
session_cleaned=false

# Clean up Android device if we're in an Android session
if [[ -f .claude-session-device ]]; then
    echo -e "${YELLOW}📱 Detected Android session, cleaning up device...${NC}"
    if [[ "$FORCE_CLEANUP" == "true" ]]; then
        ./scripts/android/cleanup-android-device.sh --force
    else
        ./scripts/android/cleanup-android-device.sh
    fi
    session_cleaned=true
fi

# Clean up iOS simulator if we're in an iOS session
if [[ -f .claude-session-simulator ]]; then
    echo -e "${YELLOW}📱 Detected iOS session, cleaning up simulator...${NC}"
    if [[ "$FORCE_CLEANUP" == "true" ]]; then
        ./scripts/ios/cleanup-session-simulator.sh --force 2>/dev/null || ./scripts/ios/cleanup-session-simulator.sh
    else
        ./scripts/ios/cleanup-session-simulator.sh
    fi
    session_cleaned=true
fi

# Check for orphaned session files if no specific session was detected
if [[ "$session_cleaned" == "false" ]]; then
    echo -e "${YELLOW}🔍 No active session detected, checking for orphaned files...${NC}"
    
    ORPHANED_FILES=($(find . -maxdepth 1 -name ".claude-*" 2>/dev/null || true))
    if [[ ${#ORPHANED_FILES[@]} -gt 0 ]]; then
        echo -e "${YELLOW}   Found orphaned Claude session files:${NC}"
        for file in "${ORPHANED_FILES[@]}"; do
            echo "      • $file"
        done
        
        if [[ "$FORCE_CLEANUP" == "true" ]]; then
            echo -e "${YELLOW}   Force cleanup mode: removing orphaned files...${NC}"
            rm -f .claude-*
            echo -e "${GREEN}   ✅ Orphaned session files cleaned${NC}"
        else
            echo -e "${BLUE}   💡 Run with --force to clean orphaned session files${NC}"
        fi
    else
        echo -e "${GREEN}   ✅ No orphaned session files found${NC}"
    fi
fi

# Clean up worktree session
echo -e "${YELLOW}🌿 Cleaning up worktree...${NC}"
./scripts/shared/cleanup-worktree.sh

# Optional: Check for system-wide orphaned emulators
echo ""
echo -e "${BLUE}🔍 Checking for system-wide orphaned emulators...${NC}"
if command -v avdmanager >/dev/null 2>&1; then
    ORPHANED_EMULATORS=($(avdmanager list avd | grep "Name: test-claude-" | sed 's/^.*Name: //' || true))
    SESSIONS_DIR="$HOME/Develop/osrswiki-sessions"
    ACTIVE_SESSIONS=()
    if [[ -d "$SESSIONS_DIR" ]]; then
        ACTIVE_SESSIONS=($(find "$SESSIONS_DIR" -maxdepth 1 -type d -name "claude-*" -exec basename {} \; 2>/dev/null || true))
    fi
    
    # Count truly orphaned emulators
    TRULY_ORPHANED=0
    for emulator in "${ORPHANED_EMULATORS[@]}"; do
        session_name="${emulator#test-}"
        is_orphaned=true
        for active_session in "${ACTIVE_SESSIONS[@]}"; do
            if [[ "$session_name" == "$active_session" ]]; then
                is_orphaned=false
                break
            fi
        done
        if [[ "$is_orphaned" == "true" ]]; then
            ((TRULY_ORPHANED++))
        fi
    done
    
    if [[ $TRULY_ORPHANED -gt 0 ]]; then
        echo -e "${YELLOW}   ⚠️  Found $TRULY_ORPHANED orphaned emulators system-wide${NC}"
        echo -e "${BLUE}   💡 Run: ./scripts/shared/cleanup-orphaned-emulators.sh${NC}"
    else
        echo -e "${GREEN}   ✅ No orphaned emulators found system-wide${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  avdmanager not available, skipping emulator check${NC}"
fi

echo ""
echo -e "${GREEN}✅ Session ended and cleaned up${NC}"
if [[ "$FORCE_CLEANUP" == "true" ]]; then
    echo -e "${BLUE}💡 Force cleanup was used - all locked resources were removed${NC}"
fi