#!/bin/bash
set -euo pipefail

# OSRS Wiki Git-Based Tooling Deployment Script
# Updates ~/Deploy/osrswiki-tooling and pushes to remote

# Source color utilities (auto-detects Claude Code environment)
source "$(dirname "${BASH_SOURCE[0]}")/color-utils.sh"

# Error handling function for better debugging
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "🚨 Script failed at line $line_number with exit code $exit_code"
    echo "Command that failed: ${BASH_COMMAND}"
    echo "Working directory: $(pwd)"
    echo "Script phase: $CURRENT_PHASE"
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Initialize phase tracking
CURRENT_PHASE="Initialization"

print_header "🔧 OSRS Wiki Git-Based Tooling Deployment"
echo "Date: $(date)"
echo ""

# Check if we're in the right place and set paths
CURRENT_PHASE="Directory Structure Validation"
if [[ -f "CLAUDE.md" && -d "main/.git" ]]; then
    # Running from project root 
    GIT_ROOT="$(cd main && pwd)"
    PROJECT_ROOT="$(pwd)"
    print_success "Running from project root with proper structure"
elif [[ -d ".git" && -f "../CLAUDE.md" ]]; then
    # Running from git repo root (main/)
    GIT_ROOT="$(pwd)"
    PROJECT_ROOT="$(cd .. && pwd)"
    print_success "Running from git repository root"
else
    print_error "Must run from monorepo root (where CLAUDE.md is located)"
    echo "Current directory: $(pwd)"
    echo "Expected structure: PROJECT_ROOT/CLAUDE.md and PROJECT_ROOT/main/.git/"
    exit 1
fi

# Phase 1: Pre-deployment validation
CURRENT_PHASE="Pre-deployment Validation"
print_phase "🔍 Phase 1: Pre-deployment Validation"
echo "--------------------------------"

# Change to git root for git operations
cd "$GIT_ROOT"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning " You have uncommitted changes"
    echo "Tooling deployment will use the current committed state."
    echo "Uncommitted changes will not be included."
    git status --short
    echo ""
fi

# Return to project root for script calls
cd "$PROJECT_ROOT"

# Run deployment validation
print_info "Running deployment validation..."
if ! ./main/scripts/shared/validate-deployment.sh tooling; then
    print_error "Pre-deployment validation failed"
    echo "Fix validation errors before proceeding"
    exit 1
fi

print_success "Pre-deployment validation passed"

# Phase 2: Repository health check
CURRENT_PHASE="Repository Health Check"
print_phase "🏥 Phase 2: Repository Health Check"
echo "-------------------------------"

print_info "Checking repository health..."
if ! ./main/scripts/shared/validate-repository-health.sh; then
    print_warning " Repository health issues detected"
    echo "Continue anyway? (y/N)"
    if [[ -t 0 ]]; then
        # Interactive mode - ask user
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled by user"
            exit 1
        fi
    else
        # Non-interactive mode - proceed automatically
        print_warning " Running non-interactively - proceeding with deployment"
        response="y"
    fi
fi

# Phase 3: Setup deployment environment
CURRENT_PHASE="Deployment Environment Setup"
print_phase "🏗️  Phase 3: Deployment Environment Setup"
echo "-------------------------------------"

DEPLOY_TOOLING="$HOME/Deploy/osrswiki-tooling"
MONOREPO_ROOT="$PROJECT_ROOT"

# Ensure deployment directory exists
if [[ ! -d "$DEPLOY_TOOLING" ]]; then
    print_info "📁 Creating deployment repository..."
    mkdir -p "$(dirname "$DEPLOY_TOOLING")"
    cd "$(dirname "$DEPLOY_TOOLING")"
    git clone https://github.com/omiyawaki/osrswiki-tooling.git
    cd "$MONOREPO_ROOT"
fi

# Validate deployment repo
if [[ ! -d "$DEPLOY_TOOLING/.git" ]]; then
    print_error "Deployment repository is not a valid git repo: $DEPLOY_TOOLING"
    exit 1
fi

print_success "Deployment environment ready"

# Phase 4: Update deployment repository content
CURRENT_PHASE="Update Deployment Content"
print_phase "📦 Phase 4: Update Deployment Content"
echo "-----------------------------------"

cd "$DEPLOY_TOOLING"
print_info "Working in deployment repository: $DEPLOY_TOOLING"

# Fetch latest changes to ensure we're up to date
print_info "Fetching latest remote changes..."
git fetch origin main
git reset --hard origin/main

# Create deployment branch for safety
DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
print_info "Creating deployment branch: $DEPLOY_BRANCH"
git checkout -b "$DEPLOY_BRANCH"

# Clear existing content (except .git)
print_info "Clearing existing content..."
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy all directories except platforms/, preserving structure
print_info "Copying tooling components (excluding platforms/)..."

# Simple approach - copy each top-level directory explicitly from git root
# Use rsync to exclude .DS_Store files and respect common ignore patterns
for dir in scripts tools shared; do
    SOURCE_DIR="$GIT_ROOT/$dir"
    if [[ -d "$SOURCE_DIR" ]]; then
        echo "  → Copying $dir/ from $SOURCE_DIR (excluding .DS_Store)"
        rsync -av --exclude='.DS_Store' --exclude='*.tmp' --exclude='*.log' "$SOURCE_DIR/" "$dir/"
    else
        echo "  ⚠️  Warning: $dir directory not found at $SOURCE_DIR"
    fi
