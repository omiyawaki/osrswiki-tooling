# Done Command

Clean up session resources when development work is complete with intelligent platform detection.

## Platform-Aware Cleanup

Claude automatically detects active platforms and performs appropriate cleanup:

1. **Detect active platforms**:
   - Check for `.claude-session-device` → Android session active
   - Check for `.claude-session-simulator` → iOS session active  
   - Check `.claude-platform` for intended platform
   - Both session files → Cross-platform session

2. **Platform-specific cleanup** performed automatically

## Cleanup Actions

1. **Final commit** (if incomplete work):
   ```bash
   git add -A
   git commit -m "[WIP] session-end: final state

   Platform: $(cat .claude-platform 2>/dev/null || echo "unknown")
   Why: End of session, documenting current progress
   Next: [describe what needs to be done next]
   Tests: [current test status]"
   git push origin HEAD
   ```

2. **Run platform-specific cleanup**:

   **For Android sessions:**
   ```bash
   ./cleanup-session-device.sh
   ```

   **For iOS sessions:**
   ```bash
   ./cleanup-session-simulator.sh
   ```

   **For cross-platform sessions:**
   ```bash
   # Clean up both platforms
   ./cleanup-session-device.sh     # If Android session exists
   ./cleanup-session-simulator.sh  # If iOS session exists
   ```

3. **Universal cleanup**:
   ```bash
   # Remove platform indicator
   rm -f .claude-platform
   
   # Run universal session cleanup
   ./end-session.sh
   ```

This handles:
- ✅ Stopping and removing session emulator (Android) or simulator (iOS)
- ✅ Cleaning up platform-specific session files  
- ✅ Removing the platform indicator file
- ✅ Removing the worktree session directory
- ✅ Returning to the main directory

The cleanup process automatically detects session type and performs complete platform-aware cleanup.

## Before Cleanup Checklist

- [ ] All important changes committed and pushed
- [ ] Session goal documented in commit history
- [ ] Any unfinished work clearly described in WIP commit
- [ ] No valuable work left uncommitted

This command ensures proper cleanup of all session resources and preservation of development progress.