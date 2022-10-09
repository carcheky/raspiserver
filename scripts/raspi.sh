#!/bin/bash
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
# set -eux
install_basics() {
  if [ ! $(which docker) ]; then
    sudo apt update
  fi
  if [ ! $(which git) ]; then
    sudo apt install git -y
  fi
  if [ ! $(which uidmap) ]; then
    sudo apt install uidmap -y
  fi
  if [ ! $(which zsh) ]; then
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
    sed -i s/'plugins=(git)'/'plugins=(git z docker composer zsh_carcheky)'/g ~/.zshrc
  fi
}
install_raspi_bin() {
  # sudo cp ~/raspiserver/rc.local /etc/rc.local
  sudo cp -fr ~/raspiserver/scripts/raspi.sh /usr/local/bin/raspi
  sudo chmod +x /usr/local/bin/raspi
  # /usr/local/bin/raspi watcher
  # runremote
  sudo reboot
}
clone() {
  install_basics
  if [ ! -d ~/raspiserver ]; then
    git clone https://gitlab.com/carcheky/raspiserver.git ~/raspiserver
    install_raspi_bin
  fi
}
checking_updates() {
  if cd ~/raspiserver; then
    current=$(git rev-parse HEAD)
    remote=$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)
    if [ $current != $remote ]; then
      git config pull.ff on
      git reset --hard
      git pull --force
      install_raspi_bin
    fi
  else
    clone
  fi
}
hd_mount() {
  if [ ! -d /media/carcheky/HDCCK/BibliotecaMultimedia/ ]; then
    sudo mkdir -p /media/carcheky/HDCCK/
    sudo chmod 770 /media/carcheky/HDCCK/
    sudo mount -U 2862B9A862B97AE0 /media/carcheky/HDCCK
  fi
}
docker_run() {
  if [ ! $(which docker) ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    dockerd-rootless-setuptool.sh install --force
    echo "
    export PATH=/usr/bin:\$PATH
    export DOCKER_HOST=unix:///run/user/1000/docker.sock
    docker ps
    raspi watcher
    alias docker='sudo docker'
    " >>~/.zshrc
    rm get-docker.sh
    echo ${USER}
    alias docker='sudo docker'
    docker run alpine echo hola mundo
  else
    docker compose up -d --build --remove-orphans &>/dev/null
  fi
  sudo chmod 777 /var/run/docker.sock
}
runremote() {
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
}
_doingthing() {
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  echo -n "${@}..."
  $(${@}) &>/dev/null
  echo -e "\\r${CHECK_MARK} ${@}"
}
_reinstall() {
  sudo apt -y remove --purge "docker*" zsh
  sudo rm -fr /usr/local/bin/raspi raspiserver .oh-my-zsh .zshrc .docker /run/user/1000/docker.pid
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
  raspi watcher
}
help() {
  cat /usr/local/bin/raspi | grep '()'
}
watcher() {
  cd ~/raspiserver
  while true; do
    if [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ]; then
      init
      sleep 15
    else
      _doingthing checking_updates
    fi
  done
}
init() {
  lockfile="/tmp/raspi.lock.d"
  echo ${lockfile}
  if touch "${lockfile}"; then
    _doingthing docker_run
    _doingthing hd_mount
    rm "${lockfile}"
  fi
}
clone
${@:-watcher}
