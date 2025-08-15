#!/bin/bash
set -euo pipefail

# OSRS Wiki Emergency Backup Script
# Creates comprehensive backups of all repositories and critical data

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_TYPE="${1:-emergency}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/Backups/osrswiki/${BACKUP_TYPE}-${TIMESTAMP}"

echo -e "${BLUE}🚨 OSRS Wiki Emergency Backup System${NC}"
echo "======================================"
echo "Backup Type: $BACKUP_TYPE"
echo "Timestamp: $TIMESTAMP"
echo "Backup Directory: $BACKUP_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo -e "${YELLOW}📁 Created backup directory: $BACKUP_DIR${NC}"

# Function to backup a repository
backup_repository() {
    local repo_path="$1"
    local repo_name="$2"
    local bundle_name="$3"
    
    echo -e "${YELLOW}📦 Backing up $repo_name...${NC}"
    
    if [[ -d "$repo_path" ]] && [[ -d "$repo_path/.git" ]]; then
        cd "$repo_path"
        
        # Create git bundle with all refs, handle corrupted history gracefully
        if git bundle create "$BACKUP_DIR/${bundle_name}.bundle" --all 2>/dev/null; then
            echo -e "${GREEN}✅ $repo_name backup created${NC}"
            
            # Get some metadata
            COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "unknown")
            BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
            
            echo "  Commits: $COMMIT_COUNT"
            echo "  Current branch: $BRANCH"
            
            # Create metadata file
            cat > "$BACKUP_DIR/${bundle_name}.metadata" << EOF
Repository: $repo_name
Path: $repo_path
Backup Date: $(date)
Commit Count: $COMMIT_COUNT
Current Branch: $BRANCH
Working Directory Clean: $(git diff --quiet && git diff --cached --quiet && echo "yes" || echo "no")
EOF
            
        else
            echo -e "${YELLOW}⚠️  Git bundle failed for $repo_name, trying alternative backup...${NC}"
            # Fallback: create tar archive of the repository
            tar -czf "$BACKUP_DIR/${bundle_name}.tar.gz" -C "$(dirname "$repo_path")" "$(basename "$repo_path")" 2>/dev/null && \
                echo -e "${GREEN}✅ $repo_name backup created (tar archive)${NC}" || \
                echo -e "${RED}❌ Failed to backup $repo_name${NC}"
        fi
        
        cd - >/dev/null
    else
        echo -e "${YELLOW}⚠️  Repository $repo_name not found or invalid at $repo_path${NC}"
    fi
}

# Backup main monorepo
echo -e "${BLUE}🔄 Phase 1: Main Monorepo Backup${NC}"
echo "-------------------------------"

MONOREPO_PATH="/Users/miyawaki/Develop/osrswiki"
backup_repository "$MONOREPO_PATH" "Main Monorepo" "monorepo-main"

# Also backup from current location if we're somewhere else
if [[ "$(pwd)" != "$MONOREPO_PATH" ]] && [[ -f "CLAUDE.md" ]]; then
    backup_repository "$(pwd)" "Current Location" "monorepo-current"
fi

# Backup deployment repositories
echo -e "${BLUE}🔄 Phase 2: Deployment Repositories Backup${NC}"
echo "----------------------------------------"

DEPLOY_REPOS=("android" "ios" "tooling")
for platform in "${DEPLOY_REPOS[@]}"; do
    DEPLOY_PATH="$HOME/Deploy/osrswiki-$platform"
    backup_repository "$DEPLOY_PATH" "Deploy $platform" "deploy-$platform"
done

# Backup session directories (if they contain git repos)
echo -e "${BLUE}🔄 Phase 3: Active Sessions Backup${NC}"
echo "------------------------------"

if [[ -d "$HOME/Develop/osrswiki-sessions" ]]; then
    SESSION_COUNT=0
    for session_dir in "$HOME/Develop/osrswiki-sessions"/claude-*; do
        if [[ -d "$session_dir/.git" ]]; then
            SESSION_NAME=$(basename "$session_dir")
            backup_repository "$session_dir" "Session $SESSION_NAME" "session-$SESSION_NAME"
            ((SESSION_COUNT++))
        elif [[ -d "$session_dir" ]]; then
            # Not a git repo, but backup the contents anyway
            echo -e "${YELLOW}📁 Archiving session directory: $(basename "$session_dir")${NC}"
            tar -czf "$BACKUP_DIR/session-$(basename "$session_dir").tar.gz" -C "$HOME/Develop/osrswiki-sessions" "$(basename "$session_dir")"
            ((SESSION_COUNT++))
        fi
    done
    
    if [[ "$SESSION_COUNT" -eq 0 ]]; then
        echo -e "${YELLOW}ℹ️  No active sessions to backup${NC}"
    else
        echo -e "${GREEN}✅ Backed up $SESSION_COUNT sessions${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  No session directory found${NC}"
fi

# Backup critical configuration files
echo -e "${BLUE}🔄 Phase 4: Configuration Backup${NC}"
echo "------------------------------"

CONFIG_FILES=(
    "$MONOREPO_PATH/.gitignore:gitignore-main"
    "$MONOREPO_PATH/CLAUDE.md:claude-instructions"
    "$MONOREPO_PATH/.git/config:git-config-main"
    "$HOME/.gitconfig:git-config-user"
)

