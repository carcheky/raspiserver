#!/bin/bash

WATCHER_TIME=30
. /raspi/raspiserver/.env

# for devs
# set -eux

# helper scripts
_install() {
  # update date
  sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
  # fix any pending install
  sudo dpkg --configure -a
  if [ ! -d /raspi ]; then
    echo "
    ██████╗  █████╗ ███████╗██████╗ ██╗
    ██╔══██╗██╔══██╗██╔════╝██╔══██╗██║
    ██████╔╝███████║███████╗██████╔╝██║
    ██╔══██╗██╔══██║╚════██║██╔═══╝ ██║
    ██║  ██║██║  ██║███████║██║     ██║
    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝                                
    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
    "
    sudo mkdir /raspi
  fi
  if [ $(which git) ]; then
    echo -e "\u2022 git ya está instalado"
  else
    echo -e "\u25E6 instalando git..."
    sudo apt update
    sudo apt install git vim -y
  fi
  if [ -d ~/.oh-my-zsh ]; then
    echo -e "\u2022 zsh ya está instalado"
  else
    echo -e "\u25E6 instalando zsh..."
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
    alias git='sudo git'
    echo \"
    ██████╗  █████╗ ███████╗██████╗ ██╗              
    ██╔══██╗██╔══██╗██╔════╝██╔══██╗██║              
    ██████╔╝███████║███████╗██████╔╝██║              
    ██╔══██╗██╔══██║╚════██║██╔═══╝ ██║              
    ██║  ██║██║  ██║███████║██║     ██║              
    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝              
    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
    ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
    ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
    \"                                                                              
    raspi logs
    " >>~/.zshrc
  fi
  if [ $(which docker) ]; then
    echo -e "\u2022 docker ya está instalado"
  else
    echo -e "\u25E6 instalando docker..."
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
      echo -e "\u25E6 group docker exists."
    else
      echo -e "\u25E6 group docker does not exist."
      sudo groupadd docker
    fi
    sudo usermod -aG docker $USER
    sudo dpkg --configure -a
  fi
  if [ -d /raspi/raspiserver ]; then
    echo -e "\u2022 raspiserver ya está instalado"
  else
    echo -e "\u25E6 instalando raspiserver..."
    sudo chmod 777 /raspi
    sudo git clone -b $CHANNEL https://gitlab.com/carcheky/raspiserver.git "/raspi/raspiserver"
    update
  fi
}
_install_bin() {
  sudo cp rc.local /etc/rc.local
  sudo cp -fr /raspi/raspiserver/scripts/raspi.sh /usr/local/bin/raspi
  sudo chmod +x /usr/local/bin/raspi
  echo -e "\u2023 necesita reinicio"
  reboot
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
    sudo chown -R $USER:$USER .
    current=$(sudo git rev-parse HEAD)
    remote=$(sudo git ls-remote $(sudo git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)
    if [ $current = $remote ]; then
      echo -e "\u2022 no hay actualizaciones disponibles"
    else
      echo -e "\u25E6 actualizando"
      sudo git config pull.ff on >/dev/null
      sudo git reset --hard >/dev/null
      sudo git pull --force >/dev/null
      sudo git pull --force >/dev/null
      up
      update
      _install_bin
    fi
  fi
}
## mount: mount hard disk
mount() {
  while [ ! -d /raspi/MOUNTED_raspimedia/BibliotecaMultimedia/Peliculas ]; do
    sudo mkdir -p /raspi/MOUNTED_raspimedia/
    sudo chmod 777 /raspi/MOUNTED_raspimedia/
    if [ $(which docker) ]; then
      sudo systemctl restart docker
    fi
    while ! sudo mount -L raspimedia /raspi/MOUNTED_raspimedia; do
      echo nop
      sleep 1
    done
  done
  while [ ! -d /raspi/MOUNTED_raspiconfig/data ]; do
    sudo mkdir -p /raspi/MOUNTED_raspiconfig/
    sudo chmod 777 /raspi/MOUNTED_raspiconfig/
    if [ $(which docker) ]; then
      sudo systemctl restart docker
    fi
    while ! sudo mount -L raspiconfig /raspi/MOUNTED_raspiconfig; do
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
## up: docker compose restart
restart() {
  mount
  if cd /raspi/raspiserver; then
    docker compose restart
    docker compose up
  fi
}
## retry: uninstall and exit
retry() {
  sudo dpkg --configure -a
  if [ $(which docker) ]; then
    sudo systemctl stop docker
  fi
  while [ -d /raspi/MOUNTED_raspimedia/BibliotecaMultimedia/Peliculas ]; do
    sudo umount /raspi/MOUNTED_raspimedia
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
    # sleep 3600
    sleep $WATCHER_TIME
  done
  exit 0
}
## log: print raspi log
log() {
  cat /raspi/raspi.log
}
## logs: docker compose logs
logs() {
  if cd /raspi/raspiserver; then
    docker compose logs -f
  fi
}
## cd: cd raspiserver folder
reboot() {
  sudo reboot
}

# this line print help if no arguments
${@:-help}
