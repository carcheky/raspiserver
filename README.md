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
bash <(curl -Ls https://gitlab.com/carcheky/raspiserver/-/raw/stable/scripts/raspi.sh) run
````

### Beta

````
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
bash <(curl -Ls https://gitlab.com/carcheky/raspiserver/-/raw/beta/scripts/raspi.sh) run
````

### Alpha

````
bash <(curl -Ls https://gitlab.com/carcheky/raspiserver/-/raw/alpha/scripts/raspi.sh) run
````

## know problems

### fix date

````
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

````
