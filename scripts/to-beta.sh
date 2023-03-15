#!/bin/bash

git checkout beta &&\
git pull --no-ff --no-edit &&\
git merge alpha --squash --no-commit &&\
bash scripts/git-commit-helper.sh

git checkout beta &&\
git pull --no-ff --no-edit &&\
git merge stable --no-edit  &&\
bash scripts/git-commit-helper.sh