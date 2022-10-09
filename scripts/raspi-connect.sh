#!/bin/bash

add_key() {
  # while ! ssh carcheky@cckpi.local ls &>/dev/null ; do
  while true; do
    echo -en "\\r comprobando."
    sleep .5
    echo -en "\\r comprobando.."
    sleep .5
    echo -en "\\r comprobando..."
    sleep .5
  done
  sudo rm -fr /home/user/.ssh/known_hosts /mnt/c/Users/carch/.ssh/known_hosts

  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  ssh -oStrictHostKeyChecking=no carcheky@cckpi.local "if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
}
raspiserver_install() {
  ssh carcheky@cckpi.local 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

add_key
# raspiserver_install
while true; do
  ssh carcheky@cckpi.local
  sleep 3
done
