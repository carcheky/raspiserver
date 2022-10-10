#!/bin/bash

key=$(cat ~/.ssh/id_rsa.pub)
command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ${command} &>/dev/null; do
    echo -en " \\r waiting key.."
    sleep 1
    echo -en " \\r waiting key..."
  done
  echo ""
}

run() {
  add_key
  while ! ssh carcheky@192.168.68.136 ls &>/dev/null; do
    echo -en " \\r waiting script.."
    sleep 1
    echo -en " \\r waiting script..."
    echo ""
  done
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- run'
}
echo "###################################################################################"



echo "press key to run, enter 'r' to uninstall first"
read option

if [[ $option == "r" ]]; then
  echo reinstalando
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- retry'
  run
  run
  run
  run
  exit 0
fi

run

bash scripts/raspi-connect.sh
