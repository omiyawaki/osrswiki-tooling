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
MAX_LOG_LINES=1000
MAX_BACKUP_SIZE_GB=10  # Maximum total backup directory size in GB
BACKUP_BASE_DIR="$HOME/Backups/osrswiki"

# Tiered retention policy (in days)
DAILY_RETENTION_DAYS=7      # Keep daily backups for 7 days
WEEKLY_RETENTION_DAYS=30    # Keep weekly backups for 30 days  
MONTHLY_RETENTION_DAYS=90   # Keep monthly backups for 90 days
EMERGENCY_RETENTION_DAYS=14 # Keep emergency backups for 14 days

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

# Function to get directory size in GB
get_size_gb() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -s "$dir" 2>/dev/null | awk '{printf "%.2f", $1/1024/1024}'
    else
        echo "0"
    fi
}

# Function to cleanup empty or failed backups
cleanup_failed_backups() {
    local cleaned=0
    
    log "Checking for empty or failed backups..."
    
    if [[ -d "$BACKUP_BASE_DIR" ]]; then
        while IFS= read -r -d '' backup_dir; do
            local backup_name=$(basename "$backup_dir")
            local backup_size=$(du -s "$backup_dir" 2>/dev/null | awk '{print $1}')
            
            # Remove if backup is empty (less than 1MB = 1024 KB)
            if [[ $backup_size -lt 1024 ]]; then
                log "Removing empty/failed backup: $backup_name"
                rm -rf "$backup_dir"
                ((cleaned++))
            fi
        done < <(find "$BACKUP_BASE_DIR" -type d -name "*-auto-*" -o -name "*deploy-*" -o -name "*emergency-*" -print0 2>/dev/null)
        
        # Also remove empty tar.gz files
        while IFS= read -r -d '' tar_file; do
            local file_size=$(stat -f%z "$tar_file" 2>/dev/null || echo "0")
            if [[ $file_size -lt 1048576 ]]; then  # Less than 1MB
                log "Removing empty archive: $(basename "$tar_file")"
                rm -f "$tar_file"
                ((cleaned++))
            fi
        done < <(find "$BACKUP_BASE_DIR" -name "*.tar.gz" -print0 2>/dev/null)
    fi
    
    if [[ $cleaned -gt 0 ]]; then
        log_success "Cleaned up $cleaned empty/failed backups"
    fi
}

# Function to implement tiered retention policy
tiered_retention_cleanup() {
    local cleaned=0
    local current_date=$(date +%s)
    
    log "Applying tiered retention policy..."
    
    if [[ -d "$BACKUP_BASE_DIR" ]]; then
        # Clean daily backups (auto) older than DAILY_RETENTION_DAYS
        while IFS= read -r -d '' backup_dir; do
            local backup_age_seconds=$((current_date - $(stat -f%m "$backup_dir")))
            local backup_age_days=$((backup_age_seconds / 86400))
            
            if [[ $backup_age_days -gt $DAILY_RETENTION_DAYS ]]; then
                log "Removing old daily backup: $(basename "$backup_dir") (${backup_age_days} days old)"
                rm -rf "$backup_dir"
                
                # Also remove associated tar.gz file
                local tar_file="${backup_dir}.tar.gz"
                if [[ -f "$tar_file" ]]; then
                    rm -f "$tar_file"
                    log "Removed associated archive: $(basename "$tar_file")"
                fi
                
                ((cleaned++))
            fi
        done < <(find "$BACKUP_BASE_DIR" -type d -name "*-auto-*" -print0 2>/dev/null)
        
        # Clean deployment backups older than WEEKLY_RETENTION_DAYS
        while IFS= read -r -d '' backup_dir; do
            local backup_age_seconds=$((current_date - $(stat -f%m "$backup_dir")))
            local backup_age_days=$((backup_age_seconds / 86400))
            
            if [[ $backup_age_days -gt $WEEKLY_RETENTION_DAYS ]]; then
                log "Removing old deployment backup: $(basename "$backup_dir") (${backup_age_days} days old)"
                rm -rf "$backup_dir"
                
                # Also remove associated tar.gz file
                local tar_file="${backup_dir}.tar.gz"
                if [[ -f "$tar_file" ]]; then
                    rm -f "$tar_file"
                    log "Removed associated archive: $(basename "$tar_file")"
                fi
                
                ((cleaned++))
            fi
        done < <(find "$BACKUP_BASE_DIR" -type d -name "*deploy-*" -print0 2>/dev/null)
        
        # Clean emergency backups older than EMERGENCY_RETENTION_DAYS
        while IFS= read -r -d '' backup_dir; do
            local backup_age_seconds=$((current_date - $(stat -f%m "$backup_dir")))
            local backup_age_days=$((backup_age_seconds / 86400))
            
            if [[ $backup_age_days -gt $EMERGENCY_RETENTION_DAYS ]]; then
                log "Removing old emergency backup: $(basename "$backup_dir") (${backup_age_days} days old)"
                rm -rf "$backup_dir"
                
                # Also remove associated tar.gz file
                local tar_file="${backup_dir}.tar.gz"
                if [[ -f "$tar_file" ]]; then
                    rm -f "$tar_file"
                    log "Removed associated archive: $(basename "$tar_file")"
                fi
                
                ((cleaned++))
            fi
        done < <(find "$BACKUP_BASE_DIR" -type d -name "*emergency-*" -print0 2>/dev/null)
    fi
    
    if [[ $cleaned -gt 0 ]]; then
        log_success "Tiered retention cleanup: removed $cleaned backups"
    else
        log "No backups exceeded retention policies"
    fi
}

