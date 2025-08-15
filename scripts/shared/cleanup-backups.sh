#!/bin/bash
set -euo pipefail

# OSRS Wiki Backup Cleanup Script
# Manual cleanup tool for backup directory management

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_BASE_DIR="$HOME/Backups/osrswiki"
DEFAULT_MAX_SIZE_GB=10
DEFAULT_MAX_AGE_DAYS=30

# Command line options
DRY_RUN=false
AGGRESSIVE=false
PRESERVE_EMERGENCY=true
MAX_SIZE_GB=$DEFAULT_MAX_SIZE_GB
MAX_AGE_DAYS=$DEFAULT_MAX_AGE_DAYS
SHOW_HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --aggressive)
            AGGRESSIVE=true
            shift
            ;;
        --no-preserve-emergency)
            PRESERVE_EMERGENCY=false
            shift
            ;;
        --max-size)
            MAX_SIZE_GB="$2"
            shift 2
            ;;
        --max-age)
            MAX_AGE_DAYS="$2"
            shift 2
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            SHOW_HELP=true
            shift
            ;;
    esac
done

# Show help
if [[ "$SHOW_HELP" == true ]]; then
    echo -e "${BLUE}🧹 OSRS Wiki Backup Cleanup Tool${NC}"
    echo "================================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run                    Show what would be deleted without actually deleting"
    echo "  --aggressive                 More aggressive cleanup (remove recent backups if needed)"
    echo "  --no-preserve-emergency      Include emergency backups in cleanup"
    echo "  --max-size GB               Set maximum total size in GB (default: $DEFAULT_MAX_SIZE_GB)"
    echo "  --max-age DAYS              Set maximum age in days (default: $DEFAULT_MAX_AGE_DAYS)"
    echo "  --help, -h                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --dry-run                # Preview what would be cleaned"
    echo "  $0 --max-size 5             # Clean to 5GB limit"
    echo "  $0 --aggressive --max-age 7 # Aggressive cleanup, keep only 7 days"
    echo ""
    exit 0
fi

echo -e "${BLUE}🧹 OSRS Wiki Backup Cleanup Tool${NC}"
echo "================================="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be deleted${NC}"
    echo ""
fi

# Function to get directory size in GB
get_size_gb() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -s "$dir" 2>/dev/null | awk '{printf "%.2f", $1/1024/1024}'
    else
        echo "0"
    fi
}

# Function to safely remove directory or file
safe_remove() {
    local target="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}[DRY RUN] Would remove: $description${NC}"
    else
        echo -e "  ${RED}Removing: $description${NC}"
        rm -rf "$target"
    fi
}

# Check if backup directory exists
if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
    echo -e "${RED}❌ Backup directory not found: $BACKUP_BASE_DIR${NC}"
    exit 1
fi

# Show current status
CURRENT_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")
echo -e "${BLUE}📊 Current Status:${NC}"
echo "Backup directory: $BACKUP_BASE_DIR"
echo "Current size: ${CURRENT_SIZE_GB}GB"
echo "Target size limit: ${MAX_SIZE_GB}GB"
echo "Max age: ${MAX_AGE_DAYS} days"
echo "Preserve emergency backups: $PRESERVE_EMERGENCY"
echo "Aggressive mode: $AGGRESSIVE"
echo ""

# Count different types of backups
AUTO_BACKUPS=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*-auto-*" 2>/dev/null | sort))
DEPLOY_BACKUPS=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*deploy-*" 2>/dev/null | sort))
EMERGENCY_BACKUPS=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*emergency-*" 2>/dev/null | sort))

echo -e "${BLUE}📋 Backup Inventory:${NC}"
echo "Daily automated backups: ${#AUTO_BACKUPS[@]}"
echo "Deployment backups: ${#DEPLOY_BACKUPS[@]}"
echo "Emergency/manual backups: ${#EMERGENCY_BACKUPS[@]}"
echo ""

# Phase 1: Remove empty or failed backups
echo -e "${BLUE}🗑️  Phase 1: Cleaning Empty/Failed Backups${NC}"
echo "----------------------------------------"

