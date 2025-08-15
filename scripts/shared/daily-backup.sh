#!/bin/bash
set -euo pipefail

# OSRS Wiki Daily Automated Backup Script
# Runs via cron to create daily backups of all repositories

# Colors for output (may not display in cron)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_TYPE="daily-auto"
LOG_FILE="$HOME/Backups/osrswiki/daily-backup.log"
MAX_BACKUP_AGE_DAYS=30
MAX_LOG_LINES=1000
MAX_BACKUP_SIZE_GB=10  # Maximum total backup directory size in GB
BACKUP_BASE_DIR="$HOME/Backups/osrswiki"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log with timestamp
log() {
    echo "$(date --iso-8601=seconds): $*" >> "$LOG_FILE"
    echo "$*"  # Also output to stdout for debugging
}

# Function to log errors
log_error() {
    echo "$(date --iso-8601=seconds): ERROR: $*" >> "$LOG_FILE"
    echo -e "${RED}ERROR: $*${NC}" >&2
}

# Function to log success
log_success() {
    echo "$(date --iso-8601=seconds): SUCCESS: $*" >> "$LOG_FILE"
    echo -e "${GREEN}SUCCESS: $*${NC}"
}

# Function to log warning
log_warning() {
    echo "$(date --iso-8601=seconds): WARNING: $*" >> "$LOG_FILE"
    echo -e "${YELLOW}WARNING: $*${NC}"
}

# Start backup process
log "====================================="
log "OSRS Wiki Daily Backup Started"
log "====================================="

BACKUP_SUCCESS=true

# Function to backup a single repository
backup_repo() {
    local repo_path="$1"
    local repo_name="$2"
    
    if [[ -d "$repo_path/.git" ]]; then
        log "Backing up $repo_name from $repo_path"
        
        cd "$repo_path"
        local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "unknown")
        local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        
        log "  → Commits: $commit_count, Branch: $current_branch"
        
        # Return success - actual backup happens in emergency-backup.sh
        return 0
    else
        log_warning "$repo_name not found or not a git repository: $repo_path"
        return 1
    fi
}

# Check repository health before backup
log "Checking repository health..."

MAIN_REPO="/Users/miyawaki/Developer/osrswiki"
if [[ -d "$MAIN_REPO" && -f "$MAIN_REPO/CLAUDE.md" ]]; then
    cd "$MAIN_REPO"
    
    # Quick health check
    if git status >/dev/null 2>&1; then
        log_success "Main repository is accessible"
    else
        log_error "Main repository has git issues"
        BACKUP_SUCCESS=false
    fi
else
    log_error "Main repository not found at $MAIN_REPO"
    BACKUP_SUCCESS=false
fi

# Check deployment repositories
DEPLOY_REPOS=(
    "$HOME/Deploy/osrswiki-android:Android"
    "$HOME/Deploy/osrswiki-ios:iOS"
    "$HOME/Deploy/osrswiki-tooling:Tooling"
)

for repo_spec in "${DEPLOY_REPOS[@]}"; do
    IFS=':' read -r repo_path repo_name <<< "$repo_spec"
    if backup_repo "$repo_path" "$repo_name"; then
        log_success "$repo_name repository checked"
    else
        log_warning "$repo_name repository check failed"
    fi
done

# Create comprehensive backup if health checks passed
if [[ "$BACKUP_SUCCESS" == true ]]; then
    log "Starting comprehensive backup..."
    
    cd "$MAIN_REPO"
    if ./scripts/shared/emergency-backup.sh "$BACKUP_TYPE" >> "$LOG_FILE" 2>&1; then
        log_success "Daily backup completed successfully"
    else
        log_error "Daily backup failed"
        BACKUP_SUCCESS=false
    fi
else
    log_error "Skipping backup due to repository health issues"
fi

# Cleanup old backups
log "Cleaning up old backups (older than $MAX_BACKUP_AGE_DAYS days)..."
CLEANUP_COUNT=0

if [[ -d "$HOME/Backups/osrswiki" ]]; then
    while IFS= read -r -d '' backup_dir; do
        log "Removing old backup: $(basename "$backup_dir")"
        rm -rf "$backup_dir"
        ((CLEANUP_COUNT++))
    done < <(find "$HOME/Backups/osrswiki" -type d -name "*-auto-*" -mtime +$MAX_BACKUP_AGE_DAYS -print0 2>/dev/null)
    
    if [[ $CLEANUP_COUNT -gt 0 ]]; then
        log_success "Cleaned up $CLEANUP_COUNT old backups"
    else
        log "No old backups to clean up"
    fi
fi

# Cleanup log file if it gets too large
LOG_LINES=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
if [[ $LOG_LINES -gt $MAX_LOG_LINES ]]; then
    log "Rotating log file (current size: $LOG_LINES lines)"
    tail -n $((MAX_LOG_LINES/2)) "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
    log "Log file rotated"
fi

# Generate summary
TOTAL_BACKUPS=$(find "$HOME/Backups/osrswiki" -name "*backup*.bundle" 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$HOME/Backups/osrswiki" 2>/dev/null | cut -f1 || echo "unknown")

log "====================================="
log "Daily Backup Summary"
log "====================================="
log "Status: $(if [[ "$BACKUP_SUCCESS" == true ]]; then echo "SUCCESS"; else echo "FAILED"; fi)"
log "Total backups available: $TOTAL_BACKUPS"
log "Total backup size: $TOTAL_SIZE"
log "Log file: $LOG_FILE"
log "====================================="

# Email notification (if configured)
# Uncomment and configure if you want email notifications
# if command -v mail >/dev/null && [[ -n "${BACKUP_EMAIL:-}" ]]; then
#     SUBJECT="OSRS Wiki Daily Backup $(if [[ "$BACKUP_SUCCESS" == true ]]; then echo "Success"; else echo "Failed"; fi)"
#     echo "Daily backup completed at $(date). Check $LOG_FILE for details." | mail -s "$SUBJECT" "$BACKUP_EMAIL"
# fi

# Set exit code based on success
if [[ "$BACKUP_SUCCESS" == true ]]; then
    log "Daily backup process completed successfully"
    exit 0
else
    log_error "Daily backup process failed"
    exit 1
fi