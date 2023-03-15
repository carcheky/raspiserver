#!/bin/bash
set -eux
git reset --hard HEAD &&\
git checkout beta &&\
git branch -D alpha &&\
git checkout -b alpha &&\
git push --force --set-upstream origin alpha
