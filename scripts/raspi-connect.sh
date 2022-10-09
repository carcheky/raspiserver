#!/bin/bash
key=$(cat ~/.ssh/id_rsa.pub)
command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /mnt/c/Users/carch/.ssh/known_hosts
  ssh -oStrictHostKeyChecking=no carcheky@cckpi.local $command
}

add_key

while true; do
  ssh carcheky@cckpi.local
  sleep 1
done
