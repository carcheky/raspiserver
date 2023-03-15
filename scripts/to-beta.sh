#!/bin/bash

git checkout beta &&\
git pull --no-ff --no-edit &&\
git merge alpha --squash --no-commit &&\
git commit &&\
git push

git checkout beta &&\
git pull --no-ff --no-edit &&\
git merge stable --no-edit  &&\
git commit &&\
git push