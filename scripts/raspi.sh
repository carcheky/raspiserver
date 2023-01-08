#!/bin/bash

WATCHER_TIME=30
RASPISERVER='~/raspiserver'
RASPIMEDIA='/media/RASPIMEDIA/'
RASPICONFIG='~/raspiserver/RASPICONFIG'
echo "Select channel (alpha,beta,stable):" && read var
CHANNEL=${var:-alpha}

[ ! $CHANNEL == 'stable' ] && set -eux

[ -f ${RASPISERVER}/.env ] && . ${RASPISERVER}/.env

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
    curl https://gitlab.com/carcheky/scripts/-/raw/main/install/zsh-ubuntu.sh | bash

    echo "
    
    export PATH=~/bin:/usr/bin:\$PATH
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
  if [ -d ${RASPISERVER} ]; then
    echo -e "\u2022 raspiserver ya está instalado"
  else
    echo -e "\u25E6 instalando raspiserver..."
    sudo chmod 777 /raspi
    sudo git clone -b ${CHANNEL} https://gitlab.com/carcheky/raspiserver.git  ${RASPISERVER}
    _create_env
    update
  fi
}
_install_bin() {
  sudo ln -fs ${RASPISERVER}/configs/raspbian/rc.local /etc/rc.local
  sudo ln -fs ${RASPISERVER}/scripts/raspi.sh /usr/local/bin/raspi
  sudo chmod +x /usr/local/bin/raspi
  echo -e "\u2023 necesita reinicio"
  reboot
  exit 0
}
_create_env(){
  if [ ! -f ${RASPISERVER}/.env ]; then
    cp ${RASPISERVER}/.env.dist ${RASPISERVER}/.env
    echo "######################################################"
    echo "contraseña genérica?: " && read var
    echo PASSWORD=$var >> ${RASPISERVER}/.env
    echo "contraseña root mysql?: " && read var
    echo MYSQL_ROOT_PASSWORD=$var >> ${RASPISERVER}/.env
    echo "contraseña mysql?: " && read var
    echo NEXTCLOUD_MYSQL_PASSWORD=$var >> ${RASPISERVER}/.env
  fi
}
## run: install, update & run
run() {
  _install
  if cd ${RASPISERVER}; then
    update
    up
  fi
}
## update: if update, update and reboot
update() {
  if cd ${RASPISERVER}; then
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
  if [ $(which docker) ]; then
    kill
    sudo systemctl stop docker
  fi
  while [ ! -f ${RASPIMEDIA}/this-is-the-hd ]; do
    sudo mkdir -p ${RASPIMEDIA}/
    sudo chmod 777 ${RASPIMEDIA}/
    while ! sudo mount -L raspimedia ${RASPIMEDIA}; do
      echo nop
      sleep 1
    done
  done
  sudo systemctl start docker
}
## umount: umount hard disks
umount() {
  kill
  sudo umount ${RASPIMEDIA}
}
## up: docker compose up -d --remove-orphans
up() {
  mount
  if cd ${RASPISERVER}; then
    docker compose up -d --remove-orphans
  fi
}
## stop: docker compose stop -d --remove-orphans
stop() {
  mount
  if cd ${RASPISERVER}; then
    docker compose stop -d --remove-orphans
  fi
}
## kill: docker compose kill -d --remove-orphans
kill() {
  mount
  if cd ${RASPISERVER}; then
    docker compose kill -d --remove-orphans
  fi
}
## down: docker compose down -d --remove-orphans
down() {
  mount
  if cd ${RASPISERVER}; then
    docker compose down -d --remove-orphans
  fi
}
## up: docker compose restart
restart() {
  mount
  if cd ${RASPISERVER}; then
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
  while [ -d ${RASPIMEDIA}/BibliotecaMultimedia/Peliculas ]; do
    sudo umount ${RASPIMEDIA}
  done
  sudo apt -y remove --purge "docker*" containerd runc git
  sudo rm -fr \
    /usr/bin/raspi \
    /usr/local/bin/raspi \
    ${RASPISERVER}\
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
  if cd ${RASPISERVER}; then
    docker compose logs -f
  fi
}
## cd: cd raspiserver folder
reboot() {
  sudo reboot
}

jellyfin_ssl(){
  if [ -d ${RASPICONFIG}/data/swag/config/etc/letsencrypt/live/carcheky.tplinkdns.com/ ]; then
    openssl pkcs12 -export \
        -out ${RASPICONFIG}/data/swag/config/etc/letsencrypt/live/carcheky.tplinkdns.com/jellyfin.p12 \
        -in ${RASPICONFIG}/data/swag/config/etc/letsencrypt/live/carcheky.tplinkdns.com/fullchain.pem \
        -inkey ${RASPICONFIG}/data/swag/config/etc/letsencrypt/live/carcheky.tplinkdns.com/privkey.pem \
        -passin pass: \
        -passout pass:
  fi
}
# this line print help if no arguments
${@:-help}
