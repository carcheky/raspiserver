#!/bin/bash

add_key() {
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ls &>/dev/null; do
    echo -en " \\r waiting key.."
    sleep 1
    echo -en " \\r waiting key..."
  done
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ${command}
}
raspiserver_install() {
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

run() {
  add_key
  while ! ssh carcheky@192.168.68.136 ls &>/dev/null; do
    echo -en " \\r waiting script.."
    sleep 1
    echo -en " \\r waiting script..."
  done
  # ssh carcheky@192.168.68.136
  echo "###################################################################################"
  # ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
  # ssh carcheky@192.168.68.136 'raspi run'
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

run

echo "###################################################################################"
# sleep 15

echo "press key to rerun, enter 'r' to retry"
read option

if [[ $option == "r" ]]; then
  echo reinstalando
  ssh carcheky@192.168.68.136 raspi retry
fi
bash scripts/raspi-connect.sh
