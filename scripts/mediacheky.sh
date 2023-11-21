#!/bin/bash

RASPISERVER="${HOME}/mediacheky/raspiserver"
RASPICONFIG="${HOME}/mediacheky/RASPICONFIG"
RASPIMEDIA="${HOME}/mediacheky/RASPIMEDIA/BibliotecaMultimedia"
[ -f ${RASPISERVER}/.env ] && . ${RASPISERVER}/.env
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
    dest="$RASPIMEDIA/../Backups"

    # Create archive filename 'hostname-YYYY-MM-DD-weekday-hhmm.tar.gz'
    day=$(date  +%Y%m%d-%H%M%S-%A.tar.gz)
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
    sudo rm -fr /usr/local/bin/mediacheky*
    sudo cp -f ${RASPISERVER}/scripts/mediacheky.sh /usr/local/bin/mediacheky
    sudo ln -fs ${RASPISERVER}/scripts/mediacheky.sh /usr/local/bin/mediacheky-dev
    sudo chmod +x /usr/local/bin/mediacheky*
    ls -la /usr/local/bin/mediacheky*
}

function cron() {
    echo "/usr/local/bin/mediacheky backup" > mediacheky-backup
    echo >> mediacheky-backup
    sudo chown root:root mediacheky-backup
    sudo chmod 644 mediacheky-backup
    sudo chmod +x mediacheky-backup
    sudo mv -f mediacheky-backup /etc/cron.hourly
    sudo service cron restart
    sudo service cron status
    ls -la /etc/cron.*
}

function update(){
    apt update -y ;
    apt upgrade -y ;
    apt autoremove -y ;
    cd "${RASPISERVER}" ;
    git pull
    docker compose up -d --pull always --remove-orphans ;
    docker system prune -af ;
    docker volume prune -af ;
    mediacheky install
}

function help() {
    this_script="${BASH_SOURCE[0]}"
    echo "Usage: ${this_script} <command>"
    cat /usr/local/bin/mediacheky | grep '##'
}

${@:-help}
