# OSRS Wiki Multi-Repository Deployment

This directory contains deployment scripts for managing the OSRS Wiki project across multiple GitHub repositories with different visibility levels.

## Repository Structure

- **osrswiki-tooling** (private) - Complete monorepo with all tools, scripts, and shared components
- **osrswiki-android** (public) - Android app with integrated shared components  
- **osrswiki-ios** (public) - iOS app with Swift bridge for shared components

## Deployment Scripts

### Individual Platform Deployment

- **`android/deploy.sh`** - Deploy Android app to public repository
  - Copies shared Kotlin components into Android app structure
  - Creates Android-specific .gitignore for public repo
  - Uses git subtree to push only `platforms/android/` directory

- **`ios/deploy.sh`** - Deploy iOS app to public repository  
  - Creates Swift bridge documentation for shared components
  - Creates iOS-specific .gitignore for public repo
  - Uses git subtree to push only `platforms/ios/` directory

- **`deploy-tooling.sh`** - Deploy complete monorepo to private repository
  - Pushes entire monorepo including tools, scripts, and shared components
  - Maintains private development workflows and configurations

### Synchronization

- **`sync-from-remotes.sh`** - Pull changes from all remote repositories
  - Syncs from private tooling repository (complete monorepo)
  - Pulls Android changes using git subtree
  - Pulls iOS changes using git subtree
  - Handles merge conflicts and maintains branch consistency

### Master Deployment

- **`deploy-all.sh`** - Deploy to all repositories in correct order
  - Validates all changes are committed
  - Deploys to private tooling repository first
  - Deploys to public Android repository
  - Deploys to public iOS repository

## Usage Examples

```bash
# Deploy everything to all repositories
./deployment/deploy-all.sh

# Deploy only Android app to public repo
./deployment/android/deploy.sh

# Deploy only iOS app to public repo  
./deployment/ios/deploy.sh

# Deploy only to private tooling repo
./deployment/deploy-tooling.sh

# Sync changes from all remotes
./deployment/sync-from-remotes.sh
```

## Security Model

- **Private components** (tools, build scripts, proprietary automation) stay in osrswiki-tooling
- **Public components** (app source code, UI, features) are deployed to platform-specific repos
- **Shared components** are copied/bridged into each platform during deployment
- **No secrets or proprietary tools** are exposed in public repositories

## Git Remote Configuration

The monorepo is configured with three remotes:

```bash
git remote -v
android   https://github.com/omiyawaki/osrswiki-android.git
ios       https://github.com/omiyawaki/osrswiki-ios.git  
tooling   https://github.com/omiyawaki/osrswiki-tooling.git
```

## Development Workflow

1. **Develop locally** in the monorepo with full access to tools and shared components
2. **Test changes** using the complete development environment
3. **Commit changes** to the monorepo  
4. **Deploy selectively** to public/private repos as needed
5. **Sync changes** from collaborators across all repositories

This approach provides the benefits of monorepo development with the flexibility of separate public/private repository deployment.