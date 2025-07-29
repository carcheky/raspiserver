#!/bin/bash

# Este script limpia la estructura de archivos docker-compose
# Borra los ymls de apps si existen en services

BASE_DIR="/home/user/mediacheky/raspiserver"
APPS_DIR="${BASE_DIR}/apps"
SERVICES_DIR="${BASE_DIR}/services"

# Verificar que ambas carpetas existen
if [ ! -d "$APPS_DIR" ] || [ ! -d "$SERVICES_DIR" ]; then
  echo "Error: No se encuentran las carpetas apps o services"
  exit 1
fi

# Función para verificar si un archivo existe en services
# y borrar su correspondiente en apps
verificar_y_limpiar() {
  local app_dir="$1"
  local app_file="$2"
  local service_file_base=$(basename "$app_file" | sed 's/docker-compose\./service-/')
  
  # Si el archivo existe en services, borrarlo de apps
  if [ -f "${SERVICES_DIR}/${service_file_base}" ]; then
    echo "✅ ${service_file_base} existe en services, borrando ${app_file}"
    rm -f "$app_file"
    
    # Si la carpeta queda vacía, borrarla también
    if [ -z "$(ls -A $(dirname "$app_file"))" ]; then
      echo "🗑️  Carpeta $(dirname "$app_file") vacía, eliminando..."
      rmdir "$(dirname "$app_file")"
    fi
  else
    echo "❌ ${service_file_base} NO existe en services, hay que crearlo"
  fi
}

# Recorrer la estructura de apps y verificar cada archivo
find "$APPS_DIR" -type f -name "docker-compose*.yml" | while read -r app_file; do
  verificar_y_limpiar "$APPS_DIR" "$app_file"
done

echo "Proceso completado"

# Actualizar docker-compose.yml para que apunte a services
echo "Actualizando rutas en docker-compose.yml..."
sed -i 's|apps/homeassistant/docker-compose.homeassistant.yml|services/service-homeassistant.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/homeassistant/docker-compose.mqtt.yml|services/service-mqtt.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/homeassistant/docker-compose.esphome.yml|services/service-esphome.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/homeassistant/docker-compose.romassistant.yml|services/service-romassistant.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.jellyfin.yml|services/service-jellyfin.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.jellyseerr.yml|services/service-jellyseerr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.bazarr.yml|services/service-bazarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.sonarr.yml|services/service-sonarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.radarr.yml|services/service-radarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.prowlarr.yml|services/service-prowlarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.transmission.yml|services/service-transmission.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.wizarr.yml|services/service-wizarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.readarr.yml|services/service-readarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.mylar3.yml|services/service-mylar3.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.lidarr.yml|services/service-lidarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.janitorr.yml|services/service-janitorr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.telegram.yml|services/service-telegram.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/mediaserver/docker-compose.plex.yml|services/service-plex.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/dashboard/docker-compose.homarr.yml|services/service-homarr.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/adguard/docker-compose.adguardhome.yml|services/service-adguard.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/adguard/docker-compose.pihole.yml|services/service-pihole.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/nextcloud/docker-compose.nextcloud.yml|services/service-nextcloud.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/tunnel/docker-compose.wireward.yml|services/service-wireward.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/experiments/docker-compose.activepieces.yml|services/service-activepieces.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/experiments/docker-compose.authelia.yml|services/service-authelia.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/experiments/docker-compose.n8n.yml|services/service-n8n.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/experiments/docker-compose.netdata.yml|services/service-netdata.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/experiments/docker-compose.thingsboard.yml|services/service-thingsboard.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/managers/docker-compose.portainer.yml|services/service-portainer.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/nordvpn/docker-compose.nordvpn.yml|services/service-nordvpn.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/watchtower/docker-compose.watchtower.yml|services/service-watchtower.yml|g' "${BASE_DIR}/docker-compose.yml"
sed -i 's|apps/code/docker-compose.code.yml|services/service-code.yml|g' "${BASE_DIR}/docker-compose.yml"

echo "Rutas actualizadas a services/ correctamente."
