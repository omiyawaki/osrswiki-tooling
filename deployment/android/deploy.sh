#!/bin/bash
set -euo pipefail

echo "🤖 Deploying Android app to public repository with history preservation..."

# Ensure we're in the monorepo root
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verify we're in the right place
if [ ! -f "CLAUDE.md" ] || [ ! -d "platforms/android" ]; then
    echo -e "${RED}❌ Error: Must run from monorepo root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-deployment checks...${NC}"

# Check if Android directory exists
if [ ! -d "platforms/android" ]; then
    echo -e "${RED}❌ Error: Android platform directory not found${NC}"
    exit 1
fi

# Check if shared directory exists
if [ ! -d "shared" ]; then
    echo -e "${RED}❌ Error: Shared components directory not found${NC}"
    exit 1
fi

# Verify we have android remote
if ! git remote | grep -q "^android$"; then
    echo -e "${RED}❌ Error: Android remote not configured${NC}"
    echo "Run: git remote add android https://github.com/omiyawaki/osrswiki-android.git"
    exit 1
fi

echo -e "${BLUE}🔍 History preservation checks...${NC}"

# Fetch latest remote state
echo "Fetching latest Android remote state..."
git fetch android main

# Check remote commit count
REMOTE_COMMITS=$(git rev-list --count android/main)
echo "Remote repository has $REMOTE_COMMITS commits"

# Check if remote has substantial history (more than 10 commits indicates real project)
if [ "$REMOTE_COMMITS" -gt 10 ]; then
    echo -e "${GREEN}✅ Remote has substantial history ($REMOTE_COMMITS commits) - proceeding with history preservation${NC}"
    PRESERVE_HISTORY=true
else
    echo -e "${YELLOW}⚠️  Remote has minimal history ($REMOTE_COMMITS commits) - may be a new repository${NC}"
    PRESERVE_HISTORY=false
fi

echo -e "${YELLOW}📦 Copying shared components to Android app...${NC}"

# Create shared directory in Android if it doesn't exist
ANDROID_SHARED_DIR="platforms/android/app/src/main/java/com/omiyawaki/osrswiki/shared"
mkdir -p "$ANDROID_SHARED_DIR"

# Copy shared components
if [ -d "shared/api" ]; then
    cp -r shared/api/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "No API files to copy"
fi

if [ -d "shared/models" ]; then
    cp -r shared/models/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "No model files to copy"
fi

if [ -d "shared/network" ]; then
    cp -r shared/network/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "No network files to copy"
fi

if [ -d "shared/utils" ]; then
    cp -r shared/utils/* "$ANDROID_SHARED_DIR/" 2>/dev/null || echo "No util files to copy"
fi

echo -e "${YELLOW}🔧 Creating Android-specific .gitignore...${NC}"

# Create Android-specific .gitignore
cat > platforms/android/.gitignore << 'EOF'
# Android-specific ignores for public repo
.gradle/
build/
app/build/
local.properties
.idea/
*.iml
.DS_Store
captures/
.externalNativeBuild/
.cxx/

# Session files (development only)
.claude-env
.claude-device-*
.claude-app-id
.claude-emulator-name
**/emulator.err
**/emulator.out

# Build artifacts
*.apk
*.ap_
*.aab

# Development logs
css_sync.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
node_modules/

# Temporary files
*.tmp
*.log
EOF

echo -e "${YELLOW}📝 Committing shared component integration...${NC}"

# Add the changes to git
git add platforms/android/app/src/main/java/com/omiyawaki/osrswiki/shared/
git add platforms/android/.gitignore

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}⏭️  No changes to commit, proceeding with deployment...${NC}"
else
    git commit -m "chore(android): integrate shared components for public deployment

- Copy shared API, models, network, and utils into Android app
- Add Android-specific .gitignore for public repository
- Prepare for subtree push to osrswiki-android

This commit integrates cross-platform shared components directly into the Android
app structure for deployment to the public repository."
fi

echo -e "${YELLOW}🚀 Deploying to Android repository with history preservation...${NC}"

