#!/bin/bash

git checkout stable
git pull --no-edit --no-ff
git merge beta --no-edit --no-ff
git push
git checkou beta
git merge stable --no-ff --no-edit
git push
