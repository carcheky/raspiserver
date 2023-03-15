#!/bin/bash

git reset --hard HEAD
git checkout beta --force
git branch -D alpha
git checkout -b alpha
git push --force --set-upstream origin alpha
