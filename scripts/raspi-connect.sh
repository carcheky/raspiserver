#!/bin/bash

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@cckpi.local exit &>/dev/null; do
    echo -en " \\r waiting key.."
    sleep 1
    echo -en " \\r waiting key..."
  done
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@cckpi.local ${command}
}
raspiserver_install() {
  ssh carcheky@cckpi.local 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

run() {
  add_key
  while ! ssh carcheky@cckpi.local ls &>/dev/null; do
    echo -en " \\r waiting script.."
    sleep 1
    echo -en " \\r waiting script..."
  done
  # ssh carcheky@cckpi.local
  echo "###################################################################################"
  # ssh carcheky@cckpi.local 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
  ssh carcheky@cckpi.local 'raspi run'
}

run

echo "###################################################################################"
# sleep 15
# bash scripts/raspi-connect.sh
