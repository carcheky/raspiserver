#!/bin/bash

gco stable 
gl --no-edit --no-ff
git merge beta --no-edit --no-ff 
gp 
gco beta 
git merge stable --no-ff --no-edit 
gp