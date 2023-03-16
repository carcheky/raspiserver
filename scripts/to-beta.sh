#!/bin/bash

# get current branch for later
currentBranch=$(git rev-parse --abbrev-ref HEAD)

# test if current brach can be merged into beta
if ! git merge-base --is-ancestor $currentBranch beta; then
    echo "Current branch cannot be merged into beta"
    exit 1
fi

# check if current brach can be merged into beta
git checkout beta
git pull --no-ff --no-edit 
git merge $currentBranch --squash --no-commit
git push
git checkout $currentBranch
