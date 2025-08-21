#!/bin/bash
# Repository Discovery Utility
# Finds the actual git repository location regardless of current working directory

set -euo pipefail

# Function to find git repository root
find_git_repo() {
    local search_dir="${1:-$(pwd)}"
    local max_depth=3
    local current_depth=0
    
    # First, check if we're already in a git repo
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git rev-parse --show-toplevel
        return 0
    fi
    
    # Search common locations
    local search_paths=(
        "$search_dir"
        "$search_dir/main"
        "$search_dir/../main"
        "$search_dir/../../main"
        "/Users/miyawaki/Develop/osrswiki/main"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -d "$path/.git" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    # If not found, search more broadly
    local potential_repos
    potential_repos=$(find "$search_dir" -name ".git" -type d -maxdepth 3 2>/dev/null | head -1)
    
    if [[ -n "$potential_repos" ]]; then
        dirname "$potential_repos"
        return 0
    fi
    
    return 1
}

# Function to find osrswiki parent directory
find_osrswiki_parent() {
    local current_dir="$(pwd)"
    
    # Common patterns for osrswiki parent directory
    local search_paths=(
        "$current_dir"
        "$(dirname "$current_dir")"
        "/Users/miyawaki/Develop/osrswiki"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -d "$path/main" ]] && [[ -d "$path/sessions" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    # If we're in a worktree session, go up to find parent
    if [[ "$current_dir" =~ /sessions/claude- ]]; then
        local parent_dir
        parent_dir=$(echo "$current_dir" | sed 's|/sessions/claude-.*||')
        if [[ -d "$parent_dir/main" ]] && [[ -d "$parent_dir/sessions" ]]; then
            echo "$parent_dir"
            return 0
        fi
    fi
    
    return 1
}

# Function to validate repository context
validate_repo_context() {
    local repo_root
    local parent_dir
    
    if ! repo_root=$(find_git_repo); then
        echo "ERROR: Cannot find git repository" >&2
        echo "Searched common locations but no .git directory found" >&2
        return 1
    fi
    
    if ! parent_dir=$(find_osrswiki_parent); then
        echo "ERROR: Cannot find osrswiki parent directory" >&2
        echo "Expected directory with main/ and sessions/ subdirectories" >&2
        return 1
    fi
    
    echo "REPO_ROOT=$repo_root"
    echo "PARENT_DIR=$parent_dir"
    return 0
}

# Main function for command line usage
main() {
    case "${1:-validate}" in
        "repo")
            find_git_repo
            ;;
        "parent")
            find_osrswiki_parent
            ;;
        "validate")
            validate_repo_context
            ;;
        *)
            echo "Usage: $0 [repo|parent|validate]"
            echo "  repo     - Find git repository root"
            echo "  parent   - Find osrswiki parent directory"
            echo "  validate - Validate and show both locations"
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi