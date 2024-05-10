#!/bin/bash

RASPISERVER="/home/carcheky/mediacheky/raspiserver"
RASPICONFIG="/home/carcheky/mediacheky/RASPICONFIG"
RASPIMEDIA="/home/carcheky/mediacheky/RASPIMEDIA/BibliotecaMultimedia"
[ -f ${RASPISERVER}/.env ] && . ${RASPISERVER}/.env
cd "${RASPISERVER}"

### MEDIACHEKY SERVER

function backup() {

    ####################################
    #
    ## backup:
    ## Backup to NFS mount script.
    #
    ####################################

    # What to backup.
    backup_files="$RASPISERVER $RASPICONFIG"

    # Subfolders to exclude.
    # exclude_subfolders=

    # Where to backup to.
    dest="$RASPIMEDIA/../../Backups"

    # Create archive filename 'hostname-YYYY-MM-DD-weekday-hhmm.tar.gz'
    day=$(date +%Y%m%d-%H%M%S-%A.tar.gz)
    hostname=$(hostname -s)
    archive_file="$hostname-$day.tgz"

    # Print start status message.
    echo "Backing up $backup_files to $dest/$archive_file"
    date
    echo

    # Backup the files using tar, excluding specified subfolders.
    tar -zcf $dest/$archive_file --exclude={"*/MediaCover/*","*/cache/*","*/keyframes/*","*/metadata/*","*/logs/*","*/collections/*","*/database/sessions/*"} $backup_files

    # Print end status message.
    echo
    echo "Backup finished"
    date

    # Long listing of files in $dest to check file sizes.
    ls -lh $dest
    df -h $dest
}

function install() {
    if ! [ -x "$(command -v git)" ]; then
        bash scripts/comitizen-install.sh
    fi
    cp ${RASPISERVER}/configs/.kopiaignore ..
    mediacheky cron
    sudo cp configs/raspbian/sudoers-mediacheky /etc/sudoers.d/sudoers-mediacheky
    sudo chmod 440 /etc/sudoers.d/sudoers-mediacheky
    sudo rm -fr /usr/local/bin/mediacheky*
    sudo cp -f ${RASPISERVER}/scripts/mediacheky.sh /usr/local/bin/mediacheky
    sudo ln -fs ${RASPISERVER}/scripts/mediacheky.sh /usr/local/bin/mediacheky-dev
    sudo chmod +x /usr/local/bin/mediacheky*
    sudo chown -R $(id -u):$(id -g) ${RASPISERVER} ${RASPICONFIG}
    ls -la /usr/local/bin/mediacheky*
}

function perms() {
    git config --global user.email carcheky@gmail.com
    git config --global user.name carcheky
    git config --global core.filemode false
    git config --global pull.rebase true
    git config --global rebase.autoStash true
}

function cron() {
    sudo cp -f ${RASPISERVER}/configs/raspbian/cron.d/* /etc/cron.d/
    sudo chown root:root /etc/cron.d/*
    sudo chmod 644 /etc/cron.d/*
    sudo chmod +x /etc/cron.d/*
    sudo service cron restart
}

function update() {
    echo "----------------------------------------------------------"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] mediacheky update START" >> ${RASPISERVER}/logs/mediacheky-update.log
    cd "${RASPISERVER}"
    git pull --rebase --autostash  
    sudo find /var/lib/docker/containers/ -name "*-json.log" -exec truncate -s 0 {} \; 
    docker compose up -d
    docker system prune -af 
    docker volume prune -af 
    mediacheky install
    [ -f ${RASPISERVER}/apps/homeassistant/volumes/ha-config/automations.yaml ] && cp ${RASPISERVER}/apps/homeassistant/volumes/ha-config/automations.yaml ${RASPISERVER}/configs/homeassistant/ 
    [ -f ${RASPISERVER}/apps/homeassistant/volumes/ha-config/configuration.yaml ] && cp ${RASPISERVER}/apps/homeassistant/volumes/ha-config/configuration.yaml ${RASPISERVER}/configs/homeassistant/ 
    [ -f ${RASPISERVER}/apps/homeassistant/volumes/ha-config/scenes.yaml ] && cp ${RASPISERVER}/apps/homeassistant/volumes/ha-config/scenes.yaml ${RASPISERVER}/configs/homeassistant/ 
    [ -f ${RASPISERVER}/apps/homeassistant/volumes/ha-config/scripts.yaml ] && cp ${RASPISERVER}/apps/homeassistant/volumes/ha-config/scripts.yaml ${RASPISERVER}/configs/homeassistant/
    git add configs && git commit -m "fix: configs"
    # [ -d /media/raspimedia10 ] && sudo mount -a && sudo mdadm -D /dev/md0 && sudo df -h  /media/raspi* /home/carcheky/mediacheky/RASPIMEDIA /home/carcheky/RAID-mediacheky
    [ ! -d ${RASPISERVER}/logs ] && mkdir -p ${RASPISERVER}/logs
    [ ! -f ${RASPISERVER}/logs/mediacheky-update.log ] && touch ${RASPISERVER}/logs/mediacheky-update.log
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] mediacheky update END" >> ${RASPISERVER}/logs/mediacheky-update.log
}  

function update_all() {
    ssh $ip1 mediacheky update
    ssh $ip3 mediacheky update
    ssh $ip2 mediacheky update
}

function help() {
    this_script="${BASH_SOURCE[0]}"
    echo "Usage: ${this_script} <command>"
    cat /usr/local/bin/mediacheky | grep '##'
}

${@:-help}