# Function to enforce size-based cleanup
enforce_size_limit() {
    local current_size_gb=$(get_size_gb "$BACKUP_BASE_DIR")
    local cleaned=0
    
    log "Current backup directory size: ${current_size_gb}GB (limit: ${MAX_BACKUP_SIZE_GB}GB)"
    
    if (( $(echo "$current_size_gb > $MAX_BACKUP_SIZE_GB" | bc -l) )); then
        log_warning "Backup directory exceeds size limit, starting size-based cleanup..."
        
        # Get all backup directories sorted by modification time (oldest first)
        local backup_dirs=()
        while IFS= read -r -d '' backup_dir; do
            backup_dirs+=("$backup_dir")
        done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d \( -name "*-auto-*" -o -name "*deploy-*" -o -name "*emergency-*" \) -print0 2>/dev/null | xargs -0 ls -1dt | tac)
        
        # Remove oldest backups until under limit
        for backup_dir in "${backup_dirs[@]}"; do
            current_size_gb=$(get_size_gb "$BACKUP_BASE_DIR")
            if (( $(echo "$current_size_gb <= $MAX_BACKUP_SIZE_GB" | bc -l) )); then
                break
            fi
            
            local backup_name=$(basename "$backup_dir")
            local backup_size_gb=$(get_size_gb "$backup_dir")
            
            log "Removing old backup for size limit: $backup_name (${backup_size_gb}GB)"
            rm -rf "$backup_dir"
            
            # Also remove associated tar.gz file
            local tar_file="${backup_dir}.tar.gz"
            if [[ -f "$tar_file" ]]; then
                rm -f "$tar_file"
                log "Removed associated archive: $(basename "$tar_file")"
            fi
            
            ((cleaned++))
        done
        
        current_size_gb=$(get_size_gb "$BACKUP_BASE_DIR")
        log_success "Size-based cleanup completed: removed $cleaned backups, new size: ${current_size_gb}GB"
    else
        log "Backup directory size within limit"
    fi
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

# Cleanup phase - multiple cleanup strategies
log "====================================="
log "Starting Backup Cleanup Phase"
log "====================================="

# Step 1: Clean up empty or failed backups first
cleanup_failed_backups

# Step 2: Tiered retention policy cleanup (new)
tiered_retention_cleanup

# Step 3: Size-based cleanup (fallback)
enforce_size_limit

# Cleanup log file if it gets too large
LOG_LINES=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
if [[ $LOG_LINES -gt $MAX_LOG_LINES ]]; then
    log "Rotating log file (current size: $LOG_LINES lines)"
    tail -n $((MAX_LOG_LINES/2)) "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
    log "Log file rotated"
fi

# Generate summary
TOTAL_BACKUPS=$(find "$BACKUP_BASE_DIR" -name "*.bundle" 2>/dev/null | wc -l)
TOTAL_DIRECTORIES=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d \( -name "*-auto-*" -o -name "*deploy-*" -o -name "*emergency-*" \) 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$BACKUP_BASE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
TOTAL_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")

log "====================================="
log "Daily Backup Summary"
log "====================================="
log "Status: $(if [[ "$BACKUP_SUCCESS" == true ]]; then echo "SUCCESS"; else echo "FAILED"; fi)"
log "Total backup directories: $TOTAL_DIRECTORIES"
log "Total bundle files: $TOTAL_BACKUPS"
log "Total backup size: $TOTAL_SIZE (${TOTAL_SIZE_GB}GB)"
log "Size limit: ${MAX_BACKUP_SIZE_GB}GB"
log "Retention policies:"
log "  - Daily backups: ${DAILY_RETENTION_DAYS} days"
log "  - Deployment backups: ${WEEKLY_RETENTION_DAYS} days"
log "  - Emergency backups: ${EMERGENCY_RETENTION_DAYS} days"
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