if [ "$PRESERVE_HISTORY" = true ]; then
    echo -e "${BLUE}📋 Using history-preserving deployment strategy...${NC}"
    
    # Create a temporary deployment branch
    DEPLOY_BRANCH="deploy-$(date +%Y%m%d-%H%M%S)"
    echo "Creating deployment branch: $DEPLOY_BRANCH"
    
    # Create temporary directory to stage Android platform content
    TEMP_ANDROID_DIR="/tmp/android-deploy-$DEPLOY_BRANCH"
    echo "Creating temporary staging directory: $TEMP_ANDROID_DIR"
    
    # Copy Android platform content to temporary directory
    if [ -d "platforms/android" ]; then
        mkdir -p "$TEMP_ANDROID_DIR"
        cp -r platforms/android/* "$TEMP_ANDROID_DIR/"
        cp platforms/android/.gitignore "$TEMP_ANDROID_DIR/" 2>/dev/null || true
        echo "✅ Android platform content staged to temporary directory"
    else
        echo "Error: Android platform directory not found at platforms/android"
        echo "Available directories in platforms/:"
        ls -la platforms/
        exit 1
    fi
    
    # Create deployment branch from Android main (preserving history)
    git checkout -b "$DEPLOY_BRANCH" android/main
    
    # Copy our Android platform content over the deployment branch
    echo "Copying staged Android content to deployment branch..."
    
    # Remove existing content but preserve git history
    find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
    
    # Copy all content from temporary directory to root
    cp -r "$TEMP_ANDROID_DIR"/* .
    
    # Clean up temporary directory
    rm -rf "$TEMP_ANDROID_DIR"
    
    # Stage all changes
    git add -A
    
    # Create deployment commit
    if ! git diff --cached --quiet; then
        git commit -m "deploy: integrate monorepo Android changes with shared components

$(git log --oneline --no-merges --max-count=5 main --grep='android\\|Android' | sed 's/^/- /')

This deployment preserves the complete Android repository history while
integrating the latest changes from the monorepo including shared components."
        
        echo -e "${GREEN}✅ Deployment commit created on branch $DEPLOY_BRANCH${NC}"
        
        # Push the deployment branch to Android main
        echo "Pushing deployment branch to Android repository..."
        if git push android "$DEPLOY_BRANCH:main"; then
            echo -e "${GREEN}✅ Android deployment successful with history preserved!${NC}"
            echo -e "${GREEN}📱 Public repository updated: https://github.com/omiyawaki/osrswiki-android${NC}"
            echo -e "${GREEN}📊 Commit count preserved: $REMOTE_COMMITS → $(git rev-list --count HEAD)${NC}"
        else
            echo -e "${RED}❌ Deployment push failed${NC}"
            git checkout main
            git branch -D "$DEPLOY_BRANCH"
            exit 1
        fi
    else
        echo -e "${YELLOW}⏭️  No changes to deploy${NC}"
    fi
    
    # Clean up deployment branch
    git checkout main
    git branch -D "$DEPLOY_BRANCH"
    
else
    echo -e "${YELLOW}⚠️  Using subtree deployment for new repository...${NC}"
    echo -e "${RED}🚨 WARNING: This may overwrite existing history!${NC}"
    
    # Ask for confirmation
    read -p "Continue with potentially destructive deployment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Use traditional subtree push for new repositories
        if git subtree push --prefix=platforms/android android main; then
            echo -e "${GREEN}✅ Android deployment successful!${NC}"
            echo -e "${GREEN}📱 Public repository updated: https://github.com/omiyawaki/osrswiki-android${NC}"
        else
            echo -e "${YELLOW}⚠️  Subtree push failed, using split and force push...${NC}"
            SPLIT_COMMIT=$(git subtree split --prefix=platforms/android)
            if [ -n "$SPLIT_COMMIT" ]; then
                git push android "$SPLIT_COMMIT:main" --force
                echo -e "${GREEN}✅ Android deployment successful (force push)!${NC}"
                echo -e "${YELLOW}⚠️  Used force push - history may have been replaced${NC}"
            else
                echo -e "${RED}❌ Failed to create subtree split${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}⏭️  Deployment cancelled by user${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}🎉 Android deployment completed successfully!${NC}"
echo -e "${BLUE}💡 Future deployments will preserve history automatically${NC}"