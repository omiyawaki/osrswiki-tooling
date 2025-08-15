#!/bin/bash
set -euo pipefail

# Manual test of the backup system
echo "🧪 Testing OSRS Wiki Backup System"
echo "================================="
echo ""

# Test the daily backup script manually
echo "Running daily backup script manually..."
/Users/miyawaki/Develop/osrswiki/scripts/shared/daily-backup.sh

echo ""
echo "✅ Manual backup test completed"
echo "Check logs at: /Users/miyawaki/Backups/osrswiki/daily-backup.log"
