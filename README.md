# raspi

Download and run
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run
````
````
cd /tmp && curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >> raspi-connect.sh && bash raspi-connect.sh
````

to retry
````
sudo apt -y remove --purge "docker*" zsh 
sudo rm -fr /usr/bin/raspi raspiserver .oh-my-zsh .zshrc .docker  /run/user/1000/docker.pid
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run
raspi watcher
````
