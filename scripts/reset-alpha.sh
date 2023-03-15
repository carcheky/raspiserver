#!/bin/bash
set -eux
git reset --hard HEAD &&\
git checkout beta &&\
git branch --delete alpha &&\
git checkout -b alpha &&\
git push --force --set-upstream origin alpha
