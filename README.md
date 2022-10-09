# raspi

Download and run
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
````

to retry
````
sudo apt -y remove --purge "docker*" zsh 
sudo rm -fr /usr/bin/raspi raspiserver .oh-my-zsh .zshrc .docker  /run/user/1000/docker.pid
curl https://gitlab.com/carcheky/raspiserver/-/raw/main/scripts/raspi.sh | bash
raspi watcher
````
