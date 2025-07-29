# Submodule Synchronization Guide

This document describes how to maintain the `arr-scripts` submodule synchronized with the upstream repository `RandomNinjaAtk/arr-scripts`.

## Overview

The `arr-scripts` submodule is configured as follows:
- **Fork Repository**: `https://github.com/carcheky/arr-scripts.git` (contains customizations)
- **Upstream Repository**: `https://github.com/RandomNinjaAtk/arr-scripts.git` (original source)
- **Active Branch**: `beta`

## Initial Setup

The submodule has been configured with an upstream remote to enable synchronization:

```bash
cd arr-scripts
git remote -v
# Should show:
# origin    https://github.com/carcheky/arr-scripts.git (fetch)
# origin    https://github.com/carcheky/arr-scripts.git (push)
# upstream  https://github.com/RandomNinjaAtk/arr-scripts.git (fetch)
# upstream  https://github.com/RandomNinjaAtk/arr-scripts.git (push)
```

## Regular Synchronization Process

### 1. Fetch Latest Changes from Upstream

```bash
cd arr-scripts
git fetch upstream
```

### 2. Check for Updates

```bash
# Compare current beta branch with upstream main
git log --oneline beta..upstream/main
```

If there are no commits shown, you're already up to date.

### 3. Merge Upstream Changes

When updates are available:

```bash
# Ensure you're on the beta branch
git checkout beta

# Merge upstream changes
git merge upstream/main

# If there are conflicts, resolve them manually and commit
```

### 4. Push Updates to Fork

```bash
# Push the updated beta branch to the fork
git push origin beta
```

### 5. Update Main Repository

From the main repository root:

```bash
# Update the submodule reference
git add arr-scripts
git commit -m "Update arr-scripts submodule to latest upstream changes"
git push
```

## Automated Sync Script

You can create a script to automate this process. Here's an example:

```bash
#!/bin/bash
# sync-arr-scripts.sh

set -e

echo "🔄 Syncing arr-scripts submodule with upstream..."

cd arr-scripts

# Fetch latest changes
echo "📥 Fetching upstream changes..."
git fetch upstream

# Check if updates are available
if [ -z "$(git log --oneline beta..upstream/main)" ]; then
    echo "✅ Already up to date with upstream"
    exit 0
fi

echo "📋 New changes found:"
git log --oneline beta..upstream/main

# Merge changes
echo "🔀 Merging upstream changes..."
git checkout beta
git merge upstream/main

# Push to fork
echo "📤 Pushing to fork..."
git push origin beta

cd ..

# Update main repository
echo "🔗 Updating submodule reference..."
git add arr-scripts
git commit -m "Update arr-scripts submodule to latest upstream changes"

echo "✅ Synchronization complete!"
```

## Handling Conflicts

If conflicts arise during merge:

1. **Review conflicts**: Use `git status` to see conflicted files
2. **Resolve manually**: Edit files to resolve conflicts
3. **Mark as resolved**: `git add <resolved-files>`
4. **Complete merge**: `git commit`
5. **Push changes**: `git push origin beta`

## Preserving Customizations

The fork may contain specific customizations. Always:

1. Review changes before merging
2. Test functionality after updates
3. Document any custom modifications
4. Consider creating feature branches for major customizations

## Troubleshooting

### Remote URLs Changed
If remote URLs have changed:
```bash
cd arr-scripts
git remote set-url origin https://github.com/carcheky/arr-scripts.git
git remote set-url upstream https://github.com/RandomNinjaAtk/arr-scripts.git
```

### Submodule Detached HEAD
If the submodule is in detached HEAD state:
```bash
cd arr-scripts
git checkout beta
cd ..
git add arr-scripts
git commit -m "Fix arr-scripts submodule branch reference"
```

### Reset to Upstream
To completely reset to upstream (losing fork customizations):
```bash
cd arr-scripts
git checkout beta
git reset --hard upstream/main
git push --force-with-lease origin beta
cd ..
git add arr-scripts
git commit -m "Reset arr-scripts to upstream main"
```

## Verification

After synchronization, verify the setup:

```bash
# Check submodule status
git submodule status

# Verify remote configuration
cd arr-scripts && git remote -v

# Check current branch
cd arr-scripts && git branch
```

## Schedule

It's recommended to sync with upstream:
- **Weekly**: For active development periods
- **Monthly**: For maintenance periods  
- **Before releases**: Always sync before tagging releases
- **After upstream releases**: When RandomNinjaAtk releases new versions