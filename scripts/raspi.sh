#!/bin/bash

raspipath=''

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

# set -eux

# helper scripts
_install() {
  sudo dpkg --configure -a
  if [ ! -d /raspi ]; then
    sudo mkdir /raspi
  fi
  if [ $(which git) ]; then
    echo "- git ya está instalado"
  else
    echo "- instalando git..."
    sudo apt update
    sudo apt install git vim -y
  fi
  if [ -d ~/.oh-my-zsh ]; then
    echo "- zsh ya está instalado"
  else
    echo "- instalando zsh..."
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
    sudo usermod -s /bin/zsh $USER
    sudo chsh -s $(which zsh)
    # sed -i s/'ZSH_THEME="robbyrussell"'/'ZSH_THEME="powerlevel10k\/powerlevel10k"'/g ~/.zshrc
    sed -i s/'plugins=(git)'/'plugins=(git z composer zsh_carcheky)'/g ~/.zshrc
    echo "
    
    export PATH=/usr/bin:\$PATH
    # alias docker='sudo docker'
    # alias reboot='sudo reboot'
    # export DOCKER_HOST=unix:///var/run/docker.sock
    # if [ \$(which docker) ]; then
    #   sleep 15
    #   alias docker='sudo docker'
    #   cd /raspiserver && docker compose restart
    #   docker ps
    # fi

    " >>~/.zshrc
  fi
  if [ $(which docker) ]; then
    echo "- docker ya está instalado"
  else
    echo "- instalando docker..."
    # curl -fsSL https://get.docker.com -o get-docker.sh
    # sudo sh get-docker.sh
    # dockerd-rootless-setuptool.sh install --force
    # rm get-docker.sh
    sudo apt update
    sudo apt install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    if [ $(getent group docker) ]; then
      echo "- group docker exists."
    else
      echo "- group docker does not exist."
      sudo groupadd docker
    fi
    sudo usermod -aG docker $USER
    sudo dpkg --configure -a
  fi
  if [ -d /raspi/raspiserver ]; then
    echo "- raspiserver ya está instalado"
  else
    echo "- instalando raspiserver..."
    sudo chmod 777 /raspi
    git clone https://gitlab.com/carcheky/raspiserver.git "/raspi/raspiserver"
    _install_raspi_bin
  fi
}
_install_raspi_bin() {
  sudo cp -fr "/raspi/raspiserver/scripts/raspi.sh" /usr/local/bin/raspi
  sudo chmod +x /usr/local/bin/raspi
  echo "- necesita reinicio"
  sudo reboot
  exit 0
}
## run: install, update & run
run() {
  _install
  if cd /raspi/raspiserver; then
    update
    up
  fi
}
## update: if update, update and reboot
update() {
  if cd /raspi/raspiserver; then
    current=$(git rev-parse HEAD)
    remote=$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)
    if [ $current = $remote ]; then
      echo "- no hay actualizaciones nuevas"
    else
      echo "- actualizando"
      git config pull.ff on >/dev/null
      git reset --hard >/dev/null
      git pull --force >/dev/null
      up
      _install_raspi_bin
    fi
  fi
}
## mount: mount hard disk
mount() {
  while [ ! -d /raspi/MOUNTED_HD/BibliotecaMultimedia/Peliculas ]; do
    sudo mkdir -p /raspi/MOUNTED_HD/
    sudo chmod 777 /raspi/MOUNTED_HD/
    if [ $(which docker) ]; then
      sudo systemctl restart docker
    fi
    while ! sudo mount -L HDCCK /raspi/MOUNTED_HD; do
      echo nop
      sleep 1
    done
  done
}
## up: docker compose up -d --remove-orphans
up() {
  mount
  if cd /raspi/raspiserver; then
    docker compose up -d --remove-orphans
  fi
}
## remote: run this script from remote repo
remote() {
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | sudo bash
}
## retry: uninstall and exit
retry() {
  if [ $(which docker) ]; then
    sudo systemctl stop docker
  fi
  while [ -d /raspi/MOUNTED_HD/BibliotecaMultimedia/Peliculas ]; do
    sudo umount /raspi/MOUNTED_HD
  done
  sudo apt -y remove --purge "docker*" containerd runc git
  sudo rm -fr \
    /usr/bin/raspi \
    /usr/local/bin/raspi \
    /raspi \
    ~/.oh-my-zsh \
    ~/.zshrc \
    ~/.docker \
    /run/user/1000/docker.pid \
    /var/run/docker.sock
  exit 0
}
## help: print this help
help() {
  cat /usr/local/bin/raspi | grep '##'
}
## watcher: keep checking repo to update if new code available
watcher() {
  while true; do
    update
    sleep 30
  done
  exit 0
}
# this line print help if no arguments
${@:-help}
