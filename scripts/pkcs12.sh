#!/bin/bash

openssl pkcs12 -export \
    -out /raspi/MOUNTED_raspiconfig/data/swag/config/etc/letsencrypt/live/carcheky.duckdns.org/jellyfin.p12 \
    -in /raspi/MOUNTED_raspiconfig/data/swag/config/etc/letsencrypt/live/carcheky.duckdns.org/fullchain.pem \
    -inkey /raspi/MOUNTED_raspiconfig/data/swag/config/etc/letsencrypt/live/carcheky.duckdns.org/privkey.pem \
    -passin pass: \
    -passout pass: