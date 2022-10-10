#!/bin/bash

key=$(cat ~/.ssh/id_rsa.pub)
command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ${command} ; do
    echo "waiting key..."
    sleep 1
  done
  echo ""
}

run() {
  while ! ssh carcheky@192.168.68.136 ls &>/dev/null; do
    echo "waiting script,.."
    sleep 1
  done
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- run'
}
echo "###################################################################################"


add_key

echo "press key to run, enter 'r' to uninstall first"
read option

if [[ $option == "r" ]]; then
  echo reinstalando
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- retry'
  run
  run
  exit 0
fi

run

curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >> raspi-connect.sh && bash raspi-connect.sh
#!/bin/bash

key=$(cat ~/.ssh/id_rsa.pub)
command="if [ ! -d .ssh ]; then mkdir .ssh; fi ; echo \"${key}\" > .ssh/authorized_keys"

add_key() {
  sudo rm -fr /home/user/.ssh/known_hosts /home/user/.ssh/known_hosts.old /home/user/.ssh/authorized_keys /mnt/c/Users/carch/.ssh/known_hosts
  while ! sshpass -p locococo ssh -oStrictHostKeyChecking=no carcheky@192.168.68.136 ${command} ; do
    echo "waiting key..."
    sleep 1
  done
  echo ""
}

run() {
  while ! ssh carcheky@192.168.68.136 ls &>/dev/null; do
    echo "waiting script,.."
    sleep 1
  done
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  echo "###################################################################################"
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- run'
}
echo "###################################################################################"


add_key

echo "press key to run, enter 'r' to uninstall first"
read option

if [[ $option == "r" ]]; then
  echo reinstalando
  ssh carcheky@192.168.68.136 'curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run  -s -- retry'
  run
  run
  exit 0
fi

run

curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >> raspi-connect.sh && bash raspi-connect.sh
