#!/bin/bash
sudo rm -fr /home/user/.ssh/known_hosts /mnt/c/Users/carch/.ssh/known_hosts
key=$(cat ~/.ssh/id_rsa.pub)
ssh -oStrictHostKeyChecking=no carcheky@cckpi.local 'rmdir -fr .ssh ; mkdir .ssh ; echo "${key}" > .ssh/authorized_keys'