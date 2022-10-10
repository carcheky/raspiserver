#!/bin/bash
# set -eux
. .env
add_key() {
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p ${PASSWORD} ssh -oStrictHostKeyChecking=no ${USER}@${HOST} ${command}; do
    echo "waiting key..."
    sleep 1
  done
  if [ ! ssh ${USER}@${HOST} ls /tmp/updated ]; then
    ssh ${USER}@${HOST} sudo apt update
    ssh ${USER}@${HOST} sudo apt upgrade -y
    ssh ${USER}@${HOST} touch /tmp/updated
  fi
  echo ""
}

run() {
  while ! ssh ${USER}@${HOST} 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run'; do
    echo "waiting script,.."
    sleep 1
  done
  echo "###################################################################################"
}

add_key

echo "___________________________________________________________________________________"
echo "press key to run"
echo "  u) uninstall first"
echo "  b) login"
echo "  l) launch"
echo "  r) reboot"
read option

if [[ $option == "r" ]]; then
  ssh ${USER}@${HOST} sudo reboot
fi
if [[ $option == "u" ]]; then
  ssh ${USER}@${HOST} 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- retry'
fi
if [[ $option == "b" ]]; then
  ssh ${USER}@${HOST}
fi
if [[ $option == "l" ]]; then
  ssh ${USER}@${HOST} 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run'
fi

bash scripts/raspi-connect.sh  

