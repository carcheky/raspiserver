#!/bin/bash

# Script para reorganizar los servicios a sus ubicaciones correctas

BASE_DIR="/home/user/mediacheky/raspiserver"
SERVICES_DIR="${BASE_DIR}/apps/services"
APPS_DIR="${BASE_DIR}/apps"

# Crear directorios de destino si no existen
mkdir -p "${BASE_DIR}/apps/mediaserver"
mkdir -p "${BASE_DIR}/apps/homeassistant"
mkdir -p "${BASE_DIR}/apps/dashboard"
mkdir -p "${BASE_DIR}/apps/adguard"
mkdir -p "${BASE_DIR}/apps/experiments"
mkdir -p "${BASE_DIR}/apps/managers"
mkdir -p "${BASE_DIR}/apps/tunnel"
mkdir -p "${BASE_DIR}/apps/monitoring"
mkdir -p "${BASE_DIR}/apps/nextcloud"
mkdir -p "${BASE_DIR}/apps/code"
mkdir -p "${BASE_DIR}/apps/nordvpn"
mkdir -p "${BASE_DIR}/apps/watchtower"

# Mapeo de servicios a directorios
declare -A service_mapping=(
  ["service-jellyfin.yml"]="mediaserver/docker-compose.jellyfin.yml"
  ["service-jellyseerr.yml"]="mediaserver/docker-compose.jellyseerr.yml"
  ["service-sonarr.yml"]="mediaserver/docker-compose.sonarr.yml"
  ["service-radarr.yml"]="mediaserver/docker-compose.radarr.yml"
  ["service-bazarr.yml"]="mediaserver/docker-compose.bazarr.yml"
  ["service-prowlarr.yml"]="mediaserver/docker-compose.prowlarr.yml"
  ["service-transmission.yml"]="mediaserver/docker-compose.transmission.yml"
  ["service-wizarr.yml"]="mediaserver/docker-compose.wizarr.yml"
  ["service-readarr.yml"]="mediaserver/docker-compose.readarr.yml"
  ["service-mylar3.yml"]="mediaserver/docker-compose.mylar3.yml"
  ["service-lidarr.yml"]="mediaserver/docker-compose.lidarr.yml"
  ["service-janitorr.yml"]="mediaserver/docker-compose.janitorr.yml"
  ["service-telegram.yml"]="mediaserver/docker-compose.telegram.yml"
  ["service-plex.yml"]="mediaserver/docker-compose.plex.yml"
  
  ["service-homeassistant.yml"]="homeassistant/docker-compose.homeassistant.yml"
  ["service-mqtt.yml"]="homeassistant/docker-compose.mqtt.yml"
  ["service-esphome.yml"]="homeassistant/docker-compose.esphome.yml"
  ["service-romassistant.yml"]="homeassistant/docker-compose.romassistant.yml"
  
  ["service-homarr.yml"]="dashboard/docker-compose.homarr.yml"
  
  ["service-adguard.yml"]="adguard/docker-compose.adguardhome.yml"
  ["service-pihole.yml"]="adguard/docker-compose.pihole.yml"
  
  ["service-activepieces.yml"]="experiments/docker-compose.activepieces.yml"
  ["service-authelia.yml"]="experiments/docker-compose.authelia.yml"
  ["service-n8n.yml"]="experiments/docker-compose.n8n.yml"
  ["service-netdata.yml"]="experiments/docker-compose.netdata.yml"
  ["service-thingsboard.yml"]="experiments/docker-compose.thingsboard.yml"
  
  ["service-portainer.yml"]="managers/docker-compose.portainer.yml"
  
  ["service-wireward.yml"]="tunnel/docker-compose.wireward.yml"
  ["service-nordvpn.yml"]="nordvpn/docker-compose.nordvpn.yml"
  
  ["service-nextcloud.yml"]="nextcloud/docker-compose.nextcloud.yml"
  
  ["service-watchtower.yml"]="watchtower/docker-compose.watchtower.yml"
  
  ["service-code.yml"]="code/docker-compose.code.yml"
)

# Mover cada archivo a su ubicación correcta
for service_file in "${!service_mapping[@]}"; do
  source_file="${SERVICES_DIR}/${service_file}"
  target_path="${APPS_DIR}/${service_mapping[$service_file]}"
  
  if [ -f "$source_file" ]; then
    echo "Moviendo $service_file a ${service_mapping[$service_file]}"
    cp "$source_file" "$target_path"
    echo "Actualizado: $target_path"
  else
    echo "No se encontró el archivo: $source_file"
  fi
done

# Actualizar el docker-compose.yml para que apunte a las nuevas ubicaciones
echo "Actualizando docker-compose.yml para apuntar a las nuevas ubicaciones..."

sed -i 's|apps/services/service-homeassistant.yml|apps/homeassistant/docker-compose.homeassistant.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-mqtt.yml|apps/homeassistant/docker-compose.mqtt.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-jellyfin.yml|apps/mediaserver/docker-compose.jellyfin.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-jellyseerr.yml|apps/mediaserver/docker-compose.jellyseerr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-bazarr.yml|apps/mediaserver/docker-compose.bazarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-homarr.yml|apps/dashboard/docker-compose.homarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-adguard.yml|apps/adguard/docker-compose.adguardhome.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-nextcloud.yml|apps/nextcloud/docker-compose.nextcloud.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-wireward.yml|apps/tunnel/docker-compose.wireward.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-sonarr.yml|apps/mediaserver/docker-compose.sonarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-radarr.yml|apps/mediaserver/docker-compose.radarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-prowlarr.yml|apps/mediaserver/docker-compose.prowlarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-transmission.yml|apps/mediaserver/docker-compose.transmission.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-wizarr.yml|apps/mediaserver/docker-compose.wizarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-readarr.yml|apps/mediaserver/docker-compose.readarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-mylar3.yml|apps/mediaserver/docker-compose.mylar3.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-lidarr.yml|apps/mediaserver/docker-compose.lidarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-janitorr.yml|apps/mediaserver/docker-compose.janitorr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-esphome.yml|apps/homeassistant/docker-compose.esphome.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-romassistant.yml|apps/homeassistant/docker-compose.romassistant.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-activepieces.yml|apps/experiments/docker-compose.activepieces.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-authelia.yml|apps/experiments/docker-compose.authelia.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-n8n.yml|apps/experiments/docker-compose.n8n.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-plex.yml|apps/mediaserver/docker-compose.plex.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-netdata.yml|apps/experiments/docker-compose.netdata.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-pihole.yml|apps/adguard/docker-compose.pihole.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-portainer.yml|apps/managers/docker-compose.portainer.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-telegram.yml|apps/mediaserver/docker-compose.telegram.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-thingsboard.yml|apps/experiments/docker-compose.thingsboard.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-nordvpn.yml|apps/nordvpn/docker-compose.nordvpn.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-watchtower.yml|apps/watchtower/docker-compose.watchtower.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/services/service-code.yml|apps/code/docker-compose.code.yml|g' "${BASE_DIR}/docker-compose.yml"

echo "Reorganización completa."