CLEANED_EMPTY=0
ALL_BACKUPS=($(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d \( -name "*-auto-*" -o -name "*deploy-*" -o -name "*emergency-*" \) 2>/dev/null))

for backup_dir in "${ALL_BACKUPS[@]}"; do
    if [[ -d "$backup_dir" ]]; then
        backup_size=$(du -s "$backup_dir" 2>/dev/null | awk '{print $1}')
        
        # Remove if backup is empty (less than 1MB = 1024 KB)
        if [[ $backup_size -lt 1024 ]]; then
            safe_remove "$backup_dir" "Empty backup: $(basename "$backup_dir")"
            
            # Also remove associated tar.gz file
            tar_file="${backup_dir}.tar.gz"
            if [[ -f "$tar_file" ]]; then
                safe_remove "$tar_file" "Associated archive: $(basename "$tar_file")"
            fi
            
            ((CLEANED_EMPTY++))
        fi
    fi
done

# Also clean empty tar.gz files
while IFS= read -r -d '' tar_file; do
    if [[ -f "$tar_file" ]]; then
        file_size=$(stat -f%z "$tar_file" 2>/dev/null || echo "0")
        if [[ $file_size -lt 1048576 ]]; then  # Less than 1MB
            safe_remove "$tar_file" "Empty archive: $(basename "$tar_file")"
            ((CLEANED_EMPTY++))
        fi
    fi
done < <(find "$BACKUP_BASE_DIR" -name "*.tar.gz" -print0 2>/dev/null)

echo "Cleaned empty/failed backups: $CLEANED_EMPTY"
echo ""

# Phase 2: Age-based cleanup
echo -e "${BLUE}📅 Phase 2: Age-Based Cleanup${NC}"
echo "----------------------------"

CLEANED_OLD=0

# Create list of backups to clean by age
BACKUPS_TO_CLEAN=()

# Always clean old auto backups
while IFS= read -r -d '' old_backup; do
    BACKUPS_TO_CLEAN+=("$old_backup")
done < <(find "$BACKUP_BASE_DIR" -type d -name "*-auto-*" -mtime +$MAX_AGE_DAYS -print0 2>/dev/null)

# Clean old deploy backups
while IFS= read -r -d '' old_backup; do
    BACKUPS_TO_CLEAN+=("$old_backup")
done < <(find "$BACKUP_BASE_DIR" -type d -name "*deploy-*" -mtime +$MAX_AGE_DAYS -print0 2>/dev/null)

# Clean old emergency backups if not preserving them
if [[ "$PRESERVE_EMERGENCY" == false ]]; then
    while IFS= read -r -d '' old_backup; do
        BACKUPS_TO_CLEAN+=("$old_backup")
    done < <(find "$BACKUP_BASE_DIR" -type d -name "*emergency-*" -mtime +$MAX_AGE_DAYS -print0 2>/dev/null)
fi

