#!/bin/bash
git checkout beta
git pull --no-ff --no-edit 
git merge stable --no-ff --no-edit
git push
git checkout stable
git pull --no-ff --no-edit 
git merge beta --no-ff --no-edit 
git push
git checkout beta

