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
  while ! ssh ${USER}@${HOST} "curl https://gitlab.com/carcheky/raspiserver/-/raw/${CHANNEL:-stable}/scripts/raspi.sh | bash -s -- run"; do
    echo "waiting script,.."
    sleep 1
  done
  echo "###################################################################################"
}

add_key

echo "___________________________________________________________________________________"
echo "press key to run:"
echo "  e) eogin"
echo "  r) run"
echo "  d) deboot"
echo "  f) feinstall"
read option
echo "___________________________________________________________________________________"

if [[ $option == "e" ]]; then
  ssh ${USER}@${HOST} cd /raspi/raspiserver
fi
if [[ $option == "r" ]]; then
  ssh ${USER}@${HOST} "curl https://gitlab.com/carcheky/raspiserver/-/raw/${CHANNEL:-stable}/scripts/raspi.sh | bash -s -- run"
fi
if [[ $option == "d" ]]; then
  ssh ${USER}@${HOST} sudo reboot
fi
if [[ $option == "f" ]]; then
  ssh ${USER}@${HOST} "curl https://gitlab.com/carcheky/raspiserver/-/raw/${CHANNEL:-stable}/scripts/raspi.sh | bash -s -- retry"
fi

bash scripts/raspi-connect.sh  

