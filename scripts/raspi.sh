#!/bin/bash
lockfile="/tmp/raspi.lock.d"
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
  /usr/local/bin/raspi watcher
}
clone() {
  install_basics
  if [ ! -d ~/raspiserver ]; then
    git clone https://gitlab.com/carcheky/raspiserver.git ~/raspiserver
    install_raspi_bin
  fi
}
update() {
  if cd ~/raspiserver; then
    if [ $(git rev-parse HEAD) != $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ]; then
      echo "UPDATING ==========================================="
      git config pull.ff on
      git reset --hard
      git pull --force
      install_raspi_bin
    fi
  else
    echo "CLONING ==========================================="
    clone
  fi
}
mount_hd() {
  # echo "[5/7] mount_hd ===================================="
  if [ ! -d /media/carcheky/HDCCK/BibliotecaMultimedia/ ]; then
    sudo mkdir -p /media/carcheky/HDCCK/
    sudo chmod 770 /media/carcheky/HDCCK/
    sudo mount -U 2862B9A862B97AE0 /media/carcheky/HDCCK
  fi
}
docker_install() {
  # echo "[6/7] docker_install ===================================="
  if [ ! $(which docker) ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    # ########## BEGIN ##########
    # sudo sh -eux <<EOF
    # # Install newuidmap & newgidmap binaries
    # apt-get install -y uidmap
    # EOF
    # ########## END ##########
    dockerd-rootless-setuptool.sh install --force
    echo "
    export PATH=/usr/bin:\$PATH
    export DOCKER_HOST=unix:///run/user/1000/docker.sock
    docker ps
    raspi watcher
    alias docker='sudo docker'
    " >>~/.zshrc
    rm get-docker.sh
    # sudo groupadd docker
    # sudo usermod -aG docker ${USER}
    echo ${USER}
    docker run alpine echo hola mundo
  fi
}
docker_start() {
  docker compose up -d --build --remove-orphans &>/dev/null
  sudo chmod 777 /var/run/docker.sock
}
runremote() {
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
}
remove_lock() {
  rm "${lockfile}"
}
init() {
  echo ${lockfile}
  if touch "${lockfile}"; then
    logic
    remove_lock
  fi
}
help() {
  cat /usr/local/bin/raspi | grep '()'
}
watcher() {
  cd ~/raspiserver
  while true; do
    if [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ]; then
      init
      docker ps
      sleep 15
    else
      update
    fi
  done
}
logic() {
  doingthing docker_install
  doingthing mount_hd
  doingthing docker_start
}
doingthing() {
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  echo -n "${@}..."
  $(${@}) &>/dev/null
  echo -e "\\r${CHECK_MARK} ${@}"
}
reinstall() {
  sudo apt -y remove --purge "docker*" zsh
  sudo rm -fr /usr/local/bin/raspi raspiserver .oh-my-zsh .zshrc .docker /run/user/1000/docker.pid
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
  raspi watcher
}
${@:-watcher}
