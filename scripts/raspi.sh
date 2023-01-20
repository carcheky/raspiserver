#!/bin/bash

WATCHER_TIME=30
RASPISERVER="${HOME}/raspiserver"
RASPIMEDIA='/media/RASPIMEDIA/'
RASPICONFIG='~/raspiserver/RASPICONFIG'
CHANNEL='stable'

if [ ! -d ${RASPISERVER} ]; then
  echo -e "\u25E6 instalando raspiserver..."
  echo "Select channel (alpha,beta,stable):" && read readchannel
  CHANNEL=${readchannel}
  echo "$CHANNEL selected"
  git clone -b ${CHANNEL} https://gitlab.com/carcheky/raspiserver.git  ~/raspiserver
  update
fi
set -eux && [ $CHANNEL == 'stable' ] && set -eu

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
    echo "contraseña genérica?: " && read readpass
    echo PASSWORD=$readpass >> ${RASPISERVER}/.env
    echo "contraseña root mysql?: " && read readmysqlrootpass
    echo MYSQL_ROOT_PASSWORD=$readmysqlrootpass >> ${RASPISERVER}/.env
    echo "contraseña mysql?: " && read readmysqlpass
    echo NEXTCLOUD_MYSQL_PASSWORD=$readmysqlpass >> ${RASPISERVER}/.env
    echo RASPISERVER="${HOME}/raspiserver" >> ${RASPISERVER}/.env
    echo RASPIMEDIA='/media/RASPIMEDIA/' >> ${RASPISERVER}/.env
    echo RASPICONFIG='~/raspiserver/RASPICONFIG' >> ${RASPISERVER}/.env
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
    _create_env
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
  while [ ! -f ${RASPIMEDIA}/this-is-the-hd ]; do
    if [ $(which docker) ]; then
      sudo systemctl stop docker
    fi
    sudo mkdir -p ${RASPIMEDIA}
    sudo chmod 777 ${RASPIMEDIA}
    sudo mount -L raspimedia ${RASPIMEDIA}
  done
  sudo systemctl start docker
}
## umount: umount hard disks
umount() {
  while [ -f ${RASPIMEDIA}/this-is-the-hd ]; do
    kill
    sudo umount ${RASPIMEDIA} -q
  done
}
## up: docker compose up -d --remove-orphans
up() {
  mount
  if cd ${RASPISERVER}; then
    docker compose up -d --remove-orphans --pull always
  fi
}
## stop: docker compose stop -d --remove-orphans
stop() {
  mount
  if cd ${RASPISERVER}; then
    docker compose stop -d --remove-orphans
  fi
}
## kill: docker compose kill
kill() {
  if cd ${RASPISERVER}; then
    set -v
    docker compose kill
    set -eux && [ $CHANNEL == 'stable' ] && set -eu
  fi
}
## down: docker compose down
down() {
  kill
  if cd ${RASPISERVER}; then
    docker compose down
  fi
}
## up: docker compose restart
restart() {
  mount
  if cd ${RASPISERVER}; then
    docker compose restart
    docker compose up -d
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

## configs_copy: copy configs if exists containers data
configs_copy(){
  [ -d ${RASPISERVER}/RASPICONFIG/swag/nginx/proxy-confs/ ] && sudo cp -f ${RASPISERVER}/configs/nginx/*.conf ${RASPISERVER}/RASPICONFIG/swag/nginx/proxy-confs/
}
## configs_backup: backup to repo configs if exists containers data
configs_backup(){
  # backup swag subdomains
  [ -d ${RASPISERVER}/RASPICONFIG/swag/nginx/proxy-confs/ ] && sudo cp -f ${RASPISERVER}/RASPICONFIG/swag/nginx/proxy-confs/*.conf ${RASPISERVER}/configs/nginx/
  # backup homeassistant configs
  [ -d ${RASPISERVER}/RASPICONFIG/homeassistant/config/ ] &&\
    ( 
      sudo cp -f ${RASPISERVER}/RASPICONFIG/homeassistant/config/configuration.yaml ${RASPISERVER}/configs/homeassistant/ ; 
      sudo cp -f ${RASPISERVER}/RASPICONFIG/homeassistant/config/automations.yaml ${RASPISERVER}/configs/homeassistant/ ; 
      sudo cp -f ${RASPISERVER}/RASPICONFIG/homeassistant/config/scenes.yaml ${RASPISERVER}/configs/homeassistant/ ; 
      sudo cp -f ${RASPISERVER}/RASPICONFIG/homeassistant/config/scripts.yaml ${RASPISERVER}/configs/homeassistant/ ; 
    )
}

# this line print help if no arguments
## help: print this help using:
help() {
  cat /usr/local/bin/raspi | grep '##'
}
${@:-help}
echo "$SECONDS seconds"