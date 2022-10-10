#!/bin/bash

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@cckpi.local exit 0 >/dev/null; do
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
  while ! ssh carcheky@cckpi.local exit 0 >/dev/null; do
    echo -en " \\r waiting script.."
    sleep 1
    echo -en " \\r waiting script..."
  done
  # ssh carcheky@cckpi.local
  raspiserver_install
}

run
sleep 5
bash scripts/raspi-connect.sh
