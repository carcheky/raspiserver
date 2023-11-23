#!/bin/bash
# This script will install Comitizen on your server

# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "Autoelevando para ejecutar como sudo" 1>&2
    sudo bash scripts/comitizen-install.sh
    exit 0
fi

if ! [ -x "$(command -v git)" ]; then
    echo '==> INTALANDO GIT' >&2
    sudo apt install git -y
    git config --global user.email carcheky@gmail.com
    git config --global user.name carcheky
    git config --global core.filemode false
    git config --global pull.rebase true
    git config --global rebase.autoStash true
fi

if ! [ -x "$(command -v pip3)" ]; then
    echo '==> INTALANDO PIP' >&2
    sudo apt install python3-pip -y
fi

# Check if the user has already installed Comitizen
# if not, run
# sudo pip3 install -U Commitizen
# to install Commitizen
if ! [ -x "$(command -v cz)" ]; then
    echo '==> INTALANDO Commitizen' >&2
    pip3 install -U Commitizen
fi

# install pre-commit if not installed
if ! [ -x "$(command -v pre-commit)" ]; then
    echo '==> INTALANDO pre-commit' >&2
    sudo apt install pre-commit -y
fi

if ! [ -f "/usr/local/share/zsh/site-functions/_python-argcomplete" ]; then
    sudo activate-global-python-argcomplete
else
    echo "==> illo ya lo tienes instalao"
fi

