#!/bin/bash
lockfile="/tmp/raspi.lock.d"
alias docker='sudo docker'
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
# set -eux
install_git() {
  # echo "[1/7] install_git ===================================="
  if [ ! $(which git) ]; then
    sudo apt update
    sudo apt install git uidmap -y
  fi
}
install_zsh() {
  # echo "[2/7] install_zsh ===================================="
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
raspi_clone() {
  # echo "[3/7] raspi_clone ===================================="
  install_git
  install_zsh
  if [ ! -d ~/raspiserver ]; then
    git clone https://gitlab.com/carcheky/raspiserver.git ~/raspiserver
    raspi_install
  fi
}
raspi_update() {
  # echo "[4/7] raspi_update ===================================="
  if cd ~/raspiserver; then
    if [ $(git rev-parse HEAD) != $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ]; then
      echo "UPDATING ==========================================="
      git config pull.ff on
      git reset --hard
      git pull --force
      raspi_install
      echo "REBOOTING ==========================================="
      raspi start
      raspi watcher
      # sudo reboot
    else
      exit 0
    fi
  else
    raspi_clone
    raspi watcher
    exit 0
  fi
}
raspi_install() {
  # sudo cp ~/raspiserver/rc.local /etc/rc.local
  sudo cp -fr ~/raspiserver/scripts/raspi.sh /usr/local/bin/raspi
  sudo chmod +x /usr/local/bin/raspi
}
raspi_mount() {
  # echo "[5/7] raspi_mount ===================================="
  if [ ! -d /media/carcheky/HDCCK/BibliotecaMultimedia/ ]; then
    sudo mkdir -p /media/carcheky/HDCCK/
    sudo chmod 770 /media/carcheky/HDCCK/
    sudo mount -U 2862B9A862B97AE0 /media/carcheky/HDCCK
  fi
}
install_docker() {
  # echo "[6/7] install_docker ===================================="
  if [ ! $(which docker) ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    ########## BEGIN ##########
    sudo sh -eux <<EOF
# Install newuidmap & newgidmap binaries
apt-get install -y uidmap
EOF
    ########## END ##########
    dockerd-rootless-setuptool.sh install --force
    echo "
    export PATH=/usr/bin:\$PATH
    export DOCKER_HOST=unix:///run/user/1000/docker.sock
    alias docker='docker'
    docker ps
    raspi watcher
    " >>~/.zshrc
    cat ~/.zshrc
    rm get-docker.sh
    # sudo groupadd docker
    # sudo usermod -aG docker ${USER}
    echo ${USER}
    docker run alpine echo hola mundo
  fi
}
docker_start() {
  # echo "[7/7] docker_start ===================================="
  if [ $(docker compose up -d --build) ]; then
    sudo chmod 777 /var/run/docker.sock
  else
    docker_install
  fi
}
runremote() {
  curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
}
remove_lock() {
  # echo "[UN-LOCKED] ===================================="
  rm "${lockfile}"
}
start() {
  echo ${lockfile}
  if touch "${lockfile}"; then
    # echo "[LOCKED]===================================="
    logic
    remove_lock
    exit 0
  fi
}
help() {
  cat /usr/local/bin/raspi | grep '()'
}
watcher() {
  while true; do
    if [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ]; then
      doingthing raspi_update
      docker_start
      docker ps
      sleep 5
    fi
  done
}
logic() {
  doingthing install_docker
  doingthing raspi_mount
  docker_start
}
doingthing() {
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  echo -n "${@}..."
  $(${@}) &>/dev/null
  echo -e "\\r${CHECK_MARK} ${@}"
}
${@:-watcher}
