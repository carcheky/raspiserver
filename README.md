# raspi

Download and run
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run
````
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi-connect.sh >> /tmp/raspi-connect.sh && bash /tmp/raspi-connect.sh
````

to retry
````
sudo apt -y remove --purge "docker*" zsh 
sudo rm -fr /usr/bin/raspi raspiserver .oh-my-zsh .zshrc .docker  /run/user/1000/docker.pid
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash -s -- run
raspi watcher
````
