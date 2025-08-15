# Start Command

Set up a new isolated worktree session for development work with intelligent platform detection.

## Usage
```bash
/start
```

**Important:**
After typing `/start`, Claude will immediately ask you to describe your task.
Provide your task description so Claude can create meaningful worktree and branch names AND detect the target platform automatically.

⚠️ **Note**: Claude will wait for your task description before creating any infrastructure, ensuring everything is properly named and the correct platform is set up.

## How it works
Claude will:
1. Ask you to describe your task immediately
2. **Detect target platform** from your description (Android, iOS, or both)
3. Generate appropriate topic name based on your description (e.g., "js-modules-analysis")
4. Create worktree session: `claude-YYYYMMDD-HHMMSS-your-topic`
5. Create session branch: `claude/YYYYMMDD-HHMMSS-your-topic`
6. Set up **platform-specific** device isolation and complete session setup
7. Begin working on the task within the isolated session

## Platform Detection

When you describe your task, Claude automatically detects the target platform:

**iOS Indicators:** "iOS", "iPhone", "iPad", "Swift", "SwiftUI", "UIKit", "Xcode", "simulator", "Apple"
**Android Indicators:** "Android", "Kotlin", "Java", "Gradle", "emulator", "APK", "Google Play"
**Cross-platform:** "both platforms", "cross-platform", "Android and iOS"

If unclear from your description, Claude will ask: "Will you be working on Android, iOS, or both platforms?"

## Agent Integration

This command uses the **orchestrator** agent for intelligent session setup and task analysis:

**Agent**: `orchestrator`  
**Purpose**: Analyzes task complexity and spawns appropriate workers for recursive development  
**Spawning**: Claude automatically uses the Task tool with `subagent_type="orchestrator"`

The orchestrator handles:
- Task description analysis and complexity assessment
- Platform detection (Android, iOS, or cross-platform)
- Session setup and environment configuration
- Worker spawning strategy (single worker vs. multiple parallel workers)
- Coordination of recursive development workflows

## Required Actions

**IMPORTANT: Claude will delegate session setup to the orchestrator agent, which will handle all complexity analysis and worker spawning automatically.**

### Automatic Agent Workflow

1. **Ask user for task description**:
   Stop and ask the user: "Please describe what you'd like to work on in this session."
   Wait for their response.

2. **Spawn Orchestrator Agent**:
   Once the user provides their task description, Claude automatically spawns the orchestrator:
   ```bash
   Task tool with:
   - description: "Initialize development session and analyze task complexity"
   - prompt: "Set up development session for: [user task description]. Analyze complexity, detect platform, set up session infrastructure, and spawn appropriate workers (single worker for simple tasks, multiple workers for complex tasks with parallel development)."
   - subagent_type: "orchestrator"
   ```

### What the Orchestrator Does

The orchestrator will automatically handle all remaining setup:
- **Platform Detection**: Android, iOS, or cross-platform based on task description
- **Complexity Analysis**: Determine if task is simple (1 worker) or complex (multiple workers)
- **Session Setup**: Create worktree, environment, branch, and initial commit
- **Worker Strategy**: Spawn appropriate number of workers for optimal parallel development

### Worker Spawning Examples

**Simple Task**: "Fix search button styling"
```
Orchestrator → Spawns 1 Worker → plan→implement→scaffold→test
```

**Complex Task**: "Add complete user authentication system"
```
Orchestrator → Spawns 3 Workers:
- Worker 1: Authentication UI (plan→implement→scaffold→test)
- Worker 2: Authentication API (plan→implement→scaffold→test)  
- Worker 3: User data management (plan→implement→scaffold→test)
All workers run in parallel!
```

**Recursive Task**: "Build e-commerce platform"
```
Orchestrator → Spawns 3 Workers (Search, Cart, Checkout)
Each Worker → Analyzes its task → May spawn sub-workers if still complex
Results in tree of workers all progressing in parallel
```

## Session Complete - Development Ready!

After the orchestrator completes session setup and spawns workers, you'll have:

### ✅ Infrastructure Ready
- **Isolated worktree session** in `~/Develop/osrswiki-sessions/claude-YYYYMMDD-HHMMSS-<topic>`
- **Platform-specific environment** configured (Android/iOS/both)
- **Session devices** connected and ready (emulator/simulator)
- **Git branch** created with initial session commit

### ✅ Workers Active
- **Orchestrator** coordinating overall progress
- **Worker(s)** progressing through development workflow:
  - Simple task: 1 worker handling plan→implement→scaffold→test
  - Complex task: Multiple workers handling different components in parallel
  - Each worker can spawn sub-workers if needed

### ✅ Parallel Development
- **Multiple features** can develop simultaneously
- **Independent progress** - each worker moves at optimal pace
- **Automatic coordination** - orchestrator manages dependencies and conflicts
- **Real-time progress** - todo lists track all worker progress

### 🎯 What Happens Next

The spawned workers will automatically:
1. **Plan** their assigned components
2. **Implement** the code
3. **Scaffold** comprehensive tests
4. **Test** with quality gates

You can monitor progress through the todo lists and worker updates. The orchestrator coordinates everything automatically!

**🚀 Development session is active!** Your recursive worker system is now handling the development workflow with optimal parallelization.