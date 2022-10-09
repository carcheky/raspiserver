#!/bin/bash

# update date
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

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
  fi
  if [ ! $(which docker) ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    # dockerd-rootless-setuptool.sh install --force
    rm get-docker.sh
    docker run alpine echo hola mundo
  fi
}
install_raspi_bin() {
  # sudo cp ~/raspiserver/rc.local /etc/rc.local
  sudo cp -fr ~/raspiserver/scripts/raspi.sh /usr/bin/raspi
  sudo chmod +x /usr/bin/raspi
  # /usr/bin/raspi watcher
  # runremote
  sudo reboot
}
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
      mount_hd
      _doingthing docker_run
      rm "/tmp/raspi.lock.d"
    fi
    sleep 5
  else
    _doingthing install
  fi
}
checking_updates() {
  current=$(git rev-parse HEAD)
  remote=$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)
  if [ $current != $remote ]; then
    echo "updating..."
    git config pull.ff on
    git reset --hard
    git pull --force
    sleep 3
    _doingthing install_raspi_bin
  fi
}
mount_hd() {
  if [ ! -d /media/carcheky/HDCCK/BibliotecaMultimedia/ ]; then
    sudo mkdir -p /media/carcheky/HDCCK/
    sudo chmod 770 /media/carcheky/HDCCK/
    sudo mount -U 2862B9A862B97AE0 /media/carcheky/HDCCK
  fi
}
docker_run() {
  docker compose up -d --build --remove-orphans &>/dev/null
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
  sudo apt -y remove --purge "docker*"
  sudo rm -fr \
    ~/raspiserver \
    ~/.oh-my-zsh \
    ~/.zshrc \
    ~/.docker \
    /usr/bin/raspi \
    /run/user/1000/docker.pid \
    /var/run/docker.sock
  sudo reboot
}
help() {
  cat /usr/bin/raspi | grep '{'
}
watcher() {
  while true; do
    run
  done
}
install
${@:-watcher}
