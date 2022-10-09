#!/bin/bash

echo "
██████╗  █████╗ ███████╗██████╗ ██╗
██╔══██╗██╔══██╗██╔════╝██╔══██╗██║
██████╔╝███████║███████╗██████╔╝██║
██╔══██╗██╔══██║╚════██║██╔═══╝ ██║
██║  ██║██║  ██║███████║██║     ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝                                
"

# update date
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
date

# aliases
alias docker='sudo docker'

install_basics() {
  if [ ! $(which git) ]; then
    sudo apt update
    sudo apt install git uidmap -y
  fi
  if [ ! -f ~/.zshrc ]; then
    sudo apt update
    sudo apt install zsh -y
    if [ ! -d ~/.oh-my-zsh ]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh_carcheky ]; then
      git clone --depth=1 https://gitlab.com/carcheky/zsh_carcheky.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh_carcheky
    fi
    sudo usermod -s /bin/zsh carcheky
    sudo chsh -s $(which zsh)
    sed -i s/'plugins=(git)'/'plugins=(git z composer zsh_carcheky)'/g ~/.zshrc
    echo "
    export PATH=/usr/bin:\$PATH
    
    export DOCKER_HOST=unix:///var/run/docker.sock
    
    if [ $(which docker) ]; then
      alias docker='sudo docker'
      sudo chmod 777 /var/run/docker.sock /run/user/1000/docker.sock
      docker ps
    fi

    raspi watcher

    " >>~/.zshrc
    echo "
    
    alias runremote=""
    " >>~/.bashrc
  fi
  if [ ! $(which docker) ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    # dockerd-rootless-setuptool.sh install --force
    rm get-docker.sh
    docker run alpine echo hola mundo
  fi
} &>/dev/null
install_raspi_bin() {
  # sudo cp ~/raspiserver/rc.local /etc/rc.local
  sudo cp -fr ~/raspiserver/scripts/raspi.sh /usr/bin/raspi
  sudo chmod +x /usr/bin/raspi
  remote
  exit 0
} &>/dev/null
install() {
  _doingthing install_basics
  if [ ! -d ~/raspiserver ]; then
    git clone https://gitlab.com/carcheky/raspiserver.git ~/raspiserver
    _doingthing install_raspi_bin
  fi
} 
run() {
  if cd ~/raspiserver; then
    _doingthing checking_updates
    if touch "/tmp/raspi.lock.d"; then
      _doingthing docker_run
      rm "/tmp/raspi.lock.d"
    fi
  else
    _doingthing install
  fi
}
checking_updates() {
  current=$(git rev-parse HEAD)
  remote=$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)
  if [ $current != $remote ]; then
    set -eux
    echo "actualizando..."
    git config pull.ff on 
    git reset --hard 
    git pull --force 
    _doingthing install_raspi_bin
  else
    echo "no se encontraron actualizaciones"
  fi
}
mount_hd() {
  if [ ! -d /media/carcheky/HDCCK/BibliotecaMultimedia/ ]; then
    sudo mkdir -p /media/carcheky/HDCCK/
    sudo chmod 770 /media/carcheky/HDCCK/
    sudo mount -U 2862B9A862B97AE0 /media/carcheky/HDCCK
  fi
} &>/dev/null
docker_run() {
  if mount_hd ; then
    docker compose up -d --build --remove-orphans 
    sudo chmod 777 /var/run/docker.sock
  fi
} &>/dev/null
remote() {
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
}
_doingthing() {
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  echo -n "${@}..."
  $(${@})
  echo -e "\\r${CHECK_MARK} ${@}"
}
retry() {
  sudo apt -y remove --purge "docker*"
  sudo rm -fr \
    ~/raspiserver \
    ~/.oh-my-zsh \
    ~/.zshrc \
    ~/.docker \
    /usr/bin/raspi \
    /run/user/1000/docker.pid \
    /var/run/docker.sock
  
  sleep 1 && echo -en "\\r Reinstalando en 3..."
  sleep 1 && echo -en "\\r Reinstalando en 2..."
  sleep 1 && echo -en "\\r Reinstalando en 1..."
  runremote
} 
help() {
  cat /usr/bin/raspi | grep '{'
}
watcher() {
  while true; do
    run
    # sleep 5
  done
}
install
${@:-watcher}
