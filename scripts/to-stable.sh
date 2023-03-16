#!/bin/bash

# test if current brach can be merged into stable
if ! git merge-base --is-ancestor beta stable; then
    echo "Current branch cannot be merged into stable"
    exit 1
fi

# check if current brach can be merged into stable
git checkout stable
git pull --no-ff --no-edit
git merge beta --no-ff --no-edit
git push
git checkout beta