done

echo "  ⏭️  Skipping platforms/ (deployed separately)"

# Copy important root files (excluding CLAUDE.md for public repo)
print_info "Copying root files..."
for file in "$MONOREPO_ROOT"/{README.md,.gitignore,.editorconfig}; do
    if [[ -f "$file" ]]; then
        echo "  → Copying $(basename "$file")"
        cp "$file" .
    fi
done
echo "  ⏭️  Skipping CLAUDE.md (contains private development instructions)"

# Copy any dotfiles that might be important (excluding .git, session files, and common temp files)
for file in "$MONOREPO_ROOT"/.*; do
    if [[ -f "$file" ]]; then
        basename_file=$(basename "$file")
        if [[ "$basename_file" != ".git" && "$basename_file" != ".DS_Store" && "$basename_file" != ".claude-session-device" && "$basename_file" != ".." && "$basename_file" != "." ]]; then
            echo "  → Copying $basename_file"
            cp "$file" . 2>/dev/null || true
        fi
    fi
done
echo "  ⏭️  Skipping .claude-session-device (session-specific file)"

# Stage all changes
git add -A

# Create deployment commit if there are changes
if ! git diff --cached --quiet; then
    # Generate intelligent commit message based on actual changes
    print_info "🧠 Generating intelligent commit message..."
    DEPLOY_COMMIT_MSG=$(source "$MONOREPO_ROOT/scripts/shared/generate-smart-commit-message.sh" && \
                        generate_deployment_commit_message "tooling" "$GIT_ROOT" "$DEPLOY_TOOLING")

    git commit -m "$DEPLOY_COMMIT_MSG"
    print_success "Deployment commit created"
    
    # Show what was deployed
    print_phase "📋 Deployment Summary:"
    git show --stat HEAD
    
else
    print_info "ℹ️  No changes to deploy"
    git checkout main
    git branch -d "$DEPLOY_BRANCH"
    cd "$MONOREPO_ROOT"
    exit 0
fi

# Phase 5: Push to remote
CURRENT_PHASE="Push to Remote"
print_phase "🚀 Phase 5: Push to Remote"
echo "------------------------"

# Safety check - ensure we have reasonable number of commits
DEPLOY_COMMITS=$(git rev-list --count HEAD)
if [[ "$DEPLOY_COMMITS" -lt 5 ]]; then
    print_error "🚨 CRITICAL SAFETY CHECK FAILED"
    echo "Deployment repository has only $DEPLOY_COMMITS commits"
    echo "Expected: 5+ commits for tooling repository"
    echo ""
    echo "This suggests a serious error in deployment preparation."
    echo "DO NOT PROCEED - investigate immediately."
    exit 1
fi

print_success "Safety check passed: $DEPLOY_COMMITS commits"

# Push with force-with-lease for safety
print_info "Pushing to remote..."
if git push origin "$DEPLOY_BRANCH" --force-with-lease; then
    print_success "Deployment branch pushed successfully"
    
    # Merge to main
    git checkout main
    git merge "$DEPLOY_BRANCH" --ff-only
    git push origin main
    
    # Clean up deployment branch
    git branch -d "$DEPLOY_BRANCH"
    git push origin --delete "$DEPLOY_BRANCH"
    
    print_success "🎉 Tooling deployment completed successfully!"
    
else
    print_error "Push failed - remote may have been updated"
    echo "Fix conflicts and try again"
    exit 1
fi

# Phase 6: Final validation
print_phase "✅ Phase 6: Post-deployment Validation"
echo "--------------------------------"

# Verify remote state
REMOTE_COMMITS=$(git ls-remote origin main | cut -f1)
LOCAL_COMMITS=$(git rev-parse HEAD)

if [[ "$REMOTE_COMMITS" == "$LOCAL_COMMITS" ]]; then
    print_success "Remote and local are synchronized"
else
    print_warning " Remote and local commits differ"
    echo "This may indicate a deployment issue - investigate"
fi

# Return to project root
cd "$PROJECT_ROOT"

echo ""
print_success "🎊 Git-Based Tooling Deployment Complete!"
echo "============================================="
echo "Deployment repository: $DEPLOY_TOOLING"
echo "Remote commits: $DEPLOY_COMMITS"
echo "Changes deployed safely"
echo ""
print_phase "Deployed components:"
echo "- ✅ Development tools and scripts"
echo "- ✅ Shared cross-platform components"
echo "- ✅ Documentation and configuration"
echo "- ✅ Build automation and workflows"
echo "- ❌ Platform code (excluded, deployed separately)"
echo ""
print_phase "Key advantages of ~/Deploy approach:"
echo "- ✅ Simple 1:1 mirror of remote repository"
echo "- ✅ Standard git workflow from deployment directory"
echo "- ✅ Clear separation between monorepo and deployment"
echo "- ✅ Easy to verify deployment state"
echo ""
print_phase "Next steps:"
echo "- Verify deployment at: https://github.com/omiyawaki/osrswiki-tooling"
echo "- Check that platforms/ directory is excluded from remote"
echo "- Monitor for any issues"

exit 0