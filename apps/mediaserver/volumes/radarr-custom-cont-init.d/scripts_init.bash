#!/usr/bin/with-contenv bash
curl https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/radarr/setup.bash | bash
cp -f /custom-cont-init.d/extended.conf /config/extended.conf
cp -f /custom-cont-init.d/recyclarr.yaml /config/extended/recyclarr.yaml
