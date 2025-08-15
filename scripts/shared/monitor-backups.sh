#!/bin/bash
set -euo pipefail

# OSRS Wiki Backup Monitoring Script
# Shows status of automated backups

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 OSRS Wiki Backup System Status${NC}"
echo "=================================="
echo ""

# Check if backup directory exists
BACKUP_DIR="/Users/miyawaki/Backups/osrswiki"
if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${GREEN}✅ Backup directory exists: $BACKUP_DIR${NC}"
    
    # Show disk usage
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
    echo "Total backup size: $BACKUP_SIZE"
    
    # Count backup files
    BUNDLE_COUNT=$(find "$BACKUP_DIR" -name "*.bundle" 2>/dev/null | wc -l)
    echo "Bundle files: $BUNDLE_COUNT"
    
    echo ""
else
    echo -e "${RED}❌ Backup directory not found: $BACKUP_DIR${NC}"
fi

# Check recent backups
echo -e "${BLUE}📅 Recent Backups (last 7 days):${NC}"
find "$BACKUP_DIR" -name "*-auto-*" -type d -mtime -7 2>/dev/null | sort -r | while read -r backup; do
    if [[ -n "$backup" ]]; then
        BACKUP_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$backup" 2>/dev/null || echo "unknown")
        BACKUP_SIZE=$(du -sh "$backup" 2>/dev/null | cut -f1)
        echo "  $(basename "$backup") - $BACKUP_DATE ($BACKUP_SIZE)"
    fi
done

# Check log file
LOG_FILE="$BACKUP_DIR/daily-backup.log"
if [[ -f "$LOG_FILE" ]]; then
    echo ""
    echo -e "${BLUE}📋 Recent Log Entries:${NC}"
    tail -10 "$LOG_FILE"
    
    # Check for recent success
    if tail -20 "$LOG_FILE" | grep -q "SUCCESS.*Daily backup completed successfully"; then
        echo -e "${GREEN}✅ Recent backup was successful${NC}"
    else
        echo -e "${YELLOW}⚠️  No recent successful backup found in logs${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No backup log file found: $LOG_FILE${NC}"
fi

# Check cron job status
echo ""
echo -e "${BLUE}⏰ Cron Job Status:${NC}"
if crontab -l 2>/dev/null | grep -q "/Users/miyawaki/Developer/osrswiki/scripts/shared/daily-backup.sh"; then
    echo -e "${GREEN}✅ Automated backup cron job is active${NC}"
    crontab -l | grep "/Users/miyawaki/Developer/osrswiki/scripts/shared/daily-backup.sh"
else
    echo -e "${RED}❌ No automated backup cron job found${NC}"
    echo "Run setup-automated-backup.sh to set it up"
fi

echo ""
echo -e "${BLUE}💡 Commands:${NC}"
echo "  Test backup manually: /Users/miyawaki/Developer/osrswiki/scripts/shared/test-backup-system.sh"
echo "  View full log: less /Users/miyawaki/Backups/osrswiki/daily-backup.log"
echo "  Emergency backup: ./scripts/shared/emergency-backup.sh"
