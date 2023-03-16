#!/bin/bash
# This script will install Comitizen on your server

# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    sudo bash scripts/comitizen-install.sh
    exit 0
fi

# Check if the user has already installed Comitizen
# if not, run
# sudo pip3 install -U Commitizen
# to install Commitizen
if ! [ -x "$(command -v cz)" ]; then
    echo 'Error: Commitizen is not installed.' >&2
    sudo pip3 install -U Commitizen
fi

# install pre-commit if not installed
if ! [ -x "$(command -v pre-commit)" ]; then
    echo 'Error: pre-commit is not installed.' >&2
    sudo apt install pre-commit
fi

sudo activate-global-python-argcomplete
# sudo chown -R $USER:$USER .git/hooks
# pre-commit install --hook-type commit-msg --hook-type pre-push
# sudo chown -R $USER:$USER .git/hooks