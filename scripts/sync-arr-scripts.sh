#!/bin/bash
# =============================================================================
# arr-scripts Submodule Sync Script
# =============================================================================
# Synchronizes the arr-scripts submodule with upstream RandomNinjaAtk/arr-scripts
# Usage: ./scripts/sync-arr-scripts.sh [--dry-run]
# =============================================================================

set -e

# Configuration
SUBMODULE_PATH="arr-scripts"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
LOCAL_BRANCH="beta"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if we're in the right directory
if [ ! -f ".gitmodules" ] || [ ! -d "$SUBMODULE_PATH" ]; then
    print_error "Error: This script must be run from the repository root"
    print_error "Make sure .gitmodules exists and $SUBMODULE_PATH directory exists"
    exit 1
fi

# Parse command line arguments
DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    print_warning "Running in dry-run mode - no changes will be made"
fi

print_status "🔄 Starting arr-scripts submodule synchronization..."

# Change to submodule directory
cd "$SUBMODULE_PATH"

# Verify remote configuration
print_status "🔍 Verifying remote configuration..."
if ! git remote | grep -q "$UPSTREAM_REMOTE"; then
    print_error "Upstream remote '$UPSTREAM_REMOTE' not found"
    print_status "Adding upstream remote..."
    if [ "$DRY_RUN" = false ]; then
        git remote add "$UPSTREAM_REMOTE" "https://github.com/RandomNinjaAtk/arr-scripts.git"
        print_success "Added upstream remote"
    fi
else
    print_success "Upstream remote found"
fi

# Fetch latest changes
print_status "📥 Fetching upstream changes..."
if [ "$DRY_RUN" = false ]; then
    git fetch "$UPSTREAM_REMOTE"
else
    echo "    [DRY RUN] Would run: git fetch $UPSTREAM_REMOTE"
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$LOCAL_BRANCH" ]; then
    print_warning "Currently on branch '$CURRENT_BRANCH', switching to '$LOCAL_BRANCH'"
    if [ "$DRY_RUN" = false ]; then
        git checkout "$LOCAL_BRANCH"
    else
        echo "    [DRY RUN] Would run: git checkout $LOCAL_BRANCH"
    fi
fi

# Check if updates are available
print_status "🔍 Checking for updates..."
UPDATES=$(git log --oneline "$LOCAL_BRANCH..$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" 2>/dev/null || echo "")

if [ -z "$UPDATES" ]; then
    print_success "Already up to date with upstream"
    cd ..
    exit 0
fi

print_status "📋 New changes found:"
echo "$UPDATES" | sed 's/^/    /'

# Check for local changes that might conflict
LOCAL_CHANGES=$(git status --porcelain 2>/dev/null || echo "")
if [ -n "$LOCAL_CHANGES" ]; then
    print_error "Local changes detected. Please commit or stash them first:"
    echo "$LOCAL_CHANGES" | sed 's/^/    /'
    cd ..
    exit 1
fi

# Merge changes
print_status "🔀 Merging upstream changes..."
if [ "$DRY_RUN" = false ]; then
    if git merge "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" --no-edit; then
        print_success "Merge completed successfully"
    else
        print_error "Merge conflicts detected. Please resolve manually:"
        print_status "1. Resolve conflicts in the listed files"
        print_status "2. Run: git add <resolved-files>"
        print_status "3. Run: git commit"
        print_status "4. Run: git push origin $LOCAL_BRANCH"
        print_status "5. Re-run this script"
        cd ..
        exit 1
    fi
else
    echo "    [DRY RUN] Would run: git merge $UPSTREAM_REMOTE/$UPSTREAM_BRANCH --no-edit"
fi

# Push to fork
print_status "📤 Pushing to fork..."
if [ "$DRY_RUN" = false ]; then
    git push origin "$LOCAL_BRANCH"
    print_success "Pushed to fork"
else
    echo "    [DRY RUN] Would run: git push origin $LOCAL_BRANCH"
fi

cd ..

# Update main repository
print_status "🔗 Updating submodule reference in main repository..."
if [ "$DRY_RUN" = false ]; then
    git add "$SUBMODULE_PATH"
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        print_warning "No submodule reference changes to commit"
    else
        COMMIT_MSG="Update arr-scripts submodule to latest upstream changes

- Merged upstream changes from RandomNinjaAtk/arr-scripts
- Updated to commit: $(cd $SUBMODULE_PATH && git rev-parse --short HEAD)
- Branch: $LOCAL_BRANCH"

        git commit -m "$COMMIT_MSG"
        print_success "Committed submodule reference update"
        
        print_status "📤 Pushing main repository changes..."
        git push
        print_success "Pushed main repository changes"
    fi
else
    echo "    [DRY RUN] Would run: git add $SUBMODULE_PATH"
    echo "    [DRY RUN] Would run: git commit -m 'Update arr-scripts submodule...'"
    echo "    [DRY RUN] Would run: git push"
fi

print_success "🎉 Synchronization complete!"

# Display summary
print_status "📊 Summary:"
cd "$SUBMODULE_PATH"
CURRENT_COMMIT=$(git rev-parse --short HEAD)
print_status "   Current commit: $CURRENT_COMMIT"
print_status "   Branch: $(git branch --show-current)"
print_status "   Remote status: $(git status --porcelain -b | head -1 | cut -d' ' -f2-)"
cd ..

print_status "💡 Tip: Run 'make health' to verify all services work correctly"