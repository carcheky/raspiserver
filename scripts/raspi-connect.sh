#!/bin/bash

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /mnt/c/Users/carch/.ssh/known_hosts
  while ! ssh -oStrictHostKeyChecking=no carcheky@cckpi.local exit 0 &>/dev/null ; do
    sleep .1 && echo -en "\\r comprobando..."
    sleep .1 && echo -en "\\r .comprobando.."
    sleep .1 && echo -en "\\r ..comprobando."
    sleep .1 && echo -en "\\r ...comprobando"
    sleep .1 && echo -en "\\r ..comprobando."
    sleep .1 && echo -en "\\r ..comprobando."
    sleep .1 && echo -en "\\r .comprobando.."
    sleep .1 && echo -en "\\r comprobando..."    
  done
  key=$(cat ~/.ssh/id_rsa.pub)
  command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"
  ssh -oStrictHostKeyChecking=no carcheky@cckpi.local ${command}
}
raspiserver_install() {
  ssh carcheky@cckpi.local 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash'
}

add_key
raspiserver_install

while true; do
  ssh carcheky@cckpi.local
  sleep 1
done
