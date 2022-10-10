#!/bin/bash

key=$(cat ~/.ssh/id_rsa.pub)
command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ${command}; do
    echo "waiting key..."
    sleep 1
  done
  echo ""
}

run() {
  while ! ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run'; do
  done
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
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- retry'
  run
  run
  exit 0
fi

run
rm -fr /tmp/raspi-connect.sh
while ! curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >>/tmp/raspi-connect.sh ; do
  bash /tmp/raspi-connect.sh
done