for config_spec in "${CONFIG_FILES[@]}"; do
    IFS=':' read -r file_path backup_name <<< "$config_spec"
    
    if [[ -f "$file_path" ]]; then
        cp "$file_path" "$BACKUP_DIR/${backup_name}.backup"
        echo -e "${GREEN}✅ Backed up: $(basename "$file_path")${NC}"
    else
        echo -e "${YELLOW}⚠️  Config file not found: $file_path${NC}"
    fi
done

# Create comprehensive system state snapshot
echo -e "${BLUE}🔄 Phase 5: System State Snapshot${NC}"
echo "------------------------------"

SYSTEM_INFO="$BACKUP_DIR/system-state.txt"
cat > "$SYSTEM_INFO" << EOF
OSRS Wiki Emergency Backup System State
========================================
Date: $(date)
User: $(whoami)
Hostname: $(hostname)
OS: $(uname -a)
Working Directory: $(pwd)

Git Configuration:
$(git --version)
$(git config --list --global | head -10)

Directory Structure:
$(find "$HOME" -maxdepth 3 -type d -name "*osrs*" 2>/dev/null | sort)

Disk Usage:
$(df -h "$HOME" | tail -1)

Repository Status (if in git repo):
$([[ -f "CLAUDE.md" ]] && git status --porcelain || echo "Not in main repository")

Recent Git Activity:
$([[ -f "CLAUDE.md" ]] && git log --oneline -10 || echo "Not in main repository")
EOF

echo -e "${GREEN}✅ System state snapshot created${NC}"

# Create restore instructions
echo -e "${BLUE}🔄 Phase 6: Restore Instructions${NC}"
echo "------------------------------"

RESTORE_SCRIPT="$BACKUP_DIR/RESTORE.sh"
cat > "$RESTORE_SCRIPT" << 'EOF'
#!/bin/bash
# Emergency Restore Script
# Generated automatically - review before use

echo "🚨 OSRS Wiki Emergency Restore"
echo "=============================="
echo "This script will help restore from backup."
echo "Review the commands before running them!"
echo ""

BACKUP_DIR="$(dirname "$0")"

echo "Available backups in this directory:"
ls -la "$BACKUP_DIR"/*.bundle 2>/dev/null || echo "No bundle files found"

echo ""
echo "To restore a repository from bundle:"
echo "1. Create/navigate to restore directory"
echo "2. Run: git clone <bundle-file> <directory-name>"
echo ""
echo "Example restore commands:"
echo "  git clone $BACKUP_DIR/monorepo-main.bundle restored-monorepo"
echo "  git clone $BACKUP_DIR/deploy-android.bundle restored-android-deploy"
echo ""
echo "⚠️  Always verify backup integrity before restoring!"
echo "⚠️  Consider backing up current state before restore!"

# Function to verify bundle integrity
verify_bundle() {
    local bundle_file="$1"
    echo "Verifying bundle: $bundle_file"
    git bundle verify "$bundle_file"
}

echo ""
echo "To verify bundle integrity:"
for bundle in "$BACKUP_DIR"/*.bundle; do
    if [[ -f "$bundle" ]]; then
        echo "  verify_bundle \"$bundle\""
    fi
done
EOF

chmod +x "$RESTORE_SCRIPT"
echo -e "${GREEN}✅ Restore instructions created${NC}"

# Calculate backup size
echo -e "${BLUE}🔄 Phase 7: Backup Summary${NC}"
echo "----------------------"

BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
BUNDLE_COUNT=$(find "$BACKUP_DIR" -name "*.bundle" | wc -l)
FILE_COUNT=$(find "$BACKUP_DIR" -type f | wc -l)

echo -e "${GREEN}📊 Backup Complete!${NC}"
echo "==================="
echo "Backup Directory: $BACKUP_DIR"
echo "Total Size: $BACKUP_SIZE"
echo "Bundle Files: $BUNDLE_COUNT"
echo "Total Files: $FILE_COUNT"
echo ""

echo -e "${BLUE}📋 Contents:${NC}"
ls -la "$BACKUP_DIR"

echo ""
echo -e "${GREEN}✅ Emergency backup completed successfully${NC}"
echo -e "${YELLOW}💾 Backup stored at: $BACKUP_DIR${NC}"
echo -e "${YELLOW}📖 Restore instructions: $RESTORE_SCRIPT${NC}"

# Optional: compress the entire backup (only for large backups or on request)
if [[ "${COMPRESS_BACKUP:-false}" == "true" ]] && command -v tar >/dev/null; then
    echo ""
    echo -e "${BLUE}🗜️  Creating compressed archive...${NC}"
    ARCHIVE_NAME="${BACKUP_DIR}.tar.gz"
    tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
    ARCHIVE_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
    echo -e "${GREEN}✅ Compressed archive created: $ARCHIVE_NAME ($ARCHIVE_SIZE)${NC}"
    echo -e "${YELLOW}💡 Set COMPRESS_BACKUP=true to enable automatic compression${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All backup operations completed successfully!${NC}"
exit 0