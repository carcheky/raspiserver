#!/bin/bash

set -eux

git checkout beta &&\
git pull --no-ff --no-edit &&\
echo "commit message:" &&\
read commit_message &&\
git merge alpha --squash -m "$commit_message" &&\
git commit &&\
git push

git branch --delete alpha
# git branch --delete alpha &&\
# git checkout -b alpha &&\
# git push --force --set-upstream origin alpha
