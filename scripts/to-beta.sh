#!/bin/bash
git checkout alpha
git pull --no-ff --no-edit 
git push
git checkout beta
git pull --no-ff --no-edit
git merge alpha --squash --no-commit
git push
git branch --delete alpha
git checkout alpha
git push --force
