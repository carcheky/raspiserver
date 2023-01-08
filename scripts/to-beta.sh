#!/bin/bash

git checkout beta &&\
git pull --no-ff --no-edit &&\
git merge alpha --squash --no-commit &&\
git commit &&\
git push

git branch --delete alpha &&\
git checkout -b alpha &&\
git push --force --set-upstream origin alpha
