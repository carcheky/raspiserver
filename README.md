# raspiserver
````
██████╗  █████╗ ███████╗██████╗ ██╗              
██╔══██╗██╔══██╗██╔════╝██╔══██╗██║              
██████╔╝███████║███████╗██████╔╝██║              
██╔══██╗██╔══██║╚════██║██╔═══╝ ██║              
██║  ██║██║  ██║███████║██║     ██║              
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝              
███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
````

## Download and run

### Stable
````
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
curl https://gitlab.com/carcheky/raspiserver/-/raw/stable/scripts/raspi.sh | bash -s -- run
````


### Beta
````
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
curl https://gitlab.com/carcheky/raspiserver/-/raw/beta/scripts/raspi.sh | bash -s -- run
````
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/beta/scripts/raspi.sh | bash -s -- retry
````


### Alpha
````
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
curl https://gitlab.com/carcheky/raspiserver/-/raw/alpha/scripts/raspi.sh | bash -s -- run
````
````
curl https://gitlab.com/carcheky/raspiserver/-/raw/alpha/scripts/raspi.sh | bash -s -- retry
````
