#!/bin/bash

add_key() {
  while ! ssh -oStrictHostKeyChecking=no carcheky@cckpi.local exit &>/dev/null; do
    echo -en " \\r waiting key.."
    sleep 1
    echo -en " \\r waiting key..."
  done
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  ssh -oStrictHostKeyChecking=no carcheky@cckpi.local ${command}
}
raspiserver_install() {
  ssh carcheky@cckpi.local 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

add_key
while ! ssh -oStrictHostKeyChecking=no carcheky@cckpi.local exit &>/dev/null; do
  echo -en " \\r waiting script.."
  sleep 1
  echo -en " \\r waiting script..."
done
# ssh carcheky@cckpi.local
raspiserver_install
sleep 5
bash scripts/raspi-connect.sh
