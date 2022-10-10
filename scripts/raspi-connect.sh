#!/bin/bash
set -eux
. .env
add_key() {
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no ${USER}@${HOST} ${command}; do
    echo "waiting key..."
    sleep 1
  done
  ssh ${USER}@${HOST} sudo apt update
  ssh ${USER}@${HOST} sudo apt upgrade -y
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
echo "press key to run, enter 'r' to uninstall first"
read option

if [[ $option == "r" ]]; then
  echo reinstalando
  ssh ${USER}@${HOST} 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- retry'
fi

run

rm -fr /tmp/raspi-connect.sh
while ! $(curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >/tmp/raspi-connect.sh) ; do
  bash /tmp/raspi-connect.sh
done
