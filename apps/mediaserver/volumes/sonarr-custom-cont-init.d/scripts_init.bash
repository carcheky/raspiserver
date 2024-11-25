#!/usr/bin/with-contenv bash
cp -f /custom-cont-init.d/extended.conf /config/extended.conf
curl https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/sonarr/setup.bash | bash