# Remove old backups
if [[ ${#BACKUPS_TO_CLEAN[@]} -gt 0 ]]; then
    for backup_dir in "${BACKUPS_TO_CLEAN[@]}"; do
    if [[ -d "$backup_dir" ]]; then
        backup_age_days=$(echo "($(date +%s) - $(stat -f%m "$backup_dir")) / 86400" | bc)
        safe_remove "$backup_dir" "Old backup: $(basename "$backup_dir") (${backup_age_days} days old)"
        
        # Also remove associated tar.gz file
        tar_file="${backup_dir}.tar.gz"
        if [[ -f "$tar_file" ]]; then
            safe_remove "$tar_file" "Associated archive: $(basename "$tar_file")"
        fi
        
        ((CLEANED_OLD++))
    fi
    done
fi

echo "Cleaned old backups: $CLEANED_OLD"
echo ""

# Phase 3: Size-based cleanup
echo -e "${BLUE}💾 Phase 3: Size-Based Cleanup${NC}"
echo "-----------------------------"

CURRENT_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")
CLEANED_SIZE=0

echo "Current size after previous cleanup: ${CURRENT_SIZE_GB}GB"

if (( $(echo "$CURRENT_SIZE_GB > $MAX_SIZE_GB" | bc -l) )); then
    echo "Size limit exceeded, starting size-based cleanup..."
    
    # Get all remaining backup directories sorted by modification time (oldest first)
    BACKUP_CANDIDATES=()
    
    # Start with deploy backups (usually largest and less critical)
    while IFS= read -r backup_dir; do
        BACKUP_CANDIDATES+=("$backup_dir")
    done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*deploy-*" 2>/dev/null | xargs ls -1dt 2>/dev/null | tac)
    
    # Then auto backups if aggressive mode or still over limit
    if [[ "$AGGRESSIVE" == true ]]; then
        while IFS= read -r backup_dir; do
            BACKUP_CANDIDATES+=("$backup_dir")
        done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*-auto-*" 2>/dev/null | xargs ls -1dt 2>/dev/null | tac)
    fi
    
    # Finally emergency backups if not preserving them
    if [[ "$PRESERVE_EMERGENCY" == false ]]; then
        while IFS= read -r backup_dir; do
            BACKUP_CANDIDATES+=("$backup_dir")
        done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*emergency-*" 2>/dev/null | xargs ls -1dt 2>/dev/null | tac)
    fi
    
    # Remove oldest backups until under size limit
    for backup_dir in "${BACKUP_CANDIDATES[@]}"; do
        CURRENT_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")
        if (( $(echo "$CURRENT_SIZE_GB <= $MAX_SIZE_GB" | bc -l) )); then
            break
        fi
        
        if [[ -d "$backup_dir" ]]; then
            backup_size_gb=$(get_size_gb "$backup_dir")
            safe_remove "$backup_dir" "Size cleanup: $(basename "$backup_dir") (${backup_size_gb}GB)"
            
            # Also remove associated tar.gz file
            tar_file="${backup_dir}.tar.gz"
            if [[ -f "$tar_file" ]]; then
                safe_remove "$tar_file" "Associated archive: $(basename "$tar_file")"
            fi
            
            ((CLEANED_SIZE++))
        fi
    done
    
    FINAL_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")
    echo "Size-based cleanup completed: removed $CLEANED_SIZE backups"
    echo "Final size: ${FINAL_SIZE_GB}GB"
else
    echo "Size within limit, no size-based cleanup needed"
fi

echo ""

# Final summary
echo -e "${BLUE}📊 Cleanup Summary${NC}"
echo "=================="

TOTAL_CLEANED=$((CLEANED_EMPTY + CLEANED_OLD + CLEANED_SIZE))
FINAL_SIZE_GB=$(get_size_gb "$BACKUP_BASE_DIR")
SPACE_SAVED=$(echo "scale=2; $CURRENT_SIZE_GB - $FINAL_SIZE_GB" | bc -l)

echo "Empty/failed backups cleaned: $CLEANED_EMPTY"
echo "Old backups cleaned: $CLEANED_OLD"
echo "Size-based cleanup: $CLEANED_SIZE"
echo "Total backups cleaned: $TOTAL_CLEANED"
echo ""
echo "Size before cleanup: ${CURRENT_SIZE_GB}GB"
echo "Size after cleanup: ${FINAL_SIZE_GB}GB"
if (( $(echo "$SPACE_SAVED > 0" | bc -l) )); then
    echo "Space saved: ${SPACE_SAVED}GB"
fi
echo ""

# Show remaining backups
REMAINING_AUTO=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*-auto-*" 2>/dev/null | wc -l)
REMAINING_DEPLOY=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*deploy-*" 2>/dev/null | wc -l)
REMAINING_EMERGENCY=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "*emergency-*" 2>/dev/null | wc -l)

echo -e "${BLUE}📋 Remaining Backups:${NC}"
echo "Daily automated: $REMAINING_AUTO"
echo "Deployment: $REMAINING_DEPLOY" 
echo "Emergency/manual: $REMAINING_EMERGENCY"

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo -e "${YELLOW}💡 This was a dry run. To actually perform cleanup, run without --dry-run${NC}"
elif [[ $TOTAL_CLEANED -gt 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ Cleanup completed successfully!${NC}"
else
    echo ""
    echo -e "${GREEN}✅ No cleanup needed - backup directory is already optimized${NC}"
fi