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

    # Where to backup to.
    dest="$RASPIMEDIA/../Backups"

    # Create archive filename.
    day=$(date +%A)
    hostname=$(hostname -s)
    archive_file="$hostname-$day.tgz"

    # Print start status message.
    echo "Backing up $backup_files to $dest/$archive_file"
    date
    echo

    # Backup the files using tar.
    tar czf $dest/$archive_file $backup_files

    # Print end status message.
    echo
    echo "Backup finished"
    date

    # Long listing of files in $dest to check file sizes.
    ls -lh $dest
}

help() {
    this_script="${BASH_SOURCE[0]}"
    echo "Usage: ${this_script} <command>"
    cat /usr/local/bin/mediacheky | grep '##'
}

${@:-help}
